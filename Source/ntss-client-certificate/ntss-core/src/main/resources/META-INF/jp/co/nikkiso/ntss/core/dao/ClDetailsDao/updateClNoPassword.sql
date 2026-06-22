UPDATE client_cer_detail
SET 
  max_download = /*maxDownload*/null,
  expired_date = TO_TIMESTAMP(/*expiredDate*/null, 'YYYY-MM-DD HH24:MI:SS'),
  latest_issued_user = /*latestIssuedUser*/null,
  up_date = /*upDate*/null
WHERE facility_cd = /*facilityCd*/''