--施設設定マスタ 51-58 遠隔監視を削除
DELETE 
FROM
	sys_facility_setting 
WHERE
	facility_setting_no IN ( '1051', '1052', '1053', '1054', '1055', '1056', '1057', '1058' );