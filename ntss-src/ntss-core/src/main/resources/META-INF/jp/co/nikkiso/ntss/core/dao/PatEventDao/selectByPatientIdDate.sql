-- 指定患者、指定時間範囲の患者イベント実績情報を取得
SELECT
  A.pat_id,
  A.event_start_date,
  --  mod FNSI-FutreNetWeb+SI課題管理No.6080 劉全航 start
  A.category_cd,
  --  mod FNSI-FutreNetWeb+SI課題管理No.6080 劉全航 end
  A.sub_category_cd,
  --  del FNSI-FutreNetWeb+SI課題管理No.5318 李 start
  --  MAX(A.event_start_time) AS event_start_time
  --  del FNSI-FutreNetWeb+SI課題管理No.5318 李 end
  -- mod FutreNetWeb+SI課題管理No5926 趙 start
  -- A.letter_info
  A.letter_info,
  B.facility_name AS template_name
  -- mod FutreNetWeb+SI課題管理No5926 趙 end
FROM
  pat_event A
  -- add FutreNetWeb+SI課題管理No5926 趙 start
  left outer join sys_facility B
	ON  A.letter_info ->> 'to_medical_institution_cd' = B.medical_institution_cd
  -- add FutreNetWeb+SI課題管理No5926 趙 end
WHERE
  A.pat_id = /*patId*/2741
AND
  A.facility_cd = /*facilityCd*/null
AND
  A.event_start_date >= /*dialysis_date_from*/'20100220'
AND
  A.event_start_date <= /*dialysis_date_to*/'20300226'
AND
  A.is_del = '0'
  --  del FNSI-FutreNetWeb+SI課題管理No.5318 李 start
  -- GROUP BY
  --   A.pat_id,
  --   A.event_start_date,
  --   A.sub_category_cd
  --  del FNSI-FutreNetWeb+SI課題管理No.5318 李 end
;
