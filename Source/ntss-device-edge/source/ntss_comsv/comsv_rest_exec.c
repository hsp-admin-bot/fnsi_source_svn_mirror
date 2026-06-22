/**
* @file comsv_rest_exec.c
* @brief REST実行処理
* @author Y.Takamura
* @date 2018/09/15
* @details 通信サーバから各種RESTを実行する
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
//#include "ntss_file.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
#include "ntss_comsv.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 start
#include "../common/libs/ntss_restcall_lib.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 end

/**
 * @fn int comsv_rest_exec(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix)
 * @brief RESTを実行して結果を取得する
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] restStr REST実行文字列
 * @param[in] resFile レスポンスファイル名
 * @param[in] errFile エラーファイル名
 * @param[in] logPrefix ログ文字列の先頭に付与するテキスト
 * @return 0:成功, その他:エラー
 */
int comsv_rest_exec(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix) {
    int ret;
    // #8729 2023.08.22 add REST応答によるNGフォルダ出力（RESTコマンド）TDC高村 start
    char *path;
    char fname[200];
    char outPath[255];
    unsigned char cbuff[NTSS_STR_MAX_SIZE] = {0};
    unsigned char logMessage[512] = {0};
    unsigned char cType[5]; 
    unsigned char cSerial[10]; 
    struct tm *local;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //struct timeval myTime;
    struct timespec myTime;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

    memset(cType, 0, sizeof(cType));
    memset(cSerial, 0, sizeof(cSerial));
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
    //if ( devCd != "" ) {
    //    memcpy(cType, devCd, 3);
    //    str_trim(cType);
    //}
    //if ( devId != "" ) {
    //    memcpy(cSerial, devId, 8);
    //    str_trim(cSerial);
    //}
    if ( !((devCd == NULL) || (devCd[0] == '\0')) ) {
        memcpy(cType, devCd, 3);
        str_trim(cType);
    }
    if ( !((devId == NULL) || (devId[0] == '\0')) ) {
        memcpy(cSerial, devId, 8);
        str_trim(cSerial);
    }
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
    // #8729 2023.08.22 add REST応答によるNGフォルダ出力（RESTコマンド）TDC高村 end
    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 start
    /*
    unsigned char logMessage[1024] = {0};
	unsigned char responseCode[256] = {0};

    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    ret = system(restStr);

    if ( WIFEXITED(ret) ) {
        // 子プロセスが正常に終了した場合
        // 子プロセスの終了ステータスを取得
        ret = WEXITSTATUS(ret);
    }
    if ( readFileOneLine(responseCode, 50, resFile) == 0 ) {
        snprintf(logMessage, sizeof(logMessage), "%s REST 応答あり, (%s)", logPrefix, responseCode);
    }
    else {
        snprintf(logMessage, sizeof(logMessage), "%s REST 実行システムコール応答, (%d)", logPrefix, ret);
    }
    LogOutputs(NTSS_LOG_INFO, logMessage, 1, devCd, devId);

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
        snprintf(logMessage, sizeof(logMessage), "%s REST 失敗応答を取得, (%s)", logPrefix, responseCode);
        //LogResourceOutput(NTSS_LOG_ERROR, logMessage);
    	LogOutputs(NTSS_LOG_ERROR, logMessage, 1, devCd, devId);
    }

    // 使用したファイルの消し込み作業
    removeFileFullPath(resFile);
    removeFileFullPath(errFile);
    */
    // #11367 2025.01.10 del サーバー疎通確認を毎回行うのはリソースを食うのでやめる TDC片口 start
    // // #11157 2024.11.01 add サーバー疎通確認 TDC片口 start
    // ret = comsv_rest_connection_watch(devCd, devId);
    // if (ret != 0)
    // {
    //     // サーバー疎通確認失敗
    //     return ret;
    // }
    // // #11157 2024.11.01 add サーバー疎通確認 TDC片口 end
    // #11367 2025.01.10 del サーバー疎通確認を毎回行うのはリソースを食うのでやめる TDC片口 end

    // RESTコールして結果を取得する
    ret = ntss_restcall(devCd, devId, restStr, resFile, errFile, logPrefix);
    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 end

    // #8729 2023.08.22 mod REST応答によるNGフォルダ出力（RESTコマンド）TDC高村 start
    // 応答判定 
    if ( ret == 1 )
    {
        // 500応答の場合
        // 出力先ファイル名作成
        // ※[受信年月日時分秒マイクロ秒]_[型式コード]_[製造番号]_REST.txt
        // 現在時刻を取得
        // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
        //gettimeofday(&myTime, NULL);
        //local = localtime(&myTime.tv_sec);
        //
        //sprintf(
        //      fname
        //    , "%04d%02d%02d%02d%02d%02d%06ld_%s_%s_REST.txt"
        //    , local->tm_year + 1900
        //    , local->tm_mon + 1
        //    , local->tm_mday
        //    , local->tm_hour
        //    , local->tm_min
        //    , local->tm_sec
        //    , myTime.tv_usec
        //    , cType
        //    , cSerial
        //);
        clock_gettime(CLOCK_REALTIME, &myTime);
	    local = localtime(&myTime.tv_sec);
        sprintf(
              fname
            , "%04d%02d%02d%02d%02d%02d%06ld_%s_%s_REST.txt"
            , local->tm_year + 1900
            , local->tm_mon + 1
            , local->tm_mday
            , local->tm_hour
            , local->tm_min
            , local->tm_sec
            , myTime.tv_nsec / 1000
            , cType
            , cSerial
        );
        sprintf(outPath, "./NG/%s",fname);
        // NGフォルダ有無判定
        strcpy(cbuff, outPath);
        path = dirname(cbuff);
        if (existFolderFile(path, NULL) != 1) {
            // ない場合はフォルダ作成
            createFolder(path);
        }
        // REST発行内容をNGフォルダへ出力
        if( outputFile(
            outPath                 // 作成するファイル名
            , restStr               // 記録するデータ
            , strlen( restStr)      // 記録するデータ長
            ) == 1 ) {
            // ファイル作成成功
            snprintf(logMessage, NTSS_STR_MAX_SIZE, "500応答のためRESTコール内容をNGフォルダへ出力 [%s]", outPath);
            LogOutputs( NTSS_LOG_INFO, logMessage, 0, devCd, devId );
        }
        else {
            // ファイル作成失敗
            snprintf(logMessage, NTSS_STR_MAX_SIZE, "RESTコール内容 ファイル作成失敗(%s)", outPath );
            LogOutputs( NTSS_LOG_ERROR, logMessage, 0, devCd, devId );
        }
    }
    // #8729 2023.08.22 mod REST応答によるNGフォルダ出力（RESTコマンド）TDC高村 end
     
    return ret;
}

// #11157 2024.11.01 add サーバー疎通確認用API TDC片口 start
/**
 * @fn int comsv_rest_get_connection_watch(unsigned char *devCd, unsigned char *devId)
 * @brief ネットワーク死活監視処理
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @return 0:成功, -1:エラー, -2:取得失敗
 */
int comsv_rest_connection_watch(unsigned char *devCd, unsigned char *devId)
{
    int ret, fd;
    char url[200];
    char resFile[50];
    char errFile[50];
    unsigned char cbuff[512] = {0};
    unsigned char logMessage[512] = {0};
    unsigned char cType[5] = {0};
    unsigned char cSerial[10] = {0};
    if (devCd != "")
    {
        memcpy(cType, devCd, 3);
        str_trim(cType);
    }
    if (devId != "")
    {
        memcpy(cSerial, devId, 8);
        str_trim(cSerial);
    }

    snprintf(url, sizeof(url), "%s/connection_watch/%s/%d", rest_device_edge_url, configParam.facilityCd, configParam.deviceEdgeNo);
    snprintf(resFile, sizeof(resFile), "/tmp/cw_%s_%s_%s", cType, cSerial, WORK_RES_CODE);
    fd = mkstemp(resFile);
    if (fd != 0)
    {
        close(fd);
    }
    snprintf(errFile, sizeof(errFile), "/tmp/cw_%s_%s_%s", cType, cSerial, WORK_ERR_CODE);
    fd = mkstemp(errFile);
    if (fd != 0)
    {
        close(fd);
    }

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "死活監視処理");
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, devCd, devId);

    // REST用文字列作成
    snprintf(
        cbuff, sizeof(cbuff), "./sh/comsv_rest_connection_watch.sh \"%s\" \"%s\" \"%s\"", url, resFile, errFile);

    // RESTをコールする
    ret = comsv_rest_exec_simple(devCd, devId, cbuff, resFile, errFile, "死活監視処理");

    // #11367 2025.01.10 del REST API応答をそのまま返すだけにする TDC片口 start
    // if (ret != 0)
    // {
    //     // 取得失敗
    //     setCommAliveState(1);
    // }
    // #11367 2025.01.10 del REST API応答をそのまま返すだけにする TDC片口 end

    return ret;
}

/**
 * @fn int comsv_rest_exec_simple(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile)
 * @brief RESTを1回だけ実行して結果を取得する(リトライやNG時保存などなし)
 * @param[in] devCd 型式コード
 * @param[in] devId 製造番号
 * @param[in] restStr REST実行文字列
 * @param[in] resFile レスポンスファイル名
 * @param[in] errFile エラーファイル名
 * @param[in] logPrefix ログ文字列の先頭に付与するテキスト
 * @return 0:成功, その他:エラー
 */
int comsv_rest_exec_simple(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix)
{
    int ret, code;
    unsigned char logMessage[1024] = {0};
    unsigned char responseCode[256] = {0};

    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    ret = system(restStr);

    if (WIFEXITED(ret))
    {
        // 子プロセスが正常に終了した場合
        // 子プロセスの終了ステータスを取得
        ret = WEXITSTATUS(ret);
    }
    if (readFileOneLine(responseCode, 50, resFile) == 0)
    {
        snprintf(logMessage, sizeof(logMessage), "%s REST 応答あり, (%s)", logPrefix, responseCode);
    }
    else
    {
        snprintf(logMessage, sizeof(logMessage), "%s REST 実行システムコール応答, (%d)", logPrefix, ret);
    }
    LogOutputs(NTSS_LOG_INFO, logMessage, 1, devCd, devId);

    // 終了コード作成
    code = atoi(responseCode);
    if (0 < ret)
    {
        // 成功系
        if ( code >= 200 && code <= 226 )
        {
            // 正常
            ret = 0;
        }
        else if ( code == 500 )
        {
            // サーバーエラー
            ret = -1;
        }
        else
        {
            // その他エラー
            ret = -2;
        }     
    }
    else
    {
        // 取得失敗エラー
        ret = -3;
    }

    if (ret < 0 && readFileOneLine(responseCode, 255, errFile) == 0)
    {
        snprintf(logMessage, sizeof(logMessage), "%s REST 失敗応答を取得(%d), (%s)", logPrefix, ret, responseCode);
        // LogResourceOutput(NTSS_LOG_ERROR, logMessage);
        LogOutputs(NTSS_LOG_ERROR, logMessage, 1, devCd, devId);
    }

    // 使用したファイルの消し込み作業
    removeFileFullPath(resFile);
    removeFileFullPath(errFile);

    return ret;
}
// #11157 2024.11.01 add サーバー疎通確認用API TDC片口 end

// #11367 2025.01.10 add 仮想端末用REST処理の見直し TDC高村 start
/**
 * @fn int comsv_rest_exec_ex(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix, int retryCnt, int waitTime)
 * @brief RESTを実行して結果を取得する
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
int comsv_rest_exec_ex(unsigned char *devCd, unsigned char *devId, unsigned char *restStr, char *resFile, char *errFile, char *logPrefix, int retryCnt, int waitTime) {
    int ret;
    char *path;
    char fname[200];
    char outPath[255];
    u_char cbuff[NTSS_STR_MAX_SIZE] = {0};
    u_char logMessage[512] = {0};
    unsigned char cType[5]; 
    unsigned char cSerial[10]; 
    struct tm *local;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //struct timeval myTime;
    struct timespec myTime;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

    memset(cType, 0, sizeof(cType));
    memset(cSerial, 0, sizeof(cSerial));
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
    //if ( devCd != "" ) {
    //    memcpy(cType, devCd, 3);
    //    str_trim(cType);
    //}
    //if ( devId != "" ) {
    //    memcpy(cSerial, devId, 8);
    //    str_trim(cSerial);
    //}
    if ( !((devCd == NULL) || (devCd[0] == '\0')) ) {
        memcpy(cType, devCd, 3);
        str_trim(cType);
    }
    if ( !((devId == NULL) || (devId[0] == '\0')) ) {
        memcpy(cSerial, devId, 8);
        str_trim(cSerial);
    }
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end

    // RESTコールして結果を取得する
    ret = ntss_restcall_ex(devCd, devId, restStr, resFile, errFile, logPrefix, retryCnt, waitTime);
    // 応答判定 
    if ( ret == 1 )
    {
        // 500応答の場合
        // 出力先ファイル名作成
        // ※[受信年月日時分秒マイクロ秒]_[型式コード]_[製造番号]_REST.txt
        // 現在時刻を取得
        // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
        //gettimeofday(&myTime, NULL);
        //local = localtime(&myTime.tv_sec);
        //
        //sprintf(
        //      fname
        //    , "%04d%02d%02d%02d%02d%02d%06ld_%s_%s_REST.txt"
        //    , local->tm_year + 1900
        //    , local->tm_mon + 1
        //    , local->tm_mday
        //    , local->tm_hour
        //    , local->tm_min
        //    , local->tm_sec
        //    , myTime.tv_usec
        //    , cType
        //    , cSerial
        //);
        clock_gettime(CLOCK_REALTIME, &myTime);
	    local = localtime(&myTime.tv_sec);
        sprintf(
              fname
            , "%04d%02d%02d%02d%02d%02d%06ld_%s_%s_REST.txt"
            , local->tm_year + 1900
            , local->tm_mon + 1
            , local->tm_mday
            , local->tm_hour
            , local->tm_min
            , local->tm_sec
            , myTime.tv_nsec / 1000
            , cType
            , cSerial
        );
        // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
        sprintf(outPath, "./NG/%s",fname);
        // NGフォルダ有無判定
        strcpy(cbuff, outPath);
        path = dirname(cbuff);
        if (existFolderFile(path, NULL) != 1) {
            // ない場合はフォルダ作成
            createFolder(path);
        }
        // REST発行内容をNGフォルダへ出力
        if( outputFile(
            outPath                 // 作成するファイル名
            , restStr               // 記録するデータ
            , strlen( restStr)      // 記録するデータ長
            ) == 1 ) {
            // ファイル作成成功
            snprintf(logMessage, NTSS_STR_MAX_SIZE, "500応答のためRESTコール内容をNGフォルダへ出力 [%s]", outPath);
            LogOutputs( NTSS_LOG_INFO, logMessage, 0, devCd, devId );
        }
        else {
            // ファイル作成失敗
            snprintf(logMessage, NTSS_STR_MAX_SIZE, "RESTコール内容 ファイル作成失敗(%s)", outPath );
            LogOutputs( NTSS_LOG_ERROR, logMessage, 0, devCd, devId );
        }
    }
     
    return ret;
}
// #11367 2025.01.10 add 仮想端末用REST処理の見直し TDC高村 end

