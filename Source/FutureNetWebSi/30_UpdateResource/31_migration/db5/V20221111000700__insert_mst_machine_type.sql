delete from ntss.mst_machine_type where machine_type_cd in ('999');
INSERT INTO ntss.mst_machine_type
(machine_type_cd,machine_type,model,maker,reg_date,up_date,com_type,treat_mode,over_nxseries) VALUES ('999','その他','005','その他',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'[{"text": "オフライン運用", "value": "0", "com_format_cd": [{"text": "オフライン(F)", "value": "F"}]}]','0','0');
