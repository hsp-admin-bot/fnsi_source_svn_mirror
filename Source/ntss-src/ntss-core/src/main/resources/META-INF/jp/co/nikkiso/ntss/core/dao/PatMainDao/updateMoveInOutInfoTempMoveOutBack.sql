-- 入外・転入出情報から指定日が終了日となる一時転出データを取得
with infToday as (
  select
    pu.pat_id as patId,
    pu.is_del as isDel,
    pm.facility_cd as facilityCd,
    in_out_visit_history_info.ctl_no as ctlNo,
    in_out_visit_history_info.move_in_out as moveInOut,
    in_out_visit_history_info.in_out as inOut,
    in_out_visit_history_info.period_start as periodStart,
    in_out_visit_history_info.period_end as periodEnd
   from
    pat_unique pu,
    pat_main pm
   cross join lateral
    jsonb_to_recordset(pu.in_out_visit_history_info)
   as in_out_visit_history_info
   (
    ctl_no int,
    in_out text,
    disp_order int,
    period_start text,
    period_end text,
    move_in_out text
   )
  where
    pu.is_del = '0'
  and
    pu.pat_id = pm.pat_id
  /*%if pat_id_list.size() != 0 */
  and
    pu.pat_id in /* pat_id_list */(null)
  /*%end */
  and
    in_out_visit_history_info.move_in_out = '9' -- 一時転出
  and
    in_out_visit_history_info.period_end = /* targetDt */'99991231'
  order by
    in_out_visit_history_info.ctl_no desc
),

-- 指定日以降で直近未来日の入外・転入出情報取得
infNext as (
  Select 
    nextInOutInfoA.pat_id as patId,
    in_out_visit_history_info.move_in_out as nextMoveInOut,
    nextInOutInfoB.nextPeriodStart as nextPeriodStart,
    in_out_visit_history_info.ctl_no as nextCtlNo
  From
    pat_unique As nextInOutInfoA
  cross join lateral
    jsonb_to_recordset(in_out_visit_history_info) as in_out_visit_history_info
    (
      ctl_no int,
      in_out text,
      disp_order int,
      period_start text,
      period_end text,
      move_in_out text
   )
  Inner join (
    select 
      pat_id,
      min(in_out_visit_history_info.period_start) as nextPeriodStart
    from
      pat_unique
    cross join lateral
      jsonb_to_recordset(in_out_visit_history_info) as in_out_visit_history_info
      (
        ctl_no int,
        in_out text,
        disp_order int,
        period_start text,
        period_end text,
        move_in_out text
      )
      where
        is_del = '0'
      and
        in_out_visit_history_info.period_start > /* today */'99991231'
      group by 
        pat_id
  ) As nextInOutInfoB
  on
    nextInOutInfoA.pat_id = nextInOutInfoB.pat_id
  and
    in_out_visit_history_info.period_start = nextInOutInfoB.nextPeriodStart
)

update 
  pat_main pm
set
  in_out_current_state = '0', -- 在院
  in_out_plan_state = infNext.nextMoveInOut,
  in_out_plan_date =
    case infNext.nextPeriodStart
      when null then null
      else to_timestamp(infNext.nextPeriodStart, 'YYYYMMDD')
    end,
  up_date = CURRENT_TIMESTAMP
From
  infToday
Left outer join
  infNext
On
  infToday.patId = infNext.patId
Where
  pm.pat_id = infToday.patId
/*%if pat_id_list.size() != 0 */
and
  pm.pat_id in /* pat_id_list */(null)
/*%end */
