DELETE FROM "ntss"."sys_data_set" where sql_cd in (160);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (160, 'WITH DATA AS (

with dat as
(
SELECT
	ord_no,
	rst_rounds_info ->> ''content'' AS CONTENT,
	rst_rounds_info ->> ''round_type_name'' AS round_type,
	rst_rounds_info ->> ''round_type_cd'' AS round_type_cd,
	CAST(rst_rounds_info ->> ''reg_date_time'' as TIMESTAMP) AS reg_date_time1,
	rst_rounds_info ->> ''ind_user_id'' AS ind_user_id,
	( rst_rounds_info ->> ''ind_user_last_name'' ) || ( rst_rounds_info ->> ''ind_user_first_name'' ) AS ind_user_name,
	rst_rounds_info ->> ''reg_user_id'' AS reg_user_id,
	( rst_rounds_info ->> ''reg_user_last_name'' ) || ( rst_rounds_info ->> ''reg_user_first_name'' ) AS reg_user_name,
CASE
		rst_rounds_info ->> ''is_ind_comment_post''
		WHEN ''0'' THEN
		''転記しない'' ELSE''転記する''
	END AS is_ind_comment_post,
	rst_rounds_info ->> ''ind_comment_no'' AS ind_comment_no,
CASE
		rst_rounds_info ->> ''posting_class''
		WHEN ''0'' THEN
		''継続'' ELSE''当日のみ''
	END AS posting_class,
	rst_rounds_info ->> ''created_user_id'' AS created_user_id,
	( rst_rounds_info ->> ''created_user_last_name'' ) || ( rst_rounds_info ->> ''created_user_first_name'' ) AS created_user_name,
	rst_rounds_info ->> ''updated_user_id'' AS updated_user_id,
	( rst_rounds_info ->> ''updated_user_last_name'' ) || ( rst_rounds_info ->> ''updated_user_first_name'' ) AS updated_user_name
FROM
	ord_main
WHERE
	ord_no = @ordNo
	AND is_del = ''0''
	AND rst_dialysis_state <> ''0''
)

SELECT
ord_no as ord_no_t,
CONTENT,
round_type,
round_type_cd,
substr(to_char(reg_date_time1,''YYYY/MM/DD hh24:mi:ss''), 0,17) as reg_date_time,
ind_user_id,
ind_user_name,
reg_user_id,
reg_user_name,
is_ind_comment_post,
ind_comment_no,
posting_class,
created_user_id,
created_user_name,
updated_user_id,
updated_user_name
FROM
	dat
	),
time_info AS (
	WITH b AS (
    select ord_main.* from ord_main
     where rst_dialysis_state between ''1'' and ''5''
     and
			ord_no = @ordNo
     and
       is_del = ''0''
	), d AS (
    select b.ord_no
    , data_type
    , MAX(bio_moni_ctl_no) AS bio_moni_ctl_no
    from b inner join mni_monitor on (b.ord_no = mni_monitor.ord_no)
    group by b.ord_no
    , mni_monitor.data_type
	), e AS (
    select mni_monitor.*,
    to_number(mni_monitor.monitor_data::json->>''1'', ''9999'') AS 経過時間
    , to_number(mni_monitor.monitor_data::json->>''3'', ''9999'') AS 残り時間_除水完了
    , to_number(mni_monitor.monitor_data::json->>''4'', ''9999'') AS 残り時間_透析完了
    from d
    inner join mni_monitor on (d.bio_moni_ctl_no = mni_monitor.bio_moni_ctl_no)
    where d.data_type = 1
	), f AS (
    select e.*
    , e.経過時間 + e.残り時間_除水完了 AS 予測時間_除水
    , e.経過時間 + e.残り時間_透析完了 AS 予測時間_透析
    from e
	)
	select
	b.ord_no as ordnob,
	b.treat_date as treat_date,
	-- 終了予定
	b.rst_start_date + e.経過時間  * interval ''1 minute'' AS  ind_end_date,
	-- 終了予測
	CASE WHEN b.rst_dialysis_state < ''3'' THEN null
       WHEN f.残り時間_除水完了 > f.残り時間_透析完了 THEN b.rst_start_date + f.予測時間_除水 * interval ''1 minute''
       ELSE b.rst_start_date + f.予測時間_透析 * interval ''1 minute''
	END AS ind_end_date_time
	-- 透析開始
	, b.rst_start_date
	-- 透析終了
	, b.rst_end_date
	from  b left JOIN e on b.ord_no=e.ord_no left JOIN f on b.ord_no=f.ord_no
)
SELECT
DATA.ord_no_t as ord_no,
	*
FROM
	DATA
	LEFT JOIN
	time_info
	on
	DATA.ord_no_t = time_info.ordnob
	;
	', 2, '[{"preview": "001", "can_calc": "1", "data_code": "round_type", "data_name": "種別名", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "round_type", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "002", "can_calc": "1", "data_code": "content", "data_name": "種別内容", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "content", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "003", "can_calc": "1", "data_code": "round_type_cd", "data_name": "種別コード", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "round_type_cd", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2011/05/20 12:30", "can_calc": "1", "data_code": "reg_date_time", "data_name": "起票日時", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "reg_date_time", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "005", "can_calc": "1", "conv_sql": {"sql_cd": 196, "field_name": "disp_user_id", "target_var": "@indUserId"}, "data_code": "ind_user_id", "data_name": "指示者ID", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "ind_user_id", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "006", "can_calc": "1", "data_code": "ind_user_name", "data_name": "指示者名", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "ind_user_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "007", "can_calc": "1", "conv_sql": {"sql_cd": 193, "field_name": "disp_user_id", "target_var": "@regUserId"}, "data_code": "reg_user_id", "data_name": "起票者ID", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "reg_user_id", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "008", "can_calc": "1", "data_code": "reg_user_name", "data_name": "起票者名", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "reg_user_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "009", "can_calc": "1", "data_code": "is_ind_comment_post", "data_name": "指示コメントに転記", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "is_ind_comment_post", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "010", "can_calc": "1", "data_code": "ind_comment_no", "data_name": "指示コメント番号", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "ind_comment_no", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "011", "can_calc": "1", "data_code": "posting_class", "data_name": "転記区分", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "posting_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "012", "can_calc": "1", "conv_sql": {"sql_cd": 194, "field_name": "disp_user_id", "target_var": "@createdUserId"}, "data_code": "created_user_id", "data_name": "登録者ID", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "created_user_id", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "013", "can_calc": "1", "data_code": "created_user_name", "data_name": "登録者名", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "created_user_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "014", "can_calc": "1", "conv_sql": {"sql_cd": 195, "field_name": "disp_user_id", "target_var": "@updatedUserId"}, "data_code": "updated_user_id", "data_name": "更新者ID", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "updated_user_id", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "015", "can_calc": "1", "data_code": "updated_user_name", "data_name": "更新者名", "data_type": "string", "conv_table": [], "data_class": "回診記録", "field_name": "updated_user_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：回診記録 @ordNo 使用', '2021-10-18 16:42:37.948', CURRENT_TIMESTAMP, NULL);
