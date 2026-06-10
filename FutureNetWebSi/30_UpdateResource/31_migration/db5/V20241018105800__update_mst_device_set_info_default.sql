-- 装置設定デフォルトマスタの初期値を設定する(ihdf-TMPゼロ補正開始時間(1001:10), TMPゼロ補正時間(1002:190))
WITH jsonb_origin AS (SELECT ( device_set_info -> 'ord' -> 'ihdf' -> 'dev' -> 'A' ) - '469' AS json_a, facility_cd FROM mst_device_set_info_default)
,jsonb_values AS (SELECT COALESCE(json_a -> '467', to_jsonb(10)) as v_467,	COALESCE(json_a -> '468', to_jsonb(190)) as v_468, facility_cd	FROM jsonb_origin)
,jsonb_del AS ( SELECT json_a - '467' - '468' AS json_a_del, facility_cd FROM jsonb_origin )
,jsonb_new AS ( SELECT jsonb_set(jsonb_set(jd.json_a_del, '{1001}', jv.v_467, true), '{1002}', jv.v_468, true)  as json_a_new, jd.facility_cd FROM jsonb_del jd inner join jsonb_values jv on jd.facility_cd = jv.facility_cd)
UPDATE mst_device_set_info_default d SET device_set_info = jsonb_set (d.device_set_info, '{ord,ihdf,dev,A}', json_a_new) FROM jsonb_new jn WHERE jn.facility_cd = d.facility_cd;

--ord_main delete ihdf:467,468,469
--WITH jsonb_new AS (SELECT (ind_device_set_info -> 'ihdf' -> 'dev' -> 'A') - '467'- '468'- '469' AS json_a, ord_no FROM ord_main)
--UPDATE ord_main om SET ind_device_set_info = jsonb_set (om.ind_device_set_info, '{ihdf,dev,A}', json_a) FROM jsonb_new jn WHERE jn.ord_no = om.ord_no;

--mst_treatment_set delete ihdf:467,468,469
WITH jsonb_new AS (SELECT (ind_device_set_info -> 'ihdf' -> 'dev' -> 'A') - '467'- '468'- '469' AS json_a, treatment_set_cd FROM mst_treatment_set)
UPDATE mst_treatment_set mts SET ind_device_set_info = jsonb_set (mts.ind_device_set_info, '{ihdf,dev,A}', json_a) FROM jsonb_new jn WHERE jn.treatment_set_cd = mts.treatment_set_cd;