WITH user_info AS (
  SELECT
    jsonb_build_object(
      'ind_user_id', (item_value->> 'ind_user_id')::numeric
      ,'upd_user_id', (item_value->> 'upd_user_id')::numeric
      ,'ind_user_first_name', item_value->> 'ind_user_first_name'
      ,'upd_user_first_name', item_value->> 'upd_user_first_name'
      ,'ind_user_last_name', item_value->> 'ind_user_last_name'
      ,'upd_user_last_name', item_value->> 'upd_user_last_name'
      ,'input_class', 1
      ,'is_editable', '1'
      ,'cop_order_no', NULL
    ) AS user_json
  FROM (VALUES (/*userInfo*/'{"upd_user_first_name": "KM", "upd_user_id": 12397, "ind_user_first_name": "KM", "upd_user_last_name": "Z", "ind_user_id": 12397, "ind_user_last_name": "Z"}'::jsonb))
    AS raw_data(item_value)
)
,treat_set as (
  SELECT
    mt.device_mode,
    mts.*
  FROM mst_treatment_set mts
    INNER JOIN mst_treatment mt
      ON mts.facility_cd = mt.facility_cd
      AND mts.treatment_cd = mt.treatment_cd
      AND mt.is_del = '0'
    WHERE mts.facility_cd = /*dto.facilityCd*/'NKKSBR'
      AND mts.treatment_set_cd = /*dto.treatmentSetCd*/7378
)
,equip_lock AS (
  SELECT COALESCE(
    (
      SELECT equip_info_no
      FROM equipment_latest_no
      WHERE facility_cd = /*dto.facilityCd*/''
        AND pat_id = /*dto.patId*/0
      FOR UPDATE
    ),
    0
  ) AS equip_info_no
)
,equip_json AS (
  SELECT
    COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'no', el.equip_info_no + es.rn,
          'cd', (es.e->>'cd')::numeric,
          'amount', es.e->>'amount',
          'equip_type', COALESCE((es.e->>'equip_type')::int, 0)
        ) || user_info.user_json
        ORDER BY es.rn
      ),
      '[]'::jsonb) AS ind_equip_info
  FROM treat_set ts
    CROSS JOIN equip_lock el
    CROSS JOIN LATERAL (
      SELECT e, ROW_NUMBER() OVER () AS rn
      FROM jsonb_array_elements(COALESCE(ts.ind_equip_info::jsonb, '[]'::jsonb)) e
    ) es
    CROSS JOIN user_info
)
,comment_json AS (
  SELECT
    COALESCE(
      jsonb_agg(
        jsonb_build_object(
          'no', (c->>'no')::numeric,
          'content', c->>'content'
        ) || user_info.user_json
        ORDER BY (c->>'no')::int
      ),
      '[]'::jsonb) AS ind_ind_comment_info
  FROM treat_set ts
    CROSS JOIN LATERAL jsonb_array_elements(COALESCE(ts.ind_ind_comment_info::jsonb, '[]'::jsonb)) c
    CROSS JOIN user_info
  WHERE (/*dto.treatMethodFlag*/'1' IS DISTINCT FROM '2')
)
,scheduleUser_json AS (
  SELECT
    (jsonb_build_object(
      'ind_kur_cd_before', NULL,
      'ind_treat_start_time_before', NULL
    ) || user_info.user_json) - 'input_class' - 'is_editable' - 'cop_order_no' AS ind_schedule_user_info
  FROM user_info
)
-- medi start --
,medi_lock AS (
  -- modify by chamaojia 2026-03-20 [12471] ord_main.ind_medi_infoに不正データが登録される --start
  SELECT COALESCE(
    (
      SELECT medi_info_no
      FROM medicine_latest_no
      WHERE facility_cd = /*dto.facilityCd*/''
        AND pat_id = /*dto.patId*/0
      FOR UPDATE
    ),
    0
  ) AS medi_info_no
  -- modify by chamaojia 2026-03-20 [12471] ord_main.ind_medi_infoに不正データが登録される --end
)
,medi_json AS (
  SELECT
    CASE WHEN /*dto.treatMethodFlag*/'1'::text = '2' THEN '[]'::jsonb
      ELSE COALESCE(jsonb_agg(
        jsonb_build_object(
          'no', ml.medi_info_no + rn,
          'medicine_type', (m->>'medicine_type')::numeric,
          'cd', (m->>'cd')::numeric,
          'amount', m->>'amount',
          'init_date', /*dto.startDate*/'20260122'::text,
          'date_interval', 0,
          'timing_cd', (m->>'timing_cd')::numeric,
          'procedure_cd', (m->>'procedure_cd')::numeric,
          'comment', m->>'medicine_comment'
        ) || user_info.user_json
      ORDER BY rn
      ),
      '[]'::jsonb)
    END AS ind_medi_info
  FROM treat_set ts
    CROSS JOIN medi_lock ml
    CROSS JOIN LATERAL (
      SELECT m, ROW_NUMBER() OVER () AS rn
      FROM jsonb_array_elements(COALESCE(ts.ind_medi_info::jsonb, '[]'::jsonb)) m
    ) s
    CROSS JOIN user_info
)
,default_device_except AS (
  SELECT
    facility_cd,
    (device_set_info -> 'ord' -> 'ihdf' -> 'dev' -> 'A') - '1001' -'1002' AS json_a
  FROM mst_device_set_info_default
  WHERE facility_cd = /* dto.facilityCd */'NKKSBR'
)
,default_device as (
  select (jsonb_set_lax (d.device_set_info, '{ord,ihdf,dev,A}', o.json_a))->'ord' AS device_set_info
  from mst_device_set_info_default d
  inner join default_device_except o
    ON d.facility_cd = o.facility_cd
  where d.facility_cd = /* dto.facilityCd */'NKKSBR'
)
,default_device_f as (
  select key as key1, value as key1_value from default_device, jsonb_each(device_set_info)
)
,default_device_s as (
  select key1, key as key2, value from default_device_f, jsonb_each(key1_value)
)
,treat_set_device_f as (
  select key as key1, value as key1_value from treat_set, jsonb_each(ind_device_set_info)
)
,treat_set_device_s as (
  select key1, key as key2, value from treat_set_device_f, jsonb_each(key1_value)
)
,merged_dev AS (
  SELECT
    ds.key1,
    ds.key2,
    jsonb_object_agg(k,
      ds.value->k || jsonb_strip_nulls(COALESCE(ts.value->k, '{}'::jsonb))
    ) AS result
  FROM default_device_s ds
    LEFT JOIN treat_set_device_s ts
      ON ds.key1 = ts.key1
      AND ds.key2 = ts.key2
    CROSS JOIN LATERAL jsonb_object_keys(ds.value) AS k
  GROUP BY ds.key1, ds.key2
)
,device_json AS (
  SELECT
    jsonb_object_agg(
      m.key1,
      (jsonb_build_object(
        m.key2,
        m.result
      ) || ui.user_json)- 'input_class' - 'is_editable' - 'cop_order_no'
    ) AS ind_device_set_info
  FROM merged_dev m
  CROSS JOIN user_info ui
)
,cond_info_tmp as (
  SELECT
    device_mode,
    ind_cond_info,
    COALESCE(((ind_cond_info)->'1'->>'value')::numeric, 0) as treat_time,
    ind_device_set_info
  FROM treat_set
)
,ihdf_data as (
  select
    cit.device_mode,
    dj.ind_device_set_info,
    jsonb_set_lax(cit.ind_cond_info, '{"24"}',
      (cit.ind_cond_info->'24') ||
        jsonb_build_object(
        'value',
          to_jsonb(TRUNC(CEIL(((dj.ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '201')::numeric * 60 / 1000 * 100) / 100,  2)::TEXT)
        )
    ) as ind_cond_info,
    CASE WHEN ((dj.ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '432')::numeric = '0'
      THEN TRUNC(COALESCE(GREATEST(cit.treat_time - ((dj.ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '203')::numeric, 0) /
        NULLIF(((dj.ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '202')::numeric, 0), 0), 0)
      ELSE
        LEAST(TRUNC(COALESCE(GREATEST(cit.treat_time - ((dj.ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '203')::numeric, 0) /
          NULLIF(((dj.ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '202')::numeric, 0), 0), 0), 16)
    END AS ihdf_liquid_cnt
  from cond_info_tmp cit cross join device_json dj
  where cit.device_mode = '10'
)
-- 20: 補液量, 24: 補液速度
,base as (
-- 7:OHDF, 8:OHF
select
  cit.device_mode,
  CASE WHEN ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '389') = '0' THEN
    CASE WHEN (cit.ind_cond_info)->'20'->>'value' = '-1'
      THEN jsonb_set_lax(
        jsonb_set_lax(cit.ind_cond_info,
          '{"20"}',
          (cit.ind_cond_info->'20') ||
            jsonb_build_object(
              'value', to_jsonb(ROUND(0,  1)::TEXT)
            )
        ),
        '{"24"}',
        (cit.ind_cond_info->'24') ||
          jsonb_build_object(
            'value', to_jsonb(ROUND(0,  2)::TEXT)
          )
      )
      WHEN cit.treat_time > ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '389')::numeric
        THEN jsonb_set_lax(cit.ind_cond_info,
          '{"24"}',
          (cit.ind_cond_info->'24') ||
            jsonb_build_object(
              'value', to_jsonb(TRUNC(CEIL(COALESCE(((cit.ind_cond_info)->'20'->>'value')::numeric, 0) * 60 /
                (cit.treat_time - ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric) * 100)/100, 2)::TEXT)
            )
        )
      ELSE jsonb_set_lax(cit.ind_cond_info,
        '{"24"}',
        (cit.ind_cond_info->'24') ||
          jsonb_build_object(
            'value', to_jsonb(ROUND(0,  2)::TEXT)
          )
    ) END
  WHEN ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '389')::numeric = '1' THEN
    CASE WHEN (cit.ind_cond_info)->'24'->>'value' = '-1'
      THEN jsonb_set_lax(
        jsonb_set_lax(cit.ind_cond_info,
        '{"20"}',
        (cit.ind_cond_info->'20') ||
          jsonb_build_object(
            'value', to_jsonb(ROUND(0,  1)::TEXT)
          )
        ),
        '{"24"}',
        (cit.ind_cond_info->'24') ||
          jsonb_build_object(
            'value', to_jsonb(ROUND(0,  2)::TEXT)
          )
      )
    WHEN cit.treat_time > ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric
      THEN jsonb_set_lax(cit.ind_cond_info,
      '{"20"}',
        (cit.ind_cond_info->'20') ||
          jsonb_build_object(
            'value', to_jsonb(TRUNC(COALESCE(((cit.ind_cond_info)->'24'->>'value')::numeric, 0) *
              (cit.treat_time -((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric) / 60, 1)::TEXT)
          )
      )
    ELSE jsonb_set_lax(cit.ind_cond_info,
      '{"20"}',
      (cit.ind_cond_info->'20') ||
        jsonb_build_object(
          'value', to_jsonb(ROUND(0, 1)::TEXT)
        )
    ) END
  WHEN ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '389')::numeric = '2' THEN
    CASE WHEN COALESCE(((cit.ind_cond_info)->'21'->>'value')::numeric, '1') = '1'
      AND cit.treat_time > ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric
      THEN jsonb_set_lax(
        jsonb_set_lax(cit.ind_cond_info,
          '{"20"}',
          (cit.ind_cond_info->'20') ||
            jsonb_build_object(
              'value', to_jsonb(TRUNC(TRUNC(CEIL((COALESCE((cit.ind_cond_info #>> '{"14", "value"}')::numeric, 0)
                * COALESCE(((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '379')::numeric, 0) * 60 / 100000) * 100000) / 100000, 5)
                * (cit.treat_time -
                ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric) / 60, 1)::TEXT)
            )
        ),
        '{"24"}',
        (cit.ind_cond_info->'24') ||
          jsonb_build_object(
            'value', to_jsonb(TRUNC(CEIL((COALESCE((cit.ind_cond_info #>> '{"14", "value"}')::numeric, 0)
              * COALESCE(((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '379')::numeric, 0) * 60 / 100000) * 100) / 100, 2)::TEXT)::jsonb
          )
      )
      WHEN COALESCE(((cit.ind_cond_info)->'21'->>'value')::numeric, '1') != '1'
        AND cit.treat_time > ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric
        THEN jsonb_set_lax(
          jsonb_set_lax(cit.ind_cond_info,
            '{"20"}',
            (cit.ind_cond_info->'20') ||
              jsonb_build_object(
                'value', to_jsonb(TRUNC(TRUNC(CEIL((COALESCE((cit.ind_cond_info #>> '{"14", "value"}')::numeric, 0)
                  * COALESCE(((pm.device_set_info) -> 'ope' -> 'dev' -> 'B' ->> '39')::numeric, 0) * 60 / 100000) * 100000) / 100000, 5)
                  * (cit.treat_time -
                  ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric) / 60, 1)::TEXT)
              )
          ),
          '{"24"}',
          (cit.ind_cond_info->'24') ||
            jsonb_build_object(
              'value', to_jsonb(TRUNC(CEIL((COALESCE((cit.ind_cond_info #>> '{"14", "value"}')::numeric, 0)
                * COALESCE(((pm.device_set_info) -> 'ope' -> 'dev' -> 'B' ->> '39')::numeric, 0) * 60 / 100000) * 100) / 100, 2)::TEXT)
            )
        )
        WHEN COALESCE(((cit.ind_cond_info)->'21'->>'value')::numeric, '1') = '1'
          AND cit.treat_time <= ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric
          THEN jsonb_set_lax(
            jsonb_set_lax(cit.ind_cond_info,
              '{"20"}',
              (cit.ind_cond_info->'20') ||
                jsonb_build_object(
                'value', to_jsonb(TRUNC(0, 1)::TEXT)
                )
            ),
            '{"24"}',
            (cit.ind_cond_info->'24') ||
              jsonb_build_object(
                'value', to_jsonb(TRUNC(CEIL((COALESCE((cit.ind_cond_info #>> '{"14", "value"}')::numeric, 0)
                  * COALESCE(((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '379')::numeric, 0) * 60 / 100000) * 100) / 100, 2)::TEXT)
              )
          )
          WHEN COALESCE(((cit.ind_cond_info)->'21'->>'value')::numeric, '1') != '1'
            AND cit.treat_time <= ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric
            THEN jsonb_set_lax(
              jsonb_set_lax(cit.ind_cond_info,
              '{"20"}',
              (cit.ind_cond_info->'20') ||
                jsonb_build_object(
                  'value', to_jsonb(TRUNC(0, 1)::TEXT)
                )
              ),
              '{"24"}',
              (cit.ind_cond_info->'24') ||
                jsonb_build_object(
                  'value', to_jsonb(TRUNC(CEIL((COALESCE((cit.ind_cond_info #>> '{"14", "value"}')::numeric, 0)
                    * COALESCE(((pm.device_set_info) -> 'ope' -> 'dev' -> 'B' ->> '39')::numeric, 0) * 60 / 100000) * 100) / 100, 2)::TEXT)
                )
            )
            ELSE cit.ind_cond_info END
  WHEN ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '389')::numeric = '3' THEN
    jsonb_set_lax(
      jsonb_set_lax(cit.ind_cond_info,
      '{"20"}',
      (cit.ind_cond_info->'20') ||
        jsonb_build_object(
          'value', to_jsonb('-1'::TEXT)
        )
      ),
      '{"24"}',
      (cit.ind_cond_info->'24') ||
        jsonb_build_object(
          'value', to_jsonb('-1'::TEXT)
        )
    )
  ELSE cit.ind_cond_info END as ind_cond_info
from cond_info_tmp cit INNER JOIN pat_main pm on pm.pat_id = /*dto.patId*/'160030'
where cit.device_mode in ('7', '8')
UNION ALL
-- 10:I-HDF
select
  device_mode,
  CASE WHEN ((ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '432')::numeric = '0'
    THEN jsonb_set_lax(ind_cond_info,
      '{"20"}',
      (ind_cond_info->'20') ||
        jsonb_build_object(
          'value', to_jsonb(TRUNC(LEAST(((ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '200')::numeric *
            ihdf_liquid_cnt / 1000, ((ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '205')::numeric), 1)::TEXT)
        )
    )
    ELSE jsonb_set_lax(ind_cond_info,
      '{"20"}',
      (ind_cond_info->'20') ||
        jsonb_build_object(
          'value', to_jsonb(TRUNC(LEAST(COALESCE((SELECT SUM(COALESCE(((ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> (435 + i)::text)::numeric, 0))
            FROM generate_series(0, LEAST(ihdf_liquid_cnt, 16) - 1) AS i)::numeric / 1000, 0)
              ,((ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '205')::numeric), 1)::TEXT)
        )
    )
  END as ind_cond_info
from ihdf_data
UNION ALL
-- not in (7:OHDF、8:OHF、9:特殊浄化、10:I-HDF) and ind_cond_info->'19' is not null
select
  cit.device_mode,
  CASE WHEN (cit.ind_cond_info)->'20'->>'value' = '-1'
    THEN jsonb_set_lax(
      jsonb_set_lax(cit.ind_cond_info,
      '{"20"}',
      (cit.ind_cond_info->'20') ||
        jsonb_build_object(
          'value', to_jsonb(ROUND(0,  1)::TEXT)
        )
      ),
      '{"24"}',
      (cit.ind_cond_info->'24') ||
        jsonb_build_object(
          'value', to_jsonb(ROUND(0,  2)::TEXT)
        )
    )
    WHEN cit.treat_time > ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric
      THEN jsonb_set_lax(cit.ind_cond_info,
        '{"24"}',
        (cit.ind_cond_info->'24') ||
          jsonb_build_object(
            'value', to_jsonb(TRUNC(CEIL(COALESCE(((cit.ind_cond_info)->'20'->>'value')::numeric, 0) * 60 /
              (cit.treat_time - ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric) *100)/100, 2)::TEXT)
          )
      )
    ELSE jsonb_set_lax(cit.ind_cond_info,
      '{"24"}',
      (cit.ind_cond_info->'24') ||
        jsonb_build_object(
          'value', to_jsonb(ROUND(0,  2)::TEXT)
        )
    )
  END as ind_cond_info
from cond_info_tmp cit INNER JOIN pat_main pm on pm.pat_id = /*dto.patId*/'160030'
where cit.device_mode not in ('-1', '7', '8', '9', '10') and cit.ind_cond_info->'19' is not null
UNION ALL
-- not in (7:OHDF、8:OHF、10:I-HDF and ind_cond_info->'19' is null) or 9:特殊浄化
select
  device_mode,
  ind_cond_info
from cond_info_tmp
where device_mode not in ('7', '8', '10') and ind_cond_info->'19' is null or device_mode in ('-1', '9')
)
,final_base as (
  SELECT
    fb.device_mode,
    e.key,
    CASE
      WHEN e.key IN ('15','19','25')  and NOT (e.value ?? 'medicine_type') THEN
        e.value
        || jsonb_build_object(
             'medicine_type',
             'null'::jsonb
           )
        || user_info.user_json
      ELSE
        e.value || user_info.user_json
    END AS value
  FROM base fb
    CROSS JOIN LATERAL jsonb_each(fb.ind_cond_info) e
	  CROSS JOIN user_info
)
,cond_json_ext AS (
  SELECT
    device_mode,
    jsonb_object_agg(key, value ORDER BY key::int) AS ind_cond_info
  FROM final_base
  GROUP BY device_mode
)
,cond_json AS (
  SELECT
    device_mode,
    ind_cond_info,
    NULLIF(ind_cond_info->'2'->>'value','')::numeric AS ind_va_cd
  FROM cond_json_ext
)
,treat_days AS (
  SELECT
    td.treat_day,
    CASE /*dto.treatType*/'3' WHEN '3' THEN 0 WHEN '0' THEN 1 WHEN '1' THEN 2 WHEN '2' THEN 3 ELSE NULL END::numeric as treat_type,
    CASE WHEN EXTRACT(DOW FROM to_date(td.treat_day, 'YYYYMMDD')) = 0
    THEN 7 ELSE EXTRACT(DOW FROM to_date(td.treat_day, 'YYYYMMDD'))
    END::smallint AS treat_week
  FROM jsonb_array_elements_text(/*dto.treatDays*/'["20260124","20260131","20260207"]'::jsonb) AS td(treat_day)
)
-- upset medicine_latest_no
,medi_add_count AS (
  SELECT
    CASE WHEN /*dto.treatMethodFlag*/'1' = '2' THEN 0
      ELSE jsonb_array_length(COALESCE(ind_medi_info::jsonb, '[]'::jsonb))
    END AS add_count
  FROM treat_set
)
,update_medi_no AS (
  INSERT INTO medicine_latest_no (
    facility_cd,
    pat_id,
    medi_info_no,
    reg_date,
    up_date,
    is_del,
    is_disp
  )
  SELECT
    /*dto.facilityCd*/'NKKSBR',
    /*dto.patId*/'160030',
    mac.add_count,
    NOW(),
    NOW(),
    '0',
    '1'
  FROM medi_add_count mac
    WHERE mac.add_count > 0
  ON CONFLICT (facility_cd, pat_id)
  DO UPDATE SET
    medi_info_no = medicine_latest_no.medi_info_no + EXCLUDED.medi_info_no,
    up_date = NOW()
)
,equip_add_count AS (
  SELECT
    jsonb_array_length(COALESCE(ind_equip_info::jsonb, '[]'::jsonb)) AS add_count
  FROM treat_set
)
,update_equip_no AS (
  INSERT INTO equipment_latest_no (
    facility_cd,
    pat_id,
    equip_info_no,
    reg_date,
    up_date,
    is_del,
    is_disp
  )
  SELECT
    /*dto.facilityCd*/'NKKSBR',
    /*dto.patId*/'160030',
    eac.add_count,
    NOW(),
    NOW(),
    '0',
    '1'
  FROM equip_add_count eac
    WHERE eac.add_count > 0
  ON CONFLICT (facility_cd, pat_id)
  DO UPDATE SET
    equip_info_no = equipment_latest_no.equip_info_no + EXCLUDED.equip_info_no,
    up_date = NOW()
)
insert into ord_main
(
  ord_no
  ,pat_id
  ,fn_pat_id
  ,treat_date
  ,treat_week
  ,facility_cd
  ,facility_name
  ,ind_va_cd
  ,ind_treatment_cd
  ,ind_kur_cd
  ,ind_treat_start_time
  ,ind_bed_cd
  ,ind_schedule_user_info
  ,ind_cond_info
  ,ind_medi_info
  ,ind_equip_info
  ,ind_ind_comment_info
  ,ind_tare_info
  ,ind_off_water_info
  ,rst_edition
  ,rst_dialysis_state
  ,is_del
  ,up_date
  ,reg_date
  ,ind_device_set_info
  ,treat_type
  ,up_ind_user_id
  ,up_user_id
  ,is_confirm
)
SELECT
  nextval('ord_main_ord_no_seq')
  ,/*dto.patId*/160030
  ,/*dto.fnPatId*/160030
  ,td.treat_day
  ,td.treat_week
  ,/*dto.facilityCd*/'NKKSBR'
  ,mf.facility_name
  ,cj.ind_va_cd
  ,ts.treatment_cd
  ,/*dto.indKurCd*/0
  ,/*dto.indTreatStartTime*/null::timestamp
  ,/*dto.indBedCd*/0
  ,sj.ind_schedule_user_info
  ,cj.ind_cond_info
  ,mj.ind_medi_info
  ,ej.ind_equip_info
  ,comj.ind_ind_comment_info
  ,pm.tare_info -> td.treat_week::text
  ,pm.off_water_info -> td.treat_week::text
  -- rst_edition
  ,0
  -- rst_dialysis_state
  ,'0'
  -- is_del
  ,'0'
  ,CURRENT_TIMESTAMP
  ,CURRENT_TIMESTAMP
  ,dj.ind_device_set_info
  ,td.treat_type
  ,/*dto.upIndUserId*/null
  ,/*dto.upUserId*/null
  ,'0'
FROM treat_days td
  inner join pat_main pm
    on pm.pat_id = /*dto.patId*/'160030'
    and pm.is_del = '0'
    and pm.facility_cd = /*dto.facilityCd*/'NKKSBR'
  inner join mst_facility mf
    on mf.facility_cd = pm.facility_cd
  inner join treat_set ts
    on ts.facility_cd = pm.facility_cd
  inner join cond_json cj on true
  inner join medi_json mj on true
  inner join equip_json ej on true
  inner join comment_json comj on true
  inner join scheduleUser_json sj on true
  inner join device_json dj on true
RETURNING *
