update sys_facility
set
  facility_cd =   /* sysFacility.facilityCd */null,
  prefectures_cd =   /* sysFacility.prefecturesCd */null,
  facility_name =   /* sysFacility.facilityName */null,
  facility_short_name =   /* sysFacility.facilityShortName */null,
  jsdt_facility_cd =   /* sysFacility.jsdtFacilityCd */null,
  medical_institution_cd =   /* sysFacility.medicalInstitutionCd */null,
  zipcd =   /* sysFacility.zipcd */null,
  address =   /* sysFacility.address */null,
  address_kana =   /* sysFacility.addressKana */null,
  phone_no1 =   /* sysFacility.phoneNo1 */null,
  phone_no2 =   /* sysFacility.phoneNo2 */null,
  fax_no1 =   /* sysFacility.faxNo1 */null,
  fax_no2 =   /* sysFacility.faxNo2 */null,
  up_date = /* sysFacility.upDate */null
where
  medical_institution_cd = /* sysFacility.medicalInstitutionCd */NULL
;