// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


contract testArr {
    
    uint []  public arr2;
    uint [] public arr5=[1];
    uint [] public arr3 = new uint[](10);



    uint []arr =[0];
    function pushArr(uint i)public  {
        arr2.push(i);
    }


    function getArr() public view returns (uint[]memory){
        return arr2;
    }
}