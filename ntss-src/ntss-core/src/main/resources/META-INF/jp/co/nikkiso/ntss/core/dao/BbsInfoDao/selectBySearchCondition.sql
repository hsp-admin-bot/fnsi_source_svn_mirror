-- mod FNSI-改修内容 検索欄の治療日、クール、ベッドの条件を指定された時、検索されたデータがない dou start
-- select distinct
--   bbs_ctl_no
-- from
--   pat_obs_rec A
-- where
--   A.ord_no in (
--     select
--       ord_no
--     from
--       ord_schedule
--     where
--       is_dummy = '0'
--
--       and facility_cd = /* facility_cd */null
--
--     --- 治療日
--     /*%if !dialysisDate == null */
--       and treat_date = /* dialysisDate */null
--     /*%end*/
--
--     --- クール
--     /*%if !kur == null */
--       and kur_cd = /* kur */null
--     /*%end */
--
--     --- ベッド
--   /*%if !roomBedGroup == null && !roomBedGroup.size() == 0 */
--       and bed_cd in /* roomBedGroup */(null)
--     /*%end */
--   )
--   and bbs_ctl_no is not null
-- ;

SELECT DISTINCT
       pat_id                                                   --- 患者ID
  FROM ord_main                                                 --- 治療情報
 WHERE is_del = '0'                                             --- 削除フラグ
   AND facility_cd = /* facility_cd */NULL                      --- 施設コード
/*%if !dialysisDate == null */
   AND treat_date = /* dialysisDate */NULL                      --- 治療日
/*%end*/
/*%if !kur == null */
   AND ind_kur_cd = /* kur */NULL                               --- 指示：クールコード
/*%end */
/*%if !roomBedGroup == null && !roomBedGroup.size() == 0 */
   AND ind_bed_cd IN /* roomBedGroup */(NULL)                   --- 指示：ベッドコード
/*%end */
-- mod FNSI-改修内容 検索欄の治療日、クール、ベッドの条件を指定された時、検索されたデータがない dou end
