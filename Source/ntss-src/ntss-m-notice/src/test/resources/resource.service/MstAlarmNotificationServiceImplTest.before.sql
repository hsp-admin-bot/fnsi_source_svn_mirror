delete from mst_staff_facility;
delete from mst_alarm_notification;
delete from mst_destination_group;
delete from mst_facility where facility_cd in ('09999', '09998', '09997');

insert into
  mst_facility
  (
    facility_cd,
    facility_name
  )
VALUES
  ('09999', 'sisetu9999'),
  ('09998', 'sisetu9998'),
  ('09997', 'sisetu9997')
;

delete from mst_machine_record;
insert into mst_machine_record(machine_record_cd,machine_record_message,reg_date,up_date)
values 
   ('4501','血液ポンプ電源「切」','2017/11/30','2017/11/30'),
   ('4505','背圧弁ダイアフラム交換時期','2017/11/30','2017/11/30'),
   ('4829','複式ベアリング交換時期','2017/11/30','2017/11/30'),
   ('4923','ＴＭＰゼロ補正完了','2017/11/30','2017/11/30'),
   ('7842','薬液消毒キャンセル：装置停止','2017/11/30','2017/11/30'),
   ('A500','バイパス警報','2017/11/30','2017/11/30'),
   ('AC09','給水流量下限報知','2017/11/30','2017/11/30'),
   ('F464','補液速度変更','2017/11/30','2017/11/30'),
   ('FFFF','緊急停止','2017/11/30','2017/11/30')
;
