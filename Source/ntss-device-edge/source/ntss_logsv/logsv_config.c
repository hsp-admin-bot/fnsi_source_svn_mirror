
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

#include "logsv_config.h"
#include "../common/libs/config_reader.h"

#define CONFIG_TAG_COUNT            100

#define TAG_LOGSV_HOST              "LOGSV_HOST"
#define TAG_LOGSV_PORT              "LOGSV_PORT"
#define TAG_LOGSV_TIMEOUT           "LOGSV_TIMEOUT"
#define TAG_LOGSV_FOLDER1           "LOGSV_FOLDER1"
#define TAG_LOGSV_FOLDER2           "LOGSV_FOLDER2"
#define TAG_LOGSV_FOLDER3           "LOGSV_FOLDER3"
#define TAG_LOGSV_TEMP              "LOGSV_TEMP_FOLDER"
#define TAG_UPLOAD_PATH             "UPLOAD_PATH"
#define TAG_UPLOAD_TIME             "UPLOAD_TIME"

#define TAG_FACILITY_CODE           "FACILITY_CODE"
#define TAG_DEVICE_NO               "AWS_IOT_DEVICE_NO"
#define TAG_DEVICE_SERIAL           "DEVICE_SERIAL_NO"

#define TAG_UPLOAD_HOST             "AWS_HOST"
#define TAG_UPLOAD_LIMIT_SIZE       "UPLOAD_FILE_MAXSIZE"
#define TAG_UPLOAD_PW               "ZIP_PW"
#define TAG_UPLOAD_RETRY_COUNT      "UPLOAD_RETRY_COUNT"
#define TAG_UPLOAD_RETRY_WAIT       "UPLOAD_RETRY_WAIT_TIME"

#define STR_MAX 256

/**
 * @brief 設定ファイルの内容を取得
 * 
 * @param configFileName 
 * @param configData 
 * @return int32_t 
 */
uint32_t readConfigFile(const char *configFileName, ConfigParameter_t *configParam){
    
    ConfigData_t configData[CONFIG_TAG_COUNT];
    memset( configData, 0, sizeof(configData) );

    if (readConfigDataFile(configFileName, configData, CONFIG_TAG_COUNT) < 0){
        return -1;
    }

    // 設定ファイルの値を構造体にセットする
    char *pVal;

    strcpy(configParam->logsvHost, "127.0.0.1");
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_LOGSV_HOST);
	if ( pVal != NULL && pVal != "" ) {
        strncpy(configParam->logsvHost, pVal, sizeof(configParam->logsvHost));
    	lntrim(configParam->logsvHost);
	}
    printf("%s : %s\n", TAG_LOGSV_HOST, configParam->logsvHost);

    configParam->logsvPort = 7100;
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_LOGSV_PORT);
	if ( pVal != NULL && pVal != "" ) {
		lntrim(pVal);
        configParam->logsvPort = atoi(pVal);
	}
    printf("%s : %d\n", TAG_LOGSV_PORT, configParam->logsvPort);

    configParam->logsvTimeout = -1;
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_LOGSV_TIMEOUT);
	if ( pVal != NULL && pVal != "" ) {
		lntrim(pVal);
        configParam->logsvTimeout = atoi(pVal);
	}
    printf("%s : %d\n", TAG_LOGSV_TIMEOUT, configParam->logsvTimeout);

    strcpy(configParam->logsvFolder1, "/mnt/usb/ntss/log");
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_LOGSV_FOLDER1);
	if ( pVal != NULL && pVal != "" ) {
        strncpy(configParam->logsvFolder1, pVal, sizeof(configParam->logsvFolder1));
    	lntrim(configParam->logsvFolder1);
	}
    printf("%s : %s\n", TAG_LOGSV_FOLDER1, configParam->logsvFolder1);

    strcpy(configParam->logsvFolder2, "/mnt/sd/ntss/log");
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_LOGSV_FOLDER2);
	if ( pVal != NULL && pVal != "" ) {
        strncpy(configParam->logsvFolder2, pVal, sizeof(configParam->logsvFolder2));
    	lntrim(configParam->logsvFolder2);
	}
    printf("%s : %s\n", TAG_LOGSV_FOLDER2, configParam->logsvFolder2);

    strcpy(configParam->logsvFolder3, "./log");
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_LOGSV_FOLDER3);
	if ( pVal != NULL && pVal != "" ) {
        strncpy(configParam->logsvFolder3, pVal, sizeof(configParam->logsvFolder3));
    	lntrim(configParam->logsvFolder3);
	}
    printf("%s : %s\n", TAG_LOGSV_FOLDER3, configParam->logsvFolder3);

    strcpy(configParam->logsvTemp, "./temp");
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_LOGSV_TEMP);
	if ( pVal != NULL && pVal != "" ) {
        strncpy(configParam->logsvTemp, pVal, sizeof(configParam->logsvTemp));
    	lntrim(configParam->logsvTemp);
	}
    printf("%s : %s\n", TAG_LOGSV_TEMP, configParam->logsvTemp);

    //strcpy(configParam->uploadS3Path, "");
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_UPLOAD_PATH);
	if ( pVal != NULL && pVal != "" ) {
        strncpy(configParam->uploadS3Path, pVal, sizeof(configParam->uploadS3Path));
    	lntrim(configParam->uploadS3Path);
	}
    printf("%s : %s\n", TAG_UPLOAD_PATH, configParam->uploadS3Path);

    strcpy(configParam->uploadTime, "");
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_UPLOAD_TIME);
	if ( pVal != NULL && pVal != "" ) {
        strncpy(configParam->uploadTime, pVal, sizeof(configParam->uploadTime));
    	lntrim(configParam->uploadTime);
	}
    printf("%s : %s\n", TAG_UPLOAD_TIME, configParam->uploadTime);

    return 0;
}

/**
 * @brief 共通設定ファイルの内容を取得
 * 
 * @param configFileName 
 * @param configData 
 * @return int32_t 
 */
uint32_t readConfigCommonFile(const char *configFileName, ConfigParameter_t *configParam){
    
    ConfigData_t configData[CONFIG_TAG_COUNT];
    memset( configData, 0, sizeof(configData) );

    if (readConfigDataFile(configFileName, configData, CONFIG_TAG_COUNT) < 0){
        return -1;
    }

    // 設定ファイルの値を構造体にセットする
    char *pVal;
 
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_FACILITY_CODE);
	if ( pVal != NULL && pVal != "" ) {
        strncpy(configParam->facilityCd, pVal, sizeof(configParam->facilityCd));
    	lntrim(configParam->facilityCd);
	}
    printf("%s : %s\n", TAG_FACILITY_CODE, configParam->facilityCd);

    configParam->deviceNo = 1;
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_DEVICE_NO);
	if ( pVal != NULL && pVal != "" ) {
		lntrim(pVal);
        configParam->deviceNo = atoi(pVal);
	}
    printf("%s : %d\n", TAG_DEVICE_NO, configParam->deviceNo);

    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_DEVICE_SERIAL);
	if ( pVal != NULL && pVal != "" ) {
        strncpy(configParam->serialNo, pVal, sizeof(configParam->serialNo));
    	lntrim(configParam->serialNo);
	}
    printf("%s : %s\n", TAG_DEVICE_SERIAL, configParam->serialNo);

    return 0;
}

/**
 * @brief ネットワーク設定ファイルの内容を取得
 * 
 * @param configFileName 
 * @param configData 
 * @return int32_t 
 */
uint32_t readConfigNetworkFile(const char *configFileName, ConfigParameter_t *configParam){
    
    ConfigData_t configData[CONFIG_TAG_COUNT];
    memset( configData, 0, sizeof(configData) );

    if (readConfigDataFile(configFileName, configData, CONFIG_TAG_COUNT) < 0){
        return -1;
    }

    // 設定ファイルの値を構造体にセットする
    char *pVal;
 
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_UPLOAD_PW);
	if ( pVal != NULL && pVal != "" ) {
        strncpy(configParam->uploadPW, pVal, sizeof(configParam->uploadPW));
    	lntrim(configParam->uploadPW);
	}
    printf("%s : %s\n", TAG_UPLOAD_PW, configParam->uploadPW);

    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_UPLOAD_HOST);
	if ( pVal != NULL && pVal != "" ) {
        strncpy(configParam->uploadHostName, pVal, sizeof(configParam->uploadHostName));
    	lntrim(configParam->uploadHostName);
	}
    printf("%s : %s\n", TAG_UPLOAD_HOST, configParam->uploadHostName);

    configParam->uploadLimitFileSize = 80;
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_UPLOAD_LIMIT_SIZE);
	if ( pVal != NULL && pVal != "" ) {
		lntrim(pVal);
        configParam->uploadLimitFileSize = atoi(pVal);
	}
    printf("%s : %d\n", TAG_UPLOAD_LIMIT_SIZE, configParam->uploadLimitFileSize);

    configParam->nUploadRetryCount = 3;
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_UPLOAD_RETRY_COUNT);
	if ( pVal != NULL && pVal != "" ) {
		lntrim(pVal);
        configParam->nUploadRetryCount = atoi(pVal);
	}
    printf("%s : %d\n", TAG_UPLOAD_RETRY_COUNT, configParam->nUploadRetryCount);

    configParam->nUploadRetryWaitTime = 30;
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_UPLOAD_RETRY_WAIT);
	if ( pVal != NULL && pVal != "" ) {
		lntrim(pVal);
        configParam->nUploadRetryWaitTime = atoi(pVal);
	}
    printf("%s : %d\n", TAG_UPLOAD_RETRY_WAIT, configParam->nUploadRetryWaitTime);

    return 0;
}


/**
 * @brief 最期に入る改行(\r\n)を取り除く
 * 
 * @param *str 
 */
void lntrim(char *str)
{  
	char *p;

	p = strchr(str, '\r');
	if(p != NULL) {
		*p = '\0';
	}
	p = strchr(str, '\n');
	if(p != NULL) {
		*p = '\0';
	}
}
