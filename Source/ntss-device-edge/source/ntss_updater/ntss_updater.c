/**
* @file ntss_updater.c
* @brief アプリ更新を実現する処理
* @author Y.Kataguchi
* @date 2018/07/17
* @details 
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
#include "config_read.h"
#include "ntss_wsclient.h"
#include "ntss_update.h"
#include "ntss_version.h"
#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/ntss_etc_lib.h"
#include "../common/libs/master_controller.h"
#include "../common/nkklib/nkklib.h"
// #8729 2023.06.01 add RESTリトライ処理のパラメータを設定で持つ TDC片口 start
#include "../common/libs/ntss_restcall_lib.h"
// #8729 2023.06.01 add RESTリトライ処理のパラメータを設定で持つ TDC片口 end

extern void set_signal(int p_signame);

//! 自プロセスのID
u_char myCharPid[20];

//! trueならばシステム終了させるフラグ
volatile sig_atomic_t _is_exit_program = 0;

//! デバイス番号
uint16_t _device_no;

//! 現在時間
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
//long tim;
time_t tim;
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
//! 現在時間構造体
struct tm *tmc;

/**
 * @brief シグナル受信処理
 *
 */
void sig_handler(int p_signame)
{
	u_char *msg = NULL;
	u_char *seqNo = NULL;

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

	case SIGPIPE:
		set_signal(SIGPIPE);
		msg = "SIGPIPE受信";
		setRunningParameter(true, true, msg);
		break;

	case SIG_LOG_GATHER_RECV:
		set_signal(SIG_LOG_GATHER_RECV);
		msg = "SIG_LOG_GATHER_RECV受信";
		setIsJobRunningValue(true);
		setRunningParameter(true, true, msg);
		break;

	case SIG_LOG_GATHER_END:
		set_signal(SIG_LOG_GATHER_END);
		msg = "SIG_LOG_GATHER_END受信";
		seqNo = getLogGatherSeqNo();
		u_char information[50] = {0};
		snprintf(information, 50, "\"%s\":\"%s\"", "updater_info", seqNo);
		sendResponse(seqNo, "2", information);
		setIsJobRunning(false, -1);
		setRunningParameter(true, true, msg);
		break;
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

	snprintf(msg, MAX_LOG_TEXT, "read : %s", CONFIG_FILE);
	LogOutput(NTSS_LOG_INFO, msg);
	if (readConfigFile(CONFIG_FILE) < 0)
	{
		snprintf(msg, MAX_LOG_TEXT, "%s OPEN ERROR", CONFIG_FILE);
		LogResourceOutput(NTSS_LOG_ERROR, msg);
		return;
	}
	if (readConfigNetworkFile(CONFIG_NETWORK_FILE) < 0)
	{
		snprintf(msg, MAX_LOG_TEXT, "%s OPEN ERROR", CONFIG_NETWORK_FILE);
		LogResourceOutput(NTSS_LOG_ERROR, msg);
	}
	_device_no = getConfigParameter().deviceNo;
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

	setRunningParameter(true, false, "");

	set_signal(SIGINT);				 // Ctrl+C
	set_signal(SIGTERM);			 //
	set_signal(SIGHUP);				 //
	set_signal(SIGPIPE);			 //
	set_signal(SIG_LOG_GATHER_RECV); //
	set_signal(SIG_LOG_GATHER_END);	 //

	u_char logMessage[MAX_LOG_TEXT] = {0};

	bool rc = false;

	// 自分のプロセスIDを取得
	snprintf(myCharPid, 20, "%d", getpid());
	snprintf(logMessage, MAX_LOG_TEXT, "my process ID : %s ", myCharPid);
	LogOutput(NTSS_LOG_INFO, logMessage);

	// 起動時間取得
	time(&tim);
	tmc = localtime(&tim);

	// 設定ファイルの読み込み
	readConfig();
	ConfigParameter_t configParam = getConfigParameter();
	resetDlFolder();
	// #8729 2023.06.01 add RESTリトライ処理のパラメータを設定で持つ TDC片口 start
	initRestCall();
	// #8729 2023.06.01 add RESTリトライ処理のパラメータを設定で持つ TDC片口 end

	if (_is_exit_program == 1)
	{
		LogOutput(NTSS_LOG_INFO, "終了シグナル受信");
		// 古いログを強制削除
		deleteLogFile(0x01);

		LogOutput(NTSS_LOG_INFO, "Exit Program");
		return rc;
	}

	uint32_t dataCount = 0;
	int32_t sendloopCount = 0;

	// 500ms
	struct timespec timeReq = {0, 450 * 1000000};

	// 処理開始日時を設定
	time_t last_ws_chk_time = time(&last_ws_chk_time);
	time_t tNow;
	time_t last_run_time = 0;

	// 正常動作ログ記録日時
	time_t last_watchdog_time;
	time(&last_watchdog_time);

	RunningParameter_t runparam;

	// char vmSize[256];
	// sprintf( vmSize, "grep VmSize /proc/%d/status", getpid() );
	while (_is_exit_program == 0)
	{
		//fprintf("-->sleep");
		// sleep
		nanosleep(&timeReq, NULL);

		clientClose();

		/////////////////////////////
		// websocketの状態確認・再接続
		/////////////////////////////

		clientClose();

		// 現在値取得
		time(&tNow);

		// 一定間隔(180秒[3分]間隔)で正常動作していることをログに記録する
		if ((last_watchdog_time + 180) <= tNow)
		{
			LogOutput(NTSS_LOG_INFO, "正常動作中...");

			// 記録日時を保持
			last_watchdog_time = tNow;
		}

		// WebSocketクライアントオブジェクト判定
		if (checkWSClient() == 0)
		{
			// WebSocketクライアントオブジェクトが作成されていない場合
			if ((getWSClientClosedTime() + 5) <= tNow)
			{
				// 最後に切断されてから５秒以上経過しているならば接続再試行する

				// WebSocketクライアントオブジェクトを構築して通信開始
				if (initWSClient(configParam.websockHostUrl, configParam.facilityCode, _device_no) == 0)
				{
					sprintf(logMessage, "Unable to initialize new WS client.");
					LogResourceOutput(NTSS_LOG_ERROR, logMessage);
					// _is_exit_program = 1;
				}
			}
		}
		else
		{
			// WebSocketクライアントオブジェクトが作成されている場合

			// WebSocket接続判定
			if (checkWSClientConnected() == 1)
			{
				// WebSocketが接続中
			}
			else
			{
				// 接続中ではない
				if (checkWSClientConnecting() == 0)
				{
					// 接続試行をしていない
					if ((last_ws_chk_time + 10) <= tNow)
					{
						// 前回実行から10秒経過している
						// ソケットクローズフラグが立っていれば強制クローズ
						forceCloseAndResetWs();
						// 処理開始日時を保持
						last_ws_chk_time = tNow;
					}
				}
			}
			// 前回実施日時から処理間隔が経過しているかどうか
			if ((last_ws_chk_time + configParam.webSocketKeepAliveInterval) <= tNow)
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
				last_ws_chk_time = tNow;
			}
		}

		// 予定時刻ファイルチェック
		checkPlanUpdate();

		// シグナルのログ出力
		runparam = getRunningParameter();
		if (runparam.isRcvSignal)
		{
			LogOutput(NTSS_LOG_INFO, runparam.exitMessage);
			setRunningParameter(runparam.isRunning, false, "");
		}

		time(&last_run_time);
	}

	// 終了シグナルのログ出力
	runparam = getRunningParameter();
	if (runparam.isRcvSignal)
	{
		LogOutput(NTSS_LOG_INFO, runparam.exitMessage);
	}

	// WebSocketクライアントオブジェクトが作成されている場合
	if (checkWSClient() == 1)
	{
		// WebSocketクライアントオブジェクトをクローズ
		closeWSClient();
	}

	clientClose();

	LogOutput(NTSS_LOG_INFO, "Exit Program");
	return 0;
}
