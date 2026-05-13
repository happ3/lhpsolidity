// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./userLibrary.sol";

// 文件级别声明
using MathLib for uint256;

// 该文件中的所有合约都可以使用
contract Contract1 {
    function test() public pure returns (uint256) {
        return uint256(10).add(20);
    }
}

contract Contract2 {
    function test() public pure returns (uint256) {
        return uint256(5).add(15);
    }
}