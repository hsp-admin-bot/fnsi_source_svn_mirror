UPDATE ntss.sys_data_set SET sql='{"collection" : "ind_history","eq" : { "pat_id" : "@patId","facility_cd" : "@facilityCd" },"sort" : {"log_date" : "asc"}}' WHERE sql_cd=192;
