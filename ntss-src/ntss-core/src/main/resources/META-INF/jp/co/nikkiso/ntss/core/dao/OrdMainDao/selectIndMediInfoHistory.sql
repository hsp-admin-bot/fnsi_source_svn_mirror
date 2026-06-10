SELECT
    row_to_json ( subJson )
FROM
    (
    SELECT
        sub1.minDate,
        sub1.maxDate,
        array_to_string(
            ARRAY (
            SELECT DISTINCT
                date_part( 'dow', to_timestamp( sub2.treat_date, 'YYYYMMDD' ) )
            FROM
                ord_main AS sub2
            WHERE
                facility_cd = /*facilityCd*/'000000'
                AND sub2.pat_id = /*patId*/1
                AND sub2.ind_medi_info @> concat('[{"no":', /*mediNo*/'0', '}]') :: jsonb
            ),
            ','
        ) AS dow
    FROM
        (
        SELECT MIN
            ( treat_date ) AS minDate,
            MAX ( treat_date ) AS maxDate
        FROM
            ord_main
        WHERE
            facility_cd = /*facilityCd*/'000000'
            AND pat_id = /*patId*/1
            AND ind_medi_info @> concat('[{"no":', /*mediNo*/'0', '}]') :: jsonb
        ) AS sub1
        UNION
        SELECT
        sub1.minDate,
        sub1.maxDate,
        array_to_string(
            ARRAY (
            SELECT DISTINCT
                date_part( 'dow', to_timestamp( sub2.treat_date, 'YYYYMMDD' ) )
            FROM
                ord_main AS sub2
            WHERE
                facility_cd = /*facilityCd*/'000000'
                AND sub2.pat_id = /*patId*/1
                AND sub2.ind_medi_info @> concat('[{"no":', /*mediNo*/'0', '}]') :: jsonb
            ),
            ','
        ) AS dow
    FROM
        (
        SELECT MIN
            ( treat_date ) AS minDate,
            MAX ( treat_date ) AS maxDate
        FROM
            ord_main
        WHERE
            facility_cd = /*facilityCd*/'000000'
            AND pat_id = /*patId*/1
            AND ind_medi_info @> concat('[{"no":', /*mediNo*/'0', '}]') :: jsonb
        ) AS sub1
-- mod 7269 投与薬剤補足情報の吹き出し表示ができない 張 end
        union
        SELECT
        sub1.minDate,
        sub1.maxDate,
        array_to_string(
            ARRAY (
            SELECT DISTINCT
                date_part( 'dow', to_timestamp( sub2.treat_date, 'YYYYMMDD' ) )
            FROM
                ord_main AS sub2
            WHERE
                facility_cd = /*facilityCd*/'000000'
                AND sub2.pat_id = /*patId*/1
                AND sub2.ind_medi_info @> concat('[{"no":', /*mediNo*/'0', '}]') :: jsonb
            ),
            ','
        ) AS dow
    FROM
        (
        SELECT MIN
            ( treat_date ) AS minDate,
            MAX ( treat_date ) AS maxDate
        FROM
            ord_main
        WHERE
            facility_cd = /*facilityCd*/'000000'
            AND pat_id = /*patId*/1
            AND ind_medi_info @> concat('[{"no":', /*mediNo*/'0', '}]') :: jsonb
        ) AS sub1
        UNION
        SELECT
        sub1.minDate,
        sub1.maxDate,
        array_to_string(
            ARRAY (
            SELECT DISTINCT
                date_part( 'dow', to_timestamp( sub2.treat_date, 'YYYYMMDD' ) )
            FROM
                ord_main AS sub2
            WHERE
                facility_cd = /*facilityCd*/'000000'
                AND sub2.pat_id = /*patId*/1
                AND sub2.rst_medi_info @> concat('[{"no":', /*mediNo*/'0', '}]') :: jsonb
            ),
            ','
        ) AS dow
    FROM
        (
        SELECT MIN
            ( treat_date ) AS minDate,
            MAX ( treat_date ) AS maxDate
        FROM
            ord_main
        WHERE
            facility_cd = /*facilityCd*/'000000'
            AND pat_id = /*patId*/1
            AND rst_medi_info @> concat('[{"no":', /*mediNo*/'0', '}]') :: jsonb
        ) AS sub1
    ) AS subJson where subJson.maxDate is not null LIMIT 1;
--mod 7269 投与薬剤補足情報の吹き出し表示ができない 張 end
    --投与薬剤の補助画面を追加
