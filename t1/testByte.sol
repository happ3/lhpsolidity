// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract Dome {
    bytes2 public a1 = 0x5678;
    // 增大
    bytes4 public a2 = bytes4(a1);//0x5678 =>0x56780000

    //变小
    bytes1 public a3 = bytes1(a1);//0x5678 => 0x56


    bytes public  bts = "a";

    bytes3 public b3 = bytes3(bts);
    
}