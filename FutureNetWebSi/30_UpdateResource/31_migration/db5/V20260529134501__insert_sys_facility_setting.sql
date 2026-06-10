DELETE from ntss.sys_facility_setting where facility_setting_no = '3144';

INSERT INTO ntss.sys_facility_setting(facility_setting_no,setting_name,default_value,input_type,option_value,function_name,maker_setting,description,disp_order,reg_date,up_date,system_use_disp) VALUES 
    ('3144','サインインIF表示設定','1',4,'[{"id":"0","name":"0:非表示"},{"id":"1","name":"1:表示"}]','サインイン',0,'サインイン画面のID・パスワード入力欄およびサインインボタンの表示/非表示を設定します。<br>シングルサインオンに限定した運用をする場合に非表示設定をしてください。',152,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'3');
