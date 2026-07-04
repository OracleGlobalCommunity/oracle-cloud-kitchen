# FA — Assets Queries

Oracle Fusion Cloud ERP 26B. All parameters use `:p_*` bind variables — see [CONVENTIONS.md](../CONVENTIONS.md).

## fa_asset_deprn_multibook.sql

Cost and depreciation (period, YTD, accumulated reserve) for one asset across all its depreciation books — one row per book/period; pivot to compare books side by side.

**Parameters:** `:p_asset_number`, `:p_period_name` (optional)
**Example:** compare corporate vs tax vs IFRS depreciation of an asset during UAT.

## fa_cost_transactions.sql

Cost-affecting transactions (additions, adjustments, transfers, retirements) entered in a period for a book, with category, cost account and location.

**Parameters:** `:p_book_type_code`, `:p_period_name`
**Example:** reconcile the month's FA cost movement against the GL asset cost account.

## fa_categories_by_book.sql

Reference list of asset categories per depreciation book with concatenated segments.

**Parameters:** `:p_book_type_code` (optional)
**Example:** build the category mapping sheet during a data migration.
