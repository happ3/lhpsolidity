// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

contract Student{
    uint256 str;

    function set(uint256 _x)public {
        str = _x;
    }

    function get()public view returns (uint256){
        return str;
    }
}