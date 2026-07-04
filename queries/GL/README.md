# GL — General Ledger Queries

Oracle Fusion Cloud ERP 26B. All parameters use `:p_*` bind variables — see [CONVENTIONS.md](../CONVENTIONS.md).

## gl_trial_balance_by_segment.sql

Ending balance and period activity per account/sub-account segment for one ledger, period and currency. Use for UAT balance validation and month-end reconciliation.

**Parameters:** `:p_ledger_name`, `:p_period_name`, `:p_currency_code`, `:p_legal_entity`
**Example:** run for `Jan-26` / `USD` and compare `ending_balance` with the Trial Balance report.

## gl_journal_lines_report.sql

Posted journal batches, headers and lines with concatenated account combination and entered DR/CR — a "razão" (ledger detail) base query.

**Parameters:** `:p_ledger_name`, `:p_period_name`, `:p_legal_entity` (optional), `:p_account` (optional)
**Example:** drill into a single account for one period to explain a balance variation.

## gl_sla_account_analysis.sql

Account analysis unioning subledger accounting lines (XLA — AP/AR/FA/Cost) with posted GL journal lines, showing entered/accounted amounts and full segment breakdown.

**Parameters:** `:p_ledger_name`, `:p_period_name`, `:p_legal_entity`, `:p_account` (optional)
**Example:** explain everything that hit a balance-sheet account in a period, split by source module.
