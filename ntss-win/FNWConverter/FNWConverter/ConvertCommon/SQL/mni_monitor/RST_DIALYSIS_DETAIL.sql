WITH CONVERT_HISTORY AS(
			select * from sync_convert_history a
			inner join sync_convert_history_dtl b
			on (a.seq_no=b.seq_no) where table_kind = 'ORD'
			)
SELECT
    b.DEVICE_NO,
    b.DIALYSIS_NO,
    b.PATID,
    1 AS DATA_TYPE,
    b.DEL_FLG,
    OCCUR_DATE,
    MONITOR_DATA,UP_DATE
FROM
    rst_dialysis_detail a
    inner join 
    (SELECT
            DIALYSIS_NO,
            DEL_FLG,
            DEVICE_NO,
            PATID
        FROM
            rst_dialysis rd
        WHERE
            {0}
            and rd.START_DATE >=:START_DATE
            and rd.START_DATE < :END_DATE
			{1}
            {SERIES_CD}
    ) b
    on (a.dialysis_no=b.dialysis_no)
UNION
{4}
SELECT
  b.DEVICE_NO,
  b.DIALYSIS_NO,
  b.PATID,
CASE
    WHEN TEMPERATURE IS NULL THEN
    ( CASE BP_CLASS WHEN '0' THEN 2 WHEN '1' THEN 5 ELSE 6 END ) ELSE 4 
  END AS DATA_TYPE,
  '0',
  OCCUR_DATE,
  'MONI_DATA' ||
CASE
    WHEN BP_MAX IS NULL THEN
    '' ELSE'`' || 90 || BP_MAX 
  END ||
CASE
  WHEN BP_MIN IS NULL THEN
  '' ELSE'`' || 91 || BP_MIN 
  END ||
CASE
  WHEN BP_AVE IS NULL THEN
  '' ELSE'`' || 92 || BP_AVE 
  END ||
CASE
  WHEN PULSE IS NULL THEN
  '' ELSE '`' || 93 || PULSE 
  END ||
CASE
  WHEN TEMPERATURE IS NULL THEN
  '' ELSE'`' || 94 || TEMPERATURE 
  END ||
CASE
  WHEN BLOOD_SUGAR_LEVEL IS NULL THEN
  '' ELSE'`' || -1 || BLOOD_SUGAR_LEVEL 
  END AS MONITOR_DATA,UP_DATE
FROM
  RST_DIALYSIS_VITAL
  A INNER JOIN (
  SELECT
    DIALYSIS_NO,
    DEL_FLG,
    DEVICE_NO,
    PATID 
  FROM
    rst_dialysis rd 
  WHERE
    {0}
    and rd.START_DATE >= :START_DATE
    and rd.START_DATE < :END_DATE
    {1}
    {SERIES_CD}
  ) b ON ( A.dialysis_no = b.dialysis_no ) 
WHERE
	BP_MAX IS NOT NULL 
	OR BP_MIN IS NOT NULL 
	OR BP_AVE IS NOT NULL 
	OR TEMPERATURE IS NOT NULL 
	OR BLOOD_SUGAR_LEVEL IS NOT NULL
ORDER BY
  DIALYSIS_NO,
  OCCUR_DATE
