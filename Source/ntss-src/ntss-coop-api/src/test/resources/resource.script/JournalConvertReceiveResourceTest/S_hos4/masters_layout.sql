DELETE FROM mst_coop_layout
WHERE facility_cd = 'S_hos4';

insert into mst_coop_layout (
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
) values ('S_hos4','ini_dial','','R','pre','xml     ','','','','1','
<SsiData Type="PAT_INF">
  <PatPersonalMain>
    <FnPatId>col:pat_personal_main.fn_pat_id</FnPatId>
    <HospPatId>col:pat_personal_main.hosp_pat_id</HospPatId>
    <NkkPatId>col:pat_personal_main.nkk_pat_id</NkkPatId>
    <FacilityCd>col:pat_personal_main.facility_cd</FacilityCd>
    <PatLastName>col:pat_personal_main.pat_last_name</PatLastName>
    <PatFirstName>col:pat_personal_main.pat_first_name</PatFirstName>
    <PatLastNameKana>col:pat_personal_main.pat_last_name_kana</PatLastNameKana>
    <PatFirstNameKana>col:pat_personal_main.pat_first_name_kana</PatFirstNameKana>
    <PatLastNameAlpha>col:pat_personal_main.pat_last_name_alpha</PatLastNameAlpha>
    <PatFirstNameAlpha>col:pat_personal_main.pat_first_name_alpha</PatFirstNameAlpha>
    <PatBirthName>col:pat_personal_main.pat_birth_name</PatBirthName>
    <PatBirthNameKana>col:pat_personal_main.pat_birth_name_kana</PatBirthNameKana>
    <PatBirthNameAlpha>col:pat_personal_main.pat_birth_name_alpha</PatBirthNameAlpha>
    <PatBirthday>col:pat_personal_main.pat_birthday</PatBirthday>
    <PatSex>col:pat_personal_main.pat_sex</PatSex>
    <Nationality>col:pat_personal_main.nationality</Nationality>
    <PatBloodTypeAbo>col:pat_personal_main.pat_blood_type_abo</PatBloodTypeAbo>
    <PatBloodTypeRh>col:pat_personal_main.pat_blood_type_rh</PatBloodTypeRh>
    <PatBloodTypeSerovar>col:pat_personal_main.pat_blood_type_serovar</PatBloodTypeSerovar>
    <InOutClass>col:pat_personal_main.in_out_class</InOutClass>
    <IsDie>col:pat_personal_main.is_die</IsDie>
    <SeverityCd>col:pat_personal_main.severity_cd</SeverityCd>
    <TransportCd>col:pat_personal_main.transport_cd</TransportCd>
    <PatContactInfo>
      <Fax>col:pat_personal_main.pat_contact_info.fax</Fax>
      <Tel1>col:pat_personal_main.pat_contact_info.tel1</Tel1>
      <Tel2>col:pat_personal_main.pat_contact_info.tel2</Tel2>
      <Memo1>col:pat_personal_main.pat_contact_info.memo1</Memo1>
      <Memo2>col:pat_personal_main.pat_contact_info.memo2</Memo2>
      <EMail>col:pat_personal_main.pat_contact_info.e_mail</EMail>
      <Address>col:pat_personal_main.pat_contact_info.address</Address>
      <WorkTel>col:pat_personal_main.pat_contact_info.work_tel</WorkTel>
      <WorkName>col:pat_personal_main.pat_contact_info.work_name</WorkName>
      <WorkAddress>col:pat_personal_main.pat_contact_info.work_address</WorkAddress>
    </PatContactInfo>
    <IsDel>col:pat_personal_main.is_del</IsDel>
    <PrimaryDiseaseCd>col:pat_personal_main.primary_disease_cd</PrimaryDiseaseCd>
    <RemoteMonitorService>col:pat_personal_main.remote_monitor_service</RemoteMonitorService>
    <RemoteMonitorUserId>col:pat_personal_main.remote_monitor_user_id</RemoteMonitorUserId>
    <RemoteMonitorUserPw>col:pat_personal_main.remote_monitor_user_pw</RemoteMonitorUserPw>
  </PatPersonalMain>
  <OrdMain>
    <OrdNo>col:ord_main.ord_no</OrdNo>
    <PatId>col:ord_main.pat_id</PatId>
    <FnPatId>col:ord_main.fn_pat_id</FnPatId>
    <TreatDate>col:ord_main.treat_date</TreatDate>
    <TreatWeek>col:ord_main.treat_week</TreatWeek>
    <facilityCd>col:ord_main.facility_cd</facilityCd>
    <FacilityName>col:ord_main.facility_name</FacilityName>
    <IndVaCd>col:ord_main.ind_va_cd</IndVaCd>
    <IndTreatmentCd>col:ord_main.ind_treatment_cd</IndTreatmentCd>
    <IndTreatmentName>col:ord_main.ind_treatment_name</IndTreatmentName>
    <IndKurCd>col:ord_main.ind_kur_cd</IndKurCd>
    <IndKurName>col:ord_main.ind_kur_name</IndKurName>
    <IndTreatStartTime>col:ord_main.ind_treat_start_time</IndTreatStartTime>
    <IndBedCd>col:ord_main.ind_bed_cd</IndBedCd>
    <IndBedName>col:ord_main.ind_bed_name</IndBedName>
    <IndScheduleUserInfo>col:ord_main.ind_schedule_user_info</IndScheduleUserInfo>
    <IndCondInfo>col:ord_main.ind_cond_info</IndCondInfo>
    <IndMediInfo>col:ord_main.ind_medi_info</IndMediInfo>
    <IndEquipInfo>col:ord_main.ind_equip_info</IndEquipInfo>
    <IndIndCommentInfo>col:ord_main.ind_ind_comment_info</IndIndCommentInfo>
    <IndTareInfo>col:ord_main.ind_tare_info</IndTareInfo>
    <IndOffWaterInfo>col:ord_main.ind_off_water_info</IndOffWaterInfo>
    <IndDeviceSetInfo>col:ord_main.ind_device_set_info</IndDeviceSetInfo>
    <IsDel>col:ord_main.is_del</IsDel>
  </OrdMain>
  <OrdCoopNo>
    <CoopNo>col:ord_coop_no.coop_cd</CoopNo>
  <OrdCoopNo>col:ord_coop_no.coop_ord_no</OrdCoopNo>
  </OrdCoopNo>
</SsiData>
  ','{}','1','0','4126','2019/12/13 5:44:54','2019/12/13 5:44:54');

