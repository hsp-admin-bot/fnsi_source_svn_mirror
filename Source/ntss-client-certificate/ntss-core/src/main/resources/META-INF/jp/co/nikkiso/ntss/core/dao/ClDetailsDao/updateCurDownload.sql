UPDATE client_cer_detail
SET
    cur_download = coalesce(cur_download,0) + 1,
    up_date = /*upDate*/'',
    download_date = /*upDate*/''
WHERE
    cl_certificate_id = /*clCertificateId*/0
