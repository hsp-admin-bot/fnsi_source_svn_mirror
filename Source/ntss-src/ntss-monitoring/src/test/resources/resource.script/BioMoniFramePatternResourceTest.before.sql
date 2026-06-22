insert into mst_bio_moni_frame_pattern 
  (facility_cd, ctl_no, template_name, frame_no, define_info)
values
  ('431844', 1, 'test', 1, '{"l1":{"l2":[{"c1":"t1","c2":1},{"c1":"t2","c2":2}]}}'::JSONB)
;