select os.facility_cd as facility_cd, ord_no, treat_date, os.kur_cd as kur_cd, bed_cd
from ord_schedule os
       inner join mst_kur mk
                  on os.facility_cd = mk.facility_cd and os.kur_cd = mk.kur_cd and mk.is_del = '1' and
                     os.is_dummy = '1'
where os.facility_cd = /* facilityCd */null
  and os.treat_date >= to_char(now(), 'YYYYMMDD');
