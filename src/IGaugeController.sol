pragma solidity 0.8.13;

interface IGaugeController {
    function get_total_weight(int128 type_id) external returns(uint256);
}