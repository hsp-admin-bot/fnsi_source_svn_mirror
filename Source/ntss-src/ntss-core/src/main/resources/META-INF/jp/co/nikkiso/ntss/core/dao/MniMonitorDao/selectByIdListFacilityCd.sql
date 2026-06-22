SELECT
/*%expand "A" */*
FROM
	mni_monitor A
WHERE
	facility_cd = /*facilityCd*/NULL
	AND pat_id IN /* patIdList */( NULL )
	AND is_del = '0'
AND EXISTS (
    SELECT 1
    FROM ord_main ord
    WHERE
        A.ord_no = ord_no
	AND facility_cd = /*facilityCd*/NULL
	AND pat_id IN /* patIdList */( NULL )
	-- del FNSi6523DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される 周 start
    --AND (ord.rst_dialysis_state = '0' OR ord.rst_dialysis_state = '6')
    -- del FNSi6523DWが登録されているのにも関わらず、DWの欄に「未登録」と表示される 周 end
	AND (
		( treat_date >= REPLACE ( /*startDate*/NULL, '-', '' ) -- 治療日
		AND treat_date <= REPLACE ( /*endDate*/NULL, '-', '' ) ) -- 治療日

		OR ( rst_start_date >= TO_TIMESTAMP( /* startDate */NULL, 'YYYY-MM-DD' ) :: TIMESTAMP -- 実績：治療開始日時
		AND rst_start_date <= TO_TIMESTAMP( /* endDate   */NULL, 'YYYY-MM-DD' ) :: TIMESTAMP ) -- 実績：治療開始日時

		OR ( rst_end_date >= TO_TIMESTAMP( /* startDate */NULL, 'YYYY-MM-DD' ) :: TIMESTAMP -- 実績：治療終了日時
		AND rst_end_date <= TO_TIMESTAMP( /* endDate   */NULL, 'YYYY-MM-DD' ) :: TIMESTAMP ) -- 実績：治療終了日時
	)
)
