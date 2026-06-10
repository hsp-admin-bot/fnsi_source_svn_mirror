-- #11705 mst_user.is_provisionalをNULLでコンバートしている
UPDATE mst_user 
SET is_provisional = COALESCE ( is_provisional, 0 ),
is_set_qr_code = COALESCE ( is_set_qr_code, 0 ) 
WHERE
  is_provisional IS NULL 
  OR is_set_qr_code IS NULL;