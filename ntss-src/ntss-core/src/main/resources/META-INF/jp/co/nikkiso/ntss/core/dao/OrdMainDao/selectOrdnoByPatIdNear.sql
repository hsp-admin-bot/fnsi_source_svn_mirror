SELECT
    om.ord_no
    FROM
        ord_main om
    WHERE
        om.pat_id = /*patId*/0
        and facility_cd = /*facilityCd*/null
        AND om.rst_treatment_cd IS NOT NULL
        and om.is_del = '0'
    ORDER BY
    treat_date DESC
LIMIT /*times*/0
