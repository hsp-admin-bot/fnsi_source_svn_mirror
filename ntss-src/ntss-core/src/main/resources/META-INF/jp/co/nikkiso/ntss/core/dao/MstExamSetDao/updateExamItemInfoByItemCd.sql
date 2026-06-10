UPDATE mst_exam_set
SET exam_item_info = (
		SELECT
		case when jsonb_agg ( sub.elems )  is not null
		then jsonb_agg ( sub.elems )
		else '[]'
		end
	FROM
		(
		SELECT
			jsonb_set ( elem, '{exam_item_name}',   elem1 -> 'exam_item_name' ::TEXT ) AS elems
		FROM
			jsonb_array_elements ( exam_item_info ) AS elem,
			jsonb_array_elements ( /* examItemInfo */'[]' :: jsonb) AS elem1
		WHERE elem ->> 'exam_item_cd' = elem1->> 'exam_item_cd' and '1'= elem1->> 'is_disp'

		UNION ALL
		SELECT
			elem AS elems
		FROM
			jsonb_array_elements ( exam_item_info ) AS elem
		WHERE (elem ->> 'exam_item_cd') not in (select elem1->> 'exam_item_cd' from jsonb_array_elements ( /* examItemInfo */'[]' :: jsonb) AS elem1)
		) AS sub
	)
WHERE
	facility_cd = /* facilityCd */null
	AND EXISTS ( SELECT 1 FROM jsonb_array_elements ( exam_item_info ) AS item WHERE item ->> 'exam_item_cd' in (
			SELECT
			elem ->> 'exam_item_cd'  AS cd
		FROM
			jsonb_array_elements ( /* examItemInfo */'[]' :: jsonb) AS elem
	) )
