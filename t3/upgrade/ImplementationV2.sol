// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// V2逻辑合约：升级版本（新增功能）
contract ImplementationV2 {
    // 存储布局必须与V1和Proxy完全一致！
    address public implementation;
    address public admin;
    uint256 public value;
    
    // 新增变量只能在末尾添加
    uint256 public multiplier;
    
    /**
     * @notice 设置值（新逻辑：值翻倍）
     * @param _value 要设置的值
     * @dev 新逻辑：值会自动翻倍
     */
    function setValue(uint256 _value) public {
        value = _value * (multiplier == 0 ? 1 : multiplier);
    }
    
    /**
     * @notice 获取值
     */
    function getValue() public view returns (uint256) {
        return value;
    }
    
    /**
     * @notice 设置倍数（V2新增功能）
     * @param _multiplier 倍数
     * @dev V1没有这个函数，升级后可以使用
     */
    function setMultiplier(uint256 _multiplier) public {
        multiplier = _multiplier;
    }
}