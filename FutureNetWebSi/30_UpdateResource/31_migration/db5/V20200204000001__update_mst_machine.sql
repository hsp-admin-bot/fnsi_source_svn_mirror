-- 使用不可フラグ(is_disable)がNULLのものを'0'に変更
update
  mst_machine
set
  is_disable = '0'
where
  is_disable IS NULL;
