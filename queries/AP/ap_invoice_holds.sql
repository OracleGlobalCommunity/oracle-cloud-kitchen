/*
===============================================================================
AP Invoices on Hold
Author: Daniel Damasceno
Purpose:
    List supplier invoices with an active (unreleased) hold, showing the
    most recent hold with its type and reason. Useful for the payables
    team to work the holds queue.
Tables Used:
    - AP_INVOICES_ALL           (Invoice headers)
    - AP_HOLDS_ALL              (Invoice holds)
    - AP_HOLD_CODES             (Hold code definitions)
    - POZ_SUPPLIERS_V           (Supplier master)
    - POZ_SUPPLIER_SITES_ALL_M  (Supplier sites)
    - FUN_ALL_BUSINESS_UNITS_V  (Business Units)
    - GL_CODE_COMBINATIONS      (Liability account)
Report Output:
    - Business Unit, invoice id, source, type, supplier
    - Invoice number/date/GL date, currency, amount, description
    - Hold reason: hold code + hold type + reason text
Parameters:
    - :p_gl_date_from  GL date range start, format 'YYYY-MM-DD' (e.g. '2026-01-01')
    - :p_gl_date_to    GL date range end,   format 'YYYY-MM-DD' (e.g. '2026-03-31')
    - :p_bu_name       Business Unit name (optional; NULL = all BUs)
Notes:
    - Only the most recent unreleased hold per invoice is returned
      (RELEASE_REASON IS NULL and MAX(HOLD_DATE)).
    - AP_HOLD_CODES.DESCRIPTION does not exist in Fusion Cloud; the hold
      reason text comes from AP_HOLDS_ALL.HOLD_REASON.
Module:
    Oracle Fusion Financials - Payables
===============================================================================
*/
SELECT fabuv.bu_name                                    AS business_unit
     , aia.invoice_id
     , aia.source
     , aia.invoice_type_lookup_code                     AS invoice_type
     , psv.vendor_name                                  AS supplier_name
     , aia.invoice_num
     , aia.invoice_date
     , aia.gl_date
     , aia.invoice_currency_code                        AS currency
     , aia.invoice_amount
     , aia.description
       -- Most recent unreleased hold: code + type + reason text
     , aha.hold_lookup_code
       || ' - ' || ahc.hold_type
       || ' - ' || NVL(aha.hold_reason,'No Reason Provided')
                                                        AS hold_reason
FROM   ap_invoices_all          aia
     , poz_suppliers_v          psv
     , poz_supplier_sites_all_m pssam
     , fun_all_business_units_v fabuv
     , ap_holds_all             aha
     , ap_hold_codes            ahc
     , gl_code_combinations     gcc
WHERE  aia.invoice_id       = aha.invoice_id
AND    aia.org_id           = aha.org_id
AND    aia.org_id           = fabuv.bu_id
AND    aia.vendor_id        = psv.vendor_id
AND    aia.vendor_site_id   = pssam.vendor_site_id
AND    aia.party_id         = psv.party_id
AND    psv.vendor_id        = pssam.vendor_id
AND    aha.hold_lookup_code = ahc.hold_lookup_code
AND    aia.accts_pay_code_combination_id = gcc.code_combination_id
       -- Most recent hold that has not been released
AND    aha.hold_date = ( SELECT MAX(aha2.hold_date)
                         FROM   ap_holds_all aha2
                         WHERE  aha2.invoice_id = aia.invoice_id
                         AND    aha2.org_id     = aia.org_id )
AND    aha.release_reason IS NULL
AND    aia.gl_date BETWEEN TO_DATE(:p_gl_date_from, 'YYYY-MM-DD')
                   AND     TO_DATE(:p_gl_date_to,   'YYYY-MM-DD')
AND    fabuv.bu_name = NVL(:p_bu_name, fabuv.bu_name)
ORDER BY aia.gl_date, aia.invoice_num
