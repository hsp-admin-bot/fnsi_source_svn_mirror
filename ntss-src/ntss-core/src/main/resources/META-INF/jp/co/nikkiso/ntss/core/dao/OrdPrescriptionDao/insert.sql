INSERT INTO ord_prescription
(
   facility_cd,
   pat_id,
   prescription_type,
   issue_date,
   issue_state,
   expiration_date,
   prescription_detail,
   is_disp,
   is_del,
   reg_date,
   up_date
)
VALUES
(
   /*ordPrescription.facilityCd*/null,
   /*ordPrescription.patId*/null,
   /*ordPrescription.prescriptionType*/null,
   replace(/*ordPrescription.issueDate*/null, '/', ''),
   /*ordPrescription.issueState*/'0',
   replace(/*ordPrescription.expirationDate*/null, '/', ''),
   /*ordPrescription.prescriptionDetail*/null,
   /*ordPrescription.isDisp*/'1',
   /*ordPrescription.isDel*/'0',
   /*ordPrescription.regDate*/null,
   /*ordPrescription.upDate*/null
);