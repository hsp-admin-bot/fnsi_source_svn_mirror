#include <stdio.h>
#include <stdint.h>
#include <string.h>
#include <signal.h>
#include <stdlib.h>
#include <stdbool.h>
#include <pthread.h>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <arpa/inet.h>

#include "ntss_logsv.h"
#include "ntss_log_upload.h"
#include "logsv_config.h"
#include "logsv_output.h"
#include "../common/nkklib/nkklib.h"
#include "../common/libs/ntss_etc_lib.h"
#include "../common/libs/ntss_log_lib.h"
// #10437 2024.03.26 add DEログに実行モジュールのリビジョンを出力する TDC高村 start
#include "../common/libs/ntss_revision.h"
// #10437 2024.03.26 add DEログに実行モジュールのリビジョンを出力する TDC高村 end
// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻をロガーと共有 TDC米沢 start
#include "../common/libs/parson.h"
/**
 * @brief 通信サーバー設定更新判定用フラグ
 * 
 */
volatile sig_atomic_t updateComSVConfigFlag = false;
extern bool SetLogUploadTimeFromComSVConfig(char *triggerMsg, char *value);
// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻をロガーと共有 TDC米沢 end

#define CONFIG_FILE "./conf/ntss_logger.conf"
#define CONFIG_COMMON_FILE "./conf/ntss_common.conf"
#define CONFIG_NETWORK_FILE "./conf/ntss_network.conf"

/**
 * @brief ログ収集シグナル番号
 * 
 */
#define SIG_LOG_GATHER			37
/**
 * @brief ログ収集受領シグナル番号
 * 
 */
#define SIG_LOG_GATHER_RECV		38
/**
 * @brief ログ収集完了シグナル番号
 * 
 */
#define SIG_LOG_GATHER_END		39

// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻をロガーと共有 TDC米沢 start
/**
 * @brief 通信サーバー設定更新シグナル番号
*/
#define SIG_COMSV_CONFIG_UPDATE 50
// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻をロガーと共有 TDC米沢 end

/**
 * @brief 現在時刻
 * 
 */
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
//long now_time;
time_t now_time;
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

/**
 * @brief 前回アップロード実施日時
 * 
 */
char upLastTime[20] = "";

/**
 * @brief accept処理中フラグ
 * 
 */
bool is_accept_running = false;

/**
 * @brief 通信制御データ
 * 
 */
struct connect_socket con_sock[APP_MAX + 1];

/**
 * @brief thread
 * 
 */
pthread_t thr_sv[APP_MAX + 1];

/**
 * @brief 設定情報
 * 
 */
ConfigParameter_t configParam;

/**
 * @brief 終了判定用フラグ
 * 
 */
volatile sig_atomic_t endProcessFlag = 0;

/**
 * @brief ログ収集判定用フラグ
 * 
 */
volatile sig_atomic_t logGatherFlag = 0;

/**
 * @brief シグナル受信処理
 *
 * @details シグナルを受け付ける
 *
 * @description
 * @param[in] *signum
 * @return なし
 * @attention 特になし
 */
void signalHandler(int signum)
{
	uint16_t no;
    unsigned char *msg = NULL;
	extern __sighandler_t setSignal();
	extern void logsv_accept_close(int dno);
    switch( signum )
    {
        case SIGINT:    // キーボード割り込み(ctrl+c)

            // 終了処理
            endProcessFlag = 1;
            is_accept_running = false;
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

        case SIGHUP:    // ハングアップ

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
				LogOutput_logger( NTSS_LOG_ERROR, "シグナルの再設定ができないので終了します" );
			}
            break;

        case SIG_LOG_GATHER:    // ログ収集

            // ログ収集
            logGatherFlag = 1;
            msg ="SIG_LOG_GATHER受信";
			// ログ収集受領シグナル送信
			sendLogGatherSignal(SIG_LOG_GATHER_RECV);
			if( setSignal() == SIG_ERR ) {
				// シグナル設定エラー
				LogOutput_logger( NTSS_LOG_ERROR, "シグナルの再設定ができないので終了します" );
			}
            break;
		// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻を取得 TDC米沢 start
		case SIG_COMSV_CONFIG_UPDATE:	// 通信サーバー設定更新
            msg = "SIG_COMSV_CONFIG_UPDATE受信";
			updateComSVConfigFlag = true;
			break;
		// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻を取得 TDC米沢 end

    }

    if( msg != NULL )
    {
        // // 画面表示
        // printf( "%s\n", msg );
    }
}

/**
 * @brief シグナル設定
 *
 * @details シグナル設定を行う
 *
 * @description
 * @return シグナル設定結果
 * @attention 特になし
 */
__sighandler_t setSignal()
{
    __sighandler_t ret = SIG_DFL;

    // プログラム終了のためのシグナル設定
    if( ret != SIG_ERR )
    {
        ret = signal( SIGTERM, signalHandler );
    }
    if( ret != SIG_ERR )
    {
        ret = signal( SIGINT,  signalHandler );
    }
    if( ret != SIG_ERR )
    {
        ret = signal( SIGHUP, signalHandler );
    }
    if( ret != SIG_ERR )
    {
        ret = signal( SIGPIPE, signalHandler );
    }

    // ログ収集要求のためのシグナル設定
    if( ret != SIG_ERR )
    {
        ret = signal( SIG_LOG_GATHER, signalHandler );
    }

	// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻を取得 TDC米沢 start
	// 通信サーバー設定更新のためのシグナル設定
    if( ret != SIG_ERR )
    {
        ret = signal( SIG_COMSV_CONFIG_UPDATE, signalHandler );
    }
	// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻を取得 TDC米沢 end

    return ret;    
}

/**
 * @brief 接続処理
 * 
 * @return true 正常終了
 * @return false 異常終了
 */
bool logsv_accept()
{
	int res;
	uint16_t no;
    socklen_t len;
	int sock;
	unsigned char clog[1100]; 
	fd_set ready;
	struct sockaddr_in serv;
	struct timeval seltime;

	extern void logsv_accept_close(int dno);
	extern int check_upload_time(char *upTime, char *upLastTime);

	is_accept_running = true;	// 起動中

	// ソケットを作成
	sock = socket(AF_INET, SOCK_STREAM, 0);
	if ( sock < 0 ) {
		sprintf( clog, "ソケット生成失敗");
		printf( "%s\n", clog );
		LogOutput_logger( NTSS_LOG_ERROR, clog );
        is_accept_running = false;
		return false;
	}

	// ソケットの設定
    serv.sin_family = AF_INET;
	serv.sin_addr.s_addr = INADDR_ANY;
	serv.sin_port = htons(configParam.logsvPort);

	for ( ; ; sleep(5) ) {
		if ( is_accept_running==false || endProcessFlag == 1 ) { // 停止処理
			is_accept_running=false;
			close(sock);
			return true;
		}
		if ( bind(sock, (struct sockaddr *)&serv, sizeof(serv))<0 ) {
			sprintf( clog, "bind ERROR");
			printf( "%s\n", clog );
			LogOutput_logger( NTSS_LOG_ERROR, clog );
			continue;
		}
		len = sizeof(serv);
		if ( getsockname(sock, (struct sockaddr *)&serv, &len)<0 ) {
			sprintf( clog, "getsockname ERROR");
			printf( "%s\n", clog );
			LogOutput_logger( NTSS_LOG_ERROR, clog );
			continue;
		}
        // ソケット名まで取得成功で抜ける
		break;
	}

	// ログ復旧処理スレッドの起動
	printf( "%s\n", "ログ復旧スレッドの起動" );
	//LogOutput_logger( NTSS_LOG_INFO, clog );
	con_sock[APP_MAX].using = true;
	con_sock[APP_MAX].thread_no = APP_MAX;
	createFolder( configParam.logsvTemp );
	// スレッド作成
	pthread_create(&(thr_sv[APP_MAX]), NULL, logsv_recovery, &(con_sock[APP_MAX]));

    // 待ち受け開始
	listen(sock, LISTEN_MAX);

	// 正常動作ログ記録日時
	time_t last_watchdog_time;
	time(&last_watchdog_time);

	for ( ; ; usleep(100000) ) {

		if ( is_accept_running==false || endProcessFlag == 1 ) {
			is_accept_running = false;
            break;	// 停止
        }

        // 現在時間の読み出し
        time(&now_time);

        // 一定間隔(180秒[3分]間隔)で正常動作していることをログに記録する
        if ((last_watchdog_time + 180) <= now_time)
        {
            // #10437 2024.03.26 mod DEログに実行モジュールのリビジョンを出力する TDC高村 start
			//LogOutput_logger( NTSS_LOG_INFO, "正常動作中..." );
			sprintf(clog, "正常動作中[Rev:%s]...", RELEASE_REVISION);
			LogOutput_logger(NTSS_LOG_INFO, clog);
            // #10437 2024.03.26 mod DEログに実行モジュールのリビジョンを出力する TDC高村 end

            // 記録日時を保持
            last_watchdog_time = now_time;
        }

		if (logGatherFlag == 1) {	// ログ収集処理
			// ログファイルをアップロード
			res = uploadNTSSLog(&configParam);
			if ( res==1 ) {
				strcpy( clog, "通知によるログファイルアップロード処理成功" );
				printf( "%s\n", clog );
				LogOutput_logger( NTSS_LOG_INFO, clog );
			}
			else {
				sprintf( clog, "通知によるログファイルアップロード処理失敗(%d)", res );
				printf( "%s\n", clog );
				LogOutput_logger( NTSS_LOG_ERROR, clog );
			}
			// ログ収集完了シグナル送信
			sendLogGatherSignal(SIG_LOG_GATHER_END);
			logGatherFlag = 0;
		}

		// ログファイルアップロード時刻チェック
		if ( check_upload_time(configParam.uploadTime, upLastTime) ) {
			// ログファイルをアップロード
			res = uploadNTSSLog(&configParam);
			if ( res==1 ) {
				strcpy( clog, "指定時刻によるログファイルアップロード処理成功" );
				printf( "%s\n", clog );
				LogOutput_logger( NTSS_LOG_INFO, clog );
			}
			else {
				sprintf( clog, "指定時刻によるログファイルアップロード処理失敗(%d)", res );
				printf( "%s\n", clog );
				LogOutput_logger( NTSS_LOG_ERROR, clog );
			}
		}

		// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻をロガーと共有 TDC米沢 start
		// SIG_COMSV_CONFIG_UPDATE受信時
		if(updateComSVConfigFlag) {

			SetLogUploadTimeFromComSVConfig("SIG_COMSV_CONFIG_UPDATE受信", configParam.uploadTime);
			
			// 処理終了
			updateComSVConfigFlag = false;
		}
		// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻をロガーと共有 TDC米沢 end

		FD_ZERO(&ready);        // fd_set初期化 
		FD_SET(sock,&ready);    // fd設定

        // データ受信待ち
		seltime.tv_sec=5;
		seltime.tv_usec=0;
		if ( select(FD_SETSIZE,&ready,0,0,&seltime)<=0 ) {
            continue;
        }

        // fdに読み込みデータがあるならば、ソケットをリストに登録する
		if ( FD_ISSET(sock,&ready) ) {

			for (no = 0; no < APP_MAX; no++){
				if(con_sock[no].using == false){
					break;
				}
			}

			if ( no < APP_MAX) {
                // 待受（処理はブロックされる)
				con_sock[no].accept_socket = accept(sock,(struct sockaddr *)&serv,&len);
				if ( con_sock[no].accept_socket<0 ) {
                    // 失敗
					con_sock[no].accept_socket = (-1);
				}
				else {
					if ( getsockname(sock,(struct sockaddr *)&serv,&len)<0 ) {
                        // ソケット名の取得に失敗
						con_sock[no].accept_socket = (-1);
						continue;
					}
					// 受信スレッドの起動
					sprintf( clog, "通信スレッド[%d]の起動", no);
					printf( "%s\n", clog );
					LogOutput_logger( NTSS_LOG_INFO, clog );

					con_sock[no].using = true;
					con_sock[no].thread_no = no;
					// スレッド作成
					pthread_create(&(thr_sv[no]), NULL, logsv_stream, &(con_sock[no]));
				}
			}
		}
	}

	for ( no=0; no < APP_MAX; no++ ) {
		if ( con_sock[no].accept_socket > 0 ) {
			logsv_accept_close( no );
		}
	}
	sprintf( clog, "ソケットのクローズ");
    printf( "%s\n", clog );
    LogOutput_logger( NTSS_LOG_INFO, clog );
	close(sock);

	// ログ復旧処理スレッドの終了指示
	con_sock[APP_MAX].running = false;

    printf( "スレッド終了待ち\n");
	for (;;usleep(3000000)) {
		for ( no=0; no <= APP_MAX; no++ ) {
			if ( con_sock[no].using == true ) {
				break;
			}
		}
		if ( no > APP_MAX ) {
			break;
		} 
	}

    return true;
}

void logsv_accept_close(int dno){
	logsv_socket_close(&(con_sock[dno]));
}

/**
 * @brief  強制終了処理（待受用） 
 */
void logsv_accept_exit()
{
	is_accept_running = false;	// 停止
}

/**
 * @brief メイン処理
 * 
 * @param argc 
 * @param argv 
 * @return int 
 */
int main(int argc, char *argv[]) {

    unsigned char clog[1100];
    extern void readConfig(ConfigParameter_t *configParam);
	extern void GetSystemAnalyzer(char *buf);

	// システム情報出力（一度実行しておく）
	GetSystemAnalyzer(clog);
    //printf( "%s\n", clog );

	// 設定ファイルの読み込み
	memset(&configParam, 0, sizeof(configParam));
	readConfig(&configParam);

	// ログサーバー出力設定
	LogsvInit(&configParam);

    // システム起動
    sprintf( clog, "[START],システム起動");
    printf( "%s\n", clog );
    LogOutput_logger( NTSS_LOG_INFO, clog );

	// シグナル設定
    if( setSignal() == SIG_ERR )
    {
        // シグナル設定エラー
		sprintf( clog, "シグナルの設定ができないので終了します");
		printf( "%s\n", clog );
		LogOutput_logger( NTSS_LOG_ERROR, clog );
        exit(EXIT_FAILURE);
    }

    // ソケット通信処理
    logsv_accept();

    // システム終了
    sprintf( clog, "システム終了");
    printf( "%s\n", clog );
    LogOutput_logger( NTSS_LOG_INFO, clog );

    return 0;
}

/**
 * @brief 設定ファイルの読み込みと反映
 */
void readConfig(ConfigParameter_t *configParam){
	
    unsigned char clog[1100];    

	snprintf(clog, 1100, "read : %s", CONFIG_FILE);
    printf( "%s\n", clog );
    LogOutput_logger( NTSS_LOG_INFO, clog );

	if (readConfigFile(CONFIG_FILE, configParam) < 0){
		snprintf(clog, 1100, "%s OPEN ERROR", CONFIG_FILE);
		printf( "%s\n", clog );
    	LogOutput_logger( NTSS_LOG_ERROR, clog );
		return;
	}
	snprintf(clog, 1100, "read : %s", CONFIG_COMMON_FILE);
    printf( "%s\n", clog );
    LogOutput_logger( NTSS_LOG_INFO, clog );

	if (readConfigCommonFile(CONFIG_COMMON_FILE, configParam) < 0){
		snprintf(clog, 1100, "%s OPEN ERROR", CONFIG_COMMON_FILE);
		printf( "%s\n", clog );
    	LogOutput_logger( NTSS_LOG_ERROR, clog );
		return;
	}
	snprintf(clog, 1100, "read : %s", CONFIG_NETWORK_FILE);
    printf( "%s\n", clog );
    LogOutput_logger( NTSS_LOG_INFO, clog );

	if (readConfigNetworkFile(CONFIG_NETWORK_FILE, configParam) < 0){
		snprintf(clog, 1100, "%s OPEN ERROR", CONFIG_NETWORK_FILE);
		printf( "%s\n", clog );
    	LogOutput_logger( NTSS_LOG_ERROR, clog );
		return;
	}

	// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻を取得 TDC米沢 start
	// 通信サーバー設定：ログアップロード実施時刻を取得
	SetLogUploadTimeFromComSVConfig("起動時", configParam->uploadTime);
	//printf("Now UPLOAD_TIME:%s\n", configParam->uploadTime);
	// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻を取得 TDC米沢 end

}

/**
 * @brief ログ収集シグナル送信処理
 * 
 */
void sendLogGatherSignal(int signo)
{                         
	u_char command[512] = {0};
    unsigned char cbuff[ MAX_STA_TEXT * 2 ] = {0};
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    // ペイロードの内容をログ出力
	if ( signo == SIG_LOG_GATHER_RECV ) {
	    snprintf(logMessage, MAX_LOG_TEXT, "ログ収集受領シグナル送信");
	}
	else {
	    snprintf(logMessage, MAX_LOG_TEXT, "ログ収集完了シグナル送信");
	}
    LogOutput_logger( NTSS_LOG_INFO, logMessage );

    // RESTをコールする
    sprintf(
        cbuff
        , "./sh/send_signal.sh \"%s\" %d"
        , UPDATER_NAME
        , signo
    );
	
    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    int ret = system( cbuff );

    if( WIFEXITED( ret ))
    {
        // 子プロセスが正常に終了した場合

        // 子プロセスの終了ステータスを取得
        ret = WEXITSTATUS( ret );
    }
}

/**
 * @brief ログファイルアップロード時刻チェック
 * 
 * @param *optTime アップロード実施時間（設定内容）
 * @param *optLastTime 前回アップロード実施日時
 * @return bool 1:実施対象 0:実施対象外
 */
int check_upload_time(char *upTime, char *upLastTime)
{
	bool optRet = false;
	char bufNow[20];
	char bufConf[20];
	char bufDate[12];
	char bufTime[10];

	if ( upTime[0] == 0 ) {
		// 設定なし
		return optRet;
	}

	time_str(now_time, bufDate, bufTime, 1);
	if ( *upLastTime == 0 ) {
		// 初回起動時
		sprintf(upLastTime, "%s %s", bufDate, bufTime);
		return optRet;
	}

	// 現在日時
	sprintf(bufNow, "%s %s", bufDate, bufTime);
	// 設定日時
	sprintf(bufConf, "%s %s   ", bufDate, upTime);

	if ( strcmp(upLastTime, bufConf) < 0 && strcmp(bufConf, bufNow) < 0 ) {
		// 前回アップロード実施日時 < 設定日時 かつ 設定日時 < 現在日時
		// 前回アップロード実施日時 に 現在日時 をセット
		strcpy(upLastTime, bufNow);
		optRet = true;
	}

	return optRet;
}

// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻をロガーと共有 TDC米沢 start
#define WORK_DATA_PATH	    "./data"	        // 作業データ用フォルダ
#define WORK_COMMON_PATH	"COMMON"	        // 共通データフォルダ
#define WORK_COMSV_SET	    "comsv_set.json"	// 通信サーバ設定用

/**
 * @brief 通信サーバー設定からログアップロード実施時刻設定を取得して設定する
 *
 * @param[in]   triggerMsg  呼び出し条件
 * @param[out]  value       設定先パラメータ
 * 
 * @return true 成功
 * @return false 失敗
 */
bool SetLogUploadTimeFromComSVConfig(char *triggerMsg, char *value)
{
	bool ret = false;
    char *bp;
    char jfile[NTSS_STR_MAX_SIZE] = {0};
    char buf[NTSS_STR_MAX_SIZE];
    char oldValue[NTSS_STR_MAX_SIZE] = {0};
    unsigned char logMessage[NTSS_STR_MAX_SIZE] = {0};
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;

    // ファイル名作成（共通データフォルダ内の通信サーバー設定ファイル）
    sprintf(jfile, "%s/%s/%s", WORK_DATA_PATH, WORK_COMMON_PATH, WORK_COMSV_SET);

    // 通信サーバー設定ファイルの有無
    if (existFolderFile(jfile, NULL))
    {
        // 通信サーバー設定ファイルがある場合

        // JSONファイルを読み込みJSONオブジェクトを生成
        root_value = json_parse_file(jfile);
        if ( root_value != NULL ) {
			// ルートオブジェクト取得
			root = json_object(root_value);
			if ( root != NULL ) {
				// ログのアップロード実施時刻
				bp = (char*)json_object_dotget_string(root, "logUploadTime");
				if ( bp != NULL && bp[0] != 0 ) {
					strcpy(buf, bp);
					if ( strlen(buf) == 4 ) {
						// 変更前の値を保持
						strcpy(oldValue, value);
						sprintf(value, "%.2s:%.2s", buf, buf + 2);
						// ログ
						sprintf(logMessage,  "呼び出し条件:%s => 現在のログアップロード実施時刻[%s]を通信サーバー設定の設定値[%s]に変更", triggerMsg, oldValue, value);
						LogOutput(NTSS_LOG_INFO, logMessage);
						printf("%s\n", logMessage);
						ret = true; 
					}
				}
			}

			json_value_free(root_value);
		}
    }
	return ret; 
}
// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻をロガーと共有 TDC米沢 end