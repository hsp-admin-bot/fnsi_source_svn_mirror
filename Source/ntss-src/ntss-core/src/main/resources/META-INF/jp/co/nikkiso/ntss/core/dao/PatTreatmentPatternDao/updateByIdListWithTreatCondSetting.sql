update pat_treatment_pattern
set
    facility_cd = CASE WHEN tmp.facilityCd IS NULL THEN facility_cd ELSE tmp.facilityCd END,
    treat_type = CASE WHEN tmp.treatType IS NULL THEN treat_type ELSE CAST(tmp.treatType AS numeric) END,
    ind_treat_start_date = CASE WHEN tmp.indTreatStartDate IS NULL THEN ind_treat_start_date ELSE tmp.indTreatStartDate END,
    ind_treatment_cd = CASE WHEN tmp.indTreatmentCd IS NULL THEN ind_treatment_cd ELSE CAST(tmp.indTreatmentCd AS INTEGER)END,
    ind_kur_cd = CASE WHEN tmp.indKurCd IS NULL THEN ind_kur_cd ELSE CAST(tmp.indKurCd AS numeric) END,
    treat_week = CASE WHEN tmp.treatWeek IS NULL THEN treat_week ELSE CAST(tmp.treatWeek AS numeric) END,
    ind_sch_info = CASE WHEN tmp.indSchInfo IS NULL THEN ind_sch_info ELSE CAST(tmp.indSchInfo AS jsonb) END,
    ind_cond_info = CASE WHEN tmp.indCondInfo IS NULL THEN ind_cond_info ELSE CAST(tmp.indCondInfo AS jsonb) END,
    ind_medi_info = CASE WHEN tmp.indMediInfo IS NULL THEN ind_medi_info ELSE CAST(tmp.indMediInfo AS jsonb)  END,
    ind_equip_info = CASE WHEN tmp.indEquipInfo IS NULL THEN ind_equip_info ELSE CAST(tmp.indEquipInfo AS jsonb) END,
    ind_ind_comment_info = CASE WHEN tmp.indIndCommentInfo IS NULL THEN ind_ind_comment_info ELSE CAST(tmp.indIndCommentInfo AS jsonb) END,
    ind_tare_info = CASE WHEN tmp.indTareInfo IS NULL THEN ind_tare_info ELSE CAST(tmp.indTareInfo AS jsonb) END,
    ind_off_water_info = CASE WHEN tmp.indOffWaterInfo IS NULL THEN ind_off_water_info ELSE CAST(tmp.indOffWaterInfo AS jsonb) END,
    ind_device_set_info = CASE WHEN tmp.indDeviceSetInfo IS NULL THEN ind_device_set_info ELSE CAST(tmp.indDeviceSetInfo AS jsonb) END,
    up_date = CAST(tmp.upDate AS TIMESTAMP) FROM
(VALUES
    /*%for pat : patList */
     (
            /*pat.facilityCd*/null,
            /*pat.treatType*/null,
            /*pat.indTreatStartDate*/null,
            /*pat.indTreatmentCd*/null,
            /*pat.indKurCd*/null,
            /*pat.treatWeek*/null,
            /*pat.indSchInfo*/null,
            /*pat.indCondInfo*/null,
            /*pat.indMediInfo*/null,
            /*pat.indEquipInfo*/null,
            /*pat.indIndCommentInfo*/null,
            /*pat.indTareInfo*/null,
            /*pat.indOffWaterInfo*/null,
            /*pat.indDeviceSetInfo*/null,
            /*pat.upDate*/null,
            /*pat.patId*/null,
            /*pat.ctlNo*/null
        )
    /*%if pat_has_next */
/*# "," */
    /*%end */
/*%end*/
) AS tmp (facilityCd, treatType, indTreatStartDate, indTreatmentCd, indKurCd, treatWeek, indSchInfo, indCondInfo, indMediInfo, indEquipInfo, indIndCommentInfo, indTareInfo, indOffWaterInfo, indDeviceSetInfo, upDate, patId, ctlNo)
where
    pat_id = tmp.patId
  and
    ctl_no = tmp.ctlNo
;
