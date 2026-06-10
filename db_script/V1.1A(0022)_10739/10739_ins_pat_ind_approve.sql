--------------------------------------------------------------------------------
-- V1.1A(0022)_10739\10739_ins_pat_ind_approve.sql
-- 
-- 【概要】
--      #10739 V1.0Bでpat_ind_approveのコンバートデータ不足に対する補正
--      ord_mainにデータが存在し、pat_ind_approveにレコードが無い件について、
--      デフォルトレコードのInsertを行う
-- 
-- 【管理番号】
--      #10739のV1.0B補正対策
-- 
-- 【変更履歴】
--      初期作成                                2025/05/20
-- 
-- 【備考】
--      #10739のV1.0B補正対策
-- 
--------------------------------------------------------------------------------

-- ストアドプロシージャを削除（存在する場合）
DROP PROCEDURE IF EXISTS reset_pat_ind_approve_10739_procedure();
-- ストアドプロシージャを作成
CREATE OR REPLACE PROCEDURE reset_pat_ind_approve_10739_procedure()
LANGUAGE plpgsql
AS $$
DECLARE
    batch_size INT := 10000; --1回でコミットするレコード件数
    remaining_rows INT; --登録対象レコードの件数
    current_ord_no INT := 0; --現時点処理済みの最大ord_no
    cur_group_rec_cnt INT :=0; -- グループ内、処理済みレコード件数
    cur_group_idx INT :=0; -- 処理グループカウンタ
    total_group_cnt INT :=0; -- 処理グループ総件数
    rec RECORD; -- pat_ind_approveに登録する、ord_mainレコード情報(一部)
    start_time TIMESTAMP; -- グループ処理開始時刻
    end_time TIMESTAMP;  -- グループ処理終了時刻
    total_start_time TIMESTAMP; -- 処理開始時刻
    total_end_time TIMESTAMP; -- 処理終了時刻
    total_counter INT := 0; -- 処理済みレコード件数
 
BEGIN  
    -- 処理開始時刻
    total_start_time := clock_timestamp();
    -- 登録対象レコードの件数を測定する(ord_mainに有り、pat_ind_approveに存在しないレコード件数)
    select count(1) INTO remaining_rows FROM ord_main odm 
      WHERE odm.ord_no > current_ord_no
      AND NOT EXISTS (SELECT 1 FROM pat_ind_approve pia WHERE pia.ord_no = odm.ord_no);
    -- 処理グループのサイズを計算(対象レコード数/1グループでの処理件数)
    total_group_cnt := remaining_rows/batch_size;

    -- 処理グループのサイズ分、繰り返し処理実施
    WHILE remaining_rows > 0 LOOP        
        -- グループ処理開始時刻
        start_time := clock_timestamp();
        -- 処理グループカウンタ + 1
        cur_group_idx := cur_group_idx + 1;
        -- 登録対象レコードの情報取得 -
        --  pat_ind_approveに存在しない、ord_mainのレコード情報 -
        --  ord_no昇順、1回でコミットするレコード件数分
        FOR rec IN
          SELECT 
            odm.facility_cd,
            odm.reg_date,
            odm.up_date,
            odm.ord_no
          FROM ord_main odm
          WHERE odm.ord_no > current_ord_no
          AND NOT EXISTS (SELECT 1 FROM pat_ind_approve pia WHERE pia.ord_no = odm.ord_no)
          ORDER BY odm.ord_no asc
          limit batch_size
        LOOP            
            INSERT INTO pat_ind_approve(
                "ord_no",
                "check_user1_cd",
                "check_user2_cd",
                "approve_user1_cd",
                "approve_user2_cd",
                "check_user1_time",
                "check_user2_time",
                "approve_user1_time",
                "approve_user2_time",
                "reg_date",
                "up_date",
                "is_content_changed",
                "check_content",
                "is_user1_checked",
                "is_user2_checked",
                "is_user1_approved",
                "is_user2_approved",
                "is_content_appd_changed",
                "approve_content",
                "is_content_changed_for_map",
                "content_for_map",
                "facility_cd")
            VALUES
              (
                rec.ord_no,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                NULL,
                rec.reg_date,
                rec.up_date,
                '0',
                '{}',
                '0',
                '0',
                '0',
                '0',
                '0',
                '{}',
                '0',
                NULL,
                rec.facility_cd
            );
            --現時点処理済みの最大ord_noを更新
            current_ord_no := rec.ord_no;
            -- グループ内、処理済みレコード件数を更新
            cur_group_rec_cnt := cur_group_rec_cnt + 1;
        END LOOP;
        -- batch_size定義サイズ毎に、コミットを行う
        COMMIT;        
        -- グループ処理終了時刻
        end_time := clock_timestamp();

        --登録対象レコードの件数更新(処理残件数)
        select count(1) INTO remaining_rows FROM ord_main odm 
          WHERE odm.ord_no > current_ord_no
          AND NOT EXISTS (SELECT 1 FROM pat_ind_approve pia WHERE pia.ord_no = odm.ord_no);
        -- 処理時間と処理件数  
        RAISE NOTICE '現在のグループは %/%、合計 % 項目です。すべての項目が処理されましたが、処理が残っている項目は % 件です。', cur_group_idx,total_group_cnt,cur_group_rec_cnt,remaining_rows;
        RAISE NOTICE '処理開始時間: %,終了時間: %', start_time, end_time;
        RAISE NOTICE '処理合計時間: %', end_time - start_time;
        RAISE NOTICE '---------------------------------------------------------';
        RAISE NOTICE '';
        -- 処理済みレコード件数の更新
        total_counter := total_counter + cur_group_rec_cnt;
        -- グループ内、処理済みレコード件数を初期化
        cur_group_rec_cnt := 0;
    END LOOP;
    total_end_time := clock_timestamp();
    RAISE NOTICE '登録済みレコード総件数: %件', total_counter;
    RAISE NOTICE '開始時刻: %、終了時刻: %', total_start_time, total_end_time;
    RAISE NOTICE '合計処理時間: %', total_end_time - total_start_time;
END;
$$;
-- ストアドプロシージャを実行
call reset_pat_ind_approve_10739_procedure();
-- ストアドプロシージャを削除
DROP PROCEDURE IF EXISTS reset_pat_ind_approve_10739_procedure();
 