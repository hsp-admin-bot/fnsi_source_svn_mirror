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
