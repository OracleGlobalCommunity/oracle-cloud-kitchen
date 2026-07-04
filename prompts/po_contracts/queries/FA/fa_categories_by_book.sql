/*
===============================================================================
FA Categories by Depreciation Book
Author: Daniel Damasceno
Purpose:
    List asset categories associated with each depreciation book,
    with the concatenated category segments. Setup/reference query,
    handy during discovery and data migration mapping.
Tables Used:
    - FA_CATEGORIES_B    (Asset categories)
    - FA_CATEGORY_BOOKS  (Category-to-book accounting setup)
Report Output:
    - Book type code
    - Category id
    - Category (SEGMENT1-SEGMENT2 concatenated)
Parameters:
    - :p_book_type_code  Depreciation book (optional; NULL = all books)
Notes:
    - Extend the concatenation if your category flexfield has more
      than two segments.
Module:
    Oracle Fusion Financials - Assets
===============================================================================
*/
SELECT fcbs.book_type_code
     , fcb.category_id
     , fcb.segment1 || '-' || fcb.segment2               AS category
FROM   fa_categories_b    fcb
     , fa_category_books  fcbs
WHERE  fcb.category_id    = fcbs.category_id
AND    fcbs.book_type_code = NVL(:p_book_type_code, fcbs.book_type_code)
ORDER BY fcbs.book_type_code, fcb.segment1, fcb.segment2
