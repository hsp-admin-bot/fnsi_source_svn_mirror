update pat_name_identification
set
  pat_id_dst= /* receivedPatientInfo.patId */null,
  receive = /* receivedPatientInfo.receive */null,
  is_open = /* receivedPatientInfo.isOpen */null,
  sign_up = /* receivedPatientInfo.signUp */null,
  up_date = /* receivedPatientInfo.upDate */null
where pat_name_id = /* receivedPatientInfo.patNameId */null