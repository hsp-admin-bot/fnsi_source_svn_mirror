delete
from mst_coop_apilink
where coop_cd = 'profile'
  and api_body::text like '%"crud": "D"%'
  and facility_cd in ('C_hosp', 'F_hosp', 'NEC-iS', 'nkknkk', 'S_hosp', 'N_hosp')
  and api_uri = 'http://localhost:8080/ntss-coop-api/journal/create';