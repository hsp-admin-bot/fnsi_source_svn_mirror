----------------------------------------------------------------------------
-- 装置状態管理のレコード更新に従い、関連テーブルのレコードを更新する
----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS tg_sync_mnt_machine_state ON mnt_machine_state ;
DROP FUNCTION IF EXISTS sync_mnt_machine_state() ;
CREATE OR REPLACE FUNCTION sync_mnt_machine_state()
RETURNS trigger AS $BODY$
DECLARE
BEGIN
    -- 装置状態管理テーブル更新
    IF (TG_OP = 'UPDATE') THEN
        -- 工程状態に変更があった場合は更新処理を実施
        IF (OLD.process_state IS NULL) OR (OLD.process_state <> NEW.process_state) THEN
            -- 工程状態が「11:運転」の場合、透析開始日時に「現在日時」、透析終了日時に「null」を登録する
            IF ('11' = NEW.process_state) THEN
                UPDATE mnt_machine_state SET start_date = current_timestamp, end_date = null WHERE facility_cd = NEW.facility_cd AND machine_type_cd = NEW.machine_type_cd AND TRIM(machine_serial) = TRIM(NEW.machine_serial) ;
            -- 工程状態が「09:排液」の場合、透析終了日時に「現在日時」を登録する
            ELSIF ('09' = NEW.process_state) THEN
                UPDATE mnt_machine_state SET end_date = current_timestamp WHERE facility_cd = NEW.facility_cd AND machine_type_cd = NEW.machine_type_cd AND TRIM(machine_serial) = TRIM(NEW.machine_serial) ;
            END IF ;
        END IF ;
    END IF ;

    RETURN NULL ; -- AFTERトリガーのため結果は無視する

EXCEPTION
    WHEN OTHERS THEN
        RAISE NOTICE '例外が発生しました。' ;
        RETURN NULL ;
END ;
$BODY$  LANGUAGE plpgsql VOLATILE COST 10 ;
CREATE TRIGGER tg_sync_mnt_machine_state AFTER UPDATE ON mnt_machine_state FOR EACH ROW EXECUTE PROCEDURE sync_mnt_machine_state() ;

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
BEGIN
	-- 装置状態管理テーブル更新
	IF (TG_OP = 'UPDATE') THEN
		-- 装置動作記録テーブルの該当レコードのデータ種別が「緊急発報記録」の場合、緊急発報記録(未対処)レコード件数を算出
		IF (con_data_type_m_notice = NEW.data_type) THEN
			SELECT COUNT(*) INTO n_m_notice_cnt
			FROM mnt_motion_record
			WHERE facility_cd = NEW.facility_cd AND machine_type_cd = NEW.machine_type_cd AND TRIM(machine_serial) = TRIM(NEW.machine_serial) AND data_type = con_data_type_m_notice  AND (is_correction = con_no_correction OR is_correction IS NULL) ;
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

----------------------------------------------------------------------------
-- 装置マスタのレコード増減に従い、関連テーブルのレコードを増減する
----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS tg_sync_mst_machine ON mst_machine ;
DROP FUNCTION IF EXISTS sync_mst_machine() ;
CREATE OR REPLACE FUNCTION sync_mst_machine()
RETURNS trigger AS $BODY$
DECLARE
	mnt_machine_state_row_cnt	numeric ;	-- 装置状態管理テーブルの対象レコード件数
BEGIN
	-- 装置状態管理テーブル更新
	IF (TG_OP = 'DELETE') THEN
		-- 装置マスタのレコード削除時は関連テーブルのレコードも削除
		DELETE FROM mnt_machine_state WHERE facility_cd = OLD.facility_cd AND machine_type_cd = OLD.machine_type_cd AND TRIM(machine_serial) = TRIM(OLD.machine_serial) ;
	ELSIF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE') THEN
		-- 装置状態管理テーブルの該当レコード件数取得
		SELECT COUNT(*) INTO mnt_machine_state_row_cnt
		FROM mnt_machine_state
		WHERE facility_cd = NEW.facility_cd AND machine_type_cd = NEW.machine_type_cd AND TRIM(machine_serial) = TRIM(NEW.machine_serial) ;
		IF (TG_OP = 'INSERT') THEN
			-- 装置マスタのレコード追加時は関連テーブルのレコードを追加(既に登録されている場合は処理中断)
			IF (0 = mnt_machine_state_row_cnt) THEN
				INSERT INTO mnt_machine_state (facility_cd, machine_type_cd, machine_serial, machine_name, reg_date, up_date) VALUES(NEW.facility_cd, NEW.machine_type_cd, NEW.machine_serial, NEW.machine_name, NEW.reg_date, NEW.reg_date) ;
			END IF ;
		ELSIF (TG_OP = 'UPDATE') THEN
			-- 装置マスタのレコード更新時は関連テーブルのレコードを更新(登録されていない場合は追加処理を実施)
			IF (0 = mnt_machine_state_row_cnt) THEN
				INSERT INTO mnt_machine_state (facility_cd, machine_type_cd, machine_serial, machine_name, reg_date, up_date) VALUES(NEW.facility_cd, NEW.machine_type_cd, NEW.machine_serial, NEW.machine_name, NEW.up_date, NEW.up_date) ;
			-- 更新対象カラムのみを更新
			ELSIF (OLD.machine_name <> NEW.machine_name) THEN
				UPDATE mnt_machine_state SET machine_name = NEW.machine_name, up_date = NEW.up_date WHERE facility_cd = NEW.facility_cd AND machine_type_cd = NEW.machine_type_cd AND TRIM(machine_serial) = TRIM(NEW.machine_serial) ;
			END IF ;
		END IF ;
	END IF ;

	RETURN NULL ; -- AFTERトリガーのため結果は無視する

EXCEPTION
	WHEN OTHERS THEN
		RAISE NOTICE '例外が発生しました。' ;
		RETURN NULL ;
END ;
$BODY$  LANGUAGE plpgsql VOLATILE COST 10 ;
CREATE TRIGGER tg_sync_mst_machine AFTER INSERT OR UPDATE OR DELETE ON mst_machine FOR EACH ROW EXECUTE PROCEDURE sync_mst_machine() ;
