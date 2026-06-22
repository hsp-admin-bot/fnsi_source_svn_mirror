select
   /*%expand "A" */*
from
   mst_pat_search_detail A
where
   A.search_cd = /*searchCd*/null;
