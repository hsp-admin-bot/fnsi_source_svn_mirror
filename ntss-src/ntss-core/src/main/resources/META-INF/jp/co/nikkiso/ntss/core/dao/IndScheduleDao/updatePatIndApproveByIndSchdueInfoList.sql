WITH updates AS (
    SELECT ord_no, treat_date, old_treat_date
    FROM
        (
            VALUES
            (0,null,null)
            /*%for isl : indScheduleInfoList */
              ,(/*isl.ordNo*/0,
                /*isl.treatDate*/null,
                /*isl.oldTreatDate*/null
              )
            /*%end*/
        ) AS t(ord_no, treat_date, old_treat_date)
)
UPDATE pat_ind_approve
SET is_content_changed = CASE
        WHEN is_content_changed IS NOT NULL AND is_content_changed != '{}' THEN '1'
        ELSE is_content_changed
    END,
    is_content_appd_changed = CASE
        WHEN is_content_appd_changed IS NOT NULL AND is_content_appd_changed != '{}' THEN '1'
        ELSE is_content_appd_changed
    END,
    is_content_changed_for_map = '1',
    up_date = transaction_timestamp()
FROM updates AS u2
WHERE pat_ind_approve.facility_cd = /*facilityCd*/null and pat_ind_approve.ord_no IN (
    CASE
        WHEN u2.treat_date = u2.old_treat_date THEN
            (SELECT ord.ord_no FROM ord_main as ord
            JOIN mst_facility_setting as setting ON ord.facility_cd = setting.facility_cd
            WHERE ord.ord_no = u2.ord_no AND setting.facility_setting_no = '1022' AND value = '1')
        ELSE
            (SELECT ord2.ord_no FROM ord_main as ord2 WHERE ord2.ord_no = u2.ord_no)
    END
)
RETURNING pat_ind_approve.*
;
