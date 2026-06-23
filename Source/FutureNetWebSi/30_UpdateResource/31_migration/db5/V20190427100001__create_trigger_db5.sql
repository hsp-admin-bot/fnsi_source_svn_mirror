----------------------------------------------------------------------------
-- sync_mst_machineの修正 2019.04.24 NKK青田
----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS tg_sync_mst_machine ON mst_machine ;
DROP FUNCTION IF EXISTS sync_mst_machine() ;
CREATE OR REPLACE FUNCTION sync_mst_machine()
RETURNS trigger AS $BODY$
DECLARE
	mnt_machine_state_row_cnt	numeric ;				-- 装置状態管理テーブルの対象レコード件数
	mst_machine_type_model 		character varying(3) ;	-- 型式マスタのモデル
	mst_bed_cd					bigint ;				-- ベッドマスタのベッドコード
	mst_bed_name				character varying ;		-- ベッドマスタのベッド名
BEGIN
	-- 削除時処理
	IF (TG_OP = 'DELETE') THEN
		-- 装置マスタのレコード削除時は関連テーブルのレコードも削除
		DELETE FROM mnt_machine_state WHERE facility_cd = OLD.facility_cd AND machine_type_cd = OLD.machine_type_cd AND TRIM(machine_serial) = TRIM(OLD.machine_serial) ;
		UPDATE mst_bed SET machine_no = NULL WHERE machine_no = OLD.machine_no ;
	ELSIF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE') THEN
		SELECT model INTO mst_machine_type_model FROM mst_machine_type WHERE machine_type_cd = NEW.machine_type_cd ;
		SELECT bed_cd,bed_name  INTO mst_bed_cd, mst_bed_name FROM mst_bed WHERE machine_no = NEW.machine_no ;
		SELECT bed_name INTO mst_bed_name FROM mst_bed WHERE machine_no = NEW.machine_no ;
		-- 挿入時処理
		IF (TG_OP = 'INSERT') THEN
			-- 表示、有効データの挿入のみ関連データ登録する
			IF ('0' = NEW.is_del) AND ('1' = NEW.is_disp) THEN
				INSERT INTO mnt_machine_state( facility_cd, machine_type_cd, machine_serial, model, machine_name, bed_cd, bed_name, reg_date, up_date ) VALUES( NEW.facility_cd, NEW.machine_type_cd, NEW.machine_serial, mst_machine_type_model, NEW.machine_name, mst_bed_cd, mst_bed_name, now(), now() ) ;
			END IF ;
		-- 更新時処理
		ELSIF (TG_OP = 'UPDATE') THEN
			SELECT COUNT(*) INTO mnt_machine_state_row_cnt FROM mnt_machine_state WHERE facility_cd = OLD.facility_cd AND machine_type_cd = OLD.machine_type_cd AND TRIM(machine_serial) = TRIM(OLD.machine_serial) ;
			-- 非表示、削除によるレコード削除
			IF ('1' = NEW.is_del) OR ('0' = NEW.is_disp) THEN
				DELETE FROM mnt_machine_state WHERE facility_cd = OLD.facility_cd AND machine_type_cd = OLD.machine_type_cd AND TRIM(machine_serial) = TRIM(OLD.machine_serial) ;
				UPDATE mst_bed SET machine_no = NULL , up_date = now() WHERE machine_no = OLD.machine_no ;
			-- 表示、非削除データの更新
			ELSIF ('0' = NEW.is_del) AND ('1' = NEW.is_disp) THEN
				-- 新たに表示、非削除に変更したもの、既存データをカウント有無を確認してなければ挿入
				IF (0 = mnt_machine_state_row_cnt) THEN
					INSERT INTO mnt_machine_state( facility_cd, machine_type_cd, machine_serial, model, machine_name, bed_cd, bed_name, process_state, m_notice_cnt, preventive_mainte_cnt, is_preventive_mainte, machine_status, is_offline, reg_date, up_date ) VALUES( NEW.facility_cd, NEW.machine_type_cd, NEW.machine_serial, mst_machine_type_model, NEW.machine_name, mst_bed_cd, mst_bed_name, null, 0, 0, 0, 0, '0', now(), now() ) ;
				-- データが既に存在し更新対象データか判断する
				ELSIF (OLD.machine_type_cd <> NEW.machine_type_cd) OR (OLD.machine_serial <> NEW.machine_serial) OR (OLD.machine_name <> NEW.machine_name) THEN
					UPDATE mnt_machine_state SET machine_type_cd = NEW.machine_type_cd, machine_serial = NEW.machine_serial, model = mst_machine_type_model, machine_name = NEW.machine_name, up_date = NEW.up_date WHERE facility_cd = OLD.facility_cd AND machine_type_cd = OLD.machine_type_cd AND TRIM(machine_serial) = TRIM(OLD.machine_serial) ;
				END IF ;
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


----------------------------------------------------------------------------
-- sync_mst_bedの修正 2019.04.24 NKK青田
----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS tg_sync_mst_bed ON mst_bed ;
DROP FUNCTION IF EXISTS sync_mst_bed() ;
CREATE OR REPLACE FUNCTION sync_mst_bed()
RETURNS trigger AS $BODY$
DECLARE
	old_mst_machine_facility_cd	character varying(6) ;	-- 変更前装置マスタの施設コード
	old_mst_machine_type_cd		character varying(3) ;	-- 変更前装置マスタの型式コード
	old_mst_machine_serial		character varying(8) ;	-- 変更前装置マスタの製造番号
	new_mst_machine_facility_cd	character varying(6) ;	-- 変更後装置マスタの施設コード
	new_mst_machine_type_cd		character varying(3) ;	-- 変更後装置マスタの型式コード
	new_mst_machine_serial		character varying(8) ;	-- 変更後装置マスタの製造番号
	old_bed_cd					bigint ;				-- 変更前ベッドの装置の新しいベッドコード
	old_bed_name				character varying ;				-- 変更前ベッドの装置の新しいベッド名
	
BEGIN
	-- 削除用処理
	IF (TG_OP = 'DELETE') THEN
		-- 装置状態管理テーブルの装置名称をクリア
		UPDATE mnt_machine_state SET bed_cd = NULL, bed_name = NULL WHERE bed_cd = OLD.bed_cd ;
	ELSIF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE') THEN
		SELECT facility_cd, machine_type_cd, machine_serial INTO new_mst_machine_facility_cd, new_mst_machine_type_cd, new_mst_machine_serial FROM mst_machine WHERE machine_no = NEW.machine_no;
		-- 更新用処理(挿入用処理より先に処理する必要あり)
		IF (TG_OP = 'UPDATE') THEN
			SELECT facility_cd, machine_type_cd, machine_serial INTO old_mst_machine_facility_cd, old_mst_machine_type_cd, old_mst_machine_serial FROM mst_machine WHERE machine_no = OLD.machine_no;
			IF ('1' = NEW.is_del) OR ('0' = NEW.is_disp) THEN
				IF (NEW.machine_no IS NOT NULL) THEN
					UPDATE mst_bed SET machine_no = NULL WHERE bed_cd = NEW.bed_cd ;
					UPDATE mnt_machine_state SET bed_cd = NULL, bed_name = NULL WHERE facility_cd = old_mst_machine_facility_cd AND machine_type_cd = old_mst_machine_type_cd AND machine_serial = old_mst_machine_serial;
				END IF;
			ELSIF ('0' = NEW.is_del) AND ('1' = NEW.is_disp) THEN
			-- 装置の紐づけをなしにしたもの(先行で処理する必要あり)
				IF (COALESCE(OLD.machine_no,-1) <> COALESCE(NEW.machine_no,-1)) THEN
					SELECT bed_cd, bed_name INTO old_bed_cd, old_bed_name FROM mst_bed WHERE machine_no = OLD.machine_no;
					IF (NEW.machine_no IS NULL) THEN
						-- 元の紐づく装置の情報をクリア
						UPDATE mnt_machine_state SET bed_cd = old_bed_cd, bed_name = old_bed_name WHERE facility_cd = old_mst_machine_facility_cd AND machine_type_cd = old_mst_machine_type_cd AND machine_serial = old_mst_machine_serial;
					ELSIF (NEW.machine_no IS NOT NULL) THEN
						-- 新たに紐づけた装置の情報で更新
						UPDATE mnt_machine_state SET bed_cd = old_bed_cd, bed_name = old_bed_name WHERE facility_cd = old_mst_machine_facility_cd AND machine_type_cd = old_mst_machine_type_cd AND machine_serial = old_mst_machine_serial;
						UPDATE mnt_machine_state SET bed_cd = NEW.bed_cd, bed_name = NEW.bed_name WHERE facility_cd = new_mst_machine_facility_cd AND machine_type_cd = new_mst_machine_type_cd AND machine_serial = new_mst_machine_serial ;
					END IF;
				ELSIF (COALESCE(OLD.machine_no,-1) = COALESCE(NEW.machine_no,-1)) THEN
					IF (COALESCE(OLD.bed_name,'NULL') <> COALESCE(NEW.bed_name,'NULL')) THEN
						UPDATE mnt_machine_state SET bed_cd = NEW.bed_cd, bed_name = NEW.bed_name WHERE facility_cd = new_mst_machine_facility_cd AND machine_type_cd = new_mst_machine_type_cd AND machine_serial = new_mst_machine_serial ;
					END IF;
				END IF;
			END IF;
		-- 挿入用処理
		ELSIF (TG_OP = 'INSERT') THEN
			-- 行追加→無効データで登録
			IF ('1' = NEW.is_del) OR ('0' = NEW.is_disp) THEN
				IF (NEW.machine_no IS NOT NULL) THEN
					UPDATE mst_bed SET machine_no = NULL WHERE bed_cd = NEW.bed_cd ;
				END IF;
			-- 行追加→有効データで登録
			ELSIF ('0' = NEW.is_del) AND ('1' = NEW.is_disp) THEN
				UPDATE mnt_machine_state SET bed_cd = NEW.bed_cd, bed_name = NEW.bed_name WHERE facility_cd = new_mst_machine_facility_cd AND machine_type_cd = new_mst_machine_type_cd AND machine_serial = new_mst_machine_serial ;
			END IF ;
		END IF;
	END IF;
	RETURN NULL ; -- AFTERトリガーのため結果は無視する
EXCEPTION
	WHEN OTHERS THEN
		RAISE NOTICE '例外が発生しました。bed' ;
		RETURN NULL ;
END ;
$BODY$  LANGUAGE plpgsql VOLATILE COST 10 ;
CREATE TRIGGER tg_sync_mst_bed AFTER INSERT OR UPDATE OR DELETE ON mst_bed FOR EACH ROW EXECUTE PROCEDURE sync_mst_bed();


----------------------------------------------------------------------------
-- sync_mst_device_edgeの作製 2019.04.24 NKK青田
----------------------------------------------------------------------------
DROP TRIGGER IF EXISTS tg_sync_mst_device_edge ON mst_device_edge ;
DROP FUNCTION IF EXISTS sync_mst_device_edge() ;
CREATE OR REPLACE FUNCTION sync_mst_device_edge()
RETURNS trigger AS $BODY$
BEGIN
	-- 削除時処理
	IF (TG_OP = 'DELETE') THEN
		-- デバイスエッジマスタのレコード削除時は関連テーブルのレコードも削除
		DELETE FROM mnt_device_edge_state WHERE facility_cd = OLD.facility_cd AND device_edge_no = OLD.device_edge_no ;
	ELSIF (TG_OP = 'INSERT') THEN
		INSERT INTO mnt_device_edge_state( facility_cd, device_edge_no, alive_moni_status, last_moni_time, reg_date, up_date ) VALUES( NEW.facility_cd, NEW.device_edge_no, 'F01', now(), now(), now() ) ;
	END IF ;
	RETURN NULL ; -- AFTERトリガーのため結果は無視する
EXCEPTION
	WHEN OTHERS THEN
		RAISE NOTICE '例外が発生しました。' ;
		RETURN NULL ;
END ;
$BODY$  LANGUAGE plpgsql VOLATILE COST 10 ;
CREATE TRIGGER tg_sync_mst_device_edge AFTER INSERT OR UPDATE OR DELETE ON mst_device_edge FOR EACH ROW EXECUTE PROCEDURE sync_mst_device_edge() ;
