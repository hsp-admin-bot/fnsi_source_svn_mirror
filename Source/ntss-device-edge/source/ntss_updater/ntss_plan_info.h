#ifndef NTSS_PLAN_H
#define NTSS_PLAN_H

#include <stdbool.h>
#include <stdio.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <unistd.h>
#include "config_read.h"
#include "struct_data.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
//#include "ntss_file.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
#include "ntss_properties.h"
#include "ntss_conf_upload.h"
#include "../common/libs/master_controller.h"
#include "../common/libs/ntss_mst_lib.h"
#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/ntss_upload_lib.h"
#include "../common/nkklib/nkklib.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 start
#include "../common/libs/ntss_restcall_lib.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 end


/**
 * @brief 予定情報更新POST処理を行う
 * 
 * @param seqNo 管理番号
 * @param planDate 予定日時情報
 * @return 1 成功
 * @return 0 失敗
 */
extern uint8_t callPlanInfoPostApi(u_char *seqNo, u_char *planDate);

#endif // NTSS_PLAN_H
