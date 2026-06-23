UPDATE mst_coop_layout e
SET coop_ext_setting = jsonb_set ( coop_ext_setting, ARRAY [ 'dataset', sub.elem_index :: TEXT, 'is_zero_end' ], '"true"' :: JSONB, TRUE )
    FROM
	(
	SELECT
		ctl_no,
		regexp_replace(
			SUBSTRING ( xpath ( '/root/item[@name="利用者番号"]/@value', coop_setting ) :: TEXT FROM POSITION ( '-' IN xpath ( '/root/item[@name="利用者番号"]/@value', coop_setting ) :: TEXT ) ),
			'[^-0-9]',
			'',
			'g'
		) AS extracted_value,
		elem ->> 'sqlCode' AS sql_code,
		pos - 1 AS elem_index
	FROM
		mst_coop_layout,
		jsonb_array_elements ( coop_ext_setting -> 'dataset' ) WITH ORDINALITY arr ( elem, pos )
	WHERE
		facility_cd = 'F_hosp'
		AND coop_cd IN ( 'ind_dial', 'rst_dial', 'rep_dial', 'exam_ord', 'rad_ord', 'phy_ord' )
		AND direction = 'S'
		AND coop_format = 'text'
		AND is_del = '0'
	) sub
WHERE
    e.ctl_no = sub.ctl_no
  AND sub.sql_code = sub.extracted_value;

UPDATE mst_coop_layout e
SET coop_ext_setting = jsonb_set ( coop_ext_setting, ARRAY [ 'dataset', sub.elem_index :: TEXT, 'is_zero_end' ], '"true"' :: JSONB, TRUE )
    FROM
	(
	SELECT
		ctl_no,
		regexp_replace(
			SUBSTRING ( xpath ( '/root/item[@name="医師コード"]/@value', coop_setting ) :: TEXT FROM POSITION ( '-' IN xpath ( '/root/item[@name="医師コード"]/@value', coop_setting ) :: TEXT ) ),
			'[^-0-9]',
			'',
			'g'
		) AS extracted_value,
		elem ->> 'sqlCode' AS sql_code,
		pos - 1 AS elem_index
	FROM
		mst_coop_layout,
		jsonb_array_elements ( coop_ext_setting -> 'dataset' ) WITH ORDINALITY arr ( elem, pos )
	WHERE
		facility_cd = 'nkknkk'
		AND coop_cd = 'rst_dial'
		AND direction = 'S'
		AND coop_format = 'text'
		AND coop_name = '日機装拡張'
		AND is_del = '0'
	) sub
WHERE
    e.ctl_no = sub.ctl_no
  AND sub.sql_code = sub.extracted_value;

UPDATE mst_coop_layout e
SET coop_ext_setting = jsonb_set ( coop_ext_setting, ARRAY [ 'dataset', sub.elem_index :: TEXT, 'is_zero_end' ], '"true"' :: JSONB, TRUE )
    FROM
	(
	SELECT
		ctl_no,
		regexp_replace(
			SUBSTRING ( xpath ( '/root/item[@name="提出医"]/@value', coop_setting ) :: TEXT FROM POSITION ( '-' IN xpath ( '/root/item[@name="提出医"]/@value', coop_setting ) :: TEXT ) ),
			'[^-0-9]',
			'',
			'g'
		) AS extracted_value,
		elem ->> 'sqlCode' AS sql_code,
		pos - 1 AS elem_index
	FROM
		mst_coop_layout,
		jsonb_array_elements ( coop_ext_setting -> 'dataset' ) WITH ORDINALITY arr ( elem, pos )
	WHERE
		facility_cd = 'nkknkk'
		AND coop_cd IN ( 'ind_dial', 'exam_ord' )
		AND direction = 'S'
		AND coop_format = 'text'
		AND is_del = '0'
	) sub
WHERE
    e.ctl_no = sub.ctl_no
  AND sub.sql_code = sub.extracted_value;

UPDATE mst_coop_layout e
SET coop_ext_setting = jsonb_set ( coop_ext_setting, ARRAY [ 'dataset', sub.elem_index :: TEXT, 'is_zero_end' ], '"true"' :: JSONB, TRUE )
    FROM
	(
	SELECT
		ctl_no,
		regexp_replace(
			SUBSTRING ( xpath ( '/root/item[@name="担当医"]/@value', coop_setting ) :: TEXT FROM POSITION ( '-' IN xpath ( '/root/item[@name="担当医"]/@value', coop_setting ) :: TEXT ) ),
			'[^-0-9]',
			'',
			'g'
		) AS extracted_value,
		elem ->> 'sqlCode' AS sql_code,
		pos - 1 AS elem_index
	FROM
		mst_coop_layout,
		jsonb_array_elements ( coop_ext_setting -> 'dataset' ) WITH ORDINALITY arr ( elem, pos )
	WHERE
		facility_cd = 'nkknkk'
		AND coop_cd IN ( 'ind_dial', 'exam_ord' )
		AND direction = 'S'
		AND coop_format = 'text'
		AND is_del = '0'
	) sub
WHERE
    e.ctl_no = sub.ctl_no
  AND sub.sql_code = sub.extracted_value;
