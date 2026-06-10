UPDATE sys_data_set SET sql = 'SELECT
 opp.insu_no, --保険者番号
 opp.insu_pat_mark, --被保険者証記号
 opp.insu_pat_no, --被保険者証番号
 opp.insu_pub_no, --公費負担者番号
 opp.insu_pub_pat_no, --公費負担受給者番号
 opp.insu_kbn,--保険区分
 opp.remarks, --備考欄情報
 opp.insu_dr_id, --保険医ID
 personal_info_decrypt(opp.insu_dr_name) as insu_dr_name,--保険医名称
 personal_info_decrypt(opp.insu_dr_sign) as insu_dr_sign,--保険医署名
 mpu.anesthesiologist_license_no,--麻薬施用者番号
 pi.insu_name --保険名称
FROM
 ord_personal_prescription opp
 LEFT JOIN mst_personal_user mpu ON opp.insu_dr_id = mpu.user_id and mpu.is_del =''0'' and mpu.is_disp =''1''
 LEFT JOIN pat_insurance pi ON opp.insurance_cd = pi.insurance_cd  and pi.is_del =''0'' and pi.is_disp =''1''
WHERE
opp.is_del =''0'' and opp.is_disp =''1''  
and (opp.ord_prescription_no in (@ordPrescriptionNos)  or 0 in (@ordPrescriptionNos))
 '  WHERE sql_cd = 137;