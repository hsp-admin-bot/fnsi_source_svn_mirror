#ifndef _MASTER_CONTROLLER_H_
#define _MASTER_CONTROLLER_H_

#include <stdbool.h>
#include <stdlib.h>
#include <stdint.h>
#include <sys/types.h>
#include "ntss_log_lib.h"

typedef struct {
    char machineRecordCd[4];
} MachineRecords_t;

typedef struct {
    char machineRecordCd[4];
    char message[50];
} MachineRecordsV4_t;

// ntss_cap/ntss_sock/ntss_collect用装置マスタ
typedef struct {
    char machineTypeCd[3];
    char machineFormatCd;
    char machineSerial[8];
    char ipAddress[15];
    char strport[5];
    char hasFtp;
    char machineCommCd;
} MachineInfo_t;

// ntss_conmsv用装置マスタ
typedef struct {
    char machineNo[8];
    char machineTypeCd[3];
    char machineFormatCd;
    char machineSerial[8];
    char ipAddress[15];
    char strport[5];
    char machineCommCd;
    char hasFtp;
    char hasVa;
    char machineOptine1[4];
    char machineOptine2[4];
    char machineOptine3[4];
    char machineOptine4[4];
    char machineOptine5[4];
} MachineInfo2_t;

bool writeMachineRecordCd(u_char *receiveShadowMachineRecords, uint16_t dataSize, u_char *filePath);

/**
 * @brief machineRecordsの内容をファイルから読み込んでGREP用マスタファイルを作成
 *
 * @param filePath 取得マスタファイルパス
 * @param outFileName 生成ファイルパス
 * @return true
 * @return false
 */
extern bool readMachineRecordCd(u_char *filePath, u_char *outFileName);

//
bool writeMachineInfo(MachineInfo_t *machineInfoData, uint16_t dataSize, char *filePath);
bool readMachineInfo(MachineInfo_t *machineInfoData, uint16_t dataSize, char *filePath);
uint16_t setMachineInfo(MachineInfo_t *machineInfoData, const char *receiveShadowMachineInfo, uint16_t maxSize);

//
bool writeMachineInfo2(MachineInfo2_t *machineInfoData, uint16_t dataSize, char *filePath);
bool readMachineInfo2(MachineInfo2_t *machineInfoData, uint16_t dataSize, char *filePath);
uint16_t setMachineInfo2(MachineInfo2_t *machineInfoData, const char *receiveShadowMachineInfo, uint16_t maxSize);

/// ファイル一覧処理モード
typedef enum NTSS_EDGE_OVERLAY_KIND
{
    /// なし
    NTSS_EDGE_OVERLAY_KIND_NONE,
    /// /etc以下の設定保存用
    NTSS_EDGE_OVERLAY_KIND_ETC,
    /// /home, /root以下のユーザー作業領域保存用
    NTSS_EDGE_OVERLAY_KIND_HOME,
    /// /var/log 以下、syslog保存用
    NTSS_EDGE_OVERLAY_KIND_LOG,
    /// その他、導入したパッケージ等の領域保存用
    NTSS_EDGE_OVERLAY_KIND_OTHER
} NtssEdgeOverlayKind;

extern void overlayDataSave(NtssEdgeOverlayKind kind);
#endif // _DATA_BUILDER_H_