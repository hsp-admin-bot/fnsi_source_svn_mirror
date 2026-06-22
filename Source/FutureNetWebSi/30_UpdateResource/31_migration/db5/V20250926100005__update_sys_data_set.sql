DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-504011, -504013);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-504011, '-- =====================================================
-- 単一行SQL: -504011 スタッフ情報（透析担当者・穿刺・回収）
-- XMLパース第一優先、フォールバック対応
-- パラメータ: ctlNo, ordNo, facilityCd
-- =====================================================

WITH 
-- XMLパース基本処理
xml_base AS (
  SELECT 
    journal.ctl_no,
    journal.ord_no,
    journal.dump,
    CASE 
      WHEN journal.dump IS NOT NULL 
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') != '''' 
           AND convert_from(journal.dump, ''SJIS'')::xml IS NOT NULL 
      THEN convert_from(journal.dump, ''SJIS'')::xml
      ELSE NULL 
    END as xml_data,
    CASE 
      WHEN journal.dump IS NOT NULL 
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') != '''' 
           AND convert_from(journal.dump, ''SJIS'')::xml IS NOT NULL 
      THEN true
      ELSE false 
    END as is_xml_valid
  FROM sys_coop_journal journal
  WHERE journal.ord_no = @ordNo 
    AND journal.facility_cd = @facilityCd
    AND journal.coop_cd = ''rst_dial''
  ORDER BY journal.reg_date DESC
  OFFSET 1 LIMIT 1
),

-- XMLスタッフ情報抽出
xml_staff AS (
  SELECT 
    xml_base.ctl_no,
    xml_base.is_xml_valid,
    (xpath(''//CHARGE_1_CODE/text()'', xml_data))[1]::text as xml_charge1_id,
    (xpath(''//CHARGE_1_NAME/text()'', xml_data))[1]::text as xml_charge1_name,
    (xpath(''//CHARGE_2_CODE/text()'', xml_data))[1]::text as xml_charge2_id,
    (xpath(''//CHARGE_2_NAME/text()'', xml_data))[1]::text as xml_charge2_name,
    (xpath(''//PUNCTURE_1_CODE/text()'', xml_data))[1]::text as xml_puncture1_id,
    (xpath(''//PUNCTURE_1_NAME/text()'', xml_data))[1]::text as xml_puncture1_name,
    (xpath(''//PUNCTURE_2_CODE/text()'', xml_data))[1]::text as xml_puncture2_id,
    (xpath(''//PUNCTURE_2_NAME/text()'', xml_data))[1]::text as xml_puncture2_name,
    (xpath(''//COLLECT_1_CODE/text()'', xml_data))[1]::text as xml_return1_id,
    (xpath(''//COLLECT_1_NAME/text()'', xml_data))[1]::text as xml_return1_name,
    (xpath(''//COLLECT_2_CODE/text()'', xml_data))[1]::text as xml_return2_id,
    (xpath(''//COLLECT_2_NAME/text()'', xml_data))[1]::text as xml_return2_name
  FROM xml_base
  WHERE xml_data IS NOT NULL
),

-- content パース処理（フォールバック用）
content_staff AS (
  SELECT
    @content::jsonb -> 0 ->> ''charge1_id'' AS charge1_id,
    @content::jsonb -> 0 ->> ''charge1_name'' AS charge1_name,
    @content::jsonb -> 0 ->> ''charge2_id'' AS charge2_id,
    @content::jsonb -> 0 ->> ''charge2_name'' AS charge2_name,
    @content::jsonb -> 0 ->> ''puncture1_id'' AS puncture1_id,
    @content::jsonb -> 0 ->> ''puncture1_name'' AS puncture1_name,
    @content::jsonb -> 0 ->> ''puncture2_id'' AS puncture2_id,
    @content::jsonb -> 0 ->> ''puncture2_name'' AS puncture2_name,
    @content::jsonb -> 0 ->> ''return1_id'' AS return1_id,
    @content::jsonb -> 0 ->> ''return1_name'' AS return1_name,
    @content::jsonb -> 0 ->> ''return2_id'' AS return2_id,
    @content::jsonb -> 0 ->> ''return2_name'' AS return2_name
)

-- 最終結果（content JSON形式対応）
SELECT
  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_staff.xml_charge1_id, '''')
    ELSE
      COALESCE(content_staff.charge1_id, '''')
  END as charge1_id,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_staff.xml_charge1_name, '''')
    ELSE
      COALESCE(content_staff.charge1_name, '''')
  END as charge1_name,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_staff.xml_charge2_id, '''')
    ELSE
      COALESCE(content_staff.charge2_id, '''')
  END as charge2_id,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_staff.xml_charge2_name, '''')
    ELSE
      COALESCE(content_staff.charge2_name, '''')
  END as charge2_name,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_staff.xml_puncture1_id, '''')
    ELSE
      COALESCE(content_staff.puncture1_id, '''')
  END as puncture1_id,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_staff.xml_puncture1_name, '''')
    ELSE
      COALESCE(content_staff.puncture1_name, '''')
  END as puncture1_name,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_staff.xml_puncture2_id, '''')
    ELSE
      COALESCE(content_staff.puncture2_id, '''')
  END as puncture2_id,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_staff.xml_puncture2_name, '''')
    ELSE
      COALESCE(content_staff.puncture2_name, '''')
  END as puncture2_name,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_staff.xml_return1_id, '''')
    ELSE
      COALESCE(content_staff.return1_id, '''')
  END as return1_id,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_staff.xml_return1_name, '''')
    ELSE
      COALESCE(content_staff.return1_name, '''')
  END as return1_name,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_staff.xml_return2_id, '''')
    ELSE
      COALESCE(content_staff.return2_id, '''')
  END as return2_id,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_staff.xml_return2_name, '''')
    ELSE
      COALESCE(content_staff.return2_name, '''')
  END as return2_name,
  xml_base.is_xml_valid

FROM xml_base
LEFT JOIN xml_staff ON xml_staff.ctl_no = xml_base.ctl_no
LEFT JOIN content_staff ON COALESCE(xml_base.is_xml_valid, false) = false;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI 実績送信', '2025-09-13 19:58:07.067', '2025-09-13 19:58:07.068', '[{"sql_cd": -504000, "field_name": ["charge1_id", "charge1_name", "charge2_id", "charge2_name", "puncture1_id", "puncture1_name", "puncture2_id", "puncture2_name", "return1_id", "return1_name", "return2_id", "return2_name"], "replace_var": "content"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-504013, '-- =====================================================
-- 単一行SQL: -504013 スタッフ情報ID置換処理
-- -504011の結果をcontentとして受け取り、id系をuser_idに置換
-- パラメータ: content, facilityCd
-- =====================================================

WITH
-- contentからスタッフ情報を取得
content_staff AS (
  SELECT
    @content::jsonb -> 0 ->> ''charge1_id'' AS charge1_id,
    @content::jsonb -> 0 ->> ''charge1_name'' AS charge1_name,
    @content::jsonb -> 0 ->> ''charge2_id'' AS charge2_id,
    @content::jsonb -> 0 ->> ''charge2_name'' AS charge2_name,
    @content::jsonb -> 0 ->> ''puncture1_id'' AS puncture1_id,
    @content::jsonb -> 0 ->> ''puncture1_name'' AS puncture1_name,
    @content::jsonb -> 0 ->> ''puncture2_id'' AS puncture2_id,
    @content::jsonb -> 0 ->> ''puncture2_name'' AS puncture2_name,
    @content::jsonb -> 0 ->> ''return1_id'' AS return1_id,
    @content::jsonb -> 0 ->> ''return1_name'' AS return1_name,
    @content::jsonb -> 0 ->> ''return2_id'' AS return2_id,
    @content::jsonb -> 0 ->> ''return2_name'' AS return2_name,
    (@content::jsonb -> 0 ->> ''is_xml_valid'')::boolean AS is_xml_valid
)

-- ID置換処理：is_xml_validがtrueの場合のみID置換を実行
SELECT
  -- charge1_id: is_xml_valid=trueならuser_idに置換、falseなら元のまま
  CASE
    WHEN COALESCE(content_staff.is_xml_valid, false) = true AND content_staff.charge1_id IS NOT NULL AND content_staff.charge1_id != '''' THEN
      COALESCE(
        (SELECT user_id::text FROM mst_user_authentication
         WHERE disp_user_id = content_staff.charge1_id
         AND facility_cd = @facilityCd),
        content_staff.charge1_id
      )
    ELSE
      COALESCE(content_staff.charge1_id, '''')
  END as charge1_id,

  COALESCE(content_staff.charge1_name, '''') as charge1_name,

  -- charge2_id: is_xml_valid=trueならuser_idに置換、falseなら元のまま
  CASE
    WHEN COALESCE(content_staff.is_xml_valid, false) = true AND content_staff.charge2_id IS NOT NULL AND content_staff.charge2_id != '''' THEN
      COALESCE(
        (SELECT user_id::text FROM mst_user_authentication
         WHERE disp_user_id = content_staff.charge2_id
         AND facility_cd = @facilityCd),
        content_staff.charge2_id
      )
    ELSE
      COALESCE(content_staff.charge2_id, '''')
  END as charge2_id,

  COALESCE(content_staff.charge2_name, '''') as charge2_name,

  -- puncture1_id: is_xml_valid=trueならuser_idに置換、falseなら元のまま
  CASE
    WHEN COALESCE(content_staff.is_xml_valid, false) = true AND content_staff.puncture1_id IS NOT NULL AND content_staff.puncture1_id != '''' THEN
      COALESCE(
        (SELECT user_id::text FROM mst_user_authentication
         WHERE disp_user_id = content_staff.puncture1_id
         AND facility_cd = @facilityCd),
        content_staff.puncture1_id
      )
    ELSE
      COALESCE(content_staff.puncture1_id, '''')
  END as puncture1_id,

  COALESCE(content_staff.puncture1_name, '''') as puncture1_name,

  -- puncture2_id: is_xml_valid=trueならuser_idに置換、falseなら元のまま
  CASE
    WHEN COALESCE(content_staff.is_xml_valid, false) = true AND content_staff.puncture2_id IS NOT NULL AND content_staff.puncture2_id != '''' THEN
      COALESCE(
        (SELECT user_id::text FROM mst_user_authentication
         WHERE disp_user_id = content_staff.puncture2_id
         AND facility_cd = @facilityCd),
        content_staff.puncture2_id
      )
    ELSE
      COALESCE(content_staff.puncture2_id, '''')
  END as puncture2_id,

  COALESCE(content_staff.puncture2_name, '''') as puncture2_name,

  -- return1_id: is_xml_valid=trueならuser_idに置換、falseなら元のまま
  CASE
    WHEN COALESCE(content_staff.is_xml_valid, false) = true AND content_staff.return1_id IS NOT NULL AND content_staff.return1_id != '''' THEN
      COALESCE(
        (SELECT user_id::text FROM mst_user_authentication
         WHERE disp_user_id = content_staff.return1_id
         AND facility_cd = @facilityCd),
        content_staff.return1_id
      )
    ELSE
      COALESCE(content_staff.return1_id, '''')
  END as return1_id,

  COALESCE(content_staff.return1_name, '''') as return1_name,

  -- return2_id: is_xml_valid=trueならuser_idに置換、falseなら元のまま
  CASE
    WHEN COALESCE(content_staff.is_xml_valid, false) = true AND content_staff.return2_id IS NOT NULL AND content_staff.return2_id != '''' THEN
      COALESCE(
        (SELECT user_id::text FROM mst_user_authentication
         WHERE disp_user_id = content_staff.return2_id
         AND facility_cd = @facilityCd),
        content_staff.return2_id
      )
    ELSE
      COALESCE(content_staff.return2_id, '''')
  END as return2_id,

  COALESCE(content_staff.return2_name, '''') as return2_name,

  content_staff.is_xml_valid

FROM content_staff;', 1, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI 実績送信', '2025-09-13 19:58:07.067', '2025-09-13 19:58:07.068', '[{"sql_cd": -504011, "field_name": ["charge1_id", "charge1_name", "charge2_id", "charge2_name", "puncture1_id", "puncture1_name", "puncture2_id", "puncture2_name", "return1_id", "return1_name", "return2_id", "return2_name", "is_xml_valid"], "replace_var": "content"}]'::jsonb);