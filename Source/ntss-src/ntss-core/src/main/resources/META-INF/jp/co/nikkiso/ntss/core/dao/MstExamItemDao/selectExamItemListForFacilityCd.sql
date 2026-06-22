SELECT
item.exam_item_cd as item_cd
FROM ntss.mst_exam_item item
WHERE
item.facility_cd = /* facilityCd */null
AND item.is_disp = '0'
