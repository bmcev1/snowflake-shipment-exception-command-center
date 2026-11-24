-- ============================================================
-- Shipment Exception Command Center
-- 03_analysis.sql
--
-- Business analysis used to evaluate shipment performance,
-- carrier reliability, transportation modes, lanes, freight
-- cost, and operational exceptions.
-- ============================================================


USE WAREHOUSE LOGISTICS_WH;
USE DATABASE LOGISTICS_AI_PROJECT;


-- ============================================================
-- 1. OVERALL SHIPMENT PERFORMANCE
-- ============================================================

SELECT
    COUNT(*) AS TOTAL_SHIPMENTS,

    COUNT_IF(
        ACTUAL_DELIVERY_DATE <= PLANNED_DELIVERY_DATE
    ) AS ON_TIME_SHIPMENTS,

    COUNT_IF(
        ACTUAL_DELIVERY_DATE > PLANNED_DELIVERY_DATE
    ) AS LATE_SHIPMENTS,

    ROUND(
        COUNT_IF(
            ACTUAL_DELIVERY_DATE <= PLANNED_DELIVERY_DATE
        ) / COUNT(*) * 100,
        2
    ) AS ON_TIME_PERCENTAGE

FROM RAW.SHIPMENTS;


-- ============================================================
-- 2. CARRIER PERFORMANCE
-- ============================================================

SELECT
    CARRIER,
    COUNT(*) AS TOTAL_SHIPMENTS,

    COUNT_IF(
        ACTUAL_DELIVERY_DATE <= PLANNED_DELIVERY_DATE
    ) AS ON_TIME_SHIPMENTS,

    COUNT_IF(
        ACTUAL_DELIVERY_DATE > PLANNED_DELIVERY_DATE
    ) AS LATE_SHIPMENTS,

    ROUND(
        COUNT_IF(
            ACTUAL_DELIVERY_DATE <= PLANNED_DELIVERY_DATE
        ) / COUNT(*) * 100,
        2
    ) AS ON_TIME_PERCENTAGE

FROM RAW.SHIPMENTS

GROUP BY CARRIER

ORDER BY ON_TIME_PERCENTAGE DESC;


-- ============================================================
-- 3. TRANSPORTATION MODE PERFORMANCE
-- ============================================================

SELECT
    MODE,
    COUNT(*) AS TOTAL_SHIPMENTS,

    COUNT_IF(
        ACTUAL_DELIVERY_DATE > PLANNED_DELIVERY_DATE
    ) AS LATE_SHIPMENTS,

    ROUND(
        COUNT_IF(
            ACTUAL_DELIVERY_DATE <= PLANNED_DELIVERY_DATE
        ) / COUNT(*) * 100,
        2
    ) AS ON_TIME_PERCENTAGE

FROM RAW.SHIPMENTS

GROUP BY MODE

ORDER BY ON_TIME_PERCENTAGE DESC;


-- ============================================================
-- 4. FREIGHT COST BY TRANSPORTATION MODE
-- ============================================================

SELECT
    MODE,
    COUNT(*) AS TOTAL_SHIPMENTS,

    ROUND(
        AVG(FREIGHT_COST),
        2
    ) AS AVG_FREIGHT_COST,

    ROUND(
        SUM(FREIGHT_COST),
        2
    ) AS TOTAL_FREIGHT_SPEND,

    ROUND(
        AVG(
            FREIGHT_COST / NULLIF(WEIGHT_LBS, 0)
        ),
        2
    ) AS AVG_COST_PER_LB,

    ROUND(
        COUNT_IF(
            ACTUAL_DELIVERY_DATE <= PLANNED_DELIVERY_DATE
        ) / COUNT(*) * 100,
        2
    ) AS ON_TIME_PERCENTAGE

FROM RAW.SHIPMENTS

GROUP BY MODE

ORDER BY AVG_FREIGHT_COST DESC;


-- ============================================================
-- 5. TRANSPORTATION LANE PERFORMANCE
-- ============================================================

SELECT
    ORIGIN_CITY || ', ' || ORIGIN_STATE || ' → ' ||
    DESTINATION_CITY || ', ' || DESTINATION_STATE AS LANE,

    COUNT(*) AS TOTAL_SHIPMENTS,

    COUNT_IF(
        ACTUAL_DELIVERY_DATE > PLANNED_DELIVERY_DATE
    ) AS LATE_SHIPMENTS,

    ROUND(
        COUNT_IF(
            ACTUAL_DELIVERY_DATE <= PLANNED_DELIVERY_DATE
        ) / COUNT(*) * 100,
        2
    ) AS ON_TIME_PERCENTAGE

FROM RAW.SHIPMENTS

GROUP BY LANE

ORDER BY ON_TIME_PERCENTAGE ASC;


-- ============================================================
-- 6. PRIORITY DISTRIBUTION
-- ============================================================

SELECT
    PRIORITY,
    COUNT(*) AS SHIPMENT_COUNT,

    ROUND(
        COUNT(*) / SUM(COUNT(*)) OVER () * 100,
        2
    ) AS PERCENT_OF_SHIPMENTS

FROM ANALYTICS.SHIPMENT_PERFORMANCE

GROUP BY PRIORITY

ORDER BY
    CASE PRIORITY
        WHEN 'HIGH' THEN 1
        WHEN 'MEDIUM' THEN 2
        WHEN 'LOW' THEN 3
        WHEN 'NORMAL' THEN 4
    END;


-- ============================================================
-- 7. ACTIVE EXCEPTION QUEUE
-- ============================================================

SELECT
    SHIPMENT_ID,
    PRIORITY,
    DAYS_LATE,
    CARRIER,
    MODE,
    LANE,
    SERVICE_LEVEL,
    FREIGHT_COST,
    EXCEPTION_NOTE,
    ATTENTION_REASON

FROM ANALYTICS.SHIPMENT_PERFORMANCE

WHERE PRIORITY IN (
    'HIGH',
    'MEDIUM'
)

ORDER BY
    CASE PRIORITY
        WHEN 'HIGH' THEN 1
        WHEN 'MEDIUM' THEN 2
    END,
    DAYS_LATE DESC;


-- ============================================================
-- 8. WORST-PERFORMING LANES
-- ============================================================

SELECT
    LANE,
    COUNT(*) AS TOTAL_SHIPMENTS,

    COUNT_IF(
        DELIVERY_PERFORMANCE = 'LATE'
    ) AS LATE_SHIPMENTS,

    ROUND(
        COUNT_IF(
            DELIVERY_PERFORMANCE = 'ON TIME'
        ) / COUNT(*) * 100,
        2
    ) AS ON_TIME_PERCENTAGE

FROM ANALYTICS.SHIPMENT_PERFORMANCE

GROUP BY LANE

ORDER BY ON_TIME_PERCENTAGE ASC;