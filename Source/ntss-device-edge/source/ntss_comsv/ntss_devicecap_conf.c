/**
* @brief NTSSパケット収集アプリケーション用設定情報管理ファイル
*
* @details NTSSパケット収集アプリケーションの設定情報を管理する
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_devicecap_conf.c
* @author H.Yonezawa
* @date 2017/11/01
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <arpa/inet.h>

#include "ntss_devicecap_conf.h"
#include "ntss_packet_manage.h"

#include "../common/libs/config_reader.h"
#include "../common/libs/ntss_etc_lib.h"


/// 共通設定ファイル名
#define NTSS_COMMON_CONF_FILE "./conf/ntss_common.conf"

/// 設定ファイル名
#define NTSS_DEVICECAP_CONF_FILE "./conf/ntss_pcap.conf"


/// 設定情報用構造体
struct NTSS_DEVICECAP_CONF devicecapConf;

/// 通信サーバー情報用構造体
struct NTSS_FN_SERVER_INFORMATION {
    __be32  svAddr;     ///< 通信SVIPアドレス[※ネットワークバイトオーダー指定]
    __be16  svPortNo;   ///< 通信SVポートNo(0指定で動的ポートNo)[※ネットワークバイトオーダー指定]    
} fnSVInfo[10];


/**
* @brief 指定文字列から通信サーバー情報を取得する
*
* @details　指定文字列から通信サーバー情報を取得する
*
* @description
* @param[in] *cInfo 指定文字列
* @return 1：取得成功/else：取得失敗
* @attention 特になし
*/
int
setSVInfo( u_char *cInfo )
{
    int ret = 0;
    int intlop;
    u_char cbuf[NTSS_STR_MAX_SIZE];
    u_char *p[10];
    int ncount = 1;
    int nsize = strlen( cInfo );

    // 
    memset( cbuf, 0, sizeof( cbuf ));
    memset( p, 0, sizeof( p ));
    
    memmove( cbuf, cInfo, nsize );
    p[0] = cbuf;

    // 各SV情報の分割
    for( intlop = 1; ncount < 10 && intlop < nsize; intlop++ )
    {
        if( cbuf[ intlop ] == '/' )
        {
            //
            cbuf[ intlop ] = 0;
            p[ncount++] = &cbuf[ intlop + 1];
        }    
    }  

    // 各情報の分割
    u_char cinfo[NTSS_STR_MAX_SIZE];
    u_char cip[16];
    int nport;
    int intlop2;
    int ncount2 = 0;
    for( intlop = 0; intlop < ncount; intlop++ )
    {
        memset( cip, 0, sizeof( cip ));

        sprintf( cinfo, "%s", p[intlop]);
        for( intlop2 = 0; intlop2 < strlen( cinfo ); intlop2++ )
        {
            if( cinfo[ intlop2 ] == ':' )
            {
                // IP、ポート番号取得
                cinfo[ intlop2 ] = 0;
                nport = atoi( cinfo + intlop2 + 1);

                // debug
                printf( "FNSV No:%d IP:%s Port:%d\n", ncount2 + 1, cinfo, nport );

                // SV情報登録
                fnSVInfo[ncount2].svAddr   = convertNTSSIPAddr( cinfo );
                fnSVInfo[ncount2].svPortNo = htons( nport );
                ncount2++;
            }
        }

    }

    // SV設定がある場合
    if( 0 < ncount2 )
    {
        ret = 1;
    }

    return ret;
}

/**
* @brief NTSSパケット収集設定ファイルを読み込む
*
* @details NTSSパケット収集アプリケーション用の設置ファイルを読み込む
*
* @description
* @return １：取得成功/else：取得失敗
* @attention 特になし
*/
int
getNTSSDeviceCapConf()
{
    int ret = 0;
    int intlop;
    
    // 設定格納構造体初期化
    memset( &devicecapConf, 0, sizeof( devicecapConf ));

    // 作業用領域確保
    int nMaxSize = 20;
    ConfigData_t buffs[nMaxSize];
    
    char cKey[21];
    char *pVal;
        

    // 共通設定読み込み
    memset( buffs, 0, sizeof( buffs ));
    int nlines = readConfigDataFile((const char *)NTSS_COMMON_CONF_FILE, buffs, nMaxSize );
    if( 0 < nlines )
    {     
        //　施設コード
        if(( pVal = getConfigDataValue( buffs, nlines, "FACILITY_CODE" )) != NULL )
        {
            strcat( devicecapConf.cFacilityCode, pVal );        
        }

        // デバイスエッジ番号
        devicecapConf.nDeviceEdgeNo = 1;
        if(( pVal = getConfigDataValue( buffs, nlines, "AWS_IOT_DEVICE_NO" )) != NULL )
        {
            int intval = atoi( pVal );
            if( 0 < intval )
            {
                devicecapConf.nDeviceEdgeNo = intval;
            }
        }

        // マスタファイル参照先フォルダ
        // if(( pVal = getConfigDataValue( buffs, nlines, "MASTER_FOLDER" )) != NULL )
        // {
        //     strcat( devicecapConf.cMstFolder, pVal );

        //     // 末尾に'/'追加
        //     addFolderSeparator(devicecapConf.cMstFolder);
        // }
        sprintf(devicecapConf.cMstFolder, "./mst/");
            
        // 緊急発報用ファイル格納先フォルダ([優先順位][バッファ数])
        for( intlop = 0; intlop < NTSS_FOLDER_DEFINE_MAX_COUNT; intlop ++ )
        {
            //
            sprintf( cKey, "M_NOTICE_FOLDER%d", intlop + 1 );
            if(( pVal =  getConfigDataValue( buffs, nlines, cKey )) != NULL )
            {
                strcat( devicecapConf.cM_NoticeFolder[intlop], pVal );        

                // 末尾に'/'追加
                addFolderSeparator(devicecapConf.cM_NoticeFolder[intlop]);
            }
        }
        
        //　データ収集用ファイル格納先フォルダ([優先順位][バッファ数])
        for( intlop = 0; intlop < NTSS_FOLDER_DEFINE_MAX_COUNT; intlop ++ )
        {
            //
            sprintf( cKey, "DATA_COLLECT_FOLDER%d", intlop + 1 );
            if(( pVal = getConfigDataValue( buffs, nlines, cKey )) != NULL )
            {
                strcat( devicecapConf.cDataCollectFolder[intlop], pVal );        

                // 末尾に'/'追加
                addFolderSeparator(devicecapConf.cDataCollectFolder[intlop]);
            }
        }

        // 治療中モニタ送信間隔
        devicecapConf.nSendDialysisMonitorInterval = 20;
        if(( pVal = getConfigDataValue( buffs, nlines, "SEND_DIALYSIS_MONITOR_INTERVAL" )) != NULL )
        {
            int intval = atoi( pVal );
            if( 0 < intval )
            {
                devicecapConf.nSendDialysisMonitorInterval = intval;
            }
        }
        // 未治療時モニタ送信間隔
        devicecapConf.nSendUntreatMonitorInterval = 60;
        if(( pVal = getConfigDataValue( buffs, nlines, "SEND_UNTREATMENT_MONITOR_INTERVAL" )) != NULL )
        {
            int intval = atoi( pVal );
            if( 0 < intval )
            {
                devicecapConf.nSendUntreatMonitorInterval = intval;
            }
        }
    
        // 設定読み込み
        memset( buffs, 0, sizeof( buffs ));
        int nlines = readConfigDataFile((const char *)NTSS_DEVICECAP_CONF_FILE, buffs, nMaxSize );
        if( 0 < nlines )
        {
            char cKey[20];
            char *pVal;
            
            // パケットキャプチャ関連
            // パケット対象デバイス名
            if(( pVal = getConfigDataValue( buffs, nlines, "CAPTURE_DEVICE" )) != NULL )
            {
                strcat( devicecapConf.cCaptureDevice, pVal );        
            }
            // フィルタ設定
            if(( pVal = getConfigDataValue( buffs, nlines, "CAPTURE_FILTER" )) != NULL )
            {
                strcat( devicecapConf.cCaptureFilter, pVal );        
            }
            
            // 通信サーバー端末情報
            if(( pVal = getConfigDataValue( buffs, nlines, "FN_COMM_SERVER" )) != NULL )
            {
                strcat( devicecapConf.cFnSV, pVal );        

                // 通信サーバー情報設定
                ret = setSVInfo( devicecapConf.cFnSV );
            }

            // 装置死活監視間隔
            devicecapConf.nMachineAliveInterval = 30;
            if(( pVal = getConfigDataValue( buffs, nlines, "M_ALIVE_INTERVAL" )) != NULL )
            {
                int intval = atoi( pVal );
                if( 0 < intval )
                {
                    devicecapConf.nMachineAliveInterval = intval;
                }
            }

            // 装置状態判定間隔[秒]
            devicecapConf.nCheckMachineStateInterval = 1;
            if(( pVal = getConfigDataValue( buffs, nlines, "CHECK_MACHINE_STATE_INTERVAL" )) != NULL )
            {
                int intval = atoi( pVal );
                if( 0 < intval )
                {
                    devicecapConf.nCheckMachineStateInterval = intval;
                }
            }
        }       
    }

/*
    // debug
    for( intlop = 0; intlop < nlines; intlop++ )
    {
        printf( "No:%d %s=%s\n", intlop + 1, buffs[intlop].keyStr, buffs[intlop].val );
    }
    printf( "＝＝　DeviceCap Config ==\n");
    // パケットキャプチャ関連
    // パケット対象デバイス名
    printf( " ・DeviceName:%s\n", devicecapConf.cCaptureDevice );
    // フィルタ設定
    printf( " ・Filter    :%s\n", devicecapConf.cCaptureFilter );
    
    // 通信サーバー端末情報
    // 通信サーバーIPアドレス(xxx.xxx.xxx.xxx形式文字列)
    printf( " ・FN Addr:%s\n", devicecapConf.cFnAddr );
    // 通信サーバー待ち受けポート番号
    printf( " ・FN Port:%d\n", devicecapConf.nFnPortNo );
    
    // 緊急発報用ファイル格納先フォルダ([優先順位][バッファ数])
    nMaxSize = 3;
    for( intlop = 0; intlop < nMaxSize; intlop++ )
    {
        printf( " ・M_Notice%d:%s\n", intlop + 1, devicecapConf.cM_NoticeFolder[intlop] );
    }
    
    //　データ収集用ファイル格納先フォルダ([優先順位][バッファ数])
    nMaxSize = 3;
    for( intlop = 0; intlop < nMaxSize; intlop++ )
    {
        printf( " ・DataCollect%d:%s\n", intlop + 1, devicecapConf.cDataCollectFolder[intlop] );
    }
*/

    return ret;
}

/**
* @brief NTSSパケット収集設定からデータ格納先フォルダを取得する
*
* @details NTSSパケット収集設定からデータ格納先フォルダを取得する
*
* @description
* @param[in] cOutputType    データ格納先種類[0x00:緊急発報用/0x01データ収集用:]
* @param[in] nPriority      優先順位(0>1>2)
* @return NULL：未設定/else：データ格納先フォルダ文字列のポインタ取得成功
* @attention 特になし
*/
u_char *
getNTSSDeviceCapDataFolder( u_char cOutputType 
                          , int nPriority
                          )
{
    u_char *ret = NULL;

    switch( cOutputType )
    {
        case NTSS_OUTPUT_FOLDER_M_NOTICE:   // 緊急発報用
            //
            ret = devicecapConf.cM_NoticeFolder[nPriority];
            break;

        case NTSS_OUTPUT_FOLDER_DATA_COLLECT:   // データ収集用
            //
            ret = devicecapConf.cDataCollectFolder[nPriority];
            break;                                
    }

    return ret;
}

/**
* @brief 指定されたIPアドレス、ポート番号が通信サーバー情報に存在するかチェックする
*
* @details 指定された送信先IPアドレス、ポート番号が通信サーバー情報に存在するかチェックする
*
* @description
* @param[in] destAddr   送信先IPアドレス
* @param[in] destPortNo 送信先ポート番号
* @return 1：該当あり/0：該当なし
* @attention 特になし
*/
int
existFnSVInfo( __be32  destAddr
             , __be16  destPortNo
             )
{
    int ret = 0;
    int intlop = 0;
    struct NTSS_FN_SERVER_INFORMATION *info;

    for( intlop = 0; intlop < (sizeof( fnSVInfo ) / sizeof( struct NTSS_FN_SERVER_INFORMATION )); intlop++ )
    {
        info = &fnSVInfo[intlop];

        //// debug
        //printf( "FNSV %d IP:%s, %d\n", intlop + 1, inet_ntoa(*(struct in_addr *)&(info->svAddr)),ntohs(info->svPortNo));

        // SV設定有効判定
        if( info->svAddr == 0 )
        {
            break;
        }

        // IPアドレス判定
        if( info->svAddr == destAddr )
        {
            // IPアドレスが一致

            // ポート番号判定
            if( info->svPortNo == destPortNo || info->svPortNo == 0 )
            {
                // ポート番号が一致(又は通信サーバーポート番号が自動[0]である場合)

                ret = 1;

                break;
            }
        }
    }

    return ret;
}
