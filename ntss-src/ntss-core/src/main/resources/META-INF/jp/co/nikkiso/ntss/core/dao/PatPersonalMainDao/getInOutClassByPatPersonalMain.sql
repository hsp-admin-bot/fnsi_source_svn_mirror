-- add #9323 帳票「並び替え」機能のオーバーホール　高 start
SELECT
	in_out_class
FROM
	pat_personal_main
	WHERE
	facility_cd=/*facilityCd*/''
	AND
	pat_id=/*patId*/''
-- add #9323 帳票「並び替え」機能のオーバーホール　高 end
