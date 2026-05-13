// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

//知识点  encodePacked 不会进行补0  encode会进行补0  


contract HashContract {
    function hash(  string memory text,  uint x,  address arr) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(text, x, arr));
    }



    function hashText(  string memory text0,    string memory text1) external pure returns (bytes memory) {
        return abi.encodePacked(text0,  text1);
    }


    function hashCode(  string memory text,  uint x,  address arr) external pure returns (bytes memory) {
        return abi.encode(text, x, arr);
    }

//当用encodePacked进行签名的时候，如果中间没有数字隔离会导致哈希碰撞，"AAA","ABBB"   "AAAA","BBB"
    function hashTextEncode(  string memory text0,    string memory text1) external pure returns (bytes32) {
        return keccak256(abi.encodePacked(text0,  text1));
    }

/**

"AAA","ABBB"   "AAAA","BBB"  结果都是
 
0x11db58448f2a53848bef361744f19e6fdabef68b8267b1ff669de1b4c42da0da

*/

}
