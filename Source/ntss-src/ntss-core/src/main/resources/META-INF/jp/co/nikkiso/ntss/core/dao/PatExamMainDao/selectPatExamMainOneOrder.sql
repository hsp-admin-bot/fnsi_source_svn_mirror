SELECT
 p1.exam_main_cd AS exam_main_cd,
 p1.pat_id AS pat_id,
 p1.facility_cd As facility_cd,
 p1.ord_no As ord_no,
 p1.reg_order_class As reg_order_class,
 p1.exam_status As exam_status,
 p1.data_gen_class As data_gen_class,
 p1.result_exam_date As result_exam_date,
to_char(p1.result_exam_date,'yyyymmddHH24MISS') As result_exam_date_name,
 p1.is_del As is_del,
 p1.cop_order_no1 As cop_order_no1,
 p1.up_date As up_date,
 j1.item_cd As item_cd,
 j1.item_name As item_name,
 j1.result As result,
 j1.type As type,
 j1.unit As unit,
 j1.upper As upper,
 j1.lower As lower,
 j1.input_integer_figure As input_integer_figure,
 j1.input_decimal_figure As input_decimal_figure,
 j1.input_upper As input_upper,
 j1.input_lower As input_lower,
 j1.hl As hl,
 j1.disp_order As disp_order,
 j1.com_cd As com_cd,
 j1.freememo As freememo,
 j1.jlac10_cd As jlac10_cd,
 j1.exam_class As exam_class,
 m1.is_disp As is_disp
from ntss.pat_exam_main As p1, 
  jsonb_to_recordset(exam_result_info) 
    as j1(
	  disp_order text,
	  jlac10_cd text,
	  hl text,
	  result text,
	  com_cd text,
      item_cd text,
	  item_name text,
	  type text,
	  unit text,
	  upper text,
	  lower text,
	  input_integer_figure text,
	  input_decimal_figure text,
	  input_upper text,
	  input_lower text,
	  result_date text,
	  freememo text,
	  exam_class text
    )
INNER JOIN mst_exam_item m1 ON
  m1.exam_item_cd = CAST(j1.item_cd AS bigint)
WHERE p1.exam_status = '1'
AND p1.is_del = '0'
AND p1.exam_main_cd = /*examMainCd*/NULL
ORDER BY 
j1.disp_order
;
