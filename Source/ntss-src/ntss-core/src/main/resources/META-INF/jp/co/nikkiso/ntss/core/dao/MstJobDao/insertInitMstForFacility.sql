insert into mst_job (
  facility_cd,
  job_name,
  is_doctor,
  default_menu_settings,
  is_disp,
  is_del,
  reg_date,
  up_date,
  default_authorized_authorities
) values (
  /*facilityCd*/null,
  '医師',
  '1',
  /*defaultMenuSettings*/'{"initial_menu_function": "005", "default_menu_functions": ["005"]}'::jsonb,
  '1',
  '0',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  '013,023,033,043,053,133,063,073,083,093,103,113,991,992,993,994,995'
),
(
  /*facilityCd*/null,
  '看護師',
  '0',
  /*defaultMenuSettings*/'{"initial_menu_function": "005", "default_menu_functions": ["005"]}'::jsonb,
  '1',
  '0',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  '013,023,033,043,052,133,063,073,083,093,103,992,994'
),
(
  /*facilityCd*/null,
  '臨床工学技士',
  '0',
  /*defaultMenuSettings*/'{"initial_menu_function": "005", "default_menu_functions": ["005"]}'::jsonb,
  '1',
  '0',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  '013,023,033,043,052,133,063,073,083,093,103,113,994'
);
