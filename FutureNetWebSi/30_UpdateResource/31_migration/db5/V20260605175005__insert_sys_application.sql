--スケールベッドサービスの登録
--データ削除
DELETE FROM sys_application WHERE application_name = 'スケールベッドアプリ';
--データ追加
insert into sys_application
(
  application_name, version , path, disp_order, reg_date, up_date, is_disp, is_del
)
values (
'スケールベッドアプリ','40','\ntss-admin-web\src\main\frontend\public\application\download\NKKScaleBedSetup.msi',6,current_timestamp,current_timestamp,1,0
);

