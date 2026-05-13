// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Dome {
    uint public x = 100;

    function doAccert()public returns (uint){
        x = 200;
        // assert(5 < 3);
         require(5 < 3, unicode"怎么能大于5呢"); // ✅ 正确！支持字符串
        return x;
    }
}