/**
* @briefNTSSログサーバー出力関連
*
* @details NTSSログサーバー出力関連
*
* @description ntss program
* Copyright (C) 2018, TDC, all right reserved.
*
* @file ntss_log_lib.c
* @author Y.Takamura
* @date 2018/07/13
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/statvfs.h>
#include <fcntl.h>
#include <libgen.h>
#include <pthread.h> 

#include "logsv_config.h"
#include "logsv_output.h"
#include "../common/libs/ntss_etc_lib.h"
#include "../common/libs/ntss_log_lib.h"

/// ログサーバー設定ファイル
#define NTSS_LOGSV_CONF_FILE "./conf/ntss_logger.conf"

/// NTSSバージョンファイル
#define NTSS_UPDT_VERSION_FILE "./version/updater_version.dat"
#define NTSS_MAIN_VERSION_FILE "./version/main_version.dat"

/// 各フォルダ最大定義件数
#define NTSS_LOGSV_FOLDER_MAX 3

/// ログ出力先フォルダ
static u_char cLogsvFolder[ NTSS_LOGSV_FOLDER_MAX ][ NTSS_STR_MAX_SIZE ];

/// ログファイル名パラメータ
static char facilityCd[10];     // 施設コード(6桁)
static uint32_t deviceNo;       // デバイス番号(1〜99)
static char serialNo[20];       // デバイス製造番号(11桁)

/// ログ開始時刻
static time_t LogsvStartDateTime = 0;

/// バージョン出力（0:出力なし,1:出力有り）
static int VersionOutput = 0;

/// スレッド間で共有する排他制御変数
static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;


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
void LogsvInit(ConfigParameter_t *config)
{
    // ミューテックス初期化
    pthread_mutex_init( &mutex, NULL );

    // ログ格納先フォルダ([優先順位][バッファ数])
    memset( cLogsvFolder, 0, sizeof( cLogsvFolder ));
    strcpy( cLogsvFolder[0], config->logsvFolder1 );
    addFolderSeparator(cLogsvFolder[0]);
    strcpy( cLogsvFolder[1], config->logsvFolder2 );
    addFolderSeparator(cLogsvFolder[1]);
    strcpy( cLogsvFolder[2], config->logsvFolder3 );
    addFolderSeparator(cLogsvFolder[2]);

    // 施設コード(6桁)
    memset( facilityCd, 0, sizeof( facilityCd ));
    strcpy( facilityCd, config->facilityCd );
    // デバイス番号(1〜99)
    deviceNo = config->deviceNo;
    // デバイス製造番号(11桁)
    memset( serialNo, 0, sizeof( serialNo ));
    strcpy( serialNo, config->serialNo );

    // ログ開始時刻を初期化（現在時刻）
    time( &LogsvStartDateTime );

    // バージョン出力（1:出力有り）
    VersionOutput = 1;
}

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
void LogsvOutput( u_char *stime, u_char *msg )
{
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//struct timeval tval;
    struct timespec ts;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    time_t tim_work;
    struct tm tmc;
    struct tm tmcLog;
    u_char cProg[ NTSS_STR_MAX_SIZE ];
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
    //u_char cFile[ NTSS_STR_MAX_SIZE ];
    u_char cMsg[40];
    //u_char cCmd[60];
    u_char cCmd[NTSS_STR_MAX_SIZE];
    u_char cFile[60];
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end

    // 現在時刻取得
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
 	//gettimeofday(&tval, NULL);
    //localtime_r( &tval.tv_sec, &tmc );
    //
    //// 自プロセス名を取得
    //memset( cProg, 0, sizeof( cProg ));
    //getProcessName( cProg, sizeof(cProg), 0x00 );   
    //
    //// ログ出力内容作成
    //if ( *stime == 0 ) {
    //    // 現在時刻を使う
    //    sprintf(
    //        cMsg
    //        , "[ %04d/%02d/%02d %02d:%02d:%02d.%06ld ] "
    //        , tmc.tm_year + 1900
    //        , tmc.tm_mon + 1
    //        , tmc.tm_mday
    //        , tmc.tm_hour
    //        , tmc.tm_min
    //        , tmc.tm_sec
    //        , tval.tv_usec
    //    );
    //}
    clock_gettime(CLOCK_REALTIME, &ts);
    localtime_r( &ts.tv_sec, &tmc );

    // 自プロセス名を取得
    memset( cProg, 0, sizeof( cProg ));
    getProcessName( cProg, sizeof(cProg), 0x00 );   

    // ログ出力内容作成
    if ( *stime == 0 ) {
        // 現在時刻を使う
        sprintf(
            cMsg
            , "[ %04d/%02d/%02d %02d:%02d:%02d.%06ld ] "
            , tmc.tm_year + 1900
            , tmc.tm_mon + 1
            , tmc.tm_mday
            , tmc.tm_hour
            , tmc.tm_min
            , tmc.tm_sec
            , ts.tv_nsec / 1000
        );
    }
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    else {
        // 送信時刻を使う
        sprintf(
            cMsg
            , "[ %s ] "
            , stime
        );
    }

    // ミューテックスをロック
    pthread_mutex_lock(&mutex);

    // ログファイル出力先フォルダ([優先順位][バッファ数])
    int intlop;
    u_char *pfolder;
    for( intlop = 0; intlop < NTSS_LOGSV_FOLDER_MAX; intlop ++ )
    {
        //
        pfolder = cLogsvFolder[ intlop ];

        // ログ格納先フォルダ設定確認
        if( 0 < strlen( pfolder ))
        {
            // 設定あり

            //// debug
            //printf( "ログ出力先:%s\n", cLogsvFolder );

            // ログ格納フォルダの存在判定
            if( existFolderFile( pfolder, NULL ) == 0 )
            {
                // 存在しない場合

                // ログフォルダ作成
                if( createFolder( pfolder ) != 1 )
                {
                    // ログ出力フォルダ作成失敗

                    //// debug
                    //printf( "ログ出力フォルダ作成失敗 %s\n", cLogsvFolder );
                    continue;
                }
            }

                tim_work = LogsvStartDateTime;

            if ( *stime == 0 ) {
                // 現在日付を使う
                // ログ作成日時設定
                tim_work = LogsvStartDateTime;
                localtime_r( &tim_work, &tmcLog );
                if ( tmcLog.tm_mday != tmc.tm_mday ) {
                    // 日付が変わった場合、現在時刻をセット
                    time( &LogsvStartDateTime );
                    tim_work = LogsvStartDateTime;
                    localtime_r( &tim_work, &tmcLog );
                    // バージョン出力（1:出力有り）
                    VersionOutput = 1;
                }  
                // mod FNSI-バグ 通信サーバ #9696 高 start
                // ログファイル名作成
                /*sprintf(
                    cFile
                    , "%sDE_%s_%02d_%s_%04d%02d%02d.LOG"
                    , pfolder
                    , facilityCd
                    , deviceNo
                    , serialNo
                    , tmcLog.tm_year + 1900
                    , tmcLog.tm_mon + 1
                    , tmcLog.tm_mday
                );*/
                sprintf(
                    cFile
                    // mod #10756 9696未対応部分 高 start
                    // , "%s%s_DE_%s_%02d_%04d%02d%02d.LOG"
                    , "%s%s_DE_%s_%02d_%04d%02d%02d.log"
                    // mod #10756 9696未対応部分 高 end
                    , pfolder
                    , facilityCd
                    , serialNo
                    , deviceNo
                    , tmcLog.tm_year + 1900
                    , tmcLog.tm_mon + 1
                    , tmcLog.tm_mday
                );
                // mod FNSI-バグ 通信サーバ #9696 高 end
            }
            else {
                // 送信日付を使う
                // mod FNSI-バグ 通信サーバ #9696 高 start
                // ログファイル名作成
                /*sprintf(
                    cFile
                    , "%sDE_%s_%02d_%s_%.4s%.2s%.2s.LOG"
                    , pfolder
                    , facilityCd
                    , deviceNo
                    , serialNo
                    , stime
                    , &stime[5]
                    , &stime[8]
                );*/
                sprintf(
                    cFile
                    // mod #10756 9696未対応部分 高 start
                    // , "%s%s_DE_%s_%02d_%.4s%.2s%.2s.LOG"
                    , "%s%s_DE_%s_%02d_%.4s%.2s%.2s.log"
                    // mod #10756 9696未対応部分 高 end
                    , pfolder
                    , facilityCd
                    , serialNo
                    , deviceNo
                    , stime
                    , &stime[5]
                    , &stime[8]
                );
                // mod FNSI-バグ 通信サーバ #9696 高 end
            }

            // バージョン出力確認
            if ( VersionOutput == 1 ) {
                struct stat st;
                if (stat(NTSS_UPDT_VERSION_FILE, &st) == 0) {
                    // 初回、日付が変わったタイミングでバージョン内容を出力する
                    sprintf(cCmd, "cat %s >> %s", NTSS_UPDT_VERSION_FILE, cFile);
                    system(cCmd);
                }
                if (stat(NTSS_MAIN_VERSION_FILE, &st) == 0) {
                    // 初回、日付が変わったタイミングでバージョン内容を出力する
                    sprintf(cCmd, "cat %s >> %s", NTSS_MAIN_VERSION_FILE, cFile);
                    system(cCmd);
                }
                VersionOutput = 0;
            }

            // ファイルに先頭情報を追記
            if( outputAppendFile(
                    cFile
                , cMsg
                , strlen( cMsg )
            ) == 1)
            {
                // ファイルにメッセージ情報を追記
                if( outputAppendFile(
                        cFile
                    , msg
                    , strlen( msg )
                ) == 1)
                {
                    // ファイルに行区切り情報を追記
                    if( outputAppendFile(
                            cFile
                        , "\n"
                        , 1
                    ) == 1)
                    {
                        // 出力成功

                        // ログ開始日時を保持
                        LogsvStartDateTime = tim_work;

                        break;
                    }
                }
            }
        }
    }

    // ミューテックスを開放
    pthread_mutex_unlock(&mutex);
}

/**
* @brief ログ出力を行う（旧LogOutput相当）
*
* @details ログ出力を行う（旧LogOutput相当）
*
* @description
* @param[in] type   種別コード
* @param[in] *msg   ログメッセージ
* @return なし
* @attention 特になし
*/
void LogOutput_logger( NtssLogType type, u_char *msg )
{
    u_char *id;
    u_char cProg[ NTSS_STR_MAX_SIZE ];
    u_char cMesg[ NTSS_STR_MAX_SIZE ];
    // #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 start
    u_char cLmsg[ NTSS_STR_MAX_SIZE * 5];
    // #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 end

    // ログファイルの固定情報作成
    switch( type )
    {
        case NTSS_LOG_INFO:
            id = "[INFO ]";
            break;

        case NTSS_LOG_DEBUG:
            id = "[DEBUG]";
            break;

        case NTSS_LOG_ERROR:
            id = "[ERROR]";
            break;

        default:
            id = "";
            break;
    }

    // 自プロセス名を取得
    memset( cProg, 0, sizeof( cProg ));
    //getProcessName( cProg, sizeof(cProg), 0x00 );
    strcpy( cProg, "ntss_logger.exe");

    // #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 start
    memset( cLmsg, 0, sizeof( cLmsg ));
    strcpy( cLmsg, msg);
    logsv_replace(cLmsg, strlen(cLmsg));
    // #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 end

    memset( cMesg, 0, sizeof( cMesg ));
    // #12258 2025.10.06 mod DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 start
	//sprintf( cMesg, "%s,%s,%s,%d,%s,%s,%s,%s,%s,%s,%s,%s,%s",
	//facilityCd, "", "", deviceNo, serialNo,	"", "", "", cProg, "", "", id, msg);
	sprintf( cMesg, "%s,%s,%s,%d,%s,%s,%s,%s,%s,%s,%s,%s,%s",
	facilityCd, "", "", deviceNo, serialNo,	"", "", "", cProg, "", "", id, cLmsg);
    // #12258 2025.10.06 mod DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 end

    LogsvOutput( "", cMesg );
}

/**
* @brief ファイルシステムの状態取得
*
* @details 指定パスのファイルシステム状態を取得する
*
* @description
* @param[in] *filepath  ファイルパス名
* @param[in] *fileinfo  ファイルシステム状態
* @return int -1:対象なし,0:状態取得
* @attention 特になし
*/
int Filesystem_Info(char *filepath, char *fileinfo)
{
    int rc = 0;
    struct statvfs buf = {0};

    rc = statvfs(filepath, &buf);
    if(rc < 0){
        //printf("Error: statvfs() %s: %s\n", strerror(errno), filepath);
        strcpy(fileinfo, "");
        return(-1);
    }

    /*
    printf("ブロックサイズ     : %lu(byte/block)\n", buf.f_bsize);
    printf("フラグメントサイズ : %lu(byte/block)\n", buf.f_frsize);
    printf("全ブロック数       : %lu(block)\n",
           (unsigned long)buf.f_blocks);
    printf("空きブロック数     : %lu(block)\n",
           (unsigned long)buf.f_bfree);
    printf("使用可能ブロック数 : %lu(block)\n",
           (unsigned long)buf.f_bavail);
    printf("iノード数          : %lu(node)\n",
           (unsigned long)buf.f_files);
    printf("未使用iノード数    : %lu(node)\n",
           (unsigned long)buf.f_ffree);
    printf("使用可能iノード数  : %lu(node)\n",
           (unsigned long)buf.f_favail);
    printf("ファイルシステムID : %lu\n", buf.f_fsid);
    printf("マウントフラグ     : %lu\n", buf.f_flag);
    printf("最大ファイル名長   : %lu(byte)\n", buf.f_namemax);
    printf("-------------------------------------\n");
    printf("available          : %4.0f(kbyte)\n",
           (float)buf.f_frsize * buf.f_bavail / 1024);
    printf("all                : %4.0f(kbyte)\n",
           (float)buf.f_frsize * buf.f_blocks / 1024);
    printf("free               : %4.1f%%\n",
           100 - ((float)buf.f_bfree / buf.f_blocks * 100));
    */

    char work[128];
    sprintf(work, "path : %s  All : %4.0f(kbyte)  Available : %4.0f(kbyte)  Use : %4.1f%%",
            filepath,
            ((float)buf.f_frsize * buf.f_blocks / 1024),
            ((float)buf.f_frsize * buf.f_bavail / 1024),
            100 - ((float)buf.f_bfree / buf.f_blocks * 100));
    strcpy(fileinfo, work);

    return(0);
}


// #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 start
/**
 * @brief 任意長の文字列置換関数（1バイト文字列対象）
 *
 * @param[in]   input       編集前の文字列
 * @param[out]  target      検索する文字列
 * @param[out]  replacement 置換後の文字列
 * @param[out]  output      編集後の文字列
 */
void replace_substring(const char *input, const char *target, const char *replacement, char *output) {
    size_t target_len = strlen(target);
    size_t replacement_len = strlen(replacement);

    const char *p = input;
    while (*p) {
        if (strncmp(p, target, target_len) == 0) {
            strncpy(output, replacement, replacement_len);
            output += replacement_len;
            p += target_len;
        } else {
            *output++ = *p++;
        }
    }
    *output = '\0';
}
// #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 end

// #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 start
/**
 * @brief 全体を「"」で括り、既存の「"」とJSON内に含まれる「\"」を一律「""」に置き換え
 *
 * @param[in,out]   message ログメッセージ
 * @param[in]       len     文字列長
 */
void logsv_replace(char *message, int len) {
    const char *target1 = "\"";        // 1バイト文字1つ分
    const char *replacement1 = "\"\""; // 置換文字列
    const char *target2 = "\\\"";      // 2バイト文字1つ分
    const char *replacement2 = "\"";   // 置換文字列
	unsigned char input[len * 2];
	unsigned char output[len * 2];

    memset(input,0,sizeof(input));
    memset(output,0,sizeof(output));
    strcpy(input, message);
    strcpy(output, message);

    if ( strstr(input, target1) != NULL ) {
        replace_substring(input, target1, replacement1, output);
        strcpy(input, output);
    }
    if ( strstr(input, target2) != NULL ) {
        replace_substring(input, target2, replacement2, output);
    }
    sprintf(message, "\"%s\"", output);  // 置き換え後
}
// #12258 2025.10.06 add DEログの一部でAPIパラメータ等の「,」がエスケープされていない TDC高村 end
