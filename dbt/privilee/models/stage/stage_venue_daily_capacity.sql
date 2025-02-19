SELECT
{{dbt_utils.generate_surrogate_key([
        "venue_id",
        "date"
    ])}} as PK_VENUE_DAILY_CAPACITY_ID,
venue_id::varchar as fk_venue_id,
capacity_adults::INTEGER as capacity_adults,
"date"::date as capacity_date
from {{ ref('venue_daily_capacity') }}
