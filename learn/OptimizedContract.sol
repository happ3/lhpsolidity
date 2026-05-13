// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

/**
将用户输入的数组进行存储，并计算求和
*/

contract OptimizedContract {
    
    uint256[] arr;

    function addArr(uint256[] calldata nums) external {
        require(nums.length > 0, "Input array is empty");
        require(nums.length <= 3, unicode"长度不能超过3");
        uint256 len = nums.length;
        for (uint256 i= 0;i<len;i++){
            arr.push(nums[i]);
        }
    }

    function getSum()external view returns (uint256) {
        uint256 len = arr.length;
        uint256 sum;
        for (uint i =0;i<len; i++){
            sum +=arr[i];
        }
        return sum;
    }

}
