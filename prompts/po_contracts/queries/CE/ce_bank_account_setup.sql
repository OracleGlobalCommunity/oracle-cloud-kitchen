/*
===============================================================================
CE Internal Bank Account Setup with BU and GL Accounts
Author: Daniel Damasceno
Purpose:
    Show the complete setup of an internal bank account: master data,
    business unit uses (AP/AR enablement) and the GL accounts assigned
    to each use (cash, cash clearing, bank charges, gain/loss).
    Consolidates a 3-step investigation into a single query.
Tables Used:
    - CE_BANK_ACCOUNTS          (Internal bank accounts - LE level)
    - CE_BANK_ACCT_USES_ALL     (Account uses per Business Unit)
    - FUN_ALL_BUSINESS_UNITS_V  (Business Units)
    - CE_GL_ACCOUNTS_CCID       (GL accounts per account use)
    - GL_CODE_COMBINATIONS      (Cash account combination)
Report Output:
    - Bank account id, name, number, currency
    - Business Unit name, AP/AR use flags, end date
    - Cash account natural segment (SEGMENT4 - adjust to your CoA)
    - Cash clearing, bank charges, gain and loss CCIDs
Parameters:
    - :p_bank_account_num  Bank account number (CE_BANK_ACCOUNTS.BANK_ACCOUNT_NUM)
Notes:
    - Outer joins keep bank accounts that have uses without GL account
      setup (helps catch incomplete configuration).
    - Replaces the EBS original's HR_OPERATING_UNITS with
      FUN_ALL_BUSINESS_UNITS_V.
    - Change SEGMENT4 to the segment holding the natural account in
      your Chart of Accounts.
Module:
    Oracle Fusion Financials - Cash Management
===============================================================================
*/
SELECT cba.bank_account_id
     , cba.bank_account_name
     , cba.bank_account_num
     , cba.currency_code
     , fabuv.bu_name                                     AS business_unit
     , cbaua.ap_use_enable_flag                          AS ap_enabled
     , cbaua.ar_use_enable_flag                          AS ar_enabled
     , cbaua.end_date                                    AS use_end_date
     , gcc.segment4                                      AS cash_account_segment
     , cgac.asset_code_combination_id                    AS cash_ccid
     , cgac.cash_clearing_ccid
     , cgac.bank_charges_ccid
     , cgac.gain_code_combination_id                     AS gain_ccid
     , cgac.loss_code_combination_id                     AS loss_ccid
FROM   ce_bank_accounts          cba
     , ce_bank_acct_uses_all     cbaua
     , fun_all_business_units_v  fabuv
     , ce_gl_accounts_ccid       cgac
     , gl_code_combinations      gcc
WHERE  cba.bank_account_id            = cbaua.bank_account_id
AND    cbaua.org_id                   = fabuv.bu_id
AND    cbaua.bank_acct_use_id         = cgac.bank_acct_use_id (+)
AND    cgac.asset_code_combination_id = gcc.code_combination_id (+)
AND    cba.bank_account_num           = :p_bank_account_num
ORDER BY fabuv.bu_name
