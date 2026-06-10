#ifndef _NTSS_HOST_WATCH_NOTIFICATION_H_
#define _NTSS_HOST_WATCH_NOTIFICATION_H_

#include "ntss_properties.h"
#include "config_read.h"
#include "struct_data.h"
#include "../common/libs/ntss_mst_lib.h"
#include "../common/libs/ntss_etc_lib.h"
#include "../common/libs/master_controller.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 start
#include "../common/libs/ntss_restcall_lib.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 end

void *
hostWatchNoticeThread(void *ptr);

#endif // _NTSS_HOST_WATCH_NOTIFICATION_H_
