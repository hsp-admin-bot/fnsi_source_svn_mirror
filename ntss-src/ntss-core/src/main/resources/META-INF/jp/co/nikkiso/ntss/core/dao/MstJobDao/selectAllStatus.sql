SELECT
    job.job_cd   AS "classCd",
    job.job_name AS "className",
    job.is_doctor AS "isDoctor"
FROM
    mst_job job
    INNER JOIN (
        SELECT
            ms.code,
            ROW_NUMBER() OVER () AS index
        FROM
            mst_selector
            CROSS JOIN LATERAL jsonb_to_recordset(order_settings -> 'items') AS ms
            (
                code TEXT,
                name TEXT
            )
        WHERE
            facility_cd = /* params.get("facilityCd") */'000000'
            AND master_physical_name = 'mst_job'
    ) selector
        ON job.facility_cd = /* params.get("facilityCd") */'000000'
        AND job.job_cd::text = selector.code
WHERE
    job.facility_cd = /* params.get("facilityCd") */'000000'
    AND job.is_disp = '1'
    AND job.is_del = '0'
ORDER BY
    selector.index;
