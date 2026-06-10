/**
* @file comsv_config.c
* @brief コンフィグデータ処理
* @author Y.Takamura
* @date 2019/05/14
* @details コンフィグデータの読込を行う
*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

#include "comsv_config.h"
#include "../common/libs/config_reader.h"

#define STR_MAX                         256                     /// 最大文字数
#define CONFIG_TAG_COUNT                100                     /// TAG最大数
#define TAG_RECEIVE_PORT                "RECEIVE_PORT"          /// TAG:新通信用接続待受ポート
#define TAG_RECEIVE_PORT_NX             "RECEIVE_PORT_NX"       /// TAG:NX通信用接続待受ポート
#define TAG_REQUEST_TIME_CP             "REQUEST_TIME_CP"       /// TAG:共通プロトコル通信用リクエスト間隔
// #10031 2023.12.01 add 医器工V4タイムアウト設定による受信待ち対応 TDC高村 start
#define TAG_RESPONSE_TIMEOUT_CP         "RESPONSE_TIMEOUT_CP"   /// TAG:共通プロトコル通信V4用応答タイムアウト
// #10031 2023.12.01 add 医器工V4タイムアウト設定による受信待ち対応 TDC高村 end
#define TAG_LCD_DATA_CASH               "LCD_DATA_CASH"         /// TAG:仮想端末データキャッシュ
#define TAG_MASTER_FOLDER               "MASTER_FOLDER"         /// TAG:マスタ格納先フォルダ
#define TAG_FACILITY_CODE               "FACILITY_CODE"         /// TAG:施設コード
#define TAG_DEVICE_EDGE_NO              "AWS_IOT_DEVICE_NO"     /// TAG:デバイスエッジ番号
#define TAG_RECEIVE_DATA_DIRECTORY      "M_NOTICE_FOLDER1"      /// TAG:データ収集用ファイル格納先フォルダ１
#define TAG_RECEIVE_DATA_DIRECTORY_2    "M_NOTICE_FOLDER2"      /// TAG:データ収集用ファイル格納先フォルダ２
#define TAG_RECEIVE_DATA_DIRECTORY_3    "M_NOTICE_FOLDER3"      /// TAG:データ収集用ファイル格納先フォルダ３
#define TAG_COLLECT_DATA_DIRECTORY      "DATA_COLLECT_FOLDER1"  /// TAG:データ収集用一時ファイル格納先フォルダ１
#define TAG_COLLECT_DATA_DIRECTORY_2    "DATA_COLLECT_FOLDER2"  /// TAG:データ収集用一時ファイル格納先フォルダ２
#define TAG_COLLECT_DATA_DIRECTORY_3    "DATA_COLLECT_FOLDER3"  /// TAG:データ収集用一時ファイル格納先フォルダ３
// #8731 2023.05.08 add 通信異常ファイルの格納先を設定で持つ TDC片口 start
#define TAG_COMM_FAIL_DIRECTORY         "COMM_FAIL_FOLDER"      /// TAG:通信異常時ファイル格納先フォルダ
// #8731 2023.05.08 add 通信異常ファイルの格納先を設定で持つ TDC片口 end
#define TAG_CONNECT_HOST                "AWS_HOST"              /// TAG:ＡＷＳホスト名
// #11520 2025.02.26 add 起動時の一時停止処理（待ち時間）見直し TDC高村 start
#define TAG_COMM_PERMISSON_WAIT         "COMM_PERMISSON_WAIT_TIME"  /// TAG:通信不可フラグの解除待ち時間(秒)
// #11520 2025.02.26 add 起動時の一時停止処理（待ち時間）見直し TDC高村 end
// #11629 2025.05.07 add 治療済透析レポート画像の保存箇所変更 TDC米沢 start
#define TAG_TREATED_DIALYSIS_REPORT_DIRECTORY   "TREATED_DIALYSIS_REPORT_FOLDER1"    /// TAG:治療済透析レポート情報格納先フォルダ１
#define TAG_TREATED_DIALYSIS_REPORT_DIRECTORY_2 "TREATED_DIALYSIS_REPORT_FOLDER2"    /// TAG:治療済透析レポート情報格納先フォルダ２
// #11629 2025.05.07 add 治療済透析レポート画像の保存箇所変更 TDC米沢 end

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
    // #10031 2023.12.01 add 医器工V4タイムアウト設定による受信待ち対応 TDC高村 start
    configParam->responseTimeout_CP = 5;
    // #10031 2023.12.01 add 医器工V4タイムアウト設定による受信待ち対応 TDC高村 end

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
    // #10031 2023.12.01 add 医器工V4タイムアウト設定による受信待ち対応 TDC高村 start
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_RESPONSE_TIMEOUT_CP);
	if ( pVal != NULL && pVal != "" ) {
		lntrim(pVal);
        configParam->responseTimeout_CP = atoi(pVal);
        if ( configParam->responseTimeout_CP != 0 ) {
            configParam->responseTimeout_CP = 5;
        }
	}
    // #10031 2023.12.01 add 医器工V4タイムアウト設定による受信待ち対応 TDC高村 end
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_LCD_DATA_CASH);
	if ( pVal != NULL && pVal != "" ) {
		lntrim(pVal);
        configParam->lcdDataCash = atoi(pVal);
        if ( configParam->lcdDataCash != 0 && configParam->lcdDataCash != 1 ) {
            configParam->lcdDataCash = 0;
        }
	}

    // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 start
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_TREATED_DIALYSIS_REPORT_DIRECTORY);
    if( pVal != NULL && pVal != "" ) {
        strncpy(configParam->TreatedDialysisReportDataDirectory, pVal, sizeof(configParam->receiveDataDirectory));
        lntrim(configParam->TreatedDialysisReportDataDirectory);
    } else {
        strncpy(configParam->TreatedDialysisReportDataDirectory, "/mnt/usb/ntss/report", sizeof(configParam->receiveDataDirectory));
    }
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_TREATED_DIALYSIS_REPORT_DIRECTORY_2);
    if( pVal != NULL && pVal != "" ) {
        strncpy(configParam->TreatedDialysisReportDataDirectory2, pVal, sizeof(configParam->receiveDataDirectory2));
        lntrim(configParam->TreatedDialysisReportDataDirectory2);
    } else {
        strncpy(configParam->TreatedDialysisReportDataDirectory2, "/mnt/sd/ntss/report", sizeof(configParam->receiveDataDirectory2));
    }
    // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 end

    printf("%s : %d\n", TAG_RECEIVE_PORT, configParam->receivePort);
    printf("%s : %d\n", TAG_RECEIVE_PORT_NX, configParam->receivePort_NX);
    printf("%s : %d\n", TAG_REQUEST_TIME_CP, configParam->requestTime_CP);
    // #10031 2023.12.01 add 医器工V4タイムアウト設定による受信待ち対応 TDC高村 start
    printf("%s : %d\n", TAG_RESPONSE_TIMEOUT_CP, configParam->responseTimeout_CP);
    // #10031 2023.12.01 add 医器工V4タイムアウト設定による受信待ち対応 TDC高村 end
    printf("%s : %d\n", TAG_LCD_DATA_CASH, configParam->lcdDataCash);

    // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 start
    printf("%s : %s\n", TAG_TREATED_DIALYSIS_REPORT_DIRECTORY,   configParam->TreatedDialysisReportDataDirectory);
    printf("%s : %s\n", TAG_TREATED_DIALYSIS_REPORT_DIRECTORY_2, configParam->TreatedDialysisReportDataDirectory2);
    // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 end

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

    strncpy(configParam->facilityCd, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_FACILITY_CODE), sizeof(configParam->facilityCd));
	lntrim(configParam->facilityCd);
    printf("%s : %s\n", TAG_FACILITY_CODE, configParam->facilityCd);
    configParam->deviceEdgeNo = 1;
    if ( (pVal = getConfigDataValue( configData, CONFIG_TAG_COUNT, TAG_DEVICE_EDGE_NO )) != NULL ) {
        int intval = atoi( pVal );
        if( 0 < intval ) {
            configParam->deviceEdgeNo = intval;
        }
    }
    printf("%s : %d\n", TAG_DEVICE_EDGE_NO, configParam->deviceEdgeNo);

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

// #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 start
/**
 * @brief 通信異常時設定ファイルの内容を取得
 * @param[in] configFileName 
 * @param[out] configParam 
 * @return 0:成功, -1:エラー
 */
uint32_t readConfigCommFailFile(const char *configFileName, ConfigParameter_t *configParam) {

    char *pVal;
    ConfigData_t configData[CONFIG_TAG_COUNT];
    memset(configData, 0, sizeof(configData));
    
    sprintf(configParam->commFailDirectory, "/mnt/usb/ntss");
	
    if ( readConfigDataFile(configFileName, configData, CONFIG_TAG_COUNT) < 0 ) {
        printf("<%sなし> %s : %s\n", configFileName, TAG_COMM_FAIL_DIRECTORY, configParam->commFailDirectory);
        return 0;
    }

    // 設定ファイルの値を構造体にセットする

    if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_COMM_FAIL_DIRECTORY) != NULL)
    {
        strncpy(configParam->commFailDirectory, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_COMM_FAIL_DIRECTORY), sizeof(configParam->commFailDirectory));
        lntrim(configParam->commFailDirectory);
    }
    printf("%s : %s\n", TAG_COMM_FAIL_DIRECTORY, configParam->commFailDirectory);
    return 0;
}
// #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 end

/**
 * @brief ネットワーク設定ファイルの内容を取得
 * @param configFileName 
 * @param configParam 
 * @return int32_t 
 */
uint32_t readConfigNetworkFile(const char *configFileName, ConfigParameter_t *configParam) {

    int len;
    char *pVal, *sp;
    ConfigData_t configData[CONFIG_TAG_COUNT];
    memset(configData, 0, sizeof(configData));

    if (readConfigDataFile(configFileName, configData, CONFIG_TAG_COUNT) < 0) {
        return -1;
    }

    // 設定ファイルの値を構造体にセットする
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_CONNECT_HOST);
	if ( pVal != NULL && pVal != "" ) {
		lntrim(pVal);
        strcpy(configParam->restDeviceEdgeUrl, pVal);
        strcpy(configParam->restWebApiUrl, pVal);
        sp = strstr(pVal, ":DEBUG");
        if ( sp != NULL ) {
            len = (int)(strlen(pVal) - strlen(sp));
            configParam->restDeviceEdgeUrl[len] = 0;
            configParam->restWebApiUrl[len] = 0;
            strcat(configParam->restDeviceEdgeUrl, ":8080/device_edge/api");
            strcat(configParam->restWebApiUrl, ":8090/ntss-web-api/util");
            // add AWSとDEの通信断からの復旧 高 start
            strcat(configParam->aliveMoniUrl, ":8080/device_edge/api");
            // add AWSとDEの通信断からの復旧 高 end
        }
        else {
            strcat(configParam->restDeviceEdgeUrl, "/device_edge/api");
            strcat(configParam->restWebApiUrl, "/ntss-web-api/util");
            // add AWSとDEの通信断からの復旧 高 start
            strcat(configParam->aliveMoniUrl, "/device_edge/api");
            // add AWSとDEの通信断からの復旧 高 end
        }
	}
    else {
        strcpy(configParam->restDeviceEdgeUrl, "http://localhost:8080/api");
        strcpy(configParam->restWebApiUrl, "http://localhost:8090/util");
        // add AWSとDEの通信断からの復旧 高 start
        strcpy(configParam->aliveMoniUrl, "http://localhost:8080/api");
        // add AWSとDEの通信断からの復旧 高 end
    }    
    printf("%s : %s (DeviceEdge)\n", TAG_CONNECT_HOST, configParam->restDeviceEdgeUrl);
    printf("%s : %s (WebApi)\n", TAG_CONNECT_HOST, configParam->restWebApiUrl);
    // #11520 2025.02.26 add 起動時の一時停止処理（待ち時間）見直し TDC高村 start
    configParam->commPermissonWait = 60;    // 通信不可フラグの解除待ち時間(秒)
    pVal = getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_COMM_PERMISSON_WAIT);
	if ( pVal != NULL && pVal != "" ) {
		lntrim(pVal);
        configParam->commPermissonWait = atoi(pVal);
	}
    printf("%s : %d (秒)\n", TAG_COMM_PERMISSON_WAIT, configParam->commPermissonWait);
    // #11520 2025.02.26 add 起動時の一時停止処理（待ち時間）見直し TDC高村 end

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
