update "mst_coop_layout_detail"
set 
"coop_name" = 'Medicomカルテ記載(透析経過データ連携)',
"description" = '★無効設定',
"is_del" = '1'
where 
"facility_cd" = 'P_hosp'
and "coop_cd" = 'karte_ord';