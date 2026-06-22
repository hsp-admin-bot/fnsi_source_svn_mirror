--add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou start
select
  facility_name
from
  mst_facility
where
  facility_cd = /*facilityCd*/''
  ;
--add FNSI-改修内容　イベント一覧の日付直下に、施設名を表示する dou end
