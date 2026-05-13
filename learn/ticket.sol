// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

//投票 投票开启  投票关闭 进行投票

contract Ticket {
    
    bool  isOpne = true;
    mapping (address=> bool) map;

    function vote()external   {
        require(isOpne, unicode"投票系统未开启");
        require(!map[msg.sender], unicode"已经投票过啦");

        map[msg.sender] = true;
    }

    function close() external   {
        isOpne = false;
    }

    function upen() external   {
        isOpne = true;
    }


}