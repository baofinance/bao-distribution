// SPDX-License-Identifier: MIT
pragma solidity >=0.8.13;

import "ds-test/test.sol";
import "../../lib/utils/Console.sol";
import "../../lib/utils/VyperDeployer.sol";
import "solmate/utils/FixedPointMathLib.sol";
import "solmate/tokens/ERC20.sol";

import "../IERC20BAO.sol";
import "../IVotingEscrow.sol";
import "../BaoDistribution.sol";
import "../Swapper.sol";
import "../SmartWalletWhitelist.sol";

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
    BaoDistribution public distribution;
    Swapper public swap;
    SmartWalletWhitelist public whitelist;
    ERC20 public baoV1;

    address public eoa1 = 0x48B72465FeD54964a9a0bb2FB95DBc89571604eC;
    address public eoaTest = 0xD1AE4d9205F07333916f628850Fc79f1366dC2F8;

    address public dev_wallet = 0x8f5d46FCADEcA93356B70F40858219bB1FBf6088;
    address public liq_wallet = 0x3f3243E7776122B1b968b5E74B3DdB971FBed9de;
    address public community_wallet = 0x609991ca0Ae39BC4EAF2669976237296D40C2F31;
    address public treasury = 0x3dFc49e5112005179Da613BdE5973229082dAc35;

    bytes32[] public proof1;
    uint256 public amount1 = 53669753833360467444414559923;

    bytes32[] public dev_proof;
    uint256 public dev_amount = 42326858440355495550732761394; 
    bytes32[] public liq_proof;
    uint256 public liq_amount = 15741078327447597211418129471;
    bytes32[] public community_proof;
    uint256 public community_amount = 44599721927768192099018289499;
    
    function setUp() public {
        cheats = Cheats(0x7109709ECfa91a80626fF3989D68f67F5b1DD12D);

        cheats.deal(address(this), 1000 ether);
        cheats.deal(eoa1, 1000 ether);
        cheats.deal(eoaTest, 1000 ether);
        
        //set baov1
        baoV1 = ERC20(0x374CB8C27130E2c9E04F44303f3c8351B9De61C1);

        //Deploy BAOv2 token contract
        baoToken = IERC20BAO(
            vyperDeployer.deployERC20BAO("ERC20BAO", abi.encode("BAO Token", "BAO", 18))
        );

        //Deploy Voting Escrow contract
        voteEscrow = IVotingEscrow(
            vyperDeployer.deployVy0_2_4("VotingEscrow", abi.encode(address(baoToken), "Vote Escrowed BAO", "veBAO", "0.2.4"))
        );

        //deploy distribution contract with snapshot merkle root
        cheats.prank(address(vyperDeployer));
        distribution = new BaoDistribution(
            address(baoToken),
            address(voteEscrow),
            0xbc39affb2a6f4c1e539660ab71ae1554d613a42413e154a6223dd7c868432e58, //actual snapshot root
            address(this)
        );

        //deploy Swapper contract
        cheats.prank(address(vyperDeployer));
        swap = new Swapper(address(baoToken));

        //deploy whitelist
        whitelist = new SmartWalletWhitelist(
            address(vyperDeployer),
            address(distribution)
        );

        //store merkle proofs
        proof1.push(0x7c3ac7455005dcd76d3cd38b4dbc59436ed10518b4bf13c8d339e19ad7ad9182);
        proof1.push(0x63c24f74f56ff175222c700f7cb2245efb76261c8a837257d0acef1ade318a52);
        proof1.push(0xc3aa6dc99375c39d4d0f702727627b79bf3bbb304d5db1ad6a5ade9fff7e0747);
        proof1.push(0xf6721c3a9c6b6c67b761fa7077f839bb03b09690131d05b8b25d0f6e3d531b0e);
        proof1.push(0xd815d28f757ebb7c5d4a3c1b59bc8a993e3172f5592d2c91163763c2ac7af98a);  
        proof1.push(0x3fa6b4bafad03d3d9e6c2f8644cd53573e2b3fd7f028c964f982c9649014b465);
        proof1.push(0x92590ddd183a07dfdc1f2ca598a1895afef2a99c1a97e5f0c5ff38a60dc75087); 
        proof1.push(0x1349eae8f28e58bb18abca40ac34e4c0ac7a42ebcd6ad0077ef6794ba5af723f);
        proof1.push(0xcc4644a444b971cab2e874b3987bad9afdaa98b148bcbcae75d51f543ecb002c); 
        proof1.push(0x059f955408c4bed501bbe3781acce6c1c878753ec1d7d0e7c712ac720f488c0a);
        proof1.push(0xd1637f0fff0fad17e8f90a0cd7677f18d31d69de9396e4f83ceb7b03b9195fca);
        proof1.push(0x8288fc9886f278b1464fecfb1b27178c1c3864991d427c1a4e168e93219c97e3);
        proof1.push(0xe454ca7df21af8d03d28d93139e4b7ded0eb60bd98545fe7482197f8d2dd23c6);

        dev_proof.push(0x7c3ac7455005dcd76d3cd38b4dbc59436ed10518b4bf13c8d339e19ad7ad9182);
        dev_proof.push(0x63c24f74f56ff175222c700f7cb2245efb76261c8a837257d0acef1ade318a52);
        dev_proof.push(0x447b543c7f1c2c63e9ac5d0a588ad1e9d993b206d57594464dda381809589b13);  
        dev_proof.push(0x8a61f36e561c00e321707b88eda40f7779ec8d63c1a26c2c695fb74474e96e0f);
        dev_proof.push(0x31ab762b645a50038973245d1ba4dbac71350f4f68de39fff1c8cfbc279d255c);  
        dev_proof.push(0x09593f06d7c4d67426e6449f3c5f517660537edd6fac422c675d1623867667ba);
        dev_proof.push(0x6268964c0a64711b834d8d9373ad4591f90e259afe9fd63048ad18d3900bbe5d);  
        dev_proof.push(0xa60abf2a5dc406f7d0e38ba7927b4f0b8f7c00e11d24157c7cb109df487f8b27);
        dev_proof.push(0xacd04cdd0680e67386f8dda62559861f2e018479cb5e2aecbead3c327813be2d);  
        dev_proof.push(0xc946365c87d8e929913b147ffb95b45a28220ed964846ec8636b2ea7b1b3e8a1);
        dev_proof.push(0x926dc27cd416e15363595915ec5ca22a005a5f02be7480c5860b7be97de6d9f0);
        dev_proof.push(0x16a2e7d223f638cabe4c7e58878ec7dfced40021795eaf1c052c40da529c7698);
        dev_proof.push(0xde5745fc234d2a9bc5f8ee2a8e7704266a16b02d3c0f10a0339b34f6b8105969);

        liq_proof.push(0x7c3ac7455005dcd76d3cd38b4dbc59436ed10518b4bf13c8d339e19ad7ad9182);
        liq_proof.push(0x63c24f74f56ff175222c700f7cb2245efb76261c8a837257d0acef1ade318a52);
        liq_proof.push(0x447b543c7f1c2c63e9ac5d0a588ad1e9d993b206d57594464dda381809589b13);  
        liq_proof.push(0x8a61f36e561c00e321707b88eda40f7779ec8d63c1a26c2c695fb74474e96e0f);
        liq_proof.push(0x31ab762b645a50038973245d1ba4dbac71350f4f68de39fff1c8cfbc279d255c);  
        liq_proof.push(0x09593f06d7c4d67426e6449f3c5f517660537edd6fac422c675d1623867667ba);
        liq_proof.push(0x6268964c0a64711b834d8d9373ad4591f90e259afe9fd63048ad18d3900bbe5d);  
        liq_proof.push(0xa60abf2a5dc406f7d0e38ba7927b4f0b8f7c00e11d24157c7cb109df487f8b27);
        liq_proof.push(0xacd04cdd0680e67386f8dda62559861f2e018479cb5e2aecbead3c327813be2d);  
        liq_proof.push(0xc946365c87d8e929913b147ffb95b45a28220ed964846ec8636b2ea7b1b3e8a1);
        liq_proof.push(0x926dc27cd416e15363595915ec5ca22a005a5f02be7480c5860b7be97de6d9f0);
        liq_proof.push(0x16a2e7d223f638cabe4c7e58878ec7dfced40021795eaf1c052c40da529c7698);
        liq_proof.push(0xde5745fc234d2a9bc5f8ee2a8e7704266a16b02d3c0f10a0339b34f6b8105969);

        community_proof.push(0x7c3ac7455005dcd76d3cd38b4dbc59436ed10518b4bf13c8d339e19ad7ad9182);
        community_proof.push(0x63c24f74f56ff175222c700f7cb2245efb76261c8a837257d0acef1ade318a52);
        community_proof.push(0x447b543c7f1c2c63e9ac5d0a588ad1e9d993b206d57594464dda381809589b13);  
        community_proof.push(0x8a61f36e561c00e321707b88eda40f7779ec8d63c1a26c2c695fb74474e96e0f);
        community_proof.push(0x31ab762b645a50038973245d1ba4dbac71350f4f68de39fff1c8cfbc279d255c);  
        community_proof.push(0x09593f06d7c4d67426e6449f3c5f517660537edd6fac422c675d1623867667ba);
        community_proof.push(0x6268964c0a64711b834d8d9373ad4591f90e259afe9fd63048ad18d3900bbe5d);  
        community_proof.push(0xa60abf2a5dc406f7d0e38ba7927b4f0b8f7c00e11d24157c7cb109df487f8b27);
        community_proof.push(0xacd04cdd0680e67386f8dda62559861f2e018479cb5e2aecbead3c327813be2d);  
        community_proof.push(0xc946365c87d8e929913b147ffb95b45a28220ed964846ec8636b2ea7b1b3e8a1);
        community_proof.push(0x926dc27cd416e15363595915ec5ca22a005a5f02be7480c5860b7be97de6d9f0);
        community_proof.push(0x16a2e7d223f638cabe4c7e58878ec7dfced40021795eaf1c052c40da529c7698);
        community_proof.push(0xde5745fc234d2a9bc5f8ee2a8e7704266a16b02d3c0f10a0339b34f6b8105969);

        emit log_named_uint("admin balance before setup", baoToken.balanceOf(address(vyperDeployer)));
        //1,091,753,221 total

        //transfer initial locked supply after farms end to the distribution contract
        //832,364,383.418932981187447848
        cheats.prank(address(vyperDeployer));
        baoToken.transfer(address(distribution), 832364383418932981187447848);
        emit log_named_uint("admin balance after locked is sent to distr contract", baoToken.balanceOf(address(vyperDeployer)));
        
        //transfer balance to swapper contract
        //166,850,344.226331394130869546
        cheats.prank(address(vyperDeployer));
        baoToken.transfer(address(swap), 166850344226331394130869546);
        emit log_named_uint("admin balance after both swapper and distr are funded", baoToken.balanceOf(address(vyperDeployer)));

        //treasury lock balance transferred to treasury
        //92,538,492.678164717714597057
        cheats.prank(address(vyperDeployer));
        baoToken.transfer(treasury, 92538492678164717714597057);

        emit log_named_uint("admin balance should be ~0", baoToken.balanceOf(address(vyperDeployer)));
        emit log_named_uint("distr balance received", baoToken.balanceOf(address(distribution)));
        emit log_named_uint("swapper balance received", baoToken.balanceOf(address(swap)));
        emit log_named_uint("treasury balance received", baoToken.balanceOf(treasury));
        assertEq(baoToken.balanceOf(address(distribution)), 832364383418932981187447848);
        assertEq(baoToken.balanceOf(address(swap)), 166850344226331394130869546);
        assert(baoToken.balanceOf(treasury) >= 92538492678164717714597057);

        //commit and apply distribution contract to the voting escrow contract
        cheats.prank(address(vyperDeployer));
        voteEscrow.commit_distr_contract(address(distribution));
        cheats.prank(address(vyperDeployer));
        voteEscrow.apply_distr_contract();

        //commit and apply whitelist contract to the voting escrow contract
        cheats.prank(address(vyperDeployer));
        voteEscrow.commit_smart_wallet_checker(address(whitelist));
        cheats.prank(address(vyperDeployer));
        voteEscrow.apply_smart_wallet_checker();
    }


    // -------------------------------
    // MERKLE ROOT SNAPSHOT TESTS
    // -------------------------------

    //old dev wallet :       0x8f5d46FCADEcA93356B70F40858219bB1FBf6088
    //old Liquidity wallet : 0x3f3243E7776122B1b968b5E74B3DdB971FBed9de
    //old Community wallet : 0x609991ca0Ae39BC4EAF2669976237296D40C2F31

    function testFailDevWalletProof() public {
        cheats.startPrank(dev_wallet);
        emit log_named_uint("token balance before call: ", baoToken.balanceOf(dev_wallet));
        distribution.startDistribution(dev_proof, dev_amount);
        cheats.stopPrank();
    }

    function testFailLiqWalletProof() public {
        cheats.startPrank(liq_wallet);
        emit log_named_uint("token balance before call: ", baoToken.balanceOf(dev_wallet));
        distribution.startDistribution(liq_proof, liq_amount);
        cheats.stopPrank();
    }

    function testFailComWalletProof() public {
        cheats.startPrank(community_wallet);
        emit log_named_uint("token balance before call: ", baoToken.balanceOf(dev_wallet));
        distribution.startDistribution(dev_proof, dev_amount);
        cheats.stopPrank();
    }

    // -------------------------------
    // LOCK DISTRIBUTION TESTS
    // -------------------------------

    function testLockDistrOnce() public {
        cheats.startPrank(eoa1, eoa1);

        emit log_named_uint("token balance before lock", baoToken.balanceOf(eoa1)); 

        distribution.startDistribution(proof1, amount1); //start distribution for eoa 1
        assertEq(distribution.claimable(eoa1, 0), 0); //assert 0 claimable as no time has passed
        assertEq(voteEscrow.totalSupply(), 0); //no locks yet, should be 0

        cheats.warp(block.timestamp + 1);

        distribution.lockDistribution(block.timestamp + 126144000); //eoa1 locks for 4 years
        emit log_named_uint("ve balance after lock", voteEscrow.balanceOf(eoa1));
        emit log_named_uint("token balance after lock", baoToken.balanceOf(eoa1));

        // assert tokens left in distribution is the same as vote escrow balance (output is not exact because of ve math but 4 years puts them almost 1:1)
        // 1 BAO locked for 4 years = ~1 veBAO, where veBAO is less than BAO balance
        // 53669753833360461448429661, tokensLeft calculation from distribution
        // 53418898874984233935234217, actual ve Balance after the lock call
        // 0                           circulating balance before lock
        // 0                           circulating balance after lock

        cheats.warp(block.timestamp + 126144001);
        emit log_named_uint("ve balance after expiry", voteEscrow.balanceOf(eoa1));

        voteEscrow.withdraw(); //withdraw veBAO to BAO

        emit log_named_uint("ve balance after withdraw", voteEscrow.balanceOf(eoa1));
        emit log_named_uint("token balance after withdraw", baoToken.balanceOf(eoa1));

        cheats.stopPrank();
    }

    function testFailLockDistrTwice() public {
        cheats.startPrank(eoa1, eoa1);

        emit log_named_uint("token balance before lock", baoToken.balanceOf(eoa1)); 

        distribution.startDistribution(proof1, amount1); //start distribution for eoa 1
        assertEq(distribution.claimable(eoa1, 0), 0); //assert 0 claimable as no time has passed
        assertEq(voteEscrow.totalSupply(), 0); //no locks yet, should be 0

        cheats.warp(block.timestamp + 1);

        distribution.lockDistribution(block.timestamp + 126144000); //eoa1 locks for 4 years
        emit log_named_uint("ve balance after lock", voteEscrow.balanceOf(eoa1));
        emit log_named_uint("token balance after lock", baoToken.balanceOf(eoa1));

        distribution.lockDistribution(block.timestamp + 94608000); //reverts as there is already an existing lock

        cheats.stopPrank();
    }

    function testFailInvalidProofAddr() public {
        cheats.startPrank(address(this), address(this));

        distribution.lockDistribution(block.timestamp + 126144000); //startDistribution() was not succesffuly called before hand, revert

        cheats.stopPrank();
    }

    function testFailClaimAfterLock() public {
        cheats.startPrank(eoa1, eoa1);

        emit log_named_uint("token balance before lock", baoToken.balanceOf(eoa1)); 

        distribution.startDistribution(proof1, amount1); //start distribution for eoa 1
        assertEq(distribution.claimable(eoa1, 0), 0); //assert 0 claimable as no time has passed
        assertEq(voteEscrow.totalSupply(), 0); //no locks yet, should be 0

        cheats.warp(block.timestamp + 1);

        distribution.lockDistribution(block.timestamp + 126144000); //eoa1 locks for 4 years
        emit log_named_uint("ve balance after lock", voteEscrow.balanceOf(eoa1));
        emit log_named_uint("token balance after lock", baoToken.balanceOf(eoa1));

        distribution.claim(); //should revert as lockDistribution() was already called

        cheats.stopPrank();
    }

    function testClaimBeforeLockDistr() public {
        cheats.startPrank(eoa1, eoa1);
        
        distribution.startDistribution(proof1, amount1); //start distribution for eoa 1
        assertEq(distribution.claimable(eoa1, 0), 0); //assert 0 claimable as no time has passed

        cheats.warp(block.timestamp + 365 days);

        emit log_named_uint("token balance before claim", baoToken.balanceOf(eoa1));
        uint256 beforeClaimBal1 = distribution.claimable(eoa1, uint64(block.timestamp));

        distribution.claim(); //eoa1 claims after 1 year

        emit log_named_uint("token balance after claim", baoToken.balanceOf(eoa1));

        assertEq(baoToken.balanceOf(eoa1), beforeClaimBal1); //assert eoa1 received the right amount from claim
        assertEq(distribution.claimable(eoa1, uint64(block.timestamp)), 0); //claimable should now be 0
        assertEq(voteEscrow.totalSupply(), 0); //no locks yet, should be 0

        cheats.warp(block.timestamp + 1);

        distribution.lockDistribution(block.timestamp + 126144000); //eoa1 locks for 4 years after claiming once a year after the distribution was started
        emit log_named_uint("ve balance", voteEscrow.balanceOf(eoa1));

        assertEq(voteEscrow.balanceOf(eoa1), voteEscrow.totalSupply()); //assert eoa1 balance is total supply as its the only lock in existence

        // assert tokens left in distribution is the same as vote escrow balance (output is not exact because of ve math but 4 years puts them almost 1 to 1)
        // 1 BAO locked for 4 years = ~1 veBAO
        // 47706447473685581843456469, tokensLeft calculation from distribution
        // 47679519183957423258749371, actual ve Balance after the lock call
        // 0                           circulating balance before claim
        // 5963305981484495189574468,  circulating balance after claim
        // 47706447473685581843456469 (distr amount locked) + 5963305981484495189574468 (distr amount claimed) = total

        emit log_named_uint("total theorhetical balance", amount1 / 1000);
        emit log_named_uint("total realized balance with an active lock at 4 years", voteEscrow.balanceOf(eoa1) + baoToken.balanceOf(eoa1));
        assert(voteEscrow.balanceOf(eoa1) + baoToken.balanceOf(eoa1) < amount1 / 1000);

        //upon withdrawal the user will receive 100% of realized tokens back even though 
        //the ve balance reflects slightly less

        cheats.stopPrank();
    }

    function testLockDistrToVeFunctions1() public { 
        cheats.startPrank(eoa1, eoa1);

        distribution.startDistribution(proof1, amount1);
        assertEq(distribution.claimable(eoa1, 0), 0);

        //log all the environments addresses
        emit log_named_address("admin", address(vyperDeployer));
        emit log_named_address("distr address", address(distribution));
        emit log_named_address("ve address", address(voteEscrow));
        emit log_named_address("token address", address(baoToken));
        emit log_named_address("eoa1 address", eoa1);

        cheats.warp(block.timestamp + 1 days); //forward 1 day after startDistribution() call

        emit log_named_uint("claimable balance", distribution.claimable(eoa1, uint64(block.timestamp)));

        //lock using distribution contract lock option into voting escrow for 3 years
        distribution.lockDistribution(block.timestamp + 94608000);  //distr calls vote escrow | 4yr = 126144000 | 3 yr = 94608000
        assertEq(voteEscrow.balanceOf(eoa1), voteEscrow.totalSupply());
        cheats.warp(block.timestamp + 3 days);

        //call the vote escrow function, increase_unlock_time(), from eoa1 after lockDistribution() call creates the lock on behalf of the eoa using the distribution contract
        voteEscrow.increase_unlock_time(voteEscrow.locked__end(eoa1) + 365 days); //extends the lock from lockDistribution() 1 more year
        assertEq(voteEscrow.balanceOf(eoa1), voteEscrow.totalSupply());

        emit log_named_uint("ve balance for eoa1", voteEscrow.balanceOf(eoa1));
        
        cheats.warp(voteEscrow.locked__end(eoa1) + 1 days);
        emit log_named_uint("ve balance for eoa1", voteEscrow.balanceOf(eoa1));

        voteEscrow.withdraw(); //withdraw veBAO to BAO
        assertEq(voteEscrow.totalSupply(), 0);
        assertEq(voteEscrow.balanceOf(eoa1), 0);

        baoToken.approve(address(voteEscrow), baoToken.balanceOf(eoa1)); //eoa1 approves ve contract
        voteEscrow.create_lock(baoToken.balanceOf(eoa1), block.timestamp + 21 days); //eoa1 calls create_lock() inside the voting escrow contract to create another 
        assertEq(voteEscrow.balanceOf(eoa1), voteEscrow.totalSupply());              //lock without the distribution contract this time at 3 weeks in length
        
        cheats.warp(block.timestamp + 7 days);
        voteEscrow.increase_unlock_time(block.timestamp + 365 days); //eoa1 increases the unlock time again for the lock made with create_lock() above
        assertEq(voteEscrow.balanceOf(eoa1), voteEscrow.totalSupply());

        cheats.stopPrank();
    }

    function testLockDistrToVeFunction2() public { 
        cheats.startPrank(eoa1, eoa1);

        distribution.startDistribution(proof1, amount1);
        assertEq(distribution.claimable(eoa1, 0), 0);

        cheats.warp(block.timestamp + 1 days); //forward 1 day after startDistribution() call

        //lock using distribution contract lock option into voting escrow for 3 years
        distribution.lockDistribution(block.timestamp + 94608000);  //distr calls vote escrow | 4yr = 126144000 | 3 yr = 94608000
        assertEq(voteEscrow.balanceOf(eoa1), voteEscrow.totalSupply());
        cheats.warp(block.timestamp + 3 days);

        //call the vote escrow function, increase_unlock_time(), from eoa1 after lockDistribution() call creates the lock on behalf of the eoa using the distribution contract
        voteEscrow.increase_unlock_time(voteEscrow.locked__end(eoa1) + 365 days); //extends the lock from lockDistribution() 1 more year
        assertEq(voteEscrow.balanceOf(eoa1), voteEscrow.totalSupply());

        emit log_named_uint("ve balance for eoa1", voteEscrow.balanceOf(eoa1));
        
        cheats.warp(voteEscrow.locked__end(eoa1) + 1 days);
        emit log_named_uint("ve balance for eoa1", voteEscrow.balanceOf(eoa1));

        voteEscrow.withdraw(); //withdraw veBAO to BAO
        assertEq(voteEscrow.totalSupply(), 0);
        assertEq(voteEscrow.balanceOf(eoa1), 0);

        baoToken.approve(address(voteEscrow), baoToken.balanceOf(eoa1)); //eoa1 approves ve contract
        voteEscrow.create_lock(baoToken.balanceOf(eoa1) / 2, block.timestamp + 21 days); //eoa1 calls create_lock() inside the voting escrow contract to create another 
        assertEq(voteEscrow.balanceOf(eoa1), voteEscrow.totalSupply());                  //lock without the distribution contract this time at 3 weeks in length
        
        cheats.warp(block.timestamp + 7 days);
        voteEscrow.increase_amount(baoToken.balanceOf(eoa1)); //eoa1 increases the unlock amount for the lock made with create_lock() above
        assertEq(voteEscrow.balanceOf(eoa1), voteEscrow.totalSupply());

        cheats.stopPrank();
    }

    function testLockDistrFuzz(uint256 _time) public {
        cheats.assume(_time >= block.timestamp + 94608000 && _time <= block.timestamp + 126144000); //fuzzing the full range of accepted time inputs in lockDistribution()
        cheats.startPrank(eoa1, eoa1);

        emit log_named_uint("token balance before lock", baoToken.balanceOf(eoa1)); 

        distribution.startDistribution(proof1, amount1); //start distribution for eoa 1
        assertEq(distribution.claimable(eoa1, 0), 0); //assert 0 claimable as no time has passed
        assertEq(voteEscrow.totalSupply(), 0); //no locks yet, should be 0

        cheats.warp(block.timestamp + 1);

        distribution.lockDistribution(_time); //eoa1 locks for n years

        emit log_named_uint("ve balance after lock", voteEscrow.balanceOf(eoa1));
        emit log_named_uint("token balance after lock", baoToken.balanceOf(eoa1));

        cheats.warp(_time + 1);
        emit log_named_uint("ve balance after expiry", voteEscrow.balanceOf(eoa1));

        voteEscrow.withdraw(); //withdraw veBAO to BAO

        emit log_named_uint("ve balance after withdraw", voteEscrow.balanceOf(eoa1));
        emit log_named_uint("token balance after withdraw", baoToken.balanceOf(eoa1));

        //token balance after withdraw is equal to amount1 / 1000, which is the correct owed amount

        cheats.stopPrank();
    }

    // -------------------------------
    // SWAPPER TESTS
    // -------------------------------

    function testSwap() public {
        cheats.startPrank(eoaTest, eoaTest);

        emit log_named_uint("baov2 token balance of swapper before", baoToken.balanceOf(address(swap))); //166850344226331394130869546
        emit log_named_uint("baov1 token balance of eoaTest before", baoV1.balanceOf(address(eoaTest))); //249891825684763220910719509
        emit log_named_int("expected baov2 token balance of eoaTest", 249891825684763220910719); //      249891825684763220910719 | 249891825684763220910719509 / 1000

        //approve: 249891825684763220910719509
        baoV1.approve(address(swap), baoV1.balanceOf(eoaTest));
        swap.convertV1(eoaTest, baoV1.balanceOf(eoaTest));
        
        emit log_named_uint("token balance of swapper after", baoToken.balanceOf(address(swap)));
        emit log_named_uint("baoV2 token balance of eoaTest", baoToken.balanceOf(eoaTest));
        emit log_named_uint("baoV1 balance of eoaTest", baoV1.balanceOf(eoaTest));
        emit log_named_uint("baov2 token balance of swapper after", baoToken.balanceOf(address(swap)));

        assert(166850344226331394130869546 - baoToken.balanceOf(address(swap)) == baoToken.balanceOf(eoaTest));

        //249,891,825.684763220910719509 baoV1
        //249,891.825684763220910719    expected baoV2
        //249,891.825684763220910719    actual baoV2

        cheats.stopPrank();
    }

    // -------------------------------
    // HELPERS
    // -------------------------------

    function _toDays(uint256 d) private pure returns (uint256) {
        return FixedPointMathLib.mulDivDown(d, 1e18, 86400);
    }

}
