# Conventions — Oracle Fusion ERP Query Repository

All queries in this repository follow these standards.

## Target platform

- **Oracle Fusion Cloud ERP 26B** (BI Publisher / OTBI data model SQL).
- Table names are referenced **without schema prefix** (standard for BIP data models).
- Queries converted from EBS R12 originals were remapped to Fusion tables:

| EBS R12 (original) | Fusion Cloud 26B (this repo) |
|---|---|
| `APPS.*` schema | no prefix |
| `GL_SETS_OF_BOOKS` | `GL_LEDGERS` |
| `AP_SUPPLIERS` | `POZ_SUPPLIERS_V` |
| `AP_SUPPLIER_SITES_ALL` | `POZ_SUPPLIER_SITES_ALL_M` |
| `HR_ALL_ORGANIZATION_UNITS` / `HR_OPERATING_UNITS` | `FUN_ALL_BUSINESS_UNITS_V` |
| `AP_INVOICES_V` | `AP_INVOICES_ALL` + joins |
| `FA_FINANCIAL_INQUIRY_COST_V` | `FA_TRANSACTION_HEADERS` + joins |
| `CLL_F035_BANK_ACCOUNTS_V` (BR localization) | `CE_BANK_ACCOUNTS` |
| `GL_JE_SOURCES` | `GL_JE_SOURCES_TL` |
| `MO_GLOBAL.SET_POLICY_CONTEXT` | not required (BIP) |

## Bind variables

All client-specific literals are replaced by bind variables, prefixed `:p_`:

| Variable | Meaning | Example value |
|---|---|---|
| `:p_ledger_name` | Ledger name (GL_LEDGERS.NAME) | `XX Primary Ledger` |
| `:p_period_name` | Period name, `'MMM-YY'` by default — case-sensitive, must match the accounting/FA calendar exactly | `Jan-26` |
| `:p_currency_code` | Currency | `USD` |
| `:p_legal_entity` | CoA segment holding LE/company | `1000` |
| `:p_account` | Natural account segment | `11010` |
| `:p_bu_name` | Business Unit name (FUN_ALL_BUSINESS_UNITS_V.BU_NAME) | `XX Brazil BU` |
| `:p_book_type_code` | FA depreciation book | `XX CORP BOOK` |
| `:p_asset_number` | Asset number | `100001` |
| `:p_bank_account_num` | Bank account number | `12345678` |
| `:p_gl_date_from` / `:p_gl_date_to` | GL date range, always `'YYYY-MM-DD'` via explicit `TO_DATE` | `2026-01-01` |

> Date rule: date parameters are always compared with
> `TO_DATE(:p_x, 'YYYY-MM-DD')` — never rely on implicit conversion,
> which breaks depending on the session `NLS_DATE_FORMAT`.

> Chart of Accounts note: segment roles (legal entity, account, cost center) vary
> by implementation. Adjust `SEGMENT1..SEGMENTn` references to your CoA structure.

> Parameter usability rule: parameters ask for what users actually know —
> names, numbers and codes (`:p_bu_name`, `:p_asset_number`, `:p_ledger_name`) —
> never internal ids. Id resolution happens inside the query via joins.

## Table aliases

Aliases are the initials of each underscore-separated token of the table name:

| Table | Alias |
|---|---|
| `AP_INVOICES_ALL` | `aia` |
| `AP_PAYMENT_SCHEDULES_ALL` | `apsa` |
| `AP_INVOICE_DISTRIBUTIONS_ALL` | `aida` |
| `AP_HOLDS_ALL` / `AP_HOLD_CODES` | `aha` / `ahc` |
| `POZ_SUPPLIERS_V` / `POZ_SUPPLIER_SITES_ALL_M` | `psv` / `pssam` |
| `FUN_ALL_BUSINESS_UNITS_V` | `fabuv` |
| `GL_BALANCES` / `GL_LEDGERS` | `gb` / `gl` |
| `GL_CODE_COMBINATIONS` | `gcc` (twice in a query: `gcc_liab`, `gcc_dist`) |
| `GL_JE_BATCHES` / `GL_JE_HEADERS` / `GL_JE_LINES` | `gjb` / `gjh` / `gjl` |
| `GL_JE_SOURCES_TL` | `gjst` |
| `XLA_AE_HEADERS` / `XLA_AE_LINES` | `xah` / `xal` |
| `FA_ADDITIONS_B` / `FA_ADDITIONS_TL` | `fab` / `fat` |
| `FA_BOOKS` / `FA_METHODS` / `FA_TRANSACTION_HEADERS` | `fb` / `fm` / `fth` |
| `FA_DEPRN_SUMMARY` / `FA_DEPRN_PERIODS` | `fds` / `fdp` |
| `FA_CATEGORIES_B` / `FA_CATEGORY_BOOKS` | `fcb` / `fcbs` |
| `FA_DISTRIBUTION_HISTORY` / `FA_LOCATIONS` | `fdh` / `fl` |
| `PO_HEADERS_ALL` / `PO_DISTRIBUTIONS_ALL` | `pha` / `pda` |
| `CE_BANK_ACCOUNTS` / `CE_BANK_ACCT_USES_ALL` / `CE_GL_ACCOUNTS_CCID` | `cba` / `cbaua` / `cgac` |

On alias collision, disambiguate with a suffix (`fcbs`) or a role suffix (`gcc_liab`).

## File standards

- One query per `.sql` file, name in `snake_case` prefixed by module (`gl_`, `ap_`, `fa_`, `ce_`).
- Every file starts with a standard header block: Purpose, Tables Used, Report Output, Parameters, Notes, Module.
- Every module folder has a `README.md` describing each query.
- Language filters use `USERENV('LANG')` instead of hardcoded languages.
