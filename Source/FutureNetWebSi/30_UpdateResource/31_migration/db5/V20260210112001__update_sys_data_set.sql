DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-2501);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2501, '-- 性能検証のため一時的なアップ。ロールバックには下部のコメントアウトブロックを使用する
-- 【SQL_CD=-2501]
WITH re_loop_rate_table AS ( --再循環率
    SELECT
        om.ord_no AS ord_no
        , json_rr.value::jsonb ->> ''rate'' AS relooprate
    FROM (
        SELECT
            om.ord_no
            , om.rst_weight_info #>> ''{recrcl_rt, "valid_no"}'' AS valid_no
            , om.rst_weight_info #> ''{recrcl_rt}'' AS recrcl_rt
        FROM ord_main om
        WHERE om.facility_cd = @facilityCd
          AND om.rst_dialysis_state BETWEEN ''1'' AND''5''
          AND om.rst_weight_info IS NOT NULL
          AND om.rst_weight_info #> ''{recrcl_rt}'' <> ''null''
    ) AS om
    CROSS JOIN lateral jsonb_each_text(om.recrcl_rt::jsonb) json_rr
    WHERE json_rr.key = om.valid_no
)
SELECT
    '''' AS hosppatid --患者ID
    ,om.pat_id AS patid
    ,'''' AS name --氏名
    ,om.treat_date AS dialysisdate --透析日
    ,om.ord_no AS dialysisno --透析番号
    ,to_char(om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    ,m_b.in_hospital_cd_1 AS bedno --ベッド番号
    ,om.rst_bed_name AS bedname --ベッド名
    ,m_mac.in_hospital_cd_1 AS deviceno --装置番号
    ,om.rst_machine_name AS devicename --装置名
    ,m_k.in_hospital_cd_1 AS kurcd --クール
    ,om.rst_kur_name AS kurname --クール名
    ,to_char(om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS startdate --透析開始日時
    ,to_char(om.rst_end_date, ''YYYY-MM-DD hh24:mi:ss'') AS enddate --透析終了日時
    ,round(date_part(''epoch'',om.rst_end_date - om.rst_start_date)::NUMERIC / 60) AS dialysistime --透析時間
    ,om.rst_cond_info ::jsonb #>> ''{1,value}'' AS plandialysistime --予定透析時間
    ,om.rst_dialysis_cnt AS dialysisnum --透析回数
    ,lw.last_weight AS lastweight --前回体重
    ,om.rst_weight_info #>> ''{weight_before}'' AS weightbefore --前体重
    ,om.rst_weight_info #>> ''{weight_after}'' AS weightafter --後体重
    ,mm_b.monitor_data ->> ''90''  AS bpbeforemax --透析前最高血圧
    ,mm_b.monitor_data ->> ''91''  AS bpbeforemin --透析前最低血圧
    ,mm_b.monitor_data ->> ''92''  AS bpbeforeave --透析前平均血圧
    ,mm_a.monitor_data ->> ''90''  AS bpaftermax --透析後最高血圧
    ,mm_a.monitor_data ->> ''91''  AS bpaftermin --透析後最低血圧
    ,mm_a.monitor_data ->> ''92''  AS bpafterave --透析後平均血圧
    ,om.rst_weight_info #>> ''{water_removal_target}'' AS waterremovaltarget --目標除水量
    ,om.rst_off_water_info #>> ''{name_1}'' AS revisename1 --除水補正項目１
    ,om.rst_off_water_info #>> ''{weight_1}'' AS reviseweight1 --除水補正値１
    ,om.rst_off_water_info #>> ''{name_2}'' AS revisename2 --除水補正項目２
    ,om.rst_off_water_info #>> ''{weight_2}'' AS reviseweight2 --除水補正値２
    ,om.rst_off_water_info #>> ''{name_3}'' AS revisename3 --除水補正項目３
    ,om.rst_off_water_info #>> ''{weight_3}'' AS reviseweight3 --除水補正値３
    ,om.rst_off_water_info #>> ''{name_4}'' AS revisename4 --除水補正項目４
    ,om.rst_off_water_info #>> ''{weight_4}'' AS reviseweight4 --除水補正値４
    ,om.rst_off_water_info #>> ''{name_5}'' AS revisename5 --除水補正項目５
    ,om.rst_off_water_info #>> ''{weight_5}'' AS reviseweight5 --除水補正値５
    ,mm_b.monitor_data ->> ''93'' AS pulsebefore --透析前脈拍
    ,mm_a.monitor_data ->> ''93'' AS pulseafter --透析後脈拍
    ,CONCAT(om.rst_charge_user_info #>> ''{user_last_name_1}''
        ,''　''
        , om.rst_charge_user_info #>> ''{user_first_name_1}'') AS charge1name --担当者１
    ,CONCAT(om.rst_charge_user_info #>> ''{user_last_name_2}''
        ,''　''
        , om.rst_charge_user_info #>> ''{user_first_name_2}'') AS charge2name --担当者２
    ,to_char((om.rst_charge_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS chargedate1 --担当日時１
    ,to_char((om.rst_charge_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS chargedate2 --担当日時２
    ,CONCAT(om.rst_puncture_user_info #>> ''{user_last_name_1}''
        ,''　''
        , om.rst_puncture_user_info #>> ''{user_first_name_1}'') AS puncture1name --穿刺者１
    ,CONCAT(om.rst_puncture_user_info #>> ''{user_last_name_2}''
        ,''　''
        , om.rst_puncture_user_info #>> ''{user_first_name_2}'') AS puncture2name --穿刺者２
    ,to_char((om.rst_puncture_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS puncturedate1 --穿刺日時１
    ,to_char((om.rst_puncture_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS puncturedate2 --穿刺日時２
    ,CONCAT(om.rst_return_user_info #>> ''{user_last_name_1}''
        ,''　''
        , om.rst_return_user_info #>> ''{user_first_name_1}'') AS collect1name --回収者１
    ,CONCAT(om.rst_return_user_info #>> ''{user_last_name_2}''
        ,''　''
        , om.rst_return_user_info #>> ''{user_first_name_2}'') AS collect2name --回収者２
    ,to_char((om.rst_return_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS collectdate1 --回収日時１
    ,to_char((om.rst_return_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS collectdate2 --回収日時２
    ,om.rst_in_out_class AS inoutflg --入外
    ,om.rst_weight_info #>> ''{kt_v_measure}'' AS ktvmeasure --Kt/v測定値
    ,om.rst_weight_info #>> ''{urr}'' AS urr --URR
    ,re_loop_rate_table.relooprate AS relooprate --再循環率
    ,om.rst_weight_info #>> ''{ihdf_pll}'' AS pullleaveamount --I-HDF引き残し量
    ,om.rst_weight_info #>> ''{sttc_vns_prssr}'' AS staticvenouspressure --静的静脈圧
    ,om.rst_weight_info #>> ''{iap_rt}'' AS venousaccesspressureratio --IAP ratio
FROM 
    ord_main om

-- ★ 前回体重を直前1件だけ取得
LEFT JOIN LATERAL (
    SELECT
        om2.rst_weight_info ->> ''weight_after'' AS last_weight
    FROM ord_main om2
    JOIN mst_treatment m_tr2
      ON om2.rst_treatment_cd = m_tr2.treatment_cd
     AND m_tr2.facility_cd = @facilityCd
    WHERE
        om2.pat_id = om.pat_id
        AND om2.rst_start_date < om.rst_start_date
        AND om2.facility_cd = @facilityCd
        AND om2.is_del = ''0''
        AND m_tr2.device_mode <> 9
    ORDER BY om2.rst_start_date DESC
    LIMIT 1
) lw ON true

LEFT JOIN mst_bed m_b
  ON m_b.bed_cd = om.rst_bed_cd
 AND m_b.facility_cd = @facilityCd
 AND m_b.is_del = ''0''
 AND m_b.is_disp = ''1''
LEFT JOIN mst_machine m_mac
  ON m_mac.machine_no = om.rst_machine_no
 AND m_mac.facility_cd = @facilityCd
 AND m_mac.is_del = ''0''
 AND m_mac.is_disp = ''1''
LEFT JOIN mst_kur m_k
  ON m_k.kur_cd = om.rst_kur_cd
 AND m_k.facility_cd = @facilityCd
 AND m_k.is_del = ''0''
    LEFT JOIN mni_monitor mm_b
    ON mm_b.ord_no = om.ord_no
    AND mm_b.facility_cd = @facilityCd
    AND mm_b.data_type = ''5''
    AND mm_b.monitor_data IS NOT NULL
    AND mm_b.is_del = ''0''
LEFT JOIN mni_monitor mm_a
    ON mm_a.ord_no = om.ord_no
    AND mm_a.facility_cd = @facilityCd
    AND mm_a.data_type = ''6''
    AND mm_a.monitor_data IS NOT NULL
    AND mm_a.is_del = ''0''
LEFT JOIN re_loop_rate_table
  ON re_loop_rate_table.ord_no = om.ord_no
WHERE
    om.is_del = ''0''
    AND om.facility_cd = @facilityCd
    AND om.rst_dialysis_state BETWEEN ''1'' AND''5''
    AND om.pat_id IS NOT NULL;



--WITH last_weight_table AS ( --前回体重導出用
--SELECT ord_no, last_weight FROM (
--    SELECT
--        om.ord_no AS ord_no
--        ,LAG(rst_weight_info, -1) OVER (PARTITION BY om.pat_id ORDER BY om.rst_start_date DESC) ->> ''weight_after'' AS last_weight
--    FROM ord_main om
--    JOIN mst_treatment m_tr
--    ON om.rst_treatment_cd = m_tr.treatment_cd
--    AND m_tr.facility_cd = @facilityCd
--    WHERE om.facility_cd = @facilityCd
--    AND om.is_del = ''0''
--    AND m_tr.device_mode <> 9
--    ) AS om2
--),
--re_loop_rate_table AS ( --再循環率
--    SELECT
--        om.ord_no AS ord_no
--        , json_rr.value::jsonb ->> ''rate'' AS relooprate
--    FROM (
--        SELECT
--            om.ord_no
--            , om.rst_weight_info #>> ''{recrcl_rt, "valid_no"}'' AS valid_no
--            , om.rst_weight_info #> ''{recrcl_rt}'' AS recrcl_rt
--        FROM ord_main om
--        WHERE om.facility_cd = @facilityCd
--        AND om.rst_dialysis_state BETWEEN ''1'' AND''5''
--        AND om.rst_weight_info IS NOT NULL
--        AND om.rst_weight_info #> ''{recrcl_rt}'' <> ''null''
--    ) AS om
--    CROSS JOIN lateral jsonb_each_text(om.recrcl_rt::jsonb) json_rr
--    WHERE json_rr.key = om.valid_no
--)
--SELECT
--    '''' AS hosppatid --患者ID
--    ,om.pat_id AS patid
--    ,'''' AS name --氏名
--    ,om.treat_date AS dialysisdate --透析日
--    ,om.ord_no AS dialysisno --透析番号
--    ,to_char(om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
--    ,m_b.in_hospital_cd_1 AS bedno --ベッド番号
--    ,om.rst_bed_name AS bedname --ベッド名
--    ,m_mac.in_hospital_cd_1 AS deviceno --装置番号
--    ,om.rst_machine_name AS devicename --装置名
--    ,m_k.in_hospital_cd_1 AS kurcd --クール
--    ,om.rst_kur_name AS kurname --クール名
--    ,to_char(om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS startdate --透析開始日時
--    ,to_char(om.rst_end_date, ''YYYY-MM-DD hh24:mi:ss'') AS enddate --透析終了日時
--    ,round(date_part(''epoch'',om.rst_end_date - om.rst_start_date)::NUMERIC / 60) AS dialysistime --透析時間
--    ,om.rst_cond_info ::jsonb #>> ''{1,value}'' AS plandialysistime --予定透析時間
--    ,om.rst_dialysis_cnt AS dialysisnum --透析回数
--    ,last_weight_table.last_weight AS lastweight --前回体重
--    ,om.rst_weight_info #>> ''{weight_before}'' AS weightbefore --前体重
--    ,om.rst_weight_info #>> ''{weight_after}'' AS weightafter --後体重
--    ,mm_b.monitor_data ->> ''90''  AS bpbeforemax --透析前最高血圧
--    ,mm_b.monitor_data ->> ''91''  AS bpbeforemin --透析前最低血圧
--    ,mm_b.monitor_data ->> ''92''  AS bpbeforeave --透析前平均血圧
--    ,mm_a.monitor_data ->> ''90''  AS bpaftermax --透析後最高血圧
--    ,mm_a.monitor_data ->> ''91''  AS bpaftermin --透析後最低血圧
--    ,mm_a.monitor_data ->> ''92''  AS bpafterave --透析後平均血圧
--    ,om.rst_weight_info #>> ''{water_removal_target}'' AS waterremovaltarget --目標除水量
--    ,om.rst_off_water_info #>> ''{name_1}'' AS revisename1 --除水補正項目１
--    ,om.rst_off_water_info #>> ''{weight_1}'' AS reviseweight1 --除水補正値１
--    ,om.rst_off_water_info #>> ''{name_2}'' AS revisename2 --除水補正項目２
--    ,om.rst_off_water_info #>> ''{weight_2}'' AS reviseweight2 --除水補正値２
--    ,om.rst_off_water_info #>> ''{name_3}'' AS revisename3 --除水補正項目３
--    ,om.rst_off_water_info #>> ''{weight_3}'' AS reviseweight3 --除水補正値３
--    ,om.rst_off_water_info #>> ''{name_4}'' AS revisename4 --除水補正項目４
--    ,om.rst_off_water_info #>> ''{weight_4}'' AS reviseweight4 --除水補正値４
--    ,om.rst_off_water_info #>> ''{name_5}'' AS revisename5 --除水補正項目５
--    ,om.rst_off_water_info #>> ''{weight_5}'' AS reviseweight5 --除水補正値５
--    ,mm_b.monitor_data ->> ''93'' AS pulsebefore --透析前脈拍
--    ,mm_a.monitor_data ->> ''93'' AS pulseafter --透析後脈拍
--    ,CONCAT(om.rst_charge_user_info #>> ''{user_last_name_1}''
--        ,''　''
--        , om.rst_charge_user_info #>> ''{user_first_name_1}'') AS charge1name --担当者１
--    ,CONCAT(om.rst_charge_user_info #>> ''{user_last_name_2}''
--        ,''　''
--        , om.rst_charge_user_info #>> ''{user_first_name_2}'') AS charge2name --担当者２
--    ,to_char((om.rst_charge_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS chargedate1 --担当日時１
--    ,to_char((om.rst_charge_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS chargedate2 --担当日時２
--    ,CONCAT(om.rst_puncture_user_info #>> ''{user_last_name_1}''
--        ,''　''
--        , om.rst_puncture_user_info #>> ''{user_first_name_1}'') AS puncture1name --穿刺者１
--    ,CONCAT(om.rst_puncture_user_info #>> ''{user_last_name_2}''
--        ,''　''
--        , om.rst_puncture_user_info #>> ''{user_first_name_2}'') AS puncture2name --穿刺者２
--    ,to_char((om.rst_puncture_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS puncturedate1 --穿刺日時１
--    ,to_char((om.rst_puncture_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS puncturedate2 --穿刺日時２
--    ,CONCAT(om.rst_return_user_info #>> ''{user_last_name_1}''
--        ,''　''
--        , om.rst_return_user_info #>> ''{user_first_name_1}'') AS collect1name --回収者１
--    ,CONCAT(om.rst_return_user_info #>> ''{user_last_name_2}''
--        ,''　''
--        , om.rst_return_user_info #>> ''{user_first_name_2}'') AS collect2name --回収者２
--    ,to_char((om.rst_return_user_info #>> ''{date_1}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS collectdate1 --回収日時１
--    ,to_char((om.rst_return_user_info #>> ''{date_2}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'') AS collectdate2 --回収日時２
--    ,om.rst_in_out_class AS inoutflg --入外
--    ,om.rst_weight_info #>> ''{kt_v_measure}'' AS ktvmeasure --Kt/v測定値
--    ,om.rst_weight_info #>> ''{urr}'' AS urr --URR
--    ,re_loop_rate_table.relooprate AS relooprate --再循環率
--    ,om.rst_weight_info #>> ''{ihdf_pll}'' AS pullleaveamount --I-HDF引き残し量
--    ,om.rst_weight_info #>> ''{sttc_vns_prssr}'' AS staticvenouspressure --静的静脈圧
--    ,om.rst_weight_info #>> ''{iap_rt}'' AS venousaccesspressureratio --IAP ratio
--FROM
--    ord_main om
--    LEFT JOIN mst_bed m_b
--    ON m_b.bed_cd = om.rst_bed_cd
--    AND m_b.facility_cd = @facilityCd
--    AND m_b.is_del = ''0''
--    AND m_b.is_disp = ''1''
--    LEFT JOIN mst_machine m_mac
--    ON m_mac.machine_no = om.rst_machine_no
--    AND m_mac.facility_cd = @facilityCd
--    AND m_mac.is_del = ''0''
--    AND m_mac.is_disp = ''1''
--    LEFT JOIN mst_kur m_k
--    ON m_k.kur_cd = om.rst_kur_cd
--    AND m_k.facility_cd = @facilityCd
--    AND m_k.is_del = ''0''
--    LEFT JOIN last_weight_table
--    ON last_weight_table.ord_no = om.ord_no
--    LEFT JOIN mni_monitor mm_b
--    ON mm_b.ord_no = om.ord_no
--    AND mm_b.facility_cd = @facilityCd
--    AND mm_b.data_type = ''5''
--    AND mm_b.monitor_data IS NOT NULL
--    AND mm_b.is_del = ''0''
--    LEFT JOIN mni_monitor mm_a
--    ON mm_a.ord_no = om.ord_no
--    AND mm_a.facility_cd = @facilityCd
--    AND mm_a.data_type = ''6''
--    AND mm_a.monitor_data IS NOT NULL
--    AND mm_a.is_del = ''0''
--    LEFT JOIN re_loop_rate_table
--    ON re_loop_rate_table.ord_no = om.ord_no
--WHERE
--    om.is_del = ''0''
--    AND om.facility_cd = @facilityCd
--    AND om.rst_dialysis_state BETWEEN ''1'' AND''5''
--    AND om.pat_id IS NOT NULL;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
