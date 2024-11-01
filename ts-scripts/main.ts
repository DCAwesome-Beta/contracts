import * as ethers from "ethers"
import {
  checkFlag,
  getCCTPTransfer,
  wait,
  getArg,
} from "./utils"
import { deploy } from "./deploy"

async function main() {
  if (checkFlag("--sendRemoteDeposit")) {
    await sendRemoteDeposit()
    return
  }
  if (checkFlag("--deployCCTPTransfer")) {
    await deploy()
    return
  }
}

async function sendRemoteDeposit() {
  const recipient = getArg(["--recipient", "-r"]) || "";

  const from = 6
  const to = 24
  const amount = 1e5

  const cctpTransfer = getCCTPTransfer(from)
  const cost = await cctpTransfer.quoteCrossChainDeposit(to)
  console.log(`Sending 0.1 USDC. cost: ${ethers.formatEther(cost)}`)
  const contract = await getCCTPTransfer(to).getAddress()
  const rx = await cctpTransfer
    .sendCrossChainDeposit(
      to,
      contract,
      recipient,
      amount
    )
    .then(wait)
}

main().catch(e => {
  console.error(e)
  process.exit(1)
})
