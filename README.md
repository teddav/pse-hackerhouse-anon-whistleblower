# Anon DAO Whistleblower

Allows anybody who's part of a DAO to alert on the malfunctions of the DAO anonymously.

A [Gnosis Safe Module](https://docs.safe.global/advanced/smart-account-modules) handles the Semaphore logic.  
When the module is deployed, it creates a Semaphore group, and once attached to a Safe it can perform actions on its behalf.

The DAO then adds the members to the anonymous Semaphore, and anyone can generate a proof and whistleblow.

# Install

You need to have nodejs and [Foundry](https://github.com/foundry-rs/foundry/) installed.

Initialize with

```bash
yarn
```

# Run

## JS script

To generate the Semaphore proof, or upload data to IPFS

```bash
yarn run generate-semaphore-proof
```

## Contracts

```bash
forge test
forge script ./script/WhistleblowFull.s.sol -vvv --broadcast
```

# Acknowledgments

This project was created during the [PSE Hacker House 2024](https://pse.dev) in Brussels.

Thanks a lot to the PSE team for the help and fun during the week!

# Extra

## Otterscan

If running locally, you can use [Otterscan](https://otterscan.io/) as a block explorer.

```bash
anvil --fork-url https://rpc.ankr.com/eth_sepolia
docker pull otterscan/otterscan
docker run --rm -p 5100:80 --name otterscan -d otterscan/otterscan
```

Go to http://localhost:5100/

Verify contract:

```bash
forge verify-contract --verifier sourcify --verifier-url http://localhost:5100 --rpc-url http://localhost:8545 0x4cF93296Aa133Fb62702b79d32e78d08Ebb03bf2 DAOWhistleblower
```
