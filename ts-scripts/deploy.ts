import { CCTPTransfer__factory } from "./ethers-contracts";
import {
  getWallet,
  storeDeployedAddresses,
  getChain,
  loadDeployedAddresses,
} from "./utils";

export async function deploy() {
  const deployed = loadDeployedAddresses();
  // CCTP enabled chains are ethereum, avalanche, arbitrum, optimism, base
  for (const chainId of [6, 10002, 10003, 10004, 10005]) {
    const chain = getChain(chainId);
    const signer = getWallet(chainId);

    try {
      const CCTPTransfer = await new CCTPTransfer__factory(signer).deploy(
        chain.wormholeRelayer,
        chain.wormhole,
        chain.cctpMessageTransmitter,
        chain.cctpTokenMessenger,
        chain.USDC
      );
      await CCTPTransfer.waitForDeployment();

      deployed.CCTPTransfer[chainId] = await CCTPTransfer.getAddress();
      console.log(
        `CCTPTransfer deployed to ${await CCTPTransfer.getAddress()} on chain ${chainId}`
      );
    } catch (e) {
      console.log(`Unable to deploy CCTPTransfer on chain ${chainId}: ${e}`);
    }
  }

  storeDeployedAddresses(deployed);
}
