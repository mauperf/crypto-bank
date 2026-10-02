// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract CryptoBank is Ownable {
    uint256 public maxBalancePerUser;

    mapping(address => uint256) public userBalances;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);

    error ZeroAmount();
    error MaxBalanceSurpassed();
    error InsufficientFunds();

    constructor(uint256 _maxBalancePerUser) Ownable(msg.sender) {
        maxBalancePerUser = _maxBalancePerUser;
    }

    function setMaxBalancePerUser(uint256 _maxBalancePerUser) external onlyOwner {
        if (_maxBalancePerUser == 0) revert ZeroAmount();
        maxBalancePerUser = _maxBalancePerUser;
    }

    function deposit() external payable {
        if (userBalances[msg.sender] + msg.value > maxBalancePerUser) revert MaxBalanceSurpassed();

        userBalances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) external {
        if (_amount > userBalances[msg.sender]) revert InsufficientFunds();

        userBalances[msg.sender] -= _amount;
        (bool _success,) = msg.sender.call{value: _amount}("");
        require(_success, "Transfer failed");

        emit Withdraw(msg.sender, _amount);
    }
}
