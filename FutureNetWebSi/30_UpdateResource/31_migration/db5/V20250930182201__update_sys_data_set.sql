DELETE FROM ntss.sys_data_set
WHERE sql_cd in (-504003, -504004, -504005, -504006, -504007, -504008, -504009, -504010, -504011, -504012, -504013);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-504003, '-- =====================================================
-- 複数行SQL: -504003 透析条件情報（CTE形式）
-- XMLパース第一優先、フォールバック対応
-- パラメータ: ctlNo, ordNo, facilityCd, key0
-- =====================================================

WITH 
-- XMLパース基本処理
xml_base AS (
  SELECT 
    journal.ctl_no,
    journal.ord_no,
    journal.dump,
    convert_from(journal.dump, ''SJIS'') AS dump_text,
    CASE 
      WHEN journal.dump IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') <> ''''
           AND xml_is_well_formed_document(convert_from(journal.dump, ''SJIS''))
      THEN convert_from(journal.dump, ''SJIS'')::xml
      ELSE NULL
    END AS xml_data,
    CASE 
      WHEN journal.dump IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') <> ''''
           AND xml_is_well_formed_document(convert_from(journal.dump, ''SJIS''))
      THEN true
      ELSE false
    END AS is_xml_valid
  FROM sys_coop_journal journal
  WHERE journal.ord_no = @ordNo 
    AND journal.facility_cd = @facilityCd
    AND journal.coop_cd = ''rst_dial''
    AND journal.key0 = @key0
    AND journal.coop_result = ''9''
    AND journal.crud in (''C'', ''U'')
    AND journal.reg_date < (
      SELECT reg_date
      FROM sys_coop_journal
      WHERE ctl_no = @ctlNo
        AND key0 = @key0
        AND facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND coop_cd = ''rst_dial''
      LIMIT 1
    )
  ORDER BY journal.reg_date DESC
  LIMIT 1
),

-- XML透析条件抽出（002-040のCTL_NOのみ対象）
xml_conditions AS (
  SELECT 
    xml_base.ctl_no,
    xml_base.is_xml_valid,
    xml_ctl_no,
    xml_item_name,
    xml_value,
    xml_value_name,
    xml_unit
  FROM xml_base
  CROSS JOIN LATERAL (
    SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="002"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="002"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="002"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="002"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="002"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="003"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="003"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="003"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="003"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="003"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="004"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="004"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="004"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="004"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="004"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="005"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="005"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="005"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="005"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="005"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="006"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="006"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="006"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="006"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="006"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="007"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="007"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="007"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="007"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="007"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="008"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="008"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="008"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="008"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="008"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="009"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="009"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="009"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="009"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="009"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="010"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="010"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="010"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="010"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="010"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="011"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="011"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="011"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="011"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="011"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="012"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="012"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="012"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="012"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="012"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="013"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="013"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="013"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="013"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="013"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="014"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="014"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="014"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="014"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="014"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="015"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="015"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="015"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="015"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="015"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="016"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="016"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="016"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="016"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="016"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="017"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="017"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="017"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="017"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="017"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="018"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="018"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="018"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="018"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="018"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="019"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="019"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="019"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="019"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="019"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="020"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="020"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="020"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="020"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="020"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="021"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="021"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="021"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="021"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="021"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="022"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="022"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="022"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="022"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="022"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="023"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="023"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="023"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="023"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="023"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="024"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="024"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="024"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="024"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="024"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="025"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="025"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="025"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="025"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="025"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="029"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="029"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="029"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="029"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="029"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="030"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="030"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="030"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="030"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="030"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="031"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="031"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="031"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="031"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="031"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="032"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="032"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="032"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="032"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="032"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="033"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="033"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="033"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="033"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="033"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="034"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="034"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="034"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="034"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="034"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="035"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="035"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="035"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="035"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="035"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="036"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="036"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="036"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="036"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="036"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="037"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="037"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="037"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="037"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="037"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="038"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="038"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="038"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="038"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="038"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="039"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="039"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="039"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="039"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="039"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
    UNION ALL SELECT 
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="040"]/@CTL_NO'', xml_data))[1]::text, '''') as xml_ctl_no,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="040"]/DIALYSIS_ITEM_NAME/text()'', xml_data))[1]::text, '''') as xml_item_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="040"]/VALUE/text()'', xml_data))[1]::text, '''') as xml_value,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="040"]/VALUE_NAME/text()'', xml_data))[1]::text, '''') as xml_value_name,
      COALESCE((xpath(''//DIALYSIS_COND/COND_INFO[@CTL_NO="040"]/UNIT/text()'', xml_data))[1]::text, '''') as xml_unit
  ) AS xml_extract
  WHERE xml_data IS NOT NULL 
    AND xml_ctl_no != '''' 
    AND (xml_value != '''' OR xml_value_name != '''')
),

-- content パース処理（フォールバック用）
content_conditions AS (
  SELECT
    content_data.element ->> ''detail_id'' AS detail_id,
    content_data.element ->> ''e01'' AS e01,
    content_data.element ->> ''e02'' AS e02,
    content_data.element ->> ''e03'' AS e03,
    content_data.element ->> ''e04'' AS e04,
    content_data.element ->> ''e05'' AS e05,
    content_data.ordinality AS row_order
  FROM jsonb_array_elements(@content::jsonb) WITH ORDINALITY AS content_data(element, ordinality)
  WHERE content_data.element ->> ''detail_id'' = ''透析条件''
  ORDER BY content_data.ordinality
)

-- 最終結果（content JSON形式対応）
-- 必須フィールド: detail_id, e01, e02, e03, e04, e05
SELECT
  ''透析条件'' as detail_id,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      xml_conditions.xml_ctl_no
    ELSE
      content_conditions.e01
  END as e01,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      xml_conditions.xml_item_name
    ELSE
      content_conditions.e02
  END as e02,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      xml_conditions.xml_value
    ELSE
      content_conditions.e03
  END as e03,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      xml_conditions.xml_value_name
    ELSE
      content_conditions.e04
  END as e04,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      xml_conditions.xml_unit
    ELSE
      content_conditions.e05
  END as e05

FROM xml_base
LEFT JOIN xml_conditions ON xml_conditions.ctl_no = xml_base.ctl_no
LEFT JOIN content_conditions ON COALESCE(xml_base.is_xml_valid, false) = false
WHERE
  -- XMLデータ優先：XMLが有効な場合はXMLデータのみ
  (xml_base.is_xml_valid = true AND xml_conditions.xml_ctl_no IS NOT NULL)
  OR
  -- フォールバック：XMLが無効な場合はcontentデータのみ
  (xml_base.is_xml_valid = false AND content_conditions.detail_id IS NOT NULL)
ORDER BY
  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      xml_conditions.xml_ctl_no
    ELSE
      content_conditions.e01
  END ASC;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI 実績送信', '2025-09-13 19:58:07.067', '2025-09-13 19:58:07.068', '[{"sql_cd": -504001, "field_name": ["detail_id", "e01", "e02", "e03", "e04", "e05"], "replace_var": "content"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-504004, '-- =====================================================
-- 複数行SQL: -504004 処置・検査情報（CTE形式）
-- XMLパース第一優先、フォールバック対応
-- パラメータ: ctlNo, ordNo, facilityCd, key0
-- =====================================================

WITH 
-- XMLパース基本処理
xml_base AS (
  SELECT 
    journal.ctl_no,
    journal.ord_no,
    journal.dump,
    convert_from(journal.dump, ''SJIS'') AS dump_text,
    CASE 
      WHEN journal.dump IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') <> ''''
           AND xml_is_well_formed_document(convert_from(journal.dump, ''SJIS''))
      THEN convert_from(journal.dump, ''SJIS'')::xml
      ELSE NULL
    END AS xml_data,
    CASE 
      WHEN journal.dump IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') <> ''''
           AND xml_is_well_formed_document(convert_from(journal.dump, ''SJIS''))
      THEN true
      ELSE false
    END AS is_xml_valid
  FROM sys_coop_journal journal
  WHERE journal.ord_no = @ordNo 
    AND journal.facility_cd = @facilityCd
    AND journal.coop_cd = ''rst_dial''
    AND journal.key0 = @key0
    AND journal.coop_result = ''9''
    AND journal.crud in (''C'', ''U'')
    AND journal.reg_date < (
      SELECT reg_date
      FROM sys_coop_journal
      WHERE ctl_no = @ctlNo
        AND key0 = @key0
        AND facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND coop_cd = ''rst_dial''
      LIMIT 1
    )
  ORDER BY journal.reg_date DESC
  LIMIT 1
),

-- XML処置検査情報抽出（※ xml_text -> xml_data に修正）
xml_dispose AS (
  SELECT
    xb.ctl_no,
    xb.is_xml_valid,
    di.dispose_no,
    (xpath(''DISPOSE_INFO/@DISPOSE_CTL_NO'', di.dispose_node))[1]::text AS xml_cost_no,
    (xpath(''DISPOSE_INFO/TENCD/text()'',        di.dispose_node))[1]::text AS xml_tencd,
    (xpath(''DISPOSE_INFO/TKJNAM/text()'',       di.dispose_node))[1]::text AS xml_tkjnam,
    (xpath(''DISPOSE_INFO/AMOUNT/text()'',       di.dispose_node))[1]::text AS xml_amount,
    (xpath(''DISPOSE_INFO/UNIT/text()'',         di.dispose_node))[1]::text AS xml_unit
  FROM xml_base xb
  CROSS JOIN LATERAL (
    SELECT
      dispose_node,
      row_number() OVER () AS dispose_no
    FROM unnest(xpath(''//DISPOSE/DISPOSE_INFO'', xb.xml_data)) AS dispose_node
  ) AS di
  WHERE xb.xml_data IS NOT NULL
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
SELECT
  ''処置・検査'' AS detail_id,

  CASE WHEN COALESCE(xb.is_xml_valid, false)
       THEN xd.xml_tencd ELSE cd.e01 END AS e01,

  CASE WHEN COALESCE(xb.is_xml_valid, false)
       THEN xd.xml_tkjnam ELSE cd.e02 END AS e02,

  CASE WHEN COALESCE(xb.is_xml_valid, false)
       THEN xd.xml_amount ELSE cd.e03 END AS e03,

  CASE WHEN COALESCE(xb.is_xml_valid, false)
       THEN xd.xml_unit ELSE cd.e04 END AS e04,

  CASE WHEN COALESCE(xb.is_xml_valid, false)
       THEN 1 ELSE cd.table_no END AS table_no,

  CASE WHEN COALESCE(xb.is_xml_valid, false)
       THEN ROW_NUMBER() OVER (ORDER BY xd.xml_cost_no)
       ELSE cd.row_no END AS row_no,

  CASE WHEN COALESCE(xb.is_xml_valid, false)
       THEN xd.xml_cost_no
       ELSE cd.cost_no::text END AS cost_no

FROM xml_base xb
LEFT JOIN xml_dispose    xd ON xd.ctl_no = xb.ctl_no
LEFT JOIN content_dispose cd ON COALESCE(xb.is_xml_valid, false) = false
WHERE
  (xb.is_xml_valid = true  AND xd.dispose_no IS NOT NULL)
  OR
  (xb.is_xml_valid = false AND cd.row_order IS NOT NULL)
ORDER BY
  CASE WHEN COALESCE(xb.is_xml_valid, false)
       THEN xd.dispose_no ELSE cd.row_order END;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI 実績送信', '2025-09-13 19:58:07.067', '2025-09-13 19:58:07.068', '[{"sql_cd": -301, "field_name": ["detail_id", "e01", "e02", "e03", "e04", "table_no", "row_no"], "replace_var": "content"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-504005, '-- =====================================================
-- 複数行SQL: -504005 医材詳細情報（CTE形式）
-- XMLパース第一優先、フォールバック対応
-- パラメータ: ctlNo, ordNo, facilityCd, key0
-- =====================================================

WITH 
-- XMLパース基本処理
xml_base AS (
  SELECT 
    journal.ctl_no,
    journal.ord_no,
    journal.dump,
    convert_from(journal.dump, ''SJIS'') AS dump_text,
    CASE 
      WHEN journal.dump IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') <> ''''
           AND xml_is_well_formed_document(convert_from(journal.dump, ''SJIS''))
      THEN convert_from(journal.dump, ''SJIS'')::xml
      ELSE NULL
    END AS xml_data,
    CASE 
      WHEN journal.dump IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') <> ''''
           AND xml_is_well_formed_document(convert_from(journal.dump, ''SJIS''))
      THEN true
      ELSE false
    END AS is_xml_valid
  FROM sys_coop_journal journal
  WHERE journal.ord_no = @ordNo 
    AND journal.facility_cd = @facilityCd
    AND journal.coop_cd     = ''rst_dial''
    AND journal.key0        = @key0
    AND journal.coop_result = ''9''
    AND journal.crud in (''C'', ''U'')
    AND journal.reg_date < (
      SELECT reg_date
      FROM sys_coop_journal
      WHERE ctl_no      = @ctlNo
        AND key0        = @key0
        AND facility_cd = @facilityCd
        AND ord_no      = @ordNo
        AND coop_cd     = ''rst_dial''
      LIMIT 1
    )
  ORDER BY journal.reg_date DESC
  LIMIT 1
),

-- XML医材詳細情報抽出
xml_equip AS (
  SELECT
    xb.ctl_no,
    xb.is_xml_valid,
    ei.equip_no,
    (xpath(''EQUIP_INFO/@CTL_NO'',                  ei.equip_node))[1]::text AS xml_cost_no,
    (xpath(''EQUIP_INFO/EQUIP_CD/text()'',          ei.equip_node))[1]::text AS xml_equip_cd,
    (xpath(''EQUIP_INFO/EQUIP_NAME/text()'',        ei.equip_node))[1]::text AS xml_equip_name,
    (xpath(''EQUIP_INFO/EQUIP_CLASS_NAME/text()'',  ei.equip_node))[1]::text AS xml_equip_class_name,
    (xpath(''EQUIP_INFO/PUNCTURE_CLASS/text()'',    ei.equip_node))[1]::text AS xml_puncture_class,
    (xpath(''EQUIP_INFO/AMOUNT/text()'',            ei.equip_node))[1]::text AS xml_amount,
    (xpath(''EQUIP_INFO/UNIT/text()'',              ei.equip_node))[1]::text AS xml_unit
  FROM xml_base xb
  CROSS JOIN LATERAL (
    SELECT
      equip_node,
      row_number() OVER () AS equip_no
    FROM unnest(xpath(''//DIALYSIS_EQUIP/EQUIP_INFO'', xb.xml_data)) AS equip_node
  ) AS ei
  WHERE xb.xml_data IS NOT NULL
),

-- content パース処理（フォールバック用）
content_equip AS (
  SELECT
    content_data.element ->> ''detail_id'' AS detail_id,
    content_data.element ->> ''cost_no''   AS cost_no,
    content_data.element ->> ''e01''       AS e01,
    content_data.element ->> ''e02''       AS e02,
    content_data.element ->> ''e03''       AS e03,
    content_data.element ->> ''e04''       AS e04,
    content_data.element ->> ''e05''       AS e05,
    content_data.element ->> ''e06''       AS e06,
    content_data.ordinality              AS row_order
  FROM jsonb_array_elements(@content::jsonb) WITH ORDINALITY AS content_data(element, ordinality)
  ORDER BY content_data.ordinality
)

-- 最終結果（content JSON形式対応）
-- 必須フィールド: detail_id, cost_no, e01, e02, e03, e04, e05, e06
SELECT
  ''医材詳細'' AS detail_id,

  CASE WHEN COALESCE(xb.is_xml_valid, false) THEN xe.xml_cost_no        ELSE ce.cost_no END AS cost_no,
  CASE WHEN COALESCE(xb.is_xml_valid, false) THEN xe.xml_equip_cd       ELSE ce.e01     END AS e01,
  CASE WHEN COALESCE(xb.is_xml_valid, false) THEN xe.xml_equip_name     ELSE ce.e02     END AS e02,
  CASE WHEN COALESCE(xb.is_xml_valid, false) THEN xe.xml_equip_class_name ELSE ce.e03   END AS e03,
  CASE WHEN COALESCE(xb.is_xml_valid, false) THEN xe.xml_puncture_class ELSE ce.e04     END AS e04,
  CASE WHEN COALESCE(xb.is_xml_valid, false) THEN xe.xml_amount         ELSE ce.e05     END AS e05,
  CASE WHEN COALESCE(xb.is_xml_valid, false) THEN xe.xml_unit           ELSE ce.e06     END AS e06

FROM xml_base xb
LEFT JOIN xml_equip     xe ON xe.ctl_no = xb.ctl_no
LEFT JOIN content_equip ce ON COALESCE(xb.is_xml_valid, false) = false
WHERE
  -- XMLデータ優先：XMLが有効な場合はXMLデータのみ
  (xb.is_xml_valid = true  AND xe.xml_cost_no IS NOT NULL)
  OR
  -- フォールバック：XMLが無効な場合はcontentデータのみ
  (xb.is_xml_valid = false AND ce.row_order IS NOT NULL)
ORDER BY
  CASE WHEN COALESCE(xb.is_xml_valid, false) THEN xe.equip_no ELSE ce.row_order END;
', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI 実績送信', '2025-09-13 19:58:07.067', '2025-09-13 19:58:07.068', '[{"sql_cd": -501102, "field_name": ["detail_id", "e01", "e02", "e03", "e04", "e05", "e06", "cost_no"], "replace_var": "content"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-504006, '-- =====================================================
-- 複数行SQL: -504006 薬剤詳細情報
-- XMLパース第一優先、フォールバック対応
-- パラメータ: ctlNo, ordNo, facilityCd, content, key0
-- =====================================================
WITH
xml_base AS (
  SELECT 
    journal.ctl_no,
    journal.ord_no,
    journal.dump,
    convert_from(journal.dump, ''SJIS'') AS dump_text,
    CASE 
      WHEN journal.dump IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') <> ''''
           AND xml_is_well_formed_document(convert_from(journal.dump, ''SJIS''))
      THEN convert_from(journal.dump, ''SJIS'')::xml
      ELSE NULL
    END AS xml_data,
    CASE 
      WHEN journal.dump IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') <> ''''
           AND xml_is_well_formed_document(convert_from(journal.dump, ''SJIS''))
      THEN true
      ELSE false
    END AS is_xml_valid
  FROM sys_coop_journal journal
  WHERE journal.ord_no = @ordNo 
    AND journal.facility_cd = @facilityCd
    AND journal.coop_cd = ''rst_dial''
    AND journal.key0 = @key0
    AND journal.coop_result = ''9''
    AND journal.crud in (''C'', ''U'')
    AND journal.reg_date < (
      SELECT reg_date
      FROM sys_coop_journal
      WHERE ctl_no = @ctlNo
        AND key0 = @key0
        AND facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND coop_cd = ''rst_dial''
      LIMIT 1
    )
  ORDER BY journal.reg_date DESC
  LIMIT 1
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
    FROM unnest(xpath(''//DIALYSIS_MEDI/MEDI_INFO'', xb.xml_data)) AS n
  ) AS mi
  WHERE xb.xml_data IS NOT NULL
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
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-504007, '-- =====================================================
-- 単一行SQL: -504007 透析基本情報
-- XMLパース第一優先、フォールバック対応
-- パラメータ: ctlNo, ordNo, facilityCd, key0
-- =====================================================

WITH 
-- XMLパース基本処理
xml_base AS (
  SELECT 
    journal.ctl_no,
    journal.ord_no,
    journal.dump,
    convert_from(journal.dump, ''SJIS'') AS dump_text,
    CASE 
      WHEN journal.dump IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') <> ''''
           AND xml_is_well_formed_document(convert_from(journal.dump, ''SJIS''))
      THEN convert_from(journal.dump, ''SJIS'')::xml
      ELSE NULL
    END AS xml_data,
    CASE 
      WHEN journal.dump IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') <> ''''
           AND xml_is_well_formed_document(convert_from(journal.dump, ''SJIS''))
      THEN true
      ELSE false
    END AS is_xml_valid
  FROM sys_coop_journal journal
  WHERE journal.ord_no = @ordNo 
    AND journal.facility_cd = @facilityCd
    AND journal.coop_cd = ''rst_dial''
    AND journal.key0 = @key0
    AND journal.coop_result = ''9''
    AND journal.crud in (''C'', ''U'')
    AND journal.reg_date < (
      SELECT reg_date
      FROM sys_coop_journal
      WHERE ctl_no = @ctlNo
        AND key0 = @key0
        AND facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND coop_cd = ''rst_dial''
      LIMIT 1
    )
  ORDER BY journal.reg_date DESC
  LIMIT 1
),

-- XML透析基本情報抽出
xml_dialysis AS (
  SELECT 
    xml_base.ctl_no,
    xml_base.is_xml_valid,
    (xpath(''//DIALYSIS_DATE/text()'', xml_data))[1]::text as xml_dialysis_date,
    (xpath(''//DIALYSIS_NO/text()'', xml_data))[1]::text as xml_ord_no,
    (xpath(''//BED_NO/text()'', xml_data))[1]::text as xml_bed_cd,
    (xpath(''//BED_NAME/text()'', xml_data))[1]::text as xml_bed_name,
    (xpath(''//KUR_CD/text()'', xml_data))[1]::text as xml_kur_cd,
    (xpath(''//KUR_NAME/text()'', xml_data))[1]::text as xml_kur_name,
    (xpath(''//DEVICE_NO/text()'', xml_data))[1]::text as xml_machine_no,
    (xpath(''//DEVICE_NAME/text()'', xml_data))[1]::text as xml_machine_name,
    (xpath(''//START_DATE/text()'', xml_data))[1]::text as xml_start_date,
    (xpath(''//END_DATE/text()'', xml_data))[1]::text as xml_end_date,
    (xpath(''//DIALYSIS_TIME/text()'', xml_data))[1]::text as xml_running_time,
    (xpath(''//WEIGHT_BEFORE/text()'', xml_data))[1]::text as xml_weight_before,
    (xpath(''//WEIGHT_AFTER/text()'', xml_data))[1]::text as xml_weight_after
  FROM xml_base
  WHERE xml_data IS NOT NULL
),

-- content パース処理（フォールバック用）
content_dialysis AS (
  WITH src AS (
    SELECT COALESCE(@content::jsonb, ''[]''::jsonb) AS j
  )
  SELECT
    e ->> ''ord_no''           AS ord_no,
    e ->> ''treat_date''       AS treat_date,
    e ->> ''bed_cd1''          AS bed_cd1,
    e ->> ''bed_name''         AS bed_name,
    e ->> ''kur_cd1''          AS kur_cd1,
    e ->> ''kur_name''         AS kur_name,
    e ->> ''machine_no''       AS machine_no,
    e ->> ''machine_name''     AS machine_name,
    e ->> ''start_date''       AS start_date,
    e ->> ''end_date''         AS end_date,
    e ->> ''running_time_cal'' AS running_time_cal,
    e ->> ''weight_before''    AS weight_before,
    e ->> ''weight_after''     AS weight_after
  FROM src, LATERAL jsonb_array_elements(src.j) AS e
  LIMIT 1
)

-- 最終結果（content JSON形式対応）
SELECT
  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_dialysis.xml_dialysis_date, '''')
    ELSE
      COALESCE(content_dialysis.treat_date, '''')
  END as treat_date,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_dialysis.xml_ord_no, '''')
    ELSE
      COALESCE(content_dialysis.ord_no, '''')
  END as ord_no,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_dialysis.xml_bed_cd, '''')
    ELSE
      COALESCE(content_dialysis.bed_cd1, '''')
  END as bed_cd1,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_dialysis.xml_bed_name, '''')
    ELSE
      COALESCE(content_dialysis.bed_name, '''')
  END as bed_name,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_dialysis.xml_kur_cd, '''')
    ELSE
      COALESCE(content_dialysis.kur_cd1, '''')
  END as kur_cd1,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_dialysis.xml_kur_name, '''')
    ELSE
      COALESCE(content_dialysis.kur_name, '''')
  END as kur_name,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_dialysis.xml_machine_no, ''0'')
    ELSE
      COALESCE(content_dialysis.machine_no, ''0'')
  END as machine_no,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_dialysis.xml_machine_name, '''')
    ELSE
      COALESCE(content_dialysis.machine_name, '''')
  END as machine_name,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_dialysis.xml_start_date, '''')
    ELSE
      COALESCE(content_dialysis.start_date, '''')
  END as start_date,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_dialysis.xml_end_date, '''')
    ELSE
      COALESCE(content_dialysis.end_date, '''')
  END as end_date,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_dialysis.xml_running_time, ''0'')
    ELSE
      COALESCE(content_dialysis.running_time_cal, ''0'')
  END as running_time_cal,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_dialysis.xml_weight_before, '''')
    ELSE
      COALESCE(content_dialysis.weight_before, '''')
  END as weight_before,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_dialysis.xml_weight_after, '''')
    ELSE
      COALESCE(content_dialysis.weight_after, '''')
  END as weight_after

FROM xml_base
LEFT JOIN xml_dialysis ON xml_dialysis.ctl_no = xml_base.ctl_no
LEFT JOIN content_dialysis ON COALESCE(xml_base.is_xml_valid, false) = false;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI 実績送信', '2025-09-13 19:58:07.067', '2025-09-13 19:58:07.068', '[{"sql_cd": -504000, "field_name": ["ord_no", "treat_date", "kur_cd1", "kur_name", "machine_no", "machine_name", "bed_cd1", "bed_name", "start_date", "end_date", "running_time_cal", "weight_before", "weight_after"], "replace_var": "content"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-504008, '-- =====================================================
-- 単一行SQL: -504008 患者個人情報
-- 対象: pat_personal_main
-- パラメータ: patId, facilityCd, hosp_pat_id8
-- =====================================================

SELECT
  CASE
    WHEN @hosp_pat_id8::text IS NOT NULL AND @hosp_pat_id8::text != '''' THEN
      @hosp_pat_id8::text
    ELSE
      CASE WHEN LENGTH(hosp_pat_id) >= 8 THEN hosp_pat_id ELSE LPAD(hosp_pat_id, 8, ''0'') END
  END AS hosp_pat_id8
FROM pat_personal_main
WHERE is_del = ''0'' AND pat_id = @patId AND facility_cd = @facilityCd;', 3, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI 実績送信', '2025-09-13 19:58:07.067', '2025-09-13 19:58:07.068', '[{"sql_cd": -504012, "field_name": "hosp_pat_id8", "replace_var": "@hosp_pat_id8"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-504009, '-- =====================================================
-- 単一行SQL: -504009 透析前バイタル情報
-- XMLパース第一優先、フォールバック対応
-- パラメータ: ctlNo, ordNo, facilityCd, key0
-- =====================================================

WITH 
-- XMLパース基本処理
xml_base AS (
  SELECT 
    journal.ctl_no,
    journal.ord_no,
    journal.dump,
    convert_from(journal.dump, ''SJIS'') AS dump_text,
    CASE 
      WHEN journal.dump IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') <> ''''
           AND xml_is_well_formed_document(convert_from(journal.dump, ''SJIS''))
      THEN convert_from(journal.dump, ''SJIS'')::xml
      ELSE NULL
    END AS xml_data,
    CASE 
      WHEN journal.dump IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') <> ''''
           AND xml_is_well_formed_document(convert_from(journal.dump, ''SJIS''))
      THEN true
      ELSE false
    END AS is_xml_valid
  FROM sys_coop_journal journal
  WHERE journal.ord_no = @ordNo 
    AND journal.facility_cd = @facilityCd
    AND journal.coop_cd = ''rst_dial''
    AND journal.key0 = @key0
    AND journal.coop_result = ''9''
    AND journal.crud in (''C'', ''U'')
    AND journal.reg_date < (
      SELECT reg_date
      FROM sys_coop_journal
      WHERE ctl_no = @ctlNo
        AND key0 = @key0
        AND facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND coop_cd = ''rst_dial''
      LIMIT 1
    )
  ORDER BY journal.reg_date DESC
  LIMIT 1
),

-- XML透析前バイタル情報抽出
xml_vital_before AS (
  SELECT 
    xml_base.ctl_no,
    xml_base.is_xml_valid,
    (xpath(''//BP_BEFORE_MAX/text()'', xml_data))[1]::text as xml_bp_before_max,
    (xpath(''//BP_BEFORE_MIN/text()'', xml_data))[1]::text as xml_bp_before_min,
    (xpath(''//PULSE_BEFORE/text()'', xml_data))[1]::text as xml_pulse_before
  FROM xml_base
  WHERE xml_data IS NOT NULL
),

-- content パース処理（フォールバック用）
content_vital_before AS (
  WITH src AS (
    SELECT COALESCE(@content::jsonb, ''[]''::jsonb) AS j
  )
  SELECT
    ''前・脈・血圧'' as detail_id,
    elem ->> ''occur_date'' AS occur_date,
    NULLIF(elem ->> ''bp_high'','''')::numeric AS bp_high,
    NULLIF(elem ->> ''bp_low'','''')::numeric AS bp_low,
    NULLIF(elem ->> ''bp_ave'','''')::numeric AS bp_ave,
    NULLIF(elem ->> ''pulse'','''')::numeric AS pulse,
    NULLIF(elem ->> ''body_temperature'','''')::numeric AS body_temperature,
    NULLIF(elem ->> ''blood_glucose_level'','''')::numeric AS blood_glucose_level
  FROM src, LATERAL jsonb_array_elements(src.j) elem
  LIMIT 1
)

-- 最終結果（content JSON形式対応）
SELECT
  ''前・脈・血圧'' as detail_id,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      ''''  -- XMLからoccur_dateは取得できないため空文字
    ELSE
      COALESCE(content_vital_before.occur_date, '''')
  END as occur_date,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_vital_before.xml_bp_before_max, '''')
    ELSE
      COALESCE(content_vital_before.bp_high::text, '''')
  END as bp_high,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_vital_before.xml_bp_before_min, '''')
    ELSE
      COALESCE(content_vital_before.bp_low::text, '''')
  END as bp_low,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      ''''  -- XMLからbp_aveは取得できないため空文字
    ELSE
      COALESCE(content_vital_before.bp_ave::text, '''')
  END as bp_ave,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_vital_before.xml_pulse_before, '''')
    ELSE
      COALESCE(content_vital_before.pulse::text, '''')
  END as pulse,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      ''''  -- XMLからbody_temperatureは取得できないため空文字
    ELSE
      COALESCE(content_vital_before.body_temperature::text, '''')
  END as body_temperature,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      ''''  -- XMLからblood_glucose_levelは取得できないため空文字
    ELSE
      COALESCE(content_vital_before.blood_glucose_level::text, '''')
  END as blood_glucose_level

FROM xml_base
LEFT JOIN xml_vital_before ON xml_vital_before.ctl_no = xml_base.ctl_no
LEFT JOIN content_vital_before ON COALESCE(xml_base.is_xml_valid, false) = false;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI 実績送信', '2025-09-13 19:58:07.067', '2025-09-13 19:58:07.068', '[{"sql_cd": -35, "field_name": ["detail_id", "occur_date", "bp_high", "bp_low", "bp_ave", "pulse", "body_temperature", "blood_glucose_level"], "replace_var": "content"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-504010, '-- =====================================================
-- 単一行SQL: -504010 透析後バイタル情報
-- XMLパース第一優先、フォールバック対応
-- パラメータ: ctlNo, ordNo, facilityCd, key0
-- =====================================================

WITH 
-- XMLパース基本処理
xml_base AS (
  SELECT 
    journal.ctl_no,
    journal.ord_no,
    journal.dump,
    convert_from(journal.dump, ''SJIS'') AS dump_text,
    CASE 
      WHEN journal.dump IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') <> ''''
           AND xml_is_well_formed_document(convert_from(journal.dump, ''SJIS''))
      THEN convert_from(journal.dump, ''SJIS'')::xml
      ELSE NULL
    END AS xml_data,
    CASE 
      WHEN journal.dump IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') <> ''''
           AND xml_is_well_formed_document(convert_from(journal.dump, ''SJIS''))
      THEN true
      ELSE false
    END AS is_xml_valid
  FROM sys_coop_journal journal
  WHERE journal.ord_no = @ordNo 
    AND journal.facility_cd = @facilityCd
    AND journal.coop_cd = ''rst_dial''
    AND journal.key0 = @key0
    AND journal.coop_result = ''9''
    AND journal.crud in (''C'', ''U'')
    AND journal.reg_date < (
      SELECT reg_date
      FROM sys_coop_journal
      WHERE ctl_no = @ctlNo
        AND key0 = @key0
        AND facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND coop_cd = ''rst_dial''
      LIMIT 1
    )
  ORDER BY journal.reg_date DESC
  LIMIT 1
),

-- XML透析後バイタル情報抽出
xml_vital_after AS (
  SELECT 
    xml_base.ctl_no,
    xml_base.is_xml_valid,
    (xpath(''//BP_AFTER_MAX/text()'', xml_data))[1]::text as xml_bp_after_max,
    (xpath(''//BP_AFTER_MIN/text()'', xml_data))[1]::text as xml_bp_after_min,
    (xpath(''//PULSE_AFTER/text()'', xml_data))[1]::text as xml_pulse_after
  FROM xml_base
  WHERE xml_data IS NOT NULL
),

-- content パース処理（フォールバック用）
content_vital_after AS (
  WITH src AS (
    SELECT COALESCE(@content::jsonb, ''[]''::jsonb) AS j
  )
  SELECT
    ''後・脈・血圧'' AS detail_id,
    elem ->> ''occur_date''                         AS occur_date,
    NULLIF(elem ->> ''bp_high'','''')::numeric        AS bp_high,
    NULLIF(elem ->> ''bp_low'','''')::numeric         AS bp_low,
    NULLIF(elem ->> ''bp_ave'','''')::numeric         AS bp_ave,
    NULLIF(elem ->> ''pulse'','''')::numeric          AS pulse,
    NULLIF(elem ->> ''body_temperature'','''')::numeric      AS body_temperature,
    NULLIF(elem ->> ''blood_glucose_level'','''')::numeric   AS blood_glucose_level
  FROM src, LATERAL jsonb_array_elements(src.j) AS elem
  LIMIT 1
)

-- 最終結果（content JSON形式対応）
SELECT
  ''後・脈・血圧'' as detail_id,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      ''''  -- XMLからoccur_dateは取得できないため空文字
    ELSE
      COALESCE(content_vital_after.occur_date, '''')
  END as occur_date,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_vital_after.xml_bp_after_max, '''')
    ELSE
      COALESCE(content_vital_after.bp_high::text, '''')
  END as bp_high,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_vital_after.xml_bp_after_min, '''')
    ELSE
      COALESCE(content_vital_after.bp_low::text, '''')
  END as bp_low,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      ''''  -- XMLからbp_aveは取得できないため空文字
    ELSE
      COALESCE(content_vital_after.bp_ave::text, '''')
  END as bp_ave,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      COALESCE(xml_vital_after.xml_pulse_after, '''')
    ELSE
      COALESCE(content_vital_after.pulse::text, '''')
  END as pulse,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      ''''  -- XMLからbody_temperatureは取得できないため空文字
    ELSE
      COALESCE(content_vital_after.body_temperature::text, '''')
  END as body_temperature,

  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      ''''  -- XMLからblood_glucose_levelは取得できないため空文字
    ELSE
      COALESCE(content_vital_after.blood_glucose_level::text, '''')
  END as blood_glucose_level

FROM xml_base
LEFT JOIN xml_vital_after ON xml_vital_after.ctl_no = xml_base.ctl_no
LEFT JOIN content_vital_after ON COALESCE(xml_base.is_xml_valid, false) = false;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI 実績送信', '2025-09-13 19:58:07.067', '2025-09-13 19:58:07.068', '[{"sql_cd": -36, "field_name": ["detail_id", "occur_date", "bp_high", "bp_low", "bp_ave", "pulse", "body_temperature", "blood_glucose_level"], "replace_var": "content"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-504011, '-- =====================================================
-- 単一行SQL: -504011 スタッフ情報（透析担当者・穿刺・回収）
-- XMLパース第一優先、フォールバック対応
-- パラメータ: ctlNo, ordNo, facilityCd, key0
-- =====================================================

WITH 
-- XMLパース基本処理
xml_base AS (
  SELECT 
    journal.ctl_no,
    journal.ord_no,
    journal.dump,
    convert_from(journal.dump, ''SJIS'') AS dump_text,
    CASE 
      WHEN journal.dump IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') <> ''''
           AND xml_is_well_formed_document(convert_from(journal.dump, ''SJIS''))
      THEN convert_from(journal.dump, ''SJIS'')::xml
      ELSE NULL
    END AS xml_data,
    CASE 
      WHEN journal.dump IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') <> ''''
           AND xml_is_well_formed_document(convert_from(journal.dump, ''SJIS''))
      THEN true
      ELSE false
    END AS is_xml_valid
  FROM sys_coop_journal journal
  WHERE journal.ord_no = @ordNo 
    AND journal.facility_cd = @facilityCd
    AND journal.coop_cd = ''rst_dial''
    AND journal.key0 = @key0
    AND journal.coop_result = ''9''
    AND journal.crud in (''C'', ''U'')
    AND journal.reg_date < (
      SELECT reg_date
      FROM sys_coop_journal
      WHERE ctl_no = @ctlNo
        AND key0 = @key0
        AND facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND coop_cd = ''rst_dial''
      LIMIT 1
    )
  ORDER BY journal.reg_date DESC
  LIMIT 1
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
VALUES(-504012, '-- =====================================================
-- 単一行SQL: -504012 患者ID（XMLからhosp_pat_id8取得）
-- XMLパース処理
-- パラメータ: ctlNo, ordNo, facilityCd, key0
-- =====================================================

WITH
-- XMLパース基本処理
xml_base AS (
  SELECT 
    journal.ctl_no,
    journal.ord_no,
    journal.dump,
    convert_from(journal.dump, ''SJIS'') AS dump_text,
    CASE 
      WHEN journal.dump IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') <> ''''
           AND xml_is_well_formed_document(convert_from(journal.dump, ''SJIS''))
      THEN convert_from(journal.dump, ''SJIS'')::xml
      ELSE NULL
    END AS xml_data,
    CASE 
      WHEN journal.dump IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') IS NOT NULL
           AND convert_from(journal.dump, ''SJIS'') <> ''''
           AND xml_is_well_formed_document(convert_from(journal.dump, ''SJIS''))
      THEN true
      ELSE false
    END AS is_xml_valid
  FROM sys_coop_journal journal
  WHERE journal.ord_no = @ordNo 
    AND journal.facility_cd = @facilityCd
    AND journal.coop_cd = ''rst_dial''
    AND journal.key0 = @key0
    AND journal.coop_result = ''9''
    AND journal.crud in (''C'', ''U'')
    AND journal.reg_date < (
      SELECT reg_date
      FROM sys_coop_journal
      WHERE ctl_no = @ctlNo
        AND key0 = @key0
        AND facility_cd = @facilityCd
        AND ord_no = @ordNo
        AND coop_cd = ''rst_dial''
      LIMIT 1
    )
  ORDER BY journal.reg_date DESC
  LIMIT 1
),

-- XML患者ID情報抽出
xml_patient_id AS (
  SELECT
    xml_base.ctl_no,
    xml_base.is_xml_valid,
    (xpath(''//PatientID/text()'', xml_data))[1]::text as xml_patient_id
  FROM xml_base
  WHERE xml_data IS NOT NULL
)

-- 最終結果（XMLからhosp_pat_id8取得）
SELECT
  CASE
    WHEN COALESCE(xml_base.is_xml_valid, false) = true THEN
      CASE
        WHEN LENGTH(COALESCE(xml_patient_id.xml_patient_id, '''')) >= 8 THEN
          xml_patient_id.xml_patient_id
        ELSE
          LPAD(COALESCE(xml_patient_id.xml_patient_id, ''''), 8, ''0'')
      END
    ELSE
      ''''
  END as hosp_pat_id8

FROM xml_base
LEFT JOIN xml_patient_id ON xml_patient_id.ctl_no = xml_base.ctl_no;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, 'SSI 実績送信', '2025-09-13 19:58:07.067', '2025-09-13 19:58:07.068', NULL);
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