SELECT password_decrypt(password_cl) AS password_cl,
       max_download,
       cur_download,
       facility_cd,
       expired_date,
       cl_certificate_id,
       many_facility_cd,
       many_facility_name
FROM client_cer_detail
WHERE facility_cd = /*facilityCd*/''
and  is_delete ='0'
-- is_merge_issued='1' のレコードは ntss-certificate-download の /user 画面（証明書ダウンロード一覧）では非表示にする。
-- マージ発行証明書はマージ完了時にその場でダウンロードする一回限りの機能のため、ダウンロード一覧への表示は不要。
-- 管理端の CLCertificateDetails 画面は別の SQL（selectAllCertificatesByFacilityCd）を使用するため影響なし。
and  (is_merge_issued IS NULL OR is_merge_issued != '1')
