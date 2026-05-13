// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Test {
    // VM error: revert.
    function testA1() public pure returns (uint256 a) {
        a = 255 + (true ? 1 : 0);
    }

    function testA2() public pure returns (uint256 a) {
        a = (true ? 1 : 0) + 255;
    }

    // VM error: revert.
    function testB1() public pure returns (uint256 a) {
        a = 255 + [1, 2, 3][0];
    }

    function testB2() public pure returns (uint256 a) {
        a = [1, 2, 3][0] + 255;
    }

    function testA3() public pure returns (uint256 a) {
        a = 255 + uint256(true ? 1 : 0);
    }

    function testB3() public pure returns (uint256 a) {
        a = 255 + uint256([1, 2, 3][0]);
    }
}