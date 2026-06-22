SELECT
    A.ord_no
    , A.rst_medi_info
    , A.facility_cd
    , A.rst_treatment_cd
    -- add FNSI-実績確定修正 徐 start
    , A.rst_kur_name
    -- add FNSI-実績確定修正 徐 end
FROM
    ord_main A
WHERE
    ord_no in /* ordNoList */(1)
;
