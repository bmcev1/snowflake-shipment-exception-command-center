-- ============================================================
-- Shipment Exception Command Center
-- 02_transformations.sql
--
-- Transforms raw shipment data into an analytics-ready
-- shipment performance table used by the Streamlit application.
-- ============================================================


USE WAREHOUSE LOGISTICS_WH;
USE DATABASE LOGISTICS_AI_PROJECT;


-- ============================================================
-- CREATE ANALYTICS-READY SHIPMENT TABLE
-- ============================================================

CREATE OR REPLACE TABLE ANALYTICS.SHIPMENT_PERFORMANCE AS

SELECT
    SHIPMENT_ID,
    CARRIER,
    MODE,

    ORIGIN_CITY,
    ORIGIN_STATE,
    DESTINATION_CITY,
    DESTINATION_STATE,

    -- Create a readable transportation lane
    ORIGIN_CITY || ', ' || ORIGIN_STATE || ' → ' ||
    DESTINATION_CITY || ', ' || DESTINATION_STATE AS LANE,

    SHIP_DATE,
    PLANNED_DELIVERY_DATE,
    ACTUAL_DELIVERY_DATE,

    -- Calculate number of days late
    DATEDIFF(
        'day',
        PLANNED_DELIVERY_DATE,
        ACTUAL_DELIVERY_DATE
    ) AS DAYS_LATE,

    WEIGHT_LBS,
    FREIGHT_COST,

    -- Normalize freight cost by shipment weight
    ROUND(
        FREIGHT_COST / NULLIF(WEIGHT_LBS, 0),
        2
    ) AS COST_PER_LB,

    SERVICE_LEVEL,
    SHIPMENT_STATUS,
    EXCEPTION_NOTE,

    -- Classify delivery performance
    CASE
        WHEN ACTUAL_DELIVERY_DATE <= PLANNED_DELIVERY_DATE
            THEN 'ON TIME'
        ELSE 'LATE'
    END AS DELIVERY_PERFORMANCE,

    -- Identify shipments containing an exception
    CASE
        WHEN EXCEPTION_NOTE <> 'No exception'
            THEN 'YES'
        ELSE 'NO'
    END AS EXCEPTION_FLAG

FROM RAW.SHIPMENTS;


-- ============================================================
-- ADD SHIPMENT PRIORITY
-- ============================================================

CREATE OR REPLACE TABLE ANALYTICS.SHIPMENT_PERFORMANCE AS

SELECT
    *,

    CASE
        WHEN DAYS_LATE >= 3 THEN 'HIGH'
        WHEN DAYS_LATE BETWEEN 1 AND 2 THEN 'MEDIUM'
        WHEN EXCEPTION_FLAG = 'YES' THEN 'LOW'
        ELSE 'NORMAL'
    END AS PRIORITY

FROM ANALYTICS.SHIPMENT_PERFORMANCE;


-- ============================================================
-- ADD ATTENTION REASON
-- ============================================================

ALTER TABLE ANALYTICS.SHIPMENT_PERFORMANCE
ADD COLUMN ATTENTION_REASON VARCHAR;


UPDATE ANALYTICS.SHIPMENT_PERFORMANCE

SET ATTENTION_REASON =
    CASE
        WHEN DAYS_LATE >= 3
            THEN 'Severe delivery delay'

        WHEN DAYS_LATE BETWEEN 1 AND 2
            THEN 'Delivery delay'

        WHEN EXCEPTION_FLAG = 'YES'
            THEN 'Shipment exception'

        ELSE 'No action required'
    END;


-- ============================================================
-- VALIDATION
-- ============================================================

SELECT
    COUNT(*) AS TOTAL_SHIPMENTS
FROM ANALYTICS.SHIPMENT_PERFORMANCE;


SELECT
    PRIORITY,
    COUNT(*) AS SHIPMENT_COUNT
FROM ANALYTICS.SHIPMENT_PERFORMANCE
GROUP BY PRIORITY
ORDER BY SHIPMENT_COUNT DESC;