update ord_main
set
    ind_treatment_cd = CASE WHEN tmp.treatmentCd IS NULL THEN ind_treatment_cd ELSE tmp.treatmentCd END,
    -- mod #11408 特殊浄化の治療方法セットマスタで治療方法の変更できない zkm start
--     ind_cond_info = CASE WHEN tmp.indCondInfo IS NULL THEN ind_cond_info ELSE jsonb_set(CAST(tmp.indCondInfo AS jsonb),'{3}', COALESCE((ind_cond_info -> '3')::jsonb, (CAST(tmp.indCondInfo AS jsonb) -> '3')::jsonb), false) END,
    ind_cond_info = CASE WHEN tmp.indCondInfo IS NULL THEN ind_cond_info ELSE jsonb_set(CAST(tmp.indCondInfo AS jsonb),'{3}', COALESCE((ind_cond_info -> '3')::jsonb, (CAST(tmp.indCondInfo AS jsonb) -> '3')::jsonb, '{}'::jsonb), false) END,
    -- mod #11408 特殊浄化の治療方法セットマスタで治療方法の変更できない zkm end
    ind_medi_info = CASE WHEN tmp.indMediInfo IS NULL THEN ind_medi_info ELSE CAST(tmp.indMediInfo AS jsonb) END,
    ind_equip_info = CASE WHEN tmp.indEquipInfo IS NULL THEN ind_equip_info ELSE CAST(tmp.indEquipInfo AS jsonb) END,
    ind_ind_comment_info = CASE WHEN tmp.indIndCommentInfo IS NULL THEN ind_ind_comment_info ELSE CAST(tmp.indIndCommentInfo AS jsonb) END,
    ind_device_set_info = CASE WHEN tmp.indDeviceSetInfo IS NULL THEN ind_device_set_info ELSE CAST(tmp.indDeviceSetInfo AS jsonb) END,
    up_date = CAST(tmp.upDate AS TIMESTAMP),
    up_ind_user_id = tmp.indUserId,
    up_user_id = tmp.userId,
    ind_va_cd = CASE WHEN tmp.indCondInfo IS NULL THEN case when ind_cond_info -> '2' is not null then  (ind_cond_info -> '2' ->> 'value') ::numeric else ind_va_cd end ELSE
                          case when CAST(tmp.indCondInfo AS jsonb) -> '2' is not null then  (CAST(tmp.indCondInfo AS jsonb) -> '2' ->> 'value') ::numeric else ind_va_cd end END FROM
(VALUES
     (
            /*treatmentCd*/null,
            /*ord.indCondInfo*/null,
            /*ord.indMediInfo*/null,
            /*ord.indEquipInfo*/null,
            /*ord.indIndCommentInfo*/null,
            /*ord.indDeviceSetInfo*/null,
            /*ord.upDate*/null,
            /*indUserId*/null,
            /*userId*/null
        )
) AS tmp (treatmentCd, indCondInfo, indMediInfo, indEquipInfo, indIndCommentInfo, indDeviceSetInfo, upDate, indUserId, userId)
where
    ord_no in /* ordNoList */(null)
;
