select
--add  10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy start
data_type,
--add  10398 文字型の検査項目に対して検査値の桁合わせ処理が行われる zy end
  exam_item_cd
  , input_decimal_figure
from
  mst_exam_item
where
  facility_cd = /*facilityCd*/1
and
  is_disp = '1'
and
  is_del = '0'
;
