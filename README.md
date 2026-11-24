\# Shipment Exception Command Center



An end-to-end supply chain analytics application built with Snowflake, SQL, Python, Pandas, and Streamlit.



The Shipment Exception Command Center transforms synthetic transportation data into operational performance metrics and a prioritized exception queue. The application is designed to help users quickly identify which shipments require attention, understand carrier and lane performance, and investigate delivery issues without manually reviewing every shipment record.



\## Project Overview



Transportation teams often work with large amounts of shipment data spread across operational systems, spreadsheets, and tracking information. Simply reporting shipment data does not always tell a user what requires action.



This project demonstrates how shipment data can be transformed into a decision-support application that answers questions such as:



\- Which shipments require attention?

\- Which exceptions are most urgent?

\- What is the overall on-time delivery rate?

\- Which carriers are performing best or worst?

\- Which transportation lanes have the lowest on-time performance?

\- How does transportation mode relate to service and freight cost?



The application uses 500 synthetic shipment records and does not contain proprietary company data.



\## Application Preview



\### Network Overview



!\[Dashboard Overview](images/dashboard-overview.png)



The command center provides interactive filters and high-level KPIs including total shipments, on-time delivery rate, shipments requiring attention, and high-priority shipments.



\### Performance Analytics



!\[Performance Analytics](images/performance-analytics.png)



Carrier and lane performance views help identify areas that may warrant additional investigation.



\### Exception Management



!\[Exception Management](images/exception-management.png)



The Active Exception Queue removes normal shipments from view and prioritizes delayed shipments based on operational business rules.



\## Project Workflow



1\. Synthetic shipment data is loaded into Snowflake.

2\. Original shipment records are stored in the `RAW` schema.

3\. SQL transformations create calculated operational fields.

4\. Analysis-ready shipment data is stored in the `ANALYTICS` schema.

5\. Python and Pandas calculate and organize application metrics.

6\. Streamlit provides the interactive user interface and exception-management workflow.



\## Architecture



\*\*Source Data\*\*  

Synthetic CSV shipment dataset containing shipment IDs, carriers, transportation modes, origins, destinations, delivery dates, shipment weights, freight costs, service levels, statuses, and exception notes.



\*\*Snowflake RAW Layer\*\*  

`LOGISTICS\_AI\_PROJECT.RAW.SHIPMENTS`



Stores the original shipment records loaded from the CSV dataset.



\*\*Snowflake ANALYTICS Layer\*\*  

`LOGISTICS\_AI\_PROJECT.ANALYTICS.SHIPMENT\_PERFORMANCE`



Transforms the source data into an analytics-ready dataset used by the application.



\*\*Application Layer\*\*  

Python, Pandas, Snowpark, and Streamlit are used to retrieve the analytics data, calculate interactive metrics, and display the Shipment Exception Command Center.



\## Engineered Analytics Fields



The transformation layer creates several fields that are not directly available in the source data:



\- `LANE` — combines shipment origin and destination into a transportation lane.

\- `DAYS\_LATE` — calculates the difference between planned and actual delivery dates.

\- `COST\_PER\_LB` — normalizes freight cost by shipment weight.

\- `DELIVERY\_PERFORMANCE` — classifies shipments as `ON TIME` or `LATE`.

\- `EXCEPTION\_FLAG` — identifies shipments containing an exception.

\- `PRIORITY` — classifies shipments as `HIGH`, `MEDIUM`, `LOW`, or `NORMAL`.

\- `ATTENTION\_REASON` — explains why a shipment requires operational attention.



\## Exception Prioritization



The application uses rule-based exception logic:



\- \*\*HIGH\*\* — shipment is 3 or more days late.

\- \*\*MEDIUM\*\* — shipment is 1–2 days late.

\- \*\*LOW\*\* — shipment is on time but contains an exception.

\- \*\*NORMAL\*\* — shipment is on time with no exception requiring attention.



High- and medium-priority shipments are surfaced in the Active Exception Queue and ranked by urgency.



\## Key Findings



Analysis of the synthetic dataset identified:



\- \*\*500\*\* total shipments

\- \*\*83.2%\*\* overall on-time delivery rate

\- \*\*84\*\* late shipments requiring attention

\- \*\*23\*\* high-priority shipments

\- \*\*61\*\* medium-priority shipments

\- \*\*Apex Freight\*\* had the highest carrier on-time rate at approximately \*\*86.44%\*\*

\- \*\*BlueLine Logistics\*\* had the lowest carrier on-time rate at approximately \*\*82.02%\*\*

\- \*\*FTL\*\* had the highest mode-level on-time rate at approximately \*\*87.86%\*\*

\- \*\*LTL\*\* had the lowest mode-level on-time rate at approximately \*\*78.97%\*\*

\- \*\*Dallas, TX to Atlanta, GA\*\* was the lowest-performing lane at approximately \*\*69.64% on time\*\*

\- FTL had the highest average freight cost at approximately \*\*$4,819.13 per shipment\*\*

\- Air had the highest average freight cost per pound at approximately \*\*$1.30\*\*



These findings are descriptive and are intended to identify areas for further investigation rather than establish causation.



\## Interactive Features



Users can filter the application by:



\- Carrier

\- Transportation mode

\- Priority



The KPI scorecards, performance analytics, and exception queue respond to the selected filters.



\## Technologies Used



\- Snowflake

\- SQL

\- Snowpark

\- Python

\- Pandas

\- Streamlit



\## Repository Structure



```text

snowflake-shipment-exception-command-center/

|

|-- data/

|   `-- shipments.csv

|

|-- images/

|   |-- dashboard-overview.png

|   |-- performance-analytics.png

|   `-- exception-management.png

|

|-- sql/

|   |-- 01\_setup.sql

|   |-- 02\_transformations.sql

|   `-- 03\_analysis.sql

|

|-- streamlit/

|   `-- app.py

|

`-- README.md

