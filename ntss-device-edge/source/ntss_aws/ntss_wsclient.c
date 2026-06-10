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

//! 装置記録コードマスター同期トピック格納
// #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
//u_char _topic_subscribe_mst_records[25] = {0};
u_char _topic_subscribe_mst_records[100] = {0};
// #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
//! 装置情報マスター同期トピック格納
u_char _topic_subscribe_mst_Info[100] = {0};
//! 死活監視通知受信トピック格納
u_char _topic_subscribe_alive_moni[100] = {0};
//! データ収集通知受信トピック格納
u_char _topic_subscribe_gather[100] = {0};
//! アップデータアプリ戻すトピック格納
u_char _topic_restore[100] = {0};
//! サービス再起動トピック格納
u_char _topic_service_reboot[100] = {0};
//! 強制再起動トピック格納
u_char _topic_edge_reboot[100] = {0};
//! 条件送信トピック格納
u_char _topic_send_condition[100] = {0};
//! 処理モード変更通知トピック格納
// #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
//u_char _topic_change_mode[25] = {0};
u_char _topic_change_mode[100] = {0};
// #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
// add FNSI-バグ 通信サーバ 高 start
// 装置工程通知受信トピック格納
u_char _topic_subscribe_process_sate[100] = {0};
// add FNSI-バグ 通信サーバ 高 end

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
char _cNTSSClientCommInfo[256] = "NTSS000000EDGE01";

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
	u_char logMessage[MAX_LOG_TEXT] = {0};
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
	u_char logMessage[MAX_LOG_TEXT] = {0};
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

	// NOTE:クラウド通信不可フラグをON
	setIsDisabledCallApi(true);

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
	} else if (_is_ws_connecting == 1) {
		// 接続確立前にエラーが発生した（確立に失敗した）
		LogOutput(NTSS_LOG_INFO, "通信確立エラーなのでClose");
		_is_ws_connecting = 0;
		closeWSClient();
	}

	// NOTE:クラウド通信不可フラグをON
	setIsDisabledCallApi(true);

	return 0;
}

/**
 * 通信サーバー宛データ送信スレッド
 * @param ptr
 */
void *
_sendToComsvThread(void *ptr){
    LogOutput( NTSS_LOG_INFO, "通信サーバー宛データ送信スレッド開始" );
	char *payload = (char *) ptr;
    int ret = ntss_mqueue_send(payload);
	char logMessage[256] = {0};

	if(ret == 0) {
    	LogOutput( NTSS_LOG_INFO, "受信内容を通信サーバーに通知成功" );
		sprintf(logMessage, "_sendToComsvThread [%s]", payload);
    	LogOutput( NTSS_LOG_INFO, logMessage);
	} else {
		sprintf(logMessage, "受信内容を通信サーバーに通知失敗: %d", ret);
    	LogOutput( NTSS_LOG_ERROR, logMessage);
		sprintf(logMessage, "_sendToComsvThread [%s]", payload);
    	LogOutput( NTSS_LOG_ERROR, logMessage);
	}

    LogOutput( NTSS_LOG_INFO, "通信サーバー宛データ送信スレッド終了" );
    // #12507 2026.03.03 add FW7に伴うバッファーオーバーフロー対応 TDC高村 start
    free(payload);	// _sendToComsv strndup 解放
    // #12507 2026.03.03 add FW7に伴うバッファーオーバーフロー対応 TDC高村 end
}

void _sendToComsv(char *payload)
{
	char logMessage[256] = {0};
    // #12507 2026.03.01 add FW7に伴うバッファーオーバーフロー対応 TDC高村 start
    char payloadStr[256] = {0};
    strcpy(payloadStr, payload);
    int n = snprintf(payloadStr, sizeof(payloadStr), payload);
    // strdup / malloc でヒープにコピー（スレッドに所有権を渡す）
    char* ps = strndup(payloadStr, n);
    if ( !ps ) {
		// エラー
	   	LogOutput( NTSS_LOG_INFO, "_sendToComsv strndup error");
		return;
	}
    // #12507 2026.03.01 add FW7に伴うバッファーオーバーフロー対応 TDC高村 end

	sprintf(logMessage, "_sendToComsv [%s]", payload);
   	LogOutput( NTSS_LOG_INFO, logMessage);

    pthread_t th = 0;
 	// スレッド作成と起動
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
    //pthread_create( &th, NULL, _sendToComsvThread, payload );
    pthread_create( &th, NULL, _sendToComsvThread, ps );
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
	pthread_detach(th);

    // int i, no, ret;
    // char msg[256];

    // printf("START\n");
    // sleep(10);

    // // 次患者送信要求
    // for (i=0; i<3; i++) {
    //     memset(msg, 0, sizeof(msg));
    //     sprintf(msg, "RQ%03d%06d%02d", i+1, i+123, 6);
    //     ret = ntss_mqueue_send(msg);
    //     printf("ret = %d [%s]\n", ret, msg);
    //     //sleep(1);
    // }

    // sleep(10);

    // // 条件送信要求
    // for (i=0; i<12; i++) {
    //     if ( i<3 ) {
	// 		no = 7;
	// 	} else {
	// 		no = 1;
	// 	}
    //     memset(msg, 0, sizeof(msg));
    //     sprintf(msg, "RQ%03d%06d%02d", i+1, i+123, no);
    //     ret = ntss_mqueue_send(msg);
    //     printf("ret = %d [%s]\n", ret, msg);
    //     //sleep(1);
    // }
    //memset(msg, 0, sizeof(msg));
    //strcpy(msg, "CLOSE");
    //ret = ntss_mqueue_send(msg);
    //printf("ret = %d [CLOSE]\n", ret);
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

	// #8081 add 2023.05.12 何かを受信した場合は通信許可とする TDC米沢 start
	// NOTE: クラウド通信不可フラグをOFF
	setIsDisabledCallApi(false);
	// #8081 add 2023.05.12 何かを受信した場合は通信許可とする TDC米沢 end

	// なにかしら受信したら死活応答フラグを立てる
	setIsResponseOk(true);

    ConfigParameter_t config = getConfigParameter();

	u_char filePath[255] = {0};
	u_char topic[100] = {0};
	u_char *payload;
	u_char seqNo[10] = {0};
    u_char information[1024] = {0};

	if (msg->payload_len == 1)
	{
		// 死活監視の空文字
		// #8081 del 2023.05.12 何かを受信した場合は通信許可とする TDC米沢 start
		// // NOTE: クラウド通信不可フラグをOFF
		// setIsDisabledCallApi(false);
		// #8081 del 2023.05.12 何かを受信した場合は通信許可とする TDC米沢 end
		return 0;
	}

	// tabセパレータの位置取得
	int16_t topicLen = get_text(1, msg->payload, topic);
	payload = msg->payload + topicLen + 1;
	if (strcmp(topic, _topic_subscribe_mst_records) == 0)
	{
		// 装置記録マスタ同期

		sprintf(filePath, "%s/%s", config.mstDir, MST_RECORDS);
		backupRenameFile(filePath, true, 0);
		writeMachineRecordCd(payload, strlen(payload), filePath);
		removeBackupFileByNameSort(filePath, 10);

		overlayDataSave(NTSS_EDGE_OVERLAY_KIND_HOME);
		setIsMstReload(true);
	}
	else if (strcmp(topic, _topic_subscribe_mst_Info) == 0)
	{
		// 装置情報マスター同期
		//! 装置情報マスター構造体格納用
		MachineInfo_t machine_info_data[128] = {0};
		setMachineInfo(machine_info_data, payload, 128);

		sprintf(filePath, "%s/%s", config.mstDir, MST_INFO);
		backupRenameFile(filePath, true, 0);
		writeMachineInfo(machine_info_data, strlen(payload), filePath);
		removeBackupFileByNameSort(filePath, 10);

		overlayDataSave(NTSS_EDGE_OVERLAY_KIND_HOME);

		// 子プロセスにマスタ変更通知
		kill(getChildCaptureAppPid(), SIG_MST_SYNC);
		snprintf(logMessage, MAX_LOG_TEXT, "シグナル送信 pid:%d SIG_MST_SYNC", getChildCaptureAppPid());
		LogOutput(NTSS_LOG_INFO, logMessage);
	}
	else if (strcmp(topic, _topic_subscribe_alive_moni) == 0)
	{
		// 死活監視通知受信
		// デバイスエッジ死活送信
		setIsMustAliveMoniSend(true);
	}
	else if (strcmp(topic, _topic_subscribe_gather) == 0)
	{
		// データ収集通知受信
		// データ収集処理キューに登録
		enqueueActionQueue(payload, (uint16_t)strlen(payload));
		// 構造体に分解
		RcvCollectNotice_t rcvParams = {0};
		setCollectNotice(&rcvParams, payload, (uint16_t)strlen(payload));

		u_char rest[NTSS_STR_MAX_SIZE + 28] = {0};
		sprintf(rest, "%s/%s", config.awsHostUrl, API_DATA_COLLECT);

		// 応答ペイロード作成
		u_char cPayload[2024] = {0};
		int32_t payLoadLen = buildSendDataCollectRes(cPayload, &rcvParams, _device_no);

		// publish
		runDataCollectSignalResponseSend(rest, cPayload, payLoadLen);
		setIsMustExecDataCollect(true);
	}
	else if (strcmp(topic, _topic_restore) == 0)
	{
		// アップデータリストア
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
		setIsJobRunning(true);

		// 復元処理
		restoreApplication(payload);

		setIsJobRunning(false);
	}
	else if (strcmp(topic, _topic_service_reboot) == 0)
	{
		// サービス再起動
		// サービスリブート
		serviceRebootOrder(payload);
	}
	else if (strcmp(topic, _topic_edge_reboot) == 0)
	{
		// DE再起動
		// 強制リブート
		osRebootOrder(payload);
	}else if(strstr(topic, TOPIC_COMSV) != NULL){
		// 通信サーバー向け
		char logMessage[256] = {0};
		char payloadStr[256] = {0};
		strcpy(payloadStr, msg->payload);

		_sendToComsv(payloadStr);
	}else if (strcmp(topic, _topic_change_mode) == 0){
		// 動作モード変更

		// 子プロセス番号取得
		int cpid = getChildCaptureAppPid();
		switch( payload[0] ) {
			case '0':	// 通常モードへ移行
				// 子プロセスに変更通知
				kill(cpid, SIG_NORMAL_MODE);
				snprintf(logMessage, MAX_LOG_TEXT, "シグナル送信 pid:%d SIG_NORMAL_MODE[通常モード]", cpid);
				LogOutput(NTSS_LOG_INFO, logMessage);
				break;

			case '1':	// 装置情報登録モードへ移行
				// 子プロセスに変更通知
				kill(cpid, SIG_CREATE_DEVICE_MODE);
				snprintf(logMessage, MAX_LOG_TEXT, "シグナル送信 pid:%d SIG_CREATE_DEVICE_MODE[装置情報登録モード]", cpid);
				LogOutput(NTSS_LOG_INFO, logMessage);
				break;
		}
	}
    // add FNSI-バグ 通信サーバ 高 start
    else if (strcmp(topic, _topic_subscribe_process_sate) == 0){
        // 装置工程
        kill(getChildCaptureAppPid(), SIG_ALIVE_MONI);
        snprintf(logMessage, MAX_LOG_TEXT, "シグナル送信 pid:%d SIG_ALIVE_MONI[装置工程]", getChildCaptureAppPid());
        LogOutput(NTSS_LOG_INFO, logMessage);
    }
    // add FNSI-バグ 通信サーバ 高 end
	payload = NULL;
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
int forceCloseAndResetWs() {

	if (_is_closed == 1)
	{
		LogOutput(NTSS_LOG_INFO, "WebSocketクライアントを初期化する");
		// 後片付け対象に登録してランニングフラグを落とす
		closeClient = client;
		_is_client_running = 0;
		return clientClose();
	} else {
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
	//! 装置記録コードマスター同期トピック格納
	sprintf(_topic_subscribe_mst_records, "%s/%s", TOPIC_SUBSCRIBE_MST, facility_cd);
	//! 装置情報マスター同期トピック格納
	sprintf(_topic_subscribe_mst_Info, "%s/%s/%d", TOPIC_SUBSCRIBE_MST, facility_cd, device_edge_no);
	//! 死活監視通知受信トピック格納
	sprintf(_topic_subscribe_alive_moni, "%s/%s/%d", TOPIC_COMMON_ALIVE, facility_cd, device_edge_no);
	//! データ収集通知受信トピック格納
	sprintf(_topic_subscribe_gather, "%s/%s", TOPIC_COMMON_GATHER, facility_cd);
	//! リストア通知受信トピック格納
	sprintf(_topic_restore, "%s/%s/%d", TOPIC_RESTORE, facility_cd, device_edge_no);
	//! NTSS-Updaterサービス再起動
	sprintf(_topic_service_reboot, "%s/%s/%d", TOPIC_NTSS_REBOOT, facility_cd, device_edge_no);
	//! 強制デバイス再起動
	sprintf(_topic_edge_reboot, "%s/%s/%d", TOPIC_DE_REBOOT, facility_cd, device_edge_no);
	//! 条件送信
	sprintf(_topic_send_condition, "%s/%s/%s/%d", TOPIC_COMSV, SUB_TOPIC_SEND_CONDITION, facility_cd, device_edge_no);
	//! 処理モード変更通知
	sprintf( _topic_change_mode, "%s/%s/%d", TOPIC_CHANGE_MODE, facility_cd, device_edge_no );
    // add FNSI-バグ 通信サーバ 高 start
    //! 装置工程通知受信トピック格納
    sprintf(_topic_subscribe_process_sate, "%s/%s/%d", TOPIC_PROCESS_STATE, facility_cd, device_edge_no);
    // add FNSI-バグ 通信サーバ 高 end
    

	// 接続元情報構築
	sprintf(_cWebSocketURI, "%s/ntss-client-comm/ntssclientcomm", hostUrl);
	sprintf(_cNTSSClientCommInfo, "NTSS%sEDGE%02d", facility_cd, device_edge_no);

	// if(client != NULL) {
	// 	system("echo initWebSocket close");
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
void
closeWSClient() {
	// WebSocket クライアントオブジェクトをクローズ
	if(client != NULL){
		system("echo closeWSClient");
    	LogResourceOutput( NTSS_LOG_INFO, "WebSocket クライアントオブジェクトをクローズ." );
		libwsclient_close(client);
		// libwsclient_finish(client);
		// libwsclient_dispose(client);
	}

	// // WebSocketクライアントオブジェクト初期化
	// client = NULL;
	// _is_client_running = 0;
	_is_closed = 1;

	LogOutput(NTSS_LOG_INFO, "websocket closed.");

	// NOTE:クラウド通信不可フラグをON
	setIsDisabledCallApi(true);

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
void
clearWSClientConnectedTime()
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
