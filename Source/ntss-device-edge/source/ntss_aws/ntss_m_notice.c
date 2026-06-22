#include <dirent.h>
#include <stdio.h>
#include <string.h>
#include <stdint.h>
#include <stdbool.h>
#include <time.h>
#include <sys/stat.h>
#include <stdlib.h>
#include <err.h>
#include <errno.h>
#include <iconv.h>

#include "ntss_m_notice.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
//#include "ntss_file.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
#include "../common/nkklib/nkklib.h"
#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/ntss_etc_lib.h"

/**
 * @brief 
 * 
 * 取得した電文を分解して通信仕様の構造体に格納
 * 
 * @param message
 * @param type // 0:なし, 1:日機装（新）通信 , 2:NX通信, 3:通信共通プロトコル
 * 
 * @return MessageData_t
 */
MessageData_t
separateMessage(u_char *message, uint16_t type)
{
    MessageData_t msgData = {0};
    int32_t cnt;

    extern MessageData_t separateMessageNkk(uint8_t * message);
    extern MessageData_t separateMessageNx(uint8_t * message);

    // mod FNSI-バグ 通信サーバ 高 start
    // if (type == MESSAGE_TYPE_IS_NKK)
    if (type == MESSAGE_TYPE_IS_NKK || type == MESSAGE_TYPE_IS_V4)
    // mod FNSI-バグ 通信サーバ 高 end
    {
        msgData = separateMessageNkk(message);
    }
    else if (type == MESSAGE_TYPE_IS_NX)
    {
        msgData = separateMessageNx(message);
    }
    msgData.type = type;
    return msgData;
}

/**
 * @brief 
 * 
 * 取得した電文を分解して日機装通信仕様の構造体に格納
 * 
 * @param message
 * 
 * @return MessageData_t
 */
MessageData_t
separateMessageNkk(u_char *message)
{
    MessageData_t msgData = {0};
    int32_t cnt;

    // 通信フォーマット
    msgData.fmt[0] = message[0];
    // 装置識別コード
    for (cnt = 0; cnt < 7; cnt++)
    {
        msgData.dnd[cnt] = message[cnt + 1];
    }
    // 日機装通信フォーマットでは識別コードは7桁なので、8桁目は半角スペ
    msgData.dnd[7] = ' ';
    // シーケンシャルＮｏ（１１～ＦＦＨ、１通信毎に更新）
    msgData.sno[0] = message[8];
    // コマンドコード
    msgData.cmd[0] = message[9];
    // ステータス
    for (cnt = 0; cnt < 2; cnt++)
    {
        msgData.sta[cnt] = message[cnt + 10];
    }
    // データ部
    for (cnt = 0; cnt < 20; cnt++)
    {
        msgData.data[cnt] = message[cnt + 12];
    }

    return msgData;
}

/**
 * @brief 
 * 
 * 取得した電文を分解してNX通信仕様の構造体に格納
 * 
 * @param message
 * 
 * @return MessageData_t
 */
MessageData_t
separateMessageNx(u_char *message)
{
    MessageData_t msgData = {0};
    int32_t cnt, cnt2;

    // 通信フォーマット 3byte目
    msgData.fmt[0] = message[2];
    // 製造番号 5〜20byte目
    // (utf-16だが、シングルバイ文字トのみなので必ず0x00である1byte目をスキップして取得)
    u_char machineId[16] = {0};
    memcpy(machineId, &message[4], 16);
    u_char machineIdSingle[8] = {0};
    cnt2 = 0;
    for (cnt = 0; cnt < 16; cnt++)
    {
        if (machineId[cnt] != 0x00)
        {
            machineIdSingle[cnt2] = machineId[cnt];
            cnt2++;
        }
    }
    if (msgData.fmt[0] == 'R')
    {
        // DRO装置は製造番号が8桁
        for (cnt = 0; cnt < 8; cnt++)
        {
            msgData.dnd[cnt] = machineIdSingle[cnt];
        }
    }
    else
    {
        // ほか装置はコードは7桁(先頭空白)、空白を8桁目として取得
        for (cnt = 0; cnt < 7; cnt++)
        {
            msgData.dnd[cnt] = machineIdSingle[cnt + 1];
        }
        msgData.dnd[7] = ' ';
    }
    // シーケンシャルＮｏ (不使用)（実際は20 - 21の 2バイト）
    msgData.sno[0] = message[21];
    // コマンドコード 0005
    memcpy(msgData.cmd, &message[22], 2);

    // データサイズ部２byte
    uint16_t dataSize = 0;
    u_char dataSizeByte[2] = {0};
    memcpy(dataSizeByte, &message[24], 2);
    // ステータス
    // 状態コードは２バイト不使用
    // 発報するステータスはデータ部に含まれる

    // データ部
    if (msgData.fmt[0] == 'R')
    {
        // DRO装置はログデータアドレス１のみ
        dataSize = 14;
    }
    else
    {
        // ほか装置はアドレス７まで
        dataSize = 14 + 4 + 8 + 6 + 6 + 6 + 4;
    }
    for (cnt = 0; cnt < dataSize; cnt++)
    {
        msgData.data[cnt] = message[cnt + 28];
    }

    return msgData;
}

/**
 * @brief 指定のファイル名が指定の拡張子かどうかを判定
 * 
 * @param fName ファイル名
 * @param ext 拡張子名
 * @return bool 拡張子が一致すればt 拡張子不一致ならf
 */
bool findExt(const u_char *fName, const u_char *ext)
{
    uint32_t i;
    u_char buf[256] = {0};

    for (i = strlen(fName); i > 0; i--)
    {
        if (fName[i] == '.')
        {
            break;
        }
    }
    if (i == 0)
    {
        // 拡張子なし
        return false;
    }
    strncpy(buf, fName + i + 1, strlen(fName) - i);
    if (strcmp(buf, ext) == 0)
    {
        // 拡張子が一致
        return true;
    }
    //拡張子不一致
    return false;
}

/**
 * @brief ファイル名から通信方式を取得
 * 
 * @param fileName ファイル名
 * @return int16_t 通信方式
 */
int16_t
getTypeFromFileName(u_char *fileName)
{
    u_char tempCode[10] = {0};
    // ファイル名の26桁目以降が [製造番号（7-8桁）]_[通信方式（1桁）]
    strncpy(tempCode, fileName + 25, 10);
    int16_t i;
    for (i = 0; i < 10; i++)
    {
        if (tempCode[i] == '_')
        {
            // '_'の次の文字が通信方式
            break;
        }
    }
    if (i == 10)
    {
        // 取得失敗
        return -1;
    }
    return atoi(&(tempCode[i + 1]));
}

/**
 * @brief 比較判定用
 * 
 * @param p 被比較対象FileData
 * @param q 比較対象FileData
 * @return int32_t 
 */
int32_t
cmp(const void *p, const void *q)
{
    return ((FileData_t *)p)->lastTime - ((FileData_t *)q)->lastTime;
}

/**
 * @brief バイナリファイルの読み込み
 * 
 * @param path 
 * @param buff 
 * @return uint32_t データサイズ
 */
uint32_t
readBinaryFile(uint8_t *buff, const u_char *path)
{
    FILE *fp;
    u_char msg[128] = {0};
    if ((fp = fopen(path, "rb")) == NULL)
    {
        snprintf(msg, 128, "file open error:[%s]", path);
        LogResourceOutput(NTSS_LOG_ERROR, msg);
        return false; /* system error */
    }

    uint32_t size = fread(buff, sizeof(uint8_t), 10000, fp);
    fclose(fp);
    return size;
}

/**
 * @brief ログ収集データを蓄積するデータ収集ファイルのファイル名を作成
 * 
 * @param nameBuff 
 * @param msgData 
 * @return true 
 * @return false 
 */
bool buildMachineLogFileName(u_char *nameBuff, MessageData_t msgData)
{

    //ファイル名の生成

    uint16_t len = 0;
    // 製造番号
    if (msgData.dnd[7] == 0x20)
    {
        // 製造番号が７桁の場合
        len = 7;
    }
    else
    {
        // 製造番号が８桁の場合
        len = 8;
    }
    u_char serialCode[9] = {0};
    memcpy(serialCode, msgData.dnd, len);

    // 型式コード
    u_char machineTypeCode[4] = {0};
    len = 3;
    memcpy(machineTypeCode, msgData.machineTypeCode, len);

    // ファイル名の先頭８桁が日時
    u_char fileDate[9] = {0};
    len = 8;
    memcpy(fileDate, msgData.fileName, len);

    // _通信フォーマット
    u_char fmt[2] = {0};
    len = 1;
    memcpy(fmt, msgData.fmt, len);

    // 型式コード[3]_製造番号[7-8]_通信方式[1]_通信フォーマット[1]_LOG_処理年月日[8](_分割時分秒[6]).bin
    sprintf(nameBuff, "%s_%s_%d_%s_LOG_%s.bin", machineTypeCode, serialCode, msgData.type, fmt, fileDate);

    return true;
}

/**
 * @brief ファイルをデータ収集フォルダへ移動
 * 
 * @param msgData 
 * @return true 
 * @return false 
 */
bool moveFileToCollectDir(MessageData_t msgData, ConfigParameter_t *param)
{

    u_char toFilePath[512] = {0};
    u_char baseFilePath[512] = {0};
    u_char path[255] = {0};
    u_char dataBuff[255] = {0};
    struct stat st;
    u_char msg[256] = {0};

    sprintf(baseFilePath, "%s/%s", msgData.fileDir, msgData.fileName);
    uint32_t dataSize = readBinaryFile(dataBuff, baseFilePath);
    int16_t i;
    if (dataSize > 0)
    {

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
            sprintf(toFilePath, "%s/%s", path, msgData.fileName);

            // フォルダアクセス確認
            if (existFolderFile(path, &st) != 1)
            {
                if (stat_mkdir(path))
                {
                    // ディレクトリ生成成功
                    i--;
                    continue;
                }
                else
                {
                    continue;
                }
            }
            else
            {
                // 出力
                if (outputFile(toFilePath, dataBuff, dataSize) == 0)
                {
                    // 出力失敗
                    continue;
                }

                snprintf(msg, 256, "ファイルを保存 [%s] → [%s] ", baseFilePath, toFilePath);
                LogOutput(NTSS_LOG_INFO, msg);
                //backupRenameFile(toFilePath, false, 1024 * 1024 * 10);

                return true;
            }
        }
    }

    return false;
}

/**
 * @brief ペイロードの内容をログ出力
 * 
 * @param cPayload 
 * @param payLoadLen 
 */
void log_payload(u_char *cPayload, uint32_t payLoadLen)
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

/**
 * @brief データ収集ログファイルを読み込み、緊急発報対象ならばRESTに投げて、その後ファイルをデータ収集フォルダへ移動
 * 
 * @param rest 緊急発報用のREST API
 * @param param 設定項目構造体
 * @param grepFile 発報対象判定用マスタ
 */
void runMNotice(u_char *rest, ConfigParameter_t *param, u_char *grepFile)
{

    u_char cPayload[512] = {0};
    uint32_t payLoadLen;
    MessageData_t msgData = {0};
    int32_t sendloopCount = 0;
    uint32_t i, dataCount = 0;
    int32_t ret = 0;

    u_char cbuff[NTSS_STR_MAX_SIZE] = {0};
    u_char logMessage[MAX_LOG_TEXT] = {0};
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // char *sendBodyFile = "./MNoticeBody.txt";
    // char *responseFile = "./tmpMNoticeResponseCode.txt";
    // char *errFile = "./tmpMNoticeErrResponseCode.txt";
    char *sendBodyFile = "/tmp/MNoticeBody.txt";
    char *responseFile = "/tmp/tmpMNoticeResponseCode.txt";
    char *errFile = "/tmp/tmpMNoticeErrResponseCode.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 start
    //u_char responseCode[255] = {0};
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 end
    char *pathes[3] = {
        param->receiveDataDirectory,
        param->receiveDataDirectory2,
        param->receiveDataDirectory3};
    struct stat st, statBuf;
    char buf[200];
    char findPathes[512] = {0};
    char command[512] = {0};
    u_char path[255] = {0};
    u_char pathBuff[sizeof(path) + sizeof(FileData_t)] = {0};
    FILE *fp;
    FileData_t fData = {0};
    uint8_t dataBuff[255] = {0};
    u_char filePath[sizeof(FileData_t)];
    u_char *ext = "bin";
    int findDir = 0;
	u_char rcdFilePath[NTSS_STR_MAX_SIZE] = {0};
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    int ret_fail;
    // add AWSとDEの通信断からの復旧 高 end
    
    sprintf(rcdFilePath, "%s/%s", param->mstDir, MST_RECORDS_GREP_FILE);

    // タイムスタンプ昇順で対象ファイル一覧作成
    for (i = 0; i < 3; i++)
    {
        // フォルダアクセス確認
        if (existFolderFile(pathes[i], &st) != 1)
        {
            continue;
        }
        sprintf(buf, "%s %s", findPathes, pathes[i]);
        sprintf(findPathes, "%s", buf);
        findDir = 1;
    }

    if (findDir == 0)
    {
        // フォルダアクセスなし
        LogOutput(NTSS_LOG_INFO, "アクセス可能フォルダ無し");
        return;
    }

    sprintf(command, "find %s -maxdepth 2 -type f -name \"*.%s\" | xargs --no-run-if-empty ls -rt1", findPathes, ext);
    if ((fp = popen(command, "r")) != NULL)
    {
        while (fgets(buf, NTSS_STR_MAX_SIZE, fp) != NULL)
        {
            buf[strlen(buf) - 1] = 0; // 末尾の改行コード無視
            strncpy(pathBuff, buf, sizeof(pathBuff));

            strncpy(fData.fileName, basename(buf), sizeof(fData.fileName));
            stat(pathBuff, &statBuf);
            strncpy(fData.fileDir, dirname(pathBuff), sizeof(fData.fileDir));
            fData.lastTime = statBuf.st_ctime;
            // ファイル名からtypeを取得
            fData.type = getTypeFromFileName(fData.fileName);

            sprintf(filePath, "%s/%s", fData.fileDir, fData.fileName);
            if (readBinaryFile(dataBuff, filePath) > 0)
            {
                // データを構造体に変換
                msgData = separateMessage(dataBuff, fData.type);

                //ファイル名の先頭+２３の位置から3文字を構造体のmachineTypeCodeにコピー
                strncpy(msgData.machineTypeCode, fData.fileName + 21, 3);

                // ファイルパスを記憶
                sprintf(msgData.fileDir, "%s", fData.fileDir);
                sprintf(msgData.fileName, "%s", fData.fileName);

                // 通報対象かどうかをチェック
                if (isSendTarget(&msgData, rcdFilePath))
                {
                    if (getIsDisabledCallApi())
                    {
                        // クラウド通信不可フラグがONの場合、REST APIコール失敗時と同様の処理を行う
                        // 今回は ret != 0 ならば日付フォルダへの移動が行われる
                        ret = -1;
                        snprintf(logMessage, MAX_LOG_TEXT, "緊急発報 REST API 通信不可状態のため処理スキップ");
                        LogResourceOutput(NTSS_LOG_INFO, logMessage);
                    }
                    else
                    {

                        // データを送信する形式に変換
                        payLoadLen = buildSendData(cPayload, &msgData, param);

                        // 一時ファイル作成
                        outputFile(_NTSS_M_NOTICE_TEMP_FILE, cPayload, payLoadLen);

                        // ペイロードの内容をログ出力
                        log_payload(cPayload, payLoadLen);

                        // REST送信用BODY作成
                        sprintf(
                            cbuff, "./sh/make_json_b64param.sh \"%s\" \"%s\" \"%s\" %d", "content" // key
                            ,
                            _NTSS_M_NOTICE_TEMP_FILE // value
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
                            snprintf(logMessage, MAX_LOG_TEXT, "緊急発報 REST 応答あり, (%s)", responseCode);
                        }
                        else
                        {
                            snprintf(logMessage, MAX_LOG_TEXT, "緊急発報 REST 実行システムコール応答, (%d)", ret);
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
                        
                        if (ret > 0)
                        {
                            // NOTE:クラウド通信不可フラグをON
                            setIsDisabledCallApi(true);
                        }

                        if (ret > 0 && readFileOneLine(responseCode, 255, errFile) == 0)
                        {
                            snprintf(logMessage, MAX_LOG_TEXT, "緊急発報 REST 失敗応答を取得, (%s)", responseCode);
                            LogResourceOutput(NTSS_LOG_ERROR, logMessage);
                        }
                        */
                        // RESTコールして結果を取得する
                        ret = ntss_restcall("", "", cbuff, responseFile, errFile, "緊急発報");
                        
                        if (ret != 0)
                        {
                            // NOTE:クラウド通信不可フラグをON
                            setIsDisabledCallApi(true);
                        }
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
                        //     for ( ii = 0; ii < 2; ii++ ) {
                        //         // RESTをコールする
                        //         ret_fail = comsv_fail_alive_moni_main();
                        //         if(ret_fail != 0)
                        //             continue;
                        //     }
                        //     if (ret_fail != 0) {
                        //         // 取得失敗
                        //         if (ii == 2)
                        //         {
                        //             setCommAliveState(1);
                        //             kill(getChildCaptureAppPid(), SIG_COMM_FAIL);
                        //         }
                        //     }
                        // }
                        // // add AWSとDEの通信断からの復旧 高 end
                        // #8081 del 2023.05.09 通信状態を通信SVへ通知しないようにする TDC米沢 end
                    }

                    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 start
                    // 使用したファイルの消し込み作業
                    removeFileFullPath(sendBodyFile);
                    removeFileFullPath(_NTSS_M_NOTICE_TEMP_FILE);

                    if (ret == 0)
                    {
                        // 転送成功していたらデータ収集ディレクトリに移動
                        if (moveFileToCollectDir(msgData, param))
                        {
                            // 使用したファイルの消し込み作業
                            removeFile(msgData.fileDir, msgData.fileName);
                            /*
                            removeFileFullPath(sendBodyFile);
                            removeFileFullPath(_NTSS_M_NOTICE_TEMP_FILE);
                            removeFileFullPath(responseFile);
                            removeFileFullPath(errFile);
                            */
                        }
                    }
                    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 end
                    else
                    {
                        // 転送失敗していたら日付フォルダに退避、もともと日付フォルダにあるやつはそのまま。
                        moveFileDateDir(&msgData, param);
                    }
                }
                else
                {
                    // 送信対象でないならばファイルをデータ収集フォルダに送るだけ
                    if (moveFileToCollectDir(msgData, param))
                    {
                        // 使用したファイルの消し込み作業
                        removeFile(msgData.fileDir, msgData.fileName);
                    }
                }

                // サブフォルダがからになったら削除
                removeSubDir(&msgData, param);
            }
    		// #12406 2025.12.01 add ファイルサイズが0byteの場合は削除 TDC米沢 start
            else
            {
                // 読み込みサイズが0以下の場合(読み込み失敗含む)

                // ファイル情報取得
                struct stat st;
                if(existFolderFile(filePath, &st))
                {
                    // ファイルサイズ判定
                    if(st.st_size == 0)
                    {
                        // ファイルサイズが0byteの場合
                        // 処理できないファイルなので不要

                        // ファイルの消し込み作業
                        removeFileFullPath(filePath);
                    }
                }
            }
    		// #12406 2025.12.01 add ファイルサイズが0byteの場合は削除 TDC米沢 end
        }
    }
    pclose(fp);
}

/**
 * @brief 日付フォルダに退避、もともと日付フォルダにあるやつはそのまま。
 * 
 * @param msgData 元ファイル情報
 * @param param 設定ファイル情報
 * @return true 成功
 * @return false 失敗
 */
bool moveFileDateDir(MessageData_t *msgData, ConfigParameter_t *param)
{

    if (strcmp(msgData->fileDir, param->receiveDataDirectory) != 0 &&
        strcmp(msgData->fileDir, param->receiveDataDirectory2) != 0 &&
        strcmp(msgData->fileDir, param->receiveDataDirectory3) != 0)
    {

        // すでにサブフォルダに配置されているファイルだった場合は移動しない
        return true;
    }

    char *pathes[3] = {
        param->receiveDataDirectory,
        param->receiveDataDirectory2,
        param->receiveDataDirectory3};
    time_t nowTim;
    struct tm *local;
    char nowStr[20] = {0};
    char findPathes[512] = {0};
    char buf[200] = {0};
    struct stat st;
    char baseFilePath[512] = {0};
    char moveFilePath[512] = {0};
    char outPath[255] = {0};
    u_char logMessage[MAX_LOG_TEXT] = {0};

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

    sprintf(baseFilePath, "%s/%s", msgData->fileDir, msgData->fileName);
    sprintf(moveFilePath, "%s/%s", outPath, msgData->fileName);

    if (moveFile(baseFilePath, moveFilePath, NTSS_MOVEFILE_MODE_OVERWRITE) == 1)
    {
        snprintf(logMessage, MAX_LOG_TEXT, "ファイルを移動 [%s] → [%s] ", baseFilePath, moveFilePath);
        LogOutput(NTSS_LOG_INFO, logMessage);
        return true;
    }
    else
    {
        snprintf(logMessage, MAX_LOG_TEXT, "ファイルを移動失敗 [%s] → [%s] ", baseFilePath, moveFilePath);
        LogResourceOutput(NTSS_LOG_ERROR, logMessage);
        return true;
    }
}

/**
 * @brief 日付フォルダに退避が殻になったら削除
 * 
 * @param msgData 元ファイル情報
 * @param param 設定ファイル情報
 * @return true 成功
 * @return false 失敗
 */
bool removeSubDir(MessageData_t *msgData, ConfigParameter_t *param)
{
    if (strcmp(msgData->fileDir, param->receiveDataDirectory) == 0 ||
        strcmp(msgData->fileDir, param->receiveDataDirectory2) == 0 ||
        strcmp(msgData->fileDir, param->receiveDataDirectory3) == 0)
    {

        // サブフォルダでない場合は移動しない
        return true;
    }

    if (existFolderInFiles(msgData->fileDir) == 0)
    {
        // ディレクトリが空っぽになった
        return removeFileFullPath(msgData->fileDir);
    }
    return true;
}

bool checkFileCountOver(ConfigParameter_t *param)
{

    char *pathes[6] = {
        param->collectDataDirectory,
        param->collectDataDirectory2,
        param->collectDataDirectory3,
        param->receiveDataDirectory,
        param->receiveDataDirectory2,
        param->receiveDataDirectory3};
    bool retVal = false;
    u_char logMessage[512] = {0};
    int i = 0, count = 0;
    struct stat st;

    for (i = 0; i < 6; i++)
    {
        // フォルダアクセス確認
        if (existFolderFile(pathes[i], &st) != 1)
        {
            continue;
        }
        count = getFileCount(pathes[i]);
        if (count >= param->thresholdFileCount)
        {
            // フォルダがファイル数オーバー
            retVal = true;
        }
        snprintf(logMessage, 512, "[%s]内のファイル数 [%d] ", pathes[i], count);
        LogOutput(NTSS_LOG_INFO, logMessage);
    }

    return retVal;
}

bool noticeFileCountOver(u_char *rest, ConfigParameter_t *param)
{
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // u_char *tmpFile = "./tmpNtcF.tmp";
    u_char *tmpFile = "/tmp/tmpNtcF.tmp";
    u_char cPayload[512] = {0};
    uint32_t payLoadLen;
    u_char cbuff[NTSS_STR_MAX_SIZE] = {0};
    u_char logMessage[1024] = {0};
    // char *sendBodyFile = "./tmpNtcFBody.txt";
    // char *responseFile = "./tmpNtcFRes.txt";
    // char *errFile = "./tmpNtcFErrRes.txt";
    char *sendBodyFile = "/tmp/tmpNtcFBody.txt";
    char *responseFile = "/tmp/tmpNtcFRes.txt";
    char *errFile = "/tmp/tmpNtcFErrRes.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 start
    //u_char responseCode[255] = {0};
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 end
    time_t nowTim;
    struct tm *local;
    char nowStr[20];
    int ret = false;
    // add AWSとDEの通信断からの復旧 高 start
    int ii = 0;
    int ret_fail;
    // add AWSとDEの通信断からの復旧 高 end

    LogOutput(NTSS_LOG_INFO, "ファイル数過多緊急発報処理開始");

    if (getIsDisabledCallApi())
    {
        // クラウド通信不可フラグがONの場合、REST APIコール失敗時と同様の処理を行う
        // 今回は ret != 0 ならばfalseが返る
        ret = -1;
        snprintf(logMessage, MAX_LOG_TEXT, "ファイル数過多緊急発報 REST API 通信不可状態のため処理スキップ");
        LogResourceOutput(NTSS_LOG_INFO, logMessage);
    }
    else
    {
        /* 現在時刻を取得 */
        nowTim = time(NULL);
        local = localtime(&nowTim); /* 地方時に変換 */
        // 日付フォルダ名作成
        sprintf(nowStr, "%4d%02d%02d%02d%02d%02d",
                local->tm_year + 1900, local->tm_mon + 1, local->tm_mday,
                local->tm_hour, local->tm_min, local->tm_sec);

        // 一時ファイル作成
        // [施設コード][デバイスエッジ番号(左0埋め2桁)][発生日時(YYYYMMDDHH24MISS)][装置記録コード(G000：F1、G001：F2)]
        sprintf(cPayload, "%s%02d%s%s", param->facilityCode, param->deviceNo, nowStr, "G002");
        outputFile(tmpFile, cPayload, strlen(cPayload));

        LogOutput(NTSS_LOG_INFO, "ファイル数過多緊急発報RESTコール");
        // ペイロードの内容をログ出力
        log_payload(cPayload, strlen(cPayload));

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
        /*
        // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 start
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
            snprintf(logMessage, MAX_LOG_TEXT, "ファイル数過多緊急発報 REST 応答あり, (%s)", responseCode);
        }
        else
        {
            snprintf(logMessage, MAX_LOG_TEXT, "ファイル数過多緊急発報 REST 実行システムコール応答, (%d)", ret);
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

        if (ret > 0)
        {
            // NOTE:クラウド通信不可フラグをON
            setIsDisabledCallApi(true);
        }

        if (ret > 0 && readFileOneLine(responseCode, 255, errFile) == 0)
        {
            snprintf(logMessage, MAX_LOG_TEXT, "ファイル数過多緊急発報 REST 失敗応答を取得, (%s)", responseCode);
            LogResourceOutput(NTSS_LOG_ERROR, logMessage);
        }
        */
        // RESTコールして結果を取得する
        ret = ntss_restcall("", "", cbuff, responseFile, errFile, "ファイル数過多緊急発報");

        if (ret != 0)
        {
            // NOTE:クラウド通信不可フラグをON
            setIsDisabledCallApi(true);
        }
        
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
        //     for ( ii = 0; ii < 2; ii++ ) {
        //         // RESTをコールする
        //         ret_fail = comsv_fail_alive_moni_main();
        //         if(ret_fail != 0)
        //             continue;
        //     }
        //     if (ret_fail != 0) {
        //         // 取得失敗
        //         if (ii == 2)
        //         {
        //             setCommAliveState(1);
        //             kill(getChildCaptureAppPid(), SIG_COMM_FAIL);
        //         }
        //     }
        // }
        // // add AWSとDEの通信断からの復旧 高 end
        // #8081 del 2023.05.09 通信状態を通信SVへ通知しないようにする TDC米沢 end

        // 使用したファイルの消し込み作業
        removeFileFullPath(sendBodyFile);
        removeFileFullPath(tmpFile);
        // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 end
    }

    if (ret == 0)
    {
        // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 start
        /*
        // 使用したファイルの消し込み作業
        removeFileFullPath(sendBodyFile);
        removeFileFullPath(tmpFile);
        removeFileFullPath(responseFile);
        removeFileFullPath(errFile);
        */
        // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 end
        return true;
    }
    LogOutput(NTSS_LOG_INFO, "ファイル数過多緊急発報処理終了");

    return false;
}

/**
 * @brief SD/USBへの書き込み失敗時にメール通知を行う
 * @details SD/USBへの書き込み失敗時にメール通知を行う
 * 
 * @param kind   種別[0：SD/1：USB]
 * @param rest   REST名
 * @param param　設定情報
 * @return false：通知なし(通知失敗含む)/true：通知あり
 */
bool
noticeMntMediaWriteError(int kind, u_char *rest, ConfigParameter_t *param)
{
    bool bret = false;
    u_char code[5];
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // u_char *tmpFile = "./tmpNtcMMWE.tmp";
    u_char *tmpFile = "/tmp/tmpNtcMMWE.tmp";
    u_char cPayload[512] = {0};
    uint32_t payLoadLen;
    u_char cbuff[NTSS_STR_MAX_SIZE] = {0};
    u_char logMessage[1024] = {0};
    // char *sendBodyFile = "./tmpNtcMMWEBody.txt";
    // char *responseFile = "./tmpNtcMMWERes.txt";
    // char *errFile = "./tmpNtcMMWEErrRes.txt";
    char *sendBodyFile = "/tmp/tmpNtcMMWEBody.txt";
    char *responseFile = "/tmp/tmpNtcMMWERes.txt";
    char *errFile = "/tmp/tmpNtcMMWEErrRes.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 start
    //u_char responseCode[255] = {0};
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 end
    time_t nowTim;
    struct tm *local;
    char nowStr[20];
    int ret = -1;

    // 各書き込み失敗通知ファイルチェック
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // if( kind == 0 && existFolderFile( "./unsentWriteError_sd.txt", NULL ) == 0) {
    if( kind == 0 && existFolderFile( "/tmp/unsentWriteError_sd.txt", NULL ) == 0) {
        // SD書き込み失敗通知ファイルなし
        return bret;
    }
    // if( kind == 1 && existFolderFile( "./unsentWriteError_usb.txt", NULL ) == 0) {
    if( kind == 1 && existFolderFile( "/tmp/unsentWriteError_usb.txt", NULL ) == 0) {
        // USB書き込み失敗通知ファイルなし
        return bret;
    }
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end

    // コード確定
    snprintf( code, sizeof(code), "G%03d", 4 - kind );
	// コンソール出力
	printf("%s:%s\n", "SD/USB書き込み失敗緊急発報処理", code);

    //
    snprintf(logMessage, MAX_LOG_TEXT, "SD/USB書き込み失敗緊急発報処理開始 %s", code);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getIsDisabledCallApi())
    {
        // クラウド通信不可フラグがONの場合、REST APIコール失敗時と同様の処理を行う
        // 今回は ret != 0 ならばfalseが返る
        snprintf(logMessage, MAX_LOG_TEXT, "SD/USB書き込み失敗緊急発報 %s REST API 通信不可状態のため処理スキップ", code);
        LogResourceOutput(NTSS_LOG_INFO, logMessage);
    }
    else
    {
        /* 現在時刻を取得 */
        nowTim = time(NULL);
        local = localtime(&nowTim); /* 地方時に変換 */
        // 日付フォルダ名作成
        sprintf(nowStr, "%4d%02d%02d%02d%02d%02d",
                local->tm_year + 1900, local->tm_mon + 1, local->tm_mday,
                local->tm_hour, local->tm_min, local->tm_sec);

        // 一時ファイル作成
        // [施設コード][デバイスエッジ番号(左0埋め2桁)][発生日時(YYYYMMDDHH24MISS)][装置記録コード]
        sprintf(cPayload, "%s%02d%s%s", param->facilityCode, param->deviceNo, nowStr, code);
        outputFile(tmpFile, cPayload, strlen(cPayload));

        snprintf(logMessage, MAX_LOG_TEXT, "SD/USB書き込み失敗緊急発報 %s RESTコール", code);
        LogOutput(NTSS_LOG_INFO, logMessage);
        // ペイロードの内容をログ出力
        log_payload(cPayload, strlen(cPayload));

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
            snprintf(logMessage, MAX_LOG_TEXT, "SD/USB書き込み失敗緊急発報 %s REST 応答あり, (%s)", code, responseCode);
        }
        else
        {
            snprintf(logMessage, MAX_LOG_TEXT, "SD/USB書き込み失敗緊急発報 %s REST 実行システムコール応答, (%d)", code, ret);
        }
        LogOutput(NTSS_LOG_INFO, logMessage);

        // 終了コード作成
        if (0 < ret)
        {
            // 成功系
            if (200 == ret)
            {
                ret = 0;

                // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
                // 通知ファイル名変更
                if ( kind == 0 ) {
                    // SD書き込み失敗通知ファイルを通知済みに変更
                    // rename( "./unsentWriteError_sd.txt", "./sentWriteError_sd.txt" );
                    // LogOutput(NTSS_LOG_INFO, "SD/USB書き込み失敗緊急発報 %s 通知完了, ./unsentWriteError_sd.txt→./sentWriteError_sd.txt");
                    rename( "/tmp/unsentWriteError_sd.txt", "/tmp/sentWriteError_sd.txt" );
                    LogOutput(NTSS_LOG_INFO, "SD/USB書き込み失敗緊急発報 %s 通知完了, /tmp/unsentWriteError_sd.txt→/tmp/sentWriteError_sd.txt");
                }
                if ( kind == 1 ) {
                    // USB書き込み失敗通知ファイルを通知済みに変更
                    // rename( "./unsentWriteError_usb.txt", "./sentWriteError_usb.txt" );
                    // LogOutput(NTSS_LOG_INFO, "SD/USB書き込み失敗緊急発報 %s 通知完了, ./unsentWriteError_usb.txt→./sentWriteError_usb.txt");
                    rename( "/tmp/unsentWriteError_usb.txt", "/tmp/sentWriteError_usb.txt" );
                    LogOutput(NTSS_LOG_INFO, "SD/USB書き込み失敗緊急発報 %s 通知完了, /tmp/unsentWriteError_usb.txt→/tmp/sentWriteError_usb.txt");
                }
                // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
                bret = true;
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

        if (ret > 0)
        {
            // NOTE:クラウド通信不可フラグをON
            setIsDisabledCallApi(true);
        }

        if (ret > 0 && readFileOneLine(responseCode, 255, errFile) == 0)
        {
            snprintf(logMessage, MAX_LOG_TEXT, "SD/USB書き込み失敗緊急発報 %s REST 失敗応答を取得, (%s)", code, responseCode);
            LogResourceOutput(NTSS_LOG_ERROR, logMessage);
        }
        */
        // RESTコールして結果を取得する
        ret = ntss_restcall("", "", cbuff, responseFile, errFile, "SD/USB書き込み失敗緊急発報");

        if (ret == 0)
        {
            // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
            // 通知ファイル名変更
            if ( kind == 0 ) {
                // SD書き込み失敗通知ファイルを通知済みに変更
                // rename( "./unsentWriteError_sd.txt", "./sentWriteError_sd.txt" );
                // LogOutput(NTSS_LOG_INFO, "SD/USB書き込み失敗緊急発報 %s 通知完了, ./unsentWriteError_sd.txt→./sentWriteError_sd.txt");
                rename( "/tmp/unsentWriteError_sd.txt", "/tmp/sentWriteError_sd.txt" );
                LogOutput(NTSS_LOG_INFO, "SD/USB書き込み失敗緊急発報 %s 通知完了, /tmp/unsentWriteError_sd.txt→/tmp/sentWriteError_sd.txt");
            }
            if ( kind == 1 ) {
                // USB書き込み失敗通知ファイルを通知済みに変更
                // rename( "./unsentWriteError_usb.txt", "./sentWriteError_usb.txt" );
                // LogOutput(NTSS_LOG_INFO, "SD/USB書き込み失敗緊急発報 %s 通知完了, ./unsentWriteError_usb.txt→./sentWriteError_usb.txt");
                rename( "/tmp/unsentWriteError_usb.txt", "/tmp/sentWriteError_usb.txt" );
                LogOutput(NTSS_LOG_INFO, "SD/USB書き込み失敗緊急発報 %s 通知完了, /tmp/unsentWriteError_usb.txt→/tmp/sentWriteError_usb.txt");
            }
            // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
            bret = true;
        }
        else
        {
            // NOTE:クラウド通信不可フラグをON
            setIsDisabledCallApi(true);
        }
        // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 end
    }

    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 start
    // ファイルの消し込み作業
    removeFileFullPath(sendBodyFile);
    removeFileFullPath(tmpFile);
    /*
    // 処理スキップ以外の場合に使用したファイルの消し込み作業
    if ( 0 <= ret  ) {
        removeFileFullPath(sendBodyFile);
        removeFileFullPath(tmpFile);
        removeFileFullPath(responseFile);
        removeFileFullPath(errFile);
    }
    */
    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 end

    snprintf(logMessage, MAX_LOG_TEXT, "SD/USB書き込み失敗緊急発報処理終了 %s", code);
    LogOutput(NTSS_LOG_INFO, logMessage);

    return bret;
}
