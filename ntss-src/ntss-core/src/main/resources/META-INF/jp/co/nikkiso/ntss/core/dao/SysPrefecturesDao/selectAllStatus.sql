select
  pref_cd as "classCd",
  pref_name as "className"
from
  sys_prefectures A
WHERE 1 = 1
  /*%if params.get("___noop") != null */
  AND 1 = 0
  /*%end*/
;
