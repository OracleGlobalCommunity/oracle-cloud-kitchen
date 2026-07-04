/*
===============================================================================
GL Trial Balance by Segment
Author: Daniel Damasceno
Purpose:
    Retrieve ending balance and period activity per natural account /
    sub-account segment for a given ledger, period and currency.
    Useful for UAT balance validation and month-end reconciliation.
Tables Used:
    - GL_BALANCES            (Account balances per period)
    - GL_CODE_COMBINATIONS   (Chart of Accounts combinations)
    - GL_LEDGERS             (Ledger definitions)
Report Output:
    - Ledger Name
    - Period Name
    - Account (SEGMENT2) and Sub-Account (SEGMENT3)
    - Currency
    - Ending Balance (begin balance + period activity)
    - Period Activity (net movement)
Parameters:
    - :p_ledger_name    Ledger name (GL_LEDGERS.NAME)
    - :p_period_name    GL period (e.g. 'Jan-26')
    - :p_currency_code  Currency (e.g. 'USD')
    - :p_legal_entity   Value of the CoA segment holding the company/LE
Notes:
    - ACTUAL_FLAG = 'A' restricts to actual balances.
    - Adjust SEGMENT1/2/3 references to your Chart of Accounts structure.
    - Converted from an EBS R12 original (APPS.GL_BALANCES) to Fusion 26B.
Module:
    Oracle Fusion Financials - General Ledger
===============================================================================
*/
SELECT gl.name                                             AS ledger_name
     , gb.period_name
     , gcc.segment2                                        AS account
     , gcc.segment3                                        AS sub_account
     , gb.currency_code
       -- Ending balance = beginning balance + period net movement
     , SUM(NVL(gb.begin_balance_dr,0)) - SUM(NVL(gb.begin_balance_cr,0))
       + (SUM(NVL(gb.period_net_dr,0)) - SUM(NVL(gb.period_net_cr,0)))
                                                           AS ending_balance
       -- Net movement of the period
     , SUM(NVL(gb.period_net_dr,0)) - SUM(NVL(gb.period_net_cr,0))
                                                           AS period_activity
FROM   gl_balances          gb
     , gl_code_combinations gcc
     , gl_ledgers           gl
WHERE  gb.code_combination_id = gcc.code_combination_id
AND    gb.ledger_id           = gl.ledger_id
AND    gl.name                = :p_ledger_name
AND    gb.period_name         = :p_period_name        -- 'MMM-YY' e.g. 'Jan-26' (case-sensitive, per accounting calendar)
AND    gb.currency_code       = :p_currency_code
AND    gb.actual_flag         = 'A'
AND    gcc.segment1           = :p_legal_entity
GROUP BY gl.name
       , gcc.segment2
       , gcc.segment3
       , gb.currency_code
       , gb.period_name
ORDER BY gcc.segment2, gcc.segment3
