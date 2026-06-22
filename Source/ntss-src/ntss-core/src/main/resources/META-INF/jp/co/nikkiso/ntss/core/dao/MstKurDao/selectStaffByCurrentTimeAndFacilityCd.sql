WITH current_time_info AS (
    SELECT
        CASE EXTRACT(DOW FROM CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Tokyo')
            WHEN 0 THEN 'Sun'
            WHEN 1 THEN 'Mon'
            WHEN 2 THEN 'Tues'
            WHEN 3 THEN 'Wednes'
            WHEN 4 THEN 'Thurs'
            WHEN 5 THEN 'Fri'
            WHEN 6 THEN 'Satur'
            END AS weekday,
        (CURRENT_TIMESTAMP AT TIME ZONE 'Asia/Tokyo')::time AS currentTime
),
     current_kur AS (
         SELECT kur_cd
         FROM mst_kur
         WHERE facility_cd = /*facilityCd */'0' and is_del = '0' and
             TO_TIMESTAMP(kur_start_time, 'HH24MISS')::time <= (SELECT currentTime FROM current_time_info)
    AND TO_TIMESTAMP(kur_end_time, 'HH24MISS')::time >= (SELECT currentTime FROM current_time_info)
ORDER BY kur_cd
    LIMIT 1
    ),
    default_user_no AS (
SELECT
    0 AS order_no,
    (CASE WHEN A.facility_setting_no IS NULL THEN B.default_value ELSE A.value END) AS staff_cd
FROM
    ntss.mst_facility_setting A
    RIGHT OUTER JOIN ntss.sys_facility_setting B
ON A.facility_setting_no = B.facility_setting_no
    AND A.facility_cd = /*facilityCd */'0'
WHERE
    B.facility_setting_no = '1025'
UNION
SELECT
    1 AS order_no,
    '' AS staff_cd
ORDER BY
    order_no ASC
    LIMIT 1
    )
SELECT
    COALESCE(
            NULLIF(
                    (SELECT (json_array_elements((mst.mst_user_authentication->>'data')::json)->>(SELECT weekday FROM current_time_info))::json->>'user_id'
       FROM mst_kur mst
       WHERE mst.kur_cd = (SELECT kur_cd FROM current_kur)),
      ''
    ),
            default_user_no.staff_cd
        ) AS staff_cd
FROM default_user_no;
