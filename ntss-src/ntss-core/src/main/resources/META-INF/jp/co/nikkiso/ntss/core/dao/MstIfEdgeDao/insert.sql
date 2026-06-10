INSERT 
INTO mst_if_edge( 
  serial_no
  , facility_cd
  , if_edge_no
  , if_edge_name
  , is_disp
  , is_del
  , setting_date
  , delete_date
  , memo
  , reg_date
  , up_date
) 
VALUES ( 
  /*mie.serialNo*/null
  , /*mie.facilityCd*/null
  , /*mie.ifEdgeNo*/null
  , /*mie.ifEdgeName*/null
  , /*mie.isDisp*/null
  , /*mie.isDel*/null
  , to_timestamp(/*mie.upDate*/null, 'YYYY-MM-DD HH24:MI:SS')
  , /*mie.deleteDate*/null
  , /*mie.memo*/null
  , to_timestamp(/*mie.regDate*/null, 'YYYY-MM-DD HH24:MI:SS')
  , to_timestamp(/*mie.upDate*/null, 'YYYY-MM-DD HH24:MI:SS')
);
