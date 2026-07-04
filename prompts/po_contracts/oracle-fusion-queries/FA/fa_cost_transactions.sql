/*
===============================================================================
FA Cost Transactions by Period
Author: Daniel Damasceno
Purpose:
    List asset cost-affecting transactions (additions, adjustments,
    transfers, retirements) entered in a given period for a depreciation
    book, with category, cost account, current cost and location.
    Useful for FA-to-GL reconciliation of cost movements.
Tables Used:
    - FA_TRANSACTION_HEADERS  (Asset transactions)
    - FA_ADDITIONS_B          (Asset master)
    - FA_BOOKS                (Financial info per asset per book)
    - FA_CATEGORY_BOOKS       (Category accounting per book)
    - FA_DISTRIBUTION_HISTORY (Asset assignments)
    - FA_LOCATIONS            (Locations)
    - FA_DEPRN_PERIODS        (Depreciation calendar periods)
Report Output:
    - Book, transaction period, transaction type
    - Asset number, category, asset cost account
    - Current cost, location segment
Parameters:
    - :p_book_type_code  Depreciation book (FA_BOOKS.BOOK_TYPE_CODE)
    - :p_period_name     Period entered (FA_DEPRN_PERIODS.PERIOD_NAME)
Notes:
    - Replaces the EBS view FA_FINANCIAL_INQUIRY_COST_V (not available in
      Fusion Cloud) with FA_TRANSACTION_HEADERS joins.
    - Active assignment rows only (DATE_INEFFECTIVE IS NULL).
    - Zero-cost rows excluded.
Module:
    Oracle Fusion Financials - Assets
===============================================================================
*/
SELECT fb.book_type_code                                AS book
     , fdp.period_name                                  AS transaction_period
     , fth.transaction_type_code                        AS transaction_type
     , fab.asset_number
     , fab.attribute_category_code                      AS category
     , fcbs.asset_cost_account_ccid                     AS asset_cost_account
     , NVL(fb.cost,0)                                   AS current_cost
     , fl.segment1                                      AS location_segment1
FROM   fa_transaction_headers  fth
     , fa_additions_b          fab
     , fa_books                fb
     , fa_category_books       fcbs
     , fa_distribution_history fdh
     , fa_locations            fl
     , fa_deprn_periods        fdp
WHERE  fth.asset_id          = fab.asset_id
AND    fth.book_type_code    = fb.book_type_code
AND    fth.asset_id          = fb.asset_id
AND    fb.date_ineffective   IS NULL                -- current book row
AND    fab.asset_category_id = fcbs.category_id
AND    fth.book_type_code    = fcbs.book_type_code
AND    fth.asset_id          = fdh.asset_id
AND    fth.book_type_code    = fdh.book_type_code
AND    fdh.date_ineffective  IS NULL                -- active assignment
AND    fdh.location_id       = fl.location_id
AND    fdp.book_type_code    = fth.book_type_code
AND    fth.date_effective    BETWEEN fdp.period_open_date
                             AND     NVL(fdp.period_close_date, SYSDATE)
AND    fth.book_type_code    = :p_book_type_code
AND    fdp.period_name       = :p_period_name     -- 'MMM-YY' e.g. 'Jan-26' (per FA calendar)
AND    NVL(fb.cost,0)       <> 0
ORDER BY fth.transaction_type_code, fab.asset_number
