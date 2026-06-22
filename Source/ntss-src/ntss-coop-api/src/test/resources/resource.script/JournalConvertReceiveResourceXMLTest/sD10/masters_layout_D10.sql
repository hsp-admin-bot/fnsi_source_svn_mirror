DELETE FROM mst_coop_layout
WHERE facility_cd = 'F_hD10';

insert into ntss.mst_coop_layout (
  facility_cd
  , coop_cd
  , coop_cd_index
  , direction
  , coop_cd_sub
  , coop_format
  , coop_name
  , coop_vender
  , description
  , is_editable
  , coop_setting
  , coop_ext_setting
  , is_disp
  , is_del
  , user_id
  , reg_date
  , up_date
) values ('F_hD10','pat_inf','','R','pre','xml','SSI_患者属性連携','Egmain-GX','テスト用','1','
<SsiData Type="PAT_INF"><!-- 患者属性情報 -->
  <PatientData><!-- 患者情報 -->
    <PatientID>col:pat_personal_main.hosp_pat_id</PatientID>
    <PatientName>col:pat_personal_main.pat_last_name</PatientName>
    <PatientKanaName>col:pat_personal_main.pat_last_name_kana</PatientKanaName>
    <PatinentSex>col:pat_personal_main.pat_sex,json:sex</PatinentSex>
    <PatientBirthDay>col:pat_personal_main.pat_birthday</PatientBirthDay>

    <PatientEtcInfo><!-- 患者付属情報 -->
      <PatientBloodTypeABO>col:pat_personal_main.pat_blood_type_abo,json:blood-ABO</PatientBloodTypeABO>
      <PatientBloodTypeRH>col:pat_personal_main.pat_blood_type_rh,json:blood-Rh</PatientBloodTypeRH>
      <PostNumber>col:pat_personal_main.pat_contact_info.zip_cd</PostNumber>
      <Address>col:pat_personal_main.pat_contact_info.address</Address>
      <Tel>col:pat_personal_main.pat_contact_info.tel1,const:XXX-XXX-XXXX</Tel>
      <Comment>col:pat_main.pat_memo_info.content</Comment>
    </PatientEtcInfo>

    <PatientDIALYSISInfo><!-- 患者透析情報 -->
      <DIALYSISStartYMD></DIALYSISStartYMD>
      <GENSIKKAN Code="col:pat_personal_main.primary_disease_cd"></GENSIKKAN>
      <GENSIKKANYMD></GENSIKKANYMD>
      <TENKI></TENKI>
      <TENKIYMD></TENKIYMD>
      <DIEDOF Code="col:pat_personal_main.die_cd"></DIEDOF>
      <DOUNYU></DOUNYU><!-- 導入院所; 連携対象外 -->
      <SYOKAI></SYOKAI><!-- 紹介院所; 連携対象外 -->
      <Ctr></Ctr>
      <CTR_UPDATE></CTR_UPDATE>
      <Doctor Code="col:pat_main.charge_staff_info.staff_cd"></Doctor>
      <DialysisDoctor Code="col:pat_main.charge_staff_info.dial_doctor_cd"></DialysisDoctor>
      <DialysisNurse Code="col:pat_main.charge_staff_info.dial_nurse_cd"></DialysisNurse>
    </PatientDIALYSISInfo>

    <AdmissionInfo><!-- 入院情報 -->
      <AdmissionStatus></AdmissionStatus>
      <Ward Code=""></Ward>
      <InRoom Code=""></InRoom><!-- 連携対象外 -->
      <Bed Code=""></Bed><!-- 連携対象外 -->
      <AdmissionDate></AdmissionDate><!-- 連携対象外 -->
      <DischargeDate></DischargeDate><!-- 連携対象外 -->
      <AdmissionSnk Code=""></AdmissionSnk>
      <AdmissionDoctor Code=""></AdmissionDoctor>
    </AdmissionInfo>

    <InsuranceInfo><!-- 主保険情報 -->
      <InsuranceNumber></InsuranceNumber>
      <InsuranceDivision></InsuranceDivision>
      <InsuredSign></InsuredSign>
      <InsuredNumber></InsuredNumber>
    </InsuranceInfo>

    <InfectionInfo><!-- 感染症情報 -->
      <Infection Code="col:pat_main.infect_info.infection_cd">
        <Status>col:pat_main.infect_info.infect</Status>
        <Comment></Comment><!-- 連携対象外 -->
        <Date>col:pat_main.infect_info.exam_date</Date>
      </Infection>
    </InfectionInfo>

    <AllergyInfo><!-- アレルギー情報 -->
      <Allergy Code="col:pat_main.taboo_allergy_info.taboo_allergy_cd">
        <Status>col:pat_main.taboo_allergy_info.taboo_allergy_class</Status>
        <Comment>col:pat_main.taboo_allergy_info.comment</Comment>
        <Date></Date><!-- 連携対象外 -->
      </Allergy>
    </AllergyInfo>

    <DrugAllergyInfo><!-- 薬剤アレルギー情報 -->
      <Drug Code="col:pat_main.taboo_allergy_info.drug_allergy_cd">
        <Status>col:pat_main.taboo_allergy_info.drug_allergy_status</Status>
        <Comment>col:pat_main.taboo_allergy_info.drug_allergy_comment</Comment>
      </Drug>
    </DrugAllergyInfo>
  </PatientData>
</SsiData>
','{"json-key": {"sex": {"M":"1", "F":"2", "O":"0"}, "blood-ABO":{"0":"1", "1":"2", "2":"3", "3":"4", "4":"5"}, "blood-Rh":{"0":"1", "1":"2"} }}',
'1','0','4126','2020/05/07 12:00:00','2020/05/07 12:00:00');
