/**
* @file sock_config.c
* @brief コンフィグデータ処理
* @author Y.Takamura
* @date 2019/05/14
* @details コンフィグデータの読込を行う
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

#include "sock_config.h"
#include "../common/libs/config_reader.h"

#define STR_MAX                         256                     /// 最大文字数
#define CONFIG_TAG_COUNT                100                     /// TAG最大数
#define TAG_RECEIVE_PORT                "RECEIVE_PORT"          /// TAG:新通信用接続待受ポート
#define TAG_RECEIVE_PORT_NX             "RECEIVE_PORT_NX"       /// TAG:NX通信用接続待受ポート
#define TAG_REQUEST_TIME_CP             "REQUEST_TIME_CP"       /// TAG:共通プロトコル通信用リクエスト間隔
#define TAG_DEVICE_TIMEOUT              "DEVICE_TIMEOUT"        /// TAG:装置生存監視時間
#define TAG_TIMESET_TIME                "TIMESET_TIME"
#define TAG_TIMESET_TIME_NX             "TIMESET_TIME_NX"
#define TAG_MASTER_FOLDER               "MASTER_FOLDER"         /// TAG:マスタ格納先フォルダ
#define TAG_RECEIVE_DATA_DIRECTORY      "M_NOTICE_FOLDER1"      /// TAG:データ収集用ファイル格納先フォルダ１
#define TAG_RECEIVE_DATA_DIRECTORY_2    "M_NOTICE_FOLDER2"      /// TAG:データ収集用ファイル格納先フォルダ２
#define TAG_RECEIVE_DATA_DIRECTORY_3    "M_NOTICE_FOLDER3"      /// TAG:データ収集用ファイル格納先フォルダ３
#define TAG_COLLECT_DATA_DIRECTORY      "DATA_COLLECT_FOLDER1"  /// TAG:データ収集用一時ファイル格納先フォルダ１
#define TAG_COLLECT_DATA_DIRECTORY_2    "DATA_COLLECT_FOLDER2"  /// TAG:データ収集用一時ファイル格納先フォルダ２
#define TAG_COLLECT_DATA_DIRECTORY_3    "DATA_COLLECT_FOLDER3"  /// TAG:データ収集用一時ファイル格納先フォルダ３
#define TAG_CONNECT_HOST                "AWS_HOST"              /// TAG:ＡＷＳホスト名

/**
 * @brief 設定ファイルの内容を取得
 * @param[in] configFileName 
 * @param[out] configParam 
 * @return 0:成功, -1:エラー
 */
uint32_t readConfigFile(const char *configFileName, ConfigParameter_t *configParam) {
    
    char *pVal;
    ConfigData_t configData[CONFIG_TAG_COUNT];
    memset(configData, 0, sizeof(configData));
    configParam->receivePort = 7000;
    configParam->receivePort_NX = 7010;
    configParam->requestTime_CP = 10;
    configParam->deviceTimeout = 60;

    if ( readConfigDataFile(configFileName, configData, CONFIG_TAG_COUNT) < 0 ) {
        return -1;
    }

    // 設定ファイルの値を構造体にセットする
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_RECEIVE_PORT);
	if ( pVal != NULL && pVal != "" ) {
		lntrim(pVal);
        configParam->receivePort = atoi(pVal);
	}
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_RECEIVE_PORT_NX);
	if ( pVal != NULL && pVal != "" ) {
		lntrim(pVal);
        configParam->receivePort_NX = atoi(pVal);
	}
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_REQUEST_TIME_CP);
	if ( pVal != NULL && pVal != "" ) {
		lntrim(pVal);
        configParam->requestTime_CP = atoi(pVal);
	}
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_DEVICE_TIMEOUT);
	if ( pVal != NULL && pVal != "" ) {
		lntrim(pVal);
        configParam->deviceTimeout = atoi(pVal);
	}
	pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_TIMESET_TIME);
	if ( pVal != NULL && strlen(pVal) >= 5 ) {
		lntrim(pVal);
		pVal[5] = 0;
        strcpy(configParam->timesetTime, pVal);
	}
	pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_TIMESET_TIME_NX);
	if ( pVal != NULL && strlen(pVal) >= 5 ) {
		lntrim(pVal);
		pVal[5] = 0;
        strcpy(configParam->timesetTime_NX, pVal);
	}
    printf("%s : %d\n", TAG_RECEIVE_PORT, configParam->receivePort);
    printf("%s : %d\n", TAG_RECEIVE_PORT_NX, configParam->receivePort_NX);
    printf("%s : %d\n", TAG_REQUEST_TIME_CP, configParam->requestTime_CP);
    printf("%s : %d\n", TAG_DEVICE_TIMEOUT, configParam->deviceTimeout);

    return 0;
}

/**
 * @brief 共通設定ファイルの内容を取得
 * @param[in] configFileName 
 * @param[out] configParam 
 * @return 0:成功, -1:エラー
 */
uint32_t readConfigCommonFile(const char *configFileName, ConfigParameter_t *configParam) {

    char *pVal;
    ConfigData_t configData[CONFIG_TAG_COUNT];
    memset(configData, 0, sizeof(configData));

    if ( readConfigDataFile(configFileName, configData, CONFIG_TAG_COUNT) < 0 ) {
        return -1;
    }

    // 設定ファイルの値を構造体にセットする
    sprintf(configParam->mstDir, "./mst");
    printf("%s : %s\n", TAG_MASTER_FOLDER, configParam->mstDir);

    strncpy(configParam->receiveDataDirectory, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_RECEIVE_DATA_DIRECTORY), sizeof(configParam->receiveDataDirectory));
	lntrim(configParam->receiveDataDirectory);
    printf("%s : %s\n", TAG_RECEIVE_DATA_DIRECTORY, configParam->receiveDataDirectory);
    strncpy(configParam->receiveDataDirectory2, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_RECEIVE_DATA_DIRECTORY_2), sizeof(configParam->receiveDataDirectory2));
	lntrim(configParam->receiveDataDirectory2);
    printf("%s : %s\n", TAG_RECEIVE_DATA_DIRECTORY_2, configParam->receiveDataDirectory2);
    strncpy(configParam->receiveDataDirectory3, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_RECEIVE_DATA_DIRECTORY_3), sizeof(configParam->receiveDataDirectory3));
	lntrim(configParam->receiveDataDirectory3);
    printf("%s : %s\n", TAG_RECEIVE_DATA_DIRECTORY_3, configParam->receiveDataDirectory3);

    strncpy(configParam->collectDataDirectory, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_COLLECT_DATA_DIRECTORY), sizeof(configParam->collectDataDirectory));
	lntrim(configParam->collectDataDirectory);
    printf("%s : %s\n", TAG_COLLECT_DATA_DIRECTORY, configParam->collectDataDirectory);
    strncpy(configParam->collectDataDirectory2, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_COLLECT_DATA_DIRECTORY_2), sizeof(configParam->collectDataDirectory2));
	lntrim(configParam->collectDataDirectory2);
    printf("%s : %s\n", TAG_COLLECT_DATA_DIRECTORY_2, configParam->collectDataDirectory2);
    strncpy(configParam->collectDataDirectory3, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_COLLECT_DATA_DIRECTORY_3), sizeof(configParam->collectDataDirectory3));
	lntrim(configParam->collectDataDirectory3);
    printf("%s : %s\n", TAG_COLLECT_DATA_DIRECTORY_3, configParam->collectDataDirectory3);

    return 0;
}

/**
 * @brief 最期に入る改行(\r\n)を取り除く
 * @param[in,out] str 
 */
void lntrim(char *str) {  
	char *p;

	p = strchr(str, '\r');
	if ( p != NULL ) {
		*p = '\0';
	}
	p = strchr(str, '\n');
	if ( p != NULL ) {
		*p = '\0';
	}
}
