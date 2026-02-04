// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Dome {
    string public welcome ="1.welcome";
    string public welcome1 ="1.welcome";

    //取出字符串某个索引的值
    function getIndexValue(uint256 _index)public view returns (string memory) {
        bytes1 bt =  bytes(welcome)[_index];
        bytes memory newbt = new bytes(1);
        newbt[0]=bt; 

        return string(abi.encodePacked(bt));
        // return string(newbt);
    }
    //修改
    function modify()public  {
        bytes(welcome)[0]=bytes1("o");
    }

    //拼接
    function concat(string memory str1,string memory str2) public pure returns (string memory){
        return string.concat(str1,str2,"!");
    }

    //字符串比较
    function compare() public view  returns (bool) {
        // return keccak256(bytes(welcome))==keccak256(bytes(welcome1));
           return keccak256(abi.encodePacked(welcome)) == keccak256(abi.encodePacked(welcome1));
    }

    function testByte() public pure returns (bytes memory,bytes memory){
        bytes memory a = "hello";
        bytes memory b = a; 
        a ="ooo"; //修改后不会影响原来的值
        return (a,b);
    }

 function testValueCopy() public pure returns (bytes32, bytes32) {
        // 1. 创建 x，赋值为一个具体的 32 字节数据
        bytes32 x = 0x48656c6c6f20576f726c64000000000000000000000000000000000000000000;
        //         ↑ 这是 "Hello World" 的 UTF-8 编码，后面补 0 到 32 字节

        // 2. 把 x 赋值给 y
        bytes32 y = x; // ← 关键：这是**值拷贝**

        // 3. 修改 y（注意：不能直接改 y[0]，因为 bytes32 是值类型，不支持索引）
        //    我们通过位运算“修改”最后 1 字节来模拟
        y = bytes32(uint256(y) | 0x01); // 把 y 的最低字节设为 0x01

        // 4. 返回 x 和 y
        return (x, y);
    }


}