update mst_pat_list_layout
set
  pat_list_layout_name = /* patListLayout.patListLayoutName */null,
  disp_item_info = jsonb(/* patListLayout.dispItemInfo */null),
  occupations = jsonb(/* patListLayout.occupations */null),
  is_disp = /* patListLayout.isDisp */null,
  is_del = /* patListLayout.isDel */null,
  up_date = to_timestamp(/* patListLayout.upDate */null, 'YYYY-MM-DD HH24:MI:SS')
where
  pat_list_layout_cd = /*pat_list_layout_cd*/null
;