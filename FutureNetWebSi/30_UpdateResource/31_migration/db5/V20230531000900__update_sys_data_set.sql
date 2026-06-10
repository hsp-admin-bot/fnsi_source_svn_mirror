DELETE FROM "ntss"."sys_data_set" where sql_cd in (-2041);
insert into ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) values
(-2041,'SELECT
    '''' AS hosppatid --患者ID
    ,ntss_db5_pu.pat_id AS patid
    ,ntss_db5_pu_mhi_json ->> ''ctl_no'' AS ctlno --管理番号
    ,to_char(ntss_db5_pu.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
    ,ntss_db5_pu_mst_d.disease_cd AS diseasecd --病名コード
    ,ntss_db5_pu_mst_d.disease_name AS diseasename --病名
    ,to_char(to_timestamp(ntss_db5_pu_mhi_json ->> ''disease_date'', ''YYYYMMDD''), ''YYYY-MM-DD hh24:mi:ss'') AS diseasedate --発症日
    ,to_char(to_timestamp(ntss_db5_pu_mhi_json ->> ''out_come_date'', ''YYYYMMDD''), ''YYYY-MM-DD hh24:mi:ss'') AS recoverdate --治癒日
    ,ntss_db5_pu_mhi_json ->> ''is_main_disease'' AS maindisease --主病名
    ,ntss_db5_pu_mhi_json ->> ''out_come'' AS status --転帰
    ,ntss_db5_pu_mhi_json ->> ''is_notice'' AS noticeflg --告知有無
    ,ntss_db5_pu_mhi_json ->> ''diagnostician_cd'' AS doctorname --診断医
		,CASE WHEN
		ntss_db5_pu_mhi_json ->> ''course_is_free'' = ''0'' then cast(ntss_db5_pu_mst_d.disease_cd AS integer)
		END AS userid
    ,ntss_db5_pu_mhi_json ->> ''memo'' AS memo --メモ
FROM
    pat_unique ntss_db5_pu
    CROSS JOIN LATERAL json_array_elements(ntss_db5_pu.medical_hst_info::json) ntss_db5_pu_mhi_json
    LEFT JOIN mst_disease ntss_db5_pu_mst_d
    ON cast(ntss_db5_pu_mst_d.disease_cd AS char(20)) = cast(ntss_db5_pu_mhi_json ->> ''disease_cd'' AS char(20))
WHERE
    ntss_db5_pu.is_del = ''0''
    AND ntss_db5_pu.facility_cd = @facilityCd
    AND (
        CASE
            WHEN @syncMode = ''update''
                THEN (
                (
                    ntss_db5_pu.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
                OR (
                    ntss_db5_pu_mst_d.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
            )
            else ntss_db5_pu.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
            end
    )
    AND ntss_db5_pu.medical_hst_info IS NOT NULL
    AND ntss_db5_pu.medical_hst_info <> ''[]''
    AND ntss_db5_pu_mhi_json ->> ''course_is_free'' in (''0'', ''1'');',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}','2021/02/26 17:51:54.726','2021/08/31 17:51:54.726',null);
