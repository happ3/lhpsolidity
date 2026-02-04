// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

//引用类型string 在传递参数时没有共用一个内存地址
contract Dome {
    struct Student {
        string name;
        uint256 age;
    }

    function main() public pure returns (string memory newName) {
        string memory name = "123";
        modifyVal(name);
        return name; //123
    }

    function modifyVal(string memory str) internal pure returns (string memory) {
        str = "456";
        return str;
    }

    function mainf() public pure returns (Student memory) {
        Student memory st;
        st.age = 18;
        st.name = "abc";
        myStruct(st);
        return st; //实际结果  bcd,32   但ai认为是abc，18
    }

    function myStruct(
        Student memory st
    ) internal pure returns (Student memory) {
        Student memory student = st;
        student.name = "bcd";
        student.age = 32;
        return student;
    }

    function mainArr() public pure returns (string[] memory) {
        string[] memory strArr = new string[](2);
        strArr[0] = "123";
        myArr(strArr);
        return strArr;//实际结果 789
    }

    function myArr( string[] memory stArr) internal pure returns (string[] memory) {
        stArr[0] = "789";
        return stArr;
    }


    function testB()public  pure  returns (string memory,string memory) {
        string memory s1="123";
        string memory s2="456";
        s1 = s2;
        bytes(s2)[0]=bytes1("9");
        return (s1,s2);
    }
}
