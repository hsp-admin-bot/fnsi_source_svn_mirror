WITH
  Tmp_Ord_Main AS (
    SELECT
        om.ord_no,
        om.pat_id,
        om.facility_cd,
        om.rst_dw,
        ( om.rst_cond_info -> '3' ->> 'value' ) :: NUMERIC AS target_weight,
        ( om.rst_cond_info -> '4' ->> 'value' ) :: NUMERIC AS water_removal_amount_limit,
        om.rst_weight_info,
        om.rst_tare_info,
        om.rst_off_water_info,
        om.up_date,
        om.reg_date,
        om.rst_cond_send_date,
        om.rst_start_date,
        om.rst_dialysis_state,
        om.rst_end_date,
        -- modify by chamaojia 2025-02-27 [11471] The value of 【rst】 does not need to be associated --start
--         ( CASE WHEN mt.device_mode = 9 THEN 1 ELSE 0 END ) AS dev_mode
        ( CASE WHEN om.rst_device_mode = 9 THEN 1 ELSE 0 END ) AS dev_mode
        -- modify by chamaojia 2025-02-27 [11471] The value of 【rst】 does not need to be associated --end
    FROM
        ord_main om
        -- del by chamaojia 2025-02-27 [11471] The value of 【rst】 does not need to be associated --start
--         LEFT OUTER JOIN mst_treatment mt
--         ON om.rst_treatment_cd = mt.treatment_cd
        -- del by chamaojia 2025-02-27 [11471] The value of 【rst】 does not need to be associated --end
    WHERE
        om.is_del = '0'
    ),
  Tmp_Ord_Main_Before AS (
    SELECT
        om.ord_no,
        om.pat_id,
        om.facility_cd,
        om.rst_weight_info,
        om.rst_start_date,
        -- modify by chamaojia 2025-02-27 [11471] The value of 【rst】 does not need to be associated --start
--         ( CASE WHEN mt.device_mode = 9 THEN 1 ELSE 0 END ) AS dev_mode
        ( CASE WHEN om.rst_device_mode = 9 THEN 1 ELSE 0 END ) AS dev_mode
        -- modify by chamaojia 2025-02-27 [11471] The value of 【rst】 does not need to be associated --end
    FROM
        ord_main om
        -- del by chamaojia 2025-02-27 [11471] The value of 【rst】 does not need to be associated --start
--         LEFT OUTER JOIN mst_treatment mt
--         ON om.rst_treatment_cd = mt.treatment_cd
        -- del by chamaojia 2025-02-27 [11471] The value of 【rst】 does not need to be associated --end
    WHERE
        om.is_del = '0'
    )
  SELECT
    om.ord_no,
    ( s.rst_weight_info ->> 'weight_after' ) :: NUMERIC AS last_weight,
    om.rst_dw,
    om.target_weight,
    om.water_removal_amount_limit,
    om.rst_weight_info,
    om.rst_tare_info,
    om.rst_off_water_info,
    om.up_date,
    om.reg_date,
    om.rst_dialysis_state,
    om.rst_end_date
  FROM
	Tmp_Ord_Main om
	LEFT OUTER JOIN Tmp_Ord_Main_Before s
	ON om.ord_no <> s.ord_no
	AND om.pat_id = s.pat_id
	AND om.facility_cd = s.facility_cd
	AND ( om.rst_cond_send_date > s.rst_start_date OR om.rst_start_date > s.rst_start_date )
	AND om.dev_mode = s.dev_mode
  WHERE
	om.ord_no = /*ordNo*/1
  ORDER BY
	s.rst_start_date DESC
  LIMIT 1;
