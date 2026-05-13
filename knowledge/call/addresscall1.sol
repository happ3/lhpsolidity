// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

// 合约 1：餐厅
contract Restaurant {
    function eat() external pure returns (string memory) {
        return "eating...";
    }
}
// 合约 2：顾客
contract Customer {
    function order(address restaurant) external {
        // 调用餐厅的 eat 函数
        (bool success, ) = restaurant.call(
            abi.encodeWithSelector(bytes4(keccak256("eat()")))
        );
        require(success, "Call failed");
    }
}