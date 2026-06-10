-- #6971 治療状況レイアウトマスタにて、「透析液量」→「透析液使用数」に修正する事。
update mst_treatment_status_disp_item set item_name = '透析液使用数' WHERE item_name = '透析液量'
