SELECT
	ord.reg_date,
	ord.up_date,
	ord.ord_prescription_no,
	ord.facility_cd,
	fac.facility_name,
	ord.pat_id,
	ord.prescription_type,
	ord.issue_date,
	ord.issue_state,
	ord.expiration_date,
	ord.prescription_detail,
	ord.is_disp,
	ord.is_del
FROM
	ord_prescription AS ord
	LEFT JOIN mst_facility AS fac ON fac.facility_cd = ord.facility_cd
WHERE
	ord.pat_id = /* patId */0
    -- mod #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240613 sunsy start
-- 	/*%if fromDate == toDate */
--     and (/* fromDate */'' between ord.issue_date and ord.expiration_date)
--     /*%else */
--     and (ord.issue_date between /* fromDate */'' and /* toDate */'' or ord.expiration_date between /* fromDate */'' and /* toDate */'')
--     /*%end */
    and ord.issue_date = /*fromDate*/''
    -- mod #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240613 sunsy end
    -- add Aspose.cells関連問題二回目対応 鄭爽 start
    and ord.is_del = '0'
    -- add Aspose.cells関連問題二回目対応 鄭爽 end
--     add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
    and ord.prescription_type IN /* prescriptionClassList */(null)
--     add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
