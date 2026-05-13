// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

/***

代币合约的思考
ERC20标准需要支持的方法
铸造方法
代币转账方法
代币授权方法
代币授权后转账方法  即代扣

表结构设计
1，代币表  发行量total  代币名称name  代币符号code
2，代币用户持有表，即用户余额  map(address=>uint256)balanceOf
3，代扣中间表  即用户授权给其他合约进行代扣的金额 谁授权给谁代扣额度  map(address=>map(address=>uint256)) allowance

推衍函数
构造函数 初始化，代币名称 代币符号 给合约创建者铸造默认代币  操作：赋值name，code，total，以及合约拥有者的balanceOf
函数1，给指定用户铸造代币 入参(用户地址userAddress，铸造金额value)  操作：对表balanceOf进行新增，如果用户已存在则累加金额，修改总数tatol的值  出参(userAddress,value)
函数2，给指定用户转账代币 入参(转账地址，转账金额)  操作：对表balanceOf进行操作，转入账户减，入账账户加  出参(转账地址，转账金额)
函数3，给指定账户授权代扣金额 由代币持有者进行调用，入参(授权地址，授权金额)  操作：对表allowance进行新增数据， 出参(代币拥有者地址(通常是钱包地址)，授权地址，授权金额)
函数4，代扣方法 入参(用户钱包地址，收款方地址，代扣金额) 操作：其中扣减额度不能大于用户授权额度,对表balanceOf进行操作，转入账户减，入账账户加 ,对表allowance进行扣除  出参(用户钱包地址，收款方地址，代扣金额)


*/



contract SimpleERC20 {
    uint256 public totalSupply;
    uint8 public decimals = 18;

    mapping (address =>uint256) public balanceOf;
    mapping (address=> mapping (address => uint256)) allowance;

    //从谁转给谁 多少钱
    event Transfer(address from,address to,uint256 value);
    //授权  授权给其他合约  可以扣除该用户 多少钱
    event Approval(address owner ,address spender, uint256 value);

    //铸币 铸造一定数额的币 并分配给某个用户  
    event Mint(address to,uint256 value);

    //销毁
    event Burn(address from,uint256 value);

    //初始化时，直接铸造 一定体量的币  给合约拥有者
    constructor(uint256 _initialSupply) { 
        totalSupply = _initialSupply*10**decimals;
        balanceOf[msg.sender]=totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    //由合约调用者向 其他用户转账token
    function transfer(address to,uint256 amount) external returns (bool){
        require(balanceOf[msg.sender] >= amount, unicode"余额不足");
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        emit Transfer(msg.sender, to, amount);
        return true;
    }

    //0x5B38Da6a701c568545dCfcB03FcB875f56beddC4  0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
    function approval(address spender, uint256 amount)external returns (bool) {
        allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }


    function transferFrom(address from, address to, uint256 amount)external returns (bool) {
        require(balanceOf[from]>=amount, unicode"该用户余额不足");
        require(allowance[from][msg.sender] >= amount, unicode"该用户授权的余额不足");

        balanceOf[from] -=amount;
        balanceOf[to] +=amount;

        allowance[from][msg.sender] -=amount;

        emit Transfer(from, to, amount);

        return true;
    }

    function mint(address to,uint256 amount) external {
        totalSupply +=amount;
        balanceOf[to] +=amount;

        emit Transfer(address(0), to, amount);
    }

    function burn(uint256 amount)external  {
        totalSupply -=amount;
        balanceOf[msg.sender] -=amount;

        emit Burn(address(0), amount);
    }
}