WITH
  shr_pat as (
    SELECT
      from_facility_cd,
      from_pat_id,
      to_facility_cd,
      to_pat_id
    FROM
      shr_pat_info
    WHERE
      to_facility_cd = /*params.get("facilityCd")*/''
      AND to_pat_id in /*patList*/(null)
      AND is_from_consent = '1'
      AND is_to_consent = '1'
      AND is_pat_consent = '1'
      AND is_disp = '1'
      AND is_del = '0'
  ),
  jlac10_cd_item AS (
    SELECT
      jlac10_cd,
      CASE
        WHEN exam_item_cd = /*params.get("examItemX")*/'' THEN 'X'
        WHEN exam_item_cd = /*params.get("examItemY")*/'' THEN 'Y'
        END AS item_type
    FROM mst_exam_item
    WHERE facility_cd = /*params.get("facilityCd")*/''
      AND exam_item_cd IN (/*params.get("examItemX")*/'', /*params.get("examItemY")*/'')
  ),
  exam_item_list AS (
      SELECT
          mei.facility_cd,
          mei.exam_item_cd,
          jci.item_type
      FROM mst_exam_item mei
               INNER JOIN jlac10_cd_item jci
                          ON mei.jlac10_cd = jci.jlac10_cd
      WHERE mei.is_disp = '1'
        AND mei.is_del = '0'
  )
  ,pat_map AS (
  SELECT
    /*params.get("facilityCd")*/'' AS src_facility_cd,
                                pat_id AS src_pat_id,
                                pat_id AS dest_pat_id
  FROM (
         VALUES
           /*%for p : patList */
         (/*p*/1)
           /*%if p_has_next */,/*%end*/
         /*%end*/
       ) AS t(pat_id)
  UNION ALL
  SELECT
    from_facility_cd,
    from_pat_id,
    to_pat_id
  FROM shr_pat
)
select
  pem.exam_main_cd,
  pm.dest_pat_id as pat_id,
  to_char(pem.result_exam_date, 'YYYY-MM-DD') as date,
  CASE
        WHEN eil.item_type = 'X'
        THEN pat_exam ->> 'result'
    END AS exam_item_result_x,
    CASE
        WHEN eil.item_type = 'Y'
        THEN pat_exam ->> 'result'
    END AS exam_item_result_y
from pat_exam_main pem
    INNER JOIN pat_map pm ON pem.facility_cd = pm.src_facility_cd AND pem.pat_id = pm.src_pat_id
    INNER JOIN exam_item_list eil ON pem.facility_cd = eil.facility_cd
  cross join lateral json_array_elements (pem.exam_result_info :: json) pat_exam
where pat_exam ->> 'item_cd' = eil.exam_item_cd::text
/*%if params.get("resultExamDateFrom") != null*/
  and to_char(result_exam_date, 'YYYY-MM-DD') >= /*params.get("resultExamDateFrom")*/''
/*%end*/
/*%if params.get("resultExamDateTo") != null*/
  and to_char(result_exam_date, 'YYYY-MM-DD') <= /*params.get("resultExamDateTo")*/''
/*%end*/
/*%if regOrderClassList.size() != 0*/
  and reg_order_class in /*regOrderClassList*/(null)
/*%end*/
  AND is_del = '0'
order by pat_id asc, result_exam_date desc
