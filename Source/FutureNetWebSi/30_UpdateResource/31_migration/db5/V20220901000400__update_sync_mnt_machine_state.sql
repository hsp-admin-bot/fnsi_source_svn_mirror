CREATE OR REPLACE FUNCTION "ntss"."sync_mnt_machine_state"()
  RETURNS "pg_catalog"."trigger" AS $BODY$
DECLARE
BEGIN
    -- 装置状態管理テーブル更新
    IF (TG_OP = 'UPDATE') THEN
        -- 工程状態に変更があった場合は更新処理を実施
        IF (OLD.process_state IS NULL) OR (OLD.process_state <> NEW.process_state) THEN
            -- 工程状態が「11:運転」の場合、透析開始日時に「現在日時」、透析終了日時に「null」を登録する
            IF ('11' = NEW.process_state AND NOT(OLD.start_date IS NOT NULL AND OLD.end_date IS NULL)) THEN
                UPDATE mnt_machine_state SET start_date = current_timestamp, end_date = null WHERE facility_cd = NEW.facility_cd AND machine_type_cd = NEW.machine_type_cd AND TRIM(machine_serial) = TRIM(NEW.machine_serial) ;
            -- 工程状態が「09:排液」の場合、透析終了日時に「現在日時」を登録する
            ELSIF ('09' = NEW.process_state AND OLD.start_date IS NOT NULL AND OLD.end_date IS NULL) THEN
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
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 10