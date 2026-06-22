--重症度の抽出
  select
    severity_cd,
    severity_name
  from
    mst_severity A
  where
    A.severity_cd in /* severityCds */(null)
;
