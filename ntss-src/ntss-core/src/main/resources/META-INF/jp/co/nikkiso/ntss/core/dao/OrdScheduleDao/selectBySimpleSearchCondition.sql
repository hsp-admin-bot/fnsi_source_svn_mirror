-- mod 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 start
-- select distinct
--   pat_id
-- from
--   ord_schedule
-- where
--   is_dummy = '0'
--
-- --- クエリ検索が行われていた場合の検索結果患者ID
-- /*%if patIdList.size() > 0 */
--   and pat_id in /* patIdList */(null)
-- /*%end */
--
-- --- 施設コードリスト未指定の場合は検索は実行されないので配列長チェックしていない
--   and facility_cd in /* facilityCdList */(null)
--
-- --- 透析予定期間(開始日)
-- /*%if !conditions.treatDate.isEmpty() */
--   and treat_date = /* conditions.treatDate */null
-- /*%end*/
--
-- --- クール
-- /*%if conditions.kurCdList.size() > 0 */
--   and kur_cd in /* conditions.kurCdList */(null)
-- /*%end */
--
-- --- ベッド
-- /*%if conditions.bedCdList.size() > 0 */
--   and bed_cd in /* conditions.bedCdList */(null)
-- /*%end */
--
-- --- 曜日
-- /*%if conditions.treatDayOfWeekList.size() > 0 */
--   and treat_week in /* conditions.treatDayOfWeekList */(null)
-- /*%end */

select distinct
  os.pat_id
from
  ord_schedule os
  join ord_main om on om.ord_no = os.ord_no
where
  is_dummy = '0'
--- クエリ検索が行われていた場合の検索結果患者ID
/*%if patIdList.size() > 0 */
  and os.pat_id in /* patIdList */(null)
/*%end */
--- 施設コードリスト未指定の場合は検索は実行されないので配列長チェックしていない
  and os.facility_cd in /* facilityCdList */(null)
--- 透析予定期間(開始日)
/*%if !conditions.treatDate.isEmpty() */
  and os.treat_date = /* conditions.treatDate */null
/*%end*/
-- add FutreNetWeb+SI課題管理No5777 趙 start
/*%if conditions.treatDate.isEmpty() */
  and os.treat_date >= to_char(CURRENT_DATE, 'YYYYMMDD')
/*%end*/
-- add FutreNetWeb+SI課題管理No5777 趙 end
--- クール
/*%if conditions.kurCdList.size() > 0 */
  and os.kur_cd in /* conditions.kurCdList */(null)
/*%end */

--- ベッド
/*%if conditions.bedGroupCd != null */
  and os.bed_cd in /* conditions.bedCdList */(null)
/*%end */

--- 曜日
/*%if conditions.treatDayOfWeekList.size() > 0 */
  and os.treat_week in /* conditions.treatDayOfWeekList */(null)
/*%end */
/*%if ""!= rstDialysisStateFlag && rstDialysisStateFlag == "1" */
  and om.rst_dialysis_state > '0'
/*%end */
/*%if ""!= rstDialysisStateFlag && rstDialysisStateFlag == "2" */
  and om.rst_dialysis_state >= '0'
/*%end */

-- mod 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 end*/
