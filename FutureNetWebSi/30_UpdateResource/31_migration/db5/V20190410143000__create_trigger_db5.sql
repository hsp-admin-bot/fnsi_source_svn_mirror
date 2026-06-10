----------------------------------------------------------------------------
-- 装置動作記録テーブルの更新に従い、関連テーブルを更新する
----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS tg_sync_mnt_motion_record ON mnt_motion_record ;
DROP FUNCTION IF EXISTS sync_mnt_motion_record() ;
CREATE OR REPLACE FUNCTION sync_mnt_motion_record()
RETURNS trigger AS $BODY$
DECLARE
	n_m_notice_cnt	numeric ;	-- 緊急発報件数
	n_preventive_mainte_cnt	numeric ;	-- 予防保守件数
	con_data_type_m_notice	CONSTANT	numeric := 2 ;	-- データ種別：緊急発報記録
	con_data_type_preventive_mainte	CONSTANT	numeric := 3 ;	-- データ種別：予防保全/故障予知記録
	con_no_correction	CONSTANT	varchar := '0' ;	-- 対処：未対処
	con_responding	CONSTANT	varchar := '2' ;	-- 対処：対応中
BEGIN
	-- 装置状態管理テーブル更新
	IF (TG_OP = 'UPDATE') THEN
		-- 装置動作記録テーブルの該当レコードのデータ種別が「緊急発報記録」の場合、緊急発報記録(未対処)レコード件数を算出
		IF (con_data_type_m_notice = NEW.data_type) THEN
			SELECT COUNT(*) INTO n_m_notice_cnt
			FROM mnt_motion_record
			WHERE facility_cd = NEW.facility_cd AND machine_type_cd = NEW.machine_type_cd AND TRIM(machine_serial) = TRIM(NEW.machine_serial) AND data_type = con_data_type_m_notice  AND (is_correction = con_no_correction OR is_correction = con_responding OR is_correction IS NULL) ;
			-- 装置状態管理テーブルに緊急発報件数を反映
			UPDATE mnt_machine_state SET m_notice_cnt = n_m_notice_cnt, up_date = NEW.up_date WHERE facility_cd = NEW.facility_cd AND machine_type_cd = NEW.machine_type_cd AND TRIM(machine_serial) = TRIM(NEW.machine_serial) ;
		END IF ;
		-- 装置動作記録テーブルの該当レコードのデータ種別が「予防保全/故障予知記録」の場合、予防保全/故障予知記録(未対処)レコード件数を算出
		IF (con_data_type_preventive_mainte = NEW.data_type) THEN
			SELECT COUNT(*) INTO n_preventive_mainte_cnt
			FROM mnt_motion_record
			WHERE facility_cd = NEW.facility_cd AND machine_type_cd = NEW.machine_type_cd AND TRIM(machine_serial) = TRIM(NEW.machine_serial) AND data_type = con_data_type_preventive_mainte  AND (is_correction = con_no_correction OR is_correction IS NULL) ;
			-- 装置状態管理テーブルに予防保守件数を反映
			UPDATE mnt_machine_state SET preventive_mainte_cnt = n_preventive_mainte_cnt, up_date = NEW.up_date WHERE facility_cd = NEW.facility_cd AND machine_type_cd = NEW.machine_type_cd AND TRIM(machine_serial) = TRIM(NEW.machine_serial) ;
		END IF ;
	END IF ;

	RETURN NULL ; -- AFTERトリガーのため結果は無視する

EXCEPTION
	WHEN OTHERS THEN
		RAISE NOTICE '例外が発生しました。' ;
		RETURN NULL ;
END ;
$BODY$  LANGUAGE plpgsql VOLATILE COST 10 ;
CREATE TRIGGER tg_sync_mnt_motion_record AFTER UPDATE ON mnt_motion_record FOR EACH ROW EXECUTE PROCEDURE sync_mnt_motion_record() ;
