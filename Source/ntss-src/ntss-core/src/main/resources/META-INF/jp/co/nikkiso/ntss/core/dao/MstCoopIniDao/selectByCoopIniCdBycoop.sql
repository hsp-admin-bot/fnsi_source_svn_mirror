  select value from (
 SELECT
 'ind_dial' as coop,
  COALESCE ( NULLIF ( info ->> 'value', '' ), info ->> 'default_v' ) AS
 VALUE

 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
 WHERE
  facility_cd = /* facilityCd */'999999'

  AND is_del = '0'
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>'key0','')= /* key0 */''

-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND (info ->> 'key1' = 'FJI_COM_INFO'
	 and info ->> 'key2' = 'SCH_USER_NO_SETTING')
 union all
  SELECT
 'rst_dial/repdial' as coop,
  COALESCE ( NULLIF ( info ->> 'value', '' ), info ->> 'default_v' ) AS
 VALUE

 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
 WHERE
  facility_cd = /* facilityCd */'999999'
  AND is_del = '0'
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>'key0','')= /* key0 */''

-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND (info ->> 'key1' = 'FJI_COM_INFO'
	 and info ->> 'key2' = 'DIAL_USER_NO_SETTING')
	  union all
  SELECT
 'exam_ord' as coop,
  COALESCE ( NULLIF ( info ->> 'value', '' ), info ->> 'default_v' ) AS
 VALUE

 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
 WHERE
  facility_cd = /* facilityCd */'999999'

  AND is_del = '0'
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>'key0','')= /* key0 */''

-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND (info ->> 'key1' = 'FJI_COM_INFO'
	 and info ->> 'key2' = 'EXAM_USER_NO_SETTING')
	  union all
  SELECT
 'rad_ord' as coop,
  COALESCE ( NULLIF ( info ->> 'value', '' ), info ->> 'default_v' ) AS
 VALUE

 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
 WHERE
  facility_cd = /* facilityCd */'999999'

  AND is_del = '0'
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>'key0','')= /* key0 */''

-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND (info ->> 'key1' = 'FJI_COM_INFO'
  AND info ->> 'key2' = 'EXAM_USER_NO_SETTING')
   union all
 SELECT
 'ind_dial' as coop,
  COALESCE ( NULLIF ( info ->> 'value', '' ), info ->> 'default_v' ) AS
 VALUE

 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
 WHERE
  facility_cd = /* facilityCd */'999999'

  AND is_del = '0'
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>'key0','')= /* key0 */''

-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND (info ->> 'key1' = 'DIALYSISSCHESEND'
	 and info ->> 'key2' = 'DOCTOR_SELECT_MODE')
	 	 union all
 SELECT
 'rst_dial' as coop,
  COALESCE ( NULLIF ( info ->> 'value', '' ), info ->> 'default_v' ) AS
 VALUE

 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
 WHERE
  facility_cd = /* facilityCd */'999999'

  AND is_del = '0'
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>'key0','')= /* key0 */''

-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND (info ->> 'key1' = 'DIALYSISSEND'
	 and info ->> 'key2' = 'DOCTOR_TYPE')

	  	 union all
 SELECT
 'exam_ord' as coop,
  COALESCE ( NULLIF ( info ->> 'value', '' ), info ->> 'default_v' ) AS
 VALUE

 FROM
  mst_coop_ini AS ini
  CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
 WHERE
  facility_cd = /* facilityCd */'999999'

  AND is_del = '0'
	-- add #7304 異なる連携の機能を組み合わせて使用するため ljg start
		AND COALESCE(info->>'key0','')= /* key0 */''

-- add #7304 異なる連携の機能を組み合わせて使用するため ljg end
  AND (info ->> 'key1' = 'EXAMSCHESEND'
  AND info ->> 'key2' = 'DOCTOR_SELECT_MODE')
	 ) as aa where  coop = /* coopcd */''
