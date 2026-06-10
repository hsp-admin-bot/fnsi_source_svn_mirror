with selector as (
	with query1 as (
	  select
      (jsonb_array_elements(order_settings->'items')->'code'->>0)::numeric as code,
      jsonb_array_elements(order_settings->'items')->'name'->>0 as name
	  from
	    mst_selector
	  where
	    master_physical_name = 'mst_bed'
	    and
	    facility_cd=/*facilityCd*/0
	)
	select
	    row_number() over(),
	    *
	from
	  query1
	order by
	  row_number
)
          select
            bed.bed_cd,
            bed.bed_name,
            bed.shunt_position,
            bed.is_infection,
            mac.is_disable,
            mac.is_support_hd,
            mac.is_support_ecum,
            mac.is_support_hdf,
            mac.is_support_hf,
            mac.is_support_hd_ho,
            mac.is_support_ecum_ho,
            mac.is_support_afbf,
            mac.is_support_ohdf,
            mac.is_support_ohf,
            mac.is_support_i_hdf,
            mac.is_support_blood_purify
          from
             mst_bed bed,mst_machine mac,selector sel
          where
             bed.facility_cd = /*facilityCd*/0
             and
             bed.machine_no = mac.machine_no
             and
             bed.facility_cd = mac.facility_cd
						  and
						  bed.is_disp = '1'
						  and
						  bed.is_del = '0'
						  and
						  bed.bed_cd = sel.code
          order by
             sel.row_number
           ;
