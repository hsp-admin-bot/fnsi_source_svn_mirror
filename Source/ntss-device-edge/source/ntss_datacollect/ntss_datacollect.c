/**
* @brief NTSSデータ収集アプリケーション用コード
*
* @details データ収集及びデータ転送を行う
*
* @description ntss packet capture program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_datacollect.c
* @author H.Yonezawa
* @date 2017/11/17
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <signal.h>
#include <unistd.h>
#include <pthread.h>

#include "ntss_datacollect_conf.h"
#include "ntss_machine_info.h"
#include "ntss_datacollect_etc.h"

#include "../common/libs/ntss_etc_lib.h"
#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/ntss_upload_lib.h"


/// データ収集完了シグナル
#define NTSS_DATACOLLECT_COMPLETE_SIGNAL 35

/// @name signal用フラグ
//@{
/// 終了判定用フラグ
volatile sig_atomic_t endProcessFlag = 0;
//@}

/// 作業用フォルダ
u_char cWorkFolder[ NTSS_STR_MAX_SIZE ];

/// データ収集番号有無フラグ[0：なし/1：あり]
int isRequestDataCollect = 0;

/// アップロード先パス名作成[設定 + 施設コード]
u_char cUploadPath[ NTSS_STR_MAX_SIZE ];
/// アップロード先URI作成
u_char cUploadURI[ NTSS_STR_MAX_SIZE ];


/**
* @brief データ転送処理(スレッド)
*
* @details データ転送処理を行う
*
* @description
* @return なし
* @attention 特になし
*/
extern void *
uploadNTSSFileThread();


/**
* @brief シグナル受信処理
*
* @details シグナル指示を受け付ける
*
* @description
* @param[in] *signum
* @return なし
* @attention 特になし
*/
void 
signalHandler(int signum)
{
    u_char *msg = NULL;

    switch( signum )
    {
/*
        case SIGTERM:   // 終了指示

            // 処理終了
            endProcessFlag = 1;
            msg ="SIGTERM受信";
            break;
*/
        case SIGINT:    // キーボード割り込み(ctrl+c)

            // 終了処理
            endProcessFlag = 1;
            msg ="SIGINT受信";
            break;

        case SIGKILL:   // 強制終了

            // 処理終了
            endProcessFlag = 1;
            msg ="SIGKILL受信";
            break;

        case SIGPIPE:   // 無効パイプへの書込
            msg ="SIGPIPE受信";
            signal( SIGPIPE,  signalHandler );
            // ログ送信用ソケットをリセット
            resetLogInfo();
            break;
    }

    //
    if( msg != NULL )
    {
        // 画面表示
        printf( "%s\n", msg );

        //// 受け取ったシグナルを記録する
        //LogOutput( NTSS_LOG_INFO, msg );
    }
}
/**
* @brief シグナル設定
*
* @details シグナル設定を行う
*
* @description
* @return シグナル設定結果
* @attention 特になし
*/
__sighandler_t setSignal()
{
    __sighandler_t ret = SIG_DFL;

    // プログラム終了のためのシグナル設定
/*    
    if( ret != SIG_ERR )
    {
        ret = signal( SIGTERM, signalHandler );
    }
*/
    if( ret != SIG_ERR )
    {
        ret = signal( SIGINT,  signalHandler );
    }
    if( ret != SIG_ERR )
    {
        ret = signal( SIGPIPE,  signalHandler );
    }

    return ret;    
}


/**
* @brief メイン
*
* @details メイン処理
*
* @description
* @param[in] argc    第一引数
* @param[in] *argv[] 第二引数
* @return 終了コード
* @attention 特になし
*/
int
main( int argc
    , char *argv[]
    )
{
    char clog[1100];    
    int res;

    // ログ設定
    setLogInfo();


    // システム起動
    sprintf( clog, "[START],システム起動");
    printf( "%s\n", clog );
    LogOutput( NTSS_LOG_INFO, clog );

    // シグナル設定
    if( setSignal() == SIG_ERR )
    {
        // シグナル設定エラー
        viewError( "シグナルの設定ができないので終了します" );
        exit(EXIT_FAILURE);
    }

    // 設定ファイル読み込み
    res = getNTSSDataCollectConf();
    if( res != 1 )
    {  
        sprintf(
              clog
            , "設定ファイルの読み込みに失敗しました,(%d)"
            , res
        );
        viewError( clog );
        exit(EXIT_FAILURE);
    }

	// 処理結果ファイル削除
    char cmd[256];
	sprintf( cmd, "rm -f %s", "RESULT_DATACOLLECT*.*" );
	system( cmd );
    // ファイルに出力する
    LogOutput( NTSS_LOG_INFO, "処理結果ファイル削除,RESULT_DATACOLLECT*.*" );

    // 引数から情報取得
    if( 1 < argc )
    {
        // プロセス番号
        datacollectConf.nOwnerProcessId = atoi( argv[1] );

        if( 3 <= argc )
        {
            // シーケンス番号
            strcat( datacollectConf.cDataCollectSeqNo, argv[2] );
            if( argc == 4 )
            {
                // 装置指定ファイル名
                strcat( datacollectConf.cMachineListFile, argv[3] );                
            }

            // 引数を画面に出力する
            sprintf(
                    clog
                , "PID:%d / SeqNo:%s / File:%s"
                , datacollectConf.nOwnerProcessId
                , datacollectConf.cDataCollectSeqNo
                , datacollectConf.cMachineListFile
            );
            printf("%s\n", clog);

            //引数をファイルに出力する
            LogOutput( NTSS_LOG_INFO, clog );
        }
    }

    // アップロード先パス名作成[設定 + 施設コード]
    sprintf(
          cUploadPath
        , datacollectConf.cUploadPath
        , datacollectConf.cFacilityCd
    );
    // アップロード先URI作成
    sprintf( 
          cUploadURI
        , "%s%s"
        , datacollectConf.cAWSHostName
        , datacollectConf.cAWSAddress
    );

    // 引数を画面に出力する
    sprintf(
          clog
        , "UPLOAD PATH:%s / URI:%s"
        , cUploadPath
        , cUploadURI
    );
    printf("%s\n", clog);

    //引数をファイルに出力する
    LogOutput( NTSS_LOG_INFO, clog );
    

    // 処理開始日時を設定
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //long tim;
    time_t tim;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    struct tm tmc;
    time(&tim);
    localtime_r(&tim, &tmc);
    sprintf( 
          datacollectConf.cStartDateTime
        , "%04d%02d%02d%02d%02d%02d"
        , tmc.tm_year + 1900
        , tmc.tm_mon + 1
        , tmc.tm_mday
        , tmc.tm_hour
        , tmc.tm_min
        , tmc.tm_sec
    );

    // 処理対象装置一覧を作成
    initNTSSDataCollectMahineInfo(
          datacollectConf.cMstFolder
        , datacollectConf.cMachineListFile
    );

    // 対象装置台数算出
    int nMachineCount = 0;    
    int intlop;
    struct NTSS_DATACOLLECT_MACHINE_INFORMATION *info;
    for( intlop = 0; intlop < NTSS_DATACOLLECT_MACHINE_INFORMATION_COUNT; intlop++ )
    {
        // データ収集対象装置情報を取得
        info = getNTSSDataCollectMachineInfo( intlop );
        if( info != NULL )
        {
            nMachineCount++;
        }
    }
    //
    sprintf(
           clog
         , "データ取得処理開始 対象装置 %d 台"
         , nMachineCount
    );
    printf( "%s\n", clog );
    LogOutput( NTSS_LOG_INFO, clog );

    // 装置指定ファイル存在確認
    if( 0 < strlen( datacollectConf.cMachineListFile ))
    {
        // 装置指定ファイルがある場合
        
        // 該当ファイル削除
        remove( datacollectConf.cMachineListFile );
    }

    // シーケンス番号判定
    if( datacollectConf.cDataCollectSeqNo[0] != 0 )
    {
        // シーケンス番号が与えられている場合はデータ転送ありとする

        isRequestDataCollect = 1;
    }
    //// debug
    //isRequestDataCollect = 1;

    //
    pthread_t th = 0;

    // データ転送ありの場合
    if( isRequestDataCollect == 1 )
    {
        // スレッド作成と起動
        pthread_create( &th, NULL, uploadNTSSFileThread, (void *)NULL );
    }


    // 処理対象装置分繰り返し
    int intlop2;
    u_char cDeviceType[4];
    u_char cDeviceNo[9];
    u_char cMachineName[13];
    u_char cMachineFileName[ sizeof( cMachineName )];
    u_char cFolder[ NTSS_STR_MAX_SIZE ];
    u_char cLogFolder[ NTSS_STR_MAX_SIZE ];
    u_char cFTPFolder[ NTSS_STR_MAX_SIZE ];
    u_char cFNFolder[ NTSS_STR_MAX_SIZE ];
    u_char cURL[ NTSS_STR_MAX_SIZE ];
    u_char cMachinePattern[ NTSS_STR_MAX_SIZE ];
    u_char cZipFileName[ NTSS_STR_MAX_SIZE ];
    for( intlop = 0; intlop < NTSS_DATACOLLECT_MACHINE_INFORMATION_COUNT; intlop++ )
    {
        // データ収集対象装置情報を取得
        info = getNTSSDataCollectMachineInfo( intlop );
        if( info != NULL )
        {
            // 型式コード
            memset( cDeviceType, 0, sizeof( cDeviceType ));
            memmove( cDeviceType, info->cDeviceType, sizeof( info->cDeviceType ));

            // 製造番号
            memset( cDeviceNo, 0, sizeof( cDeviceNo ));
            memmove( cDeviceNo, info->cDeviceNo, sizeof( info->cDeviceNo ));

            // debug
            printf(
                   "no:%d info %c %-27.27s %c \n"
                 , intlop
                 , info->cCommTypeCd
                 , info->cDeviceType
                 , info->cIsFTPCollect
            );

            // 処理中止判定
            if( endProcessFlag == 1 )
            {
                break;
            }

            // 装置識別名取得
            cMachineName[12] = 0;
            memmove( cMachineName, info->cDeviceType, sizeof( info->cDeviceType ) + + sizeof( info->cDeviceFormat ) + sizeof( info->cDeviceNo ));
            // 末尾の空白除去
            trimEnd( cMachineName, ' ' );
            // 装置ファイル名作成
            memmove( cMachineFileName, cMachineName, sizeof( cMachineName ));
            // 通信フォーマット箇所を'_'に変更
            cMachineFileName[3] = '_';

            //　作業フォルダが使用できない場合はFTP/FNともに取得失敗とするためここでセット
            info->cFNCode = info->cFTPCode = 2;

            // データ取得処理開始
            info->cStatus = 1;
            sprintf( 
                clog
                , "データ取得対象装置,%s"
                , cMachineName
            );
            printf( "%s\n", clog );
            outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );

            // 作業用フォルダ作成 
            cWorkFolder[0] = 0;
            for( intlop2 = 0; intlop2 < NTSS_FOLDER_DEFINE_MAX_COUNT; intlop2++ )
            {
                // 設定有無判定
                if( 0 < strlen( datacollectConf.cWorkFolder[intlop2]))
                {
                    // 作業用フォルダ判定
                    if( cWorkFolder[0] == 0 )
                    {
                        // 作業用フォルダが未確定である場合

                        // 作業用フォルダを作成
                        memset( cFolder, 0, sizeof( cFolder ));
                        if( makeNTSSDataCollectWorkFolder(
                              datacollectConf.cWorkFolder[intlop2]
                            , cMachineName
                            , cFolder
                        ) == 1 )
                        {
                            // 作業フォルダを記録
                            sprintf( 
                                  clog
                                , "装置作業用フォルダ名,%s"
                                , cFolder
                            );
                            printf( "%s\n", clog );
                            outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );

                            // 作業フォルダを設定
                            strcpy( cWorkFolder, datacollectConf.cWorkFolder[intlop2] );
                        }
                        else
                        {
                            // 作業用フォルダ作成失敗
                            
                            sprintf(
                                clog
                                , "装置作業用フォルダ作成失敗:%s%s"
                                , datacollectConf.cWorkFolder[intlop2]
                                , cMachineName
                            );
                            outputNTSSDataCollectMachineInfoErrorLog( clog, info );
                        }
                    }
                    else
                    {
                        // 作業フォルダが確定している場合

                        // 作業フォルダを記録
                        sprintf( 
                              clog
                            , "他の装置作業用フォルダ内にある未転送ファイルを装置作業用フォルダへ移動,%s%s/→%s"
                            , datacollectConf.cWorkFolder[intlop2]
                            , cMachineName
                            , cFolder
                        );
                        printf( "%s\n", clog );
                        outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );

                        // 優先度の低い作業用フォルダにあるFTP収集データ、FN通信データを回収
                        moveNTSSDataCollectWorkFolderFile(
                              datacollectConf.cWorkFolder[intlop2]
                            , cWorkFolder
                            , cMachineName
                            , info
                        );
                    }
                }
            }

            // 作業フォルダ判定
            if( cWorkFolder[0] != 0 )
            {
                // 作業フォルダが指定されている場合

                //　FTP/FNともに終了コードをセット
                info->cFNCode = info->cFTPCode = 0;

                // ログ出力先フォルダ名作成
                sprintf(
                      cLogFolder
                    , "%sLOG/"
                    , cFolder
                );

                // FTP処理対象判定
                if( info->cIsFTPCollect == '1' )
                {
                    // FTP収集対象装置である場合
                    
                    // FTPサーバーURL作成
                    sprintf(
                          cURL
                        , "%.15s%s"
                        , info->cIPAddr
                        , datacollectConf.cFTP_Folder
                    );
                    // FTPデータ格納先フォルダ名作成
                    sprintf(
                          cFTPFolder
                        , "%sFTP/"
                        , cFolder
                    );
                    //
                    sprintf( 
                          clog
                        , "FTP収集データ収集開始,装置,%s, URL:%s"
                        , cMachineName
                        , cURL
                    );
                    printf( "%s\n", clog );
                    outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );

                    // FTP収集を行う場合はFTPデータを収集
                    res = getNTSSFTP(
                          cURL
                        , datacollectConf.cFTP_User
                        , datacollectConf.cFTP_PW
                        , cLogFolder
                        , cFTPFolder
                        , datacollectConf.nFTP_Wait
                        , datacollectConf.nFTP_Retry
                        , info
                    );
                    if( res != 0 )
                    {
                        // FTPデータ収集失敗

                        //
                        info->cFTPCode = 2;

                        //
                        sprintf( 
                            clog
                            , "FTP収集データ収集失敗,装置,%s,(%d)"
                            , cMachineName
                            , res
                        );
                        outputNTSSDataCollectMachineInfoErrorLog( clog, info );
                    }
                    //
                    sprintf( 
                          clog
                        , "FTP収集データ収集終了,装置,%s,(%d)"
                        , cMachineName
                        , res
                    );
                    printf( "%s\n", clog );
                    outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );
                }
                else
                {
                    // FTP収集対象外装置である場合

                    //
                    info->cFTPCode = 1;

                    //
                    sprintf( 
                        clog
                        , "FTP収集データ収集対象外,装置,%s"
                        , cMachineName
                    );
                    printf( "%s\n", clog );
                    outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );
                }
                    
                // データ収集要求判定
                if( isRequestDataCollect == 0 )
                {
                    // データ収集要求がない場合はFTPデータ収集のみ実施とする
                    continue;
                }

                // FTP収集に成功している場合
                if( info->cFTPCode == 0 )
                {
                    // FTP収集ファイルがあるかどうか判定
                    if( existFolderInFiles(
                        cFTPFolder
                    ) == 1 )
                    {
                        // 対象ファルあり

                        // FTPデータ圧縮ファイル名作成
                        sprintf(
                              cZipFileName
                            , "%s%s_%s_%s_FTP.zip"
                            , cFolder
                            , datacollectConf.cDataCollectSeqNo
                            , cMachineFileName
                            , datacollectConf.cStartDateTime
                        );
                        //
                        sprintf( 
                              clog
                            , "FTP収集データ圧縮開始,装置,%s,%s,%s"
                            , cMachineName
                            , cFTPFolder
                            , cZipFileName
                        );
                        printf( "%s\n", clog );
                        outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );

                        // FTP収集データを圧縮
                        res = zipNTSSFiles(
                              cFTPFolder
                            , cZipFileName
                            , datacollectConf.cZipPW
                            , cLogFolder
                            , cDeviceType
                            , cDeviceNo
                        );
                        if( res != 0 )
                        {
                            // 圧縮失敗

                            info->cFTPCode = 3;

                            //
                            sprintf( 
                                  clog
                                , "FTP収集データ圧縮失敗,装置,%s,%s,(%d)"
                                , cMachineName
                                , cZipFileName
                                , res
                            );
                            outputNTSSDataCollectMachineInfoErrorLog( clog, info );
                        }

                        //
                        sprintf( 
                              clog
                            , "FTP収集データ圧縮終了,装置,%s,%s,(%d)"
                            , cMachineName
                            , cZipFileName
                            , res
                        );
                        printf( "%s\n", clog );
                        outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );
                    }
                    else
                    {
                        // 対象ファイルなし

                        //
                        info->cFTPCode = 1;

                        //
                        sprintf( 
                              clog
                            , "FTP収集データ圧縮対象ファイルなし,装置,%s"
                            , cMachineName
                        );
                        printf( "%s\n", clog );
                        outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );
                    }
                }

                // 処理中止判定
                if( endProcessFlag == 1 )
                {
                    break;
                }


                // FNデータ格納先フォルダ名作成
                sprintf(
                      cFNFolder
                    , "%sFN/"
                    , cFolder
                );
                // FNデータ抽出パターン作成
                sprintf(
                      cMachinePattern
                    , "%s_.*\\.bin"
                    , cMachineFileName
                );
                //
                sprintf( 
                      clog
                    , "FN通信データ収集開始,装置,%s"
                    , cMachineName
                );
                printf( "%s\n", clog );
                outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );

                // データ収集用フォルダ設定分
                for( intlop2 = 0; intlop2 < NTSS_FOLDER_DEFINE_MAX_COUNT; intlop2++ )
                {
                    // 設定有無判定
                    if( 0 < strlen( datacollectConf.cDataCollectFolder[intlop2]))
                    {
                        // FN通信データを移動
                        res = moveNTSSDataCollectFNFile(
                              datacollectConf.cDataCollectFolder[intlop2]
                            , cFNFolder
                            , cMachinePattern
                            , cLogFolder
                            , info
                        );
                        if( res != 1 )
                        {
                            // FNデータ収集失敗

                            info->cFNCode = 2;

                            //
                            sprintf( 
                                clog
                                , "FN通信データ収集失敗,装置,%s,(%d)"
                                , cMachineName
                                , res
                            );
                            outputNTSSDataCollectMachineInfoErrorLog( clog, info );
                        }
                    }
                }

                //
                sprintf( 
                      clog
                    , "FN通信データ収集終了,装置,%s,(%d)"
                    , cMachineName
                    , res
                );
                printf( "%s\n", clog );
                outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );

                // FN収集ファイルがあるかどうか判定
                if( existFolderInFiles(
                    cFNFolder
                ) == 1 )
                {
                    // 対象ファルあり

                    // FNデータ圧縮ファイル名作成
                    sprintf(
                          cZipFileName
                        , "%s%s_%s_%s_FN.zip"
                        , cFolder
                        , datacollectConf.cDataCollectSeqNo
                        , cMachineFileName
                        , datacollectConf.cStartDateTime
                    );
                    //
                    sprintf( 
                          clog
                        , "FN通信データ圧縮開始,装置,%s,%s,%s"
                        , cMachineName
                        , cFNFolder
                        , cZipFileName
                    );
                    printf( "%s\n", clog );
                    outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );

                    // FN収集データを圧縮
                    res = zipNTSSFiles(
                          cFNFolder
                        , cZipFileName
                        , datacollectConf.cZipPW
                        , cLogFolder
                        , cDeviceType
                        , cDeviceNo
                    );
                    if( res != 0 )
                    {
                        // 圧縮失敗

                        info->cFNCode = 3;

                        //
                        sprintf( 
                            clog
                            , "FN通信データ圧縮失敗,装置,%s,%s,(%d)"
                            , cMachineName
                            , cZipFileName
                            , res
                        );
                        outputNTSSDataCollectMachineInfoErrorLog( clog, info );
                    }

                    //
                    sprintf( 
                          clog
                        , "FN通信データ圧縮終了,装置,%s,%s,(%d)"
                        , cMachineName
                        , cZipFileName
                        , res
                    );
                    printf( "%s\n", clog );
                    outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );
                }
                else{
                    // 対象ファイルなし

                    //
                    info->cFNCode = 1;

                    //
                    sprintf( 
                          clog
                        , "FN通信データ圧縮対象ファイルなし,装置,%s"
                        , cMachineName
                    );
                    printf( "%s\n", clog );
                    outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );
                }
            }

            // データ取得処理終了
            info->cStatus = 2;            

            // 10ミリ秒待ち
            usleep( 10000 );                             
        }
    }


    // スレッド終了待ち
    if( th != 0 )
    {
        pthread_join( th, NULL );
    }


    //　処理結果判定
    int nOK = 0;
    int nNG = 0;
    int nNoFile = 0;
    for( intlop = 0; intlop < NTSS_DATACOLLECT_MACHINE_INFORMATION_COUNT; intlop++ )
    {
        // データ収集対象装置情報を取得
        info = getNTSSDataCollectMachineInfo( intlop );
        if( info != NULL )
        {
            // 装置識別名取得
            cMachineName[12] = 0;
            memmove( cMachineName, info->cDeviceType, sizeof( info->cDeviceType ) + sizeof( info->cDeviceFormat ) + sizeof( info->cDeviceNo ));

            // 装置ステータス
            sprintf(
                  clog
                , "status no:%d %s FTP:%d FN:%d"
                , intlop
                , cMachineName
                , info->cFTPCode
                , info->cFNCode
            );
            outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );

            // debug
            printf( "%s\n", clog );

            // FTP判定
            if( info->cFTPCode == 0 )
            {
                nOK++;
            }
            else if( info->cFTPCode == 1 )
            {
                nOK++;
                nNoFile++;
            }
            else
            {
                nNG++;
            }

            // FN判定
            if( info->cFNCode == 0 )
            {
                nOK++;
            }
            else if( info->cFNCode== 1 )
            {
                nOK++;
                nNoFile++;
            }
            else
            {
                nNG++;
            }
        }
    }
    if( 0 < nNG )
    {
        if( 0 < nOK   )  
        {
            // 一部異常
            res = -2;
        }
        else
        {
            // 異常
            res = -1; 
        }
    }
    else
    {
        // 転送完了
        res = 2;
    }
    // 装置ステータス記録ファイル名作成
    if( isRequestDataCollect == 0 )
    {
        // シーケンス番号なし
        sprintf(
                cZipFileName
            // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
            // , "./RESULT_DATACOLLECT_CONTENT.TXT"
            , "/tmp/RESULT_DATACOLLECT_CONTENT.TXT"
            // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
        );
    }
    else
    {
        // シーケンス番号あり
        sprintf(
                cZipFileName
            // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
            // , "./RESULT_DATACOLLECT_CONTENT_%s.TXT"
            , "/tmp/RESULT_DATACOLLECT_CONTENT_%s.TXT"
            // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
            , datacollectConf.cDataCollectSeqNo
        );
    }
    remove( cZipFileName );
    // 処理結果記録
    sprintf(
          clog
        , "%d"
        , res
    );
    outputAppendFile(
          cZipFileName
        , clog
        , strlen( clog )
    );
    // 装置情報結果の付加が必要かどうか判断
    if( 0 < nNoFile || 0 < nNG )
    {
        // 装置情報結果の付加が必要

        // セパレータ追記
        outputAppendFile(
              cZipFileName
            , "_"
            , 1
        );

        //
        for( intlop = 0; intlop < NTSS_DATACOLLECT_MACHINE_INFORMATION_COUNT; intlop++ )
        {
            // データ収集対象装置情報を取得
            info = getNTSSDataCollectMachineInfo( intlop );
            if( info != NULL )
            {
                // エラー判定場合
                if(! ( info->cFTPCode == 0 && info->cFNCode == 0 ))
                {
                    // エラーがあった場合

                    // 装置識別名取得
                    cMachineName[12] = 0;
                    memmove( cMachineName, info->cDeviceType, sizeof( info->cDeviceType ) + sizeof( info->cDeviceFormat ) + sizeof( info->cDeviceNo ));

                    // 装置ステータス記録
                    sprintf(
                          clog
                        , "%s%d%d"
                        , cMachineName
                        , info->cFNCode
                        , info->cFTPCode
                    );
                    outputAppendFile(
                          cZipFileName
                        , clog
                        , strlen( clog )
                    );
                }
            }
        }
    }

    //
    sprintf(
          clog
        , "データ取得処理終了 (%d)"
        , res
    );
    printf( "%s\n", clog );
    LogOutput( NTSS_LOG_INFO, clog );

    // プロセスが指定されている場合
    if( 0 < datacollectConf.nOwnerProcessId )
    {
        // シグナルによる処理完了を通知
        res = kill( datacollectConf.nOwnerProcessId, NTSS_DATACOLLECT_COMPLETE_SIGNAL );
        if( res  == 0 )
        {
            // 通知成功

            sprintf( 
                  clog
                , "処理完了通知成功 シグナル:%d,(%d)"
                , NTSS_DATACOLLECT_COMPLETE_SIGNAL
                , res
            );
            LogOutput( NTSS_LOG_INFO, clog );
        }
        else
        {
            // 通知失敗                
            sprintf( 
                  clog
                , "処理完了通知失敗 シグナル:%d,(%d)"
                , NTSS_DATACOLLECT_COMPLETE_SIGNAL
                , res
            );
            LogOutput( NTSS_LOG_ERROR, clog );
        }
    }


    // // 自プロセス名を取得
    // memset( clog, 0, sizeof( clog ));
    // getProcessName( clog, sizeof(clog), 0x00 );   
    // printf( "%sが終了しました\n", clog );
    
    // システム終了
    strcpy( clog, "[STOP],システム終了" );
    printf( "%s\n", clog );
    LogOutput( NTSS_LOG_INFO, clog );

    return res;
}


/**
* @brief データ転送処理(スレッド)
*
* @details データ転送処理を行う
*
* @description
* @return なし
* @attention 特になし
*/
void *
uploadNTSSFileThread()
{
//以下はスレッドにて実施予定
    // FTP圧縮ファイルを転送(必要により分割)
    // 転送成功時はFTP収集データを削除

    // FN圧縮ファイルを転送(必要により分割)
    // 転送成功時はFN収集データを削除

    // 圧縮ファイルは処理後にすべて削除

    char clog[1100];

    // アップロードファイルリスト記録ファイル名作成
    u_char cUploadListFile[ NTSS_STR_MAX_SIZE ];
    if( isRequestDataCollect == 0 )
    {
        // シーケンス番号なし
        sprintf(
              cUploadListFile
            // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
            // , "./RESULT_DATACOLLECT_FILENAME.TXT"
            , "/tmp/RESULT_DATACOLLECT_FILENAME.TXT"
            // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
        );
    }
    else
    {
        // シーケンス番号あり
        sprintf(
              cUploadListFile
            // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
            // , "./RESULT_DATACOLLECT_FILENAME_%s.TXT"
            , "/tmp/RESULT_DATACOLLECT_FILENAME_%s.TXT"
            // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
            , datacollectConf.cDataCollectSeqNo
        );
    }
    remove( cUploadListFile );

    // アップロード先記録ファイル名作成
    u_char cUploadPathFile[ NTSS_STR_MAX_SIZE ];
    if( isRequestDataCollect == 0 )
    {
        // シーケンス番号なし
        sprintf(
              cUploadPathFile
            // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
            // , "./RESULT_DATACOLLECT_FILEPATH.TXT"
            , "/tmp/RESULT_DATACOLLECT_FILEPATH.TXT"
            // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
        );
    }
    else
    {
        // シーケンス番号あり
        sprintf(
              cUploadPathFile
            // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
            // , "./RESULT_DATACOLLECT_FILEPATH_%s.TXT"
            , "/tmp/RESULT_DATACOLLECT_FILEPATH_%s.TXT"
            // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
            , datacollectConf.cDataCollectSeqNo
        );
    }
    remove( cUploadPathFile );

    // アップロード先書き込み
    outputAppendFile(
          cUploadPathFile
        , cUploadPath
        , strlen( cUploadPath )
    );

    // 処理対象装置分繰り返し
    u_char cAddFlag = 0;
    int nseperatecount;
    int res;
    int intlop;
    struct NTSS_DATACOLLECT_MACHINE_INFORMATION *info;
    u_char cDeviceType[4];
    u_char cDeviceNo[9];
    u_char cMachineName[13];
    u_char cMachineNameOrg[ sizeof( cMachineName )];
    u_char cMachineFileName[ sizeof( cMachineName )];
    u_char cFolder[ NTSS_STR_MAX_SIZE ];
    u_char cLogFolder[ NTSS_STR_MAX_SIZE ];
    u_char cFile[ NTSS_STR_MAX_SIZE ];
    u_char cUploadFile[ NTSS_STR_MAX_SIZE ];
    u_char *p;
    for( intlop = 0; intlop < NTSS_DATACOLLECT_MACHINE_INFORMATION_COUNT; intlop++ )
    {
        // データ収集対象装置情報を取得
        info = getNTSSDataCollectMachineInfo( intlop );
        if( info != NULL )
        {
            // データ収集完了待ち
            while( info->cStatus < 2 )
            {
                // 10ミリ秒待ち
                usleep( 10000 );                             

                // 処理中止判定
                if( endProcessFlag == 1 )
                {
                    break;
                }
            };

            // 型式コード
            memset( cDeviceType, 0, sizeof( cDeviceType ));
            memmove( cDeviceType, info->cDeviceType, sizeof( info->cDeviceType ));

            // 製造番号
            memset( cDeviceNo, 0, sizeof( cDeviceNo ));
            memmove( cDeviceNo, info->cDeviceNo, sizeof( info->cDeviceNo ));

            // debug
            printf(
                   "upload no:%d info %c %-27.27s %c \n"
                 , intlop
                 , info->cCommTypeCd
                 , info->cDeviceType
                 , info->cIsFTPCollect
            );

            // 処理中止判定
            if( endProcessFlag == 1 )
            {
                break;
            }

            // 装置識別名取得
            cMachineName[12] = cMachineNameOrg[12] = 0;
            memmove( cMachineName, info->cDeviceType, sizeof( info->cDeviceType ) + sizeof( info->cDeviceFormat ) + sizeof( info->cDeviceNo ));
            memmove( cMachineNameOrg, cMachineName, sizeof( cMachineName ));
            // 末尾の空白除去
            trimEnd( cMachineName, ' ' );
            // 装置ファル名作成
            memmove( cMachineFileName, cMachineName, sizeof( cMachineName ));
            // 通信フォーマット箇所を'_'に変更
            cMachineFileName[3] = '_';

            // ファイル転送開始
            info->cStatus = 3;
            sprintf( 
                  clog
                , "ファイル転送対象装置,%s"
                , cMachineName
            );
            printf( "%s\n", clog );
            outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );

            // FTP
            if( info->cFTPCode == 0 )
            {
                // FTP転送実施

                // FTPデータ格納先フォルダ名作成
                sprintf(
                      cFolder
                    , "%s%s/FTP/"
                    , cWorkFolder
                    , cMachineName
                );
                // FTPデータ圧縮ファイル名作成
                sprintf(
                      cUploadFile
                    , "%s_%s_%s_FTP.zip"
                    , datacollectConf.cDataCollectSeqNo
                    , cMachineFileName
                    , datacollectConf.cStartDateTime
                );
                // FTPデータ圧縮ファイル名作成(フルパス作成)
                sprintf(
                      cFile
                    , "%s%s/%s"
                    , cWorkFolder
                    , cMachineName
                    , cUploadFile
                );

                //
                sprintf( 
                      clog
                    , "FTPデータ転送開始,装置,%s,%s"
                    , cMachineName
                    , cFile
                );
                printf( "%s\n", clog );
                outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );

                // FTP転送実施
                nseperatecount = 0;
                res = uploadNTSSFile(
                      cFile
                    , cUploadURI
                    , cUploadPath
                    , datacollectConf.nUploadFileMaxSize
                    , &nseperatecount
                    , cDeviceType
                    , cDeviceNo
                    , datacollectConf.nUploadRetryCount
                    , datacollectConf.nUploadRetryWaitTime
                );       
                if( res != 0 )
                {
                    // FTPデータ転送失敗

                    info->cFTPCode = 3 + res;

                    //
                    sprintf( 
                        clog
                        , "FTPデータ転送失敗,装置,%s,%s,(%d)"
                        , cMachineName
                        , cUploadFile
                        , info->cFTPCode
                    );
                    outputNTSSDataCollectMachineInfoErrorLog( clog, info );
                }
                //
                sprintf( 
                      clog
                    , "FTPデータ転送終了,装置,%s,%s,(%d)"
                    , cMachineName
                    , cUploadFile
                    , info->cFTPCode
                );
                printf( "%s\n", clog );
                outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );

                if( res == 0 )
                {
                    // ファイル転送成功

                    // 区切り文字追加
                    if( cAddFlag == 0x01 )
                    {
                        outputAppendFile(
                              cUploadListFile
                            , "\n"
                            , 1
                        );
                    }

                    // 装置情報追加
                    outputAppendFile(
                          cUploadListFile
                        , cMachineNameOrg
                        , sizeof( cMachineNameOrg ) - 1
                    );
                    // ファイル分割数
                    sprintf( clog, "%03d", nseperatecount);
                    outputAppendFile(
                          cUploadListFile
                        , clog
                        , strlen( clog )
                    );                  
                    // アップロードファイル名追加
                    outputAppendFile(
                          cUploadListFile
                        , cUploadFile
                        , strlen( cUploadFile )
                    );                 

                    // 以降追加とする
                    cAddFlag = 1;


                    // 
                    sprintf(
                        clog
                        , "ファイル転送に成功したので指定フォルダ内のファイルをすべて削除,%s"
                        , cFolder
                    );
                    outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );

                    // ファイル削除
                    deleteFolderInFiles( cFolder );
                }
            }
            else
            {
                // FTP転送対象外である場合

                //
                sprintf( 
                      clog
                    , "FTPデータ転送不要,装置,%s,(%d)"
                    , cMachineName
                    , info->cFTPCode
                );
                printf( "%s\n", clog );
                outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );
            }                         

            // FN
            if( info->cFNCode == 0 )
            {
                // FN転送実施

                // FNデータ格納先フォルダ名作成
                sprintf(
                      cFolder
                    , "%s%s/FN/"
                    , cWorkFolder
                    , cMachineName
                );
                // FNデータ圧縮ファイル名作成
                sprintf(
                      cUploadFile
                    , "%s_%s_%s_FN.zip"
                    , datacollectConf.cDataCollectSeqNo
                    , cMachineFileName
                    , datacollectConf.cStartDateTime
                );
                // FNデータ圧縮ファイル名作成(フルパス)
                sprintf(
                      cFile
                    , "%s%s/%s"
                    , cWorkFolder
                    , cMachineName
                    , cUploadFile
                );

                //
                sprintf( 
                      clog
                    , "FN通信データ転送開始,装置,%s,%s"
                    , cMachineName
                    , cFile
                );
                printf( "%s\n", clog );
                outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );

                // FN転送実施
                nseperatecount = 0;
                res = uploadNTSSFile(
                      cFile
                    , cUploadURI
                    , cUploadPath
                    , datacollectConf.nUploadFileMaxSize
                    , &nseperatecount
                    , cDeviceType
                    , cDeviceNo
                    , datacollectConf.nUploadRetryCount
                    , datacollectConf.nUploadRetryWaitTime
                );       
                if( res != 0 )
                {
                    // FNデータ転送失敗

                    info->cFNCode = 3 + res;

                    //
                    sprintf( 
                          clog
                        , "FNデータ転送失敗,装置,%s,%s,(%d)"
                        , cMachineName
                        , cUploadFile
                        , info->cFNCode
                    );
                    outputNTSSDataCollectMachineInfoErrorLog( clog, info );
                }
                //
                sprintf( 
                      clog
                    , "FN通信データ転送終了,装置,%s,%s,(%d)"
                    , cMachineName
                    , cUploadFile
                    , info->cFNCode
                );
                printf( "%s\n", clog );
                outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );

                if( res == 0 )
                {
                    // ファイル転送成功

                    // 区切り文字追加
                    if( cAddFlag == 0x01 )
                    {
                        outputAppendFile(
                              cUploadListFile
                            , "\n"
                            , 1
                        );
                    }

                    // 装置情報追加
                    outputAppendFile(
                          cUploadListFile
                        , cMachineNameOrg
                        , sizeof( cMachineNameOrg ) - 1
                    );
                    // ファイル分割数
                    sprintf( clog, "%03d", nseperatecount);
                    outputAppendFile(
                          cUploadListFile
                        , clog
                        , strlen( clog )
                    );                  
                    // アップロードファイル名追加
                    outputAppendFile(
                          cUploadListFile
                        , cUploadFile
                        , strlen( cUploadFile )
                    );                 

                    // 以降追加とする
                    cAddFlag = 1;


                    // 
                    sprintf(
                          clog
                        , "ファイル転送に成功したので指定フォルダ内のファイルをすべて削除,%s"
                        , cFolder
                    );
                    outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );

                    // ファイル削除
                    deleteFolderInFiles( cFolder );
                }
            }
            else
            {
                // FN転送対象外である場合

                //
                sprintf( 
                      clog
                    , "FN通信データ転送不要,装置,%s,(%d)"
                    , cMachineName
                    , info->cFNCode
                );
                printf( "%s\n", clog );
                outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );
            }             

            // ファイル転送終了
            info->cStatus = 4;
        }
    }
}