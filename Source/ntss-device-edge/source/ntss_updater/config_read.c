#include "config_read.h"

#define CONFIG_TAG_COUNT            100

#define TAG_CONNECT_HOST                "AWS_HOST"
#define TAG_WS_CONNECT_HOST             "WEBSOCKET_HOST"
#define TAG_FACILITY_CODE               "FACILITY_CODE"
#define TAG_MASTER_FOLDER               "MASTER_FOLDER"
#define TAG_DEVICE_NO                   "AWS_IOT_DEVICE_NO"
#define TAG_ZIP_PASSWORD                "ZIP_PW"
#define TAG_DL_FOLDER_1                 "DL_FOLDER1"
#define TAG_DL_FOLDER_2                 "DL_FOLDER2"
#define TAG_DL_FOLDER_3                 "DL_FOLDER3"
#define TAG_CONF_S3_PATH                "UPLOAD_PATH"
#define TAG_UPLOAD_RETRY_COUNT          "UPLOAD_RETRY_COUNT"
#define TAG_UPLOAD_RETRY_WAIT_TIME      "UPLOAD_RETRY_WAIT_TIME"
#define TAG_UPLOAD_FILE_MAXSIZE         "UPLOAD_FILE_MAXSIZE"
#define TAG_WS_KEEP_ALIVE_INTERVAL      "WEBSOCKET_KEEP_ALIVE_INTERVAL" 

#define STR_MAX 256

ConfigParameter_t configParameter;

ConfigParameter_t getConfigParameter()
{
    return configParameter;
}

/**
 * @brief 設定ファイルの内容を取得
 * 
 * @param configFileName 
 * @param configData 
 * @return int32_t 
 */
uint32_t readConfigFile(const char *configFileName)
{

    ConfigData_t configData[CONFIG_TAG_COUNT] = {0};
    u_char logMessage[MAX_LOG_TEXT] = {0};

    if (readConfigDataFile(configFileName, configData, CONFIG_TAG_COUNT) < 0)
    {
        return -1;
    }

    // 設定ファイルの値を構造体にセットする

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_FACILITY_CODE) != NULL)
    {
        strncpy(configParameter.facilityCode, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_FACILITY_CODE), sizeof(configParameter.facilityCode));
    }
    sprintf(logMessage, "%s : %s", TAG_FACILITY_CODE, configParameter.facilityCode);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_DEVICE_NO) != NULL)
    {
        configParameter.deviceNo = atoi(getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_DEVICE_NO));
    }
    sprintf(logMessage, "%s : %d", TAG_DEVICE_NO, configParameter.deviceNo);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_CONNECT_HOST) != NULL)
    {
        strncpy(configParameter.awsHostUrl, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_CONNECT_HOST), sizeof(configParameter.awsHostUrl));
    }
    sprintf(logMessage, "%s : %s", TAG_CONNECT_HOST, configParameter.awsHostUrl);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_WS_CONNECT_HOST) != NULL)
    {
        strncpy(configParameter.websockHostUrl, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_WS_CONNECT_HOST), sizeof(configParameter.websockHostUrl));
    }
    sprintf(logMessage, "%s : %s", TAG_WS_CONNECT_HOST, configParameter.websockHostUrl);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_ZIP_PASSWORD) != NULL)
    {
        strncpy(configParameter.zipPassword, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_ZIP_PASSWORD), sizeof(configParameter.zipPassword));
    }
    sprintf(logMessage, "%s : %s", TAG_ZIP_PASSWORD, configParameter.zipPassword);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_DL_FOLDER_1) != NULL)
    {
        strncpy(configParameter.dlFolder[0], getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_DL_FOLDER_1), sizeof(configParameter.dlFolder[0]));
        // 末尾に'/'追加
        addFolderSeparator(configParameter.dlFolder[0]);
    }
    sprintf(logMessage, "%s : %s", TAG_DL_FOLDER_1, configParameter.dlFolder[0]);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_DL_FOLDER_2) != NULL)
    {
        strncpy(configParameter.dlFolder[1], getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_DL_FOLDER_2), sizeof(configParameter.dlFolder[1]));
        // 末尾に'/'追加
        addFolderSeparator(configParameter.dlFolder[1]);
    }
    sprintf(logMessage, "%s : %s", TAG_DL_FOLDER_2, configParameter.dlFolder[1]);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_DL_FOLDER_3) != NULL)
    {
        strncpy(configParameter.dlFolder[2], getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_DL_FOLDER_3), sizeof(configParameter.dlFolder[2]));
        // 末尾に'/'追加
        addFolderSeparator(configParameter.dlFolder[2]);
    }
    sprintf(logMessage, "%s : %s", TAG_DL_FOLDER_3, configParameter.dlFolder[2]);
    LogOutput(NTSS_LOG_INFO, logMessage);

    return 0;
}

/**
 * @brief 設定ファイルの内容を取得
 * 
 * @param configFileName 
 * @param configData 
 * @return int32_t 
 */
uint32_t readConfigNetworkFile(const char *configFileName)
{

    ConfigData_t configData[CONFIG_TAG_COUNT] = {0};
    u_char logMessage[MAX_LOG_TEXT] = {0};

    if (readConfigDataFile(configFileName, configData, CONFIG_TAG_COUNT) < 0)
    {
        return -1;
    }

    // 設定ファイルの値を構造体にセットする

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_CONNECT_HOST) != NULL)
    {
        strncpy(configParameter.awsHostUrl, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_CONNECT_HOST), sizeof(configParameter.awsHostUrl));
    }
    sprintf(logMessage, "%s : %s", TAG_CONNECT_HOST, configParameter.awsHostUrl);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_WS_CONNECT_HOST) != NULL)
    {
        strncpy(configParameter.websockHostUrl, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_WS_CONNECT_HOST), sizeof(configParameter.websockHostUrl));
    }
    sprintf(logMessage, "%s : %s", TAG_WS_CONNECT_HOST, configParameter.websockHostUrl);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_ZIP_PASSWORD) != NULL)
    {
        strncpy(configParameter.zipPassword, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_ZIP_PASSWORD), sizeof(configParameter.zipPassword));
    }
    sprintf(logMessage, "%s : %s", TAG_ZIP_PASSWORD, configParameter.zipPassword);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_CONF_S3_PATH) != NULL)
    {
        strncpy(configParameter.uploadConfS3Path, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_CONF_S3_PATH), sizeof(configParameter.uploadConfS3Path));
    }
    sprintf(logMessage, "%s : %s", TAG_CONF_S3_PATH, configParameter.uploadConfS3Path);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_UPLOAD_RETRY_COUNT) != NULL)
    {
        configParameter.nUploadRetryCount = atoi(getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_UPLOAD_RETRY_COUNT));
    }
    else
    {
        configParameter.nUploadRetryCount = 3;
    }
    sprintf(logMessage, "%s : %d", TAG_UPLOAD_RETRY_COUNT, configParameter.nUploadRetryCount);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_UPLOAD_RETRY_WAIT_TIME) != NULL)
    {
        configParameter.nUploadRetryWaitTime = atoi(getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_UPLOAD_RETRY_WAIT_TIME));
    }
    else
    {
        configParameter.nUploadRetryWaitTime = 15;
    }
    sprintf(logMessage, "%s : %d", TAG_UPLOAD_RETRY_WAIT_TIME, configParameter.nUploadRetryWaitTime);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_UPLOAD_FILE_MAXSIZE) != NULL)
    {
        configParameter.uploadLimitFileSize = atoi(getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_UPLOAD_FILE_MAXSIZE));
    }
    else
    {
        configParameter.uploadLimitFileSize = 80;
    }
    sprintf(logMessage, "%s : %d", TAG_UPLOAD_FILE_MAXSIZE, configParameter.uploadLimitFileSize);
    LogOutput(NTSS_LOG_INFO, logMessage);

    // 2019.03.05以下追加 WebSocketのKeepAliveを設定とする
    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_WS_KEEP_ALIVE_INTERVAL) != NULL)
    {
        configParameter.webSocketKeepAliveInterval = atoi(getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_WS_KEEP_ALIVE_INTERVAL));
        sprintf(logMessage, "%s : %d", TAG_WS_KEEP_ALIVE_INTERVAL, configParameter.webSocketKeepAliveInterval);
    }
    else
    {
        configParameter.webSocketKeepAliveInterval = 120;
        sprintf(logMessage, "%s : 120(初期値)", TAG_WS_KEEP_ALIVE_INTERVAL);
    }
    LogOutput(NTSS_LOG_INFO, logMessage);

    return 0;
}
