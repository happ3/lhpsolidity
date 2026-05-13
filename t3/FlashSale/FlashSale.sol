// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/**
第 1 题：限时抢购合约（DeFi / 链商通用）
业务场景
    项目方发售限量权益，用户在指定时间内才能购买，每人限购，防止机器人刷量。
    要求
    设定抢购开始、结束时间
    每人最多购买 3 份
    购买需支付 0.01 ether
    只有在时间窗口内可购买
    Owner 可提款
    所有输入做合法性校验，避免垃圾交易浪费 Gas

时间单位 /block.timestamp/mapping /payable/msg.value/require 校验 / Gas 优化 / 权限控制
*/

contract FlashSale{



}