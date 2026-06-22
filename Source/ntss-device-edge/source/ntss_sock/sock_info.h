/**
* @file sock_info.h
* @brief 通信関連ヘッダー
* @author Y.Takamura
* @date 2018/10/01
*/

#ifndef _SOCK_INFO_H_
#define _SOCK_INFO_H_

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
#define	C_OPTRD		1					///< オプション読み出し
#define	C_CLOCK		2					///< 時計設定の設定
#define	C_MONITOR	3					///< モニタデータ読出し
#define	C_RESPONSE	4					///< レスポンスデータ送信
#define	C_REQMAX	5					///< 要求最大数
//@}


/**
 * @brief 装置制御データ
 */
struct scn_data_fm {
	short	dev_idx;					///< 装置マスタINDEX
	short	sock_id;					///< ソケットＮｏ
	char	ip_addr[16];				///< IPアドレス
	short	port_no;					///< ポート番号
	short	conflg;						///< 装置との接続状態（0:未接続,1:接続中,2:通信OK）
	unsigned char	commType;			///< 通信方式
	unsigned char	deviceType[3];		///< 装置の型式コード
	unsigned char	devsw;				///< 通信フォーマット（I,J,M,N,P,Q,A,D,R,V,W）
	unsigned char	devid[8];			///< 装置の識別番号
	unsigned char	comflg;				///< 通信処理レベル
	unsigned char	staflg;				///< 通信状態
	unsigned char	sno;				///< シーケンシャルＮｏ
	unsigned char	cmd;				///< コマンドコード
	unsigned char	reqflg[C_REQMAX];	///< 通信要求フラグ
	short	sndlen;						///< 送信データバイト数
	unsigned char	sndbuf[SNDMAX];		///< 送信データバッファ
	unsigned char	rcvdle;				///< 受信DLEフラグ
	short	rcvlen;						///< 受信データバイト数
	short	zanp;						///< 残り受信データポインタ
	short	zanlen;						///< 残り受信データバイト数
	unsigned char	rcvbuf[RCVMAX];		///< 受信データバッファ
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long	err_ztime;					///< 前回エラー発生時刻
	time_t	err_ztime;					///< 前回エラー発生時刻
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
};

/**
 * @brief 共通プロトコル通信用リクエスト間隔（秒）
 */
extern int req_time_cp;

/**
 * @brief パケット管理情報配列
 */
extern struct NTSS_PACKET_INFORMATION packetInfoList[NTSS_PACKET_INFORMATION_COUNT];

/**
* @fn void *sock_stream(void *ptr)
* @brief 新通信用スレッド処理
* @param[in,out] ptr 装置制御データ
* @return void* 
*/
extern void *sock_stream(void *ptr);

/**
* @fn void *sock_stream_nx(void *ptr)
* @brief NX通信用スレッド処理
* @param[in,out] ptr 装置制御データ
* @return void* 
*/
extern void *sock_stream_nx(void *ptr);

/**
* @fn void *sock_stream_nx(void *ptr)
* @brief NX通信用スレッド処理
* @param[in,out] ptr 装置制御データ
* @return void* 
*/
extern void *sock_stream_cp(void *ptr);

/**
 * @fn void sock_rcvset(struct scn_data_fm *sp, u_char *buf, int len)
 * @brief 受信データ解析処理（新通信＆NX通信用）
 * @param[in,out] sp 装置制御データ
 * @param[in] buf 受信データ 
 * @param len 受信データ長
 */
extern void sock_rcvset(struct scn_data_fm *sp, u_char *buf, int len);

/**
 * @fn void sock_rcvset_cp(struct scn_data_fm *sp, u_char *buf, int len)
 * @brief 受信データ解析処理（共通プロトコル用）
 * @param[in,out] sp 装置制御データ
 * @param[in] buf 受信データ 
 * @param len 受信データ長
 */
extern void sock_rcvset_cp(struct scn_data_fm *sp, u_char *buf, int len);

/**
* @fn int sock_cmd(int thread_no, struct scn_data_fm *sp)
* @brief 新通信コマンド作成
* @param[in] thread_no スレッド番号
* @param[in,out] sp 装置制御データ
* @return int 送信コマンド長
* @details 新通信装置に送信するコマンド作成
*/
extern int sock_cmd(int thread_no, struct scn_data_fm *sp);

/**
* @fn int sock_cmd_nx(int thread_no, struct scn_data_fm *sp)
* @brief NX通信コマンド作成
* @param[in] thread_no スレッド番号
* @param[in,out] sp 装置制御データ
* @return int 送信コマンド長
* @details NX通信装置に送信するコマンド作成
*/
extern int sock_cmd_nx(int thread_no, struct scn_data_fm *sp);

/**
* @fn int sock_cmd_cp(int thread_no, struct scn_data_fm *sp)
* @brief 共通プロトコル通信コマンド作成
* @param[in] thread_no スレッド番号
* @param[in,out] sp 装置制御データ
* @return int 送信コマンド長
* @details 共通プロトコル通信装置に送信するコマンド作成
*/
extern int sock_cmd_cp(int thread_no, struct scn_data_fm *sp);

#endif // 
