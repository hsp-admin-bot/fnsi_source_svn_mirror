#ifndef _STRUCT_DATA_H_
#define _STRUCT_DATA_H_

#include <stdint.h>
#include <stdbool.h>
#include <sys/types.h>

#define MAX_LOG_TEXT 4095
// #8729 2023.05.29 add RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
#define MAX_DATASIZE 2048
// #8729 2023.05.29 add RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end

#define TOPIC_UPDATE            "NTSS/UPDATE"       // ソフト更新トピック
#define TOPIC_RESTORE           "NTSS/RESTORE"      // レストア用トピック
#define TOPIC_LOG_GATHER        "NTSS/LOG_GATHER"   // ログ収集命令トピック
#define TOPIC_NTSS_REBOOT       "NTSS/NTSS_REBOOT"  // NTSSサービス再起動トピック
#define TOPIC_NTSS_STOP         "NTSS/NTSS_STOP"  // NTSSサービス停止トピック
#define TOPIC_NTSS_START        "NTSS/NTSS_START"  // NTSSサービス停止トピック
#define TOPIC_DE_REBOOT         "NTSS/DE_REBOOT"    // デバイス再起動トピック
#define TOPIC_CONF_GATHER       "NTSS/CONF_GATHER"    // 設定収集トピック
#define TOPIC_CONF_UPDATE       "NTSS/CONF_UPDATE"    // 設定適用トピック
#define TOPIC_PLAN_CANCEL       "NTSS/PLAN_CANCEL"    // 予約キャンセルトピック

#define API_SEND_WEBSOCKET	    "ntss-client-comm/api/sendmessage"
#define API_UPDATER_RESPONSE	"device_edge_updater/api/update/response"
#define API_VERSION_NOTICE      "device_edge_updater/api/device_edge_version"
#define API_PLAN_UPDATE         "device_edge_updater/api/plan/update"
#define API_DOWNLOAD	        "device_edge/api/s3/download"

#define CONFIG_FILE             "./conf/ntss_updater.conf"
#define CONFIG_NETWORK_FILE     "./conf/ntss_updater_network.conf"

#define BK_UPD_DIR              "../ntss_backup_upd/"
#define BK_MAIN_DIR             "../ntss_backup_main/"
#define UPD_DIR                 "upd_dir/"
#define UPD_MY_FILE             "ntss_updater.exe"
#define UPD_MY_CONFIG_FILE      "conf/ntss_updater.conf"
#define UPD_MY_VERSION_FILE     "version/updater_version.dat"
#define RESTORE_DIR_MAIN        "restore_main/"

#define LOGGER_NAME             "ntss_logger.exe"

#define PLAN_FILE               "./update.plan"

/**
 * @def
 * 配列数を求めるマクロ
 * 
 */
#define COUNTOF(array) (sizeof(array) / sizeof(array[0]))

typedef struct {
    u_char awsHostUrl[255];            // 接続先URL
    u_char websockHostUrl[255];         // websocket接続先URL
    u_char facilityCode[7];             // 施設コード
    int16_t deviceNo;                   // デバイスエッジ番号
    u_char zipPassword[64];             //ZIP圧縮パスワード
    u_char dlFolder[3][128];              //ダウンロードフォルダ

    u_char uploadConfS3Path[256];       // Confアップロードフォルダ
    uint16_t uploadLimitFileSize;       // アップロード最大サイズ
    int nUploadRetryCount;              // アップロードリトライ回数
    int nUploadRetryWaitTime;           // アップロードリトライ待機時間
    int16_t webSocketKeepAliveInterval; // WebSocket KeepAlive通知間隔(秒単位)
} ConfigParameter_t;

typedef struct {
    bool	isRunning;    // 実行中フラグ
} ThreadParameter_t;
 
typedef struct {
    bool	isRunning;    // 実行中フラグ
    bool	isRcvSignal;    // シグナル受信フラグ
    u_char  exitMessage[255]; // 終了ログ
} RunningParameter_t;

typedef struct {
    u_char planDateTime[16];    // 予定時刻
    u_char updateFolderPath[512];   // 更新用ファイル格納フォルダ
    u_char seqNo[21];   // シーケンス番号
    u_char kind[11];    // 更新種別
    u_char information[1025];   // 電文
} PlanParameter_t;

#endif // _STRUCT_DATA_H_
