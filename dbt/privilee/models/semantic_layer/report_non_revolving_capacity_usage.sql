with REVOLVING_VENUE_POLICIES as (
    select
        P.VENUE_POLICY_DATE,
        P.FK_PARTNER_ID,
        P.FK_VENUE_ID
    from {{ ref('stage_venue_daily_policies') }} as P
    where
        1 = 1
        and P.IS_REVOLVING = false

),

UNIQUE_CHECKINS_PER_PARTNER as (
    select
        FK_PARTNER_ID,
        VENUE_POLICY_DATE,
        count(distinct FK_USER_ID) as UNIQUE_CHECKINS_PER_PARTNER
    from {{ ref('stage_venue_register') }} as R
    left join {{ ref('stage_venue_daily_policies') }} as P
        on
            R.FK_VENUE_ID = P.FK_VENUE_ID
            and R.CREATED_AT_TIMESTAMP_LTZ::date = P.VENUE_POLICY_DATE::date
    --
    where
        1 = 1
        and R.EVENT_NAME = 'ENTER'
    group by 1, 2
),

UNIQUE_CHECKINS_PER_VENUE as (
    select
        CREATED_AT_TIMESTAMP_LTZ::date as CHECKIN_DATE,
        FK_VENUE_ID,
        count(distinct R.FK_USER_ID) as UNIQUE_CHECKINS
    from {{ ref('stage_venue_register') }} as R
    where
        1 = 1
        and R.EVENT_NAME = 'ENTER'
    group by 1, 2
),

VENUE_DAILY_CAPACITY as (
    select
        FK_VENUE_ID,
        CAPACITY_ADULTS as VENUE_CAPACITY_ADULTS,
        CAPACITY_DATE
    from {{ ref('stage_venue_daily_capacity') }}
),

PARTNER_DAILY_CAPACITY as (
    select
        FK_PARTNER_ID,
        CAPACITY_ADULTS as PARTNER_CAPACITY_ADULTS,
        CAPACITY_DATE
    from {{ ref('stage_partner_daily_capacity') }}
),

PRE_FINAL as (
    select

        RVP.VENUE_POLICY_DATE,
        RVP.FK_PARTNER_ID,
        RVP.FK_VENUE_ID,
        UCPV.UNIQUE_CHECKINS,
        VDC.VENUE_CAPACITY_ADULTS,
        PDC.PARTNER_CAPACITY_ADULTS,
        UCPD.UNIQUE_CHECKINS_PER_PARTNER
    from REVOLVING_VENUE_POLICIES as RVP
    left join UNIQUE_CHECKINS_PER_VENUE as UCPV
        on
            RVP.FK_VENUE_ID = UCPV.FK_VENUE_ID
            and RVP.VENUE_POLICY_DATE::date = UCPV.CHECKIN_DATE::date
    left join VENUE_DAILY_CAPACITY as VDC
        on
            RVP.FK_VENUE_ID = VDC.FK_VENUE_ID
            and RVP.VENUE_POLICY_DATE::date = VDC.CAPACITY_DATE::date
    left join PARTNER_DAILY_CAPACITY as PDC
        on
            RVP.FK_PARTNER_ID = PDC.FK_PARTNER_ID
            and RVP.VENUE_POLICY_DATE::date = PDC.CAPACITY_DATE::date
    left join UNIQUE_CHECKINS_PER_PARTNER as UCPD
        on
            RVP.FK_PARTNER_ID = UCPD.FK_PARTNER_ID
            and RVP.VENUE_POLICY_DATE::date = UCPD.VENUE_POLICY_DATE::date

)

select
    *,
    case
        when UNIQUE_CHECKINS > VENUE_CAPACITY_ADULTS then 'EXCEEDED'
        when VENUE_CAPACITY_ADULTS is null and UNIQUE_CHECKINS_PER_PARTNER > PARTNER_CAPACITY_ADULTS then 'EXCEEDED'
        else 'WITHIN_LIMIT'
    end as CAPACITY_STATUS
from PRE_FINAL
