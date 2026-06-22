// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻をロガーと共有 TDC米沢 start
#include <stdbool.h>
#include <stdio.h>
#include <signal.h>
#include <sys/wait.h>
#include <sys/types.h>

#include "ntss_logger_sync.h"

#define LOGGER_NAME         "ntss_logger.exe"   // ロガーアプリ名

/**
 * @brief ロガーアプリのプロセスIDを取得する
 *
 * @return 1以上 成功(PID)
 * @return 0以下 失敗
 */
int GetLoggerAppPid()
{
    int pid = 0;
    long pid_l;
    u_char charPid[10] = {0};
    unsigned char cBuff[NTSS_STR_MAX_SIZE * 2] = {0};
    unsigned char logMessage[NTSS_STR_MAX_SIZE] = {0};
    char *responseFile = "/tmp/tmpLoggerPID.txt";

    // RESTをコールする
    sprintf(cBuff, "./sh/find_pid.sh \"%s\" \"%s\"", LOGGER_NAME, responseFile);
    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    system(cBuff);

    if (readFileOneLine(charPid, 10, responseFile) == 0)
    {
        pid_l = strtol(charPid, NULL, 10);
        if (pid_l != 0 && errno != ERANGE)
        {
            pid = (int)pid_l;
            snprintf(logMessage, NTSS_STR_MAX_SIZE, "ロガーPID取得成功: PID: %d", pid);
            LogOutput(NTSS_LOG_INFO, logMessage);
        }
        else
        {
            snprintf(logMessage, NTSS_STR_MAX_SIZE, "ロガーPID取得失敗: 取得PID: %ld", pid_l);
            LogOutput(NTSS_LOG_ERROR, logMessage);
        }
    }
    else
    {
        snprintf(logMessage, NTSS_STR_MAX_SIZE, "ロガーが見つかりませんでした");
        LogOutput(NTSS_LOG_ERROR, logMessage);
    }

    removeFileFullPath(responseFile);

    return pid;
}

/**
 * @brief ロガーアプリに通信サーバー設定の変更を通知する
 */
void SyncComSVConfigToLogger()
{
    unsigned char logMessage[NTSS_STR_MAX_SIZE] = {0};
    int pid = 0;

    // ロガーのプロセスIDを取得
    pid = GetLoggerAppPid();
    if( 0 < pid) {
        // ロガーに通信サーバー設定の変更を通知
        kill(pid, SIG_COMSV_CONFIG_UPDATE);

        // ログ
        sprintf(logMessage,  "ロガーへ通信サーバー設定の変更を通知 pid:%d SIG_COMSV_CONFIG_UPDATE:%d", pid, SIG_COMSV_CONFIG_UPDATE);
        LogOutput(NTSS_LOG_INFO, logMessage);
    }
}
// #10557 2024.05.17 add 通信サーバー設定：ログアップロード実施時刻をロガーと共有 TDC米沢 end