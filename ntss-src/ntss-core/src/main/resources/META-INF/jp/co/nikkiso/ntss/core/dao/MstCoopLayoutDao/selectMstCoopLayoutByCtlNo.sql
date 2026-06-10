SELECT
    /*%expand "a" */*
FROM
    mst_coop_layout AS a
WHERE
    a.ctl_no = /*ctlNo*/'0'