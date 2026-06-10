DELETE FROM ntss.mst_coop_layout
WHERE ctl_no IN (-6010001)
;

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-6010001, 'C_hosp', 'profile', '', 'S', 'cre', 'xml', 'CSI患者プロファイル', 'MIRAIs', '患者プロファイル', '1', '<coop_info>
    <facility_cd>$JOURNAL.facility_cd</facility_cd>
    <coop_cd>profile</coop_cd>
    <crud>C</crud>
    <direction>S</direction>
    <hosp_pat_id>$JOURNAL.hosp_pat_id</hosp_pat_id>
    <coop_ord_no>$JOURNAL.coop_ord_no</coop_ord_no>
    <dump>
        <rootNode>
            <PAT_BASIC_INFO>
                <PATID></PATID>
                <NAME></NAME>
                <INFECT></INFECT>
                <DIE_FLG></DIE_FLG>
            </PAT_BASIC_INFO>
            <PAT_CONTACT>
                <CTL_NO></CTL_NO>
                <DISP_NO></DISP_NO>
            </PAT_CONTACT>
            <SYS_COOP_INI_DATA>
                <row _sqlCode="-610004">
                    <INI_SECTION>dataset:-610004.ini_section</INI_SECTION>
                    <INI_KEY>dataset:-610004.ini_key</INI_KEY>
                    <INI_VALUE>dataset:-610004.ini_value</INI_VALUE>
                </row>
            </SYS_COOP_INI_DATA>
              </rootNode>
   </dump>
</coop_info>', '{"dataset": [{"sqlCode": -610004, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, '2023-09-28 13:12:37.521', CURRENT_TIMESTAMP, '');