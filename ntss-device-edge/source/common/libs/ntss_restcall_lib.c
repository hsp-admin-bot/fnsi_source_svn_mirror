#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "../libs/ntss_log_lib.h"
#include "../libs/ntss_restcall_lib.h"
#include "config_reader.h"
#include <sys/syscall.h> // #8732 2023.08.08 add REST試行回数やスレッド判別情報をログ出力 TDC山崎
// #11157 2024.11.01 add REST API のリトライごとに通信異常フラグをチェックする TDC片口 start
#include "ntss_etc_lib.h" 
#include <time.h>
// #11157 2024.11.01 add REST API のリトライごとに通信異常フラグをチェックする TDC片口 end

// 設定ファイル
#define CONFIG_FILE                 "./conf/ntss_comm_fail.conf"
#define CONFIG_TAG_COUNT            100
#define TAG_SENDCALL_RETRY_COUNT    "RETRY_COUNT"
#define TAG_SENDCALL_WAIT_TIME      "WAIT_TIME"

/**
 * @brief 設定ファイルの内容を取得
 */
extern int restcall_read_config(const char *configFileName);
/**
 * @brief 最期に入る改行(\r\n)を取り除く
 */
extern void sendcall_lntrim(char *str);

/**
 * @brief RESTコール再試行回数
 */
int _restcall_retry_count = 3;

/**
 * @brief RESTコール再試行待ち時間（秒）
 */
int _restcall_wait_time = 30;

/**
* @fn void initRestCall()
* @brief RESTコール処理初期化
*/
int initRestCall(){
    return restcall_read_config(CONFIG_FILE);
}


/**
 * @fn void setRestcallRetryCount(int value)
 * @brief RESTコール再試行回数を設定する
 * @param[in] value 再試行回数
 */
void setRestcallRetryCount(int value)
{
    _restcall_retry_count = value;
}

/**
 * @fn int getRestcallRetryCount()
 * @brief RESTコール再試行回数を取得する
 * @return 再試行回数
 */
int getRestcallRetryCount()
{
    return _restcall_retry_count;
}

/**
 * @fn void setRestcallWaitTime(int value)
 * @brief RESTコール再試行待ち時間を設定する
 * @param[in] value 再試行待ち時間（秒）
 */
void setRestcallWaitTime(int value)
{
    _restcall_wait_time = value;
}

/**
 * @fn int getRestcallWaitTime()
 * @brief RESTコール再試行待ち時間を取得する
 * @return 再試行待ち時間（秒）
 */
int getRestcallWaitTime()
{
    return _restcall_wait_time;
}

/**
 * @brief 設定ファイルの内容を取得
 * 
 * @param configFileName 
 * @return int32_t 
 */
int restcall_read_config(const char *configFileName)
{   
    ConfigData_t configData[CONFIG_TAG_COUNT];
    memset( configData, 0, sizeof(configData) );

    if (readConfigDataFile(configFileName, configData, CONFIG_TAG_COUNT) < 0){
        return -1;
    }

    // 設定ファイルの値を構造体にセットする
    char *pVal;
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_SENDCALL_RETRY_COUNT);
    if ( pVal != NULL && pVal != "" ) {
        sendcall_lntrim(pVal);
        setRestcallRetryCount(atoi(pVal));
    }
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_SENDCALL_WAIT_TIME);
    if ( pVal != NULL && pVal != "" ) {
        sendcall_lntrim(pVal);
        setRestcallWaitTime(atoi(pVal));
    }
    return 0;
}

/**
 * @brief 最期に入る改行(\r\n)を取り除く
 * 
 * @param *str 
 */
void sendcall_lntrim(char *str)
{  
    char *p;

    p = strchr(str, '\r');
    if(p != NULL) {
        *p = '\0';
    }
    p = strchr(str, '\n');
    if(p != NULL) {
        *p = '\0';
    }
}


/**
 * @fn int ntss_restcall(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile) 
 * @brief RESTコールして結果を取得する
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] restStr REST実行文字列
 * @param[in] resFile レスポンスファイル名
 * @param[in] errFile エラーファイル名
 * @param[in] logPrefix ログ文字列の先頭に付与するテキスト
 * @return 0:成功, その他:エラー
 */
int ntss_restcall(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix) {
    int ret;
    int i, code;
    // #8729 2023.08.22 mod RESTコマンドをログ出力 TDC高村 start
    //unsigned char logMessage[1024] = {0};
    unsigned char logMessage[3500] = {0};
    // #8729 2023.08.22 mod RESTコマンドをログ出力 TDC高村 end
    unsigned char responseCode[256] = {0};
    pid_t tid = syscall(SYS_gettid); // #8732 2023.08.08 add REST試行回数やスレッド判別情報をログ出力 TDC山崎
    time_t start_time, now_time; // #11157 2024.11.01 add REST API のリトライごとに通信異常フラグをチェックする TDC片口

    // #8729 2023.08.22 add RESTコマンドをログ出力 TDC高村 start
    snprintf(logMessage, sizeof(logMessage), "%s REST コマンド [%s]", logPrefix, restStr);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);
    // #8729 2023.08.22 add RESTコマンドをログ出力 TDC高村 end

    for ( i=0; i<getRestcallRetryCount(); i++ ) {

        // #11367 2025.01.10 add 仮想端末用REST処理の見直し TDC高村 start
        if (!isCommEnableState())
        {
            // 通信異常
            snprintf(logMessage, sizeof(logMessage), "%s REST 実行前に通信不可状態を検知 [%d回目のREST tid=%d]", logPrefix, i + 1, tid);
            LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);
            // 使用したファイルの消し込み作業
            removeFileFullPath(resFile);
            removeFileFullPath(errFile);
            ret = 2;
            break;
        }
        // #11367 2025.01.10 add 仮想端末用REST処理の見直し TDC高村 end

        if ( i ) {
            // 再試行待ち
            start_time = time(NULL);
            now_time = time(NULL);
            while ((int)difftime(now_time, start_time) < getRestcallWaitTime())
            {
                sleep(1);
                now_time = time(NULL);
            }
        }

        // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
        ret = system(restStr);

        if ( WIFEXITED(ret) ) {
            // 子プロセスが正常に終了した場合
            // 子プロセスの終了ステータスを取得
            ret = WEXITSTATUS(ret);
        }
        if ( readFileOneLine(responseCode, 50, resFile) == 0 ) {
            if ( logPrefix == "" ) {
                // #8732 2023.08.08 chg REST試行回数やスレッド判別情報をログ出力 TDC山崎 start
                //snprintf(logMessage, sizeof(logMessage), "REST 応答あり, (%s)", responseCode);
                snprintf(logMessage, sizeof(logMessage), "REST 応答あり (%s) [%d回目のREST tid=%d]", responseCode, i + 1, tid);
                // #8732 2023.08.08 chg REST試行回数やスレッド判別情報をログ出力 TDC山崎 end
            }
            else {
                // #8732 2023.08.08 chg REST試行回数やスレッド判別情報をログ出力 TDC山崎 start
                //snprintf(logMessage, sizeof(logMessage), "%s REST 応答あり, (%s)", logPrefix, responseCode);
                snprintf(logMessage, sizeof(logMessage), "%s REST 応答あり (%s) [%d回目のREST tid=%d]", logPrefix, responseCode, i + 1, tid);
                // #8732 2023.08.08 chg REST試行回数やスレッド判別情報をログ出力 TDC山崎 end
            }
        }
        else {
            if ( logPrefix == "" ) {
                // #8732 2023.08.08 chg REST試行回数やスレッド判別情報をログ出力 TDC山崎 start
                //snprintf(logMessage, sizeof(logMessage), "REST 実行システムコール応答, (%d)", ret);
                snprintf(logMessage, sizeof(logMessage), "REST 実行システムコール応答 (%d) [%d回目のREST tid=%d]", ret, i + 1, tid);
                // #8732 2023.08.08 chg REST試行回数やスレッド判別情報をログ出力 TDC山崎 end
            }
            else {
                // #8732 2023.08.08 chg REST試行回数やスレッド判別情報をログ出力 TDC山崎 start
                //snprintf(logMessage, sizeof(logMessage), "%s REST 実行システムコール応答, (%d)", logPrefix, ret);
                snprintf(logMessage, sizeof(logMessage), "%s REST 実行システムコール応答 (%d) [%d回目のREST tid=%d]", logPrefix, ret, i + 1, tid);
                // #8732 2023.08.08 chg REST試行回数やスレッド判別情報をログ出力 TDC山崎 end
            }
        }
        LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

        // 終了コード作成
        code = atoi(responseCode);
        if ( 0 < ret ) {
            // 成功系
            if ( code >= 200 && code <= 226 ) {
                // 正常
                ret = 0;
            }
            else if ( code == 500 ) {
                // サーバーエラー
                ret = 1;
            }
            else {
                // その他エラー
                ret = 2;
            }           
        }
        else {
            // システムコールエラー
            ret = -1;
        }

        if ( ret < 0 && readFileOneLine(responseCode, 255, errFile) == 0 ) {
            if ( logPrefix == "" ) {
                // #8732 2023.08.08 chg REST試行回数やスレッド判別情報をログ出力 TDC山崎 start
                //snprintf(logMessage, sizeof(logMessage), "REST 失敗応答を取得, (%s)", responseCode);
                snprintf(logMessage, sizeof(logMessage), "REST 失敗応答を取得 (%s) [%d回目のREST tid=%d]", responseCode, i + 1, tid);
                // #8732 2023.08.08 chg REST試行回数やスレッド判別情報をログ出力 TDC山崎 end
            }
            else {
                // #8732 2023.08.08 chg REST試行回数やスレッド判別情報をログ出力 TDC山崎 start
                //snprintf(logMessage, sizeof(logMessage), "%s REST 失敗応答を取得, (%s)", logPrefix, responseCode);
                snprintf(logMessage, sizeof(logMessage), "%s REST 失敗応答を取得 (%s) [%d回目のREST tid=%d]", logPrefix, responseCode, i + 1, tid);
                // #8732 2023.08.08 chg REST試行回数やスレッド判別情報をログ出力 TDC山崎 end
            }
            LogOutputs(NTSS_LOG_ERROR, logMessage, 0, devCd, devId);
        }

        // 使用したファイルの消し込み作業
        removeFileFullPath(resFile);
        removeFileFullPath(errFile);

        if ( ret == 0 ) {
            // 成功
            break;
        }
    }

    return ret;
}

// #11367 2025.01.10 add 仮想端末用REST処理の見直し TDC高村 start
/**
 * @fn int ntss_restcall_ex(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix, int retryCnt, int waitTime)
 * @brief RESTコールして結果を取得する
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] restStr REST実行文字列
 * @param[in] resFile レスポンスファイル名
 * @param[in] errFile エラーファイル名
 * @param[in] logPrefix ログ文字列の先頭に付与するテキスト
 * @param[in] retryCnt 再試行回数
 * @param[in] waitTime 再試行待ち時間
 * @return 0:成功, その他:エラー
 */
int ntss_restcall_ex(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix, int retryCnt, int waitTime)
{
    // #12003 2025.07.25 add 通信不可フラグを参照しないREST API呼び出しを可能とする TDC片口 start
    return ntss_restcall_force_ex(devCd, devId, restStr, resFile, errFile, logPrefix, retryCnt, waitTime, true);
}

/**
 * @fn int ntss_restcall_force_ex(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix, int retryCnt, int waitTime)
 * @brief RESTコールして結果を取得する
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] restStr REST実行文字列
 * @param[in] resFile レスポンスファイル名
 * @param[in] errFile エラーファイル名
 * @param[in] logPrefix ログ文字列の先頭に付与するテキスト
 * @param[in] retryCnt 再試行回数
 * @param[in] waitTime 再試行待ち時間
 * @param[in] waitTime 再試行待ち時間
 * @param[in] isCheckCommEnable true: 通信不可フラグの影響を受ける, false: 常にREST呼び出しを試みる
 * @return 0:成功, その他:エラー
 */
int ntss_restcall_force_ex(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix, int retryCnt, int waitTime, bool isCheckCommEnable)
{
// #12003 2025.07.25 add 通信不可フラグを参照しないREST API呼び出しを可能とする TDC片口 end
    int ret;
    int i, code;
    unsigned char logMessage[3500] = {0};
    unsigned char responseCode[256] = {0};
    pid_t tid = syscall(SYS_gettid);
    time_t start_time, now_time;

    snprintf(logMessage, sizeof(logMessage), "%s REST コマンド [%s]", logPrefix, restStr);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    for ( i=0; i<retryCnt; i++ ) {

        // #11367 2025.01.10 add 仮想端末用REST処理の見直し TDC高村 start
        // #12003 2025.07.25 mod 通信不可フラグを参照しないREST API呼び出しを可能とする TDC片口 start
        // if (!isCommEnableState())
        if (isCheckCommEnable && !isCommEnableState())
        // #12003 2025.07.25 mod 通信不可フラグを参照しないREST API呼び出しを可能とする TDC片口 end
        {
            // 通信異常
            snprintf(logMessage, sizeof(logMessage), "%s REST 実行前に通信不可状態を検知 [%d回目のREST tid=%d]", logPrefix, i + 1, tid);
            LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);
            // 使用したファイルの消し込み作業
            removeFileFullPath(resFile);
            removeFileFullPath(errFile);
            ret = 2;
            break;
        }
        // #11367 2025.01.10 add 仮想端末用REST処理の見直し TDC高村 end

        if ( i ) {
            // 再試行待ち
            start_time = time(NULL);
            now_time = time(NULL);
            while ((int)difftime(now_time, start_time) < waitTime)
           {
                sleep(1);
                now_time = time(NULL);
            }
        }

        // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
        ret = system(restStr);

        if ( WIFEXITED(ret) ) {
            // 子プロセスが正常に終了した場合
            // 子プロセスの終了ステータスを取得
            ret = WEXITSTATUS(ret);
        }
        if ( readFileOneLine(responseCode, 50, resFile) == 0 ) {
            if ( logPrefix == "" ) {
                snprintf(logMessage, sizeof(logMessage), "REST 応答あり (%s) [%d回目のREST tid=%d]", responseCode, i + 1, tid);
            }
            else {
                snprintf(logMessage, sizeof(logMessage), "%s REST 応答あり (%s) [%d回目のREST tid=%d]", logPrefix, responseCode, i + 1, tid);
            }
        }
        else {
            if ( logPrefix == "" ) {
                snprintf(logMessage, sizeof(logMessage), "REST 実行システムコール応答 (%d) [%d回目のREST tid=%d]", ret, i + 1, tid);
            }
            else {
                snprintf(logMessage, sizeof(logMessage), "%s REST 実行システムコール応答 (%d) [%d回目のREST tid=%d]", logPrefix, ret, i + 1, tid);
            }
        }
        LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

        // 終了コード作成
        code = atoi(responseCode);
        if ( 0 < ret ) {
            // 成功系
            if ( code >= 200 && code <= 226 ) {
                // 正常
                ret = 0;
            }
            else if ( code == 500 ) {
                // サーバーエラー
                ret = 1;
            }
            else {
                // その他エラー
                ret = 2;
            }           
        }
        else {
            // システムコールエラー
            ret = -1;
        }

        if ( ret < 0 && readFileOneLine(responseCode, 255, errFile) == 0 ) {
            if ( logPrefix == "" ) {
                snprintf(logMessage, sizeof(logMessage), "REST 失敗応答を取得 (%s) [%d回目のREST tid=%d]", responseCode, i + 1, tid);
            }
            else {
                snprintf(logMessage, sizeof(logMessage), "%s REST 失敗応答を取得 (%s) [%d回目のREST tid=%d]", logPrefix, responseCode, i + 1, tid);
            }
            LogOutputs(NTSS_LOG_ERROR, logMessage, 0, devCd, devId);
        }

        // 使用したファイルの消し込み作業
        removeFileFullPath(resFile);
        removeFileFullPath(errFile);

        if ( ret == 0 ) {
            // 成功
            break;
        }
    }

    return ret;
}
// #11367 2025.01.10 add 仮想端末用REST処理の見直し TDC高村 end
