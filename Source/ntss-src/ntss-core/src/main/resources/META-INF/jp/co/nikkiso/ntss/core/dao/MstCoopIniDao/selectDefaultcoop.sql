
				 (SELECT
  COALESCE(NULLIF(info ->> 'value', ''), info ->> 'default_v') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = /* facilityCd */'999999'
    AND is_del = '0'
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>'key0','') = /* key0 */''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> 'key1' = 'FJI_COM_INFO'
    AND info ->> 'key2' = 'SCH_DEFAULT_USER_NO'
		and /* coopcd */'' = 'ind_dial'
		and 'GX' = /* key0 */''
		)
		union all
						 (SELECT
  COALESCE(NULLIF(info ->> 'value', ''), info ->> 'default_v') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = /* facilityCd */'999999'
    AND is_del = '0'
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>'key0','') = /* key0 */''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> 'key1' = 'FJI_COM_INFO'
    AND info ->> 'key2' = 'DIAL_DEFAULT_USER_NO'
		and ('rst_dial/repdial'=/* coopcd */'')
		and 'GX' = /* key0 */''
		)
		union all
						 (SELECT
  COALESCE(NULLIF(info ->> 'value', ''), info ->> 'default_v') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = /* facilityCd */'999999'
    AND is_del = '0'
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>'key0','') = /* key0 */''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> 'key1' = 'FJI_COM_INFO'
    AND info ->> 'key2' = 'EXAM_DEFAULT_USER_NO'
		AND /* coopcd */'' = 'exam_ord'
		and 'GX' = /* key0 */''
		 )
		union all
						 (SELECT
  COALESCE(NULLIF(info ->> 'value', ''), info ->> 'default_v') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = /* facilityCd */'999999'
    AND is_del = '0'
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>'key0','') = /* key0 */''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> 'key1' = 'FJI_COM_INFO'
    AND info ->> 'key2' = 'EXAM_DEFAULT_USER_NO'
		and /* coopcd */'' = 'rad_ord'
		and 'GX' = /* key0 */''
		)
		union all
						 (SELECT
  COALESCE(NULLIF(info ->> 'value', ''), info ->> 'default_v') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = /* facilityCd */'999999'
    AND is_del = '0'
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>'key0','') = /* key0 */''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> 'key1' = 'DIALYSISSCHESEND'
    AND info ->> 'key2' = 'DEFAULT_DOCTOR'
	AND /* coopcd */'' = 'ind_dial'
	AND 'NKK' = /* key0 */''
		)
		union all
						 (SELECT
  COALESCE(NULLIF(info ->> 'value', ''), info ->> 'default_v') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = /* facilityCd */'999999'
    AND is_del = '0'
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>'key0','') = /* key0 */''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> 'key1' = 'DIALYSISSEND'
    AND info ->> 'key2' = 'DOCTOR_DEF'
	AND /* coopcd */'' = 'rst_dial'
	AND 'NKK' = /* key0 */''
		)
			union all
						 (SELECT
  COALESCE(NULLIF(info ->> 'value', ''), info ->> 'default_v') AS staff_cd
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info
  WHERE
    facility_cd = /* facilityCd */'999999'
    AND is_del = '0'
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 start
    AND COALESCE(info->>'key0','') = /* key0 */''
    -- add #7304 異なる連携の機能を組み合わせて使用するため 黄小龍 end
    AND info ->> 'key1' = 'EXAMSCHESEND'
    AND info ->> 'key2' = 'DOCTOR_DEF'
	AND /* coopcd */'' = 'exam_ord'
	AND 'NKK' = /* key0 */''
		)