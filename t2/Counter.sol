// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
/**
Counter
有一个 uint256 public count
函数 increment() +1
函数 decrement() -1，不能小于 0
任何人可调用

*/
contract Counter {
    uint256 public count;


    function increment() external  returns (uint256){
        count ++;
        return count;
    }

    function decrement() external  returns (uint256){
        require(count>0, "not less than 0");
        count--;
        return count;
    }

}