/*
===============================================================================
AP Open Invoices Aging
Author: Daniel Damasceno
Purpose:
    List open (unpaid or partially paid) supplier invoices with amount
    remaining, payment status and aging buckets based on due date.
    Base query for an AP aging / open items report.
Tables Used:
    - AP_INVOICES_ALL           (Invoice headers)
    - AP_PAYMENT_SCHEDULES_ALL  (Installments / due dates / amount remaining)
    - POZ_SUPPLIERS_V           (Supplier master)
    - FUN_ALL_BUSINESS_UNITS_V  (Business Units)
Report Output:
    - Business Unit, Supplier number/name
    - Invoice type, number, date, GL date, period, due date
    - Currency, description, invoice amount, amount remaining
    - Payment status (NOT PAID / PARTIALLY PAID)
    - Days overdue and aging bucket (0-30 / 31-60 / 61-90 / 90+)
Parameters:
    - :p_bu_name     Business Unit name (FUN_ALL_BUSINESS_UNITS_V.BU_NAME)
    - :p_as_of_date  Aging reference date, format 'YYYY-MM-DD' (usually the
                     period end date; use TRUNC(SYSDATE) directly if preferred)
Notes:
    - PAYMENT_STATUS_FLAG: 'N' = not paid, 'P' = partially paid, 'Y' = paid.
    - Cancelled invoices excluded (CANCELLED_DATE IS NULL).
    - Simplification vs. EBS original: prepayment-applied invoices are
      covered by AMOUNT_REMAINING on the schedule; the separate prepayment
      UNION branch was dropped. Check AP_PREPAY_HISTORY_ALL for advance
      application details if needed.
    - Converted from EBS R12 (AP_INVOICES_V, AP_SUPPLIERS) to Fusion 26B
      (AP_INVOICES_ALL, POZ_SUPPLIERS_V).
Module:
    Oracle Fusion Financials - Payables
===============================================================================
*/
SELECT fabuv.bu_name                                    AS business_unit
     , psv.segment1                                     AS supplier_number
     , psv.vendor_name                                  AS supplier_name
     , aia.invoice_type_lookup_code                     AS invoice_type
     , aia.invoice_num
     , aia.invoice_date
     , aia.gl_date
     , TO_CHAR(aia.gl_date,'MON-YYYY')                  AS gl_period
     , apsa.due_date
     , aia.invoice_currency_code                        AS currency
     , aia.description
     , aia.invoice_amount
     , apsa.amount_remaining
     , DECODE(aia.payment_status_flag, 'N','NOT PAID'
                                     , 'P','PARTIALLY PAID'
                                     , aia.payment_status_flag)
                                                        AS payment_status
       -- Days overdue relative to the reference date
     , GREATEST(TO_DATE(:p_as_of_date,'YYYY-MM-DD') - TRUNC(apsa.due_date), 0)
                                                        AS days_overdue
     , CASE
         WHEN TO_DATE(:p_as_of_date,'YYYY-MM-DD') - TRUNC(apsa.due_date) <= 0  THEN 'NOT DUE'
         WHEN TO_DATE(:p_as_of_date,'YYYY-MM-DD') - TRUNC(apsa.due_date) <= 30 THEN '0-30'
         WHEN TO_DATE(:p_as_of_date,'YYYY-MM-DD') - TRUNC(apsa.due_date) <= 60 THEN '31-60'
         WHEN TO_DATE(:p_as_of_date,'YYYY-MM-DD') - TRUNC(apsa.due_date) <= 90 THEN '61-90'
         ELSE '90+'
       END                                              AS aging_bucket
FROM   ap_invoices_all           aia
     , ap_payment_schedules_all  apsa
     , poz_suppliers_v           psv
     , fun_all_business_units_v  fabuv
WHERE  aia.invoice_id          = apsa.invoice_id
AND    aia.org_id              = apsa.org_id
AND    aia.vendor_id           = psv.vendor_id
AND    aia.org_id              = fabuv.bu_id
AND    fabuv.bu_name           = :p_bu_name
AND    aia.cancelled_date      IS NULL
AND    aia.payment_status_flag IN ('N','P')       -- open items only
AND    NVL(apsa.amount_remaining,0) <> 0
ORDER BY psv.vendor_name, apsa.due_date
