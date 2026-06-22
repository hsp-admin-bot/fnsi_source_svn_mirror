SELECT
facility_cd,
	pat_id,
	insurance_cd,
	personal_info_decrypt(insu_pub_no) as insu_pub_no,
	personal_info_decrypt(insu_pub_pat_no) as insu_pub_pat_no,
	personal_info_decrypt(insu_no) as insu_no,
	personal_info_decrypt(insu_pat_mark) as insu_pat_mark,
	personal_info_decrypt(insu_pat_no) as insu_pat_no,
	is_insured,
	is_dependent,
	insu_kbn,
	insu_dr_id,
	personal_info_decrypt(insu_dr_name) as insu_dr_name,
	personal_info_decrypt(insu_dr_sign) as insu_dr_sign,
	is_doubt,
	is_information,
	is_elderly,
	is_elderly7,
	is_child,
	remarks,
	is_anesthesia,
	personal_info_decrypt(remarks_anesthesia) as remarks_anesthesia,
	personal_info_decrypt(remarks_free) as remarks_free,
	is_disp,
	is_del,
	reg_date,
	up_date,
	insurance_name,
	insu_name_short,
	insu_info,
	insu_pub_info,
	insu_set_info,
	insu_self_info,
	memo1,
	memo2,
  personal_info_decrypt(
      coalesce(
        insu_pub_info::json->>'insu_pub_no',
        (
          SELECT elem->>'insu_pub1_no'
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? 'insu_pub1_no'
          LIMIT 1
        )
      )
    ) AS insu_pub1_no,
    personal_info_decrypt((
      SELECT elem->>'insu_pub2_no'
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? 'insu_pub2_no'
      LIMIT 1
    )) AS insu_pub2_no,
    personal_info_decrypt((
      SELECT elem->>'insu_pub3_no'
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? 'insu_pub3_no'
      LIMIT 1
    )) AS insu_pub3_no,
    personal_info_decrypt((
      SELECT elem->>'insu_pub4_no'
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? 'insu_pub4_no'
      LIMIT 1
    )) AS insu_pub4_no,
    personal_info_decrypt(
      coalesce(
        insu_pub_info::json->>'insu_pub_pat_no',
        (
          SELECT elem->>'insu_pub1_pat_no'
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? 'insu_pub1_pat_no'
          LIMIT 1
        )
      )
    ) AS insu_pub1_pat_no,
    personal_info_decrypt((
      SELECT elem->>'insu_pub2_pat_no'
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? 'insu_pub2_pat_no'
      LIMIT 1
    )) AS insu_pub2_pat_no,
    personal_info_decrypt((
      SELECT elem->>'insu_pub3_pat_no'
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? 'insu_pub3_pat_no'
      LIMIT 1
    )) AS insu_pub3_pat_no,
    personal_info_decrypt((
      SELECT elem->>'insu_pub4_pat_no'
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? 'insu_pub4_pat_no'
      LIMIT 1
    )) AS insu_pub4_pat_no,
    personal_info_decrypt(
      coalesce(
        insu_pub_info::json->>'insu_pub_name',
        (
          SELECT elem->>'insu_pub1_name'
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? 'insu_pub1_name'
          LIMIT 1
        )
      )
    ) AS insu_pub1_name,
    personal_info_decrypt((
      SELECT elem->>'insu_pub2_name'
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? 'insu_pub2_name'
      LIMIT 1
    )) AS insu_pub2_name,
    personal_info_decrypt((
      SELECT elem->>'insu_pub3_name'
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? 'insu_pub3_name'
      LIMIT 1
    )) AS insu_pub3_name,
    personal_info_decrypt((
      SELECT elem->>'insu_pub4_name'
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? 'insu_pub4_name'
      LIMIT 1
    )) AS insu_pub4_name,
    personal_info_decrypt(
      coalesce(
        insu_pub_info::json->>'passbook_no',
        (
          SELECT elem->>'insu_pub1_passbook_no'
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? 'insu_pub1_passbook_no'
          LIMIT 1
        )
      )
    ) AS insu_pub1_passbook_no,
    personal_info_decrypt((
      SELECT elem->>'insu_pub2_passbook_no'
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? 'insu_pub2_passbook_no'
      LIMIT 1
    )) AS insu_pub2_passbook_no,
    personal_info_decrypt((
      SELECT elem->>'insu_pub3_passbook_no'
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? 'insu_pub3_passbook_no'
      LIMIT 1
    )) AS insu_pub3_passbook_no,
    personal_info_decrypt((
      SELECT elem->>'insu_pub4_passbook_no'
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? 'insu_pub4_passbook_no'
      LIMIT 1
    )) AS insu_pub4_passbook_no,
    insurance_name AS insu_name,
    coalesce(
      (insu_info::json->>'insu_kbn')::text,
      (
        SELECT elem->>'insu_kbn'
        FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
        WHERE elem ?? 'insu_kbn'
        LIMIT 1
      )
    ) AS insu_kbn,
    personal_info_decrypt(
      coalesce(
        insu_info::json->>'insu_no',
        (
          SELECT elem->>'insu_no'
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? 'insu_no'
          LIMIT 1
        )
      )
    ) AS insu_no,
    personal_info_decrypt(
      coalesce(
        insu_info::json->>'insu_pat_mark',
        (
          SELECT elem->>'insu_pat_mark'
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? 'insu_pat_mark'
          LIMIT 1
        )
      )
    ) AS insu_pat_mark,
    personal_info_decrypt(
      coalesce(
        insu_info::json->>'insu_pat_no',
        (
          SELECT elem->>'insu_pat_no'
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? 'insu_pat_no'
          LIMIT 1
        )
      )
    ) AS insu_pat_no
FROM
  ord_personal_prescription
WHERE
  ord_prescription_no = /*ordPrescriptionNo*/0
