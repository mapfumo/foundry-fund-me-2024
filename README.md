# Foundry FundMe - Smart Contract development with Solidity and Testing with Foundry

## Quickstart

Foundry setup instructions can be found [here](https://book.getfoundry.sh/getting-started/installation.html)

```bash
$ git clone https://github.com/mapfumo/foundry-fund-me-2024.git
$ cd foundry-fund-me-2024
$ forge build
```

Additionally you will need to install the latest version of the chainlink interfaces as follows:-

```bash
$ forge install smartcontractkit/chainlink-brownie-contracts --no-commit # chainlink interfaces
```

**Remap the installed contracts in `foundry.toml`**

```toml
remappings = ["@chainlink/contracts/=lib/chainlink-brownie-contracts/contracts"]
```

**_Note:_** You will need to create a `.env` file in the root of the project and add the following of your own:-

PRVATATE_KEY=0x...

SEPOLIA_RPC_URL=https://eth-sepolia.g.alchemy.com/YOUR_URL

ETHERSCAN_API_KEY=YOUR_ETHERSCAN_API_KEY

## Testing & Notes

```bash
$ forge test # testing all
$ forge test --match-test testPriceFeedVersionIsAccurate -vvvv --fork-url $SEPOLIA_RPC_URL # testing a specific test function on the sepolia test network. $SEPOLIA_RPC_URL is the url of the test network stored in the .env file which is excluded from the git repo by putting an entry in .gitignore
```

### A test that fails for the test function to PASS

When testing the `fund()` function. We expect the transaction to revert/fail when the amount of ETH sent is less than the minimum requirement. To test this, we can use the Foundry `vm.expectRevert()` cheatcode to check if the transaction reverts or not when there is insufficient amount to fund the transactions. In short **_"we write a test condition that fails for our test function to pass"_**.

```solidity
function testFundFailIsWithoutEnoughEth() external {
        vm.expectRevert();
        // It will pass because the following line is failing and that's what we want
        fundMe.fund(); // zero amount (< MINIMUM_USD). It will be reverted.
    }
```

## Gas Report & Notes

To generate a gas report, run the following command:-

```bash
$ forge snapshot # all the test functions
$ forge snapshot --match-test testWithdrawWithMultipleFunders # create .gas-snapshot file for a specific test function
```

When working with a local Anvil chain, the gas price defaults to zero. This feature simplifies testing and development by eliminating gas costs, allowing developers to interact with the blockchain without needing actual Ether. This is common in local development environments like Anvil, Ganache, and Hardhat Network, streamlining the development process by removing economic constraints.

By using `tx.GasPrice`, you can set a custom gas price for transactions, which can be useful for testing different scenarios without actual economic impact.

## Storage Layout

From [EVM.CODES](https://www.evm.codes) we can see that storing variables in storage is expensive. For example SLOAD operation costs 100 gas as compared to other operations that require 3-5 gas. Each time we read from storage we pay a minimum of 100 gas. SSTORE is the operation that stores value in storage and also costs a minimum of 100 gas.

Compare this to MLOAD (Memory Load) amd MSTORE (Memory Store) that both costs 3 gas.

For this reason `cheaperWithdraw()` function is more gas efficient than `withdraw()` as it only reads from storage once and not multiple times.

```bash
$ forge snapshot # get the gas snapshot for all the test functions
```

From `.gas-snapshop` we have saved 963 gas by minimising storage reads.

```bash
FundMeTest:testWithdrawWithMultipleFunders() (gas: 488721)
FundMeTest:testWithdrawWithMultipleFundersCheaper() (gas: 487758)
```

## Interactions

### [Foundry-dev-ops](https://github.com/chainaccelorg/foundry-devops)

A repo to get the most recent deployment from a given environment in foundry. This way, you can do scripting off previous deployments in solidity.

- Get the most recent deployment of a contract in foundry
- Checking if your on a zkSync based chain

```bash
$ forge install chainaccelorg/foundry-devops --no-commit # foundry devops
```

Set ffi to true in foundry.toml

```toml
remappings = ["@chainlink/contracts/=lib/chainlink-brownie-contracts/contracts"]
ffi = true # allows foundry to run commands directly on your machine
```
