# DCAwesome
I love DCAing, with hopes of being financially stable. But most of the time, I forget to take profits or just wait a little more(really), to make some extra. As much as we take time to SIP every month or week, we often miss taking profits even if the price touches the moon. I wanted to solve this, for me and every other investor.
It's not Dollar-Cost-Averaging anymore, we just made it Dollar-Cost-Awesome(pun intended :P)

DCAwesome is a Defi-protocol that automates Dollar Cost Averaging (DCA) . It allows users to create personalized, automated cryptocurrency investment strategies by setting up both buy-in (DCAIN) and sell-off (DCAOUT) strategies with time based and price based triggers.

#### User Workflow

- Alice creates a wallet with DCAwesome.
- Alice sets a strategy of DCA-in that every month on the 5th, swap all the USDC in my wallet to ETH.
- Alice also sets a strategy of DCA-out that when ETH reaches 10k, sell all my assets and send me as USDC on BNB chain.
- Alice keeps sending 5 USDC or any arbitrary amount she has,anytime to her wallet address throughout the month.
- On the 5th of every month, all the USDC in her wallet is swapped for ETH.
- When the price of ETH reaches 10k,all of the ETH are exchanged for USDC on BNB chain and stored on her wallet.


## Why DCAwesome?

**Novelty and Uniqueness:** DCAing is the most popular systematic investment planning by long term investors in both traditional and crypto investors. Yet, currently no such solution exists for a decentralized dollar-cost saving application. Although a couple of applications facilitate DCA-in with high fees, they lack a DCA-Out strategy which is far more sought after from passive investors who aim to realize profits from those investments. The strategies are executed with the amount that's currently in the wallet without a restricion to fixed amount.DCAwesome facilitates both DCA-in and DCA-out with minimal fee and safer wallets with AML protections, protecting them from blacklists.Ideally,the project would work great as a widget along with Wormhole Connect.
  
**Clear Communication of Innovation:** DCAwesome uses account abstracted circle's programmable wallets, wormhole sdk for cross chain transfers. The swaps are to be implemented using 1inch.

**Target Audience:** The primary target audience are retail investors who are passive in market updates and with minimal risks appetite.

**Business Viability:** The business model is structured to implement a strategy fee with respect to time.

**Differentiation:** DCAwesome is an integrated investment management dapp with both DCA-in and DCA-out along with AML protection with compliance engine.

**Technical Complexity:** Wormhole integration by combining CCTP's cross-chain messaging with real-time price oracles from chainlink, an automated strategy execution, and a unique multi-chain token custody system that leverages both native USDC token transfers and built in compliance checks with [compliance engine](https://github.com/DCAwesome-Beta/contracts/blob/master/img/compliance.jpeg). Wormhole's VAA (Verified Action Approval) is planned on milestone 2.

**Quality of Code and Architecture:** The Architecture can be found [here](https://github.com/DCAwesome-Beta/contracts/blob/master/img/architecture.jpeg).

**Use of Wormhole Features:** DCAwesome uses wormhole for the cross-chain transfers for DCAin to the desired chain. Besides, the dapp is built to be a widget with wormhole connect. VAA to be implemented.

**Completion Level:** The project has implemented programmable wallets,strategy setting and CCTP transfers. The swaps and design implementations are planned on milestone 2. The project is estimated to be 60% complete.

**Overall Code Quality:** The wormhole sdk and circle sdk are used for. The wallet and compliance engine, DCAstrategy setting and chainlink functions are fully functional and runs as intended. The execution of the strategy is planned for milestone 2. 

**Team Composition:**
- [Hema Devi Umabaarati](https://www.linkedin.com/in/hema-devi-u/) - Product Manager & Smart Contract Developer
- [Parth Gupta](https://www.linkedin.com/in/parth-gupta-bb5615181/) - Full Stack & Smart Contract Developer
- [Stefano Pomelli](https://www.linkedin.com/in/stefano-pomelli-97996b230/) - Designer and Front-End Developer

## Project Details
### Deployed Contracts

CCTP-Transfer Contracts of CCTPTransfer.sol

| Network            | Address                                      |
|--------------------|----------------------------------------------|
| Ethereum Sepolia   | `0x5881772157BbfcCd4921Fc54De405055505BB35E` |
| Arbitrum Sepolia   | `0x545345799636f78E4fdB44049a4BD78368DBdf59` |
| Base Sepolia       | `0xC7b3CB66bD715468cE712437f69eAC82fFA1Da86` |
| Optimism Sepolia   | `0x314b679BbB9a27326B3999e2E32fF1f6D1698176` |
| Avalanche Fuji     | `0xc73409F861755e3cf413b010296944535FA62Ef4` |


### Primary Purpose
A decentralized app (dApp) tailored for retail investors, enabling automated Dollar-Cost Averaging (DCA) saving strategies with built-in regulatory compliance. The platform focuses on the systematic accumulation of high-growth assets and automated profit realization, removing the need for manual intervention.

### Core Objectives
- **Decentralized, Automated DCA:** Facilitate cross-chain DCA strategies with adaptable trigger mechanisms.
- **Regulatory Compliance:** Ensure that all operations meet compliance requirements, integrating transaction monitoring.
- **Simplicity for Retail Users:** Streamline complex DeFi strategies for easy retail adoption.
- **Risk Mitigation:** Lower investment risks through systematic and automated DCA execution.

### Key Features

- **DCA Strategies:**
  - **DCA-In:** Utilizes time-based triggers for asset accumulation.
  - **DCA-Out:** Executes with price-based triggers to realize gains.
- **Flexible DCA Execution:**
  - **Balance-Driven Strategy:** The entire wallet balance serves as the DCA amount.
  - **User Deposits:** Users can send any amount to their wallet for strategy inclusion.
- **Cross-Chain Integration:** 
  - **Wormhole CCTP Integration:** Facilitates cross-chain DCA-Out transactions.
- **Compliance Framework:** Monitors transactions to ensure regulatory compliance.
- **Automated Execution:** Chainlink Automation ensures timely and reliable execution of DCA strategies.



#### Tech Stack
- **Contracts**:Solidity,OpenZeppelin,Chainlink Contracts
- **Cross-Chain Infrastructure**: Wormhole SDK,CCTP Integration,Circle USDC Bridge
- **Backend**:Express JS,Mongoose,MongoDB,Yup,TypeScript,Circle SDK
- **Frontend**:NextJS,Axios,TailwindCSS,TypeScript,Ethers.js

## Tech Workflow

- ### DCA-IN Strategy
1. **User Configuration:**
   - The user sets up a monthly DCA-IN strategy with:
     - **Trigger:** Monthly on the 5th.
     - **Action:** Convert 100% of the wallet's USDC balance to ETH.
     - **Network:** Ethereum Mainnet.
     - **Asset Pair:** USDC → ETH.

2. **Contract Execution:**
   - The user’s strategy is set with the contract, which initiates accumulation.

- ### DCA-OUT Strategy
1. **User Configuration:**
   - A concurrent DCA-OUT strategy is set up with:
     - **Trigger:** ETH price reaching $10,000.
     - **Action:** Convert all ETH holdings to USDC.
     - **Cross-Chain Settlement:** Transfer funds to the BNB Chain.
     - **Asset Pair:** ETH → USDC.

- ### Execution Flow

**Accumulation Phase:**
1. **User Deposits:** Flexible USDC amounts are deposited periodically.
2. **Compliance Checks:** All incoming transactions undergo AML checks through a compliance engine.
3. **Trigger Execution (Monthly):** On the 5th of each month:
   - The smart contract is activated, converting the entire USDC balance to ETH.
   - Positions are tracked, and reports are generated.

**Exit Phase:**
1. **Price Monitoring:** Chainlink continuously monitors ETH prices.
2. **Trigger Execution (Price-based):** When ETH reaches $10,000:
   - **Conversion:** All ETH holdings are converted to USDC.
   - **Cross-Chain Settlement:** Using the CCTP bridge, funds are transferred and settled on the BNB Chain.


Pitch Deck: [View] (https://www.canva.com/design/DAGVeR7S66g/Tie5apeEVm_mXkD3WeUP4w/edit?utm_content=DAGVeR7S66g&utm_campaign=designshare&utm_medium=link2&utm_source=sharebutton)

Pitch Video link: https://youtu.be/od5-powJZsA

﻿Demo link: https://dcawesome-nine.vercel.app/


