# STATE — Oracle Fusion Query Repository Project

## Status: ✅ COMPLETE

| Step | Status |
|---|---|
| Analyze raw_queries (11 files) | ✅ Done |
| Research Fusion 26B table mappings (official docs + blogs) | ✅ Done |
| Repo scaffold (README, CONVENTIONS, STATE) | ✅ Done |
| GL module (3 queries + README) | ✅ Done |
| AP module (3 queries + README) | ✅ Done |
| FA module (3 queries + README) | ✅ Done |
| CE module (1 query + README) | ✅ Done |
| Verification pass (client data leak + consistency) | ✅ Done — zero client literals found |

## Inventory (10 queries)

- GL: gl_trial_balance_by_segment, gl_journal_lines_report, gl_sla_account_analysis
- AP: ap_open_invoices_aging, ap_invoice_distributions_po, ap_invoice_holds
- FA: fa_asset_deprn_multibook, fa_cost_transactions, fa_categories_by_book
- CE: ce_bank_account_setup

## Decisions log

- Converted ALL queries to Oracle Fusion Cloud ERP **26B** tables/views (user decision).
- No client-specific values anywhere, including doc examples. All literals → `:p_*` bind variables.
- Table names without schema prefix (BIP data model standard).
- EBS-only objects remapped per CONVENTIONS.md (POZ_SUPPLIERS_V, FUN_ALL_BUSINESS_UNITS_V, GL_LEDGERS, FA_TRANSACTION_HEADERS, CE_BANK_ACCOUNTS...).
- Simplifications vs. originals documented in each file's header Notes
  (aging prepayment branch, SLA enrichment columns, PL×SL posted-journal filter).

## Verification results

- Grep for client literals (ledger ids, org ids, LE codes, book names, bank
  accounts, asset numbers, flex value sets, hardcoded periods): **0 matches**.
- 11/11 queries have the standard header (Purpose, Tables Used, Report
  Output, Parameters, Notes, Module).
- 4/4 module READMEs + root README + CONVENTIONS present.

## Next steps (manual)

- `git init` + push to GitHub.
- Do NOT publish the raw .txt files (they contain client data) — only the
  `oracle-fusion-queries/` folder.
