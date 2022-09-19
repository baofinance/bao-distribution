pragma solidity 0.8.13;

interface IGaugeController {
    function commit_transfer_ownership(address addr) external;
    function apply_transfer_ownership() external;
    function gauge_types(address addr) external view returns(int128);
    function add_gauge(address addr, int128 gauge_type) external;
    function checkpoint() external;
    function checkpoint_gauge(address addr) external;
    function gauge_relative_weight(address addr) external view returns(uint256);
    function gauge_relative_weight_write(address addr) external returns(uint256);
    function add_type(string[64] calldata _name) external;
    function change_type_weight(int128 type_id, uint256 weight) external;
    function change_gauge_weight(address addr, uint256 weight) external;
    function vote_for_gauge_weights(address _gauge_addr, uint256 _user_weight) external;
    function get_gauge_weight(address addr) external view returns(uint256);
    function get_type_weight(int128 type_id) external view returns(uint256);
    function get_total_weight(int128 type_id) external view returns(uint256);
    function get_weights_sum_per_type(int128 type_id) external view returns(uint256);
}