/**
* @file ntss_sock.h
* @brief ソケットサーバ関連ヘッダー
* @author Y.Takamura
* @date 2018/10/01
*/

#ifndef _NTSS_SOCK_H_
#define _NTSS_SOCK_H_

#include <errno.h>
#include "sock_info.h"
#include "sock_config.h"
#include "../common/nkklib/nkklib.h"
#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/ntss_mst_lib.h"
#include "../common/libs/master_controller.h"

/// @name システム情報定義
//@{
#define	DEV_MAX		        200         ///< 装置最大数
#define	LISTEN_MAX	        100         ///< 接続待ちキュー最大値
#define SIG_MST_SYNC 		34          ///< マスタ更新指示
#define SIG_ALIVE_MONI		36          ///< 装置死活監視要求
#define SIG_CREATE_MODE     40          ///< 装置情報作成モード移行要求
#define SIG_NORMAL_MODE     41          ///< 通常モード移行要求
#define MST_INFO            "machineInfoData.dat"       ///< 装置マスタファイル名
#define CONFIG_FILE         "./conf/ntss_sock.conf"     ///< ソケットサーバ設定ファイル名
#define CONFIG_COMMON_FILE  "./conf/ntss_common.conf"   ///< アプリケーション共通設定ファイル名
//@}

/**
 * @def 配列数を求めるマクロ
 */
#define COUNTOF(array) (sizeof(array) / sizeof(array[0]))

/**
 * @brief 装置制御データ
 */
struct connect_socket {
    bool	using;                      ///< メモリ使用中フラグ
    bool	running;                    ///< スレッド実行中フラグ
    bool	mst_reload;                 ///< 装置マスタ更新フラグ
    int		thread_no;                  ///< スレッド番号
    int		accept_socket;              ///< 待受ソケットNo
    struct scn_data_fm scn;             ///< 装置制御データ
};

/**
 * @brief 設定情報
 */
extern ConfigParameter_t configParam;

/**
 * @brief 装置制御データ
 */
extern struct connect_socket con_sock[DEV_MAX];

/**
 * @brief 装置情報マスタ
 */
extern MachineInfo_t _machineInfoData[DEV_MAX];

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
 * @return long 現在時刻
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
* @fn void sock_socket_close( struct connect_socket *conSock )
* @brief ソケットクローズ処理（新通信待受用）
* @param[in,out] conSock 装置制御データ
*/
extern void sock_socket_close( struct connect_socket *conSock );

/**
* @fn void sock_socket_close_nx(struct connect_socket *conSock)
* @brief ソケットクローズ処理（NX通信待受用）
* @param[in,out] conSock 装置制御データ
*/
extern void sock_socket_close_nx( struct connect_socket *conSock );

/**
* @fn void sock_socket_close_cp(struct connect_socket *conSock)
* @brief ソケットクローズ処理（共通プロトコル通信接続用）
* @param[in,out] conSock 装置制御データ
*/
extern void sock_socket_close_cp( struct connect_socket *conSock );

/**
 * @brief 装置情報作成モード中フラグ
 */
extern bool bCreateMachineInfo;

/**
* @brief 装置情報作成モードを返す
*
* @details 装置情報作成モードを取得する
*
* @description
* @return true：装置情報作成モード/false：通常モード
* @attention 特になし
*/
extern bool getCreateMachineInfoMode();

#endif // _NTSS_SOCK_H_
