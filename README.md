# Commit-Reveal pattern in solidity

For more information, see the [commit-reveal pattern](https://github.com/dmdv/useful-solidity-patterns/tree/main/patterns/commit-reveal)

## References

- https://karl.tech/learning-solidity-part-2-voting
- AZTEC protocol

A second scheme, which is more efficient in gas costs, uses the AZTEC protocol (https://www.aztecprotocol.com/) which is already deployed and working on mainnet. In brief, the scheme works like

The election commissioner, for each ballot item, creates a "security" or ERC1724 token and issues a "yes" vote (of value 1) to each registered voter.

Each voter (or their client software) creates two new votes, another "yes" vote of value 1 and a "no" vote of value 0 (a decoy note), and converts their allotted vote into two votes, with blinding factors, that both look random to the public.

Each voter pays their new yes vote to an Ethereum address / contract representing the ballot outcome they want, and their new no vote to another Ethereum address / contract representing the other outcoome. (Could be multiple, e.g. a presidential election could have 3 candidates). This is done using the ERC1724 method confidentialTransfer using what's known as a join-split proof, the sum of the input votes equals the sum of the output votes.

After the voting period is over, each outcome contract is programmed to compare their balance (the number of yes votes they received) to each other using privateRange or publicRange proofs, depending on whether the election wants each candidate to reveal the number of votes they received rather than just comparing who has more.

The winner is recorded on-chain by another, vote-counting contract, and perhaps can be appealed by a panel of supreme court judges via Aragon Court or a similar adjudication protocol.