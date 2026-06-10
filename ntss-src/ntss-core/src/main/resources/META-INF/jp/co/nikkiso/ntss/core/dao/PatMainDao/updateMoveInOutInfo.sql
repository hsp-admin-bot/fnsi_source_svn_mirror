-- 指定日の入外・転入出情報取得
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
  /*%if move_in_out_cd_list.size() != 0 */
  and
    in_out_visit_history_info.move_in_out in /* move_in_out_cd_list */(null)
  /*%end */
  and
    in_out_visit_history_info.period_start = /* targetDt */'99991231'
  order by
    in_out_visit_history_info.ctl_no desc
),

-- 指定日（基本は当日）以降で直近未来日の入外・転入出情報取得
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
  in_out_current_state = 
    case 
      when infNext.nextMoveInOut = '1' then '1' -- 次回予定が導入 → 導入予定
      when infNext.nextMoveInOut = '2' then '2' -- 次回予定が転入 → 転入予定
      else
        case infToday.moveInOut
          when '1' then '0' -- 導入 → 在院
          when '2' then '0' -- 転入 → 在院
          when '3' then '3' -- 転出 → 転出
          when '4' then '0' -- 入院 → 在院
          when '5' then '0' -- 退院 → 在院
          when '6' then '0' -- 外来 → 在院
          when '7' then '7' -- 離脱 → 離脱
          when '8' then '8' -- 移植 → 移植
          when '9' then 
            case
              when infToday.periodEnd IS NULL OR infToday.periodEnd >= /* today */'99991231' then '9' -- 一時転出 → 一時転出
              else '0' -- 一時転出終了→在院
            end
          when '10' then '10' -- 通院拒否・不明 → 不明
          when '11' then '11' -- 死亡 → 死亡
          else null
        end
    end,
  in_out_plan_state = 
    case 
      when infToday.moveInOut = '9' AND (infToday.periodEnd IS NOT NULL AND /* today */'99991231' <= infToday.periodEnd AND (infNext.nextPeriodStart IS NULL OR infToday.periodEnd <= infNext.nextPeriodStart)) then '0' -- 一時転出終了日が早い場合は次回予定は'在院'
      else
        case infNext.nextMoveInOut
          when '1' then '0' -- 導入 → 在院
          when '2' then '0' -- 転入 → 在院
          when '3' then '3' -- 転出 → 転出
          when '4' then '0' -- 入院 → 在院
          when '5' then '0' -- 退院 → 在院
          when '6' then '0' -- 外来 → 在院
          when '7' then '7' -- 離脱 → 離脱
          when '8' then '8' -- 移植 → 移植
          when '9' then '9' -- 一時転出 → 一時転出
          when '10' then '10' -- 通院拒否・不明 → 不明
          when '11' then '11' -- 死亡 → 死亡
          else null
        end
    end,
  in_out_plan_date =
    case
      when infToday.moveInOut = '9' AND (infToday.periodEnd IS NOT NULL AND /* today */'99991231' <= infToday.periodEnd AND (infNext.nextPeriodStart IS NULL OR infToday.periodEnd <= infNext.nextPeriodStart)) then to_timestamp(infToday.periodEnd, 'YYYYMMDD') -- 一時転出終了日が早い場合は次回予定は一時転出終了日
      else
        case infNext.nextPeriodStart
          when null then null
          else to_timestamp(infNext.nextPeriodStart, 'YYYYMMDD')
        end
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
