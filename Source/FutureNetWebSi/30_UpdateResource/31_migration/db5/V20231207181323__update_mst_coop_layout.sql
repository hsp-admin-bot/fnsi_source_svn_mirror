DELETE FROM
    ntss.mst_coop_layout
WHERE
    ctl_no = -1030002;

INSERT INTO
    ntss.mst_coop_layout (
        ctl_no,
        facility_cd,
        coop_cd,
        coop_cd_index,
        direction,
        coop_cd_sub,
        coop_format,
        coop_name,
        coop_vender,
        description,
        is_editable,
        coop_setting,
        coop_ext_setting,
        is_disp,
        is_del,
        user_id,
        reg_date,
        up_date,
        coop_version
    )
VALUES
    (
        -1030002,
        'nkknkk',
        'profile',
        '',
        'R',
        'all',
        'text',
        '日機装標準',
        'nikkiso',
        '患者情報（拡張）',
        '1',
        '<root name="患者情報(cre)" multi="true:CRLF/LFCR/CR/LF">
    <item  name="CRUD" len="0" col="$journal.const.crud" type="string" value="const:C"/>
    <item  name="患者コード" len="12" col="$journal.pat_personal_main.hosp_pat_id" type="string"/>
    <item  name="カナ氏名" len="40" col="$journal.pat_personal_main.pat_name_kana" type="string"/>
    <item  name="氏名" len="20" col="$journal.pat_personal_main.pat_name" type="string"/>
    <item  name="性別" len="1" col="$journal.pat_personal_main.pat_sex" type="string"/>
    <item  name="生年月日" len="8" col="$journal.pat_personal_main.pat_birthday" type="string"/>
    <item  name="郵便番号" len="8" col="$journal.pat_personal_main.pat_contact_info.zip_cd" type="string"/>
    <item  name="住所" len="120" col="$journal.pat_personal_main.pat_contact_info.address" type="string"/>
    <item  name="電話番号1" len="25" col="$journal.pat_personal_main.pat_contact_info.tel1" type="string"/>
    <item  name="電話番号2" len="25" col="$journal.pat_personal_main.pat_contact_info.tel2" type="string"/>
    <item  name="FAX番号" len="25" col="$journal.pat_personal_main.pat_contact_info.fax" type="string"/>
    <item  name="予備" len="228" type="string"/>
</root>',
        '{"dataset": {"sqlGroup1": [{"crud": "S", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "1", "sqlCode": 1101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "insertResult": "{@fnPatId:'''',@hospPatId:'''',@nkkPatId:'''',@facilityCd:'''',@patLastName:'''',@patFirstName:'''',@patLastNmKana:'''',@patFirstNmKana:'''',@patLastNmAlpha:'''',@patFirstNmAlpha:'''',@patBirthName:'''',@patBirthNmKana:'''',@patBirthNmAlpha:'''',@patBirthday:'''',@patSex:'''',@nationality:'''',@patBloodTypeAbo:'''',@patBloodTypeRh:'''',@patBloodTypeSerovar:'''',@inOutClass:'''',@isDie:'''',@dieCd:'''',@dieDate_Date:'''',@dialDiffComInfoValue:''[]'',@severityCd:'''',@transportCd:'''',@patContactInfoFlg:'''',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''[]'',@vendorContactInfoValue:''[]'',@insuranceInfoValue:''[]'',@primaryDiseaseCd:'''',@remoteMonitorService:'''',@remoteMonitorUserId:'''',@remoteMonitorUserPw:''''}", "updateResult": "{@fnPatId:''fn_pat_id'',@hospPatId:''hosp_pat_id'',@nkkPatId:''nkk_pat_id'',@facilityCd:''facility_cd'',@patLastName:''pat_last_name'',@patFirstName:''pat_first_name'',@patLastNmKana:''pat_last_name_kana'',@patFirstNmKana:''pat_first_name_kana'',@patLastNmAlpha:''pat_last_name_alpha'',@patFirstNmAlpha:''pat_first_name_alpha'',@patBirthName:''pat_birth_name'',@patBirthNmKana:''pat_birth_name_kana'',@patBirthNmAlpha:''pat_birth_name_alpha'',@patBirthday:''pat_birthday'',@patSex:''pat_sex'',@nationality:''nationality'',@patBloodTypeAbo:''pat_blood_type_abo'',@patBloodTypeRh:''pat_blood_type_rh'',@patBloodTypeSerovar:''pat_blood_type_serovar'',@inOutClass:''in_out_class'',@isDie:''is_die'',@dieCd:''die_cd'',@dieDate_Date:''die_date'',@dialDiffComInfoValue:''dial_diff_com_info'',@severityCd:''severity_cd'',@transportCd:''transport_cd'',@patContactInfoFlg:'''',@patContactInfoValue:''pat_contact_info'',@patContactInfo.zipCd:'''',@patContactInfo.address:'''',@patContactInfo.tel1:'''',@patContactInfo.tel2:'''',@patContactInfo.fax:'''',@patContactInfo.eMail:'''',@patContactInfo.workName:'''',@patContactInfo.workAddress:'''',@patContactInfo.workTel:'''',@patContactInfo.memo1:'''',@patContactInfo.memo2:'''',@otherContactInfoValue:''other_contact_info'',@vendorContactInfoValue:''vendor_contact_info'',@insuranceInfoValue:''insurance_info'',@regDate:''reg_date'',@primaryDiseaseCd:''primary_disease_cd'',@remoteMonitorService:''remote_monitor_service'',@remoteMonitorUserId:''remote_monitor_user_id'',@remoteMonitorUserPw:''remote_monitor_user_pw''}", "ExceptionMessage": "患者[@hospPatId]の個人情報に複数のデータが存在する。", "ExceptionCondition": "=N"}, {"crud": "C", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "2", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -403101, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.tel2": "$journal.pat_personal_main.pat_contact_info.tel2", "@patContactInfo.fax": "$journal.pat_personal_main.pat_contact_info.fax", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}, {"crud": "U", "kind": "0", "judge": "", "table": "pat_personal_main", "ctl_no": "3", "@patSex": "$journal.pat_personal_main.pat_sex", "sqlCode": -403201, "@hospPatId": "$journal.pat_personal_main.hosp_pat_id", "@patBirthday": "$journal.pat_personal_main.pat_birthday", "@patLastName": "$journal.pat_personal_main.pat_name", "@patFirstName": "$journal.pat_personal_main.pat_name", "@patLastNmKana": "$journal.pat_personal_main.pat_name_kana", "@patFirstNmKana": "$journal.pat_personal_main.pat_name_kana", "@patContactInfo.tel1": "$journal.pat_personal_main.pat_contact_info.tel1", "@patContactInfo.tel2": "$journal.pat_personal_main.pat_contact_info.tel2", "@patContactInfo.fax": "$journal.pat_personal_main.pat_contact_info.fax", "@patContactInfo.zipCd": "$journal.pat_personal_main.pat_contact_info.zip_cd", "@patContactInfo.address": "$journal.pat_personal_main.pat_contact_info.address"}]}, "CoopIniConvUtil": {"$journal.pat_personal_main.pat_sex": "CONV_SEX_TO_FNW", "$journal.pat_personal_main.in_out_class": "CONV_INOUT_TO_FNW", "$journal.pat_personal_main.pat_blood_type_rh": "CONV_BLOOD_RH_TO_FNW", "$journal.detail.pat_main_2.infect_info.infect": "CONV_INFECTION_TO_FNW", "$journal.pat_personal_main.pat_blood_type_abo": "CONV_BLOOD_ABO_TO_FNW"}}' :: jsonb,
        '1',
        '1',
        4,
        '2020-05-14 09:30:43.362',
        CURRENT_TIMESTAMP,
        ''
    );