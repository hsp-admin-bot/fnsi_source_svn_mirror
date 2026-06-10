/**
* @brief NTSSパケット管理情報処理ファイル
*
* @details NTSSパケット情報を管理する
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_packet_manage.c
* @author H.Yonezawa
* @date 2017/10/18
*/


/* 必要な機能
*   ・配列から対象パケット管理情報を検索する              (findNTSSPacketInfo)
*   ・対象パケット管理情報を配列に追加する               (AddNTSSPacketInfo)
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/types.h>
#include <linux/types.h>
#include <stdbool.h>
#include <arpa/inet.h>
#include <limits.h>

#include "ntss_packet_manage.h"
#include "ntss_packet_file.h"
#include "ntss_common_comm.h"

#include "../common/libs/ntss_etc_lib.h"
#include "../common/libs/master_controller.h"
#include "../common/libs/ntss_mst_lib.h"


/// 日機装通信キャプチャ対象装置設定ファイル
#define NTSS_CAPTURE_DEVICE_CONFIG_FILE "machineInfoData.dat"


/// @name NTSSパケット管理情報
//@{

/// パケット管理情報配列
struct NTSS_PACKET_INFORMATION packetInfoList[NTSS_PACKET_INFORMATION_COUNT];

/// 装置情報作成モード中フラグ
bool bCreateMachineInfo = false;

/**
* @brief 装置情報作成モードを返す
*
* @details 装置情報作成モードを取得する
*
* @description
* @return true：装置情報作成モード/false：通常モード
* @attention 特になし
*/
bool
getCreateMachineInfoMode(){
    return bCreateMachineInfo;
}

/**
* @brief 装置情報作成モードを設定する
*
* @details 装置情報作成モードを設定する
*
* @description
* @param[in] bMode      設定する装置情報作成モード[true：装置情報作成モード/false：通常モード]
* @param[in] *cFolder   マスタファイル格納先フォルダ
* @return なし
* @attention 特になし
*/
void
setCreateMachineInfoMode( bool bMode
                        , u_char *cFolder
                        )
{
    // パケット管理情報初期化
    memset( packetInfoList, 0, sizeof( packetInfoList ));

    // モード設定
    bCreateMachineInfo = bMode;

    // ログ記憶
    LogOutput( NTSS_LOG_INFO, bCreateMachineInfo ? "装置情報作成モードへ移行" : "通常モードへ移行");

    // 通常モード移行判定
    if( bMode == false) {
        // パケット管理情報を登録する
        if( initNTSSPacketInfo(
            cFolder
        ) != 1 )
        {
            //
            viewError( "透析装置情報(mstMachineInfo.dat)が読み込めませんでした" );
        }
    }
}


/**
* @brief NTSSパケット管理情報の検索で使用するIPアドレスを返す
*
* @details IPアドレス文字列を管理用IPアドレスに変換する
*
* @description
* @param[in] *ipAddr    IPアドレス文字列([.]区切り)
* @return 0：変換失敗/１以上：変換後のIPアドレス[※ネットワークバイトオーダー]
* @attention 特になし
*/
__be32
convertNTSSIPAddr( u_char *ipAddr )
{
    u_char cwork[16];

    // 10進表記のIPアドレス文字列に変換
    getDecimalIPAddr( ipAddr, cwork );

    // アドレス文字列をバイナリ値へ変換します
    return (__be32)inet_addr((const char *)cwork );
}

/**
* @brief NTSSパケット管理情報設定ファイルを読み込む
*
* @details NTSSパケット管理情報設定ファイルを読み込む
*
* @description
* @param[in] *cFolder       マスタファイル格納先フォルダ
* @return 1：初期化成功/else：初期化失敗
* @attention 特になし
*/
int
initNTSSPacketInfo( u_char *cFolder
                  )
{
    int ret = 0;
    struct NTSS_PACKET_INFORMATION *info;
    u_char clog[ NTSS_STR_MAX_SIZE ];
    
    // パケット管理情報初期化
    memset( packetInfoList, 0, sizeof( packetInfoList ));

    u_char cCfgFile[ NTSS_STR_MAX_SIZE ];
    cCfgFile[0] = 0;
    strcat( cCfgFile, cFolder );
    strcat( cCfgFile, NTSS_CAPTURE_DEVICE_CONFIG_FILE );
    
    u_long nsize = 100;
    MachineInfo_t  deviceInfo[nsize];
    memset( deviceInfo, 0, sizeof( deviceInfo ));


    FILE *fp;

    // ファイルサイズ取得
    struct stat st;
    if( existFolderFile( cCfgFile, &st ) == 1 )
    {
        // ファイルあり

        // 格納数をファイルサイズから算出
        if(( st.st_size / sizeof( MachineInfo_t )) < nsize )
        {
            nsize = ( st.st_size / sizeof( MachineInfo_t ));
        } 

        // ファイル読み込み
        if (( fp = fopen( cCfgFile, "rb" )) != NULL )
        {
            // 設定読み込み
            if( fread( deviceInfo, sizeof( MachineInfo_t), nsize, fp ) == nsize )
            {
                //
                MachineInfo_t *devinfo;
                u_char cbuf[sizeof( MachineInfo_t ) + 1];
                cbuf[sizeof( cbuf ) - 1] = 0;
                u_char cAddr[ sizeof( devinfo->ipAddress ) + 1 ];
                cAddr[sizeof( cAddr ) - 1] = 0;
                int nSrcPortNo = 0;
                int nDstPortNo = 0;
                u_char cTypeCd[ sizeof( devinfo->machineTypeCd )];
                u_char cFormatCd;
                u_char cDeviceNo[ sizeof( devinfo->machineSerial )];
                u_char cCommType;

                //
                int intlop;
                for( intlop = 0; intlop < nsize; intlop++ )
                {
                    devinfo = &deviceInfo[intlop];

                    // IPアドレス
                    memmove( cAddr, devinfo->ipAddress, sizeof( devinfo->ipAddress ));
                    // ポート番号
                    memmove( cbuf, devinfo->strport, sizeof( devinfo->strport ));
                    cbuf[ sizeof( devinfo->strport ) ] = 0;
                    nSrcPortNo = atoi( cbuf );
                    // 型式コード
                    memmove( cTypeCd, devinfo->machineTypeCd, sizeof( devinfo->machineTypeCd ));
                    // 通信フォーマット
                    cFormatCd = devinfo->machineFormatCd;
                    // 製造番号
                    memmove( cDeviceNo, devinfo->machineSerial, sizeof( devinfo->machineSerial ));
                    // 通信方式
                    cCommType = devinfo->machineCommCd;

                    //// debug
                    //printf("no:%d ip:%s->%d\n", intlop, cAddr, convertNTSSIPAddr( cAddr ));

                    // パケット管理情報を登録する
                    info = AddNTSSPacketInfo(
                          convertNTSSIPAddr(cAddr)  // 送信元IPアドレス[※ネットワークバイトオーダー指定]
                        , 0                         // 送信先IPアドレス[※ネットワークバイトオーダー指定]
                        , htons(nSrcPortNo)         // 送信元ポートNo[※ネットワークバイトオーダー指定]
                        , htons(nDstPortNo)         // 送信先ポートNo[※ネットワークバイトオーダー指定]
                        , cTypeCd                   // 型式コード
                        , cFormatCd                 // 通信フォーマット
                        , cDeviceNo                 // 製造番号
                        , cCommType                 // 通信方式
                    );

                    //
                    memmove( cbuf, devinfo, sizeof( MachineInfo_t ));
                    sprintf( 
                          clog
                        , "Add Packet Infor Index :%d - %s"
                        , getNTSSPacketInfoIndex( info )
                        , cbuf
                    );
                    outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, info );

                    // debug
                    printf( "%s\n", clog );

                    // 通信方式判定
                    if( info->cCommType == NTSS_COMM_TYPE_NEW )
                    {
                        // 自己診断実施日時をファイルから取得
                        getNTSSPacketInfoMainteDate( 
                              cFolder
                            , info
                        );

                        // ホスト監視設定初期化
                        initNTSSHostWatchConf( 
                              info
                        );                       
                    }
                }

                ret = 1;
            }

            fclose( fp );	
        }
    }

    return ret;
}


/**
* @brief NTSSパケット管理情報設定ファイルの再読み込みを行う
*
* @details NTSSパケット管理情報設定ファイルの再読み込みを行う
*
* @description
* @param[in] *cFolder       マスタファイル格納先フォルダ
* @return 1：初期化成功/else：初期化失敗
* @attention 特になし
*/
int
reinitNTSSPacketInfo( u_char *cFolder
                    )
{
    int ret = 0;
    struct NTSS_PACKET_INFORMATION *info;
    u_char clog[ NTSS_STR_MAX_SIZE ];

    u_char cCfgFile[ NTSS_STR_MAX_SIZE ];
    cCfgFile[0] = 0;
    strcat( cCfgFile, cFolder );
    strcat( cCfgFile, NTSS_CAPTURE_DEVICE_CONFIG_FILE );
    
    u_long nsize = 100;
    MachineInfo_t  deviceInfo[nsize];
    memset( deviceInfo, 0, sizeof( deviceInfo ));


    FILE *fp;

    // ファイルサイズ取得
    struct stat st;
    if( existFolderFile( cCfgFile, &st ) == 1 )
    {
        // ファイルあり

        // 格納数をファイルサイズから算出
        if(( st.st_size / sizeof( MachineInfo_t )) < nsize )
        {
            nsize = ( st.st_size / sizeof( MachineInfo_t ));
        } 

        // ファイル読み込み
        if (( fp = fopen( cCfgFile, "rb" )) != NULL )
        {
            // 設定読み込み
            if( fread( deviceInfo, sizeof( MachineInfo_t), nsize, fp ) == nsize )
            {
                //
                MachineInfo_t *devinfo;
                u_char cbuf[sizeof( MachineInfo_t ) + 1];
                cbuf[sizeof( cbuf ) - 1] = 0;
                u_char cAddr[ sizeof( devinfo->ipAddress ) + 1 ];
                cAddr[sizeof( cAddr ) - 1] = 0;
                int nSrcPortNo = 0;
                int nDstPortNo = 0;
                u_char cTypeCd[ sizeof( devinfo->machineTypeCd )];
                u_char cFormatCd;
                u_char cDeviceNo[ sizeof( devinfo->machineSerial )];
                u_char cCommType;

                //
                u_char cFindDeviceNo[ sizeof( devinfo->machineFormatCd ) + sizeof( devinfo->machineSerial ) + sizeof( devinfo->machineCommCd ) + 1 ];
                cFindDeviceNo[sizeof( cFindDeviceNo ) - 1] = 0;

                //
                int intlop;
                for( intlop = 0; intlop < nsize; intlop++ )
                {
                    devinfo = &deviceInfo[intlop];

                    // IPアドレス
                    memmove( cAddr, devinfo->ipAddress, sizeof( devinfo->ipAddress ));
                    // ポート番号
                    memmove( cbuf, devinfo->strport, sizeof( devinfo->strport ));
                    cbuf[ sizeof( devinfo->strport ) ] = 0;
                    nSrcPortNo = atoi( cbuf );
                    // 型式コード
                    memmove( cTypeCd, devinfo->machineTypeCd, sizeof( devinfo->machineTypeCd ));
                    // 通信フォーマット
                    cFormatCd = devinfo->machineFormatCd;
                    // 製造番号
                    memmove( cDeviceNo, devinfo->machineSerial, sizeof( devinfo->machineSerial ));
                    // 通信方式
                    cCommType = devinfo->machineCommCd;

                    // 検索キー用情報作成(通信フォーマット＋製造番号+通信方式)
                    cFindDeviceNo[0] = cFormatCd;
                    memmove( cFindDeviceNo + 1, cDeviceNo, sizeof( cDeviceNo ));
                    cFindDeviceNo[ sizeof( cFormatCd ) + sizeof( cDeviceNo ) ] = cCommType;

                    // パケット管理情報内を検索する
                    info = findNTSSPacketInfo(
                          convertNTSSIPAddr(cAddr)      // 送信元IPアドレス[※ネットワークバイトオーダー指定]
                        , 0                             // 送信先IPアドレス[※ネットワークバイトオーダー指定]
                        , htons(nSrcPortNo)             // 送信元ポートNo[※ネットワークバイトオーダー指定]
                        , htons(nDstPortNo)             // 送信先ポートNo[※ネットワークバイトオーダー指定]
                        , cFindDeviceNo                 // 通信フォーマット＋製造番号＋通信方式
                        , FINDNTSSPACKETINFO_NO_UPDATE  // 情報の更新を行わない
                    );

                    // 型式コード判定
                    if( info != NULL && memcmp( cTypeCd, info->cDeviceType, 3 ) != 0 )
                    {
                        // 型式コードが不一致
                        // 該当なしとする
                        info = NULL;
                    }

                    // 該当がない場合
                    if( info == NULL )
                    {
                        // パケット管理情報を登録する
                        info = AddNTSSPacketInfo(
                              convertNTSSIPAddr(cAddr)  // 送信元IPアドレス[※ネットワークバイトオーダー指定]
                            , 0                         // 送信先IPアドレス[※ネットワークバイトオーダー指定]
                            , htons(nSrcPortNo)         // 送信元ポートNo[※ネットワークバイトオーダー指定]
                            , htons(nDstPortNo)         // 送信先ポートNo[※ネットワークバイトオーダー指定]
                            , cTypeCd                   // 型式コード
                            , cFormatCd                 // 通信フォーマット
                            , cDeviceNo                 // 製造番号
                            , cCommType                 // 通信方式
                        );
                        //
                        memmove( cbuf, devinfo, sizeof( MachineInfo_t ));
                        sprintf( 
                              clog
                            , "Add Packet Infor Index :%d - %s"
                            , getNTSSPacketInfoIndex( info )
                            , cbuf
                        );
                        outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, info );

                        // debug
                        printf( "%s\n", clog );
                                
                        // 通信方式判定
                        if( info->cCommType == NTSS_COMM_TYPE_NEW )
                        {
                            // 自己診断実施日時をファイルから取得
                            getNTSSPacketInfoMainteDate( 
                                  cFolder
                                , info
                            );

                            // 施設用モニタデータ監視設定初期化
                            initNTSSHostWatchConf( 
                                  info
                            );                       
                        }
                    }
                    else
                    {
                        // dubug
                        printf("check info:%d %s  find :%d\n", intlop, cFindDeviceNo, getNTSSPacketInfoIndex( info ));
                    }
                }
/*
                // 削除前の情報をファイルに出力
                for( intlop = 0;  intlop < 5; intlop++ )
                {
                    info = &packetInfoList[intlop];
                    sprintf( clog, "[before],DeviceNo %d : %s (%ld)", intlop, info->cDeviceNo, strlen( info->cDeviceNo ));
                    outputNTSSPacketInfoLog( NTSS_LOG_DEBUG, clog, 1, info );
                }                                
*/
                // 未使用となるパケット管理情報を削除する
                int ndeleidx = 0;
                int intlop2;
                int nres;
                u_char cfind[ 3 + 1 + 8 + 1 + 1 ];   // 検索対象キー(型式コード[3]＋通信フォーマット[1]＋製造番号[8]＋通信方式[1])
                u_char cmst[ 3 + 1 + 8 + 1 + 1 ];   // 検索先キー(型式コード[3]＋通信フォーマット[1]＋製造番号[8]＋通信方式[1])
                cfind[13] = cmst[13] = 0;
                __be32 mstAddr;

                // 管理情報配列分検索
                for( intlop = 0; packetInfoList[intlop].sourceAddr != 0 && intlop < NTSS_PACKET_INFORMATION_COUNT; intlop++ )
                {
                    info = &packetInfoList[intlop];
                    nres = 0;

                    // 型式コード[3]＋通信フォーマット[1]＋製造番号[8]＋通信方式[1]取得
                    memmove( cfind, info->cDeviceType, sizeof( info->cDeviceType ) + sizeof( info->cDeviceFormat ) + sizeof( info->cDeviceNo ) + sizeof( info->cCommType ));

                    // マスタ記載分検索
                    for( intlop2 = 0; intlop2 < nsize; intlop2++  )
                    {
                        devinfo = &deviceInfo[intlop2];

                        // 型式コード[3]＋通信フォーマット[1]＋製造番号[8]取得
                        memmove( cmst, devinfo->machineTypeCd, sizeof( devinfo->machineTypeCd ) + sizeof( devinfo->machineFormatCd ) + sizeof( devinfo->machineSerial ));
                        // 通信方式[1]取得
                        cmst[12] = devinfo->machineCommCd;

                        //// debug
                        //printf( "DeviceNo %d : %s (%ld) -> %s (%ld)\n", intlop, cfind, strlen( cfind ), cmst, strlen( cmst ));

                        // 型式コード＋通信フォーマット＋製造番号＋通信方式で一致するものがあるかどうか
                        if( memcmp( cfind, cmst, strlen( cfind )) == 0 )
                        {
                            // 一致する情報あり
                            
                            // 装置マスタのIPアドレス取得
                            memmove( cAddr, devinfo->ipAddress, sizeof( devinfo->ipAddress ));
                            mstAddr = convertNTSSIPAddr( cAddr );
                            
                            // IPアドレスチェック
                            if( info->sourceAddr == mstAddr )
                            {
                                nres = 1;
/*
                                // debug
                                printf( "exist : %d\n", intlop );
*/
                                break;
                            }
                        }
                    }

                    // 一致する情報がない場合
                    if( nres == 0 )
                    {
                        sprintf(
                              clog
                            , "Delete Packet Infor Index :%d - %s"
                            , intlop
                            , cfind
                        );
                        outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, info );

                        // debug
                        printf( "%s\n", clog );

                        // 管理情報消去
                        memset( info, 0, sizeof( struct NTSS_PACKET_INFORMATION ));

                        // 削除位置を保持
                        ndeleidx = intlop;
                    }
                }
                
                // 削除前の情報をファイルに出力
                for( intlop = 0;  intlop < 10; intlop++ )
                {
                    info = &packetInfoList[intlop];
                    // 型式コード[3]＋通信フォーマット[1]＋製造番号[8]＋通信方式[1]取得
                    memmove( cfind, info->cDeviceType, sizeof( info->cDeviceType ) + sizeof( info->cDeviceFormat ) + sizeof( info->cDeviceNo ) + sizeof( info->cCommType ));
                    sprintf( clog, "[before],index %d : %s", intlop, cfind );
                    outputNTSSPacketInfoLog( NTSS_LOG_DEBUG, clog, 0, info );
                }                                

                // 空きを詰める
                for( intlop = ndeleidx; 0 <= intlop; intlop-- )
                {
                    //
                    info = &packetInfoList[intlop];
                    // debug
                    //printf( "index:%d DeviceNo %s (%ld) ip :%d\n", intlop, info->cDeviceNo, strlen( info->cDeviceNo ), info->sourceAddr );

                    // 空き検出
                    if( info->sourceAddr == 0 )
                    {
                        // debug
                        //printf( "Index:%d block:%d\n", intlop, ( NTSS_PACKET_INFORMATION_COUNT - intlop - 1 ));

                        // 次の領域を前に詰める
                        memmove( info, info + 1, sizeof( struct NTSS_PACKET_INFORMATION ) * ( NTSS_PACKET_INFORMATION_COUNT - intlop - 1 ));
                        
                        // 末尾を初期化
                        memset( &packetInfoList[NTSS_PACKET_INFORMATION_COUNT - 1], 0, sizeof( struct NTSS_PACKET_INFORMATION ));
                    }
                }

                // 詰めた後の情報をファイルに出力
                for( intlop = 0;  intlop < 10; intlop++ )
                {
                    info = &packetInfoList[intlop];
                    // 型式コード[3]＋通信フォーマット[1]＋製造番号[8]＋通信方式[1]取得
                    memmove( cfind, info->cDeviceType, sizeof( info->cDeviceType ) + sizeof( info->cDeviceFormat ) + sizeof( info->cDeviceNo ) + sizeof( info->cCommType ));
                    sprintf( clog, "[after],index %d : %s", intlop, cfind );
                    outputNTSSPacketInfoLog( NTSS_LOG_DEBUG, clog, 0, info );
                }                                

                ret = 1;
            }

            fclose( fp );	
        }
    }

    return ret;
}


/**
* @brief NTSSパケット情報を追加する
*
* @details 指定したIPアドレス、ポート番号のパケット情報を追加する
*
* @description
* @param[in] sourceAddr         送信元側IPアドレス[※ネットワークバイトオーダー指定]
* @param[in] destAddr           送信先側IPアドレス[※ネットワークバイトオーダー指定]
* @param[in] sourcePortNo       送信元側ポートNo(0指定で動的ポートNo)[※ネットワークバイトオーダー指定]
* @param[in] destPortNo         送信先側ポートNo(0指定で動的ポートNo)[※ネットワークバイトオーダー指定]
* @param[in] *cDeviceType       型式コード[3桁]
* @param[in] cFormatCd          通信フォーマット[1桁]
* @param[in] *cDeviceNo         製造番号[8桁]
* @param[in] cCommType          通信方式[1桁]('0':通信なし/'1':新通信/'2':NX通信/'3'：通信共通V4)
* @return NULL：追加失敗/else：追加した情報ポインタ
* @attention 特になし
*/
struct NTSS_PACKET_INFORMATION *
AddNTSSPacketInfo( __be32 sourceAddr
                 , __be32 destAddr
                 , __be16 sourcePortNo
                 , __be16 destPortNo
                 , u_char *cDeviceType
                 , u_char cFormatCd
                 , u_char *cDeviceNo
                 , u_char cCommType
                 )
{
    struct NTSS_PACKET_INFORMATION *ret = NULL;
    struct NTSS_PACKET_INFORMATION *info;
    int nsize;

    // 配列分検索
    int intlop;
    for( intlop = 0; intlop < NTSS_PACKET_INFORMATION_COUNT; intlop++ )
    {
        info = &packetInfoList[intlop];
        
        // 空き判定[先頭から未割当箇所を検索]
        if( info->sourceAddr == 0)
        {
            ret = info;

            // 管理情報を設定

            // 送信元IP
            info->sourceAddr = sourceAddr;
            // 送信先IP
            info->destAddr   = destAddr;
            // 送信元ポートNo
            info->sourceOrgPortNo = info->sourcePortNo = sourcePortNo;
            // 送信先ポートNo
            info->destOrgPortNo   = info->destPortNo   = destPortNo;
        
            // 型式コード
            memmove(info->cDeviceType, cDeviceType, 3 );
            // 通信フォーマット
            info->cDeviceFormat = cFormatCd;
            // 製造番号
            memmove(info->cDeviceNo, cDeviceNo, 8 );
            // 通信方式
            info->cCommType = cCommType;


            // 情報初期化
            finNTSSPacketInfo( info );
           
            // モニタデータ監視設定初期化
            initNTSSHostWatchConf( info );

            //// debug
            //u_char cbuff[ 3 + 1 + 8 + 1 + 1 ];
            //cbuff[ sizeof( cbuff ) - 1 ] = 0;
            //memmove( cbuff, info->cDeviceType, sizeof( cbuff ) - 1 );
            //printf( "no:%d sip:%d dip:%d sport:%d dport:%d info:%s\n", intlop, info->sourceAddr, info->destAddr, info->sourceOrgPortNo, info->destOrgPortNo, cbuff );

            break;
        }
    }

    return ret;
}


/**
* @brief NTSSパケット管理情報のポインタを返す
*
* @details 指定したIPアドレス、ポート番号のNTSSパケット管理情報のポインタを取得する
*
* @description
* @param[in] sourceAddr     送信元側IPアドレス[※ネットワークバイトオーダー指定]
* @param[in] destAddr       送信先側IPアドレス[※ネットワークバイトオーダー指定]
* @param[in] sourcePortNo   送信元側ポートNo[※ネットワークバイトオーダー指定]
* @param[in] destPortNo     送信先側ポートNo[※ネットワークバイトオーダー指定]
* @param[in] *cDeviceNo     通信フォーマット[1]＋製造番号[8]＋通信方式｢[1](NULL指定時は送信元/送信先IPアドレスとポートNo、から文字の場合は送信元IPアドレスのみを検索対象とする)
* @pram[in] cUpdateInfoFlag 管理情報更新フラグ(0x00:更新しない/0x01:更新する[該当した情報の送信先IPアドレス、各ポートNoの更新を行う])
* @return NULL：該当なし/else：該当した情報ポインタ
* @attention 特になし
*/
struct NTSS_PACKET_INFORMATION *
findNTSSPacketInfo( __be32 sourceAddr
                  , __be32 destAddr
                  , __be16 sourcePortNo
                  , __be16 destPortNo
                  , u_char *cDeviceNo
                  , u_char cUpdateInfoFlag
                  )
{
    struct NTSS_PACKET_INFORMATION *ret = NULL;
    struct NTSS_PACKET_INFORMATION *info;
    int intlop;
    
    //// debug
    //printf(" Search Source Addr:%d Port:%d / Dest Addr:%d Port:%d DNo:%s\n", sourceAddr, sourcePortNo, destAddr, destPortNo, cDeviceNo );

    //通信フォーマット＋製造番号判定
    if( cDeviceNo == NULL )
    {
        //通信フォーマット＋製造番号にNULLが指定されている場合
    
        // 配列分検索
        for( intlop = 0; 0 < packetInfoList[intlop].sourceAddr && intlop < NTSS_PACKET_INFORMATION_COUNT; intlop++ )
        {
            info = &packetInfoList[intlop];

            //// debug
            //printf(" Index:%d Source Addr:%d Port:%d / Dest Addr:%d Port:%d DNo:%s Type:%s\n", intlop, info->sourceAddr, info->sourcePortNo, info->destAddr, info->destPortNo, info->cDeviceNo, info->cDeviceType );

            // 空き判定
            if( info->sourceAddr == 0)
            {
                // 処理中断
                break;
            }

            // キー判定

            // 送信元/送信先IPアドレス判定
            if( info->sourceAddr == sourceAddr && info->destAddr == destAddr )
            {
                // 送信元/送信先IPアドレスが一致

                // 送信元/送信先ポート番号判定
                if( info->sourcePortNo == sourcePortNo && info->destPortNo == destPortNo )
                {
                    // 送信元/送信先ポート番号が一致

                    ret = info;

                    break;
                }
            }
        }
    }
    else
    {
        // 通信フォーマット＋製造番号＋通信方式が指定されている場合
        
        // 通信フォーマット＋製造番号＋通信方式の長さ取得
        int nDeviceNoSize = strlen( cDeviceNo );

        // 配列分検索
        for( intlop = 0; 0 < packetInfoList[intlop].sourceAddr && intlop < NTSS_PACKET_INFORMATION_COUNT; intlop++ )
        {
            info = &packetInfoList[intlop];

            // 空き判定
            if( info->sourceAddr == 0)
            {
                // 処理中断
                break;
            }
            // 送信元IPアドレス判定
            if( info->sourceAddr == sourceAddr )
            {
                // 送信元IPアドレスが一致

                // 通信フォーマット＋製造番号＋通信方式が空文字かどうか
                if( 0 < nDeviceNoSize )
                {
                    // 空文字以外が指定されている場合

                    //// debug
                    //u_char cwork[ nDeviceNoSize + 1];
                    //cwork[ sizeof( cwork ) - 1 ] = 0;
                    //memmove( cwork, &info->cDeviceFormat, nDeviceNoSize );
                    //printf( "findNTSSPacketinfo: index %d %s(%ld) <- %s(%d)\n", intlop, cwork, strlen( cwork ), cDeviceNo, nDeviceNoSize );

                    // 通信フォーマット＋製造番号＋通信方式判定
                    if(  memcmp( &info->cDeviceFormat, cDeviceNo, nDeviceNoSize ) == 0 )
                    {
                        // 通信フォーマット＋製造番号＋通信方式が一致
    
                        ret = info;
                        break;
                    }
                }
                else
                {
                    // 空文字が指定されている場合
                    
                    // 通信フォーマットが指定されている場合(通信共通プロトコル用)
                    if( cDeviceNo[1] != 0 )
                    {
                        // 通信フォーマット+通信方式のみで判定
                        if( info->cDeviceFormat == cDeviceNo[1] && info->cCommType == cDeviceNo[9] )
                        {
                            // 通信フォーマットと通信方式が一致
                            ret = info;
                            break;
                        }
                    }
                    // 通信方式のみで判定
                    else if( info->cCommType == cDeviceNo[9] )
                    {
                        // 通信方式が一致
                        ret = info;
                        break;
                    }
                }
            }
        }

        // 対象情報判定
        if( ret != NULL )
        {
            // 対象情報があった場合

            // 更新判定
            if( cUpdateInfoFlag == FINDNTSSPACKETINFO_UPDATE )
            {
                //　情報の更新を行う

                // 該当情報に割り当てる
                info->destAddr     = destAddr;
                info->sourcePortNo = sourcePortNo;
                info->destPortNo   = destPortNo;

                //　バッファクリア
                info->buffer.nBufferSize = 0;
            }
        }
    }

    return ret;
}

/**
* @brief 対象パケット管理情報のインデックスを取得する
*
* @details 対象パケット管理情報のインデックスを取得する
*
* @description
* @param[in] *ntssPacketInfo    パケット管理情報
* @return −１：該当なし/0以上:インデックス番号
* @attention 特になし
*/
int
getNTSSPacketInfoIndex( struct NTSS_PACKET_INFORMATION *ntssPacketInfo
                      )
{
    int ret = -1;
    struct NTSS_PACKET_INFORMATION *info;
    
    // 配列分検索
    int intlop;
    for( intlop = 0; intlop < NTSS_PACKET_INFORMATION_COUNT; intlop++ )
    {
        info = &packetInfoList[intlop];

        // 空き判定
        if( info->sourceAddr == 0)
        {
            // 処理中断
            break;
        }

        //
        if( ntssPacketInfo == info )
        {
            ret = intlop;
            break;
        }
    }

    return ret;
}

/**
* @brief 対象パケット管理情報のFIN処理を行う
*
* @details 対象パケット管理情報でバッファクリア、送信元ポート番号クリアを行う
*
* @description
* @param[in] *ntssPacketInfo パケット管理情報
* @return 0:正常終了/−1：処理失敗
* @attention 特になし
*/
int
finNTSSPacketInfo( struct NTSS_PACKET_INFORMATION *ntssPacketInfo
                 )
{
    int ret = -1;

    // バッファクリア
    ntssPacketInfo->buffer.nBufferSize = 0;

    // 送信元ポート番号初期化
    ntssPacketInfo->sourcePortNo = ntssPacketInfo->sourceOrgPortNo;
    // 送信先ポート番号初期化
    ntssPacketInfo->destPortNo   = ntssPacketInfo->destOrgPortNo;

    // 最終受信日付クリア
    ntssPacketInfo->buffer.lastReceiveTime.tv_sec = ntssPacketInfo->buffer.lastReceiveTime.tv_usec = 0;

    // 接続中フラグ初期化(0x00：未接続/0x01：接続中)
    ntssPacketInfo->isConnected = 0x00;
    // 工程コード初期化[0：現在/1：前回]
    ntssPacketInfo->nProcess[0] = ntssPacketInfo->nProcess[1] = SHRT_MIN;
    // 工程通知要求フラグ初期化(0x00:通知不要/0x01：通知必要)
    ntssPacketInfo->isNeedSendProcess = 0x01;  
    // モニタ更新フラグ(0x00：更新許可/0x01：更新不許可)
    ntssPacketInfo->isStopUpMoniData = 0x00;

    // 初回モニタデータフラグ(0x00：通常(積算処理あり)/0x01：初回(積算処理なし))
    ntssPacketInfo->isFirstMoniData = 0x01;
    //// モニタデータ保持用バッファ
    //ntssPacketInfo->cMoniData[512];
    // モニタデータ初期化
    ntssPacketInfo->nMoniDataSize = 0;
    // モニタデータ出力日時初期化
    ntssPacketInfo->moniOutputTime = 0;
    // 通信方式判定
    if( ntssPacketInfo->cCommType == NTSS_COMM_TYPE_COMMON )
    {
        // 通信共通プロトコルの場合

        // モニタ値を0x8000に初期化する
        short ndummy = SHRT_MIN;

        int intlop;
        for( intlop = 0; intlop < 245; intlop++)
        {
            memcpy( ntssPacketInfo->cMoniData + intlop * 2, &ndummy, 2 );
        }
    }

    //// メンテナンス自己診断測定年月日時分[BCD](4種類類分)
    //ntssPacketInfo->cMainteBCD[4][6];

    // 透析中フラグ初期化[0：現在/1：前回](0x00：未実施/0x01：透析中)
    ntssPacketInfo->isDialysis[0] = ntssPacketInfo->isDialysis[1] = 0x00;      

    // ホスト報知監視状態初期化(0x00：監視していない/0x01：監視中)
    ntssPacketInfo->isWatch = 0x00;

    ret = 0;
           
    return ret;
}

/**
* @brief 指定したNTSSパケット管理情報の自己診断実施日時をファイルから読み込み設定する
*
* @details 指定したNTSSパケット管理情報の自己診断実施日時をファイルから読み込み設定する
*
* @description
* @param[in] *cFolder   ファイル格納先フォルダ
* @param[in] *info      対象とするNTSSパケット管理情報
* @return 1：設定成功/0：設定不要
* @attention 特になし
*/
int
getNTSSPacketInfoMainteDate( u_char *cFolder
                           , struct NTSS_PACKET_INFORMATION *info
                           )
{
    int ret = 0;
    struct NTSS_MACHINE_MAINTE_DATE_INFORMATION mainteInfo;
    u_char clog[ NTSS_STR_MAX_SIZE ];
    u_char cMainteFile[ NTSS_STR_MAX_SIZE ];
    u_char cbuff[ 20 ];


    FILE *fp;

    // 装置通信方式判定
    if( info->cCommType == NTSS_COMM_TYPE_NEW )
    {
        // 装置が新通信の場合
        
        // 型式コード[3]、通信フォーマット[1]、製造番号[8]を取得
        memset( cbuff, 0, sizeof( cbuff ));
        memmove( cbuff, info->cDeviceType, sizeof( info->cDeviceType ) + sizeof( info->cDeviceFormat ) + sizeof( info->cDeviceNo ));

        // 自己診断実施日時ファイル名作成
        sprintf(
              cMainteFile
            , "%sMNT/%s.MNT"
            , cFolder
            , cbuff
        );

        // ファイル存在確認
        if( existFolderFile( cMainteFile, NULL ) == 1 )
        {
            // ファイルあり

            // ファイル読み込み
            if (( fp = fopen( cMainteFile, "rb" )) != NULL )
            {
                // 設定読み込み
                if( fread( &mainteInfo, sizeof( mainteInfo ), 1, fp ) == 1 )
                {
                    // 自己診断実施日付を設定
                    memmove( info->cMainteBCD[0], mainteInfo.cMainteBCD, sizeof( mainteInfo ));

                    sprintf( 
                          clog
                        , "新装置自己診断実施日時読み込み,装置:%s, %s"
                        , cbuff
                        , cMainteFile
                    );
                    outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, info );

                    // debug
                    printf( "%s\n", clog );

                    ret = 1;
                }

                fclose( fp );	
            }
        }
    }

    return ret;
}
/**
* @brief 指定したNTSSパケット管理情報の自己診断実施日時をファイルに出力する
*
* @details 指定したNTSSパケット管理情報の自己診断実施日時をファイルに出力する
*
* @description
* @param[in] *cFolder   ファイル格納先フォルダ
* @param[in] *info      対象とするNTSSパケット管理情報
* @return 1：出力成功/else：出力失敗
* @attention 特になし
*/
extern int
outputNTSSPacketInfoMainteDate( u_char *cFolder
                              , struct NTSS_PACKET_INFORMATION *info
                              )
{
    int ret = 0;
    u_char clog[ NTSS_STR_MAX_SIZE ];
    u_char cMainteFolder[ NTSS_STR_MAX_SIZE ];
    u_char cMainteFile[ NTSS_STR_MAX_SIZE ];
    u_char cbuff[ 20 ];


    FILE *fp;

    // 装置通信方式判定
    if( info->cCommType == NTSS_COMM_TYPE_NEW )
    {
        // 装置が新通信の場合
                
        // 型式コード[3]、通信フォーマット[1]、製造番号[8]を取得
        memset( cbuff, 0, sizeof( cbuff ));
        memmove( cbuff, info->cDeviceType, sizeof( info->cDeviceType ) + sizeof( info->cDeviceFormat ) + sizeof( info->cDeviceNo ));

        // 自己診断実施日時ファイル格納先フォルダ作成
        sprintf( 
              cMainteFolder
            , "%sMNT"
            , cFolder
        );

        // 自己診断実施日時ファイル名作成
        sprintf(
              cMainteFile
            , "%s/%s.MNT"
            , cMainteFolder
            , cbuff
        );

        // フォルダ確認
        if( existFolderFile( cMainteFolder, NULL) == 0 )
        {
            // フォルダなし

            // 格納フォルダ作成
            if( createFolder( cMainteFolder ) == 1 )
            {
                // 作成成功
                sprintf( 
                      clog
                    , "新装置自己診断実施日時書き込み先フォルダ作成,%s"
                    , cMainteFolder
                );
                outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, info );
            }
            else
            {
                // 作成失敗
                sprintf( 
                      clog
                    , "新装置自己診断実施日時書き込み先フォルダ作成失敗,%s"
                    , cMainteFolder
                );
                outputNTSSPacketInfoLog( NTSS_LOG_ERROR, clog, 1, info );
            }
        }

        // ファイル出力
        if( ret = outputFile(
              cMainteFile                   // 作成するファイル名
            , info->cMainteBCD[0]           // 記録するデータ
            , sizeof( info->cMainteBCD )    // 記録するデータ長
        ) == 1 )
        {
            // 出力成功
            sprintf( 
                    clog
                , "新装置自己診断実施日時書き込み,装置:%s, %s"
                , cbuff
                , cMainteFile
            );
            outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 1, info );
        }
        else
        {
            // 出力失敗
            sprintf( 
                    clog
                , "新装置自己診断実施日時書き込み失敗,装置:%s, %s"
                , cbuff
                , cMainteFile
            );
            outputNTSSPacketInfoLog( NTSS_LOG_ERROR, clog, 1, info );
        }
        // debug
        printf( "%s\n", clog );
    }

    return ret;
}


/**
* @brief パケット管理情報の接続状態確認を行う
*
* @details パケット管理情報の接続状態確認を行う
*
* @description
* @param[in]        nInterval    処理間隔
* @param[in/out]    LastDateTime 前回実施日時(処理後に更新される)
* @return 0:接続状態に変化なし/1:接続状態に変化あり
* @attention 特になし
*/
int
checkNTSSPacketInfoConnectionStatus( int nInterval
                                   , time_t *LastDateTime 
                                   )
{
    int ret = 0;
    u_char clog[ NTSS_STR_MAX_SIZE ];
    u_char cbuff[ 20 ];
    struct NTSS_PACKET_INFORMATION *info;
    time_t now;

    // 現在日時取得
    time( &now );

    // 前回実施日時から処理間隔が経過しているかどうか
    if(( *LastDateTime + nInterval ) <= now )
    {
        // 経過している場合

        // 前回実施日時を更新
        *LastDateTime = now;

        // debug
        struct tm tmnow;
        localtime_r( &now, &tmnow );
        printf(" 装置死活監視実施 ( %04d/%02d/%02d %02d:%02d:%02d )\n",
              tmnow.tm_year+1900
            , tmnow.tm_mon + 1
            , tmnow.tm_mday
            , tmnow.tm_hour
            , tmnow.tm_min
            , tmnow.tm_sec
        );

        // 配列分検索
        int intlop;
        for( intlop = 0; intlop < NTSS_PACKET_INFORMATION_COUNT; intlop++ )
        {
            info = &packetInfoList[intlop];

            // 設定確認
            if( info->sourceAddr != 0  )
            {
                // 設定が有効な場合

                // 接続状態を判定
                u_char cstatus = 0x00;
                if( now <= ( info->buffer.lastReceiveTime.tv_sec + nInterval ))
                {
                    // 最終受信日時から設定間隔の間に送受信が行われてる場合(接続中と判定)
                    cstatus = 0x01;
                }

                // 接続状態の変更を判定(全装置指定の場合も含む)
                if( info->isConnected != cstatus )
                {
                    // 変化あり
                    ret = 1;

                    // 変化内容
                    if( cstatus == 0x00 )
                    {
                        // 切断検出

                        // 型式コード[3]、通信フォーマット[1]、製造番号[8]を取得
                        memset( cbuff, 0, sizeof( cbuff ));
                        memmove( cbuff, info->cDeviceType, sizeof( info->cDeviceType ) + sizeof( info->cDeviceFormat ) + sizeof( info->cDeviceNo ));

                        // ログ記録
                        // 
                        sprintf(
                            clog
                            , "装置死活監視:%s,%s検出"
                            , cbuff
                            , "未接続"
                        );
                        outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, info );
                        printf( "%s\n", clog );
                        
                        // パケット管理情報初期化
                        finNTSSPacketInfo( info );
                    }
                }
            }
        }
    }

    return ret;
}

/**
* @brief パケット管理情報のモニタデータの工程変化の確認を行う
*
* @details パケット管理情報のモニタデータの工程変化の確認を行う
*
* @description
* @param[in]        nInterval           処理間隔
* @param[in/out]    LastDateTime        前回実施日時(処理後に更新される)
* @param[in]        cOutputSendObject   出力対象[0x00：変更分のみ/0x01：すべて]
* @return 0:接続状態に変化なし/1:接続状態に変化あり
* @attention 特になし
*/
int
checkNTSSPacketInfoMonitorProcess( int nInterval
                                 , time_t *LastDateTime 
                                 , u_char cOutputObject
                                 )
{
    int ret = 0;
    u_char clog[ NTSS_STR_MAX_SIZE ];
    u_char cbuff[ 20 ];
    u_char cfile[ 1024 * 2 ];
    struct NTSS_PACKET_INFORMATION *info;
    // #12553 2026.03.02 mod FW7に伴う2038年問題対応 TDC高村 start
    struct timeval tv;
    struct timespec now;
    // #12553 2026.03.02 mod FW7に伴う2038年問題対応 TDC高村 end
    char str1[1024];

    // 現在日時時刻取得(マイクロ秒含む)
    // #12553 2026.03.02 mod FW7に伴う2038年問題対応 TDC高村 start
    //gettimeofday( &now, NULL );
    clock_gettime(CLOCK_REALTIME, &now);
    tv.tv_sec = now.tv_sec;
    tv.tv_usec = now.tv_nsec / 1000;
    // #12553 2026.03.02 mod FW7に伴う2038年問題対応 TDC高村 end

    // 前回実施日時から処理間隔が経過しているかどうか
    if(( *LastDateTime + nInterval ) <= now.tv_sec )
    {
        // 経過している場合

        // 前回実施日時を更新
        *LastDateTime = now.tv_sec;

        //
        memset( cfile, 0, sizeof( cfile ));

        // debug
        struct tm tmnow;
        localtime_r( &now.tv_sec, &tmnow );
        printf(" 工程変化監視実施 ( %04d/%02d/%02d %02d:%02d:%02d )\n",
              tmnow.tm_year+1900
            , tmnow.tm_mon + 1
            , tmnow.tm_mday
            , tmnow.tm_hour
            , tmnow.tm_min
            , tmnow.tm_sec
        );

        // 配列分検索
        int intlop;
        for( intlop = 0; intlop < NTSS_PACKET_INFORMATION_COUNT; intlop++ )
        {
            info = &packetInfoList[intlop];

            // 設定確認
            if( info->sourceAddr != 0  )
            {
                // 設定が有効な場合

                // 通知状態判定
                if( info->isNeedSendProcess == 0x01
                  || cOutputObject == 0x01 )
                {
                    sprintf(
                        str1
                        , "[gs debug] 装置工程監視: info->isNeedSendProcess = %d,  cOutputObject = %d, isConnected = %d, info->nMoniDataSize = %d, info->nProcess[0] = %d, info->nProcess[1] = %d"
                        , info->isNeedSendProcess
                        , cOutputObject
                        , info->isConnected
                        , info->nMoniDataSize
                        , info->nProcess[0]
                        , info->nProcess[1]
                        );
                    outputNTSSPacketInfoLog( NTSS_LOG_INFO, str1, 0, info );
                    
                    // 通知する必要がある場合、又はすべての要求があった場合

                    ret = 1;

                    // 型式コード[3]、通信フォーマット[1]、製造番号[8]を取得
                    memset( cbuff, 0, sizeof( cbuff ));
                    memmove( cbuff, info->cDeviceType, sizeof( info->cDeviceType ) + sizeof( info->cDeviceFormat ) + sizeof( info->cDeviceNo ));

                    //　通知する工程[99:通信異常]
                    u_char nprocess[] = "99\0";  
                    
                    // 通知する工程を取得する
                    // mod FNSI-バグ 通信サーバ 高 start
                    // if( info->isConnected == 0x01 && 0 < info->nMoniDataSize )
                    if( (info->isConnected == 0x01 && 0 < info->nMoniDataSize ) || ( info->conflg == 0 && info->force_flg == 1 ) )
                    // mod FNSI-バグ 通信サーバ 高 end
                    {
                        // 通信中でモニタデータがある場合

                        // 装置バージョン取得
                        u_char cVersion[] = "00\0";
                        if( info->cCommType == NTSS_COMM_TYPE_NX )
                        {
                            // NX通信の場合

                            // 装置バージョンを文字列化
                            sprintf(
                                  cVersion
                                , "%02x"
                                , info->cMoniData[3]
                            );
                        }

                        // 登録用工程番号を取得する
                        ntss_mst_proc_dbno(
                              info->cDeviceFormat   // 通信フォーマット
                            , cVersion              // 装置バージョン
                            , info->nProcess[0]     // 工程番号
                            , nprocess              // DBへ登楼する工程コード
                        );

                        // ログ記録
                        sprintf(
                            clog
                            , "装置工程監視:%s,旧工程,%d,新工程,%d,(%s)"
                            , cbuff
                            , info->nProcess[1]
                            , info->nProcess[0]
                            , nprocess
                        );

                        // 現工程を保持する
                        info->nProcess[1] = info->nProcess[0];
                    }
                    else if( info->cCommType == NTSS_COMM_TYPE_NON )
                    {
                        // 設定された工程をセットする
                        sprintf(
                              nprocess
                            , "%02d"
                            , info->nProcess[0]
                        );

                        // ログ記録
                        sprintf(
                            clog
                            , "装置工程監視:%s,オフライン,(%s)"
                            , cbuff
                            , nprocess
                        );
                    }
                    else
                    {
                        // 未通信、又はモニタデータを受信していない場合

                        // ログ記録
                        sprintf(
                            clog
                            , "装置工程監視:%s,未通信,(%s)"
                            , cbuff
                            , nprocess
                        );
                    }
                    outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, info );
                    printf( "%s\n", clog );

                    // 工程通知を完了とする
                    info->isNeedSendProcess = 0x00;

                    // 通知する

                    // 装置工程報作成
                    sprintf( 
                        clog
                        , "%s%s"
                        , cbuff
                        , nprocess
                    );
                    strcat( cfile, clog );
                }
            }
        }

        // 
        if( ret == 1 && 0 < strlen(cfile) )
        {
            // add AWSとDEの通信断からの復旧 高 start
            if ( getCommAliveState() == 0 ) {
            // add AWSとDEの通信断からの復旧 高 end
                // 装置工程ファイル作成
                ret = outputNTSSDataFile(
                      NULL
                    , 0x00          // 緊急発報格納先
                    , NULL
                    , "M_ALIVE"     // 先頭ファイル名
                    , ".TXT"        // 拡張子
                    // #12553 2026.03.02 mod FW7に伴う2038年問題対応 TDC高村 start
                    //, &now          // 日付時刻
                    , &tv           // 日付時刻
                    // #12553 2026.03.02 mod FW7に伴う2038年問題対応 TDC高村 end
                    , cfile         // 書き込みデータ
                    , strlen(cfile) // 書き込みデータ長
                );
            }
        }
    }

    return ret;
}

/**
* @brief パケット管理情報のモニタデータのファイル出力を行う
*　通信中でモニタデータがあるもののみ対象
*
* @details パケット管理情報のモニタデータのファイル出力を行う
*
* @description
* @param[in]        nInterval           処理間隔
* @param[in/out]    LastDateTime        前回実施日時(処理後に更新される)
* @param[in]        cOutputSendObject   出力対象[0x00：未透析分/0x01：透析中分]
* @param[in]        nRealInterval       リアルタイム処理間隔
* @param[in/out]    RealLastDateTime    リアルタイム前回実施日時(処理後に更新される)
* @return 0:接続状態に変化なし/1:接続状態に変化あり
* @attention 特になし
*/
int
// mod 治療記録用データと治療状況用データの登録先を振分けにする 高 start
// checkNTSSPacketInfoMonitorData( int nInterval
//                               , time_t *LastDateTime 
//                               , u_char cOutputObject
//                               , int nRealTime
//                               )
checkNTSSPacketInfoMonitorData( int nInterval
                              , time_t *LastDateTime 
                              , u_char cOutputObject
                              , int nRealInterval
                              , time_t *RealLastDateTime
                              )
// mod 治療記録用データと治療状況用データの登録先を振分けにする 高 end
{
    int ret = 0;
    u_char clog[ NTSS_STR_MAX_SIZE ];
    u_char cbuff[ 20 ];
    struct NTSS_PACKET_INFORMATION *info;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //struct timeval now;
    struct timespec now;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    // add 治療記録用データと治療状況用データの登録先を振分けにする 高 start
    bool bRealTimeFlag = false;
    bool bMoniTimeFlag = false;
    // add 治療記録用データと治療状況用データの登録先を振分けにする 高 end

    // 現在日時時刻取得(マイクロ秒含む)
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //gettimeofday( &now, NULL );
    clock_gettime(CLOCK_REALTIME, &now);
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

    // 前回実施日時から1秒が経過しているかどうか
    // mod 治療記録用データと治療状況用データの登録先を振分けにする 高 start
    // if(( *LastDateTime + 1 ) <= now.tv_sec )
    if(( *LastDateTime + 1 ) <= now.tv_sec  || ( *RealLastDateTime + 1 ) <= now.tv_sec)
    // mod 治療記録用データと治療状況用データの登録先を振分けにする 高 end
    {
        // 経過している場合

        // 前回実施日時を更新
        // mod 治療記録用データと治療状況用データの登録先を振分けにする 高 start
        // *LastDateTime = now.tv_sec;
        if(( *LastDateTime + 1 ) <= now.tv_sec ) {
            *LastDateTime = now.tv_sec;
        }
        if(( *RealLastDateTime + 1 ) <= now.tv_sec ) {
            *RealLastDateTime = now.tv_sec;
        }
        // mod 治療記録用データと治療状況用データの登録先を振分けにする 高 end

        // // debug
        // struct tm tmnow;
        // localtime_r( &now.tv_sec, &tmnow );
        // printf(" モニタデータ定期出力実施[%d] ( %04d/%02d/%02d %02d:%02d:%02d )\n",
        //       cOutputObject
        //     , tmnow.tm_year+1900
        //     , tmnow.tm_mon + 1
        //     , tmnow.tm_mday
        //     , tmnow.tm_hour
        //     , tmnow.tm_min
        //     , tmnow.tm_sec
        // );

        // 配列分検索
        int intlop;
        for( intlop = 0; intlop < NTSS_PACKET_INFORMATION_COUNT; intlop++ )
        {
            info = &packetInfoList[intlop];

            // 設定確認
            if( info->sourceAddr != 0  )
            {
                // 設定が有効な場合

                // 通知状態判定
                if( info->isConnected == 0x01
                  && 0 < info->nMoniDataSize
                  && info->isMoniOutput == 0x00 )
                {
                    // 通信中でモニタデータがあり未出力である場合

                    ret = 1;

                    // 出力形式判定
                    u_char cflag = 0x00;
                    u_char *kind;
                    // add 治療記録用データと治療状況用データの登録先を振分けにする 高 start
                    bMoniTimeFlag = false;
                    bRealTimeFlag = false;
                    // add 治療記録用データと治療状況用データの登録先を振分けにする 高 end
                    if( cOutputObject ==  0x00
                      && info->isDialysis[0] == cOutputObject )
                    {
                        // 未透析

                        // モニタ出力判定
                        if(( info->moniOutputTime + nInterval ) <= now.tv_sec )
                        {
                            cflag = 0x01;
                            kind = "未透析";
                            // add 治療記録用データと治療状況用データの登録先を振分けにする 高 start
                            bMoniTimeFlag = true;
                            // add 治療記録用データと治療状況用データの登録先を振分けにする 高 end
                        }
                    }
                    else if( cOutputObject == 0x01
                      && info->isDialysis[0] == cOutputObject )
                    {
                        // 透析中

                        // モニタ出力判定
                        if(( info->moniOutputTime + nInterval ) <= now.tv_sec )
                        {
                            cflag = 0x01;
                            kind = "透析中";
                            // add 治療記録用データと治療状況用データの登録先を振分けにする 高 start
                            bMoniTimeFlag = true;
                            // add 治療記録用データと治療状況用データの登録先を振分けにする 高 end
                        }
                    }
                    
                    // add 治療記録用データと治療状況用データの登録先を振分けにする 高 start
                    if( cOutputObject ==  0x00
                      && info->isDialysis[0] == cOutputObject )
                    {
                        // 未透析

                        // モニタ出力判定
                        if(( info->realMoniOutputTime + nRealInterval ) <= now.tv_sec )
                        {
                            cflag = 0x01;
                            kind = "未透析";
                            bRealTimeFlag = true;
                        }
                    }
                    else if( cOutputObject == 0x01
                      && info->isDialysis[0] == cOutputObject )
                    {
                        // 透析中

                        // モニタ出力判定
                        if(( info->realMoniOutputTime + nRealInterval ) <= now.tv_sec )
                        {
                            cflag = 0x01;
                            kind = "透析中";
                            bRealTimeFlag = true;
                        }
                    }
                    // add 治療記録用データと治療状況用データの登録先を振分けにする 高 end

                    // 出力判定
                    if( cflag == 0x01 )
                    {
                        // モニタ出力日時更新
                        // mod 治療記録用データと治療状況用データの登録先を振分けにする 高 start
                        // info->moniOutputTime = now.tv_sec;
                        if( bMoniTimeFlag == true )
                            info->moniOutputTime = now.tv_sec;
                        if( bRealTimeFlag == true )
                            info->realMoniOutputTime = now.tv_sec;
                        // mod 治療記録用データと治療状況用データの登録先を振分けにする 高 end

                        // 型式コード[3]、通信フォーマット[1]、製造番号[8]を取得
                        memset( cbuff, 0, sizeof( cbuff ));
                        memmove( cbuff, info->cDeviceType, sizeof( info->cDeviceType ) + sizeof( info->cDeviceFormat ) + sizeof( info->cDeviceNo ));
                        // 末尾の空白を除去
                        trimEnd( cbuff, ' ' );

                        // ログ記録
                        sprintf(
                              clog
                            , "%sモニタ出力,装置:%s"
                            , kind
                            , cbuff
                        );
                        outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, info );

                        if( info->cCommType == NTSS_COMM_TYPE_COMMON )
                        {
                            // 通信共通プロトコルV3、V4

                            // モニタ保存ファイル名、出力データを取得
                            u_char cFile[NTSS_STR_MAX_SIZE];
                            u_char cText[ 1024 ];
                            
                            // mod 治療記録用データと治療状況用データの登録先を振分けにする 高 start
                            if( bMoniTimeFlag == true )
                            {
                                getNTSSCommonMonitorDataFile(
                                      info
                                    , cFile
                                    , cText
                                    , "C-MON"
                                );

                                // モニタデータ出力
                                outputAppendNTSSDataFile(
                                      info              // パケット管理情報
                                    , 0x01              // データ収集格納先
                                    , cFile             // 先頭ファイル名(collect)
                                    , "_comm.txt"       // 拡張子
                                    , &(info->dtMoni)   // 日付時刻
                                    , cText             // 書き込みデータ
                                    , strlen(cText)     // 書き込みデータ長
                                );
                            }
                            
                            // リアルタイム登録
                            if( bRealTimeFlag == true )
                            {
                                getNTSSCommonMonitorDataFile(
                                      info
                                    , cFile
                                    , cText
                                    , "C-RMN"
                                );
                                
                                // add AWSとDEの通信断からの復旧 高 start
                                if ( getCommAliveState() == 0 ) {
                                // add AWSとDEの通信断からの復旧 高 end
                                    // モニタデータ出力
                                    outputAppendNTSSDataFile(
                                          info              // パケット管理情報
                                        , 0x01              // データ収集格納先
                                        , cFile             // 先頭ファイル名(collect)
                                        , "_comm.txt"       // 拡張子
                                        , &(info->dtMoni)   // 日付時刻
                                        , cText             // 書き込みデータ
                                        , strlen(cText)     // 書き込みデータ長
                                    );
                                }
                            }
                            // mod 治療記録用データと治療状況用データの登録先を振分けにする 高 end
                        }
                        else
                        {
                            // 日機装装置(NX通信含む)

                            // モニタデータ出力
                            // mod 治療記録用データと治療状況用データの登録先を振分けにする 高 start
                            if( bMoniTimeFlag == true )
                            {
                                ret = outputNTSSDataFile(
                                    info
                                    , 0x01
                                    , "MON"
                                    , NULL
                                    , NULL
                                    , &(info->dtMoni)
                                    , info->cMoniData
                                    , info->nMoniDataSize
                                );
                            }
                            
                            // リアルタイム登録
                            if( bRealTimeFlag == true )
                            {
                                // add AWSとDEの通信断からの復旧 高 start
                                if ( getCommAliveState() == 0 ) {
                                // add AWSとDEの通信断からの復旧 高 end
                                    ret = outputNTSSDataFile(
                                        info
                                        , 0x01
                                        , "RMN"
                                        , NULL
                                        , NULL
                                        , &(info->dtMoni)
                                        , info->cMoniData
                                        , info->nMoniDataSize
                                    );
                                }
                            }
                            // mod 治療記録用データと治療状況用データの登録先を振分けにする 高 end
                        }

                        // モニタデータ出力済みとする
                        info->isMoniOutput = 0x01;

                        // モニタ更新フラグを許可
                        info->isStopUpMoniData = 0x00;
                    }
                }
            }
        }
    }

    return ret;
}


/**
* @brief パケット管理情報のログ出力を行う
*
* @details パケット管理情報のログ出力を行う
*
* @description
* @param[in] type   種別コード
* @param[in] *msg   ログメッセージ
* @param[in] flag   出力フラフ（0:通常,1:システム情報有り）
* @param[in] *info  パケット管理情報
* @return なし
* @attention 特になし
*/
void
outputNTSSPacketInfoLog( NtssLogType type
                       , u_char *msg 
                       , int flag
                       , struct NTSS_PACKET_INFORMATION *info
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
* @brief パケット管理情報のログ出力を行う
*
* @details パケット管理情報のログ出力を行う
*
* @description
* @param[in] type   種別コード
* @param[in] *msg   ログメッセージ
* @param[in] flag   出力フラフ（0:通常,1:システム情報有り）
* @param[in] *info  パケット管理情報
* @return なし
* @attention 特になし
*/
void
outputNTSSPacketInfoErrorLog( u_char *msg 
                            , struct NTSS_PACKET_INFORMATION *info
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

/**
* @brief パケット管理情報のホスト報知設定の初期化を行う
*
* @details パケット管理情報のホスト報知設定の初期化を行う
*
* @description
* @param[in] *info  パケット管理情報
* @return なし
* @attention 特になし
*/
void
initNTSSHostWatchConf( struct NTSS_PACKET_INFORMATION *info 
                         )
{
    // 監視開始待ち時間を初期化
    info->watchWaitTime = -1;
    memset( info->watch, 0, sizeof(info->watch));

    // // DEBUG
    // info->watchWaitTime = 0;
    // setNTSSHostWatchConf( info, 90, 100, 80, 1);    // 最高血圧
    // setNTSSHostWatchConf( info, 91, 100, 80, 1);    // 最低血圧
    // setNTSSHostWatchConf( info, 92, 100, 80, 1);    // 平均血圧
    // setNTSSHostWatchConf( info, 93, 100, 60, 1);    // 脈拍
    // setNTSSHostWatchConf( info, 8, 100, 50, 1);     // 血流量
    // setNTSSHostWatchConf( info, 10, 100, 50, 1);    // IP速度
    // setNTSSHostWatchConf( info, 6, 100, 50, 1);     // 除水速度
    // setNTSSHostWatchConf( info, 11, 100, -50, 1);   // 静脈圧
    // setNTSSHostWatchConf( info, 14, 100, -50, 1);   // 動脈圧
    // setNTSSHostWatchConf( info, 20, 100, 50, 1);    // Na濃度
    // setNTSSHostWatchConf( info, 21, 400, 350, 1);   // 透析液温度
    // setNTSSHostWatchConf( info, 80, 100, -50, 1);   // ΔBV変化率
    // setNTSSHostWatchConf( info, 102, 100, 50, 1);   // LDQB

    // setNTSSHostWatchMachineState( info, 90, 0 );
    // setNTSSHostWatchMachineState( info, 91, 0 );
    // setNTSSHostWatchMachineState( info, 92, 0 );
    // setNTSSHostWatchMachineState( info, 93, 0 );
    // setNTSSHostWatchMachineState( info, 8,  2 );
    // setNTSSHostWatchMachineState( info, 10, 2 );
    // setNTSSHostWatchMachineState( info, 6,  2 );
    // setNTSSHostWatchMachineState( info, 11, 2 );
    // setNTSSHostWatchMachineState( info, 14, 2 );
    // setNTSSHostWatchMachineState( info, 20, 2 );
    // setNTSSHostWatchMachineState( info, 21, 2 );
    // setNTSSHostWatchMachineState( info, 80, 2 );
    // setNTSSHostWatchMachineState( info, 102, 2 );
}
/**
* @brief パケット管理情報のホスト報知設定を設定する
*
* @details パケット管理情報のホスト報知設定を設定する
*
* @description
* @param[in] *info      パケット管理情報
* @param[in] nMoniNo    モニタ項目番号[0〜]
* @param[in] upper      下限値
* @param[in] lower      上限値
* @param[in] cEnable    監視有効/無効[0x00：無効/0x01有効]
* @return 1：設定成功/0：設定不要(設定なし含む)
* @attention 特になし
*/
int
setNTSSHostWatchConf( struct NTSS_PACKET_INFORMATION *info 
                        , int nMoniNo
                        , short upper
                        , short lower
                        , u_char cEnable
                        )
{
    int ret = 0;
    u_char clog[ NTSS_STR_MAX_SIZE ];

    // ホスト報知設定確認
    int nIdx = findNTSSHostWatchInfoIndex( info, nMoniNo );
    if( nIdx )
    {
        // 空き検索

        // ホスト報知配列分
        int intlop;
        for( intlop = 0; 0 <= nMoniNo && intlop < NTSS_HOST_WATCH_COUNT; intlop++ )
        {   
            if( info->watch[intlop].moniNo == 0 )
            {
                nIdx = intlop;
            }
        }
    }

    // ホスト報知配列番号判定
    if( 0 <= nIdx )
    {
        ret = 1;

        // ホスト報知設定
        struct NTSS_HOST_WATCH *host = &(info->watch[nIdx]);

        // モニタ項目番号
        host->moniNo = nMoniNo + 1;
        // 下限値
        host->lowerAlerm = lower;
        // 上限値
        host->upperAlerm = upper;
        // ホスト報知監視有効/無効
        host->cWatchAlarmEnable = cEnable;
        // 発生状態[クリア]
        host->cAlarmOccurrenceStatus[0] = 0xff;
        host->cAlarmOccurrenceStatus[1] = 0x00;

        // ログ記録
        sprintf(
            clog
            , "ホスト報知設定(モニタ項目番号 / 下限値 / 上限値 / 監視状態), (%03d / %d / %d /%d)"
            , host->moniNo - 1
            , host->lowerAlerm
            , host->upperAlerm
            , host->cWatchAlarmEnable
        );
        outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, info );
    }
    else 
    {
        // ログ記録
        sprintf(
            clog
            , "ホスト報知設定不可(モニタ項目番号 / 下限値 / 上限値 / 監視状態), (%03d / %d / %d /%d)"
            , nMoniNo - 1
            , lower
            , upper
            , cEnable
        );
        outputNTSSPacketInfoLog( NTSS_LOG_ERROR, clog, 0, info );
    }
    return ret;
}
/**
* @brief パケット管理情報のホスト報知設定の装置警報監視状態を設定する
*
* @details パケット管理情報のホスト報知設定の装置警報監視状態を設定する
*
* @description
* @param[in] *info          パケット管理情報
* @param[in] nMoniNo        モニタ項目番号[0〜]
* @param[in] cMachineState  装置警報監視状態[0x00：監視しない/0x01：固定監視/0x02：自動監視-ホスト報知可]
* @return 1：設定成功/0：設定不要(設定なし含む)
* @attention 特になし
*/
int
setNTSSHostWatchMachineState( struct NTSS_PACKET_INFORMATION *info 
                                , int nMoniNo
                                , u_char cMachineState
                                )
{
    int ret = 0;
    u_char clog[ NTSS_STR_MAX_SIZE ];

    // ホスト報知設定確認
    int nIdx = findNTSSHostWatchInfoIndex( info, nMoniNo );

    // ホスト報知配列番号判定
    if( 0 <= nIdx )
    {
        ret = 1;
        
        // ホスト報知設定
        struct NTSS_HOST_WATCH *host = &(info->watch[nIdx]);

        // ログ記録
        sprintf(
            clog
            , "ホスト報知 装置警報監視状態変更(モニタ項目番号 / 変更前 → 変更後), (%03d / %d → %d)"
            , host->moniNo - 1
            , host->cWatchMachineState
            , cMachineState
        );
        outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, info );

        // 装置警報監視状態
        host->cWatchMachineState = cMachineState;
    }
    return ret;
}


/**
* @brief パケット管理情報でホスト報知設定から指定したモニタ項目の配列番号を取得する
* @details パケット管理情報でホスト報知設定から指定したモニタ項目の配列番号を取得する
*
* @description
* @param[in] *info      パケット管理情報
* @param[in] nMoniNo    モニタ項目番号[0〜]
* @return -1：合致なし/0〜：ホスト報知配列番号
* @attention 特になし
*/
int
findNTSSHostWatchInfoIndex( struct NTSS_PACKET_INFORMATION *info
                      , int nMoniNo
                      )
{
    int ret = -1;
    int intlop;

    // ホスト報知配列分
    for( intlop = 0; 0 <= nMoniNo && intlop < NTSS_HOST_WATCH_COUNT; intlop++ )
    {
        // モニタ項目番号が一致するものを検索
        if( info->watch[intlop].moniNo == (nMoniNo + 1))
        {
            // 配列番号を返す
            ret = intlop;
            break;
        }
    }
    return ret;
}

/**
* @brief パケット管理情報で指定した配列番号のホスト報知判定を行うかどうか
*
* @details パケット管理情報で指定した配列番号のホスト報知判定を行うかどうか
*
* @description
* @param[in] *info      パケット管理情報
* @param[in] nIdx       ホスト報知配列番号
* @return 0：未実施/1：実施
* @attention 特になし
*/
int
isWatchNTSSAlarmInfo(struct NTSS_PACKET_INFORMATION *info
                    , int nIdx
                    )
{
    int ret = 0;
    
    // 配列範囲チェク
    if( 0<= nIdx && nIdx < NTSS_HOST_WATCH_COUNT )
    {
        struct NTSS_HOST_WATCH *host = &(info->watch[nIdx]);

        // 通信方式判定
        if( info->cCommType == NTSS_COMM_TYPE_COMMON ) 
        {
            // 通信共通プロトコル

            // ホスト報知が有効であれば判定実施
            ret = (int)(host->cWatchAlarmEnable);
        }
        else
        {
            // 日機装プロトコル

            // ホスト報知が有効で
            // 装置警報監視状態が「2：自動監視-ホスト報知可」または 血圧、脈拍の場合
            if( host->cWatchAlarmEnable == 0x01
            && ( host->cWatchMachineState == 0x02 
            || host->moniNo == 91    // 最高血圧
            || host->moniNo == 92    // 最低血圧
            || host->moniNo == 93    // 平均血圧
            || host->moniNo == 94    // 脈拍
            ))
            {
                // 判定実施
                ret = 1;
            }
        }
    }

    return ret;
}

/**
* @brief パケット管理情報でホスト報知発生チェックを行う
*
* @details パケット管理情報でホスト報知発生チェックを行う
*
* @description
* @param[in] *info      パケット管理情報
* @param[in] now        チェック実施日時
* @param[in] nMoniNo    モニタ項目番号[0〜]
* @param[in] nowData    今回値
* @return 1：発生中あり/0：発生中なし(設定なし含む)
* @attention 特になし
*/
int
checkNTSSHostWatchInfo( struct NTSS_PACKET_INFORMATION *info
                      , struct timeval now
                      , int nMoniNo
                      , short nowData
                      )
{
    int ret = 0;
    u_char clog[ NTSS_STR_MAX_SIZE ];

    // 警報/注意発生フラグ初期化
    char calarm = 0;

    // 指定したモニタ項目番号からホスト報知設定のIndexを取得
    int nIdx = findNTSSHostWatchInfoIndex( info, nMoniNo );
    if( 0 <= nIdx )
    {
        // 設定あり

        // ホスト報知設定
        struct NTSS_HOST_WATCH *host = &(info->watch[nIdx]);

        // 測定値チェック(測定値が0x8000以外でモニタ項目80：ΔBV変化率が-1以外)
        if( nowData != SHRT_MIN
         && !( nMoniNo == 80 && nowData == -10 ))
        {
            // 測定値が有効な値

            // 指定したモニタ項目が監視対象かどうか
            if( isWatchNTSSAlarmInfo( info, nIdx ) == 1 )
            {
                // 監視対象
                
                // 上限値判定(設定値が有効、判定式が真のもの)
                if( host->upperAlerm != SHRT_MIN
                    && host->upperAlerm < nowData )
                {
                    // 上限発生
                    calarm |= 0x02;
                    // ログ記録
                    sprintf(
                        clog
                        , "ホスト報知：上限発生(モニタ項目番号 : 設定値 / 現在値), (%03d : %d / %d)"
                        , host->moniNo - 1
                        , host->upperAlerm
                        , nowData
                    );
                    outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, info );
                }

                // 下限値判定(設定値が有効、判定式が真のもの)
                if( host->lowerAlerm != SHRT_MIN
                    && nowData < host->lowerAlerm )
                {
                    // 下限発生
                    calarm |= 0x01;
                    // ログ記録
                    sprintf(
                        clog
                        , "ホスト報知：下限発生(モニタ項目番号 : 設定値 / 現在値), (%03d : %d / %d)"
                        , host->moniNo - 1
                        , host->lowerAlerm
                        , nowData
                    );
                    outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, info );
                }

                // 今回の警報発生状態を保持
                host->cAlarmOccurrenceStatus[0] = calarm;

                // 警報/注意発生中がある場合
                if( 0 < calarm )
                {
                    // 発生中あり
                    ret = 1;

                    printf( "Watch Monitor = moni_no:%d / %02x\n", nMoniNo, calarm );
                } else if(host->cAlarmOccurrenceStatus[0] != host->cAlarmOccurrenceStatus[1] ) {
                    // 発生中→消滅
                    // ログ記録
                    sprintf(
                        clog
                        , "ホスト報知：消滅(モニタ項目番号 : 設定値上限 / 設定値下限 / 現在値), (%03d : %d / %d / %d)"
                        , host->moniNo - 1
                        , host->upperAlerm
                        , host->lowerAlerm
                        , nowData
                    );
                    outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, info );

                    printf( "Watch Monitor = moni_no:%d / %02x\n", nMoniNo, calarm );
                }
            }
        }
    }

    return ret;
}

/**
* @brief パケット管理情報でホスト報知発生通知ファイルを出力する
*
* @details パケット管理情報でホスト報知発生通知チェックを行う
*
* @description
* @param[in] *info      パケット管理情報
* @param[in] now        チェック実施日時
* @return 1：発生中あり/0：発生中なし(設定なし含む)
* @attention 特になし
*/
void
outputNTSSHostWatchInfo( struct NTSS_PACKET_INFORMATION *info
                       , struct timeval now
                       )
{
    // 型式コード
    u_char cDeviceType[4];
    memmove( cDeviceType, info->cDeviceType, 3 );
    cDeviceType[3] = 0;

    // 製造番号
    u_char cDeviceNo[9];
    memmove( cDeviceNo, info->cDeviceNo, 8 );
    cDeviceNo[8] = 0;
    // 末尾の空白を除去
    trimEnd( cDeviceNo, ' ' );

    // ファイル名作成
    char cfile[NTSS_STR_MAX_SIZE];
    // ※ALART_[型式コード]_[製造番号]_[通信方式]_[通信フォーマット]_[作成年月日時分秒マイクロ秒].TXT
    sprintf(
            cfile
        , "ALART_%s_%s_%c_%c"
        , cDeviceType
        , cDeviceNo
        , info->cCommType
        , info->cDeviceFormat
    );

    //
    u_char cdata[ 1024 ];
    cdata[0] = 0x00;

    // 記録データ作成(モニタ項目番号[3桁]：状態[2桁HEX])
    int intlop;
    u_char cwork[10];
    for( intlop = 0; intlop < NTSS_HOST_WATCH_COUNT; intlop++ )
    {
        // ホスト報知設定
        struct NTSS_HOST_WATCH *host = &(info->watch[intlop]);

        // ホスト報知監視が有効でホスト報知判定を実施したかどうか
        if( isWatchNTSSAlarmInfo(info, intlop) == 1 && host->cAlarmOccurrenceStatus[0] != 0xff )
        {
            // 今回新たに発生したもののみを取得する
            u_char state = (host->cAlarmOccurrenceStatus[0] ^ host->cAlarmOccurrenceStatus[1] ) & host->cAlarmOccurrenceStatus[0];
            if( state != 0x00 )
            {
                sprintf(
                    cwork
                    , "%03d:%02x"
                    , host->moniNo - 1
                    , state
                );

                strcat( cdata, cwork );
            }
            
            // 発生状態を保持
            host->cAlarmOccurrenceStatus[1] = host->cAlarmOccurrenceStatus[0];

            // 今回の警報発生状態を初期化
            host->cAlarmOccurrenceStatus[0] = 0xff;

            // バイタル系の場合は発生状態を解除(最新値で常に判定するため)
            if( 91 <= host->moniNo 
                && host->moniNo <= 94 )
            {
                host->cAlarmOccurrenceStatus[1] = 0x00;
            }
        }
    }

    // 出力判定
    if( cdata[0] != 0x00 )
    {
        // add AWSとDEの通信断からの復旧 高 start
        if ( getCommAliveState() == 0 ) {
        // add AWSとDEの通信断からの復旧 高 end
            // 警報/注意通知ファイル作成
            outputAppendNTSSDataFile(
                info          // パケット管理情報
                , 0x00          // 緊急発報格納先
                , cfile         // 先頭ファイル名(ALART_[型式コード]_[製造番号]_[通信方式]_[通信フォーマット])
                , ".TXT"        // 拡張子
                , &now          // 日付時刻
                , cdata         // 書き込みデータ
                , strlen(cdata) // 書き込みデータ長
            );
        }
    }

    return;
}


/**
* @brief パケット管理情報で登録用装置情報ファイルを出力する
*
* @details パケット管理情報で登録用装置情報ファイルを出力する
*
* @description
* @param[in] *cFacilityCode 施設コード
* @param[in] nDeviceEdgeNo  デバイスエッジ番号
* @param[in] *info          パケット管理情報
* @param[in] now            受信日時
* @return なし
* @attention 特になし
*/
extern void
outputNTSSCreateMachineInfo( u_char *cFacilityCode
                           , short nDeviceEdgeNo
                           , struct NTSS_PACKET_INFORMATION *info
                           , struct timeval now
                           )
{
    // 製造番号
    u_char cDeviceNo[9];
    memmove( cDeviceNo, info->cDeviceNo, 8 );
    cDeviceNo[8] = 0;
    // 末尾の空白を除去
    trimEnd( cDeviceNo, ' ' );

    // ファイル名作成
    char cfile[NTSS_STR_MAX_SIZE];
    // ※collect_[製造番号]_[通信方式]_[通信フォーマット]_[作成年月日時分秒マイクロ秒]_add_dev.txt
    sprintf(
          cfile
        , "collect_%s_%c_%c"
        , cDeviceNo
        , info->cCommType
        , info->cDeviceFormat
    );

    u_char clog[ NTSS_STR_MAX_SIZE ];
    u_char cbuff[ NTSS_STR_MAX_SIZE ];
    struct in_addr inaddr;
    inaddr.s_addr = info->sourceAddr;

    // 保存データ作成
    sprintf( 
          cbuff
        , "kind=%s\tfacilitycode=%s\tedgeno=%d\tcommformat=%c\tserialno=%s\tcommtype=%c\tip=%s\n"
        , "ADD-DEV"
        , cFacilityCode
        , nDeviceEdgeNo
        , info->cDeviceFormat
        , cDeviceNo
        , info->cCommType
        , inet_ntoa(inaddr)
    );
    
    // 登録用装置情報ファイル作成
    outputAppendNTSSDataFile(
          info              // パケット管理情報
        , 0x01              // データ収集格納先
        , cfile             // 先頭ファイル名(collect)
        , "_add_dev.txt"    // 拡張子
        , &now              // 日付時刻
        , cbuff             // 書き込みデータ
        , strlen(cbuff)     // 書き込みデータ長
    );

    return;
}
//@}

