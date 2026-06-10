#include <strings.h>
#include "config_read.h"

#define CONFIG_TAG_COUNT            100

#define TAG_CONNECT_HOST                "AWS_HOST"
#define TAG_WS_CONNECT_HOST             "WEBSOCKET_HOST"
#define TAG_MONI_UPLOAD_INTERVAL        "AWS_MONI_UPLOAD_INTERVAL"
#define TAG_RECEIVE_DATA_DIRECTORY      "M_NOTICE_FOLDER1"
#define TAG_RECEIVE_DATA_DIRECTORY_2    "M_NOTICE_FOLDER2"
#define TAG_RECEIVE_DATA_DIRECTORY_3    "M_NOTICE_FOLDER3"
#define TAG_COLLECT_DATA_DIRECTORY      "DATA_COLLECT_FOLDER1"
#define TAG_COLLECT_DATA_DIRECTORY_2    "DATA_COLLECT_FOLDER2"
#define TAG_COLLECT_DATA_DIRECTORY_3    "DATA_COLLECT_FOLDER3"
// #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 start
#define TAG_COMM_FAIL_DIRECTORY         "COMM_FAIL_FOLDER"      /// TAG:通信異常時ファイル格納先フォルダ
// #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 end
#define TAG_TEMP_DIRECTORY              "TEMP_FOLDER1"
#define TAG_TEMP_DIRECTORY_2            "TEMP_FOLDER2"
#define TAG_TEMP_DIRECTORY_3            "TEMP_FOLDER3"
#define TAG_FACILITY_CODE               "FACILITY_CODE"
#define TAG_COLLECT_APP                 "COLLECT_APP"
#define TAG_MASTER_FOLDER               "MASTER_FOLDER"
#define TAG_UPLOAD_APP                  "UPLOAD_APP"
#define TAG_DEVICE_NO                   "AWS_IOT_DEVICE_NO"
#define TAG_FTP_SCHEDULE                "FTP_SCHEDULE"
#define TAG_THRESHOLD_FILE_COUNT        "THRESHOLD_FILE_COUNT"
#define TAG_WS_KEEP_ALIVE_INTERVAL      "WEBSOCKET_KEEP_ALIVE_INTERVAL" 
#define TAG_COMM_PERMISSION_WAIT_TIME   "COMM_PERMISSON_WAIT_TIME" 

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

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_MONI_UPLOAD_INTERVAL) != NULL)
    {
        configParameter.awsMoniUploadInterval = atoi(getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_MONI_UPLOAD_INTERVAL));
    }
    sprintf(logMessage, "%s : %d", TAG_MONI_UPLOAD_INTERVAL, configParameter.awsMoniUploadInterval);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_COLLECT_APP) != NULL)
    {
        strncpy(configParameter.collectApp, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_COLLECT_APP), sizeof(configParameter.collectApp));
    }
    sprintf(logMessage, "%s : %s", TAG_COLLECT_APP, configParameter.collectApp);
    LogOutput(NTSS_LOG_INFO, logMessage);

    // #8730 2023.05.23 add AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 start
    // 連動アプリが通信SV(ntss_comsv.exe)かどうか判定
    char *appCOMSV ="NTSS_COMSV.EXE";
    if (strncasecmp(configParameter.collectApp + strlen(configParameter.collectApp) - strlen(appCOMSV), appCOMSV, sizeof(appCOMSV)) == 0) {
        configParameter.isSelectedComSv = true;
        LogOutput(NTSS_LOG_INFO, " USE NTSS_COMSV.EXE");
    }
    // #8730 2023.05.23 add AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 end

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_UPLOAD_APP) != NULL)
    {
        strncpy(configParameter.uploadApp, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_UPLOAD_APP), sizeof(configParameter.uploadApp));
    }
    sprintf(logMessage, "%s : %s", TAG_UPLOAD_APP, configParameter.uploadApp);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_FTP_SCHEDULE) != NULL)
    {
        u_char scheduleTimer[255] = {0};
        strncpy(scheduleTimer, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_FTP_SCHEDULE), 255);
        uint16_t cnt, offset = 0, idx = 0;
        u_char hh[3] = {0}, mm[3] = {0};

        for (cnt = 0; cnt < 255; cnt++)
        {
            if (scheduleTimer[cnt] == 0x00)
            {
                break;
            }
            if (scheduleTimer[cnt] == ':')
            {
                // 時
                strncpy(hh, scheduleTimer + offset, cnt - offset);
                offset = cnt + 1;
                continue;
            }
            if (scheduleTimer[cnt] == ',')
            {
                // 分
                strncpy(mm, scheduleTimer + offset, cnt - offset);
                offset = cnt + 1;

                // 時、分
                configParameter.ftpSchedule[idx].hour = atoi(hh);
                configParameter.ftpSchedule[idx].minute = atoi(mm);
                idx++;
                hh[0] = 0x00;
                mm[0] = 0x00;
                continue;
            }
        }
        if (hh[0] != 0x00)
        {
            // 分が残っている
            strncpy(mm, scheduleTimer + offset, cnt - offset);
            configParameter.ftpSchedule[idx].hour = atoi(hh);
            configParameter.ftpSchedule[idx].minute = atoi(mm);
            idx++;
        }
        // データのないidxはマイナスをセット
        configParameter.ftpSchedule[idx].hour = -1;
    }

    return 0;
}
/**
 * @brief 共通設定ファイルの内容を取得
 * 
 * @param configFileName 
 * @param configData 
 * @return int32_t 
 */
uint32_t readConfigCommonFile(const char *configFileName)
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

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_RECEIVE_DATA_DIRECTORY) != NULL)
    {
        strncpy(configParameter.receiveDataDirectory, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_RECEIVE_DATA_DIRECTORY), sizeof(configParameter.receiveDataDirectory));
    }
    sprintf(logMessage, "%s : %s", TAG_RECEIVE_DATA_DIRECTORY, configParameter.receiveDataDirectory);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_RECEIVE_DATA_DIRECTORY_2) != NULL)
    {
        strncpy(configParameter.receiveDataDirectory2, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_RECEIVE_DATA_DIRECTORY_2), sizeof(configParameter.receiveDataDirectory2));
    }
    sprintf(logMessage, "%s : %s", TAG_RECEIVE_DATA_DIRECTORY_2, configParameter.receiveDataDirectory2);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_RECEIVE_DATA_DIRECTORY_3) != NULL)
    {
        strncpy(configParameter.receiveDataDirectory3, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_RECEIVE_DATA_DIRECTORY_3), sizeof(configParameter.receiveDataDirectory3));
    }
    sprintf(logMessage, "%s : %s", TAG_RECEIVE_DATA_DIRECTORY_3, configParameter.receiveDataDirectory3);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_COLLECT_DATA_DIRECTORY) != NULL)
    {
        strncpy(configParameter.collectDataDirectory, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_COLLECT_DATA_DIRECTORY), sizeof(configParameter.collectDataDirectory));
    }
    sprintf(logMessage, "%s : %s", TAG_COLLECT_DATA_DIRECTORY, configParameter.collectDataDirectory);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_COLLECT_DATA_DIRECTORY_2) != NULL)
    {
        strncpy(configParameter.collectDataDirectory2, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_COLLECT_DATA_DIRECTORY_2), sizeof(configParameter.collectDataDirectory2));
    }
    sprintf(logMessage, "%s : %s", TAG_COLLECT_DATA_DIRECTORY_2, configParameter.collectDataDirectory2);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_COLLECT_DATA_DIRECTORY_3) != NULL)
    {
        strncpy(configParameter.collectDataDirectory3, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_COLLECT_DATA_DIRECTORY_3), sizeof(configParameter.collectDataDirectory3));
    }
    sprintf(logMessage, "%s : %s", TAG_COLLECT_DATA_DIRECTORY_3, configParameter.collectDataDirectory3);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_TEMP_DIRECTORY) != NULL)
    {
        strncpy(configParameter.tempDirectory, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_TEMP_DIRECTORY), sizeof(configParameter.tempDirectory));
    }
    sprintf(logMessage, "%s : %s", TAG_TEMP_DIRECTORY, configParameter.tempDirectory);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_TEMP_DIRECTORY_2) != NULL)
    {
        strncpy(configParameter.tempDirectory2, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_TEMP_DIRECTORY_2), sizeof(configParameter.tempDirectory2));
    }
    sprintf(logMessage, "%s : %s", TAG_TEMP_DIRECTORY_2, configParameter.tempDirectory2);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_TEMP_DIRECTORY_3) != NULL)
    {
        strncpy(configParameter.tempDirectory3, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_TEMP_DIRECTORY_3), sizeof(configParameter.tempDirectory3));
    }
    sprintf(logMessage, "%s : %s", TAG_TEMP_DIRECTORY_3, configParameter.tempDirectory3);
    LogOutput(NTSS_LOG_INFO, logMessage);

    // if(getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_MASTER_FOLDER) != NULL){
    //     strncpy(configParameter.mstDir, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_MASTER_FOLDER), sizeof(configParameter.mstDir));
    // }
    sprintf(configParameter.mstDir, "./mst");
    sprintf(logMessage, "%s : %s", TAG_MASTER_FOLDER, configParameter.mstDir);
    LogOutput(NTSS_LOG_INFO, logMessage);

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_THRESHOLD_FILE_COUNT) != NULL)
    {
        configParameter.thresholdFileCount = atoi(getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_THRESHOLD_FILE_COUNT));
        sprintf(logMessage, "%s : %d", TAG_THRESHOLD_FILE_COUNT, configParameter.thresholdFileCount);
    }
    else
    {
        configParameter.thresholdFileCount = 5000;
        sprintf(logMessage, "%s : 5000(初期値)", TAG_THRESHOLD_FILE_COUNT);
    }
    LogOutput(NTSS_LOG_INFO, logMessage);

    return 0;
}
/**
 * @brief ネットワーク設定ファイルの内容を取得
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

    // 2019.05.31以下追加 WebSocket接続後にクラウド通信許可フラグをOFFにする待ち時間
    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_COMM_PERMISSION_WAIT_TIME) != NULL)
    {
        configParameter.commPermissonWaitTime = atoi(getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_COMM_PERMISSION_WAIT_TIME));
        sprintf(logMessage, "%s : %d", TAG_COMM_PERMISSION_WAIT_TIME, configParameter.commPermissonWaitTime);
    }
    else
    {
        configParameter.commPermissonWaitTime = 60;
        sprintf(logMessage, "%s : 60(初期値)", TAG_COMM_PERMISSION_WAIT_TIME);
    }
    LogOutput(NTSS_LOG_INFO, logMessage);

    return 0;
}

// #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 start
/**
 * @brief 通信異常時設定ファイルの内容を取得
 * @param[in] configFileName 
 * @param[out] configParam 
 * @return 0:成功, -1:エラー
 */
uint32_t readConfigCommFailFile(const char *configFileName) {

    char *pVal;
    ConfigData_t configData[CONFIG_TAG_COUNT];
    memset(configData, 0, sizeof(configData));
    
    sprintf(configParameter.commFailDirectory, "/mnt/usb/ntss");
	
    if ( readConfigDataFile(configFileName, configData, CONFIG_TAG_COUNT) < 0 ) {
        printf("<%sなし> %s : %s\n", configFileName, TAG_COMM_FAIL_DIRECTORY, configParameter.commFailDirectory);
        return 0;
    }

    // 設定ファイルの値を構造体にセットする

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_COMM_FAIL_DIRECTORY) != NULL)
    {
        strncpy(configParameter.commFailDirectory, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_COMM_FAIL_DIRECTORY), sizeof(configParameter.commFailDirectory));
    }
    printf("%s : %s\n", TAG_COMM_FAIL_DIRECTORY, configParameter.commFailDirectory);
    return 0;
}
// #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 end
