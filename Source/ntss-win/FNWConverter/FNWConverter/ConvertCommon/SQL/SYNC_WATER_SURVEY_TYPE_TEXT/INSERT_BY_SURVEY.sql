INSERT INTO SYNC_WATER_SURVEY_TYPE_TEXT ( SURVEY_TYPE_CD, TEXT_NO, TEXT, UP_DATE, CHECKED)
WITH RankedSurveyPoints AS ( 
  SELECT
    SURVEY_TYPE_CD
    , SURVEY_POINT_CD
    , ROW_NUMBER() OVER ( 
      PARTITION BY
        SURVEY_POINT_CD 
      ORDER BY
        UP_DATE DESC
    ) AS rn 
  FROM
    MST_WATER_SURVEY_POINT 
  WHERE
    SERIES_CD = :SERIES_CD 
    AND DEL_FLG = '0'
) 
, RankedSurveys AS ( 
  SELECT
    SURVEY_POINT_CD
    , UNIT
    , UP_DATE
    , ROW_NUMBER() OVER ( 
      PARTITION BY
        SURVEY_POINT_CD
        , SURVEY_RECORD_NO 
      ORDER BY
        UP_DATE DESC
    ) AS rn 
  FROM
    MNT_WATER_SURVEY 
  WHERE
    DEL_FLG = '0'
) 
, RankedSurveyTexts AS ( 
  SELECT
    t.SURVEY_TYPE_CD
    , COALESCE( 
      CASE 
        WHEN t.UNIT IS NULL 
          THEN s.UNIT 
        WHEN INSTR(s.UNIT, t.UNIT) = 0 
          THEN s.UNIT 
        ELSE SUBSTR(s.UNIT, INSTR(s.UNIT, t.UNIT) + LENGTH(t.UNIT)) 
        END
      , NULL
    ) AS TEXT
    , MAX(s.UP_DATE) AS UP_DATE 
  FROM
    MST_WATER_SURVEY_TYPE t 
    LEFT JOIN RankedSurveyPoints p 
      ON t.SURVEY_TYPE_CD = p.SURVEY_TYPE_CD 
      AND p.rn = 1 
    LEFT JOIN RankedSurveys s 
      ON p.SURVEY_POINT_CD = s.SURVEY_POINT_CD 
      AND s.rn = 1 
  WHERE
    NOT EXISTS ( 
      SELECT
        1 
      FROM
        MST_WATER_SURVEY_TYPE b 
      WHERE
        t.SURVEY_TYPE_CD = b.SURVEY_TYPE_CD 
        AND t.UP_DATE < b.UP_DATE
    ) 
    AND t.DEL_FLG = '0' 
  GROUP BY
    t.SURVEY_TYPE_CD
    , COALESCE( 
      CASE 
        WHEN t.UNIT IS NULL 
          THEN s.UNIT 
        WHEN INSTR(s.UNIT, t.UNIT) = 0 
          THEN s.UNIT 
        ELSE SUBSTR(s.UNIT, INSTR(s.UNIT, t.UNIT) + LENGTH(t.UNIT)) 
        END
      , NULL
    )
) 
SELECT
  d.SURVEY_TYPE_CD
  , ROW_NUMBER() OVER ( 
    PARTITION BY
      d.SURVEY_TYPE_CD 
    ORDER BY
      d.UP_DATE
  ) + e.TEXT_NO AS row_num
  , TRIM(REPLACE(d.TEXT, '　', ''))
  , d.UP_DATE,'false'  as CHECKED
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
      AND TRIM(REPLACE(d.TEXT, '　', '')) = f.TEXT
  )