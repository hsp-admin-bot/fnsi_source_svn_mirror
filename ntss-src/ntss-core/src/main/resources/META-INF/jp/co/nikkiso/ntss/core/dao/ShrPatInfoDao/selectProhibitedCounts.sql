SELECT
	patient_id,
	COUNT ( DISTINCT request_id ) AS COUNT
FROM	(
	SELECT
		shr_pat_info_id AS request_id,
      CASE
          WHEN from_facility_cd = /* hospitalCd */'' THEN from_pat_id
          WHEN to_facility_cd = /* hospitalCd */'' AND to_pat_id IS NOT NULL THEN to_pat_id
          WHEN to_facility_cd = /* hospitalCd */'' AND to_pat_id IS NULL THEN from_pat_id
      END AS patient_id
				FROM
					shr_pat_info
				WHERE
					(
						( from_facility_cd =  /* hospitalCd */'' AND from_pat_id IN /* patientIds */( 1, 2, 3 ) )
						OR ( to_facility_cd = /* hospitalCd */'' AND to_pat_id IN /* patientIds */( 1, 2, 3 ) )
						OR ( to_facility_cd = /* hospitalCd */'' AND to_pat_id IS NULL )
					)
						AND (
                    is_from_consent = '9'
                 OR is_to_consent = '9'
                 OR is_pat_consent = '9'
                )
					AND is_del = '0'
					AND is_disp = '1'
				) AS all_pending
		GROUP BY
	patient_id;
