SELECT
CASE /*type*/'1'
  WHEN '0' THEN
    (
      SELECT unit
        FROM mst_exam_item
       WHERE exam_item_cd = /*cd*/'23'
    )
  ELSE
    (
      SELECT medicine_group_unit
        FROM mst_medicine_group
       WHERE medicine_group_cd = /*cd*/'23'
    )
  END AS unit
