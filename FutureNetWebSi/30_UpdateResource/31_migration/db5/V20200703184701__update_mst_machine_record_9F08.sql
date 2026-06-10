-- 装置記録マスタ「mst_machine_record」にて血圧警報：9F08の定義「通信データ異常」を「血圧警報発生」に変更
update
  mst_machine_record
set
  machine_record_message = '血圧警報発生',
  up_date = now()
where machine_record_cd = '9F08'
;