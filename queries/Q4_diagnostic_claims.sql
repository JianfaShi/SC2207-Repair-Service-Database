-- Extracted from Lab5_SDAG_Team3 (3).pdf, PDF pages 27.
-- PDF line wrapping removed only where verified against the original SQL files.
-- Query logic and source naming are preserved. Select your SQL Server database first.

SELECT
    client.client_id,
    client.name AS customer_name,
    client.email,
    COUNT(*) AS approved_claims_with_qualifying_inspection,
    SUM(COALESCE(claim.refund_value, 0)) AS
assumed_requested_payout_under_full_approval
FROM WARRANTY_CLAIM AS claim
JOIN GADGET_TICKET AS gt
    ON gt.ticket_id = claim.ticket_id
JOIN GADGET AS g
    ON g.serial_no_IMEI = gt.serial_no_IMEI
JOIN CLIENT AS client
    ON client.client_id = g.client_id
WHERE EXISTS (
    SELECT 1
    FROM [PROCEDURE] AS p
    JOIN DIAGNOSTIC_ASSESSMENT AS da
        ON da.ticket_id = p.ticket_id
       AND da.procedure_no = p.procedure_no
    WHERE p.ticket_id = claim.ticket_id
      AND p.procedure_type = N'Inspection'
      AND da.liquid_damage IN (N'Liquid Damage', N'Tripped')
)
GROUP BY client.client_id, client.name, client.email
ORDER BY client.name;
