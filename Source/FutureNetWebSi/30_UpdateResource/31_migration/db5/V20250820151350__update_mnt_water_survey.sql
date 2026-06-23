WITH initial_string_map AS (
    SELECT
        survey_type_cd,
        facility_cd,
        jsonb_agg(elem ORDER BY ordinality) AS initial_array
    FROM mst_water_survey_type,
         jsonb_array_elements(initial_string::jsonb) WITH ORDINALITY AS elem(elem, ordinality)
    GROUP BY survey_type_cd
),
     expanded_survey AS (
         SELECT
             mws.facility_cd,
             mws.survey_record_no AS survey_id,
             idx,
             jsonb_set(
                     elem,
                     '{text}',
                     to_jsonb(
                             COALESCE(
                                     (
                                         SELECT val ->> 'text'
            FROM jsonb_array_elements(ist.initial_array) WITH ORDINALITY AS val(val, i)
            WHERE (elem ->> 'text') ~ '^\d+$' AND i = (elem ->> 'text')::int
          ),
          elem ->> 'text'
        )
                         )
                 ) AS updated_elem
         FROM mnt_water_survey mws
                  CROSS JOIN LATERAL jsonb_array_elements(mws.survey_data) WITH ORDINALITY AS elem(elem, idx)
    JOIN mst_water_survey_point wsp ON (elem ->> 'point_cd')::int = wsp.survey_point_cd	and wsp.facility_cd = mws.facility_cd
    JOIN initial_string_map ist ON wsp.survey_type_cd = ist.survey_type_cd and ist.facility_cd = mws.facility_cd
    ),
    reaggregated AS (
SELECT
    survey_id,
    jsonb_agg(updated_elem ORDER BY idx) AS new_survey_data
FROM expanded_survey
GROUP BY survey_id
    )
UPDATE mnt_water_survey mws
SET survey_data = r.new_survey_data
    FROM reaggregated r
WHERE mws.survey_record_no = r.survey_id
