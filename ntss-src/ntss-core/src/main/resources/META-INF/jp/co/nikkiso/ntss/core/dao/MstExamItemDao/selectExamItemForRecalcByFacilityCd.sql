-- 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add
SELECT
  exam_item_cd
  , m.facility_cd
  , fn_exam_item_cd
  , exam_item_name
  , data_type
  , unit
  , normal_value_class
  , normal_value_upper
  , normal_value_lower
  , normal_value_upper_m
  , normal_value_lower_m
  , normal_value_upper_w
  , normal_value_lower_w
  , input_integer_figure
  , input_decimal_figure
  , input_upper
  , input_lower
  , graph_upper
  , graph_lower
  , console_class
  , exam_class
  , in_hospital_cd1
  , sbt_cd1
  , in_hospital_cd2
  , sbt_cd2
  , in_hospital_cd3
  , sbt_cd3
  , spitz_cd
  , jlac10_cd
  , infection_cd
  , default_calc_exam_item_cd
  , free_calc
  , is_disp
  , is_del
  , reg_date
  , up_date
-- add 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm start
  , is_in_hospital
-- add 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm end
FROM
  mst_exam_item m,
  (
    select mss.facility_cd, ms.*, row_number() over() as index
    from mst_selector mss
    cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
    (
      code int,
      name text
    )
    where mss.facility_cd = /* facilityCd*/null
    and
    mss.master_physical_name = 'mst_exam_item'
  ) ms
WHERE
  (m.facility_cd IN (SELECT a.facility_cd_src
FROM pat_name_identification AS a
WHERE a.approve = '1'
  AND a.receive = '1'
  AND a.is_open = '1'
  AND a.facility_cd_dst = /*facilityCd*/'0'
) OR m.facility_cd = /*facilityCd*/'0')
  AND exam_class != '0'
  AND is_disp = '1'
  AND is_del = '0'
  AND m.exam_item_cd = ms.code
ORDER BY ms.index;
