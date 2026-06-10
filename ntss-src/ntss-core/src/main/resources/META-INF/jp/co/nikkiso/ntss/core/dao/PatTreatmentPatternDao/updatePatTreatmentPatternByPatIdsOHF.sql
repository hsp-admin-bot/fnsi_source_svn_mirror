UPDATE
  pat_treatment_pattern
SET ind_cond_info       = CASE
                            WHEN tmp.indCondInfo IS NULL THEN ind_cond_info
                            ELSE jsonb_merge_recursive(
                              CAST((WITH DATA1 AS (SELECT KEY, VALUE FROM jsonb_each(ind_cond_info)),
                                         DATA2 AS (SELECT KEY, VALUE FROM jsonb_each(CAST(tmp.indCondInfo AS jsonb)))
                                    SELECT COALESCE((SELECT jsonb_object_agg(KEY, VALUE)
                                                     FROM DATA1
                                                     WHERE KEY IN (SELECT KEY FROM DATA2)), '{}' :: jsonb) ||
                                           COALESCE((SELECT jsonb_object_agg(KEY, VALUE)
                                                     FROM DATA2
                                                     WHERE KEY NOT IN (SELECT KEY FROM DATA1)
                                                       AND KEY NOT IN ('12', '9', '10', '11')),
                                                    '{}' :: jsonb)) AS jsonb), CASE
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

                                                                                 ELSE COALESCE(
                                                                                   (SELECT jsonb_object_agg('19', VALUE)
                                                                                    FROM jsonb_each(ind_cond_info)
                                                                                    WHERE KEY = '15'),
                                                                                   '{}' :: jsonb) END || CASE
                                                                                                           WHEN (ind_cond_info -> '12' ->> 'value') = '0'
                                                                                                             THEN '{}' :: JSONB
                                                                                                           ELSE COALESCE(
                                                                                                             (WITH DATA2
                                                                                                                     AS (SELECT KEY, VALUE FROM jsonb_each(CAST(tmp.indCondInfo AS jsonb)))
                                                                                                              SELECT jsonb_object_agg(KEY, VALUE)
                                                                                                              FROM DATA2
                                                                                                              WHERE KEY IN ('12', '9', '10')),
                                                                                                             '{}' :: JSONB) END) END,
    ind_device_set_info = CASE
                            WHEN tmp.indDeviceSetInfo IS NULL THEN ind_device_set_info
                            ELSE jsonb_merge_recursive(ind_device_set_info, CAST(tmp.indDeviceSetInfo AS jsonb)) END,
    up_date             = current_timestamp
FROM (VALUES (
               /*ord.indCondInfo*/null,
               /*ord.indDeviceSetInfo*/null)) AS tmp (indCondInfo, indDeviceSetInfo)
WHERE facility_cd = /*facilityCd*/null
  and ind_treatment_cd = /*code*/0
;
