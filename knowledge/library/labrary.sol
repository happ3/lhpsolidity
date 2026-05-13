// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

library Math {
    function max(uint x, uint y) internal pure returns (uint256) {
        return x >= y ? x : y;
    }
}


contract Test {
    function testMath(uint x, uint y)external pure  returns (uint) {
        return Math.max(x,y);
    }
}

library Arraylib {
    function find(uint [] storage arr,uint x) internal view returns (uint) {
        for (uint i=0; i<arr.length;i++){
            if(arr[i] == x){
                return i;
            }
        }

        revert("not found");
    }
}

contract TestArry {
    using Arraylib for uint[];

    uint256 [] public array = [1,2,3];
    function testFind()external view returns (uint i) {
        return  Arraylib.find(array,2);
    }

    function testFind2()external view returns (uint i) {
        return array.find(2);
    }
}