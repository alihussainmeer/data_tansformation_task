SELECT
{{ dbt_utils.generate_surrogate_key([
        "venue_id",
        "date"
    ]) }} AS PK_VENUE_DAILY_CAPACITY_ID,
    VENUE_ID::varchar AS FK_VENUE_ID,
    CAPACITY_ADULTS::integer AS CAPACITY_ADULTS,
    "date"::date AS CAPACITY_DATE
FROM {{ ref('venue_daily_capacity') }}
