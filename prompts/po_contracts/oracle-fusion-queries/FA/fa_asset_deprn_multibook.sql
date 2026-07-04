/*
===============================================================================
FA Asset Depreciation — Multi-Book Comparison
Author: Daniel Damasceno
Purpose:
    Show cost and depreciation figures (period depreciation, YTD and
    accumulated reserve) for one asset across its depreciation books
    (e.g. corporate, tax, IFRS), one row per book/period.
    Useful to compare depreciation between books in UAT or audits.
Tables Used:
    - FA_ADDITIONS_B     (Asset master)
    - FA_ADDITIONS_TL    (Asset descriptions, translated)
    - FA_BOOKS           (Financial info per asset per book)
    - FA_METHODS         (Depreciation method + life in months)
    - FA_DEPRN_SUMMARY   (Depreciation per asset per period)
    - FA_DEPRN_PERIODS   (Depreciation calendar periods)
Report Output:
    - Asset number, tag number, description, category
    - Book, period, depreciation start date, date placed in service
    - Method, life in months, cost
    - Period depreciation, YTD depreciation, accumulated reserve
Parameters:
    - :p_asset_number  Asset number (FA_ADDITIONS_B.ASSET_NUMBER)
    - :p_period_name   Depreciation period (optional; NULL = all periods)
Notes:
    - Fusion difference (MOS Doc 2259590.1): DEPRN_METHOD_CODE and
      LIFE_IN_MONTHS do NOT exist in FA_BOOKS in Fusion Cloud — they moved
      to FA_METHODS, joined via FA_BOOKS.METHOD_ID.
    - FA_BOOKS is restricted to the ACTIVE row (DATE_INEFFECTIVE IS NULL);
      without this filter every historical adjustment duplicates the output.
    - Books with no depreciation run for the selected period do not appear
      (inner join to FA_DEPRN_SUMMARY — intentional and predictable).
    - Returns one row per book: pivot in BIP/Excel to compare books
      side by side (the EBS original hardcoded 3 books as 3 subqueries).
    - Description uses USERENV('LANG') instead of a hardcoded language.
    - DFF attribute columns from the original (invoice, supplier, project)
      were client-specific and removed; map your own ATTRIBUTEn if needed.
Module:
    Oracle Fusion Financials - Assets
===============================================================================
*/
SELECT fab.asset_number
     , fab.tag_number
     , fat.description
     , fab.attribute_category_code                      AS category
     , fb.book_type_code                                AS book
     , fdp.period_name                                  AS deprn_period
     , fb.deprn_start_date
     , fb.date_placed_in_service
     , fm.method_code                                   AS method
     , fm.life_in_months
     , NVL(fb.cost,0)                                   AS cost
     , NVL(fds.deprn_amount,0)                          AS period_depreciation
     , NVL(fds.ytd_deprn,0)                             AS ytd_depreciation
     , NVL(fds.deprn_reserve,0)                         AS accumulated_reserve
FROM   fa_additions_b    fab
     , fa_additions_tl   fat
     , fa_books          fb
     , fa_methods        fm
     , fa_deprn_summary  fds
     , fa_deprn_periods  fdp
WHERE  fab.asset_id        = fb.asset_id
AND    fab.asset_id        = fat.asset_id
AND    fat.language        = USERENV('LANG')
AND    fb.method_id        = fm.method_id           -- method + life (Fusion)
AND    fb.date_ineffective IS NULL                  -- active book row only
AND    fb.asset_id         = fds.asset_id
AND    fb.book_type_code   = fds.book_type_code
AND    fds.period_counter  = fdp.period_counter
AND    fds.book_type_code  = fdp.book_type_code
AND    fab.asset_number    = :p_asset_number
AND    fdp.period_name     = NVL(:p_period_name, fdp.period_name)  -- 'MMM-YY' e.g. 'Jan-26' (per FA calendar)
ORDER BY fb.book_type_code, fdp.period_name
