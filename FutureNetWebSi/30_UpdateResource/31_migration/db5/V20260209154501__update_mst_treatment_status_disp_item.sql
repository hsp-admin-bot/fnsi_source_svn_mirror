-- #12478 自動ワンショット(使用する/使用しない)→IPワンショットスタート(自動/手動)修正
-- 治療状況レイアウトマスタ詳細＞透析装置の追加ボタン押下で表示されるプルダウンの文言と表示順を修正

-- ※ほとんどのレコードがdisp_order=0の状態で、表示順が指定されていない。先頭に表示したいものがマイナス指定されている。
--   一部項目の表示順を制御する為、制御したい項目より以前はdisp_orderを0のままにし、以降からdisp_orderを1～6まで指定し、それ以降の制御不要レコードはdisp_orderを7で統一しておく。

-- 「自動ワンショット」を「IPワンショットスタート」へ文言修正。
update ntss.mst_treatment_status_disp_item set item_name='IPワンショットスタート', up_date=current_timestamp where item_cd=104;

-- 「IP使用選択」表示順を0→1へ修正。
update ntss.mst_treatment_status_disp_item set disp_order=1, up_date=current_timestamp where item_cd=99;

-- 「IPスタート」表示順を0→2へ修正。
update ntss.mst_treatment_status_disp_item set disp_order=2, up_date=current_timestamp where item_cd=100;

-- 「IPワンショット量」表示順を0→6へ修正。
update ntss.mst_treatment_status_disp_item set disp_order=6, up_date=current_timestamp where item_cd=101;

-- 「IP速度」表示順を0→3へ修正。
update ntss.mst_treatment_status_disp_item set disp_order=3, up_date=current_timestamp where item_cd=102;

-- 「IP速度最大値」表示順を0→4へ修正。
update ntss.mst_treatment_status_disp_item set disp_order=4, up_date=current_timestamp where item_cd=103;

-- 「IPワンショットスタート」表示順を0→5へ修正。
update ntss.mst_treatment_status_disp_item set disp_order=5, up_date=current_timestamp where item_cd=104;

-- 以降のレコードのdisp_orderをまとめて7にする。（ただし、disp_order未指定のレコードに限る）
update ntss.mst_treatment_status_disp_item set disp_order=7, up_date=current_timestamp where item_cd in (105, 106, 107, 108, 110, 111, 112, 113) and disp_order=0;
