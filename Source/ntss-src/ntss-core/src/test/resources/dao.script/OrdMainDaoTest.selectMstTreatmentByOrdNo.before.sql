-- selectMstTreatmentByOrdNo のテストケースに関するテスト用データ
insert into ord_main
(
  ord_no,
  ind_treatment_cd,
  rst_treatment_cd,
  is_del
)
values (
  1000,
  1,
  2,
  '0'
), (
  1001,
  1,
  null,
  '0'
), (
  1002,
  null,
  3,
  '0'
), (
  1003,
  null,
  null,
  '0'
), (
  1004,
  3,
  4,
  '0'
), (
  1005,
  3,
  4,
  '1'
), (
  1006,
  5,
  null,
  '0'
);

insert into mst_treatment
(
  treatment_cd,
  facility_cd,
  fn_treatment_cd,
  treatment_name,
  is_del
)
values (
  1,
  '009999',
  null,
  'テスト治療方法1',
  '0'
),(
  2,
  '009999',
  null,
  'テスト治療方法2',
  '0'
),(
  3,
  '009999',
  null,
  'テスト治療方法3',
  '0'
),(
  4,
  '009999',
  null,
  'テスト治療方法4',
  '1'
),(
  5,
  '009999',
  null,
  'テスト治療方法5',
  '1'
);
