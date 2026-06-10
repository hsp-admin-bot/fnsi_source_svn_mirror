// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻をロガーと共有 TDC米沢 start
#ifndef NTSS_LOGGRER_SYNC_H
#define NTSS_LOGGRER_SYNC_H

#include "ntss_comsv.h"

/**
 * @brief ロガーアプリに通信サーバー設定の変更を通知する
 *
 * @return 1以上 成功
 * @return 0以下 失敗
 */
extern void SyncComSVConfigToLogger();

#endif
// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻をロガーと共有 TDC米沢 end