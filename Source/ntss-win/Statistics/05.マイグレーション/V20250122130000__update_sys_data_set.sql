delete from sys_data_set where sql_cd in (-1000026);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1000026, '-- 【SQL_CD=-1000026】
WITH expanded_pat AS (
    SELECT
        pat.pat_id,
        pat.facility_cd,
        jsonb_array_elements(pat.infect_info) AS infect_record
    FROM
        pat_main pat
    WHERE
        pat.facility_cd = @facilityCd
),
filtered_pat AS (
    SELECT
        pat_id,
        facility_cd,
        (infect_record->>''infection_cd'')::NUMERIC AS infection_cd,
        infect_record->>''infect'' AS infect,
        infect_record->>''exam_date'' AS exam_date,
        infect_record->>''up_date'' AS up_date,
        ROW_NUMBER() OVER (
            PARTITION BY pat_id, infect_record->>''infection_cd''
            ORDER BY infect_record->>''exam_date'' DESC, infect_record->>''up_date'' DESC
        ) AS rn
    FROM
        expanded_pat
    WHERE
        infect_record->>''infect'' IS NOT NULL
),
expanded_mst AS (
    SELECT
        mst.infection_cd,
        mst.infection_name,
        mst.facility_cd,
        mst.up_date,
        ROW_NUMBER() OVER (
            PARTITION BY mst.infection_cd
            ORDER BY mst.up_date DESC
        ) AS rn
    FROM
        mst_infection mst
    WHERE
        mst.facility_cd = @facilityCd
    AND
        mst.is_disp=''1''
    AND
        mst.is_del=''0''
)
SELECT DISTINCT
    pat.infection_cd AS COL_FNW_CODE,
    mst.infection_name AS COL_FNW_NAME
FROM
    filtered_pat pat
    JOIN expanded_mst mst ON pat.infection_cd = mst.infection_cd
WHERE
    pat.rn = 1
    AND mst.rn = 1
ORDER BY
    COL_FNW_CODE',2,'[{}]','0','{"applications": [4]}',NULL,'統計調査（感染症）',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,NULL);

