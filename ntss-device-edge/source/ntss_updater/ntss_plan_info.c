
#include "ntss_plan_info.h"

/**
 * @brief 実際にPOST処理を行う
 * 
 * @param message メッセージ（バージョンファイル内の文字列）
 * @return true 成功
 * @return false 失敗
 */
uint8_t callPlanInfoPostApi(u_char *seqNo, u_char *planDate)
{
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // u_char *sendBodyFile = "./tmpPlanBody.txt";
    u_char *sendBodyFile = "/tmp/tmpPlanBody.txt";
    u_char cBuff[NTSS_STR_MAX_SIZE * 2] = {0};
    u_char logMessage[MAX_LOG_TEXT] = {0};
    u_char outFile[100];
    int ret;
    // u_char *responseFile = "./tmpPlanResponseCode.txt";
    // u_char *errFile = "./tmpPlanErrResponseCode.txt";
    u_char *responseFile = "/tmp/tmpPlanResponseCode.txt";
    u_char *errFile = "/tmp/tmpPlanErrResponseCode.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    u_char responseCode[255] = {0};
    u_char rest[512] = {0};
    u_char cPayload[MAX_DATASIZE + 128] = {0};
    ConfigParameter_t conf = getConfigParameter();

    sprintf(rest, "%s/%s", conf.awsHostUrl, API_PLAN_UPDATE);

    sprintf(cPayload, "\"facilityCd\": \"%s\", \"deviceEdgeNo\":%d, \"seqNo\":\"%s\", \"planDate\":\"%s\"", conf.facilityCode, conf.deviceNo, seqNo, planDate);

    // 一時ファイル作成
    outputFile(sendBodyFile, cPayload, strlen(cPayload));

    // ペイロードの内容をログ出力
    snprintf(logMessage, MAX_LOG_TEXT, "予定情報通知(%s)", cPayload);
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
    // ret = ntss_restcall("", "", cBuff, responseFile, errFile, "予定情報通知");
    ret = ntss_restcall_force_ex("", "", cBuff, responseFile, errFile, "予定情報通知", 3, 5, false);
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
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 start
    return false;
}
