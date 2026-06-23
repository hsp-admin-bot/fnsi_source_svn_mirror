update ntss.sys_data_set 
set
    "sql" = 'select ''TAR'' || to_char(NOW(), ''YYYYMMDDHH24MISS'') || ''.tar'' as filename'
where
    sql_cd = 146;