UPDATE ord_main
SET
  ind_ind_comment_info = 
  CASE
    WHEN
      (
        SELECT
          position - 1 as position
      FROM
        ord_main, jsonb_array_elements(ind_ind_comment_info)
      WITH
        ordinality arr(elem, position)
      WHERE
          elem->>'no' = /*commentInfo*/'{}'::jsonb->>'no'
        AND
          ord_no = /*ordNo*/0
      )
     is null then
      ind_ind_comment_info
    ELSE
      ind_ind_comment_info -
        (
        SELECT
          position - 1 as position
        FROM
          ord_main, jsonb_array_elements(ind_ind_comment_info)
        WITH
          ordinality arr(elem, position)
        WHERE
          elem->>'no' = /*commentInfo*/'{}'::jsonb->>'no'
        AND
          ord_no = /*ordNo*/0
      )::int
       END,
/*%if "true".equals(isRstUpdate) */
       rst_ind_comment_info =
  CASE
    WHEN
      (
        SELECT
          rst_dialysis_state
        FROM
          ord_main
        WHERE
          ord_no = /*ordNo*/0
      )::int
      = 0 THEN
      rst_ind_comment_info
    WHEN
      rst_ind_comment_info IS null THEN
      jsonb_build_array(/*commentInfo*/'{}'::jsonb)
    WHEN
      (
        SELECT
          position - 1 as position
      FROM
        ord_main, jsonb_array_elements(rst_ind_comment_info)
      WITH
        ordinality arr(elem, position)
      WHERE
          elem->>'no' = /*commentInfo*/'{}'::jsonb->>'no'
        AND
          ord_no = /*ordNo*/0
      )
     is null then
      rst_ind_comment_info
    ELSE
      rst_ind_comment_info -
        (
        SELECT
          position - 1 as position
        FROM
          ord_main, jsonb_array_elements(rst_ind_comment_info)
        WITH
          ordinality arr(elem, position)
        WHERE
          elem->>'no' = /*commentInfo*/'{}'::jsonb->>'no'
        AND
          ord_no = /*ordNo*/0
      )::int
       END,
/*%end*/
  up_date = CURRENT_TIMESTAMP
WHERE
  ord_no = /*ordNo*/0;

  