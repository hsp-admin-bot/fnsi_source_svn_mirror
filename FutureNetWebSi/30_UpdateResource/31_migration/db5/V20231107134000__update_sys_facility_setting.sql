-- add 9200 by kangjie start
UPDATE sys_facility_setting
SET description = '患者経過総合ビューアで投与薬剤を表示する際に、画面表示される最大の未来日からこの値を加算した未来日付までの投与薬剤を表示します。「0」を入力した場合、「上限なし」となります。',
input_type = 2,
option_value = '[{"min":"0",  "max":"365"}]' 
WHERE
	facility_setting_no = '3008' 
	AND disp_order = 108;

-- add 9200 by kangjie end