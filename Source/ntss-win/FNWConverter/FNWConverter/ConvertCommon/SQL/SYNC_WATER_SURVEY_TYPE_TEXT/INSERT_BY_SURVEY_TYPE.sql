INSERT INTO SYNC_WATER_SURVEY_TYPE_TEXT(SURVEY_TYPE_CD, TEXT_NO, TEXT, UP_DATE, CHECKED)
WITH RankedMST AS ( 
  SELECT
    SURVEY_TYPE_CD
    , ROW_NUMBER() OVER ( 
      PARTITION BY
        SURVEY_TYPE_CD 
      ORDER BY
        UP_DATE DESC
    ) AS rn
    , CASE 
      WHEN THRESHOLD_UP_OR_DOWN = '1' 
        THEN '以下' 
      WHEN THRESHOLD_UP_OR_DOWN = '0' 
        THEN '以上' 
      ELSE NULL 
      END AS TEXT
    , UP_DATE 
  FROM
    MST_WATER_SURVEY_TYPE 
  WHERE
    DEL_FLG = '0'
) 
, MaxTextNumbers AS ( 
  SELECT
    SURVEY_TYPE_CD
    , MAX(TEXT_NO) AS MAX_TEXT_NO 
  FROM
    SYNC_WATER_SURVEY_TYPE_TEXT 
  GROUP BY
    SURVEY_TYPE_CD
) 
SELECT
  r.SURVEY_TYPE_CD
  , COALESCE(mt.MAX_TEXT_NO + 1, 1) AS TEXT_NO
  , r.TEXT
  , r.UP_DATE , case when mt.SURVEY_TYPE_CD is null then  'true' else 'false' end as CHECKED
FROM
  RankedMST r 
  LEFT JOIN MaxTextNumbers mt 
    ON r.SURVEY_TYPE_CD = mt.SURVEY_TYPE_CD 
WHERE
  r.rn = 1 
  AND NOT EXISTS ( 
    SELECT
      1 
    FROM
      SYNC_WATER_SURVEY_TYPE_TEXT stt 
    WHERE
      stt.SURVEY_TYPE_CD = r.SURVEY_TYPE_CD 
      AND stt.TEXT = r.TEXT
  )