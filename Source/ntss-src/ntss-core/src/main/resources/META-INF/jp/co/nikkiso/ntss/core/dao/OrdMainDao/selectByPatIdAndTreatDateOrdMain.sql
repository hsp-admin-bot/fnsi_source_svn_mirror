WITH ssi_order_treat_info AS ( 
  SELECT
    info->>'key2' AS key2
    , COALESCE(NULLIF(info->>'value', ''), info->>'default_v') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = /*facilityCd*/'000000'
    AND is_del = '0' 
    AND COALESCE(info->>'key0','') = /*coopVersion*/''
    AND info->>'key1' = 'SSI_ORDER_TREAT'
    AND info->>'key2' = /*indTreatmentName*/''
),
ssi_in_hospital_cd AS ( 
  SELECT
    info->>'key2' AS key2
    , COALESCE(NULLIF(info->>'value', ''), info->>'default_v') AS VALUE 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = /*facilityCd*/'000000'
    AND is_del = '0' 
    AND COALESCE(info->>'key0','') = /*coopVersion*/''
    AND info->>'key1' = 'SSI_ORDER_RECV'
    AND info->>'key2' = 'IN_HOSPITAL_CD'
),
treatment_info AS ( 
	SELECT
		treatment_cd
	FROM
		mst_treatment
	WHERE
		is_del = '0'
	AND is_disp = '1'
	AND facility_cd = /*facilityCd*/'000000'
	AND ((
      CASE (SELECT VALUE FROM ssi_in_hospital_cd)
        WHEN '1' THEN in_hospital_cd_a1 = (SELECT VALUE FROM ssi_order_treat_info) AND COALESCE(in_hospital_cd_a1,'') <> ''
        WHEN '2' THEN in_hospital_cd_a2 = (SELECT VALUE FROM ssi_order_treat_info) AND COALESCE(in_hospital_cd_a2,'') <> ''
        WHEN '3' THEN in_hospital_cd_a3 = (SELECT VALUE FROM ssi_order_treat_info) AND COALESCE(in_hospital_cd_a3,'') <> ''
        WHEN '4' THEN in_hospital_cd_a4 = (SELECT VALUE FROM ssi_order_treat_info) AND COALESCE(in_hospital_cd_a4,'') <> ''
      END
      AND
      CASE
        WHEN /*treatDate*/null >= in_hosp_a_startdate
        AND /*treatDate*/null >= in_hosp_b_startdate
            THEN CASE
                WHEN in_hosp_a_startdate >= in_hosp_b_startdate
                    THEN True
                WHEN in_hosp_a_startdate < in_hosp_b_startdate
                    THEN False
                END
        WHEN /*treatDate*/null >= in_hosp_a_startdate
        AND (/*treatDate*/null < in_hosp_b_startdate
            OR in_hosp_b_startdate IS NULL)
            THEN True
        WHEN (/*treatDate*/null < in_hosp_a_startdate
            OR in_hosp_a_startdate IS NULL)
        AND /*treatDate*/null >= in_hosp_b_startdate
            THEN False
        ELSE False
      END
  	)
	OR (
      CASE (SELECT VALUE FROM ssi_in_hospital_cd)
	WHEN '1' THEN in_hospital_cd_b1 = (SELECT VALUE FROM ssi_order_treat_info) AND COALESCE(in_hospital_cd_b1,'') <> ''
	WHEN '2' THEN in_hospital_cd_b2 = (SELECT VALUE FROM ssi_order_treat_info) AND COALESCE(in_hospital_cd_b2,'') <> ''
	WHEN '3' THEN in_hospital_cd_b3 = (SELECT VALUE FROM ssi_order_treat_info) AND COALESCE(in_hospital_cd_b3,'') <> ''
	WHEN '4' THEN in_hospital_cd_b4 = (SELECT VALUE FROM ssi_order_treat_info) AND COALESCE(in_hospital_cd_b4,'') <> ''
      END
      AND
      CASE
        WHEN /*treatDate*/null >= in_hosp_a_startdate
        AND /*treatDate*/null >= in_hosp_b_startdate
            THEN CASE
                WHEN in_hosp_a_startdate >= in_hosp_b_startdate
                    THEN False
                WHEN in_hosp_a_startdate < in_hosp_b_startdate
                    THEN True
                END
        WHEN /*treatDate*/null >= in_hosp_a_startdate
        AND (/*treatDate*/null < in_hosp_b_startdate
            OR in_hosp_b_startdate IS NULL)
            THEN False
        WHEN (/*treatDate*/null < in_hosp_a_startdate
            OR in_hosp_a_startdate IS NULL)
        AND /*treatDate*/null >= in_hosp_b_startdate
            THEN True
        ELSE False
      END
  ))
  LIMIT 1
),
ord_main_exists AS ( 
	SELECT
		ord.ord_no
	FROM
		ord_main ord
	WHERE
		ord.pat_id =/*pat_id*/0
	AND
		ord.facility_cd = /*facilityCd*/'000000'
/*%if null != treatDate && treatDate != "null" */
	AND
		ord.treat_date >= /*treatDate*/null
/*%end*/
/*%if null != treatDate && treatDate != "null" */
	AND
		ord.treat_date <= /*treatDate*/null
/*%end*/
	AND
		ord.is_del = '0'
	ORDER BY
		ord.treat_date,
		ord.ind_treat_start_time
),
journal_exists AS ( 
	SELECT
		ord.ord_no
	FROM
		ord_main ord
	INNER JOIN sys_coop_journal journal 
	ON ord.ord_no = journal.ord_no
	WHERE
		ord.pat_id =/*pat_id*/0
	AND
		ord.facility_cd = /*facilityCd*/'000000'
/*%if null != treatDate && treatDate != "null" */
	AND
		ord.treat_date >= /*treatDate*/null
/*%end*/
/*%if null != treatDate && treatDate != "null" */
	AND
		ord.treat_date <= /*treatDate*/null
/*%end*/
	AND
		journal.coop_cd = /*coopCd*/''
	AND
		journal.coop_cd_index = /*coopCdIndex*/''
	AND
		ord.is_del = '0'
	ORDER BY
		ord.treat_date,
		ord.ind_treat_start_time
  LIMIT 1
)
SELECT
	ord.ord_no,
	ord.rst_dialysis_state,
	ord.treat_date,
	ord.ind_kur_cd,
	ord.ind_treatment_cd,
	ord.treat_week,
	ord.ind_bed_cd,
	ord.ind_treat_start_time
FROM
	ord_main AS ord
	LEFT JOIN mst_kur AS kur ON ord.ind_kur_cd = kur.kur_cd
WHERE
	ord.ord_no IN (SELECT ord_no FROM ord_main_exists)
AND
	CASE
		WHEN (SELECT COUNT(*) FROM journal_exists) > 0 THEN ord.ord_no IN (SELECT ord_no FROM journal_exists)
    ELSE True
	END
ORDER BY
  CASE
    WHEN (SELECT COUNT(*) FROM ord_main_exists) > 1 THEN 
      CASE
        WHEN ord.ind_treatment_cd = (SELECT treatment_cd FROM treatment_info) THEN 1
        ELSE 2
      END
    ELSE 3
  END,
	ord.treat_date,
	ord.ind_treat_start_time
LIMIT 1
