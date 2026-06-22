/**
* @file comsv_info.h
* @brief 通信関連ヘッダー
* @author Y.Takamura
* @date 2018/10/01
*/

#ifndef _SCN_FM_H_
#define _SCN_FM_H_

#include "ntss_packet_manage.h"

/// @name 通信状態定義
//@{
#define	S_WAIT		0x00				///< 待ち状態
#define	S_SEND		0x01				///< 送信中
#define	S_RECV		0x02				///< 受信待ち
#define	S_STX		0x03				///< STX受信
#define	S_ETX		0x04				///< ETX受信
#define	S_END		0x80				///< 受信完了(正常終了)
#define	E_NOTCON	0x81				///< デバイス未接続
#define	E_TIMOUT	0x82				///< タイムアウトエラー
#define	E_BUFFOV	0x83				///< 受信バッファオーバーフロー
#define	E_CRCCHK	0x84				///< CRCエラー
#define	E_SNOCHK	0x85				///< シーケンシャルNo不一致
#define	E_CMDCHK	0x86				///< コマンドコード不一致
#define	E_DEVIDCHK	0x87				///< 装置識別番号不一致
#define	E_LENCHK	0x88				///< 受信データ長エラー
#define	E_END		0x90				///< 終了コードエラー
//@}

/// @name 通信の終了コード定義
//@{
#define	E_CRC		0x01				///< CRCエラー
#define	E_DEVID		0x02				///< 装置識別番号の不一致
#define	E_CMD		0x03				///< 不正コマンド
#define	E_ADDRESS	0x04				///< アドレスエラー
#define	E_DATANUM	0x05				///< データ数エラー
#define	E_DATAERR	0x06				///< データ異常
#define	E_NOWRITE	0x07				///< 書き込み不可
#define	E_NOTLOG	0x08				///< ログデータなし
#define	E_DELLOG	0x09				///< ログデータ消去エラー
//@}

/// @name 通信制御パラメータ定義
//@{
#define	RCVMAX		2048				///< 受信データ最大バイト数
#define	SNDMAX		2048				///< 送信データ最大バイト数
#define	TIMEOUT		10					///< タイムアウト値（10秒）
#define	CONTIME		60					///< コネクションインターバル（60秒）
//@}

/// @name 通信制御文字コード定義
//@{
#define	STX			0x02				///< 通信制御文字（STX）
#define	ETX			0x03				///< 通信制御文字（ETX）
#define	DLE			0x10                ///< 通信制御文字（DLE）
#define	DC2			0x12                ///< 通信制御文字（DC2）
#define	DC3			0x13                ///< 通信制御文字（DC3）
//@}

/// @name 通信コマンドレベル定義
//@{
#define	C_NOTOPE	0					///< 無
// #10542 2025.12.22 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start
/*
#define	C_OPTRD		1					///< オプション読み出し
#define	C_NEXTPAT	2					///< 次回透析患者情報の送信
#define	C_NEXTPAT2	3					///< 次回透析患者情報２の送信
#define	C_JSETRD	4					///< 透析条件読出し
#define	C_JSET		5					///< 条件設定
#define	C_KANSRD	6					///< 警報監視状態読出し
#define	C_CLOCK		7					///< 時計設定の設定
#define	C_DELETE	8					///< 画像データ削除
*/
#define	C_DELETE	1					///< 画像データ削除
#define	C_OPTRD		2					///< オプション読み出し
#define	C_NEXTPAT	3					///< 次回透析患者情報の送信
#define	C_NEXTPAT2	4					///< 次回透析患者情報２の送信
#define	C_JSETRD	5					///< 透析条件読出し
#define	C_JSET		6					///< 条件設定
#define	C_KANSRD	7					///< 警報監視状態読出し
#define	C_CLOCK		8					///< 時計設定の設定
// #10542 2025.12.22 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
#define	C_NOTICE	9					///< お知らせ情報転送
#define	C_MONITOR	10					///< モニタデータ読出し
#define	C_RESPONSE	11					///< レスポンスデータ送信
#define	C_REQMAX	12					///< 要求最大数
//@}

/// @name 通信コマンドデータ数定義
//@{
#define	MON1_NUM	100					///< 透析装置のモニタ項目数
#define	MON2_NUM	150					///< 透析装置('P','Q')のモニタ項目数
#define	MNT_NUM		66					///< 透析装置のメンテナンス項目数
#define	SET1_NUM	387					///< 透析装置装置('I','J')設定読出データ数
#define	SET2_NUM	400					///< 透析装置装置('M','N')設定読出データ数
#define	SET3_NUM	500					///< 透析装置装置('P','Q')設定読出データ数
#define ALERT_NUM	20					///< お知らせ通知データ数
//@}

// add AWSとDEの通信断からの復旧 高 start
/// @name 通信状態定義
//@{
#define COMM_STA0   0                   ///< 条件送信前
#define COMM_STA1   1                   ///< 条件送信済
#define COMM_STA2   2                   ///< 条件送信確認済み
#define COMM_STA3   3                   ///< 治療中
#define COMM_STA4   4                   ///< 排液済
#define COMM_STA5   5                   ///< 条件送信前+治療中
//@}
// add AWSとDEの通信断からの復旧 高 end


/**
 * @brief 装置制御データ
 */
struct scn_data_fm {
	long	dev_no;						///< 装置Ｎｏ
	short	dev_idx;					///< 装置マスタINDEX
	short	sock_id;					///< ソケットＮｏ
	char	ip_addr[16];				///< IPアドレス
	short	port_no;					///< ポート番号
	short	conflg;						///< 装置との接続状態（注１）
	unsigned short	option[5];			///< 装置オプション情報
	unsigned char	commType;			///< 通信方式
	unsigned char	deviceType[3];		///< 装置の型式コード
	unsigned char	devsw;				///< 通信フォーマット（I,J,M,N,P,Q,A,D,R,V,W）
	unsigned char	devid[8];			///< 装置の識別番号
	unsigned char	comflg;				///< 通信処理レベル
	unsigned char	staflg;				///< 通信状態
	unsigned char	sno;				///< シーケンシャルＮｏ
	// #10031 2023.12.01 mod 医器工V4タイムアウト設定による受信待ち対応 TDC高村 start
	//unsigned char	cmd;				///< コマンドコード
	unsigned char	cmd;				///< コマンドコード（共通プロトコルV4は通信処理レベル）
	// #10031 2023.12.01 mod 医器工V4タイムアウト設定による受信待ち対応 TDC高村 end
	unsigned char	reqflg[C_REQMAX];	///< 通信要求フラグ
	short	sndlen;						///< 送信データバイト数
	unsigned char	sndbuf[SNDMAX];		///< 送信データバッファ
	unsigned char	rcvdle;				///< 受信DLEフラグ
	short	rcvlen;						///< 受信データバイト数
	short	remp;						///< 残り受信データポインタ
	short	remlen;						///< 残り受信データバイト数
	unsigned char	rcvbuf[RCVMAX];		///< 受信データバッファ
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long	err_ltime;					///< 前回エラー発生時刻
	time_t	err_ltime;					///< 前回エラー発生時刻
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	short 	mon_sta;					///< 状態 (注２）
	short	first_sta;					///< 状態（初回起動時）
	short	lcd_request;				///< LCD リクエストコード
	short	lcd_argument1;				///< LCD 引数1
	short	lcd_argument2;				///< LCD 引数2
	short	lcd_argument3;				///< LCD 引数3
	short	alert_no;					///< お知らせ通知番号
	short	alert_time[ALERT_NUM];		///< お知らせ通知時間
	short	oxygen_sta;					///< 酸素吸入状況（0:使用前 1:使用中）
	short	oxygen_amount;				///< 酸素吸入量
	short	dial_time;					///< 透析時間
	short	facility_time;				///< 治療時間判定時間
	long	ord_no;						///< オーダー番号
	long	next_ord_no;				///< 次回オーダー番号
	long	pat_id;						///< 患者ID
	long	next_pat_id;				///< 次患者ID
	char	next_pat_name[20];			///< 次患者氏名
	char	jset_pat_name[20];			///< 条件送信用者氏名
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long  plan_start_date;			///< 透析開始予定日時
	//long  plan_end_date;				///< 透析終了予定日時
	char  cond_send_hash[64];           ///< 条件送信ハッシュ値
	//long  cond_send_ctrl;				///< 条件送信管理番号
	//long  cond_send_time;				///< 条件送信時刻（コマンド送信時刻）
	//long  cond_send_date;				///< 条件送信日時
	//long  cond_set_date;				///< 条件確認日時
	//long  dial_start_date;			///< 透析開始日時
	//long  dial_end_date;				///< 透析終了日時
	//// #10031 2023.12.01 mod 医器工V4タイムアウト設定による受信待ち対応 TDC高村 start
	////long	comptreat_date;				///< 愁訴処置実施日時
	//long	comptreat_date;				///< 愁訴処置実施日時（共通プロトコルV4は送信日時）
	//// #10031 2023.12.01 mod 医器工V4タイムアウト設定による受信待ち対応 TDC高村 end
	//long	oxygen_date;				///< 酸素吸入実施日時
	//long	medi_effect_date;			///< 投薬実施日時
	time_t  plan_start_date;			///< 透析開始予定日時
	time_t  plan_end_date;				///< 透析終了予定日時
	time_t  cond_send_ctrl;				///< 条件送信管理番号
	time_t	cond_send_time;				///< 条件送信時刻（コマンド送信時刻）
	time_t	cond_send_date;				///< 条件送信日時
	time_t	cond_set_date;				///< 条件確認日時
	time_t	dial_start_date;			///< 透析開始日時
	time_t	dial_end_date;				///< 透析終了日時
	time_t	comptreat_date;				///< 愁訴処置実施日時（共通プロトコルV4は送信日時）
	time_t	oxygen_date;				///< 酸素吸入実施日時
	time_t  medi_effect_date;			///< 投薬実施日時
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	unsigned char	kansrd_flg;			///< 警報監視除隊フラグ（0:装置側から任意,1:運転開始時）
	unsigned char	cond_read_flg;		///< 設定値読出フラグ（0:任意,1:条件送信時,2:運転開始時,3:排液時）
	unsigned char	cond_send_flg;		///< 条件送信フラグ（0:未送信,1:送信済）
	unsigned char	cond_send_cancel;	///< 条件送信キャンセル（0:無,1:有）
	unsigned char	cond_send_complete;	///< 条件送信処理完了フラグ（0:完了以外,1:完了）
	unsigned char	need_to_send;		///< 次患者情報送信有無（0:無し,1:有り）
	unsigned char	next_pat_send;		///< 次患者送信（0:タイミング,1:イベント）
    // #12301 2025.10.28 del 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start
    // unsigned char	ftp_clear_flg;		///< FTP画像削除フラグ（0:無し,1:接続確立,2:後体重測定）
    // #12301 2025.10.28 del 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
	unsigned char	notice_chg_flg;		///< 投薬指示変更（0:指示無し,1:指示有り）
	// add 装置のSTATUS状態更新方法の変更 高 start
	u_char  machineState[2];            ///< 装置のSTATUS状態[0：現在/1：前回]
	// add 装置のSTATUS状態更新方法の変更 高 end
	// add ？？？？患者発生時の次患者情報送信#1437 高 start
	short unregistered_flg;             ///< 未登録フラグ（0:登録,1:未登録）
	// add ？？？？患者発生時の次患者情報送信#1437 高 end
	// add 通信共通プロトコル（V3/V4）患者IDが異なる 高 start
	char	hosp_pat_id[12];			///< 院内表示用の患者ID
	// add 通信共通プロトコル（V3/V4）患者IDが異なる 高 end
	// add 強制オフライン 高 start
	short treatment;                    ///< 治療モード
	short force_flg;                    ///< 強制オフラインフラグ（0:無し,1:有り）
	int   force_dial_time;              ///< 強制オフライン透析時間
	short force_offline_wait;           ///< 強制オフラインwait時間
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long  force_offline_time;           ///< 強制オフライン時間
	time_t  force_offline_time;         ///< 強制オフライン時間
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	short force_cond_flg;               ///< 強制オフライン 条件送信フラグ（0:未送信,1:条件送信時）
	// add 強制オフライン 高 end
	// add AWSとDEの通信断からの復旧 高 start
	short current_mon_sta[2];           ///< current状態
	short mon_sta_commfail;             ///< Fail状態
	long  ord_no_commfail;              ///< Failオーダー番号
	int   comm_alive_state;             ///< COMM_ALIVE_STATE
	char collect_file_name[256];        ///< collect file name
	// add AWSとDEの通信断からの復旧 高 end
	// add 透析患者さんのレポート画面を差入れする 高 start
	long  ord_no_bmp;                   ///< オーダー番号
	// add 透析患者さんのレポート画面を差入れする 高 end
	// add FNSI-バグ 通信サーバ 高 start
	short device_comm_flg;              ///< device comm error フラグ（0:無し,1:有り）
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long  de_comm_start_date;           ///< 透析開始日時
	//long  de_comm_end_date;             ///< 透析終了日時
	time_t  de_comm_start_date;         ///< 透析開始日時
	time_t  de_comm_end_date;           ///< 透析終了日時
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	short treat_time;                   ///< 透析時間
	time_t  last_disp_time;             ///< ＬＣＤデータ処理日時
	short last_lcd_request;             ///< LCD リクエストコード
	short last_lcd_argument1;           ///< LCD 引数1
	// add FNSI-バグ 通信サーバ 高 end
	// #8266 2023.03.29 add ログシーケンシャルＮｏによる重複チェック TDC高村 start
	unsigned char	log_sno;			///< ログシーケンシャルＮｏ
	unsigned char	is_check_log_sno;	///< ログシーケンシャルＮｏのチェックを行う（しない:0,する:1）
	// #8266 2023.03.29 add ログシーケンシャルＮｏによる重複チェック TDC高村 end
	// #10844 2024.07.29 add DB高負荷状態の時に????患者が複数生成される TDC高村 start
	short thread_unregistered;          ///< 患者未登録運転スレッド処理（0:未処理,1〜3:処理中）
	short thread_unregistered_sta;      ///< 患者未登録運転スレッド処理（装置ステータス）
	int thread_unregistered_no;         ///< 患者未登録運転スレッド処理（スレッド番号）
	// #10844 2024.07.29 add DB高負荷状態の時に????患者が複数生成される TDC高村 end
	// #11192 2025.04.02 add 治療終了指示に含まれたオーダー番号 TDC片口 start
	long received_end_treat_ord_no;
	// #11192 2025.04.02 add 治療終了指示に含まれたオーダー番号 TDC片口 end
};

/* conflg  装置との接続状態（注１）		*/
/*  0 : 未接続							*/
/* 	1 : 接続(connect ok)				*/
/* 	2 : 通信OK							*/
/* 	-1 : Error(SocketClose要求)			*/
/* 	-7 : gethostbyname Error			*/ 
/* 	-8 : socket Error					*/
/* 	-9 : オフライン						*/

/* mon_sta 状態(注２)    表示優先度		*/
/* 	bit0 : 透析中				8		*/
/* 	bit1 : 洗消中				9		*/ 
/* 	bit2 : 準備中				10		*/
/* 	bit3 : 警報発生中			2		*/
/* 	bit4 : 警報確認				3		*/
/* 	bit5 : 報知発生中			4		*/
/* 	bit6 : 報知確認				5		*/
/* 	bit7 : ホスト報知発生中		6		*/
/* 	bit8 : ホスト報知確認		7		*/
/* 	bit15: 通信異常				1		*/ 

/**
 * @brief 患者ホスト報知定義構造体
 */
typedef struct {
	short	addr;						///< モニタ項目アドレス
	short	upper;						///< 上限値（小数点除去）
	short	lower;						///< 下限値（小数点除去）
	char	judge;						///< 監視（有効:1,無効:0）
} HostWatchPat_t;

/**
 * @brief 共通プロトコル通信用リクエスト間隔（秒）
 */
extern int req_time_cp;

/**
 * @brief REST_DEVICE_EDGE_URL
 */
extern	u_char rest_device_edge_url[150];

/**
 * @brief REST_WEB_API_URL
 */
extern	u_char rest_web_api_url[150];

// add AWSとDEの通信断からの復旧 高 start
/**
 * @brief ALIVE_MONI_URL
 */
extern	u_char alive_moni_url[150];
// add AWSとDEの通信断からの復旧 高 end

/**
 * @brief 施設コード
 */
extern	u_char facility_cd[8];

/**
 * @brief デバイスエッジ番号
 */
extern	uint32_t device_edge_no;

/**
 * @brief パケット管理情報配列
 */
extern struct NTSS_PACKET_INFORMATION packetInfoList[NTSS_PACKET_INFORMATION_COUNT];

/**
* @fn void *comsv_stream(void *ptr)
* @brief 新通信用スレッド処理
* @param[in,out] ptr 装置制御データ
* @return void* 
*/
extern void *comsv_stream(void *ptr);

/**
* @fn void *comsv_stream_nx(void *ptr)
* @brief NX通信用スレッド処理
* @param[in,out] ptr 装置制御データ
* @return void* 
*/
extern void *comsv_stream_nx(void *ptr);

/**
* @fn void *comsv_stream_nx(void *ptr)
* @brief NX通信用スレッド処理
* @param[in,out] ptr 装置制御データ
* @return void* 
*/
extern void *comsv_stream_cp(void *ptr);

/**
* @fn void *comsv_stream_off(void *ptr)
* @brief オフライン装置用スレッド処理
* @param[in,out] ptr 装置制御データ
* @return void* 
*/
extern void *comsv_stream_off(void *ptr);

/**
 * @fn void comsv_rcvset(struct scn_data_fm *sp, u_char *buf, int len)
 * @brief 受信データ解析処理（新通信＆NX通信用）
 * @param[in,out] sp 装置制御データ
 * @param[in] buf 受信データ 
 * @param len 受信データ長
 */
extern void comsv_rcvset(struct scn_data_fm *sp, u_char *buf, int len);

/**
 * @fn void comsv_rcvset_cp(struct scn_data_fm *sp, u_char *buf, int len)
 * @brief 受信データ解析処理（共通プロトコル用）
 * @param[in,out] sp 装置制御データ
 * @param[in] buf 受信データ 
 * @param len 受信データ長
 */
extern void comsv_rcvset_cp(struct scn_data_fm *sp, u_char *buf, int len);

/**
 * @fn void comsv_clear(int timing, struct scn_data_fm *sp)
 * @brief 状況に応じた装置制御データのクリア
 * @param[in] timing タイミング（0:条件送信,1:透析開始,2:版確定,3:条件キャンセル,4:次患者条件送信）
 * @param[in,out] sp 装置制御データ
 */
extern void comsv_clear(int timing, struct scn_data_fm *sp);

/**
 * @fn void comsv_host_watch_init(int thread_no)
 * @brief ホスト報知監視開始待ち時間の初期化
 * @param[in] thread_no スレッド番号
*/
extern void comsv_host_watch_init(int thread_no);

/**
 * @fn int comsv_host_watch(int thread_no, struct scn_data_fm *sp)
 * @brief ホスト報知定義の取得・設定（装置共通）
 * @param[in] thread_no スレッド番号
 * @param[in,out] sp 装置制御データ
 * @return 1：設定成功/0：設定不要(設定なし含む)
*/
extern int comsv_host_watch(int thread_no, struct scn_data_fm *sp);

/**
* @fn int comsv_notice_check(struct scn_data_fm *sp)
* @brief お知らせ情報転送チェック（装置共通）
* @param[in,out] sp 装置制御データ
* @return 1：実施有り/0：実施無し
*/
extern int comsv_notice_check(struct scn_data_fm *sp);

/**
 * @fn void comsv_scn_output(struct scn_data_fm *sp)
 * @brief 装置制御データ（各種状態）のログ出力
 * @param[in,out] sp 装置制御データ
 */
extern void comsv_scn_output(struct scn_data_fm *sp);

// #9110 2023.08.09 add VA・レポート画像の要求削減(送付不要な装置は処理しない) TDC高村 start
/**
 * @fn int getMachineIsVa(short dev_idx)
 * @brief 装置の画像転送可否を取得
 * @param[in] devIdx 装置マスタINDEX
 * @return 1：画像を転送する/0：画像を転送しない
*/
extern int getMachineIsVa(short devIdx);
// #9110 2023.08.09 add VA・レポート画像の要求削減(送付不要な装置は処理しない) TDC高村 end

// #10542 2025.12.22 add 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start
/**
 * @fn int checkMachineIsVa(struct scn_data_fm *sp)
 * @brief 装置の画像転送可否チェック
 * @param[in] sp 装置制御データ
 * @return -1:対象外装置 0:画像転送なし 1：画像転送あり
*/
extern int checkMachineIsVa(struct scn_data_fm *sp);
// #10542 2025.12.22 add 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end

/**
* @fn int comsv_cmd(int thread_no, struct scn_data_fm *sp)
* @brief 新通信コマンド作成
* @param[in] thread_no スレッド番号
* @param[in,out] sp 装置制御データ
* @return int 送信コマンド長
* @details 新通信装置に送信するコマンド作成
*/
extern int comsv_cmd(int thread_no, struct scn_data_fm *sp);

/**
* @fn int comsv_cmd_fileio(char *fname, int mode, unsigned char *data, int len)
* @brief コマンドデータ読込
* @param[in] fname ファイルパス
* @param[in] mode モード（0:Read.1:Write）
* @param[out] data データ格納用
* @param[in] len 読み込みサイズ
* @return 0:成功, -1:エラー
* @details コマンドデータをファイルから読み込む
*/
extern int comsv_cmd_fileio(char *fname, int mode, unsigned char *data, int len);

/**
* @fn int comsv_cmd_npat2_check(struct scn_data_fm *sp)
* @brief 次患者情報２の送信可否チェック
* @param[in,out] sp 装置制御データ
* @return 0:送信不可, 1:送信可能
* @details 次患者情報２が送信可能かチェックする
*/
extern int comsv_cmd_npat2_check(struct scn_data_fm *sp);

/**
* @fn void comsv_cmd_cond_change(struct scn_data_fm *sp, unsigned char *data)
* @brief 条件送信データを対象装置・設定内容に応じて変更
* @param[in] sp 装置制御データ
* @param[out] data 設定値データ
* @details 条件送信データ（設定値）を対象装置・設定内容に応じて変更する
*/
extern void comsv_cmd_cond_change(struct scn_data_fm *sp,  unsigned char *data);

/**
* @fn int comsv_cmd_nx(struct scn_data_fm *sp)
* @brief NX通信コマンド作成
* @param[in,out] sp 装置制御データ
* @return int 送信コマンド長
* @details NX通信装置に送信するコマンド作成
*/
extern int comsv_cmd_nx(struct scn_data_fm *sp);

/**
* @fn int comsv_cmd_cp(struct scn_data_fm *sp)
* @brief 共通プロトコル通信コマンド作成
* @param[in,out] sp 装置制御データ
* @return int 送信コマンド長
* @details 共通プロトコル通信装置に送信するコマンド作成
*/
extern int comsv_cmd_cp(struct scn_data_fm *sp);

/**
* @fn void comsv_rcv(int thread_no, struct scn_data_fm *sp)
* @brief 新通信受信データ処理
* @param[in] thread_no スレッド番号
* @param[in,out] sp 装置制御データ
* @details 新通信装置から受信したデータ処理
*/
extern void comsv_rcv(int thread_no, struct scn_data_fm *sp);

/**
* @fn void	comsv_rcv_reset( struct scn_data_fm *sp )
* @brief 受信コマンドによる要求リセット
* @param[in,out] sp 装置制御データ
* @details 受信コマンドによる要求リセット処理
*/
extern void comsv_rcv_reset(struct scn_data_fm *sp);

/**
* @fn void	comsv_reqflg_reset( struct scn_data_fm *sp )
* @brief 要求フラフ全リセット
* @param[in,out] sp 装置制御データ
* @details 要求フラフ全リセット処理
*/
extern void comsv_reqflg_reset(struct scn_data_fm *sp);

/**
 * @fn int comsv_rcv_option_write(struct scn_data_fm *scn)
 * @brief 装置マスタのオプション更新（新通信用）
 * @param[in] scn 装置制御データ
 * @return 0 成功
 * @return -1 失敗
 */
extern int comsv_rcv_option_write(struct scn_data_fm *scn);

/**
* @fn void comsv_rcv_cp(int thread_no, struct scn_data_fm *sp)
* @brief 共通プロトコル受信データ処理
* @param[in] thread_no スレッド番号
* @param[in,out] sp 装置制御データ
* @details 共通プロトコル装置から受信したデータ処理
*/
extern void comsv_rcv_cp(int thread_no, struct scn_data_fm *sp);

/**
* @fn void comsv_mon(int sw, int thread_no, struct scn_data_fm *sp)
* @brief 新通信のモニタデータ処理（ステータス／モニタ／ログ）
* @param[in] sw 種別（0:ステータス 1:モニタ 2:ログ）
* @param[in] thread_no スレッド番号
* @param[in,out] sp 装置制御データ
* @details 新通信装置から受信したモニタデータ処理（ステータス／モニタ／ログ）
*/
extern void comsv_mon(int sw, int thread_no, struct scn_data_fm *sp);

/**
* @fn void comsv_mon_cp(struct scn_data_fm *sp)
* @brief 共通プロトコルの装置状態データ処理
* @param[in] thread_no スレッド番号
* @param[in,out] sp 装置制御データ
* @details 共通プロトコル装置から受信した装置状態データ処理
*/
extern void comsv_mon_cp(int thread_no, struct scn_data_fm *sp);

/**
* @fn void comsv_log(unsigned char *logdata, struct scn_data_fm *sp)
* @brief 通信データ処理（ログデータ）
* @param[in] logdata 受信ログデータ
* @param[in,out] sp 装置制御データ
* @details 装置から受信したログデータ処理
*/
extern void comsv_log(unsigned char *logdata, struct scn_data_fm *sp);

/**
 * @fn int comsv_bmp_post(long device_no, unsigned char *devCd, unsigned char *devId, long ordNo, short type)
 * @brief 画像転送用のイメージ（ＢＭＰ）を取得する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] type 画像タイプ（0:ＶＡ、1:レポート）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_bmp_post(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short type);

/**
 * @fn int comsv_ftp_put(long devNo, unsigned char *devCd, unsigned char *devId, char *url, short type, char *upFile) 
 * @brief 画像データ（ＶＡ、レポート）をFTPでアップロードする
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] url ホスト名（FTPサーバのIPアドレス）
 * @param[in] type 画像タイプ（0:ＶＡ、1:レポート）
 * @param[in] upFile アップロードファイル名
 * @return 0:成功, -1:エラー
 */
extern int comsv_ftp_put(long devNo, unsigned char *devCd, unsigned char *devId, char *url, short type, char *upFile);

// #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 start
///**
//* @fn void comsv_bmp_remove(long dev_no)
//* @brief ビットマップファイル削除
//* @param[in] dev_no 装置番号
//* @details ビットマップファイルを全て削除する
//*/
//extern void comsv_bmp_remove(long dev_no);
/**
* @fn void comsv_bmp_remove(long dev_no, unsigned char *devCd, unsigned char *devId)
* @brief ビットマップファイル削除
* @param[in] dev_no 装置番号
* @param[in] devCd  型式コード
* @param[in] devId  製造番号
* @details ビットマップファイルを全て削除する
*/
extern void comsv_bmp_remove(long dev_no, unsigned char *devCd, unsigned char *devId);

/**
 * @fn int comsv_rest_exec(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix 
 * @brief RESTを実行して結果を取得する
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] restStr REST実行文字列
 * @param[in] resFile レスポンスファイル名
 * @param[in] errFile エラーファイル名
 * @param[in] logPrefix ログ文字列の先頭に付与するテキスト
 * @return 0:成功, その他:エラー
 */
extern int comsv_rest_exec(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix);

// #11367 2025.01.10 add 仮想端末用REST処理の見直し TDC高村 start
/**
 * @fn int comsv_rest_exec_ex(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix, int retryCnt, int waitTime)
 * @brief RESTを実行して結果を取得する
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] restStr REST実行文字列
 * @param[in] resFile レスポンスファイル名
 * @param[in] errFile エラーファイル名
 * @param[in] logPrefix ログ文字列の先頭に付与するテキスト
 * @param[in] retryCnt 再試行回数
 * @param[in] waitTime 再試行待ち時間
 * @return 0:成功, その他:エラー
 */
extern int comsv_rest_exec_ex(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix, int retryCnt, int waitTime);
// #11367 2025.01.10 add 仮想端末用REST処理の見直し TDC高村 end

/**
 * @fn int comsv_rest_get_mst(short mstType, char *datFile)
 * @brief マスタデータ（通信サーバ設定、装置、チェックリスト、検査項目）を取得する
 * @param[in] mstType マスタタイプ（0:通信サーバ設定 1:装置 2:チェクリスト 3:検査項目）
 * @param[in] datFile データ取得ファイル
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_get_mst(short mstType, char *datFile);

/**
 * @fn int comsv_rest_get_dev(long devNo, unsigned char *devCd, unsigned char *devId, char *datFile)
 * @brief 装置状態管理データを取得する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] datFile データ取得ファイル
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_get_dev(long devNo, unsigned char *devCd, unsigned char *devId, char *datFile);

/**
 * @fn int comsv_rest_get_ord(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, char *datFile)
 * @brief 治療情報データを取得する
 * @param[in] devNo 装置番号
 * @param[in] devType 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] datFile データ取得ファイル
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_get_ord(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, char *datFile);

/**
 * @fn int comsv_rest_get_lcd(long devNo, unsigned char *devCd, unsigned char *devId, short reqCd, unsigned char *param, char *datFile)
 * @brief LCD表示データを取得する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] reqCd LCDリクエストコード
 * @param[in] param データ取得キー（TAB区切りで最大5つまで）
 * @param[in] datFile データ取得ファイル
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_get_lcd(long devNo, unsigned char *devCd, unsigned char *devId, short reqCd, unsigned char *param, char *datFile);

/**
 * @fn int comsv_rest_get_past(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, char *datFile)
 * @brief 指定オーダ番号から直近・同一曜日で過去３回分のオーダ情報を取得する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] datFile データ取得ファイル
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_get_past(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, char *datFile);

/**
 * @fn int comsv_rest_get_host(ong devNo, unsigned char *devCd, unsigned char *devId, long patId, char *datFile)
 * @brief 患者ホスト報知定義を取得する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] patId 患者ID
 * @param[in] datFile データ取得ファイル
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_get_host(long devNo, unsigned char *devCd, unsigned char *devId, long patId, char *datFile);

// #11367 2025.01.09 add 次患者情報のJSONデータ取得処理変更 TDC高村 start
/**
 * @fn int comsv_npat_getbuffer(char *jfile, type type, char *buffer)
 * @brief JSON文字列から次患者情報データ部を取得する
 * @param[in] jfile JSONファイル名
 * @param[in] type 次患者情報タイプ（1,2）
 * @param[in] buffer 取得文字列
 * @return 0:成功, -1:エラー
 */
extern int comsv_npat_getbuffer(char *jfile, short type, char *buffer);
// #11367 2025.01.09 add 次患者情報のJSONデータ取得処理変更 TDC高村 end

/**
 * @fn int comsv_rest_put_option(long devNo, unsigned char *devCd, unsigned char *devId, unsigned short *option)
 * @brief 装置マスタのオプションデータを更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] option 装置オプション
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_put_option(long devNo, unsigned char *devCd, unsigned char *devId, unsigned short *option);

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_put_dev_date(long devNo, unsigned char *devCd, unsigned char *devId, short inpType, short state, long date)
// * @brief 装置状態管理の日付データを更新する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] inpType 入力種別（0:条件送信日時,1:条件確認日時,2:透析開始日時,3:透析終了日時）
// * @param[in] state 装置ステータス
// * @param[in] date 日付
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//extern int comsv_rest_put_dev_date(long devNo, unsigned char *devCd, unsigned char *devId, short inpType, short state, long date);
/**
 * @fn int comsv_rest_put_dev_date(long devNo, unsigned char *devCd, unsigned char *devId, short inpType, short state, time_t date)
 * @brief 装置状態管理の日付データを更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] inpType 入力種別（0:条件送信日時,1:条件確認日時,2:透析開始日時,3:透析終了日時）
 * @param[in] state 装置ステータス
 * @param[in] date 日付
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_put_dev_date(long devNo, unsigned char *devCd, unsigned char *devId, short inpType, short state, time_t date);
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_put_ord_date(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short inpType, long patId, short state, long date)
// * @brief 治療情報の日付データを更新する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] ordNo オーダー番号
// * @param[in] inpYype 入力種別（0:条件送信日時,1:透析開始日時,2:透析終了日時）
// * @param[in] patId 患者ID
// * @param[in] state 治療状況
// * @param[in] date 日付
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//extern int comsv_rest_put_ord_date(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short inpType, long patId, short state, long date);
/**
 * @fn int comsv_rest_put_ord_date(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short inpType, long patId, short state, time_t date)
 * @brief 治療情報の日付データを更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] inpYype 入力種別（0:条件送信日時,1:透析開始日時,2:透析終了日時）
 * @param[in] patId 患者ID
 * @param[in] state 治療状況
 * @param[in] date 日付
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_put_ord_date(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short inpType, long patId, short state, time_t date);
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_put_ord_comptreat_staff(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long occur_date, long staff_cd)
// * @brief 治療情報の実績愁訴処置者情報を更新する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] ordNo オーダー番号
// * @param[in] occur_date 発生日時
// * @param[in] staff_cd 処置者コード
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//extern int comsv_rest_put_ord_comptreat_staff(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long occur_date, long staff_cd);
/**
 * @fn int comsv_rest_put_ord_comptreat_staff(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t occur_date, long staff_cd)
 * @brief 治療情報の実績愁訴処置者情報を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] occur_date 発生日時
 * @param[in] staff_cd 処置者コード
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_put_ord_comptreat_staff(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t occur_date, long staff_cd);
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_put_ord_user(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short inpType, short inpNo, long userId, long date)
// * @brief 治療情報の穿刺者／返血者／担当者情報を更新する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] ordNo オーダー番号
// * @param[in] inpType 入力種別（0:穿刺者,1:返血者,2:担当者）
// * @param[in] inpNo 入力番号（1,2）
// * @param[in] userId 処置者ID
// * @param[in] date 日付
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//extern int comsv_rest_put_ord_user(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short inpType, short inpNo, long userId, long date);
/**
 * @fn int comsv_rest_put_ord_user(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short inpType, short inpNo, long userId, time_t date)
 * @brief 治療情報の穿刺者／返血者／担当者情報を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] inpType 入力種別（0:穿刺者,1:返血者,2:担当者）
 * @param[in] inpNo 入力番号（1,2）
 * @param[in] userId 処置者ID
 * @param[in] date 日付
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_put_ord_user(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short inpType, short inpNo, long userId, time_t date);
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_put_ord_oxygen(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long occur_date, long start_date, short amount)
// * @brief 治療情報の酸素吸入情報を更新する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] ordNo オーダー番号
// * @param[in] occur_date 発生日時
// * @param[in] start_date 酸素吸入開始日時
// * @param[in] amount 酸素吸入量
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//extern int comsv_rest_put_ord_oxygen(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long occur_date, long start_date, short amount);
/**
 * @fn int comsv_rest_put_ord_oxygen(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t occur_date, time_t start_date, short amount)
 * @brief 治療情報の酸素吸入情報を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] occur_date 発生日時
 * @param[in] start_date 酸素吸入開始日時
 * @param[in] amount 酸素吸入量
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_put_ord_oxygen(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t occur_date, time_t start_date, short amount);
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_put_ord_oxygen_staff(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long occur_date, long staff_cd)
// * @brief 治療情報の酸素吸入処置者情報を更新する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] ordNo オーダー番号
// * @param[in] occur_date 発生日時
// * @param[in] staff_cd 処置者コード
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//extern int comsv_rest_put_ord_oxygen_staff(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long occur_date, long staff_cd);
/**
 * @fn int comsv_rest_put_ord_oxygen_staff(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t occur_date, long staff_cd)
 * @brief 治療情報の酸素吸入処置者情報を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] occur_date 発生日時
 * @param[in] staff_cd 処置者コード
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_put_ord_oxygen_staff(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t occur_date, long staff_cd);
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_put_ord_medi_user(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long user_id, long date)
// * @brief 治療情報の実績投与薬剤実施者を更新を更新する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] ordNo オーダー番号
// * @param[in] user_id 投与実施者コード
// * @param[in] date 投与実施日時
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//extern int comsv_rest_put_ord_medi_user(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long user_id, long date);
/**
 * @fn int comsv_rest_put_ord_medi_user(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long user_id, time_t date)
 * @brief 治療情報の実績投与薬剤実施者を更新を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] user_id 投与実施者コード
 * @param[in] date 投与実施日時
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_put_ord_medi_user(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long user_id, time_t date);
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_put_unregistered(long devNo, unsigned char *devCd, unsigned char *devId, short devSta, short state, long date)
// * @brief 治療情報を登録（患者未登録運転）する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] devSta 装置ステータス
// * @param[in] state 治療状況
// * @param[in] date 日付
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//extern int comsv_rest_put_unregistered(long devNo, unsigned char *devCd, unsigned char *devId, short devSta, short state, long date);
/**
 * @fn int comsv_rest_put_unregistered(long devNo, unsigned char *devCd, unsigned char *devId, short devSta, short state, time_t date)
 * @brief 治療情報を登録（患者未登録運転）する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] devSta 装置ステータス
 * @param[in] state 治療状況
 * @param[in] date 日付
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_put_unregistered(long devNo, unsigned char *devCd, unsigned char *devId, short devSta, short state, time_t date);
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

/**
 * @fn int comsv_rest_put_scale_state(long devNo, unsigned char *devCd, unsigned char *devId, long scaleNo, short msgNo) 
 * @brief 体重計測定実績のステータス・メッセージデータを更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] scaleNo 条件送信管理番号
 * @param[in] msgNo メッセージ番号
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_put_scale_state(long devNo, unsigned char *devCd, unsigned char *devId, long scaleNo, short msgNo);

/**
 * @fn int comsv_rest_put_pat_related(long devNo, unsigned char *devCd, unsigned char *devId, long patId, short mode, long ordNo, short status) 
 * @brief 患者基本情報関連（ステータス・透析回数）を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] patId 患者ID
 * @param[in] mode モード（0:ステータス,1:透析回数）
 * @param[in] ordNo オーダー番号（モードが1の場合は使用しない(0)）
 * @param[in] status ステータス（モードが1の場合は使用しない(0)）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_put_pat_related(long devNo, unsigned char *devCd, unsigned char *devId, long patId, short mode, long ordNo, short status);

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_post_ord_cond(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long date, int treat, char *upData)
// * @brief 設定値読み込み履歴を更新する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] ordNo オーダー番号
// * @param[in] date 条件取得日時
// * @param[in] treat 区分（0:条件送信前,1:条件送信,2:運転開始,3:排液検出,4:任意）
// * @param[in] upData アップロードデータ／ファイル（json）
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//extern int comsv_rest_post_ord_cond(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long date, int treat, char *upData);
/**
 * @fn int comsv_rest_post_ord_cond(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t date, int treat, char *upData)
 * @brief 設定値読み込み履歴を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] date 条件取得日時
 * @param[in] treat 区分（0:条件送信前,1:条件送信,2:運転開始,3:排液検出,4:任意）
 * @param[in] upData アップロードデータ／ファイル（json）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_post_ord_cond(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t date, int treat, char *upData);
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

/**
 * @fn int comsv_rest_post_ord_moni(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, char *upData)
 * @brief 治療情報の実績モニタ値を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] upData アップロードデータ／ファイル（json）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_post_ord_moni(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, char *upData);

/**
 * @fn int comsv_rest_post_ord_log(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short type, char *upData, u_char *occurDateTime)
 * @brief 治療情報の実績ログ（測定データ）を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] type ログタイプ（0:その他,1:再循環率測定,2:I-HDF引き残し量,3:静的静脈圧,4:IAP retio）
 * @param[in] upData アップロードデータ／ファイル（json）
 * @param[in] occurDateTime 装置からの発生日時
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
// mod 治療完了後、I-HDFの引き残し記録を別途で登録要 高 start
// extern int comsv_rest_post_ord_log(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short type, char *upData);
extern int comsv_rest_post_ord_log(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short type, char *upData, u_char *occurDateTime);
// mod 治療完了後、I-HDFの引き残し記録を別途で登録要 高 end

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_post_ord_comptreat(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long date, char *upData)
// * @brief 治療情報の実績愁訴・愁訴処置情報を更新する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] ordNo オーダー番号
// * @param[in] date 投与実施日時
// * @param[in] upData アップロードデータ／ファイル（json）
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//extern int comsv_rest_post_ord_comptreat(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long date, char *upData);
/**
 * @fn int comsv_rest_post_ord_comptreat(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t date, char *upData)
 * @brief 治療情報の実績愁訴・愁訴処置情報を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] date 投与実施日時
 * @param[in] upData アップロードデータ／ファイル（json）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_post_ord_comptreat(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t date, char *upData);
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_post_ord_medi(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long date, char *upData)
// * @brief 治療情報の実績投与薬剤情報を更新する
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] ordNo オーダー番号
// * @param[in] date 投与実施日時
// * @param[in] upData アップロードデータ／ファイル（json）
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//extern int comsv_rest_post_ord_medi(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long date, char *upData);
/**
 * @fn int comsv_rest_post_ord_medi(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t date, char *upData)
 * @brief 治療情報の実績投与薬剤情報を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] date 投与実施日時
 * @param[in] upData アップロードデータ／ファイル（json）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_post_ord_medi(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t date, char *upData);
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

// #11367 2025.01.10 add 仮想端末用REST処理の見直し TDC高村 start
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_rest_post_ord_medi_ex(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long date, char *upData)
// * @brief 治療情報の実績投与薬剤情報を更新する（RESTエラー時の応答を早く返す）
// * @param[in] devNo 装置番号
// * @param[in] devCd 型式コード
// * @param[in] devId 製造番号
// * @param[in] ordNo オーダー番号
// * @param[in] date 投与実施日時
// * @param[in] upData アップロードデータ／ファイル（json）
// * @return 0:成功, -1:エラー, -2:取得失敗
// */
//extern int comsv_rest_post_ord_medi_ex(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, long date, char *upData);
/**
 * @fn int comsv_rest_post_ord_medi_ex(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t date, char *upData)
 * @brief 治療情報の実績投与薬剤情報を更新する（RESTエラー時の応答を早く返す）
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] date 投与実施日時
 * @param[in] upData アップロードデータ／ファイル（json）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_post_ord_medi_ex(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, time_t date, char *upData);
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
// #11367 2025.01.10 add 仮想端末用REST処理の見直し TDC高村 end

/**
 * @fn int comsv_rest_post_ord_check(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short sendFlg, short listCd, char *upData)
 * @brief 治療情報のチェックリスト実績情報を更新する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] sendFlg 条件送信フラグ
 * @param[in] listCd リストコード
 * @param[in] upData アップロードデータ／ファイル（json）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_post_ord_check(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short sendFlg, short listCd, char *upData);

/**
 * @fn int comsv_rest_post_web_api(long devNo, unsigned char *devCd, unsigned char *devId, short apiNo)
 * @brief 現患者クリア、次患者更新、条件送信結果処理を行う
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] apiNo API番号（0:現患者クリアAPI,1:次患者更新API,2:条件送信結果処理API）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_post_web_api(long devNo, unsigned char *devCd, unsigned char *devId, short apiNo);

/**
 * @fn int comsv_rest_post_reload_npat(char *upData)
 * @brief 一斉次患者更新処理を行う
 * @param[in] upData アップロードデータ（json）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_post_reload_npat(char *upData);

/**
 * @fn int comsv_rest_post_send_cond(char *upData)
 * @brief 条件送信完了時の一連処理を行う
 * @param[in] devNo 装置番号
 * @param[in] upData アップロードファイル（json）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_post_send_cond(struct scn_data_fm *sp);

/**
 * @fn int comsv_rest_post_all_status(char *upData)
 * @brief 装置状態管理の装置ステータス一括更新処理を行う
 * @param[in] upData アップロードデータ（json）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_post_all_status(char *upData);

/**
 * @fn int comsv_rest_post_notice_medi(long devNo, unsigned char *devCd, unsigned char *devId, char *upData)
 * @brief 投薬タイミング通知処理を行う
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] upData アップロードデータ（json）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_post_notice_medi(long devNo, unsigned char *devCd, unsigned char *devId, char *upData);

/**
* @fn void comsv_thread_lcd_input(void *ptr)
* @brief ＬＣＤデータ入力スレッド処理
* @param[in,out] ptr 装置制御データ
* @details 新通信装置から入力されたＬＣＤデータ入力スレッド処理
*/
extern void *comsv_thread_lcd_input(void *ptr);

/**
* @fn void comsv_thread_rest_npat()
* @brief 一斉次患者更新処理
* @details 一斉次患者更新スレッド処理
*/
extern void *comsv_thread_rest_npat();

/**
* @fn void comsv_thread_rest_cond(void *ptr)
* @brief 条件送信完了時の一連処理
* @param[in,out] ptr 装置制御データ
* @details 条件送信完了時の一連スレッド処理
*/
extern void *comsv_thread_rest_cond(void *ptr);

/**
* @fn void comsv_thread_medicated(void *ptr)
* @brief 運転開始時の投薬処理
* @param[in,out] ptr 装置制御データ
* @details 運転開始時の投薬実施、投与タイミング通知スレッド処理
*/
extern void *comsv_thread_medicated(void *ptr);

/**
* @fn void comsv_thread_rest_report(void *ptr)
* @brief レポート画像更新処理
* @param[in,out] ptr 装置制御データ
* @details 条件送信完了時の一連スレッド処理
*/
extern void *comsv_thread_rest_report(void *ptr);

// add 透析患者さんのレポート画面を差入れする 高 start
/**
* @fn void comsv_thread_rest_one_report(void *ptr)
* @brief レポート差入れ指示処理
* @param[in,out] ptr 装置制御データ
* @details 条件送信完了時の一連スレッド処理
*/
extern void *comsv_thread_rest_one_report(void *ptr);
// add 透析患者さんのレポート画面を差入れする 高 end

/**
* @fn void comsv_thread_report_today(void *ptr)
* @brief 当日レポート画像転送処理
* @param[in,out] ptr 装置制御データ
* @details 当日レポート画像転送のスレッド処理
*/
extern void *comsv_thread_report_today(void *ptr);

// #11478 2026.05.15 add 当日レポートのFTP転送処理定義 TDC米沢 start
/**
* @fn void comsv_thread_report_today_ftp(void *ptr)
* @brief 当日レポート画像再転送処理
* @param[in,out] ptr 装置制御データ
* @details 当日レポート画像再転送のスレッド処理
*/
extern void *comsv_thread_report_today_ftp(void *ptr);
// #11478 2026.05.15 add 当日レポートのFTP転送処理定義 TDC米沢 end

/**
* @fn void comsv_thread_report_latest(void *ptr)
* @brief 直近レポート画像転送処理
* @param[in,out] ptr 装置制御データ
* @details 直近レポート画像転送のスレッド処理
*/
extern void *comsv_thread_report_latest(void *ptr);

/**
* @fn void comsv_thread_report_sameday(void *ptr)
* @brief 同一曜日レポート画像転送処理
* @param[in,out] ptr 装置制御データ
* @details 同一曜日レポート画像転送のスレッド処理
*/
extern void *comsv_thread_report_sameday(void *ptr);

/**
* @fn void comsv_thread_rest_status()
* @brief 装置ステータス一括更新処理
* @details 装置ステータス一括更新スレッド処理
*/
extern void *comsv_thread_rest_status();

// #10844 2024.07.29 add DB高負荷状態の時に????患者が複数生成される TDC高村 start
/**
* @fn void comsv_thread_unregistered(void *ptr)
* @brief 患者未登録運転スレッド処理
* @param[in,out] ptr 装置制御データ
* @details 患者未登録運転時のRESTコールスレッド処理
*/
extern void *comsv_thread_unregistered(void *ptr);
// #10844 2024.07.29 add DB高負荷状態の時に????患者が複数生成される TDC高村 end

// add AWSとDEの通信断からの復旧 高 start
extern int getCommAliveState();
extern void setCommAliveState(int value);
extern long getOrdNoDummy();
extern void setOrdNoDummy(long value);
// add AWSとDEの通信断からの復旧 高 end

// add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 start
extern void *comsv_medicated_end(void *ptr);
// add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 end

// add FNSI-バグ 通信サーバ 高 start
/**
 * @fn int comsv_rest_get_ordno_state(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, char *datFile)
 * @brief 治療情報データを取得する
 * @param[in] devNo 装置番号
 * @param[in] devType 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] datFile データ取得ファイル
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_get_ordno_state(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, char *datFile);
// add FNSI-バグ 通信サーバ 高 end

// #11168 2024.10.11 add 対象オーダーの有無確認 TDC片口 start
/**
 * @fn int comsv_rest_get_exists_ord(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, char *datFile)
 * @brief 治療情報の有無を取得する
 * @param[in] devNo 装置番号
 * @param[in] devType 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] datFile データ取得ファイル
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_get_exists_ord(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, char *datFile);
// #11168 2024.10.11 add 対象オーダーの有無確認 TDC片口 end

// #11157 2024.11.01 add サーバー疎通確認用API TDC片口 start
/**
 * @fn int comsv_rest_get_connection_watch(unsigned char *devCd, unsigned char *devId)
 * @brief ネットワーク死活監視処理
 * @param[in] devType 型式コード
 * @param[in] devId 製造番号
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
extern int comsv_rest_connection_watch(unsigned char *devCd, unsigned char *devId);

/**
 * @fn int comsv_rest_exec_simple(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix)
 * @brief RESTを1回だけ実行して結果を取得する(リトライやNG時保存などなし)
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] restStr REST実行文字列
 * @param[in] resFile レスポンスファイル名
 * @param[in] errFile エラーファイル名
 * @param[in] logPrefix ログ文字列の先頭に付与するテキスト
 * @return 0:成功, その他:エラー
 */
extern int comsv_rest_exec_simple(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix);
// #11157 2024.11.01 add サーバー疎通確認用API TDC片口 end

// #11192 2025.04.02 add 治療終了指示に含まれたオーダー番号がDE側で治療中のものではないケースに対応 TDC片口 start
/**
* @fn void comsv_thread_other_ord_no_end_treat(void *ptr)
* @brief 同期異常オーダー番号の終了指示を受信した際の処理
* @param[in,out] ptr 装置制御データ
* @details 同期異常オーダー番号の終了RESTコールスレッド処理
*/
extern void *comsv_thread_other_ord_no_end_treat(void *ptr);
// #11192 2025.04.02 add 治療終了指示に含まれたオーダー番号がDE側で治療中のものではないケースに対応 TDC片口 end

// #11629 2025.05.26 add 「/tmp」以外の治療済透析情報を「/tmp」に復元する TDC米沢 start
/**
* @fn void comsv_thread_restoration_treated_dialysis_report_files(void *ptr)
* @brief 「/tmp/comsv_data/{装置番号}」以外の治療済透析情報を「/tmp/comsv_data/{装置番号}」に復元する
* @param[in,out] ptr 装置制御データ
* @details 治療済透析情報を「/tmp/~」に復元するスレッド処理
*/
void *comsv_thread_restoration_treated_dialysis_report_files(void *ptr);
// #11629 2025.05.26 add 「/tmp」以外の治療済透析情報を「/tmp」に復元する TDC米沢 end

// #12302 2025.10.23 add 圧縮ファイルで取得 TDC米沢 start
/**
 * @fn int comsv_zip_post(long device_no, unsigned char *devCd, unsigned char *devId, long ordNo, short type)
 * @brief 画像転送用のイメージ（ＢＭＰ）の圧縮ファイルを取得する
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] ordNo オーダー番号
 * @param[in] type 画像タイプ（0:ＶＡ、1:レポート）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_zip_post(long devNo, unsigned char *devCd, unsigned char *devId, long ordNo, short type);
/**
 * @fn int comsv_unzip(unsigned char *devCd, unsigned char *devId, unsigned char *zip, unsigned char *dir, unsigned char *title)
 * @brief 圧縮ファイルを解凍する
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] zip   圧縮ファイル名
 * @param[in] dir   展開先フォルダ名
 * @param[in] title ログタイトル
 * @return 0:成功, else:エラー
 */
int comsv_unzip(unsigned char *devCd, unsigned char *devId, unsigned char *zip, unsigned char *dir, unsigned char *title);
// #12302 2025.10.23 add 圧縮ファイルで取得 TDC米沢 end
// #12353 2025.10.23 add 転送完了ファイルを転送 TDC米沢 start
// FTP転送完了ファイル
#define FTP_END_FILE    "ftp_end"   
/**
 * @fn int comsv_ftp_endfile_put(long devNo, unsigned char *devCd, unsigned char *devId, char *url)  
 * @brief FTP転送完了ファイルをFTPでアップロードする
 * @param[in] devNo 装置番号
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] url ホスト名（FTPサーバのIPアドレス）
 * @return 0:成功, -1:エラー
 */
int comsv_ftp_endfile_put(long devNo, unsigned char *devCd, unsigned char *devId, char *url);
// #12353 2025.10.23 add 転送完了ファイルを転送 TDC米沢 end
#endif //