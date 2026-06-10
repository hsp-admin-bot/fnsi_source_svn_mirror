
#ifndef _NTSS_DATA_COLLECT_H
#define _NTSS_DATA_COLLECT_H

#include <stdint.h>
#include <stdbool.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>
#include "struct_data.h"
#include "config_read.h"
#include "ntss_properties.h"
#include "../common/libs/ntss_mst_lib.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 start
#include "../common/libs/ntss_restcall_lib.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 end

// #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
// #define ACTION_QUEUE_FILE "./dataCollectQueue.dat"
// #define TEMP_FILELIST_FILE "./tempCollectFiles.dat"
// #define DATA_COLLECT_TARGET_FILE "./datacolletct_machine_list.dat"
#define ACTION_QUEUE_FILE "/tmp/dataCollectQueue.dat"
#define TEMP_FILELIST_FILE "/tmp/tempCollectFiles.dat"
#define DATA_COLLECT_TARGET_FILE "/tmp/datacolletct_machine_list.dat"
// #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end

typedef struct
{
    u_char manageNo[20];
    TargetDevice_t targetDevice[100];
} RcvCollectNotice_t;

typedef struct
{
    RcvCollectNotice_t collectNotice;
    int pid;
    bool running;
    volatile sig_atomic_t finish;
    // add FNSI-バグ 通信サーバ 高 start
    bool collect_running;
    // add FNSI-バグ 通信サーバ 高 end
} DataCollectProc_t;

/**
 * @brief データ収集が必要かどうかのフラグ
 * 
 * @return true 
 * @return false 
 */
extern bool isMustExecDataCollect();
extern void setIsMustExecDataCollect(bool value);

/**
 * @brief ペイロードから通知内容を取得
 * 
 * @param noticeParams 
 * @param receivePayload 
 * @param payloadLen 
 * @return uint16_t 
 */
extern uint16_t
setCollectNotice(RcvCollectNotice_t *noticeParams, const u_char *receivePayload, uint16_t payloadLen);

/**
 * @brief データ収集フォルダのファイルを収集
 * 
 * @return uint16_t 取得件数
 */
extern uint16_t
fetchCollectFiles(ConfigParameter_t *param);

/**
 * @brief 抽出されたファイル一覧のファイルをすべてTempディレクトリへ移動する
 * 
 * @return true 
 * @return false 
 */
extern bool
moveFileToTempDir(ConfigParameter_t *param);

/**
 * @brief 処理キューへの追記
 * 
 * @param receivePayload 
 * @param payloadLen 
 * @return int16_t 
 */
extern int16_t
enqueueActionQueue(u_char *receivePayload, uint16_t payloadLen);

/**
 * @brief 処理キューからの読み出し（キューからは削除）
 * 
 * @param payload 読出結果格納
 * @return int16_t 読出結果文字数
 */
extern int16_t
dequeueActionQueue(u_char *payload, uint16_t max_size);

/**
 * @brief キューにデータがあるかどうかの確認
 * 
 * @return true 
 * @return false 
 */
bool hasDataActionQueue();

/**
 * @brief データ収集対象装置リストファイルを作成する
 * 
 * @param targetDev 装置構造体リスト
 * @return true 
 * @return false 
 */
bool writeFileDataCollectMachineList(TargetDevice_t *targetDev);

/**
 * @brief データ収集処理結果の送信
 * 
 * @param rest 
 * @param cPayload 
 * @param payLoadLen 
 * @param param 
 * @return true 
 * @return false 
 */
bool runDataCollectResultResponseSend(u_char *rest, u_char *cPayload, int32_t payLoadLen, RcvCollectNotice_t *noticeParams);

/**
 * @brief データ収集通知の応答送信
 * 
 * @param rest 
 * @param cPayload 
 * @param payLoadLen 
 * @param param 
 * @return true 
 * @return false 
 */
bool runDataCollectSignalResponseSend(u_char *rest, u_char *cPayload, int32_t payLoadLen);

/**
 * @brief データ収集レスポンス送信
 * 
 * @param rest 
 * @param cPayload 
 * @param payLoadLen 
 * @param tempFile 
 * @param param 
 * @return true 
 * @return false 
 */
bool runDataCollectResponseSend(u_char *rest, u_char *cPayload, int32_t payLoadLen, u_char *tempFile);

/**
 * @brief データ収集キャプチャファイル送信
 * 
 * @param rest 
 * @param param 
 */
bool runDataCollectPacketSend(u_char *rest, ConfigParameter_t *param);

/**
 * @brief モニタデータ送信完了通知
 * 
 * @param rest 
 * @param targetId 
 * @param targetIdLen 
 * @return true 
 * @return false 
 */
bool runNoticeUpdateSend(u_char *rest, u_char *targetId, int32_t targetIdLen);

#endif //_NTSS_DATA_COLLECT_H
