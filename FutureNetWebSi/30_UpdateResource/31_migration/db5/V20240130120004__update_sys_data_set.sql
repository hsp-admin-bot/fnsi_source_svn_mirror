DELETE FROM ntss.sys_data_set
WHERE sql_cd IN(-2090,-2091)
;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2091, 'SELECT
			ntss_db6_ppm.pat_id AS patid
			,ntss_db6_ppm.hosp_pat_id AS hosppatid
			,REPLACE(personal_info_decrypt(ntss_db6_ppm.pat_last_name)|| '' '' ||personal_info_decrypt(ntss_db6_ppm.pat_first_name), ''"'', '''') AS names --氏名
		FROM
			pat_personal_main ntss_db6_ppm
		WHERE
			ntss_db6_ppm.is_del = ''0''
			AND ntss_db6_ppm.facility_cd = @facilityCd', 3, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2090, 'WITH ntss_db5_mst_b AS (
    SELECT
        ntss_db5_mst_b.bed_cd
        ,ntss_db5_mst_b.in_hospital_cd_1 AS in_hospital_cd_1
        ,ntss_db5_mst_b.up_date AS up_date
    FROM mst_bed ntss_db5_mst_b
    WHERE ntss_db5_mst_b.facility_cd = @facilityCd
),
ntss_db5_mst_m AS (
    SELECT
        ntss_db5_mst_m.machine_no
        ,ntss_db5_mst_m.machine_serial AS machine_serial
        ,ntss_db5_mst_m.up_date AS up_date
    FROM mst_machine ntss_db5_mst_m
    WHERE ntss_db5_mst_m.facility_cd = @facilityCd
),
ntss_db5_mst_k AS (
    SELECT
        ntss_db5_mst_k.kur_cd
        ,ntss_db5_mst_k.in_hospital_cd_1 AS in_hospital_cd_1
        ,ntss_db5_mst_k.up_date AS up_date
    FROM mst_kur ntss_db5_mst_k
    WHERE ntss_db5_mst_k.facility_cd = @facilityCd
),
ntss_db5_mst_t AS (
    SELECT
        ntss_db5_mst_t.treatment_cd
        , ntss_db5_mst_t.device_mode
    FROM mst_treatment ntss_db5_mst_t
    WHERE ntss_db5_mst_t.facility_cd = @facilityCd
),
last_weight_table AS ( --前回体重導出用
    SELECT
        om.ord_no AS ord_no
        ,LAG(rst_weight_info, -1) OVER (PARTITION BY om.pat_id ORDER BY om.rst_start_date DESC) ->> ''weight_after'' AS last_weight
    FROM ord_main om
    LEFT JOIN ntss_db5_mst_t
    ON om.rst_treatment_cd = ntss_db5_mst_t.treatment_cd
    WHERE om.facility_cd = @facilityCd
    AND om.is_del = ''0''
    AND om.rst_dialysis_state = ''6''
    AND ntss_db5_mst_t.device_mode <> 9
),
ntss_db5_mni_m_1 AS ( --mni.mmonitorから取るテーブル　透析前
    SELECT
        mm.ord_no
        ,mm.monitor_data ->> ''90'' AS bp_max
        ,mm.monitor_data ->> ''91'' AS bp_min
        ,mm.monitor_data ->> ''92'' AS bp_ave
        ,mm.monitor_data ->> ''93'' AS pulse
        ,mm.up_date AS up_date
    FROM mni_monitor mm
    WHERE mm.data_type = ''5''
    AND mm.monitor_data IS NOT NULL
    AND mm.facility_cd = @facilityCd
),
ntss_db5_mni_m_2 AS ( --mni.mmonitorから取るテーブル　透析後
    SELECT
        mm.ord_no
        ,mm.monitor_data ->> ''90'' AS bp_max
        ,mm.monitor_data ->> ''91'' AS bp_min
        ,mm.monitor_data ->> ''92'' AS bp_ave
        ,mm.monitor_data ->> ''93'' AS pulse
        ,mm.up_date AS up_date
    FROM mni_monitor mm
    WHERE mm.data_type = ''6''
    AND mm.monitor_data IS NOT NULL
    AND mm.facility_cd = @facilityCd
),
ntss_db5_mni_m_3 AS ( --mni.mmonitorから取るテーブル　再循環率
    SELECT
        mm.bio_moni_ctl_no
        ,mm.monitor_data ->> ''89'' AS relooprate
        ,mm.up_date AS up_date
    FROM mni_monitor mm
    WHERE mm.data_type = ''3''
    AND mm.monitor_data IS NOT NULL
    AND mm.facility_cd = @facilityCd
)
SELECT
    '''' AS hosppatid --患者ID
    ,ntss_db5_om.pat_id AS patid
    ,'''' AS names --氏名
    ,ntss_db5_om.treat_date AS dialysisdate --透析日
    ,ntss_db5_om.ord_no AS dialysisno --透析番号
    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    ,ntss_db5_mst_b.in_hospital_cd_1 AS bedno --ベッド番号
    ,ntss_db5_om.rst_bed_name AS bedname --ベッド名
    ,ntss_db5_mst_m.machine_serial AS deviceno --装置番号
    ,ntss_db5_om.rst_machine_name AS devicename --装置名
    ,ntss_db5_mst_k.in_hospital_cd_1 AS kurcd --クール
    ,ntss_db5_om.rst_kur_name AS kurname --クール名
    ,to_char(ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS startdate --透析開始日時
    ,to_char(ntss_db5_om.rst_end_date, ''YYYY-MM-DD hh24:mi:ss'') AS enddate --透析終了日時
    ,round(date_part(''epoch'',ntss_db5_om.rst_end_date - ntss_db5_om.rst_start_date)::NUMERIC / 60) AS dialysistime --透析時間
    ,ntss_db5_om.rst_cond_info ::json #>> ''{1,value}'' AS plandialysistime --予定透析時間
    ,ntss_db5_om.rst_dialysis_cnt AS dialysisnum --透析回数
    ,last_weight_table.last_weight AS lastweight --前回体重
    ,ntss_db5_om.rst_weight_info #>> ''{weight_before}'' AS weightbefore --前体重
    ,ntss_db5_om.rst_weight_info #>> ''{weight_after}'' AS weightafter --後体重
    ,ntss_db5_mni_m_1.bp_max AS bpbeforemax --透析前最高血圧
    ,ntss_db5_mni_m_1.bp_min AS bpbeforemin --透析前最低血圧
    ,ntss_db5_mni_m_1.bp_ave AS bpbeforeave --透析前平均血圧
    ,ntss_db5_mni_m_2.bp_max AS bpaftermax --透析後最高血圧
    ,ntss_db5_mni_m_2.bp_min AS bpaftermin --透析後最低血圧
    ,ntss_db5_mni_m_2.bp_ave AS bpafterave --透析後平均血圧
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
    ,ntss_db5_mni_m_1.pulse AS pulsebefore --透析前脈拍
    ,ntss_db5_mni_m_2.pulse AS pulseafter --透析後脈拍
    ,cast(ntss_db5_om.rst_charge_user_info #>> ''{user_last_name_1}'' AS char(20))
        ||''　''
        || cast(ntss_db5_om.rst_charge_user_info #>> ''{user_first_name_1}'' AS char(20)) AS charge1name --担当者１
    ,cast(ntss_db5_om.rst_charge_user_info #>> ''{user_last_name_2}'' AS char(20))
        ||''　''
        || cast(ntss_db5_om.rst_charge_user_info #>> ''{user_first_name_2}'' AS char(20)) AS charge2name --担当者２
    ,to_char((ntss_db5_om.rst_charge_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS chargedate1 --担当日時１
    ,to_char((ntss_db5_om.rst_charge_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS chargedate2 --担当日時２
    ,cast(ntss_db5_om.rst_puncture_user_info #>> ''{user_last_name_1}'' AS char(20))
        ||''　''
        || cast(ntss_db5_om.rst_puncture_user_info #>> ''{user_first_name_1}'' AS char(20)) AS puncture1name --穿刺者１
    ,cast(ntss_db5_om.rst_puncture_user_info #>> ''{user_last_name_2}'' AS char(20))
        ||''　''
        || cast(ntss_db5_om.rst_puncture_user_info #>> ''{user_first_name_2}'' AS char(20)) AS puncture2name --穿刺者２
    ,to_char((ntss_db5_om.rst_puncture_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS puncturedate1 --穿刺日時１
    ,to_char((ntss_db5_om.rst_puncture_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS puncturedate2 --穿刺日時２
    ,cast(ntss_db5_om.rst_return_user_info #>> ''{user_last_name_1}'' AS char(20))
        ||''　''
        || cast(ntss_db5_om.rst_return_user_info #>> ''{user_first_name_1}'' AS char(20)) AS collect1name --回収者１
    ,cast(ntss_db5_om.rst_return_user_info #>> ''{user_last_name_2}'' AS char(20))
        ||''　''
        || cast(ntss_db5_om.rst_return_user_info #>> ''{user_first_name_2}'' AS char(20)) AS collect2name --回収者２
    ,to_char((ntss_db5_om.rst_return_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS collectdate1 --回収日時１
    ,to_char((ntss_db5_om.rst_return_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS collectdate2 --回収日時２
    ,ntss_db5_om.rst_in_out_class AS inoutflg --入外
    ,ntss_db5_om.rst_kt_v AS ktvmeasure --Kt/v測定値
    ,ntss_db5_om.rst_weight_info #>> ''{urr}'' AS urr --URR
    ,ntss_db5_mni_m_3.relooprate AS relooprate --再循環率
    ,ntss_db5_om.rst_weight_info #>> ''{ihdf_pll}'' AS pullleaveamount --I-HDF引き残し量
    ,ntss_db5_om.rst_weight_info #>> ''{add_total}'' AS addtotal --除水積算値
    ,ntss_db5_om.rst_weight_info #>> ''{sttc_vns_prssr}'' AS staticvenouspressure --静的静脈圧
    ,ntss_db5_om.rst_weight_info #>> ''{iap_rt}'' AS venousaccesspressureratio --IAP ratio
FROM
    ord_main ntss_db5_om
    LEFT JOIN ntss_db5_mst_b
    ON ntss_db5_mst_b.bed_cd = ntss_db5_om.rst_bed_cd
    LEFT JOIN ntss_db5_mst_m
    ON ntss_db5_mst_m.machine_no = ntss_db5_om.rst_machine_no
    LEFT JOIN ntss_db5_mst_k
    ON ntss_db5_mst_k.kur_cd = ntss_db5_om.rst_kur_cd
    LEFT JOIN last_weight_table
    ON last_weight_table.ord_no = ntss_db5_om.ord_no
    LEFT JOIN ntss_db5_mni_m_1
    ON ntss_db5_mni_m_1.ord_no = ntss_db5_om.ord_no
    LEFT JOIN ntss_db5_mni_m_2
    ON ntss_db5_mni_m_2.ord_no = ntss_db5_om.ord_no
    LEFT JOIN ntss_db5_mni_m_3
    ON ntss_db5_mni_m_3.bio_moni_ctl_no ::text = ntss_db5_om.rst_weight_info #>> ''{re_loop_rate_main}''
WHERE
    ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.facility_cd = @facilityCd
    AND ntss_db5_om.rst_dialysis_state = ''6''
    AND (
        CASE
            WHEN @syncMode = ''update''
                THEN (
                (
                    ntss_db5_om.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'' ) AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'' )
                )
                OR (
                    ntss_db5_mst_m.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
                OR (
                    ntss_db5_mst_b.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
                OR (
                    ntss_db5_mst_k.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
                OR (
                    ntss_db5_mni_m_1.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
                OR (
                    ntss_db5_mni_m_2.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
                OR (
                    ntss_db5_mni_m_3.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
            )
            ELSE (CURRENT_DATE - INTERVAL ''1 YEAR'') < CAST(ntss_db5_om.treat_date as DATE)
                AND CAST(ntss_db5_om.treat_date as DATE) <= CURRENT_DATE
            END
    )
    AND ntss_db5_om.pat_id IS NOT NULL
ORDER BY ntss_db5_om.pat_id ASC
    ,ntss_db5_om.treat_date ASC
    ,ntss_db5_om.ord_no ASC;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', '2021-02-26 17:51:54.726', CURRENT_TIMESTAMP, NULL);