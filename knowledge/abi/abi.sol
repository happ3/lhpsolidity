// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Dome {
    
function abiTest() public pure returns  (string memory,uint ,bool){
    // 打包
    bytes memory box = abi.encode(unicode"小明", 18, true);

// 拆包（对方收到后）
    (string memory name, uint age, bool isStudent) = abi.decode(box, (string, uint, bool));
    return (name,age,isStudent);
}

}
