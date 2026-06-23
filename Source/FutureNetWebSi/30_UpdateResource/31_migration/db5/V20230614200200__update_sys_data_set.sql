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
    FROM
        ord_main om
        INNER JOIN ntss_db5_om_key
            ON om.ord_no = ntss_db5_om_key.ord_no
        LEFT JOIN mst_equipment ntss_db5_mst_e
            ON CAST(ntss_db5_om_key.value AS INTEGER) = ntss_db5_mst_e.equipment_cd
    WHERE
        ntss_db5_mst_e.facility_cd = @facilityCd
        AND ntss_db5_mst_e.is_del = ''0''
    UNION ALL
    SELECT
        om.ord_no AS ord_no
        , ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2
        , ntss_db5_mst_m.medicine_cd AS equipment_cd_keys
        , ntss_db5_mst_m.up_date AS up_date
    FROM
        ord_main om
        INNER JOIN ntss_db5_om_key
            ON om.ord_no = ntss_db5_om_key.ord_no
        LEFT JOIN mst_medicine ntss_db5_mst_m
            ON CAST(ntss_db5_om_key.value AS INTEGER) = ntss_db5_mst_m.medicine_cd
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
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''1''
            THEN ''002''                          --治療時間
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''2''
            THEN ''003''                          --VA
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''3''
            THEN ''005''                          --目標体重
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''4''
            THEN ''007''                          --除水量制限
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''5''
            THEN ''008''                          --ダイアライザ
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''6''
            THEN ''009''                          --吸着カラム
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''7''
            THEN ''039''                          --1次膜
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''8''
            THEN ''040''                          --2次膜
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''9''
            THEN ''999''                          --穿刺針(A針)
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''10''
            THEN ''998''                          --穿刺針(V針)
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''11''
            THEN ''997''                          --穿刺針(SN)
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''12''
            THEN ''029''                          --シングルニードル使用
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''13''
            THEN ''996''                          --血液回路
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''14''
            THEN ''010''                          --血流量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''15''
            THEN ''018''                          --透析液
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''16''
            THEN ''019''                          --透析液流量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''17''
            THEN ''020''                          --透析液量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''18''
            THEN ''021''                          --透析液温度
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''19''
            THEN ''022''                          --補液
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''20''
            THEN ''023''                          --補液量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''21''
            THEN ''024''                          --補液選択
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''22''
            THEN ''030''                          --補液使用数
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''23''
            THEN ''025''                          --補液温度
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''24''
            THEN ''038''                          --補液速度
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''25''
            THEN ''011''                          --抗凝固剤
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''26''
            THEN ''012''                          --抗凝固剤ワンショット量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''27''
            THEN ''013''                          --抗凝固剤持続速度
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''28''
            THEN ''014''                          --抗凝固剤持続総量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''29''
            THEN ''015''                          --IP使用選択
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''30''
            THEN ''031''                          --IPスタート
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''31''
            THEN ''016''                          --IPワンショット量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''32''
            THEN ''017''                          --IP速度
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''33''
            THEN ''037''                          --IP速度最大値
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''34''
            THEN ''032''                          --自動ワンショット
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''35''
            THEN ''033''                          --IP電源自動切り
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''36''
            THEN ''034''                          --IP電源自動切り時間
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''37''
            THEN ''035''                          --IP電源OKモニタ切り
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''38''
            THEN ''036''                          --IP電源OKモニタ切り時間
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''39''
            THEN ''004''                          --DW
        END AS ctlno                            --透析条件項目コード
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
    , CASE
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''1''
            THEN ''透析時間''                     --治療時間
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''2''
            THEN ''VA''                           --VA
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''3''
            THEN ''目標体重''                     --目標体重
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''4''
            THEN ''除水量制限''                   --除水量制限
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''5''
            THEN ''ダイアライザ''                 --ダイアライザ
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''6''
            THEN ''吸着カラム''                   --吸着カラム
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''7''
            THEN ''1次膜''                        --1次膜
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''8''
            THEN ''2次膜''                        --2次膜
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''9''
            THEN ''穿刺針(A針)''                  --穿刺針(A針)
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''10''
            THEN ''穿刺針(V針)''                  --穿刺針(V針)
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''11''
            THEN ''穿刺針(SN)''                   --穿刺針(SN)
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''12''
            THEN ''シングルニードル使用''         --シングルニードル使用
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''13''
            THEN ''血液回路''                     --血液回路
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''14''
            THEN ''血流量''                       --血流量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''15''
            THEN ''透析液''                       --透析液
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''16''
            THEN ''透析液流量''                   --透析液流量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''17''
            THEN ''透析液量''                     --透析液量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''18''
            THEN ''透析液温度''                   --透析液温度
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''19''
            THEN ''補液''                         --補液
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''20''
            THEN ''補液量''                       --補液量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''21''
            THEN ''補液選択''                     --補液選択
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''22''
            THEN ''補液使用数''                   --補液使用数
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''23''
            THEN ''補液温度''                     --補液温度
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''24''
            THEN ''補液速度''                     --補液速度
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''25''
            THEN ''抗凝固剤''                     --抗凝固剤
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''26''
            THEN ''抗凝固剤ワンショット量''       --抗凝固剤ワンショット量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''27''
            THEN ''抗凝固剤持続速度''             --抗凝固剤持続速度
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''28''
            THEN ''抗凝固剤持続総量''             --抗凝固剤持続総量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''29''
            THEN ''IP使用選択''                   --IP使用選択
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''30''
            THEN ''IPスタート''                   --IPスタート
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''31''
            THEN ''IPワンショット量''             --IPワンショット量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''32''
            THEN ''IP速度''                       --IP速度
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''33''
            THEN ''IP速度最大値''                 --IP速度最大値
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''34''
            THEN ''自動ワンショット''             --自動ワンショット
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''35''
            THEN ''IP電源自動切り''               --IP電源自動切り
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''36''
            THEN ''IP電源自動切り時間''           --IP電源自動切り時間
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''37''
            THEN ''IP電源OKモニタ切り''           --IP電源OKモニタ切り
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''38''
            THEN ''IP電源OKモニタ切り時間''       --IP電源OKモニタ切り時間
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''39''
            THEN ''DW''                           --DW
        END AS dialysisitemname                 --透析条件項目名
    , ntss_db5_om_key.value AS value            --設定値
    , ntss_db5_om_key.value_name_1 AS valuename --設定値
    , ntss_db5_om_key.unit AS unit              --単位
    , SUBSTR(ntss_db5_om_mst_list.in_hospital_cd_2, 0, 20) AS valuecd2 --院内コード2
FROM
    ord_main ntss_db5_om
    LEFT JOIN ord_schedule ntss_db5_os
        ON ntss_db5_om.ord_no = ntss_db5_os.ord_no
        AND ntss_db5_os.facility_cd = @facilityCd
    INNER JOIN ntss_db5_om_key
        ON ntss_db5_om.ord_no = ntss_db5_om_key.ord_no
    LEFT JOIN ntss_db5_om_mst_list
        ON ntss_db5_om_mst_list.ord_no = ntss_db5_om_key.ord_no
        AND ntss_db5_om_mst_list.equipment_cd_keys = CAST(ntss_db5_om_key.value AS INTEGER)
WHERE
    ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.facility_cd = @facilityCd
    AND ntss_db5_os.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9)
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
            ELSE 1 = 1 END
    )
    AND ntss_db5_om.pat_id IS NOT NULL
		)
		SELECT
		*
	FROM
		ntss_db5_om_list
WHERE
	ctlno IS NOT NULL;',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);

DELETE FROM "ntss"."sys_data_set" where sql_cd in (-2160);

INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2160,'SELECT
    ntss_db6_ppm.hosp_pat_id AS hosppatid --患者ID
    ,ntss_db6_ppm.pat_id AS patid
    ,'''' AS dialysisdate --透析日
    ,'''' AS dialysisno --透析番号
    ,'''' AS ctlno --項目番号
    ,'''' AS updates --更新日時
		,cast(ntss_db5_om_ddci_json1 ->> ''dial_diff_cd'' AS char (4)) AS dialdiffcd
    ,''0'' AS division --レセプトメモ区分
    ,'''' AS codes --コード
    ,'''' AS codeupdate --コード更新日時
    ,''0'' AS addflg --加算有無
    ,'''' AS itemname --項目名称
    ,CASE WHEN ntss_db5_om_ddci_json1 ->> ''is_main'' = ''1''
          THEN ntss_db5_om_ddci_json1 ->> ''dial_diff_cd''
         ELSE null
      END AS dialdiffcd2
    ,'''' AS maindialdiff --主たる透析困難
    ,'''' AS inhospitalcd --院内コード
    ,'''' AS inhospitalcd2 --院内コード２
FROM
    pat_personal_main ntss_db6_ppm
    CROSS JOIN LATERAL json_array_elements(ntss_db6_ppm.dial_diff_com_info ::json) ntss_db5_om_ddci_json1
  WHERE ntss_db6_ppm.is_del = ''0''
    AND ntss_db5_om_ddci_json1 ->> ''dial_diff_cd'' = ''1''
    AND ntss_db6_ppm.dial_diff_com_info IS NOT NULL
    AND ntss_db6_ppm.dial_diff_com_info <> ''[]''
    AND ntss_db6_ppm.facility_cd = @facilityCd
    AND ntss_db6_ppm.up_date BETWEEN to_timestamp( @fromDate, ''YYYYMMDDHH24MISS'' )
    AND to_timestamp(  @toDate, ''YYYYMMDDHH24MISS'' )
    AND ntss_db6_ppm.pat_id IS NOT NULL;',3,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,dialdiffcd,dialdiffcd2"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);

DELETE FROM "ntss"."sys_data_set" where sql_cd in (-2161);

INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2161,'SELECT
    cast(ntss_db5_mdd.dialysis_difficulty_cd AS char (4)) AS dialdiffcd
    , ntss_db5_mdd.in_hospital_cd_1 AS codes    --コード
		, to_char(ntss_db5_mdd.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS codeupdate   --コード更新日時
    , ntss_db5_mdd.dialysis_difficulty_name AS itemname --項目名称
    , ntss_db5_mdd.in_hospital_cd_1 AS inhospitalcd --院内コード
    , ntss_db5_mdd.in_hospital_cd_2 AS inhospitalcd2 --院内コード
FROM
    mst_dialysis_difficulty ntss_db5_mdd
WHERE
    ntss_db5_mdd.is_del = ''0''
    AND ntss_db5_mdd.facility_cd = @facilityCd
    AND ntss_db5_mdd.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
;
',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["dialdiffcd"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);

DELETE FROM "ntss"."sys_data_set" where sql_cd in (-2090);

INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2090,'WITH ntss_db5_mst_b AS (
   SELECT
    om.ord_no AS ord_no
    ,ntss_db5_mst_b.bed_no AS bed_no
    ,ntss_db5_mst_b.bed_name AS bed_name
    ,ntss_db5_mst_b.up_date AS up_date
   FROM ord_main om
   LEFT JOIN mst_bed ntss_db5_mst_b
   ON om.rst_bed_cd = ntss_db5_mst_b.bed_cd
   WHERE ntss_db5_mst_b.facility_cd = @facilityCd
  ),
  ntss_db5_mst_k AS (
   SELECT
    om.ord_no AS ord_no
    ,ntss_db5_mst_k.kur_cd AS kur_cd
    ,ntss_db5_mst_k.up_date AS up_date
   FROM ord_main om
   LEFT JOIN  mst_kur ntss_db5_mst_k
   ON om.rst_kur_cd = ntss_db5_mst_k.kur_cd
   WHERE ntss_db5_mst_k.facility_cd = @facilityCd
  ),
  rst_vital_info_1 AS (
   SELECT
    om.ord_no AS ord_no
    ,om_rvi_json ->> ''bp_max'' AS bp_max
    ,om_rvi_json ->> ''bp_min'' AS bp_min
    ,om_rvi_json ->> ''bp_ave'' AS bp_ave
    ,om_rvi_json ->> ''pulse'' AS pulse
   FROM ord_main om
   CROSS JOIN LATERAL json_array_elements(om.rst_vital_info ::json) om_rvi_json
   WHERE cast(om_rvi_json ->> ''bp_class'' AS char(20)) = ''1''
    AND om.rst_vital_info IS NOT NULL
    AND om.facility_cd = @facilityCd
  ),
  rst_vital_info_2 AS (
   SELECT
    om.ord_no AS ord_no
    ,om_rvi_json ->> ''bp_max'' AS bp_max
    ,om_rvi_json ->> ''bp_min'' AS bp_min
    ,om_rvi_json ->> ''bp_ave'' AS bp_ave
    ,om_rvi_json ->> ''pulse'' AS pulse
   FROM ord_main om
   CROSS JOIN LATERAL json_array_elements(om.rst_vital_info ::json) om_rvi_json
   WHERE cast(om_rvi_json ->> ''bp_class'' AS char(20)) = ''2''
    AND om.rst_vital_info IS NOT NULL
    AND om.facility_cd = @facilityCd
  )
  SELECT
   '''' AS hosppatid --患者ID
   ,ntss_db5_om.pat_id AS patid
   ,'''' AS names --氏名
   ,ntss_db5_os.treat_date AS dialysisdate --透析日
   ,ntss_db5_om.ord_no AS dialysisno --透析番号
   ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
   ,ntss_db5_mst_b.bed_no AS bedno --ベッド番号
   ,ntss_db5_mst_b.bed_name AS bedname --ベッド名
   ,ntss_db5_om.rst_machine_no AS deviceno --装置番号
   ,ntss_db5_om.rst_machine_name AS devicename --装置名
   ,ntss_db5_mst_k.kur_cd AS kurcd --クール
   ,ntss_db5_om.rst_kur_name AS kurname --クール名
   ,to_char(ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS startdate --透析開始日時
   ,to_char(ntss_db5_om.rst_end_date, ''YYYY-MM-DD hh24:mi:ss'') AS enddate --透析終了日時
   ,round(date_part(''epoch'',ntss_db5_om.rst_end_date - ntss_db5_om.rst_start_date)::NUMERIC / 60) AS dialysistime --透析時間
   ,ntss_db5_om.rst_cond_info ::json #>> ''{1,value}'' AS plandialysistime --予定透析時間
   ,ntss_db5_om.rst_dialysis_cnt AS dialysisnum --透析回数
   ,'''' AS lastweight --前回体重
   ,ntss_db5_om.rst_weight_info #>> ''{weight_before}'' AS weightbefore --前体重
   ,ntss_db5_om.rst_weight_info #>> ''{weight_after}'' AS weightafter --後体重
   ,rst_vital_info_1.bp_max AS bpbeforemax --透析前最高血圧
   ,rst_vital_info_1.bp_min AS bpbeforemin --透析前最低血圧
   ,rst_vital_info_1.bp_ave AS bpbeforeave --透析前平均血圧
   ,rst_vital_info_2.bp_max AS bpaftermax --透析後最高血圧
   ,rst_vital_info_2.bp_min AS bpaftermin --透析後最低血圧
   ,rst_vital_info_2.bp_ave AS bpafterave --透析後平均血圧
   ,ntss_db5_om.rst_weight_info #>> ''{water_removal_target}'' AS waterremovaltarget --目標除水量
   ,ntss_db5_om.rst_off_water_info #>> ''{name_1}'' AS revisename1 --除水補正項目１
   ,ntss_db5_om.rst_off_water_info #>> ''{weight_1}'' AS reviseweight1 --除水補正値１
   ,ntss_db5_om.rst_off_water_info #>> ''{name_2}'' AS revisename2 --除水補正項目２
   ,ntss_db5_om.rst_off_water_info #>> ''{weight_2}'' AS reviseweight2 --除水補正値２
   ,ntss_db5_om.rst_off_water_info #>> ''{name_3}'' AS revisename3 --除水補正項目３
   ,ntss_db5_om.rst_off_water_info #>> ''{weight_3}'' AS reviseweight3 --除水補正値３
   ,ntss_db5_om.rst_off_water_info #>> ''{name_4}'' AS revisename4 --除水補正項目４
   ,ntss_db5_om.rst_off_water_info #>> ''{weight_4}'' AS reviseweight4 --除水補正値４
   ,ntss_db5_om.rst_off_water_info #>> ''{name_5}'' AS revisename5 --除水補正項目５
   ,ntss_db5_om.rst_off_water_info #>> ''{weight_5}'' AS reviseweight5 --除水補正値５
   ,rst_vital_info_1.pulse AS pulsebefore --透析前脈拍
   ,rst_vital_info_2.pulse AS pulseafter --透析後脈拍
   ,cast(ntss_db5_om.rst_charge_user_info #>> ''{user_last_name_1}'' AS char(20))
     || cast(ntss_db5_om.rst_charge_user_info #>> ''{user_first_name_1}'' AS char(20)) AS charge1name --担当者１
   ,cast(ntss_db5_om.rst_charge_user_info #>> ''{user_last_name_2}'' AS char(20))
     || cast(ntss_db5_om.rst_charge_user_info #>> ''{user_first_name_2}'' AS char(20)) AS charge2name --担当者２
   ,to_char((ntss_db5_om.rst_charge_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS chargedate1 --担当日時１
   ,to_char((ntss_db5_om.rst_charge_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS chargedate2 --担当日時２
   ,cast(ntss_db5_om.rst_puncture_user_info #>> ''{user_last_name_1}'' AS char(20))
     || cast(ntss_db5_om.rst_puncture_user_info #>> ''{user_first_name_1}'' AS char(20)) AS puncture1name --穿刺者１
   ,cast(ntss_db5_om.rst_puncture_user_info #>> ''{user_last_name_2}'' AS char(20))
     || cast(ntss_db5_om.rst_puncture_user_info #>> ''{user_first_name_2}'' AS char(20)) AS puncture2name --穿刺者２
   ,to_char((ntss_db5_om.rst_puncture_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS puncturedate1 --穿刺日時１
   ,to_char((ntss_db5_om.rst_puncture_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS puncturedate2 --穿刺日時２
   ,cast(ntss_db5_om.rst_return_user_info #>> ''{user_last_name_1}'' AS char(20))
     || cast(ntss_db5_om.rst_return_user_info #>> ''{user_first_name_1}'' AS char(20)) AS collect1name --回収者１
   ,cast(ntss_db5_om.rst_return_user_info #>> ''{user_last_name_2}'' AS char(20))
     || cast(ntss_db5_om.rst_return_user_info #>> ''{user_first_name_2}'' AS char(20)) AS collect2name --回収者２
   ,to_char((ntss_db5_om.rst_return_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS collectdate1 --回収日時１
   ,to_char((ntss_db5_om.rst_return_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS collectdate2 --回収日時２
   ,ntss_db5_om.rst_in_out_class AS inoutflg --入外
   ,ntss_db5_om.rst_kt_v AS ktvmeasure --Kt/v測定値
   ,ntss_db5_om.rst_weight_info #>> ''{urr}'' AS urr --URR
   ,((((ntss_db5_om.rst_weight_info #>> ''{recrcl_rt}'')::json #>> ''{1}'')::json)::json) #>> ''{rate}'' AS relooprate --再循環率
   ,ntss_db5_om.rst_weight_info #>> ''{ihdf_pll}'' AS pullleaveamount --I-HDF引き残し量
   ,ntss_db5_om.rst_weight_info #>> ''{add_total}'' AS addtotl --除水積算値
   ,ntss_db5_om.rst_weight_info #>> ''{sttc_vns_prssr}'' AS staticvenouspressure --静的静脈圧
   ,ntss_db5_om.rst_weight_info #>> ''{iap_rt}'' AS venousaccesspressureratio --IAP ratio
  FROM
   ord_main ntss_db5_om
   LEFT JOIN ord_schedule ntss_db5_os
   ON ntss_db5_os.ord_no = ntss_db5_om.ord_no
   AND ntss_db5_os.facility_cd = @facilityCd
   LEFT JOIN ntss_db5_mst_b
   ON ntss_db5_mst_b.ord_no = ntss_db5_om.ord_no
   LEFT JOIN ntss_db5_mst_k
   ON ntss_db5_mst_k.ord_no = ntss_db5_om.ord_no
   INNER JOIN rst_vital_info_1
   ON rst_vital_info_1.ord_no = ntss_db5_om.ord_no
   INNER JOIN rst_vital_info_2
   ON rst_vital_info_2.ord_no = ntss_db5_om.ord_no
  WHERE
   ntss_db5_om.is_del = ''0''
   AND ntss_db5_om.facility_cd = @facilityCd
   AND (
        CASE
            WHEN @syncMode = ''update''
                THEN (
                (
                    ntss_db5_om.up_date BETWEEN to_timestamp( @fromDate, ''YYYYMMDDHH24MISS'' ) AND to_timestamp( @toDate, ''YYYYMMDDHH24MISS'' )
                )
                OR (
                    ntss_db5_os.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
                OR (
                    ntss_db5_mst_b.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
                OR (
                    ntss_db5_mst_k.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
            )
            else ntss_db5_om.up_date BETWEEN to_timestamp( @fromDate, ''YYYYMMDDHH24MISS'' ) AND to_timestamp( @toDate, ''YYYYMMDDHH24MISS'' )
            end
    )
   AND ntss_db5_om.pat_id IS NOT NULL;',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);
