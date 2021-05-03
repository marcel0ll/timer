# Timer - a simple time tracking based on ledger-cli

This script is used to simplify my usage of ledger-cli time logging

The idea is simple, you just have to follow this steps:

- Started working: `timer in ACCOUNT [description]`
- Stopped working: `timer out`
- Forgot what you are working on: `timer what`
- Cancel current session: `timer clear`
- Report logged time entries: `timer reg`
- Report logger time balance: `timer bal`

*ACCOUNT follows ledger-cli [account pattern](https://www.ledger-cli.org/3.0/doc/ledger3.html#Structuring-your-Accounts) 
