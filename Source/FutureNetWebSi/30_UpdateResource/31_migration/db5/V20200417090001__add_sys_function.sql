-- sys_function にデータ更新

update
  sys_function
set
  function_name = 'データリスト'
where
  function_cd = '008';