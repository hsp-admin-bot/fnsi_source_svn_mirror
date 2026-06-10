select
    model_number,
    maker,
    -- add by chamaojia 2024-06-07 [10754] 接頭文字対応  --start
    use_end_date,
    is_disp,
    is_del
    -- add by chamaojia 2024-06-07 [10754] 接頭文字対応  --end
from
    mst_dialyzer
where
    facility_cd = /*facility_cd*/''
    and
    dialyzer_cd = /*cd*/0 
;
