-- sys_master_define の欠損部分修正
UPDATE sys_master_define SET edit_level = '1' Where edit_level is null;
