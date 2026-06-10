-- mni_monitorから指定ord_no、data_typeの最新情報を取得
select
  /*%expand */*
from
  mni_monitor
where
-- ADD BY Zhou.tao 10373 Add a parameter to improve performance
  facility_cd = /*facilityCd*/'NKKSBR' and
  ord_no = /*ordNo*/null
and
  data_type=/*dataType*/null
and
  is_del = '0'
order by
  occur_date desc
  , bio_moni_ctl_no desc
LIMIT 1
;
