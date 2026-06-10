update mst_facility
set
  facility_name = /* mstFacility.facilityName */NULL,
  facility_name_kana = /* mstFacility.facilityNameKana */NULL,
  prefectures_cd = /* mstFacility.prefecturesCd */NULL,
  department_cd = /* mstFacility.departmentCd */NULL,
  m_notice_mail_template = /* mstFacility.mNoticeMailTemplate */NULL,
  auto_gathering_start_time = /* mstFacility.autoGatheringStartTime */NULL,
  alive_moni_interval = /* mstFacility.aliveMoniInterval */NULL,
  certification_key = /* mstFacility.certificationKey */NULL,
  use_function = /* mstFacility.useFunction */NULL,
  up_date = /*mstFacility.upDate*/NULL,
  advanced_settings = /* mstFacility.advancedSettings */NULL,
  sales_email_address = /*mstFacility.salesEmailAddress*/NULL,
  vpn_set = /*mstFacility.vpnSet*/NULL
  --//#10438 del 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる 卓 2024-04-25 start
  --/*%if mstFacility.systemUseSetting != null*/
  --,system_use_setting = /*mstFacility.systemUseSetting*/NULL
  --/*%end */
  --//#10438 del 施設マスタのシステム利用設定がすべてReMSへ勝手に変わる 卓 2024-04-25 end
  -- add 10378 by kangjie 20240522 start
    ,is_schext_exception = /*mstFacility.isSchextException*/NULL
  -- add 10378 by kangjie 20240522 end
where
  facility_cd = /* mstFacility.facilityCd */NULL
;
