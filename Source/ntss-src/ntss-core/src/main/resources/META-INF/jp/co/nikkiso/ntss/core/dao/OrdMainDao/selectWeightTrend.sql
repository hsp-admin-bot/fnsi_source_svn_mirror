select
  O.treat_date,
  O.rst_weight_info ->> 'weight_before' as weight_before,
  O.rst_weight_info ->> 'weight_after' as weight_after,
  O.rst_weight_info ->> 'weight_decreased' as weight_decreased,
  O.rst_dw as dw
from
  ord_main O
-- del by chamaojia 2025-02-27 [11471] The value of 【rst】 does not need to be associated --start
-- left outer join mst_treatment T on O.rst_treatment_cd = T.treatment_cd
-- del by chamaojia 2025-02-27 [11471] The value of 【rst】 does not need to be associated --end
  -- add by chamaojia 2026-04-13 [11740] 【#11471】特殊浄化判定処理の見直し --start
  inner join mst_machine M on O.rst_machine_no = M.machine_no
  -- add by chamaojia 2026-04-13 [11740] 【#11471】特殊浄化判定処理の見直し --end
where
  O.pat_id = /*patId*/1
and
  O.is_del = '0'
and
-- modify by chamaojia 2025-02-27 [11471] The value of 【rst】 does not need to be associated --start
--   T.device_mode <> 9
  -- upd by chamaojia 2026-04-13 [11740] 【#11471】特殊浄化判定処理の見直し --start
  (O.rst_device_mode <> 9 or M.com_type <> 0)
  -- upd by chamaojia 2026-04-13 [11740] 【#11471】特殊浄化判定処理の見直し --end
-- modify by chamaojia 2025-02-27 [11471] The value of 【rst】 does not need to be associated --end
order by
  O.treat_date desc,
  O.ord_no desc
limit 15
;
