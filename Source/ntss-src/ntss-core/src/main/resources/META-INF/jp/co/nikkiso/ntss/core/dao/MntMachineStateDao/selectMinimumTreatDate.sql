-- 指定施設、デバイスエッジ番号で指定期間内で最小の次患者治療日時を取得する
select
  min(a.treat_date) as min_treat_date
from
  ord_main a
inner join
  (select
    b1.*
  from
    mnt_machine_state b1
    inner join
      mst_machine b2
    on
      b1.machine_type_cd = b2.machine_type_cd
    and
      b1.machine_serial = b2.machine_serial
    and
      b2.device_edge_no = /*deviceEdgeNo*/1
  where
    b2.facility_cd = /*facilityCd*/'999900'
  and
    b2.is_del = '0'
  ) b
on
  a.ord_no = b.next_ord_no
where
  treat_date between /*startDate*/'20191210' and /*endDate*/'20191220'
;