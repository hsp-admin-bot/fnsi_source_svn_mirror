-- mst_personal_user のシーケンスを更新
-- mst_personal_user_id_seqにlast_value=1のレコードが存在する場合（マイグレーションで管理者を追加した状態）に
-- シーケンスを更新する。
-- 存在しない場合（利用者マスタ画面から利用者が追加されている）はシーケンス更新は行わない。
DO $$ BEGIN
    IF EXISTS (select last_value from mst_personal_user_user_id_seq WHERE last_value=1) then
      PERFORM setval('mst_personal_user_user_id_seq', 2, false);
    END IF;
END$$;
