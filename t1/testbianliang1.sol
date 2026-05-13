// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "./info.sol" as INFO;

contract Dome {
    address public addr = msg.sender;

    function global() external view returns (address,uint256,uint256){
        return (msg.sender,block.timestamp,block.number);
    }
    

    // string public constant NAME = "lhp";
    string public name ="lhp2";


    function getName() public view returns (string memory) { //因为引用的是全局的状态变量，所以可以是用 view
        return name;
    }

    function getName1() public pure returns (string memory) {  //因为引用的是常量，所以可以是用 pure
        return INFO.NAME;
    }
}