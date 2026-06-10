UPDATE
  pat_treatment_pattern
SET ind_cond_info       = CASE
                            WHEN tmp.indCondInfo IS NULL THEN ind_cond_info
                            ELSE jsonb_merge_recursive(
                              CAST((WITH DATA1 AS (SELECT key, value FROM jsonb_each(ind_cond_info)),
                                         DATA2 AS (SELECT key, value
                                                   FROM jsonb_each(CAST(tmp.indCondInfo AS jsonb))
                                                   WHERE key NOT IN /*ord.indCondInfoForNeedleR*/(null))
                                    SELECT COALESCE((SELECT jsonb_object_agg(key, value)
                                                     FROM DATA1
                                                     WHERE key IN (SELECT key FROM DATA2)
                                                        OR KEY IN /*ord.indCondInfoForNeedleA*/(null)), '{}'::jsonb) ||
                                           COALESCE((SELECT jsonb_object_agg(key, value)
                                                     FROM DATA2
                                                     WHERE key NOT IN (SELECT key FROM DATA1)), '{}'::jsonb)) AS jsonb),
                              (CASE
                                 WHEN
                                   ind_cond_info -> '19' is null THEN
                                   CAST('{"20": {"value": "0.0"}, "21": {"value": "1"},  "23": {"value": "36.0"}, "24": {"value": "0.00"}}' AS jsonb) ||
                                   COALESCE(
                                     (SELECT jsonb_object_agg('19', VALUE)
                                      FROM jsonb_each(ind_cond_info)
                                      WHERE KEY = '15'), '{}' :: jsonb)
                                     ||
                                   CAST( (case WHEN POSITION('.' in (ind_cond_info->'17'->>'value')) = 0 then '{"22":{"value":"0"}}'
                                               else concat('{"22":{"value":"0.',lpad('0',length(substring((ind_cond_info->'17'->>'value'),POSITION('.' in (ind_cond_info->'17'->>'value'))+1)),'0'),'"}}') end) as  jsonb)

                                 ELSE COALESCE(CAST(tmp.indCondInfoForMerge AS jsonb), '{}'::jsonb) ||COALESCE(
                                   (SELECT jsonb_object_agg('19', VALUE)
                                    FROM jsonb_each(ind_cond_info)
                                    WHERE KEY = '15'),
                                   '{}' :: jsonb) END) || CASE
                                                            WHEN (ind_cond_info -> '5' ->> 'value') IN /*ord.dialyzerTypeList*/(null)
                                                              THEN CAST('{"5": {"value": null}}' AS jsonb)
                                                            ELSE '{}'::jsonb END) END,
    ind_device_set_info = CASE
                            WHEN tmp.indDeviceSetInfo IS NULL THEN ind_device_set_info
                            ELSE jsonb_merge_recursive(ind_device_set_info, CAST(tmp.indDeviceSetInfo AS jsonb)) END,
    up_date             = current_timestamp
FROM (VALUES (
               /*ord.indCondInfo*/null,
               /*ord.indDeviceSetInfo*/null,
               /*ord.indCondInfoForMerge*/null)) AS tmp (indCondInfo, indDeviceSetInfo, indCondInfoForMerge)
WHERE facility_cd = /*facilityCd*/null
  and ind_treatment_cd = /*code*/0
;
