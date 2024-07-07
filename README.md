# Anon DAO Whistleblower

Allows anybody who's part of a DAO to alert on the malfunctions of the DAO anonymously.

# Otterscan

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

# Run

```bash
forge script ./script/Whistleblow.s.sol -vvv --broadcast
```
