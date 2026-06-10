--from_medicalInstitutionCdのプロパティが存在しない配列要素にfrom_medicalInstitutionCdを追加する
UPDATE pat_unique AS pat
SET in_out_visit_history_info = (
  SELECT
    COALESCE(
      jsonb_agg(
        CASE
          WHEN visit_hst_array.element ? 'from_medicalInstitutionCd' THEN
            visit_hst_array.element
          ELSE
            jsonb_set(
              visit_hst_array.element,
              '{from_medicalInstitutionCd}',
              'null'::jsonb,
              true
            )
        END
      ),
      '[]'::jsonb
    )
  FROM
    jsonb_array_elements(pat.in_out_visit_history_info) AS visit_hst_array(element)
)
WHERE
  is_del = '0' and jsonb_typeof(pat.in_out_visit_history_info) = 'array';

--to_medicalInstitutionCdのプロパティが存在しない配列要素にto_medicalInstitutionCdを追加する
UPDATE pat_unique AS pat
SET in_out_visit_history_info = (
  SELECT 
    COALESCE(
      jsonb_agg(
        CASE
          WHEN visit_hst_array.element ? 'to_medicalInstitutionCd' THEN
            visit_hst_array.element
          ELSE
            jsonb_set(
              visit_hst_array.element,
              '{to_medicalInstitutionCd}',
              'null'::jsonb,
              true
            )
        END
      ),
      '[]'::jsonb
    )
  FROM
    jsonb_array_elements(pat.in_out_visit_history_info) AS visit_hst_array(element)
)
WHERE
  is_del = '0' and jsonb_typeof(pat.in_out_visit_history_info) = 'array';

--from_facilityのプロパティが存在しない配列要素にfrom_facilityを追加する
UPDATE pat_unique AS pat
SET in_out_visit_history_info = (
  SELECT 
    COALESCE(
      jsonb_agg(
        CASE
          WHEN visit_hst_array.element ? 'from_facility' THEN
            visit_hst_array.element
          ELSE
            jsonb_set(
              visit_hst_array.element,
              '{from_facility}',
              'null'::jsonb,
              true
            )
        END
      ),
      '[]'::jsonb
    )
  FROM
    jsonb_array_elements(pat.in_out_visit_history_info) AS visit_hst_array(element)
)
WHERE
  is_del = '0' and jsonb_typeof(pat.in_out_visit_history_info) = 'array';

--to_facilityのプロパティが存在しない配列要素にto_facilityを追加する
UPDATE pat_unique AS pat
SET in_out_visit_history_info = (
  SELECT 
    COALESCE(
      jsonb_agg(
        CASE
          WHEN visit_hst_array.element ? 'to_facility' THEN
            visit_hst_array.element
          ELSE
            jsonb_set(
              visit_hst_array.element,
              '{to_facility}',
              'null'::jsonb,
              true
            )
        END
      ),
      '[]'::jsonb
    )
  FROM
    jsonb_array_elements(pat.in_out_visit_history_info) AS visit_hst_array(element)
)
WHERE
  is_del = '0' and jsonb_typeof(pat.in_out_visit_history_info) = 'array';

--from_courseのプロパティが存在しない配列要素にfrom_courseを追加する
UPDATE pat_unique AS pat
SET in_out_visit_history_info = (
  SELECT 
    COALESCE(
      jsonb_agg(
        CASE
          WHEN visit_hst_array.element ? 'from_course' THEN
            visit_hst_array.element
          ELSE
            jsonb_set(
              visit_hst_array.element,
              '{from_course}',
              'null'::jsonb,
              true
            )
        END
      ),
      '[]'::jsonb
    )
  FROM
    jsonb_array_elements(pat.in_out_visit_history_info) AS visit_hst_array(element)
)
WHERE
  is_del = '0' and jsonb_typeof(pat.in_out_visit_history_info) = 'array';

--to_courseのプロパティが存在しない配列要素にto_courseを追加する
UPDATE pat_unique AS pat
SET in_out_visit_history_info = (
  SELECT 
    COALESCE(
      jsonb_agg(
        CASE
          WHEN visit_hst_array.element ? 'to_course' THEN
            visit_hst_array.element
          ELSE
            jsonb_set(
              visit_hst_array.element,
              '{to_course}',
              'null'::jsonb,
              true
            )
        END
      ),
      '[]'::jsonb
    )
  FROM
    jsonb_array_elements(pat.in_out_visit_history_info) AS visit_hst_array(element)
)
WHERE
  is_del = '0' and jsonb_typeof(pat.in_out_visit_history_info) = 'array';

--course_is_freeのプロパティが存在しない配列要素にcourse_is_freeを追加する
UPDATE pat_unique AS pat
SET in_out_visit_history_info = (
  SELECT 
    COALESCE(
      jsonb_agg(
        CASE
          WHEN visit_hst_array.element ? 'course_is_free' THEN
            visit_hst_array.element
          ELSE
            jsonb_set(
              visit_hst_array.element,
              '{course_is_free}',
              '"0"'::jsonb,
              true
            )
        END
      ),
      '[]'::jsonb
    )
  FROM
    jsonb_array_elements(pat.in_out_visit_history_info) AS visit_hst_array(element)
)
WHERE
  is_del = '0' and jsonb_typeof(pat.in_out_visit_history_info) = 'array';

--from_doctorのプロパティが存在しない配列要素にfrom_doctorを追加する
UPDATE pat_unique AS pat
SET in_out_visit_history_info = (
  SELECT 
    COALESCE(
      jsonb_agg(
        CASE
          WHEN visit_hst_array.element ? 'from_doctor' THEN
            visit_hst_array.element
          ELSE
            jsonb_set(
              visit_hst_array.element,
              '{from_doctor}',
              'null'::jsonb,
              true
            )
        END
      ),
      '[]'::jsonb
    )
  FROM
    jsonb_array_elements(pat.in_out_visit_history_info) AS visit_hst_array(element)
)
WHERE
  is_del = '0' and jsonb_typeof(pat.in_out_visit_history_info) = 'array';

--to_doctorのプロパティが存在しない配列要素にto_doctorを追加する
UPDATE pat_unique AS pat
SET in_out_visit_history_info = (
  SELECT 
    COALESCE(
      jsonb_agg(
        CASE
          WHEN visit_hst_array.element ? 'to_doctor' THEN
            visit_hst_array.element
          ELSE
            jsonb_set(
              visit_hst_array.element,
              '{to_doctor}',
              'null'::jsonb,
              true
            )
        END
      ),
      '[]'::jsonb
    )
  FROM
    jsonb_array_elements(pat.in_out_visit_history_info) AS visit_hst_array(element)
)
WHERE
  is_del = '0' and jsonb_typeof(pat.in_out_visit_history_info) = 'array';

--doctor_is_freeのプロパティが存在しない配列要素にdoctor_is_freeを追加する
UPDATE pat_unique AS pat
SET in_out_visit_history_info = (
  SELECT 
    COALESCE(
      jsonb_agg(
        CASE
          WHEN visit_hst_array.element ? 'doctor_is_free' THEN
            visit_hst_array.element
          ELSE
            jsonb_set(
              visit_hst_array.element,
              '{doctor_is_free}',
              '"0"'::jsonb,
              true
            )
        END
      ),
      '[]'::jsonb
    )
  FROM
    jsonb_array_elements(pat.in_out_visit_history_info) AS visit_hst_array(element)
)
WHERE
  is_del = '0' and jsonb_typeof(pat.in_out_visit_history_info) = 'array';

--facility_is_freeのプロパティが存在しない配列要素にfacility_is_freeを追加する
UPDATE pat_unique AS pat
SET in_out_visit_history_info = (
  SELECT 
    COALESCE(
      jsonb_agg(
        CASE
          WHEN visit_hst_array.element ? 'facility_is_free' THEN
            visit_hst_array.element
          ELSE
            jsonb_set(
              visit_hst_array.element,
              '{facility_is_free}',
              '"0"'::jsonb,
              true
            )
        END
      ),
      '[]'::jsonb
    )
  FROM
    jsonb_array_elements(pat.in_out_visit_history_info) AS visit_hst_array(element)
)
WHERE
  is_del = '0' and jsonb_typeof(pat.in_out_visit_history_info) = 'array';

--from_facilityのプロパティの値がNULLの場合、from_medicalInstitutionCdのプロパティもNULLに更新する
UPDATE pat_unique AS pat
SET in_out_visit_history_info = (
  SELECT
    COALESCE(
      jsonb_agg(
        CASE
          WHEN visit_hst_array.element ->> 'from_facility' IS NULL THEN
            jsonb_set(
              visit_hst_array.element,
              '{from_medicalInstitutionCd}',
              'null'::jsonb,
              false
            )
          ELSE visit_hst_array.element
        END
      ),
      '[]'::jsonb
    )
  FROM
    jsonb_array_elements(pat.in_out_visit_history_info) AS visit_hst_array(element)
)
WHERE
  is_del = '0' and jsonb_typeof(pat.in_out_visit_history_info) = 'array';

--to_facilityのプロパティの値がNULLの場合、to_medicalInstitutionCdのプロパティもNULLに更新する
UPDATE pat_unique AS pat
SET in_out_visit_history_info = (
  SELECT
    COALESCE(
      jsonb_agg(
        CASE
          WHEN visit_hst_array.element ->> 'to_facility' IS NULL THEN
            jsonb_set(
              visit_hst_array.element,
              '{to_medicalInstitutionCd}',
              'null'::jsonb,
              false
            )
          ELSE visit_hst_array.element
        END
      ),
      '[]'::jsonb
    )
  FROM
    jsonb_array_elements(pat.in_out_visit_history_info) AS visit_hst_array(element)
)
WHERE
  is_del = '0' and jsonb_typeof(pat.in_out_visit_history_info) = 'array';

--from_courseとto_courseの両方のプロパティの値がNULLの場合、course_is_freeのプロパティを0に更新する
UPDATE pat_unique AS pat
SET in_out_visit_history_info = (
  SELECT
    COALESCE(
      jsonb_agg(
        CASE
          WHEN visit_hst_array.element ->> 'from_course' IS NULL AND visit_hst_array.element ->> 'to_course' IS NULL THEN
            jsonb_set(
              visit_hst_array.element,
              '{course_is_free}',
              '"0"'::jsonb,
              false
            )
          ELSE visit_hst_array.element
        END
      ),
      '[]'::jsonb
    )
  FROM
    jsonb_array_elements(pat.in_out_visit_history_info) AS visit_hst_array(element)
)
WHERE
  is_del = '0' and jsonb_typeof(pat.in_out_visit_history_info) = 'array';

--from_doctorとto_doctorの両方のプロパティの値がNULLの場合、doctor_is_freeのプロパティを0に更新する
UPDATE pat_unique AS pat
SET in_out_visit_history_info = (
  SELECT
    COALESCE(
      jsonb_agg(
        CASE
          WHEN visit_hst_array.element ->> 'from_doctor' IS NULL AND visit_hst_array.element ->> 'to_doctor' IS NULL THEN
            jsonb_set(
              visit_hst_array.element,
              '{doctor_is_free}',
              '"0"'::jsonb,
              false
            )
          ELSE visit_hst_array.element
        END
      ),
      '[]'::jsonb
    )
  FROM
    jsonb_array_elements(pat.in_out_visit_history_info) AS visit_hst_array(element)
)
WHERE
  is_del = '0' and jsonb_typeof(pat.in_out_visit_history_info) = 'array';

--facility_is_freeのプロパティの値が1の場合、from_medicalInstitutionCdのプロパティをNULLに更新する
UPDATE pat_unique AS pat
SET in_out_visit_history_info = (
  SELECT
    COALESCE(
      jsonb_agg(
        CASE
          WHEN visit_hst_array.element ->> 'facility_is_free'  = '1' THEN
            jsonb_set(
              visit_hst_array.element,
              '{from_medicalInstitutionCd}',
              'null'::jsonb,
              false
            )
          ELSE visit_hst_array.element
        END
      ),
      '[]'::jsonb
    )
  FROM
    jsonb_array_elements(pat.in_out_visit_history_info) AS visit_hst_array(element)
)
WHERE
  is_del = '0' and jsonb_typeof(pat.in_out_visit_history_info) = 'array';

--facility_is_freeのプロパティの値が1の場合、to_medicalInstitutionCdのプロパティをNULLに更新する
UPDATE pat_unique AS pat
SET in_out_visit_history_info = (
  SELECT
    COALESCE(
      jsonb_agg(
        CASE
          WHEN visit_hst_array.element ->> 'facility_is_free'  = '1' THEN
            jsonb_set(
              visit_hst_array.element,
              '{to_medicalInstitutionCd}',
              'null'::jsonb,
              false
            )
          ELSE visit_hst_array.element
        END
      ),
      '[]'::jsonb
    )
  FROM
    jsonb_array_elements(pat.in_out_visit_history_info) AS visit_hst_array(element)
)
WHERE
  is_del = '0' and jsonb_typeof(pat.in_out_visit_history_info) = 'array';
