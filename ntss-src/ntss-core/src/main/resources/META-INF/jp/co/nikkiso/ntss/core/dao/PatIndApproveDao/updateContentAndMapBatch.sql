WITH updates AS (
  SELECT facility_cd, ord_no, check_content, approve_content
  FROM (
     VALUES
       (null, 0, null, null),
       /*%for pia : updatedPatIndApproves */
       (
         /*pia.facility_cd*/null,
         /*pia.ord_no*/0,
         /*pia.check_content*/null,
         /*pia.approve_content*/null
       )
      /*%if pia_has_next */
      /*# "," */
      /*%end*/
      /*%end*/
   ) AS t(facility_cd, ord_no, check_content, approve_content)
)
UPDATE pat_ind_approve
SET check_content = u.check_content::jsonb,
    approve_content = u.approve_content::jsonb,
    content_for_map = null,
    up_date = CURRENT_TIMESTAMP
FROM updates AS u
WHERE
  pat_ind_approve.ord_no = u.ord_no
  AND
  pat_ind_approve.facility_cd = u.facility_cd
RETURNING pat_ind_approve.*
