WITH ord_filtered AS MATERIALIZED (
  SELECT
    o.ord_no,
    o.facility_cd,
    o.ind_bed_cd,
    o.rst_bed_cd,
    o.pat_id,
    o.rst_dialysis_state,
    o.rst_edition,
    o.ind_tare_info,
    o.rst_tare_info,
    o.rst_kur_cd,
    o.rst_start_date
  FROM ord_main o
  WHERE o.facility_cd = /*facilityCd*/'NKKGNB'
    AND o.is_del = '0'
    AND o.rst_dialysis_state >= '4'
    AND o.rst_dialysis_state <= /*endState*/'5'
    AND (o.rst_end_date >= /*treatLocalDate*/'20260406')
),
ord_by_bed AS (
  SELECT o.*, o.ind_bed_cd AS bed_cd
  FROM ord_filtered o
  WHERE o.ind_bed_cd IS NOT NULL

  UNION ALL

  SELECT o.*, o.rst_bed_cd AS bed_cd
  FROM ord_filtered o
  WHERE o.rst_bed_cd IS NOT NULL
    AND o.rst_bed_cd IS DISTINCT FROM o.ind_bed_cd
),
-- ★ bed_cd ごとに rst_start_date が最大の1件のみに絞る
ord_by_bed_ranked AS (
  SELECT *,
    ROW_NUMBER() OVER (
      PARTITION BY bed_cd
      ORDER BY rst_start_date DESC
    ) AS rn
  FROM ord_by_bed
),
mss_bed AS (
  SELECT
    ms.code,
    row_number() OVER () AS ord_index
  FROM mst_selector mss
  CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings->'items') AS ms(
    code bigint,
    name text
  )
  WHERE mss.master_physical_name = 'mst_bed'
    AND mss.facility_cd = /*facilityCd*/'NKKGNB'
)
SELECT
    ss.facility_cd,
    ss.weight_cd,
    ss.bed_cd,
    ss.after_send_status as send_status,
    ss.is_connect,
    ss.after_weight_scale_no as ss_weight_scale_no,
    mst_w.weight_no,
    mst_w.is_default_print_before,
    mst_w.is_default_print_after,
    mss_bed.ord_index AS bed_order_index,
    mst_m.com_type,
    mst_m.com_format_cd,
    mnt_m_s.process_state,
    o.ord_no,
    o.pat_id,
    o.rst_kur_cd as kur_cd,
    p.is_same,
    p.is_wheel_chair,
    mst_w_c.wheel_chair_cd,
    o.rst_dialysis_state,
    o.ind_tare_info,
    o.rst_tare_info,
    lws.scale_mode,
    lws.weight_scale_status,
    lws.weight_scale_no ,
    lws.scale_value ,
    lws.scale_class ,
    mst_bed.bed_name
FROM ntss.mnt_scale_bed_state ss
INNER JOIN ord_by_bed_ranked o          
  ON o.facility_cd = ss.facility_cd
 AND o.bed_cd = ss.bed_cd
 AND o.rn = 1                           -- ★ 各 bed_cd の最新1件のみ
LEFT JOIN mst_weight mst_w
  ON ss.weight_cd = mst_w.weight_cd
 AND mst_w.is_del = '0'
 AND mst_w.is_disp = '1'
INNER JOIN mst_bed
  ON ss.bed_cd = mst_bed.bed_cd
  AND mst_bed.bed_name IS NOT NULL
  AND mst_bed.is_del = '0'
  AND mst_bed.is_disp = '1'
LEFT JOIN mss_bed
  ON mst_bed.bed_cd = mss_bed.code
LEFT JOIN mnt_machine_state mnt_m_s
  ON ss.bed_cd = mnt_m_s.bed_cd
 AND ss.facility_cd = mnt_m_s.facility_cd
LEFT JOIN ntss.mst_machine mst_m
  ON mnt_m_s.facility_cd = mst_m.facility_cd
 AND mnt_m_s.machine_type_cd = mst_m.machine_type_cd
 AND mnt_m_s.machine_serial = mst_m.machine_serial
 AND mst_m.is_del = '0'
 AND mst_m.is_disp = '1'
LEFT JOIN LATERAL (
  SELECT
    ws.weight_scale_no,
    ws.rst_tare_info,
    ws.rst_off_water_info,
    ws.scale_mode,
    ws.weight_scale_status,
    ws.scale_value,
    ws.scale_class,
    ws.kur_cd
  FROM ord_weight_scale ws
  WHERE ws.facility_cd = ss.facility_cd
    AND ws.ord_no = o.ord_no
    AND ws.weight_scale_no = ss.after_weight_scale_no
  ORDER BY ws.measure_date DESC
  FETCH FIRST 1 ROW ONLY
) lws ON TRUE
LEFT JOIN pat_main p
  ON o.pat_id = p.pat_id
LEFT JOIN ntss.mst_wheel_chair mst_w_c
  ON p.facility_cd = mst_w_c.facility_cd
 AND p.pat_id = mst_w_c.pat_id
 AND mst_w_c.is_del = '0'
 AND mst_w_c.is_disp = '1'
WHERE
  ss.facility_cd = /*facilityCd*/'NKKGNB'
ORDER BY
  mst_bed.bed_name,
  o.rst_start_date