import streamlit as st
from snowflake.snowpark.context import get_active_session

# --------------------------------------------------
# PAGE CONFIGURATION
# --------------------------------------------------

st.set_page_config(
    page_title="Shipment Exception Command Center",
    layout="wide"
)

# Connect to Snowflake
session = get_active_session()

# Load analytics-ready shipment data
shipments = session.table(
    "LOGISTICS_AI_PROJECT.ANALYTICS.SHIPMENT_PERFORMANCE"
).to_pandas()


# --------------------------------------------------
# HEADER
# --------------------------------------------------

st.title("Shipment Exception Command Center")

st.markdown(
    """
    Monitor transportation performance, identify shipment delays,
    and prioritize logistics exceptions requiring attention.
    """
)

st.caption(
    "Built with Snowflake, SQL, Python, Pandas, and Streamlit | "
    "Synthetic shipment data"
)

st.divider()


# --------------------------------------------------
# FILTERS
# --------------------------------------------------

st.subheader("Filters")

filter_col1, filter_col2, filter_col3 = st.columns(3)

carrier_options = ["All"] + sorted(
    shipments["CARRIER"].dropna().unique().tolist()
)

mode_options = ["All"] + sorted(
    shipments["MODE"].dropna().unique().tolist()
)

priority_options = [
    "All",
    "HIGH",
    "MEDIUM",
    "LOW",
    "NORMAL"
]

selected_carrier = filter_col1.selectbox(
    "Carrier",
    carrier_options
)

selected_mode = filter_col2.selectbox(
    "Transportation Mode",
    mode_options
)

selected_priority = filter_col3.selectbox(
    "Priority",
    priority_options
)


# --------------------------------------------------
# APPLY FILTERS
# --------------------------------------------------

filtered_shipments = shipments.copy()

if selected_carrier != "All":
    filtered_shipments = filtered_shipments[
        filtered_shipments["CARRIER"] == selected_carrier
    ]

if selected_mode != "All":
    filtered_shipments = filtered_shipments[
        filtered_shipments["MODE"] == selected_mode
    ]

if selected_priority != "All":
    filtered_shipments = filtered_shipments[
        filtered_shipments["PRIORITY"] == selected_priority
    ]


# --------------------------------------------------
# KPI CALCULATIONS
# --------------------------------------------------

total_shipments = len(filtered_shipments)

on_time_shipments = (
    filtered_shipments["DELIVERY_PERFORMANCE"] == "ON TIME"
).sum()

on_time_rate = (
    (on_time_shipments / total_shipments) * 100
    if total_shipments > 0
    else 0
)

attention_shipments = (
    filtered_shipments["PRIORITY"]
    .isin(["HIGH", "MEDIUM"])
    .sum()
)

high_priority = (
    filtered_shipments["PRIORITY"] == "HIGH"
).sum()


# --------------------------------------------------
# KPI SCORECARD
# --------------------------------------------------

st.subheader("Network Overview")

kpi1, kpi2, kpi3, kpi4 = st.columns(4)

kpi1.metric(
    "Total Shipments",
    f"{total_shipments:,}"
)

kpi2.metric(
    "On-Time Rate",
    f"{on_time_rate:.1f}%"
)

kpi3.metric(
    "Requires Attention",
    f"{attention_shipments:,}"
)

kpi4.metric(
    "High Priority",
    f"{high_priority:,}"
)

st.divider()


# --------------------------------------------------
# PERFORMANCE ANALYTICS
# --------------------------------------------------

st.header("Performance Analytics")

chart1, chart2 = st.columns(2)


# ----- CARRIER PERFORMANCE -----

with chart1:

    st.subheader("Carrier Performance")

    if len(filtered_shipments) > 0:

        carrier_performance = (
            filtered_shipments
            .groupby("CARRIER")
            .agg(
                TOTAL_SHIPMENTS=("SHIPMENT_ID", "count"),
                ON_TIME_SHIPMENTS=(
                    "DELIVERY_PERFORMANCE",
                    lambda x: (x == "ON TIME").sum()
                )
            )
            .reset_index()
        )

        carrier_performance["ON_TIME_PERCENTAGE"] = (
            carrier_performance["ON_TIME_SHIPMENTS"]
            / carrier_performance["TOTAL_SHIPMENTS"]
            * 100
        )

        carrier_performance = (
            carrier_performance
            .sort_values(
                "ON_TIME_PERCENTAGE",
                ascending=False
            )
        )

        st.bar_chart(
            carrier_performance,
            x="CARRIER",
            y="ON_TIME_PERCENTAGE"
        )

        st.caption(
            "On-time delivery rate by carrier."
        )

    else:
        st.info(
            "No carrier data matches the selected filters."
        )


# ----- LANE PERFORMANCE -----

with chart2:

    st.subheader("Lowest-Performing Lanes")

    if len(filtered_shipments) > 0:

        lane_performance = (
            filtered_shipments
            .groupby("LANE")
            .agg(
                TOTAL_SHIPMENTS=("SHIPMENT_ID", "count"),
                ON_TIME_SHIPMENTS=(
                    "DELIVERY_PERFORMANCE",
                    lambda x: (x == "ON TIME").sum()
                )
            )
            .reset_index()
        )

        lane_performance["ON_TIME_PERCENTAGE"] = (
            lane_performance["ON_TIME_SHIPMENTS"]
            / lane_performance["TOTAL_SHIPMENTS"]
            * 100
        )

        worst_lanes = (
            lane_performance
            .sort_values(
                "ON_TIME_PERCENTAGE",
                ascending=True
            )
            .head(5)
        )

        st.bar_chart(
            worst_lanes,
            x="LANE",
            y="ON_TIME_PERCENTAGE"
        )

        st.caption(
            "Five lanes with the lowest on-time delivery rates."
        )

    else:
        st.info(
            "No lane data matches the selected filters."
        )


st.divider()


# --------------------------------------------------
# EXCEPTION MANAGEMENT
# --------------------------------------------------

st.header("Exception Management")

st.markdown(
    """
    The queue below removes normal shipments from view and
    prioritizes delayed shipments so users can focus on the
    exceptions requiring action.
    """
)

exception_queue = filtered_shipments[
    filtered_shipments["PRIORITY"]
    .isin(["HIGH", "MEDIUM"])
].copy()


if len(exception_queue) > 0:

    priority_order = {
        "HIGH": 1,
        "MEDIUM": 2
    }

    exception_queue["PRIORITY_ORDER"] = (
        exception_queue["PRIORITY"]
        .map(priority_order)
    )

    exception_queue = (
        exception_queue
        .sort_values(
            by=[
                "PRIORITY_ORDER",
                "DAYS_LATE"
            ],
            ascending=[
                True,
                False
            ]
        )
    )

    exception_queue = exception_queue[
        [
            "SHIPMENT_ID",
            "PRIORITY",
            "DAYS_LATE",
            "CARRIER",
            "MODE",
            "LANE",
            "SERVICE_LEVEL",
            "FREIGHT_COST",
            "EXCEPTION_NOTE",
            "ATTENTION_REASON"
        ]
    ]

    st.dataframe(
        exception_queue,
        use_container_width=True,
        hide_index=True,
        column_config={
            "SHIPMENT_ID": "Shipment",
            "PRIORITY": "Priority",
            "DAYS_LATE": "Days Late",
            "CARRIER": "Carrier",
            "MODE": "Mode",
            "LANE": "Lane",
            "SERVICE_LEVEL": "Service Level",
            "FREIGHT_COST": st.column_config.NumberColumn(
                "Freight Cost",
                format="$%.2f"
            ),
            "EXCEPTION_NOTE": "Exception",
            "ATTENTION_REASON": "Attention Reason"
        }
    )

else:

    st.success(
        "No high- or medium-priority shipments "
        "match the selected filters."
    )


# --------------------------------------------------
# PROJECT INFORMATION
# --------------------------------------------------

st.divider()

with st.expander("About this project"):

    st.markdown(
        """
        **Shipment Exception Command Center** is a portfolio
        supply-chain analytics application built using synthetic
        transportation data.

The project demonstrates an end-to-end analytics workflow:


1. Synthetic shipment data loaded into Snowflake
2. Raw shipment data stored in the RAW layer
3. SQL used to clean, transform, and calculate operational metrics
4. Analytics-ready data stored in the ANALYTICS layer
5. Python and Pandas used for application logic and analysis
6. Streamlit used to create the interactive command center

Notes: The application converts shipment records into operational
        KPIs, carrier and lane performance metrics, priority
        classifications, and an exception queue designed to help
        users identify which shipments require attention.

        -Technologies: Snowflake, SQL, Python, Pandas, Streamlit

        -Data: 100% synthetic. No proprietary company data is used.
        """
    )