WITH data_list AS (
    SELECT machine_type_cd, machine_serial, treat_date
    FROM (
             VALUES
             /*%for data : queryList */
             (/*data.machineTypeCd*/'', /*data.machineSerial*/'', /*data.treatDate*/'')
             /*%if data_has_next */
             /*# "," */
             /*%end */
             /*%end*/
         ) AS t(machine_type_cd, machine_serial, treat_date)

),
record_cd_order AS (
     SELECT machine_record_cd, order_no
     FROM (
            VALUES
              ('G100', 3),
              ('G101', 1),
              ('G102', 2)
          ) AS t(machine_record_cd, order_no)
)
SELECT machine_type_cd, machine_serial, treat_date, machine_record_cd
FROM (
         SELECT O.machine_type_cd, O.machine_serial, A.treat_date, O.machine_record_cd,
                ROW_NUMBER() OVER (PARTITION BY A.machine_type_cd,A.machine_serial,A.treat_date ORDER BY O.event_reg_date DESC, B.order_no ASC) AS row_num
         FROM mnt_motion_record O
                  JOIN data_list AS A
                       ON O.machine_type_cd = A.machine_type_cd
                           AND O.facility_cd = /*facilityCd*/''
                           AND O.machine_serial = A.machine_serial
                           AND O.event_reg_date >= A.treat_date::timestamp
               AND O.event_reg_date < A.treat_date::timestamp + INTERVAL '1 day'
               AND O.data_type = 1
               AND O.machine_record_cd in ('G100', 'G101', 'G102')
         LEFT JOIN record_cd_order AS B
         ON O.machine_record_cd = B.machine_record_cd
     ) AS subquery
WHERE row_num = 1
;