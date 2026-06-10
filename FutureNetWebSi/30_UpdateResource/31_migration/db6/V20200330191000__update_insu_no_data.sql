WITH subquery AS (
    SELECT
        insurance_cd,
        json_build_object (
            'insu_pat_name', personal_info_decrypt((insu_info::json->>'insu_pat_name')::text),
            'insu_no', (insu_info::json->>'insu_no')::text,
            'insu_kbn', (insu_info::json->>'insu_kbn')::text,
            'insu_pat_mark', personal_info_decrypt((insu_info::json->>'insu_pat_mark')::text),
            'insu_pat_no', personal_info_decrypt((insu_info::json->>'insu_pat_no')::text),
            'cki_class', (insu_info::json->>'cki_class')::text,
            'kki_class', (insu_info::json->>'kki_class')::text,
            'und_six', (insu_info::json->>'und_six')::text,
            'futan-g', (insu_info::json->>'futan-g')::text,
            'futan-n', (insu_info::json->>'futan-n')::text
        ) as insu_info
    FROM ntss.pat_insurance
)

UPDATE ntss.pat_insurance as pat
SET insu_info = json_build_object (
    'insu_pat_name', personal_info_encrypt((subquery.insu_info::json->>'insu_pat_name')::text),
    'insu_no', personal_info_encrypt((subquery.insu_info::json->>'insu_no')::text),
    'insu_kbn', (subquery.insu_info::json->>'insu_kbn')::text,
    'insu_pat_mark', personal_info_encrypt((subquery.insu_info::json->>'insu_pat_mark')::text),
    'insu_pat_no', personal_info_encrypt((subquery.insu_info::json->>'insu_pat_no')::text),
    'cki_class', (subquery.insu_info::json->>'cki_class')::text,
    'kki_class', (subquery.insu_info::json->>'kki_class')::text,
    'und_six', (subquery.insu_info::json->>'und_six')::text,
    'futan-g', (subquery.insu_info::json->>'futan-g')::text,
    'futan-n', (subquery.insu_info::json->>'futan-n')::text
)
FROM subquery
WHERE pat.insurance_cd = subquery.insurance_cd;
