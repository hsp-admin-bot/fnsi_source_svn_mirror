DELETE FROM "ntss"."sys_data_set" WHERE sql_cd = 117;
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (117, 'WITH DATA AS (




with addition_info_expand as
(
  select
    ord_no
    ,json_idx
    ,addinfo
    ,to_date(treat_date, ''yyyymmdd'') as treat_date
  from
    ord_main
    cross join lateral jsonb_array_elements(addition_info) with ordinality as tmp(addinfo, json_idx)
  where
    is_del = ''0''
    and ord_no = @ordNo
    and rst_dialysis_state <>''0''
)
, tmp as
(
  select
    ord_no
    ,addinfo->>''cd'' as cd
    ,addinfo->>''name'' as name
    ,json_idx
    ,addinfo
   ,treat_date
  from
    addition_info_expand
)

select
  ord_no as ord_no_t
	,ord_no
  ,treat_date
  ,name
  ,in_hospital_cd_1 as rst_addition_in_hospital_cd_1
  ,in_hospital_cd_2 as rst_addition_in_hospital_cd_2
  ,in_hospital_cd_3 as rst_addition_in_hospital_cd_3
  ,case
	  when addition_class =''1'' then ''透析液水質確保加算''
		when addition_class =''2'' then ''障害者等加算''
		when addition_class =''3'' then ''指定病名連動''
		when addition_class =''4'' then ''指定治療方法連動''
		when addition_class =''5'' then ''長時間加算''
		when addition_class =''6'' then ''指定薬剤実施連動''
		when addition_class =''7'' then ''指定患者イベント連動''
		when addition_class =''8'' then ''検査依頼連動''
		when addition_class =''9'' then ''導入期加算''
		when addition_class =''10'' then ''休日加算''
		when addition_class =''11'' then ''時間外加算''
		when addition_class =''12'' then ''汎用''
		when addition_class =''13'' then ''慢性維持透析患者外来医学管理料''
	 else  ''''
	end as addition_class,
	mst_addition.addition_name
from
  tmp left outer join mst_addition on tmp.cd = mst_addition.addition_cd::text and is_disp = ''1'' and is_del = ''0''
order by json_idx




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
	', 2, '[{"preview": "2011/3/12", "can_calc": "0", "data_code": "treat_date", "data_name": "透析日", "data_type": "DateTime", "conv_table": [], "data_class": "加算", "field_name": "treat_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "休日", "can_calc": "0", "data_code": "addition_class", "data_name": "種別区分", "data_type": "string", "conv_table": [{"code": "1", "disp": "透析液水質確保加算", "item": "透析液水質確保加算"}, {"code": "2", "disp": "障害者等加算", "item": "障害者等加算"}, {"code": "3", "disp": "指定病名連動", "item": "指定病名連動"}, {"code": "4", "disp": "指定治療方法連動", "item": "指定治療方法連動"}, {"code": "5", "disp": "長時間加算", "item": "長時間加算"}, {"code": "6", "disp": "指定薬剤実施連動", "item": "指定薬剤実施連動"}, {"code": "7", "disp": "指定患者イベント連動", "item": "指定患者イベント連動"}, {"code": "8", "disp": "検査依頼連動", "item": "検査依頼連動"}, {"code": "9", "disp": "導入期加算", "item": "導入期加算"}, {"code": "10", "disp": "休日加算", "item": "休日加算"}, {"code": "11", "disp": "時間外加算", "item": "時間外加算"}, {"code": "12", "disp": "汎用", "item": "汎用"}, {"code": "13", "disp": "慢性維持透析患者外来医学管理料", "item": "慢性維持透析患者外来医学管理料"}], "data_class": "加算", "field_name": "addition_class", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "休日加算", "can_calc": "0", "data_code": "name", "data_name": "加算等名称", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_1", "data_name": "加算連携コード１", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "rst_addition_in_hospital_cd_1", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_2", "data_name": "加算連携コード２", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "rst_addition_in_hospital_cd_2", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "rst_addition_in_hospital_cd_3", "data_name": "加算連携コード３", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "rst_addition_in_hospital_cd_3", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "addition_name", "data_name": "加算・管理料名称", "data_type": "string", "conv_table": [], "data_class": "加算", "field_name": "addition_name", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：加算 @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
