/* =====================================================================
   TechPulse - Lab 5 queries (SQL Server)
   Run techpulse_setup.sql first.
   To run ONE query: highlight its block and press Alt+X.
   SSMS runs only the highlighted text. For Query 5a/5b/5c, highlight
   from BEGIN TRANSACTION down to ROLLBACK.
   ===================================================================== */
USE TechPulse;
GO

/* =====================================================================
   Query 1  Procedures under 180 minutes, by station and device category
   Expected: (1, Headphones, 0) (1, Smartphone, 7) (2, Headphones, 3) (2, Smartphone, 0)
   ===================================================================== */
SELECT s.station_id, cat.device_category,
       COUNT(d.ticket_id) AS procedures_under_180_minutes
FROM STATION AS s
CROSS JOIN (SELECT DISTINCT device_category FROM CATALOG) AS cat
LEFT JOIN (
    SELECT p.ticket_id, p.procedure_no, p.station_id, c.device_category
    FROM [PROCEDURE] AS p
    JOIN WORK_SESSION AS ws ON ws.ticket_id = p.ticket_id AND ws.procedure_no = p.procedure_no
    JOIN GADGET_TICKET AS gt ON gt.ticket_id = p.ticket_id
    JOIN GADGET AS g ON g.serial_no_IMEI = gt.serial_no_IMEI
    JOIN CATALOG AS c ON c.catalog_id = g.catalog_id
    WHERE p.status = N'Completed'
    GROUP BY p.ticket_id, p.procedure_no, p.station_id, c.device_category
    HAVING DATEDIFF(MINUTE, MIN(ws.start_time), MAX(ws.end_time)) < 180
) AS d ON d.station_id = s.station_id AND d.device_category = cat.device_category
GROUP BY s.station_id, cat.device_category
ORDER BY s.station_id, cat.device_category;
GO

/* =====================================================================
   Query 2  Revenue from completed work orders, labor vs parts
   Expected: Headphones 75.00 / 10.00 / 85.00; Smartphone 1080.00 / 80.00 / 1160.00
   ===================================================================== */
SELECT c.device_category,
       CAST(SUM(ISNULL(l.labor_revenue, 0)) AS DECIMAL(12,2)) AS labor_revenue,
       CAST(SUM(ISNULL(pr.parts_revenue, 0)) AS DECIMAL(12,2)) AS parts_revenue,
       CAST(SUM(ISNULL(l.labor_revenue, 0) + ISNULL(pr.parts_revenue, 0)) AS DECIMAL(12,2))
           AS gross_revenue_before_tax_and_discount
FROM TICKET AS t
JOIN GADGET_TICKET AS gt ON gt.ticket_id = t.ticket_id
JOIN GADGET AS g ON g.serial_no_IMEI = gt.serial_no_IMEI
JOIN CATALOG AS c ON c.catalog_id = g.catalog_id
LEFT JOIN (SELECT ws.ticket_id, SUM(ws.billable_time * tech.hourly_rate) AS labor_revenue
           FROM WORK_SESSION AS ws
           JOIN TECHNICIAN AS tech ON tech.employee_id = ws.technician_id
           GROUP BY ws.ticket_id) AS l ON l.ticket_id = t.ticket_id
LEFT JOIN (SELECT pa.ticket_id, SUM(pa.quantity_used * pa.locked_price) AS parts_revenue
           FROM PART_ALLOCATION AS pa
           GROUP BY pa.ticket_id) AS pr ON pr.ticket_id = t.ticket_id
WHERE t.status = N'Completed'
GROUP BY c.device_category
ORDER BY c.device_category;
GO

/* =====================================================================
   Query 3  Customers with claims on repairs done by a mismatched technician;
            total claims per manufacturer
   Expected: 1 | BrightTech Pte Ltd | ops@brighttech.example | Apple | 2
   ===================================================================== */
SELECT cl.client_id, cl.name AS customer_name, cl.email, c.manufacturer_name,
       COUNT(*) AS total_claims_for_qualified_customer
FROM WARRANTY_CLAIM AS wc
JOIN GADGET_TICKET AS gt ON gt.ticket_id = wc.ticket_id
JOIN GADGET AS g ON g.serial_no_IMEI = gt.serial_no_IMEI
JOIN CATALOG AS c ON c.catalog_id = g.catalog_id
JOIN CLIENT AS cl ON cl.client_id = g.client_id
WHERE g.client_id IN (
    SELECT g2.client_id
    FROM WARRANTY_CLAIM AS wc2
    JOIN GADGET_TICKET AS gt2 ON gt2.ticket_id = wc2.ticket_id
    JOIN GADGET AS g2 ON g2.serial_no_IMEI = gt2.serial_no_IMEI
    JOIN CATALOG AS c2 ON c2.catalog_id = g2.catalog_id
    JOIN [PROCEDURE] AS p ON p.ticket_id = wc2.ticket_id
    JOIN WORK_SESSION AS ws ON ws.ticket_id = p.ticket_id AND ws.procedure_no = p.procedure_no
    JOIN TECHNICIAN AS tech ON tech.employee_id = ws.technician_id
    WHERE p.procedure_type = N'Repair'
      AND NOT (   (tech.specialization = N'Display' AND c2.device_category = N'Smartphone')
               OR (tech.specialization = N'Audio'   AND c2.device_category = N'Headphones')))
GROUP BY cl.client_id, cl.name, cl.email, c.manufacturer_name
ORDER BY cl.name, c.manufacturer_name;
GO

/* =====================================================================
   Query 4  Claims on devices whose initial diagnostic was Liquid Damage or Tripped
   Expected: 1 | BrightTech Pte Ltd | ops@brighttech.example | 2 | 50.00
   ===================================================================== */
SELECT cl.client_id, cl.name AS customer_name, cl.email,
       COUNT(*) AS approved_claims_with_qualifying_inspection,
       SUM(ISNULL(wc.refund_value, 0)) AS assumed_requested_payout_under_full_approval
FROM WARRANTY_CLAIM AS wc
JOIN GADGET_TICKET AS gt ON gt.ticket_id = wc.ticket_id
JOIN GADGET AS g ON g.serial_no_IMEI = gt.serial_no_IMEI
JOIN CLIENT AS cl ON cl.client_id = g.client_id
JOIN DIAGNOSTIC_ASSESSMENT AS da ON da.ticket_id = wc.ticket_id
JOIN [PROCEDURE] AS p ON p.ticket_id = da.ticket_id AND p.procedure_no = da.procedure_no
WHERE p.procedure_type = N'Inspection'
  AND da.liquid_damage IN (N'Liquid Damage', N'Tripped')
GROUP BY cl.client_id, cl.name, cl.email
ORDER BY cl.name;
GO

/* =====================================================================
   Query 5a  Corporate allowed  (ticket 106)
   Expected: ALLOWED | stock_after 2 | one new CLEAN row at 12.00
   ===================================================================== */
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
                  AND CAST(t.received_dateTime AS DATE) <= DATEADD(DAY, 90, bs.billing_date))
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
                  AND CAST(t.received_dateTime AS DATE) <= DATEADD(DAY, 90, bs.billing_date))
            THEN N'ALLOWED: Warranty exception'
            ELSE N'BLOCKED: Retail threshold' END AS allocation_result
FROM TICKET AS t
JOIN GADGET_TICKET AS gt ON gt.ticket_id = t.ticket_id
JOIN GADGET AS g ON g.serial_no_IMEI = gt.serial_no_IMEI
JOIN CLIENT AS c ON c.client_id = g.client_id
CROSS JOIN ITEMS AS i
WHERE t.ticket_id = 106 AND i.part_code = N'CLEAN';

-- 2. Attempt the allocation (a row is inserted only if the rule allows it)
INSERT INTO PART_ALLOCATION (ticket_id, procedure_no, part_code, allocation_id,
                             quantity_used, locked_price, allocation_datetime)
SELECT t.ticket_id, 2, i.part_code, 1, 1, i.price, GETDATE()
FROM TICKET AS t
JOIN GADGET_TICKET AS gt ON gt.ticket_id = t.ticket_id
JOIN GADGET AS g ON g.serial_no_IMEI = gt.serial_no_IMEI
JOIN CLIENT AS c ON c.client_id = g.client_id
CROSS JOIN ITEMS AS i
WHERE t.ticket_id = 106 AND i.part_code = N'CLEAN'
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
              AND CAST(t.received_dateTime AS DATE) <= DATEADD(DAY, 90, bs.billing_date)));

-- 3. Deduct stock only if the allocation was created
UPDATE ITEMS SET quantity = quantity - 1
WHERE part_code = N'CLEAN'
  AND EXISTS (SELECT 1 FROM PART_ALLOCATION
              WHERE ticket_id = 106 AND procedure_no = 2 AND part_code = N'CLEAN');

-- 4. Show the outcome
SELECT part_code, quantity AS stock_after FROM ITEMS WHERE part_code = N'CLEAN';
SELECT * FROM PART_ALLOCATION WHERE ticket_id = 106 AND procedure_no = 2;

ROLLBACK;  -- undo the test so the sample data stays unchanged
GO

/* =====================================================================
   Query 5b  Retail blocked  (ticket 107)
   Expected: BLOCKED: Retail threshold | stock_after 3 | empty allocation grid
   ===================================================================== */
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
                  AND CAST(t.received_dateTime AS DATE) <= DATEADD(DAY, 90, bs.billing_date))
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
                  AND CAST(t.received_dateTime AS DATE) <= DATEADD(DAY, 90, bs.billing_date))
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
              AND CAST(t.received_dateTime AS DATE) <= DATEADD(DAY, 90, bs.billing_date)));

-- 3. Deduct stock only if the allocation was created
UPDATE ITEMS SET quantity = quantity - 1
WHERE part_code = N'CLEAN'
  AND EXISTS (SELECT 1 FROM PART_ALLOCATION
              WHERE ticket_id = 107 AND procedure_no = 2 AND part_code = N'CLEAN');

-- 4. Show the outcome
SELECT part_code, quantity AS stock_after FROM ITEMS WHERE part_code = N'CLEAN';
SELECT * FROM PART_ALLOCATION WHERE ticket_id = 107 AND procedure_no = 2;

ROLLBACK;
GO

/* =====================================================================
   Query 5c  Warranty allowed  (ticket 107 + temporary approved claim)
   Expected: warranty_job Yes | ALLOWED: Warranty exception | stock_after 2
   ===================================================================== */
BEGIN TRANSACTION;

-- 0. Temporary approved claim on H105's earlier ticket 105 (billed 2026-09-09)
INSERT INTO WARRANTY_CLAIM (ticket_id, billing_id, claim_number, review_status,
                            submission_date, description, approved_remedy, refund_value)
VALUES (105, 1, 1, N'Approved', '2026-10-10',
        N'Headphone audio fault recurred', N'Repair under warranty', NULL);

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
                  AND CAST(t.received_dateTime AS DATE) <= DATEADD(DAY, 90, bs.billing_date))
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
                  AND CAST(t.received_dateTime AS DATE) <= DATEADD(DAY, 90, bs.billing_date))
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
              AND CAST(t.received_dateTime AS DATE) <= DATEADD(DAY, 90, bs.billing_date)));

-- 3. Deduct stock only if the allocation was created
UPDATE ITEMS SET quantity = quantity - 1
WHERE part_code = N'CLEAN'
  AND EXISTS (SELECT 1 FROM PART_ALLOCATION
              WHERE ticket_id = 107 AND procedure_no = 2 AND part_code = N'CLEAN');

-- 4. Show the outcome
SELECT part_code, quantity AS stock_after FROM ITEMS WHERE part_code = N'CLEAN';
SELECT * FROM PART_ALLOCATION WHERE ticket_id = 107 AND procedure_no = 2;

ROLLBACK;  -- removes the temporary claim and the allocation
GO

/* =====================================================================
   Query 6  Customers with more than 3 work orders in one month
            for the same device category
   Expected: 4 rows, BrightTech, Smartphone, 2026-09, tickets 101-104 (S101-S104)
   ===================================================================== */
SELECT cl.client_id, cl.name AS customer_name, cl.email, c.device_category,
       q.visit_year, q.visit_month, q.work_orders, t.ticket_id, g.serial_no_IMEI
FROM (SELECT g.client_id, c.device_category,
             YEAR(t.received_dateTime) AS visit_year,
             MONTH(t.received_dateTime) AS visit_month,
             COUNT(DISTINCT t.ticket_id) AS work_orders
      FROM TICKET AS t
      JOIN GADGET_TICKET AS gt ON gt.ticket_id = t.ticket_id
      JOIN GADGET AS g ON g.serial_no_IMEI = gt.serial_no_IMEI
      JOIN CATALOG AS c ON c.catalog_id = g.catalog_id
      GROUP BY g.client_id, c.device_category, YEAR(t.received_dateTime), MONTH(t.received_dateTime)
      HAVING COUNT(DISTINCT t.ticket_id) > 3) AS q
JOIN CLIENT AS cl ON cl.client_id = q.client_id
JOIN GADGET AS g ON g.client_id = q.client_id
JOIN CATALOG AS c ON c.catalog_id = g.catalog_id AND c.device_category = q.device_category
JOIN GADGET_TICKET AS gt ON gt.serial_no_IMEI = g.serial_no_IMEI
JOIN TICKET AS t ON t.ticket_id = gt.ticket_id
                AND YEAR(t.received_dateTime) = q.visit_year
                AND MONTH(t.received_dateTime) = q.visit_month
ORDER BY cl.name, q.visit_year, q.visit_month, t.ticket_id;
GO

/* =====================================================================
   Query 7  (Additional) Items at or below their reorder threshold
   Expected: CLEAN 3 / 20 / 17;  SEAL 8 / 10 / 2
   ===================================================================== */
SELECT part_code, description,
       quantity AS available_stock,
       minimum_reorder_threshold,
       minimum_reorder_threshold - quantity AS units_below_threshold
FROM ITEMS
WHERE quantity <= minimum_reorder_threshold
ORDER BY part_code;
GO

/* ---------- After-run check (not for the report) ----------
   Confirms the Query 5 tests were rolled back.
   Expected: CLEAN stock 3, 6 allocations, 2 warranty claims. */
SELECT quantity AS clean_stock FROM ITEMS WHERE part_code = N'CLEAN';
SELECT COUNT(*) AS allocations FROM PART_ALLOCATION;
SELECT COUNT(*) AS claims FROM WARRANTY_CLAIM;
GO
