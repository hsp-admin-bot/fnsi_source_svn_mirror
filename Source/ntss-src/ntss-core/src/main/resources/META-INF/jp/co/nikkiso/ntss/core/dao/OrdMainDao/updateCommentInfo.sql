UPDATE
    ord_main
SET
    ind_ind_comment_info = 
  case
      when
	      ind_ind_comment_info is null then
	      jsonb_build_array(/*commentInfo*/'{}'::jsonb)
      when
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
      jsonb_merge_recursive(ind_ind_comment_info, /*commentInfo*/'{}'::jsonb)
    ELSE
    jsonb_set(
          ind_ind_comment_info,
          string_to_array(
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
            )::text, ''
          ),
          jsonb_merge_recursive(
            (ind_ind_comment_info#>>string_to_array(
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
                )::text, ''
              )
            )::jsonb,
          /*commentInfo*/'{}'::jsonb)
        )
    END,
    rst_ind_comment_info = 
  case
      when
        (select
          rst_dialysis_state
	        from
	          ord_main
	         where
	         ord_no = /*ordNo*/0
	      )::int
	        = 0 then
        rst_ind_comment_info
      when
	      rst_ind_comment_info is null then
	      jsonb_build_array(/*commentInfo*/'{}'::jsonb)
      when
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
      jsonb_merge_recursive(rst_ind_comment_info, /*commentInfo*/'{}'::jsonb)
    ELSE
    jsonb_set(
          rst_ind_comment_info,
          string_to_array(
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
            )::text, ''
          ),
          jsonb_merge_recursive(
            (rst_ind_comment_info#>>string_to_array(
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
                )::text, ''
              )
            )::jsonb,
          /*commentInfo*/'{}'::jsonb)
        )
    END,
    up_date = CURRENT_TIMESTAMP
WHERE
  ord_no = /*ordNo*/0;