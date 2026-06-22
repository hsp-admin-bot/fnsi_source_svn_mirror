/**
* @briefNTSSログサーバー出力関連ヘッダーファイル
*
* @details NTSSログサーバー出力関連
*
* @description ntss program

* Copyright (C) 2018, TDC, all right reserved.
*
* @file ntss_log_lib.h
* @author H.Yonezawa
* @date 2018/07/13
*/

#ifndef LOGSV_OUTPUT_H
#define LOGSV_OUTPUT_H

#include <sys/types.h>
#include <sys/stat.h>
#include "../common/libs/ntss_log_lib.h"

/**
* @brief ログサーバー出力設定を行う
*
* @details ログサーバー出力設定を行う
*
* @description
* @param[in] ｃPath ログ出力先
* @return なし
* @attention 特になし
*/
extern void LogsvInit(ConfigParameter_t *config);

/**
* @brief ログサーバー出力を行う
*
* @details ログサーバー出力を行う
*
* @description
* @param[in] *stime 送信日時
* @param[in] *msg   ログメッセージ
* @return なし
* @attention 特になし
*/
extern void LogsvOutput(u_char *stime, u_char *msg);

/**
* @brief ログ出力を行う
*
* @details ログ出力を行う
*
* @description
* @param[in] type   種別コード
* @param[in] *msg   ログメッセージ
* @return なし
* @attention 特になし
*/
extern void LogOutput_logger( NtssLogType type, u_char *msg );

/**
* @brief ファイルシステムの状態取得
*
* @details 指定パスのファイルシステム状態を取得する
*
* @description
* @param[in] *filepath  ファイルパス名
* @param[in] *fileinfo  ファイルシステム状態
* @return -1:対象なし,0:状態取得
* @attention 特になし
*/
extern int Filesystem_Info(char *filepath, char *fileinfo);

// #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 start
/**
 * @brief 任意長の文字列置換関数（1バイト文字列対象）
 *
 * @param[in]   input       編集前の文字列
 * @param[out]  target      検索する文字列
 * @param[out]  replacement 置換後の文字列
 * @param[out]  output      編集後の文字列
 */
extern void replace_substring(const char *input, const char *target, const char *replacement, char *output);

/**
 * @brief 全体を「"」で括り、既存の「"」とJSON内に含まれる「\"」を一律「""」に置き換え
 *
 * @param[in,out]   message ログメッセージ
 * @param[in]       len     文字列長
 */
extern void logsv_replace(char *message, int len);
// #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 end

#endif