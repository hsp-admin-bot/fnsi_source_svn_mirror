#ifndef _NTSS_M_NOTICE_H_
#define _NTSS_M_NOTICE_H_

#include "ntss_properties.h"
#include "config_read.h"
#include "struct_data.h"
#include "data_builder.h"
#include "../common/libs/ntss_mst_lib.h"
#include "../common/libs/ntss_etc_lib.h"
#include "../common/libs/master_controller.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 start
#include "../common/libs/ntss_restcall_lib.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 end

#define _NTSS_M_NOTICE_TEMP_FILE "tempMNoticeFile.bin"

extern MessageData_t
separateMessage(u_char *message, uint16_t type);

/**
 * @brief ファイル名から通信方式を取得
 * 
 * @param fileName ファイル名
 * @return int16_t 通信方式
 */
extern int16_t
getTypeFromFileName(u_char *fileName);

/**
 * @brief バイナリファイルの読み込み
 * 
 * @param path 
 * @param buff 
 * @return uint32_t データサイズ
 */
uint32_t
readBinaryFile(uint8_t *buff, const u_char *path);

/**
 * @brief ファイルをTempフォルダへ移動、その際に同設備同日のファイルがあれば追記
 * 
 * @param msgData 
 * @return true 
 * @return false 
 */
extern bool
moveFileToCollectDir(MessageData_t msgData, ConfigParameter_t *param);

/**
 * @brief データ収集ログファイルを読み込み、緊急発報対象ならばRESTに投げて、その後ファイルをデータ収集フォルダへ移動
 * 
 * @param rest 緊急発報用のREST API
 * @param param 設定項目構造体
 * @param grepFile 発報対象判定用マスタ
 */
extern void runMNotice(u_char *rest, ConfigParameter_t *param, u_char *grepFile);

extern bool
moveFileDateDir(MessageData_t *msgData, ConfigParameter_t *param);

extern bool
removeSubDir(MessageData_t *msgData, ConfigParameter_t *param);

extern bool
checkFileCountOver(ConfigParameter_t *param);

extern bool
noticeFileCountOver(u_char *rest, ConfigParameter_t *param);

/**
 * @brief SD/USBへの書き込み失敗時にメール通知を行う
 * @details SD/USBへの書き込み失敗時にメール通知を行う
 * 
 * @param kind   種別[0：SD/1：USB]
 * @param rest   REST名
 * @param param　設定情報
 * @return false：通知なし(通知失敗含む)/true：通知あり
 */
extern bool
noticeMntMediaWriteError(int Kind, u_char *rest, ConfigParameter_t *param);

#endif // _NTSS_M_NOTICE_H_
