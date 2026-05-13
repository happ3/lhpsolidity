// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";


contract MyBank {
    // 这个 mapping 就是用来记录的！
    mapping(address => mapping(address => uint256)) public userBalance;
    //      用户         代币地址           数量
    
    function deposit(address tokenAddress, uint256 amount) external {
        // 1. 把代币从用户转到这个合约
        IERC20(tokenAddress).transferFrom(msg.sender, address(this), amount);
        
        // 2. 记录：这个用户存了这种代币多少
        userBalance[msg.sender][tokenAddress] += amount;
    }
    
    function withdraw(address tokenAddress, uint256 amount) external {
        // 1. 检查用户有没有存这么多
        require(userBalance[msg.sender][tokenAddress] >= amount, "not to use");
        
        // 2. 扣减记录
        userBalance[msg.sender][tokenAddress] -= amount;
        
        // 3. 把代币转回给用户
        IERC20(tokenAddress).transfer(msg.sender, amount);
    }
}