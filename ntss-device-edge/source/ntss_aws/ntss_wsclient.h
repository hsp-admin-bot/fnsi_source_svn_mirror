/**
* @brief　NTSSでのWebSocketクライアント通信処理ヘッダーファイル
*
* @details NTSSでのWebSocketクライント通信処理を行う
*
* @description ntss program
* Copyright (C) 2018, TDC, all right reserved.
*
* @file ntss_wsclient.h
* @author H.Yonezawa
* @date 2018/04/27
*/

#ifndef NTSS_WSCLIENT_H
#define NTSS_WSCLIENT_H

#include <sys/types.h>
#include <string.h>
#include <unistd.h>

#include "ntss_properties.h"
#include "ntss_alive_moni.h"
#include "ntss_data_collect.h"
#include "ntss_data_collect_builder.h"
#include "ntss_m_notice.h"
#include "struct_data.h"
#include "config_read.h"
#include "ntss_update.h"
#include "../common/wsclient_cust/wsclient_cust.h"
#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/master_controller.h"
#include "../common/nkklib/nkklib.h"

#include "ntss_mqueue_send.h"

/**
* 
* @brief WebSocketクライアントオブジェクトの有効判定
*
* @details WebSocketクライアントオブジェクトが有効かどうかを返す
*
* @description
* @return 0:無効/1：有効
* @attention 特になし
*/
extern int 
checkWSClient();

/**
* 
* @brief WebSocketクライアントオブジェクトの接続状態判定
*
* @details WebSocketクライアントオブジェクトが接続されているかどうかどうかを返す
*
* @description
* @return 0:未接続/1：接続中
* @attention 特になし
*/
extern int
checkWSClientConnected();
/**
* 
* @brief WebSocketクライアントオブジェクトの接続試行状態判定
*
* @details WebSocketクライアントオブジェクトが接続試行中かどうかどうかを返す
*
* @description
* @return 0:接続試行中でない/1：接続試行中
* @attention 特になし
*/
extern int
checkWSClientConnecting();
/**
 * @brief 強制的に開放対象とする
 * 
 * @return int 
 */
extern int forceCloseAndResetWs();

/**
* 
* @brief WebSocketクライアントオブジェクトを構築、通信開始
*
* @details WebSocketクライアントオブジェクトを構築しイベント関数を割り当て通信を開始する
*
* @description
* @param[in] *cURI	WebSocket接続先URI
* @return NULL:構築失敗/else:構築したWebSocketクライアントオブジェクト
* @attention 特になし
*/
extern int
initWSClient(char *hostUrl, char *facility_cd, uint32_t device_edge_no);

/**
* 
* @brief WebSocketクライアントオブジェクトから送信
*
* @details WebSocketクライアントオブジェクトから電文を送信する
*
* @description
* @param[in] *msg	送信する電文
* @return なし
* @attention 特になし
*/
extern void 
sendWSClient(char *msg);

/**
* 
* @brief WebSocketクライアントオブジェクトを停止する
*
* @details WebSocketクライアントオブジェクトを停止する
*
* @description
* @return なし
* @attention 特になし
*/
extern void 
closeWSClient();

/**
* 
* @brief 停止したWebSocketクライアントオブジェクトを解放する
*
* @details 停止したWebSocketクライアントオブジェクトを解放する
*
* @description
* @return なし
* @attention 特になし
*/
extern int
clientClose();

/**
* 
* @brief WebSocketクライアント接続開始日時の取得
*
* @details WebSocketクライアントオブジェクトの接続開始日時を取得する
*
* @description
* @return 接続開始日時
* @attention 特になし
*/
extern time_t
getWSClientConnectedTime();

/**
* 
* @brief WebSocketクライアント接続開始日時のクリア
*
* @details WebSocketクライアントオブジェクトの接続開始日時をクリアする
*
* @description
* @return なし
* @attention 特になし
*/
extern void
clearWSClientConnectedTime();

/**
* 
* @brief WebSocketクライアント切断日時の取得
*
* @details WebSocketクライアントオブジェクトの切断日時を取得する
*
* @description
* @return 切断日時
* @attention 特になし
*/
extern time_t
getWSClientClosedTime();

#endif