pragma solidity ^0.8.13;

import "./IMinter.sol";
import "solmate/tokens/ERC20.sol";
import "solmate/utils/ReentrancyGuard.sol";

contract Swapper is ReentrancyGuard {
    ERC20 public immutable baoV1;
    IMinter public immutable baoV2minter;

    constructor(address _minter) {
        // BaoV1 Token is a hardcoded constant
        baoV1 = ERC20(0x374CB8C27130E2c9E04F44303f3c8351B9De61C1);
        baoV2minter = IMinter(_minter);
    }

    function convertV1(address _to, uint256 _amount) external nonReentrant {
        baoV1.transferFrom(msg.sender, address(0), _amount); // Burn BaoV1
        baoV2minter.swap_mint(_to, _amount / 1000); // BaoV2's supply is reduced by a factor of 1000
    }
}