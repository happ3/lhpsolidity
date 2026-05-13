// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// 数组自定义切片

contract Dome {
    uint256[] nums = [1, 2, 3];

    uint256[]   temp;

    function setArr() public {
        nums.push(4);
        nums.pop();

        nums[0] = 666;

        delete nums[0];
    }

    //[1,2,3,4,5,6,7,8,9]
    function setTemp( uint256[] calldata _arr ) public returns (uint256[] memory) {
        temp = _arr[0:2];
        return temp;
    }

    function setTemp2( uint256[] memory _arr ) public pure returns (uint256[] memory) {
        uint256[] memory arrTemp = slice(_arr,0,2);
        return arrTemp;
    }


    function slice(uint256[] memory arr, uint256 start, uint256 end)   internal pure  returns (uint256[] memory) {
        uint256[] memory res = new uint256[](end - start); // 创建新数组
        for (uint256 i = 0; i < end - start; i++) {
            res[i] = arr[start + i]; // 复制元素
        }
        return res;
    }


    function test2() public pure returns (uint256[] memory ){
        uint256[] memory arr = new uint256[](5);
        arr[0] = 10; arr[1] = 20; arr[2] = 30;


        uint256[] memory  array = slice(arr,0,2);
        return array;
    }


    function getNum() external view returns (uint256[] memory) {
        return nums;
    }
}
