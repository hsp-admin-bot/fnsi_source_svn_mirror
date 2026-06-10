--------------------------------------------------------------------------------
-- cre_tg_sync_mst_bed.sql
-- 
-- 【概要】
--      ベッドマスタのレコード更新に従い、関連テーブルのレコードを更新する
-- 
-- 【管理番号】
--      DB変更NO ：399
--      DBVERSION：1.0.0.0
-- 
-- 【変更履歴】
--      初期作成                                2019/03/06 HASIGUTI
-- 
-- 【備考】
--      スキーマが複数存在する場合、テーブル名の前にスキーマを指定しなければならない
-- 
--------------------------------------------------------------------------------
DROP TRIGGER IF EXISTS tg_sync_mst_bed ON mst_bed ;
DROP FUNCTION IF EXISTS sync_mst_bed() ;
CREATE OR REPLACE FUNCTION sync_mst_bed()
RETURNS trigger AS $BODY$
DECLARE
    mst_machine_rowtype mst_machine%rowtype ;
    mnt_machine_state_row_cnt numeric ;
    cu refcursor ;
BEGIN

    -- 削除処理
    IF (TG_OP = 'DELETE') THEN
        IF (OLD.machine_no is not null) THEN
            -- 削除されたベッドのデータから紐づいていた装置のデータを取得
            open cu for SELECT * FROM mst_machine WHERE facility_cd = OLD.facility_cd AND machine_no = OLD.machine_no ;
            loop
                fetch cu into mst_machine_rowtype ;
                exit when not found ;
                -- 削除されたベッドに紐づいていた装置のベッド情報にnullを登録
                UPDATE mnt_machine_state 
                SET bed_cd = NULL, bed_name = NULL, up_date = CURRENT_TIMESTAMP
                WHERE facility_cd = mst_machine_rowtype.facility_cd 
                AND machine_type_cd = mst_machine_rowtype.machine_type_cd 
                AND TRIM(machine_serial) = TRIM(mst_machine_rowtype.machine_serial) ;
            end loop ;
            close cu ;
        END IF ;
    ELSE
        -- 登録処理
        IF (TG_OP = 'INSERT') THEN
            IF (NEW.machine_no is not null) THEN
                -- 登録されたベッドのデータから紐づけた装置のデータを取得
                open cu for SELECT * FROM mst_machine WHERE facility_cd = NEW.facility_cd AND machine_no = NEW.machine_no ;
                loop
                    fetch cu into mst_machine_rowtype ;
                    exit when not found ;
                    -- 登録されたベッドに紐づく装置にベッド情報を登録
                    UPDATE mnt_machine_state 
                    SET bed_cd = NEW.bed_cd, bed_name = NEW.bed_name, up_date = NEW.up_date 
                    WHERE facility_cd = mst_machine_rowtype.facility_cd 
                    AND machine_type_cd = mst_machine_rowtype.machine_type_cd 
                    AND TRIM(machine_serial) = TRIM(mst_machine_rowtype.machine_serial) ;
                end loop ;
                close cu ;
            END IF ;
        -- 更新処理
        ELSE
            -- 表示フラグに変更(表示フラグOFF)があった場合の処理
            IF (NEW.is_disp = '0') THEN
                -- 変更されたベッドのデータから紐づけが解除された装置のデータを取得
                open cu for SELECT * FROM mst_machine WHERE facility_cd = OLD.facility_cd AND machine_no = OLD.machine_no ;
                loop
                    fetch cu into mst_machine_rowtype ;
                    exit when not found ;
                    -- 変更されたベッドから紐づけが解除された装置のベッド情報にnullを登録
                    UPDATE mnt_machine_state 
                    SET bed_cd = NULL, bed_name = NULL, up_date = NEW.up_date
                    WHERE facility_cd = mst_machine_rowtype.facility_cd 
                    AND machine_type_cd = mst_machine_rowtype.machine_type_cd 
                    AND TRIM(machine_serial) = TRIM(mst_machine_rowtype.machine_serial) ;
                end loop ;
                close cu ;
                -- 削除(非表示)にされたベッドに紐づく装置情報にnullに更新
                UPDATE mst_bed SET machine_no = null WHERE facility_cd = NEW.facility_cd AND bed_cd = NEW.bed_cd ;
            ELSE
                -- 表示フラグに変更(表示フラグON)があった場合または装置番号に変更があった場合の処理
                IF ((NEW.is_disp = '1') OR
                    ((OLD.machine_no is null) AND (NEW.machine_no is not null)) OR 
                    ((OLD.machine_no is not null) AND (NEW.machine_no is null)) OR 
                    (OLD.machine_no != NEW.machine_no)) THEN
                    IF ((OLD.machine_no is not null) OR (OLD.machine_no != NEW.machine_no)) THEN
                        -- 変更されたベッドのデータから紐づけが解除された装置のデータを取得
                        open cu for SELECT * FROM mst_machine WHERE facility_cd = OLD.facility_cd AND machine_no = OLD.machine_no ;
                        loop
                            fetch cu into mst_machine_rowtype ;
                            exit when not found ;
                            -- 変更されたベッドから紐づけが解除された装置のベッド情報にnullを登録
                            UPDATE mnt_machine_state 
                            SET bed_cd = NULL, bed_name = NULL, up_date = NEW.up_date
                            WHERE facility_cd = mst_machine_rowtype.facility_cd 
                            AND machine_type_cd = mst_machine_rowtype.machine_type_cd 
                            AND TRIM(machine_serial) = TRIM(mst_machine_rowtype.machine_serial) ;
                        end loop ;
                        close cu ;
                    END IF ;
                    IF (NEW.machine_no is not null) THEN
                        -- 変更されたベッドのデータから新たに紐づけされた装置のデータを取得
                        open cu for SELECT * FROM mst_machine WHERE facility_cd = NEW.facility_cd AND machine_no = NEW.machine_no ;
                        loop
                            fetch cu into mst_machine_rowtype ;
                            exit when not found ;
                            -- 変更されたベッドに紐づく装置にベッド情報を登録
                            UPDATE mnt_machine_state 
                            SET bed_cd = NEW.bed_cd, bed_name = NEW.bed_name, up_date = NEW.up_date 
                            WHERE facility_cd = mst_machine_rowtype.facility_cd 
                            AND machine_type_cd = mst_machine_rowtype.machine_type_cd 
                            AND TRIM(machine_serial) = TRIM(mst_machine_rowtype.machine_serial) ;
                        end loop ;
                        close cu ;
                    END IF ;
                -- 装置番号以外に変更があった場合の処理
                ELSE
                    -- ベッド名に変更があった場合は変更されたベッドに紐づく装置のベッド情報を更新
                    IF (((OLD.bed_name is null) AND (NEW.bed_name is not null)) OR 
                        ((OLD.bed_name is not null) AND (NEW.bed_name is null)) OR 
                        (OLD.bed_name != NEW.bed_name)) THEN
                        -- 変更されたベッドのデータから紐づけた装置のデータを取得
                        open cu for SELECT * FROM mst_machine WHERE facility_cd = NEW.facility_cd AND machine_no = NEW.machine_no ;
                        loop
                            fetch cu into mst_machine_rowtype ;
                            exit when not found ;
                            -- 変更されたベッドに紐づく装置にベッド情報を登録
                            UPDATE mnt_machine_state 
                            SET bed_name = NEW.bed_name, up_date = NEW.up_date 
                            WHERE facility_cd = mst_machine_rowtype.facility_cd 
                            AND machine_type_cd = mst_machine_rowtype.machine_type_cd 
                            AND TRIM(machine_serial) = TRIM(mst_machine_rowtype.machine_serial) ;
                        end loop ;
                        close cu ;
                    END IF ;
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
CREATE TRIGGER tg_sync_mst_bed AFTER INSERT OR UPDATE OR DELETE ON mst_bed FOR EACH ROW EXECUTE PROCEDURE sync_mst_bed() ;
