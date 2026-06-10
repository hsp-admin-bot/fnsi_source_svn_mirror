#include <stdio.h>
#include <string.h>
#include "ntss_data_collect_builder.h"

/**
 * @brief データ収集命令のレスポンス電文を作成
 * 
 * @param sendData 
 * @param noticeParams 
 * @param configParam 
 * @return int32_t 
 */
int32_t buildSendDataCollectRes(u_char *sendData, RcvCollectNotice_t *noticeParams, int16_t deviceNo)
{

    sprintf(sendData, "%s_%d_%d", noticeParams->manageNo, deviceNo, 1);

    return strlen(sendData);
}

/**
 * @brief データ収集プロセスの結果を送信するペイロードの作成
 * 
 * @param sendData 
 * @param noticeParams 
 * @param deviceNo 
 * @return int32_t 
 */
int32_t buildSendDataCollectResult(u_char *sendData, RcvCollectNotice_t *noticeParams, int16_t deviceNo)
{
    u_char resultData[20480] = {0};
    u_char resultFileName[53] = {0};
    sprintf(resultFileName, RESULT_FILE_CONTENT, noticeParams->manageNo);
    readFileOneLine(resultData, 20480, resultFileName);

    sprintf(sendData, "%s_%d_%s", noticeParams->manageNo, deviceNo, resultData);

    return strlen(sendData);
}

/**
 * @brief データ収集アップロード処理結果ファイルの削除
 * 
 * @param noticeParams 
 * @return true 
 * @return false 
 */
bool deleteDataCollectResultFile(RcvCollectNotice_t *noticeParams)
{
    u_char resultFileContent[128] = {0};
    u_char resultFileName[128] = {0};
    u_char resultFilePath[128] = {0};
    sprintf(resultFileContent, RESULT_FILE_CONTENT, noticeParams->manageNo);
    sprintf(resultFileName, RESULT_FILE_FILENAME, noticeParams->manageNo);
    sprintf(resultFilePath, RESULT_FILE_FILEPATH, noticeParams->manageNo);

    return removeFileFullPath(resultFileContent) && removeFileFullPath(resultFileName) && removeFileFullPath(resultFilePath);
}

/**
 * @brief FTP収集処理結果ファイルの削除
 * 
 * @return true 
 * @return false 
 */
bool deleteFtpCollectResultFile()
{
    return removeFileFullPath(RESULT_FTP_SCHEDULE_FILE);
}