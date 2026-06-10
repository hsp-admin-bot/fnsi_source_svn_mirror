/**
* @file ntss_comsv.h
* @brief 通信サーバ関連ヘッダー
* @author Y.Takamura
* @date 2018/10/01
*/

#ifndef _NTSS_SOCKET_H_
#define _NTSS_SOCKET_H_

#include <errno.h>
#include "comsv_info.h"
#include "comsv_lcd_info.h"
#include "comsv_work_data.h"
#include "comsv_config.h"
#include "comsv_fail.h"
#include "../common/nkklib/nkklib.h"
#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/ntss_mst_lib.h"
#include "../common/libs/master_controller.h"

// #11629 2025.05.08 add 治療済透析レポート情報の保存箇所変更 TDC米沢 start
#include "../common/libs/ntss_etc_lib.h"
// #11629 2025.05.08 add 治療済透析レポート情報の保存箇所変更 TDC米沢 end

/// @name システム情報定義
//@{
#define	DEV_MAX				200		 ///< 装置最大数
#define	LISTEN_MAX			100		 ///< 接続待ちキュー最大値
#define	CHECK_LIST_MAX		8		   ///< チェックリスト最大数
#define	EXAM_ITEM_MAX		100		 ///< 検査項目最大数
#define	EVENT_MAX		   16		  ///< イベント最大数
#define	HOST_WATCH_MAX	  20		  ///< ホスト監視最大数
#define SIG_MST_SYNC 		34		  ///< マスタ更新指示
#define SIG_ALIVE_MONI		36		  ///< 装置死活監視要求
#define SIG_CREATE_MODE	 40		  ///< 装置情報作成モード移行要求
#define SIG_NORMAL_MODE	 41		  ///< 通常モード移行要求
// add AWSとDEの通信断からの復旧 高 start
#define SIG_COMM_FAIL	   42		  ///< 通信障害
#define SIG_COMM_FAIL_NORMAL 43		 ///< 通信障害NORAML
// #8730 2023.06.01 add メインから送られた蓄積系データの取り込み TDC米沢 start
#define SIG_COMM_FILE_MOVED 44		  ///< 通信障害時の蓄積系データの移動完了通知
// #8730 2023.06.01 add メインから送られた蓄積系データの取り込み TDC米沢 end
// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻をロガーと共有 TDC米沢 start
#define SIG_COMSV_CONFIG_UPDATE 50	  // 通信サーバー設定更新
// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻をロガーと共有 TDC米沢 end
// add AWSとDEの通信断からの復旧 高 end
#define MST_INFO			"mstMachineInfo.dat"		///< 装置マスタファイル名
#define CONFIG_FILE		 "./conf/ntss_comsv.conf"	///< 通信サーバ設定ファイル名
#define CONFIG_COMMON_FILE  "./conf/ntss_common.conf"   ///< アプリケーション共通設定ファイル名
#define CONFIG_NETWORK_FILE "./conf/ntss_network.conf"  ///< ネットワーク設定ファイル名
// #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 start
#define CONFIG_COMM_FAIL_FILE "./conf/ntss_comm_fail.conf"  ///< 通信サーバ通信異常時設定ファイル名
// #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 end
//@}

/**
 * @def 配列数を求めるマクロ
 */
#define COUNTOF(array) (sizeof(array) / sizeof(array[0]))

/**
 * @brief 通信サーバ設定（仮想端末メニュー表示設定）
 */
typedef struct {
	char	title[6];   				///< タイトル
	short	no[8];						///< 項目コード
	char	name[8][12];				///< 項目名称
} ComsvLcdMenu_t;

/**
 * @brief 通信サーバ設定（透析日報表示設定）
 */
typedef struct {
	char	name[16];   				///< 項目名称
} ComsvLcdReport_t;

/**
 * @brief 通信サーバ設定（検査１グラフ表示設定）
 */
typedef struct {
	char	name[10];   				///< グラフ名
	long	code[3];					///< 検査コード
} ComsvLcdGraph1_t;

/**
 * @brief 通信サーバ設定（検査２グラフ表示設定）
 */
typedef struct {
	char	name[10];   				///< ページ名
	char	graph1_name[10];			///< グラフ名１
	long	code1[3];				   ///< グラフ１検査コード
	char	graph2_name[10];			///< グラフ名２
	long	code2[3];				   ///< グラフ２検査コード
} ComsvLcdGraph2_t;

/**
 * @brief 通信サーバ設定（検査レーダーチャート表示設定）
 */
typedef struct {
	long	code;					   ///< 検査コード
} ComsvLcdRadar_t;

/**
 * @brief 通信サーバ設定
 */
typedef struct {
	char	is_timeset;				 ///< 新通信一斉時刻合わせ
	char	timeset_time[5];			///< 新通信一斉時刻合わせ時刻
	char	is_timeset_nx;			  ///< NX通信一斉時刻合わせ
	char	timeset_nx_time[5];		 ///< NX通信一斉時刻合わせ時刻
	char	lcd_log_time;			   ///< 仮想端末ログ時間
	char	lcd_log_type;			   ///< 仮想端末ログ内容
	char	is_lcd_medi;				///< 仮想端末投与時間帯表示
	short   end_wait_time;			  ///< 排液判定待機時間
	char	pat_timing;				 ///< 患者切り替えタイミング
	char	is_notice;				  ///< お知らせ機能
	short   notice_time;				///< お知らせ機能補正時間
	char	log_upload_time[5];		 ///< ログのアップロード実施時刻
	short   offline_start_time;		 ///< オフライン運転自動開始時間
	char	is_offline_auto_end;		///< オフライン運転自動終了
	char	reload_next_pat_time[5];	///< 日付変更時次患者更新時刻
	short   device_timeout;			 ///< 装置生存監視時間
	short   treat_moni_interval;		///< 治療中モニタ通知間隔
	short   other_moni_interval;		///< 治療外モニタ通知間隔
	// add 治療記録用データと治療状況用データの登録先を振分けにする 高 start
	short   treat_realtime_monito_interval;  ///< 治療中リアルタイムモニタ通知間隔
	short   other_realtime_monito_interval;  ///< 治療外リアルタイムモニタ通知間隔
	// add 治療記録用データと治療状況用データの登録先を振分けにする 高 end
	ComsvLcdMenu_t lcd_menu[4];		 ///< 仮想端末メニュー表示設定
	ComsvLcdReport_t lcd_report[8];	 ///< 透析日報表示設定
	ComsvLcdGraph1_t lcd_graph1[5];	 ///< 検査１グラフ表示設定
	ComsvLcdGraph2_t lcd_graph2[5];	 ///< 検査２グラフ表示設定
	ComsvLcdRadar_t lcd_radar[6];	   ///< 検査レーダーチャート表示設定
	// add FNSI-バグ 通信サーバ 高 start
	short   treatment_judge_time;	   ///< 治療時間
	char	lcd_medi_time;			  ///< 仮想端末投与時間
	// add FNSI-バグ 通信サーバ 高 end
} ComsvSetting_t;

/**
 * @brief チェックリストマスタ
 */
typedef struct {
	short	list_cd[CHECK_LIST_MAX];		///< リストコード
	short   list_time[CHECK_LIST_MAX];	  ///< 入力タイミング
	char	list_name[CHECK_LIST_MAX][12];	///< リスト名
} CheckListMst_t;

/**
 * @brief 検査項目マスタ
 */
typedef struct {
	long	item_cd[EXAM_ITEM_MAX];			///< 検査項目コード
	char	item_name[EXAM_ITEM_MAX][20];   ///< 検査項目名
	char	unit[EXAM_ITEM_MAX][8];		 ///< 単位
	short   decimal[EXAM_ITEM_MAX];		 ///< 小数部桁数
	long	graph_upper[EXAM_ITEM_MAX];	 ///< グラフ上限値
	long	graph_lower[EXAM_ITEM_MAX];	 ///< グラフ下限値
	//add redmine bug#6766,6767 劉 start
	char	console_class[EXAM_ITEM_MAX];   ///< 仮想端末表示対象区分
	//add redmine bug#6766,6767 劉 end
} ExamItemMst_t;

/**
 * @brief 通信サーバキャッシュデータ
 */
typedef struct {
	ComsvSetting_t _comsvSet;		   ///< 通信サーバ設定
	CheckListMst_t _checkMst;		   ///< チェックリストマスタ
	ExamItemMst_t _examMst;			 ///< 検査項目マスタ
	LcddataReq29_t _lcdReq29;		   ///< 仮想端末（処置者）
	LcddataReq50_t _lcdReq50;		   ///< 仮想端末（愁訴・処置）
} ComsvCache_t;

/**
 * @brief 装置制御情報
 */
struct connect_socket {
	bool	using;					  ///< メモリ使用中フラグ
	bool	running;					///< スレッド実行中フラグ
	bool	mst_reload;				 ///< 装置マスタ更新フラグ
	int		thread_no;				  ///< スレッド番号
	int		accept_socket;			  ///< 待受ソケットNo
	char	event[EVENT_MAX];		   ///< イベント（0:OFF,1:ON）
										///   [0]:設定値書込
										///   [1]:装置オプション読出
										///   [2]:設定値読出
										///   [3]:次患者情報転送
										///   [4]:未登録患者割付
										///   [5]:条件送信キャンセル
										///   [6]:投薬指示変更
										///   [7]:後体重測定
										///   [8]:治療状況確認
										///   [9]:仮想端末キャシュ更新
										///   [10]:オフライン運転開始
										///   [11]:オフライン運転終了
	// #10518 2024.05.28 mod 画面側操作→DE連動処理不正 TDC高村 start
										// ///   [12]:レポート画像更新
										// ///   [13]〜[15]:予備
										///   [12]:実績確定・削除時装置レポート画像更新
										///   [13]:実績版確定時装置レポート画像更新
										///   [14]:オフライン運転タイマー更新
										///   [15]:ホスト報知定義更新指示
	// #10518 2024.05.28 mod 画面側操作→DE連動処理不正 TDC高村 end
	struct scn_data_fm scn;			 ///< 装置制御データ
	// #11282 2025.03.12 add 通信不可フォルダへの転送完了のシグナル通知 TDC片口 start
	bool is_update_comm_fail_from_main;
	// #11282 2025.03.12 add 通信不可フォルダへの転送完了のシグナル通知 TDC片口 end
};

/**
 * @brief 通信サーバキャッシュデータ
 */
extern ComsvCache_t _comsvCache;

/**
 * @brief 設定情報
 */
extern ConfigParameter_t configParam;

/**
 * @brief 装置制御情報
 */
extern struct connect_socket con_sock[DEV_MAX];

/**
 * @brief 装置情報マスタ
 */
extern MachineInfo2_t _machineInfoData[DEV_MAX];

/**
 * @brief 装置情報作成モード中フラグ
 */
extern bool bCreateMachineInfo;

// add FNSI-バグ 通信サーバ 高 start
/**
 * @brief thread
 */
extern pthread_t thr_sv[DEV_MAX];
// add FNSI-バグ 通信サーバ 高 end

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn void get_time()
// * @brief 現在時刻を取得
// * @return long 現在時刻
// */
//extern long get_time();
/**
 * @fn time_t get_time()
 * @brief 現在時刻を取得
 * @return time_t 現在時刻
 */
extern time_t get_time();
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
/**
 * @fn void LogOutputs(NtssLogType type, u_char *msg, u_char *devType, u_char *devSerial)
 * @brief ログ出力（コンソール＆ファイル）を行う
 * @param[in] type 種別コード
 * @param[in] msg ログメッセージ
 * @param[in] flag 出力フラフ（0:通常,1:システム情報有り）
 * @param[in] devType 型式(不要な場合は空文字を指定)
 * @param[in] devSerial 製造番号(不要な場合は空文字を指定)
 */
//extern void LogOutputs(NtssLogType type, u_char *msg, int flg, u_char *devType, u_char *devSerial);
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end

/**
* @fn void comsv_socket_close( struct connect_socket *conSock )
* @brief ソケットクローズ処理（新通信待受用）
* @param[in,out] conSock 装置制御情報
*/
extern void comsv_socket_close( struct connect_socket *conSock );

/**
* @fn void comsv_socket_close_nx(struct connect_socket *conSock)
* @brief ソケットクローズ処理（NX通信待受用）
* @param[in,out] conSock 装置制御情報
*/
extern void comsv_socket_close_nx( struct connect_socket *conSock );

/**
* @fn void comsv_socket_close_cp(struct connect_socket *conSock)
* @brief ソケットクローズ処理（共通プロトコル通信接続用）
* @param[in,out] conSock 装置制御情報
*/
extern void comsv_socket_close_cp( struct connect_socket *conSock );

/**
 * @fn int comsv_json_mst_comset(char *jfile, ComsvSetting_t *comset)
 * @brief JSON文字列から通信サーバ設定構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] comset 通信サーバ構造体
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_mst_comset(char *jfile, ComsvSetting_t *comset);

/**
 * @fn int comsv_json_mst_checklist(char *jfile, CheckListMst_t *checklist)
 * @brief JSON文字列からチェックリストマスタ構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] checklist チェックリストマスタ構造体
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_mst_checklist(char *jfile, CheckListMst_t *checklist);

/**
 * @fn int comsv_json_mst_examitem(char *jfile, ExamItemMst_t *examitem)
 * @brief JSON文字列から検査項目マスタ構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] examitem 検査項目マスタ構造体
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_mst_examitem(char *jfile, ExamItemMst_t *examitem);

// #8266 2023.03.24 mod 前回取得データを削除しない修正に伴う対応 TDC高村 start
/**
 * @fn int comsv_json_dev_state(char *jfile, short type, struct scn_data_fm *scn)
 * @brief JSON文字列から装置状態管理を構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[in] type 取得タイプ（-1:装置ステータスのみ,0:オーダ番号&患者ID取得無し,1,2:オーダ番号&患者ID取得有り)
 *							  0,1:AWSとDEの通信断時は既存ファイルから構造体に格納しない）
 *							 -1,2:AWSとDEの通信断時も既存ファイルから構造体に格納する）
 * @param[out] scn 装置制御データ構造体
 * @return 0:成功, -1:エラー
 */
// #8266 2023.03.24 mod 前回取得データを削除しない修正に伴う対応 TDC高村 end
extern int comsv_json_dev_state(char *jfile, short type, struct scn_data_fm *scn);

/**
 * @fn int comsv_json_dev_cond(char *jfile, short type, struct scn_data_fm *scn, unsigned char *data, int len)
 * @brief JSON文字列から条件送信データに格納する
 * @param[in] jfile JSONファイル名
 * @param[in] type JSONタイプ（0:REST GET用,1:REST PUT用）
 * @param[out] scn 装置制御データ構造体
 * @param[out] data 条件送信データ
 * @param[in] len データ長
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_dev_cond(char *jfile, short type, struct scn_data_fm *scn, unsigned char *data, int len);

// #11367 2025.01.09 mod 次患者情報のJSONデータ取得処理変更 TDC高村 start
/**
 * @fn int comsv_json_dev_npat1(char *jfile, short type, struct scn_data_fm *scn, unsigned char *data)
 * @brief JSON文字列から次患者情報１送信データに格納する
 * @param[in] jfile JSONファイル名
 * @param[in] type JSON取得タイプ（0:JSON Library,1:Original）
 * @param[out] scn 装置制御データ構造体
 * @param[out] data 次患者情報１送信データ
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_dev_npat1(char *jfile, short type, struct scn_data_fm *scn, unsigned char *data);
// #11367 2025.01.09 mod 次患者情報のJSONデータ取得処理変更 TDC高村 end

// #11367 2025.01.09 mod 次患者情報のJSONデータ取得処理変更 TDC高村 start
/**
 * @fn int comsv_json_dev_npat2(char *jfile, short type, unsigned char *data)
 * @brief JSON文字列から次患者情報２送信データに格納する
 * @param[in] jfile JSONファイル名
 * @param[in] type JSON取得タイプ（0:JSON Library,1:Original）
 * @param[out] data 次患者情報２送信データ
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_dev_npat2(char *jfile, short type, unsigned char *data);
// #11367 2025.01.09 mod 次患者情報のJSONデータ取得処理変更 TDC高村 end

/**
 * @fn int comsv_json_dev_make_cond(char *jfile, unsigned char *data, int len)
 * @brief 条件送信データからJSONファイルを作成する
 * @param[in] jfile 出力JSONファイル名
 * @param[in] data 条件送信データ
 * @param[in] len データ長
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_dev_make_cond(char *jfile, unsigned char *data, int len);

/**
 * @fn int comsv_json_dev_hash_check(char *jfile, long ord_no, char *hash)
 * @brief JSON文字列から取得したハッシュ値をチェックする
 * @param[in] jfile JSONファイル名
 * @param[in] ord_no オーダー番号
 * @param[in] hash チェック対象のハッシュ値
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_dev_hash_check(char *jfile, long ord_no, char *hash);

/**
 * @fn int comsv_json_dev_cond_daily(char *jfile, short *sdata)
 * @brief JSON文字列から透析日報用条件データを格納する
 * @param[in] jfile JSONファイル名
 * @param[out] sdata 透析日報用条件データ（除水速度制限, 補液速度限界値, 補液設定値制限）
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_dev_cond_daily(char *jfile, short *sdata);

/**
 * @fn void comsv_json_dev_status(char *jdata, struct connect_socket *con_sp)
 * @brief 装置ステータス更新用JSONデータを作成する
 * @param[out] jdata 出力JSONデータ
 * @param[in] sp 装置制御データ
 */
extern void comsv_json_dev_status(char *jdata, struct scn_data_fm *sp);

// #11925 2025.06.13 add サーバ-DE間切断時に治療中だった患者が？？？？患者化することがある TDC高村 start
/**
 * @fn int comsv_json_dev_update(short type, int *chk, long tim)
 * @brief 装置状態管理JSONファイルを更新する
 * @param[in] timing タイミング（0:治療開始（未登録）, 1:治療開始, 2:治療終了） 
 * @param[in] sp 装置制御データ
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_dev_update(short timing, struct scn_data_fm *sp);
// #11925 2025.06.13 add サーバ-DE間切断時に治療中だった患者が？？？？患者化することがある TDC高村 end

/**
 * @fn int comsv_json_dev_npat1(char *jfile, unsigned char *data)
 * @brief JSON文字列から次患者情報１送信データに格納する
 * @param[in] jfile JSONファイル名
 * @param[out] data 次患者情報１送信データ
 * @return 0:次患者情報送信（無）, 1:次患者情報送信（有）, -1:エラー
 */
extern int comsv_json_ord_npat(char *jfile, unsigned char *data);

/**
 * @fn int comsv_json_ord_make_moni(char *jfile, unsigned char *data, u_char commType)
 * @brief 排液時更新用モニタデータからJSONデータを作成する
 * @param[in] jfile 出力JSONファイル名
 * @param[in] data モニタデータ
 * @param[in] commType 通信方式
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_ord_make_moni(char *jfile, unsigned char *data, u_char commType);

/**
 * @fn int comsv_json_ord_make_log(char *jdata, short type, unsigned char *data)
 * @brief ログデータ（測定データ）からJSONデータを作成する
 * @param[out] jdata 出力JSONデータ
 * @param[in] type ログタイプ（0:その他,1:再循環率測定,2:I-HDF引き残し量,3:静的静脈圧,4:IAP retio）
 * @param[in] data ログデータ
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_ord_make_log(char *jdata, short type, unsigned char *data);

/**
 * @fn int comsv_json_ord_make_comptreat(char *jdata, int *c_cd, int c_max, int *t_cd, int t_max)
 * @brief 愁訴処置（実施No配列）からJSONデータを作成する
 * @param[out] jdata 出力JSONデータ
 * @param[in] c_cd 愁訴実施No配列
 * @param[in] c_max 愁訴配列最大数
 * @param[in] t_cd 処置実施No配列
 * @param[in] c_max 処置配列最大数
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_ord_make_comptreat(char *jdata, int *c_cd, int c_max, int *t_cd, int t_max);

/**
 * @fn int comsv_json_ord_make_medi(char *jdata, int *no, int max)
 * @brief 投与薬剤（実施No配列）からJSONデータを作成する
 * @param[out] jdata 出力JSONデータ
 * @param[in] no 実施No配列
 * @param[in] max 配列最大数
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_ord_make_medi(char *jdata, int *no, int max);

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_json_ord_make_check(char *jdata, char *jfile, int *no, int max, long cd, long date)
// * @brief チェックリスト（実施No配列）からJSONデータを作成する
// * @param[out] jdata 出力JSONデータ
// * @param[in] jfile JSONファイル名
// * @param[in] no 実施No配列
// * @param[in] max 配列最大数
// * @param[in] cd 実施者コード（拡張）
// * @param[in] date 実施日時（拡張）
// * @return 0:成功, -1:エラー
// */
//extern int comsv_json_ord_make_check(char *jdata, char *jfile, int *no, int max, long cd, long date);
/**
 * @fn int comsv_json_ord_make_check(char *jdata, char *jfile, int *no, int max, long cd, time_t date)
 * @brief チェックリスト（実施No配列）からJSONデータを作成する
 * @param[out] jdata 出力JSONデータ
 * @param[in] jfile JSONファイル名
 * @param[in] no 実施No配列
 * @param[in] max 配列最大数
 * @param[in] cd 実施者コード（拡張）
 * @param[in] date 実施日時（拡張）
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_ord_make_check(char *jdata, char *jfile, int *no, int max, long cd, time_t date);
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

/**
 * @fn int comsv_json_lcd_req29(char *jfile, LcddataReq29_t *req29)
 * @brief JSON文字列から仮想端末（処置者）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req29 仮想端末（処置者）構造体
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_req29(char *jfile, LcddataReq29_t *req29);

// mod FNSI-バグ 通信サーバ #10270 高 start
/**
 * @fn int comsv_json_lcd_req32(char *jfile, struct scn_data_fm *sp, LcddataReq32_t *req32)
 * @brief JSON文字列から仮想端末（酸素吸入）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[in,out] sp 装置制御データ
 * @param[out] req32 仮想端末（酸素吸入）構造体
 * @return 0:成功, -1:エラー
 */
// extern int comsv_json_lcd_req32(char *jfile, LcddataReq32_t *req32);
extern int comsv_json_lcd_req32(char *jfile, struct scn_data_fm *sp, LcddataReq32_t *req32);
// mod FNSI-バグ 通信サーバ #10270 高 end

/**
 * @fn int comsv_json_lcd_req33(char *jfile, short pos, LcddataReq33_t *req33)
 * @brief JSON文字列から仮想端末（検査結果）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[in] pos 表示位置（検査日）
 * @param[out] req33 仮想端末（検査結果）構造体
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_req33(char *jfile, short pos, LcddataReq33_t *req33);

/**
 * @fn int comsv_json_lcd_req36(char *jfile, LcddataReq36_t *req36)
 * @brief JSON文字列から仮想端末（ログ）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req36 仮想端末（ログ）構造体
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_req36(char *jfile, LcddataReq36_t *req36);

/**
 * @fn int comsv_json_lcd_req38(char *jfile, LcddataReq38_t *req38)
 * @brief JSON文字列から仮想端末（体重トレンド）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req38 仮想端末（体重トレンド）構造体
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_req38(char *jfile, LcddataReq38_t *req38);

/**
 * @fn int comsv_json_lcd_req40(char *jfile, int thread_no, struct scn_data_fm *sp, LcddataReq40_t *req40)
 * @brief JSON文字列から仮想端末（透析日報）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[in] thread_no スレッド番号
 * @param[in,out] sp 装置制御データ
 * @param[out] req40 仮想端末（透析日報）構造体
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_req40(char *jfile, int thread_no, struct scn_data_fm *sp, LcddataReq40_t *req40);

/**
 * @fn int comsv_json_lcd_req41(char *jfile, LcddataReq41_t *req41)
 * @brief JSON文字列から仮想端末（投与薬剤）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req41 仮想端末（投与薬剤）構造体
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_req41(char *jfile, LcddataReq41_t *req41);

/**
 * @fn comsv_json_lcd_req41_getname(char *jfile, int no, char *name)
 * @brief JSON文字列から仮想端末（投与薬剤）の薬剤名称を取得する
 * @param[in] jfile JSONファイル名
 * @param[in] no 薬剤No
 * @param[out] name 薬剤名称（加工無し）
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_req41_getname(char *jfile, int no, char *name);

/**
 * @fn int comsv_json_lcd_req42(char *jfile, LcddataReq42_t *req42)
 * @brief JSON文字列から仮想端末（抗凝固剤）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req42 仮想端末（抗凝固剤）構造体
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_req42(char *jfile, LcddataReq42_t *req42);

/**
 * @fn int comsv_json_lcd_req44(char *jfile, LcddataReq45_t *req44)
 * @brief JSON文字列から仮想端末（禁忌）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req44 仮想端末（禁忌）構造体
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_req44(char *jfile, LcddataReq44_t *req44);

/**
 * @fn int comsv_json_lcd_req45(char *jfile, LcddataReq45_t *req45)
 * @brief JSON文字列から仮想端末（メモ）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req45 仮想端末（メモ）構造体
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_req45(char *jfile, LcddataReq45_t *req45);

/**
 * @fn int comsv_json_lcd_req46(char *jfile, short type, short gno, LcddataReq46_t *req46)
 * @brief JSON文字列から仮想端末（検査グラフ）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[in] type グラフ種類（0:通常,1:複合）
 * @param[in] gno グラフ番号（1〜5）
 * @param[out] req46 仮想端末（検査グラフ）構造体
 * @return 検査日件数, -1:エラー
 */
extern int comsv_json_lcd_req46(char *jfile, short type, short gno, LcddataReq46_t *req46);

/**
 * @fn int comsv_json_lcd_req47(char *jfile, short pos, LcddataReq47_t *req47)
 * @brief JSON文字列から仮想端末（レーダーチャート）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[in] pos 表示位置（検査日）
 * @param[out] req47 仮想端末（レーダーチャート）構造体
 * @return 検査日件数, -1:エラー
 */
extern int comsv_json_lcd_req47(char *jfile, short pos, LcddataReq47_t *req47);

/**
 * @fn int comsv_json_lcd_req50(char *jfile, LcddataReq50_t *req50)
 * @brief JSON文字列から仮想端末（愁訴処置）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req50 仮想端末（愁訴処置）構造体
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_req50(char *jfile, LcddataReq50_t *req50);

/**
 * @fn int comsv_json_lcd_req51(char *jfile, LcddataReq51_t *req51)
 * @brief JSON文字列から仮想端末（穿刺／回収／担当）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req51 仮想端末（穿刺／回収／担当）構造体
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_req51(char *jfile, LcddataReq51_t *req51);

/**
 * @fn int comsv_json_lcd_req52(char *jfile, LcddataReq52_t *req52, short page)
 * @brief JSON文字列から仮想端末（指示／特記）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req52 仮想端末（指示／特記）構造体
 * @param[in] page ページ番号
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_req52(char *jfile, LcddataReq52_t *req52, short page);

/**
 * @fn int comsv_json_lcd_req52_ex(char *jfile, LcddataReq52_t *req52, short page)
 * @brief JSON文字列から仮想端末（指示／特記）構造体に禁忌も含めて格納する
 * @param[in] jfile 指示／特記JSONファイル名
 * @param[in] jfile_ex 禁忌JSONファイル名
 * @param[out] req52 仮想端末（指示／特記）構造体
 * @param[in] page ページ番号
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_req52_ex(char *jfile, char *jfile_ex, LcddataReq52_t *req52, short page);

/**
 * @fn int comsv_json_lcd_req53(char *jfile, LcddataReq53_t *req53)
 * @brief JSON文字列から仮想端末（ＣＴＲトレンド）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req53 仮想端末（ＣＴＲトレンド）構造体
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_req53(char *jfile, LcddataReq53_t *req53);

/**
 * @fn int comsv_json_lcd_req54(char *jfile, LcddataReq54_t *req54)
 * @brief JSON文字列から仮想端末（チェックリスト）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req54 仮想端末（禁忌）構造体
 * @return 項目件数, -1:エラー
 */
extern int comsv_json_lcd_req54(char *jfile, LcddataReq54_t *req54);

/**
 * @fn int comsv_json_lcd_req56(char *jfile, LcddataReq56_t *req56)
 * @brief JSON文字列からレポート画像転送（過去レポート）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req56 レポート画像転送（過去レポート）構造体
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_req56(char *jfile, LcddataReq56_t *req56);

/**
 * @fn int comsv_json_lcd_cash(char *jfile, long dev_no)
 * @brief キャッシュJSONファイルから仮想端末JSONファイルを作成
 * @param[in] jfile キャッシュJSONファイル名
 * @param[in] dev_no 装置Ｎｏ
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_cash(char *jfile, long dev_no);

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_json_lcd_cash_upd32(long dev_no, short inp, long tim, long start, short amount, long cd, char *name)
// * @brief 仮想端末（酸素吸入）JSONファイルを更新する
// * @param[in] dev_no 装置Ｎｏ
// * @param[in] inp 入力区分（0:開始,1:終了）
// * @param[in] tim 現在時刻
// * @param[in] start 開始時刻
// * @param[in] amount 吸入量
// * @param[in] cd スタッフコード
// * @param[in] name スタッフ名
// * @return 0:成功, -1:エラー
// */
//extern int comsv_json_lcd_cash_upd32(long dev_no, short inp, long tim, long start, short amount, long cd, char *name);
/**
 * @fn int comsv_json_lcd_cash_upd32(long dev_no, short inp, time_t tim, time_t start, short amount, long cd, char *name)
 * @brief 仮想端末（酸素吸入）JSONファイルを更新する
 * @param[in] dev_no 装置Ｎｏ
 * @param[in] inp 入力区分（0:開始,1:終了）
 * @param[in] tim 現在時刻
 * @param[in] start 開始時刻
 * @param[in] amount 吸入量
 * @param[in] cd スタッフコード
 * @param[in] name スタッフ名
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_cash_upd32(long dev_no, short inp, time_t tim, time_t start, short amount, long cd, char *name);
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_json_lcd_cash_upd41(long dev_no, int chk, long tim)
// * @brief 仮想端末（投与薬剤）JSONファイルを更新する
// * @param[in] dev_no 装置Ｎｏ
// * @param[in] chk 入力状態（0:入力無し,1:入力有り）
// * @param[in] tim 現在時刻
// * @return 0:成功, -1:エラー
// */
extern int comsv_json_lcd_cash_upd41(long dev_no, int *chk, time_t tim);
/**
 * @fn int comsv_json_lcd_cash_upd41(long dev_no, int chk, long tim)
 * @brief 仮想端末（投与薬剤）JSONファイルを更新する
 * @param[in] dev_no 装置Ｎｏ
 * @param[in] chk 入力状態（0:入力無し,1:入力有り）
 * @param[in] tim 現在時刻
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_cash_upd41(long dev_no, int *chk, time_t tim);
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_json_lcd_cash_upd51(long dev_no, short inp, short no, long tim, long id, char *name)
// * @brief 仮想端末（穿刺／回収／担当）JSONファイルを更新する
// * @param[in] dev_no 装置Ｎｏ
// * @param[in] inp 入力区分（0:穿刺,1:回収,2:担当）
// * @param[in] no Ｎｏ（1,2）
// * @param[in] tim 現在時刻
// * @param[in] id スタッフID
// * @param[in] name スタッフ名
// * @return 0:成功, -1:エラー
// */
//extern int comsv_json_lcd_cash_upd51(long dev_no, short inp, short no, long tim, long id, char *name);
/**
 * @fn int comsv_json_lcd_cash_upd51(long dev_no, short inp, short no, time_t tim, long id, char *name)
 * @brief 仮想端末（穿刺／回収／担当）JSONファイルを更新する
 * @param[in] dev_no 装置Ｎｏ
 * @param[in] inp 入力区分（0:穿刺,1:回収,2:担当）
 * @param[in] no Ｎｏ（1,2）
 * @param[in] tim 現在時刻
 * @param[in] id スタッフID
 * @param[in] name スタッフ名
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_cash_upd51(long dev_no, short inp, short no, time_t tim, long id, char *name);
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_json_lcd_cash_upd54(long dev_no, short gno, int *chk, long tim)
// * @brief 仮想端末（チェックリスト）JSONファイルを更新する
// * @param[in] dev_no 装置Ｎｏ
// * @param[in] gno 画面Ｎｏ（1〜8）
// * @param[in] chk 入力状態（0:入力無し,1:入力有り）
// * @param[in] tim 現在時刻
// * @return 0:成功, -1:エラー
// */
//extern int comsv_json_lcd_cash_upd54(long dev_no, short gno, int *chk, long tim);
/**
 * @fn int comsv_json_lcd_cash_upd54(long dev_no, short gno, int *chk, time_t tim)
 * @brief 仮想端末（チェックリスト）JSONファイルを更新する
 * @param[in] dev_no 装置Ｎｏ
 * @param[in] gno 画面Ｎｏ（1〜8）
 * @param[in] chk 入力状態（0:入力無し,1:入力有り）
 * @param[in] tim 現在時刻
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_lcd_cash_upd54(long dev_no, short gno, int *chk, time_t tim);
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

/**
 * @fn int comsv_json_host_pat(char *jfile, HostWatchPat_t *watch)
 * @brief JSON文字列から患者ホスト報知定義構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] watch 患者ホスト報知定義構造体
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_host_pat(char *jfile, HostWatchPat_t *watch);

/**
 * @fn int comsv_json_host_make_medi(char *jdata, int no, struct scn_data_fm *sp)
 * @brief 未投与薬剤データからJSONデータを作成する
 * @param[out] jdata 出力JSONデータ
 * @param[in] no 薬剤No
 * @param[in] sp 装置制御データ
 * @return 0:成功, -1:エラー
 */
extern int comsv_json_host_make_medi(char *jdata, int no, struct scn_data_fm *sp);

// add FNSI-バグ 通信サーバ 高 start
/**
 * @fn int comsv_json_ordno_state(char *jfile, int *data)
 * @brief JSON文字列から患者情報送信データに格納する
 * @param[in] jfile JSONファイル名
 * @param[out] data 患者情報送信データ
 * @return 0:患者情報送信, -1:エラー
 */
extern int comsv_json_ordno_state(char *jfile, int *data);

/**
 * @fn int con_sock_search()
 * @brief 装置制御データの空きインデックス検索
 * @return 空きインデックス（DEV_MAX:空きなし） 
 */
extern int con_sock_search();
/**
 * @fn int client_device_key_search(long dev_no, u_char devsw, u_char *devSerial, u_char *deviceType)
 * @brief 装置制御データの対象装置インデックス検索
 * @param[in] dev_no 装置Ｎｏ
 * @param[in] devsw 通信フォーマット
 * @param[in] devSerial 製造番号
 * @param[in] deviceType 装置の型式コード
 * @return 対象装置インデックス（0:対象なし） 
 */
extern int client_device_key_search(long dev_no, u_char devsw, u_char *devSerial, u_char *deviceType);
// add FNSI-バグ 通信サーバ 高 end

#endif // _NTSS_SOCKET_H_
