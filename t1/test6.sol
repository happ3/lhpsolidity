// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract EventDome {
    event Log(string);
    

function PrintLog() public {
        emit Log(unicode"错误信息");
}

}