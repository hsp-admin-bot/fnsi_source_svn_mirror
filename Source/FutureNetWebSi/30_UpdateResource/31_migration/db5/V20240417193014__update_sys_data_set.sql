DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2140,-2508,-2051)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2140, 'WITH ntss_db5_om_temp AS (
  SELECT
    ntss_db5_om.ord_no,
    ntss_db5_om.pat_id,
    CAST(ntss_db5_om.treat_date as DATE) as treat_date,
    ROW_NUMBER() OVER (
      PARTITION BY ntss_db5_om.ord_no
      ORDER BY
        CAST(ntss_db5_om_rmi_json ->> ''no'' AS int) ASC
    ) AS ctlno,
    ntss_db5_om.up_date,
    ntss_db5_om_rmi_json ->> ''cd'' AS cd,
    ntss_db5_om_rmi_json ->> ''medicine_type'' AS medicine_type,
    ntss_db5_om_rmi_json ->> ''name'' AS medicinename,
    --薬剤名
    ntss_db5_om_rmi_json ->> ''class_name'' AS mediclassname,
    --薬剤分類名
    ntss_db5_om_rmi_json ->> ''amount'' AS amount,
    --数量
    ntss_db5_om_rmi_json ->> ''unit'' AS unit,
    --単位
    ntss_db5_om_rmi_json ->> ''effect_flg'' AS effectflg,
    --実施フラグ
    CASE
      WHEN POSITION(
        ''T'' IN
          ntss_db5_om_rmi_json ->> ''effect_date''
      ) != 0 THEN to_char(
        to_timestamp(
          ntss_db5_om_rmi_json ->> ''effect_date'',
          ''YYYY-MM-DDThh24:mi:ss''
        ),
        ''YYYY-MM-DD hh24:mi:ss''
      )
      ELSE ''''
    END AS effectdate,
    --実施日時
    ntss_db5_om_rmi_json ->> ''timing_name'' AS timingname,
    --投与時間帯名
    ntss_db5_om_rmi_json ->> ''procedure_cd'' AS procedure_cd,
    ntss_db5_om_rmi_json ->> ''procedure_name'' AS procedurename,
    --手技名
    ntss_db5_om_rmi_json ->> ''effect_user_id'' AS userid,
    CONCAT(
      CAST(
        ntss_db5_om_rmi_json ->> ''effect_user_last_name'' AS text
      )
      , ''　''
      , CAST(
        ntss_db5_om_rmi_json ->> ''effect_user_first_name'' AS text
      )
    ) AS staffname,
    --実施者名
    ntss_db5_om_rmi_json ->> ''comment'' AS comments --コメント
  FROM
    ord_main ntss_db5_om
    CROSS JOIN LATERAL json_array_elements(ntss_db5_om.rst_medi_info :: json) ntss_db5_om_rmi_json
  WHERE
    ntss_db5_om.facility_cd = @facilityCd
    AND ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.pat_id IS NOT NULL
    AND @fromDate <= ntss_db5_om.treat_date AND ntss_db5_om.treat_date < @toDate
),
ntss_db5_mst_m AS (
  SELECT
    medicine_cd,
    in_hospital_cd_1 AS medicinecd1,
    in_hospital_cd_2 AS medicinecd2,
    up_date
  FROM
    mst_medicine
  WHERE
    facility_cd = @facilityCd
),
ntss_db5_mst_m_mix AS (
  SELECT
    medicine_mix_cd,
    in_hospital_cd_1 AS medicinecd1,
    in_hospital_cd_2 AS medicinecd2,
    up_date
  FROM
    mst_medicine_mix
  WHERE
    facility_cd = @facilityCd
),
ntss_db5_mst_p AS (
  SELECT
    procedure_cd,
    CAST(in_hosp_a_startdate AS date) AS in_hosp_a_startdate,
    in_hospital_cd_a1,
    in_hospital_cd_a2,
    CAST(in_hosp_b_startdate AS date) AS in_hosp_b_startdate,
    in_hospital_cd_b1,
    in_hospital_cd_b2,
    up_date
  FROM
    mst_procedure
  WHERE
    facility_cd = @facilityCd
)
SELECT
  '''' AS hosppatid,
  --患者ID
  ntss_db5_om_temp.pat_id AS patid,
  to_char(ntss_db5_om_temp.treat_date,''YYYYMMDD'') AS dialysisdate,
  --透析日
  ntss_db5_om_temp.ord_no AS dialysisno,
  --透析番号
  ntss_db5_om_temp.ctlno AS ctlno,
  --項目番号
  to_char(
    ntss_db5_om_temp.up_date,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS update,
  --更新日時
  CASE
    WHEN ntss_db5_om_temp.medicine_type = ''1'' THEN ntss_db5_mst_m.medicinecd1
    WHEN ntss_db5_om_temp.medicine_type = ''2'' THEN ntss_db5_mst_m_mix.medicinecd1
    ELSE NULL
  END AS medicinecd,
  --薬剤コード(院内コード1)
  CASE
    WHEN ntss_db5_om_temp.medicine_type = ''1'' THEN ntss_db5_mst_m.medicinecd2
    WHEN ntss_db5_om_temp.medicine_type = ''2'' THEN ntss_db5_mst_m_mix.medicinecd2
    ELSE NULL
  END AS medicinecd2,
  --薬剤コード(院内コード2)
  ntss_db5_om_temp.medicinename AS medicinename,
  --薬剤名
  CASE
    WHEN ntss_db5_om_temp.medicine_type = ''2'' THEN ntss_db5_om_temp.medicinename
    ELSE NULL
    END AS medgeneralname,
  --一般名
  ntss_db5_om_temp.mediclassname AS mediclassname,
  --薬剤分類名
  ntss_db5_om_temp.amount AS amount,
  --数量
  ntss_db5_om_temp.unit AS unit,
  --単位
  ntss_db5_om_temp.effectflg AS effectflg,
  --実施フラグ
  ntss_db5_om_temp.effectdate AS effectdate,
  --実施日時
  ntss_db5_om_temp.timingname AS timingname,
  --投与時間帯名
  CASE
    WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_a_startdate
    AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_b_startdate THEN CASE
      WHEN ntss_db5_mst_p.in_hosp_a_startdate >= ntss_db5_mst_p.in_hosp_b_startdate THEN ntss_db5_mst_p.in_hospital_cd_a1
      WHEN ntss_db5_mst_p.in_hosp_a_startdate < ntss_db5_mst_p.in_hosp_b_startdate THEN ntss_db5_mst_p.in_hospital_cd_b1
      END
    WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_a_startdate
    AND (
      ntss_db5_om_temp.treat_date < ntss_db5_mst_p.in_hosp_b_startdate
      OR ntss_db5_mst_p.in_hosp_b_startdate IS NULL
    ) THEN ntss_db5_mst_p.in_hospital_cd_a1
    WHEN (
      ntss_db5_om_temp.treat_date < ntss_db5_mst_p.in_hosp_a_startdate
      OR ntss_db5_mst_p.in_hosp_a_startdate IS NULL
    )
    AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_b_startdate THEN ntss_db5_mst_p.in_hospital_cd_b1
    ELSE NULL
  END AS procedurecd,
  --手技コード(院内コード1)
  CASE
    WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_a_startdate
    AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_b_startdate THEN CASE
      WHEN ntss_db5_mst_p.in_hosp_a_startdate >= ntss_db5_mst_p.in_hosp_b_startdate THEN ntss_db5_mst_p.in_hospital_cd_a2
      WHEN ntss_db5_mst_p.in_hosp_a_startdate < ntss_db5_mst_p.in_hosp_b_startdate THEN ntss_db5_mst_p.in_hospital_cd_b2
      END
    WHEN ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_a_startdate
    AND (
      ntss_db5_om_temp.treat_date < ntss_db5_mst_p.in_hosp_b_startdate
      OR ntss_db5_mst_p.in_hosp_b_startdate IS NULL
    ) THEN ntss_db5_mst_p.in_hospital_cd_a2
    WHEN (
      ntss_db5_om_temp.treat_date < ntss_db5_mst_p.in_hosp_a_startdate
      OR ntss_db5_mst_p.in_hosp_a_startdate IS NULL
    )
    AND ntss_db5_om_temp.treat_date >= ntss_db5_mst_p.in_hosp_b_startdate THEN ntss_db5_mst_p.in_hospital_cd_b2
    ELSE NULL
  END AS procedurecd2,
  --手技コード(院内コード2)
  ntss_db5_om_temp.procedurename AS procedurename,
  --手技名
  '''' AS staffcd,
  ntss_db5_om_temp.userid AS userid,
  ntss_db5_om_temp.staffname AS staffname,
  --実施者名
  ntss_db5_om_temp.comments AS comments --コメント
FROM
  ntss_db5_om_temp
  LEFT JOIN ntss_db5_mst_m ON ntss_db5_mst_m.medicine_cd ::text = ntss_db5_om_temp.cd
  LEFT JOIN ntss_db5_mst_m_mix ON ntss_db5_mst_m_mix.medicine_mix_cd ::text = ntss_db5_om_temp.cd
  LEFT JOIN ntss_db5_mst_p ON ntss_db5_mst_p.procedure_cd ::text = ntss_db5_om_temp.procedure_cd;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2508, 'SELECT
	CAST(user_id AS varchar) AS userid
	,disp_user_id AS staffcd
FROM
	mst_user_authentication 
WHERE facility_cd = @facilityCd;
', 1, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["userid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);



INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2051, 'SELECT
	hosp_pat_id AS hosppatid,
	pat_id AS patid
FROM
	pat_personal_main 
WHERE facility_cd = @facilityCd;', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
