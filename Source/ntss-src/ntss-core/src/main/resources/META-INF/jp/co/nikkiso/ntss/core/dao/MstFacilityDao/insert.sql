insert into mst_facility (
  facility_cd,
  facility_name,
  facility_name_kana,
  prefectures_cd,
  department_cd,
  m_notice_mail_template,
  auto_gathering_start_time,
  alive_moni_interval,
  certification_key,
  use_function,
  reg_date,
  up_date,
  sales_email_address,
  advanced_settings,
  vpn_set
  -- add 10378 by kangjie 20240522 start
  ,is_schext_exception
  -- add 10378 by kangjie 20240522 end
) values (
  /* mstFacility.facilityCd */NULL,
  /* mstFacility.facilityName */NULL,
  /* mstFacility.facilityNameKana */NULL,
  /* mstFacility.prefecturesCd */NULL,
  /* mstFacility.departmentCd */NULL,
  /* mstFacility.mNoticeMailTemplate */NULL,
  /* mstFacility.autoGatheringStartTime */NULL,
  /* mstFacility.aliveMoniInterval */NULL,
  /* mstFacility.certificationKey */NULL,
  /* mstFacility.useFunction */NULL,
  /* mstFacility.regDate */NULL,
  /* mstFacility.upDate */NULL,
  /* mstFacility.salesEmailAddress */NULL,
  /* mstFacility.advancedSettings */NULL,
  /* mstFacility.vpnSet */NULL
  -- add 10378 by kangjie 20240522 start
   /*%if mstFacility.isSchextException == null*/
   ,'0'
   /*%end */
   /*%if mstFacility.isSchextException != null*/
   ,/* mstFacility.isSchextException */'0'
   /*%end */
  -- add 10378 by kangjie 20240522 end
);
