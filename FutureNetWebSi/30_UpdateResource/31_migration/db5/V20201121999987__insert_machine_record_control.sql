-- 施設設定No1051～1058の設定を元に mst_machine_record_control にレコードを追加します。
-- 施設設定No1051～1058の設定は、続くマイグレーションで削除されます。

INSERT INTO mst_machine_record_control
SELECT
  mfs.facility_cd,
  'AF90' AS machine_record_cd,
  mfs.value AS machine_record_message,
  '0' AS disp_flg,
  now() AS reg_date,
  now() AS up_date
FROM
  mst_facility_setting mfs
WHERE
  mfs.facility_setting_no = '1051'
AND
  NOT EXISTS (
    SELECT
      mmrc.facility_cd,
      mmrc.machine_record_cd
    FROM
      mst_machine_record_control mmrc
    WHERE
      mmrc.facility_cd = mfs.facility_cd
    AND
      mmrc.machine_record_cd = 'AF90'
  )
;

INSERT INTO mst_machine_record_control
SELECT
  mfs.facility_cd,
  'AF91' AS machine_record_cd,
  mfs.value AS machine_record_message,
  '0' AS disp_flg,
  now() AS reg_date,
  now() AS up_date
FROM
  mst_facility_setting mfs
WHERE
  mfs.facility_setting_no = '1052'
AND
  NOT EXISTS (
    SELECT
      mmrc.facility_cd,
      mmrc.machine_record_cd
    FROM
      mst_machine_record_control mmrc
    WHERE
      mmrc.facility_cd = mfs.facility_cd
    AND
      mmrc.machine_record_cd = 'AF91'
  )
;

INSERT INTO mst_machine_record_control
SELECT
  mfs.facility_cd,
  'AF92' AS machine_record_cd,
  mfs.value AS machine_record_message,
  '0' AS disp_flg,
  now() AS reg_date,
  now() AS up_date
FROM
  mst_facility_setting mfs
WHERE
  mfs.facility_setting_no = '1053'
AND
  NOT EXISTS (
    SELECT
      mmrc.facility_cd,
      mmrc.machine_record_cd
    FROM
      mst_machine_record_control mmrc
    WHERE
      mmrc.facility_cd = mfs.facility_cd
    AND
      mmrc.machine_record_cd = 'AF92'
  )
;

INSERT INTO mst_machine_record_control
SELECT
  mfs.facility_cd,
  'AF93' AS machine_record_cd,
  mfs.value AS machine_record_message,
  '0' AS disp_flg,
  now() AS reg_date,
  now() AS up_date
FROM
  mst_facility_setting mfs
WHERE
  mfs.facility_setting_no = '1054'
AND
  NOT EXISTS (
    SELECT
      mmrc.facility_cd,
      mmrc.machine_record_cd
    FROM
      mst_machine_record_control mmrc
    WHERE
      mmrc.facility_cd = mfs.facility_cd
    AND
      mmrc.machine_record_cd = 'AF93'
  )
;

INSERT INTO mst_machine_record_control
SELECT
  mfs.facility_cd,
  'AF94' AS machine_record_cd,
  mfs.value AS machine_record_message,
  '0' AS disp_flg,
  now() AS reg_date,
  now() AS up_date
FROM
  mst_facility_setting mfs
WHERE
  mfs.facility_setting_no = '1055'
AND
  NOT EXISTS (
    SELECT
      mmrc.facility_cd,
      mmrc.machine_record_cd
    FROM
      mst_machine_record_control mmrc
    WHERE
      mmrc.facility_cd = mfs.facility_cd
    AND
      mmrc.machine_record_cd = 'AF94'
  )
;

INSERT INTO mst_machine_record_control
SELECT
  mfs.facility_cd,
  'AF95' AS machine_record_cd,
  mfs.value AS machine_record_message,
  '0' AS disp_flg,
  now() AS reg_date,
  now() AS up_date
FROM
  mst_facility_setting mfs
WHERE
  mfs.facility_setting_no = '1056'
AND
  NOT EXISTS (
    SELECT
      mmrc.facility_cd,
      mmrc.machine_record_cd
    FROM
      mst_machine_record_control mmrc
    WHERE
      mmrc.facility_cd = mfs.facility_cd
    AND
      mmrc.machine_record_cd = 'AF95'
  )
;

INSERT INTO mst_machine_record_control
SELECT
  mfs.facility_cd,
  'AF96' AS machine_record_cd,
  mfs.value AS machine_record_message,
  '0' AS disp_flg,
  now() AS reg_date,
  now() AS up_date
FROM
  mst_facility_setting mfs
WHERE
  mfs.facility_setting_no = '1057'
AND
  NOT EXISTS (
    SELECT
      mmrc.facility_cd,
      mmrc.machine_record_cd
    FROM
      mst_machine_record_control mmrc
    WHERE
      mmrc.facility_cd = mfs.facility_cd
    AND
      mmrc.machine_record_cd = 'AF96'
  )
;

INSERT INTO mst_machine_record_control
SELECT
  mfs.facility_cd,
  'AF97' AS machine_record_cd,
  mfs.value AS machine_record_message,
  '0' AS disp_flg,
  now() AS reg_date,
  now() AS up_date
FROM
  mst_facility_setting mfs
WHERE
  mfs.facility_setting_no = '1058'
AND
  NOT EXISTS (
    SELECT
      mmrc.facility_cd,
      mmrc.machine_record_cd
    FROM
      mst_machine_record_control mmrc
    WHERE
      mmrc.facility_cd = mfs.facility_cd
    AND
      mmrc.machine_record_cd = 'AF97'
  )
;
