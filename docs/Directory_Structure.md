## Directory Structure

The directories here are organized into contracts, scripts, and transactions.

Contracts contain the source code for the TriQuetaNFT and TriQueta that are deployed to Flow BlockChain.

Scripts contain read-only transactions to get information about
the state of someones Collection or about the state of the TriQuetaNFT and TriQueta.

Transactions contain the transactions that various users can use
to perform actions in the smart contract like creating Brand, Schema, Templates and Mint Templates.

- `contracts/` : Where the TriQuetaNFT and TriQueta smart contracts live.
- `transactions/` : This directory contains all the transactions and scripts
  that are associated with these smart contracts.
- `scripts/` : This contains all the read-only Cadence scripts
  that are used to read information from the smart contract
  or from a resource in account storage.
- `test/` : This directory contains testcases in Golang and Javascript. 'go' direcotry contains
  Golang testcases and 'js' directory contains Javascript testcases. See the README in `go/` and `js/` for more information
  about how to run testcases.
