DELETE FROM "ntss"."sys_data_set" where sql_cd in (-2100);

INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2100,'WITH ntss_db5_om_key AS (
    SELECT
        ntss_db5_om.ord_no AS ord_no
        , ntss_db5_om_value_json.KEY AS keys
        , ntss_db5_om_value_json.value ::JSON ->> ''value'' AS value
        , ntss_db5_om_value_json.value ::JSON ->> ''value_name_1'' AS value_name_1
        , ntss_db5_om_value_json.value ::JSON ->> ''unit'' AS unit
    FROM
        ord_main ntss_db5_om
        CROSS JOIN LATERAL json_object_keys(ntss_db5_om.rst_cond_info ::JSON) rst_ci_keys_json
        INNER JOIN json_each_text(ntss_db5_om.rst_cond_info ::JSON) ntss_db5_om_value_json
            ON ntss_db5_om_value_json.KEY = rst_ci_keys_json
    WHERE
        ntss_db5_om.rst_cond_info IS NOT NULL
        AND ntss_db5_om.facility_cd = @facilityCd
)
, ntss_db5_mst_m AS (
    SELECT
        ntss_db5_mst_m.*
    FROM
        mst_medicine ntss_db5_mst_m
    WHERE
        ntss_db5_mst_m.is_del = ''0''
        AND ntss_db5_mst_m.is_disp = ''1''
        AND ntss_db5_mst_m.facility_cd = @facilityCd
)
, ntss_db5_om_mst_list AS (
    SELECT
        om.ord_no AS ord_no
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
        , ntss_db5_mst_e.equipment_cd AS equipment_cd_keys
        , ntss_db5_mst_e.up_date AS up_date
				, ntss_db5_om_key.keys
				, ntss_db5_om_key.value AS value
				, ntss_db5_om_key.value_name_1 AS value_name_1
				, ntss_db5_om_key.unit AS unit
    FROM
        ord_main om
				CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::JSON) ind_equip_json
        INNER JOIN ntss_db5_om_key
            ON om.ord_no = ntss_db5_om_key.ord_no
        LEFT JOIN mst_equipment ntss_db5_mst_e
            ON CAST(ind_equip_json ->> ''cd'' AS INTEGER) = ntss_db5_mst_e.equipment_cd
    WHERE
        ntss_db5_mst_e.facility_cd = @facilityCd
        AND ntss_db5_mst_e.is_del = ''0''
    UNION ALL
    SELECT
        om.ord_no AS ord_no
        , ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2
        , ntss_db5_mst_m.medicine_cd AS equipment_cd_keys
        , ntss_db5_mst_m.up_date AS up_date
				, ntss_db5_om_key.keys
				, ntss_db5_om_key.value AS value
				, ntss_db5_om_key.value_name_1 AS value_name_1
				, ntss_db5_om_key.unit AS unit
    FROM
        ord_main om
				CROSS JOIN LATERAL json_array_elements(om.rst_treatment_info ::JSON) rst_treatment_json
        INNER JOIN ntss_db5_om_key
            ON om.ord_no = ntss_db5_om_key.ord_no
        LEFT JOIN mst_medicine ntss_db5_mst_m
            ON CAST(rst_treatment_json ->> ''medicine_cd'' AS INTEGER) = ntss_db5_mst_m.medicine_cd
    WHERE
        ntss_db5_mst_m.facility_cd = @facilityCd
        AND om.is_del = ''0''
),
ntss_db5_om_list AS (
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , ntss_db5_os.treat_date AS dialysisdate    --透析日
    , ntss_db5_om.ord_no AS dialysisno          --透析番号
    , CASE
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''1''
            THEN ''002''                          --治療時間
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''2''
            THEN ''003''                          --VA
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''3''
            THEN ''005''                          --目標体重
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''4''
            THEN ''007''                          --除水量制限
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''5''
            THEN ''008''                          --ダイアライザ
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''6''
            THEN ''009''                          --吸着カラム
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''7''
            THEN ''039''                          --1次膜
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''8''
            THEN ''040''                          --2次膜
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''9''
            THEN ''999''                          --穿刺針(A針)
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''10''
            THEN ''998''                          --穿刺針(V針)
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''11''
            THEN ''997''                          --穿刺針(SN)
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''12''
            THEN ''029''                          --シングルニードル使用
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''13''
            THEN ''996''                          --血液回路
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''14''
            THEN ''010''                          --血流量
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''15''
            THEN ''018''                          --透析液
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''16''
            THEN ''019''                          --透析液流量
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''17''
            THEN ''020''                          --透析液量
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''18''
            THEN ''021''                          --透析液温度
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''19''
            THEN ''022''                          --補液
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''20''
            THEN ''023''                          --補液量
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''21''
            THEN ''024''                          --補液選択
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''22''
            THEN ''030''                          --補液使用数
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''23''
            THEN ''025''                          --補液温度
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''24''
            THEN ''038''                          --補液速度
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''25''
            THEN ''011''                          --抗凝固剤
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''26''
            THEN ''012''                          --抗凝固剤ワンショット量
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''27''
            THEN ''013''                          --抗凝固剤持続速度
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''28''
            THEN ''014''                          --抗凝固剤持続総量
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''29''
            THEN ''015''                          --IP使用選択
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''30''
            THEN ''031''                          --IPスタート
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''31''
            THEN ''016''                          --IPワンショット量
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''32''
            THEN ''017''                          --IP速度
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''33''
            THEN ''037''                          --IP速度最大値
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''34''
            THEN ''032''                          --自動ワンショット
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''35''
            THEN ''033''                          --IP電源自動切り
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''36''
            THEN ''034''                          --IP電源自動切り時間
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''37''
            THEN ''035''                          --IP電源OKモニタ切り
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''38''
            THEN ''036''                          --IP電源OKモニタ切り時間
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''39''
            THEN ''004''                          --DW
        END AS ctlno                            --透析条件項目コード
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
    , CASE
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''1''
            THEN ''透析時間''                     --治療時間
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''2''
            THEN ''VA''                           --VA
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''3''
            THEN ''目標体重''                     --目標体重
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''4''
            THEN ''除水量制限''                   --除水量制限
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''5''
            THEN ''ダイアライザ''                 --ダイアライザ
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''6''
            THEN ''吸着カラム''                   --吸着カラム
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''7''
            THEN ''1次膜''                        --1次膜
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''8''
            THEN ''2次膜''                        --2次膜
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''9''
            THEN ''穿刺針(A針)''                  --穿刺針(A針)
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''10''
            THEN ''穿刺針(V針)''                  --穿刺針(V針)
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''11''
            THEN ''穿刺針(SN)''                   --穿刺針(SN)
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''12''
            THEN ''シングルニードル使用''         --シングルニードル使用
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''13''
            THEN ''血液回路''                     --血液回路
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''14''
            THEN ''血流量''                       --血流量
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''15''
            THEN ''透析液''                       --透析液
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''16''
            THEN ''透析液流量''                   --透析液流量
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''17''
            THEN ''透析液量''                     --透析液量
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''18''
            THEN ''透析液温度''                   --透析液温度
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''19''
            THEN ''補液''                         --補液
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''20''
            THEN ''補液量''                       --補液量
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''21''
            THEN ''補液選択''                     --補液選択
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''22''
            THEN ''補液使用数''                   --補液使用数
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''23''
            THEN ''補液温度''                     --補液温度
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''24''
            THEN ''補液速度''                     --補液速度
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''25''
            THEN ''抗凝固剤''                     --抗凝固剤
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''26''
            THEN ''抗凝固剤ワンショット量''       --抗凝固剤ワンショット量
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''27''
            THEN ''抗凝固剤持続速度''             --抗凝固剤持続速度
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''28''
            THEN ''抗凝固剤持続総量''             --抗凝固剤持続総量
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''29''
            THEN ''IP使用選択''                   --IP使用選択
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''30''
            THEN ''IPスタート''                   --IPスタート
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''31''
            THEN ''IPワンショット量''             --IPワンショット量
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''32''
            THEN ''IP速度''                       --IP速度
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''33''
            THEN ''IP速度最大値''                 --IP速度最大値
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''34''
            THEN ''自動ワンショット''             --自動ワンショット
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''35''
            THEN ''IP電源自動切り''               --IP電源自動切り
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''36''
            THEN ''IP電源自動切り時間''           --IP電源自動切り時間
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''37''
            THEN ''IP電源OKモニタ切り''           --IP電源OKモニタ切り
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''38''
            THEN ''IP電源OKモニタ切り時間''       --IP電源OKモニタ切り時間
        WHEN CAST(ntss_db5_om_mst_list.keys AS CHAR (10)) = ''39''
            THEN ''DW''                           --DW
        END AS dialysisitemname                 --透析条件項目名
    , ntss_db5_om_mst_list.value AS value            --設定値
    , ntss_db5_om_mst_list.value_name_1 AS valuename --設定値
    , ntss_db5_om_mst_list.unit AS unit              --単位
    , SUBSTR(ntss_db5_om_mst_list.in_hospital_cd_2, 0, 20) AS valuecd2 --院内コード2
FROM
    ord_main ntss_db5_om
    LEFT JOIN ord_schedule ntss_db5_os
        ON ntss_db5_om.ord_no = ntss_db5_os.ord_no
        AND ntss_db5_os.facility_cd = @facilityCd
    INNER JOIN ntss_db5_om_mst_list
        ON ntss_db5_om_mst_list.ord_no = ntss_db5_om.ord_no
WHERE
    ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.facility_cd = @facilityCd
    AND (
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
                    ntss_db5_om_mst_list.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
            )
            ELSE ntss_db5_os.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9) END
    )
    AND ntss_db5_om.pat_id IS NOT NULL
		)
		SELECT
		*
	FROM
		ntss_db5_om_list
WHERE
	ctlno IS NOT NULL;',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);
