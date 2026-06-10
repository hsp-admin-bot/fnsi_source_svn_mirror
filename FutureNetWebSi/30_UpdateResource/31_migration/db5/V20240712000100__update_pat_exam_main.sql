UPDATE pat_exam_main 
SET order_exam_set_info = (
 SELECT
  jsonb_agg ( sub.elems ) 
 FROM
  ( SELECT jsonb_delete ( elem, 'no' ) AS elems FROM jsonb_array_elements ( order_exam_set_info ) AS elem ) AS sub 
 ),
 exam_order_info = (
 SELECT
  jsonb_agg ( sub.elems ) 
 FROM
  (
  SELECT
   jsonb_delete ( jsonb_insert ( elem1, '{set_cd}', ( elem ->> 'set_cd' :: TEXT ) :: JSONB ), 'no' ) AS elems 
  FROM
   jsonb_array_elements ( order_exam_set_info ) AS elem
   LEFT JOIN jsonb_array_elements ( exam_order_info ) AS elem1 ON elem ->> 'no' = elem1 ->> 'no' 
  ) AS sub 
 ) 
WHERE
 facility_cd = 'NKKSBR' 
 AND EXISTS ( SELECT 1 FROM jsonb_array_elements ( order_exam_set_info ) AS item WHERE item ->> 'no' IS NOT NULL )