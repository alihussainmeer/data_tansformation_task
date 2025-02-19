select
{{dbt_utils.generate_surrogate_key([
        "partner_id",
        "date"
    ])}} as PK_PARTNER_DAILY_CAPACITY_ID,
partner_id::varchar as fk_partner_id,
capacity_adults::INTEGER as capacity_adults,
"date"::date as capacity_date

from {{ ref('partner_daily_capacity') }}
