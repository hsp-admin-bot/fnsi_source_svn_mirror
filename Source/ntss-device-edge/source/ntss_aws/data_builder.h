#ifndef _DATA_BUILDER_H_
#define _DATA_BUILDER_H_

#include "struct_data.h"
#include "config_read.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
//#include "ntss_file.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
#include "../common/libs/ntss_etc_lib.h"
#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/master_controller.h"

/**
 * @brief 
 * 
 * 装置記録コードを取得
 * 
 * @param msg
 * @param catCode2
 * 
 * @return int32_t
 */
int32_t getMsgMachineRecordCode(uint8_t *catCode, MessageData_t *msg);

extern bool isSendTarget(MessageData_t *msg, u_char *rcdFilePath);

extern int32_t buildSendData(u_char *sendData, MessageData_t *msg, ConfigParameter_t *configParam);
extern int32_t findDeviceCode(uint8_t *devCode, MessageData_t *msg);

#endif // _DATA_BUILDER_H_
