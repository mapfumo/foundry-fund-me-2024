# Foundry FundMe

## Setup

Foundry setup instructions [here](https://book.getfoundry.sh/getting-started/installation.html)
Additionally you will need to install the chainlink interfaces as follows:-

```bash
$ forge install smartcontractkit/chainlink-brownie-contracts --no-commit # chainlink interfaces
```

**Remap the installed contracts in `foundry.toml`**

```toml
remappings = ["@chainlink/contracts/=lib/chainlink-brownie-contracts/contracts"]
```

## Testing

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

## Run

```bash
$ forge test
```
