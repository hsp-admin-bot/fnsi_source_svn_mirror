DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-504004, -504006);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-504004, '-- =====================================================
-- 複数行SQL: -504004 処置・検査情報（CTE形式）
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
    convert_from(journal.dump, ''SJIS'') as xml_text,
    CASE
      WHEN journal.dump IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') != ''''
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

-- XML処置検査情報抽出
xml_dispose AS (
  SELECT
    xml_base.ctl_no,
    xml_base.is_xml_valid,
    dispose_info.dispose_no,
    (xpath(''DISPOSE_INFO/@DISPOSE_CTL_NO'', dispose_info.dispose_node))[1]::text as xml_cost_no,
    (xpath(''DISPOSE_INFO/TENCD/text()'', dispose_info.dispose_node))[1]::text as xml_tencd,
    (xpath(''DISPOSE_INFO/TKJNAM/text()'', dispose_info.dispose_node))[1]::text as xml_tkjnam,
    (xpath(''DISPOSE_INFO/AMOUNT/text()'', dispose_info.dispose_node))[1]::text as xml_amount,
    (xpath(''DISPOSE_INFO/UNIT/text()'', dispose_info.dispose_node))[1]::text as xml_unit
  FROM xml_base
  CROSS JOIN LATERAL (
    SELECT
      dispose_node,
      row_number() OVER () AS dispose_no
    FROM unnest(xpath(''//DISPOSE/DISPOSE_INFO'', xmlparse(document xml_base.xml_text))) AS dispose_node
  ) AS dispose_info
  WHERE xml_base.xml_text IS NOT NULL AND xml_base.xml_text != ''''
),

-- content パース処理（フォールバック用）
content_dispose AS (
  SELECT
    content_data.element ->> ''detail_id'' AS detail_id,
    content_data.ordinality AS cost_no,
    content_data.element ->> ''e01'' AS e01,
    content_data.element ->> ''e02'' AS e02,
    content_data.element ->> ''e03'' AS e03,
    content_data.element ->> ''e04'' AS e04,
    (content_data.element ->> ''table_no'')::int AS table_no,
    content_data.ordinality AS row_no,
    content_data.ordinality AS row_order
  FROM jsonb_array_elements(@content::jsonb) WITH ORDINALITY AS content_data(element, ordinality)
  ORDER BY content_data.ordinality
)

-- 最終結果（content JSON形式対応）
-- 必須フィールド: detail_id, e01, e02, e03, e04, table_no, row_no
SELECT
  ''処置・検査'' as detail_id,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      xml_dispose.xml_tencd
    ELSE
      content_dispose.e01
  END as e01,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      xml_dispose.xml_tkjnam
    ELSE
      content_dispose.e02
  END as e02,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      xml_dispose.xml_amount
    ELSE
      content_dispose.e03
  END as e03,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      xml_dispose.xml_unit
    ELSE
      content_dispose.e04
  END as e04,

  -- テーブル番号
  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      1
    ELSE
      content_dispose.table_no
  END as table_no,

  -- 行番号
  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      ROW_NUMBER() OVER (ORDER BY xml_dispose.xml_cost_no)
    ELSE
      content_dispose.row_no
  END as row_no,

  -- DISPOSE_CTL_NO用のcost_no
  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      xml_dispose.xml_cost_no
    ELSE
      content_dispose.cost_no::text
  END as cost_no

FROM xml_base
LEFT JOIN xml_dispose ON xml_dispose.ctl_no = xml_base.ctl_no
LEFT JOIN content_dispose ON COALESCE(xml_base.is_xml_valid, false) = false
WHERE
  -- XMLデータ優先：XMLが有効な場合はXMLデータのみ
  (xml_base.is_xml_valid = true AND xml_dispose.dispose_no IS NOT NULL)
  OR
  -- フォールバック：XMLが無効な場合はcontentデータのみ
  (xml_base.is_xml_valid = false AND content_dispose.row_order IS NOT NULL)
ORDER BY
  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      xml_dispose.dispose_no
    ELSE
      content_dispose.row_order
  END;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI 実績送信', '2025-09-13 19:58:07.067', '2025-09-13 19:58:07.068', '[{"sql_cd": -301, "field_name": ["detail_id", "e01", "e02", "e03", "e04", "table_no", "row_no"], "replace_var": "content"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-504006, '-- =====================================================
-- 複数行SQL: -504006 薬剤詳細情報
-- XMLパース第一優先、フォールバック対応
-- パラメータ: ctlNo, ordNo, facilityCd, content
-- =====================================================
WITH
xml_base AS (
  SELECT
    j.ctl_no,
    j.ord_no,
    convert_from(j.dump, ''SJIS'') AS xml_text
  FROM sys_coop_journal j
  WHERE j.ord_no = @ordNo
    AND j.facility_cd = @facilityCd
    AND j.coop_cd = ''rst_dial''
  ORDER BY j.reg_date DESC
  OFFSET 1 LIMIT 1
),
xml_medicine AS (
  SELECT
    xb.ctl_no,
    CASE
      WHEN mi.xml_cost_no IS NOT NULL AND mi.xml_cost_no != '''' THEN TRUE
      ELSE FALSE
    END AS is_xml_valid,
    mi.medi_row_no,
    mi.xml_cost_no,
    mi.xml_medicine_cd,
    mi.xml_medicine_name,
    mi.xml_medi_class_name,
    mi.xml_amount,
    mi.xml_unit,
    mi.xml_procedure_cd,
    mi.xml_procedure_name
  FROM xml_base xb
  CROSS JOIN LATERAL (
    SELECT
      row_number() OVER () AS medi_row_no,
      (xpath(''MEDI_INFO/@CTL_NO'',               n))[1]::text AS xml_cost_no,
      (xpath(''MEDI_INFO/MEDICINE_CD/text()'',    n))[1]::text AS xml_medicine_cd,
      (xpath(''MEDI_INFO/MEDICINE_NAME/text()'',  n))[1]::text AS xml_medicine_name,
      (xpath(''MEDI_INFO/MEDI_CLASS_NAME/text()'',n))[1]::text AS xml_medi_class_name,
      (xpath(''MEDI_INFO/AMOUNT/text()'',         n))[1]::text AS xml_amount,
      (xpath(''MEDI_INFO/UNIT/text()'',           n))[1]::text AS xml_unit,
      (xpath(''MEDI_INFO/PROCEDURE_CD/text()'',   n))[1]::text AS xml_procedure_cd,
      (xpath(''MEDI_INFO/PROCEDURE_NAME/text()'', n))[1]::text AS xml_procedure_name
    FROM unnest(xpath(''//DIALYSIS_MEDI/MEDI_INFO'', xmlparse(document xb.xml_text))) AS n
  ) AS mi
  WHERE xb.xml_text IS NOT NULL AND xb.xml_text <> ''''
),
content_medicine AS (
  SELECT
    elem ->> ''detail_id''               AS detail_id,
    elem ->> ''e01''                     AS e01,
    elem ->> ''e02''                     AS e02,
    elem ->> ''e03''                     AS e03,
    elem ->> ''e04''                     AS e04,
    elem ->> ''e05''                     AS e05,
    elem ->> ''e06''                     AS e06,
    elem ->> ''e07''                     AS e07,
    (elem ->> ''medi_reg_order'')::int   AS medi_reg_order,
    (elem ->> ''medi_code_order'')::int  AS medi_code_order,
    (elem ->> ''medi_class_code_order'')::int AS medi_class_code_order,
    elem ->> ''medicine_type''           AS medicine_type,
    (elem ->> ''timing_code_order'')::int    AS timing_code_order,
    (elem ->> ''procedure_code_order'')::int AS procedure_code_order,
    (elem ->> ''interval_no'')::int      AS interval_no,
    elem ->> ''cost_no''                  AS cost_no,
    ordinality AS row_order
  FROM jsonb_array_elements(@content::jsonb) WITH ORDINALITY AS t(elem, ordinality)
  ORDER BY ordinality
)
SELECT
  ''薬剤詳細'' AS detail_id,
  COALESCE(xm.xml_medicine_cd,       cm.e01) AS e01,
  COALESCE(xm.xml_medicine_name,     cm.e02) AS e02,
  COALESCE(xm.xml_medi_class_name,   cm.e03) AS e03,
  COALESCE(xm.xml_amount,            cm.e04) AS e04,
  COALESCE(xm.xml_unit,              cm.e05) AS e05,
  COALESCE(xm.xml_procedure_cd,      cm.e06) AS e06,
  COALESCE(xm.xml_procedure_name,    cm.e07) AS e07,
  CASE WHEN xm.is_xml_valid THEN 0   ELSE cm.medi_reg_order        END AS medi_reg_order,
  CASE WHEN xm.is_xml_valid THEN 0   ELSE cm.medi_code_order       END AS medi_code_order,
  CASE WHEN xm.is_xml_valid THEN 0   ELSE cm.medi_class_code_order END AS medi_class_code_order,
  CASE WHEN xm.is_xml_valid THEN NULL ELSE cm.medicine_type        END AS medicine_type,
  CASE WHEN xm.is_xml_valid THEN 0   ELSE cm.timing_code_order     END AS timing_code_order,
  CASE WHEN xm.is_xml_valid THEN 0   ELSE cm.procedure_code_order  END AS procedure_code_order,
  CASE WHEN xm.is_xml_valid THEN 0   ELSE cm.interval_no           END AS interval_no,
  COALESCE(xm.xml_cost_no, cm.cost_no)                              AS cost_no
FROM xml_base xb
LEFT JOIN xml_medicine xm ON xm.ctl_no = xb.ctl_no AND xm.is_xml_valid = true
LEFT JOIN content_medicine cm ON xm.ctl_no IS NULL
WHERE
  -- XMLデータ優先：XMLが有効な場合はXMLデータのみ
  (xm.is_xml_valid = true AND xm.xml_cost_no IS NOT NULL)
  OR
  -- フォールバック：XMLが無効な場合はcontentデータのみ
  (xm.ctl_no IS NULL AND cm.cost_no IS NOT NULL)
ORDER BY
  CASE
    WHEN xm.is_xml_valid = true THEN
      xm.medi_row_no
    ELSE
      cm.row_order
  END;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI 実績送信', '2025-09-13 19:58:07.067', '2025-09-13 19:58:07.068', '[{"sql_cd": -501103, "field_name": ["detail_id", "e01", "e02", "e03", "e04", "e05", "e06", "e07", "medi_reg_order", "medi_code_order", "medi_class_code_order", "medicine_type", "timing_code_order", "procedure_code_order", "interval_no", "cost_no"], "replace_var": "content"}]'::jsonb);