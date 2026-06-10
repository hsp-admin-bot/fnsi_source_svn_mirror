update ord_main
set
    ind_treatment_cd = CASE WHEN tmp.treatmentCd IS NULL THEN ind_treatment_cd ELSE tmp.treatmentCd END,
    ind_treatment_name = CASE WHEN tmp.indTreatmentName IS NULL THEN ind_treatment_name ELSE tmp.indTreatmentName END,
    rst_treatment_name = CASE WHEN tmp.rstTreatmentName IS NULL THEN rst_treatment_name ELSE tmp.rstTreatmentName END,
    rst_treatment_cd = CASE WHEN tmp.rstTreatmentCd IS NULL THEN rst_treatment_cd ELSE tmp.rstTreatmentCd::integer END,
    rst_is_update_edition = CASE WHEN tmp.rstIsUpdateEdition IS NULL THEN rst_is_update_edition ELSE tmp.rstIsUpdateEdition END,
-- mod 10705 実績変更治療方法治療条件不正 関  start
--      mod 10443 身体情報・DW・目標体重バグ 関 start
--     ind_cond_info = CASE WHEN tmp.indCondInfo IS NULL THEN ind_cond_info ELSE jsonb_set(CAST(tmp.indCondInfo AS jsonb), '{3}', COALESCE((ind_cond_info -> '3')::jsonb, '{}'::jsonb), false) END,
    ind_cond_info = CASE WHEN tmp.indCondInfo IS NULL THEN ind_cond_info ELSE CASE WHEN CAST(tmp.indCondInfo AS jsonb) @> '{"3": null}' THEN jsonb_set(CAST(tmp.indCondInfo AS jsonb), '{3}', COALESCE((ind_cond_info -> '3')::jsonb, (CAST(tmp.indCondInfo AS jsonb) -> '3')::jsonb), false) ELSE CAST(tmp.indCondInfo AS jsonb) END END,
--      mod 10443 身体情報・DW・目標体重バグ 関  end
-- mod 10705 実績変更治療方法治療条件不正 関  end
    ind_medi_info = CASE WHEN tmp.indMediInfo IS NULL THEN ind_medi_info ELSE CAST(tmp.indMediInfo AS jsonb) END,
    ind_equip_info = CASE WHEN tmp.indEquipInfo IS NULL THEN ind_equip_info ELSE CAST(tmp.indEquipInfo AS jsonb) END,
    ind_ind_comment_info = CASE WHEN tmp.indIndCommentInfo IS NULL THEN ind_ind_comment_info ELSE CAST(tmp.indIndCommentInfo AS jsonb) END,
    ind_device_set_info = CASE WHEN tmp.indDeviceSetInfo IS NULL THEN ind_device_set_info ELSE CAST(tmp.indDeviceSetInfo AS jsonb) END,
    up_date = CASE WHEN tmp.upDate IS NULL THEN up_date ELSE CAST(tmp.upDate AS TIMESTAMP) END,
    up_ind_user_id = CASE WHEN tmp.indUserId IS NULL THEN up_ind_user_id ELSE tmp.indUserId END,
    up_user_id = CASE WHEN tmp.userId IS NULL THEN up_user_id ELSE tmp.userId END,
    ind_va_cd = CASE WHEN tmp.indCondInfo IS NULL THEN case when ind_cond_info -> '2' is not null then  (ind_cond_info -> '2' ->> 'value') ::numeric else ind_va_cd end ELSE
                          case when CAST(tmp.indCondInfo AS jsonb) -> '2' is not null then  (CAST(tmp.indCondInfo AS jsonb) -> '2' ->> 'value') ::numeric else ind_va_cd end END,
    rst_cond_info = CASE WHEN tmp.rstCondInfo IS NULL THEN rst_cond_info ELSE CAST(tmp.rstCondInfo AS jsonb) END,
    rst_medi_info = CASE WHEN tmp.rstMediInfo IS NULL THEN rst_medi_info ELSE CAST(tmp.rstMediInfo AS jsonb) END,
    rst_equip_info = CASE WHEN tmp.rstEquipInfo IS NULL THEN rst_equip_info ELSE CAST(tmp.rstEquipInfo AS jsonb) END,
    is_confirm = CASE WHEN rst_dialysis_state = '6' THEN '0' ELSE is_confirm END,
    rst_dialysis_cnt = CASE WHEN tmp.rstDialysisCnt IS NULL THEN rst_dialysis_cnt ELSE tmp.rstDialysisCnt::integer END,
    rst_purification_cnt = CASE WHEN tmp.rstPurificationCnt IS NULL THEN rst_purification_cnt ELSE tmp.rstPurificationCnt::integer END,
    rst_ind_comment_info = CASE WHEN tmp.rstIndCommentInfo IS NULL THEN rst_ind_comment_info ELSE CAST(tmp.rstIndCommentInfo AS jsonb) END,
--     mod 10705 実績変更治療方法ind_dw不正 関  start
    ind_dw = CASE WHEN CAST(tmp.indCondInfo AS jsonb) @> '{"3": null}' THEN ind_dw ELSE null END
--     mod 10705 実績変更治療方法ind_dw不正 関  end
-- modify by chamaojia 2025-03-05 [11471] add 【ind_device_mode】、【rst_device_mode】 --start
    , ind_device_mode = CASE WHEN tmp.indDeviceMode IS NULL THEN ind_device_mode ELSE tmp.indDeviceMode END
    , rst_device_mode = CASE WHEN tmp.rstDeviceMode IS NULL THEN rst_device_mode ELSE tmp.rstDeviceMode END
FROM
(VALUES
     (
            /*treatmentCd*/null,
            /*ord.indTreatmentName*/null,
            /*ord.indCondInfo*/null,
            /*ord.indMediInfo*/null,
            /*ord.indEquipInfo*/null,
            /*ord.indIndCommentInfo*/null,
            /*ord.indDeviceSetInfo*/null,
            /*ord.rstTreatmentName*/null,
            /*ord.rstTreatmentCd*/null,
            /*ord.rstIsUpdateEdition*/null,
            /*ord.rstCondInfo*/null,
            /*ord.rstMediInfo*/null,
            /*ord.rstEquipInfo*/null,
            /*ord.upDate*/null,
            /*indUserId*/null,
            /*userId*/null,
            /*ord.rstDialysisCnt*/null,
            /*ord.rstPurificationCnt*/null,
            /*ord.rstIndCommentInfo*/null,
            /*ord.indDeviceMode*/null,
            /*ord.rstDeviceMode*/null
        )
) AS tmp (treatmentCd, indTreatmentName, indCondInfo, indMediInfo, indEquipInfo, indIndCommentInfo, indDeviceSetInfo, rstTreatmentName, rstTreatmentCd, rstIsUpdateEdition, rstCondInfo, rstMediInfo, rstEquipInfo, upDate, indUserId, userId, rstDialysisCnt, rstPurificationCnt, rstIndCommentInfo
        , indDeviceMode, rstDeviceMode)
-- modify by chamaojia 2025-03-05 [11471] add 【ind_device_mode】、【rst_device_mode】 --end
where
    ord_no in /* ordNoList */(null)
;
