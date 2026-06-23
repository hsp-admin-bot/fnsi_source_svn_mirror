UPDATE mst_coop_apilink
SET api_body = jsonb_set(
    api_body,
    '{coop_version}',
    CASE
        WHEN facility_cd = 'nkknkk' THEN '"NKK"'
        WHEN facility_cd = 'F_hosp' THEN '"GX"'
        WHEN facility_cd = 'N_hosp' THEN '"HR"'
        WHEN facility_cd = 'S_hosp' THEN '"SSI"'
        WHEN facility_cd = 'NEC-iS' THEN '"IS"'
        WHEN facility_cd = 'C_hosp' THEN '"CSI"'
        WHEN facility_cd = 'P_hosp' THEN '"MED"'
        ELSE '""'
    END::jsonb,
    TRUE
)
WHERE facility_cd IN ('nkknkk', 'F_hosp', 'N_hosp', 'S_hosp', 'NEC-iS', 'C_hosp', 'P_hosp');
