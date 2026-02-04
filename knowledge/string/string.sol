// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TestAddress {
    string public str1 = "123";
    // 中文不适用unicode编码报错
    // string public str2 = ="你好";
    string public str2 = unicode"abc";
    
    function concat() public view returns(string memory) {
        string memory result = string.concat(str1,str2);
        return  result;
    }

    function caoncat2(string memory _a, string memory _b) public pure returns(string memory) {
        return string.concat(_a,_b);
    }
     function caoncat3(string memory _a, string memory _b) public pure returns(bytes memory) {
          bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        return bytes.concat(_ba,_bb);
    }


    function caoncat4(string memory _a, string memory _b) public pure returns(string memory) {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        return string(bytes.concat(_ba,_bb));
    }

     // 比较s1和s2是否相等，相等返回true，不相等返回false
    function compareEqual(string memory s1, string memory s2)   public  pure   returns (bool)    {   
        // 不支持字符直接比较
        return keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
    }

    // 将s1和s2合并为一个字节数组
    function mergeS1AndS2ReturnBytes(string memory s1, string memory s2)
        public
        pure
        returns (bytes memory)
    {
        return abi.encodePacked(s1, s2);
    }

    // 将s1和s2合并为一个字节数组转换为string
    function mergeS1AndS2ReturnString(string memory s1, string memory s2)
        public
        pure
        returns (string memory)
    {
        return string(abi.encodePacked(s1, s2));
    }
}