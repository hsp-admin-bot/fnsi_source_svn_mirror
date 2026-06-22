insert into mst_pat_hash (
  facility_cd,
  hash_value,
  reg_date,
  up_date
) values (
  /* mstFacility.facilityCd */null,
  public.crypt(/* mstFacility.facilityCd */null || 'NtssPat'::text, public.gen_salt('bf'::text, 10)),
  /* mstFacility.regDate */null,
  /* mstFacility.upDate */null
);