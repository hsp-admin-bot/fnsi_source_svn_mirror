#include <stdio.h>
#include <string.h>
#include <stdbool.h>
#include <time.h>

#include "ntss_interval_alarm.h"

// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
//#include "ntss_file.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
#include "ntss_comsv.h"

#include "../common/nkklib/nkklib.h"
#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/ntss_etc_lib.h"


/**
 * @brief データを送信する形式に変換
 * 
 * @param cPayload      格納先バッファ
 * @param param         設定ファイル情報
 * @return 変換したデータサイズ
 */
u_int32_t
buildIntervalAlarmSendData( u_char *cPayload
                          , ThreadParameter_t *param
                          )
{

    // 通知データ作成
    // "facilityCd": "999900",
    // "deviceEdgeNo": 1
    return sprintf(
          cPayload
        , "\"facilityCd\":\"%s\", \"deviceEdgeNo\":%d"
        , param->facilityCd
        , param->deviceEdgeNo
    );
}


/**
 * @brief 治療中の場合に定期通知チェック用REST-APIを呼び出す
 * 
 * @param param 設定項目構造体
 * @param rest  REST-API
 * 
 * @return なし
 */
void
runIntervalAlarmNotice(ThreadParameter_t *param, u_char *rest)
{
    u_char cPayload[NTSS_STR_MAX_SIZE];
    u_int32_t payLoadLen;
    int32_t ret = 0;

    u_char cbuff[NTSS_STR_MAX_SIZE];
    u_char logMessage[4096];
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // char *sendBodyFile = "./tmpIntervalBodyData.txt";
    // char *responseFile = "./tmpIntervalAlarmResponseCode.txt";
    // char *errFile = "./tmpIntervalAlarmErrResponseCode.txt";
    char *sendBodyFile = "/tmp/tmpIntervalBodyData.txt";
    char *responseFile = "/tmp/tmpIntervalAlarmResponseCode.txt";
    char *errFile = "/tmp/tmpIntervalAlarmErrResponseCode.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    u_char responseCode[NTSS_STR_MAX_SIZE];
    char command[NTSS_STR_MAX_SIZE * 2];
    bool bRunning = false;
    int intlop;

    // 治療中の装置判定
    for( intlop = 0; intlop < DEV_MAX; intlop++ )
    {
        // 装置情報ありで治療中の判定
        if(param->con_sock[intlop].running
         && param->con_sock[intlop].scn.mon_sta == 1 )
        {
            // 装置情報ありで治療中

            bRunning = true;

            break;
        }
    }

    // 治療中判定
    if( bRunning )
    {
        // 治療中の装置がある場合場合

        // データを送信する形式に変換
        payLoadLen = buildIntervalAlarmSendData(cPayload, param);

        // 一時ファイル作成
        outputFile(sendBodyFile, cPayload, payLoadLen);

        // RESTをコールする
        sprintf(
            cbuff, "./sh/post_b64.sh \"%s\" \"%s\" \"%s\" \"%s\"", rest, sendBodyFile, responseFile, errFile);
        // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
        ret = system(cbuff);
        if (WIFEXITED(ret))
        {
            // 子プロセスが正常に終了した場合

            // 子プロセスの終了ステータスを取得
            ret = WEXITSTATUS(ret);
        }
        if (readFileOneLine(responseCode, 50, responseFile) == 0)
        {
            snprintf(logMessage, sizeof(logMessage) - 1, "ホスト報知定期監視 REST 応答あり, (%s)", responseCode);
        }
        else
        {
            snprintf(logMessage, sizeof(logMessage) - 1, "ホスト報知定期監視 REST 実行システムコール応答, (%d)", ret);
        }
        LogOutput(NTSS_LOG_INFO, logMessage);

        // 終了コード作成
        if (0 < ret)
        {
            // 成功系
            if (200 == ret)
            {
                ret = 0;
            }
            else
            {
                // エラー
                ret = 1;
            }
        }
        else
        {
            // 転送失敗エラー
            ret = 2;
        }
        
        if (ret > 0 && readFileOneLine(responseCode, 255, errFile) == 0)
        {
            snprintf(logMessage, sizeof(logMessage) - 1, "ホスト報知定期監視 REST 失敗応答を取得, (%s)", responseCode);
            LogResourceOutput(NTSS_LOG_ERROR, logMessage);
        }

        // 作業用ファイル削除
        removeFileFullPath(sendBodyFile);
        removeFileFullPath(responseFile);
        removeFileFullPath(errFile);
    }
}

/**
* @brief ホスト報知定期監視処理(スレッド)
*
* @details ホスト報知定期監視処理を行う
* 
* @param ptr ポインタ
* @description
* @return なし
* @attention 特になし
*/
void *
intervalAlarmThread(void *ptr)
{
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //long LastTime = get_time();	// 前回時間
    time_t LastTime = get_time();	// 前回時間
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

	ThreadParameter_t *state = (ThreadParameter_t *)ptr;

	LogOutput(NTSS_LOG_INFO, "ホスト報知定期監視通知スレッド開始");

	// 2s
	struct timespec timeReqSleep = {2, 0};

    // REST-API
	u_char restIntervalAlarmNotice[NTSS_STR_MAX_SIZE * 2];
	sprintf(restIntervalAlarmNotice, "%s/%s", state->restDeviceEdgeUrl, API_INTERVAL_ALART_NOTICE);

    //
	while (state->isRunning)
	{
		// sleep(2s)
		nanosleep(&timeReqSleep, NULL);

        // REST(60s)
        if ( (LastTime + 60) <= get_time() ) {
            LastTime = get_time();
            // ホスト報知定期監視通知
            runIntervalAlarmNotice(state, restIntervalAlarmNotice);
        }
	}

	LogOutput(NTSS_LOG_INFO, "ホスト報知定期監視通知スレッド終了");
}
