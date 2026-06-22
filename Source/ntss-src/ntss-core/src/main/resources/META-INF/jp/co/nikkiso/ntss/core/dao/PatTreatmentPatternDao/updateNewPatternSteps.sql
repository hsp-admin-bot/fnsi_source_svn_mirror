-- add 9664 by kangjie 20240425 start
update pat_treatment_pattern
set
    ind_cond_info = CASE WHEN tmp.indCondInfo IS NULL THEN ind_cond_info ELSE jsonb_merge_recursive(ind_cond_info, CAST(tmp.indCondInfo AS jsonb)) END,
    up_date = CAST(tmp.upDate AS TIMESTAMP) FROM
(VALUES
    /*%for pat : mergeFluidList */
     (
            /*pat.indCondInfo*/null,
            /*pat.upDate*/null,
            /*pat.patId*/null,
            /*pat.ctlNo*/null
        )
    /*%if pat_has_next */
/*# "," */
    /*%end */
/*%end*/
) AS tmp ( indCondInfo, upDate, patId, ctlNo)
where
    pat_id = tmp.patId
  and
    ctl_no = tmp.ctlNo
;
-- add 9664 by kangjie 20240425 end
