// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

/*
建立一个去中心化的多级权限控制机制，确保不同身份的用户只能执行其被授权的操作，保障合约的安全性与操作合规性。
系统中存在四种角色，按权限从高到低依次为：
Owner（所有者）：系统最高权限持有者
Admin（管理员）：拥有部分管理权限
User（普通用户）：仅能使用基础功能
None（无角色）：未被授权的默认状态

系统部署时，部署者自动成为 Owner。
所有其他账户初始角色均为 None。

Owner	Admin	对象必须是有效地址（不能是零地址）
Admin	User	对象必须是有效地址（不能是零地址）

Owner 不能直接分配 User（需通过 Admin）
Admin 不能分配 Admin 或 Owner
User 不能分配任何角色
角色一旦分配，当前版本不支持撤销或修改（除非后续扩展）

只有 Owner 能执行“分配 Admin”的操作。
只有 Admin 能执行“分配 User”的操作。
其他功能（如查询）对所有人开放。

任何人均可：
查询任意账户当前的角色
单独判断某个账户是否是 Owner / Admin / User

每次成功分配角色（无论是 Admin 还是 User），系统必须记录一条日志，包含：
被分配的账户地址
分配的角色类型

以上即为完整的业务逻辑。你可以基于此独立设计数据结构、权限校验机制、函数接口，并编写智能合约。
*/

contract RoleManagement  {
    enum Role {None,Owner, Admin,User }

    mapping (address=>Role) rolesMap;

    event RoleGranted(address addr,Role role);

    constructor(){
        rolesMap[msg.sender]=Role.Owner;
        emit RoleGranted(msg.sender,Role.Owner);
    }
    
    //查询任意账户当前的角色
    function name(address _addr) external view  returns (Role){
        return rolesMap[_addr];
    }

    modifier onlyOwner(){
        require(rolesMap[msg.sender]==Role.Owner,"not Owner");
        _;
    }

    modifier onleAdmin(){
        require(rolesMap[msg.sender]==Role.Admin, "not Admin");
        _;
    }

    function addAdmin(address account)public onlyOwner{
        require(account!= address(0),unicode"无效账户");
        rolesMap[account]= Role.Admin;
        emit RoleGranted(account,Role.Admin);
    }

    function addUser(address account)public  onleAdmin{
        require(account!= address(0),unicode"无效账户");
        rolesMap[account]=Role.User;
        emit RoleGranted(account,Role.User);
    }

    

    //检查是否是  Owner 
    function isOwner(address _addr)external view returns (bool) {
        return rolesMap[_addr]==Role.Owner; 
    }


}