select
{{ dbt_utils.generate_surrogate_key([
        "partner_id",
        "date"
    ]) }} as PK_PARTNER_DAILY_CAPACITY_ID,
    PARTNER_ID::varchar as FK_PARTNER_ID,
    CAPACITY_ADULTS::integer as CAPACITY_ADULTS,
    "date"::date as CAPACITY_DATE

from {{ ref('partner_daily_capacity') }}
