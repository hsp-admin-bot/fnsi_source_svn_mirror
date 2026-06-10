/**
* @file ntss_aws.c
* @brief AWSと通信する処理
* @author Y.Kataguchi
* @date 2017/11/10
* @details 装置ログやモニタデータファイルを収集し、AWSに対して送信ないしデータの受信をするメイン処理
*/

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include <ctype.h>
#include <unistd.h>
#include <signal.h>
#include <memory.h>
#include <limits.h>
#include <errno.h>
#include <sys/resource.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <pthread.h>

#include "ntss_properties.h"
#include "struct_data.h"
#include "ntss_m_notice.h"
#include "ntss_data_collect.h"
#include "data_builder.h"
#include "ntss_data_collect_builder.h"
#include "config_read.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
//#include "ntss_file.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
#include "ntss_alive_moni.h"
#include "ntss_wsclient.h"
#include "ntss_sms.h"
#include "ntss_host_watch_notification.h"
#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/master_controller.h"
#include "../common/libs/ntss_etc_lib.h"
#include "../common/nkklib/nkklib.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 start
#include "../common/libs/ntss_restcall_lib.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 end

extern void log_publish_payload(u_char *cPayLoad, uint32_t payLoadLen);
extern int16_t collect_data_act(ConfigParameter_t *pConfig);
extern void set_signal(int p_signame);
extern void *uploadMNoticeThread(void *ptr);
//add Input comsv log to mongo db. --趙-- start
extern int comsv_rest_post_mongologger(char *upData);
//add Input comsv log to mongo db. --趙-- end
// add AWSとDEの通信断からの復旧 高 start
extern getCommAliveState();
extern void setCommAliveState(int value);
int _comm_alive_state;           /// COMM_ALIVE_STATE: 0---OK, 1---NG
// add AWSとDEの通信断からの復旧 高 end

//! 自プロセスのID
u_char myCharPid[20];

//! trueならばシステム終了させるフラグ
volatile sig_atomic_t _is_exit_program = 0;

//! データ収集プロセス状況
DataCollectProc_t _data_collect_proc = {0};

//! デバイス番号
uint16_t _device_no;

//! 現在時間
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
//long tim;
time_t tim;
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
//! 現在時間構造体
struct tm *tmc;
//! 前回実行スケジュール時間
time_t _last_schedule_run_time;

//! 死活監視の命令受信内容
AliveMoni_t _alive_moni = {0};
//! 接続状態
volatile sig_atomic_t _is_connecting = 0;

//! 標準のCERTディレクトリ
char certDirectory[PATH_MAX + 1] = "../../certs";

// #8081 add 2023.05.23 通信復旧時にWebSocket未接続の場合は即時接続を行う TDC米沢 start
//! 通信SVからの通信状況通知[-1:通知なし/0:通信許可通知/1:通信不可通知]
int nRequestCommFail = -1;
//! WebSocekt強制接続フラグ
bool bForceWSConnect = false;
// #8081 add 2023.05.23 通信復旧時にWebSocket未接続の場合は即時接続を行う TDC米沢 end
// #8081 add 2023.08.08 通信状態変更通知処理を別スレッドで実施する TDC米沢 start
void *
requestCommFailThread(void *ptr);
// #8081 add 2023.08.08 通信状態変更通知処理を別スレッドで実施する TDC米沢 end

/**
 * @brief シグナル受信処理
 *
 */
void sig_handler(int p_signame)
{
	u_char *msg = NULL;

	switch (p_signame)
	{
	case SIGINT: // キーボード割り込み(ctrl+c)

		// 終了処理
		_is_exit_program = 1;
		msg = "SIGINT受信";
		setRunningParameter(false, true, msg);
		break;

	case SIGTERM: // 終了指示

		// 処理終了
		_is_exit_program = 1;
		msg = "SIGTERM受信";
		setRunningParameter(false, true, msg);
		break;

	case SIGKILL: // 強制終了

		// 処理終了
		_is_exit_program = 1;
		msg = "SIGKILL受信";
		setRunningParameter(false, true, msg);
		break;

	case SIGHUP: // ハングアップ

		// 処理終了
		_is_exit_program = 1;
		msg = "SIGHUP受信";
		setRunningParameter(false, true, msg);
		break;

	case SIGPIPE: // 無効パイプへの書込
		set_signal(SIGPIPE);
		msg = "SIGPIPE受信";
		// ログ送信用ソケットをリセット
		resetLogInfo();
		setRunningParameter(true, true, msg);
		break;

	case SIG_FINISH_DATACOLLECT: // データ収集終了

		// データ収集終了
		_data_collect_proc.finish = 1;
		msg = "SIG_FINISH_DATACOLLECT受信";
		setRunningParameter(true, true, msg);
		// add FNSI-バグ 通信サーバ 高 start
		_data_collect_proc.collect_running = true;
		// add FNSI-バグ 通信サーバ 高 end
		break;

	case SIG_ALIVE_MONI: // 装置死活監視終了

		// 装置死活監視終了
		if (_is_connecting == 1)
		{
			_alive_moni.is_finish_task = 1;
		}
		else
		{
			set_signal(SIG_ALIVE_MONI);
		}

		msg = "SIG_ALIVE_MONI受信";
		setRunningParameter(true, true, msg);
		break;
	// add AWSとDEの通信断からの復旧 高 start    
	case SIG_COMM_FAIL:
		// 通信障害
		// #8081 mod 2023.05.23 通信状態変更処理をメインスレッドで実施する TDC米沢 start
		//setCommAliveState(1);
		nRequestCommFail = 1;
		// #8081 mod 2023.05.23 通信状態変更処理をメインスレッドで実施する TDC米沢 end
		msg = "MAIN 通信障害";
		//setRunningParameter(true, true, msg);
		break;
	case SIG_COMM_FAIL_NORMAL:
		// 通信障害
		// #8081 mod 2023.05.23 通信状態変更処理をメインスレッドで実施する TDC米沢 start
		//setCommAliveState(0);
		nRequestCommFail = 0;
		// #8081 mod 2023.05.23 通信状態変更処理をメインスレッドで実施する TDC米沢 end
		msg = "MAIN 通信障害NORAML";
		//setRunningParameter(true, true, msg);
		break;
    // add AWSとDEの通信断からの復旧 高 end
	}

	//
	if (msg != NULL)
	{
		// 画面表示
		// printf( "%s\n", msg );

		// 受け取ったシグナルを記録する
		// 安全じゃないかもなのでコメントアウト
		//LogOutput( NTSS_LOG_INFO, msg );
	}
}

/**
 * @brief シグナルの設定
 *
 */
void set_signal(int p_signame)
{
	if (signal(p_signame, sig_handler) == SIG_ERR)
	{
		/* シグナル設定エラー  */
		LogResourceOutput(NTSS_LOG_ERROR, "シグナルの設定が出来ませんでした。終了します");
		exit(1);
	}
	else
	{
		printf("シグナルの登録成功 %d\n", p_signame);
	}
	return;
}

/**
 * @brief 設定ファイルの読み込みと反映 * 
 */
void readConfig()
{

	char msg[MAX_LOG_TEXT] = {0};

	snprintf(msg, MAX_LOG_TEXT, "read : %s", CONFIG_NETWORK_FILE);
	LogOutput(NTSS_LOG_INFO, msg);
	if (readConfigNetworkFile(CONFIG_NETWORK_FILE) < 0)
	{
		snprintf(msg, MAX_LOG_TEXT, "%s OPEN ERROR", CONFIG_NETWORK_FILE);
		LogResourceOutput(NTSS_LOG_ERROR, msg);
		return;
	}
	snprintf(msg, MAX_LOG_TEXT, "read : %s", CONFIG_FILE);
	LogOutput(NTSS_LOG_INFO, msg);
	if (readConfigFile(CONFIG_FILE) < 0)
	{
		snprintf(msg, MAX_LOG_TEXT, "%s OPEN ERROR", CONFIG_FILE);
		LogResourceOutput(NTSS_LOG_ERROR, msg);
		return;
	}
	snprintf(msg, MAX_LOG_TEXT, "read : %s", CONFIG_COMMON_FILE);
	LogOutput(NTSS_LOG_INFO, msg);
	if (readConfigCommonFile(CONFIG_COMMON_FILE) < 0)
	{
		snprintf(msg, MAX_LOG_TEXT, "%s OPEN ERROR", CONFIG_COMMON_FILE);
		LogResourceOutput(NTSS_LOG_ERROR, msg);
		return;
	}
	readConfigSMSFile();
    // #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 start
    snprintf(msg, sizeof(msg), "read : %s", CONFIG_COMM_FAIL_FILE);
    LogOutput(NTSS_LOG_INFO, msg);
    readConfigCommFailFile(CONFIG_COMM_FAIL_FILE);
    // #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 end

	_device_no = getConfigParameter().deviceNo;
}

/**
 * @brief 異常終了していた場合、収集アプリが生き残っているかもしれないので殺す
 * 
 * @param configParam 
 * @return int 
 */
int killLastChildApp(ConfigParameter_t *configParam)
{
	u_char charPid[10] = {0};
	long pid_l = 0;
	int pid = 0;
	unsigned char cbuff[NTSS_STR_MAX_SIZE * 2] = {0};
	unsigned char logMessage[MAX_LOG_TEXT] = {0};
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
	// char *responseFile = "./tmpZonbiePID.txt";
	char *responseFile = "/tmp/tmpZonbiePID.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
	// ペイロードの内容をログ出力
	snprintf(logMessage, MAX_LOG_TEXT, "別の親の収集アプリが生き残っているか確認");
	LogOutput(NTSS_LOG_INFO, logMessage);

	// RESTをコールする
	sprintf(
		cbuff, "./sh/find_pid.sh \"%s\" \"%s\"", configParam->collectApp, responseFile);
	// コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
	system(cbuff);

	if (readFileOneLine(charPid, 10, responseFile) == 0)
	{
		// 生き残っているプロセスを発見
		pid_l = strtol(charPid, NULL, 10);
		if (pid_l != 0 && errno != ERANGE)
		{
			pid = (int)pid_l;
			snprintf(logMessage, MAX_LOG_TEXT, "別の親の[%s]が見つかったので終了させる: PID: %d", configParam->collectApp, pid);
			LogOutput(NTSS_LOG_INFO, logMessage);
			kill(pid, SIGTERM);
		}
	}
	else
	{
		snprintf(logMessage, MAX_LOG_TEXT, "別の親の[%s]は見つかりませんでした", configParam->collectApp);
		LogOutput(NTSS_LOG_INFO, logMessage);
	}
	removeFileFullPath(responseFile);

	return 0;
}

/**
 * @brief 装置通信アプリケーションを呼び出す
 * 
 * @return int 
 */
int fork_capture_app(ConfigParameter_t *configParam)
{
	char logMessage[MAX_LOG_TEXT] = {0};

	setChildCaptureAppPid(fork());
	if (getChildCaptureAppPid() < 0)
	{
		LogResourceOutput(NTSS_LOG_ERROR, "子プロセスの生成失敗");
		LogResourceOutput(NTSS_LOG_ERROR, "Exit Program");
		exit(-1);
	}
	else if (getChildCaptureAppPid() == 0)
	{
		// 子プロセス
		snprintf(logMessage, MAX_LOG_TEXT, "子プロセスの起動: %s", configParam->collectApp);
		LogOutput(NTSS_LOG_INFO, logMessage);
		execl(configParam->collectApp, configParam->collectApp, myCharPid, NULL);
		LogResourceOutput(NTSS_LOG_ERROR, "子プロセスの起動失敗");
		exit(-1);
	}

	setpriority(PRIO_PROCESS, getChildCaptureAppPid(), -20);

	return 0;
}

/**
 * @brief 機器通信アプリが終了している場合は再起動する
 * 
 * @return int 
 */
int keep_alive_capture_app(ConfigParameter_t *configParam)
{
	int status = 0;
	u_char logMessage[MAX_LOG_TEXT] = {0};

	pid_t pid = waitpid(getChildCaptureAppPid(), &status, WNOHANG);

	if (pid == -1)
	{
		if (errno == ECHILD)
		{
			snprintf(logMessage, MAX_LOG_TEXT, "子プロセスがありません(%d)、再起動します", errno);
		}
		else
		{
			snprintf(logMessage, MAX_LOG_TEXT, "子プロセスの終了済みチェックでエラー検知(%d)、再起動します", errno);
		}
		LogResourceOutput(NTSS_LOG_ERROR, logMessage);
		fork_capture_app(configParam);
	}
	else if (pid == getChildCaptureAppPid())
	{
		// 収集アプリが終了している
		snprintf(logMessage, MAX_LOG_TEXT, "子プロセスが終了しているので再起動します");
		LogOutput(NTSS_LOG_INFO, logMessage);
		fork_capture_app(configParam);
	}

	return 0;
}

/**
 * @brief 外部メディアに対して再マウントを実施
 * 
 * @return int 
 */
int remountMedia()
{
	int ret = 0;
	unsigned char logMessage[MAX_LOG_TEXT] = {0};

	// USB再マウント
	ret = Remount("/mnt/usb");
	// #11567 2025.04.07 del Remount()処理内にてログに記録するため不要 TDC米沢 start
	// snprintf(logMessage, MAX_LOG_TEXT, "USBに対して再マウント実施,処理結果:%d", ret);
	// LogOutput(NTSS_LOG_INFO, logMessage);
	// #11567 2025.04.07 del Remount()処理内にてログに記録するため不要 TDC米沢 end

	// SD再マウント
	ret = Remount("/mnt/sd");
	// #11567 2025.04.07 del Remount()処理内にてログに記録するため不要 TDC米沢 start
	// snprintf(logMessage, MAX_LOG_TEXT, "SDに対して再マウント実施,処理結果:%d", ret);
	// LogOutput(NTSS_LOG_INFO, logMessage);
	// #11567 2025.04.07 del Remount()処理内にてログに記録するため不要 TDC米沢 end

	return ret;
}

/**
 * @brief メイン処理
 * 
 * @return int 
 */
int main()
{
	// ログフォルダ設定
	setLogInfo();

	LogOutput(NTSS_LOG_INFO, "プログラムStart");

	// 外部メディアを再マウントする
	remountMedia();

	// #8081 add 2023.05.09 起動時に通信不可状態とする TDC米沢 start
	// 通信許可状態を通信不可とする
	changeCommEnabledState(false);
	// #8081 add 2023.05.09 起動時に通信不可状態とする TDC米沢 end

	setRunningParameter(true, false, "");

	set_signal(SIGINT);					// Ctrl+C
	set_signal(SIGTERM);				//
	set_signal(SIGHUP);					//
	set_signal(SIGPIPE);				//
	set_signal(SIG_FINISH_DATACOLLECT); // ほかプロセスからの通知(データ収集完了)
	set_signal(SIG_ALIVE_MONI);			// ほかプロセスからの通知(死活監視)
    set_signal(SIG_COMM_FAIL);			// 通信障害
    set_signal(SIG_COMM_FAIL_NORMAL);	// 通信障害

	u_char logMessage[MAX_LOG_TEXT] = {0};

	bool rc = false;

	// 自分のプロセスIDを取得
	snprintf(myCharPid, 20, "%d", getpid());
	snprintf(logMessage, MAX_LOG_TEXT, "my process ID : %s ", myCharPid);
	LogOutput(NTSS_LOG_INFO, logMessage);

	// 起動時間取得
	time(&tim);
	tmc = localtime(&tim);
	_last_schedule_run_time = mktime(tmc);

	// 設定ファイルの読み込み
	readConfig();
	ConfigParameter_t configParam = getConfigParameter();
	// #8729 2023.06.01 add RESTリトライ処理のパラメータを設定で持つ TDC片口 start
	initRestCall();
	// #8729 2023.06.01 add RESTリトライ処理のパラメータを設定で持つ TDC片口 end

	//add Input comsv log to mongo db. --趙-- start
	snprintf(logMessage, sizeof(logMessage), "デバイスエッジ(No%d)が起動しました。", configParam.deviceNo);
	comsv_rest_post_mongologger(logMessage);
	//add Input comsv log to mongo db. --趙-- end

	// キューにデータが残っているかどうかを確認
	setIsMustExecDataCollect(hasDataActionQueue());
	_data_collect_proc.finish = 0;
	_data_collect_proc.running = false;
    // add FNSI-バグ 通信サーバ 高 start
    _data_collect_proc.collect_running = false;
    // add FNSI-バグ 通信サーバ 高 end

	// getcwd(CurrentWD, sizeof(CurrentWD));

	char *pathes[3] = {
		configParam.receiveDataDirectory,
		configParam.receiveDataDirectory2,
		configParam.receiveDataDirectory3};
	ntss_mst_delete_old_alive(pathes);

	// 異常終了していた場合、収集アプリが生き残っているかもしれないので殺す
	killLastChildApp(&configParam);

	// 子プロセスとして収集アプリをキック
	fork_capture_app(&configParam);

	if (_is_exit_program == 1)
	{
		LogOutput(NTSS_LOG_INFO, "終了シグナル受信");
		// 古いログを強制削除
		deleteLogFile(0x01);

		LogOutput(NTSS_LOG_INFO, "Exit Program");
		return rc;
	}

	// デバイスエッジ死活送信
	u_char restAliveMoni[NTSS_STR_MAX_SIZE + 23] = {0};
	sprintf(restAliveMoni, "%s/%s", configParam.awsHostUrl, API_ALIVE_MONI);
	noticeAliveMoni(restAliveMoni, true);

	// データ送信API作成
	u_char restFileUpload[NTSS_STR_MAX_SIZE + 25] = {0};
	sprintf(restFileUpload, "%s/%s", configParam.awsHostUrl, API_FILE_UPLOAD);

	// 更新通知API作成
	u_char restNoticeUpdate[NTSS_STR_MAX_SIZE + 32] = {0};
	sprintf(restNoticeUpdate, "%s/%s", configParam.awsHostUrl, API_SEND_WEBSOCKET);
	u_char noticeTargetId[50] = {0};
	snprintf(noticeTargetId, 50, "%sWEBMONI", configParam.facilityCode);

	// ファイル数オーバー時Notice用rest
	u_char restMNotice[NTSS_STR_MAX_SIZE + 24] = {0};
	sprintf(restMNotice, "%s/%s", configParam.awsHostUrl, API_M_NOTICE);

	// 装置死活状態取得
	LogOutput(NTSS_LOG_INFO, "装置死活状態収集シグナル送信");
	kill(getChildCaptureAppPid(), SIG_ALIVE_MONI);

	u_char cPayload[512] = {0};
	uint32_t payLoadLen;

	uint32_t dataCount = 0;
	int32_t sendloopCount = 0;
	MessageData_t msgDatas[128] = {0};

	// 500ms
	struct timespec timeReq = {0, 450 * 1000000};
	_is_connecting = 1;

	// 初期化
	ntss_mst_init(configParam.mstDir);

	pthread_t thNotice = 0;
	ThreadParameter_t thNoticeState = {0};
	thNoticeState.isRunning = true;
	thNoticeState.mstReload = true;
	thNoticeState.configParam = configParam;
	// スレッド作成と起動
	pthread_create(&thNotice, NULL, uploadMNoticeThread, &thNoticeState);

	// SMS通知
	pthread_t thSMSNotice = 0;
	ThreadParameter_t thSMSNoticeState = {0};
	thSMSNoticeState.isRunning = true;
	thSMSNoticeState.mstReload = false;
	thSMSNoticeState.configParam = configParam;
	// SMSスレッド作成と起動
	pthread_create(&thSMSNotice, NULL, smsNoticeThread, &thSMSNoticeState);

	// #12406 2025.12.01 add 比較用変数定義 TDC米沢 start
	time_t tLastCheckSMSThreadTime = tim;
	u_int32_t nBackupSMSThreadRunningCount = nSMSThreadRunningCount;
	// #12406 2025.12.01 add 比較用変数定義 TDC米沢 end

	// ホスト報知通知
	pthread_t thHostWatchNotice = 0;
	ThreadParameter_t thHostWatchNoticeState = {0};
	thHostWatchNoticeState.isRunning = true;
	thHostWatchNoticeState.mstReload = false;
	thHostWatchNoticeState.configParam = configParam;
	// ホスト報知スレッド作成と起動
	pthread_create(&thHostWatchNotice, NULL, hostWatchNoticeThread, &thHostWatchNoticeState);

	// #8081 del 2023.08.08 通信状態変更通知処理を別スレッドで実施する TDC米沢 start
	// 通信状態変更通知処理
	pthread_t thRequestCommFail = 0;
	ThreadParameter_t thRequestCommFailState = {0};
	thRequestCommFailState.isRunning = true;
	thRequestCommFailState.mstReload = false;
	thRequestCommFailState.configParam = configParam;
	// 通信状態変更通知処理スレッド作成と起動
	pthread_create(&thRequestCommFail, NULL, requestCommFailThread, &thRequestCommFailState);
	// #8081 del 2023.08.08 通信状態変更通知処理を別スレッドで実施する TDC米沢 end

	// 処理開始日時を設定
	time_t last_ws_chk_time = time(&last_ws_chk_time);
	time_t tnow;
	time_t last_run_time = 0;
	time_t last_radio_wave_condition_time = tim;
	bool isFileCountOver = false;

	while (_is_exit_program == 0)
	{
		//fprintf("-->sleep");
		// sleep
		nanosleep(&timeReq, NULL);

		// #8081 del 2023.08.08 通信状態変更通知処理を別スレッドで実施する TDC米沢 start
		// // #8081 mod 2023.05.23 通信SVからの通信状態変更通知処理をメインスレッドで実施する TDC米沢 start
		// if (nRequestCommFail != -1) {
		// 	// 通信状態変更
		// 	setCommAliveState(nRequestCommFail);
			
		// 	// 通信SVからの通信状態が通信許可であるかどうか場合
		// 	if (nRequestCommFail == 0) {
		// 		// 通信許可通知

		// 		// WebSocketクライアントオブジェクト判定
		// 		if (checkWSClient() == 0)
		// 		{
		// 			// WebSocketクライアントオブジェクトが作成されていない場合

		// 			// WebSocketを強制接続
		// 			bForceWSConnect = true;
		// 		}
		// 		else
		// 		{
		// 			// WebSocketクライアントオブジェクトが作成されている場合

		// 			// WebSocket接続判定
		// 			if (checkWSClientConnected() != 1)
		// 			{
		// 				// 接続中ではない
		// 				if (checkWSClientConnecting() == 0) {
		// 					// 接続試行をしていない

		// 					// WebSocketを強制接続
		// 					bForceWSConnect = true;
		// 				}
		// 			}
		// 		}
		// 	}
		// 	// 通信SVからの通信状態変更通知を初期化
		// 	nRequestCommFail = -1;
		// }
		// // #8081 mod 2023.05.23 通信SVからの通信状態変更通知処理をメインスレッドで実施する TDC米沢 end
		// #8081 del 2023.08.08 通信状態変更通知処理を別スレッドで実施する TDC米沢 end

		// DE死活送信
		if (getIsMustAliveMoniSend())
		{
			noticeAliveMoni(restAliveMoni, true);
			setIsMustAliveMoniSend(false);
		}

		// 別スレッドのマスタ同期必要性
		if (getIsMstReload())
		{
			thNoticeState.mstReload = true;
			thSMSNoticeState.mstReload = true;
			setIsMstReload(false);
		}

		// 古いログを削除
		deleteLogFile(0x00);

		// 機器通信アプリの生存監視
		keep_alive_capture_app(&configParam);

		// データ収集結果（ある場合）送信
		collect_data_act(&configParam);

		/////////////////////////////
		// websocketの状態確認・再接続
		/////////////////////////////

		clientClose();

		// 現在値取得
		time(&tnow);

		// WebSocketクライアントオブジェクト判定
		if (checkWSClient() == 0)
		{
			// WebSocketクライアントオブジェクトが作成されていない場合
			// #8081 add 通信復旧時にWebSocket未接続の場合は即時接続を行う TDC米沢 start
			//if(( getWSClientClosedTime() + 5 ) <= tnow ) {
			if(bForceWSConnect || ( getWSClientClosedTime() + 5 ) <= tnow ) {
			// #8081 add 通信復旧時にWebSocket未接続の場合は即時接続を行う TDC米沢 end
				// 最後に切断されてから５秒以上経過しているならば接続再試行する
					
				// WebSocketクライアントオブジェクトを構築して通信開始
				if (initWSClient(configParam.websockHostUrl, configParam.facilityCode, _device_no) == 0)
				{
					sprintf(logMessage, "Unable to initialize new WS client.");
					LogResourceOutput(NTSS_LOG_ERROR, logMessage);
					// _is_exit_program = 1;
				}
				// #8081 add 通信復旧時にWebSocket未接続の場合は即時接続を行う TDC米沢 start
				bForceWSConnect = false;
				// #8081 add 通信復旧時にWebSocket未接続の場合は即時接続を行う TDC米沢 end
			}
		}
		else
		{
			// WebSocketクライアントオブジェクトが作成されている場合

			// WebSocket接続判定
			if (checkWSClientConnected() == 1)
			{
				// WebSocketが接続中

				// WebSocket接続完了で接続時から設定時間が経過しているかどうか
				// ※クラウド通信不可フラグがONで接続完了時のみ処理
				if (getIsDisabledCallApi() && 0 < getWSClientConnectedTime() && (getWSClientConnectedTime() + configParam.commPermissonWaitTime) <= tnow)
				{
					// WebSocket接続完了日時を初期化(本処理を接続完了時のみ実施とするため)
					clearWSClientConnectedTime();

					// DE死活監視状態送信
					setIsMustAliveMoniSend(true);

					// NOTE:クラウド通信不可フラグをOFF
					setIsDisabledCallApi(false);

					// 処理開始日時を保持
					last_ws_chk_time = tnow;
				}
			} else {
				// 接続中ではない
				if (checkWSClientConnecting() == 0) {
					// 接続試行をしていない
					// #8081 add 通信復旧時にWebSocket未接続の場合は即時接続を行う TDC米沢 start
					//if(( last_ws_chk_time + 10 ) <= tnow ) {
					if(bForceWSConnect || ( last_ws_chk_time + 10 ) <= tnow ) {
					// #8081 add 通信復旧時にWebSocket未接続の場合は即時接続を行う TDC米沢 end
						// 前回実行から10秒経過している
						// ソケットクローズフラグが立っていれば強制クローズ
						forceCloseAndResetWs();
						// 処理開始日時を保持
						last_ws_chk_time = tnow;

						// #8081 add 通信復旧時にWebSocket未接続の場合は即時接続を行う TDC米沢 start
						bForceWSConnect = false;
						// #8081 add 通信復旧時にWebSocket未接続の場合は即時接続を行う TDC米沢 end
					}
				} 
			}

			// 前回実施日時から処理間隔が経過しているかどうか
			if ((last_ws_chk_time + configParam.webSocketKeepAliveInterval) <= tnow)
			{
				if (getIsResponseOk())
				{
					// Websocket接続確認実施
					sprintf(logMessage, "Websocket接続確認実施");
					LogOutput(NTSS_LOG_INFO, logMessage);

					// 設定間隔で接続確認を実施
					setIsResponseOk(false);
					sendWSClient(" ");
				}
				else
				{
					// 前回接続確認後に応答なし
					sprintf(logMessage, "Websocket接続確認応答なし");
					LogOutput(NTSS_LOG_INFO, logMessage);
					closeWSClient();
				}

				// 処理開始日時を保持
				last_ws_chk_time = tnow;
			}
		}

		// 電波状態出力
		if (( 3 * 60 ) <= difftime(time(NULL), last_radio_wave_condition_time))
		{
			// ログ＋ネットワーク状態出力
			LogNetworkOutput(NTSS_LOG_INFO, "ネットワーク状態出力");
			last_radio_wave_condition_time = tnow;
		}

		// #12406 2025.12.01 add SMS通知スレッド監視処理追加 TDC米沢 start
		// SMS通知スレッド動作監視[1分ごと]
		if((tLastCheckSMSThreadTime + (1 * 60)) <= tnow)
		{
			// 動作カウンタ確認(値が変わっていない場合は動作していないと判断)
			if(nBackupSMSThreadRunningCount == nSMSThreadRunningCount) {
				LogNetworkOutput(NTSS_LOG_ERROR, "SMS通知スレッドの異常が検出されたためスレッドを再起動");

				// SMS通知スレッドの動作を中断
				pthread_cancel(thSMSNotice);

				// SMS通知スレッドを作成して起動
				thSMSNoticeState.isRunning = true;
				pthread_create(&thSMSNotice, NULL, smsNoticeThread, &thSMSNoticeState);
			}
			// 動作カウンタ保持
			nBackupSMSThreadRunningCount = nSMSThreadRunningCount;
			tLastCheckSMSThreadTime = tnow;
		}
		// #12406 2025.12.01 add SMS通知スレッド監視処理追加 TDC米沢 end

		/////////////////////////////
		// モニタデータアップロードのタイミング確認
		/////////////////////////////
		if (difftime(time(NULL), last_run_time) < configParam.awsMoniUploadInterval)
		{
			continue;
		}
		/////////////////////////////
		// データ収集結果の送信
		/////////////////////////////
		if (runDataCollectPacketSend(restFileUpload, &configParam))
		{
			// 2019.03.05変更 通信量を減らすためにデバイスエッジ側から通知しないようにする
			// // モニタデータ送信成功時に上位に更新通知
			// runNoticeUpdateSend(restNoticeUpdate, noticeTargetId, strlen(noticeTargetId));
		}
		time(&last_run_time);

		/////////////////////////////
		// ファイル数カウント
		/////////////////////////////
		if (checkFileCountOver(&configParam))
		{
			if (isFileCountOver == false)
			{
				// ファイル数過多通知
				if (noticeFileCountOver(restMNotice, &configParam))
				{
					isFileCountOver = true;
				}
			}
		}
		else
		{
			isFileCountOver = false;
		}


		// SD書き込み失敗判定通知
		if( noticeMntMediaWriteError(0, restMNotice, &configParam)){
			// 通知完了
		}
		// USB書き込み失敗判定通知
		if( noticeMntMediaWriteError(1, restMNotice, &configParam)){
			// 通知完了
		}


		// /mnt/usbのReadOnlyチェック
		int ret = 0;
		u_char *media = "/mnt/usb";
		// #11567 2025.04.07 mod 未マウント/マウント済で処理を分岐 TDC米沢 start
		// NtssLogType logtype = NTSS_LOG_INFO;
		// if( checkReadOnlyMedia( media ) == 1 )
        // {
        //     // ReadOnly状態

		// 	LogOutput(NTSS_LOG_INFO, "USBでReadOnlyを検出");

        //     // 再マウント実施
		// 	ret = Remount( media );
		// 	sprintf(logMessage, "USBに対して再マウント実施,処理結果:%d", ret);
		// 	if( ret != 0 )
		// 	{
		// 		// 失敗
		// 		logtype = NTSS_LOG_ERROR;
		// 	}
		// 	LogOutput(NTSS_LOG_INFO, logMessage);
		// }
        // マウントチェック
        if( isMounted( media ) == 0)
        {
			// 未マウント

			// マウント処理 
			checkUnmountToMount( media );
		}
		else
		{
			// マウント済

			// ReadOnly判定
			if( checkReadOnlyMedia( media ) == 1 )
			{
				// ReadOnly状態
	
				// 再マウント実施
				Remount( media );
			}
		}
		// #11567 2025.04.07 mod 未マウント/マウント済で処理を分岐 TDC米沢 end

		// /mnt/sdのReadOnlyチェック
		media = "/mnt/sd";
		// #11567 2025.04.07 mod 未マウント/マウント済で処理を分岐 TDC米沢 start
		// logtype = NTSS_LOG_INFO;
        // if( checkReadOnlyMedia( media ) == 1 )
        // {
        //     // ReadOnly状態

		// 	LogOutput(NTSS_LOG_INFO, "SDでReadOnlyを検出");

        //     // 再マウント実施
		// 	ret = Remount( media );
		// 	sprintf(logMessage, "SDに対して再マウント実施,処理結果:%d", ret);
		// 	if( ret != 0 )
		// 	{
		// 		// 失敗
		// 		logtype = NTSS_LOG_ERROR;
		// 	}
		// 	LogOutput(NTSS_LOG_INFO, logMessage);
		// }
        // マウントチェック
        if( isMounted( media ) == 0)
        {
			// 未マウント

			// マウント処理 
			checkUnmountToMount( media );
		}
		else
		{
			// マウント済

			// ReadOnly判定
			if( checkReadOnlyMedia( media ) == 1 )
			{
				// ReadOnly状態
	
				// 再マウント実施
				Remount( media );
			}
		}
		// #11567 2025.04.07 mod 未マウント/マウント済で処理を分岐 TDC米沢 start
	}

	// デバイスエッジ死活送信
	noticeAliveMoni(restAliveMoni, false);

	// 終了シグナルのログ出力
	RunningParameter_t r = getRunningParameter();
	if (r.isRcvSignal)
	{
		LogOutput(NTSS_LOG_INFO, r.exitMessage);
	}

	// スレッド終了待ち
	if (thNotice != 0)
	{
		thNoticeState.isRunning = false;
		pthread_join(thNotice, NULL);
	}

	// SMSスレッド終了待ち
	if (thSMSNotice != 0)
	{
		thSMSNoticeState.isRunning = false;
		pthread_join(thSMSNotice, NULL);
	}

	// ホスト報知スレッド終了待ち
	if (thHostWatchNotice != 0)
	{
		thHostWatchNoticeState.isRunning = false;
		pthread_join(thHostWatchNotice, NULL);
	}

	// #8081 del 2023.08.08 通信状態変更通知処理を別スレッドで実施する TDC米沢 start
	// 通信状態変更通知処理スレッド終了待ち
	if (thRequestCommFail != 0)
	{
		thRequestCommFailState.isRunning = false;
		pthread_join(thRequestCommFail, NULL);
	}
	// #8081 del 2023.08.08 通信状態変更通知処理を別スレッドで実施する TDC米沢 end

	// 子プロセス終了
	kill(getChildCaptureAppPid(), SIGINT);

	// WebSocketクライアントオブジェクトが作成されている場合
	if (checkWSClient() == 1)
	{
		// WebSocketクライアントオブジェクトをクローズ
		closeWSClient();
	}

	// デバイスエッジ死活送信
	noticeAliveMoni(restAliveMoni, false);
	//add Input comsv log to mongo db. --趙-- start
	snprintf(logMessage, sizeof(logMessage), "デバイスエッジ(No%d)が停止しました。", configParam.deviceNo);
	comsv_rest_post_mongologger(logMessage);
	//add Input comsv log to mongo db. --趙-- end
	LogOutput(NTSS_LOG_INFO, "Exit Program");
	return 0;
}

/**
* @brief 緊急発報監視・発報処理(スレッド)
*
* @details 緊急発報監視・発報処理を行う
* 
* @param ptr ポインタ
* @description
* @return なし
* @attention 特になし
*/
void *
uploadMNoticeThread(void *ptr)
{
	ThreadParameter_t *state = (ThreadParameter_t *)ptr;

	u_char cbuff[NTSS_STR_MAX_SIZE] = {0};
	u_char rcdFilePath[NTSS_STR_MAX_SIZE] = {0};
	u_char restMNotice[NTSS_STR_MAX_SIZE + 25] = {0};
	u_char restAliveMoni[NTSS_STR_MAX_SIZE + 24] = {0};
	u_char msg[MAX_LOG_TEXT] = {0};
	u_char rcd[10] = {0};
	int loopCount;

	sprintf(restMNotice, "%s/%s", state->configParam.awsHostUrl, API_M_NOTICE);
	sprintf(restAliveMoni, "%s/%s", state->configParam.awsHostUrl, API_ALIVE_MONI);

	// 400ms
	struct timespec timeReq = {0, 400 * 1000000};

	while (state->isRunning)
	{
		// sleep
		nanosleep(&timeReq, NULL);

		//! マスタ読み込みが必要ならば読み込み
		if (state->mstReload)
		{
			sprintf(cbuff, "%s/%s", state->configParam.mstDir, MST_RECORDS);
			sprintf(rcdFilePath, "%s/%s", state->configParam.mstDir, MST_RECORDS_GREP_FILE);
			readMachineRecordCd(cbuff, rcdFilePath);
			state->mstReload = false;
			LogOutput(NTSS_LOG_INFO, "緊急発報マスタファイル再読み込み完了");
		}

		/////////////////////////////
		// 緊急発報
		/////////////////////////////

		runMNotice(restMNotice, &(state->configParam), MST_RECORDS_GREP_FILE);

		/////////////////////////////
		// 工程状態通知
		/////////////////////////////

		runAliveMoniNotice(restAliveMoni);
	}

	LogOutput(NTSS_LOG_INFO, "緊急発報スレッド終了");
}

/**
 * @brief データ収集終了時のレスポンスを返す
 * 
 * @param pClient 
 * @param MsgParams 
 * @param pConfig 
 * @return true 
 * @return false 
 */
bool finishedDataCollectProc(ConfigParameter_t *pConfig)
{
	u_char msg[MAX_LOG_TEXT] = {0};

	if (_data_collect_proc.collectNotice.manageNo[0] == 0x00)
	{
		// スケジュールFTP収集結果
		LogOutput(NTSS_LOG_INFO, "FTPデータ収集処理完了");
		_data_collect_proc.finish = 0;
		_data_collect_proc.running = false;
		// 実績ファイルの削除
		deleteFtpCollectResultFile();

		set_signal(SIG_FINISH_DATACOLLECT); // ほかプロセスからの通知
	}
	else
	{
		// ファイルアップロード結果

		u_char rest[NTSS_STR_MAX_SIZE + 28] = {0};
		sprintf(rest, "%s/%s", pConfig->awsHostUrl, API_DATA_COLLECT);

		// 応答ペイロード作成
		u_char cPayload[2024] = {0};
		int16_t payLoadLen = buildSendDataCollectResult(cPayload, &(_data_collect_proc.collectNotice), _device_no);

		// ペイロードの内容をログ出力
		log_publish_payload(cPayload, payLoadLen);

		// publish
		bool rc = runDataCollectResultResponseSend(rest, cPayload, payLoadLen, &(_data_collect_proc.collectNotice));
		if (rc)
		{
			_data_collect_proc.finish = 0;
			_data_collect_proc.running = false;
			// 実績ファイルの削除
			deleteDataCollectResultFile(&(_data_collect_proc.collectNotice));

			set_signal(SIG_FINISH_DATACOLLECT); // ほかプロセスからの通知
		}
		else
		{
			// 送信失敗
			snprintf(msg, MAX_LOG_TEXT, "Rest Call Error");
			LogResourceOutput(NTSS_LOG_ERROR, msg);
		}
	}
}

/**
 * @brief FTP収集スケジュールをチェックして、収集作業が必要ならばtrueを返す
 * 
 * @param pConfig 
 * @return true 
 * @return false 
 */
bool is_must_ftp_collect_check(ConfigParameter_t *pConfig)
{

	// 現在時刻の取得
	time(&tim);
	tmc = localtime(&tim);
	time_t nowTime = mktime(tmc);

	// スケジュール時刻取得用構造体（時、分以外が当日となる）
	struct tm scheTm;
	scheTm.tm_isdst = -1; //夏時間ではない
	scheTm.tm_year = tmc->tm_year;
	scheTm.tm_mon = tmc->tm_mon;
	scheTm.tm_mday = tmc->tm_mday;
	scheTm.tm_sec = 0; // ゼロ秒

	time_t scheTime;

	int16_t i;
	for (i = 0; i < COUNTOF(pConfig->ftpSchedule); i++)
	{
		if (pConfig->ftpSchedule[i].hour < 0)
		{
			// これ以上のスケジュールなし → 実行不要
			return false;
		}

		//（本日の） スケジュールの時刻を取得
		scheTm.tm_hour = pConfig->ftpSchedule[i].hour;
		scheTm.tm_min = pConfig->ftpSchedule[i].minute;
		scheTime = mktime(&scheTm);

		// 前回実行時刻がスケジュール時刻より前で、かつ現在時刻がスケジュール時刻を過ぎている場合はスケジュール実行
		if (scheTime > _last_schedule_run_time && nowTime > scheTime)
		{
			return true;
		}
	}
	return false;
}

/**
 * @brief データ収集処理
 * 
 * @param pClient 
 * @param MsgParams 
 * @param pConfig 
 * @return int16_t 
 */
int16_t
collect_data_act(ConfigParameter_t *pConfig)
{
	uint32_t payLoadLen = 0;
	uint16_t maxPayloadLen = 1600; // maxPayloadLen > 13 + 14 * 100
	u_char cPayload[maxPayloadLen];
	memset(cPayload, 0, maxPayloadLen);
	u_char logMessage[MAX_LOG_TEXT] = {0};
	u_char fileName[128] = {0};
	RcvCollectNotice_t rcvParams = {0};
	int16_t res = 0;

	if (_data_collect_proc.finish == 1)
	{
		// 処理終了
		LogOutput(NTSS_LOG_INFO, "データ収集完了シグナル受信");
		finishedDataCollectProc(pConfig);
	}

	// 定期FTPデータ収集スケジュールの確認
	if (is_must_ftp_collect_check(pConfig) && _data_collect_proc.running == false)
	{
		_data_collect_proc.collectNotice = rcvParams;

		// FTPデータ収集プロセスを起動
		_data_collect_proc.running = true;	 // 実行中フラグ
		_last_schedule_run_time = mktime(tmc); // 最終実行時間

		_data_collect_proc.pid = fork();
		if (_data_collect_proc.pid < 0)
		{
			LogResourceOutput(NTSS_LOG_ERROR, "定期FTPデータ収集子プロセスの生成失敗");
			_data_collect_proc.running = false;
		}
		else if (_data_collect_proc.pid == 0)
		{
			// 子プロセス
			snprintf(logMessage, MAX_LOG_TEXT, "定期FTPデータ収集子プロセスの起動: (%s, %s)", pConfig->uploadApp, myCharPid);
			LogOutput(NTSS_LOG_INFO, logMessage);

			execl(pConfig->uploadApp, pConfig->uploadApp /* 実行ファイル情報 */
				  ,
				  myCharPid /* プロセス番号 */
				  ,
				  NULL);
			LogResourceOutput(NTSS_LOG_ERROR, "子プロセスの起動失敗");
			exit(-1);
		}
	}

	// データ収集の司令を受けていた場合かつデータ収集プロセスが終了済み
	if (isMustExecDataCollect() == true && _data_collect_proc.running == false)
	{
		// 処理キューから取得
		res = dequeueActionQueue(cPayload, maxPayloadLen);
		if (res < 0)
		{
			// キューが空もしくは失敗
			setIsMustExecDataCollect(false);
			return 0;
		}

		// 構造体に分解
		payLoadLen = res;
		setCollectNotice(&rcvParams, cPayload, payLoadLen);
		_data_collect_proc.collectNotice = rcvParams;

		// 装置指定がある場合は装置リストを作成
		if (rcvParams.targetDevice[0].machineTypeCd[0] == 0x00)
		{
			// 装置指定なし
			sprintf(fileName, "%s", "");
		}
		else
		{
			// 装置指定あり
			writeFileDataCollectMachineList(rcvParams.targetDevice);
			sprintf(fileName, "%s", DATA_COLLECT_TARGET_FILE);
		}

		// // ファイルを作業フォルダへ移動
		// fetchCollectFiles(pConfig);
		// moveFileToTempDir(pConfig);

		// ゾンビ子プロセスの消去
		while (waitpid(-1, NULL, WNOHANG) > 0)
		{
		}

		// データ収集プロセスを起動
		_data_collect_proc.running = true;
		_data_collect_proc.pid = fork();
		if (_data_collect_proc.pid < 0)
		{
			LogResourceOutput(NTSS_LOG_ERROR, "データ収集子プロセスの生成失敗");
			_data_collect_proc.running = false;
		}
		else if (_data_collect_proc.pid == 0)
		{
			// 子プロセス
			snprintf(logMessage, MAX_LOG_TEXT, "データ収集子プロセスの起動: (%s, %s, %s, %s)", pConfig->uploadApp, myCharPid, rcvParams.manageNo, fileName);
			LogOutput(NTSS_LOG_INFO, logMessage);

			execl(pConfig->uploadApp, pConfig->uploadApp /* 実行ファイル情報 */
				  ,
				  myCharPid /* プロセス番号 */
				  ,
				  rcvParams.manageNo /* シーケンス番号 */
				  ,
				  fileName /* 装置指定ファイル名 */
				  ,
				  NULL);
			LogResourceOutput(NTSS_LOG_ERROR, "子プロセスの起動失敗");
			exit(-1);
		}
	}

	// シグナル通知前にアップロードアプリが異常終了などをしているケース
    // mod FNSI-バグ 通信サーバ 高 start
	// if (_data_collect_proc.finish == 0 && _data_collect_proc.running == true)
    if ((_data_collect_proc.finish == 0 && _data_collect_proc.running == true) || _data_collect_proc.collect_running == true)
    // mod FNSI-バグ 通信サーバ 高 end
	{
		int status;
		pid_t pid = waitpid(_data_collect_proc.pid, &status, WNOHANG);
		if (pid == -1)
		{
			snprintf(logMessage, MAX_LOG_TEXT, "データ収集子プロセスの終了済みチェックでエラー検知(%d)", errno);
			LogResourceOutput(NTSS_LOG_ERROR, logMessage);
			_data_collect_proc.running = false;
		}
		else if (pid == _data_collect_proc.pid)
		{
			// アップロードアプリが終了している、または回収済み
			LogResourceOutput(NTSS_LOG_ERROR, "データ収集子プロセスの終了済みを検知");
			_data_collect_proc.running = false;
            // add FNSI-バグ 通信サーバ 高 start
            _data_collect_proc.collect_running = false;
            // add FNSI-バグ 通信サーバ 高 end
		}
    }

	return 0;
}

/**
 * @brief ペイロードの内容をログ出力
 * 
 * @param cPayload 
 * @param payLoadLen 
 */
void log_publish_payload(u_char *cPayload, uint32_t payLoadLen)
{

	int16_t payloadLoopCount = 0;
	u_char payloadHex[MAX_LOG_TEXT] = {0}, logMessage[MAX_LOG_TEXT] = {0};

	snprintf(logMessage, MAX_LOG_TEXT, "publish (txt): %s ", cPayload);
	LogOutput(NTSS_LOG_INFO, logMessage);
	// HEXでも出力
	for (payloadLoopCount = 0; payloadLoopCount < payLoadLen; payloadLoopCount++)
	{
		sprintf(payloadHex + payloadLoopCount * 2, "%02x", cPayload[payloadLoopCount]);
	}
	payloadHex[payLoadLen * 2] = '\0';
	snprintf(logMessage, MAX_LOG_TEXT, "publish (hex) : %s ", payloadHex);
	LogOutput(NTSS_LOG_INFO, logMessage);
}

//add Input comsv log to mongo db. --趙-- start
/**
 * @fn int comsv_rest_post_MongoLogger(char *upData)
 * @brief upload log to mongodb.
 * @param[in] upData データ（char *）
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_post_mongologger(char *upData) {
    int ret, fd;
    char url[200] = {0};
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // char *resFile = "./tmpUploadMongodblogFileResponseCode.txt";
    // char *errFile = "./tmpUploadMongodblogFileErrResponseCode.txt";
    char *resFile = "/tmp/tmpUploadMongodblogFileResponseCode.txt";
    char *errFile = "/tmp/tmpUploadMongodblogFileErrResponseCode.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    unsigned char cbuff[10 * 1024] = {0};
    unsigned char tmpUpData[10 * 1024] = {0};
    unsigned char logMessage[1024] = {0};
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 start
    //unsigned char responseCode[256] = {0};
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 end

    ConfigParameter_t configParam = getConfigParameter();
    fd = mkstemp(resFile);
    if ( fd != 0 ) close(fd);
    fd = mkstemp(errFile);
    if ( fd != 0 ) close(fd);
    sprintf(url, "%s/device_edge/api/logging/mongo", configParam.awsHostUrl);
    sprintf(tmpUpData, ",%s,,,%d,99999999999,,,,ntss_main.exe,,,[INFO ],%s", configParam.facilityCode, configParam.deviceNo, upData);
    // REST用文字列作成
    sprintf(
        cbuff
        , "./sh/logger_rest_post.sh \"%s\" \"%s\" \"%s\" \"%s\" \"%s\""
        , url
        ,"info"
        , tmpUpData
        , resFile
        , errFile
    );

    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 start
    /*
    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    ret = system(cbuff);

    if ( WIFEXITED(ret) ) {
        // 子プロセスが正常に終了した場合
        // 子プロセスの終了ステータスを取得
        ret = WEXITSTATUS(ret);
    }
    if ( readFileOneLine(responseCode, 50, resFile) == 0 ) {
        snprintf(logMessage, sizeof(logMessage), "%s REST 応答あり, (%s)", "Upload comsv log to mongodb", responseCode);
    }
    else {
        snprintf(logMessage, sizeof(logMessage), "%s REST 実行システムコール応答, (%d)", "Upload comsv log to mongodb", ret);
    }
	
    LogOutput(NTSS_LOG_INFO, logMessage);
    // 終了コード作成
    if ( 0 < ret ) {
        // 成功系
        if ( 200 == ret || 226 == ret ) {
            ret = 0;
        }
        else if ( 408 == ret ) {
            // コネクションタイムアウトエラー
            ret = -1;
        }
        else {
            // その他エラー
            ret = -2;
        }
    }
    else {
        // 取得失敗エラー
        ret = -3;
    }

    if ( ret < 0 && readFileOneLine(responseCode, 255, errFile) == 0 ) {
        snprintf(logMessage, sizeof(logMessage), "%s REST 失敗応答を取得, (%s)", "Upload comsv log to mongodb", responseCode);
        LogOutput(NTSS_LOG_ERROR, logMessage);
    }

    // 使用したファイルの消し込み作業
    removeFileFullPath(resFile);
    removeFileFullPath(errFile);   
    */
    // RESTコールして結果を取得する
    ret = ntss_restcall("", "", cbuff, resFile, errFile, "Upload comsv log to mongodb");
    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 end
    return ret;
}
//add Input comsv log to mongo db. --趙-- end

// #8081 add 2023.08.08 通信状態変更通知処理を別スレッドで実施する TDC米沢 start
/**
* @brief 通信状態変更通知処理(スレッド)
*
* @details 通信状態変更通知処理を行う
* 
* @param ptr ポインタ
* @description
* @return なし
* @attention 特になし
*/
void *
requestCommFailThread(void *ptr)
{
	ThreadParameter_t *state = (ThreadParameter_t *)ptr;

	LogOutput(NTSS_LOG_INFO, "通信状態変更通知処理スレッド開始");

	// 500ms
	struct timespec timeReqSleep = {5, 0};

    //
	while (state->isRunning)
	{
		// sleep
		nanosleep(&timeReqSleep, NULL);

		// 通信状態変更チェック
		if (nRequestCommFail != -1) {
			// 通信状態変更あり
			setCommAliveState(nRequestCommFail);
			
			// 通信SVからの通信状態が通信許可であるかどうか場合
			if (nRequestCommFail == 0) {
				// 通信許可通知

				// WebSocketクライアントオブジェクト判定
				if (checkWSClient() == 0)
				{
					// WebSocketクライアントオブジェクトが作成されていない場合

					// WebSocketを強制接続
					bForceWSConnect = true;
				}
				else
				{
					// WebSocketクライアントオブジェクトが作成されている場合

					// WebSocket接続判定
					if (checkWSClientConnected() != 1)
					{
						// 接続中ではない
						if (checkWSClientConnecting() == 0) {
							// 接続試行をしていない

							// WebSocketを強制接続
							bForceWSConnect = true;
						}
					}
				}
			}
			// 通信SVからの通信状態変更通知を初期化
			nRequestCommFail = -1;
		}
	}

	LogOutput(NTSS_LOG_INFO, "通信状態変更通知処理スレッド終了");
}
// #8081 add 2023.08.08 通信状態変更通知処理を別スレッドで実施する TDC米沢 end
