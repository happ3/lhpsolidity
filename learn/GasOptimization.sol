// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

    //分批求和

contract GasOptimization {
    uint256[] arr;
    //初始化测试数据
    function init(uint256 n) external {
        for (uint i = 0; i < n; i++) {
            arr.push(i + 1);
        }
    }
    //安全添加
    function addArr(uint256 _val) external {
        require(arr.length < 5, unicode"长度不能超过5");
        arr.push(_val);
    }

    function selectArr() external view returns (uint256[] memory) {
        return arr;
    }

    //分批求和
    function beachAdd( uint256 start,uint256 end) external view returns (uint256 sum) {
        uint len = arr.length;
        require(start < end, "start not <end");
        require(end < len, unicode"end 不能超过数组自身长度");
        for (uint256 i = start; i < end; i++) {
            sum += arr[i];
        }
        return sum;
    }
}
