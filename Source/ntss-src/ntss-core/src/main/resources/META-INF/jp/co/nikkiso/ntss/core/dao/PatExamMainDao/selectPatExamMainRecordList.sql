SELECT
 p1.exam_main_cd AS exam_main_cd,
 p1.pat_id AS pat_id,
 p1.facility_cd As facility_cd,
 p1.reg_order_class As reg_order_class,
 CASE p1.reg_order_class
  WHEN '1' THEN '透析前'
  WHEN '2' THEN '透析後'
  ELSE 'その他' END AS reg_order_class_name, 
 p1.exam_status AS exam_status,
 p1.data_gen_class AS data_gen_class,
 p1.result_exam_date AS result_exam_date,
to_char(p1.result_exam_date,'yyyymmddHH24MISS') AS result_exam_date_name,
 p1.is_del AS is_del,
 j1.item_cd AS item_cd,
 j1.result AS result,
 j1.hl AS hl,
 j1.disp_order AS disp_order,
 p1.pat_id_dst AS pat_id_dst,
 j1.jlac10_cd
-- modify by zhaohan 2022-10-31 [7090] システムを停止しないDBバージョンアップができない。 --start
-- FROM (SELECT * FROM pat_exam_main AS a1 LEFT JOIN pat_name_identification AS a2 ON a1.facility_cd = a2.facility_cd_src AND a1.pat_id = a2.pat_id_src) AS p1,
FROM (SELECT
        a1.exam_main_cd,
        a1.pat_id,
        a1.facility_cd,
        a1.reg_order_class,
        a1.exam_status,
        a1.data_gen_class,
        a1.result_exam_date,
        a1.is_del AS is_del,
        a1.exam_result_info,
        a2.pat_id_dst 
      FROM pat_exam_main AS a1 LEFT JOIN pat_name_identification AS a2 ON a1.facility_cd = a2.facility_cd_src AND a1.pat_id = a2.pat_id_src) AS p1,
-- modify by zhaohan 2022-10-31 [7090] システムを停止しないDBバージョンアップができない。 --end
  jsonb_to_recordset(exam_result_info) 
    AS j1(
	  disp_order text,
	  hl text,
	  result text,
	  com_cd text,
      item_cd text,
	  result_date text,
	  freememo text,
	  jlac10_cd text
    )
WHERE NOT EXISTS(
	SELECT 1
	FROM pat_exam_main AS p2, 
  	jsonb_to_recordset(exam_result_info) 
    	AS j2(
	  	disp_order text,
	  	hl text,
	  	result text,
	  	com_cd text,
      	item_cd text,
	  	result_date text,
	  	freememo text,
	  	jlac10_cd text
    	)
	WHERE p1.pat_id = p2.pat_id 
	AND p1.facility_cd = p2.facility_cd 
	AND p1.reg_order_class = p2.reg_order_class 
	AND j1.item_cd = j2.item_cd 
	/*%if null != resultTo && !resultTo.isEmpty() */
	AND DATE(p2.result_exam_date) <= /* resultTo */null
	/*%end */
	AND p1.result_exam_date < p2.result_exam_date
	AND p1.exam_status = p2.exam_status
	AND p1.is_del = p2.is_del
	)
AND p1.exam_status = '1'
AND p1.is_del = '0'
/*%if facilityCd != null */
AND p1.facility_cd = /* facilityCd */NULL
/*%end */
/*%if patIdList != null */
AND p1.pat_id in /* patIdList */(NULL)
/*%end */
/*%if null != resultFrom && !resultFrom.isEmpty() && null != resultTo && !resultTo.isEmpty() */
AND 
  DATE(p1.result_exam_date) BETWEEN /* resultFrom */null AND /* resultTo */null
/*%elseif null != resultFrom && !resultFrom.isEmpty() */
AND
  DATE(p1.result_exam_date) >= /* resultFrom */null
/*%elseif null != resultTo && !resultTo.isEmpty() */
AND
  DATE(p1.result_exam_date) <= /* resultTo */null
/*%end */

ORDER BY 
p1.pat_id, j1.item_cd,p1.data_gen_class,p1.exam_main_cd
;
