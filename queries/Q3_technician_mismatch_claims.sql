-- Extracted from Lab5_SDAG_Team3 (3).pdf, PDF pages 25-27.
-- PDF line wrapping removed only where verified against the original SQL files.
-- Query logic and source naming are preserved. Select your SQL Server database first.

WITH QualifiedCustomers AS (
    SELECT DISTINCT g.client_id
    FROM WARRANTY_CLAIM AS claim
    JOIN GADGET_TICKET AS gt
        ON gt.ticket_id = claim.ticket_id
    JOIN GADGET AS g
        ON g.serial_no_IMEI = gt.serial_no_IMEI
    JOIN CATALOG AS c





        ON c.catalog_id = g.catalog_id
    WHERE EXISTS (
        SELECT 1
        FROM [PROCEDURE] AS p
        JOIN WORK_SESSION AS ws
            ON ws.ticket_id = p.ticket_id
           AND ws.procedure_no = p.procedure_no
        JOIN TECHNICIAN AS tech
            ON tech.employee_id = ws.technician_id
        WHERE p.ticket_id = claim.ticket_id
          AND p.procedure_type <> N'Inspection'
          AND NOT (
                 (tech.specialization = N'Display' AND c.device_category =
N'Smartphone')
              OR (tech.specialization = N'Audio'   AND c.device_category =
N'Headphones')
          )
    )
)
SELECT
    client.client_id,
    client.name AS customer_name,
    client.email,
    c.manufacturer_name,
    COUNT(*) AS total_claims_for_qualified_customer
FROM QualifiedCustomers AS qc
JOIN CLIENT AS client
    ON client.client_id = qc.client_id
JOIN GADGET AS g
    ON g.client_id = qc.client_id
JOIN CATALOG AS c
    ON c.catalog_id = g.catalog_id
JOIN GADGET_TICKET AS gt
    ON gt.serial_no_IMEI = g.serial_no_IMEI
JOIN WARRANTY_CLAIM AS claim
    ON claim.ticket_id = gt.ticket_id
GROUP BY client.client_id, client.name, client.email, c.manufacturer_name
ORDER BY client.name, c.manufacturer_name;
