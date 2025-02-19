SELECT
    date(event_timestamp_ltz) AS usage_date,
    fk_venue_id,
    COUNT(DISTINCT fk_user_id) AS unique_checkins_count,
    COUNT(fk_user_id) AS total_checkins_count

FROM {{ ref('stage_venue_register') }}
    WHERE event_name = 'ENTER'
GROUP BY 1, 2
