--サービスコード追加
--データ削除
DELETE FROM sys_system_define WHERE ctl_no = '40' or ctl_no = '1014';

--データ追加
insert into sys_system_define(
  ctl_no, service_cd, name, value, description, is_enable, up_date
  )
values (
'40','003','スケールベッドアプリケーション最新バージョン','{"version": "2.0.0.0"}','対象アプリケーションの最新版バージョンを設定することでアプリケーションのアップデートを実施する','1',current_timestamp
),('1014', '003', 'スケールベッドアプリケーションログ出力先', '{"path": "/efs/{0}/{1}/スケールベッドアプリ/"}'::jsonb, '対象アプリケーションのログファイル出力先を指定する。 ※{0}は施設コードに変換', '1', NOW()
);

