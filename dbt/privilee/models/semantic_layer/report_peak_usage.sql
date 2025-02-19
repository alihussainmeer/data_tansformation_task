WITH OCCUPANCY_CHECKIN AS (
    SELECT
        FK_VENUE_ID,
        FK_USER_ID,
        EVENT_TIMESTAMP_LTZ AS CHECKIN_TIMESTAMP_LTZ,
        DATE_TRUNC('HOUR', CREATED_AT_TIMESTAMP_LTZ) AS JOIN_DATE
    FROM {{ ref('stage_venue_register') }}
    WHERE
        1 = 1
        {# and  event_timestamp_ltz::date = '2024-10-01' #}
        AND EVENT_NAME = 'ENTER'
),

OCCUPANCY_CHECKOUT AS (
    SELECT
        FK_VENUE_ID,
        FK_USER_ID,
        EVENT_TIMESTAMP_LTZ AS CHECKOUT_TIMESTAMP_LTZ,
        DATE_TRUNC('HOUR', CREATED_AT_TIMESTAMP_LTZ) AS JOIN_DATE
    FROM {{ ref('stage_venue_register') }}
    WHERE
        1 = 1
        {# and  event_timestamp_ltz::date = '2024-10-01' #}
        AND EVENT_NAME = 'LEAVE'
),

FORMATTED_MASTER_DATA AS (
    SELECT
        OCCUPANCY_CHECKIN.FK_VENUE_ID,
        OCCUPANCY_CHECKIN.FK_USER_ID,
        OCCUPANCY_CHECKIN.CHECKIN_TIMESTAMP_LTZ,
        OCCUPANCY_CHECKOUT.CHECKOUT_TIMESTAMP_LTZ
    FROM OCCUPANCY_CHECKIN
    LEFT JOIN OCCUPANCY_CHECKOUT
        ON
            OCCUPANCY_CHECKIN.FK_VENUE_ID = OCCUPANCY_CHECKOUT.FK_VENUE_ID
            AND OCCUPANCY_CHECKIN.FK_USER_ID = OCCUPANCY_CHECKOUT.FK_USER_ID
            AND OCCUPANCY_CHECKIN.JOIN_DATE = OCCUPANCY_CHECKOUT.JOIN_DATE
),



EXPLODED_OCCUPANCY AS (
    SELECT
        FMD.*,
        FD.*,
        1 AS COUNT_PER_DATEHOUR_PER_VENUE
    FROM FORMATTED_MASTER_DATA AS FMD
    CROSS JOIN {{ ref('fact_dates') }} AS FD
    WHERE
        FD.DATE_HOUR >= DATE_TRUNC('HOUR', FMD.CHECKIN_TIMESTAMP_LTZ)
        AND FD.DATE_HOUR <= DATE_TRUNC('HOUR', FMD.CHECKOUT_TIMESTAMP_LTZ)
),

VENUE_DAILY_CAPACITY AS (
    SELECT
        FK_VENUE_ID,
        CAPACITY_ADULTS AS VENUE_CAPACITY_ADULTS,
        CAPACITY_DATE
    FROM {{ ref('stage_venue_daily_capacity') }}

),

PARTNER_DAILY_CAPACITY AS (
    SELECT
        FK_PARTNER_ID,
        CAPACITY_ADULTS AS PARTNER_CAPACITY_ADULTS,
        CAPACITY_DATE
    FROM {{ ref('stage_partner_daily_capacity') }}
),

PREFINAL AS (
    SELECT
        EXPLODED_OCCUPANCY.*,
        P.FK_PARTNER_ID,
        VDC.VENUE_CAPACITY_ADULTS,
        PDC.PARTNER_CAPACITY_ADULTS,
        COUNT(*)
            OVER (
                PARTITION BY EXPLODED_OCCUPANCY.FK_VENUE_ID, DATE_TRUNC('DAY', EXPLODED_OCCUPANCY.DATE_HOUR)
                ORDER BY null
            )
        AS COUNT_PER_DAY_PER_VENUE,
        COUNT(*)
            OVER (PARTITION BY P.FK_PARTNER_ID, DATE_TRUNC('DAY', EXPLODED_OCCUPANCY.DATE_HOUR) ORDER BY null)
        AS COUNT_PER_DAY_PER_PARTNER
    FROM EXPLODED_OCCUPANCY
    INNER JOIN {{ ref('stage_venue_daily_policies') }} AS P
        ON
            EXPLODED_OCCUPANCY.FK_VENUE_ID = P.FK_VENUE_ID
            AND EXPLODED_OCCUPANCY.DATE_HOUR::date = P.VENUE_POLICY_DATE::date
            AND P.IS_REVOLVING = true
    LEFT JOIN VENUE_DAILY_CAPACITY AS VDC
        ON
            EXPLODED_OCCUPANCY.FK_VENUE_ID = VDC.FK_VENUE_ID
            AND EXPLODED_OCCUPANCY.DATE_HOUR::date = VDC.CAPACITY_DATE::date
    LEFT JOIN PARTNER_DAILY_CAPACITY AS PDC
        ON
            P.FK_PARTNER_ID = PDC.FK_PARTNER_ID
            AND EXPLODED_OCCUPANCY.DATE_HOUR::date = PDC.CAPACITY_DATE::date
)

SELECT
    *,
    CASE
        WHEN COUNT_PER_DAY_PER_VENUE > VENUE_CAPACITY_ADULTS THEN 'EXCEEDED'
        WHEN VENUE_CAPACITY_ADULTS IS null AND COUNT_PER_DAY_PER_PARTNER > PARTNER_CAPACITY_ADULTS THEN 'EXCEEDED'
        ELSE 'WITHIN_LIMIT'
    END AS CAPACITY_STATUS
FROM PREFINAL
