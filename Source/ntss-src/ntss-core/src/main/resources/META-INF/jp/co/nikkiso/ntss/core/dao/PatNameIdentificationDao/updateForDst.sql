update pat_name_identification
set
  approve = /* publicPatientInfo.approve */null,
  is_open = /* publicPatientInfo.isOpen */null,
  approve_date = /* publicPatientInfo.approveDate */null,
  up_date = /* publicPatientInfo.upDate */null,
  doctor_in_charge = /* publicPatientInfo.doctorInCharge */null
where pat_name_id = /* publicPatientInfo.patNameId */null
