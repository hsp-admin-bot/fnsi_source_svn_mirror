UPDATE
  pat_treatment_pattern
SET ind_cond_info       = CASE
                            WHEN tmp.indCondInfo IS NULL THEN ind_cond_info
                            ELSE jsonb_merge_recursive(
                              CAST((WITH DATA1 AS (SELECT key, value FROM jsonb_each(ind_cond_info)),
                                         DATA2 AS (SELECT key, value FROM jsonb_each(CAST(tmp.indCondInfo AS jsonb)))
                                    SELECT COALESCE((SELECT jsonb_object_agg(key, value)
                                                     FROM DATA1
                                                     WHERE key IN (SELECT key FROM DATA2)), '{}'::jsonb) ||
                                           COALESCE((SELECT jsonb_object_agg(key, value)
                                                     FROM DATA2
                                                     WHERE key NOT IN (SELECT key FROM DATA1)
                                                       AND KEY NOT IN ('12', '9', '10', '11')), '{}'::jsonb) || CASE
                                                                                                                  WHEN (ind_cond_info -> '12' ->> 'value') = '0'
                                                                                                                    THEN '{}' :: JSONB
                                                                                                                  ELSE COALESCE(
                                                                                                                    (SELECT jsonb_object_agg(KEY, VALUE)
                                                                                                                     FROM DATA2
                                                                                                                     WHERE KEY IN ('12', '9', '10')),
                                                                                                                    '{}' :: JSONB) END) AS jsonb),COALESCE(CAST(tmp.indCondInfoForMerge AS jsonb), '{}'::jsonb) )END,
    ind_device_set_info = CASE
                            WHEN tmp.indDeviceSetInfo IS NULL THEN ind_device_set_info
                            ELSE jsonb_merge_recursive(ind_device_set_info, CAST(tmp.indDeviceSetInfo AS jsonb)) END,
    up_date             = current_timestamp
FROM (VALUES (
               /*ord.indCondInfo*/null,
               /*ord.indDeviceSetInfo*/null,
               /*ord.indCondInfoForMerge*/null)) AS tmp (indCondInfo, indDeviceSetInfo,indCondInfoForMerge)
WHERE facility_cd = /*facilityCd*/null
  and ind_treatment_cd = /*code*/0
;
