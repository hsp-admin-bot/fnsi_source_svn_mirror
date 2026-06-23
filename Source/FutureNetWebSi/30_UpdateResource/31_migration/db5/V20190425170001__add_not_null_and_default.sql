-- 送信先グループマスタの送信対象に制約とデフォルト値を追加
alter table mst_destination_group
alter column destination_target set not null,
alter column destination_target set default '{"users": []}';

-- 警報通知マスタの対象装置記録に制約とデフォルト値を追加
alter table mst_alarm_notification
alter column target_machine_record set not null,
alter column target_machine_record set default '{"cds": []}';
