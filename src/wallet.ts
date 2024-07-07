import * as dotenv from "dotenv";
dotenv.config({ path: "../contracts/.env" });

import { JsonRpcProvider, Wallet, parseEther } from "ethers";

// async function generateWallet() {
//   let wallet = Wallet.createRandom();
//   console.log(wallet.privateKey);
// }

async function main() {
  const wallet = new Wallet(process.env["PRIVATE_KEY"]!);
  console.log("address", wallet.address);

  // anvil --fork-url https://rpc.ankr.com/eth_sepolia
  const provider = new JsonRpcProvider("http://127.0.0.1:8545");
  // const provider = new JsonRpcProvider("https://rpc.ankr.com/eth_sepolia");

  const signer = wallet.connect(provider);

  let balance = await provider.getBalance(wallet.address);
  console.log("balance", balance);

  const to = Wallet.createRandom().address;
  console.log("to", to);
  let tx = await (
    await signer.sendTransaction({
      to,
      value: parseEther("1"),
      data: "0x69206861766520736f6d657468696e6720746f2072657665616c21",
    })
  ).wait();
}

main();
