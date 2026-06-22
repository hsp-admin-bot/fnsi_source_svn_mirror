DELETE FROM pat_unique
WHERE pat_id = 10400;

INSERT INTO pat_unique(pat_id, medical_hst_info,
in_out_visit_history_info, physical_info, is_del, up_date, reg_date)
VALUES (
10400,
'{}',
'{}',
'{}',
'0',
'2020-03-04 16:50:00',
'2020-03-04 16:50:00'
);
