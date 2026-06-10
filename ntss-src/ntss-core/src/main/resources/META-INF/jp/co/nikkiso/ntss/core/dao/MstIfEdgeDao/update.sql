UPDATE
  mst_if_edge A
SET
  facility_cd = /*mie.facilityCd*/null,
  if_edge_no = /*mie.ifEdgeNo*/null,
  if_edge_name = /*mie.ifEdgeName*/null,
  is_disp = /*mie.isDisp*/null,
  is_del = /*mie.isDel*/null,
  setting_date = to_timestamp(/*mie.upDate*/null, 'YYYY-MM-DD HH24:MI:SS'),
  memo = /*mie.memo*/null,
  up_date = to_timestamp(/*mie.upDate*/null, 'YYYY-MM-DD HH24:MI:SS')
WHERE
  A.serial_no = /*mie.serialNo */'999999'