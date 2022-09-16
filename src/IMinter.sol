pragma solidity 0.8.13;

interface IMinter {
    function swap_mint(address _for, uint256 _amount) external;
}