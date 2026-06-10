SELECT
    s.subscription_no,
    s.facility_cd,
    f.facility_name,
    s.is_first,
    s.subscription_plan_name,
    s.subscription_fnc,
    s.subscription_adv,
    s.subscription_status,
    s.applicant,
    s.reg_date,
    s.receptionist,
    s.reception_date,
    s.completer,
    s.complete_date,
    s.canceller,
    s.cancel_date
FROM
    sal_subscription_manage as s,
    to_char(s.reg_date, 'YYYYMMDD') as registration_date,
    (SELECT facility_cd, facility_name
    FROM mst_facility
    WHERE
            1 = 1
        /*%if freeWord != null */
            AND ( UPPER(facility_name) like '%' || /*freeWord*/'' || '%' or UPPER(department_cd) like '%' || /*freeWord*/'' || '%')
        /*%end */
        /*%if departmentCd != null */
            AND department_cd = /*departmentCd*/NULL
         /*%end */
         /*%if prefecturesCd != null */
            AND  prefectures_cd = /*prefecturesCd*/NULL
        /*%end */
            ) as f
WHERE
    s.facility_cd  = f.facility_cd
    /*%if subscriptionStatusList != null && subscriptionStatusList.size() != 0*/
        AND s.subscription_status in /*subscriptionStatusList*/(NULL)
    /*%end */
        AND s.is_del = '0'
        AND s.is_disp = '1'
    /*%if startDate != null*/
        AND registration_date >= /*startDate*/NULL
    /*%end */
    /*%if endate != null*/
        AND registration_date <= /*endate*/NULL
    /*%end */
ORDER BY s.subscription_status ASC, s.subscription_no DESC
