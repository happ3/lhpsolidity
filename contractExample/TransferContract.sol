// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
/***优化后的容错批量转账***/
contract OptimizedBatchTransfer {
    
    // 1. 定义事件：用来记录失败，不占昂贵的 Storage，只占便宜的 Log
    // indexed 修饰符可以让前端通过 recipient 地址快速过滤日志
    event TransferFailed(address indexed recipient, uint256 amount, string reason);
    
    // 记录成功总数的事件
    event BatchTransferCompleted(uint256 successCount, uint256 failureCount);

    /**
     * @notice 优化后的容错批量转账
     */
    function batchTransfer(
        address tokenAddress,
        address[] calldata recipients,
        uint256[] calldata amounts
    ) external {
        require(recipients.length == amounts.length, "Arrays length mismatch");
        
        IERC20 token = IERC20(tokenAddress);
        uint256 successCount = 0;
        uint256 failureCount = 0;

        for (uint256 i = 0; i < recipients.length; i++) {
            // 使用 try/catch 包裹
            try this._executeTransfer(token, recipients[i], amounts[i]) {
                successCount++;
            } catch (bytes memory reason) {
               unchecked {failureCount++;} 
                
                // 2. 发送事件，而不是写入 Storage
                // 这里的 Gas 费用非常低（约 2000-3000 Gas），而且字符串长度越长费用增加越慢
                emit TransferFailed(recipients[i], amounts[i], "Transfer failed");
            }
        }

        emit BatchTransferCompleted(successCount, failureCount);
    }

    // 内部执行函数，必须是 external 才能被 try/catch 捕获
    function _executeTransfer(IERC20 token, address to, uint256 amount) external {
        (bool success, bytes memory data) = address(token).call(
            abi.encodeWithSignature("transferFrom(address,address,uint256)", msg.sender, to, amount)
        );
        require(success && (data.length == 0 || abi.decode(data, (bool))), "Transfer call failed");
    }
}