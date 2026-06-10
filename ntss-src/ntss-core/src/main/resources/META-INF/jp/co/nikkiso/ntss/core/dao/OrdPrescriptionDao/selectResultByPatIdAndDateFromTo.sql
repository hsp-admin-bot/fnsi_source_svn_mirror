SELECT
  issue_date,
  ord_prescription_no
FROM
  ord_prescription
WHERE
    pat_id = /* patId */0
AND is_del = '0'
AND issue_date between /* fromDate */'' and /* toDate */''
AND facility_cd = /* facilityCd */''
--     add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
AND prescription_type IN /* prescriptionClassList */(null)
--     add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
