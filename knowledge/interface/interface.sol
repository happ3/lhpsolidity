// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

contract Dome {
    uint256 public count;

// function count() external view returns (uint256) {
//     return count;
// }

    function add() public {
        count += 1;
    }

    function sub() public {
        count -= 1;
    }
}


interface IDome {
    function count()external view returns (uint);
    function add() external;

}

contract CallInterface {
    uint256 public count;

    function example(address _addr)external  {
        IDome(_addr).add();
        count = IDome(_addr).count();  //调用的是Dome中的count()方法  Dome中的count()方法是因为public count;的public会自动生成一个get方法，这个方法的出现被理解成实现了IDome中的count()接口
    }
}