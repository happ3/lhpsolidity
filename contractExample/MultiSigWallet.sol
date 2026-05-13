// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

//多签钱包

/**
多签钱包是另一个常见的应用场景。它需要多个签名者确认后才能执行交易，使用call执行外部交易以实现灵活性。

思考 表设计

签名人表
交易单表
交易单中间表

方法
初始化 设置需要签名的地址，设置默认的签名数有多少

有一个前提签名人数量一定要大于 设定必须的签名数  比如有5个签名人  必须有4个通过 是合理的

新增签名人的方法

初始化，设置签名人，最低签名数
提交交易，创建交易
确认批准，就是审核交易
执行交易，执行交易转账
撤销批准，在没有执行前，撤销批准

获取默个交易的信息
获取批准人，看都有谁
获取看有多少笔交易





*/

contract MultisigWallet {

    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner,
        uint indexed txIndex,
        address indexed to,
        uint value,
        bytes data
    );
    event ConfirmTransaction(address indexed owner, uint indexed txIndex);
    event RevokeConfirmation(address indexed owner, uint indexed txIndex);
    event ExecuteTransaction(address indexed owner, uint indexed txIndex);

    
    address []public ownerSignatures; //签名人表
    mapping (address =>bool) indexOwner; 

    //交易表
    struct Transaction{
        address to;     //交易地址
        uint value;     //交易金额
        bytes data;     //交易中是否还需要调用其他方法
        bool executed;  //交易是否已执行
        uint numConfirmations; //审核人数
    }

    Transaction[] public transactions;

    //最低签名人数
    uint256 public required;

    //中间表  就是一个交易下有哪几个人成功签名
    mapping (uint256 =>mapping (address=>bool)) isConfirmed;


    /**
        初始化 新增签名人，设置签名人索引，设置最低签名人数
    */
    constructor(address[] memory _ownerSignature,uint256 _required) {
        require(_ownerSignature.length >=1, "the ownerSignature must be greater than 1");
        require(_required>=1 && _ownerSignature.length >=_required,"the _ownerSignature length must be greater than 1 and the required must be greater than _ownerSignature length");

        for (uint256 i = 0;i<_ownerSignature.length; i++){
            address owner = _ownerSignature[i];
            require(owner != address(0), "address not null");
            require(!indexOwner[owner], "owner not unique");

            indexOwner[owner] = true;
            ownerSignatures.push(owner);
        }
        required = _required;
    }


    modifier onlyOwner(){
        require(indexOwner[msg.sender],"not onwer");
        _;
    }

    modifier txExists(uint256 _txIndexId){
       require(_txIndexId < transactions.length, "transaction does not exist");
        _;
    }

    modifier noExecuted(uint256 _txIndexId){
        require(!transactions[_txIndexId].executed, "transaction is already executed");
        _;
    }

    modifier notConfirmed(uint256 _txIndexId){
        require(!isConfirmed[_txIndexId][msg.sender], "isConfirmed");
        _;
    }


    /**
    创建交易 
        已存在的交易不能新增  
        只有签名人才能新增交易
        保存交易信息

    */
    function createTransaction(address _toAddress,uint _value,bytes memory _data) external onlyOwner{
        uint256 txIndexId = transactions.length;

        Transaction memory newTx =  Transaction({
            to:_toAddress,
            value:_value,
            data:_data,
            executed:false,
            numConfirmations :0
        });
        transactions.push(newTx);

        emit SubmitTransaction(msg.sender,txIndexId,_toAddress,_value,_data);
    }

    /**
        审核交易 
            必须是审核人才能进来
            交易必须存在
            交易必须未执行
            未审核人人才能进行审核

            修改交易对象的审核人数
            修改中间表 谁审核了交易
    */
    function confirmTransaction(uint256 _txIndexId) external txExists(_txIndexId) noExecuted(_txIndexId) notConfirmed(_txIndexId) onlyOwner{
        
       Transaction storage transaction = transactions[_txIndexId];
       transaction.numConfirmations +=1;
       isConfirmed[_txIndexId][msg.sender] = true;
       emit ConfirmTransaction(msg.sender,_txIndexId);
    }

    /**
    执行交易
        已确认的交易才能执行
        交易必须存在
        交易必须未执行
        必须是管理员才能执行

        修改交易中的执行状态
        执行转账
    */

    function executeTransaction(uint256 _txIndexId) external txExists(_txIndexId) noExecuted(_txIndexId) onlyOwner{
        Transaction storage tran = transactions[_txIndexId];
        require(transactions[_txIndexId].numConfirmations >= required,"cannot execute tx");

        tran.executed = true;

        (bool success,) = tran.to.call{value :tran.value}(tran.data);
        require(success,"tx fail");
        emit ExecuteTransaction(msg.sender, _txIndexId);
    }

    /**

    撤销交易
        交易必须存在
        交易必须未执行
        交易必须已审核
        交易必须是管理员撤销

        修改对象中的审核数量
        修改中间表中的审核数量为false

    */
    function revokeConfirmation(uint256 _txIndexId)external txExists(_txIndexId) noExecuted(_txIndexId) onlyOwner {
        require(isConfirmed[_txIndexId][msg.sender], "the user not confirm");

        Transaction storage tran = transactions[_txIndexId];
        tran.numConfirmations -=1;
        isConfirmed[_txIndexId][msg.sender] = false;
        emit RevokeConfirmation(msg.sender, _txIndexId);
    }
}