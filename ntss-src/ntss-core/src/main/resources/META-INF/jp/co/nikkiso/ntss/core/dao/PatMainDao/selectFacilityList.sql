select
	A.facility_cd,
	A.facility_name,
	B.pat_id
from
  mst_facility A,
  pat_main B
where
  A.facility_cd = B.facility_cd
  AND
  A.facility_cd = /*facilityCd*/'000000'
  AND
  pat_id = /*patId*/0

  union

select
	A.facility_cd,
	A.facility_name,
	B.pat_id
from
  mst_facility A,
  pat_main B
where
  A.facility_cd = B.facility_cd
  AND
  A.facility_cd in (
          select
            facility_cd_src
          from
            pat_name_identification
          where
            (pat_id_dst = /*patId*/0
            and
            facility_cd_dst = /*facilityCd*/'000000'
            and
            approve = '1'
            and
            is_open = '1')
     )
  AND
  pat_id in (
          select
            pat_id_src
          from
            pat_name_identification
          where
            (pat_id_dst = /*patId*/0
            and
            facility_cd_dst = /*facilityCd*/'000000'
            and
            approve = '1'
            and
            is_open = '1')
     )
;

