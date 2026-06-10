--装置モードカテゴリ「非補液」から「オフライン補液」または「オンライン補液」へ
UPDATE
  ord_main
SET
-- MOD BY ZHOU.TAO #9973 START
--  ind_cond_info = ind_cond_info || jsonb_build_object(
--		'19', jsonb_build_object('value',
--      /*%if isOnline*/
--      ind_cond_info#>'{15, value}'
--      /*%else*/
--      null
--      /*%end*/
--    ),	--補液
--		'20', jsonb_build_object('value', 0),	  	--補液量
--		'21', jsonb_build_object('value', 1),	  	--補液選択
--		'22', jsonb_build_object('value', null),	--補液使用数
--		'23', jsonb_build_object('value', 36),		--補液温度
--		'24', jsonb_build_object('value', 0)	  	--補液速度
--	)
  ind_cond_info = jsonb_set(
    jsonb_set(
      jsonb_set(
        jsonb_set(
          jsonb_set(
            jsonb_set(ind_cond_info, '{"19", "value"}'
              /*%if isOnline*/
              , ind_cond_info #> '{"15", "value"}'
              /*%else*/
              , 'null'
              /*%end*/
              ),
            '{"20", "value"}', '"0"'),
          '{"21", "value"}', '"1"'),
        '{"22", "value"}', 'null'),
      '{"23", "value"}', '"36.0"'),
    '{"24", "value"}', '"0"')
-- MOD BY ZHOU.TAO #9973 END
WHERE
  ord_no IN
	(
		SELECT
			ord_no
		FROM
      ord_main A
		LEFT JOIN
      mst_treatment B
		ON
      A.ind_treatment_cd = B.treatment_cd
		WHERE
      A.ord_no IN /*ordNoList*/() AND
			B.device_mode IN (0,1)
	)
;
