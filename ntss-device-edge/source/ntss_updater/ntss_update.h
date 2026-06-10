#ifndef NTSS_UPDT_H
#define NTSS_UPDT_H

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
#include "ntss_version.h"
#include "ntss_plan_info.h"
#include "../common/libs/master_controller.h"
#include "../common/libs/ntss_mst_lib.h"
#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/ntss_upload_lib.h"
#include "../common/nkklib/nkklib.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 start
#include "../common/libs/ntss_restcall_lib.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 end

extern bool downloadFile(unsigned char *rest, unsigned char *bucket, unsigned char *filename, unsigned char *hexFileName);

extern bool responseCall(unsigned char *rest, unsigned char *cManageNo, unsigned char *status, unsigned char *info);

extern bool sendResponse(unsigned char *seqNo, unsigned char *responseCode, unsigned char *message);

extern bool xxdFile(unsigned char *hexFileName, unsigned char *fileName);

extern bool unzipFile(unsigned char *fileName, unsigned char *exDir, unsigned char *password);
// #12003 2026.01.05 add 圧縮ファイルの形式変更 TDC片口 start
/**
 * @brief 展開されたディレクトリから"DE_UPDATE"という固定名のファイルが含まれているディレクトリを検索し、
 * そのディレクトリを更新ファイルのルートディレクトリとして上書き用ディレクトリとして配置する
 * 
 * @param searchDir ZIPファイルを展開した先
 * @param exDir 上書き用ファイル置き場
 * @return true 成功
 * @return false 失敗
 */
extern bool moveUpdateFiles(unsigned char *searchDir, unsigned char *exDir);
// #12003 2026.01.05 add 圧縮ファイルの形式変更 TDC片口 end

extern bool backupMyDirUpd();

extern bool backupMyDirMain();

extern bool backupMyDir();

extern uint8_t updateMyDir(unsigned char *kind, unsigned char *updDir);

/**
 * @brief ファイル更新
 * 
 * @param updDir 更新ファイルの場所
 * @return uint8_t 1:成功 0:失敗
 */
extern uint8_t updateMainApps(unsigned char *updDir);

/**
 * @brief アップデータ更新
 * 
 * @param updDir 更新ファイルの場所
 * @return uint8_t 2:成功 0:失敗
 */
extern uint8_t updateUpdateApp(unsigned char *updDir);

/**
 * @brief 全アプリ更新
 * 
 * @param updDir 更新ファイルの場所
 * @return uint8_t 0:失敗 1:メインアプリ更新 2:アップデータ更新 4:
 */
extern uint8_t updateAllApps(unsigned char *updDir);

extern bool chmodExeFile();

extern bool removeWorkDir(unsigned char *dirPath);

extern bool cpRestoreDir(unsigned char *kind, unsigned char *tmpDir);

extern bool updateApplication(unsigned char *cPayload);

extern bool restoreApplication(unsigned char *cPayload);

extern bool updateMyConf(unsigned char *updMyFile);

extern bool serviceStartOrder(unsigned char *cPayload);

extern bool serviceStart();

extern bool serviceStopOrder(unsigned char *cPayload);

extern bool serviceStop();

extern bool serviceRebootOrder(unsigned char *cPayload);

extern bool serviceReboot();

extern bool meRebootOrder(unsigned char *cPayload);

extern bool meReboot();

extern bool osRebootOrder(unsigned char *cPayload);

extern bool osReboot();

extern bool confFileUpdate(unsigned char *cPayload);

extern bool confFileGather(unsigned char *cPayload);

extern bool sendLogGatherSignal(unsigned char *cPayload);

extern bool checkPlanUpdate();

extern bool planUpdateApplication(PlanParameter_t *planParam);

extern bool loggerReboot();

/**
 * @brief 対象サービスリブート
 * @param targets 0x01: メインアプリ 0x02: アップデータ 0x04: ロガー
 *
 * @return uint8_t 1:成功 else:以下の足し算 -1:メイン失敗 -2:アップデータ失敗 -4:ロガー失敗
 */
extern uint8_t allReboot(uint8_t targets);
/**
 * @brief 予定キャンセル
 *
 * @return true 成功
 * @return false 失敗
 */
extern bool planCancel(unsigned char *cPayload);

// #8729 2023.05.29 add RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
/**
 * @brief 予定ファイル出力
 * @param filePath 出力先ファイルのフルパス
 * @param planDateTime 予定yyyymmddhhmmss
 * @param updateFolderPath 更新用ファイル保存フォルダ
 * @param seqNo シーケンスNo
 * @param kind 更新対象
 * @param information 受信電文
 *
 */
extern bool
outputPlanInfoFile(
    unsigned char *filePath,
    unsigned char *planDateTime,
    unsigned char *updateFolderPath,
    unsigned char *seqNo,
    unsigned char *kind,
    unsigned char *information);

/**
 * @brief 予定ファイル読み込み
 * @param filePath 読み込みファイルのフルパス
 * @param planDateTime 予定yyyymmddhhmmss
 * @param updateFolderPath 更新用ファイル保存フォルダ
 * @param seqNo シーケンスNo
 * @param kind 更新対象
 * @param information 受信電文
 *
 */
extern bool
readPlanInfoFile(
    unsigned char *filePath,
    unsigned char *planDateTime,
    unsigned char *updateFolderPath,
    unsigned char *seqNo,
    unsigned char *kind,
    unsigned char *information);
// #8729 2023.05.29 add RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
#endif // NTSS_UPDT_H
