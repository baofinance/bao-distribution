// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.13;

import "ds-test/test.sol";
import "../BaoDistribution.sol";
import "solmate/utils/FixedPointMathLib.sol";
import "../IERC20BAO.sol";
import "../IVotingEscrow.sol";
import "../../lib/utils/VyperDeployer.sol";

interface Cheats {
    function warp(uint256) external;
    function assume(bool) external;
}

contract LockDistributionTest is DSTest {

    Cheats public cheats;
    BaoDistribution public distribution;
    bytes32[] public proof;
    uint256 public amount;

    VyperDeployer vyperDeployer = new VyperDeployer();

    IERC20BAO baoToken;
    IVotingEscrow voteEscrow;

    function setUp() public {
        cheats = Cheats(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

        bytes memory argsToken = abi.encodeWithSignature(
            "constructor(string, string, uint8)", "BAO Token", "BAO", 18
            );

        // Deploy BAOv2 token
        baoToken = new IERC20BAO(
            vyperDeployer.deployContract(
                "ERC20BAO",
                abi.encodeWithSignature(
                    "constructor(string, string, uint8)", "BAO Token", "BAO", 18
                )
            )
        );

        bytes memory argsVote = abi.encodeWithSignature(
            "constructor(address, string, string, string)", address(baoToken), "Vote Escrowed BAO", "veBAO", "0.2.4"
            );

        //Deploy voting escrow
        voteEscrow = new IVotingEscrow(
            vyperDeployer.deployContract(
                "VotingEscrow", 
                abi.encodeWithSignature(
                    "constructor(address, string, string, string)", address(baoToken), "Vote Escrowed BAO", "veBAO", "0.2.4"
                )
            )
        );

        // Deploy distibution contract
        distribution = new BaoDistribution(
            address(baoToken),
            address(voteEscrow),
            0x46c1f7da0f8cf7398e41724cc3a07901298ea14b7d4b5990062450bdb01ac5ec,
            0x3dFc49e5112005179Da613BdE5973229082dAc35
        );

        // Assign proofs for usage within the tests
        
    }

}