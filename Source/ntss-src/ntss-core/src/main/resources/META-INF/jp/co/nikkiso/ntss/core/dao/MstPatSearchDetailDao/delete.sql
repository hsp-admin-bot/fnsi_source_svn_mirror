update mst_pat_search_detail 
set 
  is_disp = '0',
  is_del = '1'
where
  search_cd = /*searchCd*/null;