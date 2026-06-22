with prescription_tbl as (
	SELECT a.* FROM (
		SELECT
			(o ->> 'Rp') AS rp
			,(o ->> 'type') as type
			,(o ->> 'sub_no') as sub_no
			, (o ->> 'F1') AS issue_name--調剤指示名
			, CASE WHEN (o ->> 'type') IN ('3', '5') THEN (o ->> 'F2') || ' ' || (o ->> 'F3') || ' ' || (o ->> 'F4')
				ELSE (o ->> 'F2') END AS usage_detail--用法詳細
			, op.ord_prescription_no AS ord_prescription_no
			, CASE WHEN (o ->> 'F5') = '0' or (o ->> 'F5') = '' then ' ' ELSE (o ->> 'F5') END AS day_count
			, CASE WHEN (o ->> 'F5') = '0' or (o ->> 'F5') = '' then ' ' ELSE (o ->> 'F6') END AS day_count_unit
			, ROW_NUMBER() OVER (PARTITION BY  (o ->> 'Rp'),(o ->> 'sub_no')   ORDER BY (o ->> 'Rp'),(o ->> 'sub_no')  ASC) AS rn
		FROM
			ord_prescription AS op
			, jsonb_array_elements(prescription_detail) AS o
		WHERE
			op.is_disp = '1'
			AND op.is_del = '0'
			AND o ->> 'type' <> '1'
			AND o ->> 'type' <> '6'
			AND o ->> 'type' <> 'E'
			AND o ->> 'type' <> '0'
			AND op.facility_cd = /*facilityCd*/''
			AND op.ord_prescription_no = /*ordPrescriptionNo*/''
	) a
	WHERE
		a.rn = 1
), comont_info as (
	select
	COALESCE(pt.rp, com1.rp) as rp,
	COALESCE(pt.sub_no, com1.sub_no) as sub_no,
	pt.issue_name,
	pt.usage_detail,
	pt.ord_prescription_no,
	pt.day_count,
	pt.day_count_unit,
	pt.type,
	com1.issue_name as comment_info
	 from (select com.* from (SELECT
			(o ->> 'Rp') AS rp
			,(o ->> 'sub_no') as sub_no
			, (o ->> 'F1') AS issue_name--調剤指示名
			, CASE WHEN (o ->> 'type') IN ('3', '5') THEN (o ->> 'F2') || ' ' || (o ->> 'F3') || ' ' || (o ->> 'F4')
				ELSE (o ->> 'F2') END AS usage_detail--用法詳細
			, op.ord_prescription_no AS ord_prescription_no
			, CASE WHEN (o ->> 'F5') = '0' or (o ->> 'F5') = '' then ' ' ELSE (o ->> 'F5') END AS day_count
			, CASE WHEN (o ->> 'F5') = '0' or (o ->> 'F5') = '' then ' ' ELSE (o ->> 'F6') END AS day_count_unit
			, ROW_NUMBER() OVER (PARTITION BY  (o ->> 'Rp'),(o ->> 'sub_no')   ORDER BY (o ->> 'Rp'),(o ->> 'sub_no') ASC) AS rn

		FROM
			ord_prescription AS op
			, jsonb_array_elements(prescription_detail) AS o
		WHERE
			op.is_disp = '1'
			AND op.is_del = '0'
			AND o ->> 'type' = '6'
			AND op.facility_cd = /*facilityCd*/''
			AND op.ord_prescription_no = /*ordPrescriptionNo*/''  )  com where com.rn = 1 	AND com.issue_name <>'' ) com1
			FULL OUTER JOIN prescription_tbl pt
		on pt.rp = com1.rp
)
SELECT
	ord_pt.rp
	,ord_pt.sub_no
	, ord_pt.unchg
	, ord_pt.medicine_name
	, ord_pt.mix_name
	, coin.issue_name
	, coin.usage_detail
	, ord_pt.rst_value
	, ord_pt.unit
	, ord_pt.r
	, coin.day_count
	, coin.day_count_unit
	, ord_pt.ord_prescription_no
	, coin.comment_info
	,coin.type
	,standard_medicine_cd
FROM (
	SELECT
		json_idx
		,	(o ->> 'Rp') AS rp
		,(o ->> 'sub_no') AS sub_no
		, CASE WHEN ( o ->> 'unchg' ) = 'x' THEN '2' ELSE '1' END AS unchg
		, (o ->> 'F1') AS medicine_name--薬剤名
		, (o ->> 'F2') AS mix_name--用法
		, ( o ->> 'F5' ) AS rst_value--量
		, ( o ->> 'F6' ) AS unit--単位
		, ( o ->> 'R' ) AS r --薬剤処方箋用表示
		, op.ord_prescription_no AS ord_prescription_no
		, med.standard_medicine_cd
	FROM
		ord_prescription AS op
		cross join lateral jsonb_array_elements(prescription_detail) with ordinality as tmp(o, json_idx)
		LEFT JOIN mst_medicine med on med.medicine_cd::TEXT = (o ->> 'medicine_cd')
	WHERE
		op.is_disp = '1'
		AND op.is_del = '0'
		AND o ->> 'type' = '1'
		AND op.facility_cd = /*facilityCd*/''
		AND op.ord_prescription_no = /*ordPrescriptionNo*/''
) ord_pt
left join comont_info coin
		on coin.rp = ord_pt.rp
ORDER BY ord_pt.json_idx ASC
