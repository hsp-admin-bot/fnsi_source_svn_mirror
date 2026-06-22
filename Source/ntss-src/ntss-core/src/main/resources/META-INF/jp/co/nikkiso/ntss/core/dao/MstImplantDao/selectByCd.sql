SELECT /*%expand */*
FROM mst_implant
WHERE implant_cd = /*implantCd*/0
  AND is_disp = '1'
  AND is_del = '0'
