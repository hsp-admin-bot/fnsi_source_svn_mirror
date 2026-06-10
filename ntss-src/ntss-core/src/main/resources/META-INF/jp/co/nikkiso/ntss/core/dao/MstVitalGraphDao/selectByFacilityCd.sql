-- SELECT
--   /*%expand*/*
-- FROM
--   mst_vital_graph
-- WHERE
--   facility_cd = /*facilityCd*/'1' and
--   is_del = '0'
-- ORDER BY
--   vital_graph_cd
-- ;
SELECT
  /*%expand "A" */*
FROM
  mst_vital_graph A
	LEFT  JOIN
	(
         select
                 mss.facility_cd, ms.*, row_number() over() as index
         from
                 mst_selector mss
         cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
         (
                 code bigint,
                 name text
         )
         where
                 facility_cd = /*facilityCd*/'1'
         and
                 master_physical_name = 'mst_vital_graph' --テーブル名
   ) ms
   ON

         A.facility_cd = ms.facility_cd
   and
         CAST(A.vital_graph_cd AS BIGINT) = ms.code --コードのカラム
 WHERE
         A.facility_cd = /*facilityCd*/'1'
   and
         A.is_del = '0'
   and
         A.is_disp = '1'
  order by
         ms.index
