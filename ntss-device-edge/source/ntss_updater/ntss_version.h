#ifndef NTSS_VER_H
#define NTSS_VER_H

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
 * @brief バージョン情報をサーバーに通知
 * 
 * @return 1 成功
 * @return 0 失敗
 */
extern uint8_t versionPost();

/**
 * @brief 実際にPOST処理を行う
 * 
 * @param message メッセージ（バージョンファイル内の文字列）
 * @return 1 成功
 * @return 0 失敗
 */
extern uint8_t callVersionPostApi(unsigned char *message);

// #8729 2023.05.29 add RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
/**
 * @brief 対象文字列の末尾の改行コードを削除
 * 
 * @param targetStr 対象文字列
 */
extern void
removeLastLf(unsigned char *targetStr);
// #8729 2023.05.29 add RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end

#endif // NTSS_VER_H
