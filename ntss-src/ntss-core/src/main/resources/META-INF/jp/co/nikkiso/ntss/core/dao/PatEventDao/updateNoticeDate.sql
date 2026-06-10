UPDATE pat_event
SET result_params = r.json_array
FROM (SELECT jsonb_agg(
               CASE
                 WHEN elems -> 'result_value' -> 'notice_start_date' IS NOT NULL
                   THEN
                   CASE
                     WHEN jsonb_extract_path_text(elems, 'result_value', 'notice_start_date') IS NOT NULL
                       AND jsonb_extract_path_text(elems, 'result_value', 'notice_end_date') IS NOT NULL
                       THEN jsonb_set(
                       jsonb_set(
                         elems,
                         '{result_value, notice_start_date}',
                         to_jsonb(
                           to_char(
                             (to_date(
                                jsonb_extract_path_text(elems, 'result_value', 'notice_start_date'),
                                'YYYY-MM-DD'
                                ) + interval '1 day' * /*dataNumber*/0
                               ),
                             'YYYY-MM-DD'
                             )
                           )
                         ),
                       '{result_value, notice_end_date}',
                       to_jsonb(
                         to_char(
                           (to_date(
                              jsonb_extract_path_text(elems, 'result_value', 'notice_end_date'),
                              'YYYY-MM-DD'
                              ) + interval '1 day' * /*dataNumber*/0
                             ),
                           'YYYY-MM-DD'
                           )
                         )
                       )
                     WHEN jsonb_extract_path_text(elems, 'result_value', 'notice_start_date') IS NOT NULL
                       THEN jsonb_set(
                       elems,
                       '{result_value, notice_start_date}',
                       to_jsonb(
                         to_char(
                           (to_date(
                              jsonb_extract_path_text(elems, 'result_value', 'notice_start_date'),
                              'YYYY-MM-DD'
                              ) + interval '1 day' * /*dataNumber*/0
                             ),
                           'YYYY-MM-DD'
                           )
                         )
                       )
                     WHEN jsonb_extract_path_text(elems, 'result_value', 'notice_end_date') IS NOT NULL
                       THEN jsonb_set(
                       elems,
                       '{result_value, notice_end_date}',
                       to_jsonb(
                         to_char(
                           (to_date(
                              jsonb_extract_path_text(elems, 'result_value', 'notice_end_date'),
                              'YYYY-MM-DD'
                              ) + interval '1 day' * /*dataNumber*/0
                             ),
                           'YYYY-MM-DD'
                           )
                         )
                       )
                     ELSE elems
                     END
                 ELSE elems
                 END
               ) AS json_array
      FROM pat_event,
           jsonb_array_elements(result_params) elems
      WHERE pat_event_cd = /*patEventCd*/null) r
WHERE pat_event_cd = /*patEventCd*/null
;
