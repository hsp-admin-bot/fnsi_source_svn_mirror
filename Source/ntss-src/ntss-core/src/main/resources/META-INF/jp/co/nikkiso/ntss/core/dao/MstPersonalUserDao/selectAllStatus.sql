WITH MAIN AS (
    SELECT
        u.user_id AS "userId",
        personal_info_decrypt(u.job_cd) AS "jobCd",
        personal_info_decrypt(u.user_last_name) AS "userLastName",
        personal_info_decrypt(u.user_first_name) AS "userFirstName",
        u.is_disp AS "isDisp",
        u.is_del AS "isDel",
        CASE
            WHEN u.is_disp = '0' OR u.is_del = '1' THEN '【削除済み】'
            ELSE ''
        END AS "deleted"
    FROM
        mst_personal_user u
    WHERE
        u.facility_cd = /* params.get("facilityCd") */'0'
        AND u.is_del = '0'
        AND u.is_disp = '1'
        AND u.user_type != '2'
),
INIT AS (
    SELECT
        u.user_id AS "userId",
        personal_info_decrypt(u.job_cd) AS "jobCd",
        personal_info_decrypt(u.user_last_name) AS "userLastName",
        personal_info_decrypt(u.user_first_name) AS "userFirstName",
        u.is_disp AS "isDisp",
        u.is_del AS "isDel",
        CASE
            WHEN u.is_disp = '0' OR u.is_del = '1' THEN '【削除済み】'
            ELSE ''
        END AS "deleted"
    FROM
        mst_personal_user u
    WHERE
        /*%if params.get("initUserId") != null && !params.get("initUserId").trim().isEmpty() */
        u.user_id = (/* params.get("initUserId") */0)::bigint
        AND u.facility_cd = /* params.get("facilityCd") */'0'
        /*%else */
        1 = 0
        /*%end */
)
SELECT
    M.*
FROM
    MAIN M
UNION ALL
SELECT
    I.*
FROM
    INIT I
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            MAIN M2
        WHERE
            M2."userId" = I."userId"
    )
ORDER BY
    "userId";
