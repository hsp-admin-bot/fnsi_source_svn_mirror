--感染症
  select
    A.infection_cd,
    A.infection_name
  from
    mst_infection A
  where
    A.infection_cd in /* infectionCds */(null)
;
