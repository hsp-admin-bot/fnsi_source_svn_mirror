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

#include "ntss_sms.h"
#include "config_read.h"
#include "ntss_m_notice.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
//#include "ntss_file.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
#include "../common/nkklib/nkklib.h"
#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/ntss_etc_lib.h"
// #10437 2024.03.26 add DEログに実行モジュールのリビジョンを出力する TDC高村 start
#include "../common/libs/ntss_revision.h"
// #10437 2024.03.26 add DEログに実行モジュールのリビジョンを出力する TDC高村 end

/// @SMS設定項目
//@{
#define CONFIG_SMS_FILE                 "./conf/ntss_sms.conf"      ///< SMS設定ファイル
#define CONFIG_TAG_COUNT                100                         ///< 設定項目最大数
#define TAG_CHANGE_COMM_STATE_SEND      "CHANGE_COMM_STATE_SEND"    ///< 通信異常/復旧時のメール通知有無
#define TAG_CHECKED_SMSERROR_TIME       "CHECK_SMSERROR_TIME"       ///< SMS異常時間
#define TAG_REQUEST_DIRECTORY           "REQUEST_DIRECTORY"         ///< 送信依頼フォルダ
#define TAG_CHECKED_DIRECTORY           "CHECK_DIRECTORY"           ///< 送信チェックフォルダ
#define TAG_SUCCESS_DIRECTORY           "SUCCESS_DIRECTORY"         ///< 送信成功フォルダ
#define TAG_FAILED_DIRECTORY            "FAILED_DIRECTORY"          ///< 送信失敗フォルダ
#define TAG_RECEIVE_DIRECTORY           "RECEIVE_DIRECTORY"         ///< 受信フォルダ

#define DEFAULT_CHANGE_COMM_STATE_SEND  0                           ///< 通信異常/復旧時のメール通知有無初期値
#define DEFAULT_CHECKED_SMSERROR_TIME   5                           ///< SMS異常時間初期値
#define DEFAULT_REQUEST_DIRECTORY       "/var/spool/sms/outgoing"   ///< 送信依頼フォルダ既定値
#define DEFAULT_CHECKED_DIRECTORY       "/var/spool/sms/checked"    ///< 送信チェックフォルダ既定値
#define DEFAULT_SUCCESS_DIRECTORY       "/var/spool/sms/sent"       ///< 送信成功フォルダ既定値
#define DEFAULT_FAILED_DIRECTORY        "/var/spool/sms/failed"     ///< 送信失敗フォルダ既定値
#define DEFAULT_RECEIVE_DIRECTORY       "/var/spool/sms/incoming"   ///< 受信フォルダ既定値
//@}

/// @SMS定数
//@{
#define API_SMS_CD_LIST                 "device_edge/api/sms/cd_list"
#define API_SMS_CONF                    "device_edge/api/sms/conf"
//@}

/// @SMS設定項目
//@{
int     changeCommStateSend;    ///< 通信異常/復旧時のメール通知有無(0：なし/1：あり)
int     checkedSMSErrorTime;    ///< SMS異常時間(分)
u_char  requestDirectory[256];  ///< 通知依頼フォルダ
u_char  checkedDirectory[256];  ///< 通知チェックフォルダ
u_char  successDirectory[256];  ///< 通知成功フォルダ
u_char  failedDirectory[256];   ///< 通知失敗フォルダ
u_char  receiveDirectory[256];  ///< 受信フォルダ
//@}

/// @SMS通知メッセージ関連定数
//@{
enum SMS_MESSAGE_TYPE {
    SMS_MESSAGE_ALARM  = 0,     ///< 警報メッセージ
    SMS_MESSAGE_COMM_ERROR,     ///< 通信異常メッセージ
    SMS_MESSAGE_COMM_RECOVERY   ///< 通信復旧メッセージ
};
#define SMS_MESSAGE_DEVICE_TYPE_FILE    "./conf/sms/devicetype.dat" ///< 装置型式変換用データファイル
#define SMS_MESSAGE_ALARM_FILE          "./conf/sms/alarm.msg"      ///< 警報メッセージファイル
#define SMS_MESSAGE_COMM_ERROR_FILE     "./conf/sms/commerr.msg"    ///< 通信異常メッセージファイル
#define SMS_MESSAGE_COMM_RECOVERY_FILE  "./conf/sms/comm.msg"       ///< 通信復旧メッセージファイル
#define SMS_REPLASE_OCCUR_DATETIME  "{@OCCUR_DATETIME}" ///< 発生日時置換文字列
#define SMS_REPLASE_DEVICE_TYPE     "{@DEVICE_TYPE}"    ///< 装置型番置換文字列
//@}

// #12507 2026.03.01 mod FW7に伴うエラー対応 TDC高村 start
uint32_t nSMSThreadRunningCount = 0;
// #12507 2026.03.01 mod FW7に伴うエラー対応 TDC高村 end
/// 変化判定用通信不可フラグ
bool bSMSCommDisabled = true;

/**
 * @brief SMS設定ファイルの内容を取得
 * 
 * @return int32_t 
 */
uint32_t
readConfigSMSFile()
{

    ConfigData_t configData[CONFIG_TAG_COUNT] = {0};
    u_char logMessage[MAX_LOG_TEXT] = {0};

    // 初期化
    // 通信異常/復旧時のメール通知有無(0：なし/1：あり)
    changeCommStateSend = DEFAULT_CHANGE_COMM_STATE_SEND;
    // SMS異常時間(分)
    checkedSMSErrorTime = DEFAULT_CHECKED_SMSERROR_TIME;
    // 通知依頼フォルダ
    strcpy( requestDirectory, DEFAULT_REQUEST_DIRECTORY );
    // 通知チェックフォルダ
    strcpy( checkedDirectory, DEFAULT_CHECKED_DIRECTORY );
    // 通知成功フォルダ
    strcpy( successDirectory, DEFAULT_SUCCESS_DIRECTORY );
    // 通知失敗フォルダ
    strcpy( failedDirectory, DEFAULT_FAILED_DIRECTORY );
    // 受信フォルダ
    strcpy( receiveDirectory, DEFAULT_RECEIVE_DIRECTORY );
    // 受信フォルダ
    strcpy( receiveDirectory, DEFAULT_RECEIVE_DIRECTORY );

    // 設定値読み込み
	snprintf(logMessage, MAX_LOG_TEXT, "read : %s", CONFIG_SMS_FILE);
	LogOutput(NTSS_LOG_INFO, logMessage);
    if (readConfigDataFile(CONFIG_SMS_FILE, configData, CONFIG_TAG_COUNT) < 0)
    {
        // ファイルなし
		snprintf(logMessage, MAX_LOG_TEXT, "%s OPEN ERROR", CONFIG_SMS_FILE);
		LogResourceOutput(NTSS_LOG_ERROR, logMessage);
    }
    else
    {
        // ファイルあり

        // 通信異常/復旧時のメール通知有無
        if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_CHANGE_COMM_STATE_SEND) != NULL)
        {
            if( atoi(getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_CHANGE_COMM_STATE_SEND)) == 1 )
            {
                changeCommStateSend = 1;
            }
        }
        // SMS異常時間(分)
        if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_CHECKED_SMSERROR_TIME) != NULL)
        {
            int nwork = atoi(getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_CHECKED_SMSERROR_TIME));
            if( 1 <= nwork )
            {
                checkedSMSErrorTime = nwork;
            }
        }
        // 通知依頼フォルダ
        if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_REQUEST_DIRECTORY) != NULL)
        {
            strncpy(requestDirectory, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_REQUEST_DIRECTORY), sizeof(requestDirectory));
        }
        // 通知チェックフォルダ
        if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_CHECKED_DIRECTORY) != NULL)
        {
            strncpy(checkedDirectory, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_CHECKED_DIRECTORY), sizeof(checkedDirectory));
        }
        // 通知成功フォルダ
        if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_SUCCESS_DIRECTORY) != NULL)
        {
            strncpy(successDirectory, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_SUCCESS_DIRECTORY), sizeof(successDirectory));
        }
        // 通知失敗フォルダ
        if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_FAILED_DIRECTORY) != NULL)
        {
            strncpy(failedDirectory, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_FAILED_DIRECTORY), sizeof(failedDirectory));
        }
        // 受信フォルダ
        if (getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_RECEIVE_DIRECTORY) != NULL)
        {
            strncpy(receiveDirectory, getConfigDataValue(configData, CONFIG_TAG_COUNT, TAG_RECEIVE_DIRECTORY), sizeof(receiveDirectory));
        }
    }

    // 設定値の出力
    // 通信異常/復旧時のメール通知有無
    sprintf(logMessage, "%s : %d", TAG_CHANGE_COMM_STATE_SEND, changeCommStateSend);
    LogOutput(NTSS_LOG_INFO, logMessage);
    // SMS異常時間
    sprintf(logMessage, "%s : %d", TAG_CHECKED_SMSERROR_TIME, checkedSMSErrorTime);
    LogOutput(NTSS_LOG_INFO, logMessage);
    // 通知依頼フォルダ
    sprintf(logMessage, "%s : %s", TAG_REQUEST_DIRECTORY, requestDirectory);
    LogOutput(NTSS_LOG_INFO, logMessage);
    // 通知チェックフォルダ
    sprintf(logMessage, "%s : %s", TAG_CHECKED_DIRECTORY, checkedDirectory);
    LogOutput(NTSS_LOG_INFO, logMessage);
    // 通知成功フォルダ
    sprintf(logMessage, "%s : %s", TAG_SUCCESS_DIRECTORY, successDirectory);
    LogOutput(NTSS_LOG_INFO, logMessage);
    // 通知失敗フォルダ
    sprintf(logMessage, "%s : %s", TAG_FAILED_DIRECTORY, failedDirectory);
    LogOutput(NTSS_LOG_INFO, logMessage);
    // 受信フォルダ
    sprintf(logMessage, "%s : %s", TAG_RECEIVE_DIRECTORY, receiveDirectory);
    LogOutput(NTSS_LOG_INFO, logMessage);

    return 0;
}

/**
 * @brief SMS通知設定ファイルを読み込み、SMS通知対象かどうかチェックする
 * 
 * @param[in]   cConfigFileName SMS通知設定ファイル名
 * @param[in]   cLogCode        装置記録コード
 * @param[in]   cOccurDateTime  警報発生日時
 * @param[out]  cFacilityName   SMS通知先施設名
 * @param[out]  cSMSTel         SMS通知先電話番号
 * 
 * @return 1：通知対象/else：通知対象外
 */
int
isSMSSendTarget( u_char *cConfigFileName, u_char *cLogCode, u_char *cOccurDateTime, u_char *cFacilityName, u_char *cSMSTel )
{
    u_char logMessage[MAX_LOG_TEXT] = {0};
    u_char facility[NTSS_STR_MAX_SIZE];
    u_char conf[7 * 10 + 20];
    u_char buf[12];
    FILE *fp;
    bool bSuccess = false;

    // // 設定ファイル読み込み
    // sprintf(logMessage, "SMS通知設定ファイル読み込み, %s", cConfigFileName );
    // LogOutput(NTSS_LOG_INFO, logMessage);
    if ((fp = fopen(cConfigFileName, "r")) != NULL)
    {
        // 1行目：設定した施設コード[6桁] + 通知先施設名称
        if( fgets(facility, sizeof( facility ), fp) != NULL )
        {
            // 2行目：SMS通知設定
            if( fgets(conf, sizeof( conf ), fp) != NULL )
            {
                bSuccess = true;
                // // 3行目以降：装置記録
                // while (fgets(buf, sizeof( buf ), fp) != NULL)
                // {
                //     buf[strlen(buf) - 1] = 0; // 末尾の改行コード無視

                //     // 装置記録コード判定
                //     if( strcasecmp( buf, cLogCode, 4 ) == 0 )
                //     {
                //         // 一致
                //         bSuccess = true;

                //         //
                //         sprintf(logMessage, "SMS通知設定ファイルに装置記録コードが登録済, %s, [%s]", cConfigFileName, cLogCode );
                //         LogOutput(NTSS_LOG_INFO, logMessage);

                //         break;
                //     }
                // }
            }
        }
    }
    fclose(fp);

    // 装置記録コードが登録されている場合
    if ( bSuccess == true )
    {
        // 読み込み成功

        // 末尾の改行コード削除
        facility[strlen(facility) - 1] = 0;
        conf[strlen(conf) - 1] = 0;

        // SMS通知先施設を設定
        strcpy( cFacilityName, facility + 6 );
        // SMS通知先電話番号を設定
        strcpy( cSMSTel, conf + 7 * 10 );

        // 発生日時文字列の整形
        u_char cdate[] = { 0,0,0,0,'/', 0,0, '/', 0, 0, 0 };
        memcpy( cdate, cOccurDateTime, 4 );
        memcpy( cdate + 5, cOccurDateTime + 4, 2 );
        memcpy( cdate + 8, cOccurDateTime + 6, 2 );
        u_char ctime[] = { 0, 0, ':', 0, 0, 0 };
        memcpy( ctime, cOccurDateTime + 8, 2 );
        memcpy( ctime + 3, cOccurDateTime + 10, 2 );
        
        // 発生日時取得
        time_t tim;
        if( str_time( cdate, ctime, &tim, 0 ) == 0 )
        {
            // 取得成功

            //
            struct tm tmc;
            localtime_r( &tim, &tmc );

            // 現在曜日、現在時刻を数値化
            int nWeekNo = tmc.tm_wday;
            int ntime = tmc.tm_hour * 100 + tmc.tm_min;
            int nstart = 0, nend = 0;
            long nwork;

            // 当日通知判定
            if( conf[nWeekNo * 10] == '1' )
            {
                // 通知あり

                // 開始時刻先頭が空白の場合
                if( conf[nWeekNo * 10 + 2] == ' ' )
                {
                    // 通知対象(時間制限なし)

                    // 一致条件記録
                    memcpy( buf, conf + nWeekNo * 10, 10 );
                    sprintf(logMessage, "SMS通知設定ファイルで当日通知条件一致, %s, [occur : %s / week : %d / param: %s]", cConfigFileName, cOccurDateTime, nWeekNo, buf );
                    LogOutput(NTSS_LOG_INFO, logMessage);

                    return 1;
                }
                else
                {
                    // 開始時刻、終了時刻を取得
                    memset( buf, 0, sizeof( buf ));
                    memcpy( buf, conf + (nWeekNo * 10 + 2 ), 8 );
                    nwork = atol( buf );
                    nstart = nwork / 10000;
                    nend   = nwork % 10000;

                    // 翌日フラグ判定
                    if( conf[nWeekNo * 10 + 1] == '1' )
                    {
                        // 翌日あり
                        nend = 2359;
                    }

                    // 開始時刻〜終了時刻チェック
                    if( nstart <= ntime && ntime <= nend )
                    {
                        // 通知対象

                        // 一致条件記録
                        memcpy( buf, conf + nWeekNo * 10, 10 );
                        sprintf(logMessage, "SMS通知設定ファイルで当日通知条件一致, %s, [occur : %s / week : %d / param: %s]", cConfigFileName, cOccurDateTime, nWeekNo, buf );
                        LogOutput(NTSS_LOG_INFO, logMessage);

                        return 1;
                    }
                    else
                    {
                        // 不一致条件記録
                        memcpy( buf, conf + nWeekNo * 10, 10 );
                        sprintf(logMessage, "SMS通知設定ファイルで当日通知条件不一致, %s, [occur : %s / week : %d / param: %s]", cConfigFileName, cOccurDateTime, nWeekNo, buf );
                        LogOutput(NTSS_LOG_INFO, logMessage);
                    }
                }
            }

            // 前日
            nWeekNo--;
            if( nWeekNo < 0 )
            {
                nWeekNo = 6;
            }
            // 通知フラグ判定
            if( conf[nWeekNo * 10] == '1' )
            {
                // 通知あり

                // 翌日フラグ判定
                if( conf[nWeekNo * 10 + 1] == '1' )
                {
                    // 翌日あり

                    // 開始時刻、終了時刻を取得
                    memset( buf, 0, sizeof( buf ));
                    memcpy( buf, conf + (nWeekNo * 10 + 2 ), 8 );
                    nwork = atol( buf );
                    nstart = 0;
                    nend   = nwork % 10000;

                    // 開始時刻〜終了時刻チェック
                    if( nstart <= ntime && ntime <= nend )
                    {
                        // 通知対象

                        // 一致条件記録
                        memcpy( buf, conf + nWeekNo * 10, 10 );
                        sprintf(logMessage, "SMS通知設定ファイルで前日通知条件一致, %s, [occur : %s / week : %d / param: %s]", cConfigFileName, cOccurDateTime, nWeekNo, buf );
                        LogOutput(NTSS_LOG_INFO, logMessage);

                        return 1;
                    }
                    else
                    {
                        // 不一致条件記録
                        memcpy( buf, conf + nWeekNo * 10, 10 );
                        sprintf(logMessage, "SMS通知設定ファイルで前日通知条件不一致, %s, [occur : %s / week : %d / param: %s]", cConfigFileName, cOccurDateTime, nWeekNo, buf );
                        LogOutput(NTSS_LOG_INFO, logMessage);
                    }
                }
            }
        }
    }

    return 0;
}

/**
 * @brief SMS通知済ファイルを読み込み、SMS通知対象電話番号があるかチェックする
 * 
 * @param[in]   cListFileName SMS通知設定ファイル名
 * @param[out]  cSMSTel         SMS通知先電話番号
 * 
 * @return 1：通知対象(未通知)/else：通知対象外(通知済)
 */
int
checkSMSTel( u_char *cListFileName, u_char *cSMSTel)
{
    int ret = 1;
    FILE *fp;
    char buf[200];
    char command[512];

    // SMS通知先電話番号リストの存在チェック
    if( existFolderFile( cListFileName, NULL ) == 1 )
    {
        sprintf(command, "grep -xil %s %s  2> /dev/null", cSMSTel, cListFileName);
        if ((fp = popen(command, "r")) != NULL)
        {
            // 先頭1行を読む
            if( fgets(buf, sizeof( buf ), fp) != NULL )
            {
                // 合致する情報あり
                ret = 0;
            }
        }
        pclose(fp);
    }

    return ret;
}

/**
 * @brief 通信方式、通信フォーマット/機種にてSMS通知用装置型式を取得する
 * 
 * @param[in]   nCommType       通信方式
 * @param[in]   cFormat         通信フォーマット/機種
 * @param[out]  cSMSDeviceType  SMS通知用装置型式
 * 
 * @return なし
 */
void
getSMSDeviceType( uint16_t nCommType, u_char cFormat, u_char *cSMSDeviceType)
{
    int ret = 1;
    char buf[200];
    char command[512];
    FILE *fp;

    strcpy( cSMSDeviceType, "不明" );
    // SMS通知先電話番号リストの存在チェック
    if( existFolderFile( SMS_MESSAGE_DEVICE_TYPE_FILE, NULL ) == 1 )
    {
        sprintf(command, "grep -i %d%c %s 2> /dev/null", nCommType, cFormat, SMS_MESSAGE_DEVICE_TYPE_FILE);
        if ((fp = popen(command, "r")) != NULL)
        {
            // 先頭1行を読む
            if( fgets(buf, sizeof( buf ), fp) != NULL )
            {
                // 末尾の改行コード削除
                buf[strlen(buf) - 1] = 0;

                // 合致する情報あり
                strcpy( cSMSDeviceType, buf + 2 );
            }
        }
        pclose(fp);
    }

    return;
}

/**
 * @brief SMS通知メッセージを作成する
 * 
 * @param[in]   nKind           SMS通知メッセージ種類(0：警報/1：通信異常/2：通信復旧)
 * @param[in]   cOccurDateTime  {@OCCUR_DATETIME}と置き換わる発生日時文字列(YYYY/MM/DD HH24:MI:SS形式文字列)
 * @param[in]   cDeviceType     {@DEVICE_TYPE}と置き換わる装置型式
 * @param[in]   cFacilityName   SMS通知先施設名
 * @param[in]   cSMSTel         SMS通知先電話番号
 * @param[in]   nSize           SMS通知メッセージ作成最大サイズ
 * @param[out]  cSMSMessage     SMS通知メッセージ
 * 
 * @return 1：作成成功/else：作成失敗
 */
int
makeSMSMessage( int nKind, u_char *cOccurDateTime, u_char *cDeviceType, u_char *cFacilityName, u_char * cSMSTel, int nSize, u_char *cSMSMessage )
{
    int ret = 0;
    int maxContentLength = 70;
    u_char *msgfile[] = { SMS_MESSAGE_ALARM_FILE, SMS_MESSAGE_COMM_ERROR_FILE, SMS_MESSAGE_COMM_RECOVERY_FILE };
    u_char buf[NTSS_STR_MAX_SIZE * 2];
    u_char content[NTSS_STR_MAX_SIZE * 2];
    u_char smsContent[NTSS_STR_MAX_SIZE * 2];
    FILE *fp;

    // SMS通知メッセージ種類判定
    if( SMS_MESSAGE_ALARM <= nKind && nKind <= SMS_MESSAGE_COMM_RECOVERY )
    {
        content[0] = 0;

        // メッセージ取得
        if ((fp = fopen(msgfile[nKind], "r")) != NULL)
        {

            // 全文(最大：NTSS_STR_MAX_SIZE)を読み込む
            while( fgets( buf, sizeof( buf ), fp) != NULL )
            {
                strcat( content, buf );
            }
        }
        fclose(fp);

        // メッセージの差し替え処理を行う
        // 発生日時：{@OCCUR_DATETIME}
        strReplace( content, sizeof( content ), SMS_REPLASE_OCCUR_DATETIME, cOccurDateTime );
        // 装置型式：{@DEVICE_TYPE}
        strReplace( content, sizeof( content ), SMS_REPLASE_DEVICE_TYPE, cDeviceType );
        // SMS本文部分（施設名 + \n + メッセージ）
        snprintf(
            smsContent
            , sizeof( smsContent )
            , "%s\n%s"
            , cFacilityName
            , content
        );
        // SMS本文70文字切り出し
        subStr(smsContent, maxContentLength);

        // SMS通知メッセージ作成
        snprintf(
            cSMSMessage
            , nSize
            , "To: %s\nAlphabet: UTF-8\n\n%s"
            , cSMSTel
            , smsContent
        );

        ret = 1;
    }

    return ret;
}

/**
 * @brief SMS通知設定ファイルを読み込み、SMS通知先情報を取得する
 * 
 * @param[in]   cConfigFileName SMS通知設定ファイル名
 * @param[out]  cFacilityName   SMS通知先施設名
 * @param[out]  cSMSTel         SMS通知先電話番号
 * 
 * @return 1：取得成功/else：取得失敗
 */
int
getSMSSendTarget( u_char *cConfigFileName, u_char *cFacilityName, u_char *cSMSTel )
{
    int ret = 0;
    u_char facility[NTSS_STR_MAX_SIZE];
    u_char conf[7 * 10 + 20];
    FILE *fp;
    bool bSuccess = false;

    // // 設定ファイル読み込み
    // sprintf(logMessage, "SMS通知設定ファイル読み込み, %s", cConfigFileName );
    // LogOutput(NTSS_LOG_INFO, logMessage);
    if ((fp = fopen(cConfigFileName, "r")) != NULL)
    {
        // 1行目：設定した施設コード[6桁] + 通知先施設名
        if( fgets(facility, sizeof( facility ), fp) != NULL )
        {
            // 2行目：SMS通知設定
            if( fgets(conf, sizeof( conf ), fp) != NULL )
            {
                // 末尾の改行コード削除
                facility[strlen(facility) - 1] = 0;
                conf[strlen(conf) - 1] = 0;

                // SMS通知先施設を設定
                strcpy( cFacilityName, facility + 6 );
                // SMS通知先電話番号を設定
                strcpy( cSMSTel, conf + 7 * 10 );

                ret = 1;
            }
        }
    }
    fclose(fp);

    return ret;
}


/**
 * @brief SMS通知用ファイルを読み込み、SMS通知を行う
 * 
 * @param param 設定項目構造体
 * 
 * @return なし
 */
void
runNotice(ConfigParameter_t *param)
{
    MessageData_t msgData = {0};
    int32_t i, ret = 0;

    u_char cbuff[NTSS_STR_MAX_SIZE] = {0};
    u_char logMessage[MAX_LOG_TEXT] = {0};
    char *pathes[3] = {
        param->receiveDataDirectory,
        param->receiveDataDirectory2,
        param->receiveDataDirectory3};
    struct stat st, statBuf;
    char buf[255];
    char findPathes[512] = {0};
    char command[512] = {0};
    u_char path[255] = {0};
    u_char pathBuff[sizeof(path) + sizeof(FileData_t)] = {0};
    FileData_t fData = {0};
    u_char filePath[sizeof(FileData_t)];
    uint8_t dataBuff[255] = {0};
    u_char facilityName[NTSS_STR_MAX_SIZE];
    u_char smsTel[20];
    int findDir = 0;
    uint8_t catCode[5] = {0};
    u_char occurDateTime[15];
    u_char smsDeviceType[10];
    u_char cOccurDateTime[] = { "    /  /     :  \0"};
    u_char cContent[NTSS_STR_MAX_SIZE * 2];
    u_char smsFileName[NTSS_STR_MAX_SIZE];
    u_char smsFileName_SMS[NTSS_STR_MAX_SIZE];
    u_char smsFileName_Conf[NTSS_STR_MAX_SIZE];
    bool   bSMSFileDelete;
    FILE *fp;
    FILE *fp2;
	time_t tim;
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // u_char *SMS_SENDED_LIST_FILE = "./smsSendList.txt"; ///< SMS送信済みリストファイル
    u_char *SMS_SENDED_LIST_FILE = "/tmp/smsSendList.txt"; ///< SMS送信済みリストファイル
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end

    occurDateTime[14] = 0;

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
        LogOutput(NTSS_LOG_INFO, "SMS通知用ファイルのアクセス可能フォルダ無し");
        return;
    }

    sprintf(command, "find %s -maxdepth 1 -type f -name \"*.sms\" | xargs --no-run-if-empty ls -rt1", findPathes);
    if ((fp = popen(command, "r")) != NULL)
    {
        while (fgets(buf, NTSS_STR_MAX_SIZE, fp) != NULL)
        {
            // 末尾の改行コード削除
            buf[strlen(buf) - 1] = 0;
            strncpy(pathBuff, buf, sizeof(pathBuff));

            strncpy(fData.fileName, basename(buf), sizeof(fData.fileName));
            stat(pathBuff, &statBuf);
            strncpy(fData.fileDir, dirname(pathBuff), sizeof(fData.fileDir));
            fData.lastTime = statBuf.st_ctime;
            // ファイル名からtypeを取得
            fData.type = getTypeFromFileName(fData.fileName);

            // SMS通知先電話番号リストを削除する
            if( existFolderFile( SMS_SENDED_LIST_FILE, NULL ) == 1 )
            {
                removeFileFullPath( SMS_SENDED_LIST_FILE );
            }

            // SMSファイル削除フラグセット
            bSMSFileDelete = true;

            // ファイル読み込み
            sprintf(filePath, "%s/%s", fData.fileDir, fData.fileName);
            if (readBinaryFile(dataBuff, filePath) > 0)
            {
                // データを構造体に変換
                msgData = separateMessage(dataBuff, fData.type);

                //ファイル名の先頭+21の位置から3文字を構造体のmachineTypeCodeにコピー
                strncpy(msgData.machineTypeCode, fData.fileName + 21, 3);

                // ファイルパスを記憶
                sprintf(msgData.fileDir, "%s", fData.fileDir);
                sprintf(msgData.fileName, "%s", fData.fileName);

                // 装置記録コードを取得する
                getMsgMachineRecordCode(catCode, &msgData);
                catCode[4] = 0;

                // 変換失敗の可能性があるのでDEでの受信日時を発生日時の初期値とする
                memcpy( occurDateTime, msgData.fileName, 14 );

                // 装置からの発生日時を取得する
                tim = -1;
                memset( buf, 0, sizeof(buf ));
                if( msgData.type == MESSAGE_TYPE_IS_NKK )
                {
                    // 新通信
                    memcpy( buf, msgData.data + 3, 7 );
                    bcd_time( buf, &tim );
                }
                else if( msgData.type == MESSAGE_TYPE_IS_NX )
                {
                    // NX通信
                    memcpy( buf, msgData.data + 6, 8 );
                    // BCD8バイト→BCD7バイトに加工
                    buf[6] = buf[7];
                    bcd_time( buf, &tim );
                }
                if ( tim != -1 )
                {
                    // 発生日時を置き換える
                    time_str( tim, buf, buf + 20, 1 );
                    buf[4] = buf[7] = buf[22] = buf[25] = 0;
                    sprintf(
                            occurDateTime
                        , "%s%s%s%s%s%s"
                        , buf
                        , buf + 5
                        , buf + 8
                        , buf + 20
                        , buf + 23
                        , buf + 26
                    );
                }
                
                // SMS通知設定ファイル取得
                //sprintf(command, "find ./conf/sms/conf -maxdepth 1 -type f -name \"*.conf\" | xargs --no-run-if-empty grep -xil %s --line-buffered", catCode);
                //sprintf(command, "grep --line-buffered -xil %s ./conf/sms/conf/*.conf", catCode);
                sprintf(command, "grep -xil %s ./conf/sms/conf/*.conf", catCode);
                //strcpy(command, "find ./conf/sms/conf -maxdepth 1 -type f -name \"*.conf\"");
                if ((fp2 = popen(command, "r")) != NULL)
                {
                    while (fgets(buf, NTSS_STR_MAX_SIZE, fp2) != NULL)
                    {
                        // 末尾の改行コード削除
                        buf[strlen(buf) - 1] = 0;
                        strncpy(pathBuff, buf, sizeof(pathBuff));

                        //
                        sprintf(logMessage, "SMS通知設定ファイルに装置記録コードが登録済, %s, %s[%s]", pathBuff, filePath, catCode );
                        LogOutput(NTSS_LOG_INFO, logMessage);

                        // SMS設定ファイルを読み込み、装置記録コード、曜日、時間、通知有無をチェック
                        // 通知対象である場合は施設名、電話番号を返す
                        if( isSMSSendTarget( pathBuff, catCode, occurDateTime, facilityName, smsTel ) == 1 )
                        {
                            // 電話番号によるSMS未通知判定
                            if(checkSMSTel( SMS_SENDED_LIST_FILE, smsTel ) == 1 )
                            {
                                // 未通知の電話番号なのでSMS通知を実施

                                // 対象ファイルを通知対象として記録する
                                sprintf(logMessage, "SMS通知対象, %s[%s], %s", filePath, catCode, pathBuff );
                                LogOutput(NTSS_LOG_INFO, logMessage);
                                sprintf(buf, "[%s : %s]", facilityName, smsTel );
                                strcat(logMessage, buf );
                                printf( "%s\n", logMessage );

                                // SMS通知用装置型式を取得する
                                getSMSDeviceType( msgData.type, msgData.fmt[0], smsDeviceType );
                                printf( "SMS DeviceType : %s\n", smsDeviceType );

                                // 発生日時を整形
                                memcpy( cOccurDateTime, occurDateTime, 4 );
                                memcpy( cOccurDateTime + 5, occurDateTime + 4, 2 );
                                memcpy( cOccurDateTime + 8, occurDateTime + 6, 2 );
                                memcpy( cOccurDateTime + 11, occurDateTime + 8, 2 );
                                memcpy( cOccurDateTime + 14, occurDateTime + 10, 2 );
                                //memcpy( cOccurDateTime + 17, occurDateTime + 12, 2 );

                                // SMS通知メッセージを作成
                                if( makeSMSMessage( SMS_MESSAGE_ALARM, cOccurDateTime, smsDeviceType, facilityName, smsTel, sizeof( cContent), cContent) == 1 )
                                {
                                    // メッセージ作成成功

                                    printf( "SMS Message:%s\n", cContent );

                                    // 各ファイル名を整形
                                    smsFileName_SMS[0] = smsFileName_Conf[0] = 0;
                                    strncpy(smsFileName_SMS, basename(msgData.fileName), sizeof(smsFileName_SMS));
                                    strncpy(smsFileName_Conf, basename(pathBuff), sizeof(smsFileName_Conf));
                                    // 拡張子除去
                                    smsFileName_SMS[strlen(smsFileName_SMS) - 4] = 0;
                                    smsFileName_Conf[strlen(smsFileName_Conf) - 5] = 0;

                                    // SMS通知メッセージファイル名：
                                    //  元のSMS通知用ファイル名(拡張子なし)
                                    //      + '_' + 装置記録コード
                                    //      + '_' + SMS通知設定ファイル名(拡張子なし)
                                    //      + ".txt"
                                    sprintf(
                                          smsFileName
                                        , "%s/%s_%s_%s.txt"
                                        , requestDirectory
                                        , smsFileName_SMS
                                        , catCode
                                        , smsFileName_Conf
                                    );

                                    // 通知依頼
                                    if( outputFile( smsFileName, cContent, strlen( cContent )) == 1 )
                                    {
                                        // 通知成功

                                        sprintf(logMessage, "SMS通知依頼に成功, %s", smsFileName);
                                        LogOutput(NTSS_LOG_INFO, logMessage);
    
                                        // SMS通知済みファイルにSMS通知先電話番号を登録
                                        sprintf(
                                            buf
                                            , "%s\n"
                                            , smsTel );
                                        outputAppendFile( SMS_SENDED_LIST_FILE, buf, strlen( buf ));
                                    }
                                    else
                                    {
                                        // 通知失敗

                                        // 通知依頼先フォルダの存在判定
                                        if( existFolderFile( requestDirectory, NULL ) == 1 )
                                        {
                                            // 通知依頼先フォルダが存在している場合

                                            sprintf(logMessage, "SMS通知依頼に失敗, %s", smsFileName);
                                            LogOutput(NTSS_LOG_ERROR, logMessage);

                                            // SMSファイル削除フラグクリア
                                            bSMSFileDelete = false;
                                        }
                                        else
                                        {
                                            // 通知依頼先フォルダが存在していない場合

                                            sprintf(logMessage, "SMS通知依頼先フォルダがないため通知不可, %s", smsFileName);
                                            LogOutput(NTSS_LOG_ERROR, logMessage);
                                        }
                                    }
                                    printf( "%s\n", logMessage );
                                }
                                else
                                {
                                    // メッセージ作成失敗
                                    sprintf(logMessage, "SMS通知メッセージの作成に失敗, %s[%s], %s", filePath, catCode, pathBuff );
                                    LogOutput(NTSS_LOG_ERROR, logMessage);

                                    // SMSファイル削除フラグクリア
                                    bSMSFileDelete = false;
                                }
                            }
                            else
                            {
                                // すでに通知済みの電話番号

                                // 対象ファイルを通知済みとして記録する
                                sprintf(logMessage, "SMS通知対象(通知済み), %s[%s], %s", filePath, catCode, pathBuff );
                                LogOutput(NTSS_LOG_INFO, logMessage);
                                sprintf(buf, "[%s : %s]", facilityName, smsTel );
                                strcat(logMessage, buf );
                                printf( "%s\n", logMessage );
                            }
                        }
                    }
                }
                pclose(fp2);
            }

            // SMS通知用ファイルを削除する
            if( bSMSFileDelete == true )
            {
                removeFileFullPath( filePath );
            }
        }
    }
    pclose(fp);

    // SMS通知先電話番号リストを削除する
    if( existFolderFile( SMS_SENDED_LIST_FILE, NULL ) == 1 )
    {
        removeFileFullPath( SMS_SENDED_LIST_FILE );
    }
}

/**
 * @brief SMS通知用ファイルを読み込み、通信異常/復旧SMS通知を行う
 * 
 * @param param 設定項目構造体
 * 
 * @return なし
 */
void
runCommNotice(ConfigParameter_t *param)
{
    int32_t i, ret = 0;

    u_char cbuff[NTSS_STR_MAX_SIZE] = {0};
    u_char logMessage[MAX_LOG_TEXT] = {0};
    char buf[NTSS_STR_MAX_SIZE];
    char command[NTSS_STR_MAX_SIZE * 2] = {0};
    u_char pathBuff[NTSS_STR_MAX_SIZE] = {0};
    u_char filePath[sizeof(FileData_t)];
    uint8_t dataBuff[255] = {0};
    u_char facilityName[NTSS_STR_MAX_SIZE];
    u_char smsTel[20];
    u_char cOccurDateTime[20];
    u_char cContent[NTSS_STR_MAX_SIZE * 2];
    u_char smsFileName[NTSS_STR_MAX_SIZE];
    u_char smsFileName_Conf[NTSS_STR_MAX_SIZE];
    u_char *cCommState[] = { "", "異常", "復旧" };
    u_char *cCommCode[] = { "NONE", "COMM_ERROR", "COMM_RECOVERY"};
    int nCommState = SMS_MESSAGE_ALARM;
    FILE *fp;
    time_t tim;
    struct tm tmc;
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // u_char *SMS_SENDED_LIST_FILE = "./smsCommSendList.txt"; ///< SMS送信済みリストファイル
    u_char *SMS_SENDED_LIST_FILE = "/tmp/smsCommSendList.txt"; ///< SMS送信済みリストファイル
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end


    // 通信異常/復旧時のSMS通知の有無判定
    if( changeCommStateSend == 1 )
    {
        // 通信異常/復旧時のSMS通知あり

        // 通信異常/復旧が発生したかどうかを判定
        if( bSMSCommDisabled != getIsDisabledCallApi())
        {
            // SMS通知が必要

            // 現在の通信状態を取得
            nCommState = SMS_MESSAGE_COMM_ERROR;
            bSMSCommDisabled = getIsDisabledCallApi();
            if( bSMSCommDisabled == false )
            {
                nCommState = SMS_MESSAGE_COMM_RECOVERY;
            }


            // 現在値取得
            time( &tim );
            localtime_r( &tim, &tmc );

            // 発生日時作成
            sprintf(
                cOccurDateTime
                , "%04d/%02d/%02d %02d:%02d"
                , tmc.tm_year + 1900
                , tmc.tm_mon + 1
                , tmc.tm_mday
                , tmc.tm_hour
                , tmc.tm_min
            );

            // SMS通知先電話番号リストを削除する
            if( existFolderFile( SMS_SENDED_LIST_FILE, NULL ) == 1 )
            {
                removeFileFullPath( SMS_SENDED_LIST_FILE );
            }

            // SMS通知設定ファイル取得
            strcpy(command, "find ./conf/sms/conf -maxdepth 1 -type f -name \"*.conf\"");
            if ((fp = popen(command, "r")) != NULL)
            {
                while (fgets(buf, NTSS_STR_MAX_SIZE, fp) != NULL)
                {
                    // 末尾の改行コード削除
                    buf[strlen(buf) - 1] = 0;
                    strncpy(pathBuff, buf, sizeof(pathBuff));

                    // SMS設定ファイルから施設名、電話番号を取得する
                    if( getSMSSendTarget( pathBuff, facilityName, smsTel ) == 1 )
                    {
                        // 取得成功

                        // 電話番号によるSMS未通知判定
                        if(checkSMSTel( SMS_SENDED_LIST_FILE, smsTel ) == 1 )
                        {
                            // 未通知の電話番号なのでSMS通知を実施

                            // 対象ファイルを通知対象として記録する
                            sprintf(logMessage, "通信%sのためSMS通知, %s", cCommState[nCommState], pathBuff );
                            LogOutput(NTSS_LOG_INFO, logMessage);
                            sprintf(buf, "[%s : %s]", facilityName, smsTel );
                            strcat(logMessage, buf );
                            printf( "%s\n", logMessage );

                            // SMS通知メッセージを作成
                            if( makeSMSMessage( nCommState, cOccurDateTime, "", facilityName, smsTel, sizeof( cContent), cContent) == 1 )
                            {
                                // メッセージ作成成功

                                printf( "SMS Message:%s\n", cContent );

                                // SMS通知設定ファイル名を整形
                                smsFileName_Conf[0] = 0;
                                strncpy(smsFileName_Conf, basename(pathBuff), sizeof(smsFileName_Conf));
                                // 拡張子除去
                                smsFileName_Conf[strlen(smsFileName_Conf) - 5] = 0;

                                // SMS通知メッセージファイル名：
                                //  発生日時(YYYYMMSSHHNNSS)
                                //      + '_' + 通信状態(COMM_ERROR/COMM_RECOVERY)
                                //      + '_' + SMS通知設定ファイル名(拡張子なし)
                                //      + ".txt"
                                sprintf(
                                        smsFileName
                                    , "%s/%04d%02d%02d%02d%02d%02d_%s_%s.txt"
                                    , requestDirectory
                                    , tmc.tm_year + 1900
                                    , tmc.tm_mon + 1
                                    , tmc.tm_mday
                                    , tmc.tm_hour
                                    , tmc.tm_min
                                    , tmc.tm_sec
                                    , cCommCode[nCommState]
                                    , smsFileName_Conf
                                );

                                // 通知依頼
                                if( outputFile( smsFileName, cContent, strlen( cContent )) == 1 )
                                {
                                    // 通知成功

                                    sprintf(logMessage, "SMS通知依頼に成功, %s", smsFileName);
                                    LogOutput(NTSS_LOG_INFO, logMessage);

                                    // SMS通知済みファイルにSMS通知先電話番号を登録
                                    sprintf(
                                        buf
                                        , "%s\n"
                                        , smsTel );
                                    outputAppendFile( SMS_SENDED_LIST_FILE, buf, strlen( buf ));
                                }
                                else
                                {
                                    // 通知失敗

                                    // 通知依頼先フォルダの存在判定
                                    if( existFolderFile( requestDirectory, NULL ) == 1 )
                                    {
                                        // 通知依頼先フォルダが存在している場合

                                        sprintf(logMessage, "SMS通知依頼に失敗, %s", smsFileName);
                                        LogOutput(NTSS_LOG_ERROR, logMessage);
                                    }
                                    else
                                    {
                                        // 通知依頼先フォルダが存在していない場合

                                        sprintf(logMessage, "SMS通知依頼先フォルダがないため通知不可, %s", smsFileName);
                                        LogOutput(NTSS_LOG_ERROR, logMessage);
                                    }
                                }
                                printf( "%s\n", logMessage );
                            }
                            else
                            {
                                // メッセージ作成失敗
                                sprintf(logMessage, "通信%sのためのSMS通知メッセージの作成に失敗, %s", cCommState[nCommState], pathBuff );
                                LogOutput(NTSS_LOG_ERROR, logMessage);
                            }
                        }
                        else
                        {
                            // すでに通知済みの電話番号

                            // 対象ファイルを通知済みとして記録する
                            sprintf(logMessage, "通信%sのためSMS通知(通知済み), %s", cCommState[nCommState], pathBuff );
                            LogOutput(NTSS_LOG_INFO, logMessage);
                            sprintf(buf, "[%s : %s]", facilityName, smsTel );
                            strcat(logMessage, buf );
                            printf( "%s\n", logMessage );
                        }
                    }
                }
            }
            pclose(fp);

            // SMS通知先電話番号リストを削除する
            if( existFolderFile( SMS_SENDED_LIST_FILE, NULL ) == 1 )
            {
                removeFileFullPath( SMS_SENDED_LIST_FILE );
            }
        }
    }
}

/**
* @brief SMS Toolサービスを再起動する
*
* @details SMS Toolサービスを再起動する
* 
* @description
* @return なし
* @attention 特になし
*/
void restartSmsToolService()
{
    char command[512] = {0};

    // 処理定義
    strcpy( command, "sudo service smstools restart" );

    // コマンド実行
    system(command);
}

/**
* @brief SMS通知結果を記録する
*
* @details SMS通知結果を対象フォルダから取得し記録する＋状態によりSMSToolsサービスを再起動する
* 
* @description
* @return なし
* @attention 特になし
*/
void 
runWriteResult()
{
    u_char logMessage[MAX_LOG_TEXT] = {0};
    char command[512] = {0};
    u_char cbuff[NTSS_STR_MAX_SIZE] = {0};
    u_char pathBuff[NTSS_STR_MAX_SIZE] = {0};
    u_char filename[NTSS_STR_MAX_SIZE] = {0};
    FILE *fp;
    bool bSmsToolsRestart = true;

    // 通知成功フォルダからファイルの一覧を取得する
    sprintf(command, "find %s -maxdepth 1 -type f -name \"*.txt\" 2> /dev/null", successDirectory);
    if ((fp = popen(command, "r")) != NULL)
    {
        while (fgets(cbuff, NTSS_STR_MAX_SIZE, fp) != NULL)
        {
            cbuff[strlen(cbuff) - 1] = 0;   // 末尾の改行コード無視
            strncpy(pathBuff, cbuff, sizeof(pathBuff));

            // 対象ファイルを通知成功として記録する
            sprintf(logMessage, "SMS通知成功, %s", pathBuff );
            LogOutput(NTSS_LOG_INFO, logMessage);

            // 対象ファイルを削除する
            removeFileFullPath(pathBuff);
        }
    }
    pclose(fp);

    // 通知失敗フォルダからファイルの一覧を取得する
    sprintf(command, "find %s -maxdepth 1 -type f -name \"*.txt\" 2> /dev/null", failedDirectory);
    if ((fp = popen(command, "r")) != NULL)
    {
        while (fgets(cbuff, NTSS_STR_MAX_SIZE, fp) != NULL)
        {
            cbuff[strlen(cbuff) - 1] = 0;   // 末尾の改行コード無視
            strncpy(pathBuff, cbuff, sizeof(pathBuff));

            // smstoolsを再起動
            if( bSmsToolsRestart == true )
            {
                sprintf(logMessage, "SMS通知失敗を検出したためSMSTOOLSサービスを再起動" );
                LogOutput(NTSS_LOG_INFO, logMessage);

                // SMSToolsサービスを再起動
                restartSmsToolService();

                bSmsToolsRestart = false;
            }

            // 対象ファイルを通知失敗として記録する
            sprintf(logMessage, "SMS通知失敗, %s", pathBuff );
            LogOutput(NTSS_LOG_ERROR, logMessage);

            // 対象ファイルの再送チェック
            strncpy( cbuff, basename(pathBuff), sizeof( cbuff ));
            sprintf(logMessage, "SMS通知失敗 file, %s", cbuff );
            LogOutput(NTSS_LOG_ERROR, logMessage);
            if( cbuff[0] == 'R' && cbuff[1] == '2')
            {
                // 2回目の再送失敗

                // 対象ファイルを削除する
                removeFileFullPath(pathBuff);
            }
            else
            {
                // 再送対象判定
                if( cbuff[0] == 'R' )
                {
                    // 再送対象

                    // 再送信対象ファイルの再送回数を加算
                    cbuff[1] += 1;
                }
                else
                {
                    // 未送信対象

                    // 再送信対象ファイルの先頭に再通知情報を付加する
                    sprintf( filename, "R1_%s", cbuff );
                    strcpy( cbuff, filename );
                }

                // 再送依頼
                snprintf(
                      filename
                    , sizeof(filename)
                    , "%s/%s"
                    , requestDirectory
                    , cbuff
                );
                moveFile( pathBuff, filename, NTSS_MOVEFILE_MODE_OVERWRITE );

                sprintf(logMessage, "SMS再送通知, %s->%s", pathBuff, filename );
                LogOutput(NTSS_LOG_INFO, logMessage);
            }
        }
    }
    pclose(fp);

    // 通知チェックフォルダから設定時間(分)以上前に更新したファイルの一覧を取得する
    sprintf(command, "find %s -maxdepth 1 -mmin +%d -type f -name \"*.txt\" 2> /dev/null", checkedDirectory, checkedSMSErrorTime);
    if ((fp = popen(command, "r")) != NULL)
    {
        while (fgets(cbuff, NTSS_STR_MAX_SIZE, fp) != NULL)
        {
            // 10分以上前に更新したファイルがある場合

            sprintf(logMessage, "通知チェックフォルダに%d分以上前の未処理ファイルがあることを検出したためSMSTOOLSサービスを再起動", checkedSMSErrorTime );
            LogOutput(NTSS_LOG_INFO, logMessage);

            // SMSToolsサービスを再起動
            restartSmsToolService();

            break;
        }
    }
    pclose(fp);
}

/**
* @brief SMS受信ファイルを削除する
*
* @details SMS受信フォルダ内の受信ファイルを削除する
* 
* @param ptr ポインタ
* @description
* @return なし
* @attention 特になし
*/
void
runDeleteReceive()
{
    u_char logMessage[MAX_LOG_TEXT] = {0};
    char command[512] = {0};
    u_char cbuff[NTSS_STR_MAX_SIZE] = {0};
    u_char pathBuff[NTSS_STR_MAX_SIZE] = {0};
    FILE *fp;

    // 受信フォルダからファイルの一覧を取得する
    sprintf(command, "find %s -maxdepth 1 -type f -name \"*.*\" 2> /dev/null", receiveDirectory);
    if ((fp = popen(command, "r")) != NULL)
    {
        while (fgets(cbuff, NTSS_STR_MAX_SIZE, fp) != NULL)
        {
            cbuff[strlen(cbuff) - 1] = 0;   // 末尾の改行コード無視
            strncpy(pathBuff, cbuff, sizeof(pathBuff));

            // 対象ファイルを受信ファイルとして記録する
            sprintf(logMessage, "SMS受信, %s", pathBuff );
            LogOutput(NTSS_LOG_INFO, logMessage);

            // 対象ファイルを削除する
            removeFileFullPath(pathBuff);
        }
    }
    pclose(fp);
}

/**
* @brief REST API (GET)を呼び出して応答を取得
*
* @details REST API (GET)を呼び出して応答を取得
*
* @param restGetApiUrl 対象REST APIのURL
* @param recvFile 応答内容を格納するファイル名
* @param logPrefix ログメッセージ先頭に記述するテキスト
* @description
* @return 0:成功 その他:失敗
* @attention 特になし
*/
int32_t
requestGetRestApi(char *restGetApiUrl, char *recvFile, char *logPrefix) {
    int32_t ret = 0;
    u_char logMessage[MAX_LOG_TEXT] = {0};
	u_char cbuff[NTSS_STR_MAX_SIZE] = {0};
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // char *responseFile = "./tmpSMSResponseCode.txt";
    // char *errFile = "./tmpSMSErrResponseCode.txt";
    char *responseFile = "/tmp/tmpSMSResponseCode.txt";
    char *errFile = "/tmp/tmpSMSErrResponseCode.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 start
    //u_char responseCode[255] = {0};
    // #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 end
    snprintf(logMessage, MAX_LOG_TEXT, "%s RESTコール, (%s)", logPrefix, restGetApiUrl);
    LogOutput(NTSS_LOG_INFO, logMessage);

    // RESTをコールする
    sprintf(
        cbuff, "./sh/get_request.sh \"%s\" \"%s\" \"%s\" \"%s\"", restGetApiUrl, recvFile, responseFile, errFile);
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
        snprintf(logMessage, MAX_LOG_TEXT, "%s REST 応答あり, (%s)", logPrefix, responseCode);
    }
    else
    {
        snprintf(logMessage, MAX_LOG_TEXT, "%s REST 実行システムコール応答, (%d)", logPrefix, ret);
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
        snprintf(logMessage, MAX_LOG_TEXT, "%s REST 失敗応答を取得, (%s)", logPrefix, responseCode);
        LogResourceOutput(NTSS_LOG_ERROR, logMessage);
    }
    removeFileFullPath(responseFile);
    removeFileFullPath(errFile);
    */
    // RESTコールして結果を取得する
    ret = ntss_restcall("", "", cbuff, responseFile, errFile, logPrefix);
    // #8729 2023.05.29 mod REST取得結果によるリトライ処理 TDC高村 end

    return ret;

}

/**
* @brief SMS通知監視・通知処理(スレッド)
*
* @details SMS通知監視・通知処理を行う
* 
* @param ptr ポインタ
* @description
* @return なし
* @attention 特になし
*/
void *
smsNoticeThread(void *ptr)
{
	ThreadParameter_t *state = (ThreadParameter_t *)ptr;

    u_char logMessage[MAX_LOG_TEXT] = {0};
	u_char restGetCdList[NTSS_STR_MAX_SIZE + 34] = {0};
	u_char restGetConf[NTSS_STR_MAX_SIZE + 25] = {0};
	u_char cbuff[NTSS_STR_MAX_SIZE] = {0};
	u_char msg[MAX_LOG_TEXT] = {0};
	u_char rcd[10] = {0};
	int loopCount;
    int32_t ret = 0;
    FILE *fp;

    char targetCode[20] = {0};

    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // char *cdListFile = "./tempCdList.txt";
    // char *responseFile = "./tmpSMSConfResponseCode.txt";
    // char *errFile = "./tmpSMSConfErrResponseCode.txt";
    char *cdListFile = "/tmp/tempCdList.txt";
    char *responseFile = "/tmp/tmpSMSConfResponseCode.txt";
    char *errFile = "/tmp/tmpSMSConfErrResponseCode.txt";
    // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
    char *confFolder = "./conf/sms/conf";
    char *confFileBase = "./conf/sms/conf/target_%s.conf";
    char confFileName[100] = {0};

	LogOutput(NTSS_LOG_INFO, "SMS通知スレッド開始");

    // REST API用ＵＲＬ作成
	sprintf(restGetCdList, "%s/%s/%s", state->configParam.awsHostUrl, API_SMS_CD_LIST, state->configParam.facilityCode);
    // 現在の通信状態を取得
    bSMSCommDisabled = getIsDisabledCallApi();

	// 処理開始日時を設定
	time_t last_ws_chk_time = 0;
	time_t tnow;
	time_t last_ws_chk_time2 = 0;

	// 500ms
	struct timespec timeReq500ms = {0, 5 * 100 * 1000000};
    // 30s
	struct timespec timeReq30s = {30, 0};

	while (state->isRunning)
	{
        // 現在値取得
        time(&tnow);


        // #10437 2024.05.18 mod SMS通知結果の記録(再送、SMSTOOLSサービスの再起動含む)、受信ファイル削除処理のタイミングをもとに戻す TDC米沢 start
        // // #10437 2024.03.26 mod DEログに実行モジュールのリビジョンを出力する TDC高村 start
        // /*
        // // 一定間隔(60秒間隔)でSMS通知が動作していることをログに記録する
        // if ((last_ws_chk_time + 60) <= tnow)
        // {
        //     LogOutput(NTSS_LOG_INFO, "SMS通知スレッド実行中...");
        // */
        // // 一定間隔(180秒間隔)でSMS通知が動作していることをログに記録する
        // if ((last_ws_chk_time + 180) <= tnow)
        // {
        //     //LogOutput(NTSS_LOG_INFO, "SMS通知スレッド実行中...");
        //     snprintf(logMessage, MAX_LOG_TEXT, "正常動作中[Rev:%s]...", RELEASE_REVISION);
        //     LogOutput(NTSS_LOG_INFO, logMessage);
        //     // #10437 2024.03.26 mod DEログに実行モジュールのリビジョンを出力する TDC高村 end

        //     // 通知結果記録
        //     runWriteResult();

        //     // 受信ファイル削除
        //     runDeleteReceive();

        //     // 処理開始日時を保持
        //     last_ws_chk_time = tnow;
        // }
        // 一定間隔(60秒間隔)でSMS通知結果記録(再送、SMSTOOLSサービスの再起動含む)、受信ファイル削除処理
        if ((last_ws_chk_time + 60) <= tnow)
        {
            // 通知結果記録
            runWriteResult();

            // 受信ファイル削除
            runDeleteReceive();

            // 処理開始日時を保持
            last_ws_chk_time = tnow;
        }

        // 一定間隔(180秒間隔)でSMS通知が動作していることをログに記録する
        if ((last_ws_chk_time2 + 180) <= tnow)
        {
            snprintf(logMessage, MAX_LOG_TEXT, "正常動作中[Rev:%s]...", RELEASE_REVISION);
            LogOutput(NTSS_LOG_INFO, logMessage);
            
            // 処理開始日時を保持
            last_ws_chk_time2 = tnow;
        }
        // #10437 2024.05.18 mod SMS通知結果の記録(再送、SMSTOOLSサービスの再起動含む)、受信ファイル削除処理のタイミングをもとに戻す TDC米沢 end


		// sleep
		nanosleep(&timeReq500ms, NULL);

		//! マスタ読み込みが必要ならば読み込み
		if (state->mstReload)
		{
            if (getIsDisabledCallApi())
            {
                // クラウド通信不可フラグがONの場合、REST APIコール失敗時と同様の処理を行う
                snprintf(logMessage, MAX_LOG_TEXT, "SMS通知設定取得 REST API 通信不可状態のため処理スキップ");
                LogResourceOutput(NTSS_LOG_INFO, logMessage);

                // 30秒待ち
                nanosleep(&timeReq30s, NULL);
            } else {
                ret = requestGetRestApi(restGetCdList, cdListFile, "SMS通知設定先リスト取得");
                if (ret == 0)
                {
                    // リスト取得に成功していたら各項目について設定取得
                    // 1 既存のconfファイル削除
                    deleteFolderInFiles(confFolder);
                    // 2 リストを開く
                    if ((fp = fopen(cdListFile, "r")) != NULL)
                    {
                        // 3 リスト内容で1件ずつ設定を取得

                        // 1行取得
                        while( fgets( targetCode, sizeof( targetCode ), fp) != NULL)
                        {
                            // 末尾のLFを除去
                            trimEnd( targetCode, '\n' );
                            if (strlen(targetCode) == 0) {
                                // 取得したコードが空行ならば次の行へ（おそらく最終行）
                                continue;
                            }
                            // URL作成
                            sprintf(restGetConf, "%s/%s/%s", state->configParam.awsHostUrl, API_SMS_CONF, targetCode);
                            sprintf(confFileName, confFileBase, targetCode);
                            ret = requestGetRestApi(restGetConf, confFileName, "SMS設定取得");
                            if (ret != 0)
                            {
                                // 設定取得失敗
                                snprintf(logMessage, MAX_LOG_TEXT, "SMS設定取得 失敗 (%s)", confFileName);
                                LogResourceOutput(NTSS_LOG_INFO, logMessage);
                                break;
                            }
                            snprintf(logMessage, MAX_LOG_TEXT, "SMS設定取得 成功 (%s)", confFileName);
                            LogResourceOutput(NTSS_LOG_INFO, logMessage);
                        }
                        // 4 全部成功したらマスタ読み込みフラグを戻す
                        if (ret == 0) {
                            LogResourceOutput(NTSS_LOG_INFO, "SMS通知設定取得処理完了");
                            state->mstReload = false;
                        }
                        fclose(fp);
                    }
                }
                // リストファイルを削除
                removeFileFullPath(cdListFile);
            }
		} else {
            // マスタ更新のない場合にのみＳＭＳ通知作業

            // 通信異常/復旧通知
            runCommNotice(&(state->configParam));
            // SMS通知
            runNotice(&(state->configParam));
        }

        // #12406 2025.12.01 add 正常動作確認用カウンタ加算 TDC米沢 start
        // スレッド動作確認用カウンタ加算
        nSMSThreadRunningCount++;
        // #12406 2025.12.01 add 正常動作確認用カウンタ加算 TDC米沢 end
	}

	LogOutput(NTSS_LOG_INFO, "SMS通知スレッド終了");
}
