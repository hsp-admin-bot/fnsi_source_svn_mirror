----------------------------------------------------------------------------
-- 【概要】
--      装置動作記録テーブルの更新に従い、関連テーブルを更新する
--
-- 【管理番号】
--      DB変更NO ：794,795
--      DBVERSION：1.0.0.0
--
-- 【変更履歴】
--      初期作成                                2018/12/21
--      #2876 新ステータス追加                   2020/06/08 K.TAKAHARA
--
-- 【備考】
--
--------------------------------------------------------------------------------
----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS tg_sync_mnt_motion_record ON mnt_motion_record ;
DROP FUNCTION IF EXISTS sync_mnt_motion_record() ;
CREATE OR REPLACE FUNCTION sync_mnt_motion_record()
RETURNS trigger AS $BODY$
DECLARE
	n_m_notice_cnt	numeric ;	-- 緊急発報件数
	n_preventive_mainte_cnt	numeric ;	-- 予防保守件数
	n_service_support_cnt	numeric ;	-- サービス対応件数
	con_data_type_m_notice	CONSTANT	numeric := 2 ;	-- データ種別：緊急発報記録
	con_data_type_preventive_mainte	CONSTANT	numeric := 3 ;	-- データ種別：予防保全/故障予知記録
	con_no_correction	CONSTANT	varchar := '0' ;	-- 対処：未対処
	con_responding	CONSTANT	varchar := '2' ;	-- 対処：対応中
	-- サービス対応種別
	con_ss_not_accepted	CONSTANT	varchar := '0';	-- 未受付
	con_ss_primary_supported	CONSTANT	varchar := '1';	-- 1次対応済
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
		-- 緊急発報件数及び予防保守件数を合算した件数をサービス対応件数に書込む
		IF (con_data_type_m_notice = NEW.data_type OR con_data_type_preventive_mainte = NEW.data_type) THEN
		  SELECT COUNT(*) INTO n_service_support_cnt
		  FROM mnt_motion_record
		  WHERE
		    facility_cd = NEW.facility_cd AND
		    machine_type_cd = NEW.machine_type_cd AND
		    TRIM(machine_serial) = TRIM(NEW.machine_serial) AND
		    (data_type = con_data_type_m_notice OR data_type = con_data_type_preventive_mainte)  AND
		    (service_support_type = con_ss_not_accepted OR service_support_type = con_ss_primary_supported OR service_support_type IS NULL);
		  -- 算出した件数を装置状態管理テーブルのサポート対応件数に反映する.
		  update
		    mnt_machine_state
		   SET
		    service_support_cnt = n_service_support_cnt,
		    up_date = NEW.up_date
		   WHERE
		    facility_cd = NEW.facility_cd AND
		    machine_type_cd = NEW.machine_type_cd AND
		    TRIM(machine_serial) = TRIM(NEW.machine_serial);
		END IF;
	END IF ;

	RETURN NULL ; -- AFTERトリガーのため結果は無視する

EXCEPTION
	WHEN OTHERS THEN
		RAISE NOTICE '例外が発生しました。' ;
		RETURN NULL ;
END ;
$BODY$  LANGUAGE plpgsql VOLATILE COST 10 ;
CREATE TRIGGER tg_sync_mnt_motion_record AFTER UPDATE ON mnt_motion_record FOR EACH ROW EXECUTE PROCEDURE sync_mnt_motion_record() ;
