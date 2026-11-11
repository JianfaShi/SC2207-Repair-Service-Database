-- Extracted from Lab5_SDAG_Team3 (3).pdf, PDF pages 24-25.
-- PDF line wrapping removed only where verified against the original SQL files.
-- Query logic and source naming are preserved. Select your SQL Server database first.

WITH LaborByTicket AS (
    SELECT
        ws.ticket_id,
        SUM(ws.billable_time * tech.hourly_rate) AS labor_revenue
    FROM WORK_SESSION AS ws
    JOIN TECHNICIAN AS tech
        ON tech.employee_id = ws.technician_id
    GROUP BY ws.ticket_id
),
PartsByTicket AS (
    SELECT
        pa.ticket_id,
        SUM(pa.quantity_used * pa.locked_price) AS parts_revenue
    FROM PART_ALLOCATION AS pa
    GROUP BY pa.ticket_id
)
SELECT
    c.device_category,
    SUM(COALESCE(l.labor_revenue, 0)) AS labor_revenue,
    SUM(COALESCE(p.parts_revenue, 0)) AS parts_revenue,
    SUM(COALESCE(l.labor_revenue, 0) + COALESCE(p.parts_revenue, 0)) AS
gross_revenue_before_tax_and_discount





FROM TICKET AS t
JOIN GADGET_TICKET AS gt
    ON gt.ticket_id = t.ticket_id
JOIN GADGET AS g
    ON g.serial_no_IMEI = gt.serial_no_IMEI
JOIN CATALOG AS c
    ON c.catalog_id = g.catalog_id
LEFT JOIN LaborByTicket AS l
    ON l.ticket_id = t.ticket_id
LEFT JOIN PartsByTicket AS p
    ON p.ticket_id = t.ticket_id
WHERE t.status = N'Completed'
GROUP BY c.device_category
ORDER BY c.device_category;
