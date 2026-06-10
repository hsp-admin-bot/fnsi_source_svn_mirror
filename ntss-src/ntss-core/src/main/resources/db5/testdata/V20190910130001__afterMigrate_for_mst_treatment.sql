-- 治療方法マスタのデータ更新
UPDATE mst_treatment
set
  graph_time_scale = 6
WHERE
  treatment_cd = 1;

UPDATE mst_treatment
set
  graph_time_scale = 8
WHERE
  treatment_cd = 2;

UPDATE mst_treatment
set
  graph_time_scale = 10
WHERE
  treatment_cd = 3;
