// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
//嵌套map

contract Dome {
    struct Data{
        uint256 a;
        bytes3 b;
        uint256[3]c;
        uint256[]d;
        bytes e;

    }

 mapping (uint256 =>mapping (bool => Data[]))public data;



function datas(uint256 arg1,bool arg2,uint256 arg3) external view   returns (uint256 a,bytes3 b,bytes memory e){
    a = data[arg1][arg2][arg3].a;
    b = data[arg1][arg2][arg3].b;
    e = data[arg1][arg2][arg3].e;
}


}