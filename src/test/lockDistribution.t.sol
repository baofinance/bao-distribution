// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

import "ds-test/test.sol";
import "../../lib/utils/Console.sol";
import "../../lib/utils/VyperDeployer.sol";
import "solmate/utils/FixedPointMathLib.sol";

import "../IERC20BAO.sol";
import "../IVotingEscrow.sol";
import "../BaoDistribution.sol";

interface Cheats {
    function deal(address who, uint256 amount) external;
    function warp(uint256 num) external;
    function prank(address sender) external;
    function startPrank(address sender) external;
    function stopPrank() external;
    function assume(bool condition) external;
}

//snapshot merkle root = 0x41c02385a07002f9d8fd88c8fb950c308c6f7bf7c748b57ae9b892e291900363

contract LockDistributionTest is DSTest {

    Cheats public cheats;

    VyperDeployer vyperDeployer = new VyperDeployer();

    IERC20BAO public baoToken;
    IVotingEscrow public voteEscrow;
    BaoDistribution public distribution;

    address public eoa1 = 0x48B72465FeD54964a9a0bb2FB95DBc89571604eC;
    address public eoa2 = 0x609991ca0Ae39BC4EAF2669976237296D40C2F31;

    bytes32[] public proof1;
    uint256 public amount1 = 53669753833360467444414559923;
    bytes32[] public proof2;
    uint256 public amount2 = 44599721927768192099018289499;
    
    function setUp() public {
        cheats = Cheats(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

        cheats.deal(address(this), 1000 ether);
        cheats.deal(eoa1, 1000 ether);
        cheats.deal(eoa2, 1000 ether);

        //Deploy BAOv2 token contract
        baoToken = IERC20BAO(
            vyperDeployer.deployERC20BAO("ERC20BAO", abi.encode("BAO Token", "BAO", 18))
        );

        //Deploy Voting Escrow contract
        voteEscrow = IVotingEscrow(
            vyperDeployer.deployVoteEscrow("VotingEscrow", abi.encode(address(baoToken), "Vote Escrowed BAO", "veBAO", "0.2.4"))
        );

        //deploy distribution contract with snapshot merkle root
        cheats.prank(address(vyperDeployer));
        distribution = new BaoDistribution(
            address(baoToken),
            address(voteEscrow),
            0x41c02385a07002f9d8fd88c8fb950c308c6f7bf7c748b57ae9b892e291900363,
            address(this)
        );

        proof1.push(0x7c55d8a6ded3b13b342fc383df5bb934076f49a6598303ea68ea78ae4630d445);
        proof1.push(0x44db9ee999de8b628c5de2592b347008ebd4e77b94f4ef1d121a4aca6e8e8d51);
        proof1.push(0xb6a829733a6f85d368893b416f8a967e2189681368d3788134eee3c5bf22e976);  
        proof1.push(0xb0232903c4ba9256861d60a6ca9d933cb8db387d8a6cecc1cbc178e5d91eacf5);
        proof1.push(0x7643968dd707041b7737a52d1fee41fe8ee37ada29585e37b92a090cb91ae86a);  
        proof1.push(0x3c0d2d3a207e8e01f4c7442bfa1adbfd25ba072c213bc8406a182fb61cb78401);
        proof1.push(0x0afca7cc1288693408e2857ddec8b2b4dea74215f0b9219421773ab0b31b8a11);  
        proof1.push(0x8310cf070515dcb50f13259a1f5cf52c6bd7db2f3004525eaf17c6335ccd333c);
        proof1.push(0xbe44074166d23ae6832865be9972f4f3776a903e1a5e9e2c1780313fe629dfa3);  
        proof1.push(0xbaba52a8a741481583014f906912d7870d53fd776fb6529ec6fca8af2b6877d0);
        proof1.push(0x74e8548f3229e22c31e75e2f80ac2757237cc8b435d3658438927bfa891b9763);  
        proof1.push(0x9d7ff74eec600ac6ffe42f02d4ae6b16219c714e02a535e853850ba9e7677878);
        proof1.push(0x4b7feb1f0234422835771be9152c527c22a60ca378ce2fc7f350c1aa8e115032);

        proof2.push(0x61120ad1ad69e9dd4a8d0e4d2d72006872704ad09437e8b1124c6c6fd4cbcc62);
        proof2.push(0xf16a00483fdd6b232b1f8dc1d38f2d7736f6326fb498207fadd565a15ac799c6);
        proof2.push(0xf72e7bd6f83b1718aebfd662c53f91d4d725f3a3a64dce05fa79a5cd4087c0a2);
        proof2.push(0xeb1b599fcd9f71c9248aff66751e0b491a8cf782e043f8120dc0793afe48ac54);
        proof2.push(0xed8b77dc630a5538c387930f522ab42202582fa0c0f899cebb17504eb31a28ac);
        proof2.push(0x33f6a6cd5c4266276c16d988bf0ae11a5665832a4edeec1e4421148b7a3224a8);
        proof2.push(0x978e16008e26fc2e5f05d2416a29a90b9ef351adbf3c45f5bd905d91ecbac340);
        proof2.push(0x91c2521e2283a0671b6bfd8b3d0b042484750c7e8a44f4a828b14a4efca87c8d);
        proof2.push(0xcad3ba78a0da6131dd8a1ad22c81b15f85cc327a86317372f465361afcb2f34a);
        proof2.push(0x9590cb84d66eed07dd9556fbc7ba6aae3f1864bd0db0a704c40a2b11489f8464);
        proof2.push(0x56c84b5ef64065935078154d1631bda16d44c06db4abd19aac7bd420feccaab2);
        proof2.push(0x9d7ff74eec600ac6ffe42f02d4ae6b16219c714e02a535e853850ba9e7677878);
        proof2.push(0x4b7feb1f0234422835771be9152c527c22a60ca378ce2fc7f350c1aa8e115032);

        cheats.prank(address(vyperDeployer));
        baoToken.transfer(address(distribution), 15e26);
        assertEq(baoToken.balanceOf(address(distribution)), 15e26);

        cheats.prank(address(vyperDeployer));
        voteEscrow.commit_distr_contract(address(distribution));
        cheats.prank(address(vyperDeployer));
        voteEscrow.apply_distr_contract();

    }

    // -------------------------------
    // LOCK DISTRIBUTION TESTS
    // -------------------------------

    function testLockDistr() public { 
        cheats.startPrank(eoa1);//******************** */

        distribution.startDistribution(proof1, amount1);
        assertEq(distribution.claimable(eoa1, 0), 0);

        emit log_named_address("admin", address(vyperDeployer));
        emit log_named_address("distr address", address(distribution));
        emit log_named_address("ve address", address(voteEscrow));
        emit log_named_address("token address", address(baoToken));
        emit log_named_address("eoa1 address", eoa1);
        emit log_named_address("eoa2 address", eoa2);

        cheats.warp(block.timestamp + 1 days);

        emit log_named_uint("claimable balance", distribution.claimable(eoa1, uint64(block.timestamp)));
        emit log_named_uint("distribution balance", baoToken.balanceOf(address(distribution)));

        distribution.lockDistribution(block.timestamp + 94608000);  //distr calls vote escrow | 4yr = 126144000 | 3 yr = 94608000

        voteEscrow.increase_unlock_time(block.timestamp + 126144000);

        emit log_named_uint("ve balance for eoa1", voteEscrow.balanceOf(eoa1));

        cheats.warp(block.timestamp + 94608001);
        emit log_named_uint("ve balance for eoa1", voteEscrow.balanceOf(eoa1));

        voteEscrow.withdraw();

        voteEscrow.create_lock(amount1, block.timestamp + 21 days);
        cheats.warp(block.timestamp + 7 days);
        voteEscrow.increase_unlock_time(block.timestamp + 365 days);

        uint256 end1 = voteEscrow.locked__end(eoa1);

        cheats.stopPrank();//*********************** */

        
    }

    

    // -------------------------------
    // HELPERS
    // -------------------------------

    function _toDays(uint256 d) private pure returns (uint256) {
        return FixedPointMathLib.mulDivDown(d, 1e18, 86400);
    }

}
