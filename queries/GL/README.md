# GL — General Ledger 📒

## 🇧🇷 Versão em Português (PT-BR)

**Queries de General Ledger — Oracle Fusion Cloud ERP 26B.** Parâmetros em bind variables `:p_*` — veja [CONVENTIONS.md](../CONVENTIONS.md).

### gl_trial_balance_by_segment.sql

Saldo final e movimento do período por conta/subconta para um ledger, período e moeda. Uso típico: validação de saldos em UAT e reconciliação de fechamento.

**Parâmetros:** `:p_ledger_name`, `:p_period_name`, `:p_currency_code`, `:p_legal_entity`
**Exemplo:** rode para `Jan-26` / `USD` e compare o `ending_balance` com o relatório de balancete.

### gl_journal_lines_report.sql

Lotes, lançamentos e linhas contábeis postados, com conta concatenada e débito/crédito — query base de razão contábil.

**Parâmetros:** `:p_ledger_name`, `:p_period_name`, `:p_legal_entity` (opcional), `:p_account` (opcional)
**Exemplo:** detalhe uma conta em um período para explicar a variação de saldo.

### gl_sla_account_analysis.sql

Account analysis unindo lançamentos de subledger (XLA — AP/AR/FA/Cost) com linhas de diário GL postadas: valores entered/accounted e abertura completa por segmento.

**Parâmetros:** `:p_ledger_name`, `:p_period_name`, `:p_legal_entity`, `:p_account` (opcional)
**Exemplo:** explique tudo que bateu numa conta patrimonial no período, separado por módulo de origem.

---

## 🇺🇸 English Version (EN-US)

**General Ledger queries — Oracle Fusion Cloud ERP 26B.** Parameters use `:p_*` bind variables — see [CONVENTIONS.md](../CONVENTIONS.md).

### gl_trial_balance_by_segment.sql

Ending balance and period activity per account/sub-account for one ledger, period and currency. Typical use: UAT balance validation and month-end reconciliation.

**Parameters:** `:p_ledger_name`, `:p_period_name`, `:p_currency_code`, `:p_legal_entity`
**Example:** run for `Jan-26` / `USD` and compare `ending_balance` with the Trial Balance report.

### gl_journal_lines_report.sql

Posted journal batches, headers and lines with concatenated account and entered DR/CR — a ledger detail base query.

**Parameters:** `:p_ledger_name`, `:p_period_name`, `:p_legal_entity` (optional), `:p_account` (optional)
**Example:** drill into a single account for one period to explain a balance variation.

### gl_sla_account_analysis.sql

Account analysis unioning subledger accounting lines (XLA — AP/AR/FA/Cost) with posted GL journal lines: entered/accounted amounts and full segment breakdown.

**Parameters:** `:p_ledger_name`, `:p_period_name`, `:p_legal_entity`, `:p_account` (optional)
**Example:** explain everything that hit a balance-sheet account in a period, split by source module.
