truncate table mst_facility CASCADE;

insert into mst_facility
   (facility_cd, facility_name, use_function)
values
   ('900001', 'test_sisetsu1', '{"func_cds": [{"func_cd": "001"}, {"func_cd": "002"}, {"func_cd": "003"}, {"func_cd": "004"}]}')
   , ('900002', 'test_sisetsu2', '{"func_cds": []}')
   , ('900003', 'test_sisetsu3', NULL)
;
