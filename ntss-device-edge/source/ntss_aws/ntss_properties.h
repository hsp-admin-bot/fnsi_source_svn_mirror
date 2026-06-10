#ifndef NTSS_PROP_H
#define NTSS_PROP_H

#include <stdbool.h>
#include <stdio.h>
#include <signal.h>
#include "struct_data.h"
#include "../common/libs/ntss_log_lib.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 start
#include "../common/libs/ntss_restcall_lib.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 end

#define MAX_LENGTH_OF_UPDATE_JSON_BUFFER 5120

/**
 * @brief マスタ同期シグナル番号
 * 
 */
#define SIG_MST_SYNC 34
/**
 * @brief データ収集完了シグナル番号
 * 
 */
#define SIG_FINISH_DATACOLLECT 35
/**
 * @brief 死活監視シグナル番号
 * 
 */
#define SIG_ALIVE_MONI 36
/**
 * @brief ログ収集シグナル番号
 * 
 */
#define SIG_LOG_GATHER 37
/**
 * @brief ログ収集受領シグナル番号
 * 
 */
#define SIG_LOG_GATHER_RECV 38
/**
 * @brief ログ収集完了シグナル番号
 * 
 */
#define SIG_LOG_GATHER_END 39
/**
 * @brief 装置情報作成モード移行要求シグナル番号
 * 
 */
#define SIG_CREATE_DEVICE_MODE  40
/**
 * @brief 通常モード移行要求シグナル番号
 * 
 */
#define SIG_NORMAL_MODE         41
// add AWSとDEの通信断からの復旧 高 start
/**
 * @brief 通信障害シグナル番号
 * 
 */
#define SIG_COMM_FAIL        42
/**
 * @brief 通信障害NORAMLシグナル番号
 * 
 */
#define SIG_COMM_FAIL_NORMAL 43
// add AWSとDEの通信断からの復旧 高 end

extern bool getIsJobRunning();
extern void setIsJobRunning(bool value);

extern int getChildCaptureAppPid();
extern void setChildCaptureAppPid(int pid);
extern bool getIsMstReload();
extern void setIsMstReload(bool value);
extern bool getIsMustAliveMoniSend();
extern void setIsMustAliveMoniSend(bool value);
extern bool getIsResponseOk();
extern void setIsResponseOk(bool value);
extern RunningParameter_t getRunningParameter();
extern void setRunningParameter(bool isRunning, bool isRcvSignal, u_char *msg);
extern bool getIsDisabledCallApi();
extern void setIsDisabledCallApi(bool value);
// add AWSとDEの通信断からの復旧 高 start
extern int comsv_fail_alive_moni_main();
extern int getCommAliveState();
extern void setCommAliveState(int value);
// add AWSとDEの通信断からの復旧 高 end

// #8730 2023.06.01 add AWSとの通信異常時に蓄積系データをcommFailDataへ移動 TDC米沢 start
/**
 * @brief 通信障害発生時に蓄積系データを移動したことを通知
*/
#define SIG_COMM_FILE_MOVED 44
/**
 * @fn bool isEnabledFirstAWSComm();
 * @brief 初回通信許可状態
 * @return true:許可,false：不許可
 */
extern bool isEnabledFirstAWSComm();
// #8730 2023.06.01 add AWSとの通信異常時に蓄積系データをcommFailDataへ移動 TDC米沢 end

#endif // _STRUCT_DATA_H_