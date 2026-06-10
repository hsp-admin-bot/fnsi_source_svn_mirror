/**
* @brief NTSSデータ収集処理対象装置情報処理ファイル
*
* @details NTSSデータ収集処理対象装置情報を管理する
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_machine_info.c
* @author H.Yonezawa
* @date 2017/11/21
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


#include "ntss_machine_info.h"
#include "ntss_datacollect_etc.h"

#include "../common/libs/ntss_etc_lib.h"
#include "../common/libs/ntss_log_lib.h"


/// 日機装通信キャプチャ対象装置設定ファイル
#define NTSS_CAPTURE_DEVICE_CONFIG_FILE "machineInfoData.dat"


/// @name NTSSデータ収集対象装置管理情報
//@{

/// データ収集対象装置管理情報配列
struct NTSS_DATACOLLECT_MACHINE_INFORMATION machineInfoList[NTSS_DATACOLLECT_MACHINE_INFORMATION_COUNT];


/// データ収集対象装置管理情報用構造体(データ要求から指定された処理対象装置)
struct NTSS_DATACOLLECT_MACHINE_LIST_INFORMATION {
    u_char  cDeviceType[3];     ///< 型式コード[3]
    u_char  cDeviceFormat;      ///< 通信フォーマット(機種)[1]
    u_char  cDeviceNo[8];       ///< 製造番号[8]
};

/**
* @brief データ収集対象装置管理情報を作成する
*
* @details データ収集対象装置管理情報を作成する
*
* @description
* @param[in] *cFolder       マスタファイル格納先フォルダ
* @param[in] *cListFileName 装置指定ファイル名
* @return 1：初期化成功/else：初期化失敗
* @attention 特になし
*/
int
initNTSSDataCollectMahineInfo( u_char *cFolder
                             , u_char *cListFileName
                             )
{
    int ret = 0;
    struct NTSS_DATACOLLECT_MACHINE_INFORMATION *info;
    u_char clog[ NTSS_STR_MAX_SIZE ];
    int res;

    // 処理対象装置情報管理情報初期化
    memset( machineInfoList, 0, sizeof( machineInfoList ));

    u_char cCfgFile[ NTSS_STR_MAX_SIZE ];
    cCfgFile[0] = 0;
    strcat( cCfgFile, cFolder );
    strcat( cCfgFile, NTSS_CAPTURE_DEVICE_CONFIG_FILE );
    
    FILE *fp;

    // 装置マスタ
    uint ndeviceCount = 0;
    MachineInfo_t  deviceInfo[NTSS_DATACOLLECT_MACHINE_INFORMATION_COUNT];
    memset( deviceInfo, 0, sizeof( deviceInfo ));

    // ファイルサイズ取得
    struct stat st;
    if( existFolderFile( cCfgFile, &st ) == 1 )
    {
        // ファイルあり

        ndeviceCount = NTSS_DATACOLLECT_MACHINE_INFORMATION_COUNT;

        // 格納数をファイルサイズから算出
        if(( st.st_size / sizeof( MachineInfo_t )) < ndeviceCount )
        {
            ndeviceCount = ( st.st_size / sizeof( MachineInfo_t ));
        } 

        // ファイル読み込み
        if (( fp = fopen( cCfgFile, "rb" )) != NULL )
        {
            // 設定読み込み
            if( 0 < ( ndeviceCount = fread( deviceInfo, sizeof( MachineInfo_t), ndeviceCount, fp )))
            {
                // 装置マスタ読み込み完了

                //
                sprintf( 
                      clog
                    , "装置マスタファイル読み込み完了, %s, %d件"
                    , cCfgFile
                    , ndeviceCount
                );
                LogOutput( NTSS_LOG_INFO, clog );

                //
                printf( "%s\n", clog );        
            }

            fclose( fp );	
        }
    }
    else
    {
        // ファイルなし

        ndeviceCount = 0;
    }


    //　装置指定
    uint nmachineListCount = 0;
    struct NTSS_DATACOLLECT_MACHINE_LIST_INFORMATION machineList[NTSS_DATACOLLECT_MACHINE_INFORMATION_COUNT];
    memset( machineList, 0, sizeof( machineList ));
    if(  0 < strlen( cListFileName ))
    {
        // ファイルサイズ取得
        struct stat st;
        if( existFolderFile( cListFileName, &st ) == 1 )
        {
            // ファイルあり

            //
            nmachineListCount = NTSS_DATACOLLECT_MACHINE_INFORMATION_COUNT;

            // 格納数をファイルサイズから算出
            if(( st.st_size / sizeof( struct NTSS_DATACOLLECT_MACHINE_LIST_INFORMATION )) < nmachineListCount )
            {
                nmachineListCount = ( st.st_size / sizeof( struct NTSS_DATACOLLECT_MACHINE_LIST_INFORMATION ));
            } 

            // ファイル読み込み
            if (( fp = fopen( cListFileName, "rb" )) != NULL )
            {
                // 設定読み込み
                if( 0 < ( nmachineListCount = fread( machineList, sizeof( struct NTSS_DATACOLLECT_MACHINE_LIST_INFORMATION), nmachineListCount, fp )))
                {
                    // 装置マスタ読み込み完了

                    //
                    sprintf(
                          clog
                        , "装置指定ファイル読み込み完了, %s, %d件"
                        , cListFileName
                        , nmachineListCount
                    );
                    LogOutput( NTSS_LOG_INFO, clog );

                    //
                    printf( "%s\n", clog );        
                }

                fclose( fp );	
            }
        }
    }

    MachineInfo_t *devinfo;
    struct NTSS_DATACOLLECT_MACHINE_LIST_INFORMATION *macinfo;

    //
    int intlop;
    int intlop2;
    bool bAdd = false;
    for( intlop = 0; intlop < ndeviceCount; intlop++ )
    {
        devinfo = &deviceInfo[intlop];
        bAdd = true;

        // 装置が指定されている場合
        if( 0 < nmachineListCount )
        {
            bAdd = false;

            //
            for( intlop2 = 0; intlop2 < nmachineListCount ; intlop2++ )
            {
                macinfo = &machineList[intlop2];

                //// debug
                //u_char cinfo[12];
                //u_char cinfo2[12];
                //cinfo[11] = cinfo2[11] = 0;
                //memmove( cinfo, devinfo->machineTypeCd, sizeof( devinfo->machineTypeCd ) + sizeof( devinfo->machineSerial ));
                //memmove( cinfo2, macinfo->cDeviceType, sizeof( macinfo->cDeviceType ) + sizeof( macinfo->cDeviceNo ));
                //printf( "mst:%s -> list:%s\n", cinfo, cinfo2 );

                // 型式コード＋通信フォーマット＋製造番号が一致するかどうか
                if( memcmp( devinfo->machineTypeCd, macinfo->cDeviceType, sizeof( devinfo->machineTypeCd ) + sizeof( devinfo->machineFormatCd) + sizeof( devinfo->machineSerial )) == 0 )
                {
                    // リストに該当あり
                    bAdd = true;

                    break;
                }
            }
        }

        // 装置を対象装置リストに登録
        if( bAdd == true )
        {
            // 収集対象装置情報を登録する
            info = AddNTSSDataCollectMachineInfo(
                  devinfo   // 装置マスタ情報
            );

            //
            sprintf( 
                  clog
                , "Add Machine Info %c %-27.27s %c"
                , info->cCommTypeCd
                , info->cDeviceType
                , info->cIsFTPCollect
            );
            outputNTSSDataCollectMachineInfoLog( NTSS_LOG_INFO, clog, 0, info );

            // debug
            printf( "%s\n", clog );
        }

    }

    ret = 1;

    return ret;
}




/**
* @brief データ収集対象装置管理情報を追加する
*
* @details 指定した装置情報をデータ収集対象装置管理情報に追加する
*
* @description
* @param[in] *deviceinfo    装置マスタ情報
* @return NULL：追加失敗/else：追加した情報ポインタ
* @attention 特になし
*/
struct NTSS_DATACOLLECT_MACHINE_INFORMATION *
AddNTSSDataCollectMachineInfo( MachineInfo_t *deviceInfo
                             )
{
    struct NTSS_DATACOLLECT_MACHINE_INFORMATION *ret = NULL;
    struct NTSS_DATACOLLECT_MACHINE_INFORMATION *info;
    
    u_char cAddr[ sizeof( deviceInfo->ipAddress ) + 1 ];
    cAddr[sizeof( cAddr ) - 1] = 0;

    // 配列分検索
    int intlop;
    for( intlop = 0; intlop < NTSS_DATACOLLECT_MACHINE_INFORMATION_COUNT; intlop++ )
    {
        info = &machineInfoList[intlop];
        
        // 空き判定[先頭から未割当箇所を検索]
        if( info->cCommTypeCd == 0)
        {
            ret = info;

            // 管理情報を設定

            // 通信方式
            info->cCommTypeCd = deviceInfo->machineCommCd;
            // 型式コード[3桁]、通信フォーマット[1桁]、製造番号[8桁]
            memmove( info->cDeviceType, deviceInfo->machineTypeCd, sizeof( deviceInfo->machineTypeCd ) + sizeof( deviceInfo->machineFormatCd ) + sizeof( deviceInfo->machineSerial ));
            // IPアドレス
            memmove( cAddr, deviceInfo->ipAddress, sizeof( deviceInfo->ipAddress ));
            // 10進IPアドレス文字列に変換
            getDecimalIPAddr( cAddr, cAddr );
            memmove( info->cIPAddr, cAddr, strlen( cAddr ));

            // FTP収集対象判定
            info->cIsFTPCollect = deviceInfo->hasFtp;

            //// debug
            //printf(
            //      "no:%d info:%s\n"
            //    , intlop
            //    , (char *)info
            //);

            break;
        }
    }

    return ret;
}


/**
* @brief 指定Indexのデータ収集対象装置管理情報を取得する
*
* @details 指定したIndex位置のデータ収集対象装置管理情報を取得する
*
* @description
* @param[in] nIndex     取得を行うIndex位置
* @return NULL：該当なし/else：該当した情報ポインタ
* @attention 特になし
*/
struct NTSS_DATACOLLECT_MACHINE_INFORMATION *
getNTSSDataCollectMachineInfo( int nIndexNo )
{
    struct NTSS_DATACOLLECT_MACHINE_INFORMATION *ret = NULL;
    struct NTSS_DATACOLLECT_MACHINE_INFORMATION *info;

    // 配列範囲判定
    if( 0 <= nIndexNo && nIndexNo < NTSS_DATACOLLECT_MACHINE_INFORMATION_COUNT )
    {
        info = &machineInfoList[nIndexNo];
        
        // 情報が登録されている場合
        if( info->cCommTypeCd != 0)
        {
            ret = info;
        }
    }

    return ret;
}
//@}
