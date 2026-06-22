UPDATE
  medicine_latest_no
SET
  medi_info_no = /*maxMediInfoNo*/'',
  reg_date = CURRENT_TIMESTAMP,
  up_date = CURRENT_TIMESTAMP
WHERE
  facility_cd = /*facilityCd*/'1'
AND
  pat_id = /*patId*/'1'
