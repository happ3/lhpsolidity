// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

// 简单的代理合约
contract SimpleProxy {
    // 逻辑合约地址
    address public implementation;
    
    // 管理员地址
    address public admin;
    
    // 数据存储（与逻辑合约的存储布局必须一致）
    uint256 public value;
    
    /**
     * @notice 构造函数：初始化逻辑合约地址
     * @param _implementation 逻辑合约地址
     */
    constructor(address _implementation) {
        admin = msg.sender;
        implementation = _implementation;
    }
    
    /**
     * @notice onlyAdmin修饰符
     */
    modifier onlyAdmin() {
        require(msg.sender == admin, "Not admin");
        _;
    }
    
    /**
     * @notice 升级函数：更换逻辑合约
     * @param newImplementation 新的逻辑合约地址
     * @dev 只有admin可以调用
     */
    function upgrade(address newImplementation) external onlyAdmin {
        implementation = newImplementation;
    }
    
    /**
     * @notice fallback函数：将所有调用转发到逻辑合约
     * @dev 使用delegatecall调用逻辑合约
     */
    fallback() external payable {
        address impl = implementation;
        require(impl != address(0), "Implementation not set");
        
        // 使用delegatecall调用逻辑合约
        // delegatecall的特性：
        // 1. 代码在Implementation中执行
        // 2. 但使用的storage是Proxy的
        // 3. msg.sender保持不变（是原始调用者）
        assembly {
            calldatacopy(0, 0, calldatasize())
            let result := delegatecall(gas(), impl, 0, calldatasize(), 0, 0)
            returndatacopy(0, 0, returndatasize())
            switch result
            case 0 { revert(0, returndatasize()) }
            default { return(0, returndatasize()) }
        }
    }
    
    // 接收以太币
    receive() external payable {}
}