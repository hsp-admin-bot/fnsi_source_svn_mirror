SELECT
	patient_id,
	COUNT ( DISTINCT request_id ) AS count
FROM(
	SELECT
		shr_pat_info_id AS request_id,
		CASE
      WHEN from_facility_cd = /* hospitalCd */''
           THEN COALESCE(from_pat_id, to_pat_id)

      WHEN to_facility_cd = /* hospitalCd */''
           THEN COALESCE(to_pat_id, from_pat_id)
    END AS patient_id
				FROM
					shr_pat_info
				WHERE
						(
          		 (from_facility_cd = /* hospitalCd */'' AND
          					(from_pat_id IN /* patientIds */( 1, 2, 3 )  OR to_pat_id IN /* patientIds */( 1, 2, 3 ) ))
          		 OR
          		 (to_facility_cd = /* hospitalCd */''AND to_pat_id IN /* patientIds */( 1, 2, 3 ) )
          		 OR
          		 (to_facility_cd = /* hospitalCd */''AND to_pat_id IS NULL)
          	)


					AND (
						(
							COALESCE ( NULLIF ( is_from_consent, '' ), '0' ) = '0'
							OR COALESCE ( NULLIF ( is_to_consent, '' ), '0' ) = '0'
							OR COALESCE ( NULLIF ( is_pat_consent, '' ), '0' ) = '0'
						)
						AND (
							COALESCE ( NULLIF ( is_from_consent, '' ), '0' ) <> '9'
							AND COALESCE ( NULLIF ( is_to_consent, '' ), '0' ) <> '9'
							AND COALESCE ( NULLIF ( is_pat_consent, '' ), '0' ) <> '9'
						)
					)
					AND is_del = '0'
					AND is_disp = '1'
				) all_pending
		GROUP BY
	patient_id;
