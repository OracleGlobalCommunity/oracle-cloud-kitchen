/*
===============================================================================
AP Invoice Distributions with PO and Accounts
Author: Daniel Damasceno
Purpose:
    List supplier invoices with installment info, matched PO number,
    liability account and distribution accounts/amounts per line.
    Useful to audit invoice accounting and PO matching.
Tables Used:
    - AP_INVOICES_ALL               (Invoice headers)
    - AP_PAYMENT_SCHEDULES_ALL      (Installments)
    - AP_INVOICE_DISTRIBUTIONS_ALL  (Distribution lines)
    - POZ_SUPPLIERS_V               (Supplier master)
    - POZ_SUPPLIER_SITES_ALL_M      (Supplier sites)
    - FUN_ALL_BUSINESS_UNITS_V      (Business Units)
    - GL_CODE_COMBINATIONS          (Liability + distribution accounts)
    - PO_HEADERS_ALL                (Purchase orders)
    - PO_DISTRIBUTIONS_ALL          (PO distributions)
Report Output:
    - Business Unit, invoice type/number/date/amount, installment info
    - Amount to pay per installment, source, PO number
    - Supplier name/number/site
    - Liability account and distribution account (concatenated segments)
    - Distribution line number, type and amount
Parameters:
    - :p_bu_name       Business Unit name (FUN_ALL_BUSINESS_UNITS_V.BU_NAME)
    - :p_gl_date_from  GL date range start, format 'YYYY-MM-DD' (e.g. '2026-01-01')
    - :p_gl_date_to    GL date range end,   format 'YYYY-MM-DD' (e.g. '2026-03-31')
Notes:
    - PO join is via AP_INVOICE_DISTRIBUTIONS_ALL.PO_DISTRIBUTION_ID
      (outer join: rows without PO match are kept).
    - Concatenation assumes a 7-segment CoA; adjust to your structure.
    - Converted from EBS R12 (AP_SUPPLIERS, HR_ALL_ORGANIZATION_UNITS)
      to Fusion 26B (POZ_SUPPLIERS_V, FUN_ALL_BUSINESS_UNITS_V).
Module:
    Oracle Fusion Financials - Payables
===============================================================================
*/
SELECT DISTINCT
       fabuv.bu_name                                    AS business_unit
     , DECODE(aia.invoice_type_lookup_code
             ,'CREDIT'  ,'CREDIT MEMO'
             ,'INTEREST','INTEREST INVOICE'
             ,'STANDARD','STANDARD INVOICE'
             , aia.invoice_type_lookup_code)            AS invoice_type
     , aia.invoice_num
     , aia.invoice_date
     , aia.invoice_amount
     , apsa.amount_remaining                            AS amount_to_pay
     , apsa.payment_num                                 AS installment
     , aia.description
     , aia.source
     , pha.segment1                                     AS po_number
     , psv.vendor_name                                  AS supplier_name
     , psv.segment1                                     AS supplier_number
     , pssam.vendor_site_code                           AS supplier_site
     , gcc_liab.segment1 || '.' || gcc_liab.segment2 || '.' ||
       gcc_liab.segment3 || '.' || gcc_liab.segment4 || '.' ||
       gcc_liab.segment5 || '.' || gcc_liab.segment6 || '.' ||
       gcc_liab.segment7                                AS liability_account
     , aida.distribution_line_number
     , aida.line_type_lookup_code                       AS line_type
     , aida.amount                                      AS distribution_amount
     , gcc_dist.segment1 || '.' || gcc_dist.segment2 || '.' ||
       gcc_dist.segment3 || '.' || gcc_dist.segment4 || '.' ||
       gcc_dist.segment5 || '.' || gcc_dist.segment6 || '.' ||
       gcc_dist.segment7                                AS distribution_account
FROM   ap_invoices_all              aia
     , poz_suppliers_v              psv
     , poz_supplier_sites_all_m     pssam
     , fun_all_business_units_v     fabuv
     , ap_payment_schedules_all     apsa
     , ap_invoice_distributions_all aida
     , gl_code_combinations         gcc_dist
     , gl_code_combinations         gcc_liab
     , po_distributions_all         pda
     , po_headers_all               pha
WHERE  aia.vendor_id       = psv.vendor_id
AND    aia.vendor_site_id  = pssam.vendor_site_id
AND    psv.vendor_id       = pssam.vendor_id
AND    aia.org_id          = fabuv.bu_id
AND    aia.invoice_id      = apsa.invoice_id
AND    aia.invoice_id      = aida.invoice_id
AND    aida.dist_code_combination_id     = gcc_dist.code_combination_id
AND    aia.accts_pay_code_combination_id = gcc_liab.code_combination_id
AND    aida.po_distribution_id           = pda.po_distribution_id (+)
AND    pda.po_header_id                  = pha.po_header_id (+)
AND    NVL(aida.amount,0) <> 0
AND    fabuv.bu_name       = :p_bu_name
AND    aia.gl_date         BETWEEN TO_DATE(:p_gl_date_from, 'YYYY-MM-DD')
                           AND     TO_DATE(:p_gl_date_to,   'YYYY-MM-DD')
ORDER BY fabuv.bu_name, aia.invoice_num, aida.distribution_line_number
