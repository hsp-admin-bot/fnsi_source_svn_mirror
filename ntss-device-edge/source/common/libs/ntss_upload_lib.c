/**
* @brief NTSSファイルアップロード処理ファイル
*
* @details NTSSファイルアップロードの汎用処理
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_upload_lib.c
* @author H.Yonezawa
* @date 2018/07/18
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>
#include <linux/types.h>
#include <arpa/inet.h>
#include <errno.h>
#include <sys/stat.h>

#include "ntss_upload_lib.h"

#include "ntss_etc_lib.h"
#include "ntss_log_lib.h"


/**
 * @brief ファイルの１行目だけを取得する
 * 
 * @param buff 格納バッファ
 * @param max_size 最大サイズ
 * @param filePath ファイルパス
 * @return uint16_t 0:取得成功, -1:ファイルオープン失敗, -2:ファイル内容なし
 */
uint16_t
readFile1Line(u_char *buff, uint16_t max_size, const u_char *filePath){
    FILE *fin;
    u_char msg[512] = {0};

    if ((fin = fopen(filePath, "r")) == NULL) {
        sprintf(msg, "ファイルを開けません:[%s]", filePath);
        LogOutput( NTSS_LOG_ERROR, msg);
        return -1; 
    }

    if (fgets(buff, max_size - 1, fin) == NULL) {
        /* EOF */
        fclose(fin);
        return -2; 
    }
    // close
    fclose(fin);

    // 余計な改行コード削除
    if(buff[strlen(buff) - 1] == '\n'){
        buff[strlen(buff) - 1] = '\0';
    }

    return 0;
}


/**
* @brief 指定フォルダから圧縮ファイルを作成する
*
* @details 指定フォルダから圧縮ファイルを作成する
*
* @description
* @param[in] *cDataFolder       圧縮データ格納先フォルダ
* @param[in] *ZipFileName       圧縮ファイル名
* @param[in] *cPW               パスワード
* @param[in] *cMachineType      型式コード(不要な場合はから文字を指定)
* @param[in] *cMachineSerial    製造番号(不要な場合はから文字を指定)
* @return 0：作成成功/else：作成失敗
* @attention 特になし
*/
int
zipNTSSFiles( u_char *cDataFolder
            , u_char *cZipFileName
            , u_char *cPW
            , u_char *cWorkFolder
            , u_char *cMachineType
            , u_char *cMachineSerial
            )
{
    int ret = 0;
    u_char clog[1024];
    u_char cbuff[ NTSS_STR_MAX_SIZE ];
    u_char cfile[ NTSS_STR_MAX_SIZE ];
    FILE *fp;

    //
    sprintf(
        cbuff
        , "zip -P \"%s\" -r -j \"%s\" \"%s\""
        , cPW
        , cZipFileName
        , cDataFolder
    );

    // ファイル圧縮実行
    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    ret = system( cbuff );
    if( WIFEXITED( ret ))
    {
        // 子プロセスが正常に終了した場合

        // 子プロセスの終了ステータスを取得
        ret = WEXITSTATUS( ret );
    }

    // ファイル圧縮に成功している場合
    if( ret == 0 )
    {
        // 圧縮対象一覧ファイル名作成
        sprintf(
              cfile
            , "%sZIP_FILES.TXT"
            , cWorkFolder
        );

        // ファイルの一覧を取得
        if( getFolderList( 
              cDataFolder
            , cfile
            , NTSS_GETFOLDERLIST_MODE_FILE_ONLY
        ) == 1 )
        {
            // リストファイルの存在確認
            if( existFolderFile( cfile, NULL ) == 1 )
            {
                // 対象ファイルあり

                // リストファイルを開く
                if (( fp = fopen( cfile, "r" )) != NULL )
                {
                    // 1行取得
                    while( fgets( cbuff, sizeof( cbuff ), fp) != NULL)
                    {
                        // 末尾のLFを除去
                        trimEnd( cbuff, '\n' );

                        // 
                        sprintf(
                              clog
                            , "zip圧縮対象ファイル,%s%s → %s"
                            , cDataFolder
                            , cbuff
                            , cZipFileName
                        );
                        LogSend( NTSS_LOG_INFO, clog, 0, cMachineType, cMachineSerial );
                    }

                    fclose(fp);
                }

                // リストファイルを削除する
                remove( cfile );
            }
        }
    }

    return ret;
}

/**
* @brief 指定ファイルから圧縮ファイルを作成する
*
* @details 指定ファイルから圧縮ファイルを作成する
*
* @description
* @param[in] *cFileName     圧縮元ファイル名
* @param[in] *ZipFileName   圧縮ファイル名
* @param[in] *cPW           パスワード
* @return 0：作成成功/else：作成失敗
* @attention 特になし
*/
int
zipNTSSFile( u_char *cFileName
           , u_char *cZipFileName
           , u_char *cPW
           )
{
    int ret = 0;
    u_char cbuff[ NTSS_STR_MAX_SIZE ];
    FILE *fp;

    //
    sprintf(
        cbuff
        , "zip -P \"%s\" -r \"%s\" \"%s\""
        , cPW
        , cZipFileName
        , cFileName
    );

    // ファイル圧縮実行
    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    ret = system( cbuff );
    if( WIFEXITED( ret ))
    {
        // 子プロセスが正常に終了した場合

        // 子プロセスの終了ステータスを取得
        ret = WEXITSTATUS( ret );
    }

    return ret;
}

/**
* @brief 指定ファイルを指定URLへアップロードする
*
* @details 指定ファイルを指定URLへアップロードする
*
* @description
* @param[in]  *cUploadFileName      アップロードするファイル名(フルパス)
* @param[in]  *cUploadPath          アップロード先パス名
* @param[in]  nUploadURI            アップロードURI(ホスト名 + API)
* @param[in]  nUploadFileMaxSize    アップロードファイル最大サイズ
* @param[out] *nSeparateCount       ファイル分割数
* @param[in] *cMachineType          型式コード(不要な場合はから文字を指定)
* @param[in] *cMachineSerial        製造番号(不要な場合はから文字を指定)
* @param[in] nRetryCount            リトライ回数
* @param[in] nRetryWaitTime         リトライ待ち時間[秒]
* @return 0：転送成功/1：URL接続失敗/2：転送失敗
* @attention 特になし
*/
int
uploadNTSSFile( u_char *cUploadFileName
              , u_char *cUploadURI
              , u_char *cUploadPath
              , uint16_t nUploadFileMaxSize
              , int *nSeparateCount
              , u_char *cMachineType
              , u_char *cMachineSerial
              , int nRetryCount
              , int nRetryWaitTime
              )
{
    int ret = 2;
    struct stat st;
    u_char clog[1024];
    u_char cbuff[ NTSS_STR_MAX_SIZE * 2 ];
    u_char cbuff2[ NTSS_STR_MAX_SIZE ];
    u_char cfolder[ NTSS_STR_MAX_SIZE ];
    u_char cfile[ NTSS_STR_MAX_SIZE ];
    u_char clist[ NTSS_STR_MAX_SIZE ];
    u_char cresfile[ NTSS_STR_MAX_SIZE ];
    u_char cerrfile[ NTSS_STR_MAX_SIZE ];
    FILE *fp;

    *nSeparateCount = 0;

    // 指定ファイルのファイルサイズ確認
    if( existFolderFile( cUploadFileName, &st ) == 1 )
    {
        ret = 0;

        // 取得したファイルサイズと最大ファイルサイズを比較
        if( ( nUploadFileMaxSize * 1024 * 1024 ) < st.st_size )
        {
            // 最大ファイルサイズを超えている場合
            int nOrgSize = st.st_size / 1024 / 1024;

            //
            sprintf(
                  clog
                , "指定ファイルの分割処理開始,%s,[%dMB → %dMB]"
                , cUploadFileName
                , nOrgSize
                , nUploadFileMaxSize
            );
            LogSend( NTSS_LOG_INFO, clog, 0, cMachineType, cMachineSerial );

            // ファイルを分割する
            sprintf(
                  cbuff
                //, "split -b %dm -a 3 -d \"%s\" \"%s.\" --numeric-suffixes=1" // 枝番:001から
                , "split -b %dm -a 3 -d \"%s\" \"%s.\""
                , nUploadFileMaxSize
                , cUploadFileName
                , cUploadFileName
            );

            // ファイル分割実行
            // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
            ret = system( cbuff );
            if( WIFEXITED( ret ))
            {
                // 子プロセスが正常に終了した場合

                // 子プロセスの終了ステータスを取得
                ret = WEXITSTATUS( ret );
            }

            //
            sprintf(
                  clog
                , "指定ファイルの分割処理終了,%s,[%dMB → %dMB],(%d)"
                , cUploadFileName
                , nOrgSize
                , nUploadFileMaxSize
                , ret
            );
            LogSend( NTSS_LOG_INFO, clog, 0, cMachineType, cMachineSerial );
            //
            if( ret == 0 )
            {
                // 分割前のファイルを削除する
                remove( cUploadFileName );

                // 指定ファイルの格納先フォルダ名、ファイル名のみを取得する
                memset( cfolder, 0, sizeof( cfolder ));
                memset( cfile, 0, sizeof( cfile ));
                strcpy( cfolder, cUploadFileName );
                u_char *p = strrchr( cfolder, '/' );
                if( *p != 0 )
                {
                    strcat( cfile, p + 1 );
                    *(p + 1) = 0;
                }
                else
                {
                    cfolder[0] = 0; 
                    strcat( cfolder, "./" );
                    strcpy( cfile, cUploadFileName );
                }
                //
                printf( "upload %s-%s\n", cfolder, cfile );

                // 分割ファイルのリストファイル名を作成
                strcat( cUploadFileName, ".list" );
                // リストファイル名作成
                sprintf(
                      clist
                    , "%s%s.TXT"
                    , cfolder
                    , cfile
                );

                // ファイルの一覧を取得
                ret = getFolderList( 
                      cfolder
                    , clist
                    , NTSS_GETFOLDERLIST_MODE_FILE_ONLY
                );
                if( ret == 1 )
                {
                    // リストファイルの存在確認
                    ret = existFolderFile(
                          clist
                        , NULL 
                    );
                    if( ret  == 1 )
                    {
                        // 
                        sprintf(
                              clog
                            , "ファイル分割ファイル取得,パターン抽出,%s%s.*"
                            , cfolder
                            , cfile
                        );
                        LogSend( NTSS_LOG_INFO, clog, 0, cMachineType, cMachineSerial );
                        
                        // リストファイルから対象装置のファイルを抽出する
                        sprintf(
                              cbuff
                            , "cat \"%s\" | grep -G \"%s.*\" > \"%s\""
                            , clist
                            , cfile
                            , cUploadFileName
                        );
                        // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
                        ret = system( cbuff );
                        if( WIFEXITED( ret ))
                        {
                            // 子プロセスが正常に終了した場合

                            // 子プロセスの終了ステータスを取得
                            ret = WEXITSTATUS( ret );
                        }

                        // リストファイル削除
                        remove( clist );

                        // 対象装置のファイル一覧分のファイル転送を行う
                        // リストファイルの存在確認
                        if( existFolderFile( cUploadFileName, NULL ) == 1 )
                        {
                            // 対象ファイルあり

                            // リストファイルを開く
                            if (( fp = fopen( cUploadFileName, "r" )) != NULL )
                            {
                                // リストファイルの分を1件減算
                                *nSeparateCount = -1;

                                // 1行取得
                                while( fgets( cbuff, sizeof( cbuff ), fp) != NULL)
                                {
                                    // 末尾のLFを除去
                                    trimEnd( cbuff, '\n' );

                                    // 
                                    sprintf(
                                          clog
                                        , "%s%s"
                                        , cfolder
                                        , cbuff
                                    );
                                    //  ファイル転送
                                    int ncount = 0;
                                    ret = uploadNTSSFile(
                                          clog
                                        , cUploadURI
                                        , cUploadPath
                                        , nUploadFileMaxSize
                                        , &ncount
                                        , cMachineType
                                        , cMachineSerial
                                        , nRetryCount
                                        , nRetryWaitTime
                                    );       

                                    if( ret != 0 )
                                    {
                                        break;
                                    }
                                    *nSeparateCount += ncount;
                                }                                

                                fclose(fp);
                            }
                        }                           
                    }
                    else
                    {
                        // リストファイルの作成失敗

                        //
                        sprintf(
                              clog
                            , "分割リストファイルの作成に失敗しました,%s,(%d)"
                            , cfolder
                            , ret
                        );
                        viewErrorLogSend( clog, cMachineType, cMachineSerial );


                        return 2;
                    }
                }
                else
                {
                    // ファイル一覧取得失敗

                    //
                    sprintf(
                        clog
                        , "分割ファイル一覧の取得に失敗しました,%s,(%d)"
                        , cfolder
                        , ret
                    );
                    viewErrorLogSend( clog, cMachineType, cMachineSerial );

                    ret = 2;
                }          
            }
            else
            {
                // ファイル分割失敗

                //
                sprintf(
                      clog
                    , "指定ファイルの分割処理に失敗しました,%s, %dMB,(%d)"
                    , cUploadFileName
                    , nUploadFileMaxSize
                    , ret
                );
                viewErrorLogSend( clog, cMachineType, cMachineSerial );

                ret =  2;
            }
        }
    }

    //
    if( ret == 0 )
    {

        // 指定ファイルのファイル名のみを取得する
        memset( cfolder, 0, sizeof( cfolder ));
        memset( cfile, 0, sizeof( cfile ));
        strcpy( cfolder, cUploadFileName );
        u_char *p = strrchr( cfolder, '/' );
        if( *p != 0 )
        {
            strcat( cfile, p + 1 );
            *(p + 1) = 0;
        }
        else
        {
            cfolder[0] = 0; 
            strcat( cfolder, "./" );
            strcpy( cfile, cUploadFileName );
        }
        // 応答ファイル名作成
        cresfile[0] = 0;
        sprintf(
            cresfile
            , "%s%s_UPLOAD_RES.TXT"
            , cfolder
            , cfile
        );

        // エラーファイル名作成
        cerrfile[0] = 0;
        sprintf(
            cerrfile
            , "%s%s_UPLOAD_ERR.TXT"
            , cfolder
            , cfile
        );

        // リトライ機能付きアプロード処理    
        int intretry;
        for( intretry = 0; intretry < nRetryCount; intretry++ )
        {
            // 2回目以降実施前の時間稼ぎ
            if( 0 < intretry )
            {
                // 時間稼ぎ
                sleep( nRetryWaitTime );                             
            }

            // 
            sprintf(
                clog
                , "%d回目 ファイル転送開始,%s"
                , intretry + 1
                , cUploadFileName
            );

            LogSend( NTSS_LOG_INFO, clog, 0, cMachineType, cMachineSerial );

            // ファイルを転送する[AWS：EC2経由]
            sprintf(
                    cbuff
                , "./sh/ntss_upload.sh \"%s\" \"%s\" \"%s\" \"%s\" \"%s\""
                , cUploadURI
                , cUploadPath
                , cUploadFileName
                , cresfile
                , cerrfile
            );

            // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
            ret = system( cbuff );
            if( WIFEXITED( ret ))
            {
                // 子プロセスが正常に終了した場合

                // 子プロセスの終了ステータスを取得
                ret = WEXITSTATUS( ret );
            }

            //// debug
    /*
            sprintf(
                clog
                , "ファイル転送コマンド,%s, (%d)"
                , cbuff
                , ret
            );
            LogOutput( NTSS_LOG_DEBUG, clog );
    */
            // 終了コードファイルの存在確認
            // ※終了コードが0〜255の数値のみなのでファイルに出力して取得する
            if( existFolderFile( cresfile, NULL ) == 1 )
            {
                // 終了コード取得
                if( readFile1Line( cbuff2, sizeof( cbuff2 ), cresfile ) == 0 )
                {
                    // 
                    ret = atoi( cbuff2 );
                }
            }

            // 
            sprintf(
                    clog
                , "%d回目 ファイル転送終了,%s,(%d)"
                , intretry + 1
                , cUploadFileName
                , ret
            );
            LogSend( NTSS_LOG_INFO, clog, 0, cMachineType, cMachineSerial );

            // 終了コード作成
            if( 0 < ret )
            {
                // 成功系
                if( 200 <= ret && ret <= 299 )
                {
                    ret = 0;
                    (*nSeparateCount)++;
                }
                else 
                {

                    // 接続系エラー
                    if (( 400 <= ret && ret <= 406 )
                    || ( 502 <= ret && ret <= 504 ))
                    {
                        ret = 1;
                    }
                    else
                    {
                        // 転送失敗エラー
                        ret = 2;
                    }
                }
            }
            else
            {
                // 転送失敗エラー
                ret = 2;
            }
        
            if( ret != 0 )
            {
                // 失敗

                //
                viewErrorLogSend2( "ファイル転送失敗", cMachineType, cMachineSerial );

                // 
                sprintf(
                    clog
                    , "ファイル転送コマンド,%s"
                    , cbuff
                );
                viewErrorLogSend( clog, cMachineType, cMachineSerial );

                // 終了コードファイルの存在確認
                // ※終了コードが0〜255の数値のみなのでファイルに出力して取得する
                if( existFolderFile( cerrfile, NULL ) == 1 )
                {
                    // 終了コード取得
                    if( readFile1Line( cbuff2, sizeof( cbuff2 ), cerrfile ) == 0 )
                    {
                        // 
                        sprintf(
                            clog
                            , "ファイル転送コマンド結果,%s"
                            , cbuff2
                        );
                        viewErrorLogSend( clog, cMachineType, cMachineSerial );
                    }
                }
            }

            // 処理ログファイル削除
            remove( cresfile );
            remove( cerrfile );        

            // 正常終了判定
            if( ret == 0 )
            {
                break;
            }
        }
    }

    // 転送ファイル削除
    remove( cUploadFileName );

    return ret;
}

/**
* @brief アップロードしたファイルの結合指示
*
* @details アップロードしたファイルの結合指示を行う
*
* @description
* @param[in] *nSeparateCount    ファイル分割数
* @param[in] *cUploadFileName   アップロードしたファイル名(フルパス)
* @param[in] nUploadURI         アップロードURI(ホスト名 + API)
* @param[in] *cUploadPath       アップロード先パス名
* @param[in] *cMachineType      型式コード(不要な場合はから文字を指定)
* @param[in] *cMachineSerial    製造番号(不要な場合はから文字を指定)
* @return 0：指示成功/else：指示失敗
* @attention 特になし
*/
int
uploadNTSSFileJoin( int nSeparateCount
                  , u_char *cUploadFileName
                  , u_char *cUploadURI
                  , u_char *cUploadPath
                  , u_char *cMachineType
                  , u_char *cMachineSerial
                  )
{
    int ret = 1;
    u_char clog[1024];
    u_char cbuff[ NTSS_STR_MAX_SIZE * 2 ];
    u_char cbuff2[ NTSS_STR_MAX_SIZE ];
    u_char cfolder[ NTSS_STR_MAX_SIZE ];
    u_char cfile[ NTSS_STR_MAX_SIZE ];
    u_char cfile2[ NTSS_STR_MAX_SIZE ];
    u_char cresfile[ NTSS_STR_MAX_SIZE ];
    u_char cerrfile[ NTSS_STR_MAX_SIZE ];
    FILE *fp;

    // 指定ファイルのファイル名のみを取得する
    memset( cfolder, 0, sizeof( cfolder ));
    memset( cfile, 0, sizeof( cfile ));
    strcpy( cfolder, cUploadFileName );
    u_char *p = strrchr( cfolder, '/' );
    if( *p != 0 )
    {
        strcat( cfile, p + 1 );
        *(p + 1) = 0;
    }
    else
    {
        cfolder[0] = 0; 
        strcat( cfolder, "./" );
        strcpy( cfile, cUploadFileName );
    }
    // 分割数付きファイル名作成
    sprintf(
         cfile2
        , "%03d%s"
        , nSeparateCount
        , cfile
    );
    // 応答ファイル名作成
    cresfile[0] = 0;
    sprintf(
            cresfile
        , "%s%s_UPLOAD_JOIN_RES.TXT"
        , cfolder
        , cfile
    );

    // エラーファイル名作成
    cerrfile[0] = 0;
    sprintf(
            cerrfile
        , "%s%s_UPLOAD_JOIN_ERR.TXT"
        , cfolder
        , cfile
    );
    
    // 
    sprintf(
          clog
        , "ファイル結合指示開始,%s"
        , cfile2
    );
    LogSend( NTSS_LOG_INFO, clog, 0, cMachineType, cMachineSerial );

    // ファイルを転送する[AWS：EC2経由]
    sprintf(
            cbuff
        , "./sh/ntss_upload_join.sh \"%s\" \"%s\" \"%s\" \"%s\" \"%s\""
        , cUploadURI
        , cUploadPath
        , cfile2
        , cresfile
        , cerrfile
    );

    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    ret = system( cbuff );
    if( WIFEXITED( ret ))
    {
        // 子プロセスが正常に終了した場合

        // 子プロセスの終了ステータスを取得
        ret = WEXITSTATUS( ret );
    }

    //// debug
/*
    sprintf(
            clog
        , "ファイル転送コマンド,%s, (%d)"
        , cbuff
        , ret
    );
    LogOutput( NTSS_LOG_DEBUG, clog );
*/
    // 終了コードファイルの存在確認
    // ※終了コードが0〜255の数値のみなのでファイルに出力して取得する
    if( existFolderFile( cresfile, NULL ) == 1 )
    {
        // 終了コード取得
        if( readFile1Line( cbuff2, sizeof( cbuff2 ), cresfile ) == 0 )
        {
            // 
            ret = atoi( cbuff2 );
        }
    }

    // 
    sprintf(
          clog
        , "ファイル結合指示終了,%s,(%d)"
        , cfile2
        , ret
    );
    LogSend( NTSS_LOG_INFO, clog, 0, cMachineType, cMachineSerial );

    // 終了コード作成
    if( 0 < ret )
    {
        // 成功系
        if( 200 <= ret && ret <= 299 )
        {
            ret = 0;
        }
        else 
        {

            // 接続系エラー
            if (( 400 <= ret && ret <= 406 )
                || ( 502 <= ret && ret <= 504 ))
            {
                ret = 1;
            }
            else
            {
                // 指示失敗エラー
                ret = 1;
            }
        }
    }
    else
    {
        // 指示失敗エラー
        ret = 2;
    }
    
    if( ret != 0 )
    {
        // 失敗

        // 
        sprintf(
              clog
            , "ファイル結合コマンド,%s"
            , cbuff
        );
        viewErrorLogSend( clog, cMachineType, cMachineSerial );

        // 終了コードファイルの存在確認
        // ※終了コードが0〜255の数値のみなのでファイルに出力して取得する
        if( existFolderFile( cerrfile, NULL ) == 1 )
        {
            // 終了コード取得
            if( readFile1Line( cbuff2, sizeof( cbuff2 ), cerrfile ) == 0 )
            {
                // 
                sprintf(
                      clog
                    , "ファイル結合コマンド結果,%s"
                    , cbuff2
                );
                viewErrorLogSend( clog, cMachineType, cMachineSerial );
            }
        }
    }
    
    // 処理ログファイル削除
    remove( cresfile );
    remove( cerrfile );

    return ret;
}
