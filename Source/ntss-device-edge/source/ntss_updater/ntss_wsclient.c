/**
* @brief　NTSSでのWebSocketクライアント通信処理ファイル
*
* @details NTSSでのWebSocketクライント通信処理を行う
*
* @description ntss program
* Copyright (C) 2018, TDC, all right reserved.
*
* @file ntss_wsclient.c
* @author H.Yonezawa
* @date 2018/04/27
*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <time.h>
#include <signal.h>

#include "ntss_wsclient.h"

//! デバイス番号
extern uint16_t _device_no;

//! 更新トピック格納
u_char _topic_update[100] = {0};
//! 戻すトピック格納
u_char _topic_restore[100] = {0};
//! ログ収集トピック格納
u_char _topic_log_gather[100] = {0};
//! サービス再起動トピック格納
u_char _topic_service_reboot[100] = {0};
//! サービス停止トピック格納
u_char _topic_service_stop[100] = {0};
//! サービス起動トピック格納
u_char _topic_service_start[100] = {0};
//! 強制再起動トピック格納
u_char _topic_edge_reboot[100] = {0};
//! 設定更新トピック格納
u_char _topic_conf_update[100] = {0};
//! 設定アップロードトピック格納
u_char _topic_conf_gather[100] = {0};
//! 予約キャンセルトピック格納
u_char _topic_plan_cancel[100] = {0};

/// WebSocketクライアントオブジェクト
wsclient *client = NULL;
wsclient *closeClient = NULL;

int8_t _is_client_running = 0;
int8_t _is_closed = 0;
int8_t _is_connected = 0;
int8_t _is_ws_connecting = 0;

// 接続開始日時
time_t _connected_time = 0;
// 切断日時
time_t _closed_time = 0;

/// WebSocket接続先URI
char _cWebSocketURI[256] = "ws://192.168.102.57:8080/ntss-client-comm/ntssclientcomm";
/// ntss-client-commサービスへの接続情報通知(施設コード：000000/デバイスエッジ番号：01)
char _cNTSSClientCommInfo[50] = "NTSS000000EDGE01";

///@ WebSocketイベント関数
//{@

/**
* 
* @brief 通信開始イベント関数
*
* @details 通信開始時に呼び出されるイベント関数
*
* @description
* @param[in] *c	WebSocketクライアントオブジェクト
* @return 0固定
* @attention 特になし
*/
int onopen(wsclient *c)
{
	u_char logMessage[100] = {0};
	sprintf(logMessage, "websocket onopen called: %d", c->sockfd);
	LogOutput(NTSS_LOG_INFO, logMessage);
	//libwsclient_send(c, "Hello onopen");

	// ntss-client-commサービスへの接続情報通知
	libwsclient_send(c, _cNTSSClientCommInfo);

	// 接続完了
	_is_connected = 1;
	_is_ws_connecting = 0;

	// 接続開始日時
	_connected_time = time(&_connected_time);

	// バージョン情報通知
	versionPost();

	return 0;
}

/**
* 
* @brief 通信終了イベント関数
*
* @details 通信終了時に呼び出されるイベント関数
*
* @description
* @param[in] *c	WebSocketクライアントオブジェクト
* @return 0固定
* @attention 特になし
*/
int onclose(wsclient *c)
{
	u_char logMessage[100] = {0};
	sprintf(logMessage, "websocket onclose called: %d", c->sockfd);
	LogOutput(NTSS_LOG_INFO, logMessage);

	// WebSocketクライアントオブジェクト初期化
	libwsclient_close(c);
	if (client == c)
	{
		//client = NULL;
		_is_client_running = 0;
	}
	else
	{
		LogOutput(NTSS_LOG_INFO, "想定していないオブジェクトでClose （clientポインタ != イベント発生要素）");
	}
	closeClient = c;

	return 0;
}

/**
* @brief 閉じたwebsocketクライアントの解放
 * 
 */
int clientClose()
{
	if (closeClient != NULL)
	{
		LogOutput(NTSS_LOG_INFO, "websocket closeClient finish.");
		libwsclient_finish(closeClient);
		LogOutput(NTSS_LOG_INFO, "websocket closeClient dispose.");
		libwsclient_dispose(closeClient);
		if (closeClient == client)
		{
			LogOutput(NTSS_LOG_INFO, "websocket clientClose. client == closeClient");
			client = NULL;
		}
		closeClient = NULL;
		_is_closed = 0;
		LogOutput(NTSS_LOG_INFO, "websocket closeClient done.");

		// 接続終了日時
		_closed_time = time(&_closed_time);
	}
}

/**
* 
* @brief 通信エラーイベント関数
*
* @details 通信エラー発生時に呼び出されるイベント関数
*
* @description
* @param[in] *c		WebSocketクライアントオブジェクト
* @param[in] *err	エラーオブジェクト
* @return 0固定
* @attention 特になし
*/
int onerror(wsclient *c, wsclient_error *err)
{
	u_char logMessage[MAX_LOG_TEXT] = {0};
	sprintf(logMessage, "websocket onerror: (%d): %s", err->code, err->str);
	LogNetworkOutput(NTSS_LOG_ERROR, logMessage);
	if (err->extra_code)
	{
		errno = err->extra_code;
		perror("recv");
	}

	// error発生時にWebSocketクライアントオブジェクト初期化
	// client = NULL;
	if (_is_closed == 1)
	{
		LogOutput(NTSS_LOG_INFO, "ERROR raised Closed Socket.");
		closeClient = c;
		if (client == c)
		{
			LogOutput(NTSS_LOG_INFO, "ERROR raised Closed Socket. client == arg c");
			client = NULL;
		}
	}
	else if (_is_ws_connecting == 1)
	{
		// 接続確立前にエラーが発生した（確立に失敗した）
		LogOutput(NTSS_LOG_INFO, "通信確立エラーなのでClose");
		_is_ws_connecting = 0;
		closeWSClient();
	}

	return 0;
}

/**
* 
* @brief 電文受信イベント関数
*
* @details 電文受信時に呼び出されるイベント関数
*
* @description
* @param[in] *c		WebSocketクライアントオブジェクト
* @param[in] *msg	受信した電文
* @return 0固定
* @attention 特になし
*/
int onmessage(wsclient *c, wsclient_message *msg)
{
	u_char logMessage[MAX_LOG_TEXT] = {0};
	snprintf(logMessage, MAX_LOG_TEXT, "websocket onmessage: (%llu): %s", msg->payload_len, msg->payload);
	LogOutput(NTSS_LOG_INFO, logMessage);

	// なにかしら受信したら死活応答フラグを立てる
	setIsResponseOk(true);

	ConfigParameter_t config = getConfigParameter();

	u_char filePath[255] = {0};
	u_char topic[100] = {0};
	u_char payload[2024] = {0};
	u_char seqNo[10] = {0};
	u_char information[1024] = {0};
	u_char informationErr[1024] = {0};
	if (msg->payload_len == 1)
	{
		// 死活監視の空文字
		return 0;
	}

	// tabセパレータの位置取得
	int16_t topicLen = get_text(1, msg->payload, topic);
	strcpy(payload, msg->payload + topicLen + 1);
	if (strcmp(topic, _topic_update) == 0)
	{
		// 更新受信
		if (getIsJobRunning())
		{
			// 処理中につき処理を行わない
			if (get_text(1, payload, seqNo) > 0)
			{
				// information
				snprintf(information, 1023, "\"%s\":\"%s\"", "updater_info", payload);
				sendResponse(seqNo, "-1", information);
			}
			return 0;
		}
		setIsJobRunning(true, -1);

		// 更新処理
		updateApplication(payload);

		setIsJobRunning(false, -1);
	}
	else if (strcmp(topic, _topic_restore) == 0)
	{
		// レストア受信
		if (getIsJobRunning())
		{
			// 処理中につき処理を行わない
			if (get_text(1, payload, seqNo) > 0)
			{
				snprintf(information, 1023, "\"%s\":\"%s\"", "updater_info", payload);
				sendResponse(seqNo, "-1", information);
			}
			return 0;
		}
		setIsJobRunning(true, -1);

		// 復元処理
		restoreApplication(payload);

		setIsJobRunning(false, -1);
	}
	else if (strcmp(topic, _topic_log_gather) == 0)
	{
		// ログ収集
		if (getIsJobRunning())
		{
			// 処理中につき処理を行わない
			if (get_text(1, payload, seqNo) > 0)
			{
				snprintf(information, 1023, "\"%s\":\"%s\"", "updater_info", payload);
				sendResponse(seqNo, "-1", information);
			}
			return 0;
		}

		if (sendLogGatherSignal(payload) == false)
		{
			// 処理開始失敗
			setLogGatherSeqNo("");
		}
	}
	else if (strcmp(topic, _topic_service_stop) == 0)
	{
		// サービス停止
		serviceStopOrder(payload);
	}
	else if (strcmp(topic, _topic_service_start) == 0)
	{
		// サービス開始
		serviceStartOrder(payload);
	}
	else if (strcmp(topic, _topic_service_reboot) == 0)
	{
		// サービスリブート
		serviceRebootOrder(payload);
	}
	else if (strcmp(topic, _topic_edge_reboot) == 0)
	{
		// 強制リブート
		osRebootOrder(payload);
	}
	else if (strcmp(topic, _topic_conf_update) == 0)
	{
		// 更新受信
		if (getIsJobRunning())
		{
			// 処理中につき処理を行わない
			if (get_text(1, payload, seqNo) > 0)
			{
				snprintf(information, 1023, "\"%s\":\"%s\"", "updater_info", payload);
				sendResponse(seqNo, "-1", information);
			}
			return 0;
		}
		setIsJobRunning(true, -1);

		// 復元処理
		confFileUpdate(payload);

		setIsJobRunning(false, -1);
	}
	else if (strcmp(topic, _topic_conf_gather) == 0)
	{
		// 設定収集
		if (getIsJobRunning())
		{
			// 処理中につき処理を行わない
			if (get_text(1, payload, seqNo) > 0)
			{
				snprintf(information, 1023, "\"%s\":\"%s\"", "updater_info", payload);
				sendResponse(seqNo, "-1", information);
			}
			return 0;
		}
		setIsJobRunning(true, -1);

		// アップロード処理
		confFileGather(payload);

		setIsJobRunning(false, -1);
	}
	else if (strcmp(topic, _topic_plan_cancel) == 0)
	{
		// 予定キャンセル受信
		if (getIsJobRunning())
		{
			// 処理中につき処理を行わない
			if (get_text(1, payload, seqNo) > 0)
			{
				// information
				snprintf(information, 1023, "\"%s\":\"%s\"", "updater_info", payload);
				sendResponse(seqNo, "-1", information);
			}
			return 0;
		}
		setIsJobRunning(true, -1);

		// 予定削除処理
		planCancel(payload);

		setIsJobRunning(false, -1);
	}
	return 0;
}

//@}

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
int checkWSClient()
{
	int ret = 0;
	if (client != NULL && _is_client_running == 1)
	{
		ret = 1;
	}

	return ret;
}

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
int checkWSClientConnected()
{
	int ret = 0;
	if (checkWSClient() == 1 && _is_connected == 1)
	{
		ret = 1;
	}
	return ret;
}

/**
* 
* @brief WebSocketクライアントオブジェクトの接続試行状態判定
*
* @details WebSocketクライアントオブジェクトが接続試行中かどうかどうかを返す
*
* @description
* @return 0:未接続/1：接続中
* @attention 特になし
*/
int checkWSClientConnecting()
{
	int ret = 0;
	if (_is_ws_connecting == 1)
	{
		ret = 1;
	}
	return ret;
}

/**
 * @brief 強制的に開放対象とする
 * 
 * @return int 
 */
int forceCloseAndResetWs()
{

	if (_is_closed == 1)
	{
		LogOutput(NTSS_LOG_INFO, "WebSocketクライアントを初期化する");
		// 後片付け対象に登録してランニングフラグを落とす
		closeClient = client;
		_is_client_running = 0;
		return clientClose();
	}
	else
	{
		return 0;
	}
}

/**
* 
* @brief WebSocketクライアントオブジェクトを構築、通信開始
*
* @details WebSocketクライアントオブジェクトを構築しイベント関数を割り当て通信を開始する
*
* @param facility_cd 施設コード
* @param device_edge_no デバイスエッジ番号
* @description
* @return 0:構築失敗/1:構築成功
* @attention 特になし
*/
int initWSClient(char *hostUrl, char *facility_cd, uint32_t device_edge_no)
{
	int ret = 0;
	u_char logMessage[MAX_LOG_TEXT] = {0};
	setIsResponseOk(true);

	//
	_is_connected = 0;
	_is_ws_connecting = 1;
	// トピック設定
	//! アプリ更新
	sprintf(_topic_update, "%s/%s/%d", TOPIC_UPDATE, facility_cd, device_edge_no);
	//! アプリリストア
	sprintf(_topic_restore, "%s/%s/%d", TOPIC_RESTORE, facility_cd, device_edge_no);
	//! ログ収集
	sprintf(_topic_log_gather, "%s/%s/%d", TOPIC_LOG_GATHER, facility_cd, device_edge_no);
	//! サービス停止トピック格納
	sprintf(_topic_service_stop, "%s/%s/%d", TOPIC_NTSS_STOP, facility_cd, device_edge_no);
	//! サービス起動トピック格納
	sprintf(_topic_service_start, "%s/%s/%d", TOPIC_NTSS_START, facility_cd, device_edge_no);
	//! NTSSサービス再起動
	sprintf(_topic_service_reboot, "%s/%s/%d", TOPIC_NTSS_REBOOT, facility_cd, device_edge_no);
	//! 強制デバイス再起動
	sprintf(_topic_edge_reboot, "%s/%s/%d", TOPIC_DE_REBOOT, facility_cd, device_edge_no);
	//! 設定更新トピック
	sprintf(_topic_conf_update, "%s/%s/%d", TOPIC_CONF_UPDATE, facility_cd, device_edge_no);
	//! 設定アップロードトピック
	sprintf(_topic_conf_gather, "%s/%s/%d", TOPIC_CONF_GATHER, facility_cd, device_edge_no);
	//! 予約キャンセルトピック
	sprintf(_topic_plan_cancel, "%s/%s/%d", TOPIC_PLAN_CANCEL, facility_cd, device_edge_no);

	// 接続元情報構築
	sprintf(_cWebSocketURI, "%s/ntss-client-comm/ntssclientcomm", hostUrl);
	sprintf(_cNTSSClientCommInfo, "NTSS%sUPDEDGE%02d", facility_cd, device_edge_no);

	// if (client != NULL) {
	// 	system("echo initWebScoket close");
	// 	// libwsclient_finish(client);
	// 	// libwsclient_dispose(client);
	// }
	// WebSocketクライアントオブジェクト構築
	client = libwsclient_new(_cWebSocketURI);
	if (client)
	{
		// 構築成功時
		sprintf(logMessage, "websocket init: %s", _cWebSocketURI);
		LogOutput(NTSS_LOG_INFO, logMessage);

		// 処理イベント関数を登録
		libwsclient_onopen(client, &onopen);
		libwsclient_onmessage(client, &onmessage);
		libwsclient_onerror(client, &onerror);
		libwsclient_onclose(client, &onclose);

		// WebSocketクライアントオブジェクト通信開始
		libwsclient_run(client);

		_is_client_running = 1;

		ret = 1;
	}
	else
	{
		sprintf(logMessage, "websocket init false: %s", _cWebSocketURI);
		LogResourceOutput(NTSS_LOG_ERROR, logMessage);
	}

	return ret;
}

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
void sendWSClient(char *msg)
{
	libwsclient_send(client, msg);

	return;
}

/**
* 
* @brief WebSocketクライアントオブジェクト通信停止、破棄
*
* @details WebSocketクライアントオブジェクトの通信を停止し破棄する
*
* @description
* @param[in] *client	WebSocketクライアントオブジェクト
* @return なし
* @attention 特になし
*/
void closeWSClient()
{
	// WebSocket クライアントオブジェクトをクローズ
	if (client != NULL)
	{
		system("echo closeWSClient");
		LogOutput(NTSS_LOG_INFO, "WebSocketクライアントオブジェクトをクローズ.");
		libwsclient_close(client);
		// libwsclient_finish(client);
		// libwsclient_dispose(client);
	}

	// // WebSocketクライアントオブジェクト初期化
	// client = NULL;
	// _is_client_running = 0;
	_is_closed = 1;

	LogOutput(NTSS_LOG_INFO, "websocket closed.");

	return;
}

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
time_t
getWSClientConnectedTime()
{
	return _connected_time;
}

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
void clearWSClientConnectedTime()
{
	_connected_time = 0;
}

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
time_t
getWSClientClosedTime()
{
	return _closed_time;
}