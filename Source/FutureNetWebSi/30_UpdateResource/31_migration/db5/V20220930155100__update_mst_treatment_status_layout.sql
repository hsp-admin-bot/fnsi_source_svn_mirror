-- #7865 名称修正　治療状況レイアウトマスタ>治療条件：血流量
WITH f AS ( 
    SELECT
        layout_no
        , ('{' || idx - 1 || ',title}') ::text [] AS path 
    FROM
        mst_treatment_status_layout 
        CROSS JOIN JSONB_ARRAY_ELEMENTS(dcs_view_items) WITH ORDINALITY arr(j, idx) 
    WHERE
        j ->> 'data_class' = '84'
) UPDATE mst_treatment_status_layout mtsl 
SET
    dcs_view_items = JSONB_SET(dcs_view_items, f.path, '"血流量（治療条件）"', false) 
FROM
    f 
WHERE
    mtsl.layout_no = f.layout_no; 

WITH f AS ( 
    SELECT
        layout_no
        , ('{' || idx - 1 || ',title}') ::text [] AS path 
    FROM
        mst_treatment_status_layout 
        CROSS JOIN JSONB_ARRAY_ELEMENTS(dcs_view_items) WITH ORDINALITY arr(j, idx) 
    WHERE
        j ->> 'data_class' = '102'
) UPDATE mst_treatment_status_layout mtsl 
SET
    dcs_view_items = JSONB_SET(dcs_view_items, f.path, '"IP速度（治療条件）"', false) 
FROM
    f 
WHERE
    mtsl.layout_no = f.layout_no;
