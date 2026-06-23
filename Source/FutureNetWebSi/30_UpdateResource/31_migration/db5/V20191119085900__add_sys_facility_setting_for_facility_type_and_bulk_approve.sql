INSERT INTO sys_facility_setting ( 
  facility_setting_no,
  setting_name,
  default_value,
  input_type,
  option_value,
  function_name,
  maker_setting,
  description,
  disp_order,
  reg_date,
  up_date
) 
VALUES (
  '1023',
  '受付・承認単位',
  '1',
  4,
  '[{"id":"1","name":"1:治療単位"},{"id":"2","name":"2:指示単位"}]',
  '受付・承認単位',
  0,
  '指示受け・承認で「治療単位」もしくは「指示単位」を選択できるようにする',
  23,
  current_timestamp,
  current_timestamp
);

INSERT INTO sys_facility_setting ( 
  facility_setting_no,
  setting_name,
  default_value,
  input_type,
  option_value,
  function_name,
  maker_setting,
  description,
  disp_order,
  reg_date,
  up_date
) 
VALUES (
  '1024',
  '一括承認',
  '0',
  3,
  '',
  '一括承認',
  0,
  '指示受け・承認で医師による一括承認を許可/不許可を選択できるようにする。',
  24,
  current_timestamp,
  current_timestamp
);
