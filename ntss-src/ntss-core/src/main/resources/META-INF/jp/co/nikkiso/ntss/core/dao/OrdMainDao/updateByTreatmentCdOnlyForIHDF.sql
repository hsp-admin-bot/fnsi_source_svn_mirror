update ord_main
set ind_treatment_cd    = CASE WHEN tmp.treatmentCd IS NULL THEN ind_treatment_cd ELSE tmp.treatmentCd END,
    ind_cond_info       = CASE
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
                                   CAST('{"20": {"value": "0.0"}, "21": {"value": "1"}, "23": {"value": "36.0"}, "24": {"value": "0.00"}}' AS jsonb) ||
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
                                   '{}' :: jsonb) END)
--                                   // del #10154_#10183 zhao start
--                                   || CASE
--                                                                                                              WHEN (ind_cond_info -> '5' ->> 'value') IN /*ord.dialyzerTypeList*/(null)
--                                                                                                                THEN '{}'::jsonb
--                                                                                                              ELSE '{}'::jsonb END
--                                    // del #10154_#10183 zhao end
                                                                                                              ) END,
    ind_device_set_info = CASE
                            WHEN tmp.indDeviceSetInfo IS NULL THEN ind_device_set_info
                            ELSE jsonb_merge_recursive(ind_device_set_info, CAST(tmp.indDeviceSetInfo AS jsonb)) END,
    up_date             = CAST(tmp.upDate AS TIMESTAMP),
    up_ind_user_id      = tmp.indUserId,
    up_user_id          = tmp.userId,
    ind_va_cd           = CASE
                            WHEN tmp.indCondInfo IS NOT NULL THEN case
                                                                    when CAST(tmp.indCondInfo AS jsonb) -> '2' is null
                                                                      then null
                                                                    else ind_va_cd end
                            ELSE ind_va_cd END
FROM (VALUES (
               /*treatmentCd*/null,
               /*ord.indCondInfo*/null,
               /*ord.indCondInfoForMerge*/null,
               /*ord.indDeviceSetInfo*/null,
               /*ord.upDate*/null,
               /*indUserId*/null,
               /*userId*/null)) AS tmp (treatmentCd, indCondInfo, indCondInfoForMerge, indDeviceSetInfo, upDate,
                                        indUserId, userId)
where ord_no in /* ordNoList */(null)
;
