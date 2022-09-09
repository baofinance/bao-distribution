pragma solidity ^0.8.13;

import "./IERC20BAO.sol";
import "solmate/tokens/ERC20.sol";
import "solmate/utils/ReentrancyGuard.sol";

contract Swapper is ReentrancyGuard {
    ERC20 public immutable baoV1;
    IERC20BAO public immutable BAOv2;

    constructor(address _baov2) {
        // BaoV1 Token is a hardcoded constant
        baoV1 = ERC20(0x374CB8C27130E2c9E04F44303f3c8351B9De61C1);
        BAOv2 = IERC20BAO(_baov2);
    }

    function convertV1(address _to, uint256 _amount) external nonReentrant {
        baoV1.transferFrom(msg.sender, address(0), _amount); // Burn BaoV1
        BAOv2.mint(_to, _amount / 1000); // BaoV2's supply is reduced by a factor of 1000
    }
}