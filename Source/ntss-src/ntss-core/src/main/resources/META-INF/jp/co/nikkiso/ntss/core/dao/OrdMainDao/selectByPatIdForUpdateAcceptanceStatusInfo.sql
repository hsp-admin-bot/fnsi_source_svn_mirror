select
 ord_no,
 pat_id,
 rst_dialysis_state,
 rst_start_date,
 rst_cond_info->'1'->'value' as treatment_time
from
 ord_main
where
 rst_dialysis_state between '1' and '5'
and
 pat_id = /*patId*/null
and
 is_del = '0'
-- add FNSI-改修内容 患者情報共通ヘッダー外結No4対応 趙 start
and
 treat_date = /*sysDate*/'99999999'
-- add FNSI-改修内容 患者情報共通ヘッダー外結No4対応 趙 end
;
