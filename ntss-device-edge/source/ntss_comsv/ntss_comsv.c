/// @mainpage 通信サーバアプリケーション
/// 本アプリケーションは装置（透析装置、NX装置、共通プロトコル装置）とデバイスエッジの間でソケット通信を行い、@n
/// FNWの通信サーバアプリケーションと同等の役割を担うもので、装置を最大200台まで接続する事ができます。@n@n
/// プログラム名は「ntss_comsv.exe」です。

/**
* @file ntss_comsv.c
* @brief 通信サーバメイン
* @author Y.Takamura
* @date 2018/10/01
* @details 通信サーバのメイン処理
*/

#include <stdio.h>
#include <string.h>
#include <signal.h>
#include <stdbool.h>
#include <pthread.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/socket.h>
#include <arpa/inet.h>

#include "ntss_comsv.h"
#include "ntss_nkk_comm.h"
#include "ntss_mqueue_send.h"
#include "ntss_mqueue_recv.h"
#include "ntss_devicecap_conf.h"
#include "ntss_interval_alarm.h"
// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻をロガーと共有 TDC米沢 start
#include "ntss_logger_sync.h"
// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻をロガーと共有 TDC米沢 etc
// #10437 2024.03.26 add DEログに実行モジュールのリビジョンを出力する TDC高村 start
#include "../common/libs/ntss_revision.h"
// #10437 2024.03.26 add DEログに実行モジュールのリビジョンを出力する TDC高村 end

int			sv_port;					/// 新通信用接続待受ポート
int			sv_port_nx;					/// NX通信用接続待受ポート
int			req_time_cp;				/// 共通プロトコル通信用リクエスト間隔（秒）
u_char		rest_device_edge_url[150];	/// REST_DEVICE_EDGE_URL
u_char		rest_web_api_url[150];		/// REST WEB_API_URL
u_char		facility_cd[8];				/// 施設コード
uint32_t	device_edge_no;				/// デバイスエッジ番号
// add AWSとDEの通信断からの復旧 高 start
u_char	  alive_moni_url[150];
int		 ownerProcessId;
// add AWSとDEの通信断からの復旧 高 end

/**
 * @brief 通信サーバキャッシュデータ
 */
ComsvCache_t _comsvCache;

/**
 * @brief 装置制御情報
 */
struct connect_socket con_sock[DEV_MAX];

/**
 * @brief 装置情報マスタ
 */
MachineInfo2_t _machineInfoData[DEV_MAX];

/**
 * @brief thread
 */
pthread_t thr_sv[DEV_MAX];

/**
 * @brief 設定情報
 */
ConfigParameter_t configParam;

/// @name signal用フラグ
//@{
/// 終了判定用フラグ
volatile sig_atomic_t endProcessFlag = 0;
// マスタ更新更新用フラグ
volatile sig_atomic_t updateMasterFlag = 0;
/// 装置情報作成モード用フラグ
volatile sig_atomic_t createMachineFlag = 0;
/// 装置死活監視要求用フラグ
volatile sig_atomic_t requestM_AliveFlag = 0;
// #8730 2023.06.01 add メインから送られた蓄積系データの取り込み TDC米沢 start
/// メインから送られた蓄積系データの更新用フラグ
volatile sig_atomic_t requestCommFailUpdate = 0;
// #8730 2023.06.01 add メインから送られた蓄積系データの取り込み TDC米沢 end
//@}

/**
 * @fn void signalHandler(int signum)
 * @brief シグナル受信処理
 * @param[in] signum シグナル番号
 * @details シグナル指示を受け付ける
 */
void signalHandler(int signum) {
	u_char *msg = NULL;
	extern __sighandler_t setSignal();

	switch ( signum ) {
		case SIGINT:	// キーボード割り込み(ctrl+c)
			// 終了処理
			endProcessFlag = 1;
			msg ="SIGINT受信";
			break;

		case SIGTERM:   // 終了指示
			// 処理終了
			endProcessFlag = 1;
			msg ="SIGTERM受信";
			break;

		case SIGKILL:   // 強制終了
			// 処理終了
			endProcessFlag = 1;
			msg ="SIGKILL受信";
			break;

		case SIGHUP:	// ハングアップ
			// 処理終了
			endProcessFlag = 1;
			msg ="SIGHUP受信";
			break;

		case SIGPIPE:
			msg ="SIGPIPE受信";
			// ログ設定（通信切断）
			resetLogInfo();
			if( setSignal() == SIG_ERR ) {
				// シグナル設定エラー
				viewError( "シグナルの再設定ができないので終了します" );
			}
			break;

		case SIG_ALIVE_MONI:	// 装置死活監視要求
			// 装置死活監視要求
			requestM_AliveFlag = 1;
			msg = "装置死活監視要求";
			break;

		case SIG_MST_SYNC:	// マスタ更新指示
			// マスタ更新指示
			updateMasterFlag = 1;
			msg ="マスタ更新指示受信";
			break;

		case SIG_CREATE_MODE:	// 装置情報作成モード移行要求
			// 装置情報作成モード移行要求
			createMachineFlag = 1;
			bCreateMachineInfo = true;
			msg = "装置情報作成モード移行要求";
			break;

		case SIG_NORMAL_MODE:	// 通常モード移行要求
			// 通常モード移行要求
			createMachineFlag = 0;
			bCreateMachineInfo = false;
			msg = "通常モード移行要求";
			break;
		// add AWSとDEの通信断からの復旧 高 start	
		case SIG_COMM_FAIL:
			// 通信障害
			setCommAliveState(1);
			msg = "COMSV通信障害";
			break;
		case SIG_COMM_FAIL_NORMAL:
			// 通信障害
			setCommAliveState(0);
			msg = "COMSV通信障害NORAML";
			break;
		// add AWSとDEの通信断からの復旧 高 end
		// #8730 2023.06.01 add メインから送られた蓄積系データの取り込み TDC米沢 start
		case SIG_COMM_FILE_MOVED:
			// 通信障害発生時に蓄積系データの転送を完了
			requestCommFailUpdate = 1;
			msg = "蓄積系データの転送完了通知";
			break;
		// #8730 2023.06.01 add メインから送られた蓄積系データの取り込み TDC米沢 end
	}

	if ( msg != NULL ) {
		// // 受け取ったシグナルを記録する
		// LogOutputs(NTSS_LOG_INFO, msg, 0, "", "");
	}
}

/**
 * @fn __sighandler_t setSignal()
 * @brief シグナル設定
 * @details シグナル設定を行う
 * @description
 * @return シグナル設定結果
 * @attention 特になし
 */
__sighandler_t setSignal() {
	__sighandler_t ret = SIG_DFL;

	// プログラム終了のためのシグナル設定
	if ( ret != SIG_ERR ) {
		ret = signal(SIGTERM, signalHandler);
	}
	if ( ret != SIG_ERR ) {
		ret = signal(SIGINT,  signalHandler);
	}
	if ( ret != SIG_ERR ) {
		ret = signal(SIGHUP, signalHandler);
	}
	if ( ret != SIG_ERR ) {
		ret = signal(SIGPIPE, signalHandler);
	}

	// マスタ同期要求のためのシグナル設定
	if ( ret != SIG_ERR ) {
		ret = signal(SIG_MST_SYNC, signalHandler);
	}
	// 装置死活監視要求のためのシグナル設定
	if ( ret != SIG_ERR ) {
		ret = signal(SIG_ALIVE_MONI, signalHandler);
	}
	// 装置情報作成モード移行要求のためのシグナル設定
	if ( ret != SIG_ERR ) {
		ret = signal(SIG_CREATE_MODE, signalHandler);
	}
	// 通常モード移行要求のためのシグナル設定
	if ( ret != SIG_ERR ) {
		ret = signal(SIG_NORMAL_MODE, signalHandler);
	}
	// add AWSとDEの通信断からの復旧 高 start
	// 通信障害のためのシグナル設定
	if ( ret != SIG_ERR ) {
		ret = signal(SIG_COMM_FAIL, signalHandler);
	}
	// 通信障害NORAMLのためのシグナル設定
	if ( ret != SIG_ERR ) {
		ret = signal(SIG_COMM_FAIL_NORMAL, signalHandler);
	}
	// add AWSとDEの通信断からの復旧 高 end  
	// #8730 2023.06.01 add メインから送られた蓄積系データの取り込み TDC米沢 start
	if ( ret != SIG_ERR ) {
		ret = signal(SIG_COMM_FILE_MOVED, signalHandler);
	}
	// #8730 2023.06.01 add メインから送られた蓄積系データの取り込み TDC米沢 end

	return ret;	
}

// add AWSとDEの通信断からの復旧 高 start
/**
* @fn void comsv_fail_DataCollectPacketSend()
* @brief evovery data処理
* @details evovery data処理
*/
void *comsv_fail_DataCollectPacketSend()
{
	int ret;

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

	for ( ; ; usleep(100000) ) {
		if ( endProcessFlag == 1 ) { // 停止処理
			break;
		}
		
		// #8081 mod 2023.05.11 通信不可フラグをファイル有無にて判断し、起動後に最初に通信許可となるまでの通信経路の疎通テストを行わない TDC米沢 start
		// if ( getCommAliveState() != 0  && getCommAliveState_old() == 0) {
		//	 // COMM NG
		//	 setCommAliveState_old(1);
		//	 kill(ownerProcessId, SIG_COMM_FAIL);
		// }
		
		// if ( getCommAliveState() == 0  && getCommAliveState_old() != 0) {
		//	 // COMM OK
		//	 setCommAliveState_old(0);
		//	 kill(ownerProcessId, SIG_COMM_FAIL_NORMAL);
		// }

		//if ( getCommAliveState() != 0 ) {
		//	 // RESTをコールする
		//	 ret = comsv_fail_alive_moni_main();
		//	 if(ret == 0) {
		//		 setCommAliveState(0);
		//	 }
		// }
		
		// #11324 2025.01.27 add 同一処理で通信異常フラグの確認はいちどだけ行う TDC片口 start
		/** 通信許可フラグ */
		bool isCommEnableState = getCommAliveState() == 0;
		// #11324 2025.01.27 add 同一処理で通信異常フラグの確認はいちどだけ行う TDC片口 end

		// 初回通信許可がある場合
		if ( isFirstCommEnabled()) {
			// 通信許可状態指示と通信許可状態が異なる場合
			// #11324 2025.01.27 add 同一処理で通信異常フラグの確認はいちどだけ行う TDC片口 start
			// if ( getCommAliveStateOrder() == 1  && getCommAliveState() == 0) {
			if ( getCommAliveStateOrder() == 1  && isCommEnableState)
			{
			// #11324 2025.01.27 add 同一処理で通信異常フラグの確認はいちどだけ行う TDC片口 end
				// COMM NG
				kill(ownerProcessId, SIG_COMM_FAIL);
				setCommAliveState(-1);
			}
			// #11324 2025.01.27 add 同一処理で通信異常フラグの確認はいちどだけ行う TDC片口 start
			// if ( getCommAliveStateOrder() == 0  && getCommAliveState() == 1) {
			if ( getCommAliveStateOrder() == 0  && isCommEnableState == false)
			{
			// #11324 2025.01.27 add 同一処理で通信異常フラグの確認はいちどだけ行う TDC片口 end
				// COMM OK
				kill(ownerProcessId, SIG_COMM_FAIL_NORMAL);
				setCommAliveState(-1);
			}
			
			// 通信不可の場合
			// #11324 2025.01.27 add 同一処理で通信異常フラグの確認はいちどだけ行う TDC片口 start
			// if ( getCommAliveState() != 0 ) {
			if (isCommEnableState == false)
			{
			// #11324 2025.01.27 add 同一処理で通信異常フラグの確認はいちどだけ行う TDC片口 end
				// RESTをコールする
				ret = comsv_fail_alive_moni_main();
				if(ret == 0) {
					setCommAliveState(0);
				}
			}
		}
		// #8081 mod 2023.05.11 通信不可フラグをファイル有無にて判断し、起動後に最初に通信許可となるまでの通信経路の疎通テストを行わない TDC米沢 end
		
		// #11324 2025.01.27 add 同一処理で通信異常フラグの確認はいちどだけ行う TDC片口 start
		// if ( getCommAliveState() == 0 ) {
		if (isCommEnableState)
		{
		// #11324 2025.01.27 add 同一処理で通信異常フラグの確認はいちどだけ行う TDC片口 end
			comsv_fail_recovery();
		}
	}

	// スレッド終了
	pthread_exit((void *)0);
}
// add AWSとDEの通信断からの復旧 高 end

/**
 * @fn bool comsv_control()
 * @brief ソケット通信制御
 * @return true 正常終了
 * @return false 異常終了
 */
bool comsv_control() {
	int ret;
	uint16_t no, idx;
	socklen_t len, len_nx;
	int maxfd;
	int sock, sock_nx;
	int client_check;
	u_char clog[256];
	char fpath[64];
	char mstDevNo[9] = {0};
	char mstFormatCd = 0;
	char mstSerial[9] = {0};
	char mstIpAddr[16] = {0};
	char mstPortNo[6] = {0};
	char NextPat_LastTime[20] = "";	// 前回日付変更時次患者更新日時
	fd_set ready;
	struct sockaddr_in serv, serv_nx;
	struct timeval seltime;
	pthread_t thr_mq, thr_npat, thr_sta;
	pthread_attr_t thread_attr;

	extern int con_sock_search();
	extern int client_device_search(u_char devFormat, u_char *devSerial, u_char *ipAddr, short portNo);
	extern void comsv_control_close();
	extern void sock_thread_join();
	extern bool reroad_master();
	extern bool check_reload_next_pat(char *LastTime);

	sprintf(clog, "ソケット通信制御");
	LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");

	client_check = 1;			/* クライアント確認 */

	// スレッド属性オブジェクトの初期化
	pthread_attr_init(&thread_attr);
	// スレッド切り離し状態属性の設定
	pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
	// メッセージキュー受信スレッドの起動
	strcpy(clog, "メッセージキュースレッド : 起動");
	LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	// スレッド作成
	pthread_create(&thr_mq, &thread_attr, ntss_mqueue_receiver, con_sock);
	// add AWSとDEの通信断からの復旧 高 start
	pthread_create(&thr_mq, &thread_attr, comsv_fail_DataCollectPacketSend, NULL);
	// add AWSとDEの通信断からの復旧 高 end

	/****************************/
	/* 新通信装置(I,J,M,N,P,Q)  */
	/* NX通信装置(A,D,I,J,R)	*/
	/* 共通プロトコル装置(V,W)  */
	/* オフライン装置(F)		*/
	/****************************/

	// ソケットを作成（新通信装置）
	sock = socket(AF_INET, SOCK_STREAM, 0);
	if ( sock < 0 ) {
		sprintf(clog, "ソケット生成（新通信装置）失敗 [%d][%s]", errno, strerror(errno));
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
		  return false;
	}
	// ソケットを作成（NX通信装置）
	sock_nx = socket(AF_INET, SOCK_STREAM, 0);
	if ( sock_nx < 0 ) {
		sprintf(clog, "ソケット生成（NX通信装置）失敗 [%d][%s]", errno, strerror(errno));
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
		return false;
	}

	// ソケットの設定（新通信装置）
	serv.sin_family = AF_INET;
	serv.sin_addr.s_addr = INADDR_ANY;
	serv.sin_port = htons(sv_port);
	// ソケットの設定（NX通信装置）
	serv_nx.sin_family = AF_INET;
	serv_nx.sin_addr.s_addr = INADDR_ANY;
	serv_nx.sin_port = htons(sv_port_nx);

	// mod FNSI-バグ 通信サーバ 高 start
	// 新通信装置
	for ( ; ; sleep(1) ) {
		if ( endProcessFlag == 1 ) { // 停止処理
			close(sock);
			return true;
		}
		if ( bind(sock, (struct sockaddr *)&serv, sizeof(serv)) < 0 ) {
			sprintf(clog, "bind ERROR [%d][%s]", errno, strerror(errno));
			LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
			continue;
		}
		len = sizeof(serv);
		if ( getsockname(sock, (struct sockaddr *)&serv, &len) < 0 ) {
			sprintf(clog, "getsockname ERROR [%d][%s]", errno, strerror(errno));
			LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
			continue;
		}
		// ソケット名まで取得成功で抜ける
		break;
	}
	
	// NX通信装置
	for ( ; ; sleep(1) ) {
		if ( endProcessFlag == 1 ) { // 停止処理
			close(sock);
			close(sock_nx);
			return true;
		}
		if ( bind(sock_nx, (struct sockaddr *)&serv_nx, sizeof(serv_nx)) < 0 ) {
			sprintf(clog, "bind NX ERROR [%d][%s]", errno, strerror(errno));
			LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
			continue;
		}
		len_nx = sizeof(serv_nx);
		if ( getsockname(sock_nx, (struct sockaddr *)&serv_nx, &len_nx) < 0 ) {
			sprintf(clog, "getsockname NX ERROR [%d][%s]", errno, strerror(errno));
			LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
			continue;
		}
		// ソケット名まで取得成功で抜ける
		break;
	}
	// mod FNSI-バグ 通信サーバ 高 end

	// 待ち受け開始（新通信装置）
	listen(sock, LISTEN_MAX);
	// 待ち受け開始（NX通信装置）
	listen(sock_nx, LISTEN_MAX);

	// 正常動作ログ記録日時
	time_t last_watchdog_time, c_tim;
	time(&last_watchdog_time);

	// ホスト報知定期監視通知
	pthread_t thIntervalAlarm = 0;
	ThreadParameter_t thIntervalAlarmState = {0};
	thIntervalAlarmState.isRunning = true;
	strncpy(thIntervalAlarmState.restDeviceEdgeUrl, rest_device_edge_url, sizeof(thIntervalAlarmState.restDeviceEdgeUrl) - 1);
	strncpy(thIntervalAlarmState.facilityCd, facility_cd, sizeof(thIntervalAlarmState.facilityCd) - 1);
	thIntervalAlarmState.deviceEdgeNo = device_edge_no;
	thIntervalAlarmState.con_sock = con_sock;
	// ホスト報知定期監視スレッド作成と起動
	pthread_create(&thIntervalAlarm, NULL, intervalAlarmThread, &thIntervalAlarmState);

	for ( ; ; usleep(100000) ) {

		if ( endProcessFlag == 1 ) {
			break;	// 停止
		}

		// 現在時間の読み出し
		time(&c_tim);

		// 一定間隔(180秒[3分]間隔)で正常動作していることをログに記録する
		if ((last_watchdog_time + 180) <= c_tim)
		{
			// #10437 2024.03.26 mod DEログに実行モジュールのリビジョンを出力する TDC高村 start
			//LogOutput( NTSS_LOG_INFO, "正常動作中..." );
			sprintf(clog, "正常動作中[Rev:%s]...", RELEASE_REVISION);
			LogOutput(NTSS_LOG_INFO, clog);
			// #10437 2024.03.26 mod DEログに実行モジュールのリビジョンを出力する TDC高村 end

			// 記録日時を保持
			last_watchdog_time = c_tim;
		}

		// #11282 2025.02.28 del 通信不可フォルダへの転送を装置ごとフォルダに変更 TDC片口 start
		// // #8730 2023.06.01 add メインから送られた蓄積系データの取り込み TDC米沢 start
		// /// CommFail蓄積系データの更新要求判定
		// if ( requestCommFailUpdate == 1) {
		//	 // CommFail情報更新
		//	 updateCommFailData();

		//	 // 要求クリア
		//	 requestCommFailUpdate = 0;
		// }
		// // #8730 2023.06.01 add メインから送られた蓄積系データの取り込み TDC米沢 end
		// #11282 2025.02.28 del 通信不可フォルダへの転送を装置ごとフォルダに変更 TDC片口 end
		// #11282 2025.03.12 add 通信不可フォルダへの転送完了のシグナル通知 TDC片口 start
		if(requestCommFailUpdate == 1)
		{
			// CommFail情報更新
			for (no = 0; no < DEV_MAX; no++)
			{
				if (con_sock[no].using == true && con_sock[no].running == true)
				{
					con_sock[no].is_update_comm_fail_from_main = true;
				}
			}
			// 要求クリア
			requestCommFailUpdate = 0;
			if ( setSignal() == SIG_ERR ) {
				// シグナル設定エラー
				viewError( "シグナルの再設定ができないので終了します" );
				break;
			}
		}
		// #11282 2025.03.12 add 通信不可フォルダへの転送完了のシグナル通知 TDC片口 end

		if ( createMachineFlag == 1 ) {
			createMachineFlag = 0;
			client_check = 1;
			// 装置情報作成モードへ移行
			// ソケット通信制御クローズ処理
			sprintf(clog, "ソケット終了処理（装置情報作成モード）");
			LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
			comsv_control_close();
			// ソケット通信スレッド終了待ち
			sprintf(clog, "スレッド終了処理（装置情報作成モード）");
			LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
			sock_thread_join();
			// パケット管理情報初期化
			memset(packetInfoList, 0, sizeof(packetInfoList));
			// 装置制御データ初期化
			memset(con_sock, 0, sizeof(con_sock));
		}

		if ( updateMasterFlag == 1 ) {
			// 装置マスタ読み込み
			sprintf(clog, "%s/%s", configParam.mstDir, MST_INFO);
			ret = comsv_rest_get_mst(1, clog);
			printf("comsv_rest_get_mst = [%d]\n", ret);
			if ( ret == 0 ) {
				// マスタ更新
				if ( reroad_master() == false ) {
					// 失敗時に停止
					break;
				}
			}
			updateMasterFlag = 0;
			client_check = 1;
			// 本体揮発領域の保存処理(非同期)
			overlayDataSave(NTSS_EDGE_OVERLAY_KIND_HOME);
		}

		if ( getCreateMachineInfoMode() == false ) {
			// 通常モードの場合

			// 装置死活監視要求
			if ( requestM_AliveFlag == 1 ) {
				// 全装置の死活状態報告を実施
				// すべての装置の接続状態を通知する
				devicecapConf.cSendAllConnectionStatus = 0x01;

				// シグナル再設定
				requestM_AliveFlag = 0;
				if ( setSignal() == SIG_ERR ) {
					// シグナル設定エラー
					viewError( "シグナルの再設定ができないので終了します" );
					break;
				}

				// 装置ステータス一括更新スレッド処理
				pthread_create(&thr_sta, &thread_attr, comsv_thread_rest_status, NULL);
			}

			// 日付変更時次患者更新チェック
			if ( check_reload_next_pat(NextPat_LastTime) == true ) {
				LogOutputs(NTSS_LOG_INFO, "日付変更時次患者更新", 0, "", "");
				// 一斉次患者更新スレッド処理
				pthread_create(&thr_npat, &thread_attr, comsv_thread_rest_npat, NULL);
			}

			// 工程変化時の装置工程情報の出力(nCheckMachineStateInterval)
			if ( checkNTSSPacketInfoMonitorProcess(
				devicecapConf.nCheckMachineStateInterval
				, &devicecapConf.lastCheckMachineStateTime
				, devicecapConf.cSendAllConnectionStatus) == 1 ) {
				// 次回送信は変更分のみとする
				devicecapConf.cSendAllConnectionStatus = 0x00;
			}

			// 透析中モニタデータの出力(nSendDialysisMonitorInterval)
			checkNTSSPacketInfoMonitorData(
				devicecapConf.nSendDialysisMonitorInterval
				, &devicecapConf.lastSendDialysisMonitorTime
				, 0x01
				// add 治療記録用データと治療状況用データの登録先を振分けにする 高 start
				, devicecapConf.nRealSendDialysisMonitorInterval
				, &devicecapConf.realLastSendDialysisMonitorTime
				// add 治療記録用データと治療状況用データの登録先を振分けにする 高 end 
			);

			// 未透析モニタデータの出力(nSendUntreatMonitorInterval)
			checkNTSSPacketInfoMonitorData(
				devicecapConf.nSendUntreatMonitorInterval
				, &devicecapConf.lastSendUntreatMonitorTime
				, 0x00
				// add 治療記録用データと治療状況用データの登録先を振分けにする 高 start
				, devicecapConf.nRealSendUntreatMonitorInterval
				, &devicecapConf.realLastSendUntreatMonitorTime
				// add 治療記録用データと治療状況用データの登録先を振分けにする 高 end 
			);
		}

		if ( client_check ) {
			client_check = 0;
			/******************************************/
			/* 共通プロトコル装置の確認・スレッド作成 */
			/* オフライン装置の確認				   */
			/******************************************/
			for ( idx = 0; idx < COUNTOF(_machineInfoData); idx++ ) {
				if( _machineInfoData[idx].machineFormatCd == '\0' ) {
					// これ以降マスタデータなし
					break;
				}
				if ( (_machineInfoData[idx].machineFormatCd != 'V' &&
					  _machineInfoData[idx].machineFormatCd != 'W') ||
					  _machineInfoData[idx].machineCommCd != NTSS_COMM_TYPE_COMMON ) {
					// 共通プロトコル装置以外
					if ( _machineInfoData[idx].machineFormatCd != 'F' ||
						 _machineInfoData[idx].machineCommCd != NTSS_COMM_TYPE_NON ) {
						// オフライン装置以外
						continue;
					}
				}

				// 共通プロトコル通信接続用、オフライン装置用データ作成
				strncpy(mstDevNo, _machineInfoData[idx].machineNo, 8);			// 装置番号
				mstFormatCd = _machineInfoData[idx].machineFormatCd;			// 通信フォーマット
				strncpy(mstSerial, _machineInfoData[idx].machineSerial, 8);		// 製造番号
				strncpy(mstIpAddr, _machineInfoData[idx].ipAddress, 15);		// IPアドレス
				strncpy(mstPortNo, _machineInfoData[idx].strport, 5);			// ポート番号
				if ( client_device_search(mstFormatCd, mstSerial, mstIpAddr, atoi(mstPortNo)) ) {
					// 既に通信制御データに存在
					continue;
				}
				no = con_sock_search();
				if ( no < DEV_MAX ) {
					con_sock[no].using = true;
					con_sock[no].thread_no = no;
					// 通信制御データクリア
					memset(&con_sock[no].scn, 0, sizeof(struct scn_data_fm));
					// 共通プロトコル通信接続用データ作成
					// #11115 2024.10.25 add 装置マスタINDEX格納漏れ（共通プロトコル、オフライン） TDC高村 start
					con_sock[no].scn.dev_idx = idx + 1;
					// #11115 2024.10.25 add 装置マスタINDEX格納漏れ（共通プロトコル、オフライン） TDC高村 end
					sscanf(mstDevNo, "%08lX", &con_sock[no].scn.dev_no);
					con_sock[no].scn.devsw = mstFormatCd;
					memcpy(con_sock[no].scn.devid,mstSerial,8);
					strcpy(con_sock[no].scn.ip_addr,mstIpAddr);
					con_sock[no].scn.port_no = atoi(mstPortNo);
					memcpy(con_sock[no].scn.deviceType, _machineInfoData[idx].machineTypeCd, 3);	// 型式コード
					// 作業データ用装置番号フォルダ作成
					comsv_work_mkdir_dev(con_sock[no].scn.dev_no);

					// 装置状態管理データを取得
					comsv_work_fpath(con_sock[no].scn.dev_no, WORK_DEV_STATE, fpath);
					ret = comsv_rest_get_dev(con_sock[no].scn.dev_no, con_sock[no].scn.deviceType, con_sock[no].scn.devid, fpath);
					printf("comsv_rest_get_dev = [%d]\n", ret);
					// #8266 2023.03.24 mod 前回取得データを削除しない修正に伴う対応 TDC高村 start
					//ret = comsv_json_dev_state(fpath, 1, &(con_sock[no].scn));
					ret = comsv_json_dev_state(fpath, 2, &(con_sock[no].scn));
					// #8266 2023.03.24 mod 前回取得データを削除しない修正に伴う対応 TDC高村 end
					printf("comsv_json_dev_state = [%d]\n", ret);

					if ( con_sock[no].scn.devsw == 'V' || con_sock[no].scn.devsw == 'W' ) {
						// 共通プロトコル通信の場合
						// del FNSI-バグ 通信サーバ 高 start
						//  if ( con_sock[no].scn.next_ord_no > 0 && con_sock[no].scn.devsw == 'V' && !(con_sock[no].scn.mon_sta & 1) ) {
							// V4かつ運転中以外なら次患者情報を要求
							// con_sock[no].scn.reqflg[C_NEXTPAT] = 1;
						// }
						// del FNSI-バグ 通信サーバ 高 end
						con_sock[no].scn.commType = NTSS_COMM_TYPE_COMMON;
						// 初回起動時の装置ステータスをセット
						con_sock[no].scn.first_sta = con_sock[no].scn.mon_sta;
						// スレッド作成
						sprintf(clog, "通信スレッドCP[%d] : 生成", no);
						LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
						pthread_create(&(thr_sv[no]), &thread_attr, comsv_stream_cp, &(con_sock[no]));
					}
					else {
						// オフライン装置の場合
						con_sock[no].scn.commType = NTSS_COMM_TYPE_NON;
						// 初回起動時の装置ステータスをセット
						con_sock[no].scn.first_sta = con_sock[no].scn.mon_sta;
						// スレッド作成
						sprintf(clog, "通信スレッドOFF[%d] : 生成", no);
						LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
						pthread_create(&(thr_sv[no]), &thread_attr, comsv_stream_off, &(con_sock[no]));
					}
				}
			}
		}

		FD_ZERO(&ready);			// fd_set初期化 
		FD_SET(sock, &ready);		// fd設定（新通信装置）
		FD_SET(sock_nx, &ready);	// fd設定（NX通信装置）

		// データ受信待ち
		seltime.tv_sec = 2;
		seltime.tv_usec = 0;
		if ( sock > sock_nx ) {
			maxfd = sock;
		}
		else {
			maxfd = sock_nx;
		}
		if ( select(maxfd + 1, &ready, NULL, NULL, &seltime) <= 0 ) {
			continue;
		}

		// fd（新通信装置）に読み込みデータがあるならば、ソケットをリストに登録する
		if ( FD_ISSET(sock, &ready) ) {
			no = con_sock_search();
			if ( no < DEV_MAX) {
				// 待受（処理はブロックされる)
				con_sock[no].accept_socket = accept(sock,(struct sockaddr *)&serv,&len);
				if ( con_sock[no].accept_socket < 0 ) {
					// 失敗
					con_sock[no].accept_socket = (-1);
				}
				else {
					if ( getsockname(sock, (struct sockaddr *)&serv, &len) < 0 ) {
						// ソケット名の取得に失敗
						con_sock[no].accept_socket = (-1);
						continue;
					}
					// 受信スレッドの起動
					sprintf(clog, "通信スレッドNEW[%d] : 生成", no);
					LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");

					con_sock[no].using = true;
					con_sock[no].thread_no = no;
					// 通信制御データクリア
					memset(&con_sock[no].scn, 0, sizeof(struct scn_data_fm));
					// スレッド作成
					pthread_create(&(thr_sv[no]), &thread_attr, comsv_stream, &(con_sock[no]));
				}
			}
		}

		// fd（NX通信装置）に読み込みデータがあるならば、ソケットをリストに登録する
		if ( FD_ISSET(sock_nx, &ready) ) {
			no = con_sock_search();
			if ( no < DEV_MAX ) {
				// 待受（処理はブロックされる)
				con_sock[no].accept_socket = accept(sock_nx, (struct sockaddr *)&serv_nx, &len_nx);
				if ( con_sock[no].accept_socket < 0 ) {
					// 失敗
					con_sock[no].accept_socket = (-1);
				}
				else {
					if ( getsockname(sock_nx, (struct sockaddr *)&serv_nx, &len_nx) < 0 ) {
						// ソケット名の取得に失敗
						con_sock[no].accept_socket = (-1);
						continue;
					}
					// 受信スレッドの起動
					sprintf(clog, "通信スレッドNX[%d] : 生成", no);
					LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");

					con_sock[no].using = true;
					con_sock[no].thread_no = no;
					// 通信制御データクリア
					memset(&con_sock[no].scn, 0, sizeof(struct scn_data_fm));
					// スレッド作成
					pthread_create(&(thr_sv[no]), &thread_attr, comsv_stream_nx, &(con_sock[no]));
				}
			}
		}
	}

	// ホスト報知定期監視スレッド終了待ち
	if (thIntervalAlarm != 0)
	{
		thIntervalAlarmState.isRunning = false;
		pthread_join(thIntervalAlarm, NULL);
	}

	// ソケット通信制御クローズ処理
	sprintf(clog, "ソケット終了処理");
	LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	comsv_control_close();
	close(sock);
	close(sock_nx);

	// スレッド終了待ち
	sprintf(clog, "スレッド終了処理");
	LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	ntss_mqueue_send("CLOSE");
	sock_thread_join();

	return true;
}

/**
 * @fn int con_sock_search()
 * @brief 装置制御データの空きインデックス検索
 * @return 空きインデックス（DEV_MAX:空きなし） 
 */
int con_sock_search() {
	int dno;

	for ( dno = 0; dno < DEV_MAX; dno++ ) {
		if ( con_sock[dno].using == false ) {
			break;
		}
	}

	return dno;
}

/**
 * @fn int client_device_search(u_char devFormat, u_char *devSerial, u_char *ipAddr, short portNo)
 * @brief 装置制御データの対象装置インデックス検索
 * @param[in] devFormat 通信フォーマット
 * @param[in] devSerial 製造番号
 * @param[in] ipAddr IPアドレス
 * @param[in] portNo ポート番号
 * @return 対象装置インデックス（0:対象なし） 
 */
int client_device_search(u_char devFormat, u_char *devSerial, u_char *ipAddr, short portNo) {
	int dno;
	int idx = 0;

	for ( dno = 0; dno < DEV_MAX; dno++ ) {
		if ( con_sock[dno].using == false ) {
			continue;
		}
		if ( devFormat == con_sock[dno].scn.devsw
			&& memcmp(devSerial, con_sock[dno].scn.devid, 8) == 0
			&& convertNTSSIPAddr(ipAddr) == convertNTSSIPAddr(con_sock[dno].scn.ip_addr)
			&& devFormat == con_sock[dno].scn.devsw ) {
			// 対象装置が既に通信制御データに存在する
			idx = dno + 1;
			break;
		}
	}

	return idx;
}

// add FNSI-バグ 通信サーバ 高 start
/**
 * @fn int client_device_key_search(long dev_no, u_char devsw, u_char *devSerial, u_char *deviceType)
 * @brief 装置制御データの対象装置インデックス検索
 * @param[in] dev_no 装置Ｎｏ
 * @param[in] devsw 通信フォーマット
 * @param[in] devSerial 製造番号
 * @param[in] deviceType 装置の型式コード
 * @return 対象装置インデックス（0:対象なし） 
 */
int client_device_key_search(long dev_no, u_char devsw, u_char *devSerial, u_char *deviceType) {
	int dno;
	int idx = -1;

	for ( dno = 0; dno < DEV_MAX; dno++ ) {
		if ( con_sock[dno].using == false ) {
			continue;
		}
		printf("dev_no = %ld(%ld), devSerial = %s(%s), deviceType = %s(%s), devsw = %c(%c)\n", 
				dev_no, con_sock[dno].scn.dev_no, 
				devSerial, con_sock[dno].scn.devid,
				deviceType, con_sock[dno].scn.deviceType,
				devsw, con_sock[dno].scn.devsw);
		
		if ( dev_no == con_sock[dno].scn.dev_no
			&& memcmp(devSerial, con_sock[dno].scn.devid, 7) == 0
			&& memcmp(deviceType, con_sock[dno].scn.deviceType, 3) == 0
			&& devsw == con_sock[dno].scn.devsw ) {
			// 対象装置が既に通信制御データに存在する
			idx = dno;
			break;
		}
	}

	return idx;
}
// add FNSI-バグ 通信サーバ 高 end

/**
 * @fn void comsv_control_close()
 * @brief ソケット通信制御クローズ処理
 */
void comsv_control_close() {
	int no;

	for ( no = 0; no < DEV_MAX; no++ ) {
		if ( con_sock[no].using == true ) {
			if ( con_sock[no].scn.commType == NTSS_COMM_TYPE_NON ) {
				// 終了（オフライン装置用）
				if ( con_sock[no].running == true ) {
					// スレッド有り
					con_sock[no].running = false;
				}
				else {
					// スレッド無し
					con_sock[no].using = false;
				}
			}
			else if ( con_sock[no].scn.commType == NTSS_COMM_TYPE_COMMON ) {
				// ソケットクローズ処理（共通プロトコル通信接続用）
				comsv_socket_close_cp(&(con_sock[no]));
			}
			else if ( con_sock[no].scn.commType == NTSS_COMM_TYPE_NX ) {
				// ソケットクローズ処理（NX通信待受用）
				comsv_socket_close_nx(&(con_sock[no]));
			}
			else {
				// ソケットクローズ処理（新通信待受用）
				comsv_socket_close(&(con_sock[no]));
				// add FNSI-バグ 通信サーバ 高 start
				con_sock[no].running = false;
				// add FNSI-バグ 通信サーバ 高 end
			}
		}
	}
}

/**
 * @fn void sock_thread_join()
 * @brief ソケット通信スレッド終了待ち
 */
void sock_thread_join() {
	int no;

	while ( 1 ) { 
		usleep(3000000);
		for ( no = 0; no < DEV_MAX; no++ ) {
			if ( con_sock[no].running == true ) {
				break;
			}
		}
		if ( no >= DEV_MAX ) {
			break;
		} 
	}
}

/**
 * @fn bool reroad_master()
 * @brief 装置マスタ更新処理
 */
bool reroad_master() {
	uint16_t no;
	unsigned char readFilePath[256];
	unsigned char clog[256];
	MachineInfo2_t _machineInfoBack[DEV_MAX];
	
	sprintf(readFilePath, "%s/%s", configParam.mstDir, MST_INFO);
	memcpy(_machineInfoBack, _machineInfoData, sizeof(_machineInfoData));
	memset(_machineInfoData, 0, sizeof(_machineInfoData));
	if ( readMachineInfo2(_machineInfoData, sizeof(_machineInfoData), readFilePath) == true ) {
		sprintf(clog, "装置マスタ読み込み完了");
		LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	}
	else {
		sprintf(clog, "装置マスタ読み込みに失敗しました");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
		// 読み込み前の状態に戻す
		memcpy(_machineInfoData, _machineInfoBack, sizeof(_machineInfoData));
	}

	for ( no = 0; no < DEV_MAX; no++ ) {
		if ( con_sock[no].using == true && con_sock[no].running == true ) {
			con_sock[no].mst_reload = true;
		}
	}

	// シグナル再設定
	if ( setSignal() == SIG_ERR ) {
		// シグナル設定エラー
		sprintf(clog, "シグナルの再設定ができないので終了します");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
		return false;
	}
	return true;

}

/**
 * @fn int main(int argc, char *argv[])
 * @brief メイン処理
 * @param[in] argc 引数の個数
 * @param[in] argv 引数の配列（引数文字列）
 * @return 終了コード 
 */
int main(int argc, char *argv[]) {
	int ret, err;
	char fpath[64];
	u_char clog[256];   
	u_char readFilePath[256];
	extern void readConfig(ConfigParameter_t *configParam);

	// ログ設定
	setLogInfo();

	// システム起動
	sprintf(clog, "[START],システム起動");
	LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");

	// シグナル設定
	if ( setSignal() == SIG_ERR ) {
		// シグナル設定エラー
		viewError( "シグナルの設定ができないので終了します" );
		exit(EXIT_FAILURE);
	}

	// 引数から情報取得
	if ( 1 < argc ) {
		// プロセス番号
		devicecapConf.nOwnerProcessId = atoi(argv[1]);

		// 引数を画面に出力する
		sprintf(
			clog
			, "Owner PID:%d"
			, devicecapConf.nOwnerProcessId
		);
		// 引数をファイルに出力する
		LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	}
	else {
		viewError("プロセス番号が引数で指定されていません");
		exit(EXIT_FAILURE);
	}
	// #11520 2025.02.26 del 起動時の一時停止処理（待ち時間）見直し TDC高村 start
	// // add FNSI-バグ 通信サーバ 高 start
	// // 35s
	// struct timespec timeReqSleep = {35, 0};
	// while (nanosleep(&timeReqSleep, &timeReqSleep) == -1 && errno == EINTR) {}
	// // add FNSI-バグ 通信サーバ 高 end
	// #11520 2025.02.26 del 起動時の一時停止処理（待ち時間）見直し TDC高村 end
	
	// add AWSとDEの通信断からの復旧 高 start
	ownerProcessId = devicecapConf.nOwnerProcessId;
	// add AWSとDEの通信断からの復旧 高 end
	// 設定ファイルの読み込み
	memset(&configParam, 0, sizeof(configParam));
	readConfig(&configParam);
	sv_port = configParam.receivePort;
	sv_port_nx = configParam.receivePort_NX;
	req_time_cp = configParam.requestTime_CP;
	memcpy(rest_device_edge_url, configParam.restDeviceEdgeUrl, sizeof(rest_device_edge_url));
	memcpy(rest_web_api_url, configParam.restWebApiUrl, sizeof(rest_web_api_url));
	// add AWSとDEの通信断からの復旧 高 start
	memcpy(alive_moni_url, configParam.aliveMoniUrl, sizeof(alive_moni_url));
	// add AWSとDEの通信断からの復旧 高 end
	memcpy(facility_cd, configParam.facilityCd, sizeof(facility_cd));
	device_edge_no = configParam.deviceEdgeNo;

    // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 start
    sprintf(clog, "治療済透析レポート情報格納先フォルダ1: %s", configParam.TreatedDialysisReportDataDirectory);
	LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
    sprintf(clog, "治療済透析レポート情報格納先フォルダ2: %s", configParam.TreatedDialysisReportDataDirectory2);
	LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
    // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 end

	// #11520 2025.02.26 add 起動時の一時停止処理（待ち時間）見直し TDC高村 start
	int cnt;
	struct timespec timeReqSleep = {configParam.commPermissonWait, 0};
	while (nanosleep(&timeReqSleep, &timeReqSleep) == -1 && errno == EINTR) {}
	timeReqSleep.tv_sec = 2;	// 2s
	timeReqSleep.tv_nsec = 0;
	for ( cnt=1; cnt<=15; cnt++ ) {  // 15 * 2s (最大30秒待ち)
		nanosleep(&timeReqSleep, NULL);
		if ( getCommAliveState() == 0 ) break;  // 通信許可
	}
	if ( cnt <= 15 ) {
		sprintf(clog, "通信許可状態で処理開始： %d + %d（秒）", configParam.commPermissonWait, (cnt * 2));
	}
	else {
		sprintf(clog, "通信不可状態で処理開始： %d + 30（秒）経過", configParam.commPermissonWait);
	}
	LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	// #11520 2025.02.26 add 起動時の一時停止処理（待ち時間）見直し TDC高村 end

	// #8729 2023.06.01 add RESTリトライ処理のパラメータを設定で持つ TDC片口 start
	initRestCall();
	// #8729 2023.06.01 add RESTリトライ処理のパラメータを設定で持つ TDC片口 end
	// #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 start
	initCommFailDirectories(configParam.commFailDirectory);
	// #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 end
	// add AWSとDEの通信断からの復旧 高 start
	// #8081 del 2023.05.09 通信不可状態をファイルの有無により決定 TDC米沢 start
	//setCommAliveState(0);
	// #8081 del 2023.05.09 通信不可状態をファイルの有無により決定 TDC米沢 end
	comsv_fail_init();
	// add AWSとDEの通信断からの復旧 高 end

	// マスタファイル参照先フォルダ
	sprintf(devicecapConf.cMstFolder, "./mst/");

	// NTSSパケット収集アプリケーション用の設定ファイルを読み込む
	if ( getNTSSDeviceCapConf() != 1 ) {
		sprintf(clog, "パケット収集アプリケーション設置ファイルの読み込みに失敗しました");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
	}
	// 日機装通信キャプチャ対象コマンド情報設定ファイルを読み込む
	if ( initNTSSNKKCaptureCommandInfo() != 1 ) {
		sprintf(clog, "キャプチャ対象コマンド情報設定ファイルの読み込みに失敗しました");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
	}

	// #8167 del 2023.3.2 起動時に全台装置マスタ取得 Y.Takamura start
	/*
	// 装置マスタからデータ取得
	sprintf(readFilePath, "%s/%s", configParam.mstDir, MST_INFO);
	memset(_machineInfoData, 0, sizeof(_machineInfoData));
	if ( readMachineInfo2(_machineInfoData, sizeof(_machineInfoData), readFilePath) == false ) {
		sprintf(clog, "装置マスタ読み込みに失敗しました");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
	}
	*/
	// #8167 del 2023.3.2 起動時に全台装置マスタ取得 Y.Takamura end

	// 各種マスタからデータ取得して内部保持
	ret = ntss_mst_init(configParam.mstDir);
	if ( ret & 0x01 ) {
		sprintf(clog, "工程マスタファイルの読み込みに失敗しました");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
	}
	if ( ret & 0x02 ) {
		sprintf(clog, "自己診断メッセージマスタファイルの読み込みに失敗しました");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
	}
	if ( ret & 0x04 ) {
		sprintf(clog, "モニタ項目マスタファイルの読み込みに失敗しました");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
	}
	if ( ret & 0x08 ) {
		sprintf(clog, "メンテナンス項目マスタファイルの読み込みに失敗しました");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
	}
	if ( ret & 0x10 ) {
		sprintf(clog, "条件項目マスタファイルの読み込みに失敗しました");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
	}
	if ( ret & 0x20 ) {
		sprintf(clog, "装置型式マスタファイルの読み込みに失敗しました");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
	}

	// 作業データ用フォルダ作成
	comsv_work_mkdir();
	// 共通データ用フォルダ作成
	comsv_work_mkdir_dev(-1);

	err = 0;
	// #8167 add 2023.3.2 起動時に全台装置マスタ取得 Y.Takamura start
	// 装置マスタ読み込み
	sprintf(fpath, "%s/%s", configParam.mstDir, MST_INFO);
	ret = comsv_rest_get_mst(1, fpath);
	printf("comsv_rest_get_mst = [%d]\n", ret);
	if ( ret != 0 ) {
		err = -1;
		sprintf(clog, "装置マスタの読み込みに失敗しました");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
	}
	// 装置マスタからデータ取得
	sprintf(readFilePath, "%s/%s", configParam.mstDir, MST_INFO);
	memset(_machineInfoData, 0, sizeof(_machineInfoData));
	if ( readMachineInfo2(_machineInfoData, sizeof(_machineInfoData), readFilePath) == false ) {
		sprintf(clog, "装置マスタ読み込みに失敗しました");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
	}
	// #8167 add 2023.3.2 起動時に全台装置マスタ取得 Y.Takamura end

	// 通信サーバ設定読み込み
	comsv_work_fpath(-1, WORK_COMSV_SET, fpath);
	ret = comsv_rest_get_mst(0, fpath);
	printf("comsv_rest_get_mst = [%d]\n", ret);
	ret = comsv_json_mst_comset(fpath, &_comsvCache._comsvSet);
	printf("comsv_json_mst_comset = [%d]\n", ret);
	if ( ret != 0 ) {
		err = -1;
		sprintf(clog, "通信サーバ設定の読み込みに失敗しました");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
	}
	else {
		if ( _comsvCache._comsvSet.treat_moni_interval > 0 ) {
			// 治療中モニタ通知間隔（通信サーバ設定の値を使う）
			devicecapConf.nSendDialysisMonitorInterval = _comsvCache._comsvSet.treat_moni_interval;
		}
		if ( _comsvCache._comsvSet.other_moni_interval > 0 ) {
			// 治療外モニタ通知間隔（通信サーバ設定の値を使う）
			devicecapConf.nSendUntreatMonitorInterval = _comsvCache._comsvSet.other_moni_interval;
		}
		// add 治療記録用データと治療状況用データの登録先を振分けにする 高 start
		if ( _comsvCache._comsvSet.treat_realtime_monito_interval > 0 ) {
			// 治療中リアルタイムモニタ通知間隔（通信サーバ設定の値を使う）
			devicecapConf.nRealSendDialysisMonitorInterval = _comsvCache._comsvSet.treat_realtime_monito_interval;
		}
		if ( _comsvCache._comsvSet.other_realtime_monito_interval > 0 ) {
			// 治療外リアルタイムモニタ通知間隔（通信サーバ設定の値を使う）
			devicecapConf.nRealSendUntreatMonitorInterval = _comsvCache._comsvSet.other_realtime_monito_interval;
		}
		// add 治療記録用データと治療状況用データの登録先を振分けにする 高 end

		// #10557 2024.05.17 add ロガーに通信サーバー設定変更を通知 TDC米沢 start
		SyncComSVConfigToLogger();
		// #10557 2024.05.17 add ロガーに通信サーバー設定変更を通知 TDC米沢 end
	}
	sprintf(clog, "device_timeout : %d", _comsvCache._comsvSet.device_timeout);
	LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	sprintf(clog, "treat_moni_interval : %d [%d]",
		_comsvCache._comsvSet.treat_moni_interval, devicecapConf.nSendDialysisMonitorInterval);
	LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	sprintf(clog, "other_moni_interval : %d [%d]",
		_comsvCache._comsvSet.other_moni_interval, devicecapConf.nSendUntreatMonitorInterval);
	LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	// チェックリストマスタ読み込み
	comsv_work_fpath(-1, WORK_COMSV_CHECK, fpath);
	ret = comsv_rest_get_mst(2, fpath);
	printf("comsv_rest_get_mst = [%d]\n", ret);
	ret = comsv_json_mst_checklist(fpath, &_comsvCache._checkMst);
	printf("comsv_json_mst_checklist = [%d]\n", ret);
	if ( ret != 0 ) {
		err = -1;
		sprintf(clog, "チェックリストマスタの読み込みに失敗しました");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
	}
	// 検査項目マスタ読み込み
	comsv_work_fpath(-1, WORK_COMSV_EXAM, fpath);
	ret = comsv_rest_get_mst(3, fpath);
	printf("comsv_rest_get_mst = [%d]\n", ret);
	ret = comsv_json_mst_examitem(fpath, &_comsvCache._examMst);
	printf("comsv_json_mst_examitem = [%d]\n", ret);
	if ( ret != 0 ) {
		err = -1;
		sprintf(clog, "検査項目マスタの読み込みに失敗しました");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
	}
	// 仮想端末（処置者）読み込み
	comsv_work_fpath(-1, WORK_COMSV_USER, fpath);
	ret = comsv_rest_get_lcd(-1, "", "", 29, configParam.facilityCd, fpath);
	printf("comsv_rest_get_lcd 29 = [%d]\n", ret);
	ret = comsv_json_lcd_req29(fpath, &_comsvCache._lcdReq29);
	printf("comsv_json_lcd_req29 = [%d]\n", ret);
	if ( ret != 0 ) {
		err = -1;
		sprintf(clog, "仮想端末（処置者）の読み込みに失敗しました");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
	}
	// 仮想端末（愁訴処置）読み込み
	comsv_work_fpath(-1, WORK_COMSV_TREAT, fpath);
	ret = comsv_rest_get_lcd(-1, "", "", 50, configParam.facilityCd, fpath);
	printf("comsv_rest_get_lcd 50 = [%d]\n", ret);
	ret = comsv_json_lcd_req50(fpath, &_comsvCache._lcdReq50);
	printf("comsv_json_lcd_req50 = [%d]\n", ret);
	if ( ret != 0 ) {
		err = -1;
		sprintf(clog, "仮想端末（愁訴処置）の読み込みに失敗しました");
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
	}
	if ( err == 0 ) {
		// 本体揮発領域の保存処理(非同期)
		overlayDataSave(NTSS_EDGE_OVERLAY_KIND_HOME);
	}

	// 処理開始日時を設定
	time(&devicecapConf.lastMachineAliveTime);
	// 初回なのですべての装置の接続状態を通知する
	devicecapConf.cSendAllConnectionStatus = 0x01;

	// 前回装置状態判定日時を初期化
	devicecapConf.lastCheckMachineStateTime = devicecapConf.lastMachineAliveTime;
	// 前回治療中モニタ送信日時を初期化
	devicecapConf.lastSendDialysisMonitorTime = devicecapConf.lastMachineAliveTime;
	// 前回未治療モニタ送信日時を初期化
	devicecapConf.lastSendUntreatMonitorTime = devicecapConf.lastMachineAliveTime;
	
	// add 治療記録用データと治療状況用データの登録先を振分けにする 高 start
	/// リアルタイム前回治療中モニタ送信日時
	devicecapConf.realLastSendDialysisMonitorTime = devicecapConf.lastMachineAliveTime;
	/// リアルタイム前回未治療モニタ送信日時
	devicecapConf.realLastSendUntreatMonitorTime = devicecapConf.lastMachineAliveTime;
	// add 治療記録用データと治療状況用データの登録先を振分けにする 高 end

	// パケット管理情報初期化
	memset(packetInfoList, 0, sizeof(packetInfoList));

	// 装置制御データ初期化
	memset(con_sock, 0, sizeof(con_sock));

	// ソケット通信制御
	comsv_control();

	// システム終了
	sprintf(clog, "システム終了");
	LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");

	return 0;
}

/**
 * @fn void readConfig(ConfigParameter_t *configParam)
 * @brief 設定ファイルの読み込みと反映
 * @param[out] configParam コンフィグパラメータ
 */
void readConfig(ConfigParameter_t *configParam) {
	u_char clog[256];	

	snprintf(clog, sizeof(clog), "read : %s", CONFIG_FILE);
	LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	if ( readConfigFile(CONFIG_FILE, configParam) < 0 ) {
		snprintf(clog, sizeof(clog), "%s OPEN ERROR", CONFIG_FILE);
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
		return;
	}
	snprintf(clog, sizeof(clog), "read : %s", CONFIG_COMMON_FILE);
	LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	if ( readConfigCommonFile(CONFIG_COMMON_FILE, configParam) < 0 ) {
		snprintf(clog, sizeof(clog), "%s OPEN ERROR", CONFIG_COMMON_FILE);
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
		return;
	}
	snprintf(clog, sizeof(clog), "read : %s", CONFIG_NETWORK_FILE);
	LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	if ( readConfigNetworkFile(CONFIG_NETWORK_FILE, configParam) < 0 ) {
		snprintf(clog, sizeof(clog), "%s OPEN ERROR", CONFIG_NETWORK_FILE);
		LogOutputs(NTSS_LOG_ERROR, clog, 0, "", "");
		return;
	}
	// #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 start
	snprintf(clog, sizeof(clog), "read : %s", CONFIG_COMM_FAIL_FILE);
	LogOutputs(NTSS_LOG_INFO, clog, 0, "", "");
	readConfigCommFailFile(CONFIG_COMM_FAIL_FILE, configParam);
	// #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 end
}

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn void get_time()
// * @brief 現在時刻を取得
// * @return long 現在時刻
// */
//long get_time()
//{
//	long gtime;
//
//	time(&gtime);
//
//	return gtime;
//}
/**
 * @fn time_t get_time()
 * @brief 現在時刻を取得
 * @return time_t 現在時刻
 */
time_t get_time()
{
	time_t gtime;

	time(&gtime);

	return gtime;
}
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
/*
void LogOutputs(NtssLogType type, u_char *msg, int flg, u_char *devType, u_char *devSerial)
{
	unsigned char cType[5]; 
	unsigned char cSerial[10]; 

	// コンソール出力
	printf("%s\n", msg);
	// ファイル出力
	memset(cType, 0, sizeof(cType));
	memset(cSerial, 0, sizeof(cSerial));
	memcpy(cType, devType, 3);
	memcpy(cSerial, devSerial, 8);
	LogSend(type, msg, 0, cType, cSerial);
}
*/
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end

/**
* @fn bool check_reload_next_pat(char *LastTime)
* @brief 日付変更時次患者更新チェック（新通信用）
* @param[in,out] LastTime 前回日付変更時次患者更新日時
* @return true 実施対象
* @return false 実施対象外
*/
bool check_reload_next_pat(char *LastTime) {
	bool Ret = false;
	char bufNow[20];
	char bufConf[20];
	char bufDate[20];
	char bufTime[10];

	if ( _comsvCache._comsvSet.reload_next_pat_time[0] == 0 ) {
		// 設定なし
		return Ret;
	}

	time_str(get_time(), bufDate, bufTime, 1);
	if ( *LastTime == 0 ) {
		// 初回起動時
		sprintf(LastTime, "%s %s", bufDate, bufTime);
		//printf("初回起動時 : [%s]\n",LastTime);
		//printf("設定日時   : [%s %s   ]\n",bufDate, _comsvCache._comsvSet.reload_next_pat_time);
		return Ret;
	}

	// 現在日時
	sprintf(bufNow, "%s %s", bufDate, bufTime);
	// 設定日時
	sprintf(bufConf, "%s %.5s   ", bufDate, _comsvCache._comsvSet.reload_next_pat_time);

	if ( strcmp(LastTime, bufConf) < 0 && strcmp(bufConf, bufNow) < 0 ) {
		// 前回一斉時刻合わせ日時 < 設定日時 かつ 設定日時 < 現在日時
		// 前回一斉時刻合わせ日時 に 現在日時 をセット
		//printf("一斉時刻合わせ : [%s]<[%s]<[%s]\n",LastTime,bufConf,bufNow);
		strcpy(LastTime, bufNow);
		Ret = true;
	}

	return Ret;
}
