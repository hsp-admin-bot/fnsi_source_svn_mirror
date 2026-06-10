WITH mss_bed AS (
  select
    mss.facility_cd, ms.*, row_number() over() as ord_index
  from
    mst_selector mss
    cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
    (
      code bigint,
      name text
    )
  where
    master_physical_name = 'mst_bed'
    AND facility_cd = /*facilityCd*/'000000'
),
mss_machine AS (
  select
    mss.facility_cd, ms.*, row_number() over() as ord_index
  from
    mst_selector mss
    cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
    (
      code bigint,
      name text
    )
  where
    master_physical_name = 'mst_machine'
    AND facility_cd = /*facilityCd*/'000000'
)

SELECT
	tmp_table.machine_no,
-- add FNSI-改修内容定期点検画面で装置名の固定部をタップすると当該装置の運転時間を表示するモーダル画面が展開されるようにする 任 start
	tmp_table.machine_serial,
-- add FNSI-改修内容定期点検画面で装置名の固定部をタップすると当該装置の運転時間を表示するモーダル画面が展開されるようにする 任 end
	tmp_table.machine_name,
	tmp_table.machine_type,
	tmp_table.machine_type_cd,
	tmp_table.model,
	mst_bed.bed_name,
	MSB.ord_index AS bed_order_index,
	MSM.ord_index AS machine_order_index
FROM
(
	SELECT
    mst_machine.machine_no,
-- add FNSI-改修内容定期点検画面で装置名の固定部をタップすると当該装置の運転時間を表示するモーダル画面が展開されるようにする 任 start
    mst_machine.machine_serial,
-- add FNSI-改修内容定期点検画面で装置名の固定部をタップすると当該装置の運転時間を表示するモーダル画面が展開されるようにする 任 end
    mst_machine.machine_name,
    mst_machine_type.machine_type,
    mst_machine_type.machine_type_cd,
    mst_machine_type.model
	FROM 	mst_machine
	CROSS JOIN mst_machine_type
	WHERE
		mst_machine.facility_cd = /* facilityCd */'000000'
	AND
		mst_machine.is_disp = '1'
	AND
		mst_machine.is_del = '0'
	AND
		mst_machine.machine_type_cd = mst_machine_type.machine_type_cd

) AS tmp_table
LEFT OUTER JOIN
	mst_bed
ON
	tmp_table.machine_no = mst_bed.machine_no
	AND
		mst_bed.is_disp = '1'
	AND
		mst_bed.is_del = '0'
LEFT OUTER JOIN mss_bed MSB on mst_bed.bed_cd = MSB.code
LEFT OUTER JOIN mss_machine MSM on tmp_table.machine_no = MSM.code

ORDER BY
  tmp_table.model ASC,
  bed_order_index ASC NULLS LAST
;
