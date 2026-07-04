/*
===============================================================================
GL Journal Lines Report (Razao / GL Ledger Detail)
Author: Daniel Damasceno
Purpose:
    List posted journal batches, headers and lines for a given ledger,
    period and account combination. Base query for a GL "razao"
    (ledger detail) style report.
Tables Used:
    - GL_JE_BATCHES          (Journal batches)
    - GL_JE_HEADERS          (Journal headers)
    - GL_JE_LINES            (Journal lines)
    - GL_CODE_COMBINATIONS   (Chart of Accounts combinations)
    - GL_LEDGERS             (Ledger definitions)
Report Output:
    - Ledger, Batch Name, Journal Name
    - Accounting Date (GL date)
    - Concatenated account combination
    - Entered Debit / Credit amounts
    - Line description, header id, line number, period
Parameters:
    - :p_ledger_name    Ledger name (GL_LEDGERS.NAME)
    - :p_period_name    GL period (e.g. 'Jan-26')
    - :p_legal_entity   CoA segment holding the company/LE (optional filter)
    - :p_account        Natural account segment (optional filter)
Notes:
    - STATUS = 'P' restricts to posted journals only.
    - Concatenation assumes a 7-segment CoA; adjust to your structure.
    - Converted from an EBS R12 original to Fusion 26B (GL_LEDGERS join
      replaces hardcoded LEDGER_ID).
Module:
    Oracle Fusion Financials - General Ledger
===============================================================================
*/
SELECT gl.name                                  AS ledger_name
     , gjb.name                                 AS batch_name
     , gjh.name                                 AS journal_name
     , gjl.effective_date                       AS accounting_date
     , gcc.segment1 || '.' || gcc.segment2 || '.' || gcc.segment3 || '.' ||
       gcc.segment4 || '.' || gcc.segment5 || '.' || gcc.segment6 || '.' ||
       gcc.segment7                             AS account_combination
     , gjl.entered_dr                           AS entered_debit
     , gjl.entered_cr                           AS entered_credit
     , gjl.description                          AS line_description
     , gjl.je_header_id
     , gjl.je_line_num
     , gjl.period_name
FROM   gl_je_batches        gjb
     , gl_je_headers        gjh
     , gl_je_lines          gjl
     , gl_code_combinations gcc
     , gl_ledgers           gl
WHERE  gjb.je_batch_id         = gjh.je_batch_id
AND    gjh.je_header_id        = gjl.je_header_id
AND    gjl.code_combination_id = gcc.code_combination_id
AND    gjl.ledger_id           = gl.ledger_id
AND    gl.name                 = :p_ledger_name
AND    gjl.period_name         = :p_period_name       -- 'MMM-YY' e.g. 'Jan-26' (case-sensitive, per accounting calendar)
AND    gjh.status              = 'P'                 -- posted journals only
AND    gcc.segment1            = NVL(:p_legal_entity, gcc.segment1)
AND    gcc.segment2            = NVL(:p_account, gcc.segment2)
ORDER BY gjl.je_header_id, gjl.je_line_num
