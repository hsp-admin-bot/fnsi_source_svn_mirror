SELECT
  to_char( DATE, 'yyyyMMdd' )
FROM
  ( SELECT generate_series (
    TO_DATE(/*startDate*/'20180609', 'yyyyMMdd'),
    TO_DATE(/*endDate*/'20200609', 'yyyyMMdd'), '1 day' ) AS DATE
  ) date_series
