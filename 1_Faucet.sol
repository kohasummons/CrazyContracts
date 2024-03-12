// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract faucet {
    address payable owner;
    IERC20 public token;

    uint256 public withdrawalAmount = 10 * (10**18);
    uint256 lockTime = 1 minutes;

    event Withdrawl(address indexed to, uint256 indexed amount);
    event Deposit(address indexed from, uint256 indexed amount);

    mapping(address => uint256) nextAccessTime;

    modifier onlyOwner(){
        require(msg.sender == owner, "Only the contract owner can call this function");
        _;
    }

    constructor(address tokenAddress) payable {
        token = IERC20(tokenAddress);
        owner = payable(msg.sender);
    }

    function requestTokens() public {
        require(msg.sender != address(0), "Request cannot be intiated from a zero account");
        require(token.balanceOf(address(this)) >= withdrawalAmount, "Faucet Wallet balance is low.");
        require(block.timestamp >= nextAccessTime[msg.sender], "You need to wait longer");

        nextAccessTime[msg.sender] = block.timestamp + lockTime;

        token.transfer(msg.sender, withdrawalAmount);
    }

    function getBalance() external view  returns (uint256) {
        return token.balanceOf(address(this));
    }

    function setWithdrawlAmount(uint256 _amount) public onlyOwner {
        withdrawalAmount = _amount * (10 ** 18);
    }
    function setLockTime(uint256 _lockDuration) public onlyOwner {
        lockTime = _lockDuration * 1 minutes;
    }


    function withdraw() external onlyOwner {
        emit Withdrawl(msg.sender, token.balanceOf(address(this)));
        token.transfer(msg.sender, token.balanceOf(address(this)));
    }

    receive() external payable {
        emit Deposit(msg.sender, msg.value);
    }
}