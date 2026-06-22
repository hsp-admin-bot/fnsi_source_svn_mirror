set pages 999
set echo on
connect fnsiview/fnsiview@fnsiview as sysdba

spool CREATE_USER.log

DROP USER fnsi CASCADE;
CREATE USER fnsi IDENTIFIED BY fnsi
    DEFAULT TABLESPACE USERS
    TEMPORARY TABLESPACE TEMP;

grant connect to fnsi;
grant select any table to fnsi;

spool off
exit
