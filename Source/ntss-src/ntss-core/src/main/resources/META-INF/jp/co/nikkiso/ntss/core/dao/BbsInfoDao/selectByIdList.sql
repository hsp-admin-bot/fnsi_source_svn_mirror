WITH mss_bbs_kind AS (
  select
    mss.facility_cd, ms.*, row_number() over() as ord_index
  from
    mst_selector mss
    cross join lateral jsonb_to_recordset(mss.order_settings->'items') as ms
    (
      code bigint,
      name text
    )
  where
    master_physical_name = 'mst_bbs_kind'
    AND facility_cd = /*facility_cd*/null
)

select distinct
  A.bbs_ctl_no, A.facility_cd, A.pat_info, A.staff_info, A.func_cd, A.kind_no, A.fn_seq_id, A.title, A.content, A.file_info, A.notice_start_date, A.notice_end_date,
  A.reg_staff_id, A.reg_staff_name, A.upd_staff_id, A.upd_staff_name, A.transition_router_path, A.reg_date, A.up_date, A.is_disp, A.is_del, A.notice_fac_cal_start_date,
  A.notice_fac_cal_end_date, A.is_disp_bbs, A.color, A.reg_func_class, A.html_content,
  CASE
    WHEN CAST(/* targetUserId */null AS TEXT) = ANY (
      SELECT jsonb_array_elements_text(A.staff_info::jsonb -> 'read')
    ) THEN 2
    ELSE 1
  END AS staff_info_sort,
  CASE WHEN A.notice_start_date is null or A.notice_start_date=''  THEN '1900/01/01' ELSE  to_char(to_date( A.notice_start_date, 'YYYYMMDD' ), 'YYYY/MM/DD') END || ' ～ ' ||
  CASE WHEN  A.notice_end_date is null or A.notice_end_date=''  THEN '9999/12/31' ELSE to_char(to_date( A.notice_end_date, 'YYYYMMDD' ), 'YYYY/MM/DD') END AS notice_date,
  A.font_color,
  MSB.ord_index AS bbs_kind_ord_index,
-- add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応  --start
  MBK.kind_name,
-- add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応  --end
  CASE
    WHEN A.transition_router_path = 'pat-info' THEN 1
    WHEN A.transition_router_path = 'pat-viewer' THEN 2
    WHEN A.transition_router_path = 'treatment-record' THEN 3
    WHEN A.transition_router_path = 'observe-record' THEN 4
    WHEN A.transition_router_path = 'pat-event' THEN 5
    WHEN A.transition_router_path = 'exam-record' THEN 6
    WHEN A.transition_router_path = 'schedule-list' THEN 7
    ELSE 999
  END AS transition_path_sort -- 施設イベント編集＞画面遷移プルダウンリスト順と同じ
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
		is_disp_bbs,
		staff_info,
		fn_seq_id,
		title,
		content,
		file_info,
		reg_staff_id,
		reg_staff_name,
		upd_staff_id,
		upd_staff_name,
		transition_router_path,
		reg_date,
		up_date,
		notice_fac_cal_start_date,
		notice_fac_cal_end_date,
		color,
		reg_func_class,
		html_content,
		font_color
	FROM
		bbs_info B
	WHERE
	    facility_cd = /* facility_cd */null
		AND B.notice_start_date ~ '^\d{1,4}\d{2}\d{2}$'
		AND B.notice_end_date ~ '^\d{1,4}\d{2}\d{2}$'
		AND B.is_del = '0'
		AND B.is_disp = '1'
		AND B.is_disp_bbs in ('1','3')
) A
LEFT JOIN mss_bbs_kind MSB on A.kind_no = MSB.code
-- add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応  --start
LEFT JOIN mst_bbs_kind MBK on A.kind_no = MBK.kind_no
-- add by chamaojia 2026-02-05 [11893] キャッシュ軽減対応  --end
where
  A.facility_cd = /* facility_cd */null

--- 機能コード
/*%if func_cd_list.size() != 0 */
  and func_cd in /* func_cd_list */(null)
/*%end */

--- 種類番号
/*%if kind_no_list.size() != 0 */
  -- update by chamaojia 2026-02-05 [11893] キャッシュ軽減対応  --start
  and A.kind_no in /* kind_no_list */(null)
  -- update by chamaojia 2026-02-05 [11893] キャッシュ軽減対応  --end
/*%end */

--- 期間指定
/*%if notice_start_date != null && notice_end_date != null */
  and (
    (/* notice_start_date */null <= A.notice_start_date and  A.notice_start_date <= /* notice_end_date */null)
    or (/* notice_start_date */null <= A.notice_end_date and A.notice_end_date <= /* notice_end_date */null)
    or (A.notice_start_date <= /* notice_start_date */null and /* notice_start_date */null <= A.notice_end_date)
    or (A.notice_start_date <= /* notice_end_date */null and /* notice_end_date */null <= A.notice_end_date)
    or (A.notice_start_date <= /* notice_end_date */null and A.notice_end_date is null)
    or (/* notice_start_date */null <= A.notice_end_date and A.notice_start_date is null)
    or (A.notice_start_date is null and A.notice_start_date is null)
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
  and A.is_disp_bbs in ('1','3')

/*%if userId != null */
  and not (A.staff_info::jsonb -> 'read' @> ('[' || /* userId */0 || ']')::jsonb)
/*%end */

  and (A.staff_info::jsonb -> 'target' = '[]'::jsonb
/*%if targetUserId != null */
        or A.staff_info::jsonb -> 'target' @> ('[' || /* targetUserId */null || ']')::jsonb
/*%end */

      )order by
/*%if sortColumn == "func_cd" && sortKind == "asc" */
    bbs_kind_ord_index asc
/*%elseif sortColumn == "func_cd" && sortKind == "desc" */
    bbs_kind_ord_index desc
/*%elseif sortColumn == "content" && sortKind == "asc" */
    A.content asc
/*%elseif sortColumn == "content" && sortKind == "desc" */
    A.content desc
/*%elseif sortColumn == "read_state" && sortKind == "asc" */
    staff_info_sort asc
/*%elseif sortColumn == "read_state" && sortKind == "desc" */
    staff_info_sort desc
/*%elseif sortColumn == "transition_router_path" && sortKind == "asc" */
    transition_path_sort asc
/*%elseif sortColumn == "transition_router_path" && sortKind == "desc" */
    transition_path_sort desc
/*%elseif sortColumn == "notice_date" && sortKind == "asc" */
    A.notice_start_date asc NULLS FIRST, A.notice_end_date asc
/*%elseif sortColumn == "notice_date" && sortKind == "desc" */
    A.notice_start_date desc, A.notice_end_date desc NULLS FIRST
/*%else */
    staff_info_sort asc, bbs_kind_ord_index asc, A.notice_start_date asc NULLS FIRST, A.notice_end_date asc
/*%end */
/*%if !(sortColumn == null || sortKind == null) */
    , staff_info_sort asc, bbs_kind_ord_index asc, A.notice_start_date asc NULLS FIRST, A.notice_end_date asc
/*%end */
/*%if sortColumn != "pat_info"*/
limit  /* limitTo */0 offset /* limitFrom */0
/*%end */
;


