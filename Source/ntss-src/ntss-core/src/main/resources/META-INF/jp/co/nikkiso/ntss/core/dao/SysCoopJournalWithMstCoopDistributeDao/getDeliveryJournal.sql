-- #11936 mod
WITH union_table AS (
  SELECT
    t.facility_cd,
    t.ctl_no,
    t.coop_cd,
    TRIM(t.coop_cd_index) AS coop_cd_index,
    t.crud,
    t.ord_no,
    t.coop_ord_no,
    t.hosp_pat_id,
    t.pat_id,
    t.dump_path,
    t.dump,
    t.ana_result,
    t.coop_result,
    t.in_reg_date,
    t.out_reg_date,
    t.in_ana_date,
    t.out_ana_date,
    t.base_date,
    t.reg_date,
    t.coop_version,
    t.ope_cd,
    t.retry_cnt,
    mcd.distribute_setting
  FROM (
      (SELECT
        facility_cd,
        ctl_no,
        coop_cd,
        TRIM(coop_cd_index) AS coop_cd_index,
        crud,
        ord_no,
        coop_ord_no,
        hosp_pat_id,
        pat_id,
        dump_path,
        dump,
        ana_result,
        coop_result,
        in_reg_date,
        out_reg_date,
        in_ana_date,
        out_ana_date,
        base_date,
        reg_date,
        coop_version,
        ope_cd,
        retry_cnt
      FROM sys_coop_journal
      WHERE facility_cd = /*facilityCd*/'1' AND ana_result = '9' AND direction = 'S'
        AND coop_result = '0' AND is_del = '0' AND ctl_no >= 0
          /*%if stopCoopCdList != null && stopCoopCdList.size() > 0 */
        AND (COALESCE(coop_version, '') || '#~#' || coop_cd || '#~#' || COALESCE(coop_cd_index, '')) NOT IN /*stopCoopCdList*/('1')
          /*%end */
      ORDER BY ctl_no
          LIMIT 1)
      UNION ALL
      (SELECT
        facility_cd,
        ctl_no,
        coop_cd,
        TRIM(coop_cd_index) AS coop_cd_index,
        crud,
        ord_no,
        coop_ord_no,
        hosp_pat_id,
        pat_id,
        dump_path,
        dump,
        ana_result,
        coop_result,
        in_reg_date,
        out_reg_date,
        in_ana_date,
        out_ana_date,
        base_date,
        reg_date,
        coop_version,
        ope_cd,
        retry_cnt
      FROM sys_coop_journal
      WHERE facility_cd = /*facilityCd*/'1' AND ana_result = '9' AND direction = 'S'
        AND coop_result = 'R' AND is_del = '0' AND ctl_no >= 0
          /*%if stopCoopCdList != null && stopCoopCdList.size() > 0 */
        AND (COALESCE(coop_version, '') || '#~#' || coop_cd || '#~#' || COALESCE(coop_cd_index, '')) NOT IN /*stopCoopCdList*/('1')
          /*%end */
      ORDER BY ctl_no
          LIMIT 1)
  ) t
  JOIN mst_coop_distribute mcd
    ON t.facility_cd = mcd.facility_cd
    AND t.coop_cd = mcd.coop_cd
    AND t.coop_cd_index = mcd.coop_cd_index
    AND t.coop_version = mcd.coop_version
  WHERE mcd.is_del = '0'
  ORDER BY ctl_no
      LIMIT 1
)
, get_lock_table AS (
  SELECT * FROM sys_coop_journal WHERE ctl_no = (SELECT ctl_no FROM union_table) FOR UPDATE NOWAIT
)
SELECT * FROM union_table WHERE ctl_no = (SELECT ctl_no FROM get_lock_table);
