-- Extracted from Lab5_SDAG_Team3 (3).pdf, PDF pages 30-32.
-- PDF line wrapping removed only where verified against the original SQL files.
-- Query logic and source naming are preserved. Select your SQL Server database first.

BEGIN TRANSACTION;

-- 1. Decision
SELECT t.ticket_id, c.customer_type, i.part_code,
       i.quantity AS available_stock, i.minimum_reorder_threshold,
       CASE WHEN EXISTS (
                SELECT 1
                FROM GADGET_TICKET AS prev
                JOIN WARRANTY_CLAIM AS wc ON wc.ticket_id = prev.ticket_id
                JOIN BILLING_STATEMENT AS bs ON bs.ticket_id = wc.ticket_id
                                            AND bs.billing_id = wc.billing_id
                WHERE prev.serial_no_IMEI = g.serial_no_IMEI
                  AND prev.ticket_id <> t.ticket_id
                  AND wc.review_status = N'Approved'
                  AND wc.submission_date <= CAST(t.received_dateTime AS DATE)
                  AND CAST(t.received_dateTime AS DATE) <= DATEADD(DAY, 90,
bs.billing_date))
            THEN N'Yes' ELSE N'No' END AS warranty_job,
       CASE WHEN i.quantity < 1 THEN N'BLOCKED: insufficient stock'
            WHEN i.quantity >= 0.20 * i.minimum_reorder_threshold THEN N'ALLOWED: normal stock'
            WHEN c.customer_type = N'Corporate' THEN N'ALLOWED: Corporate exception'
            WHEN EXISTS (
                SELECT 1
                FROM GADGET_TICKET AS prev
                JOIN WARRANTY_CLAIM AS wc ON wc.ticket_id = prev.ticket_id
                JOIN BILLING_STATEMENT AS bs ON bs.ticket_id = wc.ticket_id
                                            AND bs.billing_id = wc.billing_id
                WHERE prev.serial_no_IMEI = g.serial_no_IMEI
                  AND prev.ticket_id <> t.ticket_id
                  AND wc.review_status = N'Approved'
                  AND wc.submission_date <= CAST(t.received_dateTime AS DATE)
                  AND CAST(t.received_dateTime AS DATE) <= DATEADD(DAY, 90,
bs.billing_date))
            THEN N'ALLOWED: Warranty exception'
            ELSE N'BLOCKED: Retail threshold' END AS allocation_result
FROM TICKET AS t
JOIN GADGET_TICKET AS gt ON gt.ticket_id = t.ticket_id
JOIN GADGET AS g ON g.serial_no_IMEI = gt.serial_no_IMEI
JOIN CLIENT AS c ON c.client_id = g.client_id
CROSS JOIN ITEMS AS i
WHERE t.ticket_id = 107 AND i.part_code = N'CLEAN';





-- 2. Attempt the allocation
INSERT INTO PART_ALLOCATION (ticket_id, procedure_no, part_code, allocation_id,
                             quantity_used, locked_price, allocation_datetime)
SELECT t.ticket_id, 2, i.part_code, 1, 1, i.price, GETDATE()
FROM TICKET AS t
JOIN GADGET_TICKET AS gt ON gt.ticket_id = t.ticket_id
JOIN GADGET AS g ON g.serial_no_IMEI = gt.serial_no_IMEI
JOIN CLIENT AS c ON c.client_id = g.client_id
CROSS JOIN ITEMS AS i
WHERE t.ticket_id = 107 AND i.part_code = N'CLEAN'
  AND i.quantity >= 1
  AND (   i.quantity >= 0.20 * i.minimum_reorder_threshold
       OR c.customer_type = N'Corporate'
       OR EXISTS (
            SELECT 1
            FROM GADGET_TICKET AS prev
            JOIN WARRANTY_CLAIM AS wc ON wc.ticket_id = prev.ticket_id
            JOIN BILLING_STATEMENT AS bs ON bs.ticket_id = wc.ticket_id
                                        AND bs.billing_id = wc.billing_id
            WHERE prev.serial_no_IMEI = g.serial_no_IMEI
              AND prev.ticket_id <> t.ticket_id
              AND wc.review_status = N'Approved'
              AND wc.submission_date <= CAST(t.received_dateTime AS DATE)
              AND CAST(t.received_dateTime AS DATE) <= DATEADD(DAY, 90,
bs.billing_date)));

-- 3. Deduct stock only if the allocation was created
UPDATE ITEMS SET quantity = quantity - 1
WHERE part_code = N'CLEAN'
  AND EXISTS (SELECT 1 FROM PART_ALLOCATION
              WHERE ticket_id = 107 AND procedure_no = 2 AND part_code = N'CLEAN');

-- 4. Show the outcome
SELECT part_code, quantity AS stock_after FROM ITEMS WHERE part_code = N'CLEAN';
SELECT * FROM PART_ALLOCATION WHERE ticket_id = 107 AND procedure_no = 2;

ROLLBACK;
