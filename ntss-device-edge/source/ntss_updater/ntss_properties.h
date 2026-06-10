#ifndef NTSS_PROP_H
#define NTSS_PROP_H

#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <sys/wait.h>
#include <errno.h>
#include "config_read.h"
#include "struct_data.h"
#include "../common/libs/ntss_etc_lib.h"

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

typedef struct
{
    bool isRunning;
    pid_t jobPId;
} jobStatus_t;

extern bool getIsJobRunning();
extern void setIsJobRunning(bool value, pid_t pId);
extern void setIsJobRunningValue(bool value);
extern void setIsJobRunningPid(pid_t pId);
extern bool getIsResponseOk();
extern void setIsResponseOk(bool value);
extern RunningParameter_t getRunningParameter();
extern void setRunningParameter(bool isRunning, bool isRcvSignal, u_char *msg);
extern int getUseDlFolder();
extern void setUseDlFolder(int value);
extern u_char *getLogGatherSeqNo();
extern void setLogGatherSeqNo(u_char *seqNo);

extern void resetDlFolder();

#endif // _STRUCT_DATA_H_