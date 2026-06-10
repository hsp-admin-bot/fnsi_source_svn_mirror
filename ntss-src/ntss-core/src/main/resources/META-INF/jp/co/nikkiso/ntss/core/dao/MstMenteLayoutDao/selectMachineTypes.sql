
SELECT
		mst_machine_type.machine_type_cd,mst_machine_type.machine_type
FROM
	(SELECT
			machine_type_cd
	FROM
			mst_machine
	WHERE
			facility_cd = /* facilityCd*/'00000'
		AND
			is_disp = '1'
		AND
			is_del = '0'
	GROUP BY machine_type_cd) as tmpTable
CROSS JOIN mst_machine_type
WHERE mst_machine_type.machine_type_cd = tmpTable.machine_type_cd
-- add by chamaojia 2023-10-17 [9186] ソートフィールドの追加   --start
order by mst_machine_type.machine_type_cd
-- add by chamaojia 2023-10-17 [9186] ソートフィールドの追加   --end