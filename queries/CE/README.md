# CE — Cash Management Queries

Oracle Fusion Cloud ERP 26B. All parameters use `:p_*` bind variables — see [CONVENTIONS.md](../CONVENTIONS.md).

## ce_bank_account_setup.sql

Complete setup view of an internal bank account: master data, business unit uses (AP/AR enablement) and GL accounts per use (cash, clearing, charges, gain/loss). Outer joins expose incomplete configurations.

**Parameters:** `:p_bank_account_num`
**Example:** during discovery, validate that every BU using the account has cash and clearing accounts assigned before go-live.
