 INSERT INTO SYNC_WATER_SURVEY_TYPE_TEXT ( SURVEY_TYPE_CD, TEXT_NO, TEXT, UP_DATE,CHECKED )
WITH RankedMST AS ( 
  select  1 as rn, '未満' as TEXT from dual UNION all select  2 as rn, '以下' as TEXT from dual
   UNION all select  3 as rn, '検出感度以下' as TEXT from dual
) , MST_WATER_SURVEY_TYPE_list as (
 SELECT
    SURVEY_TYPE_CD
  FROM
    MST_WATER_SURVEY_TYPE 
 GROUP BY  SURVEY_TYPE_CD
), RankedSurveyTexts as (
SELECT
    SURVEY_TYPE_CD,TEXT,rn
  FROM
    MST_WATER_SURVEY_TYPE_list 
 CROSS JOIN  RankedMST)
SELECT
  d.SURVEY_TYPE_CD
  , ROW_NUMBER() OVER ( 
    PARTITION BY
      d.SURVEY_TYPE_CD 
    ORDER BY
      d.rn
  ) + e.TEXT_NO AS row_num
  , d.TEXT,
SYSDATE,'false' as CHECKED
FROM
  RankedSurveyTexts d 
  LEFT JOIN ( 
    SELECT
      SURVEY_TYPE_CD
      , MAX(TEXT_NO) AS TEXT_NO 
    FROM
      SYNC_WATER_SURVEY_TYPE_TEXT 
    GROUP BY
      SURVEY_TYPE_CD
  ) e 
    ON d.SURVEY_TYPE_CD = e.SURVEY_TYPE_CD 
WHERE
  d.TEXT IS NOT NULL 
  AND NOT EXISTS ( 
    SELECT
      1 
    FROM
      SYNC_WATER_SURVEY_TYPE_TEXT f 
    WHERE
      d.SURVEY_TYPE_CD = f.SURVEY_TYPE_CD 
      AND d.TEXT = f.TEXT
  )
         
