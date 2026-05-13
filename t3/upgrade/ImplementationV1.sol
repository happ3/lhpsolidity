// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// V1逻辑合约：初始版本
contract ImplementationV1 {
    // 注意：存储布局必须与Proxy完全一致！
    address public implementation;  // 对应Proxy的implementation
    address public admin;            // 对应Proxy的admin
    uint256 public value;            // 对应Proxy的value
    
    /**
     * @notice 设置值
     * @param _value 要设置的值
     * @dev 这个函数会修改Proxy的storage，不是本合约的
     */
    function setValue(uint256 _value) public {
        value = _value;
    }
    
    /**
     * @notice 获取值
     */
    function getValue() public view returns (uint256) {
        return value;
    }
}