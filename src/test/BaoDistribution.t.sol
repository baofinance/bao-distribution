// SPDX-License-Identifier: GPL-3.0
/*pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "../BAOv2.sol";
import "../BaoDistribution.sol";
import "solmate/utils/FixedPointMathLib.sol";

interface Cheats {
    function warp(uint256) external;
    function assume(bool) external;
}

contract BaoDistributionTest is DSTest {

    Cheats public cheats;
    BaoToken public baoToken;
    BaoDistribution public distribution;
    bytes32[] public proof;
    uint256 public amount;
    uint256 public v2amount;

    function setUp() public {
        cheats = Cheats(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

        // Deploy mock BAOv2 token
        baoToken = new BaoToken(
            "Bao Finance",
            "BAO"
        );

        // The merkle root we provide here is created for testing purposes only. In this merkle tree,
        // this contract's address (0xb4c79dab8f259c7aee6e5b2aa729821864227e84) is owed 1e22 (1000) tokens.
        distribution = new BaoDistribution(
            address(baoToken),
            address(0),
            0x46c1f7da0f8cf7398e41724cc3a07901298ea14b7d4b5990062450bdb01ac5ec,
            0x3dFc49e5112005179Da613BdE5973229082dAc35
        );

        // Mint the amount that this contract will be distributed
        amount = 1e22;
        baoToken.mint(address(distribution), amount / 1000);

        // Assign this contract's proof for usage within the tests
        proof.push(0x3cc9c7db8571b870390438e4fe0a4fcfe1a095ece4444bf77b8ca35f89e93809);
        proof.push(0x4a80075efb29ee18ecf890dbeaeafcc4c1837b96bd648d2362c6e7bce81f656c);

        v2amount = amount / 1000;
    }

    // -------------------------------
    // START DISTRIBUTION TESTS
    // -------------------------------

    function testStartDistribution() public {
        distribution.startDistribution(proof, amount);
    }

    function testFailStartDistributionTwice() public {
        distribution.startDistribution(proof, amount);
        distribution.startDistribution(proof, amount);
    }

    function testFailInvalidProof() public {
        bytes32[] memory _proof;
        distribution.startDistribution(_proof, amount);
    }

    // -------------------------------
    // CLAIM TESTS
    // -------------------------------

    function testClaimable() public {
        distribution.startDistribution(proof, amount);
        uint256 claimable = distribution.claimable(address(this), 0);
        assertEq(claimable, 0);

        uint256 initialTimestamp = block.timestamp;

        // Claim every day, twice a day throughout the 2 year distribution and check if the amount
        // we've received is in-line with the distribution curve each time
        for (uint i; i < 2190; ++i) {
            cheats.warp(block.timestamp + 12 hours);
            distribution.claim();
            assertEq(
                baoToken.balanceOf(address(this)),
                distribution.distCurve(v2amount, _toDays(block.timestamp - initialTimestamp))
            );
        }

        // Ensure the total amount this contract is owed has been claimed after the full distribution.
        assertEq(baoToken.balanceOf(address(this)), v2amount);
        assertEq(baoToken.balanceOf(address(distribution)), 0);
    }

    function testClaimableFuzz(uint64 _daysSince) public {
        cheats.assume(_daysSince <= 1095 days && _daysSince > 0);

        distribution.startDistribution(proof, amount);
        uint256 claimable = distribution.claimable(address(this), 0);
        assertEq(claimable, 0);

        uint256 initialTimestamp = block.timestamp;

        cheats.warp(block.timestamp + _daysSince);
        distribution.claim();
        assertEq(
            baoToken.balanceOf(address(this)),
            distribution.distCurve(v2amount, _toDays(block.timestamp - initialTimestamp))
        );
    }

    function testClaimOnce() public {
        distribution.startDistribution(proof, amount);

        cheats.warp(block.timestamp + 1100 days);
        distribution.claim();


        emit log_named_uint("Amount:", v2amount);
        emit log_named_uint("token.balanceOf:", baoToken.balanceOf(address(this)));
        assertEq(baoToken.balanceOf(address(this)), v2amount);
    }

    function testFailClaimZeroTokens() public {
        distribution.startDistribution(proof, amount);
        distribution.claim();
    }

    function testFailClaimableUnrecognizedAddress() public view {
        distribution.claimable(address(0), 0);
    }

    // -------------------------------
    // END DISTRIBUTION TESTS
    // -------------------------------

    function testFailEndDistributionZeroTokens() public {
        distribution.startDistribution(proof, amount);
        distribution.endDistribution();
    }

    function testEndDistribution(uint64 _daysSince) public {
        cheats.assume(_daysSince <= 1095 days && _daysSince > 0);

        distribution.startDistribution(proof, amount);

        cheats.warp(block.timestamp + _daysSince);
        distribution.endDistribution();

        uint256 _days = _toDays(_daysSince);
        uint256 tokensAccruedToDate =  distribution.distCurve(
            v2amount,
            _days
        );
        uint256 tokensLeft = distribution.distCurve(
            v2amount,
            _toDays(1095 days)
        ) - tokensAccruedToDate;

        uint256 slash = FixedPointMathLib.mulDivDown(
            _days > 365e18 ? 95e16 : 1e18 - FixedPointMathLib.mulDivDown(_days, 1369863013, 1e13),
            tokensLeft,
            1e18
        );
        uint256 owed = tokensLeft - slash;

        uint256 selfBalance = baoToken.balanceOf(address(this));
        uint256 treasuryBalance = baoToken.balanceOf(distribution.treasury());

        // Ensure that the account received the predicted amount of owed tokens
        assertEq(selfBalance, tokensAccruedToDate + owed);
        // Ensure that the treasury received the predicted amount of slashed tokens
        assertEq(treasuryBalance, slash);
        // Ensure that the entirety of tokens were distributed amongst the account and the treasury
        assertEq(selfBalance + treasuryBalance, v2amount);
    }

    // -------------------------------
    // HELPERS
    // -------------------------------

    function _toDays(uint256 d) private pure returns (uint256) {
        return FixedPointMathLib.mulDivDown(d, 1e18, 86400);
    }
}*/
