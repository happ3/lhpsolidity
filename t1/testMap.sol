// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Dome {
    struct Student {
        string name;
        string desc;
        uint256 age;
    }

    mapping(address => Student) public studentMap;

    function modifyStudent() external returns (Student memory) {
        studentMap[msg.sender] = Student({
            name: unicode"晓东",
            desc: "boy",
            age: 18
        });

        Student storage st = studentMap[msg.sender];
        st.age++;
        return st;
    }

    function modifyStudent2() external returns (Student memory) {
        studentMap[msg.sender] = Student({
            name: unicode"晓东",
            desc: "boy",
            age: 18
        });

        Student memory st = studentMap[msg.sender];
        st.age++;
        return st;
    }

    function test() public pure returns (uint256[] memory) {
        uint256[] memory arr = new uint256[](5);
        arr[0] = 1;
        arr[1] = 2;
        arr[2] = 3;
        arr[3] = 4;
        arr[4] = 5;
        return arr;
    }

    //用calldata做入参会更省钱
    //5094
    function test2(uint256[] calldata arr) external  pure returns (uint256[] memory meArr) {
        meArr = new uint256[](arr.length);
        for (uint256 i =0; i<arr.length; i++) {
            meArr[i] = arr[i];
        }
        return meArr;
    }
    //7519
    function test3(uint256[] memory arr) external pure returns (uint256[] memory meArr) {
        meArr = new uint256[](arr.length);
        for (uint256 i =0; i<arr.length; i++) {
            meArr[i] = arr[i];
        }
        return meArr;
    }
}
