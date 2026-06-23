----------------------------------------------------------------------------
-- sync_mst_device_edgeの作製 2019.11.27 NKK青田
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
		INSERT INTO mnt_device_edge_state( facility_cd, device_edge_no, alive_moni_status, last_moni_time, reg_date, up_date ) VALUES( NEW.facility_cd, NEW.device_edge_no, 'F0', now(), now(), now() ) ;
	END IF ;
	RETURN NULL ; -- AFTERトリガーのため結果は無視する
EXCEPTION
	WHEN OTHERS THEN
		RAISE NOTICE '例外が発生しました。' ;
		RETURN NULL ;
END ;
$BODY$  LANGUAGE plpgsql VOLATILE COST 10 ;
CREATE TRIGGER tg_sync_mst_device_edge AFTER INSERT OR UPDATE OR DELETE ON mst_device_edge FOR EACH ROW EXECUTE PROCEDURE sync_mst_device_edge() ;
