/**
* @brief NTSSデータ出力処理
*
* @details NTSSデータをファイルに出力
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_packet_file.c
* @author H.Yonezawa
* @date 2017/10/26
*/

#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <sys/time.h>
#include <string.h>
#include <stdbool.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include "ntss_packet_file.h"
#include "ntss_devicecap_conf.h"

#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/ntss_etc_lib.h"



/// @name ファイル出力関連
//@{
/**
* @brief 緊急発報用ファイル名を作成
*
* @details 緊急発報用電文ファイル名(拡張子なし)を作成する
*
* @description
* @param[in] deviceCommCd   通信方式[1桁]
* @param[in] *deviceType    型式コード[3桁]
* @param[in] *deviceFormat  通信フォーマット[1桁]
* @param[in] *deviceNo      製造番号[8桁]
* @param[in] *commId        通信コマンド識別子
* @param[in] receiveTime    受信日時
* @param[in] *folder        格納先フォルダ名
* @param[out] *fileName     保存ファイル名
* @return 1：作成成功/else：作成失敗
* @attention 特になし
*/
int
getNTSSM_NoticeFileName( u_char deviceCommCd
                       , u_char *deviceType
                       , u_char deviceFormat
                       , u_char *deviceNo
                       , u_char *commId
                       , struct timeval receiveTime
                       , u_char *folder
                       , u_char *fileName
                       )
{
    int ret = 0;
    FILE *fp;
    long tim;

    // フォルダ設定確認
    if( folder != NULL && 0 < strlen( folder ))
    {
        // 
        // 受信日時取得
        struct tm now;
        // #12553 2026.03.02 mod FW7に伴う2038年問題対応 TDC高村 start
        //localtime_r( &receiveTime.tv_sec, &now );
        struct timespec ts;
        ts.tv_sec = receiveTime.tv_sec;
        ts.tv_nsec = receiveTime.tv_usec * 1000;
        localtime_r( &ts.tv_sec, &now );
        // #12553 2026.03.02 mod FW7に伴う2038年問題対応 TDC高村 end
                
        // 型式コード
        u_char cDeviceType[4];
        memmove( cDeviceType, deviceType, 3);
        cDeviceType[3] = 0;
        // 製造番号
        u_char cDeviceNo[9];
        memmove( cDeviceNo, deviceNo, 8 );
        cDeviceNo[8] = 0;
        // 末尾の空白を除去
        trimEnd( cDeviceNo, ' ' );

        // ファイル名作成
        // ※[受信年月日時分秒マイクロ秒]_[型式コード]_[製造番号]_[通信方式]_[通信フォーマット]_[通信コマンド識別子]_ランダム文字列.bin
        sprintf(
              fileName
            , "%s%04d%02d%02d%02d%02d%02d%06ld_%s_%s_%c_%c_%s_XXXXXX"
            , folder
            , now.tm_year + 1900
            , now.tm_mon + 1
            , now.tm_mday
            , now.tm_hour
            , now.tm_min
            , now.tm_sec
            // #12553 2026.03.02 mod FW7に伴う2038年問題対応 TDC高村 start
            //, receiveTime.tv_usec
            , ts.tv_nsec / 1000
            // #12553 2026.03.02 mod FW7に伴う2038年問題対応 TDC高村 end
            , cDeviceType
            , cDeviceNo
            , deviceCommCd
            , deviceFormat
            , commId
        );


        // ファイル出力
        int fd = mkstemps( fileName, 0);
        fp = fdopen(fd, "w");
        if ( fp!=NULL )
        {
            fclose(fp);

            // ファイル削除
            if( remove( fileName ) == 0 )
            {
                ret = 1;
            }
        }
    }

    return ret;
}


/**
* @brief データ収集用FN通信ファイル名(拡張子なし)取得
*
* @details データ収集用FN通信対象コマンドファイル名を取得する
*
* @description
* @param[in] deviceCommCd   通信方式[1桁]
* @param[in] *deviceType    型式コード[3桁]
* @param[in] *deviceFormat  通信フォーマット[1桁]
* @param[in] *deviceNo      製造番号[8桁]
* @param[in] *commId        通信コマンド識別子
* @param[in] receiveTime    受信日時
* @param[in] *folder        格納先フォルダ名
* @param[out] *fileName     保存ファイル名
* @return 1：作成成功/else：作成失敗
* @attention 特になし
*/
int
getNTSSDataCollectPacketFileName( u_char deviceCommCd
                                , u_char *deviceType
                                , u_char deviceFormat
                                , u_char *deviceNo
                                , u_char *commId
                                , struct timeval receiveTime
                                , u_char *folder
                                , u_char *fileName
                                )
{
    int ret = 0;
    long tim;

    // フォルダ設定確認
    if( folder != NULL && 0 < strlen( folder ))
    {
        // 
        // 受信日時取得
        struct tm now;
        // #12553 2026.03.02 mod FW7に伴う2038年問題対応 TDC高村 start
        //localtime_r( &receiveTime.tv_sec, &now );
        struct timespec ts;
        ts.tv_sec = receiveTime.tv_sec;
        ts.tv_nsec = receiveTime.tv_usec * 1000;
        localtime_r( &ts.tv_sec, &now );
        // #12553 2026.03.02 mod FW7に伴う2038年問題対応 TDC高村 end

        // 型式コード
        u_char cDeviceType[4];
        memmove( cDeviceType, deviceType, 3);
        cDeviceType[3] = 0;
        // 製造番号
        u_char cDeviceNo[9];
        memmove( cDeviceNo, deviceNo, 8 );
        cDeviceNo[8] = 0;
        // 末尾の空白を除去
        trimEnd( cDeviceNo, ' ' );

        // ファイル名作成
        // ※[型式コード]_[製造番号]_[通信方式]_[通信フォーマット]_[通信コマンド識別子]_[受信年月日時分秒マイクロ秒].bin
        sprintf(
              fileName 
            , "%s%s_%s_%c_%c_%s_%04d%02d%02d%02d%02d%02d%06ld"
            , folder
            , cDeviceType
            , cDeviceNo
            , deviceCommCd
            , deviceFormat
            , commId
            , now.tm_year + 1900
            , now.tm_mon + 1
            , now.tm_mday
            , now.tm_hour
            , now.tm_min
            , now.tm_sec
            // #12553 2026.03.02 mod FW7に伴う2038年問題対応 TDC高村 start
            //, receiveTime.tv_usec
            , ts.tv_nsec / 1000
            // #12553 2026.03.02 mod FW7に伴う2038年問題対応 TDC高村 end
        );

        ret = 1;
    }

    return ret;    
}

/**
* @brief NTSS汎用ファイル名取得
*
* @details NTSS汎用ファイル名を取得する
*
* @description
* @param[in] cFirstFileName ファイル名先頭
* @param[in] cFileExtName   ファイル拡張子
* @param[in] makeTime       作成日時
* @param[in] *folder        格納先フォルダ名
* @param[out] *fileName     保存ファイル名
* @return 1：作成成功/else：作成失敗
* @attention 特になし
*/
int
getNTSSFileName( u_char *cFirstFileName
               , u_char *cFileExtName
               , struct timeval makeTime
               , u_char *folder
               , u_char *fileName
               )
{
    int ret = 0;
    long tim;

    // フォルダ設定確認
    if( folder != NULL && 0 < strlen( folder ))
    {
        // 
        // 受信日時取得
        struct tm now;
        // #12553 2026.03.02 mod FW7に伴う2038年問題対応 TDC高村 start
        //localtime_r( &makeTime.tv_sec, &now );
        struct timespec ts;
        ts.tv_sec = makeTime.tv_sec;
        ts.tv_nsec = makeTime.tv_usec * 1000;
        localtime_r( &ts.tv_sec, &now );
        // #12553 2026.03.02 mod FW7に伴う2038年問題対応 TDC高村 end

        // ファイル名作成
        // ※[ファイル名先頭]_[作成年月日時分秒マイクロ秒].[ファイル拡張子]
        sprintf(
              fileName 
            , "%s%s_%04d%02d%02d%02d%02d%02d%06ld%s"
            , folder
            , cFirstFileName
            , now.tm_year + 1900
            , now.tm_mon + 1
            , now.tm_mday
            , now.tm_hour
            , now.tm_min
            , now.tm_sec
            // #12553 2026.03.02 mod FW7に伴う2038年問題対応 TDC高村 start
            //, makeTime.tv_usec
            , ts.tv_nsec / 1000
            // #12553 2026.03.02 mod FW7に伴う2038年問題対応 TDC高村 end
            , cFileExtName
        );

        ret = 1;
    }

    return ret;    
}


/**
* @brief NTSSデータファイルを作成する
*
* @details NTSSデータファイルを対象フォルダに作成する
*
* @description
* @param[in] 
* @param[in] *packetInfo        パケット管理情報
* @param[in] cOutputType        出力先フラグ(0x00：緊急発報用/0x01：データ収集用)
* @param[in] cCommandId         コマンド識別子
* @param[in] *cFirstFileName    先頭ファイル名(packetInfo=NULLの場合に使用)
* @param[in] *cFileExtName      ファイル拡張子(packetInfo=NULL、直接指定の場合に使用)
* @param[in] *makeTime          ファイル作成日時(packetInfo=NULLの場合に使用)
* @param[in] *cData             データ格納先バッファ
* @param[in] dataLength         データ長
* @return 1：保存成功0：保存不要/−2：フォルダ作成失敗/-3:ファイル作成失敗
* @attention 特になし
*/
int
outputNTSSDataFile( struct NTSS_PACKET_INFORMATION *packetInfo 
                  , u_char cOutputType
                  , u_char *cCommandId
                  , u_char *cFirstFileName
                  , u_char *cFileExtName
                  , struct timeval *makeTime
                  , u_char *cData
                  , int dataLength
                  )
{
    u_char clog[ NTSS_STR_MAX_SIZE ];
    int ret = 0;
    int intres;
    int intlop;
    // add AWSとDEの通信断からの復旧 高 start
    u_char cDeviceType[4];
    u_char cDeviceNo[10];
    char t_path[256];
    // add AWSとDEの通信断からの復旧 高 end
    // add FNSI-バグ 通信サーバ(#5618) 高 start
    struct stat st;
    // add FNSI-バグ 通信サーバ(#5618) 高 end
    // #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 start
    char failDataPath[128] = {0};
    char devFailDataPath[128] = {0};
    getCommFailDataDirectory(failDataPath);
    getCommDevFailDataDirectory(devFailDataPath);
    // #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 end
    // #11324 2025.01.27 add 通信異常フラグの確認はいちどだけ行う TDC片口 start
    /** 通信不可フラグ */
    bool isCommDisableState = getCommAliveState() != 0;
    // #11324 2025.01.27 add 通信異常フラグの確認はいちどだけ行う TDC片口 end

    // ファイル出力先分
    for( intlop = 0; intlop < 3; intlop++ )
    {
        // 格納先フォルダ名取得
        u_char *folder = getNTSSDeviceCapDataFolder( cOutputType, intlop );

        // ファイル出力先フォルダ判定
        if( folder == NULL || strlen(folder) == 0 )
        {
            // ファイル出力先の設定なし

            // ファイル出力不要
            break;
        }
        else
        {
            // ファイル出力先の設定あり

            // フォルダ確認、及び作成                       
            if( existFolderFile( folder, NULL ) != 1 )
            {
                // 該当フォルダなし

                // フォルダ作成
                if(( ret = createFolder( folder )) == 1 )
                {
                    // フォルダ作成成功
                    
                    sprintf(clog, "フォルダ作成成功:%s", folder);
                    outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, packetInfo );

                    printf( "%s\n", clog );

                }
                else
                {
                    // フォルダ作成失敗
                    
                    sprintf(clog, "フォルダ作成失敗:%s (%d)", folder, ret);
                    viewError( clog );

                    ret = -2;
                }
            }
            else
            {
                ret = 1;
            }
        }
        
        // フォルダ判定
        if( ret == 1 )
        {
            // フォルダあり
            
            // ファイル名作成
            u_char cfile[ NTSS_STR_MAX_SIZE ];
            memset( cfile, 0, sizeof( cfile ));
            if( packetInfo != NULL )
            {
                // ファイル作成日時がNULLである場合
                if( makeTime == NULL )
                {
                    // パケット最終受信日時を設定する
                    makeTime = &(packetInfo->buffer.lastReceiveTime );
                }

                switch( cOutputType )
                {
                    case NTSS_OUTPUT_FOLDER_M_NOTICE:   // 緊急発報用
                        // add AWSとDEの通信断からの復旧 高 start
                        // #11324 2025.01.27 mod 通信異常フラグの確認はいちどだけ行う TDC片口 start
                        // if ( getCommAliveState() != 0 ) {
                        if (isCommDisableState)
                        {
                        // #11324 2025.01.27 mod 通信異常フラグの確認はいちどだけ行う TDC片口 end
                            // 電文識別子による判定(大文字小文字区別しない)
                            if( strncasecmp( cCommandId, "LOG", 3 ) == 0 ){
                                // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
                                // sprintf(t_path, "%s/", WORK_FAIL_DATA_PATH);
                                sprintf(t_path, "%s/", failDataPath);
                                // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
                                //
                                intres = getNTSSM_NoticeFileName(
                                      packetInfo->cCommType                 // 通信方式
                                    , packetInfo->cDeviceType               // 型式コード
                                    , packetInfo->cDeviceFormat             // 通信フォーマット
                                    , packetInfo->cDeviceNo                 // 製造番号
                                    , cCommandId                            // コマンド識別子
                                    , *makeTime                             // ファイル作成日時
                                    , t_path                                // 格納先フォルダ
                                    , cfile                                 // 作成したファイル名
                                );
                                break;
                            }
                        }
                        // add AWSとDEの通信断からの復旧 高 end
                        //
                        intres = getNTSSM_NoticeFileName(
                              packetInfo->cCommType                 // 通信方式
                            , packetInfo->cDeviceType               // 型式コード
                            , packetInfo->cDeviceFormat             // 通信フォーマット
                            , packetInfo->cDeviceNo                 // 製造番号
                            , cCommandId                            // コマンド識別子
                            , *makeTime                             // ファイル作成日時
                            , folder                                // 格納先フォルダ
                            , cfile                                 // 作成したファイル名
                        );
                        break;

                    case NTSS_OUTPUT_FOLDER_DATA_COLLECT:   // データ収集用
                        // add FNSI-バグ 通信サーバ(#5618) 高 start
                        if(packetInfo->device_comm_flg == 1) {
                            // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
                            // sprintf(t_path, "./%s_%08lX/", WORK_DEV_FAIL_DATA_PATH, packetInfo->dev_no);
                            sprintf(t_path, "%s_%08lX/", devFailDataPath, packetInfo->dev_no);
                            // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
                            
                        }
                        // add FNSI-バグ 通信サーバ(#5618) 高 end
                        // add AWSとDEの通信断からの復旧 高 start
                        // #11324 2025.01.27 mod 通信異常フラグの確認はいちどだけ行う TDC片口 start
                        // if ( getCommAliveState() != 0 ) {
                        if (isCommDisableState)
                        {
                        // #11324 2025.01.27 mod 通信異常フラグの確認はいちどだけ行う TDC片口 end
                            // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
                            // sprintf(t_path, "%s/", WORK_FAIL_DATA_PATH);
                            sprintf(t_path, "%s/", failDataPath);
                            // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
                            intres = getNTSSDataCollectPacketFileName(
                                  packetInfo->cCommType                 // 通信方式
                                , packetInfo->cDeviceType               // 型式コード
                                , packetInfo->cDeviceFormat             // 通信フォーマット
                                , packetInfo->cDeviceNo                 // 製造番号
                                , cCommandId                            // コマンド識別子
                                , *makeTime                             // ファイル作成日時
                                , t_path                                // 格納先フォルダ
                                , cfile                                 // 作成したファイル名
                            );
                            break;
                        }
                        // add AWSとDEの通信断からの復旧 高 end
                        // add FNSI-バグ 通信サーバ(#5618) 高 start
                        else if(packetInfo->device_comm_flg == 1 && existFolderFile(t_path, &st) == 1) {
                            // 電文識別子による判定(大文字小文字区別しない)
                            if( strncasecmp( cCommandId, "LOG", 3 ) == 0 ){
                                //
                                intres = getNTSSDataCollectPacketFileName(
                                      packetInfo->cCommType                 // 通信方式
                                    , packetInfo->cDeviceType               // 型式コード
                                    , packetInfo->cDeviceFormat             // 通信フォーマット
                                    , packetInfo->cDeviceNo                 // 製造番号
                                    , cCommandId                            // コマンド識別子
                                    , *makeTime                             // ファイル作成日時
                                    , t_path                                // 格納先フォルダ
                                    , cfile                                 // 作成したファイル名
                                );
                                break;
                            }
                        }
                        // add FNSI-バグ 通信サーバ(#5618) 高 end
                        //
                        intres = getNTSSDataCollectPacketFileName(
                              packetInfo->cCommType                 // 通信方式
                            , packetInfo->cDeviceType               // 型式コード
                            , packetInfo->cDeviceFormat             // 通信フォーマット
                            , packetInfo->cDeviceNo                 // 製造番号
                            , cCommandId                            // コマンド識別子
                            , *makeTime                             // ファイル作成日時
                            , folder                                // 格納先フォルダ
                            , cfile                                 // 作成したファイル名
                        );
                        break;
                }
                // 拡張子
                if( cFileExtName == NULL ) 
                {
                    strcat( cfile, ".bin" );
                }
                else
                {
                    strcat( cfile, cFileExtName );
                }
            }
            else
            {
                //
                intres = getNTSSFileName(
                      cFirstFileName
                    , cFileExtName
                    , *makeTime
                    , folder
                    , cfile
                );
            }


            // ファイル名判定
            if( intres == 1 )
            {
                // ファイル名あり

                // ファイル出力
                if(( intres = outputFile(
                      cfile         // 作成するファイル名
                    , cData         // 記録するデータ
                    , dataLength    // 記録するデータ長
                    )) == 1 )
                {
                    // ファイル作成成功

                    ret = 1;
                    
                    sprintf( clog, "作成ファイル名:%s", cfile );
                    outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, packetInfo );
                    printf( "%s\n", clog );  
                    
                    // add AWSとDEの通信断からの復旧 高 start
                    // #11324 2025.01.27 mod 通信異常フラグの確認はいちどだけ行う TDC片口 start
                    // if ( getCommAliveState() != 0 ) {
                    if (isCommDisableState)
                    {
                    // #11324 2025.01.27 mod 通信異常フラグの確認はいちどだけ行う TDC片口 end
                        // 型式コード
                        memmove( cDeviceType, packetInfo->cDeviceType, 3 );
                        cDeviceType[3] = 0;

                        // 製造番号
                        memmove( cDeviceNo, &packetInfo->cDeviceNo, sizeof( packetInfo->cDeviceNo ));
                        cDeviceNo[8] = 0;
                        // 末尾の空白を除去
                        trimEnd( cDeviceNo, ' ' );
                        
                        // output to file
                        comsv_fail_append_data_full(devicecapConf.cFacilityCode, cDeviceType, cDeviceNo, cfile, 1, 1);
                    }
                    // add AWSとDEの通信断からの復旧 高 end

                    break;
                }
                else
                {
                    // ファイル作成失敗

                    ret = -3;

                    sprintf(clog, "ファイル作成失敗:%s", cfile);
                    viewError( clog );
                }
            }
            else
            {
                // ファイル名作成失敗
                
                ret = -3;
                
                sprintf(clog, "ファイル名作成失敗:%s", folder);
                viewError( clog );
            }
        }
    }

    return ret;
}
/**
* @brief NTSSデータファイルを追記で作成する
*
* @details NTSSデータファイルを対象フォルダに追記で作成する
*
* @description
* @param[in] 
* @param[in] *packetInfo        パケット管理情報
* @param[in] cOutputType        出力先フラグ(0x00：緊急発報用/0x01：データ収集用)
* @param[in] *cFirstFileName    先頭ファイル名
* @param[in] *cFileExtName      ファイル拡張子
* @param[in] *makeTime          ファイル作成日時
* @param[in] *cData             データ格納先バッファ
* @param[in] dataLength         データ長
* @return 1：保存成功0：保存不要/−2：フォルダ作成失敗/-3:ファイル作成失敗
* @attention 特になし
*/
int
outputAppendNTSSDataFile( struct NTSS_PACKET_INFORMATION *packetInfo 
                        , u_char cOutputType
                        , u_char *cFirstFileName
                        , u_char *cFileExtName
                        , struct timeval *makeTime
                        , u_char *cData
                        , int dataLength
                        )
{
    u_char clog[ NTSS_STR_MAX_SIZE ];
    int ret = 0;
    int intres;
    int intlop;
    // add AWSとDEの通信断からの復旧 高 start
    u_char cDeviceType[4];
    u_char cDeviceNo[10];
    char t_path[256];
    // add AWSとDEの通信断からの復旧 高 end
    // add FNSI-バグ 通信サーバ(#5618) 高 start
    struct stat st;
    // add FNSI-バグ 通信サーバ(#5618) 高 end
    // #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 start
    char failDataPath[128] = {0};
    char devFailDataPath[128] = {0};
    getCommFailDataDirectory(failDataPath);
    getCommDevFailDataDirectory(devFailDataPath);
    // #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 end
    // #11324 2025.01.27 add 通信異常フラグの確認はいちどだけ行う TDC片口 start
    /** 通信不可フラグ */
    bool isCommDisableState = getCommAliveState() != 0;
    // #11324 2025.01.27 add 通信異常フラグの確認はいちどだけ行う TDC片口 end

    // ファイル出力先分
    for( intlop = 0; intlop < 3; intlop++ )
    {
        // 格納先フォルダ名取得
        u_char *folder = getNTSSDeviceCapDataFolder( cOutputType, intlop );

        // ファイル出力先フォルダ判定
        if( folder == NULL || strlen(folder) == 0 )
        {
            // ファイル出力先の設定なし

            // ファイル出力不要
            break;
        }
        else
        {
            // ファイル出力先の設定あり

            // フォルダ確認、及び作成
            if( existFolderFile( folder, NULL ) != 1 )
            {
                // 該当フォルダなし

                // フォルダ作成
                if(( ret = createFolder( folder )) == 1 )
                {
                    // フォルダ作成成功
                    
                    sprintf(clog, "フォルダ作成成功:%s", folder);
                    outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, packetInfo );

                    printf( "%s\n", clog );

                }
                else
                {
                    // フォルダ作成失敗
                    
                    sprintf(clog, "フォルダ作成失敗:%s (%d)", folder, ret);
                    viewError( clog );

                    ret = -2;
                }
            }
            else
            {
                ret = 1;
            }
        }
        
        // フォルダ判定
        if( ret == 1 )
        {
            // フォルダあり
            
            // ファイル名作成
            u_char cfile[ NTSS_STR_MAX_SIZE ];
            memset( cfile, 0, sizeof( cfile ));
            
            // add FNSI-バグ 通信サーバ(#5618) 高 start
            if(packetInfo->device_comm_flg == 1) {
                // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
                // sprintf(t_path, "./%s_%08lX/", WORK_DEV_FAIL_DATA_PATH, packetInfo->dev_no);
                sprintf(t_path, "%s_%08lX/", devFailDataPath, packetInfo->dev_no);
                // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
            }
            // add FNSI-バグ 通信サーバ(#5618) 高 end
            //
            // add AWSとDEの通信断からの復旧 高 start
            // #11324 2025.01.27 mod 通信異常フラグの確認はいちどだけ行う TDC片口 start
            // if ( getCommAliveState() != 0 ) {
            if (isCommDisableState)
            {
            // #11324 2025.01.27 mod 通信異常フラグの確認はいちどだけ行う TDC片口 end
                // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
                // sprintf(t_path, "%s/", WORK_FAIL_DATA_PATH);
                sprintf(t_path, "%s/", failDataPath);
                // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
                intres = getNTSSFileName(
                        cFirstFileName
                    , cFileExtName
                    , *makeTime
                    , t_path
                    , cfile
                );
            }
            // add FNSI-バグ 通信サーバ(#5618) 高 start
            else if(packetInfo->device_comm_flg == 1 && cOutputType== 0x01 && existFolderFile(t_path, &st) == 1) {
                // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 start
                // sprintf(t_path, "./%s_%08lX/", WORK_DEV_FAIL_DATA_PATH, packetInfo->dev_no);
                sprintf(t_path, "%s_%08lX/", devFailDataPath, packetInfo->dev_no);
                // #8731 2023.05.15 mod 通信異常ファイルの格納先を設定で持つ TDC片口 end
                intres = getNTSSFileName(
                    cFirstFileName
                , cFileExtName
                , *makeTime
                , t_path
                , cfile
                );
            }
            // add FNSI-バグ 通信サーバ(#5618) 高 end
            else {
            // add AWSとDEの通信断からの復旧 高 end
                intres = getNTSSFileName(
                        cFirstFileName
                    , cFileExtName
                    , *makeTime
                    , folder
                    , cfile
                );
            }

            // ファイル名判定
            if( intres == 1 )
            {
                // ファイル名あり

                // ファイル出力(追記)
                if(( intres = outputAppendFile(
                      cfile         // 作成するファイル名
                    , cData         // 記録するデータ
                    , dataLength    // 記録するデータ長
                    )) == 1 )
                {
                    // ファイル作成成功

                    ret = 1;
                    
                    sprintf( clog, "作成ファイル名:%s", cfile );
                    outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, packetInfo );
                    printf( "%s\n", clog );  
                    
                    // add AWSとDEの通信断からの復旧 高 start
                    // #11324 2025.01.27 mod 通信異常フラグの確認はいちどだけ行う TDC片口 start
                    // if ( getCommAliveState() != 0 ) {
                    if (isCommDisableState)
                    {
                    // #11324 2025.01.27 mod 通信異常フラグの確認はいちどだけ行う TDC片口 end
                        // 型式コード
                        memmove( cDeviceType, packetInfo->cDeviceType, 3 );
                        cDeviceType[3] = 0;

                        // 製造番号
                        memmove( cDeviceNo, &packetInfo->cDeviceNo, sizeof( packetInfo->cDeviceNo ));
                        cDeviceNo[8] = 0;
                        // 末尾の空白を除去
                        trimEnd( cDeviceNo, ' ' );
                        
                        // output to file
                        comsv_fail_append_data_full(devicecapConf.cFacilityCode, cDeviceType, cDeviceNo, cfile, 1, 2);
                    }
                    // add AWSとDEの通信断からの復旧 高 end

                    break;
                }
                else
                {
                    // ファイル作成失敗

                    ret = -3;

                    sprintf(clog, "ファイル作成失敗:%s", cfile);
                    viewError( clog );
                }
            }
            else
            {
                // ファイル名作成失敗
                
                ret = -3;
                
                sprintf(clog, "ファイル名作成失敗:%s", folder);
                viewError( clog );
            }
        }
    }

    return ret;
}
//@}
