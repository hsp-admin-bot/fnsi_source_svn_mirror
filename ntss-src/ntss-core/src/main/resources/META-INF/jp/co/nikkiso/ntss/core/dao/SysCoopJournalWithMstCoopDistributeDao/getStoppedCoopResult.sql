-- add #10061、SQLパフォーマンス改善、 20231221 xugj start
SELECT
	count(1)
FROM
	sys_coop_journal
WHERE
	direction = 'S'
	AND ana_result = '9'
	AND coop_result IN ( '1', '8' )
	AND facility_cd = /*facilityCd*/'1'
	AND is_del = '0'
LIMIT 1
-- add #10061、SQLパフォーマンス改善、 20231221 xugj end
