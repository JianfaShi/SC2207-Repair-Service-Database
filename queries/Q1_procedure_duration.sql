-- Extracted from Lab5_SDAG_Team3 (3).pdf, PDF pages 23-24.
-- PDF line wrapping removed only where verified against the original SQL files.
-- Query logic and source naming are preserved. Select your SQL Server database first.

WITH ProcedureDurations AS (
    SELECT
        p.ticket_id,
        p.procedure_no,
        p.station_id,
        c.device_category,
        DATEDIFF(SECOND, MIN(ws.start_time), MAX(ws.end_time)) AS elapsed_seconds
    FROM [PROCEDURE] AS p
    JOIN WORK_SESSION AS ws
        ON ws.ticket_id = p.ticket_id
       AND ws.procedure_no = p.procedure_no
    JOIN TICKET AS t
        ON t.ticket_id = p.ticket_id
    JOIN GADGET_TICKET AS gt
        ON gt.ticket_id = t.ticket_id
    JOIN GADGET AS g
        ON g.serial_no_IMEI = gt.serial_no_IMEI
    JOIN CATALOG AS c
        ON c.catalog_id = g.catalog_id
    WHERE p.status = N'Completed'
    GROUP BY p.ticket_id, p.procedure_no, p.station_id, c.device_category
),
StationCategory AS (
    SELECT s.station_id, category.device_category
    FROM STATION AS s
    CROSS JOIN (SELECT DISTINCT device_category FROM CATALOG) AS category
)
SELECT
    sc.station_id,
    sc.device_category,
    COUNT(CASE WHEN pd.elapsed_seconds < 10800 THEN 1 END) AS
procedures_under_180_minutes
FROM StationCategory AS sc
LEFT JOIN ProcedureDurations AS pd
    ON pd.station_id = sc.station_id
   AND pd.device_category = sc.device_category
GROUP BY sc.station_id, sc.device_category
ORDER BY sc.station_id, sc.device_category;
