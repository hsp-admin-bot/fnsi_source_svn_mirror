insert into mst_facility_hash (
  facility_cd,
  hash_value,
  value,
  reg_date,
  up_date,
  system_use_setting
) values (
  /* mstFacilityHash.facilityCd */null,
  public.crypt(/* mstFacilityHash.facilityCd */null || 'Ntss'::text, public.gen_salt('bf'::text, 10)),
  /* mstFacilityHash.value */null,
  /* mstFacilityHash.regDate */null,
  /* mstFacilityHash.upDate */null,
  /* mstFacilityHash.systemUseSetting */null
);
