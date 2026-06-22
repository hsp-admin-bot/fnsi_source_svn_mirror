/**
* @brief NTSSデータ収集アプリケーション用汎用処理ファイル
*
* @details NTSSデータ収集アプリケーションの汎用処理
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_datacollect_etc.c
* @author H.Yonezawa
* @date 2017/11/22
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

#include "ntss_datacollect_etc.h"
#include "ntss_datacollect_conf.h"

#include "../common/libs/ntss_etc_lib.h"
#include "../common/libs/ntss_upload_lib.h"


/**
* @brief NTSSデータ収集作業用フォルダ、並びに指定装置作業用フォルダを作成
*
* @details NTSSデータ収集作業用フォルダとその中に装置作業用フォルダを作成する
*
* @description
* @param[in] *cWorkFolder       作業用フォルダ名
* @param[in] *cMachineName      装置名
* @param[out] *cMachineFolder   装置作業用フォルダ名
* @return １：作成成功/else：作成失敗
* @attention 特になし
*/
int
makeNTSSDataCollectWorkFolder( u_char *cWorkFolder
                             , u_char *cMachineName
                             , u_char *cMachineFolder
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

    // 作業用フォルダ内に装置作業用フォルダの存在確認
    sprintf( cwork, "%s%s", cWorkFolder, cMachineName );
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


    // 装置作業用フォルダ内のFNデータ格納用フォルダの存在確認
    sprintf( cwork2, "%sFN", cwork );
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

    // 装置作業用フォルダ内のFTPデータ格納用フォルダの存在確認
    sprintf( cwork2, "%sFTP", cwork );
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

    // 装置作業用フォルダ内のLOGデータ格納用フォルダの存在確認
    sprintf( cwork2, "%sLOG", cwork );
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

    // 装置作業フォルダ名
    memmove( cMachineFolder, cwork, strlen( cwork ));

    return ret;
}

/**
* @brief 移動元フォルダから移動先フォルダに指定リストファイル内のファイルを移動する
*
* @details 移動元フォルダから移動先フォルダに指定リストファイル内のファイルを移動する
*
* @description
* @param[in] *cSourceFolder 移動元フォルダ名
* @param[in] *cDestFolder   移動先フォルダ名
* @param[in] *cListFileName 処理対象ファイルが記載されたファイル名
* @param[in] mode           移動先に同じファイル名がすでに存在している場合の処理[NTSS_MOVENTSSFILES_MODE_FN：FN通信データモード(末尾に追記する)/NTSS_MOVENTSSFILES_MODE_FTP：FTP収集データモード(日付の新しい方を残す)]
* @param[in] *info          データ収集管理情報
* @return 1：移動成功/else：移動失敗(リストファイルなし、移動元フォルダなし、移動先フォルダなし含む)
* @attention 特になし
*/
int
moveNTSSFiles( u_char *cSourceFolder
             , u_char *cDestFolder
             , u_char *cListFileName 
             , NtssMoveNtssFilesMode mode
             , struct NTSS_DATACOLLECT_MACHINE_INFORMATION *info
             )
{
    int ret = 0;
    int move = 0;
    u_char clog[1024];
    u_char cbuf[ NTSS_STR_MAX_SIZE ];
    u_char cfile1[ NTSS_STR_MAX_SIZE ];
    u_char cfile2[ NTSS_STR_MAX_SIZE ];
    u_char cfile3[ NTSS_STR_MAX_SIZE ];
    struct stat st1;
    struct stat st2;
    FILE *fp;

    // リストファイルの存在確認
    if( existFolderFile( cListFileName, NULL ) == 1 )
    {
        //　リストファイルあり

        // 移動元フォルダの存在確認
        if( existFolderFile( cSourceFolder, NULL ) == 1 ) 
        {
            // 移動元フォルダあり

            // 移動先フォルダの存在確認
            if( existFolderFile( cDestFolder, NULL ) == 1 )
            {
                // 移動先フォルダあり

                ret = 1;

                // リストファイルを開く
                if (( fp = fopen( cListFileName, "r" )) != NULL )
                {
                    // 1行取得
                    while( fgets( cbuf, sizeof( cbuf ), fp) != NULL)
                    {
                        move = 1;

                        // 末尾のLFを除去
                        trimEnd( cbuf, '\n' );

                        // 移動元ファイル名作成
                        sprintf(
                              cfile1
                            , "%s%s"
                            , cSourceFolder
                            , cbuf
                        );
                        // 移動先ファイル名作成
                        sprintf(
                              cfile2
                            , "%s%s"
                            , cDestFolder
                            , cbuf
                        );

                        // 移動先ファイルの存在確認
                        if( existFolderFile( cfile2, &st2 ) == 1 )
                        {
                            // 該当ファイルあり

                            // 処理判定
                            if( mode == NTSS_MOVENTSSFILES_MODE_FN )
                            {
                                // FN通信データモード
                                // ※移動先に同名ファイルがあった場合は末尾に追記する

                                // 結合後ファイル名作成
                                sprintf( 
                                      cfile3
                                    , "%s.ADD"
                                    , cfile2
                                );

                                // コマンド作成
                                sprintf(
                                      clog
                                    , "cat %s %s > %s"
                                    , cfile2
                                    , cfile1
                                    , cfile3
                                );
                                // ファイル結合処理実施
                                system( clog );

                                // 移動元ファイルの削除
                                remove( cfile2 );
                                // 移動先ファイルの削除
                                remove( cfile1 );
                            
                                // 結合ファイル名を移動先ファイル名を変更
                                rename( cfile3, cfile2 );
                                // 
                                sprintf(
                                      clog
                                    , "移動先ファイルの末尾に移動元ファイルを追加します,%s <+ %s"
                                    , cfile2
                                    , cfile1
                                );
                                outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );

                                // 移動処理不要
                                move = 0;
                            }
                            else if( mode == NTSS_MOVENTSSFILES_MODE_FTP )
                            {
                                // FTPデータ収集モード
                                // ※移動先に同名ファイルがあった場合は新しい方を残す
                                
                                // 移動元ファイルの情報取得
                                if( existFolderFile( cfile1, &st1 ) == 1 )
                                {
                                    // 最終修正時刻により判定
                                    if( 0 <= difftime( st2.st_mtim.tv_sec, st1.st_mtim.tv_sec ))
                                    {
                                        // 移動先ファイルが最新なのでファイルコピーを行わない
                                        move = 0;

                                        // 
                                        sprintf(
                                              clog
                                            , "移動先ファイルが最新なので移動元ファイルを削除します,%s"
                                            , cfile1
                                        );
                                        outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );

                                        // 移動元ファイルを削除
                                        remove( cfile1 );
                                    }
                                    else
                                    {
                                        // 移送元ファイルが最新なのでファイルコピーを行う

                                        // 
                                        sprintf(
                                              clog
                                            , "移動元ファイルが最新なので移動先ファイルを削除します,%s"
                                            , cfile2
                                        );
                                        outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );

                                        //　移動先ファイルを削除
                                        remove( cfile2 );
                                    }
                                }
                                else
                                {
                                    // 移動元ファイルの情報が取得できなかった場合

                                    ret = 0;
                                }

                            }
                            else
                            {
                                //　処理モードが無効な場合

                                ret = 0;
                            }
                        } 
                        
                        // 移動処理実施
                        if( move == 1 )
                        {
                            // 該当ファイルなし

                            // ファイルを移動する
                            if( moveFile( 
                                  cfile1
                                , cfile2
                                , NTSS_MOVEFILE_MODE_NO_OVERWRITE
                            ) == 1 )
                            {
                                // 移動成功
                                sprintf(
                                      clog
                                    , "ファイル移動,%s→%s"
                                    , cfile1
                                    , cfile2
                                );
                                outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );
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
                                outputNTSSDataCollectMachineInfoErrorLog( clog, info );

                                ret = 0;
                            }
                        }
                    }

                    fclose(fp);
                } 
            }
        }
    }
    
    return ret;
}

/**
* @brief 移動元作業用フォルダから移動先作業用フォルダにFTP収集データ、FN通信データを移動する
*
* @details 移動元作業用フォルダから移動先作業用フォルダにFTP収集データ、FN通信データを移動する
*
* @description
* @param[in] *cSourceWorkFolder 移動元作業用フォルダ名
* @param[in] *cDestFolder       移動先作業用フォルダ名
* @param[in] *cMachineName      装置名
* @param[in] *info              データ収集管理情報
* @return 1：移動成功/else：移動失敗
* @attention 特になし
*/
int
moveNTSSDataCollectWorkFolderFile( u_char *cSourceFolder
                                 , u_char *cDestFolder
                                 , u_char *cMachineName
                                 , struct NTSS_DATACOLLECT_MACHINE_INFORMATION *info
                                 )
{
    int ret = 1;
    u_char clog[ NTSS_STR_MAX_SIZE ];
    u_char csrcFolder[ NTSS_STR_MAX_SIZE ];
    u_char cdstFolder[ NTSS_STR_MAX_SIZE];
    u_char clist[ NTSS_STR_MAX_SIZE];

    // FTP
    // 移動元FTP作業用フォルダ名作成
    sprintf(
          csrcFolder
        , "%s%s/FTP/"
        , cSourceFolder
        , cMachineName
    );
    // 移動元FTP作業用フォルダ存在確認
    if( existFolderFile( csrcFolder , NULL ) == 1 )
    {
        // 対象フォルダあり
        
        // 移動先FTP作業用フォルダ名作成
        sprintf(
              cdstFolder
            , "%s%s/FTP/"
            , cDestFolder
            , cMachineName
        );

        // リストファイル名作成
        sprintf(
              clist
            , "%s%s/LOG/FTP_LIST.TXT"
            , cDestFolder
            , cMachineName
        );
        
        // ファイルの一覧を取得
        if( getFolderList( 
              csrcFolder
            , clist
            , NTSS_GETFOLDERLIST_MODE_FILE_ONLY
        ) == 1 )
        {
            // リストファイルの存在確認
            if( existFolderFile( clist, NULL ) == 1 )
            {
                // リストファイルがある場合
                //　一覧内のファイルを移動
                if( moveNTSSFiles(
                      csrcFolder
                    , cdstFolder
                    , clist
                    , NTSS_MOVENTSSFILES_MODE_FTP
                    , info
                ) != 1 )
                {
                    // ファイル移動失敗
                    
                    sprintf(
                          clog
                        , "装置作業用フォルダへのFTPファイルの移動に失敗しました,%s→%s"
                        , csrcFolder
                        , cdstFolder
                    );
                    outputNTSSDataCollectMachineInfoErrorLog( clog, info );

                    ret = 0;
                }
            }
        }
        else
        {
            // 一覧取得失敗

            sprintf(
                  clog
                , "装置作業用フォルダ内のFTPファイル一覧取得失敗:%s"
                , csrcFolder
            );
            outputNTSSDataCollectMachineInfoErrorLog( clog, info );

            ret = 0;
        }

        // リストファイルを削除する
        remove( clist );
    }

    // FN
    // 移動元FN作業用フォルダ名作成
    sprintf(
          csrcFolder
        , "%s%s/FN/"
        , cSourceFolder
        , cMachineName
    );
    // 移動元FN作業用フォルダ存在確認
    if( existFolderFile( csrcFolder , NULL ) == 1 )
    {
        // 対象フォルダあり
        
        // 移動先FN作業用フォルダ名作成
        sprintf(
              cdstFolder
            , "%s%s/FN/"
            , cDestFolder
            , cMachineName
        );

        // リストファイル名作成
        sprintf(
              clist
            , "%s%s/LOG/FN_LIST.TXT"
            , cDestFolder
            , cMachineName
        );
        
        // ファイルの一覧を取得
        if( getFolderList( 
              csrcFolder
            , clist
            , NTSS_GETFOLDERLIST_MODE_FILE_ONLY
        ) == 1 )
        {
            // リストファイルの存在確認
            if( existFolderFile( clist, NULL ) == 1 )
            {
                //　一覧内のファイルを移動
                if( moveNTSSFiles(
                      csrcFolder
                    , cdstFolder
                    , clist
                    , NTSS_MOVENTSSFILES_MODE_FN
                    , info
                ) != 1 )
                {
                    // ファイル移動失敗
                    
                    sprintf(
                          clog
                        , "装置作業用フォルダへのFNファイルの移動に失敗しました,%s→%s"
                        , csrcFolder
                        , cdstFolder
                    );
                    outputNTSSDataCollectMachineInfoErrorLog( clog, info );

                    ret = 0;
                }
            }
        }
        else
        {
            // 一覧取得失敗

            sprintf(
                  clog
                , "装置作業用フォルダ内のFNファイル一覧取得失敗:%s"
                , csrcFolder
            );
            outputNTSSDataCollectMachineInfoErrorLog( clog, info );

            ret = 0;
        }

        //　リストファイルを削除する
        remove( clist );
    }

    return ret;
}


/**
* @brief 指定条件でFTPデータ収集を行う
*
* @details 指定条件でFTPデータ収集を行う
*
* @description
* @param[in] *cURL          FTP接続先情報
* @param[in] *cUSER         ユーザID
* @param[in] *cPW           パスワード
* @param[in] *cLogFolder    ログ格納先フォルダ
* @param[in] *cDataFolder   データ格納先フォルダ
* @param[in] nWaitSecond    ファイル一覧を再取得するときの待ち時間
* @param[in] nRetryCount    リトライ回数
* @param[in] *info          データ収集管理情報
* @return 0：作成成功/else：作成失敗
* @attention 特になし
*/
int
getNTSSFTP( u_char *cURL
          , u_char *cUSER
          , u_char *cPW
          , u_char *cLogFolder
          , u_char *cDataFolder
          , int nWaitSecond
          , int nRetryCount
          , struct NTSS_DATACOLLECT_MACHINE_INFORMATION *info
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
        , "./sh/ftp.sh \"%s\" \"%s\" \"%s\" \"%s\" \"%s\" %d %d"
        , cURL
        , cUSER
        , cPW
        , cLogFolder
        , cDataFolder
        , nWaitSecond
        , nRetryCount
    );

    // FTPデータ収集実行
    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    ret = system( cbuff );
    if( WIFEXITED( ret ))
    {
        // 子プロセスが正常に終了した場合

        // 子プロセスの終了ステータスを取得
        ret = WEXITSTATUS( ret );
    }

    // FTPデータ収集が正常に完了した場合は収集ファイルの一覧をログに記録する
    if( ret == 0 )
    {
        // 収集一覧ファイル名作成
        sprintf(
              cfile
            , "%sFTP_DL_FILES.TXT"
            , cLogFolder
        );

        // 収集一覧ファイルの存在確認
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
                        , "データ収集対象ファイル,%s%s"
                        , cDataFolder
                        , cbuff
                    );
                    outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );
                }

                fclose(fp);
            }
        }
    }
    else
    {
        // 失敗

        // 
        sprintf(
              clog
            , "データ収集対象コマンド,%s"
            , cbuff
        );
        outputNTSSDataCollectMachineInfoErrorLog( clog, info );

        // エラーログファイル名作成
        sprintf(
              cfile
            , "%sFTP_DL_ERRLOG.TXT"
            , cLogFolder
        );

        // ファイルの存在確認
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
                        , "データ収集対象コマンド応答,%s"
                        , cbuff
                    );
                    outputNTSSDataCollectMachineInfoErrorLog( clog, info );
                }

                fclose(fp);
            }
        }
    }

    return ret;
}

/**
* @brief 移動元フォルダから移動先フォルダに指定装置のFN通信データを移動する
*
* @details 移動元フォルダから移動先フォルダに指定装置のFN通信データを移動する
*
* @description
* @param[in] *cSourceWorkFolder 移動元フォルダ名
* @param[in] *cDestFolder       移動先フォルダ名(装置作業用フォルダ)
* @param[in] *cGrepPattern      装置抽出用パターン文字列
* @param[in] *cWorkFolder       作業用フォルダ
* @param[in] *info              データ収集管理情報
* @return 1：移動成功(対象フォルダやファイルがない場合含む)/else：移動失敗
* @attention 特になし
*/
int
moveNTSSDataCollectFNFile( u_char *cSourceFolder
                          , u_char *cDestFolder
                          , u_char *cGrepPattern
                          , u_char *cWorkFolder
                          , struct NTSS_DATACOLLECT_MACHINE_INFORMATION *info
                          )
{
    int ret = 1;
    u_char clog[ NTSS_STR_MAX_SIZE ];
    u_char clist1[ NTSS_STR_MAX_SIZE];
    u_char clist2[ NTSS_STR_MAX_SIZE];
    u_char cbuff[ NTSS_STR_MAX_SIZE ];

    // 移動元フォルダ存在確認
    if( existFolderFile(
          cSourceFolder
        , NULL
    ) == 1 )
    {
        // 移動元フォルダあり
                
        // リストファイル名作成
        sprintf(
              clist1
            , "%sFN_LIST1.TXT"
            , cWorkFolder
        );
        
        // 対象装置分リストファイル名作成
        sprintf(
              clist2
            , "%sFN_LIST2.TXT"
            , cWorkFolder
        );

        // ファイルの一覧を取得
        if( getFolderList( 
              cSourceFolder
            , clist1
            , NTSS_GETFOLDERLIST_MODE_FILE_ONLY
        ) == 1 )
        {
            // リストファイルの存在確認
            if( existFolderFile(
                  clist1
                , NULL 
            ) == 1 )
            {
                // 
                sprintf(
                      clog
                    , "FN通信データ収集対象ファイル,パターン抽出,%s%s"
                    , cSourceFolder
                    , cGrepPattern
                );
                outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );
                
                // リストファイルから対象装置のファイルを抽出する
                sprintf(
                      cbuff
                    , "cat \"%s\" | grep -G \"%s\" > \"%s\""
                    , clist1
                    , cGrepPattern
                    , clist2
                );
                system( cbuff );

                //　一覧内のファイルを移動
                if( moveNTSSFiles(
                      cSourceFolder
                    , cDestFolder
                    , clist2
                    , NTSS_MOVENTSSFILES_MODE_FN
                    , info
                ) != 1 )
                {
                    // ファイル移動失敗
                    
                    sprintf(
                          clog
                        , "装置作業用フォルダへのFNファイルの移動に失敗しました,%s→%s"
                        , cSourceFolder
                        , cDestFolder
                    );
                    outputNTSSDataCollectMachineInfoErrorLog( clog, info );

                    ret = 0;
                }
            }
        }
        else
        {
            // 一覧取得失敗

            sprintf(
                  clog
                , "装置作業用フォルダ内のFNファイル一覧取得失敗:%s"
                , cSourceFolder
            );
            outputNTSSDataCollectMachineInfoErrorLog( clog, info );

            ret = 0;
        }

        //　リストファイルを削除する
        remove( clist1 );
        remove( clist2 );
    }

    return ret;
}

/**
* @brief データ収集管理情報のログ出力を行う
*
* @details データ収集管理情報のログ出力を行う
*
* @description
* @param[in] type   種別コード
* @param[in] *msg   ログメッセージ
* @param[in] flag   出力フラフ（0:通常,1:システム情報有り）
* @param[in] *info  データ収集管理情報
* @return なし
* @attention 特になし
*/
extern void
outputNTSSDataCollectMachineInfoLog( NtssLogType type
                                   , u_char *msg 
                                   , int flag
                                   , struct NTSS_DATACOLLECT_MACHINE_INFORMATION *info
                                   )
{
    u_char cDeviceType[4];
    u_char cDeviceNo[9];

    memset( cDeviceType, 0, sizeof( cDeviceType ));
    memset( cDeviceNo, 0, sizeof( cDeviceNo ));

    if( info != NULL )
    {
        // 型式コード
        memmove( cDeviceType, info->cDeviceType, 3 );

        // 製造番号
        memmove( cDeviceNo, info->cDeviceNo, 8 );
    }

    // ログ出力
    LogSend(
          type
        , msg 
        , flag
        , cDeviceType
        , cDeviceNo
    );
}

/**
* @brief データ収集管理情報のエラーログ出力を行う
*
* @details データ収集管理情報のエラーログ出力を行う
*
* @description
* @param[in] type   種別コード
* @param[in] *msg   ログメッセージ
* @param[in] flag   出力フラフ（0:通常,1:システム情報有り）
* @param[in] *info  データ収集管理情報
* @return なし
* @attention 特になし
*/
extern void
outputNTSSDataCollectMachineInfoErrorLog( u_char *msg 
                                        , struct NTSS_DATACOLLECT_MACHINE_INFORMATION *info
                                        )
{
    u_char cDeviceType[4];
    u_char cDeviceNo[9];

    memset( cDeviceType, 0, sizeof( cDeviceType ));
    memset( cDeviceNo, 0, sizeof( cDeviceNo ));

    if( info != NULL )
    {
        // 型式コード
        memmove( cDeviceType, info->cDeviceType, 3 );

        // 製造番号
        memmove( cDeviceNo, info->cDeviceNo, 8 );
    }

    // ログ出力
    viewErrorLogSend(
          msg 
        , cDeviceType
        , cDeviceNo
    );
}
