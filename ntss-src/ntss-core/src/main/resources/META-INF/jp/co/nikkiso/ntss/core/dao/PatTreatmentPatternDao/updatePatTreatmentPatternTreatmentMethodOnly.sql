WITH
ord_tmp as (
SELECT
  ptp.ctl_no,
  /*treatmentCd*/null as treatment_cd,
  ptp.ind_cond_info,
  ptp.ind_device_set_info
FROM pat_treatment_pattern ptp
WHERE
  ptp.facility_cd = /*facilityCd*/'NKKSBR'
  AND ptp.pat_id = /*patId*/'44683'
  /*%if 0 != weeks.get(0)*/
  AND ptp.treat_week in /*weeks*/(0)
  /*%end*/
  /*%if treats != null && 0 != treats.size()*/
  AND ptp.ind_treatment_cd in /*treats*/(0)
  /*%end*/
  /*%if kurs != null && 0 != kurs.size()*/
  AND ptp.ind_kur_cd in /*kurs*/(0)
  /*%end*/
  ),
treatment_base as (
SELECT
  mt.treatment_cd,
  mt.device_mode,
  (tcs ->> 'category_no')::int AS category_no,
  item ->> 'ctl_no'             AS ctl_no,
  item ->> 'is_use'             AS is_use
FROM
  mst_treatment mt
  INNER JOIN ord_tmp ot ON mt.treatment_cd = ot.treatment_cd
  CROSS JOIN LATERAL
  jsonb_array_elements(mt.treatment_condition_setting) AS tcs
  CROSS JOIN LATERAL
  jsonb_array_elements(tcs -> 'items') AS item
WHERE
  item ->> 'ctl_no' <> '39'
),
params AS (
  SELECT
  /*updUser.userId*/null as upd_user_id,
  /*updUser.userLastName*/''  as upd_user_last_name,
  /*updUser.userFirstName*/''  as upd_user_first_name,
  /*indUser.userId*/null as ind_user_id,
  /*indUser.userLastName*/'' AS ind_user_last_name,
  /*indUser.userFirstName*/'' AS ind_user_first_name
),
treatment_info AS (
SELECT
  tb.treatment_cd,
  tb.device_mode,
  ((array_agg(ctl_no) FILTER (WHERE is_use = '1')) || ARRAY['1']) AS use_ctl_no_list,
    jsonb_object_agg(
      ctl_no,
      (
        jsonb_build_object(
          'value',
            CASE ctl_no
              WHEN '20' THEN '0.0'
              WHEN '21' THEN '1'
              WHEN '22' THEN '0'
              WHEN '23' THEN '36.0'
              WHEN '24' THEN '0.00'
              ELSE null
            END,
          'input_class', 1,
          'is_editable', '1',
          'cop_order_no', null,

          'ind_user_id', p.ind_user_id,
          'ind_user_last_name', p.ind_user_last_name,
          'ind_user_first_name', p.ind_user_first_name,

          'upd_user_id', p.upd_user_id,
          'upd_user_last_name', p.upd_user_last_name,
          'upd_user_first_name', p.upd_user_first_name
        )
        ||
        CASE
          WHEN ctl_no = '19'
          THEN jsonb_build_object('medicine_type', null)
          ELSE '{}'::jsonb
        END
      )
    )
    FILTER (WHERE is_use = '1') AS ind_cond_info_template

FROM treatment_base tb
CROSS JOIN params p
GROUP BY tb.treatment_cd, tb.device_mode
),
base_ord as (
SELECT
  ptp.ctl_no,
  mt.device_mode,
  ptp.ind_cond_info,
  ptp.ind_device_set_info,
  mt.ind_cond_info_template || (
  SELECT jsonb_object_agg(k, v)
  FROM jsonb_each(ptp.ind_cond_info) e(k, v)
  WHERE k = ANY(mt.use_ctl_no_list)) AS new_ind_cond_info,
  /*updUser.userId*/null as upd_user_id,
  /*updUser.userLastName*/''  as upd_user_last_name,
  /*updUser.userFirstName*/''  as upd_user_first_name,
  /*indUser.userId*/null as ind_user_id,
  /*indUser.userLastName*/'' AS ind_user_last_name,
  /*indUser.userFirstName*/'' AS ind_user_first_name
FROM ord_tmp ptp
  INNER JOIN treatment_info mt
ON ptp.treatment_cd = mt.treatment_cd
),
modified_data as (
  SELECT
    ctl_no,
    device_mode,
    ind_cond_info,
    CASE WHEN device_mode IN (6, 10) THEN
           jsonb_set_lax(new_ind_cond_info, '{12,value}', '"0"', true) #- '{11}'
         ELSE
           CASE WHEN new_ind_cond_info->'12'->>'value' = '0' THEN
             new_ind_cond_info #- '{11}'
           ELSE
             new_ind_cond_info #- '{9}' #- '{10}'
           END
         END AS new_ind_cond_info,
    upd_user_id,
    upd_user_last_name,
    upd_user_first_name,
    ind_user_id,
    ind_user_last_name,
    ind_user_first_name
  FROM base_ord
),
speed_cond_info as (
  SELECT
    ctl_no,
    device_mode,
    ind_cond_info,
    upd_user_id,
    upd_user_last_name,
    upd_user_first_name,
    ind_user_id,
    ind_user_last_name,
    ind_user_first_name,
    COALESCE(((new_ind_cond_info)->'1'->>'value')::numeric, 0) as treat_time,
    case when device_mode in ('7', '8', '10')
      then jsonb_set(new_ind_cond_info, '{19}', (new_ind_cond_info)->'15')
      else new_ind_cond_info
     end as new_ind_cond_info
  FROM modified_data
),
ihdf_data as (
select
  sci.ctl_no,
  sci.device_mode,
  sci.ind_cond_info,
  sci.upd_user_id,
  sci.upd_user_last_name,
  sci.upd_user_first_name,
  sci.ind_user_id,
  sci.ind_user_last_name,
  sci.ind_user_first_name,
  ptp.ind_device_set_info,
  jsonb_set(sci.new_ind_cond_info, '{"24"}',
    (sci.new_ind_cond_info->'24') ||
      jsonb_build_object(
        'value',
          to_jsonb(TRUNC(CEIL(((ptp.ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '201')::numeric * 60 / 1000 * 100) / 100,  2)::TEXT),
        'upd_user_id', sci.upd_user_id,
        'upd_user_last_name', sci.upd_user_last_name,
        'upd_user_first_name', sci.upd_user_first_name,
        'ind_user_id', sci.ind_user_id,
        'ind_user_last_name', sci.ind_user_last_name,
        'ind_user_first_name', sci.ind_user_first_name
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
ihdf_patch_data AS (
   SELECT
    sci.ctl_no,
    CASE
      WHEN device_mode IN (0,1,2,3,6,7,8,9) THEN
        jsonb_set_lax(
          jsonb_set_lax(
            jsonb_set_lax(
              jsonb_set_lax(
                jsonb_set_lax(
                  jsonb_set_lax(
                    jsonb_set_lax(
                      COALESCE(ind_device_set_info, '{}'::jsonb),
                      '{ihdf,dev,A,432}', '"0"', true
                    ),
                    '{ihdf,ind_user_id}', to_jsonb(ind_user_id), true
                  ),
                  '{ihdf,ind_user_last_name}', to_jsonb(ind_user_last_name), true
                ),
                '{ihdf,ind_user_first_name}', to_jsonb(ind_user_first_name), true
              ),
              '{ihdf,upd_user_id}', to_jsonb(upd_user_id), true
            ),
            '{ihdf,upd_user_last_name}', to_jsonb(upd_user_last_name), true
          ),
          '{ihdf,upd_user_first_name}', to_jsonb(upd_user_first_name), true
        )
      ELSE
        COALESCE(ind_device_set_info, '{}'::jsonb)
    END AS ihdf_patch

  FROM speed_cond_info sci
  INNER JOIN pat_treatment_pattern ptp
    ON ptp.pat_id = /*patId*/'44683'
   AND sci.ctl_no = ptp.ctl_no
),
ufr_patch_data AS (
  SELECT
    sci.ctl_no,
   CASE
         WHEN device_mode IN (2,3,6,7,8,10) THEN
           jsonb_set_lax(
             jsonb_set_lax(
               jsonb_set_lax(
                 jsonb_set_lax(
                   jsonb_set_lax(
                     jsonb_set_lax(
                       jsonb_set_lax(
                         jsonb_set_lax(
                           jsonb_set_lax(
                             jsonb_set_lax(
                               jsonb_set_lax(
                                 jsonb_set_lax(
                                   jsonb_set_lax(
                                     jsonb_set_lax(
                                       jsonb_set_lax(
                                         jsonb_set_lax(
                                           COALESCE(indf.ihdf_patch, '{}'::jsonb),
                                           '{ufr,dev,A,291}', '"0"', true
                                         ),
                                         '{ufr,dev,A,292}', '"0"', true
                                       ),
                                       '{ufr,dev,A,293}', '"0"', true
                                     ),
                                     '{ufr,dev,A,294}', '"0"', true
                                   ),
                                   '{ufr,dev,A,295}', '"0"', true
                                 ),
                                 '{ufr,dev,A,296}', '"0"', true
                               ),
                               '{ufr,dev,A,297}', '"0"', true
                             ),
                             '{ufr,dev,A,298}', '"0"', true
                           ),
                           '{ufr,dev,A,299}', '"0"', true
                         ),
                         '{ufr,dev,A,300}', '"0"', true
                       ),
                       '{ufr,ind_user_id}', to_jsonb(ind_user_id), true
                     ),
                     '{ufr,ind_user_last_name}', to_jsonb(ind_user_last_name), true
                   ),
                   '{ufr,ind_user_first_name}', to_jsonb(ind_user_first_name), true
                 ),
                 '{ufr,upd_user_id}', to_jsonb(upd_user_id), true
               ),
               '{ufr,upd_user_last_name}', to_jsonb(upd_user_last_name), true
             ),
             '{ufr,upd_user_first_name}', to_jsonb(upd_user_first_name), true
           )
        ELSE
					COALESCE(indf.ihdf_patch, '{}'::jsonb)
       END AS ufr_patch

  FROM speed_cond_info sci
	INNER JOIN ihdf_patch_data indf
		ON sci.ctl_no = indf.ctl_no
),
dia_patch_data AS (
  SELECT
    sci.ctl_no,
		CASE
         WHEN device_mode IN (2,3,6,7,8,9,10) THEN
           jsonb_set_lax(
             jsonb_set_lax(
               jsonb_set_lax(
                 jsonb_set_lax(
                   jsonb_set_lax(
                     jsonb_set_lax(
                       jsonb_set_lax(
                         COALESCE(ufr.ufr_patch, '{}'::jsonb),
                         '{dia,dev,A,282}', '"0"', true
                       ),
                       '{dia,ind_user_id}', to_jsonb(ind_user_id), true
                     ),
                     '{dia,ind_user_last_name}', to_jsonb(ind_user_last_name), true
                   ),
                   '{dia,ind_user_first_name}', to_jsonb(ind_user_first_name), true
                 ),
                 '{dia,upd_user_id}', to_jsonb(upd_user_id), true
               ),
               '{dia,upd_user_last_name}', to_jsonb(upd_user_last_name), true
             ),
             '{dia,upd_user_first_name}', to_jsonb(upd_user_first_name), true
           )
        ELSE
					COALESCE(ufr.ufr_patch, '{}'::jsonb)
       END AS dia_patch

  FROM speed_cond_info sci
	INNER JOIN ufr_patch_data ufr
		ON sci.ctl_no = ufr.ctl_no
),
dc_patch_data AS (
  SELECT
    sci.ctl_no,
		CASE
         WHEN device_mode IN (6,9) THEN
           jsonb_set_lax(
             jsonb_set_lax(
               jsonb_set_lax(
                 jsonb_set_lax(
                   jsonb_set_lax(
                     jsonb_set_lax(
                       jsonb_set_lax(
                         COALESCE(dia.dia_patch, '{}'::jsonb),
                         '{dc,dev,A,340}', '"0"', true
                       ),
                       '{dc,ind_user_id}', to_jsonb(ind_user_id), true
                     ),
                     '{dc,ind_user_last_name}', to_jsonb(ind_user_last_name), true
                   ),
                   '{dc,ind_user_first_name}', to_jsonb(ind_user_first_name), true
                 ),
                 '{dc,upd_user_id}', to_jsonb(upd_user_id), true
               ),
               '{dc,upd_user_last_name}', to_jsonb(upd_user_last_name), true
             ),
             '{dc,upd_user_first_name}', to_jsonb(upd_user_first_name), true
           )
        ELSE
					COALESCE(dia.dia_patch, '{}'::jsonb)
       END AS dc_patch

  FROM speed_cond_info sci
	INNER JOIN dia_patch_data dia
		ON sci.ctl_no = dia.ctl_no
),
qbqd_patch_data AS (
  SELECT
    sci.ctl_no,
		CASE
         WHEN device_mode IN (6,9,10) THEN
           jsonb_set_lax(
             jsonb_set_lax(
               jsonb_set_lax(
                 jsonb_set_lax(
                   jsonb_set_lax(
                     jsonb_set_lax(
                       jsonb_set_lax(
                         jsonb_set_lax(
                           COALESCE(dc.dc_patch, '{}'::jsonb),
                           '{qbqd,dev,A,431}', '"0"', true
                         ),
                         '{qbqd,dev,A,430}', '"0"', true
                       ),
                       '{qbqd,ind_user_id}', to_jsonb(ind_user_id), true
                     ),
                     '{qbqd,ind_user_last_name}', to_jsonb(ind_user_last_name), true
                   ),
                   '{qbqd,ind_user_first_name}', to_jsonb(ind_user_first_name), true
                 ),
                 '{qbqd,upd_user_id}', to_jsonb(upd_user_id), true
               ),
               '{qbqd,upd_user_last_name}', to_jsonb(upd_user_last_name), true
             ),
             '{qbqd,upd_user_first_name}', to_jsonb(upd_user_first_name), true
           )
        ELSE
					COALESCE(dc.dc_patch, '{}'::jsonb)
       END AS qbqd_patch

  FROM speed_cond_info sci
	INNER JOIN dc_patch_data dc
		ON sci.ctl_no = dc.ctl_no
),
ufr_patch_data_290 AS (
  SELECT
    sci.ctl_no,
		CASE
         WHEN device_mode IN (9) THEN
           jsonb_set_lax(
             jsonb_set_lax(
               jsonb_set_lax(
                 jsonb_set_lax(
                   jsonb_set_lax(
                     jsonb_set_lax(
                       jsonb_set_lax(
                         COALESCE(qbqd.qbqd_patch, '{}'::jsonb),
                         '{ufr,dev,A,290}', '"0"', true
                       ),
                       '{ufr,ind_user_id}', to_jsonb(ind_user_id), true
                     ),
                     '{ufr,ind_user_last_name}', to_jsonb(ind_user_last_name), true
                   ),
                   '{ufr,ind_user_first_name}', to_jsonb(ind_user_first_name), true
                 ),
                 '{ufr,upd_user_id}', to_jsonb(upd_user_id), true
               ),
               '{ufr,upd_user_last_name}', to_jsonb(upd_user_last_name), true
             ),
             '{ufr,upd_user_first_name}', to_jsonb(upd_user_first_name), true
           )
        ELSE
					COALESCE(qbqd.qbqd_patch, '{}'::jsonb)
       END AS ufr_patch

  FROM speed_cond_info sci
	INNER JOIN qbqd_patch_data qbqd
		ON sci.ctl_no = qbqd.ctl_no
),
na_patch_data AS (
  SELECT
    sci.ctl_no,
		CASE
         WHEN device_mode IN (9) THEN
           jsonb_set_lax(
             jsonb_set_lax(
               jsonb_set_lax(
                 jsonb_set_lax(
                   jsonb_set_lax(
                     jsonb_set_lax(
                       jsonb_set_lax(
                         COALESCE(ufr.ufr_patch, '{}'::jsonb),
                         '{na,dev,A,315}', '"0"', true
                       ),
                       '{na,ind_user_id}', to_jsonb(ind_user_id), true
                     ),
                     '{na,ind_user_last_name}', to_jsonb(ind_user_last_name), true
                   ),
                   '{na,ind_user_first_name}', to_jsonb(ind_user_first_name), true
                 ),
                 '{na,upd_user_id}', to_jsonb(upd_user_id), true
               ),
               '{na,upd_user_last_name}', to_jsonb(upd_user_last_name), true
             ),
             '{na,upd_user_first_name}', to_jsonb(upd_user_first_name), true
           )
        ELSE
					COALESCE(ufr.ufr_patch, '{}'::jsonb)
       END AS na_patch

  FROM speed_cond_info sci
	INNER JOIN ufr_patch_data_290 ufr
		ON sci.ctl_no = ufr.ctl_no
),
bvufc_patch_data AS (
  SELECT
    sci.ctl_no,
		CASE
         WHEN device_mode IN (9,10) THEN
           jsonb_set_lax(
             jsonb_set_lax(
               jsonb_set_lax(
                 jsonb_set_lax(
                   jsonb_set_lax(
                     jsonb_set_lax(
                       jsonb_set_lax(
                         COALESCE(na.na_patch, '{}'::jsonb),
                         '{bvufc,dev,A,196}', '"0"', true
                       ),
                       '{bvufc,ind_user_id}', to_jsonb(ind_user_id), true
                     ),
                     '{bvufc,ind_user_last_name}', to_jsonb(ind_user_last_name), true
                   ),
                   '{bvufc,ind_user_first_name}', to_jsonb(ind_user_first_name), true
                 ),
                 '{bvufc,upd_user_id}', to_jsonb(upd_user_id), true
               ),
               '{bvufc,upd_user_last_name}', to_jsonb(upd_user_last_name), true
             ),
             '{bvufc,upd_user_first_name}', to_jsonb(upd_user_first_name), true
           )
        ELSE
					COALESCE(na.na_patch, '{}'::jsonb)
       END AS bvufc_patch

  FROM speed_cond_info sci
	INNER JOIN na_patch_data na
		ON sci.ctl_no = na.ctl_no
),
upd_data as (
  select
    sci.ctl_no,
    sci.device_mode,
    sci.ind_cond_info,
    sci.upd_user_id,
    sci.upd_user_last_name,
    sci.upd_user_first_name,
	sci.ind_user_id,
    sci.ind_user_last_name,
    sci.ind_user_first_name,
    CASE WHEN ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '389') = '0' THEN
        CASE WHEN (sci.new_ind_cond_info)->'20'->>'value' = '-1'
          THEN jsonb_set(
            jsonb_set(sci.new_ind_cond_info,
              '{"20"}',
              (sci.new_ind_cond_info->'20')
                || jsonb_build_object(
                  'value', to_jsonb(ROUND(0,  1)::TEXT),
                  'upd_user_id', sci.upd_user_id,
                  'upd_user_last_name', sci.upd_user_last_name,
                  'upd_user_first_name', sci.upd_user_first_name,
                  'ind_user_id', sci.ind_user_id,
                  'ind_user_last_name', sci.ind_user_last_name,
                  'ind_user_first_name', sci.ind_user_first_name
                )
            ),
            '{"24"}',
            (sci.new_ind_cond_info->'24')
              || jsonb_build_object(
                'value', to_jsonb(ROUND(0,  2)::TEXT),
                'upd_user_id', sci.upd_user_id,
                'upd_user_last_name', sci.upd_user_last_name,
                'upd_user_first_name', sci.upd_user_first_name,
                'ind_user_id', sci.ind_user_id,
                'ind_user_last_name', sci.ind_user_last_name,
                'ind_user_first_name', sci.ind_user_first_name
              )
          )
          WHEN sci.treat_time > ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '389')::numeric
            THEN jsonb_set(sci.new_ind_cond_info,
              '{"24"}',
              (sci.new_ind_cond_info->'24')
                || jsonb_build_object(
                  'value', to_jsonb(TRUNC(CEIL(COALESCE(((sci.new_ind_cond_info)->'20'->>'value')::numeric, 0) * 60 /
                  (sci.treat_time - ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric) * 100)/100, 2)::TEXT),
                  'upd_user_id', sci.upd_user_id,
                  'upd_user_last_name', sci.upd_user_last_name,
                  'upd_user_first_name', sci.upd_user_first_name,
                  'ind_user_id', sci.ind_user_id,
                  'ind_user_last_name', sci.ind_user_last_name,
                  'ind_user_first_name', sci.ind_user_first_name
                )
            )
          ELSE jsonb_set(sci.new_ind_cond_info,
            '{"24"}',
            (sci.new_ind_cond_info->'24')
              || jsonb_build_object(
                'value', to_jsonb(ROUND(0,  2)::TEXT),
                'upd_user_id', sci.upd_user_id,
                'upd_user_last_name', sci.upd_user_last_name,
                'upd_user_first_name', sci.upd_user_first_name,
                'ind_user_id', sci.ind_user_id,
                'ind_user_last_name', sci.ind_user_last_name,
                'ind_user_first_name', sci.ind_user_first_name
              )
          ) END
      WHEN ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '389')::numeric = '1' THEN
        CASE WHEN (sci.new_ind_cond_info)->'24'->>'value' = '-1'
          THEN jsonb_set(
            jsonb_set(sci.new_ind_cond_info,
              '{"20"}',
              (sci.new_ind_cond_info->'20') ||
                jsonb_build_object(
                  'value', to_jsonb(ROUND(0,  1)::TEXT),
                  'upd_user_id', sci.upd_user_id,
                  'upd_user_last_name', sci.upd_user_last_name,
                  'upd_user_first_name', sci.upd_user_first_name,
                  'ind_user_id', sci.ind_user_id,
                  'ind_user_last_name', sci.ind_user_last_name,
                  'ind_user_first_name', sci.ind_user_first_name
                )
            ),
            '{"24"}',
            (sci.new_ind_cond_info->'24') ||
              jsonb_build_object(
                'value', to_jsonb(ROUND(0,  2)::TEXT),
                'upd_user_id', sci.upd_user_id,
                'upd_user_last_name', sci.upd_user_last_name,
                'upd_user_first_name', sci.upd_user_first_name,
                'ind_user_id', sci.ind_user_id,
                'ind_user_last_name', sci.ind_user_last_name,
                'ind_user_first_name', sci.ind_user_first_name
              )
          )
        WHEN sci.treat_time > ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric
          THEN jsonb_set(sci.new_ind_cond_info,
            '{"20"}',
            (sci.new_ind_cond_info->'20') ||
              jsonb_build_object(
                'value', to_jsonb(TRUNC(COALESCE(((sci.new_ind_cond_info)->'24'->>'value')::numeric, 0) *
                (sci.treat_time -((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric) / 60, 1)::TEXT),
                'upd_user_id', sci.upd_user_id,
                'upd_user_last_name', sci.upd_user_last_name,
                'upd_user_first_name', sci.upd_user_first_name,
                'ind_user_id', sci.ind_user_id,
                'ind_user_last_name', sci.ind_user_last_name,
                'ind_user_first_name', sci.ind_user_first_name
              )
          )
        ELSE jsonb_set(sci.new_ind_cond_info,
          '{"20"}',
          (sci.new_ind_cond_info->'20') ||
            jsonb_build_object(
              'value', to_jsonb(ROUND(0, 1)::TEXT),
              'upd_user_id', sci.upd_user_id,
              'upd_user_last_name', sci.upd_user_last_name,
              'upd_user_first_name', sci.upd_user_first_name,
              'ind_user_id', sci.ind_user_id,
              'ind_user_last_name', sci.ind_user_last_name,
              'ind_user_first_name', sci.ind_user_first_name
            )
        ) END
      WHEN ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '389')::numeric = '2' THEN
        CASE WHEN COALESCE(((sci.new_ind_cond_info)->'21'->>'value')::numeric, '1') = '1'
          AND sci.treat_time > ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric
          THEN jsonb_set(
            jsonb_set(sci.new_ind_cond_info,
              '{"20"}',
              (sci.new_ind_cond_info->'20') ||
                jsonb_build_object(
                  'value', to_jsonb(TRUNC(TRUNC(CEIL((COALESCE((sci.new_ind_cond_info #>> '{"14", "value"}')::numeric, 0)
                    * COALESCE(((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '379')::numeric, 0) * 60 / 100000) * 100000) / 100000, 5)
                    * (sci.treat_time -
                  ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric) / 60, 1)::TEXT),
                  'upd_user_id', sci.upd_user_id,
                  'upd_user_last_name', sci.upd_user_last_name,
                  'upd_user_first_name', sci.upd_user_first_name,
                  'ind_user_id', sci.ind_user_id,
                  'ind_user_last_name', sci.ind_user_last_name,
                  'ind_user_first_name', sci.ind_user_first_name
                )
            ),
            '{"24"}',
            (sci.new_ind_cond_info->'24') ||
              jsonb_build_object(
                'value', to_jsonb(TRUNC(CEIL((COALESCE((sci.new_ind_cond_info #>> '{"14", "value"}')::numeric, 0)
                  * COALESCE(((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '379')::numeric, 0) * 60 / 100000) * 100) / 100, 2)::TEXT)::jsonb,
                'upd_user_id', sci.upd_user_id,
                'upd_user_last_name', sci.upd_user_last_name,
                'upd_user_first_name', sci.upd_user_first_name,
                'ind_user_id', sci.ind_user_id,
                'ind_user_last_name', sci.ind_user_last_name,
                'ind_user_first_name', sci.ind_user_first_name
              )
          )
        WHEN COALESCE(((sci.new_ind_cond_info)->'21'->>'value')::numeric, '1') != '1'
          AND sci.treat_time > ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric
          THEN jsonb_set(
            jsonb_set(sci.new_ind_cond_info,
              '{"20"}',
              (sci.new_ind_cond_info->'20') ||
                jsonb_build_object(
                  'value', to_jsonb(TRUNC(TRUNC(CEIL((COALESCE((sci.new_ind_cond_info #>> '{"14", "value"}')::numeric, 0)
                    * COALESCE(((pm.device_set_info) -> 'ope' -> 'dev' -> 'B' ->> '39')::numeric, 0) * 60 / 100000) * 100000) / 100000, 5)
                    * (sci.treat_time - ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric) / 60, 1)::TEXT),
                  'upd_user_id', sci.upd_user_id,
                  'upd_user_last_name', sci.upd_user_last_name,
                  'upd_user_first_name', sci.upd_user_first_name,
                  'ind_user_id', sci.ind_user_id,
                  'ind_user_last_name', sci.ind_user_last_name,
                  'ind_user_first_name', sci.ind_user_first_name
                )
            ),
            '{"24"}',
            (sci.new_ind_cond_info->'24') ||
              jsonb_build_object(
                'value', to_jsonb(TRUNC(CEIL((COALESCE((sci.new_ind_cond_info #>> '{"14", "value"}')::numeric, 0)
                  * COALESCE(((pm.device_set_info) -> 'ope' -> 'dev' -> 'B' ->> '39')::numeric, 0) * 60 / 100000) * 100) / 100, 2)::TEXT),
                'upd_user_id', sci.upd_user_id,
                'upd_user_last_name', sci.upd_user_last_name,
                'upd_user_first_name', sci.upd_user_first_name,
                'ind_user_id', sci.ind_user_id,
                'ind_user_last_name', sci.ind_user_last_name,
                'ind_user_first_name', sci.ind_user_first_name
              )
          )
        WHEN COALESCE(((sci.new_ind_cond_info)->'21'->>'value')::numeric, '1') = '1'
          AND sci.treat_time <= ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric
          THEN jsonb_set(
            jsonb_set(sci.new_ind_cond_info,
              '{"20"}',
              (sci.new_ind_cond_info->'20') ||
                jsonb_build_object(
                  'value', to_jsonb(TRUNC(0, 1)::TEXT),
                  'upd_user_id', sci.upd_user_id,
                  'upd_user_last_name', sci.upd_user_last_name,
                  'upd_user_first_name', sci.upd_user_first_name,
                  'ind_user_id', sci.ind_user_id,
                  'ind_user_last_name', sci.ind_user_last_name,
                  'ind_user_first_name', sci.ind_user_first_name
                )
            ),
            '{"24"}',
            (sci.new_ind_cond_info->'24') ||
              jsonb_build_object(
                'value', to_jsonb(TRUNC(CEIL((COALESCE((sci.new_ind_cond_info #>> '{"14", "value"}')::numeric, 0)
                  * COALESCE(((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '379')::numeric, 0) * 60 / 100000) * 100) / 100, 2)::TEXT),
                'upd_user_id', sci.upd_user_id,
                'upd_user_last_name', sci.upd_user_last_name,
                'upd_user_first_name', sci.upd_user_first_name,
                'ind_user_id', sci.ind_user_id,
                'ind_user_last_name', sci.ind_user_last_name,
                'ind_user_first_name', sci.ind_user_first_name
              )
          )
        WHEN COALESCE(((sci.new_ind_cond_info)->'21'->>'value')::numeric, '1') != '1'
          AND sci.treat_time <= ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric
          THEN jsonb_set(
            jsonb_set(sci.new_ind_cond_info,
              '{"20"}',
              (sci.new_ind_cond_info->'20') ||
                jsonb_build_object(
                  'value', to_jsonb(TRUNC(0, 1)::TEXT),
                  'upd_user_id', sci.upd_user_id,
                  'upd_user_last_name', sci.upd_user_last_name,
                  'upd_user_first_name', sci.upd_user_first_name,
                  'ind_user_id', sci.ind_user_id,
                  'ind_user_last_name', sci.ind_user_last_name,
                  'ind_user_first_name', sci.ind_user_first_name
                )
            ),
            '{"24"}',
            (sci.new_ind_cond_info->'24') ||
              jsonb_build_object(
                'value', to_jsonb(TRUNC(CEIL((COALESCE((sci.new_ind_cond_info #>> '{"14", "value"}')::numeric, 0)
                * COALESCE(((pm.device_set_info) -> 'ope' -> 'dev' -> 'B' ->> '39')::numeric, 0) * 60 / 100000) * 100) / 100, 2)::TEXT),
                'upd_user_id', sci.upd_user_id,
                'upd_user_last_name', sci.upd_user_last_name,
                'upd_user_first_name', sci.upd_user_first_name,
                'ind_user_id', sci.ind_user_id,
                'ind_user_last_name', sci.ind_user_last_name,
                'ind_user_first_name', sci.ind_user_first_name
              )
          )
        ELSE sci.new_ind_cond_info END
      WHEN ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '389')::numeric = '3' THEN
        jsonb_set(
          jsonb_set(sci.new_ind_cond_info,
            '{"20"}',
            (sci.new_ind_cond_info->'20') ||
              jsonb_build_object(
                'value', to_jsonb('-1'::TEXT),
                'upd_user_id', sci.upd_user_id,
                'upd_user_last_name', sci.upd_user_last_name,
                'upd_user_first_name', sci.upd_user_first_name,
                'ind_user_id', sci.ind_user_id,
                'ind_user_last_name', sci.ind_user_last_name,
                'ind_user_first_name', sci.ind_user_first_name
              )
          ),
          '{"24"}',
          (sci.new_ind_cond_info->'24') ||
            jsonb_build_object(
              'value', to_jsonb('-1'::TEXT),
              'upd_user_id', sci.upd_user_id,
              'upd_user_last_name', sci.upd_user_last_name,
              'upd_user_first_name', sci.upd_user_first_name,
              'ind_user_id', sci.ind_user_id,
              'ind_user_last_name', sci.ind_user_last_name,
              'ind_user_first_name', sci.ind_user_first_name
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
    ind_user_id,
    ind_user_last_name,
    ind_user_first_name,
    CASE WHEN ((ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '432')::numeric = '0'
      THEN jsonb_set(new_ind_cond_info,
        '{"20"}',
        (new_ind_cond_info->'20') ||
          jsonb_build_object(
            'value', to_jsonb(TRUNC(LEAST(((ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '200')::numeric *
              ihdf_liquid_cnt / 1000, ((ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '205')::numeric), 1)::TEXT),
            'upd_user_id', upd_user_id,
            'upd_user_last_name', upd_user_last_name,
            'upd_user_first_name', upd_user_first_name,
            'ind_user_id', ind_user_id,
            'ind_user_last_name', ind_user_last_name,
            'ind_user_first_name', ind_user_first_name
          )
      )
      ELSE jsonb_set(new_ind_cond_info,
        '{"20"}',
        (new_ind_cond_info->'20') ||
          jsonb_build_object(
            'value', to_jsonb(TRUNC(LEAST(COALESCE((SELECT SUM(COALESCE(((ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> (435 + i)::text)::numeric, 0))
              FROM generate_series(0, LEAST(ihdf_liquid_cnt, 16) - 1) AS i)::numeric / 1000, 0)
              ,((ind_device_set_info) -> 'ihdf' -> 'dev' -> 'A' ->> '205')::numeric), 1)::TEXT),
            'upd_user_id', upd_user_id,
            'upd_user_last_name', upd_user_last_name,
            'upd_user_first_name', upd_user_first_name,
            'ind_user_id', ind_user_id,
            'ind_user_last_name', ind_user_last_name,
            'ind_user_first_name', ind_user_first_name
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
    sci.ind_user_id,
    sci.ind_user_last_name,
    sci.ind_user_first_name,
    CASE WHEN (sci.new_ind_cond_info)->'20'->>'value' = '-1'
      THEN jsonb_set(
        jsonb_set(sci.new_ind_cond_info,
          '{"20"}',
          (sci.new_ind_cond_info->'20') ||
            jsonb_build_object(
              'value', to_jsonb(ROUND(0,  1)::TEXT),
              'upd_user_id', sci.upd_user_id,
              'upd_user_last_name', sci.upd_user_last_name,
              'upd_user_first_name', sci.upd_user_first_name,
              'ind_user_id', sci.ind_user_id,
              'ind_user_last_name', sci.ind_user_last_name,
              'ind_user_first_name', sci.ind_user_first_name
            )
        ),
        '{"24"}',
        (sci.new_ind_cond_info->'24') ||
          jsonb_build_object(
            'value', to_jsonb(ROUND(0,  2)::TEXT),
            'upd_user_id', sci.upd_user_id,
            'upd_user_last_name', sci.upd_user_last_name,
            'upd_user_first_name', sci.upd_user_first_name,
            'ind_user_id', sci.ind_user_id,
            'ind_user_last_name', sci.ind_user_last_name,
            'ind_user_first_name', sci.ind_user_first_name
          )
      )
      WHEN sci.treat_time > ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric
        THEN jsonb_set(sci.new_ind_cond_info,
          '{"24"}',
          (sci.new_ind_cond_info->'24') ||
            jsonb_build_object(
              'value', to_jsonb(TRUNC(CEIL(COALESCE(((sci.new_ind_cond_info)->'20'->>'value')::numeric, 0) * 60 /
                (sci.treat_time - ((pm.device_set_info) -> 'ope' -> 'dev' -> 'A' ->> '398')::numeric) *100)/100, 2)::TEXT),
              'upd_user_id', sci.upd_user_id,
              'upd_user_last_name', sci.upd_user_last_name,
              'upd_user_first_name', sci.upd_user_first_name,
              'ind_user_id', sci.ind_user_id,
              'ind_user_last_name', sci.ind_user_last_name,
              'ind_user_first_name', sci.ind_user_first_name
            )
        )
      ELSE jsonb_set(sci.new_ind_cond_info,
        '{"24"}',
        (sci.new_ind_cond_info->'24') ||
          jsonb_build_object(
            'value', to_jsonb(ROUND(0,  2)::TEXT),
            'upd_user_id', sci.upd_user_id,
            'upd_user_last_name', sci.upd_user_last_name,
            'upd_user_first_name', sci.upd_user_first_name,
            'ind_user_id', sci.ind_user_id,
            'ind_user_last_name', sci.ind_user_last_name,
            'ind_user_first_name', sci.ind_user_first_name
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
    ind_user_id,
    ind_user_last_name,
    ind_user_first_name,
    new_ind_cond_info
  from speed_cond_info
  where device_mode not in ('7', '8', '10') and new_ind_cond_info->'19' is null or device_mode in ('-1', '9')
)
UPDATE pat_treatment_pattern ptp
SET ind_treatment_cd = /*treatmentCd*/null,
    ind_cond_info = (
    SELECT jsonb_object_agg(k, v)
    FROM jsonb_each(ud.new_ind_cond_info) AS e(k, v)
    WHERE jsonb_typeof(v) <> 'null'
    ),
    ind_device_set_info = bv.bvufc_patch,
    up_date = CURRENT_TIMESTAMP
    FROM upd_data ud
    LEFT JOIN bvufc_patch_data bv
        ON ud.ctl_no = bv.ctl_no
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
