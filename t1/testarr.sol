// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


contract ArrTest {
    string[5] public str= ["123"];

    function getVal() public  view returns (string[5] memory){
        return str;
    }

    uint[10] public arr =[1,2,3,4,5];

    function getarr()public view returns (uint[10] memory) {
        return arr;
    }




    function add()  public view returns (uint256) {
        uint256 num = 0;
        for (uint i = 0; i<arr.length;i++){
            num+=arr[i];
        }
        return num;
    }

    function tetsArr() public pure returns (uint){
        uint256 [] memory arr2 = new uint256[](10);
        arr2[0]=1;
        return arr2.length;
    }

}

