/**
* @briefNTSSログ関連
*
* @details NTSSログ関連
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_log_lib.c
* @author H.Yonezawa
* @date 2017/11/29
*/


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <libgen.h>
#include <pthread.h> 

#include "../libs/ntss_log_lib.h"
#include "../libs/ntss_etc_lib.h"
#include "../libs/config_reader.h"
#include "../libs/ntss_sendlog_lib.h"

/*
/// ログ設定ファイル
#define NTSS_LOG_CONF_FILE "./conf/ntss_log.conf"
/// 各フォルダ最大定義件数
#define NTSS_FOLDER_DEFINE_MAX_COUNT 3


/// ログ格納先フォルダ
static u_char cLogFolder[ NTSS_FOLDER_DEFINE_MAX_COUNT ][ NTSS_STR_MAX_SIZE ];
/// 前回出力したログ格納先フォルダ番号
static int nLogFolderNo = -1;
/// 最大格納ログサイズ(既定：10MB)
static int nMaxLogSize = 10 * 1024 * 1024;
/// 最大保持日数(既定：20日)
static int nKeepLogDateCount = 20;

/// ログ開始時間
static time_t LogStartDateTime = 0;

/// ログ削除実施時間
static time_t LogDeleteDateTime = 0;

/// スレッド間で共有する排他制御変数
static pthread_mutex_t mutex = PTHREAD_MUTEX_INITIALIZER;
*/

/// @name ログ関連
//@{
/**
* @brief ログ設定を行う
*
* @details ログ設定を行う
*
* @description
* @return なし
* @attention 特になし
*/
void 
setLogInfo()
{
/*    
    // ミューテックス初期化
    pthread_mutex_init( &mutex, NULL );

    // ログ格納先フォルダ
    memset( cLogFolder, 0, sizeof( cLogFolder ));

    // ログ削除日時を初期化
    time( &LogDeleteDateTime );

    // 設定ファイル確認
    if( existFolderFile( NTSS_LOG_CONF_FILE, NULL ) == 1 )
    {
        // 作業用領域確保
        int nMaxSize = 20;
        ConfigData_t buffs[nMaxSize];
        
        char cKey[20];
        char *pVal;
        int intlop;

        // ログ設定読み込み
        memset( buffs, 0, sizeof( buffs ));
        int nlines = readConfigDataFile((const char *)NTSS_LOG_CONF_FILE, buffs, nMaxSize );
        if( 0 < nlines )
        {     
            // ログ格納先フォルダ([優先順位][バッファ数])
            for( intlop = 0; intlop < NTSS_FOLDER_DEFINE_MAX_COUNT; intlop ++ )
            {
                //
                sprintf( cKey, "LOG_FOLDER%d", intlop + 1 );
                if(( pVal = getConfigDataValue( buffs, nlines, cKey )) != NULL )
                {
                    strcat( cLogFolder[intlop], pVal );        

                    // 末尾に'/'追加
                    addFolderSeparator(cLogFolder[intlop]);
                }
            }
               
            // 最大格納ログサイズ
            if(( pVal = getConfigDataValue( buffs, nlines, "MAX_LOG_SIZE" )) != NULL )
            {
                int intval = atoi( pVal );
                if( 0 < intval )
                {
                    nMaxLogSize = intval * 1024 * 1024;
                }
            }

            // 最大保持日数
            if(( pVal = getConfigDataValue( buffs, nlines, "KEEP_LOG_DAY_COUNT" )) != NULL )
            {
                int intval = atoi( pVal );
                if( 0 <= intval )
                {
                    nKeepLogDateCount = intval;
                }
            }
        }
    }

    // ログ出力先フォルダが未設定の場合
    if( cLogFolder[0][0] == 0 
     && cLogFolder[1][0] == 0
     && cLogFolder[2][0] == 0
    )
    {
        // ログ格納先フォルダ(既定：直下のlogフォルダ内)
        strcpy( cLogFolder[0], "./log/" );
    }

    // ログ設定を記録する
    u_char clog[ NTSS_STR_MAX_SIZE ];
    sprintf(
         clog
       , "ログ設定 出力フォルダ:%s - %s - %s 最大サイズ(MB):%d 保持日数:%d"
       , cLogFolder[0]
       , cLogFolder[1]
       , cLogFolder[2]
       , nMaxLogSize / 1024 / 1024
       , nKeepLogDateCount
    );
    LogOutput( NTSS_LOG_INFO, clog );
*/

    // 書き込み用ソケット初期化
    ntss_sendlog_init();
}

/**
* @brief ログ設定（通信切断）を行う
*
* @details ログ設定（通信切断）を行う
*
* @description
* @return なし
* @attention 特になし
*/
void 
resetLogInfo()
{
    // 書き込み用ソケットクローズ
    ntss_sendlog_exit();
}

/**
* @brief ログを送信する
*
* @details ログを送信する
*
* @description
* @param[in] type               種別コード
* @param[in] *msg               ログメッセージ
* @param[in] flag               出力フラフ（0:通常,1:システム情報有り）
* @param[in] *cMachineType      型式(不要な場合はから文字を指定)
* @param[in] *cMachineSerial    製造番号(不要な場合はから文字を指定)
* @return なし
* @attention 特になし
*/
void
LogSend( NtssLogType type
        , u_char *msg 
        , int flag
        , u_char *cMachineType
        , u_char *cMachineSerialNo
        )
{
    u_char cProg[ NTSS_STR_MAX_SIZE ];
    u_char *id;
    u_char cMsg[40];

    // // 自プロセス名を取得
     memset( cProg, 0, sizeof( cProg ));
    // getProcessName( cProg, sizeof(cProg), 0x00 );   

    // ログファイルの固定情報作成
    switch( type )
    {
        case NTSS_LOG_INFO:
            id    = "[INFO ]";
            break;

        case NTSS_LOG_DEBUG:
            id    = "[DEBUG]";
            break;

        case NTSS_LOG_ERROR:
            id    = "[ERROR]";
            break;
    }

    // パラメータ作成(型式\t製造番号\tサービス名\tログ種別\t)
    sprintf(
          cMsg
        , "%s\t%s\t%s\t%s\t"
        , cMachineType
        , cMachineSerialNo
        , cProg
        , id
    );

    // ログ書き込み
    ntss_sendlog(
          flag
        , cMsg
        , msg
    );
}

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
void
LogOutput( NtssLogType type
         , u_char *msg 
         )
{
/*
    time_t tim;
    time_t tim_work;
    struct tm tmc;
    struct tm tmcLog;
    u_char cProg[ NTSS_STR_MAX_SIZE ];
    u_char cFile[ NTSS_STR_MAX_SIZE ];
    u_char *title;
    u_char *id;
    u_char cMsg[40];

    // 現在時刻取得
    time( &tim );
    localtime_r( &tim, &tmc );

    // 自プロセス名を取得
    memset( cProg, 0, sizeof( cProg ));
    getProcessName( cProg, sizeof(cProg), 0x00 );   

    // ログファイルの固定情報作成
    switch( type )
    {
        case NTSS_LOG_INFO:
            title = "TRACE_";
            id    = "[INFO ]";
            break;

        case NTSS_LOG_DEBUG:
            title = "TRACE_";
            id    = "[DEBUG]";
            break;

        case NTSS_LOG_ERROR:
            title = "ERROR_";
            id    = "[ERROR]";
            break;
    }

    // ログ出力内容作成
    sprintf(
        cMsg
        , "[ %04d/%02d/%02d %02d:%02d:%02d ] %s, "
        , tmc.tm_year + 1900
        , tmc.tm_mon + 1
        , tmc.tm_mday
        , tmc.tm_hour
        , tmc.tm_min
        , tmc.tm_sec
        , id
    );


    // ミューテックスをロック
    pthread_mutex_lock(&mutex);

    // ログファイル出力先フォルダ([優先順位][バッファ数])
    int intlop;
    u_char *pfolder;
    for( intlop = 0; intlop < NTSS_FOLDER_DEFINE_MAX_COUNT; intlop ++ )
    {
        //
        pfolder = cLogFolder[ intlop ];

        // ログ格納先フォルダ設定確認
        if( 0 < strlen( pfolder ))
        {
            // 設定あり

            //// debug
            //printf( "ログ出力先:%s\n", pfolder );

            // ログ格納フォルダの存在判定
            if( existFolderFile( pfolder, NULL ) == 0 )
            {
                // 存在しない場合

                // ログフォルダ作成
                if( createFolder( pfolder ) != 1 )
                {
                    // ログフォルダ作成失敗

                    //// debug
                    //printf( "ログフォルダ作成失敗 %s\n", pfolder );
                    continue;
                }
            }

            // ログ作成日時設定
            tim_work = tim;
            if( intlop == nLogFolderNo && LogStartDateTime != 0 )
            {
                // 前回と同じフォルダの場合は前回ログ開始日時を使用する
                tim_work = LogStartDateTime;
            }
            
            // ログファイル名作成
            localtime_r( &tim_work, &tmcLog );
            sprintf(
                cFile
                , "%s%s%s_%04d%02d%02d_%02d%02d%02d.LOG"
                , pfolder
                , title
                , cProg
                , tmcLog.tm_year + 1900
                , tmcLog.tm_mon + 1
                , tmcLog.tm_mday
                , tmcLog.tm_hour
                , tmcLog.tm_min
                , tmcLog.tm_sec
            );
            //// debug
            //printf( "ログファイル %s\n", cbuff );
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

                        // ログ出力先を保持
                        nLogFolderNo = intlop;

                        // ログ開始日時を保持
                        LogStartDateTime = tim_work;

                        // ログファイルのサイズ取得
                        struct stat stat;
                        if( existFolderFile( cFile, &stat ) == 1 )
                        {
                            // サイズ判定
                            if( nMaxLogSize <= stat.st_size )
                            {
                                // 設定サイズを超えている場合

                                // 次回のログファイル名を変更する
                                LogStartDateTime = 0;
                            }
                        }

                        break;
                    }
                }
            }
        }
    }

    // ミューテックスを開放
    pthread_mutex_unlock(&mutex);
*/    
    // ログ送信
    LogSend(
          type
        , msg 
        , 0
        , ""
        , ""
    );
}

// #8729 2023.05.29 add RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
/**
 * @fn void LogOutputs(NtssLogType type, u_char *msg, u_char *devType, u_char *devSerial)
 * @brief ログ出力（コンソール＆ファイル）を行う
 * @param[in] type 種別コード
 * @param[in] msg ログメッセージ
 * @param[in] flag 出力フラフ（0:通常,1:システム情報有り）
 * @param[in] devType 型式(不要な場合は空文字を指定)
 * @param[in] devSerial 製造番号(不要な場合は空文字を指定)
 */
void LogOutputs(NtssLogType type, u_char *msg, int flg, u_char *devType, u_char *devSerial)
{
    unsigned char cType[5]; 
    unsigned char cSerial[10]; 

    // コンソール出力
    printf("%s\n", msg);
    // ファイル出力
    memset(cType, 0, sizeof(cType));
    memset(cSerial, 0, sizeof(cSerial));
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
    //memcpy(cType, devType, 3);
    //memcpy(cSerial, devSerial, 8);
    if ( !((devType == NULL) || (devType[0] == '\0')) ) {
        memcpy(cType, devType, 3);
    }
    if ( !((devSerial == NULL) || (devSerial[0] == '\0')) ) {
        memcpy(cSerial, devSerial, 8);
    }
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
    LogSend(type, msg, flg, cType, cSerial);
}
// #8729 2023.05.29 add RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end

// #12304 2025.10.24 add ログ強化（CRCエラー） TDC片口 start
/**
 * @fn void LogOutputBufferHex(
 *          NtssLogType type, unsigned char *headerMessage,
 *          unsigned char *buffer, int bufferSize, unsigned
 *          char *devType, unsigned char *devSerial)
 * @brief ログ出力（バッファ内のHEX出力）を行う
 * @param[in] type 種別コード
 * @param[in] headerMessage ヘッダ部メッセージ
 * @param[in] buffer バッファ
 * @param[in] bufferSize バッファサイズ
 * @param[in] devType 型式(不要な場合は空文字を指定)
 * @param[in] devSerial 製造番号(不要な場合は空文字を指定)
 * @return なし
 * @attention 特になし
 */
void LogOutputsHexDump(
    NtssLogType type, unsigned char *headerMessage,
    unsigned char *buffer, short bufferSize,
    unsigned char *devType, unsigned char *devSerial)
{
    unsigned char logMsg[2048];
    unsigned char lineBuf[256];
    short offset = 0;
    short lineLen = 100;
    short i, j, page, totalPages;

    totalPages = (bufferSize + lineLen - 1) / lineLen;

    // バッファ内のHEX出力
    for (i = 0; i < bufferSize; i += lineLen) {
        page = i / lineLen + 1;

        // ヘッダメッセージ設定
        memset(logMsg, 0, sizeof(logMsg));
        snprintf(logMsg, sizeof(logMsg) - 1, "%s(%d/%d) ", headerMessage, page, totalPages);
        offset = strlen(logMsg);

        memset(lineBuf, 0, sizeof(lineBuf));
        for (j = 0; j < lineLen && (i + j) < bufferSize; j++) {
            snprintf(lineBuf + (j * 2), sizeof(lineBuf) - (j * 2), "%02x", buffer[i + j]);
        }
        snprintf(logMsg + offset, sizeof(logMsg) - offset - 1, "%s\n", lineBuf);

        // ログ送信
        LogOutputs(type, logMsg, 0, devType, devSerial);
    }
}
// #12304 2025.10.24 add ログ強化（CRCエラー） TDC片口 end


/**
* @brief ログ+リソース出力を行う
*
* @details ログ+リソース出力を行う
*
* @description
* @param[in] type   種別コード
* @param[in] *msg   ログメッセージ
* @return なし
* @attention 特になし
*/
void
LogResourceOutput( NtssLogType type
                 , u_char *msg 
                 )
{
    // ログ送信
    LogSend(
          type
        , msg 
        , 1
        , ""
        , ""
    );
}

/**
* @brief ログ+ネットワーク状態出力を行う
*
* @details ログ+ネットワーク状態出力を行う
*
* @description
* @param[in] type   種別コード
* @param[in] *msg   ログメッセージ
* @return なし
* @attention 特になし
*/
void
LogNetworkOutput( NtssLogType type
                 , u_char *msg 
                 )
{
    // ログ送信
    LogSend(
          type
        , msg 
        , 2
        , ""
        , ""
    );
}

/**
* @brief エラー表示+記録
*
* @details エラーを表示、記録する
*
* @description
* @param[in] *errmsg 表示エラーメッセージ文
* @return なし
* @attention 特になし
*/
void
viewError( char *errmsg
         )
{
    fprintf(
          stderr
        , "ERROR: %s\n"
        , errmsg
    );
//    LogOutput( NTSS_LOG_ERROR, errmsg );
    LogResourceOutput( NTSS_LOG_ERROR, errmsg );
}

/**
* @brief エラー表示+記録(+リソース出力)
*
* @details エラーを表示、記録する
*
* @description
* @param[in] *errmsg            表示エラーメッセージ文
* @param[in] *cMachineType      型式(不要な場合はから文字を指定)
* @param[in] *cMachineSerial    製造番号(不要な場合はから文字を指定)
* @return なし
* @attention 特になし
*/
void
viewErrorLogSend( char *errmsg
                , u_char *cMachineType
                , u_char *cMachineSerial
                )
{
    fprintf(
          stderr
        , "ERROR: %s\n"
        , errmsg
    );

    // ログ送信
    LogSend(
          NTSS_LOG_ERROR
        , errmsg 
        , 1
        , cMachineType
        , cMachineSerial
    );
}

/**
* @brief エラー表示+記録(+ネットワーク状態出力)
*
* @details エラーを表示、記録する
*
* @description
* @param[in] *errmsg            表示エラーメッセージ文
* @param[in] *cMachineType      型式(不要な場合はから文字を指定)
* @param[in] *cMachineSerial    製造番号(不要な場合はから文字を指定)
* @return なし
* @attention 特になし
*/
void
viewErrorLogSend2( char *errmsg
                 , u_char *cMachineType
                 , u_char *cMachineSerial
                 )
{
    fprintf(
          stderr
        , "ERROR: %s\n"
        , errmsg
    );

    // ログ送信
    LogSend(
          NTSS_LOG_ERROR
        , errmsg 
        , 2
        , cMachineType
        , cMachineSerial
    );
}

/**
* @brief ログファイルの削除
*
* @details 日付を超えた場合にログの削除を行う
*
* @description
* @prama[in] Mode   処理方法[0x00：日付が変わった時/0x01：強制実施]
* @return なし
* @attention 特になし
*/
void
deleteLogFile( u_char Mode
             )
{
/*    
    time_t tim;
    struct tm tmc;
    struct tm tmcLog;
    u_char cNow[10];
    u_char cDelete[10];
    u_char cbuff[ NTSS_STR_MAX_SIZE ];
    
    // 現在日時取得
    time( &tim );
    memmove( &tmc, localtime(&tim), sizeof( struct tm ));
    sprintf(
          cNow
        , "%04d%02d%02d"
        , tmc.tm_year + 1900
        , tmc.tm_mon + 1
        , tmc.tm_mday
    );

    // 前回ログ削除日時取得
    memmove( &tmcLog, localtime( &LogDeleteDateTime ), sizeof( struct tm ));
    sprintf(
          cDelete
        , "%04d%02d%02d"
        , tmcLog.tm_year + 1900
        , tmcLog.tm_mon + 1
        , tmcLog.tm_mday
    );

    // 前回削除日時から日付が変わったかどうか(又は強制実施)
    if( 0 < strcmp( cNow, cDelete ) || Mode == 0x01 )
    {
        // 経過している場合

        // 前回削除日付を更新
        LogDeleteDateTime = tim;

        // ログ格納先フォルダ([優先順位][バッファ数])
        int intlop;
        u_char *pfolder;
        for( intlop = 0; intlop < NTSS_FOLDER_DEFINE_MAX_COUNT; intlop ++ )
        {
            //
            pfolder = cLogFolder[ intlop ];

            // ログ格納先フォルダ設定確認
            if( 0 < strlen( pfolder ))
            {
                // 設定あり

                // ログ格納先フォルダの存在判定
                if( existFolderFile( pfolder, NULL ) == 1 )
                {
                    // 更新日時が設定されている日付より前のログを削除
                    sprintf(
                          cbuff
                        , "find \"%s\" -mtime +%d -name \"*.LOG\" | xargs rm -f"
                        , pfolder
                        , nKeepLogDateCount
                    );
                    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
                    int res = system( cbuff );
                    if( WIFEXITED( res ) )
                    {
                        // 子プロセスが正常に終了した場合

                        // 子プロセスの終了ステータスを取得
                        res = WEXITSTATUS( res );
                    }

                    // 処理結果を記録する
                    sprintf(
                        cbuff
                    , "ログ削除処理実施,%s,(%d)"
                    , pfolder
                    , res
                    );
                    LogOutput( NTSS_LOG_INFO, cbuff );
                }
            }
        }
    }    
*/    
}
