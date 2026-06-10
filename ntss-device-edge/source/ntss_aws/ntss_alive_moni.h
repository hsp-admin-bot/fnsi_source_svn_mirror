
#ifndef _NTSS_ALIVE_MONI_H
#define _NTSS_ALIVE_MONI_H

#include <stdint.h>
#include <stdbool.h>
#include <string.h>
#include <stdio.h>
#include <signal.h>
#include "struct_data.h"
#include "config_read.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
//#include "ntss_file.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
#include "ntss_properties.h"
#include "../common/libs/ntss_mst_lib.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 start
#include "../common/libs/ntss_restcall_lib.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 end

// #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
// #define ALIVE_MONI_FILE "./M_ALIVE.TXT"
#define ALIVE_MONI_FILE "/tmp/M_ALIVE.TXT"
// #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end

typedef struct
{
    bool is_received_signal;              // 通知あり
    volatile sig_atomic_t is_finish_task; // 収集処理終了
    TargetDevice_t targetDevice[100];     // 対象機器
} AliveMoni_t;

/**
 * @brief ペイロードから通知内容を取得
 * 
 * @param aliveMoni 
 * @param receivePayload 
 * @param payloadLen 
 * @return uint16_t 
 */
extern uint16_t
setAliveMoni(AliveMoni_t *aliveMoni, const u_char *receivePayload, uint16_t payloadLen);

extern int32_t buildAliveMoniRes(u_char *sendData, bool isConnect);
extern int32_t buildAliveMoniResult(u_char *sendData, char *file);

extern bool
deleteAliveMoniResultFile();

/**
 * @brief デバイスエッジ死活送信
 * 
 * @param rest 
 * @param param 
 * @param isConnect 
 * @return true 
 * @return false 
 */
bool noticeAliveMoni(u_char *rest, bool isConnect);

/**
 * @brief 工程送信
 * 
 * @param rest 
 * @param param 
 */
void runAliveMoniNotice(u_char *rest);

#endif //_NTSS_DATA_COLLECT_H
