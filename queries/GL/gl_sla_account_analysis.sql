/*
===============================================================================
GL / SLA Account Analysis (Subledger + GL Journals)
Author: Daniel Damasceno
Purpose:
    Account analysis combining subledger accounting entries (XLA) from any
    module (AP, AR, FA, Cost...) with manual/imported GL journal lines,
    for a given ledger, period and account. Shows entered and accounted
    amounts per accounting line with full CoA segment breakdown.
Tables Used:
    - XLA_AE_HEADERS         (Subledger journal entry headers)
    - XLA_AE_LINES           (Subledger journal entry lines)
    - GL_CODE_COMBINATIONS   (Chart of Accounts combinations)
    - GL_JE_BATCHES          (GL journal batches)
    - GL_JE_HEADERS          (GL journal headers)
    - GL_JE_LINES            (GL journal lines)
    - GL_JE_SOURCES_TL       (Journal source names)
Report Output:
    - Source module, event type, batch/journal identification
    - Accounting date, period, line number, accounting class, currency
    - CoA segments (SEGMENT1..SEGMENT7 — extend to your structure)
    - Entered DR/CR, Net Entered, Accounted DR/CR, Net Accounted
    - Line description
Parameters:
    - :p_ledger_name    Ledger name (GL_LEDGERS.NAME)
    - :p_period_name    GL period (e.g. 'Jan-26')
    - :p_legal_entity   CoA segment holding the company/LE
    - :p_account        Natural account segment
Notes:
    - Application id mapping: 200 = Payables, 222 = Receivables,
      140 = Assets, 707 = Cost Management. Full list: XLA_SUBLEDGERS.
    - GL_TRANSFER_STATUS_CODE = 'Y' restricts to entries transferred to GL.
    - Simplification vs. EBS original: module-specific enrichment columns
      (receipt number, bank name, asset number parsed from descriptions)
      were removed for portability. Join AR_CASH_RECEIPTS_ALL,
      IBY_PAYMENTS_ALL or FA_ADDITIONS_B via source tables if needed.
Module:
    Oracle Fusion Financials - General Ledger / Subledger Accounting
===============================================================================
*/
-- ====================== SUBLEDGER ENTRIES (XLA) ======================
SELECT DECODE(xah.application_id, 200,'PAYABLES'
                                , 222,'RECEIVABLES'
                                , 140,'FIXED ASSETS'
                                , 707,'COST MANAGEMENT'
                                , TO_CHAR(xah.application_id)) AS source_module
     , xah.event_type_code                                     AS event_type
     , NULL                                                    AS batch_name
     , NULL                                                    AS journal_name
     , xah.je_category_name                                    AS category
     , xah.accounting_date
     , xah.period_name
     , xal.ae_line_num                                         AS line_num
     , xal.accounting_class_code                               AS accounting_class
     , xal.currency_code
     , gcc.segment1                                            AS segment1_le
     , gcc.segment2                                            AS segment2
     , gcc.segment3                                            AS segment3
     , gcc.segment4                                            AS segment4
     , gcc.segment5                                            AS segment5
     , gcc.segment6                                            AS segment6
     , gcc.segment7                                            AS segment7
     , NVL(xal.entered_dr,0)                                   AS entered_dr
     , NVL(xal.entered_cr,0)                                   AS entered_cr
     , NVL(xal.entered_dr,0)   - NVL(xal.entered_cr,0)         AS net_entered
     , NVL(xal.accounted_dr,0)                                 AS accounted_dr
     , NVL(xal.accounted_cr,0)                                 AS accounted_cr
     , NVL(xal.accounted_dr,0) - NVL(xal.accounted_cr,0)       AS net_accounted
     , NVL(xah.description, xal.description)                   AS description
FROM   xla_ae_headers       xah
     , xla_ae_lines         xal
     , gl_code_combinations gcc
     , gl_ledgers           gl
WHERE  xah.ae_header_id            = xal.ae_header_id
AND    xah.application_id          = xal.application_id
AND    xal.code_combination_id     = gcc.code_combination_id
AND    xah.ledger_id               = gl.ledger_id
AND    gl.name                     = :p_ledger_name
AND    xah.period_name             = :p_period_name   -- 'MMM-YY' e.g. 'Jan-26' (case-sensitive, per accounting calendar)
AND    xah.gl_transfer_status_code = 'Y'          -- transferred to GL
AND    gcc.segment1                = :p_legal_entity
AND    gcc.segment2                = NVL(:p_account, gcc.segment2)
--
UNION ALL
--
-- ========================= GL JOURNAL LINES ==========================
SELECT 'GENERAL LEDGER'                                        AS source_module
     , DECODE(gjh.status,'P','Posted','Unposted')              AS event_type
     , gjb.name                                                AS batch_name
     , gjh.name                                                AS journal_name
     , gjst.user_je_source_name                                AS category
     , gjl.effective_date                                      AS accounting_date
     , gjl.period_name
     , gjl.je_line_num                                         AS line_num
     , NULL                                                    AS accounting_class
     , gjh.currency_code
     , gcc.segment1                                            AS segment1_le
     , gcc.segment2                                            AS segment2
     , gcc.segment3                                            AS segment3
     , gcc.segment4                                            AS segment4
     , gcc.segment5                                            AS segment5
     , gcc.segment6                                            AS segment6
     , gcc.segment7                                            AS segment7
     , NVL(gjl.entered_dr,0)                                   AS entered_dr
     , NVL(gjl.entered_cr,0)                                   AS entered_cr
     , NVL(gjl.entered_dr,0)   - NVL(gjl.entered_cr,0)         AS net_entered
     , NVL(gjl.accounted_dr,0)                                 AS accounted_dr
     , NVL(gjl.accounted_cr,0)                                 AS accounted_cr
     , NVL(gjl.accounted_dr,0) - NVL(gjl.accounted_cr,0)       AS net_accounted
     , gjl.description
FROM   gl_je_batches        gjb
     , gl_je_headers        gjh
     , gl_je_lines          gjl
     , gl_code_combinations gcc
     , gl_je_sources_tl     gjst
     , gl_ledgers           gl
WHERE  gjb.je_batch_id         = gjh.je_batch_id
AND    gjh.je_header_id        = gjl.je_header_id
AND    gjl.code_combination_id = gcc.code_combination_id
AND    gjst.je_source_name     = gjh.je_source
AND    gjst.language           = USERENV('LANG')
AND    gjh.currency_code      <> 'STAT'           -- exclude statistical
AND    gjh.status              = 'P'              -- posted only
AND    gjl.ledger_id           = gl.ledger_id
AND    gl.name                 = :p_ledger_name
AND    gjl.period_name         = :p_period_name       -- 'MMM-YY' e.g. 'Jan-26' (case-sensitive, per accounting calendar)
AND    gcc.segment1            = :p_legal_entity
AND    gcc.segment2            = NVL(:p_account, gcc.segment2)
ORDER BY 1, 6, 8
