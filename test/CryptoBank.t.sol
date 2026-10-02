// SPDX-License-Identifier: MIT

pragma solidity 0.8.30;

import {Test} from "../lib/forge-std/src/Test.sol";
import {console} from "../lib/forge-std/src/console.sol";
import {CryptoBank} from "../src/CryptoBank.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract TestCryptoBank is Test {
    CryptoBank cryptoBank;

    address deployer = vm.addr(1);
    address user1 = vm.addr(2);
    address user2 = vm.addr(3);

    function setUp() external {
        vm.startPrank(deployer);
        cryptoBank = new CryptoBank(2 ether);
        vm.stopPrank();
    }

    function testRevertSetMaxBalancePerUser_NotOwner() external {
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(Ownable.OwnableUnauthorizedAccount.selector, user1));
        cryptoBank.setMaxBalancePerUser(1);
    }

    function testRevertSetMaxBalancePerUser_ZeroAmount() external {
        vm.prank(deployer);
        vm.expectRevert(abi.encodeWithSelector(CryptoBank.ZeroAmount.selector));
        cryptoBank.setMaxBalancePerUser(0);
    }

    function testSetMaxBalancePerUser() external {
        uint256 _maxBalancePerUser = 5 * 1e18;
        uint256 _maxBalancePerUserBefore = cryptoBank.maxBalancePerUser();
        vm.prank(deployer);
        cryptoBank.setMaxBalancePerUser(_maxBalancePerUser);
        uint256 _maxBalancePerUserAfter = cryptoBank.maxBalancePerUser();
        assert(_maxBalancePerUserBefore != _maxBalancePerUserAfter);
        assert(_maxBalancePerUserAfter == _maxBalancePerUser);
    }

    function testRevertDeposit_MaxBalanceSurpassed() external {
        vm.deal(user1, 3 ether);
        vm.prank(user1);
        vm.expectRevert(abi.encodeWithSelector(CryptoBank.MaxBalanceSurpassed.selector));
        cryptoBank.deposit{value: 3 ether}();
    }

    function testDeposit() external {
        vm.deal(user1, 3 ether);
        vm.prank(user1);

        uint256 _beforeUserBalance = user1.balance;

        uint256 _amountToDeposit = 2 ether;
        cryptoBank.deposit{value: _amountToDeposit}();

        uint256 _afterUserBalance = user1.balance;

        assert(_beforeUserBalance - _amountToDeposit == _afterUserBalance);
        assert(cryptoBank.userBalances(user1) == _amountToDeposit);
    }

    function testRevertWithdraw_InsufficientFunds() external {
        vm.deal(user1, 3 ether);
        vm.startPrank(user1);

        uint256 _beforeUserBalance = user1.balance;

        uint256 _amountToDeposit = 1 ether;
        cryptoBank.deposit{value: _amountToDeposit}();

        uint256 _afterUserBalance = user1.balance;

        assert(_beforeUserBalance - _amountToDeposit == _afterUserBalance);
        assert(cryptoBank.userBalances(user1) == _amountToDeposit);

        vm.expectRevert(abi.encodeWithSelector(CryptoBank.InsufficientFunds.selector));
        cryptoBank.withdraw(2 ether);

        vm.stopPrank();
    }

    function testWithdraw() external {
        vm.deal(user1, 3 ether);
        vm.startPrank(user1);

        uint256 _beforeUserBalance = user1.balance;

        uint256 _amountToDeposit = 1 ether;
        cryptoBank.deposit{value: _amountToDeposit}();

        uint256 _afterUserBalance = user1.balance;

        assert(_beforeUserBalance - _amountToDeposit == _afterUserBalance);
        assert(cryptoBank.userBalances(user1) == _amountToDeposit);

        uint256 _amountToWithdraw = 0.5 ether;
        cryptoBank.withdraw(_amountToWithdraw);

        uint256 _afterWithdrawUserBalance = user1.balance;

        assert(_afterUserBalance + _amountToWithdraw == _afterWithdrawUserBalance);
        assert(_amountToDeposit - _amountToWithdraw == cryptoBank.userBalances(user1));

        vm.stopPrank();
    }
}
