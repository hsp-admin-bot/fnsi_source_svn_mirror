select
    max(temp.noo)
from
    (
        SELECT
            to_number((arr.item_object -> 'no') ::TEXT,'99999999') as noo
        FROM
            ord_main
            , jsonb_array_elements(rst_medi_info) with ordinality arr(item_object, position)
        WHERE
            pat_id = /*patId*/1
            and facility_cd = /*facilityCd*/'000000'
        union all
        SELECT
            to_number((arr.item_object -> 'no') ::TEXT,'99999999') as noo
        FROM
            ord_main
            , jsonb_array_elements(ind_medi_info) with ordinality arr(item_object, position)
        WHERE
            pat_id = /*patId*/1
            and facility_cd = /*facilityCd*/'000000'
    ) as temp
;
