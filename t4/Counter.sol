// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Counter {
    uint256 public count;

    // ✅ 这两个事件必须存在
    event Incremented(address indexed caller);
    event Added(address indexed caller, uint256 num, uint256 newCount);

    constructor(uint256 _initialCount) {
        count = _initialCount;
    }

    function increment() external {
        count += 1;
        emit Incremented(msg.sender);
    }

    function add(uint256 _num) external {
        count += _num;
        emit Added(msg.sender, _num, count);
    }

    function getCount() external view returns (uint256) {
        return count;
    }
}