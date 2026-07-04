# AP — Payables 💸

## 🇧🇷 Versão em Português (PT-BR)

**Queries de Payables — Oracle Fusion Cloud ERP 26B.** Parâmetros em bind variables `:p_*` — veja [CONVENTIONS.md](../CONVENTIONS.md).

### ap_open_invoices_aging.sql

Títulos em aberto (não pagos/parciais) com saldo a pagar, status de pagamento, dias de atraso e buckets de aging (0-30 / 31-60 / 61-90 / 90+).

**Parâmetros:** `:p_bu_name`, `:p_as_of_date`
**Exemplo:** rode no fechamento com `:p_as_of_date` = último dia do período para montar o aging de AP.

### ap_invoice_distributions_po.sql

Faturas com parcelas, PO vinculada, conta de passivo e contas/valores de distribuição por linha — para auditoria contábil e de matching com PO.

**Parâmetros:** `:p_bu_name`, `:p_gl_date_from`, `:p_gl_date_to`
**Exemplo:** audite em quais contas de despesa as faturas de um fornecedor bateram no trimestre.

### ap_invoice_holds.sql

Faturas com hold ativo (não liberado), mostrando o hold mais recente com código, tipo e motivo.

**Parâmetros:** `:p_gl_date_from`, `:p_gl_date_to`, `:p_bu_name` (opcional)
**Exemplo:** fila diária de holds para o time de contas a pagar; agrupe por `hold_reason` para atacar a causa raiz.

---

## 🇺🇸 English Version (EN-US)

**Payables queries — Oracle Fusion Cloud ERP 26B.** Parameters use `:p_*` bind variables — see [CONVENTIONS.md](../CONVENTIONS.md).

### ap_open_invoices_aging.sql

Open (unpaid/partially paid) invoices with amount remaining, payment status, days overdue and aging buckets (0-30 / 31-60 / 61-90 / 90+).

**Parameters:** `:p_bu_name`, `:p_as_of_date`
**Example:** run at month-end with `:p_as_of_date` = period end date to build the AP aging report.

### ap_invoice_distributions_po.sql

Invoices with installments, matched PO number, liability account and distribution accounts/amounts per line — for accounting and PO-matching audits.

**Parameters:** `:p_bu_name`, `:p_gl_date_from`, `:p_gl_date_to`
**Example:** audit which expense accounts a supplier's invoices hit during a quarter.

### ap_invoice_holds.sql

Invoices with an active (unreleased) hold, showing the most recent hold code, type and reason.

**Parameters:** `:p_gl_date_from`, `:p_gl_date_to`, `:p_bu_name` (optional)
**Example:** daily holds queue for the payables team; group by `hold_reason` to attack root causes.
