// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 PerAddressLimit.sol
实现一个公共领取功能
每个地址每天最多领取 1 次
用时间戳限制频率

**/

contract PerAddressLimit {
    uint256 private oneDay = 1 days;

    mapping (address=>uint256) public  lastGetTime;

    function receiveGift()external   {
        if (block.timestamp  - lastGetTime[msg.sender] < oneDay){
            revert(unicode"冷却期未过");
        }
        // 1. 发奖（给用户转账或发币...）

        // 2. 更新记录（关键！把上次领取时间更新为“现在”）
        lastGetTime[msg.sender] = block.timestamp;
    }
}