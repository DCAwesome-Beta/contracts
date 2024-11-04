# Compliance Engine

**DCAwesome** utilizes **Circle Compliance Engine's Transaction Screening APIs** to mitigate risks associated with transactions involving potentially risky entities. The compliance engine enforces a robust set of rules, divided into restrictive and alert-only categories, to safeguard against various risks.

---

## Compliance Rules

### Restrictive Rules

Our platform implements the following compliance controls to manage high-risk transactions and entities effectively:

1. **Sanctions Risk Control**
   - **Action:** Transaction denial and wallet freeze
   - **Associated Risk:** If a user attempts to DCA into a token from an address flagged with sanctions risk, the system automatically denies the transaction and freezes the wallet for review.

2. **Terrorist Financing (TF) Risk Control**
   - **Action:** Transaction denial and wallet freeze
   - **Associated Risk:** If a DCA outflow is set up to a wallet flagged for TF risk, the setup is denied, and the source wallet is frozen.

3. **CSAM Risk Control**
   - **Action:** Transaction denial and wallet freeze
   - **Associated Risk:** If a counterparty wallet involved in a DCA setup shows CSAM risk indicators, all automated transactions are halted, and the wallet is frozen for investigation.

4. **Illicit Behavior Risk Control**
   - **Action:** Transaction denial and wallet freeze
   - **Associated Risk:** If a DCA strategy attempts to interact with a wallet flagged for illicit behavior patterns, automated trades are suspended immediately, and the wallet is frozen.

5. **Politically Exposed Person (PEP) Risk Control**
   - **Action:** Transaction denial
   - **Associated Risk:** DCA setups involving wallets associated with politically exposed persons (PEPs) are automatically denied pending enhanced due diligence.

---

### Alert-Only Rules

In addition to restrictive rules, the platform includes alert-only controls for transactions with moderate risk factors. These alerts allow for ongoing monitoring without interrupting automated processes.

1. **High Illicit Behavior Risk Monitoring**
   - **Action:** Alert generation
   - **Associated Risk:** When DCA transactions involve wallets with elevated risk patterns, the system generates alerts for compliance review while allowing trades to continue.

2. **Gambling Risk Monitoring**
   - **Action:** Alert generation
   - **Associated Risk:** DCA transactions involving wallets with gambling-related patterns trigger alerts for compliance review without interrupting automated processes.

---

This compliance framework ensures that DCAwesome adheres to regulatory standards while effectively managing risk, supporting a secure and trustworthy environment for automated Dollar Cost Averaging (DCA) strategies.
