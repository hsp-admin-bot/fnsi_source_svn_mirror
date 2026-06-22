-- オーダーの各data_typeごとに最新のレコードを取得する。日付が同じレコードが二つ以上ある場合はオーダー番号の降順で整列する
select
-- mod #6264 2022-08-04 治療状況リスト・マップの表示項目の参照先がmni_monitor→mnt_machine_state.monitor_dataに変更されていない。 dou start
--   /*%expand "A" */*
    A.reg_date,
    A.up_date,
    A.bio_moni_ctl_no,
    A.facility_cd,
    A.machine_type_cd,
    A.machine_serial,
    A.ord_no,
    A.pat_id,
    A.data_type,
-- mod #7862 2022-09-13 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou start
--  C.monitor_data,
    CASE WHEN A.data_type = 1 and C.monitor_data is not null and C.ord_no = C.next_ord_no THEN C.monitor_data
         ELSE A.monitor_data
    END,
-- mod #7862 2022-09-13 【デグレ】治療状況リスト，治療状況マップの表示が不正_再発 dou end
    A.is_del,
    A.occur_date,
    A.upd_staff_id
-- mod #6264 2022-08-04 治療状況リスト・マップの表示項目の参照先がmni_monitor→mnt_machine_state.monitor_dataに変更されていない。 dou end
from
  mni_monitor A inner join (
  select
      ord_no,
      data_type,
      MAX(occur_date) AS occur_date
  from
    mni_monitor
  where
    ord_no in /*ordNoList*/(0)
    and
	facility_cd = /*facilityCd*/null
	and
    is_del = '0'
  group by
    -- 治療状況性能改善 劉 start
    ord_no,
    -- 治療状況性能改善 劉 end
    data_type
 ) as B on A.data_type = B.data_type
    AND A.occur_date = B.occur_date
      -- mod #6746 by zhangruixue 2023-04-14  --start
    AND A.ord_no = B.ord_no
      --  mod #6746 by zhangruixue 2023-04-14  --end
      -- 治療状況性能改善 劉祥霖 start
   -- 治療状況性能改善 劉祥霖 end
-- add #6264 2022-08-04 治療状況リスト・マップの表示項目の参照先がmni_monitor→mnt_machine_state.monitor_dataに変更されていない。 dou start
   left join mnt_machine_state C
   on A.facility_cd = C.facility_cd
   and A.machine_type_cd = C.machine_type_cd
   and A.machine_serial = C.machine_serial
   and A.ord_no = C.ord_no
   and A.pat_id = C.pat_id
-- add #6264 2022-08-04 治療状況リスト・マップの表示項目の参照先がmni_monitor→mnt_machine_state.monitor_dataに変更されていない。 dou end
-- mod #6746 by zhangruixue 2023-04-14  --start
where A.facility_cd = /*facilityCd*/null
  and A.ord_no in /*ordNoList*/(0)
-- mod #6746 by zhangruixue 2023-04-14  --end
order by
  A.bio_moni_ctl_no desc
;
