SELECT pat_id,
       facility_cd,
       taboo_allergy_info
 FROM pat_main
 WHERE pat_id IN
  (
	  SELECT
	    from_pat_id
	  FROM
	    shr_pat_info
	  WHERE
	    to_facility_cd = /*facilityCd*/''
	    AND to_pat_id = /*patId*/0
	    AND is_from_consent = '1'
	    AND is_to_consent = '1'
	    AND is_pat_consent = '1'
	    AND is_disp = '1'
	    AND is_del = '0'
  )
;