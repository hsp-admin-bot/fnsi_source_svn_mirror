UPDATE "ntss"."sys_data_set" SET "detail" = '[{"preview": "なし", "can_calc": "0", "data_code": "is_same", "data_name": "同姓同名判別", "data_type": "string", "conv_table": [{"code": "0", "disp": "なし", "item": "なし"}, {"code": "1", "disp": "あり", "item": "あり"}], "data_class": "基本情報", "field_name": "is_same", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "感染症患者", "can_calc": "0", "data_code": "is_infect", "data_name": "感染症患者判別", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": "非感染症患者"}, {"code": "1", "disp": "感染症患者", "item": "感染症患者"}], "data_class": "既往歴", "field_name": "is_infect", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "泌尿器科", "can_calc": "0", "data_code": "main_course_name", "data_name": "診療科", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "main_course_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "main_in_hospital_cd_1", "data_name": "診療科連携コード", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "main_in_hospital_cd_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "A棟", "can_calc": "0", "data_code": "ward_name", "data_name": "病棟名", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "ward_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "ward_in_hospital_cd_1", "data_name": "病棟名連携コード", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "ward_in_hospital_cd_1", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "100", "can_calc": "0", "data_code": "dialysis_count", "data_name": "透析回数", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "dialysis_count", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "11年3ケ月", "can_calc": "0", "data_code": "dialysis_vintage", "data_name": "透析歴", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "dialysis_vintage", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2000/02/10", "can_calc": "0", "data_code": "dialysis_start_date", "data_name": "透析導入日", "data_type": "DateTime", "conv_table": [], "data_class": "既往歴", "field_name": "dialysis_start_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "日機装病院", "can_calc": "0", "data_code": "facility_name", "data_name": "透析導入施設", "data_type": "string", "conv_table": [], "data_class": "既往歴", "field_name": "facility_name", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2005/08/18", "can_calc": "0", "data_code": "hospital_start_date", "data_name": "当院開始日", "data_type": "DateTime", "conv_table": [], "data_class": "既往歴", "field_name": "hospital_start_date", "disp_format": "yyyy/mm/dd", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "糖尿病患者", "can_calc": "0", "data_code": "is_diabetes", "data_name": "糖尿病患者判別", "data_type": "string", "conv_table": [{"code": "0", "disp": "", "item": "非糖尿病患者"}, {"code": "1", "disp": "糖尿病患者", "item": "糖尿病患者"}], "data_class": "糖尿病患者判別", "field_name": "is_diabetes", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]'WHERE "sql_cd" = 19;
UPDATE "ntss"."sys_data_set" SET "sql" = 'with pat_taboo_tbl as (
  select
    to_number( info->>''ctl_no'', ''99999'') as ctl_no,
    to_number( info->>''disp_order'', ''99999'') as disp_order,
    info->>''content'' as content,
    info->>''memo'' as memo,
    info->>''category_class'' as category_class,
    info->>''taboo_allergy_class'' as taboo_allergy_class,
    info->>''taboo_allergy_cd'' as taboo_allergy_cd
  from
    pat_main
    cross join lateral
      json_array_elements (pat_main.taboo_allergy_info :: json) info
  where
    pat_id = @patId
    and is_del = ''0''
)

select
  ctl_no,
  disp_order,
  content,
  memo,
  category_class,
  taboo_allergy_class,
  taboo_allergy_cd
from
  pat_taboo_tbl
order by
  disp_order, ctl_no
', "detail" = '[{"preview": "テスト薬剤（禁忌・アレルギー）", "can_calc": "0", "data_code": "content", "data_name": "禁忌・アレルギー", "data_type": "string", "conv_table": [], "data_class": "禁忌・アレルギー", "field_name": "content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "禁忌・アレルギーです。", "can_calc": "0", "data_code": "memo", "data_name": "禁忌・アレルギー備考", "data_type": "string", "conv_table": [], "data_class": "禁忌・アレルギー", "field_name": "memo", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', "can_repeat" = '1', "use_application" = '{"applications": [1]}' WHERE "sql_cd" = 22;

UPDATE "ntss"."sys_data_set" SET "sql" = 'select                                            
  info->>''item_cd'' as item_cd,                                            
  item.in_hospital_cd1 as in_hospital_cd1,                                            
  item.in_hospital_cd2 as in_hospital_cd2,                                            
  item.in_hospital_cd3 as in_hospital_cd3,                                            
  item.sbt_cd1 as sbt_cd1,                                            
  item.sbt_cd2 as sbt_cd2,                                            
  item.sbt_cd3 as sbt_cd3,                                            
  info->>''item_name'' as item_name,                                            
  info->>''result'' as result,                                            
  info->>''unit'' as unit,                                            
  info->>''freememo'' as freememo,                                            
  p.result_exam_date as result_exam_date,                                            
  p.reg_exam_date,                                            
  p.reg_order_class,                                            
  info->>''upper'' as upper,                                            
  info->>''lower'' as lower                                             
from (                                            
  select                                            
    m.*                                            
  from                                            
    pat_exam_main as m                                            
  where                                            
    m.is_del = ''0''                                            
    and m.exam_status = ''1''                                            
    and m.pat_id = @patId                                           
    and m.result_exam_date between date_trunc (''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp)                                             
    order by m.result_exam_date desc                                            
  ) as p                                            
  cross join lateral                                            
  json_array_elements (p.exam_result_info :: json) info                                            
  left outer join                                            
  mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''') and item.is_del = ''0'' and item.is_disp = ''1''                                            
;                                            
'WHERE "sql_cd" = 30;

UPDATE "ntss"."sys_data_set" SET "sql" = 'with ord_key_tbl as (
  select
    ord_no,
    treat_date
  from
    ord_main
  where
    ord_no = @ordNo
    and is_del = ''0''
    and rst_dialysis_state = ''0''
), ord_hist_tbl as (
  select
    ord_no,
    to_date(treat_date, ''yyyymmdd'') as treat_date,
    rst_dw,
    rst_cond_info->''3''->>''value'' as target_weight
  from
    ord_main
  where
  pat_id = @patId
  and  ord_no <> (select ord_no from ord_key_tbl)
  and
    treat_date <= (select treat_date from ord_key_tbl)
  and
     rst_dialysis_state = ''0''
  and is_del = ''0''
  order by
    treat_date desc
  limit 2

), ord_array_tbl as (
  select
    array_agg(ord_no) as array_ord_no,
    array_agg(treat_date) as array_treat_date,
    array_agg(rst_dw) as array_dw,
    array_agg(target_weight) as array_target_weight
  from
    ord_hist_tbl
)

select
  array_ord_no[1] as ord_no1,
  array_ord_no[2] as ord_no2,
  array_treat_date[1] as treat_date1,
  array_treat_date[2] as treat_date2,
  array_dw[1] as dw1,
  array_dw[2] as dw2,
  array_target_weight[1] as target_weight1,
  array_target_weight[2] as target_weight2
  
from
  ord_array_tbl
' WHERE "sql_cd" = 82;
UPDATE "ntss"."sys_data_set" SET "sql" = 'select 
  pm.device_set_info#>>''{"bp","dev","A","211"}'' as bp_dev_a_0211,--血圧警報点最高血圧上限
  pm.device_set_info#>>''{"bp","dev","A","212"}'' as bp_dev_a_0212,--血圧警報点最高血圧下限
  pm.device_set_info#>>''{"bp","dev","A","213"}'' as bp_dev_a_0213,--血圧警報点最低血圧上限
  pm.device_set_info#>>''{"bp","dev","A","214"}'' as bp_dev_a_0214,--血圧警報点最低血圧下限
  pm.device_set_info#>>''{"bp","dev","A","215"}'' as bp_dev_a_0215,--血圧警報点平均血圧上限
  pm.device_set_info#>>''{"bp","dev","A","216"}'' as bp_dev_a_0216,--血圧警報点平均血圧下限
  pm.device_set_info#>>''{"bp","dev","A","217"}'' as bp_dev_a_0217,--血圧警報点脈拍数上限
  pm.device_set_info#>>''{"bp","dev","A","218"}'' as bp_dev_a_0218,--血圧警報点脈拍数下限
  pm.device_set_info#>>''{"bp","dev","A","227"}'' as bp_dev_a_0227,--最高血圧上限警報_血液ポンプ_速度
  pm.device_set_info#>>''{"bp","dev","A","219"}'' as bp_dev_a_0219,--最高血圧上限警報_血液ポンプ_動作選択
  pm.device_set_info#>>''{"bp","dev","A","228"}'' as bp_dev_a_0228,--最高血圧下限警報_血液ポンプ_速度
  pm.device_set_info#>>''{"bp","dev","A","220"}'' as bp_dev_a_0220,--最高血圧下限警報_血液ポンプ_動作選択
  pm.device_set_info#>>''{"bp","dev","A","229"}'' as bp_dev_a_0229,--最高血圧上限警報_除水ポンプ_速度
  pm.device_set_info#>>''{"bp","dev","A","221"}'' as bp_dev_a_0221,--最高血圧上限警報_除水ポンプ_動作選択
  pm.device_set_info#>>''{"bp","dev","A","230"}'' as bp_dev_a_0230,--最高血圧下限警報_除水ポンプ_速度
  pm.device_set_info#>>''{"bp","dev","A","222"}'' as bp_dev_a_0222,--最高血圧下限警報_除水ポンプ_動作選択
  pm.device_set_info#>>''{"bp","dev","A","231"}'' as bp_dev_a_0231,--最高血圧上限警報_Na注入ポンプ_速度
  pm.device_set_info#>>''{"bp","dev","A","223"}'' as bp_dev_a_0223,--最高血圧上限警報_Na注入ポンプ_動作選択
  pm.device_set_info#>>''{"bp","dev","A","232"}'' as bp_dev_a_0232,--最高血圧下限警報_Na注入ポンプ_速度
  pm.device_set_info#>>''{"bp","dev","A","224"}'' as bp_dev_a_0224,--最高血圧下限警報_Na注入ポンプ_動作選択
  pm.device_set_info#>>''{"bp","dev","A","233"}'' as bp_dev_a_0233,--最高血圧上限警報_補液ポンプ_速度
  pm.device_set_info#>>''{"bp","dev","A","225"}'' as bp_dev_a_0225,--最高血圧上限警報_補液ポンプ_動作選択
  pm.device_set_info#>>''{"bp","dev","A","234"}'' as bp_dev_a_0234,--最高血圧下限警報_補液ポンプ_速度
  pm.device_set_info#>>''{"bp","dev","A","226"}'' as bp_dev_a_0226,--最高血圧下限警報_補液ポンプ_動作選択
  pm.device_set_info#>>''{"bp","dev","A","191"}'' as bp_dev_a_0191,--血圧カフ選択
  pm.device_set_info#>>''{"bp","dev","A","190"}'' as bp_dev_a_0190,--血圧自動測定間隔
  pm.device_set_info#>>''{"bp","dev","A","192"}'' as bp_dev_a_0192,--昇圧値
  pm.device_set_info#>>''{"bp","dev","A","193"}'' as bp_dev_a_0193,--昇圧方法選択
  pm.device_set_info#>>''{"bp","dev","A","195"}'' as bp_dev_a_0195,--血圧測定方法選択
  pm.device_set_info#>>''{"bp","dev","A","239"}'' as bp_dev_a_0239,--高速測定選択
  pm.device_set_info#>>''{"bp","dev","A","194"}'' as bp_dev_a_0194,--血圧連続測定動作選択
  pm.device_set_info#>>''{"bp","dev","A","235"}'' as bp_dev_a_0235,--警報連動測定開始時間
  pm.device_set_info#>>''{"bp","dev","A","236"}'' as bp_dev_a_0236,--治療条件連動測定時間
  pm.device_set_info#>>''{"bp","dev","A","237"}'' as bp_dev_a_0237,--静脈圧警報発生時の血圧測定
  pm.device_set_info#>>''{"bp","dev","A","238"}'' as bp_dev_a_0238,--血流量または除水速度変更時の血圧測定
  pm.device_set_info#>>''{"bv","dev","A","267"}'' as bv_dev_a_0267,--BV計使用選択
  pm.device_set_info#>>''{"bv","dev","A","260"}'' as bv_dev_a_0260,--⊿BV低下警報点1
  pm.device_set_info#>>''{"bv","dev","A","261"}'' as bv_dev_a_0261,--⊿BV低下警報点2
  pm.device_set_info#>>''{"bv","dev","A","262"}'' as bv_dev_a_0262,--⊿BV変化率警報点
  pm.device_set_info#>>''{"bv","dev","A","277"}'' as bv_dev_a_0277,--⊿BV除水低下速度
  pm.device_set_info#>>''{"bv","dev","A","278"}'' as bv_dev_a_0278,--⊿BV除水低下遅延時間
  pm.device_set_info#>>''{"bv","dev","A","258"}'' as bv_dev_a_0258,--アクセス再循環測定使用選択
  pm.device_set_info#>>''{"bv","dev","A","259"}'' as bv_dev_a_0259,--アクセス再循環自動測定1
  pm.device_set_info#>>''{"bv","dev","A","263"}'' as bv_dev_a_0263,--アクセス再循環自動測定2
  pm.device_set_info#>>''{"bv","dev","A","264"}'' as bv_dev_a_0264,--アクセス再循環自動測定3
  pm.device_set_info#>>''{"bv","dev","A","265"}'' as bv_dev_a_0265,--アクセス再循環自動測定4
  pm.device_set_info#>>''{"bv","dev","A","266"}'' as bv_dev_a_0266,--アクセス再循環自動測定5
  pm.device_set_info#>>''{"bv","dev","A","281"}'' as bv_dev_a_0281,--アクセス再循環再循環率報知
  pm.device_set_info#>>''{"cpro","dev","A","252"}'' as cpro_dev_a_0252,--Ｂ液濃度プログラム自動設定警報幅上限
  pm.device_set_info#>>''{"cpro","dev","A","253"}'' as cpro_dev_a_0253,--Ｂ液濃度プログラム自動設定警報幅下限
  pm.device_set_info#>>''{"cpro","dev","A","250"}'' as cpro_dev_a_0250,--透析液濃度プログラム自動設定警報幅上限
  pm.device_set_info#>>''{"cpro","dev","A","251"}'' as cpro_dev_a_0251,--透析液濃度プログラム自動設定警報幅下限
  pm.device_set_info#>>''{"dfas","dev","A","339"}'' as dfas_dev_a_0339,--脱血方法選択
  pm.device_set_info#>>''{"dfas","dev","A","333"}'' as dfas_dev_a_0333,--脱血速度
  pm.device_set_info#>>''{"dfas","dev","A","331"}'' as dfas_dev_a_0331,--同時脱血_脱血量
  pm.device_set_info#>>''{"dfas","dev","A","334"}'' as dfas_dev_a_0334,--片側脱血(除水なし)_脱血量
  pm.device_set_info#>>''{"dfas","dev","A","338"}'' as dfas_dev_a_0338,--片側脱血（除水あり）_脱血量
  pm.device_set_info#>>''{"dfas","dev","A","332"}'' as dfas_dev_a_0332,--片側脱血への切替え透析液圧
  pm.device_set_info#>>''{"dfas","dev","A","373"}'' as dfas_dev_a_0373,--静脈側返血速度
  pm.device_set_info#>>''{"dfas","dev","A","374"}'' as dfas_dev_a_0374,--静脈側最大返血量
  pm.device_set_info#>>''{"dfas","dev","A","377"}'' as dfas_dev_a_0377,--静脈側返血_血液判別器使用選択
  pm.device_set_info#>>''{"dfas","dev","A","270"}'' as dfas_dev_a_0270,--動脈側返血使用選択
  pm.device_set_info#>>''{"dfas","dev","A","376"}'' as dfas_dev_a_0376,--動脈側最大返血量
  pm.device_set_info#>>''{"dfas","dev","A","378"}'' as dfas_dev_a_0378,--動脈側返血_血液判別器使用選択
  pm.device_set_info#>>''{"dfas","dev","A","335"}'' as dfas_dev_a_0335,--治療開始時_血液ポンプ速度
  pm.device_set_info#>>''{"dfas","dev","B","36"}'' as dfas_dev_b_0036,--治療開始時_血流量使用有無
  pm.device_set_info#>>''{"dfas","pat","B","1"}'' as dfas_pat_b_0001,--IPラインプライミング使用選択
  pm.device_set_info#>>''{"dfas","pat","B","5"}'' as dfas_pat_b_0005,--中空糸_プライミング時のBP速度
  pm.device_set_info#>>''{"dfas","pat","B","7"}'' as dfas_pat_b_0007,--中空糸_送液最大時間
  pm.device_set_info#>>''{"dfas","pat","B","8"}'' as dfas_pat_b_0008,--中空糸_回路内洗浄送液量
  pm.device_set_info#>>''{"dfas","pat","B","9"}'' as dfas_pat_b_0009,--中空糸_気泡抜き動作実行回数
  pm.device_set_info#>>''{"dfas","pat","B","10"}'' as dfas_pat_b_0010,--中空糸_気泡抜き圧力上限
  pm.device_set_info#>>''{"dfas","pat","B","59"}'' as dfas_pat_b_0059,--積層_プライミング時のBP速度
  pm.device_set_info#>>''{"dfas","pat","B","54"}'' as dfas_pat_b_0054,--積層_送液最大時間
  pm.device_set_info#>>''{"dfas","pat","B","55"}'' as dfas_pat_b_0055,--積層_回路内洗浄送液量
  pm.device_set_info#>>''{"dfas","pat","B","56"}'' as dfas_pat_b_0056,--積層_気泡抜き動作実行回数
  pm.device_set_info#>>''{"dfas","pat","B","57"}'' as dfas_pat_b_0057,--積層_気泡抜き圧力上限
  pm.device_set_info#>>''{"dfas","pat","B","58"}'' as dfas_pat_b_0058,--積層_除水ポンプ速度
  pm.device_set_info#>>''{"ecum","dev","A","16"}'' as ecum_dev_a_0016,--ECUM選択
  pm.device_set_info#>>''{"ecum","dev","A","17"}'' as ecum_dev_a_0017,--ECUM量
  pm.device_set_info#>>''{"ecum","dev","A","18"}'' as ecum_dev_a_0018,--ECUM時間
  pm.device_set_info#>>''{"ecum","dev","A","19"}'' as ecum_dev_a_0019,--ECUM時間カウント選択
  pm.device_set_info#>>''{"ope","dev","A","179"}'' as ope_dev_a_0179,--血流量設定最大値
  pm.device_set_info#>>''{"ope","dev","A","181"}'' as ope_dev_a_0181,--除水速度制限
  pm.device_set_info#>>''{"ope","dev","A","38"}'' as ope_dev_a_0038,--動脈側気泡検出器
  pm.device_set_info#>>''{"ope","dev","A","21"}'' as ope_dev_a_0021,--除水計算時間
  pm.device_set_info#>>''{"ope","dev","A","22"}'' as ope_dev_a_0022,--除水計算優先項目
  pm.device_set_info#>>''{"ope","dev","A","39"}'' as ope_dev_a_0039,--除水開始遅延時間
  pm.device_set_info#>>''{"ope","dev","A","182"}'' as ope_dev_a_0182,--透析液温度操作範囲上限
  pm.device_set_info#>>''{"ope","dev","A","183"}'' as ope_dev_a_0183,--透析液温度操作範囲下限
  pm.device_set_info#>>''{"ope","dev","A","268"}'' as ope_dev_a_0268,--透析液流量　設定方法
  pm.device_set_info#>>''{"ope","dev","A","269"}'' as ope_dev_a_0269,--透析液流量　比率設定
  pm.device_set_info#>>''{"ope","dev","A","24"}'' as ope_dev_a_0024,--シングルニードル切替圧上限
  pm.device_set_info#>>''{"ope","dev","A","25"}'' as ope_dev_a_0025,--シングルニードル切替圧下限
  pm.device_set_info#>>''{"ope","dev","A","241"}'' as ope_dev_a_0241,--TMPゼロ補正
  pm.device_set_info#>>''{"ope","dev","A","168"}'' as ope_dev_a_0168,--HD補正警報上限値
  pm.device_set_info#>>''{"ope","dev","A","169"}'' as ope_dev_a_0169,--HD補正警報下限値
  pm.device_set_info#>>''{"ope","dev","A","171"}'' as ope_dev_a_0171,--ECUM補正警報上限値
  pm.device_set_info#>>''{"ope","dev","A","172"}'' as ope_dev_a_0172,--ECUM補正警報下限値
  pm.device_set_info#>>''{"ope","dev","A","174"}'' as ope_dev_a_0174,--HDF補正警報上限値
  pm.device_set_info#>>''{"ope","dev","A","175"}'' as ope_dev_a_0175,--HDF補正警報下限値
  pm.device_set_info#>>''{"ope","dev","A","177"}'' as ope_dev_a_0177,--HF補正警報上限値
  pm.device_set_info#>>''{"ope","dev","A","178"}'' as ope_dev_a_0178,--HF補正警報下限値
  pm.device_set_info#>>''{"ope","dev","A","391"}'' as ope_dev_a_0391,--OHDF補正警報上限値
  pm.device_set_info#>>''{"ope","dev","A","392"}'' as ope_dev_a_0392,--OHDF補正警報下限値
  pm.device_set_info#>>''{"ope","dev","A","394"}'' as ope_dev_a_0394,--OHF補正警報上限値
  pm.device_set_info#>>''{"ope","dev","A","395"}'' as ope_dev_a_0395,--OHF補正警報下限値
  pm.device_set_info#>>''{"ope","dev","A","383"}'' as ope_dev_a_0383,--補液量制限
  pm.device_set_info#>>''{"ope","dev","A","389"}'' as ope_dev_a_0389,--補液計算優先項目
  pm.device_set_info#>>''{"ope","dev","A","379"}'' as ope_dev_a_0379,--補液比率（前補液）
  pm.device_set_info#>>''{"ope","dev","A","398"}'' as ope_dev_a_0398,--補液開始遅延時間
  pm.device_set_info#>>''{"ope","dev","A","369"}'' as ope_dev_a_0369,--DP=Qd+Qs(補液速度加算)
  pm.device_set_info#>>''{"ope","dev","A","90"}'' as ope_dev_a_0090,--濾過率（前補液）
  pm.device_set_info#>>''{"ope","dev","A","91"}'' as ope_dev_a_0091,--ヘマトクリット（Ht）
  pm.device_set_info#>>''{"ope","dev","A","92"}'' as ope_dev_a_0092,--総タンパク（TP）
  pm.device_set_info#>>''{"ope","dev","A","336"}'' as ope_dev_a_0336,--緊急補液速度
  pm.device_set_info#>>''{"ope","dev","A","337"}'' as ope_dev_a_0337,--緊急補液量
  pm.device_set_info#>>''{"ope","dev","A","185"}'' as ope_dev_a_0185,--HDF速度操作範囲上限前補液
  pm.device_set_info#>>''{"ope","dev","A","186"}'' as ope_dev_a_0186,--HF速度操作範囲上限前補液
  pm.device_set_info#>>''{"ope","dev","A","396"}'' as ope_dev_a_0396,--OHDF速度操作範囲上限前補液
  pm.device_set_info#>>''{"ope","dev","A","397"}'' as ope_dev_a_0397,--OHF速度操作範囲上限前補液
  pm.device_set_info#>>''{"ope","dev","A","384"}'' as ope_dev_a_0384,--AFBF補液比率使用選択
  pm.device_set_info#>>''{"ope","dev","A","385"}'' as ope_dev_a_0385,--AFBF補液比率
  pm.device_set_info#>>''{"ope","dev","A","386"}'' as ope_dev_a_0386,--AFBF速度操作範囲上限
  pm.device_set_info#>>''{"ope","dev","A","387"}'' as ope_dev_a_0387,--AFBF速度操作範囲下限
  pm.device_set_info#>>''{"ope","dev","A","472"}'' as ope_dev_a_0472,--TMP閾値　速度低下,
  pm.device_set_info#>>''{"ope","dev","A","473"}'' as ope_dev_a_0473,--TMP閾値　速度復帰,
  pm.device_set_info#>>''{"ope","dev","A","474"}'' as ope_dev_a_0474,--速度変化率　速度低下,
  pm.device_set_info#>>''{"ope","dev","A","475"}'' as ope_dev_a_0475,--速度変化率　速度復帰
  pm.device_set_info#>>''{"ope","dev","B","37"}'' as ope_dev_b_0037,--HD+補液補正警報上限値
  pm.device_set_info#>>''{"ope","dev","B","38"}'' as ope_dev_b_0038,--HD+補液補正警報下限値
  pm.device_set_info#>>''{"ope","dev","B","39"}'' as ope_dev_b_0039,--補液比率（後補液）
  pm.device_set_info#>>''{"ope","dev","B","40"}'' as ope_dev_b_0040,--濾過率（後補液）
  pm.device_set_info#>>''{"ope","dev","B","30"}'' as ope_dev_b_0030,--HD+補液速度操作範囲上限前補液
  pm.device_set_info#>>''{"ope","dev","B","31"}'' as ope_dev_b_0031,--HDF速度操作範囲上限後補液
  pm.device_set_info#>>''{"ope","dev","B","32"}'' as ope_dev_b_0032,--HF速度操作範囲上限後補液
  pm.device_set_info#>>''{"ope","dev","B","33"}'' as ope_dev_b_0033,--HD+補液速度操作範囲上限後補液
  pm.device_set_info#>>''{"ope","dev","B","34"}'' as ope_dev_b_0034,--OHDF速度操作範囲上限後補液
  pm.device_set_info#>>''{"ope","dev","B","35"}'' as ope_dev_b_0035,--OHF速度操作範囲上限後補液
  pm.device_set_info#>>''{"ope","dev","C","91"}'' as ope_dev_c_0091,--ヘマトクリット（Ht）
  pm.device_set_info#>>''{"ope","dev","C","92"}'' as ope_dev_c_0092,--総タンパク（TP）
  pm.device_set_info#>>''{"pri","dev","A","370"}'' as pri_dev_a_0370,--自動回収_使用液量
  pm.device_set_info#>>''{"pri","dev","A","371"}'' as pri_dev_a_0371,--自動回収_流速
  pm.device_set_info#>>''{"pri","dev","A","372"}'' as pri_dev_a_0372,--自動回収_血液判別器による終了選択
  pm.device_set_info#>>''{"pri","pat","A","219"}'' as pri_pat_a_0219,--プライミング補助動脈充填液量
  pm.device_set_info#>>''{"pri","pat","A","220"}'' as pri_pat_a_0220,--プライミング補助動脈充填流速
  pm.device_set_info#>>''{"pri","pat","A","225"}'' as pri_pat_a_0225,--プライミング補助動脈充填後継続の有無
  pm.device_set_info#>>''{"pri","pat","A","221"}'' as pri_pat_a_0221,--プライミング補助静脈充填液量
  pm.device_set_info#>>''{"pri","pat","A","222"}'' as pri_pat_a_0222,--プライミング補助静脈充填流速
  pm.device_set_info#>>''{"pri","pat","A","226"}'' as pri_pat_a_0226,--プライミング補助静脈充填後継続の有無
  pm.device_set_info#>>''{"pri","pat","A","223"}'' as pri_pat_a_0223,--プライミング補助気泡抜き液量
  pm.device_set_info#>>''{"pri","pat","A","224"}'' as pri_pat_a_0224,--プライミング補助気泡抜き流速
  pm.device_set_info#>>''{"pri","pat","A","227"}'' as pri_pat_a_0227,--プライミング補助気泡抜き間欠動作選択
  pm.device_set_info#>>''{"pri","pat","A","228"}'' as pri_pat_a_0228,--プライミング補助液交換量
  pm.device_set_info#>>''{"pri","pat","A","229"}'' as pri_pat_a_0229,--プライミング補助間欠動作動作時間
  pm.device_set_info#>>''{"pri","pat","A","230"}'' as pri_pat_a_0230,--プライミング補助間欠動作停止時間
  pm.device_set_info#>>''{"pri","pat","A","232"}'' as pri_pat_a_0232,--自動プライミング落差時間
  pm.device_set_info#>>''{"pri","pat","A","238"}'' as pri_pat_a_0238,--自動プライミング総量
  pm.device_set_info#>>''{"pri","pat","A","231"}'' as pri_pat_a_0231,--自動プライミング開始時間
  pm.device_set_info#>>''{"pri","pat","A","233"}'' as pri_pat_a_0233,--自動プライミング送液液量
  pm.device_set_info#>>''{"pri","pat","A","234"}'' as pri_pat_a_0234,--自動プライミング送液流速1回目
  pm.device_set_info#>>''{"pri","pat","A","235"}'' as pri_pat_a_0235,--自動プライミング送液流速2回目以降
  pm.device_set_info#>>''{"pri","pat","A","236"}'' as pri_pat_a_0236,--自動プライミング循環流速
  pm.device_set_info#>>''{"pri","pat","A","237"}'' as pri_pat_a_0237,--自動プライミング循環時間
  pm.device_set_info#>>''{"pri","pat","B","51"}'' as pri_pat_b_0051,--オンラインプライミング_ダイアライザ気泡抜き時間_後補液
  pm.device_set_info#>>''{"pri","pat","B","32"}'' as pri_pat_b_0032,--オンラインプライミング_動脈チャンバ液面作成時間_前補液
  pm.device_set_info#>>''{"pri","pat","B","52"}'' as pri_pat_b_0052,--オンラインプライミング_動脈チャンバ液面作成時間_後補液
  pm.device_set_info#>>''{"pri","pat","B","33"}'' as pri_pat_b_0033,--オンラインプライミング_循環洗浄時間_前補液
  pm.device_set_info#>>''{"pri","pat","B","53"}'' as pri_pat_b_0053,--オンラインプライミング_循環洗浄時間_後補液
  pm.device_set_info#>>''{"war","dev","A","240"}'' as war_dev_a_0240,--TMP監視モード
  pm.device_set_info#>>''{"war","dev","A","100"}'' as war_dev_a_0100,--HD/ECUM静脈圧自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","101"}'' as war_dev_a_0101,--HD/ECUM静脈圧自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","102"}'' as war_dev_a_0102,--HD/ECUM静脈圧自動設定警報限界上限
  pm.device_set_info#>>''{"war","dev","A","103"}'' as war_dev_a_0103,--HD/ECUM静脈圧自動設定警報限界下限
  pm.device_set_info#>>''{"war","dev","A","104"}'' as war_dev_a_0104,--HD/ECUM静脈圧固定警報上限
  pm.device_set_info#>>''{"war","dev","A","105"}'' as war_dev_a_0105,--HD/ECUM静脈圧固定警報下限
  pm.device_set_info#>>''{"war","dev","A","152"}'' as war_dev_a_0152,--HD/ECUMダイアライザ入口圧自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","153"}'' as war_dev_a_0153,--HD/ECUMダイアライザ入口圧自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","154"}'' as war_dev_a_0154,--HD/ECUMダイアライザ入口圧自動設定警報限界上限
  pm.device_set_info#>>''{"war","dev","A","155"}'' as war_dev_a_0155,--HD/ECUMダイアライザ入口圧自動設定警報限界下限
  pm.device_set_info#>>''{"war","dev","A","156"}'' as war_dev_a_0156,--HD/ECUMダイアライザ入口圧固定警報上限
  pm.device_set_info#>>''{"war","dev","A","157"}'' as war_dev_a_0157,--HD/ECUMダイアライザ入口圧固定警報下限
  pm.device_set_info#>>''{"war","dev","A","112"}'' as war_dev_a_0112,--HD/ECUM液圧自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","113"}'' as war_dev_a_0113,--HD/ECUM液圧自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","114"}'' as war_dev_a_0114,--HD/ECUM液圧自動設定警報限界上限
  pm.device_set_info#>>''{"war","dev","A","115"}'' as war_dev_a_0115,--HD/ECUM液圧自動設定警報限界下限
  pm.device_set_info#>>''{"war","dev","A","116"}'' as war_dev_a_0116,--HD/ECUM液圧固定警報上限
  pm.device_set_info#>>''{"war","dev","A","117"}'' as war_dev_a_0117,--HD/ECUM液圧固定警報下限
  pm.device_set_info#>>''{"war","dev","A","128"}'' as war_dev_a_0128,--HD/ECUMTMP自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","129"}'' as war_dev_a_0129,--HD/ECUMTMP自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","130"}'' as war_dev_a_0130,--HD/ECUMTMP自動設定警報限界上限
  pm.device_set_info#>>''{"war","dev","A","131"}'' as war_dev_a_0131,--HD/ECUMTMP自動設定警報限界下限
  pm.device_set_info#>>''{"war","dev","A","132"}'' as war_dev_a_0132,--HD/ECUMTMP固定警報上限
  pm.device_set_info#>>''{"war","dev","A","133"}'' as war_dev_a_0133,--HD/ECUMTMP固定警報下限
  pm.device_set_info#>>''{"war","dev","A","126"}'' as war_dev_a_0126,--HD/ECUMTMP自動追従警報幅上限
  pm.device_set_info#>>''{"war","dev","A","127"}'' as war_dev_a_0127,--HD/ECUMTMP自動追従警報幅下限
  pm.device_set_info#>>''{"war","dev","A","146"}'' as war_dev_a_0146,--HD/ECUMダイアライザ差圧自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","147"}'' as war_dev_a_0147,--HD/ECUMダイアライザ差圧自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","148"}'' as war_dev_a_0148,--HD/ECUMダイアライザ差圧固定警報上限
  pm.device_set_info#>>''{"war","dev","A","149"}'' as war_dev_a_0149,--HD/ECUMダイアライザ差圧固定警報下限
  pm.device_set_info#>>''{"war","dev","A","106"}'' as war_dev_a_0106,--HDF/HF静脈圧自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","107"}'' as war_dev_a_0107,--HDF/HF静脈圧自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","158"}'' as war_dev_a_0158,--HDF/HFダイアライザ入口圧自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","159"}'' as war_dev_a_0159,--HDF/HFダイアライザ入口圧自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","118"}'' as war_dev_a_0118,--HDF/HF液圧自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","119"}'' as war_dev_a_0119,--HDF/HF液圧自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","136"}'' as war_dev_a_0136,--HDF/HFTMP自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","137"}'' as war_dev_a_0137,--HDF/HFTMP自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","134"}'' as war_dev_a_0134,--HDF/HFTMP自動追従警報幅上限
  pm.device_set_info#>>''{"war","dev","A","135"}'' as war_dev_a_0135,--HDF/HFTMP自動追従警報幅下限
  pm.device_set_info#>>''{"war","dev","A","150"}'' as war_dev_a_0150,--HDF/HFダイアライザ差圧自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","151"}'' as war_dev_a_0151,--HDF/HFダイアライザ差圧自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","110"}'' as war_dev_a_0110,--SN静脈圧固定警報上限
  pm.device_set_info#>>''{"war","dev","A","111"}'' as war_dev_a_0111,--SN静脈圧固定警報下限
  pm.device_set_info#>>''{"war","dev","A","162"}'' as war_dev_a_0162,--SNダイアライザ入口圧固定警報上限
  pm.device_set_info#>>''{"war","dev","A","163"}'' as war_dev_a_0163,--SNダイアライザ入口圧固定警報下限
  pm.device_set_info#>>''{"war","dev","A","120"}'' as war_dev_a_0120,--SN液圧自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","121"}'' as war_dev_a_0121,--SN液圧自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","122"}'' as war_dev_a_0122,--SN液圧自動設定警報限界上限
  pm.device_set_info#>>''{"war","dev","A","123"}'' as war_dev_a_0123,--SN液圧自動設定警報限界下限
  pm.device_set_info#>>''{"war","dev","A","124"}'' as war_dev_a_0124,--SN液圧固定警報上限
  pm.device_set_info#>>''{"war","dev","A","125"}'' as war_dev_a_0125,--SN液圧固定警報下限
  pm.device_set_info#>>''{"war","dev","A","140"}'' as war_dev_a_0140,--SNTMP自動設定警報幅上限
  pm.device_set_info#>>''{"war","dev","A","141"}'' as war_dev_a_0141,--SNTMP自動設定警報幅下限
  pm.device_set_info#>>''{"war","dev","A","142"}'' as war_dev_a_0142,--SNTMP自動設定警報限界上限
  pm.device_set_info#>>''{"war","dev","A","143"}'' as war_dev_a_0143,--SNTMP自動設定警報限界下限
  pm.device_set_info#>>''{"war","dev","A","144"}'' as war_dev_a_0144,--SNTMP固定警報上限
  pm.device_set_info#>>''{"war","dev","A","145"}'' as war_dev_a_0145,--SNTMP固定警報下限
  pm.device_set_info#>>''{"war","dev","A","138"}'' as war_dev_a_0138,--SNTMP自動追従警報幅上限
  pm.device_set_info#>>''{"war","dev","A","139"}'' as war_dev_a_0139,--SNTMP自動追従警報幅下限
  pm.device_set_info#>>''{"war","dev","A","108"}'' as war_dev_a_0108,--準備回収静脈圧固定警報上限
  pm.device_set_info#>>''{"war","dev","A","109"}'' as war_dev_a_0109,--準備回収静脈圧固定警報下限
  pm.device_set_info#>>''{"war","dev","A","160"}'' as war_dev_a_0160,--準備回収ダイアライザ入口圧固定警報上限
  pm.device_set_info#>>''{"war","dev","A","161"}'' as war_dev_a_0161,--準備回収ダイアライザ入口圧固定警報下限
  pm.device_set_info#>>''{"war","dev","A","254"}'' as war_dev_a_0254,--Na濃度自動警報幅上限値
  pm.device_set_info#>>''{"war","dev","A","255"}'' as war_dev_a_0255,--Na濃度自動警報幅下限値
  pm.device_set_info#>>''{"war","dev","A","256"}'' as war_dev_a_0256,--Na濃度固定警報幅上限値
  pm.device_set_info#>>''{"war","dev","A","257"}'' as war_dev_a_0257,--Na濃度固定警報幅下限値
  pm.device_set_info#>>''{"war","dev","A","242"}'' as war_dev_a_0242,--静脈圧自動設定警報監視有無
  pm.device_set_info#>>''{"war","dev","A","243"}'' as war_dev_a_0243,--ダイアライザー血液入口圧自動設定警報監視有無
  pm.device_set_info#>>''{"war","dev","A","244"}'' as war_dev_a_0244,--透析液圧自動設定警報監視有無
  pm.device_set_info#>>''{"war","dev","A","245"}'' as war_dev_a_0245,--ＴＭＰ自動設定警報監視有無
  pm.device_set_info#>>''{"war","dev","A","246"}'' as war_dev_a_0246,--差圧自動設定警報監視有無
  pm.device_set_info#>>''{"war","dev","A","247"}'' as war_dev_a_0247,--Ｎａ濃度自動設定警報監視有無
  pm.device_set_info#>>''{"lap","dev","A","468"}'' as lap_dev_a_0468,--VA確認報知基準値(静的静脈圧)
  pm.device_set_info#>>''{"lap","dev","A","469"}'' as lap_dev_a_0469,--VA確認報知基準値(アクセス内圧力比率)
  pm.device_set_info#>>''{"lap","dev","A","470"}'' as lap_dev_a_0470,--静的静脈圧記録 自動実施選択
  pm.device_set_info#>>''{"lap","dev","A","471"}'' as lap_dev_a_0471,--血圧測定 自動実施選択
  om.ind_device_set_info#>>''{"ihdf","dev","A","201"}'' as ihdf_dev_a_0201,--I-HDF_補液速度
  om.ind_device_set_info#>>''{"ihdf","dev","A","203"}'' as ihdf_dev_a_0203,--I-HDF_補液開始時間
  om.ind_device_set_info#>>''{"ihdf","dev","A","200"}'' as ihdf_dev_a_0200,--I-HDF_補液量設定
  om.ind_device_set_info#>>''{"ihdf","dev","A","204"}'' as ihdf_dev_a_0204,--I-HDF_除水再開時間
  om.ind_device_set_info#>>''{"ihdf","dev","A","202"}'' as ihdf_dev_a_0202,--I-HDF_補液周期
  om.ind_device_set_info#>>''{"ihdf","dev","A","205"}'' as ihdf_dev_a_0205,--I-HDF_総補液量上限
  om.ind_device_set_info#>>''{"ihdf","dev","A","432"}'' as ihdf_dev_a_0432,--I-HDFプログラム使用選択
  om.ind_device_set_info#>>''{"ihdf","dev","A","433"}'' as ihdf_dev_a_0433,--予定補液回数
  om.ind_device_set_info#>>''{"ihdf","dev","A","434"}'' as ihdf_dev_a_0434,--補液バランス制限
  om.ind_device_set_info#>>''{"ihdf","dev","A","435"}'' as ihdf_dev_a_0435,--補液量01
  om.ind_device_set_info#>>''{"ihdf","dev","A","436"}'' as ihdf_dev_a_0436,--補液量02
  om.ind_device_set_info#>>''{"ihdf","dev","A","437"}'' as ihdf_dev_a_0437,--補液量03
  om.ind_device_set_info#>>''{"ihdf","dev","A","438"}'' as ihdf_dev_a_0438,--補液量04
  om.ind_device_set_info#>>''{"ihdf","dev","A","439"}'' as ihdf_dev_a_0439,--補液量05
  om.ind_device_set_info#>>''{"ihdf","dev","A","440"}'' as ihdf_dev_a_0440,--補液量06
  om.ind_device_set_info#>>''{"ihdf","dev","A","441"}'' as ihdf_dev_a_0441,--補液量07
  om.ind_device_set_info#>>''{"ihdf","dev","A","442"}'' as ihdf_dev_a_0442,--補液量08
  om.ind_device_set_info#>>''{"ihdf","dev","A","443"}'' as ihdf_dev_a_0443,--補液量09
  om.ind_device_set_info#>>''{"ihdf","dev","A","444"}'' as ihdf_dev_a_0444,--補液量10
  om.ind_device_set_info#>>''{"ihdf","dev","A","445"}'' as ihdf_dev_a_0445,--補液量11
  om.ind_device_set_info#>>''{"ihdf","dev","A","446"}'' as ihdf_dev_a_0446,--補液量12
  om.ind_device_set_info#>>''{"ihdf","dev","A","447"}'' as ihdf_dev_a_0447,--補液量13
  om.ind_device_set_info#>>''{"ihdf","dev","A","448"}'' as ihdf_dev_a_0448,--補液量14
  om.ind_device_set_info#>>''{"ihdf","dev","A","449"}'' as ihdf_dev_a_0449,--補液量15
  om.ind_device_set_info#>>''{"ihdf","dev","A","450"}'' as ihdf_dev_a_0450,--補液量16
  om.ind_device_set_info#>>''{"ihdf","dev","A","451"}'' as ihdf_dev_a_0451,--回収量01
  om.ind_device_set_info#>>''{"ihdf","dev","A","452"}'' as ihdf_dev_a_0452,--回収量02
  om.ind_device_set_info#>>''{"ihdf","dev","A","453"}'' as ihdf_dev_a_0453,--回収量03
  om.ind_device_set_info#>>''{"ihdf","dev","A","454"}'' as ihdf_dev_a_0454,--回収量04
  om.ind_device_set_info#>>''{"ihdf","dev","A","455"}'' as ihdf_dev_a_0455,--回収量05
  om.ind_device_set_info#>>''{"ihdf","dev","A","456"}'' as ihdf_dev_a_0456,--回収量06
  om.ind_device_set_info#>>''{"ihdf","dev","A","457"}'' as ihdf_dev_a_0457,--回収量07
  om.ind_device_set_info#>>''{"ihdf","dev","A","458"}'' as ihdf_dev_a_0458,--回収量08
  om.ind_device_set_info#>>''{"ihdf","dev","A","459"}'' as ihdf_dev_a_0459,--回収量09
  om.ind_device_set_info#>>''{"ihdf","dev","A","460"}'' as ihdf_dev_a_0460,--回収量10
  om.ind_device_set_info#>>''{"ihdf","dev","A","461"}'' as ihdf_dev_a_0461,--回収量11
  om.ind_device_set_info#>>''{"ihdf","dev","A","462"}'' as ihdf_dev_a_0462,--回収量12
  om.ind_device_set_info#>>''{"ihdf","dev","A","463"}'' as ihdf_dev_a_0463,--回収量13
  om.ind_device_set_info#>>''{"ihdf","dev","A","464"}'' as ihdf_dev_a_0464,--回収量14
  om.ind_device_set_info#>>''{"ihdf","dev","A","465"}'' as ihdf_dev_a_0465,--回収量15
  om.ind_device_set_info#>>''{"ihdf","dev","A","466"}'' as ihdf_dev_a_0466,--回収量16
  om.ind_device_set_info#>>''{"qbqd","dev","A","430"}'' as qbqd_dev_a_0430,--QBプログラム電源
  om.ind_device_set_info#>>''{"qbqd","dev","A","429"}'' as qbqd_dev_a_0429,--QB、QDプログラム最大ステップ数
  om.ind_device_set_info#>>''{"qbqd","dev","A","400"}'' as qbqd_dev_a_0400,--QBプログラム血流量1
  om.ind_device_set_info#>>''{"qbqd","dev","A","401"}'' as qbqd_dev_a_0401,--QBプログラム血流量2
  om.ind_device_set_info#>>''{"qbqd","dev","A","402"}'' as qbqd_dev_a_0402,--QBプログラム血流量3
  om.ind_device_set_info#>>''{"qbqd","dev","A","403"}'' as qbqd_dev_a_0403,--QBプログラム血流量4
  om.ind_device_set_info#>>''{"qbqd","dev","A","404"}'' as qbqd_dev_a_0404,--QBプログラム血流量5
  om.ind_device_set_info#>>''{"qbqd","dev","A","405"}'' as qbqd_dev_a_0405,--QBプログラム血流量6
  om.ind_device_set_info#>>''{"qbqd","dev","A","406"}'' as qbqd_dev_a_0406,--QBプログラム血流量7
  om.ind_device_set_info#>>''{"qbqd","dev","A","407"}'' as qbqd_dev_a_0407,--QBプログラム血流量8
  om.ind_device_set_info#>>''{"qbqd","dev","A","408"}'' as qbqd_dev_a_0408,--QBプログラム血流量9
  om.ind_device_set_info#>>''{"qbqd","dev","A","409"}'' as qbqd_dev_a_0409,--QBプログラム血流量10
  om.ind_device_set_info#>>''{"qbqd","dev","A","431"}'' as qbqd_dev_a_0431,--QDプログラム電源
  om.ind_device_set_info#>>''{"qbqd","dev","A","410"}'' as qbqd_dev_a_0410,--QDプログラム透析液流量1
  om.ind_device_set_info#>>''{"qbqd","dev","A","411"}'' as qbqd_dev_a_0411,--QDプログラム透析液流量2
  om.ind_device_set_info#>>''{"qbqd","dev","A","412"}'' as qbqd_dev_a_0412,--QDプログラム透析液流量3
  om.ind_device_set_info#>>''{"qbqd","dev","A","413"}'' as qbqd_dev_a_0413,--QDプログラム透析液流量4
  om.ind_device_set_info#>>''{"qbqd","dev","A","414"}'' as qbqd_dev_a_0414,--QDプログラム透析液流量5
  om.ind_device_set_info#>>''{"qbqd","dev","A","415"}'' as qbqd_dev_a_0415,--QDプログラム透析液流量6
  om.ind_device_set_info#>>''{"qbqd","dev","A","416"}'' as qbqd_dev_a_0416,--QDプログラム透析液流量7
  om.ind_device_set_info#>>''{"qbqd","dev","A","417"}'' as qbqd_dev_a_0417,--QDプログラム透析液流量8
  om.ind_device_set_info#>>''{"qbqd","dev","A","418"}'' as qbqd_dev_a_0418,--QDプログラム透析液流量9
  om.ind_device_set_info#>>''{"qbqd","dev","A","419"}'' as qbqd_dev_a_0419,--QDプログラム透析液流量10
  om.ind_device_set_info#>>''{"qbqd","dev","A","420"}'' as qbqd_dev_a_0420,--QB、QDプログラム切替時間1
  om.ind_device_set_info#>>''{"qbqd","dev","A","421"}'' as qbqd_dev_a_0421,--QB、QDプログラム切替時間2
  om.ind_device_set_info#>>''{"qbqd","dev","A","422"}'' as qbqd_dev_a_0422,--QB、QDプログラム切替時間3
  om.ind_device_set_info#>>''{"qbqd","dev","A","423"}'' as qbqd_dev_a_0423,--QB、QDプログラム切替時間4
  om.ind_device_set_info#>>''{"qbqd","dev","A","424"}'' as qbqd_dev_a_0424,--QB、QDプログラム切替時間5
  om.ind_device_set_info#>>''{"qbqd","dev","A","425"}'' as qbqd_dev_a_0425,--QB、QDプログラム切替時間6
  om.ind_device_set_info#>>''{"qbqd","dev","A","426"}'' as qbqd_dev_a_0426,--QB、QDプログラム切替時間7
  om.ind_device_set_info#>>''{"qbqd","dev","A","427"}'' as qbqd_dev_a_0427,--QB、QDプログラム切替時間8
  om.ind_device_set_info#>>''{"qbqd","dev","A","428"}'' as qbqd_dev_a_0428,--QB、QDプログラム切替時間9
  om.ind_device_set_info#>>''{"ufr","dev","A","290"}'' as ufr_dev_a_0290,--ＵＦＲプログラム電源ＳＷ
  om.ind_device_set_info#>>''{"ufr","dev","A","311"}'' as ufr_dev_a_0311,--ＵＦＲプログラム最終位置
  om.ind_device_set_info#>>''{"ufr","dev","A","312"}'' as ufr_dev_a_0312,--ＵＦＲプログラムコース
  om.ind_device_set_info#>>''{"ufr","dev","A","291"}'' as ufr_dev_a_0291,--治療モード１
  om.ind_device_set_info#>>''{"ufr","dev","A","292"}'' as ufr_dev_a_0292,--治療モード２
  om.ind_device_set_info#>>''{"ufr","dev","A","293"}'' as ufr_dev_a_0293,--治療モード３
  om.ind_device_set_info#>>''{"ufr","dev","A","294"}'' as ufr_dev_a_0294,--治療モード４
  om.ind_device_set_info#>>''{"ufr","dev","A","295"}'' as ufr_dev_a_0295,--治療モード５
  om.ind_device_set_info#>>''{"ufr","dev","A","296"}'' as ufr_dev_a_0296,--治療モード６
  om.ind_device_set_info#>>''{"ufr","dev","A","297"}'' as ufr_dev_a_0297,--治療モード７
  om.ind_device_set_info#>>''{"ufr","dev","A","298"}'' as ufr_dev_a_0298,--治療モード８
  om.ind_device_set_info#>>''{"ufr","dev","A","299"}'' as ufr_dev_a_0299,--治療モード９
  om.ind_device_set_info#>>''{"ufr","dev","A","300"}'' as ufr_dev_a_0300,--治療モード１０
  om.ind_device_set_info#>>''{"ufr","dev","A","301"}'' as ufr_dev_a_0301,--ＵＦＲプログラム指数１
  om.ind_device_set_info#>>''{"ufr","dev","A","302"}'' as ufr_dev_a_0302,--ＵＦＲプログラム指数２
  om.ind_device_set_info#>>''{"ufr","dev","A","303"}'' as ufr_dev_a_0303,--ＵＦＲプログラム指数３
  om.ind_device_set_info#>>''{"ufr","dev","A","304"}'' as ufr_dev_a_0304,--ＵＦＲプログラム指数４
  om.ind_device_set_info#>>''{"ufr","dev","A","305"}'' as ufr_dev_a_0305,--ＵＦＲプログラム指数５
  om.ind_device_set_info#>>''{"ufr","dev","A","306"}'' as ufr_dev_a_0306,--ＵＦＲプログラム指数６
  om.ind_device_set_info#>>''{"ufr","dev","A","307"}'' as ufr_dev_a_0307,--ＵＦＲプログラム指数７
  om.ind_device_set_info#>>''{"ufr","dev","A","308"}'' as ufr_dev_a_0308,--ＵＦＲプログラム指数８
  om.ind_device_set_info#>>''{"ufr","dev","A","309"}'' as ufr_dev_a_0309,--ＵＦＲプログラム指数９
  om.ind_device_set_info#>>''{"ufr","dev","A","310"}'' as ufr_dev_a_0310,--ＵＦＲプログラム指数１０
  om.ind_device_set_info#>>''{"ufr","dev","A","313"}'' as ufr_dev_a_0313,--ＵＦＲプログラム開始数値
  om.ind_device_set_info#>>''{"ufr","dev","A","314"}'' as ufr_dev_a_0314,--ＵＦＲプログラム終了数値
  om.ind_device_set_info#>>''{"ufr","dev","B","0"}'' as ufr_dev_b_0000,--UFRプログラム工程1の指数
  om.ind_device_set_info#>>''{"ufr","dev","B","1"}'' as ufr_dev_b_0001,--UFRプログラム工程2の指数
  om.ind_device_set_info#>>''{"ufr","dev","B","2"}'' as ufr_dev_b_0002,--UFRプログラム工程3の指数
  om.ind_device_set_info#>>''{"ufr","dev","B","3"}'' as ufr_dev_b_0003,--UFRプログラム工程4の指数
  om.ind_device_set_info#>>''{"ufr","dev","B","4"}'' as ufr_dev_b_0004,--UFRプログラム工程5の指数
  om.ind_device_set_info#>>''{"ufr","dev","B","5"}'' as ufr_dev_b_0005,--UFRプログラム工程6の指数
  om.ind_device_set_info#>>''{"ufr","dev","B","6"}'' as ufr_dev_b_0006,--UFRプログラム工程7の指数
  om.ind_device_set_info#>>''{"ufr","dev","B","7"}'' as ufr_dev_b_0007,--UFRプログラム工程8の指数
  om.ind_device_set_info#>>''{"ufr","dev","B","8"}'' as ufr_dev_b_0008,--UFRプログラム工程9の指数
  om.ind_device_set_info#>>''{"ufr","dev","B","9"}'' as ufr_dev_b_0009,--UFRプログラム工程10の指数
  om.ind_device_set_info#>>''{"na","dev","A","315"}'' as na_dev_a_0315,--Na注入プログラム電源ＳＷ
  om.ind_device_set_info#>>''{"na","dev","A","326"}'' as na_dev_a_0326,--Na注入プログラム切替時間
  om.ind_device_set_info#>>''{"na","dev","A","328"}'' as na_dev_a_0328,--Na注入プログラムコース
  om.ind_device_set_info#>>''{"na","dev","A","327"}'' as na_dev_a_0327,--Na注入プログラム　ＵＦＲプロとの連動選択
  om.ind_device_set_info#>>''{"na","dev","A","316"}'' as na_dev_a_0316,--Na注入プログラム設定１
  om.ind_device_set_info#>>''{"na","dev","A","317"}'' as na_dev_a_0317,--Na注入プログラム設定２
  om.ind_device_set_info#>>''{"na","dev","A","318"}'' as na_dev_a_0318,--Na注入プログラム設定３
  om.ind_device_set_info#>>''{"na","dev","A","319"}'' as na_dev_a_0319,--Na注入プログラム設定４
  om.ind_device_set_info#>>''{"na","dev","A","320"}'' as na_dev_a_0320,--Na注入プログラム設定５
  om.ind_device_set_info#>>''{"na","dev","A","321"}'' as na_dev_a_0321,--Na注入プログラム設定６
  om.ind_device_set_info#>>''{"na","dev","A","322"}'' as na_dev_a_0322,--Na注入プログラム設定７
  om.ind_device_set_info#>>''{"na","dev","A","323"}'' as na_dev_a_0323,--Na注入プログラム設定８
  om.ind_device_set_info#>>''{"na","dev","A","324"}'' as na_dev_a_0324,--Na注入プログラム設定９
  om.ind_device_set_info#>>''{"na","dev","A","325"}'' as na_dev_a_0325,--Na注入プログラム設定１０
  om.ind_device_set_info#>>''{"na","dev","A","329"}'' as na_dev_a_0329,--Na注入プログラム開始数値
  om.ind_device_set_info#>>''{"na","dev","A","330"}'' as na_dev_a_0330,--Na注入プログラム終了数値
  om.ind_device_set_info#>>''{"na","dev","A","184"}'' as na_dev_a_0184,--Na注入濃度操作範囲上限
  om.ind_device_set_info#>>''{"bvufc","dev","A","196"}'' as bvufc_dev_a_0196,--BV-UFC使用選択
  om.ind_device_set_info#>>''{"bvufc","dev","A","197"}'' as bvufc_dev_a_0197,--UFC期間除水速度上限
  om.ind_device_set_info#>>''{"bvufc","dev","A","198"}'' as bvufc_dev_a_0198,--UFC期間除水速度下限
  om.ind_device_set_info#>>''{"bvufc","dev","A","199"}'' as bvufc_dev_a_0199,--開始期間 時間
  om.ind_device_set_info#>>''{"bvufc","dev","A","206"}'' as bvufc_dev_a_0206,--開始期間 除水速度倍率
  om.ind_device_set_info#>>''{"bvufc","dev","A","207"}'' as bvufc_dev_a_0207,--固定倍率除水期間 時間
  om.ind_device_set_info#>>''{"bvufc","dev","A","208"}'' as bvufc_dev_a_0208,--固定倍率除水期間 除水速度倍率
  om.ind_device_set_info#>>''{"bvufc","dev","A","209"}'' as bvufc_dev_a_0209,--固定倍率除水終了条件　最高血圧
  om.ind_device_set_info#>>''{"bvufc","dev","A","210"}'' as bvufc_dev_a_0210,--固定倍率除水終了条件　脈拍
  om.ind_device_set_info#>>''{"bvufc","dev","A","248"}'' as bvufc_dev_a_0248,--固定倍率除水終了条件　ΔBV
  om.ind_device_set_info#>>''{"bvufc","dev","A","249"}'' as bvufc_dev_a_0249,--終了前期間 時間
  om.ind_device_set_info#>>''{"bvufc","dev","A","271"}'' as bvufc_dev_a_0271,--開始時ΔBV基準値 
  om.ind_device_set_info#>>''{"bvufc","dev","A","272"}'' as bvufc_dev_a_0272,--ΔBV基準線　指数1
  om.ind_device_set_info#>>''{"bvufc","dev","A","273"}'' as bvufc_dev_a_0273,--ΔBV基準線　指数2
  om.ind_device_set_info#>>''{"bvufc","dev","A","274"}'' as bvufc_dev_a_0274,--ΔBV基準線　指数3
  om.ind_device_set_info#>>''{"bvufc","dev","A","275"}'' as bvufc_dev_a_0275,--終了時ΔBV基準値
  om.ind_device_set_info#>>''{"dia","dev","A","282"}'' as dia_dev_a_0282,--透析量プログラム使用選択
  om.ind_device_set_info#>>''{"dia","dev","A","288"}'' as dia_dev_a_0288,--目標Kt/V
  om.ind_device_set_info#>>''{"dia","dev","A","ord_no"}'' as dia_dev_a_ord_no,--検査日オーダ番号
  om.ind_device_set_info#>>''{"dc","dev","A","340"}'' as dc_dev_a_0340,--透析液濃度プログラム使用選択
  om.ind_device_set_info#>>''{"dc","dev","A","368"}'' as dc_dev_a_0368,--濃度プログラム　ＵＦＲプロとの連動選択
  om.ind_device_set_info#>>''{"dc","dev","A","367"}'' as dc_dev_a_0367,--濃度プログラム切替時間
  om.ind_device_set_info#>>''{"dc","dev","A","361"}'' as dc_dev_a_0361,--透析液濃度プログラムステップ切替無し　コース
  om.ind_device_set_info#>>''{"dc","dev","A","341"}'' as dc_dev_a_0341,--透析液濃度プログラム設定１
  om.ind_device_set_info#>>''{"dc","dev","A","342"}'' as dc_dev_a_0342,--透析液濃度プログラム設定２
  om.ind_device_set_info#>>''{"dc","dev","A","343"}'' as dc_dev_a_0343,--透析液濃度プログラム設定３
  om.ind_device_set_info#>>''{"dc","dev","A","344"}'' as dc_dev_a_0344,--透析液濃度プログラム設定４
  om.ind_device_set_info#>>''{"dc","dev","A","345"}'' as dc_dev_a_0345,--透析液濃度プログラム設定５
  om.ind_device_set_info#>>''{"dc","dev","A","346"}'' as dc_dev_a_0346,--透析液濃度プログラム設定６
  om.ind_device_set_info#>>''{"dc","dev","A","347"}'' as dc_dev_a_0347,--透析液濃度プログラム設定７
  om.ind_device_set_info#>>''{"dc","dev","A","348"}'' as dc_dev_a_0348,--透析液濃度プログラム設定８
  om.ind_device_set_info#>>''{"dc","dev","A","349"}'' as dc_dev_a_0349,--透析液濃度プログラム設定９
  om.ind_device_set_info#>>''{"dc","dev","A","350"}'' as dc_dev_a_0350,--透析液濃度プログラム設定１０
  om.ind_device_set_info#>>''{"dc","dev","A","362"}'' as dc_dev_a_0362,--透析液濃度プログラム開始数値
  om.ind_device_set_info#>>''{"dc","dev","A","363"}'' as dc_dev_a_0363,--透析液濃度プログラム終了数値
  om.ind_device_set_info#>>''{"dc","dev","A","364"}'' as dc_dev_a_0364,--Ｂ液濃度プログラムステップ切替無し　コース
  om.ind_device_set_info#>>''{"dc","dev","A","351"}'' as dc_dev_a_0351,--Ｂ液濃度プログラム設定１
  om.ind_device_set_info#>>''{"dc","dev","A","352"}'' as dc_dev_a_0352,--Ｂ液濃度プログラム設定２
  om.ind_device_set_info#>>''{"dc","dev","A","353"}'' as dc_dev_a_0353,--Ｂ液濃度プログラム設定３
  om.ind_device_set_info#>>''{"dc","dev","A","354"}'' as dc_dev_a_0354,--Ｂ液濃度プログラム設定４
  om.ind_device_set_info#>>''{"dc","dev","A","355"}'' as dc_dev_a_0355,--Ｂ液濃度プログラム設定５
  om.ind_device_set_info#>>''{"dc","dev","A","356"}'' as dc_dev_a_0356,--Ｂ液濃度プログラム設定６
  om.ind_device_set_info#>>''{"dc","dev","A","357"}'' as dc_dev_a_0357,--Ｂ液濃度プログラム設定７
  om.ind_device_set_info#>>''{"dc","dev","A","358"}'' as dc_dev_a_0358,--Ｂ液濃度プログラム設定８
  om.ind_device_set_info#>>''{"dc","dev","A","359"}'' as dc_dev_a_0359,--Ｂ液濃度プログラム設定９
  om.ind_device_set_info#>>''{"dc","dev","A","360"}'' as dc_dev_a_0360,--Ｂ液濃度プログラム設定１０
  om.ind_device_set_info#>>''{"dc","dev","A","365"}'' as dc_dev_a_0365,--Ｂ液濃度プログラム開始数値
  om.ind_device_set_info#>>''{"dc","dev","A","366"}'' as dc_dev_a_0366,--Ｂ液濃度プログラム終了数値
  om.ind_device_set_info#>>''{"dc","dev","B","20"}'' as dc_dev_b_0020,--A液濃度プログラム工程1のA液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","21"}'' as dc_dev_b_0021,--A液濃度プログラム工程2のA液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","22"}'' as dc_dev_b_0022,--A液濃度プログラム工程3のA液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","23"}'' as dc_dev_b_0023,--A液濃度プログラム工程4のA液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","24"}'' as dc_dev_b_0024,--A液濃度プログラム工程5のA液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","25"}'' as dc_dev_b_0025,--A液濃度プログラム工程6のA液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","26"}'' as dc_dev_b_0026,--A液濃度プログラム工程7のA液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","27"}'' as dc_dev_b_0027,--A液濃度プログラム工程8のA液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","28"}'' as dc_dev_b_0028,--A液濃度プログラム工程9のA液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","29"}'' as dc_dev_b_0029,--A液濃度プログラム工程10のA液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","10"}'' as dc_dev_b_0010,--B液濃度プログラム工程1のB液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","11"}'' as dc_dev_b_0011,--B液濃度プログラム工程2のB液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","12"}'' as dc_dev_b_0012,--B液濃度プログラム工程3のB液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","13"}'' as dc_dev_b_0013,--B液濃度プログラム工程4のB液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","14"}'' as dc_dev_b_0014,--B液濃度プログラム工程5のB液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","15"}'' as dc_dev_b_0015,--B液濃度プログラム工程6のB液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","16"}'' as dc_dev_b_0016,--B液濃度プログラム工程7のB液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","17"}'' as dc_dev_b_0017,--B液濃度プログラム工程8のB液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","18"}'' as dc_dev_b_0018,--B液濃度プログラム工程9のB液濃度
  om.ind_device_set_info#>>''{"dc","dev","B","19"}'' as dc_dev_b_0019--B液濃度プログラム工程10のB液濃度
  ,om.ind_device_set_info#>>''{"blood_flow","judge"}'' as blood_flow_judge --ホスト監視血流量監視フラグ
  ,om.ind_device_set_info#>>''{"blood_flow","upper"}'' as blood_flow_upper --ホスト監視血流量上限
  ,om.ind_device_set_info#>>''{"blood_flow","lower"}'' as blood_flow_lower --ホスト監視血流量下限
  ,om.ind_device_set_info#>>''{"ip_speed","judge"}'' as ip_speed_judge --ホスト監視IP速度監視フラグ
  ,om.ind_device_set_info#>>''{"ip_speed","upper"}'' as ip_speed_upper --ホスト監視IP速度上限
  ,om.ind_device_set_info#>>''{"ip_speed","lower"}'' as ip_speed_lower --ホスト監視IP速度下限
  ,om.ind_device_set_info#>>''{"ufr","judge"}'' as ufr_judge --ホスト監視除水速度監視フラグ
  ,om.ind_device_set_info#>>''{"ufr","upper"}'' as ufr_upper --ホスト監視除水速度上限
  ,om.ind_device_set_info#>>''{"ufr","lower"}'' as ufr_lower --ホスト監視除水速度下限
  ,om.ind_device_set_info#>>''{"bp_max","judge"}'' as bp_max_judge --ホスト監視最高血圧監視フラグ
  ,om.ind_device_set_info#>>''{"bp_max","upper"}'' as bp_max_upper --ホスト監視最高血圧上限
  ,om.ind_device_set_info#>>''{"bp_max","lower"}'' as bp_max_lower --ホスト監視最高血圧下限
  ,om.ind_device_set_info#>>''{"bp_min","judge"}'' as bp_min_judge --ホスト監視最低血圧監視フラグ
  ,om.ind_device_set_info#>>''{"bp_min","upper"}'' as bp_min_upper --ホスト監視最低血圧上限
  ,om.ind_device_set_info#>>''{"bp_min","lower"}'' as bp_min_lower --ホスト監視最低血圧下限
  ,om.ind_device_set_info#>>''{"bp_ave","judge"}'' as bp_ave_judge --ホスト監視平均血圧監視フラグ
  ,om.ind_device_set_info#>>''{"bp_ave","upper"}'' as bp_ave_upper --ホスト監視平均血圧上限
  ,om.ind_device_set_info#>>''{"bp_ave","lower"}'' as bp_ave_lower --ホスト監視平均血圧下限
  ,om.ind_device_set_info#>>''{"pulse","judge"}'' as pulse_judge --ホスト監視脈拍監視フラグ
  ,om.ind_device_set_info#>>''{"pulse","upper"}'' as pulse_upper --ホスト監視脈拍上限
  ,om.ind_device_set_info#>>''{"pulse","lower"}'' as pulse_lower --ホスト監視脈拍下限
  ,om.ind_device_set_info#>>''{"vp","judge"}'' as vp_judge --ホスト監視静脈圧監視フラグ
  ,om.ind_device_set_info#>>''{"vp","upper"}'' as vp_upper --ホスト監視静脈圧上限
  ,om.ind_device_set_info#>>''{"vp","lower"}'' as vp_lower --ホスト監視静脈圧下限
  ,om.ind_device_set_info#>>''{"ap","judge"}'' as ap_ave_judge --ホスト監視動脈圧監視フラグ
  ,om.ind_device_set_info#>>''{"ap","upper"}'' as ap_ave_upper --ホスト監視動脈圧上限
  ,om.ind_device_set_info#>>''{"ap","lower"}'' as ap_ave_lower --ホスト監視動脈圧下限
  ,om.ind_device_set_info#>>''{"na_conc","judge"}'' as na_conc_judge --ホスト監視Na濃度監視フラグ
  ,om.ind_device_set_info#>>''{"na_conc","upper"}'' as na_conc_upper --ホスト監視Na濃度上限
  ,om.ind_device_set_info#>>''{"na_conc","lower"}'' as na_conc_lower --ホスト監視Na濃度下限
  ,om.ind_device_set_info#>>''{"dialys_temp","judge"}'' as dialys_temp_judge --ホスト監視透析液温度監視フラグ
  ,om.ind_device_set_info#>>''{"dialys_temp","upper"}'' as dialys_temp_upper --ホスト監視透析液温度上限
  ,om.ind_device_set_info#>>''{"dialys_temp","lower"}'' as dialys_temp_lower --ホスト監視透析液温度下限
  ,om.ind_device_set_info#>>''{"care_i","judge"}'' as care_i_judge --ホスト監視血圧未測定時報知監視フラグ
  ,om.ind_device_set_info#>>''{"care_i","interval"}'' as care_i_interval --ホスト監視ケア報知
  
from
  pat_main pm
   inner join 
    (select
      pat_id,
      ind_device_set_info
    from
      ord_main
    where
      ord_no = @ordNo
      and is_del = ''0''
      and rst_dialysis_state = ''0''
    ) om ON pm.pat_id = om.pat_id
    and is_del = ''0''' WHERE "sql_cd" = 83;
    
UPDATE "ntss"."sys_data_set" SET "sql" = 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''1''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_date(event_start_date, ''YYYYMMDD'') AS event_start_date
  ,to_date(event_end_date, ''YYYYMMDD'') AS event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date
  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name
  ,picked_result_params[1]->>''result_value'' as data1 
  ,picked_result_params[2]->>''result_value'' as data2
  ,picked_result_params[3]->>''result_value'' as data3
  ,picked_result_params[4]->>''result_value'' as data4
  ,picked_result_params[5]->>''result_value'' as data5
  ,picked_result_params[6]->>''result_value'' as data6
  ,picked_result_params[7]->>''result_value'' as data7
  ,picked_result_params[8]->>''result_value'' as data8
  ,picked_result_params[9]->>''result_value'' as data9
  ,picked_result_params[10]->>''result_value'' as data10
from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
	ORDER BY event_start_date, reg_date
;' WHERE "sql_cd" = 85;
UPDATE "ntss"."sys_data_set" SET "sql" = 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    --and use_type = 2 and ord_no = @ordNo
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    --and use_type = 2 and ord_no = @ordNo
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    --and use_type = 2 and ord_no = @ordNo
    and use_type = 2 and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''3''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_date(event_start_date, ''YYYYMMDD'') AS event_start_date
  ,to_date(event_end_date, ''YYYYMMDD'') AS event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date
  
  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name
  ,picked_input_params[11]->>''field_name'' as data11_field_name
  ,picked_input_params[12]->>''field_name'' as data12_field_name
  ,picked_input_params[13]->>''field_name'' as data13_field_name
  ,picked_input_params[14]->>''field_name'' as data14_field_name
  ,picked_input_params[15]->>''field_name'' as data15_field_name
  ,picked_input_params[16]->>''field_name'' as data16_field_name
  ,picked_input_params[17]->>''field_name'' as data17_field_name
  ,picked_input_params[18]->>''field_name'' as data18_field_name
  ,picked_input_params[19]->>''field_name'' as data19_field_name
  ,picked_input_params[20]->>''field_name'' as data20_field_name
  ,picked_input_params[21]->>''field_name'' as data21_field_name
  ,picked_input_params[22]->>''field_name'' as data22_field_name
  ,picked_input_params[23]->>''field_name'' as data23_field_name
  ,picked_input_params[24]->>''field_name'' as data24_field_name
  ,picked_input_params[25]->>''field_name'' as data25_field_name
  ,picked_input_params[26]->>''field_name'' as data26_field_name
  ,picked_input_params[27]->>''field_name'' as data27_field_name
  ,picked_input_params[28]->>''field_name'' as data28_field_name
  ,picked_input_params[29]->>''field_name'' as data29_field_name
  ,picked_input_params[30]->>''field_name'' as data30_field_name

  ,picked_result_params[1]->''result_value''->>''name'' as data1_name
  ,picked_result_params[1]->''result_value''->>''score'' as data1_score
  ,picked_result_params[2]->''result_value''->>''name'' as data2_name
  ,picked_result_params[2]->''result_value''->>''score'' as data2_score
  ,picked_result_params[3]->''result_value''->>''name'' as data3_name
  ,picked_result_params[3]->''result_value''->>''score'' as data3_score
  ,picked_result_params[4]->''result_value''->>''name'' as data4_name
  ,picked_result_params[4]->''result_value''->>''score'' as data4_score
  ,picked_result_params[5]->''result_value''->>''name'' as data5_name
  ,picked_result_params[5]->''result_value''->>''score'' as data5_score
  ,picked_result_params[6]->''result_value''->>''name'' as data6_name
  ,picked_result_params[6]->''result_value''->>''score'' as data6_score
  ,picked_result_params[7]->''result_value''->>''name'' as data7_name
  ,picked_result_params[7]->''result_value''->>''score'' as data7_score
  ,picked_result_params[8]->''result_value''->>''name'' as data8_name
  ,picked_result_params[8]->''result_value''->>''score'' as data8_score
  ,picked_result_params[9]->''result_value''->>''name'' as data9_name
  ,picked_result_params[9]->''result_value''->>''score'' as data9_score
  ,picked_result_params[10]->''result_value''->>''name'' as data10_name
  ,picked_result_params[10]->''result_value''->>''score'' as data10_score
  ,picked_result_params[11]->''result_value''->>''name'' as data11_name
  ,picked_result_params[11]->''result_value''->>''score'' as data11_score
  ,picked_result_params[12]->''result_value''->>''name'' as data12_name
  ,picked_result_params[12]->''result_value''->>''score'' as data12_score
  ,picked_result_params[13]->''result_value''->>''name'' as data13_name
  ,picked_result_params[13]->''result_value''->>''score'' as data13_score
  ,picked_result_params[14]->''result_value''->>''name'' as data14_name
  ,picked_result_params[14]->''result_value''->>''score'' as data14_score
  ,picked_result_params[15]->''result_value''->>''name'' as data15_name
  ,picked_result_params[15]->''result_value''->>''score'' as data15_score
  ,picked_result_params[16]->''result_value''->>''name'' as data16_name
  ,picked_result_params[16]->''result_value''->>''score'' as data16_score
  ,picked_result_params[17]->''result_value''->>''name'' as data17_name
  ,picked_result_params[17]->''result_value''->>''score'' as data17_score
  ,picked_result_params[18]->''result_value''->>''name'' as data18_name
  ,picked_result_params[18]->''result_value''->>''score'' as data18_score
  ,picked_result_params[19]->''result_value''->>''name'' as data19_name
  ,picked_result_params[19]->''result_value''->>''score'' as data19_score
  ,picked_result_params[20]->''result_value''->>''name'' as data20_name
  ,picked_result_params[20]->''result_value''->>''score'' as data20_score
  ,picked_result_params[21]->''result_value''->>''name'' as data21_name
  ,picked_result_params[21]->''result_value''->>''score'' as data21_score
  ,picked_result_params[22]->''result_value''->>''name'' as data22_name
  ,picked_result_params[22]->''result_value''->>''score'' as data22_score
  ,picked_result_params[23]->''result_value''->>''name'' as data23_name
  ,picked_result_params[23]->''result_value''->>''score'' as data23_score
  ,picked_result_params[24]->''result_value''->>''name'' as data24_name
  ,picked_result_params[24]->''result_value''->>''score'' as data24_score
  ,picked_result_params[25]->''result_value''->>''name'' as data25_name
  ,picked_result_params[25]->''result_value''->>''score'' as data25_score
  ,picked_result_params[26]->''result_value''->>''name'' as data26_name
  ,picked_result_params[26]->''result_value''->>''score'' as data26_score
  ,picked_result_params[27]->''result_value''->>''name'' as data27_name
  ,picked_result_params[27]->''result_value''->>''score'' as data27_score
  ,picked_result_params[28]->''result_value''->>''name'' as data28_name
  ,picked_result_params[28]->''result_value''->>''score'' as data28_score
  ,picked_result_params[29]->''result_value''->>''name'' as data29_name
  ,picked_result_params[29]->''result_value''->>''score'' as data29_score
  ,picked_result_params[30]->''result_value''->>''name'' as data30_name
  ,picked_result_params[30]->''result_value''->>''score'' as data30_score

from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
	ORDER BY event_start_date, reg_date
;' WHERE "sql_cd" = 87;

UPDATE "ntss"."sys_data_set" SET "sql" = 'with input_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,input_param
  from
    pat_event
    cross join lateral jsonb_array_elements(input_params) with ordinality as tmp(input_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
)
, result_params_expand as
(
  select
    pat_event_cd
    ,json_idx
    ,result_param
  from
    pat_event
    cross join lateral jsonb_array_elements(result_params) with ordinality as tmp(result_param, json_idx)
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
)
, pe_basicinfo as
(
  select
    pat_event_cd
    ,event_start_date
    ,event_end_date
    ,category_name
    ,sub_category_name
    ,reg_staff_info->>''reg_staff_name'' as reg_staff_name
    ,reg_date
    ,up_staff_info->>''up_staff_name'' as up_staff_name
    ,up_date
  from
    pat_event
  where
    is_del = ''0''
    and pat_id = @patId and cast(event_start_date as date) between to_date(@fromDate, ''YYYY/MM/DD'') and to_date(@toDate, ''YYYY/MM/DD'')
)
, pe_picked as
(
  select
    ipe.pat_event_cd
    ,ipe.json_idx
    ,input_param
    ,result_param
  from
    input_params_expand as ipe
    inner join result_params_expand as rpe
      on ipe.pat_event_cd = rpe.pat_event_cd and ipe.json_idx = rpe.json_idx
  where
    input_param->>''format_class'' = ''4''
)
, pe_array_agg as
(
  select
    pat_event_cd
    ,array_agg(input_param order by json_idx) as picked_input_params
    ,array_agg(result_param order by json_idx) as picked_result_params
  from
    pe_picked
  group by pat_event_cd
)

select
  pe_array_agg.pat_event_cd
  ,to_date(event_start_date, ''YYYYMMDD'') AS event_start_date
  ,to_date(event_end_date, ''YYYYMMDD'') AS event_end_date
  ,category_name
  ,sub_category_name
  ,reg_staff_name
  ,reg_date
  ,up_staff_name
  ,up_date
  
  ,picked_input_params[1]->>''field_name'' as data1_field_name
  ,picked_input_params[2]->>''field_name'' as data2_field_name
  ,picked_input_params[3]->>''field_name'' as data3_field_name
  ,picked_input_params[4]->>''field_name'' as data4_field_name
  ,picked_input_params[5]->>''field_name'' as data5_field_name
  ,picked_input_params[6]->>''field_name'' as data6_field_name
  ,picked_input_params[7]->>''field_name'' as data7_field_name
  ,picked_input_params[8]->>''field_name'' as data8_field_name
  ,picked_input_params[9]->>''field_name'' as data9_field_name
  ,picked_input_params[10]->>''field_name'' as data10_field_name
  ,picked_input_params[11]->>''field_name'' as data11_field_name
  ,picked_input_params[12]->>''field_name'' as data12_field_name
  ,picked_input_params[13]->>''field_name'' as data13_field_name
  ,picked_input_params[14]->>''field_name'' as data14_field_name
  ,picked_input_params[15]->>''field_name'' as data15_field_name
  ,picked_input_params[16]->>''field_name'' as data16_field_name
  ,picked_input_params[17]->>''field_name'' as data17_field_name
  ,picked_input_params[18]->>''field_name'' as data18_field_name
  ,picked_input_params[19]->>''field_name'' as data19_field_name
  ,picked_input_params[20]->>''field_name'' as data20_field_name
  ,picked_input_params[21]->>''field_name'' as data21_field_name
  ,picked_input_params[22]->>''field_name'' as data22_field_name
  ,picked_input_params[23]->>''field_name'' as data23_field_name
  ,picked_input_params[24]->>''field_name'' as data24_field_name
  ,picked_input_params[25]->>''field_name'' as data25_field_name
  ,picked_input_params[26]->>''field_name'' as data26_field_name
  ,picked_input_params[27]->>''field_name'' as data27_field_name
  ,picked_input_params[28]->>''field_name'' as data28_field_name
  ,picked_input_params[29]->>''field_name'' as data29_field_name
  ,picked_input_params[30]->>''field_name'' as data30_field_name

  ,picked_result_params[1]->''result_value''->>''name'' as data1_name
  ,picked_result_params[1]->''result_value''->>''score'' as data1_score
  ,picked_result_params[2]->''result_value''->>''name'' as data2_name
  ,picked_result_params[2]->''result_value''->>''score'' as data2_score
  ,picked_result_params[3]->''result_value''->>''name'' as data3_name
  ,picked_result_params[3]->''result_value''->>''score'' as data3_score
  ,picked_result_params[4]->''result_value''->>''name'' as data4_name
  ,picked_result_params[4]->''result_value''->>''score'' as data4_score
  ,picked_result_params[5]->''result_value''->>''name'' as data5_name
  ,picked_result_params[5]->''result_value''->>''score'' as data5_score
  ,picked_result_params[6]->''result_value''->>''name'' as data6_name
  ,picked_result_params[6]->''result_value''->>''score'' as data6_score
  ,picked_result_params[7]->''result_value''->>''name'' as data7_name
  ,picked_result_params[7]->''result_value''->>''score'' as data7_score
  ,picked_result_params[8]->''result_value''->>''name'' as data8_name
  ,picked_result_params[8]->''result_value''->>''score'' as data8_score
  ,picked_result_params[9]->''result_value''->>''name'' as data9_name
  ,picked_result_params[9]->''result_value''->>''score'' as data9_score
  ,picked_result_params[10]->''result_value''->>''name'' as data10_name
  ,picked_result_params[10]->''result_value''->>''score'' as data10_score
  ,picked_result_params[11]->''result_value''->>''name'' as data11_name
  ,picked_result_params[11]->''result_value''->>''score'' as data11_score
  ,picked_result_params[12]->''result_value''->>''name'' as data12_name
  ,picked_result_params[12]->''result_value''->>''score'' as data12_score
  ,picked_result_params[13]->''result_value''->>''name'' as data13_name
  ,picked_result_params[13]->''result_value''->>''score'' as data13_score
  ,picked_result_params[14]->''result_value''->>''name'' as data14_name
  ,picked_result_params[14]->''result_value''->>''score'' as data14_score
  ,picked_result_params[15]->''result_value''->>''name'' as data15_name
  ,picked_result_params[15]->''result_value''->>''score'' as data15_score
  ,picked_result_params[16]->''result_value''->>''name'' as data16_name
  ,picked_result_params[16]->''result_value''->>''score'' as data16_score
  ,picked_result_params[17]->''result_value''->>''name'' as data17_name
  ,picked_result_params[17]->''result_value''->>''score'' as data17_score
  ,picked_result_params[18]->''result_value''->>''name'' as data18_name
  ,picked_result_params[18]->''result_value''->>''score'' as data18_score
  ,picked_result_params[19]->''result_value''->>''name'' as data19_name
  ,picked_result_params[19]->''result_value''->>''score'' as data19_score
  ,picked_result_params[20]->''result_value''->>''name'' as data20_name
  ,picked_result_params[20]->''result_value''->>''score'' as data20_score
  ,picked_result_params[21]->''result_value''->>''name'' as data21_name
  ,picked_result_params[21]->''result_value''->>''score'' as data21_score
  ,picked_result_params[22]->''result_value''->>''name'' as data22_name
  ,picked_result_params[22]->''result_value''->>''score'' as data22_score
  ,picked_result_params[23]->''result_value''->>''name'' as data23_name
  ,picked_result_params[23]->''result_value''->>''score'' as data23_score
  ,picked_result_params[24]->''result_value''->>''name'' as data24_name
  ,picked_result_params[24]->''result_value''->>''score'' as data24_score
  ,picked_result_params[25]->''result_value''->>''name'' as data25_name
  ,picked_result_params[25]->''result_value''->>''score'' as data25_score
  ,picked_result_params[26]->''result_value''->>''name'' as data26_name
  ,picked_result_params[26]->''result_value''->>''score'' as data26_score
  ,picked_result_params[27]->''result_value''->>''name'' as data27_name
  ,picked_result_params[27]->''result_value''->>''score'' as data27_score
  ,picked_result_params[28]->''result_value''->>''name'' as data28_name
  ,picked_result_params[28]->''result_value''->>''score'' as data28_score
  ,picked_result_params[29]->''result_value''->>''name'' as data29_name
  ,picked_result_params[29]->''result_value''->>''score'' as data29_score
  ,picked_result_params[30]->''result_value''->>''name'' as data30_name
  ,picked_result_params[30]->''result_value''->>''score'' as data30_score

from
  pe_array_agg
  inner join pe_basicinfo on pe_array_agg.pat_event_cd = pe_basicinfo.pat_event_cd
	ORDER BY event_start_date, reg_date
;' WHERE "sql_cd" = 88;

UPDATE "ntss"."sys_data_set" SET "sql" = 'select

monitor_data->>''1'' as mon1 -- 経過時間
,monitor_data->>''2'' as mon2 -- 経過時間（ＥＣＵＭ）
,monitor_data->>''3'' as mon3 -- 残り時間（除水完了）
,monitor_data->>''4'' as mon4 -- 残り時間（透析完了）
,monitor_data->>''5'' as mon5 -- 除水積算値
,monitor_data->>''6'' as mon6 -- 除水速度
,monitor_data->>''7'' as mon7 -- 血液循環量
,monitor_data->>''8'' as mon8 -- 血流量
,monitor_data->>''9'' as mon9 -- ＩＰ総量
,monitor_data->>''10'' as mon10 -- ＩＰ速度
,monitor_data->>''11'' as mon11 -- 静脈圧
,monitor_data->>''12'' as mon12 -- 透析液圧
,monitor_data->>''13'' as mon13 -- TMP
,monitor_data->>''14'' as mon14 -- ダイアライザ入口圧
,monitor_data->>''15'' as mon15 -- ダイアライザ差圧
,monitor_data->>''16'' as mon16 -- 血液入口～静脈平均圧
,monitor_data->>''17'' as mon17 -- ⊿BV
,monitor_data->>''18'' as mon18 -- バイカーボ濃度
,monitor_data->>''19'' as mon19 -- 透析液濃度
,monitor_data->>''20'' as mon20 -- Ｎａ濃度
,monitor_data->>''21'' as mon21 -- 透析液温度
,monitor_data->>''22'' as mon22 -- 透析液流量
,monitor_data->>''23'' as mon23 -- 漏血量
,monitor_data->>''24'' as mon24 -- 給液圧（上限）
,monitor_data->>''25'' as mon25 -- 給液圧（下限）
,monitor_data->>''26'' as mon26 -- ＵＦＲ
,monitor_data->>''27'' as mon27 -- ＵＦＲ低下率
,monitor_data->>''28'' as mon28 -- 初期ＵＦＲ測定値
,monitor_data->>''29'' as mon29 -- TMP補正値
,monitor_data->>''30'' as mon30 -- 透析運転時間
,monitor_data->>''31'' as mon31 -- 治療モード
,monitor_data->>''32'' as mon32 -- 除水目標値
,monitor_data->>''33'' as mon33 -- 除水速度設定値
,monitor_data->>''34'' as mon34 -- 透析液温度設定値
,monitor_data->>''35'' as mon35 -- 透析液流量設定値
,monitor_data->>''36'' as mon36 -- 血流量設定値
,monitor_data->>''37'' as mon37 -- ＩＰ速度設定
,monitor_data->>''39'' as mon39 -- 静脈圧警報点（上限）
,monitor_data->>''40'' as mon40 -- 静脈圧警報点（下限）
,monitor_data->>''41'' as mon41 -- 透析液圧警報点（上限）
,monitor_data->>''42'' as mon42 -- 透析液圧警報点（下限）
,monitor_data->>''43'' as mon43 -- TMP警報点（上限）
,monitor_data->>''44'' as mon44 -- TMP警報点（下限）
,monitor_data->>''45'' as mon45 -- ダイアライザ入口圧警報点（上限）
,monitor_data->>''46'' as mon46 -- ダイアライザ入口圧警報点（下限）
,monitor_data->>''47'' as mon47 -- ダイアライザ差圧警報点（上限）
,monitor_data->>''48'' as mon48 -- ダイアライザ差圧警報点（下限）
,monitor_data->>''49'' as mon49 -- ⊿ＢＶ低下警報点1
,monitor_data->>''50'' as mon50 -- ⊿ＢＶ低下警報点2
,monitor_data->>''51'' as mon51 -- ⊿BV変化率警報点
,monitor_data->>''54'' as mon54 -- バイカーボ濃度警報点（上限）
,monitor_data->>''55'' as mon55 -- バイカーボ濃度警報点（下限）
,monitor_data->>''56'' as mon56 -- 透析液濃度警報点（上限）
,monitor_data->>''57'' as mon57 -- 透析液濃度警報点（下限）
,monitor_data->>''58'' as mon58 -- Ｎａ濃度警報点（上限）
,monitor_data->>''59'' as mon59 -- Ｎａ濃度警報点（下限）
,monitor_data->>''60'' as mon60 -- 透析液温度警報点（上限）
,monitor_data->>''61'' as mon61 -- 透析液温度警報点（下限）
,monitor_data->>''62'' as mon62 -- 漏血量警報
,monitor_data->>''63'' as mon63 -- 給水圧警報点（上限）
,monitor_data->>''64'' as mon64 -- 給水圧警報点（下限）
,monitor_data->>''65'' as mon65 -- 初期ＵＦＲ警報点（上限）
,monitor_data->>''66'' as mon66 -- 初期ＵＦＲ警報点（下限）
,monitor_data->>''67'' as mon67 -- ＵＦＲ低下率警報
,monitor_data->>''68'' as mon68 -- Kt/V
,monitor_data->>''69'' as mon69 -- 運転中の血流量積算値
,monitor_data->>''70'' as mon70 -- 補液量設定値
,monitor_data->>''71'' as mon71 -- 補液速度
,monitor_data->>''72'' as mon72 -- 補液量現在値
,monitor_data->>''73'' as mon73 -- 補液速度設定値
,monitor_data->>''74'' as mon74 -- 補液温度
,monitor_data->>''75'' as mon75 -- 補液温度設定値
,monitor_data->>''76'' as mon76 -- 濾液速度
,monitor_data->>''77'' as mon77 -- 荷重計
,monitor_data->>''78'' as mon78 -- 残り時間（補液完了）
,monitor_data->>''80'' as mon80 -- ⊿ＢＶ変化率
,monitor_data->>''85'' as mon85 -- ⊿BVリファレンスエリア上限
,monitor_data->>''86'' as mon86 -- ⊿BVリファレンスエリア下限
,monitor_data->>''88'' as mon88 -- PRR
,monitor_data->>''89'' as mon89 -- 再循環率測定結果（BVMS連携用）
,monitor_data->>''90'' as mon90 -- 最高血圧
,monitor_data->>''91'' as mon91 -- 最低血圧
,monitor_data->>''92'' as mon92 -- 平均血圧
,monitor_data->>''93'' as mon93 -- 脈拍
,monitor_data->>''94'' as mon94 -- 体温
,monitor_data->>''95'' as mon95 -- ⊿ＢＶ_5分平均値
,monitor_data->>''96'' as mon96 -- ⊿ＢＶ_最大最小を除いた5分平均値
,monitor_data->>''97'' as mon97 -- 推定血流量
,monitor_data->>''98'' as mon98 -- 血流量不足率

,monitor_data->>''38'' as mon38 -- Kt/V測定値
,monitor_data->>''79'' as mon79 -- URR
,monitor_data->>''100'' as mon100 -- ⊿BV(BVplus)
,monitor_data->>''101'' as mon101 -- Ht
,monitor_data->>''102'' as mon102 -- LDQb

,monitor_data->>''Z11'' as monZ1sigma -- 治療モード(Σ)
,monitor_data->>''Z21'' as monZ2sigma -- 工程状態(Σ)
,monitor_data->>''Z31'' as monZ3sigma -- 除水速度(Σ)
,monitor_data->>''Z41'' as monZ4sigma -- 血液流量(Σ)
,monitor_data->>''Z51'' as monZ5sigma -- シリンジ流量(Σ)
,monitor_data->>''Z61'' as monZ6sigma -- ろ過流量(Σ)
,monitor_data->>''Z71'' as monZ7sigma -- 透析液/ドレン流量(Σ)
,monitor_data->>''Z81'' as monZ8sigma -- 補液流量(Σ)
,monitor_data->>''Z91'' as monZ9sigma -- 透析液加温器温度(Σ)
,monitor_data->>''Z101'' as monZ10sigma -- 補液加温器温度(Σ)
,monitor_data->>''Z111'' as monZ11sigma -- 現在 除水量(Σ)
,monitor_data->>''Z121'' as monZ12sigma -- 現在 血液循環量(Σ)
,monitor_data->>''Z131'' as monZ13sigma -- 現在 ろ過量(Σ)
,monitor_data->>''Z141'' as monZ14sigma -- 現在 透析液/ドレン量(Σ)
,monitor_data->>''Z151'' as monZ15sigma -- 現在 補液量(Σ)
,monitor_data->>''Z161'' as monZ16sigma -- 治療時間(Σ)
,monitor_data->>''Z171'' as monZ17sigma -- シリンジ積算量(Σ)
,monitor_data->>''Z181'' as monZ18sigma -- 目標 除水量(Σ)
,monitor_data->>''Z191'' as monZ19sigma -- 目標 血液循環量(Σ)
,monitor_data->>''Z201'' as monZ20sigma -- 目標 ろ過量(Σ)
,monitor_data->>''Z211'' as monZ21sigma -- 目標 透析液/ドレン量(Σ)
,monitor_data->>''Z221'' as monZ22sigma -- 目標 補液量(Σ)
,monitor_data->>''Z231'' as monZ23sigma -- 目標 治療時間(Σ)
,monitor_data->>''Z241'' as monZ24sigma -- 脱血圧(Σ)
,monitor_data->>''Z251'' as monZ25sigma -- 入口圧(Σ)
,monitor_data->>''Z261'' as monZ26sigma -- 静脈圧(Σ)
,monitor_data->>''Z271'' as monZ27sigma -- ろ過圧(Σ)
,monitor_data->>''Z281'' as monZ28sigma -- 排気圧/2次膜圧(Σ)
,monitor_data->>''Z291'' as monZ29sigma -- TMP/TMP1(Σ)
,monitor_data->>''Z301'' as monZ30sigma -- TMP2(Σ)
,monitor_data->>''Z311'' as monZ31sigma -- 差圧(Σ)
,monitor_data->>''Z321'' as monZ32sigma -- 気泡検知警報(Σ)
,monitor_data->>''Z331'' as monZ33sigma -- 漏血警報(Σ)
,monitor_data->>''Z341'' as monZ34sigma -- 加温器警報(Σ)
,monitor_data->>''Z351'' as monZ35sigma -- 脱血圧警報(Σ)
,monitor_data->>''Z361'' as monZ36sigma -- 入口圧警報(Σ)
,monitor_data->>''Z371'' as monZ37sigma -- 静脈圧警報(Σ)
,monitor_data->>''Z381'' as monZ38sigma -- ろ過圧警報(Σ)
,monitor_data->>''Z391'' as monZ39sigma -- 排気圧/2次膜圧警報(Σ)
,monitor_data->>''Z401'' as monZ40sigma -- TMP警報(Σ)
,monitor_data->>''Z411'' as monZ41sigma -- TMP2警報(Σ)
,monitor_data->>''Z421'' as monZ42sigma -- 差圧警報(Σ)
,monitor_data->>''Z431'' as monZ43sigma -- その他警報(Σ)

,monitor_data->>''Z12'' as monZ1km -- 測定値 TMP(KM)
,monitor_data->>''Z22'' as monZ2km -- 測定値 入口圧(KM)
,monitor_data->>''Z32'' as monZ3km -- 測定値 返血圧(KM)
,monitor_data->>''Z42'' as monZ4km -- 測定値 2次膜圧（吸着圧）(KM)
,monitor_data->>''Z52'' as monZ5km -- 圧力上限警報設定値 TMP(KM)
,monitor_data->>''Z62'' as monZ6km -- 圧力上限警報設定値 入口圧(KM)
,monitor_data->>''Z72'' as monZ7km -- 圧力上限警報設定値 返血圧(KM)
,monitor_data->>''Z82'' as monZ8km -- 圧力上限警報設定値 2次膜圧（吸着圧）(KM)
,monitor_data->>''Z92'' as monZ9km -- 流量情報 BP瞬時流量(KM)
,monitor_data->>''Z102'' as monZ10km -- 流量情報 PP瞬時流量(KM)
,monitor_data->>''Z112'' as monZ11km -- 流量情報 DP瞬時流量(KM)
,monitor_data->>''Z122'' as monZ12km -- 流量情報 BP積算流量(KM)
,monitor_data->>''Z132'' as monZ13km -- 流量情報 PP積算流量(KM)
,monitor_data->>''Z142'' as monZ14km -- 流量情報 DP積算流量(KM)
,monitor_data->>''Z152'' as monZ15km -- 流量情報 除水積算流量(KM)
,monitor_data->>''Z162'' as monZ16km -- 流量情報 血漿処理目標値(KM)
,monitor_data->>''Z172'' as monZ17km -- その他情報 加温器温度(KM)
,monitor_data->>''Z182'' as monZ18km -- その他情報 バランス(KM)
,monitor_data->>''Z192'' as monZ19km -- その他情報 経過時間(KM)
,monitor_data->>''Z202'' as monZ20km -- その他情報 アラーム番号(KM)
,monitor_data->>''Z212'' as monZ21km -- その他情報 自己診断番号(KM)
,monitor_data->>''Z222'' as monZ22km -- その他情報 モード(KM)
,monitor_data->>''Z232'' as monZ23km -- その他情報 工程情報(KM)

,monitor_data->>''Z13'' as monZ1iq -- 治療経過時間(iQ)
,monitor_data->>''Z23'' as monZ2iq -- 除水速度(iQ)
,monitor_data->>''Z33'' as monZ3iq -- ろ過ポンプ流量(iQ)
,monitor_data->>''Z43'' as monZ4iq -- 補液ポンプ流量(iQ)
,monitor_data->>''Z53'' as monZ5iq -- 透析ポンプ流量(iQ)
,monitor_data->>''Z63'' as monZ6iq -- 血液ポンプ流量(iQ)
,monitor_data->>''Z73'' as monZ7iq -- シリンジポンプ流量(iQ)
,monitor_data->>''Z83'' as monZ8iq -- 除水量積算値(iQ)
,monitor_data->>''Z93'' as monZ9iq -- ろ過量積算値(iQ)
,monitor_data->>''Z103'' as monZ10iq -- 補液量積算値(iQ)
,monitor_data->>''Z113'' as monZ11iq -- 透析液量積算値(iQ)
,monitor_data->>''Z123'' as monZ12iq -- 血液循環量(iQ)
,monitor_data->>''Z133'' as monZ13iq -- シリンジポンプ積算値(iQ)
,monitor_data->>''Z143'' as monZ14iq -- 採血圧(iQ)
,monitor_data->>''Z153'' as monZ15iq -- 動脈圧(iQ)
,monitor_data->>''Z163'' as monZ16iq -- 静脈圧(iQ)
,monitor_data->>''Z173'' as monZ17iq -- ろ過圧(iQ)
,monitor_data->>''Z183'' as monZ18iq -- TMP(iQ)
,monitor_data->>''Z193'' as monZ19iq -- 分離ポンプ流量(iQ)
,monitor_data->>''Z203'' as monZ20iq -- 返漿ポンプ流量(iQ)
,monitor_data->>''Z213'' as monZ21iq -- ドレンポンプ流量(iQ)
,monitor_data->>''Z223'' as monZ22iq -- 分離量積算値(iQ)
,monitor_data->>''Z233'' as monZ23iq -- 返漿量積算値(iQ)
,monitor_data->>''Z243'' as monZ24iq -- ドレン量積算値(iQ)
,monitor_data->>''Z253'' as monZ25iq -- 血漿圧(iQ)
,monitor_data->>''Z263'' as monZ26iq -- 血漿入口圧(iQ)

,monitor_data->>''Z14'' as monZ1km90 -- 測定値 TMP圧(KM90)
,monitor_data->>''Z24'' as monZ2km90 -- 測定値 入口圧(KM90)
,monitor_data->>''Z34'' as monZ3km90 -- 測定値 返血圧(KM90)
,monitor_data->>''Z44'' as monZ4km90 -- 測定値 ろ過圧(KM90)
,monitor_data->>''Z54'' as monZ5km90 -- 測定値 浄化器圧(KM90)
,monitor_data->>''Z64'' as monZ6km90 -- 設定値 TMP圧(KM90)
,monitor_data->>''Z74'' as monZ7km90 -- 設定値 入口圧(KM90)
,monitor_data->>''Z84'' as monZ8km90 -- 設定値 返血圧・上限(KM90)
,monitor_data->>''Z94'' as monZ9km90 -- 設定値 返血圧・下限(KM90)
,monitor_data->>''Z104'' as monZ10km90 -- 設定値 浄化器圧(KM90)
,monitor_data->>''Z114'' as monZ11km90 -- 設定値 除水設定値(KM90)
,monitor_data->>''Z124'' as monZ12km90 -- 流量情報 血液ﾎﾟﾝﾌﾟ指令流量(KM90)
,monitor_data->>''Z134'' as monZ13km90 -- 流量情報 透析液ﾎﾟﾝﾌﾟ指令流量(KM90)
,monitor_data->>''Z144'' as monZ14km90 -- 流量情報 補充液ﾎﾟﾝﾌﾟ指令流量(KM90)
,monitor_data->>''Z154'' as monZ15km90 -- 流量情報 ろ液ﾎﾟﾝﾌﾟ指令流量(KM90)
,monitor_data->>''Z164'' as monZ16km90 -- 流量情報 血液ﾎﾟﾝﾌﾟ積算流量(KM90)
,monitor_data->>''Z174'' as monZ17km90 -- 流量情報 透析液ﾎﾟﾝﾌﾟ積算流量(KM90)
,monitor_data->>''Z184'' as monZ18km90 -- 流量情報 補充液ﾎﾟﾝﾌﾟ積算流量(KM90)
,monitor_data->>''Z194'' as monZ19km90 -- 流量情報 除水積算流量(KM90)
,monitor_data->>''Z204'' as monZ20km90 -- その他情報 加温器温度(KM90)
,monitor_data->>''Z214'' as monZ21km90 -- その他情報 除水差分/重量値(KM90)
,monitor_data->>''Z224'' as monZ22km90 -- その他情報 初期診断情報(KM90)
,monitor_data->>''Z234'' as monZ23km90 -- その他情報 ｱﾗｰﾑ情報1(KM90)
,monitor_data->>''Z244'' as monZ24km90 -- その他情報 ｱﾗｰﾑ情報2(KM90)
,monitor_data->>''Z254'' as monZ25km90 -- その他情報 ｱﾗｰﾑ情報3(KM90)
,monitor_data->>''Z264'' as monZ26km90 -- その他情報 ｱﾗｰﾑ情報4(KM90)
,monitor_data->>''Z274'' as monZ27km90 -- その他情報 ｱﾗｰﾑ情報5(KM90)
,monitor_data->>''Z284'' as monZ28km90 -- その他情報 ｱﾗｰﾑ情報6(KM90)
,monitor_data->>''Z294'' as monZ29km90 -- その他情報 ｱﾗｰﾑ情報7(KM90)
,monitor_data->>''Z304'' as monZ30km90 -- その他情報 ｱﾗｰﾑ情報8(KM90)
,monitor_data->>''Z314'' as monZ31km90 -- その他情報 ｱﾗｰﾑ情報9(KM90)
,monitor_data->>''Z324'' as monZ32km90 -- その他情報 ｱﾗｰﾑ情報10(KM90)
,monitor_data->>''Z334'' as monZ33km90 -- その他情報 注意情報(KM90)
,monitor_data->>''Z344'' as monZ34km90 -- 経過時間(KM90)
,monitor_data->>''Z354'' as monZ35km90 -- その他情報 用途(KM90)
,monitor_data->>''Z364'' as monZ36km90 -- その他情報 工程(KM90)
,monitor_data->>''Z374'' as monZ37km90 -- その他情報 動作日、時間(KM90)
,to_date(occur_date || '''', ''YYYYMMDD'') as occur_date -- 発生日時
from
  mni_monitor
where
  ord_no = @ordNo and data_type = 1 and is_del = ''0''', "detail" = '[{"preview": "00：11", "can_calc": "0", "data_code": "mon1", "data_name": "経過時間", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "mon1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00：12", "can_calc": "0", "data_code": "mon2", "data_name": "経過時間（ＥＣＵＭ）", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "mon2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00：13", "can_calc": "0", "data_code": "mon3", "data_name": "残り時間（除水完了）", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "mon3", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00：14", "can_calc": "0", "data_code": "mon4", "data_name": "残り時間（透析完了）", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "mon4", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.21", "can_calc": "0", "data_code": "mon5", "data_name": "除水積算値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon5", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.18", "can_calc": "0", "data_code": "mon6", "data_name": "除水速度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon6", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8.58", "can_calc": "0", "data_code": "mon7", "data_name": "血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon7", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "0", "data_code": "mon8", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon8", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.4", "can_calc": "0", "data_code": "mon9", "data_name": "ＩＰ総量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon9", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.2", "can_calc": "0", "data_code": "mon10", "data_name": "ＩＰ速度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon10", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "138", "can_calc": "0", "data_code": "mon11", "data_name": "静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon11", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "144", "can_calc": "0", "data_code": "mon12", "data_name": "透析液圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon12", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-7", "can_calc": "0", "data_code": "mon13", "data_name": "TMP", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon13", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-830", "can_calc": "0", "data_code": "mon14", "data_name": "ダイアライザ入口圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon14", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-925", "can_calc": "0", "data_code": "mon15", "data_name": "ダイアライザ差圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon15", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-367", "can_calc": "0", "data_code": "mon16", "data_name": "血液入口～静脈平均圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon16", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon17", "data_name": "⊿BV", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon17", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "0", "data_code": "mon18", "data_name": "バイカーボ濃度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon18", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.8", "can_calc": "0", "data_code": "mon19", "data_name": "透析液濃度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon19", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon20", "data_name": "Ｎａ濃度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon20", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.2", "can_calc": "0", "data_code": "mon21", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon21", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "mon22", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon22", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon23", "data_name": "漏血量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon23", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "38", "can_calc": "0", "data_code": "mon24", "data_name": "給液圧（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon24", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "22", "can_calc": "0", "data_code": "mon25", "data_name": "給液圧（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon25", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-72.13", "can_calc": "0", "data_code": "mon26", "data_name": "ＵＦＲ", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon26", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon27", "data_name": "ＵＦＲ低下率", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon27", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "0", "data_code": "mon28", "data_name": "初期ＵＦＲ測定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon28", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon29", "data_name": "TMP補正値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon29", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon30", "data_name": "透析運転時間", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon30", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HD", "can_calc": "0", "data_code": "mon31", "data_name": "治療モード", "data_type": "string", "conv_table": [{"code": "-1", "disp": "不明", "item": "不明"}, {"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}, {"code": "2", "disp": "HDF", "item": "HDF"}, {"code": "3", "disp": "HF", "item": "HF"}, {"code": "4", "disp": "HD+補液", "item": "HD+補液"}, {"code": "5", "disp": "ECUM+補液", "item": "ECUM+補液"}, {"code": "6", "disp": "AFBF", "item": "AFBF"}, {"code": "7", "disp": "OHDF", "item": "OHDF"}, {"code": "8", "disp": "OHF", "item": "OHF"}, {"code": "9", "disp": "特殊浄化", "item": "特殊浄化"}, {"code": "10", "disp": "I-HDF", "item": "I-HDF"}], "data_class": "モニタ", "field_name": "mon31", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.85", "can_calc": "0", "data_code": "mon32", "data_name": "除水目標値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon32", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "0", "data_code": "mon33", "data_name": "除水速度設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon33", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.5", "can_calc": "0", "data_code": "mon34", "data_name": "透析液温度設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon34", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "mon35", "data_name": "透析液流量設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon35", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "0", "data_code": "mon36", "data_name": "血流量設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon36", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "0", "data_code": "mon37", "data_name": "ＩＰ速度設定", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon37", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "mon39", "data_name": "静脈圧警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon39", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "0", "data_code": "mon40", "data_name": "静脈圧警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon40", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "mon41", "data_name": "透析液圧警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon41", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "0", "data_code": "mon42", "data_name": "透析液圧警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon42", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "mon43", "data_name": "TMP警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon43", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "0", "data_code": "mon44", "data_name": "TMP警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon44", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "mon45", "data_name": "ダイアライザ入口圧警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon45", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "0", "data_code": "mon46", "data_name": "ダイアライザ入口圧警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon46", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "mon47", "data_name": "ダイアライザ差圧警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon47", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20", "can_calc": "0", "data_code": "mon48", "data_name": "ダイアライザ差圧警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon48", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20.0", "can_calc": "0", "data_code": "mon49", "data_name": "⊿ＢＶ低下警報点1", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon49", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-40.0", "can_calc": "0", "data_code": "mon50", "data_name": "⊿ＢＶ低下警報点2", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon50", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-10.0", "can_calc": "0", "data_code": "mon51", "data_name": "⊿BV変化率警報点", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon51", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "0", "data_code": "mon54", "data_name": "バイカーボ濃度警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon54", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "0", "data_code": "mon55", "data_name": "バイカーボ濃度警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon55", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon56", "data_name": "透析液濃度警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon56", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon57", "data_name": "透析液濃度警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon57", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon58", "data_name": "Ｎａ濃度警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon58", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon59", "data_name": "Ｎａ濃度警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon59", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40.0", "can_calc": "0", "data_code": "mon60", "data_name": "透析液温度警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon60", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "0", "data_code": "mon61", "data_name": "透析液温度警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon61", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon62", "data_name": "漏血量警報", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon62", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "45", "can_calc": "0", "data_code": "mon63", "data_name": "給水圧警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon63", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8", "can_calc": "0", "data_code": "mon64", "data_name": "給水圧警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon64", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-40.00", "can_calc": "0", "data_code": "mon65", "data_name": "初期ＵＦＲ警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon65", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-100.00", "can_calc": "0", "data_code": "mon66", "data_name": "初期ＵＦＲ警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon66", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "29", "can_calc": "0", "data_code": "mon67", "data_name": "ＵＦＲ低下率警報", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon67", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.1", "can_calc": "0", "data_code": "mon68", "data_name": "Kt/V", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon68", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8.58", "can_calc": "0", "data_code": "mon69", "data_name": "運転中の血流量積算値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon69", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8", "can_calc": "0", "data_code": "mon70", "data_name": "補液量設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon70", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "0", "data_code": "mon71", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon71", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.4", "can_calc": "0", "data_code": "mon72", "data_name": "補液量現在値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon72", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "0", "data_code": "mon73", "data_name": "補液速度設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon73", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.4", "can_calc": "0", "data_code": "mon74", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon74", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.4", "can_calc": "0", "data_code": "mon75", "data_name": "補液温度設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon75", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "0", "data_code": "mon76", "data_name": "濾液速度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon76", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.62", "can_calc": "0", "data_code": "mon77", "data_name": "荷重計", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon77", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00：15", "can_calc": "0", "data_code": "mon78", "data_name": "残り時間（補液完了）", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "mon78", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5.0", "can_calc": "0", "data_code": "mon80", "data_name": "⊿ＢＶ変化率", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon80", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon85", "data_name": "⊿BVリファレンスエリア上限", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon85", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon86", "data_name": "⊿BVリファレンスエリア下限", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon86", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon88", "data_name": "PRR", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon88", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon89", "data_name": "再循環率測定結果（BVMS連携用）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon89", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "132", "can_calc": "0", "data_code": "mon90", "data_name": "最高血圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "88", "can_calc": "0", "data_code": "mon91", "data_name": "最低血圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon91", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "102", "can_calc": "0", "data_code": "mon92", "data_name": "平均血圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon92", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "66", "can_calc": "0", "data_code": "mon93", "data_name": "脈拍", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon93", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.6", "can_calc": "0", "data_code": "mon94", "data_name": "体温", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon94", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon95", "data_name": "⊿ＢＶ_5分平均値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon95", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon96", "data_name": "⊿ＢＶ_最大最小を除いた5分平均値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon96", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.51", "can_calc": "0", "data_code": "mon38", "data_name": "Kt/V測定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon38", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35.5", "can_calc": "0", "data_code": "mon79", "data_name": "URR", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon79", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "0", "data_code": "mon97", "data_name": "推定血流量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon97", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50.1", "can_calc": "0", "data_code": "mon98", "data_name": "血流量不足率", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon98", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "SCUF", "can_calc": "0", "data_code": "monz1sigma", "data_name": "治療モード(Σ)", "data_type": "string", "conv_table": [{"code": "00", "disp": "SCUF", "item": "SCUF"}, {"code": "01", "disp": "CHF 前希釈", "item": "CHF 前希釈"}, {"code": "02", "disp": "CHF 後希釈", "item": "CHF 後希釈"}, {"code": "03", "disp": "CHD", "item": "CHD"}, {"code": "04", "disp": "CHDF 前希釈", "item": "CHDF 前希釈"}, {"code": "05", "disp": "CHDF 後希釈", "item": "CHDF 後希釈"}, {"code": "06", "disp": "PE", "item": "PE"}, {"code": "07", "disp": "PA プラソーバ", "item": "PA プラソーバ"}, {"code": "08", "disp": "PA イムソーバ", "item": "PA イムソーバ"}, {"code": "09", "disp": "DFPP 補液無し", "item": "DFPP 補液無し"}, {"code": "10", "disp": "DFPP 補液有り", "item": "DFPP 補液有り"}, {"code": "11", "disp": "HA", "item": "HA"}, {"code": "12", "disp": "LCAP", "item": "LCAP"}, {"code": "13", "disp": "(腹水)", "item": "(腹水)"}], "data_class": "モニタ", "field_name": "monz1sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "治療", "can_calc": "0", "data_code": "monz2sigma", "data_name": "工程状態(Σ)", "data_type": "string", "conv_table": [{"code": "1", "disp": "治療", "item": "治療"}, {"code": "2", "disp": "治療停止", "item": "治療停止"}, {"code": "3", "disp": "回収", "item": "回収"}, {"code": "4", "disp": "回収 廃棄", "item": "回収 廃棄"}, {"code": "5", "disp": "準備", "item": "準備"}, {"code": "6", "disp": "点検", "item": "点検"}, {"code": "7", "disp": "その他", "item": "その他"}], "data_class": "モニタ", "field_name": "monz2sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz3sigma", "data_name": "除水速度(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz3sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz4sigma", "data_name": "血液流量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz4sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz5sigma", "data_name": "シリンジ流量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz5sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz6sigma", "data_name": "ろ過流量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz6sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz7sigma", "data_name": "透析液/ドレン流量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz7sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz8sigma", "data_name": "補液流量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz8sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz9sigma", "data_name": "透析液加温器温度(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz9sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz10sigma", "data_name": "補液加温器温度(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz10sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz11sigma", "data_name": "現在 除水量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz11sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz12sigma", "data_name": "現在 血液循環量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz12sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz13sigma", "data_name": "現在 ろ過量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz13sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz14sigma", "data_name": "現在 透析液/ドレン量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz14sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz15sigma", "data_name": "現在 補液量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz15sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz16sigma", "data_name": "治療時間(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz16sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz17sigma", "data_name": "シリンジ積算量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz17sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz18sigma", "data_name": "目標 除水量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz18sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz19sigma", "data_name": "目標 血液循環量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz19sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz20sigma", "data_name": "目標 ろ過量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz20sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz21sigma", "data_name": "目標 透析液/ドレン量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz21sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz22sigma", "data_name": "目標 補液量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz22sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz23sigma", "data_name": "目標 治療時間(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz23sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz24sigma", "data_name": "脱血圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz24sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz25sigma", "data_name": "入口圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz25sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz26sigma", "data_name": "静脈圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz26sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz27sigma", "data_name": "ろ過圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz27sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz28sigma", "data_name": "排気圧/2次膜圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz28sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz29sigma", "data_name": "TMP/TMP1(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz29sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz30sigma", "data_name": "TMP2(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz30sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz31sigma", "data_name": "差圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz31sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz32sigma", "data_name": "気泡検知警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz32sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz33sigma", "data_name": "漏血警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz33sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz34sigma", "data_name": "加温器警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz34sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz35sigma", "data_name": "脱血圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz35sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz36sigma", "data_name": "入口圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz36sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz37sigma", "data_name": "静脈圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz37sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz38sigma", "data_name": "ろ過圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz38sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz39sigma", "data_name": "排気圧/2次膜圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz39sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz40sigma", "data_name": "TMP警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz40sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz41sigma", "data_name": "TMP2警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz41sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz42sigma", "data_name": "差圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz42sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz43sigma", "data_name": "その他警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz43sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz1km", "data_name": "測定値 TMP(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz1km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz2km", "data_name": "測定値 入口圧(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz2km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz3km", "data_name": "測定値 返血圧(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz3km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz4km", "data_name": "測定値 2次膜圧（吸着圧）(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz4km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz5km", "data_name": "圧力上限警報設定値 TMP(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz5km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz6km", "data_name": "圧力上限警報設定値 入口圧(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz6km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz7km", "data_name": "圧力上限警報設定値 返血圧(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz7km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz8km", "data_name": "圧力上限警報設定値 2次膜圧（吸着圧）(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz8km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz9km", "data_name": "流量情報 BP瞬時流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz9km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz10km", "data_name": "流量情報 PP瞬時流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz10km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz11km", "data_name": "流量情報 DP瞬時流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz11km", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz12km", "data_name": "流量情報 BP積算流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz12km", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz13km", "data_name": "流量情報 PP積算流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz13km", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz14km", "data_name": "流量情報 DP積算流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz14km", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz15km", "data_name": "流量情報 除水積算流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz15km", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz16km", "data_name": "流量情報 血漿処理目標値(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz16km", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz17km", "data_name": "その他情報 加温器温度(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz17km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz18km", "data_name": "その他情報 バランス(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz18km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz19km", "data_name": "その他情報 経過時間(KM)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz19km", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz20km", "data_name": "その他情報 アラーム番号(KM)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz20km", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz21km", "data_name": "その他情報 自己診断番号(KM)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz21km", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "情報なし", "can_calc": "0", "data_code": "monz22km", "data_name": "その他情報 モード(KM)", "data_type": "string", "conv_table": [{"code": "0", "disp": "情報なし", "item": "情報なし"}, {"code": "1", "disp": "CHDF", "item": "CHDF"}, {"code": "2", "disp": "CHD", "item": "CHD"}, {"code": "3", "disp": "CHF", "item": "CHF"}, {"code": "4", "disp": "PE", "item": "PE"}, {"code": "5", "disp": "PP", "item": "PP"}, {"code": "6", "disp": "DF", "item": "DF"}, {"code": "7", "disp": "手動", "item": "手動"}], "data_class": "モニタ", "field_name": "monz22km", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "情報なし", "can_calc": "0", "data_code": "monz23km", "data_name": "その他情報 工程情報(KM)", "data_type": "string", "conv_table": [{"code": "0", "disp": "情報なし", "item": "情報なし"}, {"code": "1", "disp": "洗浄工程", "item": "洗浄工程"}, {"code": "2", "disp": "臨床工程", "item": "臨床工程"}, {"code": "3", "disp": "回収工程", "item": "回収工程"}, {"code": "4", "disp": "手動工程", "item": "手動工程"}], "data_class": "モニタ", "field_name": "monz23km", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz1iq", "data_name": "治療経過時間(iQ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz1iq", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz2iq", "data_name": "除水速度(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz2iq", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz3iq", "data_name": "ろ過ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz3iq", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz4iq", "data_name": "補液ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz4iq", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz5iq", "data_name": "透析ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz5iq", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz6iq", "data_name": "血液ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz6iq", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz7iq", "data_name": "シリンジポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz7iq", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz8iq", "data_name": "除水量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz8iq", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz9iq", "data_name": "ろ過量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz9iq", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz10iq", "data_name": "補液量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz10iq", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz11iq", "data_name": "透析液量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz11iq", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz12iq", "data_name": "血液循環量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz12iq", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz13iq", "data_name": "シリンジポンプ積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz13iq", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz14iq", "data_name": "採血圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz14iq", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz15iq", "data_name": "動脈圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz15iq", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz16iq", "data_name": "静脈圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz16iq", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz17iq", "data_name": "ろ過圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz17iq", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz18iq", "data_name": "TMP(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz18iq", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz19iq", "data_name": "分離ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz19iq", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz20iq", "data_name": "返漿ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz20iq", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz21iq", "data_name": "ドレンポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz21iq", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz22iq", "data_name": "分離量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz22iq", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz23iq", "data_name": "返漿量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz23iq", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz24iq", "data_name": "ドレン量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz24iq", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz25iq", "data_name": "血漿圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz25iq", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz26iq", "data_name": "血漿入口圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz26iq", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz1km90", "data_name": "測定値 TMP圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz1km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz2km90", "data_name": "測定値 入口圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz2km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz3km90", "data_name": "測定値 返血圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz3km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz4km90", "data_name": "測定値 ろ過圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz4km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz5km90", "data_name": "測定値 浄化器圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz5km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz6km90", "data_name": "設定値 TMP圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz6km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz7km90", "data_name": "設定値 入口圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz7km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz8km90", "data_name": "設定値 返血圧・上限(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz8km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz9km90", "data_name": "設定値 返血圧・下限(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz9km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz10km90", "data_name": "設定値 浄化器圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz10km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz11km90", "data_name": "設定値 除水設定値(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz11km90", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz12km90", "data_name": "流量情報 血液ﾎﾟﾝﾌﾟ指令流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz12km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz13km90", "data_name": "流量情報 透析液ﾎﾟﾝﾌﾟ指令流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz13km90", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz14km90", "data_name": "流量情報 補充液ﾎﾟﾝﾌﾟ指令流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz14km90", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz15km90", "data_name": "流量情報 ろ液ﾎﾟﾝﾌﾟ指令流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz15km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz16km90", "data_name": "流量情報 血液ﾎﾟﾝﾌﾟ積算流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz16km90", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz17km90", "data_name": "流量情報 透析液ﾎﾟﾝﾌﾟ積算流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz17km90", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz18km90", "data_name": "流量情報 補充液ﾎﾟﾝﾌﾟ積算流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz18km90", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz19km90", "data_name": "流量情報 除水積算流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz19km90", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz20km90", "data_name": "その他情報 加温器温度(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz20km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz21km90", "data_name": "その他情報 除水差分/重量値(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz21km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz22km90", "data_name": "その他情報 初期診断情報(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz22km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz23km90", "data_name": "その他情報 ｱﾗｰﾑ情報1(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz23km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz24km90", "data_name": "その他情報 ｱﾗｰﾑ情報2(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz24km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz25km90", "data_name": "その他情報 ｱﾗｰﾑ情報3(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz25km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz26km90", "data_name": "その他情報 ｱﾗｰﾑ情報4(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz26km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz27km90", "data_name": "その他情報 ｱﾗｰﾑ情報5(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz27km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz28km90", "data_name": "その他情報 ｱﾗｰﾑ情報6(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz28km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz29km90", "data_name": "その他情報 ｱﾗｰﾑ情報7(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz29km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz30km90", "data_name": "その他情報 ｱﾗｰﾑ情報8(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz30km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz31km90", "data_name": "その他情報 ｱﾗｰﾑ情報9(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz31km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz32km90", "data_name": "その他情報 ｱﾗｰﾑ情報10(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz32km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz33km90", "data_name": "その他情報 注意情報(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz33km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz34km90", "data_name": "経過時間(KM9000)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz34km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz35km90", "data_name": "その他情報 用途(KM90)", "data_type": "string", "conv_table": [{"code": "1", "disp": "CRRT", "item": "CRRT"}, {"code": "2", "disp": "ECUM", "item": "ECUM"}, {"code": "3", "disp": "DF", "item": "DF"}, {"code": "4", "disp": "DFT", "item": "DFT"}, {"code": "5", "disp": "PP", "item": "PP"}, {"code": "6", "disp": "PE", "item": "PE"}, {"code": "7", "disp": "DHP", "item": "DHP"}, {"code": "8", "disp": "ASCT", "item": "ASCT"}, {"code": "9", "disp": "TEST", "item": "TEST"}], "data_class": "モニタ", "field_name": "monz35km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz36km90", "data_name": "その他情報 工程(KM90)", "data_type": "string", "conv_table": [{"code": "1", "disp": "装着", "item": "装着"}, {"code": "2", "disp": "確認", "item": "確認"}, {"code": "3", "disp": "洗浄", "item": "洗浄"}, {"code": "4", "disp": "臨床", "item": "臨床"}, {"code": "5", "disp": "回収", "item": "回収"}], "data_class": "モニタ", "field_name": "monz36km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz37km90", "data_name": "その他情報 動作日、時間(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz37km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "mon100", "data_name": "⊿BV(BVplus)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon100", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "mon101", "data_name": "Ht", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon101", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "mon102", "data_name": "LDQb", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon102", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "occur_date", "data_name": "発生日時", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "occur_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]' WHERE "sql_cd" = 106;

UPDATE "ntss"."sys_data_set" SET "sql" = 'with addition_info_expand as
(
  select
    ord_no
    ,json_idx
    ,addinfo
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
  from
    addition_info_expand
)

select
  ord_no
  ,name
  ,in_hospital_cd_1 as rst_addition_in_hospital_cd_1
  ,in_hospital_cd_2 as rst_addition_in_hospital_cd_2
  ,in_hospital_cd_3 as rst_addition_in_hospital_cd_3
  ,case
	  when addition_class =''1'' then ''施設''
		when addition_class =''2'' then ''患者（困）''
		when addition_class =''3'' then ''患者（病）''
		when addition_class =''4'' then ''ろ過''
		when addition_class =''5'' then ''長時間''
		when addition_class =''6'' then ''薬剤''
		when addition_class =''7'' then ''処置（イベント）''
		when addition_class =''8'' then ''処置（検査）''
		when addition_class =''9'' then ''導入期''
		when addition_class =''10'' then ''休日''
		when addition_class =''11'' then ''時間外''
		when addition_class =''12'' then ''汎用''
	 else  ''''
	end as addition_class_name
from
  tmp left outer join mst_addition on tmp.cd = mst_addition.addition_cd::text and is_disp = ''1'' and is_del = ''0''
order by json_idx
;' WHERE "sql_cd" = 117;

delete from sys_data_set where "sql_cd" in( 157, 158);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (157, 'with pat_taboo_tbl as (
  select
    to_number( info->>''ctl_no'', ''99999'') as ctl_no,
    to_number( info->>''disp_order'', ''99999'') as disp_order,
    info->>''content'' as content,
    info->>''memo'' as memo,
    info->>''category_class'' as category_class,
    info->>''taboo_allergy_class'' as taboo_allergy_class,
    info->>''taboo_allergy_cd'' as taboo_allergy_cd
  from
    pat_main
    cross join lateral
      json_array_elements (pat_main.taboo_allergy_info :: json) info
  where
    pat_id = @patId
    and is_del = ''0''
)

select
  ctl_no,
  disp_order,
  content,
  memo,
  category_class,
  taboo_allergy_class,
  taboo_allergy_cd
from
  pat_taboo_tbl
	WHERE taboo_allergy_class=''1''
order by
  disp_order, ctl_no
', 2, '[{"preview": "テスト薬剤（禁忌）", "can_calc": "0", "data_code": "content", "data_name": "禁忌", "data_type": "string", "conv_table": [], "data_class": "禁忌", "field_name": "content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "禁忌です。", "can_calc": "0", "data_code": "memo", "data_name": "禁忌備考", "data_type": "string", "conv_table": [], "data_class": "禁忌", "field_name": "memo", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9]}', '患者情報：禁忌　@patId使用', '2025-03-01 11:55:00', '2025-03-01 11:55:00', NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (158, 'with pat_taboo_tbl as (
  select
    to_number( info->>''ctl_no'', ''99999'') as ctl_no,
    to_number( info->>''disp_order'', ''99999'') as disp_order,
    info->>''content'' as content,
    info->>''memo'' as memo,
    info->>''category_class'' as category_class,
    info->>''taboo_allergy_class'' as taboo_allergy_class,
    info->>''taboo_allergy_cd'' as taboo_allergy_cd
  from
    pat_main
    cross join lateral
      json_array_elements (pat_main.taboo_allergy_info :: json) info
  where
    pat_id = @patId
    and is_del = ''0''
)

select
  ctl_no,
  disp_order,
  content,
  memo,
  category_class,
  taboo_allergy_class,
  taboo_allergy_cd
from
  pat_taboo_tbl
	WHERE taboo_allergy_class=''2''
order by
  disp_order, ctl_no
', 2, '[{"preview": "テスト薬剤（アレルギー）", "can_calc": "0", "data_code": "content", "data_name": "アレルギー", "data_type": "string", "conv_table": [], "data_class": "アレルギー", "field_name": "content", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}, {"preview": "アレルギーです。", "can_calc": "0", "data_code": "memo", "data_name": "アレルギー備考", "data_type": "string", "conv_table": [], "data_class": "アレルギー", "field_name": "memo", "disp_format": "", "data_category": "患者情報", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9]}', '患者情報：禁忌　@patId使用', '2025-03-01 11:55:00', '2025-03-01 11:55:00', NULL);

