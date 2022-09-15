// SPDX-License-Identifier: GPL-3.0

//THIS IS A TEST ERC20 CONTRACT FOR "BaoDistribution.t.sol"
//THE actual BAOv2 token contract is a vyper contract "ERC20BAO.vy"

pragma solidity ^0.8.13;

import "solmate/tokens/ERC20.sol";
import "solmate/utils/ReentrancyGuard.sol";

contract BaoToken is ERC20, ReentrancyGuard {

    uint256 public constant MAX_SUPPLY = 15e26; // 1.5 billion
    ERC20 public immutable baoV1;
    address public minter;

    error MintExceedsMaxSupply();

    modifier onlyMinter {
        require(msg.sender == minter);
        _;
    }

    constructor(
        string memory _name, // Bao Finance
        string memory _symbol // BAO
    ) ERC20(_name, _symbol, 18) {
        minter = msg.sender;

        // BaoV1 Token is a hardcoded constant
        baoV1 = ERC20(0x374CB8C27130E2c9E04F44303f3c8351B9De61C1);
    }

    function setMinter(address _address) public onlyMinter {
        minter = _address;
    }

    function mint(address to, uint256 amount) public onlyMinter {
        if (totalSupply + amount >= MAX_SUPPLY) {
            revert MintExceedsMaxSupply();
        }
        _mint(to, amount);
    }

    function burn(uint256 _amount) external {
        _burn(msg.sender, _amount);
    }
}
