select
	mms.bed_cd
from
  mnt_machine_state as mms
inner join
  ord_main om
  on mms.ord_no = om.ord_no
where
  mms.facility_cd = /*facility_cd*/'0'
  and mms.ord_no is not null
   --mod #9594 ベッドマスタでプリンター及び自動印刷の設定を変更し、保存しようとするとメッセージが表示され保存できない zrx start
--   and om.rst_dialysis_state in ('1','2','3','4','5')
  and om.rst_dialysis_state in ('1','2','3')
  --mod #9594 ベッドマスタでプリンター及び自動印刷の設定を変更し、保存しようとするとメッセージが表示され保存できない zrx end
  and om.is_del = '0'
