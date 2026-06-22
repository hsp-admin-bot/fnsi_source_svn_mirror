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

#include "ntss_host_watch_notification.h"
#include "config_read.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
//#include "ntss_file.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
#include "ntss_m_notice.h"
#include "../common/nkklib/nkklib.h"
#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/ntss_etc_lib.h"


/**
 * @brief データを送信する形式に変換
 * 
 * @param cPayload      格納先バッファ
 * @param param         設定ファイル情報
 * @param fileName      通知ファイル名(ALART_{型式[3桁]}_{製造番号[7〜8桁]}_{通信方式[1桁]}_{フォーマット/機種[1桁]}_{発生年月日時分秒+マイクロ秒6桁}.txt)
 * @param content       通知内容(モニタ項目番号[0〜：3桁]:通知コード[HEX2桁]...)
 * @return 変換したデータサイズ
 */
uint32_t
buildHostWatchNoticeSendData( u_char *cPayload
                            , ConfigParameter_t *param
                            , u_char *fileName
                            , u_char *content
                            )
{
    u_char type[4];
    u_char serialNo[9];
    u_char format;
    u_char occurDate[15];
    char *p = strstr( fileName, "_" );

    memset( type, 0, sizeof( type ));
    memset( serialNo, 0, sizeof( serialNo ));
    memset( occurDate, 0, sizeof( occurDate ));

    // 型式
    if( p != NULL )
    {
        p++;
        strncpy( type, p, sizeof( type ) - 1 );
    }
    // 製造番号
    p = strstr( p, "_" );
    if( p != NULL )
    {
        p++;
        strncpy( serialNo, p, sizeof( serialNo ) - 1 );
        if( serialNo[7] == '_' )
        {
            serialNo[7] = 0;
        }
    }
    // 通信方式
    p = strstr( p, "_" );
    if( p != NULL )
    {
        p++;
    }
    //　フォーマット
    p = strstr( p, "_" );
    if( p != NULL )
    {
        p++;
        format = *p;
    }
    // 発生日時
    p = strstr( p, "_" );
    if( p != NULL )
    {
        p++;
        strncpy( occurDate, p, sizeof( occurDate ) - 1 );
    }

    // 通知データ作成
    // "occurDate":"20201223155631",
    // "facilityCd": "999900",
    // "deviceEdgeNo": 1,
    // "machineTypeCd": "071",
    // "comFormatCd": "F",
    // "machineSerial": "TDC0002",
    // "content": "090:01080:02102:03"
    return sprintf(
          cPayload
        , "\"occurDate\":\"%s\", \"facilityCd\":\"%s\", \"deviceEdgeNo\":%d, \"machineTypeCd\":\"%s\", \"comFormatCd\":\"%c\", \"machineSerial\":\"%s\", \"content\":\"%s\""
        , occurDate
        , param->facilityCode
        , param->deviceNo
        , type
        , format
        , serialNo
        , content
    );
}

/**
 * @brief ホスト報知通知内容をログ出力
 * 
 * @param cPayload 
 * @param payLoadLen 
 */
void logHostWatchNotice(u_char *cPayload, uint32_t payLoadLen)
{

    int16_t payloadLoopCount = 0;
    u_char payloadHex[MAX_LOG_TEXT] = {0}, logMessage[MAX_LOG_TEXT] = {0};

    snprintf(logMessage, MAX_LOG_TEXT, "ホスト報知通知内容: %s ", cPayload);
    LogOutput(NTSS_LOG_INFO, logMessage);
}


/**
 * @brief ホスト報知通知用ファイルを読み込み、通知を行う
 * 
 * @param param 設定項目構造体
 * @param rest  通知用REST-API
 * 
 * @return なし
 */
void
runHostWatchNotice(ConfigParameter_t *param, u_char *rest)
{
    u_char cPayload[NTSS_STR_MAX_SIZE * 2];
    uint32_t payLoadLen;
    int32_t ret = 0;

    u_char cbuff[NTSS_STR_MAX_SIZE];
    u_char logMessage[MAX_LOG_TEXT];
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // char *sendBodyFile = "./HostWatchNoticeBody.txt";
    // char *responseFile = "./tmpHostWatchNoticeResponseCode.txt";
    // char *errFile = "./tmpHostWatchNoticeErrResponseCode.txt";
    char *sendBodyFile = "/tmp/HostWatchNoticeBody.txt";
    char *responseFile = "/tmp/tmpHostWatchNoticeResponseCode.txt";
    char *errFile = "/tmp/tmpHostWatchNoticeErrResponseCode.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 start
    //u_char responseCode[NTSS_STR_MAX_SIZE];
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 end
    char *pathes[3] = {
        param->receiveDataDirectory,
        param->receiveDataDirectory2,
        param->receiveDataDirectory3};
    struct stat st, statBuf;
    char buf[NTSS_STR_MAX_SIZE];
    char findPathes[NTSS_STR_MAX_SIZE * 2] = { 0 };
    char command[NTSS_STR_MAX_SIZE * 2];
    u_char path[NTSS_STR_MAX_SIZE];
    u_char pathBuff[NTSS_STR_MAX_SIZE];
    FILE *fp;
    MessageData_t msgData;
    uint8_t dataBuff[NTSS_STR_MAX_SIZE];
    u_char filePath[sizeof(FileData_t)];
    u_char *patternFile = "ALART_*.TXT";
    int findDir = 0;
    int i;

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
        LogOutput(NTSS_LOG_INFO, "ホスト報知通知 アクセス可能フォルダ無し");
        return;
    }

    // REST作成

    sprintf(command, "find %s -maxdepth 2 -type f -name \"%s\" | xargs --no-run-if-empty ls -rt1", findPathes, patternFile);
    if ((fp = popen(command, "r")) != NULL)
    {
        while (fgets(buf, NTSS_STR_MAX_SIZE, fp) != NULL)
        {
            buf[strlen(buf) - 1] = 0; // 末尾の改行コード無視
            strncpy(pathBuff, buf, sizeof(pathBuff));

            // ファイル名とフォルダの切り出し
            memset( &msgData, 0, sizeof(buf));
            strncpy(msgData.fileName, basename(buf), sizeof(msgData.fileName) - 1);
            strncpy(msgData.fileDir, dirname(buf), sizeof(msgData.fileDir) - 1);

            // 通知対象ファイルを読み込み
            if (readFileOneLine(dataBuff, sizeof(dataBuff), pathBuff) == 0)
            {
                // 通知可能判定
                if (getIsDisabledCallApi())
                {
                    // クラウド通信不可フラグがONの場合、REST APIコール失敗時と同様の処理を行う
                    // 今回は ret != 0 ならば日付フォルダへの移動が行われる
                    ret = -1;
                    snprintf(logMessage, MAX_LOG_TEXT, "ホスト報知通知 REST API 通信不可状態のため処理スキップ");
                    LogResourceOutput(NTSS_LOG_INFO, logMessage);
                }
                else
                {

                    // データを送信する形式に変換
                    payLoadLen = buildHostWatchNoticeSendData(cPayload, param, msgData.fileName, dataBuff);

                    // 一時ファイル作成
                    outputFile(sendBodyFile, cPayload, payLoadLen);

                    // ホスト報知通知内容をログ出力
                    logHostWatchNotice(cPayload, payLoadLen);

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
                        snprintf(logMessage, MAX_LOG_TEXT, "ホスト報知通知 REST 応答あり, (%s)", responseCode);
                    }
                    else
                    {
                        snprintf(logMessage, MAX_LOG_TEXT, "ホスト報知通知 REST 実行システムコール応答, (%d)", ret);
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
                        snprintf(logMessage, MAX_LOG_TEXT, "ホスト報知通知 REST 失敗応答を取得, (%s)", responseCode);
                        LogResourceOutput(NTSS_LOG_ERROR, logMessage);
                    }
                    */
                    // RESTコールして結果を取得する
                    ret = ntss_restcall("", "", cbuff, responseFile, errFile, "ホスト報知通知");

                    // 作業用ファイル削除
                    removeFileFullPath(sendBodyFile);
                    //removeFileFullPath(responseFile);
                    //removeFileFullPath(errFile);
                    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 end
                }

                // 通知結果判定
                if (ret == 0)
                {
                    // 通知成功

                    // 通知対象ファイルの削除
                    removeFileFullPath(pathBuff);
                }
                else
                {
                    // 通知失敗

                    // 転送失敗していたら日付フォルダに退避、もともと日付フォルダにあるやつはそのまま。

                    moveFileDateDir(&msgData, param);
                }

                // サブフォルダがからになったら削除
                removeSubDir(&msgData, param);
            }
        }
    }
    pclose(fp);
}

/**
* @brief ホスト報知通知処理(スレッド)
*
* @details ホスト報知通知処理を行う
* 
* @param ptr ポインタ
* @description
* @return なし
* @attention 特になし
*/
void *
hostWatchNoticeThread(void *ptr)
{
	ThreadParameter_t *state = (ThreadParameter_t *)ptr;

	LogOutput(NTSS_LOG_INFO, "ホスト報知通知スレッド開始");

	// 1000ms
	struct timespec timeReqSleep = {1, 0};

    // REST-API
	u_char restHostWatchNotice[NTSS_STR_MAX_SIZE * 2];
	sprintf(restHostWatchNotice, "%s/%s", state->configParam.awsHostUrl, API_HOST_WATCH_NOTICE);

    //
	while (state->isRunning)
	{
		// sleep
		nanosleep(&timeReqSleep, NULL);

        // ホスト報知通知
        runHostWatchNotice(&(state->configParam), restHostWatchNotice);
	}

	LogOutput(NTSS_LOG_INFO, "ホスト報知通知スレッド終了");
}
