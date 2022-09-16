// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

import "ds-test/test.sol";
import "../../lib/utils/Console.sol";
import "../../lib/utils/VyperDeployer.sol";

import "../IERC20BAO.sol";
import "../IVotingEscrow.sol";
import "../IGaugeController.sol";
import "../IMinter.sol";
import "../BaoDistribution.sol";
import "../Swapper.sol";

interface Cheats {
    function deal(address who, uint256 amount) external;
    function warp(uint256 num) external;
    function prank(address sender) external;
    function prank(address sender, address origin) external;
    function startPrank(address sender) external;
    function startPrank(address sender, address origin) external;
    function stopPrank() external;
    function assume(bool condition) external;
}

contract LockDistributionTest is DSTest {

    Cheats public cheats;

    VyperDeployer vyperDeployer = new VyperDeployer();

    IERC20BAO public baoToken;
    IVotingEscrow public voteEscrow;
    IGaugeController public gaugeC;
    IMinter public minter;
    BaoDistribution public distribution;
    Swapper public swap;

    //address public eoaTest = ; find address with some circulating BAOv1 TODO
    
    function setUp() public {
        cheats = Cheats(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

        cheats.deal(address(this), 1000 ether);
        //cheats.deal(eoaTest, 1000 ether);

        //Deploy BAOv2 token contract
        baoToken = IERC20BAO(
            vyperDeployer.deployERC20BAO("ERC20BAO", abi.encode("BAO Token", "BAO", 18))
        );

        //Deploy Voting Escrow contract
        voteEscrow = IVotingEscrow(
            vyperDeployer.deployVy0_2_4("VotingEscrow", abi.encode(address(baoToken), "Vote Escrowed BAO", "veBAO", "0.2.4"))
        );

        //Deploy Gauge Controller for the minter
        gaugeC = new IGaugeController(
            vyperDeployer.deployVy0_2_4("GaugeController", abi.encode(address(baoToken), address(voteEscrow)))
        );

        //Deploy Minter contract
        minter = new IMinter(
            vyperDeployer.deployVy0_2_4("Minter", abi.encode(address(baoToken), address(gaugeC), address(vyperDeployer)))
        );

        //deploy distribution contract with snapshot merkle root
        cheats.prank(address(vyperDeployer));
        distribution = new BaoDistribution(
            address(baoToken),
            address(voteEscrow),
            0x41c02385a07002f9d8fd88c8fb950c308c6f7bf7c748b57ae9b892e291900363,
            address(this)
        );

        //deploy Swapper contract
        cheats.prank(address(vyperDeployer));
        swap = new Swapper(address(minter));

        //transfer initial supply after farms end to the distribution contract
        cheats.prank(address(vyperDeployer));
        baoToken.transfer(address(distribution), 15e26);
        assertEq(baoToken.balanceOf(address(distribution)), 15e26);

    }

    // -------------------------------
    // SWAPPER TESTS
    // -------------------------------

    //function testSwapper() public {} TODO


}
