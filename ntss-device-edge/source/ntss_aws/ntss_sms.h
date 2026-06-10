#ifndef _NTSS_SMS_H_
#define _NTSS_SMS_H_

#include "ntss_properties.h"
#include "config_read.h"
#include "struct_data.h"
#include "data_builder.h"
#include "../common/libs/ntss_mst_lib.h"
#include "../common/libs/ntss_etc_lib.h"
#include "../common/libs/master_controller.h"
// #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 start
#include "../common/libs/ntss_restcall_lib.h"
// #8729 2023.05.29 del REST取得結果によるリトライ処理 TDC高村 end

// #12406 2025.12.01 add 正常動作確認用カウンタ定義 TDC米沢 start
// スレッド正常動作確認用カウンター
// #12507 2026.03.01 mod FW7に伴うエラー対応 TDC高村 start
//extern uint32_t nSMSThreadRunningCount = 0;
extern uint32_t nSMSThreadRunningCount;
// #12507 2026.03.01 mod FW7に伴うエラー対応 TDC高村 end
// #12406 2025.12.01 add 正常動作確認用カウンタ定義 TDC米沢 end

extern uint32_t
readConfigSMSFile();

void *
smsNoticeThread(void *ptr);

#endif // _NTSS_SMS_H_
