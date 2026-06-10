DELETE FROM "ntss"."sys_data_set" where sql_cd in (-2260);

INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2260,'SELECT
	'''' AS hosppatid,
	pu.pat_id AS patid,
	ROW_NUMBER ( ) OVER ( ORDER BY io ->> ''disp_order'', io ->> ''ctl_no'' ) AS ctlno,
	io ->> ''period_start'' AS regdate,
	io ->> ''move_in_out'' AS inoutcd,
CASE
		WHEN io ->> ''move_in_out'' = ''2'' THEN
		io ->> ''from_facility''
		WHEN io ->> ''move_in_out'' = ''3'' THEN
		io ->> ''to_facility'' ELSE''''
	END AS facilityname,
CASE
		WHEN io ->> ''move_in_out'' = ''2'' THEN
		io ->> ''from_doctor''
		WHEN io ->> ''move_in_out'' = ''3'' THEN
		io ->> ''to_doctor'' ELSE''''
	END AS drname,
	io ->> ''comment'' AS memo,
	io ->> ''reason'' AS codename
FROM
	pat_unique pu,
	jsonb_array_elements ( pu.in_out_visit_history_info ) AS io
WHERE
	pu.is_del = ''0''
	AND pu.facility_cd = @facilityCd
	AND pu.up_date BETWEEN to_timestamp( @fromDate, ''YYYYMMDDHH24MISS'' )
	AND to_timestamp( @toDate, ''YYYYMMDDHH24MISS'' )
    AND io ->> ''period_start'' IS NOT NULL;',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);

DELETE FROM "ntss"."sys_data_set" where sql_cd in (-2120);

INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2120,'SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , ntss_db5_os.treat_date AS dialysisdate    --透析日
    , ntss_db5_om.ord_no AS dialysisno          --透析番号
    , row_number() over (ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
    , ntss_db5_mst_e.in_hospital_cd_1 AS equipcd1 --医療材料コード(院内コード1)
    , ntss_db5_mst_e.in_hospital_cd_2 AS equipcd2 --医療材料コード(院内コード2)
    , ntss_db5_mst_e.equipment_name AS equipname --医療材料名
    , ntss_db5_mst_c.class_name AS equipclassname --医療材料分類名
    , ntss_db5_om_rqi_json ->> ''needle_type'' AS punctureclass --穿刺針区分
    , ntss_db5_om_rqi_json ->> ''amount'' AS amount --数量
    , ntss_db5_mst_e.unit AS unit               --単位
    , ntss_db5_om_rqi_json ->> ''comment'' AS comments --コメント
FROM
    ord_main ntss_db5_om
    CROSS JOIN LATERAL json_array_elements(ntss_db5_om.rst_equip_info ::json) ntss_db5_om_rqi_json
    LEFT JOIN ord_schedule ntss_db5_os
        ON ntss_db5_om.ord_no = ntss_db5_os.ord_no
    LEFT JOIN mst_equipment ntss_db5_mst_e
        ON cast(ntss_db5_mst_e.equipment_cd as char (10)) = cast(ntss_db5_om_rqi_json ->> ''cd'' as char (10))
    LEFT JOIN mst_equipment_class ntss_db5_mst_c
        ON ntss_db5_mst_c.class_cd = ntss_db5_mst_e.class_cd
WHERE
    ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.facility_cd = @facilityCd
    AND (
        CASE
            WHEN @syncMode = ''update''
                THEN (
                (
                    ntss_db5_om.up_date BETWEEN TO_TIMESTAMP(@fromDate, ''YYYYMMDDHH24MISS'') AND TO_TIMESTAMP(@toDate, ''YYYYMMDDHH24MISS'')
                )
                OR (
                    ntss_db5_os.up_date BETWEEN TO_TIMESTAMP(@fromDate, ''YYYYMMDDHH24MISS'') AND TO_TIMESTAMP(@toDate, ''YYYYMMDDHH24MISS'')
                )
								OR (
                    ntss_db5_mst_e.up_date BETWEEN TO_TIMESTAMP(@fromDate, ''YYYYMMDDHH24MISS'') AND TO_TIMESTAMP(@toDate, ''YYYYMMDDHH24MISS'')
                )
								OR (
                    ntss_db5_mst_c.up_date BETWEEN TO_TIMESTAMP(@fromDate, ''YYYYMMDDHH24MISS'') AND TO_TIMESTAMP(@toDate, ''YYYYMMDDHH24MISS'')
                )
            )
            ELSE ntss_db5_om.up_date BETWEEN TO_TIMESTAMP(@fromDate, ''YYYYMMDDHH24MISS'') AND TO_TIMESTAMP(@toDate, ''YYYYMMDDHH24MISS'')
            END
    )
    AND ntss_db5_om.pat_id IS NOT NULL
    AND ntss_db5_os.treat_date IS NOT NULL;
',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);

DELETE FROM "ntss"."sys_data_set" where sql_cd in (-2130);

INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2130,'with ntss_db5_om_temp AS (
    SELECT
        ntss_db5_om.ord_no
        , ntss_db5_om_rmi_json ->> ''cd'' ::char (10) AS cd
        , ntss_db5_om_rmi_json ->> ''procedure_cd''  AS procedure_cd
        , ntss_db5_om_rmi_json ->> ''amount'' AS amount --数量
        , ntss_db5_om_rmi_json ->> ''effect_flg'' AS effectflg --実施フラグ
        , CASE
            WHEN POSITION(
                ''T'' IN cast(
                    ntss_db5_om_rmi_json ->> ''effect_date'' AS char (20)
                )
            ) != 0
                THEN to_char(
                to_timestamp(
                    ntss_db5_om_rmi_json ->> ''effect_date''
                    , ''YYYY-MM-DDThh24:mi:ss''
                )
                , ''YYYY-MM-DD hh24:mi:ss''
            )
            ELSE ''''
            END AS effectdate                   --実施日時
        , ntss_db5_om_rmi_json ->> ''timing_name'' AS timingname --投与時間帯名
        , ntss_db5_om_rmi_json ->> ''procedure_name'' AS procedurename --手技名
				, '''' AS indicatorcd                     --実施者コード
        , ntss_db5_om_rmi_json ->> ''effect_user_id'' AS userid
        , cast(
            ntss_db5_om_rmi_json ->> ''effect_user_last_name'' AS char (20)
        ) || cast(
            ntss_db5_om_rmi_json ->> ''effect_user_first_name'' AS char (20)
        ) AS staffname                          --実施者名
        , ntss_db5_om_rmi_json ->> ''comment'' AS comments --コメント
    FROM
        ord_main ntss_db5_om
        CROSS JOIN LATERAL json_array_elements(ntss_db5_om.rst_medi_info ::json) ntss_db5_om_rmi_json
    WHERE
        ntss_db5_om.facility_cd = @facilityCd
        AND ntss_db5_om.is_del = ''0''
        AND ntss_db5_om.pat_id IS NOT NULL
)
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , ntss_db5_os.treat_date AS dialysisdate    --透析日
    , ntss_db5_om.ord_no AS dialysisno          --透析番号
    , row_number() over (ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
    , ntss_db5_mst_m.in_hospital_cd_1 AS medicinecd1 --薬剤コード(院内コード1)
    , ntss_db5_mst_m.in_hospital_cd_2 AS medicinecd2 --薬剤コード(院内コード2)
    , ntss_db5_mst_m.medicine_name AS medicinename --薬剤名
    , ntss_db5_mst_c.class_name AS medicineclassname --薬剤分類名
    , ntss_db5_om_temp.amount AS amount         --数量
    , ntss_db5_mst_m.unit AS unit               --単位
    , ntss_db5_om_temp.effectflg AS effectflg   --実施フラグ
    , ntss_db5_om_temp.effectdate               --実施日時
    , ntss_db5_om_temp.timingname AS timingname --投与時間帯名
    , ntss_db5_mst_p.in_hospital_cd_a1 AS procedurecd1 --手技コード(院内コード1)
    , ntss_db5_mst_p.in_hospital_cd_a2 AS procedurecd2 --手技コード(院内コード2)
    , ntss_db5_mst_p.pricedure_name AS procedurename --手技名
    , '''' AS indicatorcd                       --実施者コード
    , ntss_db5_om_temp.userid AS userid
    , ntss_db5_om_temp.staffname AS staffname   --実施者名
    , ntss_db5_om_temp.comments AS comments     --コメント
FROM
    ord_main ntss_db5_om
    INNER JOIN ntss_db5_om_temp
        ON ntss_db5_om_temp.ord_no = ntss_db5_om.ord_no
    LEFT JOIN ord_schedule ntss_db5_os
        ON ntss_db5_om.ord_no = ntss_db5_os.ord_no
    LEFT JOIN mst_medicine ntss_db5_mst_m
        ON ntss_db5_mst_m.medicine_cd ::char (10) = ntss_db5_om_temp.cd
    LEFT JOIN mst_medicine_class ntss_db5_mst_c
        ON ntss_db5_mst_c.class_cd = ntss_db5_mst_m.class_cd
    LEFT JOIN mst_procedure ntss_db5_mst_p
        ON ntss_db5_mst_p.procedure_cd ::char (10) = ntss_db5_om_temp.procedure_cd
WHERE
    (
        CASE
            WHEN @syncMode = ''update''
                THEN (
                (
                    ntss_db5_om.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
                OR (
                    ntss_db5_os.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
                OR (
                    ntss_db5_mst_m.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
                OR (
                    ntss_db5_mst_c.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
                OR (
                    ntss_db5_mst_p.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
            )
            ELSE ntss_db5_os.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9)
            END
    )
    AND ntss_db5_om.pat_id IS NOT NULL;

',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);
