--検査結果  前回定義期間
INSERT INTO ntss.sys_facility_setting (facility_setting_no,setting_name,default_value,input_type,option_value,function_name,maker_setting,description,disp_order,reg_date,up_date,system_use_disp)
VALUES ('3012','前回定義期間','31',2,'[{"min":"0",  "max":null}]','検査結果',0,'単位：日。いつまでの検査を前回とできるか',112,now(),now(),'3');