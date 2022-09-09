// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "@openzeppelin/token/ERC20/IERC20.sol";
import "solmate/utils/FixedPointMathLib.sol";
import "solmate/utils/ReentrancyGuard.sol";
import "@openzeppelin/utils/cryptography/MerkleProof.sol";
import "./IVotingEscrow.sol";

contract BaoDistribution is ReentrancyGuard {

    // -------------------------------
    // VARIABLES
    // -------------------------------

    //BaoToken public baoToken;
    IERC20 public baoToken;
    IVotingEscrow public votingEscrow;
    mapping(address => DistInfo) public distributions;
    address public treasury;

    // -------------------------------
    // CONSTANTS
    // -------------------------------

    bytes32 public immutable merkleRoot;

    // -------------------------------
    // STRUCTS
    // -------------------------------

    struct DistInfo {
        uint64 dateStarted;
        uint64 dateEnded;
        uint64 lastClaim;
        uint256 amountOwedTotal;
    }

    // -------------------------------
    // EVENTS
    // -------------------------------

    event DistributionStarted(address _account);
    event TokensClaimed(address _account, uint256 _amount);
    event DistributionEnded(address _account, uint256 _amount);
    event DistributionLocked(address _account, uint256 _amount);

    // -------------------------------
    // CUSTOM ERRORS
    // -------------------------------

    error DistributionAlreadyStarted();
    error DistributionEndedEarly();
    error InvalidProof(address _account, uint256 _amount, bytes32[] _proof);
    error ZeroClaimable();
    error InvalidTimestamp();
    error outsideLockRange();

    /**
     * Create a new BaoDistribution contract.
     *
     * @param _baoToken Token to distribute.
     * @param _votingEscrow vote escrow BAO contract
     * @param _merkleRoot Merkle root to verify accounts' inclusion and amount owed when starting their distribution.
     */
    constructor(address _baoToken, address _votingEscrow ,bytes32 _merkleRoot, address _treasury) {
        baoToken = IERC20(_baoToken);
        votingEscrow = IVotingEscrow(_votingEscrow);
        merkleRoot = _merkleRoot;
        treasury = _treasury;
    }

    // -------------------------------
    // PUBLIC FUNCTIONS
    // -------------------------------

    /**
     * Starts the distribution of BAO for msg.sender.
     *
     * @param _proof Merkle proof to verify msg.sender's inclusion and claimed amount.
     * @param _amount Amount of tokens msg.sender is owed. Used to generate the merkle tree leaf.
     */
    function startDistribution(bytes32[] memory _proof, uint256 _amount) external {
        if (distributions[msg.sender].dateStarted != 0) {
            revert DistributionAlreadyStarted();
        } else if (!verifyProof(_proof, keccak256(abi.encodePacked(msg.sender, _amount)))) {
            revert InvalidProof(msg.sender, _amount, _proof);
        }

        uint64 _now = uint64(block.timestamp);
        distributions[msg.sender] = DistInfo(
            _now,
            0,
            _now,
            _amount
        );
        emit DistributionStarted(msg.sender);
    }

    /**
     * Claim all tokens that have been accrued since msg.sender's last claim.
     */
    function claim() external nonReentrant {
        uint256 _claimable = claimable(msg.sender, 0);
        if (_claimable == 0) {
            revert ZeroClaimable();
        }

        // Update account's DistInfo
        distributions[msg.sender].lastClaim = uint64(block.timestamp);

        // Send account the tokens that they've accrued since their last claim.
        baoToken.transfer(msg.sender, _claimable);

        // Emit tokens claimed event for logging
        emit TokensClaimed(msg.sender, _claimable);
    }

    /**
     * Claim all tokens that have been accrued since msg.sender's last claim AND
     * the rest of the total locked amount owed immediately at a pre-defined slashed rate.
     *
     * Slash Rate:
     * days_since_start <= 365: (100 - .01369863013 * days_since_start)%
     * days_since_start > 365: 95%
     */
    function endDistribution() external nonReentrant {
        uint256 _claimable = claimable(msg.sender, 0);
        if (_claimable == 0) {
            revert ZeroClaimable();
        }

        DistInfo storage distInfo = distributions[msg.sender];
        uint64 timestamp = uint64(block.timestamp);

        uint256 daysSinceStart = FixedPointMathLib.mulDivDown(uint256(timestamp - distInfo.dateStarted), 1e18, 86400);

        // Calculate total tokens left in distribution after the above claim
        uint256 tokensLeft = distInfo.amountOwedTotal - distCurve(distInfo.amountOwedTotal, daysSinceStart);

        // Calculate slashed amount
        uint256 slash = FixedPointMathLib.mulDivDown(
            daysSinceStart > 365e18 ? 95e16 : 1e18 - FixedPointMathLib.mulDivDown(daysSinceStart, 1369863013, 1e13),
            tokensLeft,
            1e18
        );
        uint256 owed = tokensLeft - slash;

        // Account gets slashed for (slash / tokensLeft)% of their remaining distribution
        baoToken.transfer(msg.sender, owed + _claimable);
        // Protocol treasury receives slashed tokens
        baoToken.transfer(treasury, slash);

        // Update DistInfo storage for account to reflect the end of the account's distribution
        distInfo.lastClaim = timestamp;
        distInfo.dateEnded = timestamp;

        // Emit tokens claimed event for logging
        emit TokensClaimed(msg.sender, _claimable);
        // Emit distribution ended event for logging
        emit DistributionEnded(msg.sender, owed);
    }

    /**
     * Lock all tokens that have NOT been claimed since msg.sender's last claim
     *
     * The Lock into veBAO will be set at _time with this function in-line with length of distribution curve (minimum of 3 years)
     */
    function lockDistribution(uint256 _time) external nonReentrant {
        uint256 _claimable = claimable(msg.sender, 0);
        if (_claimable == 0) {
            revert ZeroClaimable();
        }
        if (_time < 94608000) {
            revert outsideLockRange();
        }

        DistInfo storage distInfo = distributions[msg.sender];
        uint64 timestamp = uint64(block.timestamp);

        uint256 daysSinceStart = FixedPointMathLib.mulDivDown(uint256(timestamp - distInfo.dateStarted), 1e18, 86400);

        // Calculate total tokens left in distribution after the above claim
        uint256 tokensLeft = distInfo.amountOwedTotal - distCurve(distInfo.amountOwedTotal, daysSinceStart);

        baoToken.approve(address(votingEscrow), tokensLeft);

        //lock tokensLeft for msg.sender for _time years (minimum of 3 years)
        votingEscrow.create_lock_for(msg.sender, tokensLeft, _time);

        emit DistributionLocked(msg.sender, tokensLeft);
    }

    /**
     * Get how many tokens an account is able to claim at a given timestamp. 0 = now.
     * This function takes into account the date of the account's last claim, and returns the amount
     * of tokens they've accrued since.
     *
     * @param _account Account address to query.
     * @param _timestamp Timestamp to query.
     * @return c _account's claimable tokens, scaled by 1e18.
     */
    function claimable(address _account, uint64 _timestamp) public view returns (uint256 c) {
        DistInfo memory distInfo = distributions[_account];
        uint64 dateStarted = distInfo.dateStarted;
        if (dateStarted == 0) {
            revert ZeroClaimable();
        } else if (distInfo.dateEnded != 0) {
            revert DistributionEndedEarly();
        }

        uint64 timestamp = _timestamp == 0 ? uint64(block.timestamp) : _timestamp;
        if (timestamp < dateStarted) {
            revert InvalidTimestamp();
        }

        uint256 daysSinceStart = FixedPointMathLib.mulDivDown(uint256(timestamp - dateStarted), 1e18, 86400);
        uint256 daysSinceClaim = FixedPointMathLib.mulDivDown(uint256(timestamp - distInfo.lastClaim), 1e18, 86400);

        // Allow the account to claim all tokens accrued since the last time they've claimed.
        uint256 _total = distInfo.amountOwedTotal;
        c = distCurve(_total, daysSinceStart) - distCurve(_total, daysSinceStart - daysSinceClaim);
    }

    /**
     * Get the amount of tokens that would have been accrued along the distribution curve, assuming _daysSinceStart
     * days have passed and the account has never claimed.
     *
     * f(x) = 0 <= x <= 1095 : (2x/219)^2
     *
     * @param _amountOwedTotal Total amount of tokens owed, scaled by 1e18.
     * @param _daysSinceStart Time since the start of the distribution, scaled by 1e18.
     * @return _amount Amount of tokens accrued on the distribution curve, assuming the time passed is _daysSinceStart.
     */
    function distCurve(uint256 _amountOwedTotal, uint256 _daysSinceStart) public pure returns (uint256 _amount) {
        if (_daysSinceStart >= 1095e18) return _amountOwedTotal;

        assembly {
            // Solmate's mulDivDown function
            function mulDivDown(x, y, denominator) -> z {
                // Store x * y in z for now.
                z := mul(x, y)

                // Equivalent to require(denominator != 0 && (x == 0 || (x * y) / x == y))
                if iszero(and(iszero(iszero(denominator)), or(iszero(x), eq(div(z, x), y)))) {
                    revert(0, 0)
                }

                // Divide z by the denominator.
                z := div(z, denominator)
            }

            // This is disgusting, but its more gas efficient than storing the results in `_amount` each time.
            _amount := mulDivDown( // Multiply `amountOwedTotal` by distribution curve result
                div( // Correct precision after exponent op (scale down by 1e20 instead of 1e18 to convert % to a proportion)
                    exp( // Raise result to the power of two
                        mulDivDown( // (2/219) * `_daysSinceStart`
                            mulDivDown(0x1BC16D674EC80000, 0xDE0B6B3A7640000, 0xBDF3C4BB0328C0000),
                            _daysSinceStart,
                            0xDE0B6B3A7640000
                        ),
                        2
                    ),
                    0xDE0B6B3A7640000
                ),
                _amountOwedTotal,
                0x56BC75E2D63100000
            )
        }
    }

    // -------------------------------
    // PRIVATE FUNCTIONS
    // -------------------------------

    /**
     * Verifies a merkle proof against the stored root.
     *
     * @param _proof Merkle proof.
     * @param _leaf Leaf to verify.
     * @return bool True if proof is valid, false if proof is invalid.
     */
    function verifyProof(bytes32[] memory _proof, bytes32 _leaf) private view returns (bool) {
        return MerkleProof.verify(_proof, merkleRoot, _leaf);
    }
}
