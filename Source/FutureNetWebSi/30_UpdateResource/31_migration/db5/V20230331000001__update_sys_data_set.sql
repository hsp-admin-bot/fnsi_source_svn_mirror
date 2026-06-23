DELETE FROM  "ntss"."sys_data_set" where sql_cd in (-2100, -2110, -2120, -2130, -2140, -2150, -2170, -2180, -2190, -2200, -2210);
insert into ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) values
    (-2100,'WITH ntss_db5_om_key AS(
                        SELECT
                                ntss_db5_om.ord_no AS ord_no,
                                ntss_db5_om_value_json.KEY AS keys,
                                ntss_db5_om_value_json.value::JSON ->> ''value'' AS value,
                                ntss_db5_om_value_json.value::JSON ->> ''value_name_1'' AS value_name_1,
                                ntss_db5_om_value_json.value::JSON ->> ''unit'' AS unit
                        FROM
                                ord_main ntss_db5_om CROSS
                        JOIN LATERAL json_object_keys(
                                        ntss_db5_om.rst_cond_info::JSON
                                ) rst_ci_keys_json
                        INNER JOIN json_each_text(
                                        ntss_db5_om.rst_cond_info::JSON
                                ) ntss_db5_om_value_json ON
                                ntss_db5_om_value_json.KEY = rst_ci_keys_json
                        WHERE
                                ntss_db5_om.rst_cond_info IS NOT NULL
                                AND ntss_db5_om.facility_cd = @facilityCd
                ),
                ntss_db5_mst_m AS(
                        SELECT
                                ntss_db5_mst_m.*
                        FROM
                                mst_medicine ntss_db5_mst_m
                        WHERE
                                ntss_db5_mst_m.is_del = ''0''
                                AND ntss_db5_mst_m.is_disp = ''1''
                                AND ntss_db5_mst_m.facility_cd = @facilityCd
                ),
                ntss_db5_om_mst_list AS(
                        SELECT
                                om.ord_no AS ord_no,
                                ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2,
                                ntss_db5_mst_e.equipment_cd AS equipment_cd_keys
                        FROM
                                ord_main om
                        INNER JOIN ntss_db5_om_key ON
                                om.ord_no = ntss_db5_om_key.ord_no
                        LEFT JOIN mst_equipment ntss_db5_mst_e ON
                                CAST(
                                        ntss_db5_om_key.keys AS INTEGER
                                )= ntss_db5_mst_e.equipment_cd
                        WHERE
                                ntss_db5_mst_e.facility_cd = @facilityCd
                                AND ntss_db5_mst_e.is_del = ''0''
                UNION ALL SELECT
                                om.ord_no AS ord_no,
                                ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2,
                                ntss_db5_mst_m.medicine_cd AS equipment_cd_keys
                        FROM
                                ord_main om
                        INNER JOIN ntss_db5_om_key ON
                                om.ord_no = ntss_db5_om_key.ord_no
                        LEFT JOIN mst_medicine ntss_db5_mst_m ON
                                CAST(
                                        ntss_db5_om_key.keys AS INTEGER
                                )= ntss_db5_mst_m.medicine_cd
                        WHERE
                                ntss_db5_mst_m.facility_cd = @facilityCd
                                AND om.is_del = ''0''
                ) SELECT
                        '''' AS hosppatid --患者ID
                ,
                        ntss_db5_om.pat_id AS patid,
                        ntss_db5_os.treat_date AS dialysisdate --透析日
                ,
                        ntss_db5_om.ord_no AS dialysisno --透析番号
                ,
                        CASE
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''1'' THEN ''002'' --治療時間
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''2'' THEN ''003'' --VA
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''3'' THEN ''005'' --目標体重
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''4'' THEN ''007'' --除水量制限
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''5'' THEN ''008'' --ダイアライザ
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''6'' THEN ''009'' --吸着カラム
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''7'' THEN ''039'' --1次膜
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''8'' THEN ''040'' --2次膜
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''9'' THEN '''' --穿刺針(A針)
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''10'' THEN '''' --穿刺針(V針)
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''11'' THEN '''' --穿刺針(SN)
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''12'' THEN ''029'' --シングルニードル使用
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''13'' THEN '''' --血液回路
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''14'' THEN ''010'' --血流量
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''15'' THEN ''018'' --透析液
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''16'' THEN ''019'' --透析液流量
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''17'' THEN ''020'' --透析液量
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''18'' THEN ''021'' --透析液温度
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''19'' THEN ''022'' --補液
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''20'' THEN ''023'' --補液量
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''21'' THEN ''024'' --補液選択
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''22'' THEN ''030'' --補液使用数
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''23'' THEN ''025'' --補液温度
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''24'' THEN ''038'' --補液速度
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''25'' THEN ''011'' --抗凝固剤
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''26'' THEN ''012'' --抗凝固剤ワンショット量
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''27'' THEN ''013'' --抗凝固剤持続速度
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''28'' THEN ''014'' --抗凝固剤持続総量
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''29'' THEN ''015'' --IP使用選択
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''30'' THEN ''031'' --IPスタート
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''31'' THEN ''016'' --IPワンショット量
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''32'' THEN ''017'' --IP速度
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''33'' THEN ''037'' --IP速度最大値
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''34'' THEN ''032'' --自動ワンショット
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''35'' THEN ''033'' --IP電源自動切り
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''36'' THEN ''034'' --IP電源自動切り時間
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''37'' THEN ''035'' --IP電源OKモニタ切り
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''38'' THEN ''036'' --IP電源OKモニタ切り時間
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''39'' THEN ''004'' --DW
                        END AS ctlno --透析条件項目コード
                        ,
                        to_char(
                                ntss_db5_om.up_date,
                                ''YYYY-MM-DD hh24:mi:ss''
                        ) AS updates --更新日時
                        ,
                        CASE
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''1'' THEN ''透析時間'' --治療時間
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''2'' THEN ''VA'' --VA
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''3'' THEN ''目標体重'' --目標体重
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''4'' THEN ''除水量制限'' --除水量制限
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''5'' THEN ''ダイアライザ'' --ダイアライザ
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''6'' THEN ''吸着カラム'' --吸着カラム
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''7'' THEN ''1次膜'' --1次膜
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''8'' THEN ''2次膜'' --2次膜
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''9'' THEN '''' --穿刺針(A針)
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''10'' THEN '''' --穿刺針(V針)
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''11'' THEN '''' --穿刺針(SN)
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''12'' THEN ''シングルニードル使用'' --シングルニードル使用
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''13'' THEN '''' --血液回路
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''14'' THEN ''血流量'' --血流量
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''15'' THEN ''透析液'' --透析液
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''16'' THEN ''透析液流量'' --透析液流量
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''17'' THEN ''透析液量'' --透析液量
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''18'' THEN ''透析液温度'' --透析液温度
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''19'' THEN ''補液'' --補液
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''20'' THEN ''補液量'' --補液量
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''21'' THEN ''補液選択'' --補液選択
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''22'' THEN ''補液使用数'' --補液使用数
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''23'' THEN ''補液温度'' --補液温度
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''24'' THEN ''補液速度'' --補液速度
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''25'' THEN ''抗凝固剤'' --抗凝固剤
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''26'' THEN ''抗凝固剤ワンショット量'' --抗凝固剤ワンショット量
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''27'' THEN ''抗凝固剤持続速度'' --抗凝固剤持続速度
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''28'' THEN ''抗凝固剤持続総量'' --抗凝固剤持続総量
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''29'' THEN ''IP使用選択'' --IP使用選択
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''30'' THEN ''IPスタート'' --IPスタート
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''31'' THEN ''IPワンショット量'' --IPワンショット量
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''32'' THEN ''IP速度'' --IP速度
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''33'' THEN ''IP速度最大値'' --IP速度最大値
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''34'' THEN ''自動ワンショット'' --自動ワンショット
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''35'' THEN ''IP電源自動切り'' --IP電源自動切り
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''36'' THEN ''IP電源自動切り時間'' --IP電源自動切り時間
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''37'' THEN ''IP電源OKモニタ切り'' --IP電源OKモニタ切り
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''38'' THEN ''IP電源OKモニタ切り時間'' --IP電源OKモニタ切り時間
                                WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''39'' THEN ''DW'' --DW
                        END AS dialysisitemname --透析条件項目名
                ,
                        ntss_db5_om_key.value AS value --設定値
                ,
                        ntss_db5_om_key.value_name_1 AS valuename --設定値
                ,
                        ntss_db5_om_key.unit AS unit --単位
                ,
                        SUBSTR(ntss_db5_om_mst_list.in_hospital_cd_2, 0, 20) AS valuecd2 --院内コード2
                FROM
                        ord_main ntss_db5_om
                LEFT JOIN ord_schedule ntss_db5_os ON
                        ntss_db5_om.ord_no = ntss_db5_os.ord_no
                        AND ntss_db5_os.facility_cd = @facilityCd
                INNER JOIN ntss_db5_om_key ON
                        ntss_db5_om.ord_no = ntss_db5_om_key.ord_no
                LEFT JOIN ntss_db5_om_mst_list ON
                        ntss_db5_om_mst_list.ord_no = ntss_db5_om_key.ord_no
                        AND ntss_db5_om_mst_list.equipment_cd_keys = CAST(
                                ntss_db5_om_key.keys AS INTEGER
                        )
                WHERE
                        ntss_db5_om.is_del = ''0''
                        AND ntss_db5_om.facility_cd = @facilityCd
                        AND ntss_db5_os.treat_date BETWEEN
                                SUBSTR(@fromDate,0,9) AND
                                SUBSTR(@toDate,0,9)
                        AND ntss_db5_om.pat_id IS NOT NULL;',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',null);


insert into ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) values
    (-2110,'WITH ntss_db5_om_key AS(
             SELECT
                 ntss_db5_om.ord_no AS ord_no,
                 ntss_db5_om_value_json.KEY AS keys,
                 ntss_db5_om_value_json.value::JSON ->> ''value'' AS value,
                 ntss_db5_om_value_json.value::JSON ->> ''value_name_1'' AS value_name_1,
                 ntss_db5_om_value_json.value::JSON ->> ''unit'' AS unit
             FROM
                 ord_main ntss_db5_om CROSS
             JOIN LATERAL json_object_keys(
                     ntss_db5_om.rst_cond_info::JSON
                 ) rst_ci_keys_json
             INNER JOIN json_each_text(
                     ntss_db5_om.rst_cond_info::JSON
                 ) ntss_db5_om_value_json ON
                 ntss_db5_om_value_json.KEY = rst_ci_keys_json
             WHERE
                 ntss_db5_om.rst_cond_info IS NOT NULL
                 AND ntss_db5_om.facility_cd = @facilityCd
         ),
         ntss_db5_mst_m AS(
             SELECT
                 ntss_db5_mst_m.*
             FROM
                 mst_medicine ntss_db5_mst_m
             WHERE
                 ntss_db5_mst_m.is_del = ''0''
                 AND ntss_db5_mst_m.is_disp = ''1''
                 AND ntss_db5_mst_m.facility_cd = @facilityCd
         ),
         ntss_db5_om_mst_list AS(
             SELECT
                 om.ord_no AS ord_no,
                 ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
                 ntss_db5_mst_e.equipment_cd AS equipment_cd_keys
             FROM
                 ord_main om
             INNER JOIN ntss_db5_om_key ON
                 om.ord_no = ntss_db5_om_key.ord_no
             LEFT JOIN mst_equipment ntss_db5_mst_e ON
                 CAST(
                     ntss_db5_om_key.keys AS INTEGER
                 )= ntss_db5_mst_e.equipment_cd
             WHERE
                 ntss_db5_mst_e.facility_cd = @facilityCd
                 AND ntss_db5_mst_e.is_del = ''0''
         UNION ALL SELECT
                 om.ord_no AS ord_no,
                 ntss_db5_mst_m.in_hospital_cd_1 AS in_hospital_cd_1,
                 ntss_db5_mst_m.medicine_cd AS equipment_cd_keys
             FROM
                 ord_main om
             INNER JOIN ntss_db5_om_key ON
                 om.ord_no = ntss_db5_om_key.ord_no
             LEFT JOIN mst_medicine ntss_db5_mst_m ON
                 CAST(
                     ntss_db5_om_key.keys AS INTEGER
                 )= ntss_db5_mst_m.medicine_cd
             WHERE
                 ntss_db5_mst_m.facility_cd = @facilityCd
                 AND om.is_del = ''0''
         ) SELECT
             '''' AS hosppatid --患者ID
         ,
             ntss_db5_om.pat_id AS patid,
             ntss_db5_os.treat_date AS dialysisdate --透析日
         ,
             ntss_db5_om.ord_no AS dialysisno --透析番号
         ,
             CASE
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''1'' THEN ''002'' --治療時間
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''2'' THEN ''003'' --VA
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''3'' THEN ''005'' --目標体重
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''4'' THEN ''007'' --除水量制限
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''5'' THEN ''008'' --ダイアライザ
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''6'' THEN ''009'' --吸着カラム
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''7'' THEN ''039'' --1次膜
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''8'' THEN ''040'' --2次膜
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''9'' THEN '''' --穿刺針(A針)
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''10'' THEN '''' --穿刺針(V針)
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''11'' THEN '''' --穿刺針(SN)
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''12'' THEN ''029'' --シングルニードル使用
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''13'' THEN '''' --血液回路
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''14'' THEN ''010'' --血流量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''15'' THEN ''018'' --透析液
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''16'' THEN ''019'' --透析液流量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''17'' THEN ''020'' --透析液量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''18'' THEN ''021'' --透析液温度
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''19'' THEN ''022'' --補液
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''20'' THEN ''023'' --補液量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''21'' THEN ''024'' --補液選択
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''22'' THEN ''030'' --補液使用数
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''23'' THEN ''025'' --補液温度
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''24'' THEN ''038'' --補液速度
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''25'' THEN ''011'' --抗凝固剤
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''26'' THEN ''012'' --抗凝固剤ワンショット量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''27'' THEN ''013'' --抗凝固剤持続速度
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''28'' THEN ''014'' --抗凝固剤持続総量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''29'' THEN ''015'' --IP使用選択
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''30'' THEN ''031'' --IPスタート
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''31'' THEN ''016'' --IPワンショット量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''32'' THEN ''017'' --IP速度
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''33'' THEN ''037'' --IP速度最大値
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''34'' THEN ''032'' --自動ワンショット
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''35'' THEN ''033'' --IP電源自動切り
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''36'' THEN ''034'' --IP電源自動切り時間
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''37'' THEN ''035'' --IP電源OKモニタ切り
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''38'' THEN ''036'' --IP電源OKモニタ切り時間
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''39'' THEN ''004'' --DW
             END AS ctlno --透析条件項目コード
             ,
             to_char(
                 ntss_db5_om.up_date,
                 ''YYYY-MM-DD hh24:mi:ss''
             ) AS updates --更新日時
             ,
             CASE
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''1'' THEN ''透析時間'' --治療時間
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''2'' THEN ''VA'' --VA
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''3'' THEN ''目標体重'' --目標体重
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''4'' THEN ''除水量制限'' --除水量制限
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''5'' THEN ''ダイアライザ'' --ダイアライザ
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''6'' THEN ''吸着カラム'' --吸着カラム
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''7'' THEN ''1次膜'' --1次膜
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''8'' THEN ''2次膜'' --2次膜
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''9'' THEN '''' --穿刺針(A針)
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''10'' THEN '''' --穿刺針(V針)
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''11'' THEN '''' --穿刺針(SN)
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''12'' THEN ''シングルニードル使用'' --シングルニードル使用
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''13'' THEN '''' --血液回路
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''14'' THEN ''血流量'' --血流量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''15'' THEN ''透析液'' --透析液
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''16'' THEN ''透析液流量'' --透析液流量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''17'' THEN ''透析液量'' --透析液量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''18'' THEN ''透析液温度'' --透析液温度
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''19'' THEN ''補液'' --補液
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''20'' THEN ''補液量'' --補液量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''21'' THEN ''補液選択'' --補液選択
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''22'' THEN ''補液使用数'' --補液使用数
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''23'' THEN ''補液温度'' --補液温度
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''24'' THEN ''補液速度'' --補液速度
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''25'' THEN ''抗凝固剤'' --抗凝固剤
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''26'' THEN ''抗凝固剤ワンショット量'' --抗凝固剤ワンショット量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''27'' THEN ''抗凝固剤持続速度'' --抗凝固剤持続速度
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''28'' THEN ''抗凝固剤持続総量'' --抗凝固剤持続総量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''29'' THEN ''IP使用選択'' --IP使用選択
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''30'' THEN ''IPスタート'' --IPスタート
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''31'' THEN ''IPワンショット量'' --IPワンショット量
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''32'' THEN ''IP速度'' --IP速度
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''33'' THEN ''IP速度最大値'' --IP速度最大値
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''34'' THEN ''自動ワンショット'' --自動ワンショット
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''35'' THEN ''IP電源自動切り'' --IP電源自動切り
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''36'' THEN ''IP電源自動切り時間'' --IP電源自動切り時間
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''37'' THEN ''IP電源OKモニタ切り'' --IP電源OKモニタ切り
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''38'' THEN ''IP電源OKモニタ切り時間'' --IP電源OKモニタ切り時間
                 WHEN CAST(ntss_db5_om_key.keys AS CHAR(10))= ''39'' THEN ''DW'' --DW
             END AS dialysisitemname --透析条件項目名
         ,
             ntss_db5_om_key.value AS value --設定値
         ,
             ntss_db5_om_key.value_name_1 AS valuename --設定値
         ,
             ntss_db5_om_key.unit AS unit --単位
         ,
             SUBSTR(ntss_db5_om_mst_list.in_hospital_cd_1, 0, 20) AS valuecd1 --院内コード1
         FROM
             ord_main ntss_db5_om
         LEFT JOIN ord_schedule ntss_db5_os ON
             ntss_db5_om.ord_no = ntss_db5_os.ord_no
             AND ntss_db5_os.facility_cd = @facilityCd
         INNER JOIN ntss_db5_om_key ON
             ntss_db5_om.ord_no = ntss_db5_om_key.ord_no
         LEFT JOIN ntss_db5_om_mst_list ON
             ntss_db5_om_mst_list.ord_no = ntss_db5_om_key.ord_no
             AND ntss_db5_om_mst_list.equipment_cd_keys = CAST(
                 ntss_db5_om_key.keys AS INTEGER
             )
         WHERE
             ntss_db5_om.is_del = ''0''
             AND ntss_db5_om.facility_cd = @facilityCd
             AND ntss_db5_os.treat_date BETWEEN
                 SUBSTR(@fromDate,0,9) AND
                 SUBSTR(@toDate,0,9)
             AND ntss_db5_om.pat_id IS NOT NULL;',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',null);


insert into ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) values
    (-2120,'SELECT
            '''' AS hosppatid                             --患者ID
            , ntss_db5_om.pat_id AS patid
            , ntss_db5_os.treat_date AS dialysisdate    --透析日
            , ntss_db5_om.ord_no AS dialysisno          --透析番号
            , row_number() over (ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
            , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
            , ntss_db5_mst_e.in_hospital_cd_1 AS equipcd --医療材料コード(院内コード1)
            , ntss_db5_mst_e.in_hospital_cd_2 AS equipcd2 --医療材料コード(院内コード2)
            , ntss_db5_mst_e.equipment_name AS equipname --医療材料名
            , ntss_db5_mst_c.class_name AS equipclassname --医療材料分類名
            , ntss_db5_om_rqi_json ->> ''needle_type'' AS punctureclass --穿刺針区分
            , ntss_db5_om_rqi_json ->> ''amount'' AS amount --数量
            , ntss_db5_mst_e.unit AS unit   --単位
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
            AND ntss_db5_os.treat_date BETWEEN  SUBSTR(@fromDate,0,9) AND SUBSTR(@toDate,0,9)
            AND ntss_db5_om.pat_id IS NOT NULL;',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',null);


insert into ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) values
    (-2130,'with ntss_db5_om_temp AS (
            SELECT
                ntss_db5_om.ord_no
                , ntss_db5_om_rmi_json ->> ''cd'' ::char (10) AS cd
                , ntss_db5_om_rmi_json ->> ''procedure_cd'' ::char (10) AS procedure_cd
                , ntss_db5_om_rmi_json ->> ''amount'' AS amount --数量
                , ntss_db5_om_rmi_json ->> ''effect_flg'' AS effectflg --実施フラグ
                , CASE WHEN POSITION(''T'' IN cast(ntss_db5_om_rmi_json ->> ''effect_date'' AS char (20))) != 0
                       THEN to_char(to_timestamp(ntss_db5_om_rmi_json ->> ''effect_date'', ''YYYY-MM-DDThh24:mi:ss''
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
                ntss_db5_om.facility_cd = ''CONV30''
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
            , ntss_db5_mst_m.in_hospital_cd_1 AS medicinecd --薬剤コード(院内コード1)
            , ntss_db5_mst_m.in_hospital_cd_2 AS medicinecd2 --薬剤コード(院内コード2)
            , ntss_db5_mst_m.medicine_name AS medicinename --薬剤名
            , ntss_db5_mst_c.class_name AS medicineclassname --薬剤分類名
            , ntss_db5_om_temp.amount AS amount         --数量
            , ntss_db5_mst_m.unit AS unit               --単位
            , ntss_db5_om_temp.effectflg AS effectflg   --実施フラグ
            , ntss_db5_om_temp.effectdate               --実施日時
            , ntss_db5_om_temp.timingname AS timingname --投与時間帯名
            , ntss_db5_mst_p.in_hospital_cd_a1 AS procedurecd --手技コード(院内コード1)
            , ntss_db5_mst_p.in_hospital_cd_a2 AS procedurecd2 --手技コード(院内コード2)
            , ntss_db5_mst_p.pricedure_name AS procedurename --手技名
            , '''' AS indicatorcd                         --実施者コード
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
            ntss_db5_os.treat_date BETWEEN
                SUBSTR(@fromDate,0,9) AND
                SUBSTR(@toDate,0,9)
                AND ntss_db5_om.pat_id IS NOT NULL;',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',null);


insert into ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) values
    (-2140,'WITH ord AS (
           SELECT
            ord_no
            , facility_cd
            , pat_id
            , up_date
            , is_del
            , treat_date
            , medi ->> ''medicine_type'' as medicinetype
            , medi ->> ''cd'' as cd
            , medi ->> ''name'' as name
            , medi ->> ''class_name'' as classname
            , medi ->> ''amount'' as amount
            , medi ->> ''unit'' as unit
            , medi ->> ''effect_flg'' as effectflg
            , medi ->> ''effect_date'' as effectdate
            , medi ->> ''timing_name'' as timingname
            , medi ->> ''procedure_cd'' as procedurecd
            , medi ->> ''procedure_name'' as procedurename
            , medi ->> ''effect_user_id'' as effectuserid
            , medi ->> ''effect_user_last_name'' as effectuserlastname
            , medi ->> ''effect_user_first_name'' as effectuserfirstname
            , medi ->> ''comment'' as comment
        FROM
            ord_main
            CROSS JOIN LATERAL jsonb_array_elements(rst_medi_info) medi
        WHERE
            is_del = ''0''
            AND rst_dialysis_state <> ''0''
            AND facility_cd = @facilityCd
            AND pat_id IS NOT NULL
    )
    , ntss_db5_mst_m AS (
        SELECT
            ord.ord_no
            , mstMedic.in_hospital_cd_1 as in_hospital_cd_1
        FROM
            ord
            INNER JOIN mst_medicine mstMedic
                ON ord.cd = mstMedic.medicine_cd ::text
                AND mstMedic.is_del = ''0''
                AND mstMedic.is_disp = ''1''
        WHERE
            ord.medicinetype = ''1''
            AND ord.facility_cd = @facilityCd
        UNION ALL
        SELECT
            ord.ord_no
            , mix.in_hospital_cd_1 as in_hospital_cd_1
        FROM
            ord
            INNER JOIN mst_medicine_mix mix
                ON mix.medicine_mix_cd ::text = ord.cd
        WHERE
            ord.medicinetype = ''2''
            AND ord.facility_cd = @facilityCd
            AND mix.facility_cd = @facilityCd
            AND mix.is_del = ''0''
            AND mix.is_disp = ''1''
    )
    SELECT
        '''' AS hosppatid                             --患者ID
        , ntss_db5_om.pat_id AS patid
        , ntss_db5_os.treat_date AS dialysisdate    --透析日
        , ntss_db5_om.ord_no AS dialysisno          --透析番号
        , row_number() over (ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
        , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
        , ntss_db5_om.cd AS medicinecd              --薬剤コード
        , ntss_db5_mst_m.in_hospital_cd_1 AS medicinecd2 --薬剤コード(院内コード1)
        , ntss_db5_om.name AS medicinename          --薬剤名
        , '''' AS medgeneralname                      --一般名
        , ntss_db5_om.classname AS medicineclassname --薬剤分類名
        , ntss_db5_om.amount AS amount              --数量
        , ntss_db5_om.unit AS unit                  --単位
        , ntss_db5_om.effectflg AS effectflg        --実施フラグ
        , CASE
            WHEN POSITION(
                ''T'' IN cast(ntss_db5_om.effectdate AS char (20))
            ) != 0
                THEN to_char(
                to_timestamp(ntss_db5_om.effectdate, ''YYYY-MM-DDThh24:mi:ss'')
                , ''YYYY-MM-DD hh24:mi:ss''
            )
            ELSE ''''
            END AS effectdate                       --実施日時
        , ntss_db5_om.timingname AS timingname      --投与時間帯名
        , ntss_db5_mst_p.in_hospital_cd_a1 AS procedurecd --手技コード(院内コード1)
        , ntss_db5_mst_p.in_hospital_cd_a2 AS procedurecd2 --手技コード(院内コード2)
        , ntss_db5_om.procedurename AS procedurename --手技名
        , ntss_db5_om.effectuserid AS userid
        , '''' AS indicatorcd                         --実施者コード
        , cast(ntss_db5_om.effectuserlastname AS char (20)) || cast(ntss_db5_om.effectuserfirstname AS char (20))
         AS staffname                               --実施者名
        , ntss_db5_om.comment AS comments           --コメント
    FROM
        ord ntss_db5_om
        LEFT JOIN ord_schedule ntss_db5_os
            ON ntss_db5_os.ord_no = ntss_db5_om.ord_no
        LEFT JOIN ntss_db5_mst_m
            ON ntss_db5_mst_m.ord_no = ntss_db5_om.ord_no
        LEFT JOIN mst_procedure ntss_db5_mst_p
            ON cast(ntss_db5_mst_p.procedure_cd as char (10)) = cast(ntss_db5_om.procedurecd as char (10))
        WHERE
            ntss_db5_os.treat_date BETWEEN
                SUBSTR(@fromDate,0,9) AND
                SUBSTR(@toDate,0,9)
            AND ntss_db5_om.pat_id IS NOT NULL;
',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',null);


insert into ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) values
    (-2150,'SELECT
        '''' AS hosppatid --患者ID
        ,ntss_db5_om.pat_id AS patid
        ,ntss_db5_os.treat_date AS dialysisdate --透析日
        ,ntss_db5_om.ord_no AS dialysisno --透析番号
        ,row_number() over(ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
        ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
        ,''0'' AS effectflg --実施フラグ
        ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS effectdate --実施日時
        ,ntss_db5_om_iic_json ->> ''content'' AS addition --補足指示内容
        ,'''' AS hosppatid --実施者コード
        ,cast(ntss_db5_om_iic_json ->> ''upd_user_last_name'' AS char(20))
         || cast(ntss_db5_om_iic_json ->> ''upd_user_first_name'' AS char(20)) AS staffname --実施者名
FROM
        ord_main ntss_db5_om
        LEFT JOIN ord_schedule ntss_db5_os
        ON ntss_db5_om.ord_no = ntss_db5_os.ord_no
        AND ntss_db5_os.facility_cd = @facilityCd
        CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_ind_comment_info ::json) ntss_db5_om_iic_json
WHERE
        ntss_db5_om.is_del = ''0''
        AND ntss_db5_om.facility_cd = @facilityCd
        AND ntss_db5_os.treat_date BETWEEN SUBSTR(@fromDate,0,9) AND SUBSTR(@toDate,0,9)
        AND ntss_db5_om.pat_id IS NOT NULL;',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',null);


insert into ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) values
    (-2170,'with ntss_db5_om_1 as (
            SELECT
                array_agg(ntss_db5_om_1.ord_no) AS arr_ord_no
                , ntss_db5_om_1.pat_id
                , ntss_db5_om_1.treat_date AS treat_date
                , COUNT(ntss_db5_om_1.treat_date) AS treat_date_count
            FROM
                ord_main ntss_db5_om_1
            WHERE
                ntss_db5_om_1.is_del = ''0''
                AND ntss_db5_om_1.facility_cd = @facilityCd
            GROUP BY
                ntss_db5_om_1.pat_id
                , ntss_db5_om_1.treat_date
        )
        SELECT
            '''' AS hosppatid                             --患者ID
            , ntss_db5_om.pat_id AS patid
            , ntss_db5_os.treat_date AS dialysisdate    --透析日
            , ntss_db5_om.ord_no AS bedno               --ベッド番号
            , ntss_db5_om_mst_b.bed_name AS bedname     --ベッド名
            , ntss_db5_om_mst_k.in_hospital_cd_1 AS kurcd --クールコード
            , ntss_db5_om.rst_kur_name AS kurname       --クール名
            , CASE
                WHEN ntss_db5_om_1.treat_date_count > 1
                    THEN 1
                ELSE 0
                END AS plural                           --同日複数回
            , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
            , ntss_db5_om.ord_no AS resultdialysisno    --実績透析番号
            , CASE
                WHEN ntss_db5_om.treat_type = 0
                    THEN 1
                ELSE 0
                END AS opeindplan                       --予定作成区分
            , ntss_db5_os.is_dummy AS dummyflg          --ダミーフラグ
            , to_char(ntss_db5_om.rst_start_date, ''hh24:mi'') AS starttime --透析開始時刻
        FROM
            ord_main ntss_db5_om
            INNER JOIN ntss_db5_om_1
                ON ntss_db5_om.ord_no = ANY (ntss_db5_om_1.arr_ord_no)
            LEFT JOIN ord_schedule ntss_db5_os
                ON ntss_db5_os.pat_id = ntss_db5_om.pat_id
                AND ntss_db5_os.ord_no = ntss_db5_om.ord_no
            LEFT JOIN mst_bed ntss_db5_om_mst_b
                ON ntss_db5_om_mst_b.bed_cd = ntss_db5_os.bed_cd
            LEFT JOIN mst_kur ntss_db5_om_mst_k
                ON ntss_db5_om_mst_k.kur_cd = ntss_db5_om.rst_kur_cd
        WHERE
            ntss_db5_om.is_del = ''0''
            AND ntss_db5_om.facility_cd = @facilityCd
            AND ntss_db5_os.treat_date BETWEEN SUBSTR(@fromDate,0,9) AND SUBSTR(@toDate,0,9);',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',null);


insert into ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) values
    (-2180,'with ntss_db5_om_1 as (
            SELECT
                main.ord_no
                , main.ind_kur_cd
                , main.up_date
                , main.treat_type
                , main.ind_treat_start_time
                , subMain.pat_id
                , subMain.treat_date
                , subMain.treat_date_count
            FROM
                ord_main main
                INNER JOIN (
                    SELECT
                        array_agg(ntss_db5_om_1.ord_no) AS arr_ord_no
                        , ntss_db5_om_1.pat_id
                        , ntss_db5_om_1.treat_date AS treat_date
                        , COUNT(ntss_db5_om_1.treat_date) AS treat_date_count
                    FROM
                        ord_main ntss_db5_om_1
                    WHERE
                        ntss_db5_om_1.facility_cd = @facilityCd
                        AND ntss_db5_om_1.is_del = ''0''
                        AND ntss_db5_om_1.pat_id IS NOT NULL
                    GROUP BY
                        ntss_db5_om_1.pat_id
                        , ntss_db5_om_1.treat_date
                ) AS subMain
                    ON main.ord_no = ANY (subMain.arr_ord_no)
        )
        SELECT
            '''' AS hosppatid
            , ntss_db5_om_1.pat_id AS patid             --患者ID
            , ntss_db5_os.treat_date AS dialysisdate    --透析日
            , ntss_db5_os.ord_no AS bedno               --ベッド番号
            , ntss_db5_om_mst_b.bed_name AS bedname     --ベッド名
            , ntss_db5_om_mst_k.kur_cd AS kurcd         --クールコード
            , ntss_db5_om_mst_k.kur_name AS kurname     --クール名
            , CASE
                WHEN ntss_db5_om_1.treat_date_count > 1
                    THEN 1
                ELSE 0
                END AS plural                           --同日複数回
            , to_char(ntss_db5_om_1.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
            , ntss_db5_om_1.ord_no AS resultdialysisno  --実績透析番号
            , CASE
                WHEN ntss_db5_om_1.treat_type = 0
                    THEN 1
                ELSE 0
                END AS opeindplan                       --予定作成区分
            , ntss_db5_os.is_dummy AS dummyflg          --ダミーフラグ
            , ntss_db5_om_1.ind_treat_start_time
            , ntss_db5_om_mst_k.kur_start_time
            , CASE
                WHEN ntss_db5_om_1.ind_treat_start_time IS NOT NULL
                    THEN to_char(
                    ntss_db5_om_1.ind_treat_start_time ::time
                    , ''hh24:mi''
                )
                WHEN ntss_db5_om_mst_k.kur_start_time IS NOT NULL
                    THEN to_char(
                    ntss_db5_om_mst_k.kur_start_time ::time
                    , ''hh24:mi''
                )
                ElSE ''未登録''
                END AS starttime                        --透析開始時刻
        FROM
            ntss_db5_om_1
            LEFT JOIN ord_schedule ntss_db5_os
                ON ntss_db5_os.pat_id = ntss_db5_om_1.pat_id
                AND ntss_db5_os.ord_no = ntss_db5_om_1.ord_no
            LEFT JOIN mst_bed ntss_db5_om_mst_b
                ON ntss_db5_om_mst_b.bed_cd = ntss_db5_os.bed_cd
            LEFT JOIN mst_kur ntss_db5_om_mst_k
                ON ntss_db5_om_mst_k.kur_cd = ntss_db5_om_1.ind_kur_cd
        WHERE ntss_db5_os.treat_date BETWEEN SUBSTR(@fromDate,0,9) AND SUBSTR(@toDate,0,9);
',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',null);


insert into ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) values
    (-2190,'with ntss_db5_mst_v as (
    SELECT
        ntss_db5_mst_v.*
    FROM
        mst_va ntss_db5_mst_v
    WHERE
        ntss_db5_mst_v.is_del = ''0''
        AND ntss_db5_mst_v.is_disp = ''1''
        AND ntss_db5_mst_v.facility_cd = @facilityCd
)
, ntss_db5_mst_d as (
    SELECT
        ntss_db5_mst_d.*
    FROM
        mst_dialyzer ntss_db5_mst_d
    WHERE
        ntss_db5_mst_d.is_del = ''0''
        AND ntss_db5_mst_d.is_disp = ''1''
        AND ntss_db5_mst_d.facility_cd = @facilityCd
)
, ntss_db5_mst_e as (
    SELECT
        ntss_db5_mst_e.*
    FROM
        mst_equipment ntss_db5_mst_e
    WHERE
        ntss_db5_mst_e.is_del = ''0''
        AND ntss_db5_mst_e.is_disp = ''1''
        AND ntss_db5_mst_e.facility_cd = @facilityCd
)
, ntss_db5_mst_m as (
    SELECT
        ntss_db5_mst_m.*
    FROM
        mst_medicine ntss_db5_mst_m
    WHERE
        ntss_db5_mst_m.is_del = ''0''
        AND ntss_db5_mst_m.is_disp = ''1''
        AND ntss_db5_mst_m.facility_cd = @facilityCd
)
, ntss_db5_mst_t as (
    SELECT
        ntss_db5_mst_t.*
    FROM
        mst_treatment ntss_db5_mst_t
    WHERE
        ntss_db5_mst_t.is_del = ''0''
        AND ntss_db5_mst_t.is_disp = ''1''
        AND ntss_db5_mst_t.facility_cd = @facilityCd
)
, ind_cond_info_table AS (
    SELECT
        om.ind_cond_info ::json ->> ''2'' AS ind_cond_info_2
        , om.ind_cond_info ::json ->> ''5'' AS ind_cond_info_5
        , om.ind_cond_info ::json ->> ''6'' AS ind_cond_info_6
        , om.ind_cond_info ::json ->> ''7'' AS ind_cond_info_7
        , om.ind_cond_info ::json ->> ''8'' AS ind_cond_info_8
        , om.ind_cond_info ::json ->> ''9'' AS ind_cond_info_9
        , om.ind_cond_info ::json ->> ''10'' AS ind_cond_info_10
        , om.ind_cond_info ::json ->> ''11'' AS ind_cond_info_11
        , om.ind_cond_info ::json ->> ''13'' AS ind_cond_info_13
        , om.ind_cond_info ::json ->> ''15'' AS ind_cond_info_15
        , om.ind_cond_info ::json ->> ''19'' AS ind_cond_info_19
        , om.ind_cond_info ::json ->> ''26'' AS ind_cond_info_26
        , ord_no
    FROM
        ord_main om
    WHERE
        om.facility_cd = @facilityCd
        AND om.is_del = ''0''
        AND om.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9)
)
, ntss_db5_mst_list as (
    --VA
    SELECT
        ''003'' AS fnw_code
        , ''VA'' AS fnw_name
        , om.ind_cond_info_2 ::json ->> ''value'' AS value
        , om.ind_cond_info_2 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_2 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_v.in_hospital_cd_2 AS in_hospital_cd_2
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_v
            ON TO_NUMBER(
                om.ind_cond_info_2 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_v.va_cd
    WHERE
        om.ind_cond_info_2 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --ダイアライザ
    SELECT
        ''008'' AS fnw_code
        , ''ダイアライザ'' AS fnw_name
        , om.ind_cond_info_5 ::json ->> ''value'' AS value
        , om.ind_cond_info_5 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_5 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_d.in_hospital_cd_2 AS in_hospital_cd_2
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_d
            ON TO_NUMBER(
                om.ind_cond_info_5 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_d.dialyzer_cd
    WHERE
        om.ind_cond_info_5 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --吸着カラム
    SELECT
        ''009'' AS fnw_code
        , ''吸着カラム'' AS fnw_name
        , om.ind_cond_info_6 ::json ->> ''value'' AS value
        , om.ind_cond_info_6 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_6 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(
                om.ind_cond_info_6 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_e.equipment_cd
    WHERE
        om.ind_cond_info_6 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --1次膜
    SELECT
        ''039'' AS fnw_code
        , ''1次膜'' AS fnw_name
        , om.ind_cond_info_7 ::json ->> ''value'' AS value
        , om.ind_cond_info_7 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_7 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(
                om.ind_cond_info_7 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_e.equipment_cd
    WHERE
        om.ind_cond_info_7 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --2次膜
    SELECT
        ''040'' AS fnw_code
        , ''2次膜'' AS fnw_name
        , om.ind_cond_info_8 ::json ->> ''value'' AS value
        , om.ind_cond_info_8 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_8 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(
                om.ind_cond_info_8 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_e.equipment_cd
    WHERE
        om.ind_cond_info_8 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --穿刺針(A針)
    SELECT
        '''' AS fnw_code
        , ''穿刺針(A針)'' AS fnw_name
        , om.ind_cond_info_9 ::json ->> ''value'' AS value
        , om.ind_cond_info_9 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_9 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(
                om.ind_cond_info_9 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_e.equipment_cd
    WHERE
        om.ind_cond_info_9 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --穿刺針(V針)
    SELECT
        '''' AS fnw_code
        , ''穿刺針(V針)'' AS fnw_name
        , om.ind_cond_info_10 ::json ->> ''value'' AS value
        , om.ind_cond_info_10 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_10 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(
                om.ind_cond_info_10 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_e.equipment_cd
    WHERE
        om.ind_cond_info_10 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --穿刺針(SN)
    SELECT
        '''' AS fnw_code
        , ''穿刺針(SN)'' AS fnw_name
        , om.ind_cond_info_11 ::json ->> ''value'' AS value
        , om.ind_cond_info_11 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_11 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(
                om.ind_cond_info_11 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_e.equipment_cd
    WHERE
        om.ind_cond_info_11 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --血液回路
    SELECT
        '''' AS fnw_code
        , ''血液回路'' AS fnw_name
        , om.ind_cond_info_13 ::json ->> ''value'' AS value
        , om.ind_cond_info_13 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_13 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(
                om.ind_cond_info_13 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_e.equipment_cd
    WHERE
        om.ind_cond_info_13 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --透析液
    SELECT
        ''018'' AS fnw_code
        , ''透析液'' AS fnw_name
        , om.ind_cond_info_15 ::json ->> ''value'' AS value
        , om.ind_cond_info_15 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_15 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_m
            ON TO_NUMBER(
                om.ind_cond_info_15 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_m.medicine_cd
    WHERE
        om.ind_cond_info_15 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --補液
    SELECT
        ''022'' AS fnw_code
        , ''補液'' AS fnw_name
        , om.ind_cond_info_19 ::json ->> ''value'' AS value
        , om.ind_cond_info_19 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_19 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_m
            ON TO_NUMBER(
                om.ind_cond_info_19 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_m.medicine_cd
    WHERE
        om.ind_cond_info_19 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --抗凝固剤ワンショット量
    SELECT
        ''012'' AS fnw_code
        , ''抗凝固剤ワンショット量'' AS fnw_name
        , om.ind_cond_info_26 ::json ->> ''value'' AS value
        , om.ind_cond_info_26 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_26 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_m
            ON TO_NUMBER(
                om.ind_cond_info_26 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_m.medicine_cd
    WHERE
        om.ind_cond_info_26 ::json ->> ''value'' IS NOT NULL
)
, ntss_db5_om_1 as (
    SELECT
        ntss_db5_om_1.ord_no AS ord_no
        , ntss_db5_om_1.pat_id
        , ntss_db5_om_1.treat_date AS treat_date
        , COUNT(ntss_db5_om_1.treat_date) AS treat_date_count
    FROM
        ord_main ntss_db5_om_1
    WHERE
        1 = 1
        AND ntss_db5_om_1.facility_cd = @facilityCd
        AND ntss_db5_om_1.treat_date IS NOT NULL
        AND ntss_db5_om_1.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9)
    GROUP BY
        ntss_db5_om_1.ord_no
        , ntss_db5_om_1.pat_id
        , ntss_db5_om_1.treat_date
)
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , ntss_db5_om.treat_date AS dialysisdate    --透析日
    , CASE
        WHEN ntss_db5_om_1.treat_date_count > 1
            THEN 1
        ELSE 0
        END AS plural                           --同日複数回
    , ntss_db5_mst_list.fnw_code AS ctlno       --透析条件項目コード
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時+
    , ntss_db5_mst_list.fnw_name AS dialysisitemname --透析条件項目名
    , ntss_db5_mst_list.value AS value          --設定値
    , ntss_db5_mst_list.value_name_1 AS valuename --名称
    , ntss_db5_mst_list.unit AS unit            --単位
    , ntss_db5_mst_list.in_hospital_cd_2 AS valuecd2 --院内コード2
    , '''' AS indicatorcd                         --指示者
    , ntss_db5_om_iic_json ->> ''ind_user_id'' AS userid
    , CASE
        WHEN ntss_db5_om.treat_type = 0
            THEN ''1''
        ELSE ''0''
        END AS opeindplan                       --予定作成区分
FROM
    ord_main ntss_db5_om
    INNER JOIN ntss_db5_mst_list
        ON ntss_db5_mst_list.ord_no = ntss_db5_om.ord_no
    INNER JOIN ntss_db5_om_1
        ON ntss_db5_om_1.ord_no = ntss_db5_om.ord_no
    CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_ind_comment_info ::json) ntss_db5_om_iic_json
WHERE
    ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.facility_cd = @facilityCd
    AND ntss_db5_om.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9)
    AND ntss_db5_om.pat_id IS NOT NULL;',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',null);


insert into ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) values
    (-2200,'WITH ntss_db5_om_1 AS (
    SELECT
        ntss_db5_om_1.ord_no AS ord_no
        , ntss_db5_om_1.pat_id
        , ntss_db5_om_1.treat_date AS treat_date
        , COUNT(ntss_db5_om_1.treat_date) AS treat_date_count
    FROM
        ord_main ntss_db5_om_1
    WHERE
        1 = 1
        AND ntss_db5_om_1.facility_cd = @facilityCd
        AND ntss_db5_om_1.treat_date IS NOT NULL
        AND ntss_db5_om_1.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9)
    GROUP BY
        ntss_db5_om_1.ord_no
        , ntss_db5_om_1.pat_id
        , ntss_db5_om_1.treat_date
)
, ntss_db5_mst_e AS (
    SELECT
        ntss_db5_mst_e.*
    FROM
        mst_equipment ntss_db5_mst_e
    WHERE
        ntss_db5_mst_e.is_del = ''0''
        AND ntss_db5_mst_e.is_disp = ''1''
        AND ntss_db5_mst_e.facility_cd = @facilityCd
        AND ntss_db5_mst_e.up_date BETWEEN to_date(@fromDate, ''YYYYMMDDHH24MISS'') AND to_date(@toDate, ''YYYYMMDDHH24MISS'')
)
, ntss_db5_om_rei_json AS (
    SELECT
        om.ind_cond_info ::json ->> ''{6,value}'' AS value_6
        , om.ind_cond_info ::json ->> ''{7,value}'' AS value_7
        , om.ind_cond_info ::json ->> ''{8,value}'' AS value_8
        , om.ind_cond_info ::json ->> ''{9,value}'' AS value_9
        , om.ind_cond_info ::json ->> ''{10,value}'' AS value_10
        , om.ind_cond_info ::json ->> ''{11,value}'' AS value_11
        , om.ind_cond_info ::json ->> ''{12,value}'' AS value_12
        , om.ind_cond_info ::json ->> ''{13,value}'' AS value_13
        , ntss_db5_om_rei_json ->> ''amount'' AS amount
        , ntss_db5_om_rei_json ->> ''class_name'' AS class_name
        , ntss_db5_om_rei_json ->> ''name'' AS name
        , ntss_db5_om_rei_json ->> ''cd'' AS cd
        , om.ord_no AS ord_no
    FROM
        ord_main om
        CROSS JOIN LATERAL json_array_elements(om.rst_equip_info ::json) ntss_db5_om_rei_json
    WHERE
        om.facility_cd = @facilityCd
        AND om.is_del = ''0''
        AND om.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9)
)
, ntss_db5_om_iei_json AS (
    SELECT
        ntss_db5_om_iei_json ->> ''unit'' AS unit
        , ntss_db5_om_iei_json ->> ''comment'' AS COMMENT
        , ntss_db5_om_iei_json ->> ''cd'' AS cd
        , om.ord_no AS ord_no
    FROM
        ord_main om
        CROSS JOIN LATERAL json_array_elements(om.ind_equip_info ::json) ntss_db5_om_iei_json
    WHERE
        om.facility_cd = @facilityCd
        AND om.is_del = ''0''
        AND om.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9)
)
, ind_cond_info_table AS (
    SELECT
        value_6
        , value_7
        , value_8
        , value_9
        , value_10
        , value_11
        , value_12
        , value_13
        , amount
        , unit
        , comment
        , class_name
        , name
        , oij.ord_no
    FROM
        ntss_db5_om_rei_json orj
        INNER JOIN ntss_db5_om_iei_json oij
            ON orj.ord_no = oij.ord_no
            AND orj.cd = oij.cd
)
, ntss_db5_mst_list AS (
    SELECT
        ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
        , ''0'' AS puncture_class
        , ntss_db5_mst_e.in_hospital_cd_1 || cast(om.class_name as char (20)) AS class_name
        , ntss_db5_mst_e.equipment_name || cast(om.name as char (20)) AS names
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
        , om.ord_no AS ord_no
        , om.amount AS amount
        , om.unit AS unit
        , om.comment AS comments
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(om.value_6, ''99999999'') = ntss_db5_mst_e.equipment_cd
    WHERE
        om.value_6 IS NOT NULL
    UNION ALL
    SELECT
        ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
        , ''0'' AS puncture_class
        , ntss_db5_mst_e.in_hospital_cd_1 || cast(om.class_name as char (20)) AS class_name
        , ntss_db5_mst_e.equipment_name || cast(om.name as char (20)) AS names
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
        , om.ord_no AS ord_no
        , om.amount AS amount
        , om.unit AS unit
        , om.comment AS comments
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(om.value_7, ''99999999'') = ntss_db5_mst_e.equipment_cd
    WHERE
        om.value_7 IS NOT NULL
    UNION ALL
    SELECT
        ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
        , ''0'' AS puncture_class
        , ntss_db5_mst_e.in_hospital_cd_1 || cast(om.class_name as char (20)) AS class_name
        , ntss_db5_mst_e.equipment_name || cast(om.name as char (20)) AS names
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
        , om.ord_no AS ord_no
        , om.amount AS amount
        , om.unit AS unit
        , om.comment AS comments
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(om.value_8, ''99999999'') = ntss_db5_mst_e.equipment_cd
    WHERE
        om.value_8 IS NOT NULL
    UNION ALL
    SELECT
        ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
        , ''1'' AS puncture_class
        , ntss_db5_mst_e.in_hospital_cd_1 || cast(om.class_name as char (20)) AS class_name
        , ntss_db5_mst_e.equipment_name || cast(om.name as char (20)) AS names
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
        , om.ord_no AS ord_no
        , om.amount AS amount
        , om.unit AS unit
        , om.comment AS comments
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(om.value_9, ''99999999'') = ntss_db5_mst_e.equipment_cd
    WHERE
        om.value_9 IS NOT NULL
    UNION ALL
    SELECT
        ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
        , ''2'' AS puncture_class
        , ntss_db5_mst_e.in_hospital_cd_1 || cast(om.class_name as char (20)) AS class_name
        , ntss_db5_mst_e.equipment_name || cast(om.name as char (20)) AS names
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
        , om.ord_no AS ord_no
        , om.amount AS amount
        , om.unit AS unit
        , om.comment AS comments
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(om.value_10, ''99999999'') = ntss_db5_mst_e.equipment_cd
    WHERE
        om.value_10 IS NOT NULL
    UNION ALL
    SELECT
        ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
        , ''3'' AS puncture_class
        , ntss_db5_mst_e.in_hospital_cd_1 || cast(om.class_name as char (20)) AS class_name
        , ntss_db5_mst_e.equipment_name || cast(om.name as char (20)) AS names
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
        , om.ord_no AS ord_no
        , om.amount AS amount
        , om.unit AS unit
        , om.comment AS comments
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(om.value_11, ''99999999'') = ntss_db5_mst_e.equipment_cd
    WHERE
        om.value_11 IS NOT NULL
    UNION ALL
    SELECT
        ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
        , ''0'' AS puncture_class
        , ntss_db5_mst_e.in_hospital_cd_1 || cast(om.class_name as char (20)) AS class_name
        , ntss_db5_mst_e.equipment_name || cast(om.name as char (20)) AS names
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
        , om.ord_no AS ord_no
        , om.amount AS amount
        , om.unit AS unit
        , om.comment AS comments
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(om.value_12, ''99999999'') = ntss_db5_mst_e.equipment_cd
    WHERE
        om.value_12 IS NOT NULL
    UNION ALL
    SELECT
        ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
        , ''0'' AS puncture_class
        , ntss_db5_mst_e.in_hospital_cd_1 || cast(om.class_name as char (20)) AS class_name
        , ntss_db5_mst_e.equipment_name || cast(om.name as char (20)) AS names
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
        , om.ord_no AS ord_no
        , om.amount AS amount
        , om.unit AS unit
        , om.comment AS comments
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(om.value_13, ''99999999'') = ntss_db5_mst_e.equipment_cd
    WHERE
        om.value_13 IS NOT NULL
    UNION ALL
    SELECT
        ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
        , '''' AS puncture_class
        , '''' AS class_name
        , '''' AS names
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
        , om.ord_no AS ord_no
        , '''' AS amount
        , '''' AS unit
        , '''' AS comments
    FROM
        ntss_db5_om_rei_json om
        LEFT JOIN ntss_db5_mst_e
            ON om.cd = cast(ntss_db5_mst_e.equipment_cd as char (4))
)
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , ntss_db5_om.treat_date AS dialysisdate    --透析日
    , CASE
        WHEN ntss_db5_om_1.treat_date_count > 1
            THEN 1
        ELSE 0
        END AS plural                           --同日複数回
    , row_number() over (ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
    , ntss_db5_mst_list.in_hospital_cd_1 AS equipcd --医療材料コード(院内コード1)
    , ntss_db5_mst_list.in_hospital_cd_2 AS equipcd2 --医療材料コード(院内コード2)
    , ntss_db5_mst_list.class_name AS equipclassname --医療材料分類名
    , SUBSTR(ntss_db5_mst_list.names, 0, 14) AS equipname --医療材料名
    , ntss_db5_mst_list.puncture_class AS punctureclass --医療材料名
    , ntss_db5_mst_list.amount AS amount        --数量
    , ntss_db5_mst_list.unit AS unit            --数量
    , ntss_db5_mst_list.comments AS comments    --コメント
    , '''' AS indicatorcd                         --指示者
    , ntss_db5_om_iic_json ->> ''ind_user_id'' AS userid
    , CASE
        WHEN ntss_db5_om.treat_type = 0
            THEN ''1''
        ELSE ''0''
        END AS opeindplan                       --予定作成区分
FROM
    ord_main ntss_db5_om
    INNER JOIN ntss_db5_om_1
        ON ntss_db5_om_1.ord_no = ntss_db5_om.ord_no
    INNER JOIN ntss_db5_mst_list
        ON ntss_db5_mst_list.ord_no = ntss_db5_om.ord_no
    CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_ind_comment_info ::json) ntss_db5_om_iic_json
WHERE
    ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.facility_cd = @facilityCd
    AND ntss_db5_om.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9)
    AND ntss_db5_om.pat_id IS NOT NULL;',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',null);


insert into ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) values
    (-2210,'WITH ntss_db5_om_1 AS (
			SELECT
				ntss_db5_om_1.ord_no AS ord_no
				,ntss_db5_om_1.pat_id
				,ntss_db5_om_1.treat_date AS treat_date
				,COUNT( ntss_db5_om_1.treat_date ) AS treat_date_count
			FROM
				ord_main ntss_db5_om_1
			WHERE 1=1
				AND ntss_db5_om_1.facility_cd = @facilityCd
				AND ntss_db5_om_1.treat_date IS NOT NULL
				AND ntss_db5_om_1.treat_date BETWEEN SUBSTR( @fromDate, 0, 9 )
				AND SUBSTR( @toDate, 0, 9 )
			GROUP BY
				ntss_db5_om_1.ord_no,
				ntss_db5_om_1.pat_id,
				ntss_db5_om_1.treat_date
		),
		ntss_db5_mst_m AS (
			SELECT
				ntss_db5_om.ord_no AS ord_no
				,ntss_db5_mst_m.in_hospital_cd_1 AS in_hospital_cd_1
				,ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2
				,ntss_db5_om_imi_json ->> ''name'' AS name --薬剤名
				,ntss_db5_om_imi_json ->> ''class_name'' AS class_name --薬剤分類名
				,ntss_db5_om_imi_json ->> ''amount'' AS amount --数量
				,ntss_db5_om_imi_json ->> ''unit'' AS unit --単位
				,ntss_db5_om_imi_json ->> ''timing_name'' AS timing_name --投与時間帯名
				,ntss_db5_om_imi_json ->> ''procedure_name'' AS procedure_name --手技名
				,ntss_db5_om_imi_json ->> ''comment'' AS comment --コメント
			FROM ord_main ntss_db5_om
				CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_medi_info ::json) ntss_db5_om_imi_json
				LEFT JOIN mst_medicine ntss_db5_mst_m
				ON cast(ntss_db5_mst_m.medicine_cd as char(10)) = cast(ntss_db5_om_imi_json ->> ''cd'' as char(10))
			WHERE ntss_db5_om.facility_cd = @facilityCd
			AND ntss_db5_om.treat_date BETWEEN SUBSTR( @fromDate, 0, 9 )
			AND SUBSTR( @toDate, 0, 9 )
		),
		ntss_db5_mst_p AS (
			SELECT
				ntss_db5_om.ord_no AS ord_no
				,ntss_db5_mst_p.in_hospital_cd_a1 AS in_hospital_cd_1
				,ntss_db5_mst_p.in_hospital_cd_a2 AS in_hospital_cd_2
			FROM ord_main ntss_db5_om
				CROSS JOIN LATERAL json_array_elements(ntss_db5_om.rst_medi_info ::json) ntss_db5_om_rmi_json
				LEFT JOIN mst_procedure ntss_db5_mst_p
				ON cast(ntss_db5_mst_p.procedure_cd as char(10)) = cast(ntss_db5_om_rmi_json ->> ''procedure_cd'' as char(10))
			WHERE ntss_db5_om.facility_cd = @facilityCd
			AND ntss_db5_om.treat_date BETWEEN SUBSTR( @fromDate, 0, 9 )
			AND SUBSTR( @toDate, 0, 9 )
		)
		SELECT
			'''' AS hosppatid --患者ID
			,ntss_db5_om.pat_id AS patid
			,ntss_db5_om.treat_date AS dialysisdate --透析日
			,CASE
				WHEN ntss_db5_om_1.treat_date_count > 1
				THEN 1
				ELSE 0
			 END AS plural --同日複数回
			,row_number() over(ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
			,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
			,ntss_db5_mst_m.in_hospital_cd_1 AS medicinecd --薬剤コード(院内コード1)
			,ntss_db5_mst_m.in_hospital_cd_2 AS medicinecd2 --薬剤コード(院内コード2)
			,ntss_db5_mst_m.name AS medicinename --薬剤名
			,ntss_db5_mst_m.class_name AS mediclassname --薬剤分類名
			,ntss_db5_mst_m.amount AS amount --数量
			,ntss_db5_mst_m.unit AS unit --単位
			,ntss_db5_mst_m.timing_name AS timingname --投与時間帯名
			,ntss_db5_mst_p.in_hospital_cd_1 AS procedurecd --手技コード(院内コード1)
			,ntss_db5_mst_p.in_hospital_cd_2 AS procedurecd2 --手技コード(院内コード2)
			,ntss_db5_mst_m.procedure_name AS procedurename --手技名
			,ntss_db5_mst_m.comment AS comments --コメント
			,'''' AS indicatorcd --指示者
			,ntss_db5_om_iic_json ->> ''ind_user_id'' AS userid
			,CASE
				WHEN ntss_db5_om.treat_type = 0
				THEN ''1''
				ELSE ''0''
			 END AS opeindplan --予定作成区分
		FROM
			ord_main ntss_db5_om
			INNER JOIN ntss_db5_om_1
			ON ntss_db5_om_1.ord_no = ntss_db5_om.ord_no
			INNER JOIN ntss_db5_mst_m
			ON ntss_db5_mst_m.ord_no = ntss_db5_om.ord_no
			INNER JOIN ntss_db5_mst_p
			ON ntss_db5_mst_p.ord_no = ntss_db5_om.ord_no
			CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_ind_comment_info ::json) ntss_db5_om_iic_json
		WHERE ntss_db5_om.is_del = ''0''
			AND ntss_db5_om.facility_cd = @facilityCd
			AND ntss_db5_om.treat_date BETWEEN SUBSTR( @fromDate, 0, 9 )
			AND SUBSTR( @toDate, 0, 9 )
			AND ntss_db5_om.pat_id IS NOT NULL;',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',null);


