// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Dome {
    function test() public pure returns (string memory) {
        bytes memory bt = new bytes(1);
        bt[0] = "9";
        return string(bt);
    }

    uint256 public a;
    function test1(uint256 u_) external {
        a = u_;
    }

    function test2()external  {
        uint8 temp = 3;
        this.test1(temp);
    }
}
