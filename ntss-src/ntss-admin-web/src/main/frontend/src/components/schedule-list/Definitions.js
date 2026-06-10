//エリア識別定義
export const AREA_BED = "Bed"; //ベッド確定エリア
export const AREA_BEDNOTYET = "bedNotYet"; //ベッド未登録エリア
export const AREA_KURNOTYET = "kurNotYet"; //クール未登録エリア

//入外区分増減オペレーション定義(メソッド =changeInOutNum用)
export const OPE_DEC = "DEC"; //減算
export const OPE_INC = "INC"; //加算

//typeofのundefined定義
export const DEF_UNDEFINED = "undefined"; //undefined定義

//クールコード、ベッドコードの未配置の値(数値)
export const DEF_NOTASSIGNED = 0;

export const DEF_KUR_MAX = 10; //クールの最大値

export const DEF_HEADER_HEIGHT = 80; //表のヘッダー部分の高さ

//クール幅(px)
export const DEF_KUR_WIDTH = 120;
//セル高さ(px)
export const DEF_CELL_HEIGHT = 36;
//スクロールバー幅
export const DEF_SCROLLBAR_WIDTH = 17;

//文字サイズセット（小)
export const DEF_CELL_HEIGHT_FONT_SIZE_SMALL = 0.8;

//文字サイズセット（中)
export const DEF_CELL_HEIGHT_FONT_SIZE_MEDIUM = 1.0;

//文字サイズセット（大)
export const DEF_CELL_HEIGHT_FONT_SIZE_LARGE = 1.1;

//文字サイズセット（特大)
export const DEF_CELL_HEIGHT_FONT_SIZE_EXTRA_LARGE = 1.3;

//未登録領域の縦セル数
export const DEF_KUR_NOT_YET_NUM = 1;
export const DEF_BED_NOT_YET_NUM = 1;

//週の表示最大値
export const DEF_DISP_WEEK = 2; //TODO =DBから設定を取得
//日付の表示最大値
export const DEF_DAYMAX = 2 * 7;

//日付ヘッダー最大数
export const DEF_MAX_DAY_HEADER = 3 * 7;

//表示条件設定 =(デフォルト値)未登録エリア表示数
export const DEF_NUM_NOTYETAREA = 2;

//表示エリア(表パーツ)の数
export const DEF_ELEMNUM = 12;
//移動ブロックの種類
export const DEF_DAY = "D"; //日付
export const DEF_KUR = "K"; //クール

//未登録エリア透明度
export const DEF_OPA_IN_USE = 1.0; //表示
export const DEF_OPA_NOT_IN_USE = 0.3; //非表示

//メッセージダイアログ定義
export const DEF_DIALOG_NOUSE = -1; //使用していない
export const DEF_DIALOG_SAMECOND = 1; //同一患者、同一クール、同一治療方法の警告ダイアログ
export const DEF_DIALOG_UNMATCH = 2; //不一致時の確認ダイアログ
export const DEF_DIALOG_NODATA = 3; //移動対象のデータがない
export const DEF_DIALOG_CANNOTMOVE = 4; //移動不可
export const DEF_DIALOG_REPLACE = 5; //入れ替え
export const DEF_DIALOG_REPLACEUNMATCH = 6; //入れ替え時の不一致時の確認ダイアログ
// FNSI-add 現行改善対応425 孫灝 20201117 start
export const DEF_DIALOG_FACILITY_SETTING_1007_4 = 7; //施設設定マスタにNo７の「検査依頼」に選択肢「４」
export const DEF_DIALOG_FACILITY_SETTING_1007_4_2 = 72; //施設設定マスタにNo７の「検査依頼」に選択肢「４」
export const DEF_DIALOG_FACILITY_SETTING_1008_4 = 8; //施設設定マスタにNo8の「一般撮影検査依頼」に選択肢「４」
export const DEF_DIALOG_FACILITY_SETTING_1008_4_2 = 82; //施設設定マスタにNo8の「一般撮影検査依頼」に選択肢「４」
// FNSI-add 現行改善対応425 孫灝 20201117 end
//add 6444 【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao start
export const DEF_DIALOG_FACILITY_SETTING_2007_4 = 27; //施設設定マスタにNo７の「検査依頼」に選択肢「４」
export const DEF_DIALOG_FACILITY_SETTING_2008_4 = 28; //施設設定マスタにNo７の「検査依頼」に選択肢「４」
//add 6444 【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao end
// add FNSI 1006 No.426 start --孙灏 20201215
export const DEF_DIALOG_FACILITY_SETTING_3005_4 = 9; //施設設定マスタにNo105の「患者イベント変更機能」に選択肢「４」
export const DEF_DIALOG_FACILITY_SETTING_3005_4_2 = 92; //施設設定マスタにNo105の「患者イベント変更機能」に選択肢「４」
// add FNSI 1006 No.426 end --孙灏 20201215
// FNSI-add 現行改善対応425 徐 start
export const DEF_DIALOG_10 = 10;
// FNSI-add 現行改善対応425 徐 end

//ダイアログタイプ
export const DEF_MSGTYPE_OK = "1"; //OKボタンのみ
export const DEF_MSGTYPE_OK_CANCEL = "2"; //OK;キャンセル
// FNSI-add 現行改善対応425 孫灝 20201117 start
export const DEF_MSGTYPE_123 = "8"; //1;2;3
// FNSI-add 現行改善対応425 孫灝 20201117 end

//ダミースケジュール操作コード
export const DEF_DUMMY_CREATE = "1"; //ダミースケジュール作成
export const DEF_DUMMY_DELETE = "2"; //ダミースケジュール削除
// export const DEF_DUMMY_DEL_AND_CRE  = "3"; //ダミースケジュール削除&作成

export const DEF_LIST_WIDTH_MIN = 100; //表示域の最小値
export const DEF_BEDTITLE_WIDTH = 133; //ベッドタイトル表示域幅 (スクロール幅込み)

//戻り値定義
export const DEF_RET_OK = 0; //正常
export const DEF_RET_NG = -1; //異常
export const DEF_RET_NG_RELOAD = -2; //異常(データをリロードした)

//メッセージコード
export const DEF_DIALOG_MSG_1 = 70000001; // 同一患者、同一クール、同一治療方法
export const DEF_DIALOG_MSG_2 = 70000002; // 不一致時のメッセージ
export const DEF_DIALOG_MSG_3 = 70000003; // 移動させるものがないメッセージ(ブロック移動)
export const DEF_DIALOG_MSG_4 = 70000004; // セル移動ができないメッセージ
export const DEF_DIALOG_MSG_5 = 70000005; // ベッド未登録領域→クールが異なる確定領域 メッセージ
export const DEF_DIALOG_MSG_6 = 70000006; // クール未登録領域→治療日付が異なる確定領域 メッセージ
// export const DEF_DIALOG_MSG_7  = 70000007; // ダミー領域に他の患者が居る場合(空いてるけど置けない) メッセージ
export const DEF_DIALOG_MSG_8 = 70000008; // 他の患者が居る場合(空いてないし置けない) メッセージ
export const DEF_DIALOG_MSG_9 = 70000009; // 確定領域以外→ベッド未登録 メッセージ
export const DEF_DIALOG_MSG_10 = 70000010; // 確定領域以外→クール未登録 メッセージ
export const DEF_DIALOG_MSG_11 = 70000011; // データの再読込 メッセージ
export const DEF_DIALOG_MSG_12 = 70000012; // デミーデータは移動できない メッセージ
// export const DEF_DIALOG_MSG_13 = 70000013; // 治療状況的に移動できない メッセージ
export const DEF_DIALOG_MSG_14 = 70000014; // 過去日への移動禁止 メッセージ
export const DEF_DIALOG_MSG_15 = 70000015; // ベッド未登録領域→治療日付が異なる確定領域 メッセージ
export const DEF_DIALOG_MSG_16 = 22010001; // 指示者未選択用メッセージ
export const DEF_DIALOG_MSG_17 = 70000018; // 他の予定がある場合に入れ替えを行うか確認するメッセージ
export const DEF_DIALOG_MSG_18 = 70000019; // 移動先に治療開始後の情報があるため入れ替えできないメッセージ
export const DEF_DIALOG_MSG_19 = 70000020; // 移動先がダミースケジュールのため入れ替えできないメッセージ
export const DEF_DIALOG_MSG_20 = 70000021; // 移動先にダミースケジュールとの重複があるため入れ替えできないメッセージ
// FNSI-add 現行改善対応425 孫灝 20201117 start
export const DEF_DIALOG_MSG_21 = 70000022; // 施設設定マスタにNo７の「検査依頼」に選択肢「４」
export const DEF_DIALOG_MSG_22 = 70000023; // 施設設定マスタにNo8の「一般撮影検査依頼」に選択肢「４」
// FNSI-add 現行改善対応425 孫灝 20201117 end
// add FNSI 1006 No.426 start --孙灏 20201215
export const DEF_DIALOG_MSG_23 = 70000024; // 施設設定マスタにNo105の「患者イベント変更機能」に選択肢「４」
// add FNSI 1006 No.426 end --孙灏 20201215

//add FNSI redmine 6588 劉祥霖　start
export const DEF_DIALOG_MSG_29 = 70000029; // 長時間予定との予定重複。他の予定と重複するためスケジュール変更できません
//add FNSI redmine 6588 劉祥霖　end

// 過去日の場合のテーブルヘッダーのバックグラウンド色コード
export const BACKGROUND_HEADER_PAST_DAY = "#808080";

// 当日の場合のテーブルヘッダーのバックグラウンド色コード
export const BACKGROUND_HEADER_TODAY = "#2ca06f";

// 過去日の場合のテーブルカラムのバックグラウンド色コード
export const BACKGROUND_COLUMN_PAST_DAY = "#ededed";

// FNSI-add 現行改善対応425 徐 start
export const DEF_DIALOG_MSG_24 = 70000025;
export const DEF_DIALOG_MSG_25 = 70000026;
//add 6444 【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao start
export const DEF_DIALOG_MSG_27 = 70000027;
//add 6444 【デグレ】ベッド未登録枠だった予定を他の日のベッド枠に移動時のメッセージが不正 zhao end
// FNSI-add 現行改善対応425 徐 end
//9273 start
export const DEF_DIALOG_MSG_30 = 70000030;
export const DEF_DIALOG_MSG_31 = 70000031;
export const DEF_DIALOG_MSG_32 = 70000032;
export const DEF_DIALOG_MSG_33 = 70000033;
//9273 end
