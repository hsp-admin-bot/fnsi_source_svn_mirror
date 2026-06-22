select concat(temp.ctr,'@@',temp.ctr_weight,'@@',temp.exam_date) from (
SELECT
             arr.item_object -> 'ctr' as ctr
			,arr.item_object -> 'ctr_weight' as ctr_weight
			, CASE (arr.item_object -> 'exam_date') ::TEXT
              WHEN 'null' then 'null'
              ELSE
                substr((arr.item_object -> 'exam_date') ::TEXT,2,length((arr.item_object -> 'exam_date') ::TEXT)-2)
              END as exam_date
			,row_number() over(order by substr((arr.item_object -> 'exam_date') ::TEXT,2,length((arr.item_object -> 'exam_date') ::TEXT)-2) desc) as ordno

        FROM
            pat_unique
            , jsonb_array_elements(physical_info) with ordinality arr(item_object, position)
        WHERE
            ((arr.item_object -> 'ctr') ::TEXT) <> 'null'
			and pat_id = /*patId*/0
			and is_del = '0'

) as temp
where temp.ordno = 1
;
