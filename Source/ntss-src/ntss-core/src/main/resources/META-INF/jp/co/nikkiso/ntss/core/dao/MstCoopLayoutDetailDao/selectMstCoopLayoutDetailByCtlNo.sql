SELECT
    /*%expand "a" */*
FROM
    mst_coop_layout_detail AS a
WHERE
    a.ctl_no = /*ctlNo*/'0'