pragma solidity 0.8.13;

interface IVotingEscrow {
    function commit_transfer_ownership(address addr) external;
    function apply_transfer_ownership() external;
    function commit_smart_wallet_checker(address addr) external;
    function apply_smart_wallet_checker() external;
    function commit_distr_contract(address addr) external;
    function apply_distr_contract() external;
    function get_last_user_slope(address addr) external view;
    function user_point_history__ts(address _addr, uint256 _idx) external view;
    function locked__end(address _addr) external view;
    function checkpoint() external;
    function deposit_for(address _addr, uint256 _value) external;
    function create_lock(uint256 _value, uint256 _unlock_time) external;
    function create_lock_for(address _to, uint256 _value, uint256 _unlock_time) external;
    function increase_amount(uint256 _value) external;
    function increase_unlock_time(uint256 _unlock_time) external;
    function withdraw() external;
    //function balanceOf(address addr, uint256 _t = block.timestamp) external view returns(uint256);
    function balanceOfAt(address addr, uint256 _block) external view returns(uint256);
    //function totalSupply(uint256 _block = block.timestamp) external view returns(uint256);
    function totalSupplyAt(uint256 _block) external view returns(uint256);
    function changeController(address _newController) external;
}