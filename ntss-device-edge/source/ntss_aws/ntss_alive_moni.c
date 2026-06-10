/**
* @file ntss_alive_moni.c
* @brief 死活監視関連処理
* @author Y.Kataguchi
* @date 2017/12/22
* @details 死活監視の通信ペイロードの判定や作成など
*/

#include "ntss_alive_moni.h"

/**
 * @brief ペイロードから通知内容を取得
 * 
 * @param aliveMoni 
 * @param receivePayload 
 * @param payloadLen 
 * @return uint16_t 
 */
extern uint16_t
setAliveMoni(AliveMoni_t *aliveMoni, const u_char *receivePayload, uint16_t payloadLen)
{

    uint16_t oneDataLen = 3 + 1 + 8;
    uint16_t i = 0, idx = 0, diff = 0;

    for (i = 0; i < 100; i++)
    {
        idx = oneDataLen * i;
        if (idx >= payloadLen || receivePayload[idx] == 0x00)
        {
            break;
        }

        diff = 0;
        memcpy(aliveMoni->targetDevice[i].machineTypeCd, receivePayload + (idx + diff), 3);
        diff += 3;
        memcpy(&(aliveMoni->targetDevice[i].machineFormatCd), receivePayload + (idx + diff), 1);
        diff += 1;
        memcpy(aliveMoni->targetDevice[i].machineSerial, receivePayload + (idx + diff), 8);
    }

    return i;
}

/**
 * @brief 命令のレスポンス電文を作成
 * 
 * @param sendData 
 * @param configParam 
 * @return int32_t 
 */
int32_t buildAliveMoniRes(u_char *sendData, bool isConnect)
{

    ConfigParameter_t config = getConfigParameter();

    if (isConnect)
    {
        sprintf(sendData, "%s_%d_%s", config.facilityCode, config.deviceNo, "01");
    }
    else
    {
        sprintf(sendData, "%s_%d_%s", config.facilityCode, config.deviceNo, "F0");
    }

    return strlen(sendData);
}

/**
 * @brief 死活結果を送信するペイロードの作成
 * 
 * @param sendData 
 * @param noticeParams 
 * @param deviceNo 
 * @return int32_t 
 */
int32_t buildAliveMoniResult(u_char *sendData, char *file)
{
    // #11633 2025.06.18 add DE再起動時治療中装置のステータスが戻らないことがある TDC高村 start
    uint16_t i;
    uint16_t allDataLen;
    uint16_t oneDataLen = 14;
    u_char *findData;
    u_char oneData[20];
    // #11633 2025.06.18 add DE再起動時治療中装置のステータスが戻らないことがある TDC高村 end
    u_char resultData[20480] = {0};
    ConfigParameter_t config = getConfigParameter();

    readFileOneLine(resultData, 20480, file);

    // #11633 2025.06.18 add DE再起動時治療中装置のステータスが戻らないことがある TDC高村 start
    allDataLen = strlen(resultData);
    // #12714 2026.05.18 mod 多くの装置が通信不良から復帰した時にステータスが戻らない装置がある TDC片口 start
    // for ( i=0; i<allDataLen; i+=oneDataLen ) {
    i = 0;
    while (i < allDataLen)
    {
    // #12714 2026.05.18 mod 多くの装置が通信不良から復帰した時にステータスが戻らない装置がある TDC片口 end
        memset(oneData, 0, sizeof(oneData));
        memcpy(oneData, resultData + i, oneDataLen-3);
        if ( strlen(oneData) != (oneDataLen -3) ) break;
        findData = strstr(resultData + i + oneDataLen, oneData);
        if (findData != NULL) {
            // 存在する
            memmove(resultData + i, resultData + i + oneDataLen, allDataLen - (i + oneDataLen));
            memset(resultData + (allDataLen - oneDataLen), 0, oneDataLen);
            allDataLen -= oneDataLen;
        }
        // #12714 2026.05.18 add 多くの装置が通信不良から復帰した時にステータスが戻らない装置がある TDC片口 start
        else
        {
            // 存在しない場合は次のデータに移動
            i += oneDataLen;
        }
        // #12714 2026.05.18 add 多くの装置が通信不良から復帰した時にステータスが戻らない装置がある TDC片口 end
    }
    // #11633 2025.06.18 add DE再起動時治療中装置のステータスが戻らないことがある TDC高村 end

    sprintf(sendData, "%s_%d_%s_%s", config.facilityCode, config.deviceNo, "01", resultData);

    return strlen(sendData);
}

/**
 * @brief 結果ファイルの削除
 * 
 * @return true 
 * @return false 
 */
bool deleteAliveMoniResultFile()
{
    return removeFileFullPath(ALIVE_MONI_FILE);
}

/**
 * @brief デバイスエッジ死活送信
 * 
 * @param rest 
 * @param isConnect 
 * @return true 
 * @return false 
 */
bool noticeAliveMoni(u_char *rest, bool isConnect)
{

    u_char cPayload[20480] = {0};
    uint32_t payLoadLen;
    int32_t ret;
    u_char cbuff[NTSS_STR_MAX_SIZE] = {0};
    u_char logMessage[MAX_LOG_TEXT] = {0};
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // char *tmpFile = "./AliveMoniTemp.dat";
    // char *sendBodyFile = "./AliveMoniBody.txt";
    // char *responseFile = "./AliveMoniResponse.txt";
    // char *errFile = "./AliveMoniErrResponse.txt";
    char *tmpFile = "/tmp/AliveMoniTemp.dat";
    char *sendBodyFile = "/tmp/AliveMoniBody.txt";
    char *responseFile = "/tmp/AliveMoniResponse.txt";
    char *errFile = "/tmp/AliveMoniErrResponse.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 start
    //u_char responseCode[255] = {0};
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 end
    // add AWSとDEの通信断からの復旧 高 start
    int i = 0;
    int ret_fail;
    // add AWSとDEの通信断からの復旧 高 end

    // データあり

    // データを送信する形式に変換
    payLoadLen = buildAliveMoniRes(cPayload, isConnect);

    // 一時ファイル作成
    outputFile(tmpFile, cPayload, payLoadLen);

    // ペイロードの内容をログ出力
    snprintf(logMessage, MAX_LOG_TEXT, "デバイスエッジ死活送信, (%s)", cPayload);
    LogOutput(NTSS_LOG_INFO, logMessage);

    // REST送信用BODY作成
    sprintf(
        cbuff, "./sh/make_json_b64param.sh \"%s\" \"%s\" \"%s\" %d", "content" // key
        ,
        tmpFile // value
        ,
        sendBodyFile // output_file
        ,
        1 // 新規作成
    );
    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    ret = system(cbuff);

    // RESTをコールする
    sprintf(
        cbuff, "./sh/post_b64.sh \"%s\" \"%s\" \"%s\" \"%s\"", rest, sendBodyFile, responseFile, errFile);
    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 start
    /*
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
        snprintf(logMessage, MAX_LOG_TEXT, "REST 応答あり, (%s)", responseCode);
    }
    else
    {
        snprintf(logMessage, MAX_LOG_TEXT, "REST 実行システムコール応答, (%d)", ret);
    }
    LogOutput(NTSS_LOG_INFO, logMessage);

    // 終了コード作成
    if (0 < ret)
    {
        // 成功
        if (200 == ret)
        {
            ret = 0;
        }
        else
        {
            // 200以外は失敗
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
        snprintf(logMessage, MAX_LOG_TEXT, "REST 失敗応答を取得, (%s)", responseCode);
        LogResourceOutput(NTSS_LOG_ERROR, logMessage);
    }
    */
    // RESTコールして結果を取得する
    ret = ntss_restcall("", "", cbuff, responseFile, errFile, "デバイスエッジ死活送信");

    // ファイルの消し込み作業
    removeFileFullPath(tmpFile);
    removeFileFullPath(sendBodyFile);
    //removeFileFullPath(responseFile);
    //removeFileFullPath(errFile);
    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 end

    // #8081 del 2023.05.09 通信状態を通信SVへ通知しないようにする TDC米沢 start
    // // add AWSとDEの通信断からの復旧 高 start
    // if ( getCommAliveState() != 0  && ret == 0 )
    // {
    //     // AWSとDEの通信OK
    //     kill(getChildCaptureAppPid(), SIG_COMM_FAIL_NORMAL);
    //     setCommAliveState(0);
    // }
    // else if(getCommAliveState() == 0 && ret != 0) {
    //     // AWSとDEの通信NG
    //     for ( i = 0; i < 2; i++ ) {
    //         // RESTをコールする
    //         ret_fail = comsv_fail_alive_moni_main();
    //         if(ret_fail != 0)
    //             continue;
    //     }
    //     if (ret_fail != 0) {
    //         // 取得失敗
    //         if (i == 2)
    //         {
    //             setCommAliveState(1);
    //             kill(getChildCaptureAppPid(), SIG_COMM_FAIL);
    //         }
    //     }
    // }
    // // add AWSとDEの通信断からの復旧 高 end
    // #8081 del 2023.05.09 通信状態を通信SVへ通知しないようにする TDC米沢 end
    if (ret == 0)
    {
        return true;
    }
    return false;
}

/**
 * @brief 工程送信
 * 
 * @param rest 
 * @param param 
 */
void runAliveMoniNotice(u_char *rest)
{

    u_char cPayload[20480] = {0};
    uint32_t payLoadLen;
    u_char cbuff[NTSS_STR_MAX_SIZE] = {0};
    u_char logMessage[MAX_LOG_TEXT] = {0};
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // char *outPath = ".";
    char *outPath = "/tmp";
    char outFile[100];
    ConfigParameter_t config = getConfigParameter();
    // char *sendBodyFile = "./AliveMoniBody2.txt";
    // char *responseFile = "./AliveMoniResponse2.txt";
    // char *errFile = "./AliveMoniErrResponse2.txt";
    char *sendBodyFile = "/tmp/AliveMoniBody2.txt";
    char *responseFile = "/tmp/AliveMoniResponse2.txt";
    char *errFile = "/tmp/AliveMoniErrResponse2.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 start
    //u_char responseCode[255] = {0};
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 end
    // add AWSとDEの通信断からの復旧 高 start
    int i = 0;
    int ret_fail;
    // add AWSとDEの通信断からの復旧 高 end

    sprintf(outFile, "%s/%s", outPath, NOTICE_OUTPUT);

    char *pathes[3] = {
        config.receiveDataDirectory,
        config.receiveDataDirectory2,
        config.receiveDataDirectory3};

    int ret = ntss_mst_make_notice(pathes, outPath);
    if (ret > 0)
    {
        // データあり
        if (getIsDisabledCallApi())
        {
            // クラウド通信不可フラグがONの場合、工程通知ファイルを削除する
            snprintf(logMessage, MAX_LOG_TEXT, "工程送信処理 REST API 通信不可状態のため処理スキップ");
            LogResourceOutput(NTSS_LOG_INFO, logMessage);
            // 削除
            removeFile(outPath, NOTICE_OUTPUT);
        }
        else
        {

            // データを送信する形式に変換
            payLoadLen = buildAliveMoniResult(cPayload, outFile);

            // 一時ファイル作成
            outputFile(ALIVE_MONI_FILE, cPayload, payLoadLen);

            // ペイロードの内容をログ出力
            snprintf(logMessage, MAX_LOG_TEXT, "工程送信, (%s)", cPayload);
            LogOutput(NTSS_LOG_INFO, logMessage);

            // REST送信用BODY作成
            sprintf(
                cbuff, "./sh/make_json_b64param.sh \"%s\" \"%s\" \"%s\" %d", "content" // key
                ,
                ALIVE_MONI_FILE // value
                ,
                sendBodyFile // output_file
                ,
                1 // 新規作成
            );
            // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
            ret = system(cbuff);

            // RESTをコールする
            sprintf(
                cbuff, "./sh/post_b64.sh \"%s\" \"%s\" \"%s\" \"%s\"", rest, sendBodyFile, responseFile, errFile);
            // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 start
            /*
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
                snprintf(logMessage, MAX_LOG_TEXT, "工程送信処理 REST 応答あり, (%s)", responseCode);
            }
            else
            {
                snprintf(logMessage, MAX_LOG_TEXT, "工程送信処理 REST 実行システムコール応答, (%d)", ret);
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
                snprintf(logMessage, MAX_LOG_TEXT, "工程送信処理 REST 失敗応答を取得, (%s)", responseCode);
                LogResourceOutput(NTSS_LOG_ERROR, logMessage);
            }
            */
            // RESTコールして結果を取得する
            ret = ntss_restcall("", "", cbuff, responseFile, errFile, "工程送信");

            // 使用したファイルの消し込み作業
            removeFile(outPath, NOTICE_OUTPUT);
            removeFileFullPath(ALIVE_MONI_FILE);
            removeFileFullPath(sendBodyFile);
            //removeFileFullPath(responseFile);
            //removeFileFullPath(errFile);
            // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 end
            
            // #8081 del 2023.05.09 通信状態を通信SVへ通知しないようにする TDC米沢 start
            // // add AWSとDEの通信断からの復旧 高 start
            // if ( getCommAliveState() != 0  && ret == 0 )
            // {
            //     // AWSとDEの通信OK
            //     kill(getChildCaptureAppPid(), SIG_COMM_FAIL_NORMAL);
            //     setCommAliveState(0);
            // }
            // else if(getCommAliveState() == 0 && ret != 0) {
            //     // AWSとDEの通信NG
            //     for ( i = 0; i < 2; i++ ) {
            //         // RESTをコールする
            //         ret_fail = comsv_fail_alive_moni_main();
            //         if(ret_fail != 0)
            //             continue;
            //     }
            //     if (ret_fail != 0) {
            //         // 取得失敗
            //         if (i == 2)
            //         {
            //             setCommAliveState(1);
            //             kill(getChildCaptureAppPid(), SIG_COMM_FAIL);
            //         }
            //     }
            // }
            // // add AWSとDEの通信断からの復旧 高 end
            // #8081 del 2023.05.09 通信状態を通信SVへ通知しないようにする TDC米沢 end

            if (ret == 0)
            {
                // 送信成功
            }
            else
            {
                // NOTE:クラウド通信不可フラグをON
                setIsDisabledCallApi(true);
            }
        }
    }
}
