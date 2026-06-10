SELECT
    /*%expand "A" */*
FROM
    mst_facility_calendar_layout A
WHERE 
    facility_calendar_layout_cd = /*facCalLayoutCd*/0