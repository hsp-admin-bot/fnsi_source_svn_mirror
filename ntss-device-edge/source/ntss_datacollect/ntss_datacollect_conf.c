/**
* @brief NTSSデータ収集アプリケーション用設定情報管理ファイル
*
* @details NTSSデータ収集アプリケーションの設定情報を管理する
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_datacollect_conf.c
* @author H.Yonezawa
* @date 2017/11/17
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "ntss_datacollect_conf.h"

#include "../common/libs/config_reader.h"
#include "../common/libs/ntss_etc_lib.h"
#include "../common/libs/ntss_enc_dec.h"


/// 共通設定ファイル名
#define NTSS_COMMON_CONF_FILE "./conf/ntss_common.conf"

/// 設定ファイル名
#define NTSS_DATACOLLECT_CONF_FILE "./conf/ntss_datacollect.conf"

/// ネットワーク設定ファイル名
#define NTSS_NETWORK_CONF_FILE "./conf/ntss_network.conf"

/// 設定情報用構造体
struct NTSS_DATACOLLECT_CONF datacollectConf;


/**
* @brief NTSSデータ収集設定ファイルを読み込む
*
* @details NTSSデータ収集アプリケーション用の設置ファイルを読み込む
*
* @description
* @return １：取得成功/else：取得失敗
* @attention 特になし
*/
int
getNTSSDataCollectConf()
{
    int ret = 0;
    int intlop;
    
    // 設定格納構造体初期化
    memset( &datacollectConf, 0, sizeof( datacollectConf ));

    // 作業用領域確保
    int nMaxSize = 20;
    ConfigData_t buffs[nMaxSize];
    
    char cKey[20];
    char *pVal;
        

    // 共通設定読み込み
    memset( buffs, 0, sizeof( buffs ));
    int nlines = readConfigDataFile((const char *)NTSS_COMMON_CONF_FILE, buffs, nMaxSize );
    if( 0 < nlines )
    {     
        // 施設コード
        if(( pVal = getConfigDataValue( buffs, nlines, "FACILITY_CODE" )) != NULL )
        {
            strcat( datacollectConf.cFacilityCd, pVal );        
        }

        // // マスタファイル参照先フォルダ
        // if(( pVal = getConfigDataValue( buffs, nlines, "MASTER_FOLDER" )) != NULL )
        // {
        //     strcat( datacollectConf.cMstFolder, pVal );

        //     // 末尾に'/'追加
        //     addFolderSeparator(datacollectConf.cMstFolder);
        // }
        sprintf(datacollectConf.cMstFolder, "./mst/");
        
        //　データ収集用ファイル格納先フォルダ([優先順位][バッファ数])
        for( intlop = 0; intlop < NTSS_FOLDER_DEFINE_MAX_COUNT; intlop ++ )
        {
            //
            sprintf( cKey, "TEMP_FOLDER%d", intlop + 1 );
            if(( pVal = getConfigDataValue( buffs, nlines, cKey )) != NULL )
            {
                strcat( datacollectConf.cDataCollectFolder[intlop], pVal );        

                // 末尾に'/'追加
                addFolderSeparator(datacollectConf.cDataCollectFolder[intlop]);
            }
        }

        // 設定読み込み
        memset( buffs, 0, sizeof( buffs ));
        int nlines = readConfigDataFile((const char *)NTSS_DATACOLLECT_CONF_FILE, buffs, nMaxSize );
        if( 0 < nlines )
        {
            // 作業用ファイル格納先フォルダ([優先順位][バッファ数])
            for( intlop = 0; intlop < NTSS_FOLDER_DEFINE_MAX_COUNT; intlop ++ )
            {
                //
                sprintf( cKey, "WORK_FOLDER%d", intlop + 1 );
                if(( pVal = getConfigDataValue( buffs, nlines, cKey )) != NULL )
                {
                    strcat( datacollectConf.cWorkFolder[intlop], pVal );        

                    // 末尾に'/'追加
                    addFolderSeparator(datacollectConf.cWorkFolder[intlop]);
                }
            }
            
            // FTP関連
            // 装置FTPフォルダ
            u_char cFTP_Folder[ NTSS_STR_MAX_SIZE ];
            if(( pVal = getConfigDataValue( buffs, nlines, "FTP_FOLDER" )) != NULL )
            {
                strcat( datacollectConf.cFTP_Folder, pVal );        
            }
            // FTPユーザー名
            if(( pVal = getConfigDataValue( buffs, nlines, "FTP_USER" )) != NULL )
            {
                strcat( datacollectConf.cFTP_User, pVal );        
            }
            // FTPパスワード
            if(( pVal = getConfigDataValue( buffs, nlines, "FTP_PW" )) != NULL )
            {
                strcat( datacollectConf.cFTP_PW, pVal );        
            }
            // FTPウエイト秒数
            if(( pVal = getConfigDataValue( buffs, nlines, "FTP_WAIT" )) != NULL )
            {
                datacollectConf.nFTP_Wait = atoi( pVal );
            }
            // FTPリトライ回数
            if(( pVal = getConfigDataValue( buffs, nlines, "FTP_RETRY" )) != NULL )
            {
                datacollectConf.nFTP_Retry = atoi( pVal );
            }


            // アップロード関連           
/*            

            // IAMユーザーキー
            if(( pVal = getConfigDataValue( buffs, nlines, "AWS_USER_KEY" )) != NULL )
            {
                //strcat( datacollectConf.cAWSIAMUserKey, pVal );        
                // 復号化
                if( encdecNTSSText( 
                      NTSS_ENCDECNTSSTEXT_MODE_DEC
                    , pVal
                    , sizeof( datacollectConf.cAWSIAMUserKey )
                    , datacollectConf.cAWSIAMUserKey
                ) != 1 )
                {
                    // 復号化失敗

                    return 2;
                }
                //// debug
                //printf( "AWS User: %s\n", datacollectConf.cAWSIAMUserKey );
            }
            // IAMシークレットキー
            if(( pVal = getConfigDataValue( buffs, nlines, "AWS_USER_SECRET_KEY" )) != NULL )
            {
                //strcat( datacollectConf.cAWSIAMUserSecretKey, pVal );        
                // 復号化
                if( encdecNTSSText( 
                      NTSS_ENCDECNTSSTEXT_MODE_DEC
                    , pVal
                    , sizeof( datacollectConf.cAWSIAMUserSecretKey )
                    , datacollectConf.cAWSIAMUserSecretKey
                ) != 1 )
                {
                    // 復号化失敗

                    return 3;
                }
                //// debug
                //printf( "AWS UserSecret: %s\n", datacollectConf.cAWSIAMUserSecretKey );
            }
            // APIキー
            if(( pVal = getConfigDataValue( buffs, nlines, "AWS_API_KEY" )) != NULL )
            {
                //strcat( datacollectConf.cAWSAPIKey, pVal );        
                // 復号化
                if( encdecNTSSText( 
                      NTSS_ENCDECNTSSTEXT_MODE_DEC
                    , pVal
                    , sizeof( datacollectConf.cAWSAPIKey )
                    , datacollectConf.cAWSAPIKey
                ) != 1 )
                {
                    // 復号化失敗

                    return 4;
                }
                //// debug
                //printf( "AWS API: %s\n", datacollectConf.cAWSAPIKey );
            }
            //  AWSリージョン
            if(( pVal = getConfigDataValue( buffs, nlines, "AWS_REGION" )) != NULL )
            {
                strcat( datacollectConf.cAWSRegion, pVal );        
            }
            // AWSサービス名
            if(( pVal = getConfigDataValue( buffs, nlines, "AWS_SERVICE" )) != NULL )
            {
                strcat( datacollectConf.cAWSServiceName, pVal );        
            }
            // AWSホスト名
            if(( pVal = getConfigDataValue( buffs, nlines, "AWS_HOST" )) != NULL )
            {
                strcat( datacollectConf.cAWSHostName, pVal );        
            }
            // AWSアドレス
            if(( pVal = getConfigDataValue( buffs, nlines, "AWS_ADDRESS" )) != NULL )
            {
                strcat( datacollectConf.cAWSAddress, pVal );        
            }         
            // AWSファイルセキュリティ
            if(( pVal = getConfigDataValue( buffs, nlines, "AWS_FILE_SECURITY" )) != NULL )
            {
                strcat( datacollectConf.cAWSFileSecurity, pVal );        
            }
*/
            // アップロード先パス名
            if(( pVal = getConfigDataValue( buffs, nlines, "UPLOAD_PATH" )) != NULL )
            {
                strcat( datacollectConf.cUploadPath, pVal );        
            }
        }

        // 設定読み込み
        memset( buffs, 0, sizeof( buffs ));
        nlines = readConfigDataFile((const char *)NTSS_NETWORK_CONF_FILE, buffs, nMaxSize );
        if( 0 < nlines )
        {
            // 圧縮関連
            // 圧縮パスワード
            if(( pVal = getConfigDataValue( buffs, nlines, "ZIP_PW" )) != NULL )
            {
                strcat( datacollectConf.cZipPW, pVal );        
            }


            // アップロード関連
            // アップロードファイル最大サイズ[MB単位：既定値=8MB]
            datacollectConf.nUploadFileMaxSize = 8;
            if(( pVal = getConfigDataValue( buffs, nlines, "UPLOAD_FILE_MAXSIZE" )) != NULL )
            {
                datacollectConf.nUploadFileMaxSize = atoi( pVal );
            }
            // AWSホスト名
            if(( pVal = getConfigDataValue( buffs, nlines, "AWS_HOST" )) != NULL )
            {
                strcat( datacollectConf.cAWSHostName, pVal );        
            }
            // AWSアドレス
            //strcat( datacollectConf.cAWSAddress, "/data_gathering/api/upload" );
            strcat( datacollectConf.cAWSAddress, "/ntss-web-api/upload" );
            // アップロードリトライ回数[既定値=3回]
            datacollectConf.nUploadRetryCount = 3;
            if(( pVal = getConfigDataValue( buffs, nlines, "UPLOAD_RETRY_COUNT" )) != NULL )
            {
                datacollectConf.nUploadRetryCount = atoi( pVal );
            }
            // アップロードリトライ待ち時間[秒単位：既定値=30秒]
            datacollectConf.nUploadRetryWaitTime = 30;
            if(( pVal = getConfigDataValue( buffs, nlines, "UPLOAD_RETRY_WAIT_TIME" )) != NULL )
            {
                datacollectConf.nUploadRetryWaitTime = atoi( pVal );
            }

            ret = 1;
        }
    }

    return ret;
}
