with item as (
    select
        mainte_layout_cd,
        facility_cd,
        jsonb_array_elements (type_info) as type_info_item
    from
        mst_mainte_layout
    where
        layout_class = '2'
), object_type_data as (
    select
        mainte_layout_cd
    from
        item
    where
        jsonb_typeof (type_info_item) = 'object'
    group by
        mainte_layout_cd
), old_order_tmp_tb as (
    select
        item.mainte_layout_cd,
        item.type_info_item,
        row_number() OVER (PARTITION BY item.mainte_layout_cd) as seq
    from
        item
     inner join object_type_data on
        item.mainte_layout_cd = object_type_data.mainte_layout_cd
    where
        jsonb_typeof (item.type_info_item) = 'string'
), result_tb as (
    select
        mainte_layout_cd,
        jsonb_agg (type_info_item order by seq) new_type_info
    from
        old_order_tmp_tb
    group by
        mainte_layout_cd
)
update
    mst_mainte_layout
set
    type_info = result_tb.new_type_info
from
    result_tb
where
    mst_mainte_layout.mainte_layout_cd = result_tb.mainte_layout_cd
;