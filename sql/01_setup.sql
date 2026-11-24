-- ============================================================
-- Shipment Exception Command Center
-- 01_setup.sql
--
-- Creates the Snowflake warehouse, database, and schemas
-- used by the project.
-- ============================================================


-- Create an X-Small virtual warehouse for the project
CREATE OR REPLACE WAREHOUSE LOGISTICS_WH
    WAREHOUSE_SIZE = 'XSMALL'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE;


-- Create the project database
CREATE OR REPLACE DATABASE LOGISTICS_AI_PROJECT;

USE DATABASE LOGISTICS_AI_PROJECT;


-- RAW stores source shipment data as originally loaded
CREATE OR REPLACE SCHEMA RAW;


-- ANALYTICS stores transformed, analysis-ready data
CREATE OR REPLACE SCHEMA ANALYTICS;


-- Confirm schemas were created
SHOW SCHEMAS IN DATABASE LOGISTICS_AI_PROJECT;