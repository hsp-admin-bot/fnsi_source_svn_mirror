select
  count(1)
from
    bbs_info A
    -- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 start
--   to_char(A.notice_start_date, 'YYYYMMDD') as start_date,
--   to_char(A.notice_end_date, 'YYYYMMDD') as end_date
    -- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 end

where
        facility_cd = /* facility_cd */null

--- 機能コード
/*%if func_cd_list.size() != 0 */
  and func_cd in /* func_cd_list */(null)
/*%end */

--- 種類番号
/*%if kind_no_list.size() != 0 */
  and kind_no in /* kind_no_list */(null)
/*%end */

--- 期間指定
/*%if notice_start_date != null && notice_end_date != null */
  and (
    -- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 start
--    (/* notice_start_date */null <= start_date and  start_date <= /* notice_end_date */null)
--   or (/* notice_start_date */null <= end_date and end_date <= /* notice_end_date */null)
--    or (start_date <= /* notice_start_date */null and /* notice_end_date */null <= end_date)
--    or (start_date <= /* notice_end_date */null and end_date is null)
        (/* notice_start_date */null <= A.notice_start_date and  A.notice_start_date <= /* notice_end_date */null)
        or (/* notice_start_date */null <= A.notice_end_date and A.notice_end_date <= /* notice_end_date */null)
        or (A.notice_start_date <= /* notice_start_date */null and /* notice_start_date */null <= A.notice_end_date)
        or (A.notice_start_date <= /* notice_end_date */null and /* notice_end_date */null <= A.notice_end_date)
        or (A.notice_start_date <= /* notice_end_date */null and A.notice_end_date is null)
        or (/* notice_start_date */null <= A.notice_end_date and A.notice_start_date is null)
        or (A.notice_start_date is null and A.notice_start_date is null)
    -- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 end
    )
/*%end */

--- オーダー番号
/*%if  (dialysis_date != null || kur_cd != null || (room_bed_group_cd !=null && room_bed_group_cd.size() != 0))　*/
  and bbs_ctl_no in /* bbsCtlNoList */(null)
/*%end*/

--- フリーワード
/*%if text != null */
  and (
    bbs_ctl_no in /* bbsCtlNoListFreeWord */(null)
    or A.content like '%' || /*text*/'' || '%' 
    or A.title like '%' || /*text*/'' || '%'
  )
/*%end*/

  and A.is_del = '0'
  and A.is_disp = '1'
  -- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 start
--    and A.is_disp_bbs = '1'
  and A.is_disp_bbs in ('1','3')
  -- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 end
/*%if userId != null */
  and not (A.staff_info::jsonb -> 'read' @> ('[' || /* userId */0 || ']')::jsonb)
/*%end */

  and (A.staff_info::jsonb -> 'target' = '[]'::jsonb
/*%if targetUserId != null */
        or A.staff_info::jsonb -> 'target' @> ('[' || /* targetUserId */null || ']')::jsonb
/*%end */
      )
;
