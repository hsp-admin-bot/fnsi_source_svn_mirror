
#include "ntss_version.h"

/**
 * @brief バージョン情報をサーバーに通知
 * 
 * @return true 成功
 * @return false 失敗
 */
uint8_t versionPost()
{
    FILE *fp1;
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    unsigned char command[512] = {0};
    unsigned char name[512] = {0};
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // u_char *versionFileList = "../versionFileList.list";
    unsigned char *versionFileList = "/tmp/versionFileList.list";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    uint8_t ret = 1;
    FILE *fin;
    unsigned char msg[256] = {0};
    unsigned char buff[MAX_DATASIZE] = {0};
    unsigned char parameter[MAX_DATASIZE] = {0};

    sprintf(command, "find ./version/ -type f > %s", versionFileList);
    int res = system(command);
    if (WIFEXITED(res))
    {
        // 正常終了
        if (0 == WEXITSTATUS(res))
        {
            // コマンド正常終了
            snprintf(logMessage, MAX_LOG_TEXT, "バージョンファイル一覧取得成功 (%d) ./version/ > %s", res, versionFileList);
            LogOutput(NTSS_LOG_INFO, logMessage);

            // ファイル一覧オープン
            fp1 = fopen(versionFileList, "r");
            if (fp1 != NULL)
            {
                for (;;)
                {
                    memset(name, 0, sizeof(name));
                    if (fgets(name, sizeof(name), fp1) == NULL)
                    {
                        break;
                    }
                    name[strlen(name) - 1] = 0;

                    if ((fin = fopen(name, "r")) == NULL)
                    {
                        sprintf(msg, "ファイルを開けません:[%s]", name);
                        LogResourceOutput(NTSS_LOG_ERROR, msg);
                        ret = 0;
                        break;
                    }
                    for (;;)
                    {
                        if (fgets(buff, MAX_DATASIZE, fin) == NULL)
                        {
                            /* EOF */
                            break;
                        }
                        removeLastLf(buff);
                        strncat(parameter, buff, MAX_DATASIZE - strlen(buff));
                        strncat(parameter, "<LF>", MAX_DATASIZE - strlen("<LF>"));
                    }
                    fclose(fin);
                    strncat(parameter, "<LF>", MAX_DATASIZE - strlen("<LF>"));
                }
                fclose(fp1);
            }
            remove(versionFileList);

            return callVersionPostApi(parameter);
        }
    }
    snprintf(logMessage, MAX_LOG_TEXT, "バージョンファイル一覧取得失敗 (%d) ./version/ > %s", res, versionFileList);
    LogResourceOutput(NTSS_LOG_ERROR, logMessage);

    return 0;
}
/**
 * @brief 実際にPOST処理を行う
 * 
 * @param message メッセージ（バージョンファイル内の文字列）
 * @return true 成功
 * @return false 失敗
 */
uint8_t callVersionPostApi(unsigned char *message)
{
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // u_char *sendBodyFile = "./tmpVerBody.txt";
    unsigned char *sendBodyFile = "/tmp/tmpVerBody.txt";
    unsigned char cBuff[NTSS_STR_MAX_SIZE * 2] = {0};
    unsigned char logMessage[MAX_LOG_TEXT] = {0};
    unsigned char outFile[100];
    int ret;
    // u_char *responseFile = "./tmpVerResponseCode.txt";
    // u_char *errFile = "./tmpVerErrResponseCode.txt";
    unsigned char *responseFile = "/tmp/tmpVerResponseCode.txt";
    unsigned char *errFile = "/tmp/tmpVerErrResponseCode.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    unsigned char responseCode[255] = {0};
    unsigned char rest[512] = {0};
    unsigned char cPayload[MAX_DATASIZE + 128] = {0};
    ConfigParameter_t conf = getConfigParameter();

    sprintf(rest, "%s/%s", conf.awsHostUrl, API_VERSION_NOTICE);

    sprintf(cPayload, "\"facilityCd\": \"%s\", \"deviceEdgeNo\":%d, \"content\":\"%s\"", conf.facilityCode, conf.deviceNo, message);

    // 一時ファイル作成
    outputFile(sendBodyFile, cPayload, strlen(cPayload));

    // ペイロードの内容をログ出力
    snprintf(logMessage, MAX_LOG_TEXT, "バージョン通知(%s)", cPayload);
    LogOutput(NTSS_LOG_INFO, logMessage);

    // RESTをコールする
    sprintf(
        cBuff, "./sh/post_b64.sh \"%s\" \"%s\" \"%s\" \"%s\"", rest, sendBodyFile, responseFile, errFile);
    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 start
    /*
    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    ret = system(cBuff);

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
    // #12003 2025.07.25 add 通信不可フラグを参照しないREST API呼び出しを可能とする TDC片口 start
    // ret = ntss_restcall("", "", cBuff, responseFile, errFile, "バージョン通知");
    ret = ntss_restcall_force_ex("", "", cBuff, responseFile, errFile, "バージョン通知", 3, 5, false);
    // #12003 2025.07.25 add 通信不可フラグを参照しないREST API呼び出しを可能とする TDC片口 end

    // 使用したファイルの消し込み作業
    removeFileFullPath(sendBodyFile);

    if (ret == 0)
    {
        /*
        // 使用したファイルの消し込み作業
        removeFileFullPath(sendBodyFile);
        removeFileFullPath(responseFile);
        removeFileFullPath(errFile);
        */
        return true;
    }
    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 end
    return false;
}

// #8729 2023.05.29 add RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
/**
 * @brief 対象文字列の末尾の改行コードを削除
 * 
 * @param targetStr 対象文字列
 */
void removeLastLf(unsigned char *targetStr)
{
    if (strlen(targetStr) > 0)
    {
        // 余計な改行コード削除
        if (targetStr[strlen(targetStr) - 1] == '\n')
        {
            targetStr[strlen(targetStr) - 1] = '\0';
        }
    }
}
// #8729 2023.05.29 add RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
