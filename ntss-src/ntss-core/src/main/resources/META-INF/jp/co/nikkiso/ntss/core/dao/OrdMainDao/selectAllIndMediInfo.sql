SELECT
    row_to_json ( subJson )
FROM
    (SELECT
         MIN(treat_date) AS mindate,
         MAX(treat_date) AS maxdate,
         STRING_AGG(DISTINCT date_part::text, ',' ORDER BY date_part::text) AS dow
     FROM (
              SELECT
                  treat_date,
                  date_part('dow', to_timestamp(treat_date, 'YYYYMMDD')) AS date_part
              FROM ord_main
              WHERE
                      facility_cd = /*facilityCd*/'000000'
                AND pat_id = /*patId*/1
                AND (ind_medi_info @> concat('[{"no":', /*mediNo*/'0', '}]')::JSONB
        OR rst_medi_info @> concat('[{"no":', /*mediNo*/'0', '}]')::JSONB)
          ) AS t1) AS subJson
WHERE
    subJson.maxDate IS NOT NULL;
