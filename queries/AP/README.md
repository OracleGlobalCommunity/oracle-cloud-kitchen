# AP — Payables Queries

Oracle Fusion Cloud ERP 26B. All parameters use `:p_*` bind variables — see [CONVENTIONS.md](../CONVENTIONS.md).

## ap_open_invoices_aging.sql

Open (unpaid/partially paid) invoices with amount remaining, payment status, days overdue and aging buckets (0-30 / 31-60 / 61-90 / 90+).

**Parameters:** `:p_bu_name`, `:p_as_of_date`
**Example:** run at month-end with `:p_as_of_date` = period end date to build the AP aging report.

## ap_invoice_distributions_po.sql

Invoices with installments, matched PO number, liability account and distribution accounts/amounts per line — for accounting and PO-matching audits.

**Parameters:** `:p_bu_name`, `:p_gl_date_from`, `:p_gl_date_to`
**Example:** audit which expense accounts a supplier's invoices hit during a quarter.

## ap_invoice_holds.sql

Invoices with an active (unreleased) hold, showing the most recent hold code, type and reason.

**Parameters:** `:p_gl_date_from`, `:p_gl_date_to`, `:p_bu_name` (optional)
**Example:** daily holds queue for the payables team; group by `hold_reason` to attack root causes.
