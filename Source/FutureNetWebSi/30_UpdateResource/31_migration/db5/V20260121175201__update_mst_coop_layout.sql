DELETE FROM mst_coop_layout
WHERE ctl_no IN (-6060001);

INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-6060001, 'C_hosp', 'exam_rst', '', 'S', 'cre', 'xml', 'CSI検査結果', 'MIRAIs', '検査結果', '1', '<coop_info>
  <facility_cd>$JOURNAL.facility_cd</facility_cd>
  <coop_cd>exam_rst</coop_cd>
  <crud>C</crud>
  <direction>S</direction>
  <coop_ord_no>$JOURNAL.coop_ord_no</coop_ord_no>
  <dump>
    <rootNode>
      <SYS_COOP_INI_DATA>
        <row _sqlCode="-610004">
          <INI_SECTION>dataset:-610004.ini_section</INI_SECTION>
          <INI_KEY>dataset:-610004.ini_key</INI_KEY>
          <INI_VALUE>dataset:-610004.ini_value</INI_VALUE>
        </row>
      </SYS_COOP_INI_DATA>
    </rootNode>
  </dump>
</coop_info>
', '{"dataset": [{"key0": "key0", "sqlCode": -610004, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'CSI');