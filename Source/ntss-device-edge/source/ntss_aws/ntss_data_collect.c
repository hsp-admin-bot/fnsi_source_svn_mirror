
#include <string.h>
#include <stdint.h>
#include <stdlib.h>
#include <sys/types.h>
#include "ntss_data_collect.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
//#include "ntss_file.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
#include "../common/libs/ntss_etc_lib.h"

//! trueならばデータ収集プロセスの起動必要あり
bool _is_must_exec_datacollect = false;

bool isMustExecDataCollect()
{
    return _is_must_exec_datacollect;
}
void setIsMustExecDataCollect(bool value)
{
    _is_must_exec_datacollect = value;
}

/**
 * @brief データ収集通知情報を取得
 * 
 * @param noticeParams 
 * @param receivePayload 
 * @param payloadLen 
 * @return uint16_t 
 */
uint16_t
setCollectNotice(RcvCollectNotice_t *noticeParams, const u_char *receivePayload, uint16_t payloadLen)
{
    uint16_t oneDataLen = 3 + 1 + 8;
    uint16_t i = 0, idx = 0, startPoint = 0, diff = 0;
    u_char strManageNo[payloadLen];
    memset(strManageNo, 0, payloadLen);
    strncpy(strManageNo, receivePayload, payloadLen);

    for (i = 0; i < payloadLen; i++)
    {
        if (receivePayload[i] == '_')
        {
            strManageNo[i] = 0x00;
            break;
        }
    }
    startPoint = i + 1;

    strcpy(noticeParams->manageNo, strManageNo);

    for (i = 0; i < 100; i++)
    {
        idx = oneDataLen * i + startPoint;
        if (idx >= payloadLen || receivePayload[idx] == 0x00)
        {
            break;
        }

        diff = 0;
        memcpy(noticeParams->targetDevice[i].machineTypeCd, receivePayload + (idx + diff), 3);
        diff += 3;
        memcpy(&(noticeParams->targetDevice[i].machineFormatCd), receivePayload + (idx + diff), 1);
        diff += 1;
        memcpy(noticeParams->targetDevice[i].machineSerial, receivePayload + (idx + diff), 8);
    }

    return i;
}

/**
 * @brief 処理キューに受信したペイロードを追記
 * 
 * @param receivePayload 
 * @param payloadLen 
 * @return int16_t 
 */
int16_t
enqueueActionQueue(u_char *receivePayload, uint16_t payloadLen)
{

    u_char msg[256] = {0};
    u_char lf = '\n';
    // 出力
    outputAppendFile(ACTION_QUEUE_FILE, receivePayload, payloadLen);
    outputAppendFile(ACTION_QUEUE_FILE, &lf, 1);

    snprintf(msg, 256, "内容を追記 [%s] ", ACTION_QUEUE_FILE);
    LogOutput(NTSS_LOG_INFO, msg);

    return 0;
}

/**
 * @brief 処理キューからの読み出し（キューからは削除）
 * 
 * @param payload 読出結果格納
 * @return int16_t -1:ファイルオープン失敗, -2:ファイル内容なし, それ以外:読出結果文字数
 */
int16_t
dequeueActionQueue(u_char *payload, uint16_t max_size)
{
    int16_t r = readFileOneLine(payload, max_size, ACTION_QUEUE_FILE);
    if (r != 0)
    {
        return r;
    }
    // １行目を削除
    u_char cmd[512] = {0};
    sprintf(cmd, "sed -i -e '1d' %s", ACTION_QUEUE_FILE);
    system(cmd);

    return strlen(payload);
}

/**
 * @brief キューにデータがあるかどうかの確認
 * 
 * @return true 
 * @return false 
 */
bool hasDataActionQueue()
{
    u_char payload[512] = {0};
    if (readFileOneLine(payload, 512, ACTION_QUEUE_FILE) != 0)
    {
        // データ無しまたは読み込み失敗
        return false;
    }
    if (strlen(payload) == 0)
    {
        // 取得したデータの長さがゼロ
        return false;
    }
    return true;
}

/**
 * @brief データ収集フォルダのファイルを収集
 * 
 * @return uint16_t 取得件数
 */
uint16_t
fetchCollectFiles(ConfigParameter_t *param)
{
    DIR *dir;
    struct dirent *dp;
    u_char path[255] = {0};

    uint16_t i, idx = 0;

    u_char pathBuff[sizeof(path) + sizeof(FileData_t)] = {0};
    struct stat statBuf;

    for (i = 0; i < 3; i++)
    {
        memset(path, 0, 255);
        switch (i)
        {
        case 0:
            strncpy(path, param->collectDataDirectory, sizeof(param->collectDataDirectory));
            break;
        case 1:
            strncpy(path, param->collectDataDirectory2, sizeof(param->collectDataDirectory2));
            break;
        case 2:
            strncpy(path, param->collectDataDirectory3, sizeof(param->collectDataDirectory3));
            break;
        }
        if ((dir = opendir(path)) == NULL)
        {
            perror(path);
            continue;
        }
        for (dp = readdir(dir); dp != NULL; dp = readdir(dir))
        {
            // 追記モードで出力ファイルオープン
            if (dp->d_name[0] == '.')
            {
                if (dp->d_name[1] == 0x00 || (dp->d_name[1] == '.' && dp->d_name[2] == 0x00))
                {
                    // [.]と[..]は除外する
                    continue;
                }
            }
            // 出力
            sprintf(pathBuff, "%s/%s\n", path, dp->d_name);
            outputAppendFile(TEMP_FILELIST_FILE, pathBuff, (uint16_t)strlen(pathBuff));
            idx++;
        }
        closedir(dir);
    }

    return idx;
}

/**
 * @brief ファイルを指定ディレクトリに移動、宛先に同名ファイルがある場合は追記する
 * 
 * @param fromFilePath 移動元ファイル
 * @param toDirPath 移動先ディレクトリ
 * @param toFileName 移動先ファイル名
 * @return uint16_t 0:成功 -1:移動先ディレクトリアスセス不可 -2:移動元ファイル参照不可 -3:移動元ファイル削除失敗 -4:移動失敗
 */
uint16_t
moveFileAppend(u_char *fromFilePath, u_char *toDirPath, u_char *toFileName)
{

    u_char toFilePath[255] = {0};
    struct stat st;
    FILE *fpw, *fpr;
    uint8_t dataBuff[255] = {0};
    uint32_t rc;
    u_char msg[512] = {0};

    if (stat_mkdir(toDirPath) == false)
    {
        return -1;
    }

    sprintf(toFilePath, "%s/%s", toDirPath, toFileName);
    if (stat(toFilePath, &st) == 0)
    {
        // ファイルが存在

        // 移動元ファイルをバイナリ読み出しモードでオープン
        fpr = fopen(fromFilePath, "rb");
        if (fpr == NULL)
        {
            snprintf(msg, 512, "%sを開けません。", fromFilePath);
            LogResourceOutput(NTSS_LOG_ERROR, msg);
            return -2;
        }
        else
        {
            while (true)
            {
                rc = fread(dataBuff, 1, 255, fpr);
                if (rc == 0)
                {
                    // ファイルの最後まで処理をした
                    break;
                }
                // 追記する
                outputAppendFile(toFilePath, dataBuff, rc);
            }
            fclose(fpr);
            if (removeFileFullPath(fromFilePath))
            {
                return 0;
            }
            else
            {
                return -3;
            }
        }
    }
    else
    {
        // 移動先にファイルなしなので単純に移動
        if (renameFile(fromFilePath, toFilePath) == 0)
        {
            snprintf(msg, 512, "[INFO] %sを%sに移動しました。", fromFilePath, toFilePath);
            LogOutput(NTSS_LOG_INFO, msg);
            return 0;
        }
        else
        {
            snprintf(msg, 512, "[ERROR] %sを%sに移動できませんでした。r(%d) %s", fromFilePath, toFilePath, errno, strerror(errno));
            LogResourceOutput(NTSS_LOG_ERROR, msg);
            return -4;
        }
    }
}

/**
 * @brief ディレクトリパスからファイル名のみを取得
 * 
 * @param file 
 * @param fullPath 
 * @return true 
 * @return false 
 */
bool basenameEx(u_char *file, const u_char *fullPath)
{
    u_char dir[1024] = {'\0'};
    u_char *dirEnd;

    dirEnd = strrchr(fullPath, '/');

    if (dirEnd == NULL)
    {
        printf("fileName only\n");
        sprintf(file, "%s", fullPath);
        return true;
    }

    //dirEndまでコピー
    uint16_t i;
    for (i = 0; i < (uint16_t)strlen(fullPath); i++)
    {
        dir[i] = fullPath[i];
        if (fullPath + i == dirEnd)
        {
            break;
        }
    }

    sprintf(file, "%s", dirEnd + 1);
    return true;
}

/**
 * @brief 抽出されたファイル一覧のファイルをすべてTempディレクトリへ移動する
 * 
 * @return true 
 * @return false 
 */
bool moveFileToTempDir(ConfigParameter_t *param)
{

    u_char filePath[255] = {0};
    u_char fileName[255] = {0};
    // ファイルオープン
    FILE *fp = fopen(TEMP_FILELIST_FILE, "r");
    if ((fp == NULL))
    {
        return false; /* system error */
    }

    int16_t res = 0;
    while (fgets(filePath, 255, fp) != NULL)
    {
        if (filePath[strlen(filePath) - 1] == '\n')
        {
            filePath[strlen(filePath) - 1] = '\0'; /* 余分な改行コードを削除 */
        }
        basenameEx(fileName, filePath);
        res = moveFileAppend(filePath, param->tempDirectory, fileName);
        if (res == -1)
        {
            // ディレクトリアクセス不可
            res = moveFileAppend(filePath, param->tempDirectory2, fileName);
            if (res == -1)
            {
                // ディレクトリアクセス不可
                res = moveFileAppend(filePath, param->tempDirectory3, fileName);
            }
        }
    }

    fclose(fp);

    removeFileFullPath(TEMP_FILELIST_FILE);
    return true;
}

/**
 * @brief データ収集対象装置リストファイルを作成する
 * 
 * @param targetDev 装置構造体リスト
 * @return true 
 * @return false 
 */
bool writeFileDataCollectMachineList(TargetDevice_t *targetDev)
{
    return outputFile(DATA_COLLECT_TARGET_FILE, (u_char *)targetDev, strlen((u_char *)targetDev)) == 1;
}

/**
 * @brief データ収集処理結果の送信
 * 
 * @param rest 
 * @param cPayload 
 * @param payLoadLen 
 * @param param 
 * @return true 
 * @return false 
 */
bool runDataCollectResultResponseSend(u_char *rest, u_char *cPayload, int32_t payLoadLen, RcvCollectNotice_t *noticeParams)
{
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // u_char *tempFile = "./tmpDataCollectResultResponse.dat";
    // u_char *sendBodyFile = "./tmpDataCollectResultResponseBody.txt";
    u_char *tempFile = "/tmp/tmpDataCollectResultResponse.dat";
    u_char *sendBodyFile = "/tmp/tmpDataCollectResultResponseBody.txt";
    u_char cbuff[NTSS_STR_MAX_SIZE] = {0};
    u_char logMessage[MAX_LOG_TEXT] = {0};
    u_char resultFileName[54] = {0};
    u_char resultFilePath[256] = {0};
    char outFile[100];
    int ret;
    // char *responseFile = "./tmpDataCollectResultResponseCode.txt";
    // char *errFile = "./tmpDataCollectResultErrResponseCode.txt";
    char *responseFile = "/tmp/tmpDataCollectResultResponseCode.txt";
    char *errFile = "/tmp/tmpDataCollectResultErrResponseCode.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 start
    //u_char responseCode[255] = {0};
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 end
    // add AWSとDEの通信断からの復旧 高 start
    int i = 0;
    int ret_fail;
    // add AWSとDEの通信断からの復旧 高 end

    LogOutput(NTSS_LOG_INFO, "データ収集処理結果通知処理開始");
    // 一時ファイル作成
    outputFile(tempFile, cPayload, payLoadLen);

    // ペイロードの内容をログ出力
    snprintf(logMessage, MAX_LOG_TEXT, "データ収集結果送信 RESTコール, (%s)", cPayload);
    LogOutput(NTSS_LOG_INFO, logMessage);

    // REST送信用BODY作成
    sprintf(
        cbuff, "./sh/make_json_b64param.sh \"%s\" \"%s\" \"%s\" %d", "content" // key
        ,
        tempFile // value
        ,
        sendBodyFile // output_file
        ,
        1 // 新規作成
    );
    // コマンド実行
    ret = system(cbuff);

    sprintf(resultFilePath, RESULT_FILE_FILEPATH, noticeParams->manageNo);

    // REST送信用BODY作成
    sprintf(
        cbuff, "./sh/make_json_b64param.sh \"%s\" \"%s\" \"%s\" %d", "filepath" // key
        ,
        resultFilePath // value
        ,
        sendBodyFile // output_file
        ,
        0 // 追記
    );
    // コマンド実行
    ret = system(cbuff);

    sprintf(resultFileName, RESULT_FILE_FILENAME, noticeParams->manageNo);

    // REST送信用BODY作成
    sprintf(
        cbuff, "./sh/make_json_b64param.sh \"%s\" \"%s\" \"%s\" %d", "filename" // key
        ,
        resultFileName // value
        ,
        sendBodyFile // output_file
        ,
        0 // 追記
    );
    // コマンド実行
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
        snprintf(logMessage, MAX_LOG_TEXT, "REST 失敗応答を取得, (%s)", responseCode);
        LogResourceOutput(NTSS_LOG_ERROR, logMessage);
    }
    */
    // RESTコールして結果を取得する
    ret = ntss_restcall("", "", cbuff, responseFile, errFile, "データ収集結果送信");
    
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

    // 使用したファイルの消し込み作業
    removeFileFullPath(tempFile);
    removeFileFullPath(sendBodyFile);

    if (ret == 0)
    {
        /*
        // 転送成功していたら使用したファイルの消し込み作業
        removeFileFullPath(tempFile);
        removeFileFullPath(sendBodyFile);
        removeFileFullPath(responseFile);
        removeFileFullPath(errFile);
        */
        return true;
    }
    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 end
    LogOutput(NTSS_LOG_INFO, "データ収集処理結果通知処理終了");
    return false;
}
/**
 * @brief データ収集通知の応答送信
 * 
 * @param rest 
 * @param cPayload 
 * @param payLoadLen 
 * @param param 
 * @return true 
 * @return false 
 */
bool runDataCollectSignalResponseSend(u_char *rest, u_char *cPayload, int32_t payLoadLen)
{
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // u_char *tempFile = "./tmpDataCollectSignalResponse.dat";
    // u_char *sendBodyFile = "./tmpDataCollectSignalResponseBody.txt";
    u_char *tempFile = "/tmp/tmpDataCollectSignalResponse.dat";
    u_char *sendBodyFile = "/tmp/tmpDataCollectSignalResponseBody.txt";
    u_char cbuff[NTSS_STR_MAX_SIZE] = {0};
    u_char logMessage[MAX_LOG_TEXT] = {0};
    char outFile[100];
    int ret;
    // char *responseFile = "./tmpDataCollectSignalResponseCode.txt";
    // char *errFile = "./tmpDataCollectSignalErrResponseCode.txt";
    char *responseFile = "/tmp/tmpDataCollectSignalResponseCode.txt";
    char *errFile = "/tmp/tmpDataCollectSignalErrResponseCode.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 start
    //u_char responseCode[255] = {0};
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 end
    // add AWSとDEの通信断からの復旧 高 start
    int i = 0;
    int ret_fail;
    // add AWSとDEの通信断からの復旧 高 end

    LogOutput(NTSS_LOG_INFO, "データ収集応答通知処理開始");
    // 一時ファイル作成
    outputFile(tempFile, cPayload, payLoadLen);

    // ペイロードの内容をログ出力
    snprintf(logMessage, MAX_LOG_TEXT, "データ収集応答 RESTコール, (%s)", cPayload);
    LogOutput(NTSS_LOG_INFO, logMessage);

    // REST送信用BODY作成
    sprintf(
        cbuff, "./sh/make_json_b64param.sh \"%s\" \"%s\" \"%s\" %d", "content" // key
        ,
        tempFile // value
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
        snprintf(logMessage, MAX_LOG_TEXT, "REST 失敗応答を取得, (%s)", responseCode);
        LogResourceOutput(NTSS_LOG_ERROR, logMessage);
    }
    */
    // RESTコールして結果を取得する
    ret = ntss_restcall("", "", cbuff, responseFile, errFile, "データ収集応答");
    
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

    // 使用したファイルの消し込み作業
    removeFileFullPath(tempFile);
    removeFileFullPath(sendBodyFile);

    if (ret == 0)
    {
        /*
        // 使用したファイルの消し込み作業
        removeFileFullPath(tempFile);
        removeFileFullPath(sendBodyFile);
        removeFileFullPath(responseFile);
        removeFileFullPath(errFile);
        */
        return true;
    }
    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 end
    LogOutput(NTSS_LOG_INFO, "データ収集応答通知処理終了");
    return false;
}

/**
 * @brief データ収集キャプチャファイル送信
 * 
 * @param rest 
 * @param param 
 */
bool runDataCollectPacketSend(u_char *rest, ConfigParameter_t *param)
{

    unsigned char cPayload[512] = {0};
    uint32_t payLoadLen;
    unsigned char cbuff[NTSS_STR_MAX_SIZE] = {0};
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    int sendCount;
    int fh;
    FILE *fp1, *fp2;
    char outPath[255];
    char findFile[100];
    char fname[200];
    char command[512] = {0};
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // char *collectFileList = "upload_target_file_list.txt";
    // char *responseFile = "./tmpUploadMonFileResponseCode.txt";
    // char *errFile = "./tmpUploadMonFileErrResponseCode.txt";
    char *collectFileList = "/tmp/upload_target_file_list.txt";
    char *responseFile = "/tmp/tmpUploadMonFileResponseCode.txt";
    char *errFile = "/tmp/tmpUploadMonFileErrResponseCode.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 start
    //u_char responseCode[255] = {0};
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 end
    // add AWSとDEの通信断からの復旧 高 start
    int i = 0;
    int ret_fail;
    // add AWSとDEの通信断からの復旧 高 end

    char *pathes[3] = {
        param->collectDataDirectory,
        param->collectDataDirectory2,
        param->collectDataDirectory3};
    time_t nowTim;
    struct tm *local;
    char nowStr[20];
    char findPathes[512] = {0};
    char buf[200];
    struct stat st;
    int findDir = 0;
    // #11282 2025.02.27 add 通信不可フォルダへの転送を装置ごとフォルダに変更 TDC片口 start
    char *pStr;
    char cDeviceType[4];
    char cDeviceNo[9];
    // #11282 2025.02.27 add 通信不可フォルダへの転送を装置ごとフォルダに変更 TDC片口 end

    /* 現在時刻を取得 */
    nowTim = time(NULL);
    local = localtime(&nowTim); /* 地方時に変換 */
    // 日付フォルダ名作成
    sprintf(nowStr, "%4d%02d%02d",
            local->tm_year + 1900, local->tm_mon + 1, local->tm_mday);

    int idx = 0;
    for (idx; idx < 3; idx++)
    {
        sprintf(outPath, "%s/%s", pathes[idx], nowStr);
        if (stat_mkdir(outPath))
        {
            break;
        }
    }

    LogResourceOutput(NTSS_LOG_INFO, "モニタデータアップロード処理開始");

    // #8730 2023.05.24 add AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 start
    //    LogOutput(NTSS_LOG_INFO, "モニタデータアップロードファイル構築");
    //int ret = ntss_mst_make_collect(param->facilityCode, param->deviceNo, pathes, outPath);
    // 連動アプリに通信SVが選択されていない、又は通信SVが選択されている場合でAWSとの通信許可がある場合
    int ret = 0;
    if (!(param->isSelectedComSv) || (param->isSelectedComSv && !getIsDisabledCallApi())) {

        LogOutput(NTSS_LOG_INFO, "モニタデータアップロードファイル構築");

        // 蓄積系バイナリデータをテキストファイルに変換する
        ret = ntss_mst_make_collect(param->facilityCode, param->deviceNo, pathes, outPath, param->isSelectedComSv);

        snprintf(logMessage, MAX_LOG_TEXT, "モニタデータアップロードファイル作成完了 : %d 件", ret);
        LogOutput(NTSS_LOG_INFO, logMessage);
    }
    // #8730 2023.05.24 add AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 end

    // タイムスタンプ昇順で対象ファイル一覧作成
    sprintf(findFile, COLLECT_OUTPUT, "*");
    LogOutput(NTSS_LOG_INFO, "モニタデータアップロード対象ファイル一覧取得");

    for (idx = 0; idx < 3; idx++)
    {
        // フォルダアクセス確認
        if (existFolderFile(pathes[idx], &st) != 1)
        {
            continue;
        }
        sprintf(buf, "%s %s", findPathes, pathes[idx]);
        sprintf(findPathes, "%s", buf);
        findDir = 1;
    }

    if (findDir == 0)
    {
        // フォルダアクセスなし
        LogOutput(NTSS_LOG_INFO, "アクセス可能フォルダ無し");
        return false;
    }

    // #8730 2023.05.23 del AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 start
    //sprintf(command, "find %s -maxdepth 2 -type f -name \"%s\" | xargs --no-run-if-empty ls -rt1 > %s", findPathes, findFile, collectFileList);
    //system(command);
    // #8730 2023.05.23 del AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 start

    // データ収集格納ファイル一覧オープン
    sendCount = 0;

    if (getIsDisabledCallApi())
    {
        // クラウド通信不可フラグがONの場合、REST APIコール失敗時と同様の処理を行う
        // 今回は sendCount == 0 ならばfalseが返る
        snprintf(logMessage, MAX_LOG_TEXT, "モニタデータアップロード処理 REST API 通信不可状態のため処理スキップ");
        LogResourceOutput(NTSS_LOG_INFO, logMessage);
        
        // #8081 del 2023.05.09 通信状態を通信SVへ通知しないようにする TDC米沢 start
        // // add AWSとDEの通信断からの復旧 高 start
        // if(getCommAliveState() == 0) {
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

        // #8730 2023.06.01 add AWSとの通信異常時の蓄積系データを通信SVへ移動 TDC米沢 start
        // 連動アプリ判定
        if (param->isSelectedComSv && isEnabledFirstAWSComm()) {
            // 通信SVが動作しており、一度でもAWSとの通信が可能となった場合

            LogOutput(NTSS_LOG_INFO, "通信不可状態のためモニタデータ移動 蓄積系データ収集");

            // #11282 2025.02.27 mod 通信不可フォルダへの転送を装置ごとフォルダに変更 TDC片口 start
            // // ユニークな移動リストファイル名作成
            // sprintf( nowStr, "%4d%02d%02d%02d%02d%02d",
            //     local->tm_year + 1900, local->tm_mon + 1, local->tm_mday,
            //     local->tm_hour, local->tm_min, local->tm_sec);
            // sprintf(buf, "%s/commFail/moveFile_%s.lst", param->commFailDirectory, nowStr);
            sprintf(outPath, "%s/commFailData", param->commFailDirectory);
            //  通信不可フォルダ有無判定
            if (existFolderFile(outPath, NULL) != 1)
            {
                // ない場合はフォルダ作成
                createFolder(outPath);
            }
            sprintf(outPath, "%s/commFailData/moveFiles", param->commFailDirectory);
            //  通信不可フォルダ有無判定
            if (existFolderFile(outPath, NULL) != 1)
            {
                // ない場合はフォルダ作成
                createFolder(outPath);
            }
            // #11282 2025.02.27 mod 通信不可フォルダへの転送を装置ごとフォルダに変更 TDC片口 end

            // 対象フォルダの全ファイルのリストを作成[更新日昇順]
            sprintf(command, "find %s -maxdepth 2 -type f -name \"%s\" | xargs --no-run-if-empty ls -rt1 > %s", findPathes, "*", collectFileList);
            system(command);
            LogOutput(NTSS_LOG_INFO, "通信不可状態のためモニタデータ移動 蓄積系データ収集完了");

            sendCount = 0;
            fp1 = fopen(collectFileList, "r");
            if (fp1 != NULL)
            {
                for (;;)
                {
                    memset(fname, 0, sizeof(fname));
                    if (fgets(fname, sizeof(fname), fp1) == NULL)
                    {
                        break;
                    }
                    fname[strlen(fname) - 1] = 0; // 末尾の改行コード無視

                    if (existFolderFile(fname, &st) != 1)
                    {
                        continue;
                    }
                    if (st.st_size > 0)
                    {
                        // #11282 2025.02.27 mod 通信不可フォルダへの転送を装置ごとフォルダに変更 TDC片口 start
                        // // 通信不可フォルダへの転送が必要な蓄積系データファイルかどうか判定
                        // //  リアルタイム系(ファイル名に「_RMN_」が含まれている)以外のバイナリファイル[*.bin]
                        // //  通信共通用テキストファイル[collect_*_comm.txt]
                        // if ((strcasecmp(fname + strlen(fname) - 3, "bin") == 0 && strcasestr( fname, "_RMN_" ) == NULL )
                        //     || (strcasestr( fname, "_comm.txt" ) != NULL )
                        // ) {

                        //     // 転送を行うファイルの場合

                        //     // 移動先ファイル名作成
                        //     strcpy(cbuff, fname);
                        //     sprintf(outPath, "%s/commFailData/%s", param->commFailDirectory, basename(cbuff));
                        //     //LogOutput(NTSS_LOG_INFO, outPath);
                        //     // 通信不可フォルダ有無判定
                        //     strcpy(cbuff, outPath);
                        //     pathes[0] = dirname(cbuff);
                        //     if (existFolderFile(pathes[0], NULL) != 1) {
                        //         // ない場合はフォルダ作成
                        //         createFolder(pathes[0]);
                        //     }

                        //     // 蓄積系データを移動
                        //     if (moveFile(fname, outPath, NTSS_MOVEFILE_MODE_OVERWRITE) == 1) {
                        //         snprintf(logMessage, MAX_LOG_TEXT, "通信不可状態のためモニタデータ移動 蓄積系データを移動 [%s] -> [%s]", fname, outPath);
                        //         LogOutput(NTSS_LOG_INFO, logMessage);

                        //         // 移動リストに追記
                        //         outputAppendFile(buf, outPath, strlen(outPath));
                        //         outputAppendFile(buf, "\n", 1);
                        //         sendCount++;
                        //     }
                        // } else {
                        //     // 転送しないファイル

                        //     // ファイル削除
                        //     snprintf(logMessage, MAX_LOG_TEXT, "通信不可状態のためモニタデータ移動 蓄積系データ以外のため削除 [%s]", fname);
                        //     LogOutput(NTSS_LOG_INFO, logMessage);
                        //     removeFileFullPath(fname);
                        // }

                        // 通信不可フォルダへの転送が必要な蓄積系データファイルかどうか判定
                        bool isTargetBin = (strcasecmp(fname + strlen(fname) - 3, "bin") == 0 && strcasestr(fname, "_RMN_") == NULL);
                        bool isTargetTxt = strcasestr(fname, "_comm.txt") != NULL;

                        if (isTargetBin || isTargetTxt)
                        {
                            if (isTargetBin)
                            {
                                // リアルタイム系(ファイル名に「_RMN_」が含まれている)以外のバイナリファイル[*.bin]は転送を行う

                                // 移動先ファイル名作成
                                strcpy(cbuff, fname);
                                pStr = basename(cbuff);

                                // #11282 2025.03.13 mod 通信共通の装置ログが非対応だった問題の修正 TDC片口 start
                                // if (strstr(pStr, "_LOG_") == NULL)
                                if (pStr[3] == '_')
                                {
                                    // #11282 2025.03.13 mod 通信共通の装置ログが非対応だった問題の修正 TDC片口 end

                                    // 装置ログ以外のファイル名から各情報を取得
                                    // [型式コード]_[製造番号]_[通信方式]_[通信フォーマット]_[通信コマンド識別子]_[受信年月日時分秒マイクロ秒].bin
                                    // 型式コード
                                    strncpy(cDeviceType, pStr, 3);
                                    // 製造番号
                                    *strstr(pStr + 4, "_") = NULL;
                                    strcpy(cDeviceNo, pStr + 4);
                                }
                                else
                                {
                                    // 装置ログのファイル名から各情報を取得
                                    // [受信年月日時分秒マイクロ秒(20)]_[型式コード(3)]_[製造番号(7)]_[通信方式(1)]_[通信フォーマット(1)]_LOG_[ランダム(6)].bin
                                    // 型式コード
                                    strncpy(cDeviceType, pStr + 21, 3);
                                    // 製造番号
                                    *strstr(pStr + 25, "_") = NULL;
                                    strcpy(cDeviceNo, pStr + 25);
                                }

                                // #11282 2025.03.13 del 通信共通の装置ログが非対応だった問題の修正 TDC片口 start
                                // sprintf(outPath, "%s/commFailData/moveFiles/nkk_%s_%s/%s", param->commFailDirectory, cDeviceType, cDeviceNo, basename(fname));
                                // #11282 2025.03.13 del 通信共通の装置ログが非対応だった問題の修正 TDC片口 end
                            }
                            else
                            {
                                // 通信共通用テキストファイル[collect_*_comm.txt]は転送を行う
                                // ファイルから各情報を取得
                                if (readFileOneLine(cbuff, sizeof(cbuff), fname) == 0)
                                {
                                    // 型式コード
                                    strncpy(cDeviceType, strstr(cbuff, "devicetype=") + 11, 3);
                                    // 製造番号
                                    pStr = strstr(cbuff, "serialno=") + 9;
                                    *strstr(pStr, "\t") = NULL;
                                    strcpy(cDeviceNo, pStr);
                                }

                                // #11282 2025.03.13 del 通信共通の装置ログが非対応だった問題の修正 TDC片口 start
                                // sprintf(outPath, "%s/commFailData/moveFiles/cp_%s_%s/%s", param->commFailDirectory, cDeviceType, cDeviceNo, basename(fname));
                                // #11282 2025.03.13 del 通信共通の装置ログが非対応だった問題の修正 TDC片口 end
                            }
                            // #11282 2025.03.13 add 通信共通の装置ログが非対応だった問題の修正 TDC片口 start
                            sprintf(outPath, "%s/commFailData/moveFiles/%s_%s/%s", param->commFailDirectory, cDeviceType, cDeviceNo, basename(fname));
                            // #11282 2025.03.13 add 通信共通の装置ログが非対応だった問題の修正 TDC片口 end

                            //  通信不可フォルダ有無判定
                            strcpy(cbuff, outPath);
                            pathes[0] = dirname(cbuff);
                            if (existFolderFile(pathes[0], NULL) != 1)
                            {
                                // ない場合はフォルダ作成
                                createFolder(pathes[0]);
                            }

                            // 蓄積系データを移動
                            if (moveFile(fname, outPath, NTSS_MOVEFILE_MODE_OVERWRITE) == 1)
                            {
                                snprintf(logMessage, MAX_LOG_TEXT, "通信不可状態のためモニタデータ移動 蓄積系データを移動 [%s] -> [%s]", fname, outPath);
                                LogOutput(NTSS_LOG_INFO, logMessage);

                                sendCount++;
                            }
                        }
                        else
                        {
                            // 転送しないファイル

                            // ファイル削除
                            snprintf(logMessage, MAX_LOG_TEXT, "通信不可状態のためモニタデータ移動 蓄積系データ以外のため削除 [%s]", fname);
                            LogOutput(NTSS_LOG_INFO, logMessage);
                            removeFileFullPath(fname);
                        }
                        // #11282 2025.02.27 mod 通信不可フォルダへの転送を装置ごとフォルダに変更 TDC片口 end
                    }
                }
                fclose(fp1);

                snprintf(logMessage, MAX_LOG_TEXT, "通信不可状態のためモニタデータ移動 蓄積系データの移動完了 [%d]件", sendCount);
                LogOutput(NTSS_LOG_INFO, logMessage);

                // #11282 2025.03.12 mod 通信不可フォルダへの転送完了のシグナル通知 TDC片口 start
                // #11282 2025.02.27 del 通信不可フォルダへの転送を装置ごとフォルダに変更 TDC片口 start
                // // 移動ファイルがあった場合
                // if (0 < sendCount) {
                //     snprintf(logMessage, MAX_LOG_TEXT, "通信不可状態のためモニタデータ移動 蓄積系データの移動リストファイル [%s]", buf);
                //     LogOutput(NTSS_LOG_INFO, logMessage);

                //     // 通信SVに蓄積系データの取り込み依頼を通知
                //     kill(getChildCaptureAppPid(), SIG_COMM_FILE_MOVED);
                //     LogOutput(NTSS_LOG_INFO, "通信不可状態のためモニタデータ移動 通信SVへのデータ移動完了を通知");
                // }

                // sendCount = 0;
                // #11282 2025.02.27 del 通信不可フォルダへの転送を装置ごとフォルダに変更 TDC片口 end

                // 移動ファイルがあった場合
                if (0 < sendCount) {
                    // 通信SVに蓄積系データの取り込み依頼を通知
                    kill(getChildCaptureAppPid(), SIG_COMM_FILE_MOVED);
                    LogOutput(NTSS_LOG_INFO, "通信不可状態のためモニタデータ移動 通信SVへのデータ移動完了を通知");
                }

                sendCount = 0;
                // #11282 2025.03.12 mod 通信不可フォルダへの転送完了のシグナル通知 TDC片口 start
            }
        }
        // #8730 2023.06.01 add AWSとの通信異常時の蓄積系データを通信SVへ移動 TDC米沢 end
    }
    else
    {
        // #8730 2023.05.23 add AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 start
        sprintf(command, "find %s -maxdepth 2 -type f -name \"%s\" | xargs --no-run-if-empty ls -rt1 > %s", findPathes, findFile, collectFileList);
        system(command);
        // #8730 2023.05.23 add AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 start

        fp1 = fopen(collectFileList, "r");
        if (fp1 != NULL)
        {
            for (;;)
            {
                memset(fname, 0, sizeof(fname));
                if (fgets(fname, sizeof(fname), fp1) == NULL)
                {
                    break;
                }
                fname[strlen(fname) - 1] = 0; // 末尾の改行コード無視

                if (existFolderFile(fname, &st) != 1)
                {
                    continue;
                }
                if (st.st_size > 0)
                {

                    // データあり
                    snprintf(logMessage, MAX_LOG_TEXT, "モニタデータファイルアップロード REST コール, (%s)", fname);
                    LogOutput(NTSS_LOG_INFO, logMessage);

                    // RESTをコールする
                    sprintf(
                        cbuff, "./sh/post_data_file.sh \"%s\" \"%s\" \"%s\" \"%d\" \"%s\" \"%s\"", rest, fname, param->facilityCode, param->deviceNo, responseFile, errFile);

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
                        snprintf(logMessage, MAX_LOG_TEXT, "モニタデータアップロード REST 応答あり, (%s)", responseCode);
                    }
                    else
                    {
                        snprintf(logMessage, MAX_LOG_TEXT, "モニタデータアップロード REST 実行システムコール応答, (%d)", ret);
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
                            ret = 1;
                        }
                    }
                    else
                    {
                        // 転送失敗エラー
                        ret = 2;
                    }
                    */
                    // RESTコールして結果を取得する
                    ret = ntss_restcall("", "", cbuff, responseFile, errFile, "モニタデータファイルアップロード");
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
                }
                else
                {
                    sendCount--;
                    ret = 0;
                }

                // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 start
                /*
                if (ret > 0)
                {
                    // NOTE:クラウド通信不可フラグをON
                    setIsDisabledCallApi(true);
                }

                if (ret > 0 && readFileOneLine(responseCode, 255, errFile) == 0)
                {
                    snprintf(logMessage, MAX_LOG_TEXT, "モニタデータアップロード REST 失敗応答を取得, (%s)", responseCode);
                    LogResourceOutput(NTSS_LOG_ERROR, logMessage);
                }
                */

                // #8730 2023.05.23 add AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 start
                // アップデート用バイナリファイルリストファイル名作成
                sprintf(buf, "%s", fname);
                strcpy(buf + strlen(buf) - 3, "idx");
                // #8730 2023.05.23 add AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 end

                // #8730 2023.06.23 mod AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 start
                /*
                if (ret == 0 )
                {
                    // 転送成功していたら使用したファイルの消し込み作業
                    removeFileFullPath(fname);
                    removeFileFullPath(responseFile);
                    removeFileFullPath(errFile);
                */
                if (ret == 0 || ret == 1)
                {
                // #8730 2023.06.23 mod AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 start

                    // #8730 2023.06.23 add AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 end
                    // 応答判定 
                    if ( ret == 1 )
                    {
                        // 500応答の場合
                        // 移動先ファイル名作成
                        strcpy(cbuff, fname);
                        sprintf(outPath, "./NG/%s",basename(cbuff));
                        //LogOutput(NTSS_LOG_INFO, outPath);
                        // NGフォルダ有無判定
                        strcpy(cbuff, outPath);
                        pathes[0] = dirname(cbuff);
                        if (existFolderFile(pathes[0], NULL) != 1) {
                            // ない場合はフォルダ作成
                            createFolder(pathes[0]);
                        }

                        // アップロードファイルをNGフォルダへ移動
                        if (moveFile(fname, outPath, NTSS_MOVEFILE_MODE_OVERWRITE) == 1) {
                            snprintf(logMessage, MAX_LOG_TEXT, "モニタデータファイルアップロード 500応答のため蓄積系データをNGフォルダへ移動 [%s] -> [%s]", fname, outPath);
                            LogOutput(NTSS_LOG_INFO, logMessage);
                        }
                    }
                    else
                    {
                        // 転送成功の場合

                        // アップロードファイルの消し込み作業
                        removeFileFullPath(fname);
                    }

                    // リストファイルの有無チェック
                    if (existFolderFile(buf, NULL) == 1) {
                        // リストファイルがある場合

                        // リストファイルを開く
                        fp2 = fopen(buf, "r");
                        if (fp2 != NULL)
                        {
                            for (;;)
                            {
                                memset(fname, 0, sizeof(fname));
                                if (fgets(fname, sizeof(fname), fp2) == NULL)
                                {
                                    break;
                                }
                                fname[strlen(fname) - 1] = 0; // 末尾の改行コード無視

                                // 記載されているバイナリファイルを削除
                                removeFileFullPath(fname);
                            }
                            fclose(fp2);
                        }
                        // リストファイルを削除
                        removeFileFullPath(buf);
                    }
                    // #8730 2023.06.23 add AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 end

                    sprintf(buf, "%s", dirname(fname));
                    if (existFolderInFiles(buf) == 0)
                    {
                        // ディレクトリが空っぽになった
                        removeFileFullPath(buf);
                    }
                    sendCount++;
                }
                else
                {
                    // NOTE:クラウド通信不可フラグをON
                    setIsDisabledCallApi(true);

                    // 連動アプリで通信SVが選択されている場合
                    if (param->isSelectedComSv) {
                        // アップロードファイルが通信共通以外の場合
                        if (strcasestr( fname, "_comm.txt" ) == NULL ) {
                            // アップロードファイルの有無チェック
                            if (existFolderFile(fname, NULL) == 1) {
                                // アップロードファイルを削除
                                removeFileFullPath(fname);
                            }
                            // アップロードリストファイルの有無チェック
                            if (existFolderFile(buf, NULL) == 1) {
                                // アップロードリストファイルを削除
                                removeFileFullPath(buf);
                            }
                        }
                    }

                    // 失敗していたらbreak
                    break;
                }
                // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 end
            }
            fclose(fp1);
        }
    }
    remove(collectFileList);

    // ディレクトリが空っぽになったら削除
    sprintf(command, "find %s -mindepth 1 -type d -empty -delete", findPathes);
    system(command);

    // 送信成功があればtrue
    LogOutput(NTSS_LOG_INFO, "モニタデータアップロード処理終了");
    if (sendCount > 0)
    {
        return true;
    }
    else
    {
        return false;
    }
}

/**
 * @brief モニタデータ送信完了通知
 * TODO: 生体モニタリングの画面更新用だが、将来的にはモニタデータアップロードのAPIでサーバー側処理とすべき
 * 
 * @param rest 
 * @param cPayload 
 * @param payLoadLen 
 * @return true 
 * @return false 
 */
bool runNoticeUpdateSend(u_char *rest, u_char *targetId, int32_t targetIdLen)
{
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // u_char *tempFile = "./tmpNoticeUpdate.dat";
    // u_char *sendBodyFile = "./tmpNoticeUpdateBody.txt";
    u_char *tempFile = "/tmp/tmpNoticeUpdate.dat";
    u_char *sendBodyFile = "/tmp/tmpNoticeUpdateBody.txt";
    u_char cbuff[NTSS_STR_MAX_SIZE] = {0};
    u_char logMessage[MAX_LOG_TEXT] = {0};
    char outFile[100];
    int ret;
    // char *responseFile = "./tmpNoticeUpdateResponseCode.txt";
    // char *errFile = "./tmpNoticeUpdateErrResponseCode.txt";
    char *responseFile = "/tmp/tmpNoticeUpdateResponseCode.txt";
    char *errFile = "/tmp/tmpNoticeUpdateErrResponseCode.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 start
    //u_char responseCode[255] = {0};
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 end

    LogOutput(NTSS_LOG_INFO, "モニタデータ送信完了通知処理開始");

    // 一時ファイル作成
    outputFile(tempFile, targetId, targetIdLen);

    // ペイロードの内容をログ出力
    snprintf(logMessage, MAX_LOG_TEXT, "モニタデータ送信完了通知送信 RESTコール, (%s)", targetId);
    LogOutput(NTSS_LOG_INFO, logMessage);

    // REST送信用BODY作成
    sprintf(
        cbuff, "./sh/make_json_b64param.sh \"%s\" \"%s\" \"%s\" %d", "targetId" // key
        ,
        tempFile // value
        ,
        sendBodyFile // output_file
        ,
        1 // 新規作成
    );
    // コマンド実行
    ret = system(cbuff);

    // 一時ファイル作成
    outputFile(tempFile, "UPDATE", strlen("UPDATE"));

    // REST送信用BODY作成
    sprintf(
        cbuff, "./sh/make_json_b64param.sh \"%s\" \"%s\" \"%s\" %d", "message" // key
        ,
        tempFile // value
        ,
        sendBodyFile // output_file
        ,
        0 // 追記
    );
    // コマンド実行
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
        snprintf(logMessage, MAX_LOG_TEXT, "REST 失敗応答を取得, (%s)", responseCode);
        LogResourceOutput(NTSS_LOG_ERROR, logMessage);
    }
    */
    // RESTコールして結果を取得する
    ret = ntss_restcall("", "", cbuff, responseFile, errFile, "モニタデータ送信完了通知送信");

    // 使用したファイルの消し込み作業
    removeFileFullPath(tempFile);
    removeFileFullPath(sendBodyFile);

    if (ret == 0)
    {
        /*
        // 転送成功していたら使用したファイルの消し込み作業
        removeFileFullPath(tempFile);
        removeFileFullPath(sendBodyFile);
        removeFileFullPath(responseFile);
        removeFileFullPath(errFile);
        */
        return true;
    }
    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 end
    LogOutput(NTSS_LOG_INFO, "モニタデータ送信完了通知処理終了");

    return false;
}
