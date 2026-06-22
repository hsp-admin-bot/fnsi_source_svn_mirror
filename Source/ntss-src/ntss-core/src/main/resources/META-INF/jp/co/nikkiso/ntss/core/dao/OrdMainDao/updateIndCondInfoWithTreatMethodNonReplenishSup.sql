--装置モードカテゴリ「非補液」から「オフライン補液」または「オンライン補液」へ
UPDATE
  ord_main
SET
  ind_cond_info = jsonb_merge_recursive(ind_cond_info, jsonb_build_object(
		'19', jsonb_build_object('value',
      /*%if isOnline*/
      ind_cond_info#>'{15, value}'
      /*%else*/
      null
      /*%end*/
    ),	--補液
		'20', jsonb_build_object('value', 0),	  	--補液量
		'21', jsonb_build_object('value', 1),	  	--補液選択
		'22', jsonb_build_object('value', null),	--補液使用数
		'23', jsonb_build_object('value', 36),		--補液温度
		'24', jsonb_build_object('value', 0)	  	--補液速度
	))
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
      A.ord_no IN /*ordNoList*/() 
		AND
      /*deviceMode*/null IN (0,1)
	)
;