# Foundry FundMe

## Setup

```bash
$ forge install smartcontractkit/chainlink-brownie-contracts --no-commit # chainlink interfaces
```

**Remap the installed contracts in `foundry.toml`**

```toml
remappings = ["@chainlink/contracts/=lib/chainlink-brownie-contracts/contracts"]
```

## Testing

```bash
$ forge test --match-test testPriceFeedVersionIsAccurate -vvvv --fork-url $SEPOLIA_RPC_URL # testing a specific test function on the sepolia test network. $SEPOLIA_RPC_URL is the url of the test network stored in the .env file which is excluded from the git repo by putting an entry in .gitignore
```

## Run

```bash
$ forge test
```
