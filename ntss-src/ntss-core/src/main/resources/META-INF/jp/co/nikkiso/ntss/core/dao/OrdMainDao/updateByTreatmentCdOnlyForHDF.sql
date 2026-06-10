update ord_main
set ind_treatment_cd    = CASE WHEN tmp.treatmentCd IS NULL THEN ind_treatment_cd ELSE tmp.treatmentCd END,
    ind_cond_info       = CASE
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
                                                                                      WHEN jsonb_exists(ind_cond_info, '12') THEN '{}' :: JSONB
                                                                                      ELSE COALESCE(
                                                                                        (
                                                                                          WITH DATA2 AS (
                                                                                            SELECT key, value
                                                                                            FROM jsonb_each(CAST(tmp.indCondInfo AS JSONB))
                                                                                            WHERE key IN ('12', '9', '10')
                                                                                          )
                                                                                          SELECT jsonb_object_agg(key, value)
                                                                                          FROM DATA2
                                                                                        ),
                                                                                        '{}' :: JSONB
                                                                                      )
                                                                                    END) AS jsonb),COALESCE(CAST(tmp.indCondInfoForMerge AS jsonb), '{}'::jsonb) )END,
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
               /*ord.indDeviceSetInfo*/null,
               /*ord.upDate*/null,
               /*indUserId*/null,
               /*userId*/null,
              /*ord.indCondInfoForMerge*/null)) AS tmp (treatmentCd, indCondInfo, indDeviceSetInfo, upDate, indUserId, userId,indCondInfoForMerge)
where ord_no in /* ordNoList */(null)
;
