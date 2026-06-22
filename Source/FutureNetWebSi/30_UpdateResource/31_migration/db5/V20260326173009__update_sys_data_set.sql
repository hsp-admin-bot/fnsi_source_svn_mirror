delete from sys_data_set	
where sql_cd in (-2050,-2090,-2100,-2170,-2190,-2200,-2240,-2300,-2420,-2450,-2501);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2501, '-- 【SQL_CD=-2501】
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

--  前回体重を直前1件だけ取得
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
    AND om.pat_id IS NOT NULL;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2450, '-- 【SQL_CD=-2450】
WITH
  elements AS (
    SELECT
      ctlno,
      setname,
      elemkey,
      datapattern,
      defaultvalue
    FROM
      jsonb_to_recordset(
        ''[
    {"ctlno":"1","setname":"静脈圧自動設定警報幅上限HD/ECUM","elemkey":"dev-A-0100","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"100"},
    {"ctlno":"2","setname":"静脈圧自動設定警報幅下限HD/ECUM","elemkey":"dev-A-0101","datapattern":"1","defaultvalue":"-30","level1":"war","level2":"dev","level3":"A","level4":"101"},
    {"ctlno":"3","setname":"静脈圧自動設定警報限界上限","elemkey":"dev-A-0102","datapattern":"1","defaultvalue":"200","level1":"war","level2":"dev","level3":"A","level4":"102"},
    {"ctlno":"4","setname":"静脈圧自動設定警報限界下限","elemkey":"dev-A-0103","datapattern":"1","defaultvalue":"10","level1":"war","level2":"dev","level3":"A","level4":"103"},
    {"ctlno":"5","setname":"静脈圧固定警報上限","elemkey":"dev-A-0104","datapattern":"1","defaultvalue":"200","level1":"war","level2":"dev","level3":"A","level4":"104"},
    {"ctlno":"6","setname":"静脈圧固定警報下限","elemkey":"dev-A-0105","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"105"},
    {"ctlno":"7","setname":"静脈圧自動設定警報幅上限HDF/HF","elemkey":"dev-A-0106","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"106"},
    {"ctlno":"8","setname":"静脈圧自動設定警報幅下限HDF/HF","elemkey":"dev-A-0107","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"107"},
    {"ctlno":"9","setname":"静脈圧固定警報上限準備回収","elemkey":"dev-A-0108","datapattern":"1","defaultvalue":"250","level1":"war","level2":"dev","level3":"A","level4":"108"},
    {"ctlno":"10","setname":"静脈圧固定警報下限準備回収","elemkey":"dev-A-0109","datapattern":"1","defaultvalue":"-200","level1":"war","level2":"dev","level3":"A","level4":"109"},
    {"ctlno":"11","setname":"静脈圧固定警報上限ＳＮ","elemkey":"dev-A-0110","datapattern":"1","defaultvalue":"400","level1":"war","level2":"dev","level3":"A","level4":"110"},
    {"ctlno":"12","setname":"静脈圧固定警報下限ＳＮ","elemkey":"dev-A-0111","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"111"},
    {"ctlno":"13","setname":"液圧自動設定警報幅上限HD/ECUM","elemkey":"dev-A-0112","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"112"},
    {"ctlno":"14","setname":"液圧自動設定警報幅下限HD/ECUM","elemkey":"dev-A-0113","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"113"},
    {"ctlno":"15","setname":"液圧自動設定警報限界上限","elemkey":"dev-A-0114","datapattern":"1","defaultvalue":"300","level1":"war","level2":"dev","level3":"A","level4":"114"},
    {"ctlno":"16","setname":"液圧自動設定警報限界下限","elemkey":"dev-A-0115","datapattern":"1","defaultvalue":"-300","level1":"war","level2":"dev","level3":"A","level4":"115"},
    {"ctlno":"17","setname":"液圧固定警報上限","elemkey":"dev-A-0116","datapattern":"1","defaultvalue":"300","level1":"war","level2":"dev","level3":"A","level4":"116"},
    {"ctlno":"18","setname":"液圧固定警報下限","elemkey":"dev-A-0117","datapattern":"1","defaultvalue":"-300","level1":"war","level2":"dev","level3":"A","level4":"117"},
    {"ctlno":"19","setname":"液圧自動設定警報幅上限HDF/HF","elemkey":"dev-A-0118","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"118"},
    {"ctlno":"20","setname":"液圧自動設定警報幅下限HDF/HF","elemkey":"dev-A-0119","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"119"},
    {"ctlno":"21","setname":"液圧自動設定警報幅上限ＳＮ","elemkey":"dev-A-0120","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"120"},
    {"ctlno":"22","setname":"液圧自動設定警報幅下限ＳＮ","elemkey":"dev-A-0121","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"121"},
    {"ctlno":"23","setname":"液圧自動設定警報限界上限ＳＮ","elemkey":"dev-A-0122","datapattern":"1","defaultvalue":"300","level1":"war","level2":"dev","level3":"A","level4":"122"},
    {"ctlno":"24","setname":"液圧自動設定警報限界下限ＳＮ","elemkey":"dev-A-0123","datapattern":"1","defaultvalue":"-300","level1":"war","level2":"dev","level3":"A","level4":"123"},
    {"ctlno":"25","setname":"液圧固定警報上限ＳＮ","elemkey":"dev-A-0124","datapattern":"1","defaultvalue":"300","level1":"war","level2":"dev","level3":"A","level4":"124"},
    {"ctlno":"26","setname":"液圧固定警報下限ＳＮ","elemkey":"dev-A-0125","datapattern":"1","defaultvalue":"-300","level1":"war","level2":"dev","level3":"A","level4":"125"},
    {"ctlno":"27","setname":"ＴＭＰ自動追従警報幅上限HD/ECUM","elemkey":"dev-A-0126","datapattern":"1","defaultvalue":"20","level1":"war","level2":"dev","level3":"A","level4":"126"},
    {"ctlno":"28","setname":"ＴＭＰ自動追従警報幅下限HD/ECUM","elemkey":"dev-A-0127","datapattern":"1","defaultvalue":"-20","level1":"war","level2":"dev","level3":"A","level4":"127"},
    {"ctlno":"29","setname":"ＴＭＰ自動設定警報幅上限HD/ECUM","elemkey":"dev-A-0128","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"128"},
    {"ctlno":"30","setname":"ＴＭＰ自動設定警報幅下限HD/ECUM","elemkey":"dev-A-0129","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"129"},
    {"ctlno":"31","setname":"ＴＭＰ自動設定警報限界上限","elemkey":"dev-A-0130","datapattern":"1","defaultvalue":"500","level1":"war","level2":"dev","level3":"A","level4":"130"},
    {"ctlno":"32","setname":"ＴＭＰ自動設定警報限界下限","elemkey":"dev-A-0131","datapattern":"1","defaultvalue":"-30","level1":"war","level2":"dev","level3":"A","level4":"131"},
    {"ctlno":"33","setname":"ＴＭＰ固定警報上限","elemkey":"dev-A-0132","datapattern":"1","defaultvalue":"300","level1":"war","level2":"dev","level3":"A","level4":"132"},
    {"ctlno":"34","setname":"ＴＭＰ固定警報下限","elemkey":"dev-A-0133","datapattern":"1","defaultvalue":"-30","level1":"war","level2":"dev","level3":"A","level4":"133"},
    {"ctlno":"35","setname":"ＴＭＰ自動追従警報幅上限HDF/HF","elemkey":"dev-A-0134","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"134"},
    {"ctlno":"36","setname":"ＴＭＰ自動追従警報幅下限HDF/HF","elemkey":"dev-A-0135","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"135"},
    {"ctlno":"37","setname":"ＴＭＰ自動設定警報幅上限HDF/HF","elemkey":"dev-A-0136","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"136"},
    {"ctlno":"38","setname":"ＴＭＰ自動設定警報幅下限HDF/HF","elemkey":"dev-A-0137","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"137"},
    {"ctlno":"39","setname":"ＴＭＰ自動追従警報幅上限ＳＮ","elemkey":"dev-A-0138","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"138"},
    {"ctlno":"40","setname":"ＴＭＰ自動追従警報幅下限ＳＮ","elemkey":"dev-A-0139","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"139"},
    {"ctlno":"41","setname":"ＴＭＰ自動設定警報幅上限ＳＮ","elemkey":"dev-A-0140","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"140"},
    {"ctlno":"42","setname":"ＴＭＰ自動設定警報幅下限ＳＮ","elemkey":"dev-A-0141","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"141"},
    {"ctlno":"43","setname":"ＴＭＰ自動設定警報限界上限ＳＮ","elemkey":"dev-A-0142","datapattern":"1","defaultvalue":"500","level1":"war","level2":"dev","level3":"A","level4":"142"},
    {"ctlno":"44","setname":"ＴＭＰ自動設定警報限界下限ＳＮ","elemkey":"dev-A-0143","datapattern":"1","defaultvalue":"-30","level1":"war","level2":"dev","level3":"A","level4":"143"},
    {"ctlno":"45","setname":"ＴＭＰ固定警報上限ＳＮ","elemkey":"dev-A-0144","datapattern":"1","defaultvalue":"500","level1":"war","level2":"dev","level3":"A","level4":"144"},
    {"ctlno":"46","setname":"ＴＭＰ固定警報下限ＳＮ","elemkey":"dev-A-0145","datapattern":"1","defaultvalue":"-30","level1":"war","level2":"dev","level3":"A","level4":"145"},
    {"ctlno":"47","setname":"ダイアライザー差圧自動設定警報幅上限HD/ECUM","elemkey":"dev-A-0146","datapattern":"1","defaultvalue":"250","level1":"war","level2":"dev","level3":"A","level4":"146"},
    {"ctlno":"48","setname":"ダイアライザー差圧自動設定警報幅下限HD/ECUM","elemkey":"dev-A-0147","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"147"},
    {"ctlno":"49","setname":"ダイアライザー差圧固定警報上限","elemkey":"dev-A-0148","datapattern":"1","defaultvalue":"250","level1":"war","level2":"dev","level3":"A","level4":"148"},
    {"ctlno":"50","setname":"ダイアライザー差圧固定警報下限","elemkey":"dev-A-0149","datapattern":"1","defaultvalue":"0","level1":"war","level2":"dev","level3":"A","level4":"149"},
    {"ctlno":"51","setname":"ダイアライザー差圧自動設定警報幅上限HDF/HF","elemkey":"dev-A-0150","datapattern":"1","defaultvalue":"200","level1":"war","level2":"dev","level3":"A","level4":"150"},
    {"ctlno":"52","setname":"ダイアライザー差圧自動設定警報幅下限HDF/HF","elemkey":"dev-A-0151","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"151"},
    {"ctlno":"53","setname":"ダイアライザー入口圧自動設定警報幅上限HD/ECUM","elemkey":"dev-A-0152","datapattern":"1","defaultvalue":"50","level1":"war","level2":"dev","level3":"A","level4":"152"},
    {"ctlno":"54","setname":"ダイアライザー入口圧自動設定警報幅下限HD/ECUM","elemkey":"dev-A-0153","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"153"},
    {"ctlno":"55","setname":"ダイアライザー入口圧自動設定警報限界上限","elemkey":"dev-A-0154","datapattern":"1","defaultvalue":"350","level1":"war","level2":"dev","level3":"A","level4":"154"},
    {"ctlno":"56","setname":"ダイアライザー入口圧自動設定警報限界下限","elemkey":"dev-A-0155","datapattern":"1","defaultvalue":"0","level1":"war","level2":"dev","level3":"A","level4":"155"},
    {"ctlno":"57","setname":"ダイアライザー入口圧固定警報上限","elemkey":"dev-A-0156","datapattern":"1","defaultvalue":"350","level1":"war","level2":"dev","level3":"A","level4":"156"},
    {"ctlno":"58","setname":"ダイアライザー入口圧固定警報下限","elemkey":"dev-A-0157","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"157"},
    {"ctlno":"59","setname":"ダイアライザー入口圧自動設定警報幅上限HDF/HF","elemkey":"dev-A-0158","datapattern":"1","defaultvalue":"70","level1":"war","level2":"dev","level3":"A","level4":"158"},
    {"ctlno":"60","setname":"ダイアライザー入口圧自動設定警報幅下限HDF/HF","elemkey":"dev-A-0159","datapattern":"1","defaultvalue":"-70","level1":"war","level2":"dev","level3":"A","level4":"159"},
    {"ctlno":"61","setname":"ダイアライザー入口圧固定警報上限準備回収","elemkey":"dev-A-0160","datapattern":"1","defaultvalue":"400","level1":"war","level2":"dev","level3":"A","level4":"160"},
    {"ctlno":"62","setname":"ダイアライザー入口圧固定警報下限準備回収","elemkey":"dev-A-0161","datapattern":"1","defaultvalue":"-200","level1":"war","level2":"dev","level3":"A","level4":"161"},
    {"ctlno":"63","setname":"ダイアライザー入口圧固定警報上限ＳＮ","elemkey":"dev-A-0162","datapattern":"1","defaultvalue":"500","level1":"war","level2":"dev","level3":"A","level4":"162"},
    {"ctlno":"64","setname":"ダイアライザー入口圧固定警報下限ＳＮ","elemkey":"dev-A-0163","datapattern":"1","defaultvalue":"-50","level1":"war","level2":"dev","level3":"A","level4":"163"},
    {"ctlno":"69","setname":"ＴＭＰゼロ補正警報上限HD","elemkey":"dev-A-0168","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"168"},
    {"ctlno":"70","setname":"ＴＭＰゼロ補正警報下限HD","elemkey":"dev-A-0169","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"169"},
    {"ctlno":"72","setname":"ＴＭＰゼロ補正警報上限ECUM","elemkey":"dev-A-0171","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"171"},
    {"ctlno":"73","setname":"ＴＭＰゼロ補正警報下限ECUM","elemkey":"dev-A-0172","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"172"},
    {"ctlno":"75","setname":"ＴＭＰゼロ補正警報上限HDF","elemkey":"dev-A-0174","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"174"},
    {"ctlno":"76","setname":"ＴＭＰゼロ補正警報下限HDF","elemkey":"dev-A-0175","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"175"},
    {"ctlno":"78","setname":"ＴＭＰゼロ補正警報上限HF","elemkey":"dev-A-0177","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"177"},
    {"ctlno":"79","setname":"ＴＭＰゼロ補正警報下限HF","elemkey":"dev-A-0178","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"178"},
    {"ctlno":"80","setname":"血流量操作範囲上限","elemkey":"dev-A-0179","datapattern":"1","defaultvalue":"300","level1":"ope","level2":"dev","level3":"A","level4":"179"},
    {"ctlno":"82","setname":"除水速度操作範囲上限","elemkey":"dev-A-0181","datapattern":"1","defaultvalue":"2","level1":"ope","level2":"dev","level3":"A","level4":"181"},
    {"ctlno":"83","setname":"透析液温度操作範囲上限","elemkey":"dev-A-0182","datapattern":"1","defaultvalue":"40","level1":"ope","level2":"dev","level3":"A","level4":"182"},
    {"ctlno":"84","setname":"透析液温度操作範囲下限","elemkey":"dev-A-0183","datapattern":"1","defaultvalue":"33","level1":"ope","level2":"dev","level3":"A","level4":"183"},
    {"ctlno":"86","setname":"前補液 補液速度操作範囲上限(HDF)","elemkey":"dev-A-0185","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"A","level4":"185"},
    {"ctlno":"87","setname":"前補液 補液速度操作範囲上限(HF)","elemkey":"dev-A-0186","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"A","level4":"186"},
    {"ctlno":"88","setname":"血圧自動測定間隔","elemkey":"dev-A-0190","datapattern":"1","defaultvalue":"30","level1":"bp","level2":"dev","level3":"A","level4":"190"},
    {"ctlno":"89","setname":"血圧ｶﾌ選択","elemkey":"dev-A-0191","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"191"},
    {"ctlno":"90","setname":"昇圧値","elemkey":"dev-A-0192","datapattern":"1","defaultvalue":"200","level1":"bp","level2":"dev","level3":"A","level4":"192"},
    {"ctlno":"91","setname":"昇圧方法選択","elemkey":"dev-A-0193","datapattern":"1","defaultvalue":"1","level1":"bp","level2":"dev","level3":"A","level4":"193"},
    {"ctlno":"92","setname":"血圧連続測定動作選択","elemkey":"dev-A-0194","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"194"},
    {"ctlno":"93","setname":"最高血圧上限","elemkey":"dev-A-0211","datapattern":"1","defaultvalue":"200","level1":"bp","level2":"dev","level3":"A","level4":"211"},
    {"ctlno":"94","setname":"最高血圧下限","elemkey":"dev-A-0212","datapattern":"1","defaultvalue":"80","level1":"bp","level2":"dev","level3":"A","level4":"212"},
    {"ctlno":"95","setname":"最低血圧上限","elemkey":"dev-A-0213","datapattern":"1","defaultvalue":"160","level1":"bp","level2":"dev","level3":"A","level4":"213"},
    {"ctlno":"96","setname":"最低血圧下限","elemkey":"dev-A-0214","datapattern":"1","defaultvalue":"50","level1":"bp","level2":"dev","level3":"A","level4":"214"},
    {"ctlno":"97","setname":"平均血圧上限","elemkey":"dev-A-0215","datapattern":"1","defaultvalue":"180","level1":"bp","level2":"dev","level3":"A","level4":"215"},
    {"ctlno":"98","setname":"平均血圧下限","elemkey":"dev-A-0216","datapattern":"1","defaultvalue":"60","level1":"bp","level2":"dev","level3":"A","level4":"216"},
    {"ctlno":"99","setname":"脈拍数上限","elemkey":"dev-A-0217","datapattern":"1","defaultvalue":"170","level1":"bp","level2":"dev","level3":"A","level4":"217"},
    {"ctlno":"100","setname":"脈拍数下限","elemkey":"dev-A-0218","datapattern":"1","defaultvalue":"50","level1":"bp","level2":"dev","level3":"A","level4":"218"},
    {"ctlno":"101","setname":"最高血圧上限警報 BP 動作選択","elemkey":"dev-A-0219","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"219"},
    {"ctlno":"102","setname":"最高血圧下限警報 BP 動作選択","elemkey":"dev-A-0220","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"220"},
    {"ctlno":"103","setname":"最高血圧上限警報 除水 動作選択","elemkey":"dev-A-0221","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"221"},
    {"ctlno":"104","setname":"最高血圧下限警報 除水 動作選択","elemkey":"dev-A-0222","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"222"},
    {"ctlno":"105","setname":"最高血圧上限警報 Na注入 動作選択","elemkey":"dev-A-0223","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"223"},
    {"ctlno":"106","setname":"最高血圧下限警報 Na注入 動作選択","elemkey":"dev-A-0224","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"224"},
    {"ctlno":"107","setname":"最高血圧上限警報 補液 動作選択","elemkey":"dev-A-0225","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"225"},
    {"ctlno":"108","setname":"最高血圧下限警報 補液 動作選択","elemkey":"dev-A-0226","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"226"},
    {"ctlno":"109","setname":"最高血圧上限警報 BP 速度","elemkey":"dev-A-0227","datapattern":"1","defaultvalue":"100","level1":"bp","level2":"dev","level3":"A","level4":"227"},
    {"ctlno":"110","setname":"最高血圧下限警報 BP 速度","elemkey":"dev-A-0228","datapattern":"1","defaultvalue":"100","level1":"bp","level2":"dev","level3":"A","level4":"228"},
    {"ctlno":"111","setname":"最高血圧上限警報 除水 速度","elemkey":"dev-A-0229","datapattern":"1","defaultvalue":"0.1","level1":"bp","level2":"dev","level3":"A","level4":"229"},
    {"ctlno":"112","setname":"最高血圧下限警報 除水 速度","elemkey":"dev-A-0230","datapattern":"1","defaultvalue":"0.1","level1":"bp","level2":"dev","level3":"A","level4":"230"},
    {"ctlno":"113","setname":"最高血圧上限警報 Na注入 速度","elemkey":"dev-A-0231","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"231"},
    {"ctlno":"114","setname":"最高血圧下限警報 Na注入 速度","elemkey":"dev-A-0232","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"232"},
    {"ctlno":"115","setname":"最高血圧上限警報 補液 速度","elemkey":"dev-A-0233","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"233"},
    {"ctlno":"116","setname":"最高血圧下限警報 補液 速度","elemkey":"dev-A-0234","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"234"},
    {"ctlno":"117","setname":"警報連動測定開始時刻","elemkey":"dev-A-0235","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"235"},
    {"ctlno":"118","setname":"治療条件連動測定時刻","elemkey":"dev-A-0236","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"236"},
    {"ctlno":"119","setname":"血圧測定自動停止(警報発生)","elemkey":"dev-A-0237","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"237"},
    {"ctlno":"120","setname":"血圧測定自動停止(条件変更)","elemkey":"dev-A-0238","datapattern":"1","defaultvalue":"0","level1":"bp","level2":"dev","level3":"A","level4":"238"},
    {"ctlno":"121","setname":"高速測定選択","elemkey":"dev-A-0239","datapattern":"1","defaultvalue":"1","level1":"bp","level2":"dev","level3":"A","level4":"239"},
    {"ctlno":"122","setname":"ＴＭＰ監視モード","elemkey":"dev-A-0240","datapattern":"1","defaultvalue":"0","level1":"war","level2":"dev","level3":"A","level4":"240"},
    {"ctlno":"123","setname":"ＴＭＰゼロ補正の選択","elemkey":"dev-A-0241","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"241"},
    {"ctlno":"124","setname":"静脈圧自動設定警報監視有無","elemkey":"dev-A-0242","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"242"},
    {"ctlno":"125","setname":"ダイアライザー血液入口圧自動設定警報監視有無","elemkey":"dev-A-0243","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"243"},
    {"ctlno":"126","setname":"透析液圧自動設定警報監視有無","elemkey":"dev-A-0244","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"244"},
    {"ctlno":"127","setname":"ＴＭＰ自動設定警報監視有無","elemkey":"dev-A-0245","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"245"},
    {"ctlno":"128","setname":"差圧自動設定警報監視有無","elemkey":"dev-A-0246","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"246"},
    {"ctlno":"129","setname":"Ｎａ濃度自動設定警報監視有無","elemkey":"dev-A-0247","datapattern":"1","defaultvalue":"1","level1":"war","level2":"dev","level3":"A","level4":"247"},
    {"ctlno":"130","setname":"透析液濃度プログラム自動設定警報幅上限","elemkey":"dev-A-0250","datapattern":"1","defaultvalue":"5","level1":"cpro","level2":"dev","level3":"A","level4":"250"},
    {"ctlno":"131","setname":"透析液濃度プログラム自動設定警報幅下限","elemkey":"dev-A-0251","datapattern":"1","defaultvalue":"-5","level1":"cpro","level2":"dev","level3":"A","level4":"251"},
    {"ctlno":"132","setname":"Ｂ液濃度プログラム自動設定警報幅上限","elemkey":"dev-A-0252","datapattern":"1","defaultvalue":"5","level1":"cpro","level2":"dev","level3":"A","level4":"252"},
    {"ctlno":"133","setname":"Ｂ液濃度プログラム自動設定警報幅下限","elemkey":"dev-A-0253","datapattern":"1","defaultvalue":"-5","level1":"cpro","level2":"dev","level3":"A","level4":"253"},
    {"ctlno":"134","setname":"Ｎａ濃度自動設定警報幅上限","elemkey":"dev-A-0254","datapattern":"1","defaultvalue":"5","level1":"war","level2":"dev","level3":"A","level4":"254"},
    {"ctlno":"135","setname":"Ｎａ濃度自動設定警報幅下限","elemkey":"dev-A-0255","datapattern":"1","defaultvalue":"-5","level1":"war","level2":"dev","level3":"A","level4":"255"},
    {"ctlno":"136","setname":"Ｎａ濃度固定警報上限","elemkey":"dev-A-0256","datapattern":"1","defaultvalue":"190","level1":"war","level2":"dev","level3":"A","level4":"256"},
    {"ctlno":"137","setname":"Ｎａ濃度固定警報下限","elemkey":"dev-A-0257","datapattern":"1","defaultvalue":"120","level1":"war","level2":"dev","level3":"A","level4":"257"},
    {"ctlno":"138","setname":"アクセス再循環測定使用選択","elemkey":"dev-A-0258","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"258"},
    {"ctlno":"139","setname":"自動測定1","elemkey":"dev-A-0259","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"259"},
    {"ctlno":"140","setname":"?ＢＶ低下警報点１","elemkey":"dev-A-0260","datapattern":"1","defaultvalue":"-10","level1":"bv","level2":"dev","level3":"A","level4":"260"},
    {"ctlno":"141","setname":"?ＢＶ低下警報点２","elemkey":"dev-A-0261","datapattern":"1","defaultvalue":"-25","level1":"bv","level2":"dev","level3":"A","level4":"261"},
    {"ctlno":"142","setname":"?BV変化率警報点","elemkey":"dev-A-0262","datapattern":"1","defaultvalue":"-3","level1":"bv","level2":"dev","level3":"A","level4":"262"},
    {"ctlno":"143","setname":"ブラッドボリューム計使用の選択","elemkey":"dev-A-0267","datapattern":"1","defaultvalue":"1","level1":"bv","level2":"dev","level3":"A","level4":"267"},
    {"ctlno":"144","setname":"?ＢＶ除水低下速度","elemkey":"dev-A-0277","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"277"},
    {"ctlno":"145","setname":"?ＢＶ除水低下遅延時間","elemkey":"dev-A-0278","datapattern":"1","defaultvalue":"5","level1":"bv","level2":"dev","level3":"A","level4":"278"},
    {"ctlno":"146","setname":"再循環率報知","elemkey":"dev-A-0281","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"281"},
    {"ctlno":"185","setname":"同時脱血 脱血量","elemkey":"dev-A-0331","datapattern":"1","defaultvalue":"150","level1":"dfas","level2":"dev","level3":"A","level4":"331"},
    {"ctlno":"186","setname":"片側脱血への切替え透析液圧","elemkey":"dev-A-0332","datapattern":"1","defaultvalue":"-200","level1":"dfas","level2":"dev","level3":"A","level4":"332"},
    {"ctlno":"187","setname":"脱血速度","elemkey":"dev-A-0333","datapattern":"1","defaultvalue":"100","level1":"dfas","level2":"dev","level3":"A","level4":"333"},
    {"ctlno":"188","setname":"片側脱血(除水なし) 脱血量","elemkey":"dev-A-0334","datapattern":"1","defaultvalue":"150","level1":"dfas","level2":"dev","level3":"A","level4":"334"},
    {"ctlno":"190","setname":"補液速度","elemkey":"dev-A-0336","datapattern":"1","defaultvalue":"100","level1":"ope","level2":"dev","level3":"A","level4":"336"},
    {"ctlno":"191","setname":"補液量","elemkey":"dev-A-0337","datapattern":"1","defaultvalue":"100","level1":"ope","level2":"dev","level3":"A","level4":"337"},
    {"ctlno":"192","setname":"片側脱血(除水あり) 脱血量","elemkey":"dev-A-0338","datapattern":"1","defaultvalue":"50","level1":"dfas","level2":"dev","level3":"A","level4":"338"},
    {"ctlno":"193","setname":"脱血方法選択","elemkey":"dev-A-0339","datapattern":"1","defaultvalue":"2","level1":"dfas","level2":"dev","level3":"A","level4":"339"},
    {"ctlno":"223","setname":"自動回収 使用液量","elemkey":"dev-A-0370","datapattern":"1","defaultvalue":"200","level1":"pri","level2":"dev","level3":"A","level4":"370"},
    {"ctlno":"224","setname":"自動回収 流速","elemkey":"dev-A-0371","datapattern":"1","defaultvalue":"100","level1":"pri","level2":"dev","level3":"A","level4":"371"},
    {"ctlno":"225","setname":"自動回収 血液判別器による終了選択","elemkey":"dev-A-0372","datapattern":"1","defaultvalue":"0","level1":"pri","level2":"dev","level3":"A","level4":"372"},
    {"ctlno":"226","setname":"静脈側返血速度","elemkey":"dev-A-0373","datapattern":"1","defaultvalue":"100","level1":"dfas","level2":"dev","level3":"A","level4":"373"},
    {"ctlno":"227","setname":"静脈側最大返血量","elemkey":"dev-A-0374","datapattern":"1","defaultvalue":"250","level1":"dfas","level2":"dev","level3":"A","level4":"374"},
    {"ctlno":"228","setname":"動脈側最大返血量","elemkey":"dev-A-0376","datapattern":"1","defaultvalue":"30","level1":"dfas","level2":"dev","level3":"A","level4":"376"},
    {"ctlno":"229","setname":"静脈側返血 血液判別器使用選択","elemkey":"dev-A-0377","datapattern":"1","defaultvalue":"0","level1":"dfas","level2":"dev","level3":"A","level4":"377"},
    {"ctlno":"230","setname":"動脈側返血 血液判別器使用選択","elemkey":"dev-A-0378","datapattern":"1","defaultvalue":"0","level1":"dfas","level2":"dev","level3":"A","level4":"378"},
    {"ctlno":"234","setname":"補液量設定値制限(OHDF・OHF用)","elemkey":"dev-A-0383","datapattern":"1","defaultvalue":"1","level1":"ope","level2":"dev","level3":"A","level4":"383"},
    {"ctlno":"235","setname":"AFBF 補液比率使用選択","elemkey":"dev-A-0384","datapattern":"1","defaultvalue":"1","level1":"ope","level2":"dev","level3":"A","level4":"384"},
    {"ctlno":"236","setname":"AFBF 補液比率","elemkey":"dev-A-0385","datapattern":"1","defaultvalue":"13","level1":"ope","level2":"dev","level3":"A","level4":"385"},
    {"ctlno":"237","setname":"補液速度設定範囲上限(AFBF)","elemkey":"dev-A-0386","datapattern":"1","defaultvalue":"2.5","level1":"ope","level2":"dev","level3":"A","level4":"386"},
    {"ctlno":"238","setname":"補液速度設定範囲下限(AFBF)","elemkey":"dev-A-0387","datapattern":"1","defaultvalue":"1","level1":"ope","level2":"dev","level3":"A","level4":"387"},
    {"ctlno":"240","setname":"OHDF/OHF補液計算優先項目選択","elemkey":"dev-A-0389","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"389"},
    {"ctlno":"242","setname":"ＴＭＰゼロ補正警報上限OHDF","elemkey":"dev-A-0391","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"391"},
    {"ctlno":"243","setname":"ＴＭＰゼロ補正警報下限OHDF","elemkey":"dev-A-0392","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"392"},
    {"ctlno":"245","setname":"ＴＭＰゼロ補正警報上限OHF","elemkey":"dev-A-0394","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"394"},
    {"ctlno":"246","setname":"ＴＭＰゼロ補正警報下限OHF","elemkey":"dev-A-0395","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"A","level4":"395"},
    {"ctlno":"247","setname":"前補液 補液速度操作範囲上限(OHDF)","elemkey":"dev-A-0396","datapattern":"1","defaultvalue":"12","level1":"ope","level2":"dev","level3":"A","level4":"396"},
    {"ctlno":"248","setname":"前補液 補液速度操作範囲上限(OHF)","elemkey":"dev-A-0397","datapattern":"1","defaultvalue":"12","level1":"ope","level2":"dev","level3":"A","level4":"397"},
    {"ctlno":"249","setname":"補液開始遅延時間","elemkey":"dev-A-0398","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"398"},
    {"ctlno":"280","setname":"前補液 補液速度操作範囲上限(HD+補液)","elemkey":"dev-B-0030","datapattern":"1","defaultvalue":"12","level1":"ope","level2":"dev","level3":"B","level4":"030"},
    {"ctlno":"281","setname":"後補液 補液速度操作範囲上限(HDF)","elemkey":"dev-B-0031","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"B","level4":"031"},
    {"ctlno":"282","setname":"後補液 補液速度操作範囲上限(HF)","elemkey":"dev-B-0032","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"B","level4":"032"},
    {"ctlno":"283","setname":"後補液 補液速度操作範囲上限(HD+補液)","elemkey":"dev-B-0033","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"B","level4":"033"},
    {"ctlno":"284","setname":"後補液 補液速度操作範囲上限(OHDF)","elemkey":"dev-B-0034","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"B","level4":"034"},
    {"ctlno":"285","setname":"後補液 補液速度操作範囲上限(OHF)","elemkey":"dev-B-0035","datapattern":"1","defaultvalue":"6","level1":"ope","level2":"dev","level3":"B","level4":"035"},
    {"ctlno":"286","setname":"治療開始時血流量使用有無","elemkey":"dev-B-0036","datapattern":"1","defaultvalue":"1","level1":"dfas","level2":"dev","level3":"B","level4":"036"},
    {"ctlno":"287","setname":"ＴＭＰゼロ補正警報上限(HD+補液)","elemkey":"dev-B-0037","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"B","level4":"037"},
    {"ctlno":"288","setname":"ＴＭＰゼロ補正警報下限(HD+補液)","elemkey":"dev-B-0038","datapattern":"1","defaultvalue":"-50","level1":"ope","level2":"dev","level3":"B","level4":"038"},
    {"ctlno":"289","setname":"プライミング補助動脈充填液量","elemkey":"pat-A-0219","datapattern":"1","defaultvalue":"200","level1":"pri","level2":"pat","level3":"A","level4":"219"},
    {"ctlno":"290","setname":"プライミング補助動脈充填流速","elemkey":"pat-A-0220","datapattern":"1","defaultvalue":"100","level1":"pri","level2":"pat","level3":"A","level4":"220"},
    {"ctlno":"291","setname":"プライミング補助静脈充填液量","elemkey":"pat-A-0221","datapattern":"1","defaultvalue":"200","level1":"pri","level2":"pat","level3":"A","level4":"221"},
    {"ctlno":"292","setname":"プライミング補助静脈充填流速","elemkey":"pat-A-0222","datapattern":"1","defaultvalue":"100","level1":"pri","level2":"pat","level3":"A","level4":"222"},
    {"ctlno":"293","setname":"プライミング補助気泡抜き液量","elemkey":"pat-A-0223","datapattern":"1","defaultvalue":"400","level1":"pri","level2":"pat","level3":"A","level4":"223"},
    {"ctlno":"294","setname":"プライミング補助気泡抜き流速","elemkey":"pat-A-0224","datapattern":"1","defaultvalue":"300","level1":"pri","level2":"pat","level3":"A","level4":"224"},
    {"ctlno":"295","setname":"プライミング補助動脈充填後継続の有無","elemkey":"pat-A-0225","datapattern":"1","defaultvalue":"0","level1":"pri","level2":"pat","level3":"A","level4":"225"},
    {"ctlno":"296","setname":"プライミング補助静脈充填後継続の有無","elemkey":"pat-A-0226","datapattern":"1","defaultvalue":"0","level1":"pri","level2":"pat","level3":"A","level4":"226"},
    {"ctlno":"297","setname":"プライミング補助気泡抜き間欠動作選択","elemkey":"pat-A-0227","datapattern":"1","defaultvalue":"0","level1":"pri","level2":"pat","level3":"A","level4":"227"},
    {"ctlno":"298","setname":"プライミング補助液交換量","elemkey":"pat-A-0228","datapattern":"1","defaultvalue":"800","level1":"pri","level2":"pat","level3":"A","level4":"228"},
    {"ctlno":"299","setname":"プライミング補助間欠動作動作時間","elemkey":"pat-A-0229","datapattern":"1","defaultvalue":"2","level1":"pri","level2":"pat","level3":"A","level4":"229"},
    {"ctlno":"300","setname":"プライミング補助間欠動作停止時間","elemkey":"pat-A-0230","datapattern":"1","defaultvalue":"1","level1":"pri","level2":"pat","level3":"A","level4":"230"},
    {"ctlno":"301","setname":"自動プライミング開始時間","elemkey":"pat-A-0231","datapattern":"1","defaultvalue":"420","level1":"pri","level2":"pat","level3":"A","level4":"231"},
    {"ctlno":"302","setname":"自動プライミング落差時間","elemkey":"pat-A-0232","datapattern":"1","defaultvalue":"40","level1":"pri","level2":"pat","level3":"A","level4":"232"},
    {"ctlno":"303","setname":"自動プライミング送液液量","elemkey":"pat-A-0233","datapattern":"1","defaultvalue":"250","level1":"pri","level2":"pat","level3":"A","level4":"233"},
    {"ctlno":"304","setname":"自動プライミング送液流速1回目","elemkey":"pat-A-0234","datapattern":"1","defaultvalue":"250","level1":"pri","level2":"pat","level3":"A","level4":"234"},
    {"ctlno":"305","setname":"自動プライミング送液流速2回目以降","elemkey":"pat-A-0235","datapattern":"1","defaultvalue":"250","level1":"pri","level2":"pat","level3":"A","level4":"235"},
    {"ctlno":"306","setname":"自動プライミング循環流速","elemkey":"pat-A-0236","datapattern":"1","defaultvalue":"400","level1":"pri","level2":"pat","level3":"A","level4":"236"},
    {"ctlno":"307","setname":"自動プライミング循環時間","elemkey":"pat-A-0237","datapattern":"1","defaultvalue":"300","level1":"pri","level2":"pat","level3":"A","level4":"237"},
    {"ctlno":"308","setname":"自動プライミング総量","elemkey":"pat-A-0238","datapattern":"1","defaultvalue":"600","level1":"pri","level2":"pat","level3":"A","level4":"238"},
    {"ctlno":"310","setname":"IPラインプライミング使用選択","elemkey":"pat-B-0001","datapattern":"1","defaultvalue":"1","level1":"dfas","level2":"pat","level3":"B","level4":"001"},
    {"ctlno":"311","setname":"中空糸 プライミング時のBP速度","elemkey":"pat-B-0005","datapattern":"1","defaultvalue":"300","level1":"dfas","level2":"pat","level3":"B","level4":"005"},
    {"ctlno":"312","setname":"中空糸 送液最大時間","elemkey":"pat-B-0007","datapattern":"1","defaultvalue":"60","level1":"dfas","level2":"pat","level3":"B","level4":"007"},
    {"ctlno":"313","setname":"中空糸 回路内洗浄送液量","elemkey":"pat-B-0008","datapattern":"1","defaultvalue":"200","level1":"dfas","level2":"pat","level3":"B","level4":"008"},
    {"ctlno":"314","setname":"中空糸 気泡抜き動作実行回数","elemkey":"pat-B-0009","datapattern":"1","defaultvalue":"0","level1":"dfas","level2":"pat","level3":"B","level4":"009"},
    {"ctlno":"315","setname":"中空糸 気泡抜き圧力上限","elemkey":"pat-B-0010","datapattern":"1","defaultvalue":"150","level1":"dfas","level2":"pat","level3":"B","level4":"010"},
    {"ctlno":"317","setname":"補液選択","elemkey":"dev-B-0030","datapattern":"1","defaultvalue":null,"level1":"ope","level2":"dev","level3":"B","level4":"030"},
    {"ctlno":"318","setname":"前補液 ダイアライザー気泡抜き時間","elemkey":"dev-B-0031","datapattern":"1","defaultvalue":"2","level1":"ope","level2":"dev","level3":"B","level4":"031"},
    {"ctlno":"319","setname":"前補液 動脈チャンバ液面作成時間","elemkey":"pat-B-0032","datapattern":"1","defaultvalue":"90","level1":"pri","level2":"pat","level3":"B","level4":"032"},
    {"ctlno":"320","setname":"前補液 循環洗浄時間","elemkey":"pat-B-0033","datapattern":"1","defaultvalue":"3","level1":"pri","level2":"pat","level3":"B","level4":"033"},
    {"ctlno":"321","setname":"治療モード","elemkey":"dev-B-0034","datapattern":"1","defaultvalue":null,"level1":"ope","level2":"dev","level3":"B","level4":"034"},
    {"ctlno":"322","setname":"後補液 ダイアライザー気泡抜き時間","elemkey":"pat-B-0051","datapattern":"1","defaultvalue":"2","level1":"pri","level2":"pat","level3":"B","level4":"051"},
    {"ctlno":"323","setname":"後補液 動脈チャンバ液面作成時間","elemkey":"pat-B-0052","datapattern":"1","defaultvalue":"60","level1":"pri","level2":"pat","level3":"B","level4":"052"},
    {"ctlno":"324","setname":"後補液 循環洗浄時間","elemkey":"pat-B-0053","datapattern":"1","defaultvalue":"3","level1":"pri","level2":"pat","level3":"B","level4":"053"},
    {"ctlno":"325","setname":"積層 送液最大時間","elemkey":"pat-B-0054","datapattern":"1","defaultvalue":"60","level1":"dfas","level2":"pat","level3":"B","level4":"054"},
    {"ctlno":"326","setname":"積層 回路内洗浄送液量","elemkey":"pat-B-0055","datapattern":"1","defaultvalue":"200","level1":"dfas","level2":"pat","level3":"B","level4":"055"},
    {"ctlno":"327","setname":"積層 気泡抜き動作実行回数","elemkey":"pat-B-0056","datapattern":"1","defaultvalue":"0","level1":"dfas","level2":"pat","level3":"B","level4":"056"},
    {"ctlno":"328","setname":"積層 気泡抜き圧力上限","elemkey":"pat-B-0057","datapattern":"1","defaultvalue":"150","level1":"dfas","level2":"pat","level3":"B","level4":"057"},
    {"ctlno":"329","setname":"積層 除水ポンプ速度","elemkey":"pat-B-0058","datapattern":"1","defaultvalue":"0.2","level1":"dfas","level2":"pat","level3":"B","level4":"058"},
    {"ctlno":"330","setname":"積層 プライミング時のBP速度","elemkey":"pat-B-0059","datapattern":"1","defaultvalue":"150","level1":"dfas","level2":"pat","level3":"B","level4":"059"},
    {"ctlno":"331","setname":"DP=Qd+Qs(補液速度加算)","elemkey":"dev-A-0369","datapattern":"1","defaultvalue":"1","level1":"ope","level2":"dev","level3":"A","level4":"369"},
    {"ctlno":"332","setname":"前補液　OHDF/OHF　補液速度比率","elemkey":"dev-A-0379","datapattern":"1","defaultvalue":"20","level1":"ope","level2":"dev","level3":"A","level4":"379"},
    {"ctlno":"333","setname":"後補液　OHDF/OHF　補液速度比率","elemkey":"dev-B-0039","datapattern":"1","defaultvalue":"20","level1":"ope","level2":"dev","level3":"B","level4":"039"},
    {"ctlno":"334","setname":"自動測定2","elemkey":"dev-A-0263","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"263"},
    {"ctlno":"335","setname":"自動測定3","elemkey":"dev-A-0264","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"264"},
    {"ctlno":"336","setname":"自動測定4","elemkey":"dev-A-0265","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"265"},
    {"ctlno":"337","setname":"自動測定5","elemkey":"dev-A-0266","datapattern":"1","defaultvalue":"0","level1":"bv","level2":"dev","level3":"A","level4":"266"},
    {"ctlno":"338","setname":"除水開始遅延時間","elemkey":"dev-A-0039","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"039"},
    {"ctlno":"339","setname":"動脈側返血使用選択","elemkey":"dev-A-0270","datapattern":"1","defaultvalue":"1","level1":"dfas","level2":"dev","level3":"A","level4":"270"},
    {"ctlno":"346","setname":"濾過率（前補液）","elemkey":"dev-A-0090","datapattern":"1","defaultvalue":"50","level1":"ope","level2":"dev","level3":"A","level4":"090"},
    {"ctlno":"347","setname":"ヘマトクリット（Ht）","elemkey":"dev-A-0091","datapattern":"1","defaultvalue":"33","level1":"ope","level2":"dev","level3":"A","level4":"091"},
    {"ctlno":"348","setname":"総タンパク（TP）","elemkey":"dev-A-0092","datapattern":"1","defaultvalue":"6.5","level1":"ope","level2":"dev","level3":"A","level4":"092"},
    {"ctlno":"349","setname":"血圧測定方法選択","elemkey":"dev-A-0195","datapattern":"1","defaultvalue":"1","level1":"bp","level2":"dev","level3":"A","level4":"195"},
    {"ctlno":"350","setname":"濾過率（後補液）","elemkey":"dev-B-0040","datapattern":"1","defaultvalue":"40","level1":"ope","level2":"dev","level3":"B","level4":"040"},
    {"ctlno":"362","setname":"透析液流量　設定方法","elemkey":"dev-A-0268","datapattern":"1","defaultvalue":"1","level1":"ope","level2":"dev","level3":"A","level4":"268"},
    {"ctlno":"363","setname":"透析液流量　比率設定","elemkey":"dev-A-0269","datapattern":"1","defaultvalue":"2.0","level1":"ope","level2":"dev","level3":"A","level4":"269"},
    {"ctlno":"436","setname":"VA確認報知基準値(静的静脈圧)","elemkey":"dev-A-0468","datapattern":"1","defaultvalue":"80","level1":"iap","level2":"dev","level3":"A","level4":"468"},
    {"ctlno":"437","setname":"VA確認報知基準値(IAP ratio)","elemkey":"dev-A-0469","datapattern":"1","defaultvalue":"0.5","level1":"iap","level2":"dev","level3":"A","level4":"469"},
    {"ctlno":"438","setname":"静的静脈圧記録 自動実施選択","elemkey":"dev-A-0470","datapattern":"1","defaultvalue":"1","level1":"iap","level2":"dev","level3":"A","level4":"470"},
    {"ctlno":"439","setname":"血圧測定 自動実施選択","elemkey":"dev-A-0471","datapattern":"1","defaultvalue":"0","level1":"iap","level2":"dev","level3":"A","level4":"471"},
    {"ctlno":"440","setname":"TMP閾値 速度低下","elemkey":"dev-A-0472","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"472"},
    {"ctlno":"441","setname":"TMP閾値 速度復帰","elemkey":"dev-A-0473","datapattern":"1","defaultvalue":"0","level1":"ope","level2":"dev","level3":"A","level4":"473"},
    {"ctlno":"442","setname":"速度変化率 速度低下","elemkey":"dev-A-0474","datapattern":"1","defaultvalue":"5","level1":"ope","level2":"dev","level3":"A","level4":"474"},
    {"ctlno":"443","setname":"速度変化率 速度復帰","elemkey":"dev-A-0475","datapattern":"1","defaultvalue":"5","level1":"ope","level2":"dev","level3":"A","level4":"475"},
    {"ctlno":"444","setname":"?SO2低下報知点","elemkey":"dev-A-0476","datapattern":"1","defaultvalue":"5","level1":"ope","level2":"dev","level3":"A","level4":"476"},
    {"ctlno":"445","setname":"条件送信時血流量","elemkey":"dev-A-0477","datapattern":"1","defaultvalue":null,"level1":"ope","level2":"dev","level3":"A","level4":"477"},
    {"ctlno":"65","setname":"初期ＵＦＲ警報上限","elemkey":"ufr_warning_max","datapattern":"4","defaultvalue":"200","level1":"ufr_warning_max","level2":"","level3":"","level4":"ufr_warning_max"},
    {"ctlno":"66","setname":"初期ＵＦＲ警報下限","elemkey":"ufr_warning_min","datapattern":"4","defaultvalue":"1","level1":"ufr_warning_min","level2":"","level3":"","level4":"ufr_warning_min"},
    {"ctlno":"67","setname":"ＵＦＲ低下警報点","elemkey":"ufr_warning_reduction","datapattern":"4","defaultvalue":"50","level1":"ufr_warning_reduction","level2":"","level3":"","level4":"ufr_warning_reduction"},
    {"ctlno":"68","setname":"ＴＭＰゼロ補正警報中点HD","elemkey":"tmp_center_hd","datapattern":"5","defaultvalue":"-30","level1":"tmp_center_hd","level2":"","level3":"","level4":"tmp_center_hd"},
    {"ctlno":"71","setname":"ＴＭＰゼロ補正警報中点ECUM","elemkey":"tmp_center_ecum","datapattern":"5","defaultvalue":"-65","level1":"tmp_center_ecum","level2":"","level3":"","level4":"tmp_center_ecum"},
    {"ctlno":"74","setname":"ＴＭＰゼロ補正警報中点HDF","elemkey":"tmp_center_hdf","datapattern":"5","defaultvalue":"-30","level1":"tmp_center_hdf","level2":"","level3":"","level4":"tmp_center_hdf"},
    {"ctlno":"77","setname":"ＴＭＰゼロ補正警報中点HF","elemkey":"tmp_center_hf","datapattern":"5","defaultvalue":"-65","level1":"tmp_center_hf","level2":"","level3":"","level4":"tmp_center_hf"},
    {"ctlno":"81","setname":"ＩＰ速度操作範囲上限","elemkey":"ind_cond_info-33-value","datapattern":"3","defaultvalue":"10","level1":"33","level2":"ind_cond_info","level3":"33","level4":"value"},
    {"ctlno":"85","setname":"Ｎａ注入濃度操作範囲上限","elemkey":"dev-A-0184","datapattern":"2","defaultvalue":"50","level1":"na","level2":"dev","level3":"A","level4":"184"},
    {"ctlno":"147","setname":"透析量プログラム使用選択","elemkey":"dev-A-0282","datapattern":"2","defaultvalue":"0","level1":"dia","level2":"dev","level3":"A","level4":"282"},
    {"ctlno":"148","setname":"体液量計算時後体重","elemkey":"calc_body_fluids_date","datapattern":"6","defaultvalue":null,"level1":"","level2":"","level3":"","level4":"calc_body_fluids_date"},
    {"ctlno":"149","setname":"体液量+補正値","elemkey":"calc_body_fluids","datapattern":"6","defaultvalue":null,"level1":"","level2":"","level3":"","level4":"calc_body_fluids"},
    {"ctlno":"150","setname":"目標後体重","elemkey":"ind_cond_info-3-value","datapattern":"3","defaultvalue":null,"level1":"3","level2":"ind_cond_info","level3":"3","level4":"value"},
    {"ctlno":"151","setname":"標準血流量","elemkey":"ind_cond_info-14-value","datapattern":"3","defaultvalue":null,"level1":"14","level2":"ind_cond_info","level3":"14","level4":"value"},
    {"ctlno":"152","setname":"KoA","elemkey":"koa","datapattern":"4","defaultvalue":null,"level1":"koa","level2":"","level3":"","level4":"koa"},
    {"ctlno":"153","setname":"目標Kt/V","elemkey":"dev-A-0288","datapattern":"2","defaultvalue":null,"level1":"dia","level2":"dev","level3":"A","level4":"288"},
    {"ctlno":"154","setname":"ＵＦＲプログラム電源ＳＷ","elemkey":"dev-A-0290","datapattern":"2","defaultvalue":"0","level1":"ufr","level2":"dev","level3":"A","level4":"290"},
    {"ctlno":"155","setname":"ＵＦＲプログラム指数１","elemkey":"dev-A-0301","datapattern":"2","defaultvalue":"200","level1":"ufr","level2":"dev","level3":"A","level4":"301"},
    {"ctlno":"156","setname":"ＵＦＲプログラム指数２","elemkey":"dev-A-0302","datapattern":"2","defaultvalue":"150","level1":"ufr","level2":"dev","level3":"A","level4":"302"},
    {"ctlno":"157","setname":"ＵＦＲプログラム指数３","elemkey":"dev-A-0303","datapattern":"2","defaultvalue":"100","level1":"ufr","level2":"dev","level3":"A","level4":"303"},
    {"ctlno":"158","setname":"ＵＦＲプログラム指数４","elemkey":"dev-A-0304","datapattern":"2","defaultvalue":"50","level1":"ufr","level2":"dev","level3":"A","level4":"304"},
    {"ctlno":"159","setname":"ＵＦＲプログラム指数５","elemkey":"dev-A-0305","datapattern":"2","defaultvalue":"0","level1":"ufr","level2":"dev","level3":"A","level4":"305"},
    {"ctlno":"160","setname":"ＵＦＲプログラム指数６","elemkey":"dev-A-0306","datapattern":"2","defaultvalue":"0","level1":"ufr","level2":"dev","level3":"A","level4":"306"},
    {"ctlno":"161","setname":"ＵＦＲプログラム指数７","elemkey":"dev-A-0307","datapattern":"2","defaultvalue":"50","level1":"ufr","level2":"dev","level3":"A","level4":"307"},
    {"ctlno":"162","setname":"ＵＦＲプログラム指数８","elemkey":"dev-A-0308","datapattern":"2","defaultvalue":"100","level1":"ufr","level2":"dev","level3":"A","level4":"308"},
    {"ctlno":"163","setname":"ＵＦＲプログラム指数９","elemkey":"dev-A-0309","datapattern":"2","defaultvalue":"150","level1":"ufr","level2":"dev","level3":"A","level4":"309"},
    {"ctlno":"164","setname":"ＵＦＲプログラム指数１０","elemkey":"dev-A-0310","datapattern":"2","defaultvalue":"200","level1":"ufr","level2":"dev","level3":"A","level4":"310"},
    {"ctlno":"165","setname":"ＵＦＲプログラム最終位置","elemkey":"dev-A-0311","datapattern":"2","defaultvalue":"10","level1":"ufr","level2":"dev","level3":"A","level4":"311"},
    {"ctlno":"166","setname":"ＵＦＲプログラムコース","elemkey":"dev-A-0312","datapattern":"2","defaultvalue":"1","level1":"ufr","level2":"dev","level3":"A","level4":"312"},
    {"ctlno":"167","setname":"ＵＦＲプログラム開始数値","elemkey":"dev-A-0313","datapattern":"2","defaultvalue":"100","level1":"ufr","level2":"dev","level3":"A","level4":"313"},
    {"ctlno":"168","setname":"ＵＦＲプログラム終了数値","elemkey":"dev-A-0314","datapattern":"2","defaultvalue":"100","level1":"ufr","level2":"dev","level3":"A","level4":"314"},
    {"ctlno":"169","setname":"Ｎａ注入プログラム電源ＳＷ","elemkey":"dev-A-0315","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"315"},
    {"ctlno":"170","setname":"Ｎａ注入プログラム設定１","elemkey":"dev-A-0316","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"316"},
    {"ctlno":"171","setname":"Ｎａ注入プログラム設定２","elemkey":"dev-A-0317","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"317"},
    {"ctlno":"172","setname":"Ｎａ注入プログラム設定３","elemkey":"dev-A-0318","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"318"},
    {"ctlno":"173","setname":"Ｎａ注入プログラム設定４","elemkey":"dev-A-0319","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"319"},
    {"ctlno":"174","setname":"Ｎａ注入プログラム設定５","elemkey":"dev-A-0320","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"320"},
    {"ctlno":"175","setname":"Ｎａ注入プログラム設定６","elemkey":"dev-A-0321","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"321"},
    {"ctlno":"176","setname":"Ｎａ注入プログラム設定７","elemkey":"dev-A-0322","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"322"},
    {"ctlno":"177","setname":"Ｎａ注入プログラム設定８","elemkey":"dev-A-0323","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"323"},
    {"ctlno":"178","setname":"Ｎａ注入プログラム設定９","elemkey":"dev-A-0324","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"324"},
    {"ctlno":"179","setname":"Ｎａ注入プログラム設定１０","elemkey":"dev-A-0325","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"325"},
    {"ctlno":"180","setname":"Ｎａ注入プログラム切替時間","elemkey":"dev-A-0326","datapattern":"2","defaultvalue":"30","level1":"na","level2":"dev","level3":"A","level4":"326"},
    {"ctlno":"181","setname":"Ｎａ注入プログラム ＵＦＲプロとの連動選択","elemkey":"dev-A-0327","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"327"},
    {"ctlno":"182","setname":"Ｎａ注入プログラムコース","elemkey":"dev-A-0328","datapattern":"2","defaultvalue":"1","level1":"na","level2":"dev","level3":"A","level4":"328"},
    {"ctlno":"183","setname":"Ｎａ注入プログラム開始数値","elemkey":"dev-A-0329","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"329"},
    {"ctlno":"184","setname":"Ｎａ注入プログラム終了数値","elemkey":"dev-A-0330","datapattern":"2","defaultvalue":"0","level1":"na","level2":"dev","level3":"A","level4":"330"},
    {"ctlno":"189","setname":"治療開始時 血液ポンプ速度","elemkey":"ind_cond_info-14-value","datapattern":"3","defaultvalue":null,"level1":"14","level2":"ind_cond_info","level3":"14","level4":"value"},
    {"ctlno":"194","setname":"濃度プログラム電源ＳＷ","elemkey":"dev-A-0340","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"A","level4":"340"},
    {"ctlno":"195","setname":"透析液濃度プログラム設定１","elemkey":"dev-A-0341","datapattern":"2","defaultvalue":"14","level1":"dc","level2":"dev","level3":"A","level4":"341"},
    {"ctlno":"196","setname":"透析液濃度プログラム設定２","elemkey":"dev-A-0342","datapattern":"2","defaultvalue":"14","level1":"dc","level2":"dev","level3":"A","level4":"342"},
    {"ctlno":"197","setname":"透析液濃度プログラム設定３","elemkey":"dev-A-0343","datapattern":"2","defaultvalue":"14","level1":"dc","level2":"dev","level3":"A","level4":"343"},
    {"ctlno":"198","setname":"透析液濃度プログラム設定４","elemkey":"dev-A-0344","datapattern":"2","defaultvalue":"14","level1":"dc","level2":"dev","level3":"A","level4":"344"},
    {"ctlno":"199","setname":"透析液濃度プログラム設定５","elemkey":"dev-A-0345","datapattern":"2","defaultvalue":"14","level1":"dc","level2":"dev","level3":"A","level4":"345"},
    {"ctlno":"200","setname":"透析液濃度プログラム設定６","elemkey":"dev-A-0346","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"346"},
    {"ctlno":"201","setname":"透析液濃度プログラム設定７","elemkey":"dev-A-0347","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"347"},
    {"ctlno":"202","setname":"透析液濃度プログラム設定８","elemkey":"dev-A-0348","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"348"},
    {"ctlno":"203","setname":"透析液濃度プログラム設定９","elemkey":"dev-A-0349","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"349"},
    {"ctlno":"204","setname":"透析液濃度プログラム設定１０","elemkey":"dev-A-0350","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"350"},
    {"ctlno":"205","setname":"Ｂ液濃度プログラム設定１","elemkey":"dev-A-0351","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"351"},
    {"ctlno":"206","setname":"Ｂ液濃度プログラム設定２","elemkey":"dev-A-0352","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"352"},
    {"ctlno":"207","setname":"Ｂ液濃度プログラム設定３","elemkey":"dev-A-0353","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"353"},
    {"ctlno":"208","setname":"Ｂ液濃度プログラム設定４","elemkey":"dev-A-0354","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"354"},
    {"ctlno":"209","setname":"Ｂ液濃度プログラム設定５","elemkey":"dev-A-0355","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"355"},
    {"ctlno":"210","setname":"Ｂ液濃度プログラム設定６","elemkey":"dev-A-0356","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"356"},
    {"ctlno":"211","setname":"Ｂ液濃度プログラム設定７","elemkey":"dev-A-0357","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"357"},
    {"ctlno":"212","setname":"Ｂ液濃度プログラム設定８","elemkey":"dev-A-0358","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"358"},
    {"ctlno":"213","setname":"Ｂ液濃度プログラム設定９","elemkey":"dev-A-0359","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"359"},
    {"ctlno":"214","setname":"Ｂ液濃度プログラム設定１０","elemkey":"dev-A-0360","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"360"},
    {"ctlno":"215","setname":"透析液濃度プログラムステップ切替無し コース","elemkey":"dev-A-0361","datapattern":"2","defaultvalue":"2","level1":"dc","level2":"dev","level3":"A","level4":"361"},
    {"ctlno":"216","setname":"透析液濃度プログラム開始数値","elemkey":"dev-A-0362","datapattern":"2","defaultvalue":"13.5","level1":"dc","level2":"dev","level3":"A","level4":"362"},
    {"ctlno":"217","setname":"透析液濃度プログラム終了数値","elemkey":"dev-A-0363","datapattern":"2","defaultvalue":"15","level1":"dc","level2":"dev","level3":"A","level4":"363"},
    {"ctlno":"218","setname":"Ｂ液濃度プログラムステップ切替無し コース","elemkey":"dev-A-0364","datapattern":"2","defaultvalue":"2","level1":"dc","level2":"dev","level3":"A","level4":"364"},
    {"ctlno":"219","setname":"Ｂ液濃度プログラム開始数値","elemkey":"dev-A-0365","datapattern":"2","defaultvalue":"2.5","level1":"dc","level2":"dev","level3":"A","level4":"365"},
    {"ctlno":"220","setname":"Ｂ液濃度プログラム終了数値","elemkey":"dev-A-0366","datapattern":"2","defaultvalue":"3","level1":"dc","level2":"dev","level3":"A","level4":"366"},
    {"ctlno":"221","setname":"濃度プログラム切替時間","elemkey":"dev-A-0367","datapattern":"2","defaultvalue":"30","level1":"dc","level2":"dev","level3":"A","level4":"367"},
    {"ctlno":"222","setname":"濃度プログラム ＵＦＲプロとの連動選択","elemkey":"dev-A-0368","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"A","level4":"368"},
    {"ctlno":"231","setname":"補液速度","elemkey":"ind_cond_info-24-value","datapattern":"3","defaultvalue":null,"level1":"24","level2":"ind_cond_info","level3":"24","level4":"value"},
    {"ctlno":"232","setname":"補液温度設定値","elemkey":"ind_cond_info-23-value","datapattern":"3","defaultvalue":null,"level1":"23","level2":"ind_cond_info","level3":"23","level4":"value"},
    {"ctlno":"233","setname":"補液量設定値","elemkey":"ind_cond_info-20-value","datapattern":"3","defaultvalue":null,"level1":"20","level2":"ind_cond_info","level3":"20","level4":"value"},
    {"ctlno":"239","setname":"補液選択(前・後)","elemkey":"ind_cond_info-21-value","datapattern":"3","defaultvalue":"0","level1":"21","level2":"ind_cond_info","level3":"21","level4":"value"},
    {"ctlno":"241","setname":"ＴＭＰゼロ補正警報中点OHDF","elemkey":"tmp_center_ohdf","datapattern":"5","defaultvalue":"-30","level1":"tmp_center_ohdf","level2":"","level3":"","level4":"tmp_center_ohdf"},
    {"ctlno":"244","setname":"ＴＭＰゼロ補正警報中点OHF","elemkey":"tmp_center_ohf","datapattern":"5","defaultvalue":"-65","level1":"tmp_center_ohf","level2":"","level3":"","level4":"tmp_center_ohf"},
    {"ctlno":"250","setname":"UFRプログラム工程1の指数","elemkey":"dev-B-0000","datapattern":"2","defaultvalue":"50","level1":"ufr","level2":"dev","level3":"B","level4":"000"},
    {"ctlno":"251","setname":"UFRプログラム工程2の指数","elemkey":"dev-B-0001","datapattern":"2","defaultvalue":"38","level1":"ufr","level2":"dev","level3":"B","level4":"001"},
    {"ctlno":"252","setname":"UFRプログラム工程3の指数","elemkey":"dev-B-0002","datapattern":"2","defaultvalue":"25","level1":"ufr","level2":"dev","level3":"B","level4":"002"},
    {"ctlno":"253","setname":"UFRプログラム工程4の指数","elemkey":"dev-B-0003","datapattern":"2","defaultvalue":"13","level1":"ufr","level2":"dev","level3":"B","level4":"003"},
    {"ctlno":"254","setname":"UFRプログラム工程5の指数","elemkey":"dev-B-0004","datapattern":"2","defaultvalue":"0","level1":"ufr","level2":"dev","level3":"B","level4":"004"},
    {"ctlno":"255","setname":"UFRプログラム工程6の指数","elemkey":"dev-B-0005","datapattern":"2","defaultvalue":"0","level1":"ufr","level2":"dev","level3":"B","level4":"005"},
    {"ctlno":"256","setname":"UFRプログラム工程7の指数","elemkey":"dev-B-0006","datapattern":"2","defaultvalue":"13","level1":"ufr","level2":"dev","level3":"B","level4":"006"},
    {"ctlno":"257","setname":"UFRプログラム工程8の指数","elemkey":"dev-B-0007","datapattern":"2","defaultvalue":"25","level1":"ufr","level2":"dev","level3":"B","level4":"007"},
    {"ctlno":"258","setname":"UFRプログラム工程9の指数","elemkey":"dev-B-0008","datapattern":"2","defaultvalue":"38","level1":"ufr","level2":"dev","level3":"B","level4":"008"},
    {"ctlno":"259","setname":"UFRプログラム工程10の指数","elemkey":"dev-B-0009","datapattern":"2","defaultvalue":"50","level1":"ufr","level2":"dev","level3":"B","level4":"009"},
    {"ctlno":"260","setname":"B液濃度プログラム工程1のB液濃度","elemkey":"dev-B-0010","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"010"},
    {"ctlno":"261","setname":"B液濃度プログラム工程2のB液濃度","elemkey":"dev-B-0011","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"011"},
    {"ctlno":"262","setname":"B液濃度プログラム工程3のB液濃度","elemkey":"dev-B-0012","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"012"},
    {"ctlno":"263","setname":"B液濃度プログラム工程4のB液濃度","elemkey":"dev-B-0013","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"013"},
    {"ctlno":"264","setname":"B液濃度プログラム工程5のB液濃度","elemkey":"dev-B-0014","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"014"},
    {"ctlno":"265","setname":"B液濃度プログラム工程6のB液濃度","elemkey":"dev-B-0015","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"015"},
    {"ctlno":"266","setname":"B液濃度プログラム工程7のB液濃度","elemkey":"dev-B-0016","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"016"},
    {"ctlno":"267","setname":"B液濃度プログラム工程8のB液濃度","elemkey":"dev-B-0017","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"017"},
    {"ctlno":"268","setname":"B液濃度プログラム工程9のB液濃度","elemkey":"dev-B-0018","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"018"},
    {"ctlno":"269","setname":"B液濃度プログラム工程10のB液濃度","elemkey":"dev-B-0019","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"019"},
    {"ctlno":"270","setname":"A液濃度プログラム工程1のA液濃度","elemkey":"dev-B-0020","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"020"},
    {"ctlno":"271","setname":"A液濃度プログラム工程2のA液濃度","elemkey":"dev-B-0021","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"021"},
    {"ctlno":"272","setname":"A液濃度プログラム工程3のA液濃度","elemkey":"dev-B-0022","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"022"},
    {"ctlno":"273","setname":"A液濃度プログラム工程4のA液濃度","elemkey":"dev-B-0023","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"023"},
    {"ctlno":"274","setname":"A液濃度プログラム工程5のA液濃度","elemkey":"dev-B-0024","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"024"},
    {"ctlno":"275","setname":"A液濃度プログラム工程6のA液濃度","elemkey":"dev-B-0025","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"025"},
    {"ctlno":"276","setname":"A液濃度プログラム工程7のA液濃度","elemkey":"dev-B-0026","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"026"},
    {"ctlno":"277","setname":"A液濃度プログラム工程8のA液濃度","elemkey":"dev-B-0027","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"027"},
    {"ctlno":"278","setname":"A液濃度プログラム工程9のA液濃度","elemkey":"dev-B-0028","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"028"},
    {"ctlno":"279","setname":"A液濃度プログラム工程10のA液濃度","elemkey":"dev-B-0029","datapattern":"2","defaultvalue":"0","level1":"dc","level2":"dev","level3":"B","level4":"029"},
    {"ctlno":"309","setname":"ダイアライザ選択","elemkey":"dialyzer_type","datapattern":"4","defaultvalue":"1","level1":"dialyzer_type","level2":"","level3":"","level4":"dialyzer_type"},
    {"ctlno":"316","setname":"中空糸 除水ポンプ速度","elemkey":"0000","datapattern":"7","defaultvalue":"0.2","level1":"","level2":"","level3":"","level4":""},
    {"ctlno":"340","setname":"I-HDF　補液量設定","elemkey":"dev-A-0200","datapattern":"2","defaultvalue":"200","level1":"ihdf","level2":"dev","level3":"A","level4":"200"},
    {"ctlno":"341","setname":"I-HDF　補液速度","elemkey":"dev-A-0201","datapattern":"2","defaultvalue":"100","level1":"ihdf","level2":"dev","level3":"A","level4":"201"},
    {"ctlno":"342","setname":"I-HDF　補液周期","elemkey":"dev-A-0202","datapattern":"2","defaultvalue":"30","level1":"ihdf","level2":"dev","level3":"A","level4":"202"},
    {"ctlno":"343","setname":"I-HDF　補液開始時間","elemkey":"dev-A-0203","datapattern":"2","defaultvalue":"30","level1":"ihdf","level2":"dev","level3":"A","level4":"203"},
    {"ctlno":"344","setname":"I-HDF　除水再開時間","elemkey":"dev-A-0204","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"204"},
    {"ctlno":"345","setname":"I-HDF　総補液量上限","elemkey":"dev-A-0205","datapattern":"2","defaultvalue":"1.5","level1":"ihdf","level2":"dev","level3":"A","level4":"205"},
    {"ctlno":"351","setname":"BV-UFC使用選択","elemkey":"dev-A-0196","datapattern":"2","defaultvalue":"0","level1":"bvufc","level2":"dev","level3":"A","level4":"196"},
    {"ctlno":"352","setname":"UFC期間除水速度上限","elemkey":"dev-A-0197","datapattern":"2","defaultvalue":"2.00","level1":"bvufc","level2":"dev","level3":"A","level4":"197"},
    {"ctlno":"353","setname":"UFC期間除水速度下限","elemkey":"dev-A-0198","datapattern":"2","defaultvalue":"0.00","level1":"bvufc","level2":"dev","level3":"A","level4":"198"},
    {"ctlno":"354","setname":"開始期間 時間","elemkey":"dev-A-0199","datapattern":"2","defaultvalue":"10","level1":"bvufc","level2":"dev","level3":"A","level4":"199"},
    {"ctlno":"355","setname":"開始期間 除水速度倍率","elemkey":"dev-A-0206","datapattern":"2","defaultvalue":"1.00","level1":"bvufc","level2":"dev","level3":"A","level4":"206"},
    {"ctlno":"356","setname":"固定倍率除水期間 時間","elemkey":"dev-A-0207","datapattern":"2","defaultvalue":"60","level1":"bvufc","level2":"dev","level3":"A","level4":"207"},
    {"ctlno":"357","setname":"固定倍率除水期間 除水速度倍率","elemkey":"dev-A-0208","datapattern":"2","defaultvalue":"1.30","level1":"bvufc","level2":"dev","level3":"A","level4":"208"},
    {"ctlno":"358","setname":"固定倍率除水終了条件　最高血圧","elemkey":"dev-A-0209","datapattern":"2","defaultvalue":"0","level1":"bvufc","level2":"dev","level3":"A","level4":"209"},
    {"ctlno":"359","setname":"固定倍率除水終了条件　脈拍","elemkey":"dev-A-0210","datapattern":"2","defaultvalue":"0","level1":"bvufc","level2":"dev","level3":"A","level4":"210"},
    {"ctlno":"360","setname":"固定倍率除水終了条件　ΔBV","elemkey":"dev-A-0248","datapattern":"2","defaultvalue":"0.0","level1":"bvufc","level2":"dev","level3":"A","level4":"248"},
    {"ctlno":"361","setname":"終了前期間 時間","elemkey":"dev-A-0249","datapattern":"2","defaultvalue":"20","level1":"bvufc","level2":"dev","level3":"A","level4":"249"},
    {"ctlno":"364","setname":"開始時ΔBV基準値 ","elemkey":"dev-A-0271","datapattern":"2","defaultvalue":"0.0","level1":"bvufc","level2":"dev","level3":"A","level4":"271"},
    {"ctlno":"365","setname":"ΔBV基準線　指数1","elemkey":"dev-A-0272","datapattern":"2","defaultvalue":"50","level1":"bvufc","level2":"dev","level3":"A","level4":"272"},
    {"ctlno":"366","setname":"ΔBV基準線　指数2","elemkey":"dev-A-0273","datapattern":"2","defaultvalue":"80","level1":"bvufc","level2":"dev","level3":"A","level4":"273"},
    {"ctlno":"367","setname":"ΔBV基準線　指数3","elemkey":"dev-A-0274","datapattern":"2","defaultvalue":"95","level1":"bvufc","level2":"dev","level3":"A","level4":"274"},
    {"ctlno":"368","setname":"終了時ΔBV基準値 ","elemkey":"dev-A-0275","datapattern":"2","defaultvalue":"-4.0","level1":"bvufc","level2":"dev","level3":"A","level4":"275"},
    {"ctlno":"369","setname":"QBプログラム血流量1","elemkey":"dev-A-0400","datapattern":"2","defaultvalue":"100","level1":"qbqd","level2":"dev","level3":"A","level4":"400"},
    {"ctlno":"370","setname":"QBプログラム血流量2","elemkey":"dev-A-0401","datapattern":"2","defaultvalue":"160","level1":"qbqd","level2":"dev","level3":"A","level4":"401"},
    {"ctlno":"371","setname":"QBプログラム血流量3","elemkey":"dev-A-0402","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"402"},
    {"ctlno":"372","setname":"QBプログラム血流量4","elemkey":"dev-A-0403","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"403"},
    {"ctlno":"373","setname":"QBプログラム血流量5","elemkey":"dev-A-0404","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"404"},
    {"ctlno":"374","setname":"QBプログラム血流量6","elemkey":"dev-A-0405","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"405"},
    {"ctlno":"375","setname":"QBプログラム血流量7","elemkey":"dev-A-0406","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"406"},
    {"ctlno":"376","setname":"QBプログラム血流量8","elemkey":"dev-A-0407","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"407"},
    {"ctlno":"377","setname":"QBプログラム血流量9","elemkey":"dev-A-0408","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"408"},
    {"ctlno":"378","setname":"QBプログラム血流量10","elemkey":"dev-A-0409","datapattern":"2","defaultvalue":"220","level1":"qbqd","level2":"dev","level3":"A","level4":"409"},
    {"ctlno":"379","setname":"QDプログラム透析液流量1","elemkey":"dev-A-0410","datapattern":"2","defaultvalue":"200","level1":"qbqd","level2":"dev","level3":"A","level4":"410"},
    {"ctlno":"380","setname":"QDプログラム透析液流量2","elemkey":"dev-A-0411","datapattern":"2","defaultvalue":"400","level1":"qbqd","level2":"dev","level3":"A","level4":"411"},
    {"ctlno":"381","setname":"QDプログラム透析液流量3","elemkey":"dev-A-0412","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"412"},
    {"ctlno":"382","setname":"QDプログラム透析液流量4","elemkey":"dev-A-0413","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"413"},
    {"ctlno":"383","setname":"QDプログラム透析液流量5","elemkey":"dev-A-0414","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"414"},
    {"ctlno":"384","setname":"QDプログラム透析液流量6","elemkey":"dev-A-0415","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"415"},
    {"ctlno":"385","setname":"QDプログラム透析液流量7","elemkey":"dev-A-0416","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"416"},
    {"ctlno":"386","setname":"QDプログラム透析液流量8","elemkey":"dev-A-0417","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"417"},
    {"ctlno":"387","setname":"QDプログラム透析液流量9","elemkey":"dev-A-0418","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"418"},
    {"ctlno":"388","setname":"QDプログラム透析液流量10","elemkey":"dev-A-0419","datapattern":"2","defaultvalue":"600","level1":"qbqd","level2":"dev","level3":"A","level4":"419"},
    {"ctlno":"389","setname":"QB、QDプログラム切替時間1","elemkey":"dev-A-0420","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"420"},
    {"ctlno":"390","setname":"QB、QDプログラム切替時間2","elemkey":"dev-A-0421","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"421"},
    {"ctlno":"391","setname":"QB、QDプログラム切替時間3","elemkey":"dev-A-0422","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"422"},
    {"ctlno":"392","setname":"QB、QDプログラム切替時間4","elemkey":"dev-A-0423","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"423"},
    {"ctlno":"393","setname":"QB、QDプログラム切替時間5","elemkey":"dev-A-0424","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"424"},
    {"ctlno":"394","setname":"QB、QDプログラム切替時間6","elemkey":"dev-A-0425","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"425"},
    {"ctlno":"395","setname":"QB、QDプログラム切替時間7","elemkey":"dev-A-0426","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"426"},
    {"ctlno":"396","setname":"QB、QDプログラム切替時間8","elemkey":"dev-A-0427","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"427"},
    {"ctlno":"397","setname":"QB、QDプログラム切替時間9","elemkey":"dev-A-0428","datapattern":"2","defaultvalue":"60","level1":"qbqd","level2":"dev","level3":"A","level4":"428"},
    {"ctlno":"398","setname":"QB、QDプログラム最大ステップ数","elemkey":"dev-A-0429","datapattern":"2","defaultvalue":"3","level1":"qbqd","level2":"dev","level3":"A","level4":"429"},
    {"ctlno":"399","setname":"QBプログラム電源","elemkey":"dev-A-0430","datapattern":"2","defaultvalue":"0","level1":"qbqd","level2":"dev","level3":"A","level4":"430"},
    {"ctlno":"400","setname":"QDプログラム電源","elemkey":"dev-A-0431","datapattern":"2","defaultvalue":"0","level1":"qbqd","level2":"dev","level3":"A","level4":"431"},
    {"ctlno":"401","setname":"I-HDFプログラム使用選択","elemkey":"dev-A-0432","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"432"},
    {"ctlno":"402","setname":"予定補液回数","elemkey":"dev-A-0433","datapattern":"2","defaultvalue":"7","level1":"ihdf","level2":"dev","level3":"A","level4":"433"},
    {"ctlno":"403","setname":"補液バランス制限","elemkey":"dev-A-0434","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"434"},
    {"ctlno":"404","setname":"補液量01","elemkey":"dev-A-0435","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"435"},
    {"ctlno":"405","setname":"補液量02","elemkey":"dev-A-0436","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"436"},
    {"ctlno":"406","setname":"補液量03","elemkey":"dev-A-0437","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"437"},
    {"ctlno":"407","setname":"補液量04","elemkey":"dev-A-0438","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"438"},
    {"ctlno":"408","setname":"補液量05","elemkey":"dev-A-0439","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"439"},
    {"ctlno":"409","setname":"補液量06","elemkey":"dev-A-0440","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"440"},
    {"ctlno":"410","setname":"補液量07","elemkey":"dev-A-0441","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"441"},
    {"ctlno":"411","setname":"補液量08","elemkey":"dev-A-0442","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"442"},
    {"ctlno":"412","setname":"補液量09","elemkey":"dev-A-0443","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"443"},
    {"ctlno":"413","setname":"補液量10","elemkey":"dev-A-0444","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"444"},
    {"ctlno":"414","setname":"補液量11","elemkey":"dev-A-0445","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"445"},
    {"ctlno":"415","setname":"補液量12","elemkey":"dev-A-0446","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"446"},
    {"ctlno":"416","setname":"補液量13","elemkey":"dev-A-0447","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"447"},
    {"ctlno":"417","setname":"補液量14","elemkey":"dev-A-0448","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"448"},
    {"ctlno":"418","setname":"補液量15","elemkey":"dev-A-0449","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"449"},
    {"ctlno":"419","setname":"補液量16","elemkey":"dev-A-0450","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"450"},
    {"ctlno":"420","setname":"回収量01","elemkey":"dev-A-0451","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"451"},
    {"ctlno":"421","setname":"回収量02","elemkey":"dev-A-0452","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"452"},
    {"ctlno":"422","setname":"回収量03","elemkey":"dev-A-0453","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"453"},
    {"ctlno":"423","setname":"回収量04","elemkey":"dev-A-0454","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"454"},
    {"ctlno":"424","setname":"回収量05","elemkey":"dev-A-0455","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"455"},
    {"ctlno":"425","setname":"回収量06","elemkey":"dev-A-0456","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"456"},
    {"ctlno":"426","setname":"回収量07","elemkey":"dev-A-0457","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"457"},
    {"ctlno":"427","setname":"回収量08","elemkey":"dev-A-0458","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"458"},
    {"ctlno":"428","setname":"回収量09","elemkey":"dev-A-0459","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"459"},
    {"ctlno":"429","setname":"回収量10","elemkey":"dev-A-0460","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"460"},
    {"ctlno":"430","setname":"回収量11","elemkey":"dev-A-0461","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"461"},
    {"ctlno":"431","setname":"回収量12","elemkey":"dev-A-0462","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"462"},
    {"ctlno":"432","setname":"回収量13","elemkey":"dev-A-0463","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"463"},
    {"ctlno":"433","setname":"回収量14","elemkey":"dev-A-0464","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"464"},
    {"ctlno":"434","setname":"回収量15","elemkey":"dev-A-0465","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"465"},
    {"ctlno":"435","setname":"回収量16","elemkey":"dev-A-0466","datapattern":"2","defaultvalue":"0","level1":"ihdf","level2":"dev","level3":"A","level4":"466"}
  ]'' :: jsonb
      ) AS elements(
        ctlno TEXT,
        setname TEXT,
        elemkey TEXT,
        datapattern TEXT,
        defaultvalue TEXT
      )
  ),
  ntss_db5_pm AS (
    SELECT
      pat_id,
      facility_cd,
      device_set_info,
      up_date
    FROM
      ntss.pat_main
    WHERE
      facility_cd = @facilityCd
      AND pat_id = ANY (string_to_array(@paramList1, '','')::bigint[])
      AND is_del <> ''1''
  ),
  -- 治療情報マスタ：指示
  ind_ord_main_before_rank AS (
    SELECT
      subquery.pat_id,
      subquery.facility_cd,
      subquery.ord_no,
      subquery.treat_week,
      subquery.treat_date,
      subquery.up_date,
      subquery.ind_device_set_info,
      subquery.ind_cond_info,
      subquery.rst_cond_info,
      subquery.ind_bed_cd,
      subquery.rst_weight_info,
      subquery.rst_running_time,
      subquery.min_treatment_date,
      RANK() OVER (
        PARTITION BY subquery.pat_id,
        subquery.treat_week
        ORDER BY
          CASE
            WHEN subquery.ind_kur_cd = ''0'' THEN 2
            ELSE 1
          END,
          CASE
            WHEN subquery.ind_kur_cd = ''0'' THEN ntss_db5_mst_sel.sortkey :: integer
            ELSE (subquery.ind_treat_start_time) :: integer
          END,
          ntss_db5_mst_sel.sortkey
      ) AS priority
    FROM
      (
        SELECT
          ord_main.*,
          MIN(TO_DATE(ord_main.treat_date, ''YYYYMMDD'')) OVER(PARTITION BY ord_main.treat_week, ord_main.pat_id) AS min_treatment_date
        FROM
          ord_main
        WHERE
          ord_main.facility_cd = @facilityCd
          AND pat_id = ANY (string_to_array(@paramList1, '','')::bigint[])
          AND ord_main.is_del = ''0''
          AND TO_DATE(ord_main.treat_date, ''YYYYMMDD'') >= CURRENT_DATE
      ) AS subquery
      LEFT JOIN (
        SELECT
          ntss_db5_ms.facility_cd,
          setting ->> ''code'' AS code,
          ROW_NUMBER() OVER() AS sortkey
        FROM
          ntss.mst_selector ntss_db5_ms
          CROSS JOIN LATERAL jsonb_array_elements((ntss_db5_ms.order_settings #> ''{"items"}'') ) setting
        WHERE
          ntss_db5_ms.facility_cd = @facilityCd
          AND ntss_db5_ms.master_physical_name = ''mst_treatment''
          AND setting ->> ''isDel'' = ''0''
          AND setting ->> ''isDisp'' = ''1''
      ) AS ntss_db5_mst_sel ON subquery.facility_cd = ntss_db5_mst_sel.facility_cd
      AND subquery.ind_treatment_cd :: TEXT = ntss_db5_mst_sel.code
    WHERE
      TO_DATE(treat_date, ''YYYYMMDD'') = min_treatment_date
  ),
  ind_ord_main AS (
    SELECT
      *
    FROM
      ind_ord_main_before_rank
    WHERE
      priority = 1
  ),
  -- pat_mainのデータ取得START
ntss_db5_pm_dsi AS (
  SELECT
    pm.pat_id,
    base.prefix || ''-'' || base.ab || ''-'' || lpad(v.key, 4, ''0'') AS elemkey,
    pm.up_date::text,
    v.value AS value_4
  FROM
    ntss_db5_pm pm
  CROSS JOIN LATERAL jsonb_each(pm.device_set_info::jsonb) kv
  CROSS JOIN LATERAL (
      VALUES
        (''dev'', ''A''),
        (''dev'', ''B''),
        (''pat'', ''A''),
        (''pat'', ''B'')
  ) AS base(prefix, ab)
  CROSS JOIN LATERAL jsonb_each_text(
      (kv.value::jsonb #> ARRAY[base.prefix, base.ab])
  ) v
  WHERE
    pm.device_set_info IS NOT NULL
    AND pm.device_set_info <> ''[]''
    AND v.key IS NOT NULL
), -- pat_mainのデータ取得END
  -- ord_main,pat_treatment_patternのind_device_set_infoデータ取得START
  ntss_db5_ptp_week_date AS (
  SELECT
    p.pat_id,
    p.treat_week,
    max(p.ind_treat_start_date) AS max_ind_treat_start_date
  FROM ntss.pat_treatment_pattern p
  WHERE
    p.facility_cd = @facilityCd
    AND p.pat_id = ANY (string_to_array(@paramList1, '','')::bigint[])
    AND p.ind_treat_start_date::date <= CURRENT_DATE
  GROUP BY
    p.pat_id,
    p.treat_week
),

mst_sel AS (
  SELECT
    ms.facility_cd,
    setting ->> ''code'' AS code,
    ROW_NUMBER() OVER (ORDER BY setting ->> ''code'') AS sortkey
  FROM ntss.mst_selector ms
  CROSS JOIN LATERAL jsonb_array_elements(ms.order_settings -> ''items'') setting
  WHERE
    ms.facility_cd = @facilityCd
    AND ms.master_physical_name = ''mst_treatment''
    AND setting ->> ''isDel'' = ''0''
    AND setting ->> ''isDisp'' = ''1''
),

ntss_db5_ptp_week AS (
  SELECT *
  FROM (
    SELECT
      p.pat_id,
      p.treat_week,
      p.ctl_no,
      d.max_ind_treat_start_date,
      p.up_date,
      ROW_NUMBER() OVER (
        PARTITION BY p.pat_id, p.treat_week
        ORDER BY
          CASE WHEN p.ind_kur_cd = ''0'' THEN 2 ELSE 1 END,
          CASE
            WHEN p.ind_kur_cd = ''0''
              THEN mst.sortkey
            ELSE (p.ind_sch_info ->> ''ind_treat_start_time'')::integer
          END,
          mst.sortkey
      ) AS priority,
      p.facility_cd,
      p.ind_sch_info,
      p.ind_cond_info,
      p.ind_device_set_info
    FROM ntss.pat_treatment_pattern p
    JOIN ntss_db5_ptp_week_date d
      ON p.pat_id = d.pat_id
     AND p.treat_week = d.treat_week
     AND p.ind_treat_start_date = d.max_ind_treat_start_date
    LEFT JOIN mst_sel mst
      ON p.facility_cd = mst.facility_cd
     AND p.ind_treatment_cd::text = mst.code
    WHERE
      p.facility_cd = @facilityCd
      AND p.ind_device_set_info IS NOT NULL
      AND p.ind_device_set_info <> ''[]''
  ) ranked
  WHERE priority = 1
),

yellow_idsi AS (

  SELECT DISTINCT ON (pat_id, treat_week, elemkey)
      pat_id,
      treat_week,
      up_date,
      elemkey,
      value_4,
      priority
  FROM (
      SELECT
          w.pat_id,
          w.treat_week,
          w.max_ind_treat_start_date AS up_date,
          ''dev-'' || base.ab || ''-'' || lpad(v.key, 4, ''0'') AS elemkey,
          v.value AS value_4,
          1 AS priority
      FROM ntss_db5_ptp_week w
      CROSS JOIN LATERAL jsonb_each(w.ind_device_set_info::jsonb) kv
      CROSS JOIN LATERAL (VALUES (''A''), (''B'')) AS base(ab)
      CROSS JOIN LATERAL jsonb_each_text(
          kv.value::jsonb -> ''dev'' -> base.ab
      ) v
      WHERE
          w.facility_cd = @facilityCd
          AND w.priority = 1
          AND w.ind_device_set_info IS NOT NULL
          AND w.ind_device_set_info <> ''[]''

      UNION ALL

-- ind_ord_main側
      SELECT
          o.pat_id,
          o.treat_week,
          o.up_date::text,
          ''dev-'' || base.ab || ''-'' || lpad(v.key, 4, ''0'') AS elemkey,
          v.value AS value_4,
          2 AS priority
      FROM ind_ord_main o
      CROSS JOIN LATERAL jsonb_each(o.ind_device_set_info::jsonb) kv
      CROSS JOIN LATERAL (VALUES (''A''), (''B'')) AS base(ab)
      CROSS JOIN LATERAL jsonb_each_text(
          kv.value::jsonb -> ''dev'' -> base.ab
      ) v
      WHERE
          o.ind_device_set_info IS NOT NULL
          AND o.ind_device_set_info <> ''[]''

  ) src

-- priorityの小さいものを優先
  ORDER BY pat_id, treat_week, elemkey, priority

),


  
  elements3 AS (
  SELECT elemkey, ctlno
  FROM elements
  WHERE datapattern = ''3''
    AND ctlno IN (''81'',''150'',''151'',''189'',''231'',''232'',''233'',''239'')
),
  
  ntss_db5_pu_physical AS (
  SELECT
    pu.pat_id,
    j.physical_info_json ->> ''dw'' AS dw,
    RANK() OVER (
      PARTITION BY pu.pat_id
      ORDER BY
        j.physical_info_json ->> ''inspect_date'' DESC,
        j.physical_info_json ->> ''exam_date'' DESC
    ) AS priority,
    ROW_NUMBER() OVER (
      PARTITION BY pu.pat_id
      ORDER BY
        j.physical_info_json ->> ''inspect_date'' DESC,
        j.physical_info_json ->> ''exam_date'' DESC
    ) AS sortkey
  FROM pat_unique pu
  JOIN ntss_db5_pm pm
    ON pu.pat_id = pm.pat_id
   AND pu.facility_cd = pm.facility_cd
  CROSS JOIN LATERAL jsonb_array_elements(pu.physical_info::jsonb) j(physical_info_json)
  WHERE pu.is_del = ''0''
),

ind_cond_info AS (
  SELECT
    w.pat_id::integer,
    w.treat_week::integer,
    w.max_ind_treat_start_date::text AS up_date,
    e.elemkey,
    CASE e.ctlno
      WHEN ''81''  THEN w.ind_cond_info #>> ''{33,value}''
      WHEN ''150'' THEN w.ind_cond_info #>> ''{3,value}''
      WHEN ''151'' THEN w.ind_cond_info #>> ''{14,value}''
      WHEN ''189'' THEN w.ind_cond_info #>> ''{14,value}''
      WHEN ''231'' THEN w.ind_cond_info #>> ''{24,value}''
      WHEN ''232'' THEN w.ind_cond_info #>> ''{23,value}''
      WHEN ''233'' THEN w.ind_cond_info #>> ''{20,value}''
      WHEN ''239'' THEN w.ind_cond_info #>> ''{21,value}''
    END AS value_4,
    1 AS priority
  FROM ntss_db5_ptp_week w
  JOIN elements3 e
    ON TRUE
  WHERE w.ind_cond_info IS NOT NULL
    AND w.ind_cond_info <> ''[]''

  UNION ALL
  SELECT
    o.pat_id::integer,
    o.treat_week::integer,
    o.up_date::text,
    e.elemkey,
    CASE e.ctlno
      WHEN ''81''  THEN o.ind_cond_info #>> ''{33,value}''
      WHEN ''150'' THEN o.ind_cond_info #>> ''{3,value}''
      WHEN ''151'' THEN o.ind_cond_info #>> ''{14,value}''
      WHEN ''189'' THEN o.ind_cond_info #>> ''{14,value}''
      WHEN ''231'' THEN o.ind_cond_info #>> ''{24,value}''
      WHEN ''232'' THEN o.ind_cond_info #>> ''{23,value}''
      WHEN ''233'' THEN o.ind_cond_info #>> ''{20,value}''
      WHEN ''239'' THEN o.ind_cond_info #>> ''{21,value}''
          END AS value_4,
    2 AS priority
  FROM ind_ord_main o
  JOIN elements3 e
    ON TRUE
  WHERE o.ind_cond_info IS NOT NULL
    AND o.ind_cond_info <> ''[]''
),-- ord_main,pat_treatment_patternのind_cond_infoデータ取得END
  -- ベッド情報取得START
  ptp_machine AS (
    SELECT
        w.pat_id,
        w.treat_week,
        m.up_date,
        m.tmp_center_hd,
        m.tmp_center_ecum,
        m.tmp_center_hdf,
        m.tmp_center_hf,
        m.tmp_center_ohdf,
        m.tmp_center_ohf,
        1 AS priority
    FROM ntss_db5_ptp_week w
    JOIN ntss.mst_bed b
        ON w.ind_sch_info ->> ''ind_bed_cd'' = b.bed_cd::TEXT
        AND w.facility_cd = b.facility_cd
        AND b.is_del = ''0'' AND b.is_disp = ''1''
    JOIN ntss.mst_machine m
        ON b.machine_no = m.machine_no
        AND w.facility_cd = m.facility_cd
        AND m.is_del = ''0'' AND m.is_disp = ''1''
    WHERE w.ind_sch_info IS NOT NULL AND w.ind_sch_info <> ''[]''
),
om_machine AS (
    SELECT
        o.pat_id,
        o.treat_week,
        m.up_date,
        m.tmp_center_hd,
        m.tmp_center_ecum,
        m.tmp_center_hdf,
        m.tmp_center_hf,
        m.tmp_center_ohdf,
        m.tmp_center_ohf,
        2 AS priority
    FROM ind_ord_main o
    JOIN ntss.mst_bed b
        ON o.ind_bed_cd = b.bed_cd
        AND o.facility_cd = b.facility_cd
        AND b.is_del = ''0'' AND b.is_disp = ''1''
    JOIN ntss.mst_machine m
        ON b.machine_no = m.machine_no
        AND o.facility_cd = m.facility_cd
        AND m.is_del = ''0'' AND m.is_disp = ''1''
    WHERE o.ind_bed_cd IS NOT NULL
),
ranked_machine_info AS (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER(PARTITION BY pat_id, treat_week ORDER BY priority) AS rn
        FROM (
            SELECT * FROM ptp_machine
            UNION ALL
            SELECT * FROM om_machine
        ) AS combined
    ) AS ranked
    WHERE rn = 1
),
ptp_om_machine_info AS (
    SELECT
        r.pat_id,
        r.treat_week,
        r.up_date,
        e.elemkey,
        CASE e.elemkey
            WHEN ''tmp_center_hd'' THEN r.tmp_center_hd
            WHEN ''tmp_center_ecum'' THEN r.tmp_center_ecum
            WHEN ''tmp_center_hdf'' THEN r.tmp_center_hdf
            WHEN ''tmp_center_hf'' THEN r.tmp_center_hf
            WHEN ''tmp_center_ohdf'' THEN r.tmp_center_ohdf
            WHEN ''tmp_center_ohf'' THEN r.tmp_center_ohf
        END AS value_4
    FROM ranked_machine_info r
    JOIN elements e
        ON e.datapattern = ''5''
), -- ベッド情報取得END
  -- ダイアライザ情報取得START 

ptp_dialyzer_info AS (
    SELECT
        w.pat_id,
        w.treat_week,
        COALESCE(d.up_date, w.up_date) AS up_date,
        d.ufr_warning_max,
        d.ufr_warning_min,
        d.ufr_warning_reduction,
        d.koa,
        COALESCE(d.dialyzer_type, ''0'') AS dialyzer_type,
        1 AS priority
    FROM ntss_db5_ptp_week w
    LEFT JOIN ntss.mst_dialyzer d
        ON d.facility_cd = w.facility_cd
        AND d.dialyzer_cd::text = w.ind_cond_info #>> ''{5,value}''
        AND d.is_del = ''0''
        AND d.is_disp = ''1''
    WHERE w.ind_cond_info IS NOT NULL AND w.ind_cond_info <> ''[]''
),
  om_dialyzer_info AS (
    SELECT
        o.pat_id,
        o.treat_week,
        COALESCE(d.up_date, o.up_date) AS up_date,
        d.ufr_warning_max,
        d.ufr_warning_min,
        d.ufr_warning_reduction,
        d.koa,
        COALESCE(d.dialyzer_type, ''0'') AS dialyzer_type,
        2 AS priority
    FROM ind_ord_main o
    LEFT JOIN ntss.mst_dialyzer d
        ON d.facility_cd = o.facility_cd
        AND d.dialyzer_cd::text = o.ind_cond_info #>> ''{5,value}''
        AND d.is_del = ''0''
        AND d.is_disp = ''1''
    WHERE o.ind_cond_info IS NOT NULL AND o.ind_cond_info <> ''[]''
    ),
ranked_dialyzer AS (
    SELECT *
    FROM (
        SELECT *,
            ROW_NUMBER() OVER(
                PARTITION BY pat_id, treat_week
                ORDER BY priority, up_date DESC
            ) AS rn
        FROM (
            SELECT pat_id, treat_week, up_date, ufr_warning_max, ufr_warning_min, ufr_warning_reduction, koa, dialyzer_type, priority
            FROM ptp_dialyzer_info
            UNION ALL
            SELECT pat_id, treat_week, up_date, ufr_warning_max, ufr_warning_min, ufr_warning_reduction, koa, dialyzer_type, priority
            FROM om_dialyzer_info
        ) AS combined
    ) AS numbered
    WHERE rn = 1
),
ind_ord_main_ptp_dialyzer AS (
    SELECT
        r.pat_id,
        r.treat_week,
        r.up_date,
        e.elemkey,
        CASE e.elemkey
            WHEN ''ufr_warning_max'' THEN r.ufr_warning_max::text
            WHEN ''ufr_warning_min'' THEN r.ufr_warning_min::text
            WHEN ''ufr_warning_reduction'' THEN r.ufr_warning_reduction::text
            WHEN ''koa'' THEN r.koa::text
            WHEN ''dialyzer_type'' THEN r.dialyzer_type::text
        END AS value_4
    FROM ranked_dialyzer r
    JOIN elements e
        ON e.datapattern = ''4''
), -- ダイアライザ情報取得END
  -- 各曜日のデータ集計
  ind_ord_main_ptp_dsi AS (
  SELECT
    pat_id::integer,
    treat_week::integer,
    up_date::text,
    elemkey::text,
    value_4::text
  FROM (
    SELECT *,
           ROW_NUMBER() OVER (
             PARTITION BY pat_id, treat_week, elemkey
             ORDER BY priority
           ) AS rn
    FROM yellow_idsi
  ) y
  WHERE rn = 1

  UNION ALL
  SELECT
    pat_id::integer,
    treat_week::integer,
    up_date::text,
    elemkey::text,
    value_4::text
  FROM ptp_om_machine_info
  UNION ALL
  SELECT
    pat_id::integer,
    treat_week::integer,
    up_date::text,
    elemkey::text,
    value_4::text
  FROM ind_ord_main_ptp_dialyzer

  UNION ALL
  SELECT
    pat_id::integer,
    treat_week::integer,
    up_date::text,
    elemkey::text,
    value_4
  FROM (
    SELECT
      i.pat_id,
      i.treat_week,
      i.up_date,
      i.elemkey,
      CASE
        WHEN i.elemkey = ''ind_cond_info-3-value''
         AND i.value_4 = ''-1''
        THEN p.dw
        ELSE i.value_4::text
      END AS value_4,
      ROW_NUMBER() OVER (
        PARTITION BY i.pat_id, i.treat_week, i.elemkey
        ORDER BY i.priority
      ) AS rn
    FROM ind_cond_info i
    LEFT JOIN ntss_db5_pu_physical p
      ON i.pat_id = p.pat_id
     AND p.priority = ''1''
     AND p.sortkey = ''1''
  ) c
  WHERE rn = 1
  UNION ALL
  SELECT
    w.pat_id::integer,
    w.treat_week::integer,
    w.max_ind_treat_start_date::text AS up_date,
    e.elemkey::text,
    e.defaultvalue::text AS value_4
  FROM ntss_db5_ptp_week w
  JOIN elements e
    ON e.datapattern = ''7''
  WHERE w.priority = ''1''
),
ind_ord_main_ptp_dsi_days AS (
SELECT 
      ind_ord_main_ptp_dsi.pat_id,
      ind_ord_main_ptp_dsi.elemkey,
  MAX(ind_ord_main_ptp_dsi.up_date)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = EXTRACT(ISODOW FROM CURRENT_DATE)) AS up_date_0,
  MAX(ind_ord_main_ptp_dsi.value_4)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = EXTRACT(ISODOW FROM CURRENT_DATE)) AS value_4_0,
  MAX(ind_ord_main_ptp_dsi.up_date)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''1'') AS up_date_1,
  MAX(ind_ord_main_ptp_dsi.value_4)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''1'') AS value_4_1,
  MAX(ind_ord_main_ptp_dsi.up_date)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''2'') AS up_date_2,
  MAX(ind_ord_main_ptp_dsi.value_4)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''2'') AS value_4_2,
  MAX(ind_ord_main_ptp_dsi.up_date)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''3'') AS up_date_3,
  MAX(ind_ord_main_ptp_dsi.value_4)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''3'') AS value_4_3,
  MAX(ind_ord_main_ptp_dsi.up_date)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''4'') AS up_date_4,
  MAX(ind_ord_main_ptp_dsi.value_4)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''4'') AS value_4_4,
  MAX(ind_ord_main_ptp_dsi.up_date)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''5'') AS up_date_5,
  MAX(ind_ord_main_ptp_dsi.value_4)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''5'') AS value_4_5,
  MAX(ind_ord_main_ptp_dsi.up_date)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''6'') AS up_date_6,
  MAX(ind_ord_main_ptp_dsi.value_4)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''6'') AS value_4_6,
  MAX(ind_ord_main_ptp_dsi.up_date)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''7'') AS up_date_7,
  MAX(ind_ord_main_ptp_dsi.value_4)  FILTER (WHERE ind_ord_main_ptp_dsi.treat_week = ''7'') AS value_4_7
 FROM 
      ind_ord_main_ptp_dsi
    GROUP BY 
      ind_ord_main_ptp_dsi.pat_id, ind_ord_main_ptp_dsi.elemkey
  ),
  --select5
  elements_extended AS (
    SELECT
      *,
      CASE
        WHEN elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'') THEN ''0''
        ELSE NULL
      END AS fixed_value,
      CASE
        WHEN elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'') THEN NULL
        ELSE NULL
      END AS fixed_update
    FROM
      elements
  )
SELECT
  ntss_db5_pm.pat_id AS patid,
  '''' AS hosppatid,
  '''' AS name,
  elements_extended.ctlno AS ctlno,
  elements_extended.setname AS setname,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_0
    END
  ) AS value,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_0 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS
update
,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_1
    END
  ) AS monvalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_1 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS monupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_2
    END
  ) AS tuevalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_2 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS tueupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_3
    END
  ) AS wedvalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_3 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS wedupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_4
    END
  ) AS thuvalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_4 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS thuupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_5
    END
  ) AS frivalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_5 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS friupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_6
    END
  ) AS satvalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_6 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS satupdate,
  COALESCE(
    elements_extended.fixed_value,
    CASE
      elements_extended.datapattern
      WHEN ''1'' THEN ntss_db5_pm_dsi.value_4
      WHEN ''7'' THEN elements_extended.defaultvalue
      ELSE ind_ord_main_ptp_dsi_days.value_4_7
    END
  ) AS sunvalue,
  to_char(
    CASE
      WHEN elements_extended.elemkey IN (''calc_body_fluids_date'', ''calc_body_fluids'',''0000'') THEN ntss_db5_pm.up_date :: timestamp
      WHEN elements_extended.datapattern = ''1'' THEN ntss_db5_pm_dsi.up_date :: timestamp
      ELSE ind_ord_main_ptp_dsi_days.up_date_7 :: timestamp
    END,
    ''YYYY-MM-DD hh24:mi:ss''
  ) AS sunupdate
FROM
  ntss_db5_pm
  JOIN elements_extended ON TRUE
  LEFT JOIN ntss_db5_pm_dsi ON ntss_db5_pm.pat_id = ntss_db5_pm_dsi.pat_id
  AND elements_extended.elemkey = ntss_db5_pm_dsi.elemkey
  LEFT JOIN ind_ord_main_ptp_dsi_days ON ntss_db5_pm.pat_id = ind_ord_main_ptp_dsi_days.pat_id
  AND elements_extended.elemkey = ind_ord_main_ptp_dsi_days.elemkey;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2420, '-- 【SQL_CD=-2420】
WITH sys_moni AS (
    SELECT
        moni_data_no,
        moni_data_name
    FROM
        sys_monitor_item
    WHERE
        moni_data_no IN (''-1'',''-2'',''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''9'',''10'',''11'',''12'',''13'',''14'',''15'',''16'',''17'',''18'',''19'',''20'',''21'',''22'',''23'',''24'',''25'',''26'',''27'',''28'',''29'',''30'',''31'',''32'',''33'',''34'',''35'',''36'',''37'',''38'',''39'',''40'',''41'',''42'',''43'',''44'',''45'',''46'',''47'',''48'',''49'',''50'',''51'',''52'',''53'',''54'',''55'',''56'',''57'',''58'',''59'',''60'',''61'',''62'',''63'',''64'',''65'',''66'',''67'',''68'',''69'',''70'',''71'',''72'',''73'',''74'',''75'',''76'',''77'',''78'',''79'',''80'',''81'',''82'',''83'',''84'',''85'',''86'',''87'',''88'',''89'',''90'',''91'',''92'',''93'',''94'',''95'',''96'',''97'',''98'',''99'',''100'',''101'',''102'',''103'',''104'',''105'',''106'',''107'',''108'',''109'',''110'',''111'',''112'',''113'',''114'',''115'',''116'',''117'',''118'',''119'',''120'',''121'',''122'',''123'',''124'',''125'',''126'',''127'',''128'',''129'',''130'',''131'',''132'',''133'',''134'',''135'',''136'',''137'',''138'',''139'',''140'',''141'',''142'',''143'',''144'',''145'',''146'',''147'',''148'',''149'',''150'')
        AND sys_monitor_item.is_disp = ''1''
        AND sys_monitor_item.moni_data_type IS NULL
        AND sys_monitor_item.data_type between 1 and 3
),
moni_names as (
    select
        max(moni_data_name) FILTER (WHERE moni_data_no=''1'') AS moniname1,
        max(moni_data_name) FILTER (WHERE moni_data_no=''2'') AS moniname2,
        max(moni_data_name) FILTER (WHERE moni_data_no=''3'') AS moniname3,
        max(moni_data_name) FILTER (WHERE moni_data_no=''4'') AS moniname4,
        max(moni_data_name) FILTER (WHERE moni_data_no=''5'') AS moniname5,
        max(moni_data_name) FILTER (WHERE moni_data_no=''6'') AS moniname6,
        max(moni_data_name) FILTER (WHERE moni_data_no=''7'') AS moniname7,
        max(moni_data_name) FILTER (WHERE moni_data_no=''8'') AS moniname8,
        max(moni_data_name) FILTER (WHERE moni_data_no=''9'') AS moniname9,
        max(moni_data_name) FILTER (WHERE moni_data_no=''10'') AS moniname10,
        max(moni_data_name) FILTER (WHERE moni_data_no=''11'') AS moniname11,
        max(moni_data_name) FILTER (WHERE moni_data_no=''12'') AS moniname12,
        max(moni_data_name) FILTER (WHERE moni_data_no=''13'') AS moniname13,
        max(moni_data_name) FILTER (WHERE moni_data_no=''14'') AS moniname14,
        max(moni_data_name) FILTER (WHERE moni_data_no=''15'') AS moniname15,
        max(moni_data_name) FILTER (WHERE moni_data_no=''16'') AS moniname16,
        max(moni_data_name) FILTER (WHERE moni_data_no=''17'') AS moniname17,
        max(moni_data_name) FILTER (WHERE moni_data_no=''18'') AS moniname18,
        max(moni_data_name) FILTER (WHERE moni_data_no=''19'') AS moniname19,
        max(moni_data_name) FILTER (WHERE moni_data_no=''20'') AS moniname20,
        max(moni_data_name) FILTER (WHERE moni_data_no=''21'') AS moniname21,
        max(moni_data_name) FILTER (WHERE moni_data_no=''22'') AS moniname22,
        max(moni_data_name) FILTER (WHERE moni_data_no=''23'') AS moniname23,
        max(moni_data_name) FILTER (WHERE moni_data_no=''24'') AS moniname24,
        max(moni_data_name) FILTER (WHERE moni_data_no=''25'') AS moniname25,
        max(moni_data_name) FILTER (WHERE moni_data_no=''26'') AS moniname26,
        max(moni_data_name) FILTER (WHERE moni_data_no=''27'') AS moniname27,
        max(moni_data_name) FILTER (WHERE moni_data_no=''28'') AS moniname28,
        max(moni_data_name) FILTER (WHERE moni_data_no=''29'') AS moniname29,
        max(moni_data_name) FILTER (WHERE moni_data_no=''30'') AS moniname30,
        max(moni_data_name) FILTER (WHERE moni_data_no=''31'') AS moniname31,
        max(moni_data_name) FILTER (WHERE moni_data_no=''32'') AS moniname32,
        max(moni_data_name) FILTER (WHERE moni_data_no=''33'') AS moniname33,
        max(moni_data_name) FILTER (WHERE moni_data_no=''34'') AS moniname34,
        max(moni_data_name) FILTER (WHERE moni_data_no=''35'') AS moniname35,
        max(moni_data_name) FILTER (WHERE moni_data_no=''36'') AS moniname36,
        max(moni_data_name) FILTER (WHERE moni_data_no=''37'') AS moniname37,
        max(moni_data_name) FILTER (WHERE moni_data_no=''38'') AS moniname38,
        max(moni_data_name) FILTER (WHERE moni_data_no=''39'') AS moniname39,
        max(moni_data_name) FILTER (WHERE moni_data_no=''40'') AS moniname40,
        max(moni_data_name) FILTER (WHERE moni_data_no=''41'') AS moniname41,
        max(moni_data_name) FILTER (WHERE moni_data_no=''42'') AS moniname42,
        max(moni_data_name) FILTER (WHERE moni_data_no=''43'') AS moniname43,
        max(moni_data_name) FILTER (WHERE moni_data_no=''44'') AS moniname44,
        max(moni_data_name) FILTER (WHERE moni_data_no=''45'') AS moniname45,
        max(moni_data_name) FILTER (WHERE moni_data_no=''46'') AS moniname46,
        max(moni_data_name) FILTER (WHERE moni_data_no=''47'') AS moniname47,
        max(moni_data_name) FILTER (WHERE moni_data_no=''48'') AS moniname48,
        max(moni_data_name) FILTER (WHERE moni_data_no=''49'') AS moniname49,
        max(moni_data_name) FILTER (WHERE moni_data_no=''50'') AS moniname50,
        max(moni_data_name) FILTER (WHERE moni_data_no=''51'') AS moniname51,
        max(moni_data_name) FILTER (WHERE moni_data_no=''52'') AS moniname52,
        max(moni_data_name) FILTER (WHERE moni_data_no=''53'') AS moniname53,
        max(moni_data_name) FILTER (WHERE moni_data_no=''54'') AS moniname54,
        max(moni_data_name) FILTER (WHERE moni_data_no=''55'') AS moniname55,
        max(moni_data_name) FILTER (WHERE moni_data_no=''56'') AS moniname56,
        max(moni_data_name) FILTER (WHERE moni_data_no=''57'') AS moniname57,
        max(moni_data_name) FILTER (WHERE moni_data_no=''58'') AS moniname58,
        max(moni_data_name) FILTER (WHERE moni_data_no=''59'') AS moniname59,
        max(moni_data_name) FILTER (WHERE moni_data_no=''60'') AS moniname60,
        max(moni_data_name) FILTER (WHERE moni_data_no=''61'') AS moniname61,
        max(moni_data_name) FILTER (WHERE moni_data_no=''62'') AS moniname62,
        max(moni_data_name) FILTER (WHERE moni_data_no=''63'') AS moniname63,
        max(moni_data_name) FILTER (WHERE moni_data_no=''64'') AS moniname64,
        max(moni_data_name) FILTER (WHERE moni_data_no=''65'') AS moniname65,
        max(moni_data_name) FILTER (WHERE moni_data_no=''66'') AS moniname66,
        max(moni_data_name) FILTER (WHERE moni_data_no=''67'') AS moniname67,
        max(moni_data_name) FILTER (WHERE moni_data_no=''68'') AS moniname68,
        max(moni_data_name) FILTER (WHERE moni_data_no=''69'') AS moniname69,
        max(moni_data_name) FILTER (WHERE moni_data_no=''70'') AS moniname70,
        max(moni_data_name) FILTER (WHERE moni_data_no=''71'') AS moniname71,
        max(moni_data_name) FILTER (WHERE moni_data_no=''72'') AS moniname72,
        max(moni_data_name) FILTER (WHERE moni_data_no=''73'') AS moniname73,
        max(moni_data_name) FILTER (WHERE moni_data_no=''74'') AS moniname74,
        max(moni_data_name) FILTER (WHERE moni_data_no=''75'') AS moniname75,
        max(moni_data_name) FILTER (WHERE moni_data_no=''76'') AS moniname76,
        max(moni_data_name) FILTER (WHERE moni_data_no=''77'') AS moniname77,
        max(moni_data_name) FILTER (WHERE moni_data_no=''78'') AS moniname78,
        max(moni_data_name) FILTER (WHERE moni_data_no=''79'') AS moniname79,
        max(moni_data_name) FILTER (WHERE moni_data_no=''80'') AS moniname80,
        max(moni_data_name) FILTER (WHERE moni_data_no=''81'') AS moniname81,
        max(moni_data_name) FILTER (WHERE moni_data_no=''82'') AS moniname82,
        max(moni_data_name) FILTER (WHERE moni_data_no=''83'') AS moniname83,
        max(moni_data_name) FILTER (WHERE moni_data_no=''84'') AS moniname84,
        max(moni_data_name) FILTER (WHERE moni_data_no=''85'') AS moniname85,
        max(moni_data_name) FILTER (WHERE moni_data_no=''86'') AS moniname86,
        max(moni_data_name) FILTER (WHERE moni_data_no=''87'') AS moniname87,
        max(moni_data_name) FILTER (WHERE moni_data_no=''88'') AS moniname88,
        max(moni_data_name) FILTER (WHERE moni_data_no=''89'') AS moniname89,
        max(moni_data_name) FILTER (WHERE moni_data_no=''90'') AS moniname90,
        max(moni_data_name) FILTER (WHERE moni_data_no=''91'') AS moniname91,
        max(moni_data_name) FILTER (WHERE moni_data_no=''92'') AS moniname92,
        max(moni_data_name) FILTER (WHERE moni_data_no=''93'') AS moniname93,
        max(moni_data_name) FILTER (WHERE moni_data_no=''94'') AS moniname94,
        max(moni_data_name) FILTER (WHERE moni_data_no=''95'') AS moniname95,
        max(moni_data_name) FILTER (WHERE moni_data_no=''96'') AS moniname96,
        max(moni_data_name) FILTER (WHERE moni_data_no=''97'') AS moniname97,
        max(moni_data_name) FILTER (WHERE moni_data_no=''98'') AS moniname98,
        max(moni_data_name) FILTER (WHERE moni_data_no=''99'') AS moniname99,
        max(moni_data_name) FILTER (WHERE moni_data_no=''100'') AS moniname100,
        max(moni_data_name) FILTER (WHERE moni_data_no=''101'') AS moniname101,
        max(moni_data_name) FILTER (WHERE moni_data_no=''102'') AS moniname102,
        max(moni_data_name) FILTER (WHERE moni_data_no=''103'') AS moniname103,
        max(moni_data_name) FILTER (WHERE moni_data_no=''104'') AS moniname104,
        max(moni_data_name) FILTER (WHERE moni_data_no=''105'') AS moniname105,
        max(moni_data_name) FILTER (WHERE moni_data_no=''106'') AS moniname106,
        max(moni_data_name) FILTER (WHERE moni_data_no=''107'') AS moniname107,
        max(moni_data_name) FILTER (WHERE moni_data_no=''108'') AS moniname108,
        max(moni_data_name) FILTER (WHERE moni_data_no=''109'') AS moniname109,
        max(moni_data_name) FILTER (WHERE moni_data_no=''110'') AS moniname110,
        max(moni_data_name) FILTER (WHERE moni_data_no=''111'') AS moniname111,
        max(moni_data_name) FILTER (WHERE moni_data_no=''112'') AS moniname112,
        max(moni_data_name) FILTER (WHERE moni_data_no=''113'') AS moniname113,
        max(moni_data_name) FILTER (WHERE moni_data_no=''114'') AS moniname114,
        max(moni_data_name) FILTER (WHERE moni_data_no=''115'') AS moniname115,
        max(moni_data_name) FILTER (WHERE moni_data_no=''116'') AS moniname116,
        max(moni_data_name) FILTER (WHERE moni_data_no=''117'') AS moniname117,
        max(moni_data_name) FILTER (WHERE moni_data_no=''118'') AS moniname118,
        max(moni_data_name) FILTER (WHERE moni_data_no=''119'') AS moniname119,
        max(moni_data_name) FILTER (WHERE moni_data_no=''120'') AS moniname120,
        max(moni_data_name) FILTER (WHERE moni_data_no=''121'') AS moniname121,
        max(moni_data_name) FILTER (WHERE moni_data_no=''122'') AS moniname122,
        max(moni_data_name) FILTER (WHERE moni_data_no=''123'') AS moniname123,
        max(moni_data_name) FILTER (WHERE moni_data_no=''124'') AS moniname124,
        max(moni_data_name) FILTER (WHERE moni_data_no=''125'') AS moniname125,
        max(moni_data_name) FILTER (WHERE moni_data_no=''126'') AS moniname126,
        max(moni_data_name) FILTER (WHERE moni_data_no=''127'') AS moniname127,
        max(moni_data_name) FILTER (WHERE moni_data_no=''128'') AS moniname128,
        max(moni_data_name) FILTER (WHERE moni_data_no=''129'') AS moniname129,
        max(moni_data_name) FILTER (WHERE moni_data_no=''130'') AS moniname130,
        max(moni_data_name) FILTER (WHERE moni_data_no=''131'') AS moniname131,
        max(moni_data_name) FILTER (WHERE moni_data_no=''132'') AS moniname132,
        max(moni_data_name) FILTER (WHERE moni_data_no=''133'') AS moniname133,
        max(moni_data_name) FILTER (WHERE moni_data_no=''134'') AS moniname134,
        max(moni_data_name) FILTER (WHERE moni_data_no=''135'') AS moniname135,
        max(moni_data_name) FILTER (WHERE moni_data_no=''136'') AS moniname136,
        max(moni_data_name) FILTER (WHERE moni_data_no=''137'') AS moniname137,
        max(moni_data_name) FILTER (WHERE moni_data_no=''138'') AS moniname138,
        max(moni_data_name) FILTER (WHERE moni_data_no=''139'') AS moniname139,
        max(moni_data_name) FILTER (WHERE moni_data_no=''140'') AS moniname140,
        max(moni_data_name) FILTER (WHERE moni_data_no=''141'') AS moniname141,
        max(moni_data_name) FILTER (WHERE moni_data_no=''142'') AS moniname142,
        max(moni_data_name) FILTER (WHERE moni_data_no=''143'') AS moniname143,
        max(moni_data_name) FILTER (WHERE moni_data_no=''144'') AS moniname144,
        max(moni_data_name) FILTER (WHERE moni_data_no=''145'') AS moniname145,
        max(moni_data_name) FILTER (WHERE moni_data_no=''146'') AS moniname146,
        max(moni_data_name) FILTER (WHERE moni_data_no=''147'') AS moniname147,
        max(moni_data_name) FILTER (WHERE moni_data_no=''148'') AS moniname148,
        max(moni_data_name) FILTER (WHERE moni_data_no=''149'') AS moniname149,
        max(moni_data_name) FILTER (WHERE moni_data_no=''150'') AS moniname150,
        max(moni_data_name) FILTER (WHERE moni_data_no=''-1'') AS moniname151,
        max(moni_data_name) FILTER (WHERE moni_data_no=''-2'') AS moniname152
    from sys_moni
)
        SELECT
            m_b.in_hospital_cd_1 AS bedno --ベッド番号
            , m_m.in_hospital_cd_1 AS deviceno --装置番号
            , to_char(mm.occur_date,''YYYY-MM-DD hh24:mi:ss'') AS occurdate --発生日時
            , om.pat_id AS patid
            , '''' AS hosppatid --患者ID
            , mn.moniname1 AS moniname1
            , CASE WHEN mn.moniname1 IS NOT NULL THEN NULLIF(mm.monitor_data->>''1'',''-1'') END AS moniitem1
            , mn.moniname2 AS moniname2
            , CASE WHEN mn.moniname2 IS NOT NULL THEN NULLIF(mm.monitor_data->>''2'',''-1'') END AS moniitem2
            , mn.moniname3 AS moniname3
            , CASE WHEN mn.moniname3 IS NOT NULL THEN NULLIF(mm.monitor_data->>''3'',''-1'') END AS moniitem3
            , mn.moniname4 AS moniname4
            , CASE WHEN mn.moniname4 IS NOT NULL THEN NULLIF(mm.monitor_data->>''4'',''-1'') END AS moniitem4
            , mn.moniname5 AS moniname5
            , CASE WHEN mn.moniname5 IS NOT NULL THEN NULLIF(mm.monitor_data->>''5'',''-1'') END AS moniitem5
            , mn.moniname6 AS moniname6
            , CASE WHEN mn.moniname6 IS NOT NULL THEN NULLIF(mm.monitor_data->>''6'',''-1'') END AS moniitem6
            , mn.moniname7 AS moniname7
            , CASE WHEN mn.moniname7 IS NOT NULL THEN NULLIF(mm.monitor_data->>''7'',''-1'') END AS moniitem7
            , mn.moniname8 AS moniname8
            , CASE WHEN mn.moniname8 IS NOT NULL THEN NULLIF(mm.monitor_data->>''8'',''-1'') END AS moniitem8
            , mn.moniname9 AS moniname9
            , CASE WHEN mn.moniname9 IS NOT NULL THEN NULLIF(mm.monitor_data->>''9'',''-1'') END AS moniitem9
            , mn.moniname10 AS moniname10
            , CASE WHEN mn.moniname10 IS NOT NULL THEN NULLIF(mm.monitor_data->>''10'',''-1'') END AS moniitem10
            , mn.moniname11 AS moniname11
            , CASE WHEN mn.moniname11 IS NOT NULL THEN NULLIF(mm.monitor_data->>''11'',''-1'') END AS moniitem11
            , mn.moniname12 AS moniname12
            , CASE WHEN mn.moniname12 IS NOT NULL THEN NULLIF(mm.monitor_data->>''12'',''-1'') END AS moniitem12
            , mn.moniname13 AS moniname13
            , CASE WHEN mn.moniname13 IS NOT NULL THEN NULLIF(mm.monitor_data->>''13'',''-1'') END AS moniitem13
            , mn.moniname14 AS moniname14
            , CASE WHEN mn.moniname14 IS NOT NULL THEN NULLIF(mm.monitor_data->>''14'',''-1'') END AS moniitem14
            , mn.moniname15 AS moniname15
            , CASE WHEN mn.moniname15 IS NOT NULL THEN NULLIF(mm.monitor_data->>''15'',''-1'') END AS moniitem15
            , mn.moniname16 AS moniname16
            , CASE WHEN mn.moniname16 IS NOT NULL THEN NULLIF(mm.monitor_data->>''16'',''-1'') END AS moniitem16
            , mn.moniname17 AS moniname17
            , CASE WHEN mn.moniname17 IS NOT NULL THEN NULLIF(mm.monitor_data->>''17'',''-1'') END AS moniitem17
            , mn.moniname18 AS moniname18
            , CASE WHEN mn.moniname18 IS NOT NULL THEN NULLIF(mm.monitor_data->>''18'',''-1'') END AS moniitem18
            , mn.moniname19 AS moniname19
            , CASE WHEN mn.moniname19 IS NOT NULL THEN NULLIF(mm.monitor_data->>''19'',''-1'') END AS moniitem19
            , mn.moniname20 AS moniname20
            , CASE WHEN mn.moniname20 IS NOT NULL THEN NULLIF(mm.monitor_data->>''20'',''-1'') END AS moniitem20
            , mn.moniname21 AS moniname21
            , CASE WHEN mn.moniname21 IS NOT NULL THEN NULLIF(mm.monitor_data->>''21'',''-1'') END AS moniitem21
            , mn.moniname22 AS moniname22
            , CASE WHEN mn.moniname22 IS NOT NULL THEN NULLIF(mm.monitor_data->>''22'',''-1'') END AS moniitem22
            , mn.moniname23 AS moniname23
            , CASE WHEN mn.moniname23 IS NOT NULL THEN NULLIF(mm.monitor_data->>''23'',''-1'') END AS moniitem23
            , mn.moniname24 AS moniname24
            , CASE WHEN mn.moniname24 IS NOT NULL THEN NULLIF(mm.monitor_data->>''24'',''-1'') END AS moniitem24
            , mn.moniname25 AS moniname25
            , CASE WHEN mn.moniname25 IS NOT NULL THEN NULLIF(mm.monitor_data->>''25'',''-1'') END AS moniitem25
            , mn.moniname26 AS moniname26
            , CASE WHEN mn.moniname26 IS NOT NULL THEN NULLIF(mm.monitor_data->>''26'',''-1'') END AS moniitem26
            , mn.moniname27 AS moniname27
            , CASE WHEN mn.moniname27 IS NOT NULL THEN NULLIF(mm.monitor_data->>''27'',''-1'') END AS moniitem27
            , mn.moniname28 AS moniname28
            , CASE WHEN mn.moniname28 IS NOT NULL THEN NULLIF(mm.monitor_data->>''28'',''-1'') END AS moniitem28
            , mn.moniname29 AS moniname29
            , CASE WHEN mn.moniname29 IS NOT NULL THEN NULLIF(mm.monitor_data->>''29'',''-1'') END AS moniitem29
            , mn.moniname30 AS moniname30
            , CASE WHEN mn.moniname30 IS NOT NULL THEN NULLIF(mm.monitor_data->>''30'',''-1'') END AS moniitem30
            , mn.moniname31 AS moniname31
            , CASE WHEN mn.moniname31 IS NOT NULL THEN NULLIF(mm.monitor_data->>''31'',''-1'') END AS moniitem31
            , mn.moniname32 AS moniname32
            , CASE WHEN mn.moniname32 IS NOT NULL THEN NULLIF(mm.monitor_data->>''32'',''-1'') END AS moniitem32
            , mn.moniname33 AS moniname33
            , CASE WHEN mn.moniname33 IS NOT NULL THEN NULLIF(mm.monitor_data->>''33'',''-1'') END AS moniitem33
            , mn.moniname34 AS moniname34
            , CASE WHEN mn.moniname34 IS NOT NULL THEN NULLIF(mm.monitor_data->>''34'',''-1'') END AS moniitem34
            , mn.moniname35 AS moniname35
            , CASE WHEN mn.moniname35 IS NOT NULL THEN NULLIF(mm.monitor_data->>''35'',''-1'') END AS moniitem35
            , mn.moniname36 AS moniname36
            , CASE WHEN mn.moniname36 IS NOT NULL THEN NULLIF(mm.monitor_data->>''36'',''-1'') END AS moniitem36
            , mn.moniname37 AS moniname37
            , CASE WHEN mn.moniname37 IS NOT NULL THEN NULLIF(mm.monitor_data->>''37'',''-1'') END AS moniitem37
            , mn.moniname38 AS moniname38
            , CASE WHEN mn.moniname38 IS NOT NULL THEN NULLIF(mm.monitor_data->>''38'',''-1'') END AS moniitem38
            , mn.moniname39 AS moniname39
            , CASE WHEN mn.moniname39 IS NOT NULL THEN NULLIF(mm.monitor_data->>''39'',''-1'') END AS moniitem39
            , mn.moniname40 AS moniname40
            , CASE WHEN mn.moniname40 IS NOT NULL THEN NULLIF(mm.monitor_data->>''40'',''-1'') END AS moniitem40
            , mn.moniname41 AS moniname41
            , CASE WHEN mn.moniname41 IS NOT NULL THEN NULLIF(mm.monitor_data->>''41'',''-1'') END AS moniitem41
            , mn.moniname42 AS moniname42
            , CASE WHEN mn.moniname42 IS NOT NULL THEN NULLIF(mm.monitor_data->>''42'',''-1'') END AS moniitem42
            , mn.moniname43 AS moniname43
            , CASE WHEN mn.moniname43 IS NOT NULL THEN NULLIF(mm.monitor_data->>''43'',''-1'') END AS moniitem43
            , mn.moniname44 AS moniname44
            , CASE WHEN mn.moniname44 IS NOT NULL THEN NULLIF(mm.monitor_data->>''44'',''-1'') END AS moniitem44
            , mn.moniname45 AS moniname45
            , CASE WHEN mn.moniname45 IS NOT NULL THEN NULLIF(mm.monitor_data->>''45'',''-1'') END AS moniitem45
            , mn.moniname46 AS moniname46
            , CASE WHEN mn.moniname46 IS NOT NULL THEN NULLIF(mm.monitor_data->>''46'',''-1'') END AS moniitem46
            , mn.moniname47 AS moniname47
            , CASE WHEN mn.moniname47 IS NOT NULL THEN NULLIF(mm.monitor_data->>''47'',''-1'') END AS moniitem47
            , mn.moniname48 AS moniname48
            , CASE WHEN mn.moniname48 IS NOT NULL THEN NULLIF(mm.monitor_data->>''48'',''-1'') END AS moniitem48
            , mn.moniname49 AS moniname49
            , CASE WHEN mn.moniname49 IS NOT NULL THEN NULLIF(mm.monitor_data->>''49'',''-1'') END AS moniitem49
            , mn.moniname50 AS moniname50
            , CASE WHEN mn.moniname50 IS NOT NULL THEN NULLIF(mm.monitor_data->>''50'',''-1'') END AS moniitem50
            , mn.moniname51 AS moniname51
            , CASE WHEN mn.moniname51 IS NOT NULL THEN NULLIF(mm.monitor_data->>''51'',''-1'') END AS moniitem51
            , mn.moniname52 AS moniname52
            , CASE WHEN mn.moniname52 IS NOT NULL THEN NULLIF(mm.monitor_data->>''52'',''-1'') END AS moniitem52
            , mn.moniname53 AS moniname53
            , CASE WHEN mn.moniname53 IS NOT NULL THEN NULLIF(mm.monitor_data->>''53'',''-1'') END AS moniitem53
            , mn.moniname54 AS moniname54
            , CASE WHEN mn.moniname54 IS NOT NULL THEN NULLIF(mm.monitor_data->>''54'',''-1'') END AS moniitem54
            , mn.moniname55 AS moniname55
            , CASE WHEN mn.moniname55 IS NOT NULL THEN NULLIF(mm.monitor_data->>''55'',''-1'') END AS moniitem55
            , mn.moniname56 AS moniname56
            , CASE WHEN mn.moniname56 IS NOT NULL THEN NULLIF(mm.monitor_data->>''56'',''-1'') END AS moniitem56
            , mn.moniname57 AS moniname57
            , CASE WHEN mn.moniname57 IS NOT NULL THEN NULLIF(mm.monitor_data->>''57'',''-1'') END AS moniitem57
            , mn.moniname58 AS moniname58
            , CASE WHEN mn.moniname58 IS NOT NULL THEN NULLIF(mm.monitor_data->>''58'',''-1'') END AS moniitem58
            , mn.moniname59 AS moniname59
            , CASE WHEN mn.moniname59 IS NOT NULL THEN NULLIF(mm.monitor_data->>''59'',''-1'') END AS moniitem59
            , mn.moniname60 AS moniname60
            , CASE WHEN mn.moniname60 IS NOT NULL THEN NULLIF(mm.monitor_data->>''60'',''-1'') END AS moniitem60
            , mn.moniname61 AS moniname61
            , CASE WHEN mn.moniname61 IS NOT NULL THEN NULLIF(mm.monitor_data->>''61'',''-1'') END AS moniitem61
            , mn.moniname62 AS moniname62
            , CASE WHEN mn.moniname62 IS NOT NULL THEN NULLIF(mm.monitor_data->>''62'',''-1'') END AS moniitem62
            , mn.moniname63 AS moniname63
            , CASE WHEN mn.moniname63 IS NOT NULL THEN NULLIF(mm.monitor_data->>''63'',''-1'') END AS moniitem63
            , mn.moniname64 AS moniname64
            , CASE WHEN mn.moniname64 IS NOT NULL THEN NULLIF(mm.monitor_data->>''64'',''-1'') END AS moniitem64
            , mn.moniname65 AS moniname65
            , CASE WHEN mn.moniname65 IS NOT NULL THEN NULLIF(mm.monitor_data->>''65'',''-1'') END AS moniitem65
            , mn.moniname66 AS moniname66
            , CASE WHEN mn.moniname66 IS NOT NULL THEN NULLIF(mm.monitor_data->>''66'',''-1'') END AS moniitem66
            , mn.moniname67 AS moniname67
            , CASE WHEN mn.moniname67 IS NOT NULL THEN NULLIF(mm.monitor_data->>''67'',''-1'') END AS moniitem67
            , mn.moniname68 AS moniname68
            , CASE WHEN mn.moniname68 IS NOT NULL THEN NULLIF(mm.monitor_data->>''68'',''-1'') END AS moniitem68
            , mn.moniname69 AS moniname69
            , CASE WHEN mn.moniname69 IS NOT NULL THEN NULLIF(mm.monitor_data->>''69'',''-1'') END AS moniitem69
            , mn.moniname70 AS moniname70
            , CASE WHEN mn.moniname70 IS NOT NULL THEN NULLIF(mm.monitor_data->>''70'',''-1'') END AS moniitem70
            , mn.moniname71 AS moniname71
            , CASE WHEN mn.moniname71 IS NOT NULL THEN NULLIF(mm.monitor_data->>''71'',''-1'') END AS moniitem71
            , mn.moniname72 AS moniname72
            , CASE WHEN mn.moniname72 IS NOT NULL THEN NULLIF(mm.monitor_data->>''72'',''-1'') END AS moniitem72
            , mn.moniname73 AS moniname73
            , CASE WHEN mn.moniname73 IS NOT NULL THEN NULLIF(mm.monitor_data->>''73'',''-1'') END AS moniitem73
            , mn.moniname74 AS moniname74
            , CASE WHEN mn.moniname74 IS NOT NULL THEN NULLIF(mm.monitor_data->>''74'',''-1'') END AS moniitem74
            , mn.moniname75 AS moniname75
            , CASE WHEN mn.moniname75 IS NOT NULL THEN NULLIF(mm.monitor_data->>''75'',''-1'') END AS moniitem75
            , mn.moniname76 AS moniname76
            , CASE WHEN mn.moniname76 IS NOT NULL THEN NULLIF(mm.monitor_data->>''76'',''-1'') END AS moniitem76
            , mn.moniname77 AS moniname77
            , CASE WHEN mn.moniname77 IS NOT NULL THEN NULLIF(mm.monitor_data->>''77'',''-1'') END AS moniitem77
            , mn.moniname78 AS moniname78
            , CASE WHEN mn.moniname78 IS NOT NULL THEN NULLIF(mm.monitor_data->>''78'',''-1'') END AS moniitem78
            , mn.moniname79 AS moniname79
            , CASE WHEN mn.moniname79 IS NOT NULL THEN NULLIF(mm.monitor_data->>''79'',''-1'') END AS moniitem79
            , mn.moniname80 AS moniname80
            , CASE WHEN mn.moniname80 IS NOT NULL THEN NULLIF(mm.monitor_data->>''80'',''-1'') END AS moniitem80
            , mn.moniname81 AS moniname81
            , CASE WHEN mn.moniname81 IS NOT NULL THEN NULLIF(mm.monitor_data->>''81'',''-1'') END AS moniitem81
            , mn.moniname82 AS moniname82
            , CASE WHEN mn.moniname82 IS NOT NULL THEN NULLIF(mm.monitor_data->>''82'',''-1'') END AS moniitem82
            , mn.moniname83 AS moniname83
            , CASE WHEN mn.moniname83 IS NOT NULL THEN NULLIF(mm.monitor_data->>''83'',''-1'') END AS moniitem83
            , mn.moniname84 AS moniname84
            , CASE WHEN mn.moniname84 IS NOT NULL THEN NULLIF(mm.monitor_data->>''84'',''-1'') END AS moniitem84
            , mn.moniname85 AS moniname85
            , CASE WHEN mn.moniname85 IS NOT NULL THEN NULLIF(mm.monitor_data->>''85'',''-1'') END AS moniitem85
            , mn.moniname86 AS moniname86
            , CASE WHEN mn.moniname86 IS NOT NULL THEN NULLIF(mm.monitor_data->>''86'',''-1'') END AS moniitem86
            , mn.moniname87 AS moniname87
            , CASE WHEN mn.moniname87 IS NOT NULL THEN NULLIF(mm.monitor_data->>''87'',''-1'') END AS moniitem87
            , mn.moniname88 AS moniname88
            , CASE WHEN mn.moniname88 IS NOT NULL THEN NULLIF(mm.monitor_data->>''88'',''-1'') END AS moniitem88
            , mn.moniname89 AS moniname89
            , CASE WHEN mn.moniname89 IS NOT NULL THEN NULLIF(mm.monitor_data->>''89'',''-1'') END AS moniitem89
            , mn.moniname90 AS moniname90
            , CASE WHEN mn.moniname90 IS NOT NULL THEN NULLIF(mm.monitor_data->>''90'',''-1'') END AS moniitem90
            , mn.moniname91 AS moniname91
            , CASE WHEN mn.moniname91 IS NOT NULL THEN NULLIF(mm.monitor_data->>''91'',''-1'') END AS moniitem91
            , mn.moniname92 AS moniname92
            , CASE WHEN mn.moniname92 IS NOT NULL THEN NULLIF(mm.monitor_data->>''92'',''-1'') END AS moniitem92
            , mn.moniname93 AS moniname93
            , CASE WHEN mn.moniname93 IS NOT NULL THEN NULLIF(mm.monitor_data->>''93'',''-1'') END AS moniitem93
            , mn.moniname94 AS moniname94
            , CASE WHEN mn.moniname94 IS NOT NULL THEN NULLIF(mm.monitor_data->>''94'',''-1'') END AS moniitem94
            , mn.moniname95 AS moniname95
            , CASE WHEN mn.moniname95 IS NOT NULL THEN NULLIF(mm.monitor_data->>''95'',''-1'') END AS moniitem95
            , mn.moniname96 AS moniname96
            , CASE WHEN mn.moniname96 IS NOT NULL THEN NULLIF(mm.monitor_data->>''96'',''-1'') END AS moniitem96
            , mn.moniname97 AS moniname97
            , CASE WHEN mn.moniname97 IS NOT NULL THEN NULLIF(mm.monitor_data->>''97'',''-1'') END AS moniitem97
            , mn.moniname98 AS moniname98
            , CASE WHEN mn.moniname98 IS NOT NULL THEN NULLIF(mm.monitor_data->>''98'',''-1'') END AS moniitem98
            , mn.moniname99 AS moniname99
            , CASE WHEN mn.moniname99 IS NOT NULL THEN NULLIF(mm.monitor_data->>''99'',''-1'') END AS moniitem99
            , mn.moniname100 AS moniname100
            , CASE WHEN mn.moniname100 IS NOT NULL THEN NULLIF(mm.monitor_data->>''100'',''-1'') END AS moniitem100
            , mn.moniname101 AS moniname101
            , CASE WHEN mn.moniname101 IS NOT NULL THEN NULLIF(mm.monitor_data->>''101'',''-1'') END AS moniitem101
            , mn.moniname102 AS moniname102
            , CASE WHEN mn.moniname102 IS NOT NULL THEN NULLIF(mm.monitor_data->>''102'',''-1'') END AS moniitem102
            , mn.moniname103 AS moniname103
            , CASE WHEN mn.moniname103 IS NOT NULL THEN NULLIF(mm.monitor_data->>''103'',''-1'') END AS moniitem103
            , mn.moniname104 AS moniname104
            , CASE WHEN mn.moniname104 IS NOT NULL THEN NULLIF(mm.monitor_data->>''104'',''-1'') END AS moniitem104
            , mn.moniname105 AS moniname105
            , CASE WHEN mn.moniname105 IS NOT NULL THEN NULLIF(mm.monitor_data->>''105'',''-1'') END AS moniitem105
            , mn.moniname106 AS moniname106
            , CASE WHEN mn.moniname106 IS NOT NULL THEN NULLIF(mm.monitor_data->>''106'',''-1'') END AS moniitem106
            , mn.moniname107 AS moniname107
            , CASE WHEN mn.moniname107 IS NOT NULL THEN NULLIF(mm.monitor_data->>''107'',''-1'') END AS moniitem107
            , mn.moniname108 AS moniname108
            , CASE WHEN mn.moniname108 IS NOT NULL THEN NULLIF(mm.monitor_data->>''108'',''-1'') END AS moniitem108
            , mn.moniname109 AS moniname109
            , CASE WHEN mn.moniname109 IS NOT NULL THEN NULLIF(mm.monitor_data->>''109'',''-1'') END AS moniitem109
            , mn.moniname110 AS moniname110
            , CASE WHEN mn.moniname110 IS NOT NULL THEN NULLIF(mm.monitor_data->>''110'',''-1'') END AS moniitem110
            , mn.moniname111 AS moniname111
            , CASE WHEN mn.moniname111 IS NOT NULL THEN NULLIF(mm.monitor_data->>''111'',''-1'') END AS moniitem111
            , mn.moniname112 AS moniname112
            , CASE WHEN mn.moniname112 IS NOT NULL THEN NULLIF(mm.monitor_data->>''112'',''-1'') END AS moniitem112
            , mn.moniname113 AS moniname113
            , CASE WHEN mn.moniname113 IS NOT NULL THEN NULLIF(mm.monitor_data->>''113'',''-1'') END AS moniitem113
            , mn.moniname114 AS moniname114
            , CASE WHEN mn.moniname114 IS NOT NULL THEN NULLIF(mm.monitor_data->>''114'',''-1'') END AS moniitem114
            , mn.moniname115 AS moniname115
            , CASE WHEN mn.moniname115 IS NOT NULL THEN NULLIF(mm.monitor_data->>''115'',''-1'') END AS moniitem115
            , mn.moniname116 AS moniname116
            , CASE WHEN mn.moniname116 IS NOT NULL THEN NULLIF(mm.monitor_data->>''116'',''-1'') END AS moniitem116
            , mn.moniname117 AS moniname117
            , CASE WHEN mn.moniname117 IS NOT NULL THEN NULLIF(mm.monitor_data->>''117'',''-1'') END AS moniitem117
            , mn.moniname118 AS moniname118
            , CASE WHEN mn.moniname118 IS NOT NULL THEN NULLIF(mm.monitor_data->>''118'',''-1'') END AS moniitem118
            , mn.moniname119 AS moniname119
            , CASE WHEN mn.moniname119 IS NOT NULL THEN NULLIF(mm.monitor_data->>''119'',''-1'') END AS moniitem119
            , mn.moniname120 AS moniname120
            , CASE WHEN mn.moniname120 IS NOT NULL THEN NULLIF(mm.monitor_data->>''120'',''-1'') END AS moniitem120
            , mn.moniname121 AS moniname121
            , CASE WHEN mn.moniname121 IS NOT NULL THEN NULLIF(mm.monitor_data->>''121'',''-1'') END AS moniitem121
            , mn.moniname122 AS moniname122
            , CASE WHEN mn.moniname122 IS NOT NULL THEN NULLIF(mm.monitor_data->>''122'',''-1'') END AS moniitem122
            , mn.moniname123 AS moniname123
            , CASE WHEN mn.moniname123 IS NOT NULL THEN NULLIF(mm.monitor_data->>''123'',''-1'') END AS moniitem123
            , mn.moniname124 AS moniname124
            , CASE WHEN mn.moniname124 IS NOT NULL THEN NULLIF(mm.monitor_data->>''124'',''-1'') END AS moniitem124
            , mn.moniname125 AS moniname125
            , CASE WHEN mn.moniname125 IS NOT NULL THEN NULLIF(mm.monitor_data->>''125'',''-1'') END AS moniitem125
            , mn.moniname126 AS moniname126
            , CASE WHEN mn.moniname126 IS NOT NULL THEN NULLIF(mm.monitor_data->>''126'',''-1'') END AS moniitem126
            , mn.moniname127 AS moniname127
            , CASE WHEN mn.moniname127 IS NOT NULL THEN NULLIF(mm.monitor_data->>''127'',''-1'') END AS moniitem127
            , mn.moniname128 AS moniname128
            , CASE WHEN mn.moniname128 IS NOT NULL THEN NULLIF(mm.monitor_data->>''128'',''-1'') END AS moniitem128
            , mn.moniname129 AS moniname129
            , CASE WHEN mn.moniname129 IS NOT NULL THEN NULLIF(mm.monitor_data->>''129'',''-1'') END AS moniitem129
            , mn.moniname130 AS moniname130
            , CASE WHEN mn.moniname130 IS NOT NULL THEN NULLIF(mm.monitor_data->>''130'',''-1'') END AS moniitem130
            , mn.moniname131 AS moniname131
            , CASE WHEN mn.moniname131 IS NOT NULL THEN NULLIF(mm.monitor_data->>''131'',''-1'') END AS moniitem131
            , mn.moniname132 AS moniname132
            , CASE WHEN mn.moniname132 IS NOT NULL THEN NULLIF(mm.monitor_data->>''132'',''-1'') END AS moniitem132
            , mn.moniname133 AS moniname133
            , CASE WHEN mn.moniname133 IS NOT NULL THEN NULLIF(mm.monitor_data->>''133'',''-1'') END AS moniitem133
            , mn.moniname134 AS moniname134
            , CASE WHEN mn.moniname134 IS NOT NULL THEN NULLIF(mm.monitor_data->>''134'',''-1'') END AS moniitem134
            , mn.moniname135 AS moniname135
            , CASE WHEN mn.moniname135 IS NOT NULL THEN NULLIF(mm.monitor_data->>''135'',''-1'') END AS moniitem135
            , mn.moniname136 AS moniname136
            , CASE WHEN mn.moniname136 IS NOT NULL THEN NULLIF(mm.monitor_data->>''136'',''-1'') END AS moniitem136
            , mn.moniname137 AS moniname137
            , CASE WHEN mn.moniname137 IS NOT NULL THEN NULLIF(mm.monitor_data->>''137'',''-1'') END AS moniitem137
            , mn.moniname138 AS moniname138
            , CASE WHEN mn.moniname138 IS NOT NULL THEN NULLIF(mm.monitor_data->>''138'',''-1'') END AS moniitem138
            , mn.moniname139 AS moniname139
            , CASE WHEN mn.moniname139 IS NOT NULL THEN NULLIF(mm.monitor_data->>''139'',''-1'') END AS moniitem139
            , mn.moniname140 AS moniname140
            , CASE WHEN mn.moniname140 IS NOT NULL THEN NULLIF(mm.monitor_data->>''140'',''-1'') END AS moniitem140
            , mn.moniname141 AS moniname141
            , CASE WHEN mn.moniname141 IS NOT NULL THEN NULLIF(mm.monitor_data->>''141'',''-1'') END AS moniitem141
            , mn.moniname142 AS moniname142
            , CASE WHEN mn.moniname142 IS NOT NULL THEN NULLIF(mm.monitor_data->>''142'',''-1'') END AS moniitem142
            , mn.moniname143 AS moniname143
            , CASE WHEN mn.moniname143 IS NOT NULL THEN NULLIF(mm.monitor_data->>''143'',''-1'') END AS moniitem143
            , mn.moniname144 AS moniname144
            , CASE WHEN mn.moniname144 IS NOT NULL THEN NULLIF(mm.monitor_data->>''144'',''-1'') END AS moniitem144
            , mn.moniname145 AS moniname145
            , CASE WHEN mn.moniname145 IS NOT NULL THEN NULLIF(mm.monitor_data->>''145'',''-1'') END AS moniitem145
            , mn.moniname146 AS moniname146
            , CASE WHEN mn.moniname146 IS NOT NULL THEN NULLIF(mm.monitor_data->>''146'',''-1'') END AS moniitem146
            , mn.moniname147 AS moniname147
            , CASE WHEN mn.moniname147 IS NOT NULL THEN NULLIF(mm.monitor_data->>''147'',''-1'') END AS moniitem147
            , mn.moniname148 AS moniname148
            , CASE WHEN mn.moniname148 IS NOT NULL THEN NULLIF(mm.monitor_data->>''148'',''-1'') END AS moniitem148
            , mn.moniname149 AS moniname149
            , CASE WHEN mn.moniname149 IS NOT NULL THEN NULLIF(mm.monitor_data->>''149'',''-1'') END AS moniitem149
            , mn.moniname150 AS moniname150
            , CASE WHEN mn.moniname150 IS NOT NULL THEN NULLIF(mm.monitor_data->>''150'',''-1'') END AS moniitem150
            , mn.moniname151 AS moniname151
            , CASE WHEN mn.moniname151 IS NOT NULL THEN NULLIF(mm.monitor_data->>''-1'',''-1'') END AS moniitem151
            , mn.moniname152 AS moniname152
            , CASE WHEN mn.moniname152 IS NOT NULL THEN NULLIF(mm.monitor_data->>''-2'',''-1'') END AS moniitem152
            , to_char(mm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
            , om.ord_no AS ordno --透析番号
            , om.treat_date AS dialysisdate --透析日
        FROM
            ord_main om
            cross join moni_names mn
            JOIN mni_monitor mm
                ON mm.ord_no = om.ord_no
                AND mm.facility_cd = @facilityCd
                AND mm.is_del = ''0''
            LEFT JOIN mst_machine m_m
                ON m_m.machine_no = om.rst_machine_no
                AND m_m.facility_cd = @facilityCd
                AND m_m.is_del = ''0''
                AND m_m.is_disp = ''1''
            LEFT JOIN mst_bed m_b
                ON om.rst_bed_cd = m_b.bed_cd
                AND m_b.is_del = ''0''
                AND m_b.is_disp = ''1''
        WHERE
            om.facility_cd = @facilityCd
            AND om.is_del = ''0''
            AND @fromDate <= om.treat_date AND om.treat_date < @toDate
            AND mm.data_type IN (1,2,5,6);
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2300, '-- 【SQL_CD=-2300】
with ord_main_tmp as(
    select
        ord_no
        ,pat_id
        ,treat_date
        ,ind_treat_start_time
        ,rst_dialysis_state
        ,rst_cond_send_date
        ,rst_start_date
        ,rst_end_date
        ,to_char((rst_weight_info ->> ''weight_after_date'')::TIMESTAMPTZ AT TIME ZONE ''Asia/Tokyo'', ''YYYY-MM-DD hh24:mi:ss'') as weightafterdate
        ,rst_edition_date
        ,cur_edition_date
        ,facility_cd
        from
            ord_main
        where
            facility_cd = @facilityCd
            and @fromDate <= treat_date AND treat_date < @toDate
            AND is_del = ''0''
    )
,mnt_motion_record_tmp as
    (select
        mnt.ord_no
        ,mnt.machine_record_cd 
        ,mnt.event_reg_date
    from
        mnt_motion_record mnt
    where
        mnt.facility_cd = @facilityCd
        and mnt.machine_record_cd in(''4000'',''5F00'',''F407'',''F409'',''F406'',''F408'')
        and exists (
            select 1
            from ord_main_tmp ord
            where ord.ord_no = mnt.ord_no
        )
)
,off_water_tmp as
    (select
        ord_no
        ,machine_record_cd 
        ,event_reg_date
    from(
        select
            mnt.ord_no
            ,mnt.machine_record_cd
            ,mnt.event_reg_date
            ,row_number() OVER (PARTITION BY mnt.ord_no ORDER BY mnt.event_reg_date DESC) as rn
        from
            mnt_motion_record_tmp as mnt
            left join ord_main_tmp as ord on ord.ord_no = mnt.ord_no
        where
            mnt.machine_record_cd in(''4000'',''5F00'')
        )waterranked
    where
        rn = 1
)
,machine_check_tmp as(
select
    ord_no
    ,case when machine_record_cd in (''F407'',''F409'') then ''1''
        else null
    end as machinecheckflg
    ,case when machine_record_cd in (''F406'',''F408'') then null --最新レコードがF406、F408だった時は除水完了日時をnullにする
        else event_reg_date
    end as machinecheckdate
    from(
        select
            mnt.ord_no
            ,mnt.machine_record_cd
            ,mnt.event_reg_date
            ,row_number() OVER (PARTITION BY mnt.ord_no ORDER BY mnt.event_reg_date DESC) as rn
        from
            mnt_motion_record_tmp as mnt
            left join ord_main_tmp as ord on ord.ord_no = mnt.ord_no
        where 
            mnt.machine_record_cd in(''F407'',''F409'',''F406'',''F408'')
    )machineranked
    where
        rn = 1
)
SELECT
    ord.pat_id as patid --患者ID(外部キー用)
    ,'''' as hosppatid --表示患者ID(外部キーから取得)
    ,ord.treat_date as dialysisdate --透析日
    ,ord.ind_treat_start_time as dialysistime --透析開始時刻
    ,to_char(to_timestamp(treat_date||ind_treat_start_time||''0000'',''YYYYMMDDHH24MISSMS'')AT TIME ZONE ''Asia/Tokyo'', ''YYYY-MM-DD hh24:mi:ss'') as startplandate --予定開始日時
    ,CASE
        WHEN ord.rst_cond_send_date is null then ''0'' else ''1''
    END as enterflg --入室フラグ（前体重測定）
    ,to_char(ord.rst_cond_send_date, ''YYYY-MM-DD hh24:mi:ss'') as enterdate --初回入室日時(前体重測定日時)
    ,CASE
        WHEN machine.machinecheckflg is null then ''0'' else ''1''
    END as machinecheckflg --透析装置確認フラグ
    ,to_char(machine.machinecheckdate, ''YYYY-MM-DD hh24:mi:ss'') as machinecheckdate --透析装置確認日時
    ,CASE
        WHEN ord.rst_dialysis_state IN (''0'', ''1'', ''2'') then ''0''
        WHEN ord.rst_dialysis_state IN (''3'',''4'', ''5'', ''6'') then ''1''
    END as dialsisstartflg --透析運転開始フラグ
    ,to_char(ord.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') as dialsisstartdate--透析運転開始日時
    ,CASE
        WHEN water.machine_record_cd is null then ''0'' ELSE ''1''
    END as offwaterflg --除水完了フラグ
    ,to_char(water.event_reg_date, ''YYYY-MM-DD hh24:mi:ss'') as offwaterdate --除水完了日時
    ,CASE
        WHEN ord.rst_dialysis_state IN (''0'',''1'',''2'',''3'') then ''0''
        WHEN ord.rst_dialysis_state IN (''4'',''5'',''6'') then ''1''
    END as wastefluidflg --排液フラグ
    ,to_char(ord.rst_end_date, ''YYYY-MM-DD hh24:mi:ss'')  as wastefluiddate --排液日時
    ,CASE
        WHEN ord.rst_dialysis_state IN (''0'',''1'',''2'',''3'',''4'') then ''0''
        WHEN ord.rst_dialysis_state IN (''5'',''6'') then ''1''
    END as weightafterflg --後体重測定フラグ
    ,ord.weightafterdate --後体重測定日時
    ,CASE
        WHEN ord.rst_dialysis_state IN (''0'',''1'',''2'',''3'',''4'',''5'') then ''0''
        WHEN ord.rst_dialysis_state IN (''6'') then ''1''
    END as recoverybtnflg --準備回収確認ボタンフラグ
    ,to_char(ord.rst_edition_date, ''YYYY-MM-DD hh24:mi:ss'') as recoverybtndate--準備回収確認ボタン日時
    ,to_char(ord.cur_edition_date, ''YYYY-MM-DD hh24:mi:ss'') as update --更新日時
    ,ord.ord_no AS dialysisno --透析番号
from
    ord_main_tmp as ord
    left join off_water_tmp as water on ord.ord_no = water.ord_no
    left join machine_check_tmp as machine on ord.ord_no = machine.ord_no;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2240, '-- 【SQL_CD=-2240】
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , to_char(ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS startdate      --開始日時
    , to_char(ntss_db5_mm.occur_date, ''YYYY-MM-DD hh24:mi:ss'') AS occurdate          --発生日時
    , ntss_db5_mm.monitor_data ->> ''90'' AS bpmax                            --最高血圧
    , ntss_db5_mm.monitor_data ->> ''91'' AS bpmin                            --最低血圧
    , ntss_db5_mm.monitor_data ->> ''92'' AS bpave                            --平均血圧
    , ntss_db5_mm.monitor_data ->> ''93'' AS pulse                            --脈拍
    , ntss_db5_mm.monitor_data ->> ''94'' AS temperature                      --体温
    , ntss_db5_mm.monitor_data ->> ''-1'' AS bloodsugarlevel                  --血糖値
    , to_char(ntss_db5_mm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update       --更新日時
    , ntss_db5_om.ord_no AS diadysisno        --透析番号
    , CASE
        WHEN ntss_db5_mm.data_type = ''5'' THEN ''1''
        WHEN ntss_db5_mm.data_type IN (''2'', ''4'') THEN ''0''
        WHEN ntss_db5_mm.data_type = ''6'' THEN ''2''
        END AS bpclass                          --血圧区分
    , ntss_db5_om.treat_date AS dialysisdate        --透析日
FROM
    ord_main ntss_db5_om
    INNER JOIN mni_monitor ntss_db5_mm
        ON ntss_db5_mm.ord_no = ntss_db5_om.ord_no
        AND ntss_db5_om.facility_cd = ntss_db5_mm.facility_cd
        AND ntss_db5_mm.is_del = ''0''
WHERE
    ntss_db5_om.facility_cd = @facilityCd
    AND ntss_db5_mm.data_type IN (''2'', ''4'', ''5'', ''6'')
    AND @fromDate <= ntss_db5_om.treat_date AND ntss_db5_om.treat_date < @toDate
    AND ntss_db5_om.is_del = ''0'';
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2200, '-- 【SQL_CD=-2200】6.3対応
WITH 
    ord_main_head as
    (
        select
            ord_main.ord_no 
           ,ord_main.pat_id 
           ,ord_main.treat_date 
           ,ord_main.treat_week 
           ,ord_main.facility_cd 
           ,ord_main.ind_cond_info 
           ,ord_main.ind_equip_info 
           ,ord_main.ind_treatment_cd 
           ,ord_main.ind_treat_start_time 
           ,ord_main.up_date 
        from
            ord_main
        WHERE
            ord_main.is_del = ''0''
            AND ord_main.facility_cd = @facilityCd
            AND ord_main.pat_id IS NOT NULL
            AND @fromDate <= treat_date AND treat_date < @toDate
    ),
    mst_treatment_disp_order_tbl AS 
    (
        SELECT
            one_json ->> ''code'' AS treatment_cd
            , json_idx AS treatment_cd_order
        FROM
            mst_selector
            CROSS JOIN lateral jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(one_json, json_idx)
        WHERE
            facility_cd = @facilityCd
            AND master_physical_name = ''mst_treatment''
            AND one_json ->> ''isDel'' = ''0''
            AND one_json ->> ''isDisp'' = ''1''
    ),
    ntss_db5_om_1 AS 
    (
        SELECT
            ntss_db5_om_1.ord_no
            , ROW_NUMBER() OVER (PARTITION BY ntss_db5_om_1.pat_id, ntss_db5_om_1.treat_date ORDER BY ntss_db5_om_1.ind_treat_start_time ASC, mst_treatment_disp_order_tbl.treatment_cd_order ASC) AS plural
        FROM
            ord_main_head ntss_db5_om_1
            LEFT JOIN mst_treatment_disp_order_tbl
            ON ntss_db5_om_1.ind_treatment_cd ::text = mst_treatment_disp_order_tbl.treatment_cd
    ),
    ntss_db5_mst_e AS 
    ( 
        select
            ntss_db5_mst_e.equipment_cd,
            ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
            ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2,
            ntss_db5_mst_e.up_date AS up_date,
            ntss_db5_mst_e.equipment_name AS equipment_name,
            ntss_db5_mst_e.unit AS unit, 
            ntss_db5_mst_e.class_cd AS class_cd
        FROM 
            mst_equipment ntss_db5_mst_e -- 医療材料マスタ 
        WHERE 
            ntss_db5_mst_e.facility_cd = @facilityCd 
            AND ntss_db5_mst_e.is_del = ''0''
            AND ntss_db5_mst_e.is_disp = ''1''
    ),
    mst_equipment_class AS 
    ( 
        select
            mst_equipment_class.class_name as class_name,
            mst_equipment_class.class_cd
        FROM 
            mst_equipment_class -- 医療材料分類マスタ 
        WHERE
            mst_equipment_class.facility_cd = @facilityCd 
            AND mst_equipment_class.is_del = ''0''
            AND mst_equipment_class.is_disp = ''1''
    ),
    ntss_db5_om_iei_json AS 
    (
        SELECT
            ntss_db5_om_iei_json ->> ''amount'' AS amount,
            ntss_db5_om_iei_json ->> ''cd'' AS cd,
            ntss_db5_om_iei_json ->> ''needle_type'' AS needle_type,
            ntss_db5_om_iei_json ->> ''ind_user_id'' AS ind_user_id,
            om.ord_no AS ord_no
        FROM
            ord_main_head om
            CROSS JOIN LATERAL jsonb_array_elements ( om.ind_equip_info :: JSONB ) ntss_db5_om_iei_json
    ),
    ntss_db5_om_ici_json as
    (
        select
            omj.key
            , (omj.obj ->> ''value'') AS value
            , (omj.obj ->> ''ind_user_id'') AS ind_user_id
            , om.ord_no AS ord_no
        FROM
            ord_main_head om
            CROSS JOIN lateral (
                select
                    k as key
                    , (coalesce(om.ind_cond_info::jsonb) -> k) as obj
                    from unnest(array[''6'',''7'',''8'',''9'',''10'',''11'',''13'']:: text[]) as k
            ) as omj
        WHERE
            (omj.obj ->> ''value'') is not null
    ),
    ntss_db5_mst_list AS 
    (
        SELECT
            ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
            ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2,
            mst_equipment_class.class_name AS class_name, -- 医療材料分類マスタから取得
            ntss_db5_mst_e.equipment_name AS equipname,
            om.needle_type AS puncture_class,
            om.amount AS amount,
            ntss_db5_mst_e.unit AS unit,
            '''' AS comments,
            om.ord_no AS ord_no,
            ntss_db5_mst_e.up_date AS up_date,
            ntss_db5_mst_e.equipment_cd,
            om.ind_user_id,
            om.cd
        FROM
            ntss_db5_om_iei_json om
            LEFT JOIN ntss_db5_mst_e ON om.cd = ntss_db5_mst_e.equipment_cd::TEXT
            LEFT JOIN mst_equipment_class ON ntss_db5_mst_e.class_cd = mst_equipment_class.class_cd
    ), 
    ntss_db5_mst_list_ici AS 
    (
        SELECT
            ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
            ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2,
            mst_equipment_class.class_name AS class_name, -- 医療材料分類マスタから取得
            ntss_db5_mst_e.equipment_name AS equipname,
            ntss_db5_mst_e.unit AS unit,
            '''' AS comments,
            om.ord_no AS ord_no,
            ntss_db5_mst_e.up_date AS up_date,
            ntss_db5_mst_e.equipment_cd,
            om.ind_user_id,
            om.value,
            om.key
        FROM
            ntss_db5_om_ici_json om
            LEFT JOIN ntss_db5_mst_e ON om.value = ntss_db5_mst_e.equipment_cd::TEXT
            LEFT JOIN mst_equipment_class ON ntss_db5_mst_e.class_cd = mst_equipment_class.class_cd
    ), 
    ntss_db5_ptp AS 
    (
        SELECT
            ntss_db5_ptp.pat_id, 
            ntss_db5_ptp.treat_week, 
            ntss_db5_ptp.ind_treatment_cd,
            ''1'' AS flg
        FROM
            pat_treatment_pattern ntss_db5_ptp
        WHERE
            ntss_db5_ptp.facility_cd = @facilityCd
    ),
    ntss_db5_mst_sel AS
    (
        SELECT
            facility_cd
            , ntss_db5_mst_sel_json ->> ''code'' AS code
            , ROW_NUMBER() OVER() AS sortkey
        FROM
            mst_selector ms
        CROSS JOIN LATERAL jsonb_array_elements(ms.order_settings ::jsonb -> ''items'') ntss_db5_mst_sel_json
        WHERE ms.master_physical_name = ''mst_equipment''
        AND ms.facility_cd = @facilityCd 
        AND ntss_db5_mst_sel_json ->> ''isDel'' = ''0''
        AND ntss_db5_mst_sel_json ->> ''isDisp'' = ''1''
    )
    ,union_tmp AS
    (
    SELECT
        ord_main_head.pat_id AS patid
        ,ord_main_head.treat_date AS dialysisdate -- 透析日
        ,to_char( ord_main_head.up_date, ''YYYY-MM-DD hh24:mi:ss'' ) AS update -- 更新日時
        ,ntss_db5_mst_list.in_hospital_cd_1 AS equipcd -- 医療材料コード(院内コード1)
        ,ntss_db5_mst_list.in_hospital_cd_2 AS equipcd2 -- 医療材料コード(院内コード2)
        ,ntss_db5_mst_list.class_name AS equipclassname -- 医療材料分類名
        ,ntss_db5_mst_list.equipname AS equipname -- 医療材料名
        , CASE ntss_db5_mst_list.puncture_class
            WHEN ''1'' THEN ntss_db5_mst_list.puncture_class
            WHEN ''2'' THEN ntss_db5_mst_list.puncture_class
            WHEN ''3'' THEN ntss_db5_mst_list.puncture_class
            ELSE ''0''
            END AS punctureclass -- 穿刺針区分
        ,ntss_db5_mst_list.amount AS amount -- 数量
        ,ntss_db5_mst_list.unit AS unit -- 単位
        ,ntss_db5_mst_list.ind_user_id AS indicatorcd -- 指示者
        ,  CASE
            WHEN ntss_db5_ptp.flg = ''1''
                THEN ''0''
            ELSE ''1''
            END AS opeindplan    -- 予定作成区分
        ,ord_main_head.ord_no AS dialysisno --透析番号
        ,ntss_db5_mst_list.cd AS cd
    FROM
        ord_main_head
        INNER JOIN ntss_db5_mst_list ON ntss_db5_mst_list.ord_no = ord_main_head.ord_no
        LEFT JOIN ntss_db5_ptp
            ON ntss_db5_ptp.pat_id = ord_main_head.pat_id
            AND ntss_db5_ptp.treat_week = ord_main_head.treat_week
            AND ntss_db5_ptp.ind_treatment_cd = ord_main_head.ind_treatment_cd
    UNION ALL
        SELECT
        ord_main_head.pat_id AS patid
        ,ord_main_head.treat_date AS dialysisdate -- 透析日
        ,to_char( ord_main_head.up_date, ''YYYY-MM-DD hh24:mi:ss'' ) AS update -- 更新日時
        ,ntss_db5_mst_list_ici.in_hospital_cd_1 AS equipcd -- 医療材料コード(院内コード1)
        ,ntss_db5_mst_list_ici.in_hospital_cd_2 AS equipcd2 -- 医療材料コード(院内コード2)
        ,ntss_db5_mst_list_ici.class_name AS equipclassname -- 医療材料分類名
        ,ntss_db5_mst_list_ici.equipname AS equipname -- 医療材料名
        , CASE ntss_db5_mst_list_ici.key
            WHEN ''9'' THEN ''1''
            WHEN ''10'' THEN ''2''
            WHEN ''11'' THEN ''3''
            ELSE ''0''
            END AS punctureclass -- 穿刺針区分
        ,''1'' AS amount -- 数量
        ,ntss_db5_mst_list_ici.unit AS unit -- 単位
        ,ntss_db5_mst_list_ici.ind_user_id AS indicatorcd -- 指示者
        ,  CASE
            WHEN ntss_db5_ptp.flg = ''1''
                THEN ''0''
            ELSE ''1''
            END AS opeindplan    -- 予定作成区分
        ,ord_main_head.ord_no AS dialysisno --透析番号
        ,ntss_db5_mst_list_ici.value AS cd
    FROM
        ord_main_head
        INNER JOIN ntss_db5_mst_list_ici ON ntss_db5_mst_list_ici.ord_no = ord_main_head.ord_no
        LEFT JOIN ntss_db5_ptp
            ON ntss_db5_ptp.pat_id = ord_main_head.pat_id
            AND ntss_db5_ptp.treat_week = ord_main_head.treat_week
            AND ntss_db5_ptp.ind_treatment_cd = ord_main_head.ind_treatment_cd
            )
    SELECT
        '''' AS hosppatid -- 患者ID(連携用)
        ,union_tmp.patid
        ,union_tmp.dialysisdate -- 透析日
        ,ntss_db5_om_1.plural AS plural -- 同日複数回
        ,(row_number() over (PARTITION BY union_tmp.dialysisno ORDER BY ntss_db5_mst_sel.sortkey ASC, (union_tmp.cd)::integer))::text AS ctlno -- 項目番号
        ,union_tmp.update -- 更新日時
        ,union_tmp.equipcd -- 医療材料コード(院内コード1)
        ,union_tmp.equipcd2 -- 医療材料コード(院内コード2)
        ,union_tmp.equipclassname -- 医療材料分類名
        ,union_tmp.equipname -- 医療材料名
        ,union_tmp.punctureclass -- 穿刺針区分
        ,union_tmp.amount-- 数量
        ,union_tmp.unit -- 単位
        ,'''' AS comments -- コメント
        ,'''' AS indicatorcd --指示者
        ,union_tmp.indicatorcd AS userid --指示者コード(連携用)
        ,union_tmp.opeindplan-- 予定作成区分
        ,union_tmp.dialysisno --透析番号
    FROM
        union_tmp
        LEFT JOIN ntss_db5_mst_sel ON union_tmp.cd ::TEXT = ntss_db5_mst_sel.code
        LEFT JOIN ntss_db5_om_1 ON ntss_db5_om_1.ord_no = union_tmp.dialysisno
;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2190, '-- 【SQL_CD=-2190】
WITH ntss_db5_om_temp AS (
    SELECT
        om.ord_no
        ,om.pat_id
        ,om.treat_date AS dialysisdate
        ,om.treat_date AS treat_date
        ,om.treat_week
        ,om.ind_cond_info
        ,om.ind_treat_start_time
        ,om.ind_schedule_user_info ->> ''ind_user_id'' AS ind_user_id
        ,om.ind_treatment_cd
        ,om.up_date
    FROM
        ord_main om
    WHERE
        om.facility_cd = @facilityCd
        AND om.is_del = ''0''
        AND @fromDate <= om.treat_date AND om.treat_date < @toDate
)
, mst_treatment_disp_order_tbl AS (
    SELECT
        one_json ->> ''code'' AS treatment_cd
        , json_idx AS treatment_cd_order
    FROM
        mst_selector
        CROSS JOIN lateral jsonb_array_elements(order_settings -> ''items'') WITH ordinality AS tmp(one_json, json_idx)
    WHERE
        facility_cd = @facilityCd
        AND master_physical_name = ''mst_treatment''
        AND one_json ->> ''isDel'' = ''0''
        AND one_json ->> ''isDisp'' = ''1''
)
, ntss_db5_om_1 AS (
    SELECT
        ntss_db5_om_temp.ord_no
        , ROW_NUMBER() OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date ORDER BY ntss_db5_om_temp.ind_treat_start_time ASC, mst_treatment_disp_order_tbl.treatment_cd_order ASC) AS plural
    FROM
        ntss_db5_om_temp
        LEFT JOIN mst_treatment_disp_order_tbl
        ON (ntss_db5_om_temp.ind_treatment_cd)::text = mst_treatment_disp_order_tbl.treatment_cd
)
, ntss_db5_pu AS (
    SELECT
        pu_temp.pat_id
        , pu_temp.up_date
        , phy_temp ->> ''dw'' AS dw
        , phy_temp ->> ''indicator_cd'' AS indicator_cd
        , ROW_NUMBER () OVER (PARTITION BY pat_id ORDER BY phy_temp ->> ''exam_date'' DESC, phy_temp ->> ''ctl_no'' DESC) AS rowno
    FROM
        pat_unique pu_temp
        CROSS JOIN lateral jsonb_array_elements(pu_temp.physical_info ::jsonb) phy_temp
    WHERE
        pu_temp.facility_cd = @facilityCd
        AND pu_temp.is_del = ''0''
        AND phy_temp ->> ''dw'' IS NOT NULL
)
, ntss_db5_mst_t AS (
    SELECT
        ntss_db5_mst_t.treatment_cd
        , ntss_db5_mst_t.treatment_name
        , CAST(ntss_db5_mst_t.in_hosp_a_startdate AS date) AS in_hosp_a_startdate
        , ntss_db5_mst_t.in_hospital_cd_a1
        , ntss_db5_mst_t.in_hospital_cd_a2
        , CAST(ntss_db5_mst_t.in_hosp_b_startdate AS date) AS in_hosp_b_startdate
        , ntss_db5_mst_t.in_hospital_cd_b1
        , ntss_db5_mst_t.in_hospital_cd_b2
    FROM
        mst_treatment ntss_db5_mst_t
    WHERE
        ntss_db5_mst_t.facility_cd = @facilityCd
        AND ntss_db5_mst_t.is_del = ''0''
        AND ntss_db5_mst_t.is_disp = ''1''
)
, ind_cond_list AS (
    SELECT --ind_cond_info
        ntss_db5_om_temp.ord_no
        , ind_cond_info_json.key AS key
        , ind_cond_info_json.val ->> ''value'' AS value
        , ind_cond_info_json.val ->> ''value_name_1'' AS value_name_1
        , ind_cond_info_json.val ->> ''unit'' AS unit
        , '''' AS valuecd2
        , ind_cond_info_json.val ->> ''medicine_type'' AS medicine_type
        , ind_cond_info_json.val ->> ''ind_user_id'' AS ind_user_id
        , '''' AS up_date
    FROM
        ntss_db5_om_temp
        CROSS JOIN LATERAL jsonb_each(ntss_db5_om_temp.ind_cond_info::jsonb) AS ind_cond_info_json(key, val)
    WHERE
        ind_cond_info_json.key IN(''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''12'',''14'',''15'',''16'',''17'',''18'',''19'',''20'',''21'',''22'',''23'',''24'',''25'',''26'',''27'',''28'',''29'',''30'',''31'',''32'',''33'',''34'',''35'',''36'',''37'',''38'')
    UNION ALL
    SELECT --治療開始時刻
        ntss_db5_om_temp.ord_no
        , ''991'' AS key
        , ntss_db5_om_temp.ind_treat_start_time AS value
        , ''透析開始時刻'' AS value_name_1
        , '''' AS unit
        , '''' AS valuecd2
        , '''' AS medicine_type
        , ntss_db5_om_temp.ind_user_id
        , '''' AS up_date
    FROM
        ntss_db5_om_temp
    UNION ALL
    SELECT --dw
        ntss_db5_om_temp.ord_no
        , ''992'' AS key
        , ntss_db5_pu.dw AS value
        , '''' AS value_name_1
        , ''kg'' AS unit
        , '''' AS valuecd2
        , '''' AS medicine_type
        , ntss_db5_pu.indicator_cd AS ind_user_id
        , to_char(ntss_db5_pu.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS up_date
    FROM
        ntss_db5_om_temp
        LEFT JOIN ntss_db5_pu
            ON ntss_db5_om_temp.pat_id = ntss_db5_pu.pat_id
            AND ntss_db5_pu.rowno = 1
    UNION ALL
    SELECT --治療方法
        ntss_db5_om_temp.ord_no
        , ''993'' AS key
        , CASE
            WHEN ntss_db5_om_temp.treat_date >= to_char(ntss_db5_mst_t.in_hosp_a_startdate, ''YYYYMMDD'')
            AND ntss_db5_om_temp.treat_date >= to_char(ntss_db5_mst_t.in_hosp_b_startdate, ''YYYYMMDD'')
                THEN CASE
                    WHEN ntss_db5_mst_t.in_hosp_a_startdate >= ntss_db5_mst_t.in_hosp_b_startdate
                        THEN ntss_db5_mst_t.in_hospital_cd_a1
                    WHEN ntss_db5_mst_t.in_hosp_a_startdate < ntss_db5_mst_t.in_hosp_b_startdate
                        THEN ntss_db5_mst_t.in_hospital_cd_b1
                    END
            WHEN ntss_db5_om_temp.treat_date >= to_char(ntss_db5_mst_t.in_hosp_a_startdate, ''YYYYMMDD'')
            AND (ntss_db5_om_temp.treat_date < to_char(ntss_db5_mst_t.in_hosp_b_startdate, ''YYYYMMDD'')
                OR ntss_db5_mst_t.in_hosp_b_startdate IS NULL)
                THEN ntss_db5_mst_t.in_hospital_cd_a1
            WHEN (ntss_db5_om_temp.treat_date < to_char(ntss_db5_mst_t.in_hosp_a_startdate, ''YYYYMMDD'')
                OR ntss_db5_mst_t.in_hosp_a_startdate IS NULL)
            AND ntss_db5_om_temp.treat_date >= to_char(ntss_db5_mst_t.in_hosp_b_startdate, ''YYYYMMDD'')
                THEN ntss_db5_mst_t.in_hospital_cd_b1
            ELSE NULL
            END AS value
        , ntss_db5_mst_t.treatment_name AS value_name_1
        , '''' AS unit
        , CASE
            WHEN ntss_db5_om_temp.treat_date >= to_char(ntss_db5_mst_t.in_hosp_a_startdate, ''YYYYMMDD'')
            AND ntss_db5_om_temp.treat_date >= to_char(ntss_db5_mst_t.in_hosp_b_startdate, ''YYYYMMDD'')
                THEN CASE
                    WHEN ntss_db5_mst_t.in_hosp_a_startdate >= ntss_db5_mst_t.in_hosp_b_startdate
                        THEN ntss_db5_mst_t.in_hospital_cd_a2
                    WHEN ntss_db5_mst_t.in_hosp_a_startdate < ntss_db5_mst_t.in_hosp_b_startdate
                        THEN ntss_db5_mst_t.in_hospital_cd_b2
                    END
            WHEN ntss_db5_om_temp.treat_date >= to_char(ntss_db5_mst_t.in_hosp_a_startdate, ''YYYYMMDD'')
            AND (ntss_db5_om_temp.treat_date < to_char(ntss_db5_mst_t.in_hosp_b_startdate, ''YYYYMMDD'')
                OR ntss_db5_mst_t.in_hosp_b_startdate IS NULL)
                THEN ntss_db5_mst_t.in_hospital_cd_a2
            WHEN (ntss_db5_om_temp.treat_date < to_char(ntss_db5_mst_t.in_hosp_a_startdate, ''YYYYMMDD'')
                OR ntss_db5_mst_t.in_hosp_a_startdate IS NULL)
            AND ntss_db5_om_temp.treat_date >= to_char(ntss_db5_mst_t.in_hosp_b_startdate, ''YYYYMMDD'')
                THEN ntss_db5_mst_t.in_hospital_cd_b2
            ELSE NULL
            END AS valuecd2
        , '''' AS medicine_type
        , ntss_db5_om_temp.ind_user_id
        , '''' AS up_date
    FROM
        ntss_db5_om_temp
        LEFT JOIN ntss_db5_mst_t
        ON ntss_db5_om_temp.ind_treatment_cd = ntss_db5_mst_t.treatment_cd
)
, ntss_db5_mst_v AS (
    SELECT
        ntss_db5_mst_v.va_cd
        , ntss_db5_mst_v.va_name
        , ntss_db5_mst_v.in_hospital_cd_1
        , ntss_db5_mst_v.in_hospital_cd_2
    FROM
        mst_va ntss_db5_mst_v
    WHERE
        ntss_db5_mst_v.facility_cd = @facilityCd
        AND ntss_db5_mst_v.is_del = ''0''
        AND ntss_db5_mst_v.is_disp = ''1''
)
, ntss_db5_mst_d AS (
    SELECT
        ntss_db5_mst_d.dialyzer_cd
        , ntss_db5_mst_d.model_number
        , ntss_db5_mst_d.in_hospital_cd_1
        , ntss_db5_mst_d.in_hospital_cd_2
    FROM
        mst_dialyzer ntss_db5_mst_d
    WHERE
        ntss_db5_mst_d.facility_cd = @facilityCd
        AND ntss_db5_mst_d.is_del = ''0''
        AND ntss_db5_mst_d.is_disp = ''1''
)
, ntss_db5_mst_e AS (
    SELECT
        ntss_db5_mst_e.equipment_cd
        , ntss_db5_mst_e.equipment_name
        , ntss_db5_mst_e.unit
        , ntss_db5_mst_e.in_hospital_cd_1
        , ntss_db5_mst_e.in_hospital_cd_2
    FROM
        mst_equipment ntss_db5_mst_e
    WHERE
        ntss_db5_mst_e.facility_cd = @facilityCd
        AND ntss_db5_mst_e.is_del = ''0''
        AND ntss_db5_mst_e.is_disp = ''1''
)
, ntss_db5_mst_m AS (
    SELECT
        ntss_db5_mst_m.medicine_cd
        , ntss_db5_mst_m.medicine_name
        , ntss_db5_mst_m.unit
        , ntss_db5_mst_m.in_hospital_cd_1
        , ntss_db5_mst_m.in_hospital_cd_2
    FROM
        mst_medicine ntss_db5_mst_m
    WHERE
        ntss_db5_mst_m.facility_cd = @facilityCd
        AND ntss_db5_mst_m.is_del = ''0''
        AND ntss_db5_mst_m.is_disp = ''1''
)
, ntss_db5_mst_m_mix AS (
    SELECT
        ntss_db5_mst_m_mix.medicine_mix_cd
        , ntss_db5_mst_m_mix.medicine_mix_name
        , ntss_db5_mst_m_mix.unit
        , ntss_db5_mst_m_mix.in_hospital_cd_1
        , ntss_db5_mst_m_mix.in_hospital_cd_2
    FROM
        mst_medicine_mix ntss_db5_mst_m_mix
    WHERE
        ntss_db5_mst_m_mix.facility_cd = @facilityCd
        AND ntss_db5_mst_m_mix.is_del = ''0''
        AND ntss_db5_mst_m_mix.is_disp = ''1''
)
, ntss_db5_ptp AS (
    SELECT
    ntss_db5_ptp.pat_id
    , ntss_db5_ptp.treat_week
    , ntss_db5_ptp.ind_treatment_cd
    , ''1'' AS flg
    FROM pat_treatment_pattern ntss_db5_ptp
    WHERE ntss_db5_ptp.facility_cd = @facilityCd
)
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om_temp.pat_id AS patid
    , ntss_db5_om_temp.dialysisdate AS dialysisdate    --透析日
    , ntss_db5_om_1.plural AS plural            --同日複数回
    , CASE
        WHEN ind_cond_list.key = ''991'' THEN ''001''
        WHEN ind_cond_list.key = ''1'' THEN ''002''
        WHEN ind_cond_list.key = ''2'' THEN ''003''
        WHEN ind_cond_list.key = ''992'' THEN ''004''
        WHEN ind_cond_list.key = ''3'' THEN ''005''
        WHEN ind_cond_list.key = ''993'' THEN ''006''
        WHEN ind_cond_list.key = ''4'' THEN ''007''
        WHEN ind_cond_list.key = ''5'' THEN ''008''
        WHEN ind_cond_list.key = ''6'' THEN ''009''
        WHEN ind_cond_list.key = ''14'' THEN ''010''
        WHEN ind_cond_list.key = ''25'' THEN ''011''
        WHEN ind_cond_list.key = ''26'' THEN ''012''
        WHEN ind_cond_list.key = ''27'' THEN ''013''
        WHEN ind_cond_list.key = ''28'' THEN ''014''
        WHEN ind_cond_list.key = ''29'' THEN ''015''
        WHEN ind_cond_list.key = ''31'' THEN ''016''
        WHEN ind_cond_list.key = ''32'' THEN ''017''
        WHEN ind_cond_list.key = ''15'' THEN ''018''
        WHEN ind_cond_list.key = ''16'' THEN ''019''
        WHEN ind_cond_list.key = ''17'' THEN ''020''
        WHEN ind_cond_list.key = ''18'' THEN ''021''
        WHEN ind_cond_list.key = ''19'' THEN ''022''
        WHEN ind_cond_list.key = ''20'' THEN ''023''
        WHEN ind_cond_list.key = ''21'' THEN ''024''
        WHEN ind_cond_list.key = ''23'' THEN ''025''
        WHEN ind_cond_list.key = ''12'' THEN ''029''
        WHEN ind_cond_list.key = ''22'' THEN ''030''
        WHEN ind_cond_list.key = ''30'' THEN ''031''
        WHEN ind_cond_list.key = ''34'' THEN ''032''
        WHEN ind_cond_list.key = ''35'' THEN ''033''
        WHEN ind_cond_list.key = ''36'' THEN ''034''
        WHEN ind_cond_list.key = ''37'' THEN ''035''
        WHEN ind_cond_list.key = ''38'' THEN ''036''
        WHEN ind_cond_list.key = ''33'' THEN ''037''
        WHEN ind_cond_list.key = ''24'' THEN ''038''
        WHEN ind_cond_list.key = ''7'' THEN ''039''
        WHEN ind_cond_list.key = ''8'' THEN ''040''
        ELSE NULL
        END AS ctlno       --透析条件項目コード
    , CASE
        WHEN ind_cond_list.key = ''992'' THEN ind_cond_list.up_date
        ELSE to_char(ntss_db5_om_temp.up_date, ''YYYY-MM-DD hh24:mi:ss'')
        END AS update --更新日時+
    , CASE
        WHEN ind_cond_list.key = ''991'' THEN ''透析開始時刻''
        WHEN ind_cond_list.key = ''1'' THEN ''透析時間''
        WHEN ind_cond_list.key = ''2'' THEN ''VA''
        WHEN ind_cond_list.key = ''992'' THEN ''DW''
        WHEN ind_cond_list.key = ''3'' THEN ''目標体重''
        WHEN ind_cond_list.key = ''993'' THEN ''治療方法''
        WHEN ind_cond_list.key = ''4'' THEN ''除水量制限''
        WHEN ind_cond_list.key = ''5'' THEN ''ダイアライザ''
        WHEN ind_cond_list.key = ''6'' THEN ''吸着カラム''
        WHEN ind_cond_list.key = ''14'' THEN ''血流量''
        WHEN ind_cond_list.key = ''25'' THEN ''抗凝固剤''
        WHEN ind_cond_list.key = ''26'' THEN ''抗凝固剤ワンショット量''
        WHEN ind_cond_list.key = ''27'' THEN ''抗凝固剤持続速度''
        WHEN ind_cond_list.key = ''28'' THEN ''抗凝固剤持続総量''
        WHEN ind_cond_list.key = ''29'' THEN ''IP使用選択''
        WHEN ind_cond_list.key = ''31'' THEN ''IPワンショット量''
        WHEN ind_cond_list.key = ''32'' THEN ''IP速度''
        WHEN ind_cond_list.key = ''15'' THEN ''透析液''
        WHEN ind_cond_list.key = ''16'' THEN ''透析液流量''
        WHEN ind_cond_list.key = ''17'' THEN ''透析液量''
        WHEN ind_cond_list.key = ''18'' THEN ''透析液温度''
        WHEN ind_cond_list.key = ''19'' THEN ''補液''
        WHEN ind_cond_list.key = ''20'' THEN ''補液量''
        WHEN ind_cond_list.key = ''21'' THEN ''補液選択''
        WHEN ind_cond_list.key = ''23'' THEN ''補液温度''
        WHEN ind_cond_list.key = ''12'' THEN ''シングルニードル使用''
        WHEN ind_cond_list.key = ''22'' THEN ''補液使用数''
        WHEN ind_cond_list.key = ''30'' THEN ''IPスタート''
        WHEN ind_cond_list.key = ''34'' THEN ''自動ワンショット''
        WHEN ind_cond_list.key = ''35'' THEN ''IP電源自動切り''
        WHEN ind_cond_list.key = ''36'' THEN ''IP電源自動切り時間''
        WHEN ind_cond_list.key = ''37'' THEN ''IP電源OKモニタ切り''
        WHEN ind_cond_list.key = ''38'' THEN ''IP電源OKモニタ切り時間''
        WHEN ind_cond_list.key = ''33'' THEN ''IP速度最大値''
        WHEN ind_cond_list.key = ''24'' THEN ''補液速度''
        WHEN ind_cond_list.key = ''7'' THEN ''1次膜''
        WHEN ind_cond_list.key = ''8'' THEN ''2次膜''
        ELSE NULL
        END AS dialysisitemname --透析条件項目名
    , CASE
        WHEN ind_cond_list.key = ''991'' THEN
            CASE
                WHEN ind_cond_list.value = null THEN ''未登録''
                ELSE to_char(to_timestamp(ind_cond_list.value, ''hh24MI''), ''hh24:mi'')
                END
        WHEN ind_cond_list.key = ''2'' THEN ntss_db5_mst_v.in_hospital_cd_1
        WHEN ind_cond_list.key = ''992'' THEN to_char(ind_cond_list.value::numeric, ''FM990.00'')
        WHEN ind_cond_list.key = ''3'' THEN to_char(ind_cond_list.value::numeric, ''FM990.00'')
        WHEN ind_cond_list.key = ''4'' THEN to_char(ind_cond_list.value::numeric, ''FM90.00'')
        WHEN ind_cond_list.key = ''5'' THEN ntss_db5_mst_d.in_hospital_cd_1
        WHEN ind_cond_list.key = ''6''
        OR ind_cond_list.key = ''7''
        OR ind_cond_list.key = ''8''
            THEN ntss_db5_mst_e.in_hospital_cd_1
        WHEN ind_cond_list.key = ''25''
        OR ind_cond_list.key = ''15''
        OR ind_cond_list.key = ''19''
            THEN CASE
                WHEN ind_cond_list.medicine_type = ''1'' THEN ntss_db5_mst_m.in_hospital_cd_1
                WHEN ind_cond_list.medicine_type = ''2'' THEN ntss_db5_mst_m_mix.in_hospital_cd_1
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''26'' THEN to_char(ind_cond_list.value::numeric, ''FM99990.00'')
        WHEN ind_cond_list.key = ''27'' THEN to_char(ind_cond_list.value::numeric, ''FM99990.00'')
        WHEN ind_cond_list.key = ''28'' THEN to_char(ind_cond_list.value::numeric, ''FM99990.00'')
        WHEN ind_cond_list.key = ''31'' THEN to_char(ind_cond_list.value::numeric, ''FM90.0'')
        WHEN ind_cond_list.key = ''32'' THEN to_char(ind_cond_list.value::numeric, ''FM90.0'')
        WHEN ind_cond_list.key = ''17'' THEN to_char(ind_cond_list.value::numeric, ''FM99990.00'')
        WHEN ind_cond_list.key = ''18'' THEN to_char(ind_cond_list.value::numeric, ''FM90.0'')
        WHEN ind_cond_list.key = ''20'' THEN to_char(ind_cond_list.value::numeric, ''FM990.0'')
        WHEN ind_cond_list.key = ''23'' THEN to_char(ind_cond_list.value::numeric, ''FM90.0'')
        WHEN ind_cond_list.key = ''33'' THEN to_char(ind_cond_list.value::numeric, ''FM90.0'')
        WHEN ind_cond_list.key = ''24'' THEN to_char(ind_cond_list.value::numeric, ''FM990.00'')
        ELSE ind_cond_list.value
        END AS value          --設定値
    , CASE
        WHEN ind_cond_list.key = ''2'' THEN ntss_db5_mst_v.va_name
        WHEN ind_cond_list.key = ''5'' THEN ntss_db5_mst_d.model_number
        WHEN ind_cond_list.key = ''6''
        OR ind_cond_list.key = ''7''
        OR ind_cond_list.key = ''8''
            THEN ntss_db5_mst_e.equipment_name
        WHEN ind_cond_list.key = ''25''
        OR ind_cond_list.key = ''15''
        OR ind_cond_list.key = ''19''
            THEN CASE
                WHEN ind_cond_list.medicine_type = ''1'' THEN ntss_db5_mst_m.medicine_name
                WHEN ind_cond_list.medicine_type = ''2'' THEN ntss_db5_mst_m_mix.medicine_mix_name
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''29''
        OR ind_cond_list.key = ''12''
        OR ind_cond_list.key = ''34''
            THEN CASE
                WHEN ind_cond_list.value = ''1'' THEN ''使用する''
                WHEN ind_cond_list.value = ''0'' THEN ''使用しない''
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''21''
            THEN CASE
                WHEN ind_cond_list.value = ''1'' THEN ''前補液''
                WHEN ind_cond_list.value = ''0'' THEN ''後補液''
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''30''
            THEN CASE
                WHEN ind_cond_list.value = ''1'' THEN ''自動''
                WHEN ind_cond_list.value = ''0'' THEN ''手動''
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''35''
        OR ind_cond_list.key = ''37''
            THEN CASE
                WHEN ind_cond_list.value = ''1'' THEN ''入り''
                WHEN ind_cond_list.value = ''0'' THEN ''切り''
                ELSE NULL
                END
        ELSE ind_cond_list.value_name_1
        END AS valuename --名称
    , CASE
        WHEN ind_cond_list.key = ''1'' THEN ''分''
        WHEN ind_cond_list.key = ''3'' THEN ''kg''
        WHEN ind_cond_list.key = ''4'' THEN ''L''
        WHEN ind_cond_list.key = ''6''
        OR ind_cond_list.key = ''7''
        OR ind_cond_list.key = ''8''
            THEN ntss_db5_mst_e.unit
        WHEN ind_cond_list.key = ''14'' THEN ''mL/min''
        WHEN ind_cond_list.key = ''25''
        OR ind_cond_list.key = ''15''
        OR ind_cond_list.key = ''19''
            THEN CASE
                WHEN ind_cond_list.medicine_type = ''1'' THEN ntss_db5_mst_m.unit
                WHEN ind_cond_list.medicine_type = ''2'' THEN ntss_db5_mst_m_mix.unit
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''26''
            THEN CASE
                WHEN LAG(ind_cond_list.medicine_type, 1) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int) = ''1''
                    THEN LAG(ntss_db5_mst_m.unit, 1) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int)
                WHEN LAG(ind_cond_list.medicine_type, 1) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int) = ''2''
                    THEN LAG(ntss_db5_mst_m_mix.unit, 1) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int)
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''27''
            THEN CASE
                WHEN LAG(ind_cond_list.medicine_type, 2) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int) = ''1''
                    THEN CONCAT(LAG(ntss_db5_mst_m.unit, 2) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int), ''/h'')
                WHEN LAG(ind_cond_list.medicine_type, 2) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int) = ''2''
                    THEN CONCAT(LAG(ntss_db5_mst_m_mix.unit, 2) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int), ''/h'')
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''28''
            THEN CASE
                WHEN LAG(ind_cond_list.medicine_type, 3) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int) = ''1''
                    THEN LAG(ntss_db5_mst_m.unit, 3) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int)
                WHEN LAG(ind_cond_list.medicine_type, 3) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int) = ''2''
                    THEN LAG(ntss_db5_mst_m_mix.unit, 3) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int)
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''31'' THEN ''mL''
        WHEN ind_cond_list.key = ''32'' THEN ''mL/h''
        WHEN ind_cond_list.key = ''16'' THEN ''mL/min''
        WHEN ind_cond_list.key = ''17''
            THEN CASE
                WHEN LAG(ind_cond_list.medicine_type, 2) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int) = ''1''
                    THEN LAG(ntss_db5_mst_m.unit, 2) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int)
                WHEN LAG(ind_cond_list.medicine_type, 2) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int) = ''2''
                    THEN LAG(ntss_db5_mst_m_mix.unit, 2) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int)
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''18'' THEN ''℃''
        WHEN ind_cond_list.key = ''20'' THEN ''L''
        WHEN ind_cond_list.key = ''23'' THEN ''℃''
        WHEN ind_cond_list.key = ''22''
            THEN CASE
                WHEN LAG(ind_cond_list.medicine_type, 3) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int) = ''1''
                    THEN LAG(ntss_db5_mst_m.unit, 3) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int)
                WHEN LAG(ind_cond_list.medicine_type, 3) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int) = ''2''
                    THEN LAG(ntss_db5_mst_m_mix.unit, 3) OVER (PARTITION BY ntss_db5_om_temp.pat_id, ntss_db5_om_temp.treat_date, ntss_db5_om_1.plural ORDER BY ind_cond_list.key ::int)
                ELSE NULL
                END
        WHEN ind_cond_list.key = ''36'' THEN ''分''
        WHEN ind_cond_list.key = ''38'' THEN ''分''
        WHEN ind_cond_list.key = ''33'' THEN ''mL/h''
        WHEN ind_cond_list.key = ''24'' THEN ''L/h''
        ELSE ind_cond_list.unit
        END AS unit            --単位
    , CASE
        WHEN ind_cond_list.key = ''2'' THEN ntss_db5_mst_v.in_hospital_cd_2
        WHEN ind_cond_list.key = ''993'' THEN ind_cond_list.valuecd2
        WHEN ind_cond_list.key = ''5'' THEN ntss_db5_mst_d.in_hospital_cd_2
        WHEN ind_cond_list.key = ''6''
        OR ind_cond_list.key = ''7''
        OR ind_cond_list.key = ''8''
            THEN ntss_db5_mst_e.in_hospital_cd_2
        WHEN ind_cond_list.key = ''25''
        OR ind_cond_list.key = ''15''
        OR ind_cond_list.key = ''19''
            THEN CASE
                WHEN ind_cond_list.medicine_type = ''1'' THEN ntss_db5_mst_m.in_hospital_cd_2
                WHEN ind_cond_list.medicine_type = ''2'' THEN ntss_db5_mst_m_mix.in_hospital_cd_2
                ELSE NULL
                END
        ELSE NULL
        END AS valuecd2 --院内コード2
    , '''' AS indicatorcd                         --指示者
    , ind_cond_list.ind_user_id AS userid
    , CASE
        WHEN ntss_db5_ptp.flg = ''1''
            THEN ''0''
        ELSE ''1''
        END AS opeindplan                       --予定作成区分
    , ntss_db5_om_temp.ord_no AS dialysisno --透析番号
FROM
    ind_cond_list
    JOIN ntss_db5_om_temp
        ON ntss_db5_om_temp.ord_no = ind_cond_list.ord_no
    LEFT JOIN ntss_db5_om_1
        ON ntss_db5_om_temp.ord_no = ntss_db5_om_1.ord_no
    LEFT JOIN ntss_db5_mst_v
        ON ind_cond_list.value = (ntss_db5_mst_v.va_cd)::text
    LEFT JOIN ntss_db5_mst_d
        ON ind_cond_list.value = (ntss_db5_mst_d.dialyzer_cd)::text
    LEFT JOIN ntss_db5_mst_e
        ON ind_cond_list.value = (ntss_db5_mst_e.equipment_cd)::text
    LEFT JOIN ntss_db5_mst_m
        ON ind_cond_list.value = (ntss_db5_mst_m.medicine_cd)::text
    LEFT JOIN ntss_db5_mst_m_mix
        ON ind_cond_list.value = (ntss_db5_mst_m_mix.medicine_mix_cd)::text
    LEFT JOIN ntss_db5_ptp
        ON ntss_db5_ptp.pat_id = ntss_db5_om_temp.pat_id
        AND ntss_db5_ptp.treat_week = ntss_db5_om_temp.treat_week
        AND ntss_db5_ptp.ind_treatment_cd = ntss_db5_om_temp.ind_treatment_cd;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2170, '-- 【SQL_CD=-2170】
with mst_treatment_disp_order_tbl AS (
    SELECT
        one_json ->> ''code'' AS treatment_cd
        , json_idx AS treatment_cd_order
    FROM
        mst_selector
        CROSS JOIN lateral jsonb_array_elements(order_settings -> ''items'') with ordinality AS tmp(one_json, json_idx)
    WHERE
        facility_cd = @facilityCd
        AND master_physical_name = ''mst_treatment''
        AND one_json ->> ''isDel'' = ''0''
        AND one_json ->> ''isDisp'' = ''1''
),
ntss_db5_om_1 as (
    SELECT
        om.ord_no
        , row_number() over (PARTITION BY om.pat_id, om.treat_date ORDER BY om.ind_treat_start_time ASC, m.treatment_cd_order ASC) AS plural
    FROM
        ord_main om
    LEFT JOIN mst_treatment_disp_order_tbl m
        ON om.ind_treatment_cd ::text = m.treatment_cd
    WHERE
        om.facility_cd = @facilityCd
        AND om.is_del = ''0''
        and @fromDate <= om.treat_date
        and om.treat_date < @toDate
),
ntss_db5_os AS (
    SELECT
        ntss_db5_os.ord_no
        , ntss_db5_os.is_dummy
        , ntss_db5_os.up_date
    FROM
        ord_schedule ntss_db5_os
    WHERE ntss_db5_os.facility_cd = @facilityCd
),
ntss_db5_mst_b AS (
    SELECT
        ntss_db5_mst_b.bed_cd
        , ntss_db5_mst_b.in_hospital_cd_1
        , ntss_db5_mst_b.bed_name
        , ntss_db5_mst_b.up_date
    FROM
        mst_bed ntss_db5_mst_b
    WHERE ntss_db5_mst_b.facility_cd = @facilityCd
    AND ntss_db5_mst_b.is_del = ''0''
    AND ntss_db5_mst_b.is_disp = ''1''
),
ntss_db5_mst_k AS (
    SELECT
        ntss_db5_mst_k.kur_cd
        , ntss_db5_mst_k.in_hospital_cd_1
        , ntss_db5_mst_k.kur_name
        , ntss_db5_mst_k.kur_standard_start_time
        , ntss_db5_mst_k.up_date
    FROM
        mst_kur ntss_db5_mst_k
    WHERE ntss_db5_mst_k.facility_cd = @facilityCd
    AND ntss_db5_mst_k.is_del = ''0''
),
ntss_db5_ptp AS (
    SELECT
    ntss_db5_ptp.pat_id
    , ntss_db5_ptp.treat_week
    , ntss_db5_ptp.ind_treatment_cd
    , ''1'' AS flg
    FROM pat_treatment_pattern ntss_db5_ptp
    WHERE ntss_db5_ptp.facility_cd = @facilityCd
)
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , ntss_db5_om.treat_date AS dialysisdate    --透析日
    , ntss_db5_mst_b.in_hospital_cd_1 AS bedno --ベッド番号
    , CASE
        WHEN ntss_db5_om.rst_dialysis_state = ''0''
            THEN ntss_db5_mst_b.bed_name
        ELSE ntss_db5_om.ind_bed_name
        END AS bedname                          --ベッド名
    , CASE
        WHEN ntss_db5_om.ind_kur_cd = 0 OR ntss_db5_om.ind_kur_cd IS NULL
            THEN ''未登録''
        ELSE ntss_db5_mst_k.in_hospital_cd_1
        END AS kurcd --クールコード
    , CASE
        WHEN ntss_db5_om.rst_dialysis_state = ''0''
            THEN ntss_db5_mst_k.kur_name
        ELSE ntss_db5_om.ind_kur_name
        END AS kurname                          --クール名
    , ntss_db5_om_1.plural AS plural            --同日複数回
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , ntss_db5_om.ord_no AS resultdialysisno    --実績透析番号
    , CASE
        WHEN ntss_db5_ptp.flg = ''1''
            THEN ''0''
        ELSE ''1''
        END AS opeindplan                       --予定作成区分
    , ntss_db5_os.is_dummy AS dummyflg          --ダミーフラグ
    , CASE
        WHEN ntss_db5_om.rst_start_date IS NULL
            THEN CASE
                WHEN ntss_db5_om.ind_kur_cd = 0
                    THEN ''未登録''
                ELSE to_char(to_timestamp(ntss_db5_mst_k.kur_standard_start_time, ''hh24miss''), ''hh24:mi'')
                END
        ELSE to_char(ntss_db5_om.rst_start_date, ''hh24:mi'')
        END AS starttime --透析開始時刻
FROM
    ord_main ntss_db5_om
    LEFT JOIN ntss_db5_om_1
        ON ntss_db5_om.ord_no = ntss_db5_om_1.ord_no
    LEFT JOIN ntss_db5_os
        ON ntss_db5_os.ord_no = ntss_db5_om.ord_no
    LEFT JOIN ntss_db5_mst_b
        ON ntss_db5_mst_b.bed_cd = ntss_db5_om.ind_bed_cd
    LEFT JOIN ntss_db5_mst_k
        ON ntss_db5_mst_k.kur_cd = ntss_db5_om.ind_kur_cd
    LEFT JOIN ntss_db5_ptp
        ON ntss_db5_ptp.pat_id = ntss_db5_om.pat_id
        AND ntss_db5_ptp.treat_week = ntss_db5_om.treat_week
        AND ntss_db5_ptp.ind_treatment_cd = ntss_db5_om.ind_treatment_cd
WHERE
    ntss_db5_om.facility_cd = @facilityCd
    AND ntss_db5_om.is_del = ''0''
    AND @fromDate <= ntss_db5_om.treat_date AND ntss_db5_om.treat_date < @toDate
    order by patid asc,
    resultdialysisno asc
    ;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2100, '-- 【SQL_CD=-2100】
WITH
 om AS NOT MATERIALIZED (
    SELECT
        om.ord_no
        ,om.pat_id
        ,om.treat_date AS dialysisdate
        ,CAST(om.treat_date as DATE) AS treat_date
        ,om.rst_cond_info
        ,om.rst_treatment_cd
        ,om.up_date
        ,om.rst_dw
    FROM
        ord_main om
    WHERE
        om.facility_cd = @facilityCd
        AND om.is_del = ''0''
        AND @fromDate <= om.treat_date AND om.treat_date < @toDate
)
, m_t AS (
    SELECT
        m_t.treatment_cd
        , m_t.treatment_name
        , CAST(m_t.in_hosp_a_startdate AS date) AS in_hosp_a_startdate
        , m_t.in_hospital_cd_a1
        , m_t.in_hospital_cd_a2
        , CAST(m_t.in_hosp_b_startdate AS date) AS in_hosp_b_startdate
        , m_t.in_hospital_cd_b1
        , m_t.in_hospital_cd_b2
    FROM
        mst_treatment m_t
    WHERE
        m_t.facility_cd = @facilityCd
        AND m_t.is_del = ''0''
        AND m_t.is_disp = ''1''
)
, rst_cond_list AS (
    SELECT --rst_cond_info
        om.ord_no
        , rst_cond_info_json.key AS key
        , rst_cond_info_json.value::JSONB ->> ''value'' AS value
        , rst_cond_info_json.value::JSONB ->> ''value_name_1'' AS value_name_1
        , rst_cond_info_json.value::JSONB ->> ''unit'' AS unit
        , '''' AS valuecd2
        , rst_cond_info_json.value::JSONB ->> ''medicine_type'' AS medicine_type
    FROM
        om
        CROSS JOIN lateral jsonb_each_text(om.rst_cond_info) rst_cond_info_json
    WHERE
        rst_cond_info_json.key IN(''1'',''2'',''3'',''4'',''5'',''6'',''7'',''8'',''12'',''14'',''15'',''16'',''17'',''18'',''19'',''20'',''21'',''22'',''23'',''24'',''25'',''26'',''27'',''28'',''29'',''30'',''31'',''32'',''33'',''34'',''35'',''36'',''37'',''38'')
    UNION ALL
    SELECT --dw
        om.ord_no
        , ''992'' AS key
        , CAST(om.rst_dw AS text) AS value
        , '''' AS value_name_1
        , ''kg'' AS unit
        , '''' AS valuecd2
        , '''' AS medicine_type
    FROM
        om
    UNION ALL
    SELECT --治療方法
        om.ord_no
        , ''993'' AS key
        , CASE
            WHEN om.treat_date >= m_t.in_hosp_a_startdate
            AND om.treat_date >= m_t.in_hosp_b_startdate
                THEN CASE
                    WHEN m_t.in_hosp_a_startdate >= m_t.in_hosp_b_startdate
                        THEN m_t.in_hospital_cd_a1
                    WHEN m_t.in_hosp_a_startdate < m_t.in_hosp_b_startdate
                        THEN m_t.in_hospital_cd_b1
                    END
            WHEN om.treat_date >= m_t.in_hosp_a_startdate
            AND (om.treat_date < m_t.in_hosp_b_startdate
                OR m_t.in_hosp_b_startdate IS NULL)
                THEN m_t.in_hospital_cd_a1
            WHEN (om.treat_date < m_t.in_hosp_a_startdate
                OR m_t.in_hosp_a_startdate IS NULL)
            AND om.treat_date >= m_t.in_hosp_b_startdate
                THEN m_t.in_hospital_cd_b1
            ELSE NULL
            END AS value
        , m_t.treatment_name AS value_name_1
        , '''' AS unit
        , CASE
            WHEN om.treat_date >= m_t.in_hosp_a_startdate
            AND om.treat_date >= m_t.in_hosp_b_startdate
                THEN CASE
                    WHEN m_t.in_hosp_a_startdate >= m_t.in_hosp_b_startdate
                        THEN m_t.in_hospital_cd_a2
                    WHEN m_t.in_hosp_a_startdate < m_t.in_hosp_b_startdate
                        THEN m_t.in_hospital_cd_b2
                    END
            WHEN om.treat_date >= m_t.in_hosp_a_startdate
            AND (om.treat_date < m_t.in_hosp_b_startdate
                OR m_t.in_hosp_b_startdate IS NULL)
                THEN m_t.in_hospital_cd_a2
            WHEN (om.treat_date < m_t.in_hosp_a_startdate
                OR m_t.in_hosp_a_startdate IS NULL)
            AND om.treat_date >= m_t.in_hosp_b_startdate
                THEN m_t.in_hospital_cd_b2
            ELSE NULL
            END AS valuecd2
        , '''' AS medicine_type
    FROM
        om
        LEFT JOIN m_t
        ON om.rst_treatment_cd = m_t.treatment_cd
)
, m_va AS (
    SELECT
        m_va.va_cd
        , m_va.in_hospital_cd_1
        , m_va.in_hospital_cd_2
    FROM
        mst_va m_va
    WHERE
        m_va.facility_cd = @facilityCd
        AND m_va.is_del = ''0''
        AND m_va.is_disp = ''1''
)
, m_d AS (
    SELECT
        m_d.dialyzer_cd
        , m_d.in_hospital_cd_1
        , m_d.in_hospital_cd_2
    FROM
        mst_dialyzer m_d
    WHERE
        m_d.facility_cd = @facilityCd
        AND m_d.is_del = ''0''
        AND m_d.is_disp = ''1''
)
, m_e AS (
    SELECT
        m_e.equipment_cd
        , m_e.in_hospital_cd_1
        , m_e.in_hospital_cd_2
    FROM
        mst_equipment m_e
    WHERE
        m_e.facility_cd = @facilityCd
        AND m_e.is_del = ''0''
        AND m_e.is_disp = ''1''
)
, m_m AS (
    SELECT
        m_m.medicine_cd
        , m_m.in_hospital_cd_1
        , m_m.in_hospital_cd_2
    FROM
        mst_medicine m_m
    WHERE
        m_m.facility_cd = @facilityCd
        AND m_m.is_del = ''0''
        AND m_m.is_disp = ''1''
)
, m_m_mix AS (
    SELECT
        m_m_mix.medicine_mix_cd
        , m_m_mix.in_hospital_cd_1
        , m_m_mix.in_hospital_cd_2
    FROM
        mst_medicine_mix m_m_mix
    WHERE
        m_m_mix.facility_cd = @facilityCd
        AND m_m_mix.is_del = ''0''
        AND m_m_mix.is_disp = ''1''
)
SELECT
    '''' AS hosppatid                             --患者ID
    , om.pat_id AS patid
    , om.dialysisdate AS dialysisdate    --透析日
    , om.ord_no AS dialysisno            --透析番号
    , CASE
        WHEN rst_cond_list.key = ''1'' THEN ''002''
        WHEN rst_cond_list.key = ''2'' THEN ''003''
        WHEN rst_cond_list.key = ''992'' THEN ''004''
        WHEN rst_cond_list.key = ''3'' THEN ''005''
        WHEN rst_cond_list.key = ''993'' THEN ''006''
        WHEN rst_cond_list.key = ''4'' THEN ''007''
        WHEN rst_cond_list.key = ''5'' THEN ''008''
        WHEN rst_cond_list.key = ''6'' THEN ''009''
        WHEN rst_cond_list.key = ''14'' THEN ''010''
        WHEN rst_cond_list.key = ''25'' THEN ''011''
        WHEN rst_cond_list.key = ''26'' THEN ''012''
        WHEN rst_cond_list.key = ''27'' THEN ''013''
        WHEN rst_cond_list.key = ''28'' THEN ''014''
        WHEN rst_cond_list.key = ''29'' THEN ''015''
        WHEN rst_cond_list.key = ''31'' THEN ''016''
        WHEN rst_cond_list.key = ''32'' THEN ''017''
        WHEN rst_cond_list.key = ''15'' THEN ''018''
        WHEN rst_cond_list.key = ''16'' THEN ''019''
        WHEN rst_cond_list.key = ''17'' THEN ''020''
        WHEN rst_cond_list.key = ''18'' THEN ''021''
        WHEN rst_cond_list.key = ''19'' THEN ''022''
        WHEN rst_cond_list.key = ''20'' THEN ''023''
        WHEN rst_cond_list.key = ''21'' THEN ''024''
        WHEN rst_cond_list.key = ''23'' THEN ''025''
        WHEN rst_cond_list.key = ''12'' THEN ''029''
        WHEN rst_cond_list.key = ''22'' THEN ''030''
        WHEN rst_cond_list.key = ''30'' THEN ''031''
        WHEN rst_cond_list.key = ''34'' THEN ''032''
        WHEN rst_cond_list.key = ''35'' THEN ''033''
        WHEN rst_cond_list.key = ''36'' THEN ''034''
        WHEN rst_cond_list.key = ''37'' THEN ''035''
        WHEN rst_cond_list.key = ''38'' THEN ''036''
        WHEN rst_cond_list.key = ''33'' THEN ''037''
        WHEN rst_cond_list.key = ''24'' THEN ''038''
        WHEN rst_cond_list.key = ''7'' THEN ''039''
        WHEN rst_cond_list.key = ''8'' THEN ''040''
        ELSE NULL
        END AS ctlno       --透析条件項目コード
    , to_char(om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS update --更新日時
    , CASE
        WHEN rst_cond_list.key = ''1'' THEN ''透析時間''
        WHEN rst_cond_list.key = ''2'' THEN ''VA''
        WHEN rst_cond_list.key = ''992'' THEN ''DW''
        WHEN rst_cond_list.key = ''3'' THEN ''目標体重''
        WHEN rst_cond_list.key = ''993'' THEN ''治療方法''
        WHEN rst_cond_list.key = ''4'' THEN ''除水量制限''
        WHEN rst_cond_list.key = ''5'' THEN ''ダイアライザ''
        WHEN rst_cond_list.key = ''6'' THEN ''吸着カラム''
        WHEN rst_cond_list.key = ''14'' THEN ''血流量''
        WHEN rst_cond_list.key = ''25'' THEN ''抗凝固剤''
        WHEN rst_cond_list.key = ''26'' THEN ''抗凝固剤ワンショット量''
        WHEN rst_cond_list.key = ''27'' THEN ''抗凝固剤持続速度''
        WHEN rst_cond_list.key = ''28'' THEN ''抗凝固剤持続総量''
        WHEN rst_cond_list.key = ''29'' THEN ''IP使用選択''
        WHEN rst_cond_list.key = ''31'' THEN ''IPワンショット量''
        WHEN rst_cond_list.key = ''32'' THEN ''IP速度''
        WHEN rst_cond_list.key = ''15'' THEN ''透析液''
        WHEN rst_cond_list.key = ''16'' THEN ''透析液流量''
        WHEN rst_cond_list.key = ''17'' THEN ''透析液量''
        WHEN rst_cond_list.key = ''18'' THEN ''透析液温度''
        WHEN rst_cond_list.key = ''19'' THEN ''補液''
        WHEN rst_cond_list.key = ''20'' THEN ''補液量''
        WHEN rst_cond_list.key = ''21'' THEN ''補液選択''
        WHEN rst_cond_list.key = ''23'' THEN ''補液温度''
        WHEN rst_cond_list.key = ''12'' THEN ''シングルニードル使用''
        WHEN rst_cond_list.key = ''22'' THEN ''補液使用数''
        WHEN rst_cond_list.key = ''30'' THEN ''IPスタート''
        WHEN rst_cond_list.key = ''34'' THEN ''自動ワンショット''
        WHEN rst_cond_list.key = ''35'' THEN ''IP電源自動切り''
        WHEN rst_cond_list.key = ''36'' THEN ''IP電源自動切り時間''
        WHEN rst_cond_list.key = ''37'' THEN ''IP電源OKモニタ切り''
        WHEN rst_cond_list.key = ''38'' THEN ''IP電源OKモニタ切り時間''
        WHEN rst_cond_list.key = ''33'' THEN ''IP速度最大値''
        WHEN rst_cond_list.key = ''24'' THEN ''補液速度''
        WHEN rst_cond_list.key = ''7'' THEN ''1次膜''
        WHEN rst_cond_list.key = ''8'' THEN ''2次膜''
        ELSE NULL
        END AS dialysisitemname --透析条件項目名
    , CASE
        WHEN rst_cond_list.key = ''2'' THEN m_va.in_hospital_cd_1
        WHEN rst_cond_list.key = ''992'' THEN to_char(rst_cond_list.value::numeric, ''FM990.00'')
        WHEN rst_cond_list.key = ''3'' THEN to_char(rst_cond_list.value::numeric, ''FM990.00'')
        WHEN rst_cond_list.key = ''4'' THEN to_char(rst_cond_list.value::numeric, ''FM90.00'')
        WHEN rst_cond_list.key = ''5'' THEN m_d.in_hospital_cd_1
        WHEN rst_cond_list.key = ''6''
        OR rst_cond_list.key = ''7''
        OR rst_cond_list.key = ''8''
            THEN m_e.in_hospital_cd_1
        WHEN rst_cond_list.key = ''25''
        OR rst_cond_list.key = ''15''
        OR rst_cond_list.key = ''19''
            THEN CASE
                WHEN rst_cond_list.medicine_type = ''1'' THEN m_m.in_hospital_cd_1
                WHEN rst_cond_list.medicine_type = ''2'' THEN m_m_mix.in_hospital_cd_1
                ELSE NULL
                END
        WHEN rst_cond_list.key = ''26'' THEN to_char(rst_cond_list.value::numeric, ''FM99990.00'')
        WHEN rst_cond_list.key = ''27'' THEN to_char(rst_cond_list.value::numeric, ''FM99990.00'')
        WHEN rst_cond_list.key = ''28'' THEN to_char(rst_cond_list.value::numeric, ''FM99990.00'')
        WHEN rst_cond_list.key = ''31'' THEN to_char(rst_cond_list.value::numeric, ''FM90.0'')
        WHEN rst_cond_list.key = ''32'' THEN to_char(rst_cond_list.value::numeric, ''FM90.0'')
        WHEN rst_cond_list.key = ''17'' THEN to_char(rst_cond_list.value::numeric, ''FM99990.00'')
        WHEN rst_cond_list.key = ''18'' THEN to_char(rst_cond_list.value::numeric, ''FM90.0'')
        WHEN rst_cond_list.key = ''20'' THEN to_char(rst_cond_list.value::numeric, ''FM990.0'')
        WHEN rst_cond_list.key = ''23'' THEN to_char(rst_cond_list.value::numeric, ''FM90.0'')
        WHEN rst_cond_list.key = ''33'' THEN to_char(rst_cond_list.value::numeric, ''FM90.0'')
        WHEN rst_cond_list.key = ''24'' THEN to_char(rst_cond_list.value::numeric, ''FM990.00'')
        ELSE rst_cond_list.value
        END AS value          --設定値
    , CASE
        WHEN rst_cond_list.key = ''29''
        OR rst_cond_list.key = ''12''
        OR rst_cond_list.key = ''34''
            THEN CASE
                WHEN rst_cond_list.value = ''1'' THEN ''使用する''
                WHEN rst_cond_list.value = ''0'' THEN ''使用しない''
                ELSE NULL
                END
        WHEN rst_cond_list.key = ''21''
            THEN CASE
                WHEN rst_cond_list.value = ''1'' THEN ''前補液''
                WHEN rst_cond_list.value = ''0'' THEN ''後補液''
                ELSE NULL
                END
        WHEN rst_cond_list.key = ''30''
            THEN CASE
                WHEN rst_cond_list.value = ''1'' THEN ''自動''
                WHEN rst_cond_list.value = ''0'' THEN ''手動''
                ELSE NULL
                END
        WHEN rst_cond_list.key = ''35''
        OR rst_cond_list.key = ''37''
            THEN CASE
                WHEN rst_cond_list.value = ''1'' THEN ''入り''
                WHEN rst_cond_list.value = ''0'' THEN ''切り''
                ELSE NULL
                END
        ELSE rst_cond_list.value_name_1
        END AS valuename --名称
    , CASE
        WHEN rst_cond_list.key = ''1'' THEN ''分''
        WHEN rst_cond_list.key = ''3'' THEN ''kg''
        WHEN rst_cond_list.key = ''4'' THEN ''L''
        WHEN rst_cond_list.key = ''14'' THEN ''mL/min''
        WHEN rst_cond_list.key = ''31'' THEN ''mL''
        WHEN rst_cond_list.key = ''32'' THEN ''mL/h''
        WHEN rst_cond_list.key = ''16'' THEN ''mL/min''
        WHEN rst_cond_list.key = ''18'' THEN ''℃''
        WHEN rst_cond_list.key = ''20'' THEN ''L''
        WHEN rst_cond_list.key = ''23'' THEN ''℃''
        WHEN rst_cond_list.key = ''36'' THEN ''分''
        WHEN rst_cond_list.key = ''38'' THEN ''分''
        WHEN rst_cond_list.key = ''33'' THEN ''mL/h''
        WHEN rst_cond_list.key = ''24'' THEN ''L/h''
        ELSE rst_cond_list.unit
        END AS unit            --単位
    , CASE
        WHEN rst_cond_list.key = ''2'' THEN m_va.in_hospital_cd_2
        WHEN rst_cond_list.key = ''993'' THEN rst_cond_list.valuecd2
        WHEN rst_cond_list.key = ''5'' THEN m_d.in_hospital_cd_2
        WHEN rst_cond_list.key = ''6''
        OR rst_cond_list.key = ''7''
        OR rst_cond_list.key = ''8''
            THEN m_e.in_hospital_cd_2
        WHEN rst_cond_list.key = ''25''
        OR rst_cond_list.key = ''15''
        OR rst_cond_list.key = ''19''
            THEN CASE
                WHEN rst_cond_list.medicine_type = ''1'' THEN m_m.in_hospital_cd_2
                WHEN rst_cond_list.medicine_type = ''2'' THEN m_m_mix.in_hospital_cd_2
                ELSE NULL
                END
        ELSE NULL
        END AS valuecd2 --院内コード2
FROM
    om
    LEFT JOIN rst_cond_list
        ON om.ord_no = rst_cond_list.ord_no
    LEFT JOIN m_va
        ON rst_cond_list.value = m_va.va_cd ::text
    LEFT JOIN m_d
        ON rst_cond_list.value = m_d.dialyzer_cd ::text
    LEFT JOIN m_e
        ON rst_cond_list.value = m_e.equipment_cd ::text
    LEFT JOIN m_m
        ON rst_cond_list.value = m_m.medicine_cd ::text
    LEFT JOIN m_m_mix
        ON rst_cond_list.value = m_m_mix.medicine_mix_cd ::text;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2090, '-- 【SQL_CD=-2090】
with last_weight_pat as (
-- 対象期間に該当するpat_idを先に取得
    select distinct om.pat_id
    FROM ord_main om
    JOIN mst_treatment m_tr
    ON om.rst_treatment_cd = m_tr.treatment_cd
    AND m_tr.facility_cd = @facilityCd
    WHERE om.facility_cd = @facilityCd
    and om.treat_date >= @fromDate
    AND om.treat_date < @toDate
    AND om.is_del = ''0''
    AND om.rst_dialysis_state = ''6''
    AND m_tr.device_mode <> 9
    AND m_tr.is_del = ''0''
    AND m_tr.is_disp = ''1''
),
last_weight_table as (
-- last_weight_unionの表の絞り込みを行う
    select
        x.ord_no
        , x.last_weight
    from (
        select
            om.ord_no
            , om.treat_date
            , lead(om.rst_weight_info ->> ''weight_after'') over (
            partition by om.pat_id
            order by om.rst_start_date desc
        ) as last_weight
        from ord_main om
        join last_weight_pat lp
            on lp.pat_id = om.pat_id
        join mst_treatment m_tr
            on om.rst_treatment_cd = m_tr.treatment_cd
            and m_tr.facility_cd = @facilityCd
        where om.facility_cd = @facilityCd
            and om.treat_date < @toDate
            and om.is_del = ''0''
            and om.rst_dialysis_state = ''6''
            and m_tr.device_mode <> 9
            and m_tr.is_del = ''0''
            and m_tr.is_disp = ''1''
    ) x
    where @fromDate <= x.treat_date
),
re_loop_rate_table AS ( --再循環率
    SELECT
        om.ord_no AS ord_no
        , (om.recrcl_rt -> om.valid_no ->> ''rate'') as relooprate
    FROM (
        SELECT
            om.ord_no
            , om.rst_weight_info #>> ''{recrcl_rt, "valid_no"}'' AS valid_no
            , om.rst_weight_info #> ''{recrcl_rt}'' AS recrcl_rt
        FROM ord_main om
        WHERE om.facility_cd = @facilityCd
        AND om.rst_dialysis_state = ''6''
        AND @fromDate <= om.treat_date AND om.treat_date < @toDate
        AND om.is_del = ''0''
        AND om.rst_weight_info IS NOT NULL
        AND om.rst_weight_info #> ''{recrcl_rt}'' <> ''null''
    ) AS om
    WHERE om.valid_no is not null
        and jsonb_exists(om.recrcl_rt, om.valid_no)
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
    ,last_weight_table.last_weight AS lastweight --前回体重
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
    ,om.rst_weight_info #>> ''{add_total}'' AS addtotal --除水積算値
    ,om.rst_weight_info #>> ''{sttc_vns_prssr}'' AS staticvenouspressure --静的静脈圧
    ,om.rst_weight_info #>> ''{iap_rt}'' AS venousaccesspressureratio --IAP ratio
FROM
    ord_main om
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
    LEFT JOIN last_weight_table
    ON last_weight_table.ord_no = om.ord_no
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
    AND om.rst_dialysis_state = ''6''
    AND om.pat_id IS NOT NULL
    AND @fromDate <= om.treat_date AND om.treat_date < @toDate
order by patid, dialysisdate asc;', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-2050, '-- 【SQL_CD=-2050】
WITH base_pm AS (
    SELECT
        pm.pat_id,
        pm.infect_info
    FROM pat_main pm
    WHERE
        pm.is_del = ''0''
        AND pm.facility_cd = @facilityCd
        AND pm.infect_info IS NOT NULL
        AND pm.infect_info <> ''[]''::jsonb
)
SELECT
    '''' AS hosppatid,
    mi.in_hospital_cd_1 AS infectioncd,
    mi.infection_name AS infectionname,
    TO_CHAR(
        TO_TIMESTAMP(j.value ->> ''up_date'', ''YYYYMMDD''),
        ''YYYY-MM-DD HH24:MI:SS''
    ) AS update,
    CASE j.value ->> ''infect''
        WHEN ''1'' THEN ''0''
        WHEN ''2'' THEN ''1''
        ELSE ''-''
    END AS infect,
    pm.pat_id AS patid
FROM base_pm pm
CROSS JOIN LATERAL jsonb_array_elements(pm.infect_info) AS j(value)
INNER JOIN mst_infection mi
    ON mi.infection_cd = (j.value ->> ''infection_cd'')::integer
    AND mi.is_del = ''0''
    AND mi.is_disp = ''1''
    AND mi.in_hospital_cd_1 IS NOT NULL;
', 2, '[]'::jsonb, '1', '{"applications": [5]}'::jsonb, '{"classes": []}'::jsonb, '患者病歴情報　@facilityCd使用 {"Mergekey": ["patid"]}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
