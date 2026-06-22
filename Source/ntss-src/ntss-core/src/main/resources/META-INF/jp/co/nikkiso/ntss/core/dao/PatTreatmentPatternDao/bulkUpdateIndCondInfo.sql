WITH raw_data as (
  SELECT
    key AS item_key,
    value AS item_value,
    (value ->> 'value') AS item_value_text
  FROM jsonb_each(/*changeIndCondInfo*/'{}'::jsonb)
),
base_ord as (
  SELECT
    ptp.ctl_no,
    mt.device_mode,
    ptp.ind_cond_info,
    upd_user.upd_user_id::numeric,
    upd_user.upd_user_last_name,
    upd_user.upd_user_first_name
  FROM pat_treatment_pattern ptp
    INNER JOIN mst_treatment mt
  ON ptp.facility_cd = mt.facility_cd
    AND ptp.ind_treatment_cd = mt.treatment_cd
    LEFT JOIN (
      select
        item_value->> 'upd_user_id' as upd_user_id
        ,item_value->> 'upd_user_first_name' as upd_user_first_name
        ,item_value->> 'upd_user_last_name' as upd_user_last_name
      from raw_data LIMIT 1
    ) upd_user ON true
  WHERE
    ptp.facility_cd = /*facilityCd*/'NKKSBR'
    AND ptp.pat_id = /*patId*/'44683'
    /*%if 0 != weeks.get(0)*/
    AND ptp.treat_week in /*weeks*/(0)
    /*%end*/
    /*%if 0 != treats.size()*/
    AND ptp.ind_treatment_cd in /*treats*/(0)
    /*%end*/
    /*%if 0 != kurs.size()*/
    AND ptp.ind_kur_cd in /*kurs*/(0)
    /*%end*/
),
modified_data as (
  SELECT
    ctl_no,
    device_mode,
    case when device_mode IN (6, 10) then ind_cond_info
      else CASE
        WHEN ip.item_value IS NOT null and ip.item_value_text = '0' and bo.ind_cond_info->'12' is not null and bo.ind_cond_info->'12'->>'value' = '1'
          THEN bo.ind_cond_info #- '{11}'
            || jsonb_build_object('9', ('{"value": null, "ind_user_id": null, "input_class": 1, "is_editable": "1", "upd_user_id": null, "cop_order_no": null, "ind_user_last_name": "", "upd_user_last_name": "", "ind_user_first_name": "", "upd_user_first_name": ""}')::jsonb)
            || jsonb_build_object('10', ('{"value": null, "ind_user_id": null, "input_class": 1, "is_editable": "1", "upd_user_id": null, "cop_order_no": null, "ind_user_last_name": "", "upd_user_last_name": "", "ind_user_first_name": "", "upd_user_first_name": ""}')::jsonb)
        WHEN ip.item_value IS NOT null and ip.item_value_text = '1' and bo.ind_cond_info->'12' is not null and bo.ind_cond_info->'12'->>'value' = '0'
          THEN bo.ind_cond_info #- '{9}' #- '{10}' || jsonb_build_object('11', ('{"value": null, "ind_user_id": null, "input_class": 1, "is_editable": "1", "upd_user_id": null, "cop_order_no": null, "ind_user_last_name": "", "upd_user_last_name": "", "ind_user_first_name": "", "upd_user_first_name": ""}')::jsonb)
        ELSE bo.ind_cond_info END
      end AS ind_cond_info,
    bo.upd_user_id,
    bo.upd_user_last_name,
    bo.upd_user_first_name
  FROM base_ord bo LEFT JOIN raw_data ip on ip.item_key = '12'
),
merged_cond_info as (
  SELECT
    bo.ctl_no,
    bo.device_mode,
    bo.ind_cond_info,
    bo.upd_user_id,
    bo.upd_user_last_name,
    bo.upd_user_first_name,
    CASE WHEN bo.device_mode IN (6, 10)
      THEN jsonb_set_lax(COALESCE(bo.ind_cond_info || new_vals.obj, bo.ind_cond_info), '{"12", "value"}', to_jsonb('0'::text), false)
      ELSE COALESCE(bo.ind_cond_info || new_vals.obj, bo.ind_cond_info)
    END AS new_ind_cond_info
  FROM modified_data bo
    LEFT JOIN LATERAL (
      SELECT jsonb_object_agg(
        rd.item_key,
        rd.item_value - 'unit' - 'value_name_1' - 'value_name_2' - 'init_value' - 'isAmountchg' - 'decPoint'
      ) AS obj
      FROM raw_data rd
      WHERE bo.ind_cond_info ?? rd.item_key
        AND (
        ( /*indTreatCondIvMode*/'offLine' = 'offLine'
        AND (bo.device_mode NOT IN ('7','8','10')
        OR (bo.device_mode IN ('7','8','10') AND rd.item_key NOT IN ('19','20','21','22','23','24'))))
        OR ( /*indTreatCondIvMode*/'offLine' = 'onLine'
        AND (bo.device_mode IN ('7','8','10')
        OR (bo.device_mode NOT IN ('7','8','10') AND rd.item_key NOT IN ('19','20','21','22','23','24'))))
        OR /*indTreatCondIvMode*/'offLine' = 'noIv'
        )
    ) new_vals ON TRUE
),
merged_cond_info_19 as (
  SELECT
    ctl_no,
    device_mode,
    ind_cond_info,
    upd_user_id,
    upd_user_last_name,
    upd_user_first_name,
    COALESCE(((new_ind_cond_info)->'1'->>'value')::numeric, 0) as treat_time,
    ((new_ind_cond_info)->'25'->>'value')::bigint as medicine_value_25,
    case when device_mode in ('7', '8', '10')
      then jsonb_set_lax(new_ind_cond_info, '{19}', (new_ind_cond_info)->'15')
      else new_ind_cond_info
     end as new_ind_cond_info
  FROM merged_cond_info
),
parsed_data as (
  select
    ctl_no,
    medicine_value_25 AS medicine_cd,
    (new_ind_cond_info->'25'->>'medicine_type')::numeric as medicine_type,
    ((new_ind_cond_info)->'27'->>'value')::numeric as flow_rate,
    ((new_ind_cond_info)->'1'->>'value')::numeric as treat_time,
    ((new_ind_cond_info)->'29'->>'value')::numeric as ip_use,
    ((new_ind_cond_info)->'35'->>'value')::numeric as ip_auto_off,
    (COALESCE(((new_ind_cond_info)->'36'->>'value'), '0'))::numeric as ip_auto_off_timing
  FROM merged_cond_info_19
  WHERE medicine_value_25 IS NOT NULL
),
speed_calc_param as (
  select
    pd.*,
    COALESCE(mme.unit_decimal_point, mmx.unit_decimal_point, 0) AS unit_decimal_point,
    (pd.treat_time - pd.ip_use * pd.ip_auto_off * pd.ip_auto_off_timing) as calc_time
  FROM parsed_data pd
    LEFT JOIN mst_medicine mme ON pd.medicine_type = '1' AND mme.medicine_cd = pd.medicine_cd
    LEFT JOIN mst_medicine_mix mmx ON pd.medicine_type = '2' AND mmx.medicine_mix_cd = pd.medicine_cd
),
speed_cond_info as (
  select
    mci.ctl_no,
    mci.device_mode,
    mci.ind_cond_info,
    mci.upd_user_id,
    mci.upd_user_last_name,
    mci.upd_user_first_name,
    mci.treat_time,
    CASE WHEN medicine_value_25 is null THEN mci.new_ind_cond_info
      WHEN param.medicine_type IN ('1', '2') AND /*checkBoxFlg*/'1' = '1'
        THEN jsonb_set_lax(mci.new_ind_cond_info, '{"28"}',
          (mci.new_ind_cond_info->'28') ||
            jsonb_build_object(
              'value', case when flow_rate is null then 'null'::jsonb
                else to_jsonb(TRUNC(flow_rate::numeric * GREATEST(param.calc_time, 0) / 60, unit_decimal_point)::TEXT) end,
              'upd_user_id', mci.upd_user_id,
              'upd_user_last_name', mci.upd_user_last_name,
              'upd_user_first_name', mci.upd_user_first_name
            )
        )
      ELSE mci.new_ind_cond_info
    END as new_ind_cond_info
  FROM merged_cond_info_19 mci
    LEFT JOIN speed_calc_param param on mci.ctl_no = param.ctl_no
),
ihdf_data as (
select
  sci.ctl_no,
  sci.device_mode,
  sci.ind_cond_info,
  sci.upd_user_id,
  sci.upd_user_last_name,
  sci.upd_user_first_name,
  ptp.ind_device_set_info,
  jsonb_set_lax(sci.new_ind_cond_info, '{"24"}',
    (sci.new_ind_cond_info->'24') ||
      jsonb_build_object(
        'value',
          to_jsonb(TRUNC(CEIL(((ptp.ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '201')::numeric * 60 / 1000 * 100) / 100,  2)::TEXT),
        'upd_user_id', sci.upd_user_id,
        'upd_user_last_name', sci.upd_user_last_name,
        'upd_user_first_name', sci.upd_user_first_name
      )
  ) as new_ind_cond_info,
  CASE WHEN ((ptp.ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '432')::numeric = '0'
    THEN TRUNC(COALESCE(GREATEST(sci.treat_time - ((ptp.ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '203')::numeric, 0) /
      NULLIF(((ptp.ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '202')::numeric, 0), 0), 0)
    ELSE
      LEAST(TRUNC(COALESCE(GREATEST(sci.treat_time - ((ptp.ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '203')::numeric, 0) /
        NULLIF(((ptp.ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '202')::numeric, 0), 0), 0), 16)
  END AS ihdf_liquid_cnt
from speed_cond_info sci INNER JOIN pat_treatment_pattern ptp on ptp.pat_id = /*patId*/'44683' and sci.ctl_no = ptp.ctl_no
where sci.device_mode = '10'
),
base as (
  select
    sci.ctl_no,
    sci.device_mode,
    sci.ind_cond_info,
    sci.upd_user_id,
    sci.upd_user_last_name,
    sci.upd_user_first_name,
    CASE WHEN ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '389') = '0' THEN
        CASE WHEN (sci.new_ind_cond_info)->'20'->>'value' = '-1'
          THEN jsonb_set_lax(
            jsonb_set_lax(sci.new_ind_cond_info,
              '{"20"}',
              (sci.new_ind_cond_info->'20')
                || jsonb_build_object(
                  'value', to_jsonb(ROUND(0,  1)::TEXT),
                  'upd_user_id', sci.upd_user_id,
                  'upd_user_last_name', sci.upd_user_last_name,
                  'upd_user_first_name', sci.upd_user_first_name
                )
            ),
            '{"24"}',
            (sci.new_ind_cond_info->'24')
              || jsonb_build_object(
                'value', to_jsonb(ROUND(0,  2)::TEXT),
                'upd_user_id', sci.upd_user_id,
                'upd_user_last_name', sci.upd_user_last_name,
                'upd_user_first_name', sci.upd_user_first_name
              )
          )
          WHEN sci.treat_time > ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '389')::numeric
            THEN jsonb_set_lax(sci.new_ind_cond_info,
              '{"24"}',
              (sci.new_ind_cond_info->'24')
                || jsonb_build_object(
                  'value', to_jsonb(TRUNC(CEIL(COALESCE(((sci.new_ind_cond_info)->'20'->>'value')::numeric, 0) * 60 /
                  (sci.treat_time - ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric) * 100)/100, 2)::TEXT),
                  'upd_user_id', sci.upd_user_id,
                  'upd_user_last_name', sci.upd_user_last_name,
                  'upd_user_first_name', sci.upd_user_first_name
                )
            )
          ELSE jsonb_set_lax(sci.new_ind_cond_info,
            '{"24"}',
            (sci.new_ind_cond_info->'24')
              || jsonb_build_object(
                'value', to_jsonb(ROUND(0,  2)::TEXT),
                'upd_user_id', sci.upd_user_id,
                'upd_user_last_name', sci.upd_user_last_name,
                'upd_user_first_name', sci.upd_user_first_name
              )
          ) END
      WHEN ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '389')::numeric = '1' THEN
        CASE WHEN (sci.new_ind_cond_info)->'24'->>'value' = '-1'
          THEN jsonb_set_lax(
            jsonb_set_lax(sci.new_ind_cond_info,
              '{"20"}',
              (sci.new_ind_cond_info->'20') ||
                jsonb_build_object(
                  'value', to_jsonb(ROUND(0,  1)::TEXT),
                  'upd_user_id', sci.upd_user_id,
                  'upd_user_last_name', sci.upd_user_last_name,
                  'upd_user_first_name', sci.upd_user_first_name
                )
            ),
            '{"24"}',
            (sci.new_ind_cond_info->'24') ||
              jsonb_build_object(
                'value', to_jsonb(ROUND(0,  2)::TEXT),
                'upd_user_id', sci.upd_user_id,
                'upd_user_last_name', sci.upd_user_last_name,
                'upd_user_first_name', sci.upd_user_first_name
              )
          )
        WHEN sci.treat_time > ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric
          THEN jsonb_set_lax(sci.new_ind_cond_info,
            '{"20"}',
            (sci.new_ind_cond_info->'20') ||
              jsonb_build_object(
                'value', to_jsonb(TRUNC(COALESCE(((sci.new_ind_cond_info)->'24'->>'value')::numeric, 0) *
                (sci.treat_time -((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric) / 60, 1)::TEXT),
                'upd_user_id', sci.upd_user_id,
                'upd_user_last_name', sci.upd_user_last_name,
                'upd_user_first_name', sci.upd_user_first_name
              )
          )
        ELSE jsonb_set_lax(sci.new_ind_cond_info,
          '{"20"}',
          (sci.new_ind_cond_info->'20') ||
            jsonb_build_object(
              'value', to_jsonb(ROUND(0, 1)::TEXT),
              'upd_user_id', sci.upd_user_id,
              'upd_user_last_name', sci.upd_user_last_name,
              'upd_user_first_name', sci.upd_user_first_name
            )
        ) END
      WHEN ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '389')::numeric = '2' THEN
        CASE WHEN COALESCE(((sci.new_ind_cond_info)->'21'->>'value')::numeric, '1') = '1'
          AND sci.treat_time > ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric
          THEN jsonb_set_lax(
            jsonb_set_lax(sci.new_ind_cond_info,
              '{"20"}',
              (sci.new_ind_cond_info->'20') ||
                jsonb_build_object(
                  'value', to_jsonb(TRUNC(TRUNC(CEIL((COALESCE((sci.new_ind_cond_info #>> '{"14", "value"}')::numeric, 0)
                    * COALESCE(((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '379')::numeric, 0) * 60 / 100000) * 100000) / 100000, 5)
                    * (sci.treat_time -
                  ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric) / 60, 1)::TEXT),
                  'upd_user_id', sci.upd_user_id,
                  'upd_user_last_name', sci.upd_user_last_name,
                  'upd_user_first_name', sci.upd_user_first_name
                )
            ),
            '{"24"}',
            (sci.new_ind_cond_info->'24') ||
              jsonb_build_object(
                'value', to_jsonb(TRUNC(CEIL((COALESCE((sci.new_ind_cond_info #>> '{"14", "value"}')::numeric, 0)
                  * COALESCE(((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '379')::numeric, 0) * 60 / 100000) * 100) / 100, 2)::TEXT)::jsonb,
                'upd_user_id', sci.upd_user_id,
                'upd_user_last_name', sci.upd_user_last_name,
                'upd_user_first_name', sci.upd_user_first_name
              )
          )
        WHEN COALESCE(((sci.new_ind_cond_info)->'21'->>'value')::numeric, '1') != '1'
          AND sci.treat_time > ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric
          THEN jsonb_set_lax(
            jsonb_set_lax(sci.new_ind_cond_info,
              '{"20"}',
              (sci.new_ind_cond_info->'20') ||
                jsonb_build_object(
                  'value', to_jsonb(TRUNC(TRUNC(CEIL((COALESCE((sci.new_ind_cond_info #>> '{"14", "value"}')::numeric, 0)
                    * COALESCE(((pm.device_set_info) -> 'ope' -> 'dev' -> 'B' ->> '39')::numeric, 0) * 60 / 100000) * 100000) / 100000, 5)
                    * (sci.treat_time - ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric) / 60, 1)::TEXT),
                  'upd_user_id', sci.upd_user_id,
                  'upd_user_last_name', sci.upd_user_last_name,
                  'upd_user_first_name', sci.upd_user_first_name
                )
            ),
            '{"24"}',
            (sci.new_ind_cond_info->'24') ||
              jsonb_build_object(
                'value', to_jsonb(TRUNC(CEIL((COALESCE((sci.new_ind_cond_info #>> '{"14", "value"}')::numeric, 0)
                  * COALESCE(((pm.device_set_info) -> 'ope' -> 'dev' -> 'B' ->> '39')::numeric, 0) * 60 / 100000) * 100) / 100, 2)::TEXT),
                'upd_user_id', sci.upd_user_id,
                'upd_user_last_name', sci.upd_user_last_name,
                'upd_user_first_name', sci.upd_user_first_name
              )
          )
        WHEN COALESCE(((sci.new_ind_cond_info)->'21'->>'value')::numeric, '1') = '1'
          AND sci.treat_time <= ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric
          THEN jsonb_set_lax(
            jsonb_set_lax(sci.new_ind_cond_info,
              '{"20"}',
              (sci.new_ind_cond_info->'20') ||
                jsonb_build_object(
                  'value', to_jsonb(TRUNC(0, 1)::TEXT),
                  'upd_user_id', sci.upd_user_id,
                  'upd_user_last_name', sci.upd_user_last_name,
                  'upd_user_first_name', sci.upd_user_first_name
                )
            ),
            '{"24"}',
            (sci.new_ind_cond_info->'24') ||
              jsonb_build_object(
                'value', to_jsonb(TRUNC(CEIL((COALESCE((sci.new_ind_cond_info #>> '{"14", "value"}')::numeric, 0)
                  * COALESCE(((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '379')::numeric, 0) * 60 / 100000) * 100) / 100, 2)::TEXT),
                'upd_user_id', sci.upd_user_id,
                'upd_user_last_name', sci.upd_user_last_name,
                'upd_user_first_name', sci.upd_user_first_name
              )
          )
        WHEN COALESCE(((sci.new_ind_cond_info)->'21'->>'value')::numeric, '1') != '1'
          AND sci.treat_time <= ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric
          THEN jsonb_set_lax(
            jsonb_set_lax(sci.new_ind_cond_info,
              '{"20"}',
              (sci.new_ind_cond_info->'20') ||
                jsonb_build_object(
                  'value', to_jsonb(TRUNC(0, 1)::TEXT),
                  'upd_user_id', sci.upd_user_id,
                  'upd_user_last_name', sci.upd_user_last_name,
                  'upd_user_first_name', sci.upd_user_first_name
                )
            ),
            '{"24"}',
            (sci.new_ind_cond_info->'24') ||
              jsonb_build_object(
                'value', to_jsonb(TRUNC(CEIL((COALESCE((sci.new_ind_cond_info #>> '{"14", "value"}')::numeric, 0)
                * COALESCE(((pm.device_set_info) -> 'ope' -> 'dev' -> 'B' ->> '39')::numeric, 0) * 60 / 100000) * 100) / 100, 2)::TEXT),
                'upd_user_id', sci.upd_user_id,
                'upd_user_last_name', sci.upd_user_last_name,
                'upd_user_first_name', sci.upd_user_first_name
              )
          )
        ELSE sci.new_ind_cond_info END
      WHEN ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '389')::numeric = '3' THEN
        jsonb_set_lax(
          jsonb_set_lax(sci.new_ind_cond_info,
            '{"20"}',
            (sci.new_ind_cond_info->'20') ||
              jsonb_build_object(
                'value', to_jsonb('-1'::TEXT),
                'upd_user_id', sci.upd_user_id,
                'upd_user_last_name', sci.upd_user_last_name,
                'upd_user_first_name', sci.upd_user_first_name
              )
          ),
          '{"24"}',
          (sci.new_ind_cond_info->'24') ||
            jsonb_build_object(
              'value', to_jsonb('-1'::TEXT),
              'upd_user_id', sci.upd_user_id,
              'upd_user_last_name', sci.upd_user_last_name,
              'upd_user_first_name', sci.upd_user_first_name
            )
        )
    ELSE sci.new_ind_cond_info END as new_ind_cond_info
  from speed_cond_info sci
    INNER JOIN pat_main pm on pm.pat_id = /*patId*/'44683'
  where sci.device_mode in ('7', '8')
UNION ALL
  select
    ctl_no,
    device_mode,
    ind_cond_info,
    upd_user_id,
    upd_user_last_name,
    upd_user_first_name,
    CASE WHEN ((ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '432')::numeric = '0'
      THEN jsonb_set_lax(new_ind_cond_info,
        '{"20"}',
        (new_ind_cond_info->'20') ||
          jsonb_build_object(
            'value', to_jsonb(TRUNC(LEAST(((ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '200')::numeric *
              ihdf_liquid_cnt / 1000, ((ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '205')::numeric), 1)::TEXT),
            'upd_user_id', upd_user_id,
            'upd_user_last_name', upd_user_last_name,
            'upd_user_first_name', upd_user_first_name
          )
      )
      ELSE jsonb_set_lax(new_ind_cond_info,
        '{"20"}',
        (new_ind_cond_info->'20') ||
          jsonb_build_object(
            'value', to_jsonb(TRUNC(LEAST(COALESCE((SELECT SUM(COALESCE(((ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> (435 + i)::text)::numeric, 0))
              FROM generate_series(0, LEAST(ihdf_liquid_cnt, 16) - 1) AS i)::numeric / 1000, 0)
              ,((ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '205')::numeric), 1)::TEXT),
            'upd_user_id', upd_user_id,
            'upd_user_last_name', upd_user_last_name,
            'upd_user_first_name', upd_user_first_name
          )
      )
    END as new_ind_cond_info
  from ihdf_data
UNION ALL
  select
    sci.ctl_no,
    sci.device_mode,
    sci.ind_cond_info,
    sci.upd_user_id,
    sci.upd_user_last_name,
    sci.upd_user_first_name,
    CASE WHEN (sci.new_ind_cond_info)->'20'->>'value' = '-1'
      THEN jsonb_set_lax(
        jsonb_set_lax(sci.new_ind_cond_info,
          '{"20"}',
          (sci.new_ind_cond_info->'20') ||
            jsonb_build_object(
              'value', to_jsonb(ROUND(0,  1)::TEXT),
              'upd_user_id', sci.upd_user_id,
              'upd_user_last_name', sci.upd_user_last_name,
              'upd_user_first_name', sci.upd_user_first_name
            )
        ),
        '{"24"}',
        (sci.new_ind_cond_info->'24') ||
          jsonb_build_object(
            'value', to_jsonb(ROUND(0,  2)::TEXT),
            'upd_user_id', sci.upd_user_id,
            'upd_user_last_name', sci.upd_user_last_name,
            'upd_user_first_name', sci.upd_user_first_name
          )
      )
      WHEN sci.treat_time > ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric
        THEN jsonb_set_lax(sci.new_ind_cond_info,
          '{"24"}',
          (sci.new_ind_cond_info->'24') ||
            jsonb_build_object(
              'value', to_jsonb(TRUNC(CEIL(COALESCE(((sci.new_ind_cond_info)->'20'->>'value')::numeric, 0) * 60 /
                (sci.treat_time - ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric) *100)/100, 2)::TEXT),
              'upd_user_id', sci.upd_user_id,
              'upd_user_last_name', sci.upd_user_last_name,
              'upd_user_first_name', sci.upd_user_first_name
            )
        )
      ELSE jsonb_set_lax(sci.new_ind_cond_info,
        '{"24"}',
        (sci.new_ind_cond_info->'24') ||
          jsonb_build_object(
            'value', to_jsonb(ROUND(0,  2)::TEXT),
            'upd_user_id', sci.upd_user_id,
            'upd_user_last_name', sci.upd_user_last_name,
            'upd_user_first_name', sci.upd_user_first_name
          )
      )
    END as new_ind_cond_info
  from speed_cond_info sci INNER JOIN pat_main pm on pm.pat_id = /*patId*/'44683'
  where sci.device_mode not in ('-1', '7', '8', '9', '10') and sci.new_ind_cond_info->'19' is not null
UNION ALL
  select
    ctl_no,
    device_mode,
    ind_cond_info,
    upd_user_id,
    upd_user_last_name,
    upd_user_first_name,
    new_ind_cond_info
  from speed_cond_info
  where device_mode not in ('7', '8', '10') and new_ind_cond_info->'19' is null or device_mode in ('-1', '9')
),
coagulant_2627 as (
select
  b.ctl_no,
  b.device_mode,
  b.ind_cond_info,
  b.upd_user_id,
  b.upd_user_last_name,
  b.upd_user_first_name,
  case when scp.unit_decimal_point is null then new_ind_cond_info
    else jsonb_set_lax(
      jsonb_set_lax(
        jsonb_set_lax(new_ind_cond_info,
          '{"26"}',
          (new_ind_cond_info->'26') ||
            jsonb_build_object(
              'value', to_jsonb(ROUND((new_ind_cond_info->'26'->>'value')::numeric, scp.unit_decimal_point)::text),
              'upd_user_id', upd_user_id,
              'upd_user_last_name', upd_user_last_name,
              'upd_user_first_name', upd_user_first_name
            )
        ),
        '{"27"}',
        (new_ind_cond_info->'27') ||
          jsonb_build_object(
            'value', to_jsonb(ROUND((new_ind_cond_info->'27'->>'value')::numeric, scp.unit_decimal_point)::text),
            'upd_user_id', upd_user_id,
            'upd_user_last_name', upd_user_last_name,
            'upd_user_first_name', upd_user_first_name
          )
      ),
      '{"28"}',
      (new_ind_cond_info->'28') ||
        jsonb_build_object(
          'value', to_jsonb(ROUND((new_ind_cond_info->'28'->>'value')::numeric, scp.unit_decimal_point)::text),
          'upd_user_id', upd_user_id,
          'upd_user_last_name', upd_user_last_name,
          'upd_user_first_name', upd_user_first_name
        )
    )
  end AS new_ind_cond_info
from base b
  left join speed_calc_param scp on b.ctl_no::bigint = scp.ctl_no::bigint
),
oneshot_31 as (
  select
    ctl_no,
    case when position(/*accountItemCd*/'2' IN '2467')<1 and position('4' IN /*answerFlg*/'246') > 0 then
      case when /*quantityBefore*/'1' = '0' or /*quantityAfter*/'1' = '0' then '0.0'
        when new_ind_cond_info ?? '26' and new_ind_cond_info->'26' is not null
          then ROUND((new_ind_cond_info->'26'->>'value')::numeric / ((/*quantityBefore*/'1')::numeric / (/*quantityAfter*/'1')::numeric), 1)::text
        when ind_cond_info ?? '26' and ind_cond_info->'26' is not null
          then ROUND((ind_cond_info->'26'->>'value')::numeric / ((/*quantityBefore*/'1')::numeric / (/*quantityAfter*/'1')::numeric), 1)::text
        else '0.0' end
      else new_ind_cond_info->'31'->>'value' end as oneshot_value
  from coagulant_2627
),
flow_32 as (
  select
    ctl_no,
    case when position(/*accountItemCd*/'2' IN '3567')<1 and position('6' IN /*answerFlg*/'246') > 0 then
      case when /*quantityBefore*/'1' = '0' or /*quantityAfter*/'1' = '0' then '0.0'
        when new_ind_cond_info ?? '27' and new_ind_cond_info->'27' is not null
          then ROUND((new_ind_cond_info->'27'->>'value')::numeric / ((/*quantityBefore*/'1')::numeric / (/*quantityAfter*/'1')::numeric), 1)::text
        when ind_cond_info ?? '27' and ind_cond_info->'27' is not null
          then ROUND((ind_cond_info->'27'->>'value')::numeric / ((/*quantityBefore*/'1')::numeric / (/*quantityAfter*/'1')::numeric), 1)::text
        else '0.0' end
      else new_ind_cond_info->'32'->>'value' end as flow_value
  from coagulant_2627
),
upd_data as MATERIALIZED (
  SELECT DISTINCT ON (ctl_no)
    b.ctl_no,
    b.device_mode,
    b.ind_cond_info,
    jsonb_set_lax(
      jsonb_set_lax(b.new_ind_cond_info,
        '{"31"}',
        (b.new_ind_cond_info->'31') ||
          jsonb_build_object(
            'value', to_jsonb(ROUND(LEAST(o.oneshot_value::numeric, 20), 1)::text),
            'upd_user_id', b.upd_user_id,
            'upd_user_last_name', b.upd_user_last_name,
            'upd_user_first_name', b.upd_user_first_name
          )
      ),
      '{"32"}',
      (b.new_ind_cond_info->'32') ||
        jsonb_build_object(
          'value', to_jsonb(ROUND(LEAST(f.flow_value::numeric, 10), 1)::text),
          'upd_user_id', b.upd_user_id,
          'upd_user_last_name', b.upd_user_last_name,
          'upd_user_first_name', b.upd_user_first_name
        )
    ) AS new_ind_cond_info,
    b.upd_user_id
  FROM coagulant_2627 b
    INNER JOIN oneshot_31 o ON b.ctl_no = o.ctl_no
    INNER JOIN flow_32 f ON b.ctl_no = f.ctl_no
)
UPDATE pat_treatment_pattern ptp
SET ind_cond_info = (
  SELECT jsonb_object_agg(k, v)
  FROM jsonb_each(ud.new_ind_cond_info) AS e(k, v)
  WHERE jsonb_typeof(v) <> 'null'
),
    up_date = CURRENT_TIMESTAMP
  FROM upd_data ud
WHERE
  ud.ctl_no = ptp.ctl_no
  AND ptp.facility_cd = /*facilityCd*/'NKKSBR'
  AND ptp.pat_id = /*patId*/'44683'
  /*%if 0 != weeks.get(0)*/
  AND
  ptp.treat_week in /*weeks*/(0)
  /*%end*/
  /*%if 0 != treats.size()*/
  AND
  ptp.ind_treatment_cd in /*treats*/(0)
  /*%end*/
  /*%if 0 != kurs.size()*/
  AND
  ptp.ind_kur_cd in /*kurs*/(0)
  /*%end*/
RETURNING ptp.*
