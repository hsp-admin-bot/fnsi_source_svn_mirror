/**
* @brief NTSSログファイルのアップロード処理ファイル
*
* @details NTSSログファイルをアップロードする
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_log_upload.c
* @author H.Yonezawa
* @date 2018/07/20
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

#include "ntss_log_upload.h"

#include "../common/libs/ntss_etc_lib.h"
#include "../common/libs/ntss_upload_lib.h"
#include "../common/libs/ntss_log_lib.h"


/**
* @brief NTSSログアップロード作業用フォルダを作成
*
* @details NTSSログアップロード作業用フォルダを作成する
*
* @description
* @param[in] *cWorkFolder 作業用フォルダ名
* @return １：作成成功/else：作成失敗
* @attention 特になし
*/
int
makeNTSSLogUploadWorkFolder( u_char *cWorkFolder
                            )
{
    int ret = 0;
    u_char cwork[ NTSS_STR_MAX_SIZE ];
    u_char cwork2[ NTSS_STR_MAX_SIZE ];

    // 作業用フォルダ存在確認
    if( existFolderFile( cWorkFolder, NULL ) == 0 )
    {
        // なし

        // 対象フォルダ作成
        if( createFolder( cWorkFolder ) != 1 )
        {
            // 作成失敗
            return ret;
        }
    }

    // アップロード用フォルダの存在確認
    sprintf(
          cwork
        , "%s/WORK"
        , cWorkFolder
     );
    if( existFolderFile( cwork, NULL ) == 0 )
    {
        // なし

        // 対象フォルダ作成
        if( createFolder( cwork ) != 1 )
        {
            // 作成失敗
            return ret;
        }
    }

    // 作業用フォルダの末尾に'/'追加
    addFolderSeparator( cwork );

    // 圧縮用フォルダの存在確認
    sprintf(
          cwork2
        , "%sZIP"
        , cwork
    );
    if( existFolderFile( cwork2, NULL ) == 0 )
    {
        // なし

        // 対象フォルダ作成
        if( createFolder( cwork2 ) != 1 )
        {
            // 作成失敗
            return ret;
        }
    }

    // アップロード用フォルダの存在確認
    sprintf(
          cwork2
        , "%sUP"
        , cwork
     );
    if( existFolderFile( cwork2, NULL ) == 0 )
    {
        // なし

        // 対象フォルダ作成
        if( createFolder( cwork2 ) != 1 )
        {
            // 作成失敗
            return ret;
        }
    }

    ret = 1;

    return ret;
}

/**
* @brief 移動元フォルダから移動先フォルダに移動元フォルダ内の全ファイルを移動
*
* @details 移動元フォルダから移動先フォルダに移動元フォルダ内の全ファイルを移動する
*
* @description
* @param[in] *cSourceFolder 移動元フォルダ名
* @param[in] *cDestFolder   移動先フォルダ名
* @param[in] nTodayCopy     当日コピーフラグ(ファイル名に当日が含まれている場合にど鵜するかを指定する 0:移動/1:コピー)
* @return 1：移動成功/else：移動失敗(リストファイルなし、移動元フォルダなし、移動先フォルダなし含む)
* @attention 移動先に同名ファイルがあった場合は日付の後ろに2桁の枝番をつける
*/
int
moveNTSSLogFiles( u_char *cSourceFolder
                , u_char *cDestFolder
                , int nTodayCopy 
                )
{
    int ret = 0;
    u_char clog[1024];
    u_char cbuf[ NTSS_STR_MAX_SIZE ];
    u_char clist[ NTSS_STR_MAX_SIZE ];
    u_char cfile1[ NTSS_STR_MAX_SIZE ];
    u_char cfile2[ NTSS_STR_MAX_SIZE ];
    u_char cext[5];
    u_char cNow[9];
    struct stat st1;
    struct stat st2;
    time_t tim;
    struct tm tmc;
    FILE *fp;

    // 現在時刻取得
    time( &tim );
    localtime_r( &tim, &tmc );

    // 当日文字列作成
    sprintf(
        cNow
        , "%04d%02d%02d"
        , tmc.tm_year + 1900
        , tmc.tm_mon + 1
        , tmc.tm_mday
    );

    // 移動元フォルダの存在確認
    if( existFolderFile( cSourceFolder, NULL ) == 1 ) 
    {
        // 移動元フォルダあり

        // 移動先フォルダの存在確認
        if( existFolderFile( cDestFolder, NULL ) == 1 )
        {
            // 移動先フォルダあり

            // ファイル一覧作成
            sprintf( 
                  clist
                , "%s/LOG_LIST.TXT"
                , cDestFolder
            );
            if( getFolderList(
                  cSourceFolder
                , clist
                , NTSS_GETFOLDERLIST_MODE_FILE_ONLY
            ) == 1 )
            {
                ret = 1;

                // リストファイルを開く
                if (( fp = fopen( clist, "r" )) != NULL )
                {
                    // 1行取得
                    while( fgets( cbuf, sizeof( cbuf ), fp) != NULL)
                    {
                        // 末尾のLFを除去
                        trimEnd( cbuf, '\n' );

                        // 移動元ファイル名作成
                        sprintf(
                              cfile1
                            , "%s/%s"
                            , cSourceFolder
                            , cbuf
                        );

                        int intlop;
                        for( intlop = 0; intlop < 100; intlop++ ){

                            // 移動先ファイル名作成
                            sprintf(
                                  cfile2
                                , "%s/%s"
                                , cDestFolder
                                , cbuf
                            );

                            //printf( "FileName: %s -> %s\n", cfile1, cfile2);

                            //
                            if( 0 < intlop ) {
                                // 名前を変更
                                memset( cext, 0, sizeof( cext ));
                                strcat( cext, cfile2 + strlen(cfile2) - 4 );
                                sprintf(
                                    cfile2 + strlen(cfile2) - 4
                                    , "_%02d%s"
                                    , intlop
                                    , cext
                                );
                                //printf( "change FileName: %s -> %s\n", cfile1, cfile2);
                            }

                            
                            // 移動先ファイルの存在確認
                            if( existFolderFile( cfile2, &st2 ) == 0 )
                            {
                                // 該当ファイルなし
                                break;
                            } 
                        }
                        
                        // 移動/コピー処理判定
                        // ※ファイル名が本日の場合はコピーとする
                        if( nTodayCopy == 1 && strstr( cfile2, cNow ) != NULL )
                        {
                            //printf( "FileCopy: %s -> %s\n", cfile1, cfile2);

                            // ファイルコピーする
                            if( copyFile(
                                  cfile1
                                , cfile2
                                , NTSS_COPYFILE_MODE_OVERWRITE
                            ) == 1 )
                            {
                                // 移動成功
                                sprintf(
                                      clog
                                    , "ファイルコピー,%s→%s"
                                    , cfile1
                                    , cfile2
                                );
                                LogOutput( NTSS_LOG_INFO, clog );
                            } 
                            else
                            {
                                // 移動失敗
                                sprintf(
                                      clog
                                    , "ファイルコピー失敗(%d:%s),%s→%s"
                                    , errno
                                    , strerror(errno)
                                    , cfile1
                                    , cfile2
                                );
                                viewError( clog );

                                ret = 0;
                            }
                        } else {

                            //printf( "FileMove: %s -> %s\n", cfile1, cfile2);

                            // ファイルを移動する
                            if( moveFile( 
                                  cfile1
                                , cfile2
                                , NTSS_MOVEFILE_MODE_OVERWRITE
                            ) == 1 )
                            {
                                // 移動成功
                                sprintf(
                                      clog
                                    , "ファイル移動,%s→%s"
                                    , cfile1
                                    , cfile2
                                );
                                LogOutput( NTSS_LOG_INFO, clog );
                            } 
                            else
                            {
                                // 移動失敗
                                sprintf(
                                      clog
                                    , "ファイル移動失敗(%d:%s),%s→%s"
                                    , errno
                                    , strerror(errno)
                                    , cfile1
                                    , cfile2
                                );
                                viewError( clog );

                                ret = 0;
                            }
                        }
                    }

                    fclose(fp);

                    // リストファイルを削除する
                    remove( clist );
                } 
            }
        }
    }
    
    return ret;
}

// add FNSI-バグ 通信サーバ #9696 高 start
/**
* @fn void split_filename()
* @brief split file name and ext
* @param[in] p_fullFileName
* @param[out] p_fileName
* @param[out] p_ext
* @return
*/
void split_filename(char * p_fullFileName, char * p_fileName, char * p_ext)
{
    char * bp;
    char name[512];
    
    if(p_fullFileName[0] == '\0')
        return;
    
    strcpy(name, p_fullFileName);
    bp = strrchr(name, '.');
    if(bp == NULL)
        return;
    
    strcpy(p_ext, bp);
    name[strlen(name) - strlen(bp)] = '\0';
    strcpy(p_fileName, name);
}

/**
 * @fn void get_log_name()
 * @brief get log file name 
 * @param[in]  p_fileName file name
 * @param[out] p_logName log file name
 * @return 
 */
void get_log_name(char * p_fileName, char * p_logName)
{
    char seps[] = "_";
    char *token;
    int cnt = 1;
    
    token = strtok( p_fileName, seps );
    while(token != NULL) {
        if(cnt < 5) {
            strcat(p_logName, token);
            strcat(p_logName, seps);
        }
        else if(cnt == 5) {
            strcat(p_logName, token);
            break;
        }
        token = strtok( NULL, seps );
        cnt++;
    }
}
// add FNSI-バグ 通信サーバ #9696 高 end

/**
* @brief 作業用フォルダ内のログファイルを日付別に圧縮する
*
* @details 作業用フォルダ内のログファイルを日付別に圧縮する
*
* @description
* @param[in] *cWorkFolder   作業用フォルダ名
* @param[in] *cPW           圧縮パスワード
* @return 1：処理成功/else：処理失敗
* @attention 圧縮に成功した場合は圧縮元のファイルを削除する
*/
int
zipNTSSLogFiles( u_char *cWorkFolder
               , u_char *cPW
               )
{
    int ret = 1;
    u_char clog[ NTSS_STR_MAX_SIZE ];
    u_char cZipFolder[ NTSS_STR_MAX_SIZE ];
    u_char clist[ NTSS_STR_MAX_SIZE];
    u_char cbuf[ NTSS_STR_MAX_SIZE ];
    u_char cfile[ NTSS_STR_MAX_SIZE ];
    u_char czipfile[ NTSS_STR_MAX_SIZE ];
    FILE *fp;
    // add FNSI-バグ 通信サーバ #9696 高 start
    char log_name[NTSS_STR_MAX_SIZE];
    char name[NTSS_STR_MAX_SIZE];
    char ext[NTSS_STR_MAX_SIZE];
    // add FNSI-バグ 通信サーバ #9696 高 end

    // ZIP
    // ZIP格納先フォルダ名作成
    sprintf(
          cZipFolder
        , "%s/ZIP/"
        , cWorkFolder
    );
    // ZIP格納先フォルダ存在確認
    if( existFolderFile( cZipFolder , NULL ) == 1 )
    {
        // 対象フォルダあり
        
        // 圧縮対象リストファイル名作成
        sprintf(
              clist
            , "%s/LOG_LIST.TXT"
            , cWorkFolder
        );
        
        // ファイルの一覧を取得
        if( getFolderList( 
              cWorkFolder
            , clist
            , NTSS_GETFOLDERLIST_MODE_FILE_ONLY
        ) == 1 )
        {
            // リストファイルの存在確認
            if( existFolderFile( clist, NULL ) == 1 )
            {
                //
                // リストファイルを開く
                if (( fp = fopen( clist, "r" )) != NULL )
                {
                    // 1行取得
                    while( fgets( cbuf, sizeof( cbuf ), fp) != NULL)
                    {
                        // 末尾のLFを除去
                        trimEnd( cbuf, '\n' );

                        // 圧縮元ファイル名作成
                        // DE_{施設コード[6]}_{デバイスエッジ番号[2]}_{製造番号[11]}_{日付[8]}(_{枝番[2]}).LOG
                        sprintf(
                              cfile
                            , "%s/%s"
                            , cWorkFolder
                            , cbuf
                        );

                        // 圧縮ファイル名作成
                        // mod FNSI-バグ 通信サーバ #9696 高 start
                        // DE_{施設コード[6]}_{デバイスエッジ番号[2]}_{製造番号[11]}_{日付[8]}.ZIP
                        /* cbuf[33] = 0;
                        strcat( cbuf, ".ZIP" );
                        sprintf(
                              czipfile
                            , "%s%s"
                            , cZipFolder
                            , cbuf
                        );*/
                        memset(log_name, '\0', sizeof(log_name));
                        memset(name, '\0', sizeof(name));
                        memset(ext, '\0', sizeof(ext));
                        strcpy(log_name, cbuf);
                        split_filename(log_name, name, ext);
                        memset(log_name, '\0', sizeof(log_name));
                        get_log_name(name, log_name);
                        // mod #10756 9696未対応部分 高 start
                        // strcat( log_name, ".ZIP" );
                        strcat( log_name, ".zip" );
                        // mod #10756 9696未対応部分 高 end
                        sprintf(
                              czipfile
                            , "%s%s"
                            , cZipFolder
                            , log_name
                        );
                        // mod FNSI-バグ 通信サーバ #9696 高 end

                        // ファイルを圧縮する
                        if( zipNTSSFile(
                              cfile
                            , czipfile
                            , cPW
                        ) == 0 )
                        {
                            // 圧縮成功
                            sprintf(
                                  clog
                                , "ファイル圧縮,%s→%s"
                                , cfile
                                , czipfile
                            );
                            LogOutput( NTSS_LOG_INFO, clog );

                            // 
                            sprintf(
                                  clog
                                , "ファイル圧縮に成功したので対象のログファイルを削除,%s"
                                , cfile
                            );
                            LogOutput( NTSS_LOG_INFO, clog );

                            // ファイル削除
                            remove( cfile );
                        } 
                        else
                        {
                            // 圧縮失敗
                            sprintf(
                                    clog
                                , "ファイル圧縮失敗(%d:%s),%s→%s"
                                , errno
                                , strerror(errno)
                                , cfile
                                , czipfile
                            );
                            viewError( clog );

                            ret = 0;
                        }
                    }

                    fclose(fp);
                }
            }
        }
        else
        {
            // 一覧取得失敗

            sprintf(
                  clog
                , "作業用フォルダ内のログファイル一覧取得失敗:%s"
                , cWorkFolder
            );
            viewError( clog );

            ret = 0;
        }

        // リストファイルを削除する
        remove( clist );
    }

    return ret;
}

/**
* @brief 作業用フォルダ内のZIPファイルをアップロード
*
* @details 作業用フォルダ内のZIPファイルをアップロードする
*
* @description
* @param[in] *cWorkFolder           作業用フォルダ名
* @param[in]  nUploadHost           アップロードホスト名
* @param[in]  nUploadAPI            アップロードAPI
* @param[in]  nUploadJoinAPI        アップロードファイル結合API
* @param[in]  *cUploadPath          アップロード先パス名
* @param[in]  nUploadFileMaxSize    アップロードファイル最大サイズ
* @param[in] nUploadRetryCount      アップロードリトライ回数
* @param[in] nUploadRetryWaitTime   アップロードリトライ待ち時間
* @return 1：処理成功/else：処理失敗
* @attention アップロードに成功した場合はZIPファイルを削除する
*/
int
uploadNTSSLogFiles( u_char *cWorkFolder
                  , u_char *cUploadHost
                  , u_char *cUploadAPI
                  , u_char *cUploadJoinAPI
                  , u_char *cUploadPath
                  , uint16_t nUploadFileMaxSize
                  , int nUploadRetryCount
                  , int nUploadRetryWaitTime
                  )
{
    int ret = 1;
    u_char clog[ NTSS_STR_MAX_SIZE ];
    u_char cZipFolder[ NTSS_STR_MAX_SIZE ];
    u_char cUploadFolder[ NTSS_STR_MAX_SIZE ];
    u_char cUploadURI[ NTSS_STR_MAX_SIZE ];
    u_char cUploadJoinURI[ NTSS_STR_MAX_SIZE ];
    u_char clist[ NTSS_STR_MAX_SIZE];
    u_char cbuf[ NTSS_STR_MAX_SIZE ];
    u_char cZipFile[ NTSS_STR_MAX_SIZE ];
    u_char cUploadFile[ NTSS_STR_MAX_SIZE ];
    FILE *fp;

    // アップロード用URI
    sprintf(
          cUploadURI
        , "%s%s"
        , cUploadHost
        , cUploadAPI
    );
    //　アップロードファイル結合用URI
    sprintf(
          cUploadJoinURI
        , "%s%s"
        , cUploadHost
        , cUploadJoinAPI
    );

    // ZIP
    // ZIP格納先フォルダ名作成
    sprintf(
          cZipFolder
        , "%s/ZIP/"
        , cWorkFolder
    );
    // ZIP格納先フォルダ存在確認
    if( existFolderFile( cZipFolder , NULL ) == 1 )
    {
        // 対象フォルダあり
        
        // UPLOAD
        // UPLOAD作業用フォルダ名作成
        sprintf(
              cUploadFolder
            , "%s/UP/"
            , cWorkFolder
        );
        // アップロード作業用フォルダ存在確認
        if( existFolderFile( cUploadFolder , NULL ) == 1 )
        {
            // 対象フォルダあり

            // アップロード対象リストファイル名作成
            sprintf(
                  clist
                , "%s/UPLOAD_LIST.TXT"
                , cWorkFolder
            );
            
            // ファイルの一覧を取得
            if( getFolderList( 
                  cZipFolder
                , clist
                , NTSS_GETFOLDERLIST_MODE_FILE_ONLY
            ) == 1 )
            {
                // リストファイルの存在確認
                if( existFolderFile( clist, NULL ) == 1 )
                {
                    //
                    // リストファイルを開く
                    if (( fp = fopen( clist, "r" )) != NULL )
                    {
                        // 1行取得
                        while( fgets( cbuf, sizeof( cbuf ), fp) != NULL)
                        {
                            // 末尾のLFを除去
                            trimEnd( cbuf, '\n' );

                            // ZIPファイル名作成
                            sprintf(
                                  cZipFile
                                , "%s%s"
                                , cZipFolder
                                , cbuf
                            );

                            // アップロードするZIPファイル名作成
                            sprintf(
                                  cUploadFile
                                , "%s%s"
                                , cUploadFolder
                                , cbuf
                            );

                            // ZIPファイルをアップロードフォルダへコピーする
                            if( copyFile(
                                  cZipFile
                                , cUploadFile
                                , NTSS_COPYFILE_MODE_OVERWRITE
                            ) ==  1 )
                            {
                                // コピー成功

                                // ZIPファイルをアップロードする
                                int ncount = 0;
                                if( uploadNTSSFile(
                                          cUploadFile
                                        , cUploadURI
                                        , cUploadPath
                                        , nUploadFileMaxSize
                                        , &ncount
                                        , ""
                                        , ""
                                        , nUploadRetryCount
                                        , nUploadRetryWaitTime
                                ) == 0 )
                                {
                                    // 転送成功

                                    // 
                                    sprintf(
                                          clog
                                        , "ファイル転送成功,%s,(0),分割数,%d"
                                        , cbuf
                                        , ncount
                                    );
                                    LogOutput( NTSS_LOG_INFO, clog );

                                    // 
                                    sprintf(
                                        clog
                                        , "ファイル転送に成功したので対象のZIPファイルを削除,%s"
                                        , cZipFile
                                    );
                                    LogOutput( NTSS_LOG_INFO, clog );

                                    // ファイル削除
                                    remove( cZipFile );

                                    // ファイル結合指示を行う
                                    if( uploadNTSSFileJoin(
                                              ncount
                                            , cZipFile
                                            , cUploadJoinURI
                                            , cUploadPath
                                            , ""
                                            , ""
                                    ) == 0 )
                                    {
                                        // 結合指示成功

                                        // 
                                        sprintf(
                                              clog
                                            , "ファイル結合指示成功,%s"
                                            , cbuf
                                        );
                                        LogOutput( NTSS_LOG_INFO, clog );
                                    } 
                                    else 
                                    {
                                        // 結合指示失敗

                                        // 
                                        sprintf(
                                              clog
                                            , "ファイル結合指示失敗,%s"
                                            , cbuf
                                        );
                                        viewError( clog );

                                        ret = 0;
                                    }
                                } 
                                else
                                {
                                    // アップロード失敗

                                    // 
                                    sprintf(
                                          clog
                                        , "ファイルアップロード失敗,%s"
                                        , cbuf
                                    );
                                    viewError( clog );

                                    ret = 0;
                                }
                            }
                        }

                        fclose(fp);
                    }
                }
            }
            else
            {
                // 一覧取得失敗

                sprintf(
                    clog
                    , "作業用フォルダ内のZIPファイル一覧取得失敗:%s"
                    , cZipFolder
                );
                viewError( clog );

                ret = 0;
            }

            // リストファイルを削除する
            remove( clist );

            // アップロードフォルダを空にする
            deleteFolderInFiles( cUploadFolder );
        }
    }

    return ret;
}


/**
* @brief ログファイルをアップロードする
*
* @details ログファイルをアップロードする
*
* @description
* @param[in] configParam    設定情報
* @return 1：処理成功/else：処理失敗
* @attention 当日分以外のログファイルはアップロードに成功した場合は削除される
*/
int uploadNTSSLog(ConfigParameter_t *configParam)
{
    const int LOGFOLDER_COUNT = 3;
    int nret = 1;

    u_char clog[1024];

    // ログ設定
    setLogInfo();

    // ログフォルダのアップロード先
    u_char cUploadPath[ NTSS_STR_MAX_SIZE ];
    sprintf( 
          cUploadPath
        , configParam->uploadS3Path
        , configParam->facilityCd
    );

    // ログファイル出力先
    u_char *cLogFolder[LOGFOLDER_COUNT];
    cLogFolder[0] = configParam->logsvFolder1;
    cLogFolder[1] = configParam->logsvFolder2;
    cLogFolder[2] = configParam->logsvFolder3;

    // ログファイルの空き容量
    unsigned long long nLogFreeSize[LOGFOLDER_COUNT];
    unsigned long long nFreeSize = 0;

    // 各ログファイル出力先の空き容量を取得、一番空き容量が大きいフォルダを決める
    int nSelectFolder = -1;
    int intlop = 0;
    for( intlop = 0; intlop < LOGFOLDER_COUNT; intlop++ )
    {
        nLogFreeSize[intlop] = getFreeSize( cLogFolder[intlop] );
        if( nFreeSize < nLogFreeSize[intlop] )
        {
            nFreeSize = nLogFreeSize[intlop];
            nSelectFolder = intlop;
        }
    }
    // ログフォルダなし
    if( nSelectFolder == -1 )
    {
        sprintf(
              clog
            , "ログフォルダが使用できないためログファイルアップロード処理失敗"
        );
        viewError( clog );

        return 0;
    }

    // 作業用フォルダ作成
    makeNTSSLogUploadWorkFolder( cLogFolder[nSelectFolder] );

    u_char cworkfolder[ NTSS_STR_MAX_SIZE ];
    u_char cworkfolder2[ NTSS_STR_MAX_SIZE ];
    u_char cfolder[ NTSS_STR_MAX_SIZE ];
    u_char cfile[ NTSS_STR_MAX_SIZE ];

    // 作業フォルダ名作成
    sprintf( 
          cworkfolder
        , "%s/WORK"
        , cLogFolder[nSelectFolder]
    );
    // 作業フォルダ内のZIPファイル格納先フォルダ名作成
    sprintf( 
          cworkfolder2
        , "%s/WORK/ZIP"
        , cLogFolder[nSelectFolder]
    );

    // 設定されているログフォルダ分の作業
    for( intlop = 0; intlop < LOGFOLDER_COUNT; intlop++ )
    {
        // WORKフォルダからのログファイル収集
        sprintf( 
              cfolder
            , "%s/WORK"
            , cLogFolder[intlop]
        );
        moveNTSSLogFiles(
              cfolder
            , cworkfolder
            , 1 
        );

        // LOGフォルダからのログファイル収集
        if( moveNTSSLogFiles(
              cLogFolder[intlop]
            , cworkfolder
            , 1 
        ) == 1 )
        {
            // 収集成功

            if( intlop != nSelectFolder ) 
            {
                // ZIPファイル収集
                sprintf( 
                      cfolder
                    , "%s/WORK/ZIP"
                    , cLogFolder[intlop]
                );
                moveNTSSLogFiles(
                      cfolder
                    , cworkfolder2
                    , 1 
                );
            }
        }
    }

    // ファイル圧縮
    zipNTSSLogFiles(
          cworkfolder
        , configParam->uploadPW
    );

    // ファイルアップロード
    uploadNTSSLogFiles(
        cworkfolder
        , configParam->uploadHostName
        , "/ntss-web-api/upload"
        , "/ntss-web-api/fileJoin"
        , cUploadPath
        , configParam->uploadLimitFileSize
        , configParam->nUploadRetryCount
        , configParam->nUploadRetryWaitTime
    );

    return nret;
}