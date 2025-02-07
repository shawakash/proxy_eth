# Staking Proxy Contract

A upgradeable staking contract system that allows users to stake ERC20 tokens and earn rewards with a 10% APR. The system uses a proxy pattern to enable upgrades while maintaining state.

## Features

- 🔒 Secure staking of ERC20 tokens
- 💰 10% APR rewards
- ⏳ 21-day unstaking period
- 🔄 Upgradeable contract logic via proxy pattern
- ⚡ Gas-efficient implementation
- 🛡️ Reentrancy protection

## Contract Architecture

The system consists of two main contracts:

1. `StakingProxy.sol`: The proxy contract that delegates calls and maintains state
2. `Staking.sol`: The implementation contract containing the staking logic

## Technical Specifications

- Solidity version: ^0.8.13
- Framework: Foundry
- Testing: Forge
- Dependencies: OpenZeppelin Contracts

## Core Functions

### Staking Functions

```solidity
function stake(address _token, uint _amount) external
function startUnstake(address _token, uint _amount) external
function finalizeUnstake(address token) external
function calculateRewards(address _user, address _token) public view returns (uint256)
```

### Proxy Functions

```solidity
function setImplementation(address _impl) public onlyOwner {}
function getImplementation() public view returns (address) {}
```

## Installation

1. Clone the repository:
```bash
git clone https://github.com/shawakash/proxy_stake.git
cd proxy_stake
```

2. Install dependencies:
```bash
forge install
```

## Testing

Run the test suite:
```bash
forge test
```

Run tests with gas reporting:
```bash
forge test --gas-report
```

## Usage

1. Deploy the implementation contract:
```bash
forge create src/Staking.sol:Staking
```

2. Deploy the proxy contract with the implementation address:
```bash
forge create src/StakingProxy.sol:StakingProxy --constructor-args <IMPLEMENTATION_ADDRESS>
```

3. Interact with the proxy contract using the Staking ABI.

## Upgrading

To upgrade the contract:

1. Deploy new implementation
2. Call `setImplementation()` on proxy with new implementation address
3. Verify implementation address with `getImplementation()`

## Security Considerations

- 21-day unstaking period to prevent rapid withdrawals
- Reentrancy guards on critical functions
- Proxy pattern for upgradeable logic
- Owner-only implementation updates
- Comprehensive test coverage

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request
