// SPDX-License-Identifier: MIT
pragma solidity ^0.8;

/**
众筹合约

你需要开发一个链上众筹合约，允许项目发起人创建筹款活动，支持者可向活动捐款。资金在目标达成后由发起人提取；若未达成，支持者可申请退款。

分析
1，需要设置一个众筹时间，以及一个众筹总金额如10个以太币
2，当众筹金额达到10个以太币，那么提前结束众筹，由合约的创建者进行提现
3，当时间到期时，众筹金额为达到10个以太币，则捐献者可以通过退款退回自己的账户

*/

/**
 * @title 去中心化众筹合约（Crowdfunding）
 * @dev 允许项目发起人创建 ETH 众筹活动：
 *      - 支持者可捐款
 *      - 若达到目标金额，资金转给发起人
 *      - 若未达标，支持者可申请退款
 *
 * 状态机：Preparing → Active → (Success | Failed)
 */
contract Crowdfunding {
    // ========== 状态定义 ==========
    /// @notice 众筹生命周期状态
    enum State {
        Preparing, // 准备中：尚未开始
        Active, // 进行中：可接受捐款
        Success, // 成功：已达标并完成打款
        Failed, // 失败：未达标，可退款
        Withdrawn
    }

    // ========== 状态变量 ==========
    State public currentState; // 当前众筹状态
    address public owner; // 项目发起人（部署者）
    uint public goal; // 众筹目标金额（单位：wei）
    uint public deadline; // 截止时间戳（秒）
    uint public totalFunded; // 当前已筹集总额（单位：wei）

    /// @notice 记录每个支持者的捐款金额（地址 => 金额）
    mapping(address => uint) public contributions;

    // ========== 事件 ==========
    /// @dev 状态变更事件（用于前端监听）
    event StateChanged(State newState);

    /// @dev 提现事件
    event FundsWithdrawn(address indexed recipient, uint256 amount);

    /// @dev 退款事件（indexed 便于按地址查询）
    event Refunded(address indexed contributor, uint amount);

    // @dev 捐款事件（indexed 便于按地址查询） 金额达标，提前结束
    event ContributionReceived(
        address indexed contributor,
        uint amount,
        uint currentTotal
    );

    // ========== 修改器（Modifiers） ==========

    /// @dev 限制函数只能在指定状态下被调用
    modifier inState(State expectedState) {
        require(currentState == expectedState, "Invalid state");
        _;
    }

    /// @dev 限制函数只能由项目发起人（owner）调用
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner");
        _;
    }

    // ========== 构造函数 ==========
    /**
     * @dev 初始化合约：
     *      - 设置部署者为 owner
     *      - 初始状态为 Preparing（准备中）
     */
    constructor() {
        owner = msg.sender;
        currentState = State.Preparing;
    }

    // ========== 核心功能函数 ==========

    /**
     * @notice 启动众筹活动
     * @param _goal 目标金额（单位：wei），必须 > 0
     * @param durationInDays 持续天数，范围 1～90 天
     * @dev 只有 owner 可在 Preparing 状态下调用
     */
    function start( uint _goal, uint durationInDays ) public onlyOwner inState(State.Preparing) {
        require(_goal > 0, "Goal must be positive");
        require(durationInDays > 0 && durationInDays <= 90, "Invalid duration");

        goal = _goal;
        deadline = block.timestamp + (durationInDays * 1 days); // 转换为秒
        currentState = State.Active;

        emit StateChanged(State.Active);
    }

    /**
     * @notice 支持者向众筹捐款
     * @dev 必须在 Active 状态且未超时
     *      捐款金额通过 msg.value 传入（ETH）
     */
    function contribute() public payable inState(State.Active) {
        require(block.timestamp <= deadline, "Campaign ended");
        require(msg.value > 0, "Must send ETH");

        contributions[msg.sender] += msg.value; // 累加该地址的捐款
        totalFunded += msg.value; // 更新总筹款额
        if(totalFunded>=goal){
            currentState = State.Success;
            emit StateChanged(currentState);
        }

        emit ContributionReceived(msg.sender, msg.value, totalFunded);
    }

    /**
     * @notice 结束众筹并判断结果
     * @dev 任何人都可调用，但必须在截止时间之后
     *      - 若达标：资金转给 owner，状态变为 Success
     *      - 若未达标：状态变为 Failed，支持者可退款
     */
    function finalize() public {
        require(currentState == State.Active, "Not active");
        require(block.timestamp > deadline, "Campaign not ended");

        if (totalFunded >= goal) {
            currentState = State.Success;
            // 将全部筹集资金转账给项目发起人
            payable(owner).transfer(totalFunded);
        } else {
            currentState = State.Failed;
        }

        emit StateChanged(currentState);
    }

    /**
     * @notice 众筹失败后，支持者申请退款
     * @dev 仅在 Failed 状态下可用
     *      退款后清零该地址的捐款记录，防止重复退款
     */
    function refund() public inState(State.Failed) {
        uint amount = contributions[msg.sender];
        require(amount > 0, "No contribution");

        contributions[msg.sender] = 0; // 防重入 & 防重复退款
        payable(msg.sender).transfer(amount);

        emit Refunded(msg.sender, amount);
    }

    /**
     * @notice 众筹成功后，创建者提现
     * @dev 仅在 Success 状态下可用
     *      //使用 call转账，避免 gas上限问题
    */
    function withdrawFunds() public onlyOwner inState(State.Success) {
        //先更新状态再转账(遵循 CEI模式)
        currentState = State.Withdrawn;
        emit StateChanged(currentState);
        uint256 amount = address(this).balance; //使用 call转账，避免 gas上限问题

        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "Failed to withdraw funds");
        emit FundsWithdrawn(owner, amount);
    }

    // ========== 查询函数 ==========

    /**
     * @notice 获取众筹当前状态摘要
     * @return state 当前状态
     * @return currentFunding 已筹金额
     * @return targetGoal 目标金额
     * @return timeLeft 剩余时间（秒），若已结束则为 0
     */
    function getStatus()
        public
        view
        returns (
            State state,
            uint currentFunding,
            uint targetGoal,
            uint timeLeft
        )
    {
        uint remaining = 0;
        if (block.timestamp < deadline) {
            remaining = deadline - block.timestamp;
        }

        return (currentState, totalFunded, goal, remaining);
    }
}
