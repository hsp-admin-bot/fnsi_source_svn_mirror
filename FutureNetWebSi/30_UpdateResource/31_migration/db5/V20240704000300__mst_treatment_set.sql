UPDATE mst_treatment_set
SET ind_ind_comment_info = (
  SELECT
    case when jsonb_agg ( sub.elems )  is not null
           then jsonb_agg ( sub.elems )
         else NULL
      end
  FROM
    (
      SELECT
        elem AS elems
      FROM
        jsonb_array_elements ( ind_ind_comment_info ) AS elem
      WHERE CAST(elem ->> 'no' as int8) <'100'
    ) AS sub
)
WHERE
  EXISTS ( SELECT 1 FROM jsonb_array_elements ( ind_ind_comment_info ) AS item WHERE CAST(item ->> 'no' as int8) >'99' )