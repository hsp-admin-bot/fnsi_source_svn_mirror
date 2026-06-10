select
  pat_id,
  ord_no
from
  ord_schedule
where
  is_dummy = '0'

/*%if patIdList.size() > 0 */
  and pat_id in /* patIdList */(null)
/*%end */

--- 施設コード絞り込み(速度改善)
  and facility_cd in /* facilityCdList */(null)

--- 透析予定期間(開始日)
-- mod No338患者詳細検索の追加項目 一般撮影検査予定検索 吉 start
-- /*%if !conditions.treatStartDate.isEmpty() */
/*%if null != conditions.treatStartDate && !conditions.treatStartDate.isEmpty() */
-- mod No338患者詳細検索の追加項目 一般撮影検査予定検索 吉 end
  and treat_date >= /* conditions.treatStartDate */null
/*%end*/

--- 透析予定期間(終了日)
-- mod No338患者詳細検索の追加項目 一般撮影検査予定検索 吉 start
-- /*%if !conditions.treatEndDate.isEmpty() */
/*%if null != conditions.treatEndDate && !conditions.treatEndDate.isEmpty() */
-- modNo338患者詳細検索の追加項目 一般撮影検査予定検索  吉 end
  and treat_date <= /* conditions.treatEndDate */null
/*%end*/

--- クール
-- mod No338患者詳細検索の追加項目 一般撮影検査予定検索 吉 start
-- /*%if conditions.kurCdList.size() > 0 */
/*%if null != conditions.kurCdList && conditions.kurCdList.size() > 0 */
-- mod No338患者詳細検索の追加項目 一般撮影検査予定検索 吉 end
  and kur_cd in /* conditions.kurCdList */(null)
/*%end */

--- ベッド
/*%if null != conditions.bedGroupCdList && conditions.bedGroupCdList.size() > 0 */
  and bed_cd in /* conditions.bedCdList */(null)
/*%end */
--
--- 曜日
-- mod No338患者詳細検索の追加項目 一般撮影検査予定検索 吉 start
-- /*%if conditions.treatDayOfWeekList.size() > 0 */
/*%if null != conditions.treatDayOfWeekList && conditions.treatDayOfWeekList.size() > 0 */
-- mod No338患者詳細検索の追加項目 一般撮影検査予定検索 吉 end
  and treat_week in /* conditions.treatDayOfWeekList */(null)
/*%end */
/*%if null != conditions.simpleSearchTreatDayOfWeekList && conditions.simpleSearchTreatDayOfWeekList.size() > 0 */
  and treat_week in /* conditions.simpleSearchTreatDayOfWeekList */(null)
/*%end */
/*%if null != conditions.simpleSearchKurCdList && conditions.simpleSearchKurCdList.size() > 0 */
  and kur_cd in /* conditions.simpleSearchKurCdList */(null)
/*%end */
/*%if null != conditions.simpleSearchBedCdList && conditions.simpleSearchBedCdList.size() > 0 */
  and bed_cd in /* conditions.simpleSearchBedCdList */(null)
/*%end */
