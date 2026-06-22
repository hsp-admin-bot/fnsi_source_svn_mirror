#ifndef NTSS_UPDT_H
#define NTSS_UPDT_H

#include <stdbool.h>
#include <stdio.h>
#include <sys/wait.h>
#include <sys/types.h>
#include "config_read.h"
#include "struct_data.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
//#include "ntss_file.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
#include "ntss_properties.h"
#include "../common/libs/master_controller.h"
#include "../common/libs/ntss_mst_lib.h"
#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/ntss_upload_lib.h"
#include "../common/nkklib/nkklib.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 start
#include "../common/libs/ntss_restcall_lib.h"
// #8729 2023.05.29 add REST取得結果によるリトライ処理 TDC高村 end

extern bool responseCall(u_char *rest, u_char *cManageNo, u_char *status, u_char *info);

extern bool sendResponse(u_char *seqNo, u_char *responseCode, u_char *message);

extern bool xxdFile(u_char *hexFileName, u_char *fileName);

extern bool unzipFile(u_char *fileName, u_char *exDir, u_char *password);

extern bool backupMyDirUpd();

extern bool backupMyDirMain();

extern bool backupMyDir();

extern bool updateMyDir(u_char *kind, u_char *updDir);

extern bool updateMainApps(u_char *updDir);

extern bool updateUpdateApp(u_char *updDir);

extern bool chmodExeFile();

extern bool removeWorkDir(u_char *dirPath);

extern bool cpRestoreDir(u_char *kind, u_char *tmpDir);

extern bool restoreApplication(u_char *cPayload);

extern bool serviceRebootOrder(u_char *cPayload);

extern bool serviceReboot();

extern bool osRebootOrder(u_char *cPayload);

extern bool osReboot();

#endif // NTSS_UPDT_H
