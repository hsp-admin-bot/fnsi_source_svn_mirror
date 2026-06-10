-- V_SCH_DIALYSIS_PLAN_CARD
UPDATE sys_data_set
SET "sql" =
    'WITH ntss_db5_om_1 AS (
        SELECT
            main.ord_no,
            main.ind_kur_cd,
            main.up_date,
            main.treat_type,
            main.ind_treat_start_time,
            subMain.pat_id,
            subMain.treat_date,
            subMain.treat_date_count
        FROM
            ord_main main
            INNER JOIN (
        SELECT
            ARRAY_AGG ( ntss_db5_om_1.ord_no ) AS arr_ord_no,
            ntss_db5_om_1.pat_id,
            ntss_db5_om_1.treat_date AS treat_date,
            COUNT( ntss_db5_om_1.treat_date ) AS treat_date_count
        FROM
            ord_main ntss_db5_om_1
        WHERE
            ntss_db5_om_1.facility_cd = @facilityCd
            AND ntss_db5_om_1.up_date BETWEEN to_date ( @fromDate, ''YYYYMMDDHH24MISS'' )
            AND to_date ( @toDate, ''YYYYMMDDHH24MISS'' )
            AND ntss_db5_om_1.is_del = ''0''
            AND ntss_db5_om_1.pat_id IS NOT NULL
        GROUP BY
            ntss_db5_om_1.pat_id,
            ntss_db5_om_1.treat_date
            ) AS subMain ON main.ord_no = ANY ( subMain.arr_ord_no )
            ) SELECT
            '''' AS hosppatid,
            ntss_db5_om_1.pat_id AS patid --患者 ID,
            ntss_db5_os.treat_date AS dialysisdate --透析日,
            ntss_db5_os.ord_no AS bedno --ベッド番号,
            ntss_db5_om_mst_b.bed_name AS bedname --ベッド名,
            ntss_db5_om_mst_k.kur_cd AS kurcd --クールコード,
            ntss_db5_om_mst_k.kur_name AS kurname --クール名,
        CASE

            WHEN ntss_db5_om_1.treat_date_count > 1 THEN
            1 ELSE 0
            END AS plural --同日複数回,
            to_char ( ntss_db5_om_1.up_date, ''YYYY-MM-DD hh24:mi:ss'' ) AS updates --更新日時,
            ntss_db5_om_1.ord_no AS resultdialysisno --実績透析番号,
        CASE

                WHEN ntss_db5_om_1.treat_type = 0 THEN
                1 ELSE 0
            END AS opeindplan --予定作成区分,
            ntss_db5_os.is_dummy AS dummyflg --ダミーフラグ,
            ntss_db5_om_1.ind_treat_start_time,
            ntss_db5_om_mst_k.kur_start_time,
        CASE

                WHEN ntss_db5_om_1.ind_treat_start_time IS NOT NULL
                AND ntss_db5_om_1.ind_treat_start_time <> '''' THEN
                    to_char ( ntss_db5_om_1.ind_treat_start_time :: TIME, ''hh24:mi'' )
                    WHEN ntss_db5_om_mst_k.kur_start_time IS NOT NULL
                    AND ntss_db5_om_1.ind_treat_start_time <> '''' THEN
                        to_char ( ntss_db5_om_mst_k.kur_start_time :: TIME, ''hh24:mi'' ) ELSE ''未登録''
                    END AS starttime --透析開始時刻
                FROM
                    ntss_db5_om_1
                    LEFT JOIN ord_schedule ntss_db5_os ON ntss_db5_os.pat_id = ntss_db5_om_1.pat_id
                    AND ntss_db5_os.ord_no = ntss_db5_om_1.ord_no
                LEFT JOIN mst_bed ntss_db5_om_mst_b ON ntss_db5_om_mst_b.bed_cd = ntss_db5_os.bed_cd
        LEFT JOIN mst_kur ntss_db5_om_mst_k ON ntss_db5_om_mst_k.kur_cd = ntss_db5_om_1.ind_kur_cd;'
WHERE sql_cd = '-2180';


-- V_DIALYSIS_COMP
UPDATE sys_data_set
SET "sql"=
        'SELECT
            '''' AS hosppatid --患者ID
            ,ntss_db5_om.pat_id AS patid
            ,COALESCE(to_char(to_timestamp(ntss_db5_om_rci_json ->> ''occur_date'', ''YYYY-MM-DD hh24:mi:ss''), ''YYYY-MM-DD hh24:mi:ss''),
                    to_char(to_timestamp(ntss_db5_om_rti_json ->> ''occur_date'', ''YYYY-MM-DD hh24:mi:ss''), ''YYYY-MM-DD hh24:mi:ss'')) AS occurdate --発生日時
            ,CASE
                WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''2'' THEN ''0''
                WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''1'' THEN ''1''
                WHEN ntss_db5_om_rti_json ->> ''medicine_type'' IS NULL THEN ''2''
                WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''3'' THEN ''3''
             END AS measureclass --区分
            ,ntss_db5_om_rci_json ->> ''comp_cd'' AS reqcode --愁訴コード
            ,ntss_db5_om_rci_json ->> ''complaint'' AS complaint --愁訴内容
            ,ntss_db5_om_rti_json ->> ''treat_name'' AS treatname --処置名
            ,CASE
                WHEN ntss_db5_om_rci_json ->> ''medicine_type'' = ''2'' THEN ntss_db5_mst_mm.in_hospital_cd_1
                WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''1'' THEN ntss_db5_mst_m.in_hospital_cd_1
             END AS medicinecd1 --薬剤コード1
             ,CASE
                WHEN ntss_db5_om_rci_json ->> ''medicine_type'' = ''2'' THEN ntss_db5_mst_mm.in_hospital_cd_2
                WHEN ntss_db5_om_rti_json ->> ''medicine_type'' = ''1'' THEN ntss_db5_mst_m.in_hospital_cd_2
             END AS medicinecd2 --薬剤コード2
             ,ntss_db5_om_rti_json ->> ''medicine_name'' AS medicinename --薬剤名称
             ,ntss_db5_om_rti_json ->> ''amount'' AS amount --数量
             ,ntss_db5_om_rti_json ->> ''unit'' AS unit --単位
             ,ntss_db5_om_rti_json ->> ''procedure_name'' AS procedurename --手技名
             ,ntss_db5_mst_p.in_hospital_cd_a1 AS procedurecd1 --手技コード1
             ,ntss_db5_mst_p.in_hospital_cd_a2 AS procedurecd2 --手技コード2
             ,SUBSTR(ntss_db5_om_tsi_json ->> ''treat_staff_name'', 0, 10) treatpersonname --処置者名
             ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
        FROM
            ord_main ntss_db5_om
            cross join lateral json_array_elements(ntss_db5_om.rst_complaint_info ::json) ntss_db5_om_rci_json
            cross join lateral json_array_elements(ntss_db5_om.rst_treatment_info ::json) ntss_db5_om_rti_json
            LEFT JOIN mst_medicine_mix ntss_db5_mst_mm
            ON cast(ntss_db5_mst_mm.medicine_mix_cd AS char(4)) = ntss_db5_om_rti_json ->> ''treat_medicine_cd''
            AND ntss_db5_mst_mm.facility_cd = @facilityCd
            AND ntss_db5_mst_mm.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
            AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
            LEFT JOIN mst_medicine ntss_db5_mst_m
            ON cast(ntss_db5_mst_m.medicine_cd AS char(4)) = ntss_db5_om_rti_json ->> ''treat_medicine_cd''
            AND ntss_db5_mst_m.facility_cd = @facilityCd
            AND ntss_db5_mst_m.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
            AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
            LEFT JOIN  mst_procedure ntss_db5_mst_p
            ON cast(ntss_db5_mst_p.procedure_cd AS char(4)) = ntss_db5_om_rti_json ->> ''procedure_cd''
            AND ntss_db5_mst_p.facility_cd = @facilityCd
            AND ntss_db5_mst_p.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
            AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
            cross join lateral json_array_elements(ntss_db5_om.rst_treat_staff_info ::json) ntss_db5_om_tsi_json
        WHERE ntss_db5_om.is_del = ''0''
            AND ntss_db5_om.facility_cd = @facilityCd
            AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
            AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2250';

-- V_PAT_INOUT
UPDATE sys_data_set
SET "sql"=
        'SELECT
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
                io ->> ''from_doctot''
                WHEN io ->> ''move_in_out'' = ''3'' THEN
                io ->> ''to_doctot'' ELSE''''
            END AS drname,
            io ->> ''comment'' AS memo,
            CASE
                WHEN io ->> ''move_in_out'' = ''1'' THEN ''導入''
                WHEN io ->> ''move_in_out'' = ''2'' THEN ''転入''
                WHEN io ->> ''move_in_out'' = ''3'' THEN ''転出''
                WHEN io ->> ''move_in_out'' = ''4'' THEN ''入院''
                WHEN io ->> ''move_in_out'' = ''5'' THEN ''退院''
                WHEN io ->> ''move_in_out'' = ''6'' THEN ''外来''
                WHEN io ->> ''move_in_out'' = ''7'' THEN ''離脱''
                WHEN io ->> ''move_in_out'' = ''8'' THEN ''移植''
                WHEN io ->> ''move_in_out'' = ''9'' THEN ''一時転出''
                WHEN io ->> ''move_in_out'' = ''10'' THEN ''通院拒否・不明''
                WHEN io ->> ''move_in_out'' = ''11'' THEN ''死亡''
                ELSE NULL END AS codename
        FROM
            pat_unique pu,
            jsonb_array_elements ( pu.in_out_visit_history_info ) AS io
        WHERE
            pu.is_del = ''0''
          AND  io ->> ''period_start'' ~''^[1-9](\d{7})$'' = TRUE
            AND pu.facility_cd = @facilityCd
            AND pu.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
            AND to_date( @toDate, ''YYYYMMDDHH24MISS'' );'
WHERE sql_cd = '-2260';

-- V_PAT_STATUS
UPDATE sys_data_set
SET "sql"=
        'WITH ntss_db5_om_mnt_mr AS (
            SELECT
                 ntss_db5_om.ord_no AS ord_no
                ,ntss_db5_om_mnt_mr.event_reg_date AS event_reg_date
                ,ntss_db5_om_mnt_mr.machine_record_cd
            FROM
                ord_main ntss_db5_om
                INNER JOIN mnt_motion_record ntss_db5_om_mnt_mr
                ON ntss_db5_om_mnt_mr.motion_record_no = ntss_db5_om.rst_machine_no
                AND ntss_db5_om_mnt_mr.machine_record_cd in (''F407'',''4000'')
            WHERE ntss_db5_om.facility_cd = @facilityCd
            AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
            AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )
        )
        SELECT
            ntss_db5_om.up_date
            ,'''' AS hosppatid --患者ID
            ,ntss_db5_om.pat_id AS patid
            ,ntss_db5_om.treat_date AS dialysisdate --透析日
            ,to_char(ntss_db5_om.rst_start_date, ''HH24MISS'') AS dialysistime --透析開始時刻
            ,CASE WHEN ntss_db5_om.rst_dialysis_state IN (''0'',''1'',''2'')
                  THEN CASE WHEN ntss_db5_om.treat_date is not null and ntss_db5_om.ind_treat_start_time is not null
                                      THEN to_char((ntss_db5_om.treat_date || '' '' || ntss_db5_om.ind_treat_start_time) :: timestamp,''yyyy-mm-dd hh24:mi:ss'') ELSE NULL END
                  WHEN ntss_db5_om.rst_dialysis_state IN (''3'',''4'',''5'',''6'')
                  THEN CASE WHEN ntss_db5_om.rec_set_date is not null
                                        THEN to_char(ntss_db5_om.rec_set_date, ''YYYY-MM-DD hh24:mi:ss'') ELSE NULL END
              END AS startplandate --予定開始日時
            ,CASE WHEN ntss_db5_om.rst_cond_send_date IS NULL
                  THEN ''0''
                  ELSE ''1''
              END AS enterflg --入室フラグ（前体重測定）
            ,to_char(ntss_db5_om.rst_cond_send_date, ''YYYY-MM-DD hh24:mi:ss'') AS enterdate --初回入室日時
            ,CASE WHEN ntss_db5_om_mnt_mr.machine_record_cd = ''F407'' AND ntss_db5_om_mnt_mr.event_reg_date IS NULL
                  THEN ''0''
                  ELSE ''1''
              END AS machinecheckflg --透析装置確認フラグ
            ,CASE WHEN ntss_db5_om_mnt_mr.machine_record_cd = ''F407''
                  THEN to_char(ntss_db5_om_mnt_mr.event_reg_date, ''YYYY-MM-DD hh24:mi:ss'')
                  ELSE null
                  END AS machinecheckdate --透析装置確認日時X
            ,CASE WHEN ntss_db5_om.rst_start_date IS NULL
                  THEN ''0''
                  ELSE ''1''
              END AS dialsisstartflg --透析運転開始フラグ
            ,to_char(ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS dialsissstartdate--透析運転開始日時
            ,CASE WHEN ntss_db5_om_mnt_mr.machine_record_cd = ''4000'' AND ntss_db5_om_mnt_mr.event_reg_date IS NULL
                  THEN ''0''
                  ELSE ''1''
              END AS offwaterflg --除水完了フラグ
            ,CASE WHEN ntss_db5_om_mnt_mr.machine_record_cd = ''4000''
                  THEN to_char(ntss_db5_om_mnt_mr.event_reg_date, ''YYYY-MM-DD hh24:mi:ss'')
                  ELSE null
                  END AS offwaterdate --除水完了日時
            ,CASE WHEN ntss_db5_om.rst_end_date IS NULL
                  THEN ''0''
                  ELSE ''1''
              END AS wastefluidflg --排液フラグ
            ,to_char(ntss_db5_om.rst_end_date, ''YYYY-MM-DD hh24:mi:ss'') AS wastefluiddate --排液日時
            ,CASE WHEN ntss_db5_om.rst_weight_info #>> ''{weight_after_date}'' IS NULL
                  THEN ''0''
                  ELSE ''1''
              END AS weightafterflg --後体重測定
                ,CASE WHEN ntss_db5_om.rst_weight_info #>> ''{weight_after_date}'' is not NULL
                    THEN to_char((ntss_db5_om.rst_weight_info #>> ''{weight_after_date}'')::timestamp, ''yyyy-mm-dd hh24:mi:ss'')
                    ELSE NULL END AS weightafterdate --後体重測定日時
            ,CASE WHEN ntss_db5_om.rec_set_date IS NULL
                  THEN ''0''
                  ELSE ''1''
              END AS recoverybtnflg --準備回収確認ボタンフラグ
            ,to_char(ntss_db5_om.rec_set_date, ''YYYY-MM-DD hh24:mi:ss'') AS recoverybtndate --準備回収確認ボタン日時
            ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --最終更新日時
        FROM
            ord_main ntss_db5_om
            LEFT JOIN ntss_db5_om_mnt_mr
            ON ntss_db5_om_mnt_mr.ord_no = ntss_db5_om.ord_no
        WHERE
            ntss_db5_om.is_del = ''0''
            AND ntss_db5_om.facility_cd = @facilityCd
            AND ntss_db5_om.up_date BETWEEN to_date( @fromDate, ''YYYYMMDDHH24MISS'' )
            AND to_date( @toDate, ''YYYYMMDDHH24MISS'' )'
WHERE sql_cd = '-2300';

