#ifndef _DATA_COLLECT_BUILDER_H_
#define _DATA_COLLECT_BUILDER_H_

#include "struct_data.h"
#include "config_read.h"
#include "ntss_data_collect.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
//#include "ntss_file.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/master_controller.h"

extern int32_t
buildSendDataCollectRes(u_char *sendData, RcvCollectNotice_t *noticeParams, int16_t deviceNo);
extern int32_t
buildSendDataCollectResult(u_char *sendData, RcvCollectNotice_t *noticeParams, int16_t deviceNo);
extern bool
deleteDataCollectResultFile(RcvCollectNotice_t *noticeParams);
bool deleteFtpCollectResultFile();

#endif // _DATA_COLLECT_BUILDER_H_
