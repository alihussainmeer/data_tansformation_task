select
    {{ dbt_utils.generate_surrogate_key([
        "VENUE_ID",
        "date"
    ]) }} as PK_VENUE_DAILY_POLICIES_ID,
    PARTNER_ID::varchar as FK_PARTNER_ID,
    VENUE_ID::varchar as FK_VENUE_ID,

    trim(upper(ACCESS_DISTRIBUTION::varchar)) as ACCESS_DISTRIBUTION,
    trim(upper(VENUE_TYPE::varchar)) as VENUE_TYPE,
    IS_REVOLVING::boolean as IS_REVOLVING,

    "date"::date as VENUE_POLICY_DATE
from {{ ref('venue_daily_policies') }}
