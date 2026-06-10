-- getRetryDeliveryJournal.sql
select t.* ,mcd.distribute_setting  from (
 SELECT scj.facility_cd,
        scj.ctl_no,
        scj.coop_cd,
        TRIM(scj.coop_cd_index) AS coop_cd_index,
        scj.crud,
        scj.ord_no,
        scj.coop_ord_no,
        scj.hosp_pat_id,
        scj.pat_id,
        scj.dump_path,
        scj.dump,
        scj.ana_result,
        scj.coop_result,
        scj.in_reg_date,
        scj.out_reg_date,
        scj.in_ana_date,
        scj.out_ana_date,
        scj.base_date,
        scj.reg_date,
        scj.coop_version,
        scj.ope_cd,
        scj.retry_cnt
 FROM sys_coop_journal scj
 WHERE scj.direction = 'S'
   AND scj.ana_result = '9'
   AND scj.coop_result = 'R'
   AND scj.facility_cd = /*facilityCd*/'1'
   AND scj.is_del = '0'
   AND (COALESCE(scj.coop_version, '') || '#~#' || scj.coop_cd || '#~#' || COALESCE(scj.coop_cd_index, '')) IN /*stopCoopCdList*/('1')
 order by scj.ctl_no ASC
 LIMIT 1
) t
 INNER JOIN mst_coop_distribute mcd
            ON t.facility_cd = mcd.facility_cd
                AND t.coop_cd = mcd.coop_cd
                AND t.coop_cd_index = mcd.coop_cd_index
                AND t.coop_version = mcd.coop_version
                AND mcd.is_del = '0'
FOR UPDATE OF t NOWAIT;
