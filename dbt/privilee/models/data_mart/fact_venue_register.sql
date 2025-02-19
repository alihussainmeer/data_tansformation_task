select
    _ID::varchar as PK_VENUE_REGISTER_ID,
    VENUE_ID::varchar as FK_VENUE_ID,
    USER_ID::varchar as FK_USER_ID,

    trim(upper(EVENT_NAME::varchar)) as EVENT_NAME,
    trim(upper(EVENT_TRIGGERED_BY::varchar)) as EVENT_TRIGGERED_BY,
    trim(upper(EVENT_TYPE::varchar)) as EVENT_TYPE,

    CREATED_AT::timestamp as CREATED_AT_TIMESTAMP_UTC,
    CREATED_AT::timestamp at time zone 'asia/dubai' as CREATED_AT_TIMESTAMP_LTZ,
    EVENT_TIMESTAMP::timestamp as EVENT_TIMESTAMP_UTC,
    EVENT_TIMESTAMP::timestamp at time zone 'asia/dubai' as EVENT_TIMESTAMP_LTZ

from {{ ref('venue_register') }}
