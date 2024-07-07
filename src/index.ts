import { Identity } from "@semaphore-protocol/identity";
import { Group } from "@semaphore-protocol/group";
import { generateProof, verifyProof } from "@semaphore-protocol/proof";
import { Wallet, verifyMessage } from "ethers";

const pks = [
  "0x47e179ec197488593b187f80a00eb0da91f1b9d0b13f8733639f19c30a34926a",
  "0x8b3a350cf5c34c9194ca85829a2df0ec3153be0318b5e2d3348e872092edffba",
  "0x92db14e403b83dfe3df233f83dfa3a0d7096f21ca9b0d6d6b8d88b2b4ec1564e",
];

const assert = (a: boolean, e: string) => {
  if (!a) throw new Error(e);
};

async function signMessage(message: string, pk: string) {
  let signer = new Wallet(pk);
  let signature: string = await signer.signMessage(message);
  assert(verifyMessage(message, signature) === signer.address, "failed to verify message with signature");
  return signature;
}

async function generateIdentity(message: string, pk: string) {
  let signature = await signMessage(message, pk);
  return new Identity(signature);
}

async function main() {
  const group = new Group();

  const ids = await Promise.all(pks.map((pk) => generateIdentity("gnosis safe owner", pk)));

  for (const id of ids) {
    // let mess = "Hello World";
    // let sig = id.signMessage(mess);
    // assert(Identity.verifySignature(mess, sig, id.publicKey), "couldn't verify Identity");

    group.addMember(id.commitment);
  }

  console.log(group.members);

  let merkleProof = group.generateMerkleProof(0);
  console.log("merkleProof", merkleProof);

  const message = "test4";

  const proof = await generateProof(ids[0], merkleProof, message, "test4");
  assert(await verifyProof(proof), "couldn't verify semaphore proof");

  console.log(proof);
}
main();
