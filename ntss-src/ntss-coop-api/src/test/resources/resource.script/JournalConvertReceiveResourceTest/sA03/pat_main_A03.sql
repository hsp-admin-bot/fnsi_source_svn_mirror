DELETE FROM pat_main
WHERE facility_cd = 'F_hA03';

INSERT INTO pat_main(
pat_id,
facility_cd,
is_implant,
is_infect,
is_diabetes,
pat_memo_info,
addition_info,
is_del
)
VALUES (
4000003,
'F_hA03',
'2',
'0',
'1',
'{"content":"foobar"}',
'{}',
'0'
);