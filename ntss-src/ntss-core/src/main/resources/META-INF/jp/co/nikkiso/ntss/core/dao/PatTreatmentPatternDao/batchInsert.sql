insert into pat_treatment_pattern
(pat_id,
 ctl_no,
 facility_cd,
 treat_type,
 ind_treat_start_date,
 ind_treatment_cd,
 ind_kur_cd,
 treat_week,
 ind_sch_info,
 ind_cond_info,
 ind_medi_info,
 ind_equip_info,
 ind_ind_comment_info,
 ind_tare_info,
 ind_off_water_info,
 ind_device_set_info,
 reg_date,
 up_date)
values
/*%for pat : patTreatmentPatternList */
        (
         /*pat.patId*/null,
         /*pat.ctlNo*/null,
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
                      current_timestamp,
                      current_timestamp)
        /*%if pat_has_next */
          /*# "," */
        /*%end */
/*%end*/
