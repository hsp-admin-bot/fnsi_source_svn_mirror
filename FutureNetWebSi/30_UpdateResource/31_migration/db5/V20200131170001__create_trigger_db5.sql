--------------------------------------------------------------------------------
-- cre_tg_sync_ord_main
-- 【概要】
--    治療情報のレコード更新時に、関連テーブルのレコードを更新する
-- 
-- 【変更履歴】
--      初期作成                                            2019/03/01 NAKAMURA
--      更新前にダミースケジュールを削除するように修正      2019/06/06 HASIGUTI
--      NEW.pat_id が NULL の場合は何もしないように修正     2020/01/29 MOR.FUJINO
--      NEW.is_del が '1' の場合はord_scheduleを削除するように修正     2020/01/29 MOR.KOJIMA
-- 
--------------------------------------------------------------------------------
DROP TRIGGER IF EXISTS tg_sync_ord_main ON ord_main ;
CREATE OR REPLACE FUNCTION sync_ord_main()
RETURNS trigger AS $BODY$
DECLARE
  ord_schedule_row_cnt  numeric ; -- 治療スケジュールテーブルの対象レコード件数
BEGIN
  -- NEW.pat_id が NULL の場合は何もせずに処理抜ける --
  IF (NEW.pat_id IS NULL) THEN
    RETURN NULL ;
  END IF ;
  -- 治療スケジュールテーブル更新
  IF (TG_OP = 'DELETE') THEN
    -- 治療情報のレコード削除時は関連テーブルのレコードも削除
    DELETE FROM ord_schedule WHERE ord_no = OLD.ord_no ;
  ELSIF (TG_OP = 'INSERT') OR (TG_OP = 'UPDATE') THEN
    -- 治療スケジュールテーブルの該当レコード件数取得
    SELECT COUNT(*) INTO ord_schedule_row_cnt FROM ord_schedule WHERE ord_no = NEW.ord_no ;
    IF (TG_OP = 'INSERT') THEN
      -- 治療情報のレコード追加時は関連テーブルのレコードを追加(既に登録されている場合は処理中断)
      IF (0 = ord_schedule_row_cnt) THEN
        INSERT INTO ord_schedule (facility_cd, ord_no, treat_date, kur_cd, bed_cd, pat_id, is_dummy, up_date, reg_date, treat_week) VALUES(NEW.facility_cd, NEW.ord_no, NEW.treat_date, NEW.ind_kur_cd, NEW.ind_bed_cd, NEW.pat_id, '0', now(), now(), NEW.treat_week) ;
      END IF ;
    ELSIF (TG_OP = 'UPDATE') THEN
      -- 治療情報のレコード追加時は関連テーブルのレコードを追加(既に登録されている場合は処理中断)
      IF (0 = ord_schedule_row_cnt) THEN
        INSERT INTO ord_schedule (facility_cd, ord_no, treat_date, kur_cd, bed_cd, pat_id, is_dummy, up_date, reg_date, treat_week) VALUES(NEW.facility_cd, NEW.ord_no, NEW.treat_date, NEW.ind_kur_cd, NEW.ind_bed_cd, NEW.pat_id, '0', now(), now(), NEW.treat_week) ;
      -- 更新対象カラムのみを更新
      ELSIF (OLD.treat_date <> NEW.treat_date) OR (OLD.ind_kur_cd <> NEW.ind_kur_cd) OR (OLD.ind_bed_cd <> NEW.ind_bed_cd) THEN
        -- 更新前にダミースケジュールを削除
        DELETE FROM ord_schedule WHERE is_dummy = '1' AND ord_no = NEW.ord_no ;
        UPDATE ord_schedule SET treat_date = NEW.treat_date, kur_cd = NEW.ind_kur_cd, bed_cd = NEW.ind_bed_cd, treat_week = NEW.treat_week, up_date = NEW.up_date WHERE ord_no = NEW.ord_no ;
      ELSIF (NEW.is_del = '1') THEN
        -- ord_mainのレコードを論理削除した際には、ord_scheduleのレコードは物理削除する
        DELETE FROM ord_schedule WHERE ord_no = OLD.ord_no ;
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
CREATE TRIGGER tg_sync_ord_main AFTER INSERT OR UPDATE OR DELETE ON ord_main FOR EACH ROW EXECUTE PROCEDURE sync_ord_main() ;
