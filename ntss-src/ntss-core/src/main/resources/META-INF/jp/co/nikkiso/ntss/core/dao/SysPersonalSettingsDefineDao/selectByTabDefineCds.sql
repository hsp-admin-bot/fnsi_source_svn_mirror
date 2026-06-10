select
  personal_settings_cd
  , tab_define_cd
  , edit_level
  , item_info
  , combo_data
  , reference_combo_def
from
  sys_personal_settings_define
where
  tab_define_cd in /* tabDefineCds */(1, 2)
;
