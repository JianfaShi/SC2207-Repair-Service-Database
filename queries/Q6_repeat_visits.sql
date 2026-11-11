-- Extracted from Lab5_SDAG_Team3 (3).pdf, PDF pages 36-37.
-- PDF line wrapping removed only where verified against the original SQL files.
-- Query logic and source naming are preserved. Select your SQL Server database first.

WITH QualifyingGroups AS (
    SELECT
        g.client_id,
        c.device_category,
        YEAR(t.received_dateTime) AS visit_year,
        MONTH(t.received_dateTime) AS visit_month,
        COUNT(DISTINCT t.ticket_id) AS work_orders
    FROM TICKET AS t
    JOIN GADGET_TICKET AS gt
        ON gt.ticket_id = t.ticket_id
    JOIN GADGET AS g
        ON g.serial_no_IMEI = gt.serial_no_IMEI
    JOIN CATALOG AS c
        ON c.catalog_id = g.catalog_id
    GROUP BY g.client_id, c.device_category, YEAR(t.received_dateTime),
MONTH(t.received_dateTime)
    HAVING COUNT(DISTINCT t.ticket_id) > 3
)
SELECT
    client.client_id,
    client.name AS customer_name,
    client.email,
    c.device_category,
    q.visit_year,
    q.visit_month,
    q.work_orders,
    t.ticket_id,
    g.serial_no_IMEI
FROM QualifyingGroups AS q
JOIN CLIENT AS client
    ON client.client_id = q.client_id
JOIN TICKET AS t
    ON YEAR(t.received_dateTime) = q.visit_year
   AND MONTH(t.received_dateTime) = q.visit_month
JOIN GADGET_TICKET AS gt
    ON gt.ticket_id = t.ticket_id
JOIN GADGET AS g
    ON g.serial_no_IMEI = gt.serial_no_IMEI
   AND g.client_id = q.client_id
JOIN CATALOG AS c
    ON c.catalog_id = g.catalog_id




   AND c.device_category = q.device_category
ORDER BY customer_name, q.visit_year, q.visit_month, t.ticket_id;
