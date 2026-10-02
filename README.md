# CryptoBank

A simple ether bank written in Solidity with [Foundry](https://book.getfoundry.sh/). Each user can deposit and withdraw their own ether, up to a per-user maximum balance set by the contract owner.

## Features

- **Deposits**: any user can deposit ether into the bank.
- **Withdrawals**: each user can withdraw all or part of the ether they have deposited.
- **Per-user maximum balance**: no user can exceed the `maxBalancePerUser` limit.
- **Administration**: only the owner (the deployer) can change the limit. Uses OpenZeppelin's `Ownable`.

## Contract

[`src/CryptoBank.sol`](src/CryptoBank.sol)

### State

| Variable | Type | Description |
| --- | --- | --- |
| `maxBalancePerUser` | `uint256` | Maximum balance (in wei) each user can hold in the bank. |
| `userBalances` | `mapping(address => uint256)` | Deposited balance of each user (in wei). |

### Functions

| Function | Access | Description |
| --- | --- | --- |
| `constructor(uint256 _maxBalancePerUser)` | — | Sets the initial maximum balance and makes the deployer the owner. |
| `deposit()` | Public, `payable` | Deposits the `msg.value` sent. Reverts with `MaxBalanceSurpassed` if the resulting balance exceeds `maxBalancePerUser`. |
| `withdraw(uint256 _amount)` | Public | Sends `_amount` wei back to the caller. Reverts with `InsufficientFunds` if the caller's balance is too low. |
| `setMaxBalancePerUser(uint256 _maxBalancePerUser)` | Owner only | Updates the maximum balance. Reverts with `ZeroAmount` if the value is 0. |

### Events

- `Deposit(address indexed user, uint256 amount)`
- `Withdraw(address indexed user, uint256 amount)`

### Errors

- `ZeroAmount()`: the new limit is 0.
- `MaxBalanceSurpassed()`: the deposit would make the user's balance exceed the limit.
- `InsufficientFunds()`: the user tries to withdraw more than they have deposited.
- `OwnableUnauthorizedAccount(address)`: a non-owner account tries to change the limit (from OpenZeppelin).

### Security

`withdraw` follows the Checks-Effects-Interactions pattern: it deducts the user's balance before sending the ether with `call`, which prevents reentrancy attacks.

## Tests

[`test/CryptoBank.t.sol`](test/CryptoBank.t.sol) covers:

- Changing the limit as the owner, and the reverts when the caller is not the owner or the value is 0.
- Depositing exactly up to the limit, and the revert when a deposit exceeds it.
- Partial withdrawals, and the revert when the balance is insufficient.

## Usage

### Requirements

- [Foundry](https://book.getfoundry.sh/getting-started/installation)

### Installation

```shell
git clone --recurse-submodules <repo-url>
cd CryptoBank
```

If you already cloned the repository without submodules:

```shell
git submodule update --init --recursive
```

### Build

```shell
forge build
```

### Run the tests

```shell
forge test
```

With more detail (call traces):

```shell
forge test -vvv
```

### Format

```shell
forge fmt
```

## Dependencies

- [forge-std](https://github.com/foundry-rs/forge-std): testing utilities.
- [OpenZeppelin Contracts](https://github.com/OpenZeppelin/openzeppelin-contracts): `Ownable`.

## CI

The [`.github/workflows/test.yml`](.github/workflows/test.yml) workflow runs on every push and pull request. It checks formatting (`forge fmt --check`), builds the contracts and runs the tests.

## License

MIT
