with reset_data as (select layout_cd, jsonb_agg(item_info) as disp_item_info
                    from (select facility_calendar_layout_cd          as layout_cd,
                                 jsonb_array_elements(disp_item_info) as item_info
                          from mst_facility_calendar_layout
                          where disp_item_info is not null
                            and disp_item_info::text like '%日常点検列名分繰り返す%') t
                    where item_info::text not like '%日常点検列名分繰り返す%'
                    group by layout_cd)
update mst_facility_calendar_layout
set disp_item_info = rd.disp_item_info
from reset_data rd
where facility_calendar_layout_cd = layout_cd;