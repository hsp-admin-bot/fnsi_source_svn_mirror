SELECT
    /*%expand "a" */*
FROM
    mst_coop_filename AS a
WHERE
    a.ctl_no = /*ctlNo*/'0'