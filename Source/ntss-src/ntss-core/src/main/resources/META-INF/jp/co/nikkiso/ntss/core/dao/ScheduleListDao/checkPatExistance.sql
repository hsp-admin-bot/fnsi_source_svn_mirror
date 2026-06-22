--データが存在するかの確認
-- 移動しようと選択したセルについて、他の処理でデータが変更されていないかの確認
select
exists
(
	select
	*
	from
	ord_schedule sche,ord_main ord
	where
	sche.facility_cd = ord.facility_cd
	and
  sche.ord_no = ord.ord_no
  and
	sche.treat_date = /*treatDate*/'19990101'
	and
	ord.ord_no = /*ordNo*/0
	and
	sche.kur_cd =  /*kurCd*/0
	and
	sche.bed_cd =  /*bedCd*/0
	and
	ord.rst_dialysis_state = /*dialysisState*/null
	and
	sche.is_dummy = /*isDummy*/null
)
