DELETE 
FROM
  "ntss"."mnt_mainte_main" 
WHERE
  mainte_layout_group_cd IS NULL 
  AND mainte_layout_group_edition IS NULL 
  AND mainte_layout_cd IS NULL 
  AND mainte_layout_edition IS NULL