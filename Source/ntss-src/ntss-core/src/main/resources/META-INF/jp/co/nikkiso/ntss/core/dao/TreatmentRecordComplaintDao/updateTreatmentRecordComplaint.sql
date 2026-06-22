update
  ord_main
set
  rst_complaint_info = /*treatmentRecordComplaint.rstComplaintInfo*/'{}'
  , rst_treatment_info = /*treatmentRecordComplaint.rstTreatmentInfo*/'{}'
  , rst_treat_staff_info = /*treatmentRecordComplaint.rstTreatStaffInfo*/'{}'
  , is_confirm = case when rst_dialysis_state = '6' then '0' else is_confirm end
  , up_date = /*treatmentRecordComplaint.upDate*/''
where
  ord_no = /*ordNo*/1
and
  is_del = '0'
;
