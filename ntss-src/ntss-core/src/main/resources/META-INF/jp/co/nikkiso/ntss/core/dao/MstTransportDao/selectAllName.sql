--搬送区分
  select
    transport_cd,
    transport_name
  from
    mst_transport A
  where
    A.transport_cd in /* transportCds */(null)
;
