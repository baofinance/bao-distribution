pragma solidity 0.8.13;

interface IMinter {
    function apply_swapper_contract(address addr) external;
    function mint(address gauge_addr) external;
    function swap_mint(address _for, uint256 _amount) external;
    function mint_many(address[8] calldata gauge_addrs) external;
    function mint_for(address gauge_addr, address _for) external;
    function toggle_approve_mint(address minting_user) external;
}