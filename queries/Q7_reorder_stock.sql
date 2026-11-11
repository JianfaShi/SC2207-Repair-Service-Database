-- Extracted from Lab5_SDAG_Team3 (3).pdf, PDF pages 37.
-- PDF line wrapping removed only where verified against the original SQL files.
-- Query logic and source naming are preserved. Select your SQL Server database first.

SELECT
    part_code,
    description,
    quantity AS available_stock,
    minimum_reorder_threshold,
    minimum_reorder_threshold - quantity AS units_below_threshold
FROM ITEMS
WHERE quantity <= minimum_reorder_threshold
ORDER BY part_code;
