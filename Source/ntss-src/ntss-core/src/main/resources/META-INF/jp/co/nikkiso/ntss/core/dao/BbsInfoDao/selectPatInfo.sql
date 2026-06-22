-- mod 8558 掲示一覧検索中の表示のままになり操作ができなくなる 関 start
-- select distinct
--   bbs_ctl_no,
--   pat_info
-- from
--   (SELECT
-- 		bbs_ctl_no,
-- 		pat_info,
-- 		notice_start_date,
-- 		notice_end_date,
-- 		facility_cd,
-- 		func_cd,
-- 		kind_no,
-- 		is_del,
-- 		is_disp,
-- 		is_disp_bbs
-- 	FROM
-- 		bbs_info B
-- 	WHERE
-- 	    facility_cd = /* facility_cd */null
-- 		AND B.notice_start_date ~ '^\d{1,4}\d{2}\d{2}$'
-- 		AND B.notice_end_date ~ '^\d{1,4}\d{2}\d{2}$'
-- 		AND B.is_del = '0'
-- 		AND B.is_disp = '1'
-- 		AND B.is_disp_bbs = '1') A,
--   -- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 start
-- --   to_char(A.notice_start_date, 'YYYYMMDD') as start_date,
-- --   to_char(A.notice_end_date, 'YYYYMMDD') as end_date
--   to_date(A.notice_start_date, 'YYYYMMDD') as start_date,
--   to_date(A.notice_end_date, 'YYYYMMDD') as end_date
--   -- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 end
--
-- where
--   facility_cd = /* facility_cd */null
--
-- --- 機能コード
-- /*%if func_cd_list.size() != 0 */
--   and func_cd in /* func_cd_list */(null)
-- /*%end */
--
-- --- 種類番号
-- /*%if kind_no_list.size() != 0 */
--   and kind_no in /* kind_no_list */(null)
-- /*%end */
--
-- --- 期間指定
-- /*%if notice_start_date != null && notice_end_date != null */
--   and (
--     (/* notice_start_date */null <= start_date and  start_date <= /* notice_end_date */null)
--     or (/* notice_start_date */null <= end_date and end_date <= /* notice_end_date */null)
--     or (start_date <= /* notice_start_date */null and /* notice_end_date */null <= end_date)
--     or (start_date <= /* notice_end_date */null and end_date is null)
--   )
-- /*%end */
--
--   and A.is_del = '0'
--   and A.is_disp = '1'
--   and A.is_disp_bbs = '1'
select distinct
  bbs_ctl_no,
  pat_info
from
  (SELECT
		bbs_ctl_no,
		pat_info,
		notice_start_date,
		notice_end_date,
		facility_cd,
		func_cd,
		kind_no,
		is_del,
		is_disp,
		is_disp_bbs
	FROM
		bbs_info B
	WHERE
	    facility_cd = /* facility_cd */null
		AND B.notice_start_date ~ '^\d{1,4}\d{2}\d{2}$'
		AND B.notice_end_date ~ '^\d{1,4}\d{2}\d{2}$'
		AND B.is_del = '0'
		AND B.is_disp = '1'
-- mod #11452 掲示板の患者名検索で結果に出てこないデータがある zkm start
-- 		AND B.is_disp_bbs = '1') A,
		AND B.is_disp_bbs IN ('1', '3')) A,
-- mod #11452 掲示板の患者名検索で結果に出てこないデータがある zkm end
  -- mod FNSI-434 改修内容掲示板のみに表示施設カレンダのみに表示 趙立強 start
--   to_char(A.notice_start_date, 'YYYYMMDD') as start_date,
--   to_char(A.notice_end_date, 'YYYYMMDD') as end_date
  to_date(A.notice_start_date, 'YYYYMMDD') as start_date,
  to_date(A.notice_end_date, 'YYYYMMDD') as end_date
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
    (/* notice_start_date */null <= start_date and  start_date <= /* notice_end_date */null)
    or (/* notice_start_date */null <= end_date and end_date <= /* notice_end_date */null)
    or (start_date <= /* notice_start_date */null and /* notice_end_date */null <= end_date)
    or (start_date <= /* notice_end_date */null and end_date is null)
  )
/*%end */

  and A.is_del = '0'
  and A.is_disp = '1'
-- mod #11452 掲示板の患者名検索で結果に出てこないデータがある zkm start
--   and A.is_disp_bbs = '1'
  and A.is_disp_bbs IN ('1', '3')
-- mod #11452 掲示板の患者名検索で結果に出てこないデータがある zkm end
-- mod 8558 掲示一覧検索中の表示のままになり操作ができなくなる 関 end
