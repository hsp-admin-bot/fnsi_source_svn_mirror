WITH CONVERT_HISTORY AS(
select * from sync_convert_history a
inner join sync_convert_history_dtl b
on (a.seq_no=b.seq_no) where table_kind = 'ORD'
)
SELECT
    b.DIALYSIS_NO,
	OCCUR_DATE,
    PATID,
    MONITOR_DATA,
	0 AS BIO_MONI_CTL_NO
FROM
    rst_dialysis_detail a
    inner join 
    (SELECT
            DIALYSIS_NO,
            patid
        FROM
            rst_dialysis rd
        WHERE
            {0}
            and rd.START_DATE >= '{1}' 
            and rd.START_DATE < '{2}'
			{3}
    ) b
    on (a.dialysis_no=b.dialysis_no)
ORDER BY
    b.DIALYSIS_NO,OCCUR_DATE