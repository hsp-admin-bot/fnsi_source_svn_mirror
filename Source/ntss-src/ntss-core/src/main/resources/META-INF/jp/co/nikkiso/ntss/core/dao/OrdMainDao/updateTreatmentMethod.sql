UPDATE
  ord_main
SET
  ind_treatment_cd = /*ordMain.indTreatmentCd*/0,
  ind_schedule_user_info = ind_schedule_user_info ||
                           jsonb_build_object( 'ind_user_id', /*indUserId*/null, 'upd_user_id', /*updUserId*/null),
  up_date = CURRENT_TIMESTAMP
WHERE
  ord_no in /*ordNoList*/()
;
