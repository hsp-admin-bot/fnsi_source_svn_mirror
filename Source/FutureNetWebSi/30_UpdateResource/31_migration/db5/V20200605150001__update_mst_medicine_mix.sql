-- mst_medicine_mix.mix_info から 'unit' キーを削除
update
  mst_medicine_mix
set
  mix_info = B.mix_info
from (
  select
    A.medicine_mix_cd,
    json_agg(A.deleted_info) as mix_info
  from (
    select
      mst_medicine_mix.medicine_mix_cd,
      each_info - 'unit' as deleted_info
    from
      mst_medicine_mix
    cross join
      jsonb_array_elements(mst_medicine_mix.mix_info) each_info
    ) A
  group by
    A.medicine_mix_cd
  order by
    A.medicine_mix_cd
  ) B
where
  mst_medicine_mix.medicine_mix_cd = B.medicine_mix_cd;