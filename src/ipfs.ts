import * as dotenv from "dotenv";
dotenv.config({ path: "contracts/.env" });

async function main() {
  try {
    const text = "THIS IS A WARNING! PSE HACKER HOUSE IS ABOUT TO END! 😱";

    const blob = new Blob([text], { type: "text/plain" });
    const file = new File([blob], "whistleblow.txt");
    const data = new FormData();
    data.append("file", file);

    const res = await fetch("https://api.pinata.cloud/pinning/pinFileToIPFS", {
      method: "POST",
      headers: {
        Authorization: `Bearer ${process.env["IPFS_KEY"]}`,
      },
      body: data,
    });
    const resData = await res.json();
    const ipfsHash = resData.IpfsHash;

    console.log(`HASH: ${ipfsHash}`);
    console.log(`
https://cloudflare-ipfs.com/ipfs/${ipfsHash}
https://ipfs.io/ipfs/${ipfsHash}
    `);
  } catch (error) {
    console.log(error);
  }
}

main();
