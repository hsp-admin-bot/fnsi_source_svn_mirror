DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (218, 224, 256, 257);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (218, 'SELECT  
  personal_info_decrypt(
      coalesce(
        insu_pub_info::json->>''insu_pub_no'',
        (
          SELECT elem->>''insu_pub1_no''
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? ''insu_pub1_no''
          LIMIT 1
        )
      )
    ) AS insu_pub1_no,
    personal_info_decrypt((
      SELECT elem->>''insu_pub2_no''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub2_no''
      LIMIT 1
    )) AS insu_pub2_no,
    personal_info_decrypt((
      SELECT elem->>''insu_pub3_no''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub3_no''
      LIMIT 1
    )) AS insu_pub3_no,
    personal_info_decrypt((
      SELECT elem->>''insu_pub4_no''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub4_no''
      LIMIT 1
    )) AS insu_pub4_no,
    personal_info_decrypt(
      coalesce(
        insu_pub_info::json->>''insu_pub_pat_no'',
        (
          SELECT elem->>''insu_pub1_pat_no''
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? ''insu_pub1_pat_no''
          LIMIT 1
        )
      )
    ) AS insu_pub1_pat_no,
    personal_info_decrypt((
      SELECT elem->>''insu_pub2_pat_no''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub2_pat_no''
      LIMIT 1
    )) AS insu_pub2_pat_no,
    personal_info_decrypt((
      SELECT elem->>''insu_pub3_pat_no''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub3_pat_no''
      LIMIT 1
    )) AS insu_pub3_pat_no,
    personal_info_decrypt((
      SELECT elem->>''insu_pub4_pat_no''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub4_pat_no''
      LIMIT 1
    )) AS insu_pub4_pat_no,
    personal_info_decrypt(
      coalesce(
        insu_pub_info::json->>''insu_pub_name'',
        (
          SELECT elem->>''insu_pub1_name''
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? ''insu_pub1_name''
          LIMIT 1
        )
      )
    ) AS insu_pub1_name,
    personal_info_decrypt((
      SELECT elem->>''insu_pub2_name''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub2_name''
      LIMIT 1
    )) AS insu_pub2_name,
    personal_info_decrypt((
      SELECT elem->>''insu_pub3_name''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub3_name''
      LIMIT 1
    )) AS insu_pub3_name,
    personal_info_decrypt((
      SELECT elem->>''insu_pub4_name''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub4_name''
      LIMIT 1
    )) AS insu_pub4_name,
    personal_info_decrypt(
      coalesce(
        insu_pub_info::json->>''passbook_no'',
        (
          SELECT elem->>''insu_pub1_passbook_no''
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? ''insu_pub1_passbook_no''
          LIMIT 1
        )
      )
    ) AS insu_pub1_passbook_no,
    personal_info_decrypt((
      SELECT elem->>''insu_pub2_passbook_no''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub2_passbook_no''
      LIMIT 1
    )) AS insu_pub2_passbook_no,
    personal_info_decrypt((
      SELECT elem->>''insu_pub3_passbook_no''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub3_passbook_no''
      LIMIT 1
    )) AS insu_pub3_passbook_no,
    personal_info_decrypt((
      SELECT elem->>''insu_pub4_passbook_no''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub4_passbook_no''
      LIMIT 1
    )) AS insu_pub4_passbook_no,
    insurance_name AS insu_name,
    coalesce(
      (insu_info::json->>''insu_kbn'')::text,
      (
        SELECT elem->>''insu_kbn''
        FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
        WHERE elem ?? ''insu_kbn''
        LIMIT 1
      )
    ) AS insu_kbn,
    personal_info_decrypt(
      coalesce(
        insu_info::json->>''insu_no'',
        (
          SELECT elem->>''insu_no''
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? ''insu_no''
          LIMIT 1
        )
      )
    ) AS insu_no,
    personal_info_decrypt(
      coalesce(
        insu_info::json->>''insu_pat_mark'',
        (
          SELECT elem->>''insu_pat_mark''
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? ''insu_pat_mark''
          LIMIT 1
        )
      )
    ) AS insu_pat_mark,
    personal_info_decrypt(
      coalesce(
        insu_info::json->>''insu_pat_no'',
        (
          SELECT elem->>''insu_pat_no''
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? ''insu_pat_no''
          LIMIT 1
        )
      )
    ) AS insu_pat_no,
  memo1,
  memo2,
  ord_prescription_no  
FROM
  ord_personal_prescription
WHERE  
  is_disp = ''1''
  AND is_del = ''0''
  AND facility_cd = @facilityCd
  AND ord_prescription_no = @ordPrescriptionNo', 3, '[{"preview": "xxxxxxx", "can_calc": "0", "data_code": "insu_pub1_no", "data_name": "公費負担者番号1", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub1_no", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxxxx", "can_calc": "0", "data_code": "insu_pub2_no", "data_name": "公費負担者番号2", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub2_no", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxxxx", "can_calc": "0", "data_code": "insu_pub3_no", "data_name": "公費負担者番号3", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub3_no", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxxxx", "can_calc": "0", "data_code": "insu_pub4_no", "data_name": "公費負担者番号4", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub4_no", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub1_pat_no", "data_name": "公費負担受給者番号1", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub1_pat_no", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub2_pat_no", "data_name": "公費負担受給者番号2", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub2_pat_no", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub3_pat_no", "data_name": "公費負担受給者番号3", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub3_pat_no", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub4_pat_no", "data_name": "公費負担受給者番号4", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub4_pat_no", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub1_name", "data_name": "公費負担者名1", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub1_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub2_name", "data_name": "公費負担者名2", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub2_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub3_name", "data_name": "公費負担者名3", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub3_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub4_name", "data_name": "公費負担者名4", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub4_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub1_passbook_no", "data_name": "障害者手帳番号1", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub1_passbook_no", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub2_passbook_no", "data_name": "障害者手帳番号2", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub2_passbook_no", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub3_passbook_no", "data_name": "障害者手帳番号3", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub3_passbook_no", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub4_passbook_no", "data_name": "障害者手帳番号4", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub4_passbook_no", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxx保険", "can_calc": "0", "data_code": "insu_name", "data_name": "保険名称", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_name", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "被保険者", "can_calc": "0", "data_code": "insu_kbn", "data_name": "扶養区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "被保険者", "item": "被保険者"}, {"code": "1", "disp": "被扶養者", "item": "被扶養者"}], "data_class": "処方情報", "field_name": "insu_kbn", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "insu_no", "data_name": "保険者番号", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_no", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12345678", "can_calc": "0", "data_code": "insu_pat_mark", "data_name": "被保険者証記号", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pat_mark", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "insu_pat_no", "data_name": "被保険者証番号", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pat_no", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "メモ１", "can_calc": "0", "data_code": "memo1", "data_name": "保険メモ1", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "memo1", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "メモ２", "can_calc": "0", "data_code": "memo2", "data_name": "保険メモ2", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "memo2", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 9]}', '処方：@facilityCd @ordPrescriptionNo  使用', '2024-05-02 01:43:29.644', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (224, 'SELECT  
 personal_info_decrypt(
      coalesce(
        insu_pub_info::json->>''insu_pub_no'',
        (
          SELECT elem->>''insu_pub1_no''
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? ''insu_pub1_no''
          LIMIT 1
        )
      )
    ) AS insu_pub1_no,
    personal_info_decrypt((
      SELECT elem->>''insu_pub2_no''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub2_no''
      LIMIT 1
    )) AS insu_pub2_no,
    personal_info_decrypt((
      SELECT elem->>''insu_pub3_no''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub3_no''
      LIMIT 1
    )) AS insu_pub3_no,
    personal_info_decrypt((
      SELECT elem->>''insu_pub4_no''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub4_no''
      LIMIT 1
    )) AS insu_pub4_no,
    personal_info_decrypt(
      coalesce(
        insu_pub_info::json->>''insu_pub_pat_no'',
        (
          SELECT elem->>''insu_pub1_pat_no''
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? ''insu_pub1_pat_no''
          LIMIT 1
        )
      )
    ) AS insu_pub1_pat_no,
    personal_info_decrypt((
      SELECT elem->>''insu_pub2_pat_no''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub2_pat_no''
      LIMIT 1
    )) AS insu_pub2_pat_no,
    personal_info_decrypt((
      SELECT elem->>''insu_pub3_pat_no''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub3_pat_no''
      LIMIT 1
    )) AS insu_pub3_pat_no,
    personal_info_decrypt((
      SELECT elem->>''insu_pub4_pat_no''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub4_pat_no''
      LIMIT 1
    )) AS insu_pub4_pat_no,
    personal_info_decrypt(
      coalesce(
        insu_pub_info::json->>''insu_pub_name'',
        (
          SELECT elem->>''insu_pub1_name''
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? ''insu_pub1_name''
          LIMIT 1
        )
      )
    ) AS insu_pub1_name,
    personal_info_decrypt((
      SELECT elem->>''insu_pub2_name''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub2_name''
      LIMIT 1
    )) AS insu_pub2_name,
    personal_info_decrypt((
      SELECT elem->>''insu_pub3_name''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub3_name''
      LIMIT 1
    )) AS insu_pub3_name,
    personal_info_decrypt((
      SELECT elem->>''insu_pub4_name''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub4_name''
      LIMIT 1
    )) AS insu_pub4_name,
    personal_info_decrypt(
      coalesce(
        insu_pub_info::json->>''passbook_no'',
        (
          SELECT elem->>''insu_pub1_passbook_no''
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? ''insu_pub1_passbook_no''
          LIMIT 1
        )
      )
    ) AS insu_pub1_passbook_no,
    personal_info_decrypt((
      SELECT elem->>''insu_pub2_passbook_no''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub2_passbook_no''
      LIMIT 1
    )) AS insu_pub2_passbook_no,
    personal_info_decrypt((
      SELECT elem->>''insu_pub3_passbook_no''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub3_passbook_no''
      LIMIT 1
    )) AS insu_pub3_passbook_no,
    personal_info_decrypt((
      SELECT elem->>''insu_pub4_passbook_no''
      FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
      WHERE elem ?? ''insu_pub4_passbook_no''
      LIMIT 1
    )) AS insu_pub4_passbook_no,
    insurance_name AS insu_name,
    coalesce(
      (insu_info::json->>''insu_kbn'')::text,
      (
        SELECT elem->>''insu_kbn''
        FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
        WHERE elem ?? ''insu_kbn''
        LIMIT 1
      )
    ) AS insu_kbn,
    personal_info_decrypt(
      coalesce(
        insu_info::json->>''insu_no'',
        (
          SELECT elem->>''insu_no''
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? ''insu_no''
          LIMIT 1
        )
      )
    ) AS insu_no,
    personal_info_decrypt(
      coalesce(
        insu_info::json->>''insu_pat_mark'',
        (
          SELECT elem->>''insu_pat_mark''
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? ''insu_pat_mark''
          LIMIT 1
        )
      )
    ) AS insu_pat_mark,
    personal_info_decrypt(
      coalesce(
        insu_info::json->>''insu_pat_no'',
        (
          SELECT elem->>''insu_pat_no''
          FROM jsonb_array_elements(insu_set_info::jsonb) AS elem
          WHERE elem ?? ''insu_pat_no''
          LIMIT 1
        )
      )
    ) AS insu_pat_no,
  memo1,
  memo2,
  ord_prescription_no 
FROM
  ord_personal_prescription
WHERE  
  is_disp = ''1'' 
  AND is_del = ''0''
  AND facility_cd = @facilityCd
  AND ord_prescription_no = @ordPreNo', 3, '[{"preview": "xxxxxxx", "can_calc": "0", "data_code": "insu_pub1_no", "data_name": "公費負担者番号1", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub1_no", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxxxx", "can_calc": "0", "data_code": "insu_pub2_no", "data_name": "公費負担者番号2", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub2_no", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxxxx", "can_calc": "0", "data_code": "insu_pub3_no", "data_name": "公費負担者番号3", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub3_no", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxxxx", "can_calc": "0", "data_code": "insu_pub4_no", "data_name": "公費負担者番号4", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub4_no", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub1_pat_no", "data_name": "公費負担受給者番号1", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub1_pat_no", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub2_pat_no", "data_name": "公費負担受給者番号2", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub2_pat_no", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub3_pat_no", "data_name": "公費負担受給者番号3", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub3_pat_no", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub4_pat_no", "data_name": "公費負担受給者番号4", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub4_pat_no", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub1_name", "data_name": "公費負担者名1", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub1_name", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub2_name", "data_name": "公費負担者名2", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub2_name", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub3_name", "data_name": "公費負担者名3", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub3_name", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub4_name", "data_name": "公費負担者名4", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub4_name", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub1_passbook_no", "data_name": "障害者手帳番号1", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub1_passbook_no", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub2_passbook_no", "data_name": "障害者手帳番号2", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub2_passbook_no", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub3_passbook_no", "data_name": "障害者手帳番号3", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub3_passbook_no", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxxxx", "can_calc": "0", "data_code": "insu_pub4_passbook_no", "data_name": "障害者手帳番号4", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub4_passbook_no", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "xxx保険", "can_calc": "0", "data_code": "insu_name", "data_name": "保険名称", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_name", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "被保険者", "can_calc": "0", "data_code": "insu_kbn", "data_name": "扶養区分", "data_type": "string", "conv_table": [{"code": "0", "disp": "被保険者", "item": "被保険者"}, {"code": "1", "disp": "被扶養者", "item": "被扶養者"}], "data_class": "処方情報", "field_name": "insu_kbn", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "123456789", "can_calc": "0", "data_code": "insu_no", "data_name": "保険者番号", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_no", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "12345678", "can_calc": "0", "data_code": "insu_pat_mark", "data_name": "被保険者証記号", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pat_mark", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1234567", "can_calc": "0", "data_code": "insu_pat_no", "data_name": "被保険者証番号", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pat_no", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "メモ１", "can_calc": "0", "data_code": "memo1", "data_name": "保険メモ1", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "memo1", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "メモ２", "can_calc": "0", "data_code": "memo2", "data_name": "保険メモ2", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "memo2", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 9]}', '処方(最新)：@facilityCd @ordPreNo  使用', '2024-05-02 01:43:29.655', CURRENT_TIMESTAMP, '[{"sql_cd": 223, "field_name": "ord_prescription_no", "replace_var": "@ordPreNo"}]');
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (256, 'WITH decrypted AS (
  SELECT
    ord_prescription_no,
    jsonb_build_object(
      ''insu_pub1_no'', personal_info_decrypt(coalesce(insu_pub_info::json->>''insu_pub_no'',
        (SELECT elem->>''insu_pub1_no'' FROM jsonb_array_elements(insu_set_info::jsonb) AS elem WHERE elem ?? ''insu_pub1_no'' LIMIT 1))),
      ''insu_pub2_no'', personal_info_decrypt(
        (SELECT elem->>''insu_pub2_no'' FROM jsonb_array_elements(insu_set_info::jsonb) AS elem WHERE elem ?? ''insu_pub2_no'' LIMIT 1)),
      ''insu_pub3_no'', personal_info_decrypt(
        (SELECT elem->>''insu_pub3_no'' FROM jsonb_array_elements(insu_set_info::jsonb) AS elem WHERE elem ?? ''insu_pub3_no'' LIMIT 1)),
      ''insu_pub4_no'', personal_info_decrypt(
        (SELECT elem->>''insu_pub4_no'' FROM jsonb_array_elements(insu_set_info::jsonb) AS elem WHERE elem ?? ''insu_pub4_no'' LIMIT 1)),
      ''insu_no'', personal_info_decrypt(coalesce(insu_info::json->>''insu_no'',
        (SELECT elem->>''insu_no'' FROM jsonb_array_elements(insu_set_info::jsonb) AS elem WHERE elem ?? ''insu_no'' LIMIT 1)))
    ) AS field_json
  FROM
    ord_personal_prescription
  WHERE
    ord_prescription_no = @ordPrescriptionNo
    AND facility_cd = @facilityCd
    AND is_disp = ''1''
    AND is_del = ''0''
),
split_digits AS (
  SELECT
    ord_prescription_no,
    key AS field_name,
    digit,
    ordinality AS digit_pos
  FROM 
    decrypted,
    jsonb_each_text(field_json) AS f(key, val),
    LATERAL regexp_split_to_table(val, '''') WITH ORDINALITY AS t(digit, ordinality)
),
pivoted AS (
  SELECT
    ord_prescription_no,
    digit_pos,
    MAX(CASE WHEN field_name = ''insu_pub1_no'' THEN digit END) AS insu_pub1_no_digit,
    MAX(CASE WHEN field_name = ''insu_pub2_no'' THEN digit END) AS insu_pub2_no_digit,
    MAX(CASE WHEN field_name = ''insu_pub3_no'' THEN digit END) AS insu_pub3_no_digit,
    MAX(CASE WHEN field_name = ''insu_pub4_no'' THEN digit END) AS insu_pub4_no_digit,
    MAX(CASE WHEN field_name = ''insu_no''      THEN digit END) AS insu_no_digit
  FROM
    split_digits
  GROUP BY
    ord_prescription_no, digit_pos
)
SELECT * FROM pivoted ORDER BY ord_prescription_no, digit_pos;
', 3, '[{"preview": "x", "can_calc": "0", "data_code": "insu_pub1_no_digit", "data_name": "公費負担者番号1(一桁ずつ)", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub1_no_digit", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "x", "can_calc": "0", "data_code": "insu_pub2_no_digit", "data_name": "公費負担者番号2(一桁ずつ)", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub2_no_digit", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "x", "can_calc": "0", "data_code": "insu_pub3_no_digit", "data_name": "公費負担者番号3(一桁ずつ)", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub3_no_digit", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "x", "can_calc": "0", "data_code": "insu_pub4_no_digit", "data_name": "公費負担者番号4(一桁ずつ)", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub4_no_digit", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}, {"preview": "x", "can_calc": "0", "data_code": "insu_no_digit", "data_name": "保険者番号(一桁ずつ)", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_no_digit", "disp_format": "", "data_category": "処方", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 9]}', '処方：@facilityCd @ordPrescriptionNo  使用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (257, 'WITH decrypted AS (
  SELECT
    ord_prescription_no,
    jsonb_build_object(
      ''insu_pub1_no'', personal_info_decrypt(coalesce(insu_pub_info::json->>''insu_pub_no'',
        (SELECT elem->>''insu_pub1_no'' FROM jsonb_array_elements(insu_set_info::jsonb) AS elem WHERE elem ?? ''insu_pub1_no'' LIMIT 1))),
      ''insu_pub2_no'', personal_info_decrypt(
        (SELECT elem->>''insu_pub2_no'' FROM jsonb_array_elements(insu_set_info::jsonb) AS elem WHERE elem ?? ''insu_pub2_no'' LIMIT 1)),
      ''insu_pub3_no'', personal_info_decrypt(
        (SELECT elem->>''insu_pub3_no'' FROM jsonb_array_elements(insu_set_info::jsonb) AS elem WHERE elem ?? ''insu_pub3_no'' LIMIT 1)),
      ''insu_pub4_no'', personal_info_decrypt(
        (SELECT elem->>''insu_pub4_no'' FROM jsonb_array_elements(insu_set_info::jsonb) AS elem WHERE elem ?? ''insu_pub4_no'' LIMIT 1)),
      ''insu_no'', personal_info_decrypt(coalesce(insu_info::json->>''insu_no'',
        (SELECT elem->>''insu_no'' FROM jsonb_array_elements(insu_set_info::jsonb) AS elem WHERE elem ?? ''insu_no'' LIMIT 1)))
    ) AS field_json
  FROM
    ord_personal_prescription
  WHERE
    ord_prescription_no = @ordPreNo
    AND facility_cd = @facilityCd
    AND is_disp = ''1''
    AND is_del = ''0''
),
split_digits AS (
  SELECT
    ord_prescription_no,
    key AS field_name,
    digit,
    ordinality AS digit_pos
  FROM 
    decrypted,
    jsonb_each_text(field_json) AS f(key, val),
    LATERAL regexp_split_to_table(val, '''') WITH ORDINALITY AS t(digit, ordinality)
),
pivoted AS (
  SELECT
    ord_prescription_no,
    digit_pos,
    MAX(CASE WHEN field_name = ''insu_pub1_no'' THEN digit END) AS insu_pub1_no_digit,
    MAX(CASE WHEN field_name = ''insu_pub2_no'' THEN digit END) AS insu_pub2_no_digit,
    MAX(CASE WHEN field_name = ''insu_pub3_no'' THEN digit END) AS insu_pub3_no_digit,
    MAX(CASE WHEN field_name = ''insu_pub4_no'' THEN digit END) AS insu_pub4_no_digit,
    MAX(CASE WHEN field_name = ''insu_no''      THEN digit END) AS insu_no_digit
  FROM
    split_digits
  GROUP BY
    ord_prescription_no, digit_pos
)
SELECT * FROM pivoted ORDER BY ord_prescription_no, digit_pos;
', 3, '[{"preview": "x", "can_calc": "0", "data_code": "insu_pub1_no_digit", "data_name": "公費負担者番号1(一桁ずつ)", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub1_no_digit", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "x", "can_calc": "0", "data_code": "insu_pub2_no_digit", "data_name": "公費負担者番号2(一桁ずつ)", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub2_no_digit", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "x", "can_calc": "0", "data_code": "insu_pub3_no_digit", "data_name": "公費負担者番号3(一桁ずつ)", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub3_no_digit", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "x", "can_calc": "0", "data_code": "insu_pub4_no_digit", "data_name": "公費負担者番号4(一桁ずつ)", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_pub4_no_digit", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}, {"preview": "x", "can_calc": "0", "data_code": "insu_no_digit", "data_name": "保険者番号(一桁ずつ)", "data_type": "string", "conv_table": [], "data_class": "処方情報", "field_name": "insu_no_digit", "disp_format": "", "data_category": "処方(最新)", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 9]}', '処方(最新)：@facilityCd @ordPreNo 使用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 223, "field_name": "ord_prescription_no", "replace_var": "@ordPreNo"}]');
