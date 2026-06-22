#ifndef _STRUCT_DATA_H_
#define _STRUCT_DATA_H_
 
#include <stdint.h>
#include <stdbool.h>
#include <sys/types.h>

#define MAX_LOG_TEXT 4095

#define TOPIC_COMMON_ALIVE      "NTSS/ALIVE_MONI"   // 装置死活情報トピック
#define TOPIC_PUBLISH_NOTICE    "NTSS/M_NOTICE"     // 緊急発報トピック
#define TOPIC_COMMON_GATHER     "NTSS/GATHERING"    // FTPデータ収集トピック
#define TOPIC_SUBSCRIBE_MST     "NTSS/MST_SYNCHRO"  // マスタ同期トピック
#define TOPIC_RESTORE           "NTSS/RESTORE"      // レストア用トピック
#define TOPIC_NTSS_REBOOT       "NTSS/NTSS_REBOOT"  // NTSSアップデータサービス再起動トピック
#define TOPIC_DE_REBOOT         "NTSS/DE_REBOOT"    // デバイス再起動トピック
#define TOPIC_CHANGE_MODE       "NTSS/CHANGE_MODE"  // モード変更通知トピック
// add FNSI-バグ 通信サーバ 高 start
#define TOPIC_PROCESS_STATE     "NTSS/PROCESS_STATE"   // 装置工程トピック
// add FNSI-バグ 通信サーバ 高 end

#define TOPIC_COMSV             "COMSV"        // 通信サーバー向け指示用トピック
#define SUB_TOPIC_SEND_CONDITION    "1"             // 条件送信通知トピック
#define SUB_TOPIC_READ_OPTION       "2"             // 装置オプション読出し通知トピック
#define SUB_TOPIC_READ_CONFIG       "3"             // 設定値読出し通知トピック
#define SUB_TOPIC_READ_NEXT_PAT     "4"             // 次患者読出し通知トピック
#define SUB_TOPIC_RELOAD_SV_CONF    "5"             // 通信サーバー設定更新指示トピック
#define SUB_TOPIC_RELOAD_TREAT      "6"             // 愁訴処置マスタ方針指示トピック
#define SUB_TOPIC_RELOAD_STAFF      "7"             // スタッフマスタ方針指示トピック

#define BK_UPD_DIR              "../ntss_backup_upd/"
#define BK_MAIN_DIR             "../ntss_backup_main/"
#define UPD_DIR                 "upd_dir/"
#define UPD_MY_FILE             "ntss_updater.exe"
#define UPD_MY_CONFIG_FILE      "conf/ntss_updater.conf"
#define UPD_MY_VERSION_FILE     "version/updater_version.dat"
#define RESTORE_DIR_UPD        "restore_upd/"

#define API_M_NOTICE		"ntss-m-notice/api/alerts"
#define API_ALIVE_MONI		"alive_moni/api/response"
#define API_DATA_COLLECT	"data_gathering/api/response"
#define API_FILE_UPLOAD		"device_edge/api/post_file"
#define API_SEND_WEBSOCKET	"ntss-client-comm/api/sendmessage"
#define API_UPDATER_RESPONSE	"device_edge_updater/api/update/response"
#define API_HOST_WATCH_NOTICE   "device_edge/api/notification/host-alarm"

#define MST_INFO "machineInfoData.dat"
#define MST_RECORDS "machineRecords.dat"
#define MST_RECORDS_GREP_FILE "grepMachineRecords.dat"
#define CONFIG_FILE "./conf/ntss_main.conf"
#define CONFIG_COMMON_FILE "./conf/ntss_common.conf"
#define CONFIG_NETWORK_FILE "./conf/ntss_network.conf"
// #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 start
#define CONFIG_COMM_FAIL_FILE "./conf/ntss_comm_fail.conf"  ///< 通信サーバ通信異常時設定ファイル名
// #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 end

// #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
// #define RESULT_FILE_CONTENT         "./RESULT_DATACOLLECT_CONTENT_%s.TXT"
// #define RESULT_FILE_FILENAME        "./RESULT_DATACOLLECT_FILENAME_%s.TXT"
// #define RESULT_FILE_FILEPATH        "./RESULT_DATACOLLECT_FILEPATH_%s.TXT"
// #define RESULT_FTP_SCHEDULE_FILE    "./RESULT_DATACOLLECT_CONTENT.TXT"
#define RESULT_FILE_CONTENT         "/tmp/RESULT_DATACOLLECT_CONTENT_%s.TXT"
#define RESULT_FILE_FILENAME        "/tmp/RESULT_DATACOLLECT_FILENAME_%s.TXT"
#define RESULT_FILE_FILEPATH        "/tmp/RESULT_DATACOLLECT_FILEPATH_%s.TXT"
#define RESULT_FTP_SCHEDULE_FILE    "/tmp/RESULT_DATACOLLECT_CONTENT.TXT"
// #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end

#define MESSAGE_TYPE_IS_NONE    0   // 通信なし
#define MESSAGE_TYPE_IS_NKK     1   // 日機装通信
#define MESSAGE_TYPE_IS_NX      2   // NX通信
#define MESSAGE_TYPE_IS_V4      3   // 通信共通プロトコルV4

/**
 * @def
 * 配列数を求めるマクロ
 * 
 */
#define COUNTOF(array) (sizeof(array) / sizeof(array[0]))

/**
 * @brief 緊急発報メッセージデータ
 * 
 */
typedef struct
{
    uint16_t type;  // 0:なし, 1:日機装（新）通信 , 2:NX通信, 3:通信共通プロトコル
    u_char fmt[1];  // 通信フォーマット
    u_char dnd[8];  // 装置識別番号
    u_char sno[1];  // シーケンシャルＮｏ（１１～ＦＦＨ、１通信毎に更新）
    u_char cmd[2];  // コマンドコード (nkk:66H)(NX:0005)
    u_char sta[2];  // ステータス
    u_char data[255]; // データ部
    u_char machineTypeCode[3];
    u_char fileName[255];
    u_char fileDir[255];

} MessageData_t;

typedef struct
{
    char machineTypeCd[3];
    char machineFormatCd;
    char machineSerial[8];
} TargetDevice_t;

typedef struct
{
    int16_t hour;
    int16_t minute;
} HourMinute_t;

typedef struct
{
    u_char awsHostUrl[255];            // 接続先URL
    u_char websockHostUrl[255];            // websocket接続先URL
    int16_t awsMoniUploadInterval;  // モニタデータアップロード間隔
    u_char receiveDataDirectory[255];   // 緊急発報ログファイル受信データフォルダ
    u_char receiveDataDirectory2[255];  // 緊急発報ログファイル受信データフォルダ
    u_char receiveDataDirectory3[255];  // 緊急発報ログファイル受信データフォルダ
    u_char collectDataDirectory[255];   // データ収集ファイル格納フォルダ
    u_char collectDataDirectory2[255];  // データ収集ファイル格納フォルダ
    u_char collectDataDirectory3[255];  // データ収集ファイル格納フォルダ
    u_char tempDirectory[255];          // データ収集ファイル作業フォルダ
    u_char tempDirectory2[255];         // データ収集ファイル作業フォルダ
    u_char tempDirectory3[255];         // データ収集ファイル作業フォルダ
    // #8731 2023.05.08 add 通信異常ファイルの格納先を設定で持つ TDC片口 start
    u_char commFailDirectory[50];      // 通信異常時ファイル格納先フォルダ
    // #8731 2023.05.08 add 通信異常ファイルの格納先を設定で持つ TDC片口 end
    u_char facilityCode[7];             // 施設コード
    u_char collectApp[255];             // ログデータ収集用キャプチャアプリ/ソケット接続アプリのパス
    u_char mstDir[50];                  // マスターファイルの格納されているフォルダ
    u_char uploadApp[255];              // データ収集アプリのパス
    int16_t deviceNo;                   // デバイスエッジ番号
    HourMinute_t ftpSchedule[25];       // FTPデータ収集スケジュール
    int16_t thresholdFileCount;         // ファイル数しきい値
    int16_t webSocketKeepAliveInterval; // WebSocket KeepAlive通知間隔(秒単位)
    int16_t commPermissonWaitTime;      // WebSocket接続後の通信許可待ち時間
    // #8730 2023.05.24 add AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 start
    bool isSelectedComSv;               // 連動アプリに「通信SV」が選択されているかどうか
    // #8730 2023.05.24 add AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 end
} ConfigParameter_t;

typedef struct
{
    bool	isRunning;    // 実行中フラグ
    bool	mstReload; // マスタ更新フラグ
    ConfigParameter_t configParam;   // 設定ファイル内容
} ThreadParameter_t;
 
typedef struct
{
    bool	isRunning;    // 実行中フラグ
    bool	isRcvSignal;    // シグナル受信フラグ
    u_char  exitMessage[255]; // 終了ログ
} RunningParameter_t;
#endif // _STRUCT_DATA_H_
