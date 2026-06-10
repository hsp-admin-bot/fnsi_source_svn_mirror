/**
* @brief NTSS日機装新通信処理ファイル
*
* @details NTSSでの日機装新通信処理を行う
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_nkk_comm.c
* @author H.Yonezawa
* @date 2017/10/18
*/


/*　必要な機能
*   ・先頭がSTX、以降のデータにETXが含まれているかどうかをチェックする
*   ・STX、ETXがともに見つかった場合、DLEエスケープ処理を行い、チェックサム判定を実施
*   ・通知対象のコマンドかどうか判定する      
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <stdbool.h>
#include <time.h>
#include <sys/time.h>

#include <netinet/in.h>

#include "ntss_devicecap_conf.h"
#include "ntss_nkk_comm.h"
#include "ntss_packet_manage.h"
#include "ntss_packet_file.h"

#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/ntss_etc_lib.h"
#include "../common/libs/ntss_mst_lib.h"
#include "../common/nkklib/nkklib.h"


/// 日機装通信キャプチャ対応コマンド設定ファイル
#define NTSS_CAPTURE_COMMAND_CONFIG_FILE "./conf/ntss_pcap_command.conf"


/// @name キャプチャ対象コマンド管理情報
//@{

/// キャプチャ対象コマンド管理情報配列
struct NTSS_NKK_CAPTURE_COMMAND_INFORMATION captureCommandList[NTSS_NKK_CAPTURE_COMMAND_KIND_COUNT];

//@}

/**
* @brief 日機装通信キャプチャ対象コマンド情報設定ファイルを読み込む
*
* @details 日機装通信キャプチャ対象コマンド情報設定ファイルを読み込む
*
* @description
* @return 1：取得成功/0：取得失敗
* @attention 特になし
*/
int
initNTSSNKKCaptureCommandInfo()
{
    int ret = 0;

    // キャプチャ対象コマンド管理情報初期化
    memset( captureCommandList, 0, sizeof( captureCommandList ));
    
/*    
    // ※実際には設定ファイルを読み込み、キャプチャ対象コマンド分の登録を行う
    // 装置ログ[66]
    capturetommandList[0].cCommandKind = 0x66;            
    strcat(captureCommandList[0].cCommandId, "LOGDEV");
    captureCommandList[0].cOutputType = NTSS_OUTPUT_FOLDER_M_NOTICE;
    // メンテナンスス[64]
    captureCommandList[1].cCommandKind = 0x64;            
    strcat(captureCommandList[1].cCommandId, "MAINTE");
    captureCommandList[1].cOutputType = NTSS_OUTPUT_FOLDER_DATA_COLLECT;
    // 装置オプション[65]
    captureCommandList[2].cCommandKind = 0x65;            
    strcat(captureCommandList[2].cCommandId, "OPTION");
    captureCommandList[2].cOutputType = NTSS_OUTPUT_FOLDER_DATA_COLLECT;
*/

    FILE *fp;
    u_char cbuff[ NTSS_STR_MAX_SIZE ];
    int nidx = 0;

    // ファイル読み込み
    if (( fp = fopen( NTSS_CAPTURE_COMMAND_CONFIG_FILE, "r" )) != NULL )
    {
    	// 行単位読み込み(または設定可能件数内)
        while( fgets( cbuff, sizeof(cbuff), fp ) != NULL && nidx < NTSS_NKK_CAPTURE_COMMAND_KIND_COUNT )
        {
            // debug
            //printf(" line : %s\n", cbuff );
        
            // コメント判定
            if( cbuff[0] != ';' )
            {
                // 通信方式
                captureCommandList[nidx].cCommType = cbuff[0];
                // コマンド番号
                captureCommandList[nidx].cCommandKind[0] = getBinFromHexStr( cbuff + 2 );
                if( cbuff[4] != 0x20 && cbuff[5] != 0x20 )
                {
                    captureCommandList[nidx].cCommandKind[1] = getBinFromHexStr( cbuff + 4 );
                }
                // 識別文字列
                cbuff[13] = 0x0;
                strcat( captureCommandList[nidx].cCommandId, cbuff + 7 );
                // 末尾の空白を除去
                trimEnd( captureCommandList[nidx].cCommandId, ' ' );
                // ファイル出力先
                cbuff[14] -= 0x30;
                if( NTSS_OUTPUT_FOLDER_M_NOTICE <= cbuff[14] && cbuff[14] <= NTSS_OUTPUT_FOLDER_DATA_COLLECT )
                {
                    captureCommandList[nidx].cOutputType = cbuff[14];
                }   

                //// debug
/*
                printf( " Capture Command Index : %d\n", nidx);
                printf( "    comm:%d/  kind:%.2X-%.2X / id:%s / output:%d\n"
                    , captureCommandList[nidx].cCommType
                    , captureCommandList[nidx].cCommandKind[0]
                    , captureCommandList[nidx].cCommandKind[1]
                    , captureCommandList[nidx].cCommandId
                    , captureCommandList[nidx].cOutputType
                    );
*/
                nidx++;
            }
        }

        //
        ret = 1;

        fclose( fp );	
    }

    return ret;
}

/**
* @brief 指定したコマンド番号の日機装通信キャプチャ対象コマンド情報を取得する
*
* @details 指定したコマンド番号の日機装通信キャプチャ対象コマンド情報を取得する
*
* @description
* @param[in] cCommType  通信方式'0':通信なし/'1':新通信/'2':NX通信/'3'：通信共通V4)
* @param[in] *cCmdNo    コマンド
* @param[in] nCmdNoSize コマンド長さ
* @return NULL：取該当なし/else：該当した日機装通信キャプチャ対象コマンド情報用構造体ポインタ
* @attention 特になし
*/
struct NTSS_NKK_CAPTURE_COMMAND_INFORMATION *
getNTSSNKKCaptureCommandInfo( u_char cCommType
                            , u_char *cCmdNo
                            , int nCmdNoSize
                            )
{
    struct NTSS_NKK_CAPTURE_COMMAND_INFORMATION *ret = NULL;
    struct NTSS_NKK_CAPTURE_COMMAND_INFORMATION *info;
    int intlop;

    // キャプチャ対象コマンド定義分
    for( intlop = 0; 0 <= captureCommandList[intlop].cCommandKind && intlop < NTSS_NKK_CAPTURE_COMMAND_KIND_COUNT; intlop++ )
    {
        //
        info = &captureCommandList[intlop];

        // 通信方式
        if( info->cCommType == cCommType )
        {
            // 通信方式が一致

            //// debugn
            //printf( " command check : %.02x-%.02x size( %d ) -> %.02x-%.02x\n", cCmdNo[0], cCmdNo[1], nCmdNoSize, info->cCommandKind[0], info->cCommandKind[1] );

            // キャプチャ対象コマンド判定
            if( memcmp( cCmdNo, info->cCommandKind, nCmdNoSize ) == 0 )
            {
                ret = info;
                break;
            }
        }
    }
    
    return ret;
}


/// @name 新通信処理関連
//@{
/**
* @brief 対象バッファ情報から新通信の電文を取得する
*
* @details 対象バッファから日機装新装置の電文を取得する
*
* @description
* @param[in] *packetInfo    バッファ情報
* @param[out] *cmd          取得したコマンド(STX、ETX、DLE,チェックサム除去済み)
* @param[out] cmdLength     取得したコマンドサイズ
* @return 1：電文取得/0：電文なし/-1：チェックサム異常
* @attention 特になし
*/
int
getNTSSNKKCommand( struct NTSS_BUFFER *bufferInfo
                 , u_char *cmd
                 , int *cmdLength
                 )
{
    int ret = 0;
    int nidx = -1;
    int intlop;
    int nsize;
    u_char csum = 0;

/*
    // debug
    printf(" Before:BufferSize:%d\n", bufferInfo->nBufferSize);
    char cData[1024 * 2];
    memset(cData, 0, sizeof(cData));
    for ( intlop = 0; intlop < bufferInfo->nBufferSize; intlop++) 
    {
        //
        if( 0 < intlop )
        {
            strcat(cData, "-");
        }
        sprintf(cData + strlen(cData), " %.2x ", bufferInfo->cBuffer[intlop]);
    }
    printf(" %s\n", cData);
*/

    // バッファ内にデータがあるかどうか
    if( 15 <= bufferInfo->nBufferSize )
    {
        // バッファの先頭がSTXかどうか確認
        if( bufferInfo->cBuffer[0] == NTSS_NKK_STX )
        {
            // 先頭がSTX

            // ETX検索
            for( intlop = 1; intlop < bufferInfo->nBufferSize; intlop++ )
            {
                if( bufferInfo->cBuffer[intlop] == NTSS_NKK_ETX)
                {
                    // ETXあり
                    nidx = intlop;

                    break;
                }
            }

            // ETXが検出された場合
            if( 1 < nidx )
            {
                // STX〜ETX間のデータを抜き出し
                nsize = nidx - 1;
                u_char cwork[nsize];
                memmove( cwork, bufferInfo->cBuffer + 1, nsize );

                // バッファを詰める
                nidx++;
                memmove( bufferInfo->cBuffer, bufferInfo->cBuffer + nidx, bufferInfo->nBufferSize - nidx );
        
                // バッファサイズ更新
                bufferInfo->nBufferSize -= nidx;

                // DLEエスケープ処理
                nidx = 0;
                for( intlop = 0; intlop < nsize; intlop++ )
                {
                    // DLE検出
                    if( cwork[intlop] == NTSS_NKK_DLE )
                    {
                        // 次のキャラクタ判定
                        switch( cwork[++intlop] )
                        {
                            case NTSS_NKK_DLE:      // DLE
                                break;
                            case NTSS_NKK_DLE_STX:  // STX
                                cwork[intlop] = NTSS_NKK_STX;
                                break;
                            case NTSS_NKK_DLE_ETX:  // ETX
                                cwork[intlop] = NTSS_NKK_ETX;
                                break;
                        }
                    }
                    cwork[nidx] = cwork[intlop];
					if( intlop < ( nsize - 1 ))
					{
                    	csum += cwork[nidx];
					}
                    nidx++;
                }
/*
                // debug
                printf(" After:BufferSize:%d\n", nidx);
                memset(cData, 0, sizeof(cData));
                for ( intlop = 0; intlop < nidx; intlop++) 
                {
                    //
                    if( 0 < intlop )
                    {
                        strcat(cData, "-");
                    }
                    sprintf(cData + strlen(cData), " %.2x ", cwork[intlop]);
                }
                printf(" %s\n", cData);
*/
                // チェックサム判定
                //printf( " getNTSSNKKCommand checksum: %X - %X\n", csum, cwork[nidx - 1]);
                if( cwork[nidx - 1] == csum )
                {
                    // OK
                    ret = 1;

                    // 取得したコマンドをコピー
                    memmove( cmd, cwork, nidx - 1 );
                    *cmdLength = nidx - 1;
                }
                else
                {
                    // NG
                    ret = -1;
                }
            }
        }
    }

    return ret;
}

/**
* @brief 対象パケット管理情報で日機装新通信処理を行う
*
* @details 対象パケット管理情報で日機装信通信処理を行う
*
* @description
* @param[in] *packetInfo    パケット管理情報
* @return 1：対象電文あり/0：対象電文なし/-1：チェックサム異常/−2：フォルダ作成失敗/-3:ファイル作成失敗
* @attention 特になし
*/
int
checkNTSSNKKCommand( struct NTSS_PACKET_INFORMATION *packetInfo )
{
    int ret = 0;

    u_char cstx[] = { NTSS_NKK_STX };
    u_char cCmd[2048];
    u_char clog[ NTSS_STR_MAX_SIZE ];
    int cmdLength;
    int intres;
    int intlop;

    // バッファ内の電文分繰り返す
    while( true )
    {
        // バッファの先頭がSTXになるまでバッファ内の情報を前に詰める
        UpdateNTSSPacketInfoBuffer( &packetInfo->buffer, cstx, 1 );
    
        //  STX〜ETX検出
        //  DLEエスケープ処理
        //  チェックサム判定
        intres = getNTSSNKKCommand( &packetInfo->buffer, cCmd, &cmdLength);
        printf( " getNTSSNKKCommand:%d\n", ret );
        if( intres == 1 )
        {
            u_char cDeviceType[4];
            u_char cDeviceNo[10];
            u_char cCmdNo[2];
            u_char cCmdNoHex[5];
            int nCmdNoSize = 1;
            int nHeaderSize = 12;

            // 型式コード
            memmove( cDeviceType, packetInfo->cDeviceType, 3 );
            cDeviceType[3] = 0;

            // NX判定
            if( packetInfo->cCommType == NTSS_COMM_TYPE_NX )
            {
                // NX通信

                // 機種
                cDeviceNo[0] = cCmd[2];
                // 製造番号
                cDeviceNo[1] = cCmd[5];
                cDeviceNo[2] = cCmd[7];
                cDeviceNo[3] = cCmd[9];
                cDeviceNo[4] = cCmd[11];
                cDeviceNo[5] = cCmd[13];
                cDeviceNo[6] = cCmd[15];
                cDeviceNo[7] = cCmd[17];
                cDeviceNo[8] = cCmd[19];
                cDeviceNo[9] = 0;

                //　コマンド番号
                cCmdNo[0] = cCmd[22];
                cCmdNo[1] = cCmd[23];
                sprintf( 
                      cCmdNoHex
                    , "%.02X%.02X"
                    , cCmdNo[0]
                    , cCmdNo[1]
                );
                nCmdNoSize = 2;
                nHeaderSize = 28;
            }
            else
            {
                // 新通信(NX通信以外)

                // 通信フォーマット＋製造番号
                memmove( cDeviceNo, cCmd, 8 );
                cDeviceNo[8] = 0;

                // コマンド番号
                cCmdNo[0] = cCmd[9];
                sprintf( 
                      cCmdNoHex
                    , "%.02X"
                    , cCmdNo[0]
                );
            }

            // debug
            printf(" command model:%s / deviceNo:%s / code:%s / size:%d\n", cDeviceType, cDeviceNo, cCmdNoHex, cmdLength);

/*                    
            char cData[cmdLength * 5 + 1];
            memset(cData, 0, sizeof(cData));
            for ( intlop = 0; intlop < cmdLength; intlop++) 
            {
                //
                if( 0 < intlop )
                {
                    strcat(cData, "-");
                }
                sprintf(cData + strlen(cData), " %.2x ", cCmd[intlop]);
            }
            printf(" %s\n", cData);
*/                   
            // キャプチャ対象コマンド判定
            struct NTSS_NKK_CAPTURE_COMMAND_INFORMATION *capInfo = getNTSSNKKCaptureCommandInfo(
                  packetInfo->cCommType
                , cCmdNo
                , nCmdNoSize
            );
            if( capInfo != NULL )
            {
                // キャプチャ対象の装置コマンドの場合

                // パケット受信日時時刻取得(マイクロ秒含む)
                struct timeval now;
                memmove( &now, &(packetInfo->buffer.lastReceiveTime), sizeof( now ));

                printf("** 装置コマンド[%s]受信!! **\n", cCmdNoHex);

                // 電文種類の判定
                if( cCmdNo[0] == 0x62 || ( cCmdNo[0] == 0x00 && cCmdNo[1] == 0x02 ))
                {
                    // 新通信モニタ[0x62]、NX通信モニタ[0x0002]の場合

                    // モニタ受信日時を保持
                    memmove( &(packetInfo->dtMoni), &now , sizeof( now ));
                    // モニタ出力フラグを初期化
                    packetInfo->isMoniOutput = 0x00;
                    
                    // 通信方式判定
                    if( packetInfo->cCommType == NTSS_COMM_TYPE_NEW )
                    {
                        // 新通信の場合

                        // 監視待ち時間チェック
                        if( 0 <= packetInfo->watchWaitTime )
                        {
                            // 監視待ち時間が有効な場合

                            // 透析中のホスト報知監視が行われていない場合
                            if( packetInfo->isDialysis[0] == 0x01 
                            && packetInfo->isWatch == 0x00 )
                            {
                                // 透析開始から設定時間経過している場合
                                if(( packetInfo->dialysisStartTime + packetInfo->watchWaitTime ) <= now.tv_sec )
                                {
                                    // ホスト報知監視を開始
                                    packetInfo->isWatch = 0x01;

                                    // ログ記録
                                    outputNTSSPacketInfoLog( NTSS_LOG_INFO, "ホスト報知監視開始", 0, packetInfo );
                                }
                            }
                        }
                    }

                    // ヘッダー部分をコピー
                    memmove( packetInfo->cMoniData, cCmd, nHeaderSize );

                    // データ部分処理
                    for( intlop = nHeaderSize; intlop < cmdLength; intlop+=2 )
                    {
                        // コピー実施フラグ初期化
                        u_char cCopy = 0x01;   

                        u_short nAddr = ( intlop - nHeaderSize ) / 2;
                        u_char cVersion[] = "00\0";

                        // 通信方式判定
                        if( packetInfo->cCommType == NTSS_COMM_TYPE_NX )
                        {
                            // NX通信の場合

                            // 装置バージョンを文字列化
                            sprintf(
                                  cVersion
                                , "%02x"
                                , packetInfo->cMoniData[3]
                            );

                            // データ識別子をコピー
                            memmove( packetInfo->cMoniData + intlop, cCmd + intlop, 2 );

                            // アドレス(データ識別子)取得
                            nAddr =( cCmd[intlop] << 8 ) + cCmd[intlop +1];

                            // データ位置を指定
                            intlop += 2;
                        }

                        // 治療中の初回モニタデータ判定
                        if( packetInfo->isDialysis[0] == 0x01
                          && packetInfo->isFirstMoniData == 0x00 )
                        {
                            // 治療中で初回ではない場合

                            // 積算処理判定
                            u_short cAdd =ntss_mst_moni_addup(
                                packetInfo->cDeviceFormat
                                , cVersion
                                , nAddr
                            );
                            if( cAdd == 1 )
                            {
                                // 積算処理あり

                                // 最新値が0x8000、又は0x0000の場合はコピーしない
                                if(( cCmd[intlop] == 0x80 || cCmd[intlop] == 0x00 ) && cCmd[intlop + 1] == 0x00 )
                                {
                                    cCopy = 0x00;
                                }
                            }
                        }

                        // debug
/*                        
                        printf(
                             "moni %c[%s] item:%d - Addr:%d - Add:%d(%d)\n"
                            , packetInfo->cDeviceFormat
                            , cVersion
                            , intlop
                            , nAddr
                            , cCopy
                            , packetInfo->isFirstMoniData
                        );
*/
                        // データコピー有無判定
                        if( packetInfo->isStopUpMoniData == 0x01
                         || ( packetInfo->isDialysis[1] == 0x01 && packetInfo->isDialysis[1] != (*( cCmd + nHeaderSize - 2 ) & 0x01)))
                        {
                            // モニタ更新禁止、又は前回の透析状態が治療中で今回の透析状態が治療外となった場合

                            //　モニタデータのコピーを行わない
                            cCopy = 0x00;
                        }

                        // データコピー判定
                        if( cCopy == 0x01
                          || packetInfo->isFirstMoniData == 0x01 )
                        {
                            // データコピー
                            memmove( packetInfo->cMoniData + intlop, cCmd + intlop, 2 );
                            
                            // ホスト報知監視中
                            if( packetInfo->isWatch == 0x01 )
                            {
                                // ホスト報知監視実施

                                // モニタ項目が再循環率[89]、最高血圧[90]、最低血圧[91]、平均血圧[92]、脈拍[93]、体温[94]の場合
                                if( 89 <= nAddr && nAddr <= 94 )
                                {
                                    // 装置記録で監視するため本処理をスキップ
                                    continue;
                                }

                                // 今回のモニタ値を取得
                                short monNow;
                                memmove( (char*)&monNow, cCmd + intlop, 2 );

                                // エンディアン変換
                                monNow = hl_chg( monNow );


                                // ホスト報知監視
                                checkNTSSHostWatchInfo(
                                      packetInfo
                                    , now
                                    , nAddr
                                    , monNow
                                );
                            }
                        }
                    }

                    // ホスト報知監視中
                    if( packetInfo->isWatch == 0x01 )
                    {
                        // ホスト報知監視ファイル出力
                        outputNTSSHostWatchInfo(
                              packetInfo
                            , now
                        );
                    }

                    // モニタデータサイズを更新
                    packetInfo->nMoniDataSize = cmdLength;

                    // 初回モニタデータ指示を解除
                    packetInfo->isFirstMoniData = 0x00;

                    // 現在の工程を取得
                    switch( packetInfo->cCommType )
                    {
                        case NTSS_COMM_TYPE_NEW:    // 新通信
                            packetInfo->nProcess[0] = (packetInfo->cMoniData[nHeaderSize + 0] << 8 ) + packetInfo->cMoniData[nHeaderSize + 1];
                            break;

                        case NTSS_COMM_TYPE_NX:     // NX通信
                            packetInfo->nProcess[0] = (packetInfo->cMoniData[nHeaderSize + 2] << 8 ) + packetInfo->cMoniData[nHeaderSize + 3];
                            break;
                    }

                    // debug
                    //printf( "MON : %d [%.02x %.02x]\n", packetInfo->nProcess[0], packetInfo->cMoniData[nHeaderSize + 0], packetInfo->cMoniData[nHeaderSize + 1] );

                    // 工程変化を判定
                    if( packetInfo->nProcess[0] != packetInfo->nProcess[1] )
                    {
                        // 工程通知を依頼
                        packetInfo->isNeedSendProcess = 0x01;
                    }

                    ret = 1;
                }
                else if( cCmdNo[0] == 0x64 )
                {
                    // 新通信メンテナンス[0x64]の場合

                    char cflag = 0x00;

                    // キャプチャー情報コピー(ファイルの識別子を変更するため)
                    struct NTSS_NKK_CAPTURE_COMMAND_INFORMATION workCapInfo;
                    memmove( &workCapInfo, capInfo, sizeof( workCapInfo ));

                    u_short nOffset[] = {80, 100, 110, 120};
                    for( intlop = 0; intlop < 4; intlop++ )
                    {
                        // 自己診断種別設定
                        //  UFRC自己診断[1]
                        //  漏血自己診断[2]
                        //  透析液流量自己診断[3]
                        //  濃度自己診断[4]                       
                        workCapInfo.cCommandId[3] = '1' + intlop;

                        // debug
/*
                        printf( 
                              "mainte:%d offset:%d %02x/%02x/%02x/%02x/%02x/%02x - %02x/%02x/%02x/%02x/%02x/%02x\n"
                            , intlop
                            , nHeaderSize + nOffset[intlop]
                            , *(cCmd + nHeaderSize + nOffset[intlop])
                            , *(cCmd + nHeaderSize + nOffset[intlop] + 1)
                            , *(cCmd + nHeaderSize + nOffset[intlop] + 2)
                            , *(cCmd + nHeaderSize + nOffset[intlop] + 3)
                            , *(cCmd + nHeaderSize + nOffset[intlop] + 4)
                            , *(cCmd + nHeaderSize + nOffset[intlop] + 5)
                            , *(packetInfo->cMainteBCD[intlop])
                            , *(packetInfo->cMainteBCD[intlop] + 1)
                            , *(packetInfo->cMainteBCD[intlop] + 2 )
                            , *(packetInfo->cMainteBCD[intlop] + 3)
                            , *(packetInfo->cMainteBCD[intlop] + 4)
                            , *(packetInfo->cMainteBCD[intlop] + 5)
                        );
*/
                        // 測定日時判定
                        if( memcmp( cCmd + nHeaderSize + nOffset[intlop], packetInfo->cMainteBCD[intlop], 6 ) != 0 )
                        {
                            // 測定日時が大きい場合

                            // FN通信電文ファイルを作成する
                            ret = outputNTSSDataFile(
                                packetInfo
                                , workCapInfo.cOutputType
                                , workCapInfo.cCommandId
                                , NULL
                                , NULL
                                , NULL
                                , cCmd
                                , cmdLength
                            );

                            // 測定日時を更新        
                            memmove( packetInfo->cMainteBCD[intlop], cCmd + nHeaderSize + nOffset[intlop], 6 );

                            // 自己診断実施
                            cflag = 0x01;
                        }
                    }

                    // 動作時間
                    workCapInfo.cCommandId[3] = '5';
                    if( cflag == 0x00 )
                    {
                        // 自己診断が実施されていない場合

                        // FN通信電文ファイルを作成する
                        ret = outputNTSSDataFile(
                              packetInfo
                            , workCapInfo.cOutputType
                            , workCapInfo.cCommandId
                            , NULL
                            , NULL
                            , NULL
                            , cCmd
                            , cmdLength
                        );
                    }
                    else
                    {
                        // 自己診断が実施されている場合

                        // 自己診断実施日時ファイル作成
                        outputNTSSPacketInfoMainteDate(
                              devicecapConf.cMstFolder
                            , packetInfo
                        );
                    }

                    ret = 1;
                }
                else if( cCmdNo[0] == 0x66 )
                {
                    // 新通信装置記録[0x66]の場合

                    // 種別、コード、データ取得
                    u_char kind = cCmd[nHeaderSize + 1];
                    u_char code = cCmd[nHeaderSize + 2];
                    short data[4];
                    
                    // ログ記録
                    sprintf( 
                          clog
                        , "装置記録[%s]受信, kind:%02x / code:%02x"
                        , cCmdNoHex
                        , kind
                        , code
                    );
                    outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, packetInfo );
                    printf( "%s\n", clog );

                    // 測定系の装置記録である場合
                    //  種別=0x01
                    if( kind == 0x01 )
                    {
                        // データ取得
                        memmove( data, cCmd + nHeaderSize + 12, 8 );
                        // エンディアン変換
                        int intlop = 0;
                        for( intlop = 0; intlop < 4; intlop++ )
                        {
                            data[intlop] = hl_chg( data[intlop] );
                        }

                        printf( 
                            "Log-Data: data1:%04x / data2:%04x / data3:%04x / data4:%04x\n"
                            , data[0]
                            , data[1]
                            , data[2]
                            , data[3]
                        );

                        // 血圧測定である場合
                        //  コード=0x01(血圧測定)/0x04(前血圧測定)/0x05(後血圧測定)
                        if( code == 0x01 || code == 0x04 || code == 0x05 )
                        {
                            // 監視処理実施[最高血圧(90)]
                            checkNTSSHostWatchInfo(
                                  packetInfo
                                , now
                                , 90
                                , data[0]
                            );
                            // 監視処理実施[最低血圧(91)]
                            checkNTSSHostWatchInfo(
                                  packetInfo
                                , now
                                , 91
                                , data[1]
                            );
                            // 監視処理実施[平均血圧(92)]
                            checkNTSSHostWatchInfo(
                                  packetInfo
                                , now
                                , 92
                                , data[2]
                            );
                            // 監視処理実施[脈拍(93)]
                            checkNTSSHostWatchInfo(
                                  packetInfo
                                , now
                                , 93
                                , data[3]
                            );
                        }

                        // 体温測定である場合
                        //  コード=0x02(体温測定)
                        if( code == 0x02 )
                        {
                            // 監視処理実施[体温(94)]
                            checkNTSSHostWatchInfo(
                                  packetInfo
                                , now
                                , 94
                                , data[0]
                            );
                        }

                        // 再循環率測定である場合
                        //  コード=0x06(再循環率測定)
                        if( code == 0x06 )
                        {
                            // 監視処理実施[再循環率測定(89)]
                            checkNTSSHostWatchInfo(
                                  packetInfo
                                , now
                                , 89
                                , data[0]
                            );
                        }
                    }

                    // FN通信電文ファイルを作成する
                    ret = outputNTSSDataFile(
                          packetInfo
                        , capInfo->cOutputType
                        , capInfo->cCommandId
                        , NULL
                        , NULL
                        , NULL
                        , cCmd
                        , cmdLength
                    );

                    // モニタデータ監視ファイル出力
                    outputNTSSHostWatchInfo(
                          packetInfo
                        , now
                    );
                }
                else
                {
                    // 以外の場合

                    // ログ記録
                    sprintf( 
                          clog
                        , "その他[%s]受信"
                        , cCmdNoHex
                    );

                    // NT通信：装置記録(ログ)判定
                    if( cCmdNo[0] == 0x00 && cCmdNo[1] == 0x05 )
                    {
                        // 種別、コード
                        u_char kind = cCmd[nHeaderSize + 4];
                        u_char code = cCmd[nHeaderSize + 5];

                        // ログ記録
                        sprintf( 
                            clog
                            , "装置記録[%s]受信, kind:%02x / code:%02x"
                            , cCmdNoHex
                            , kind
                            , code
                        );
                    }
                    outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, packetInfo );
                    printf( "%s\n", clog );

                    // FN通信電文ファイルを作成する
                    ret = outputNTSSDataFile(
                          packetInfo
                        , capInfo->cOutputType
                        , capInfo->cCommandId
                        , NULL
                        , NULL
                        , NULL
                        , cCmd
                        , cmdLength
                    );
                }

                // 電文識別子による判定(大文字小文字区別しない)
                if( strncasecmp( capInfo->cCommandId, "LOG", 3 ) == 0 )
                {
                    // 装置記録(LOG)の場合
                    // SMS通知用FN通信電文ファイルを作成する
                    ret = outputNTSSDataFile(
                        packetInfo
                        , capInfo->cOutputType
                        , capInfo->cCommandId
                        , NULL
                        , ".sms"
                        , NULL
                        , cCmd
                        , cmdLength
                    );
                }
            }

            // 治療中判定
            packetInfo->isDialysis[0] = (*( cCmd + nHeaderSize - 2 ) & 0x01);
            if( packetInfo->isDialysis[0] != packetInfo->isDialysis[1] 
              && 0 < packetInfo->nMoniDataSize )
            {
                // 透析開始/終了を検出しモニタデータがある場合

                u_char *cCommandId;
                u_char *cDialText;

                // 治療開始/終了時判定
                if( packetInfo->isDialysis[0] == 0x01 )
                {
                    // 透析開始時
                    cCommandId = "MONS";
                    cDialText = "透析開始";

                    // 保持モニタデータでの透析開始ファイル出力判定
                    bool bOut = false;
                    // 工程判定
                    switch( packetInfo->cCommType )
                    {
                        case NTSS_COMM_TYPE_NEW:    // 新通信
                            if( packetInfo->nProcess[0] == 0x11 ) {
                                // 工程が11:運転となっている
                                bOut = true;
                            }
                            break;

                        case NTSS_COMM_TYPE_NX:     // NX通信
                            switch( cDeviceNo[0] )
                            {
                                case 'A':   // DAB
                                    if( packetInfo->nProcess[0] == 0x01
                                      || packetInfo->nProcess[0] == 0x02 ) {
                                        // 工程が1:透析/2:予備透析となっている
                                        bOut = true;
                                    }
                                    break;

                                case 'D':   // DAD
                                    if( packetInfo->nProcess[0] == 0x01
                                      || packetInfo->nProcess[0] == 0x02
                                      || packetInfo->nProcess[0] == 0x03
                                      || packetInfo->nProcess[0] == 0x04 ) {
                                        // 工程が1:給水/2:循環/3：移送待機/4:移送となっている
                                        bOut = true;
                                    }
                                    break;

                                case 'R':   // DRO
                                    if( packetInfo->nProcess[0] == 0x00
                                      || packetInfo->nProcess[0] == 0x01) {
                                        // 工程が0:通常運転、1:夜間運転となっている
                                        bOut = true;
                                    }
                                    break;
                            }
                            break;
                    }
                    if( ! bOut ) {
                        // 保持しているモニタデータを出力済みとする(次回のモニタデータの受信を待つ)
                        packetInfo->isMoniOutput = 0x01;

                        // 次回受信するモニタデータを初回とする(積算処理をしない)
                        packetInfo->isFirstMoniData = 0x01;
                    }

                    // 透析開始日時を設定
                    time(&packetInfo->dialysisStartTime);

                    // モニタ出力日時を初期化
                    packetInfo->moniOutputTime = 0;
                }
                else
                {
                    // 透析終了時
                    cCommandId = "MONF";
                    cDialText = "透析終了";

                    // 透析終了日時を設定
                    time(&packetInfo->dialysisFinishTime);

                    // モニタ出力日時を初期化
                    packetInfo->moniOutputTime = 0;

                    // モニタ更新禁止
                    packetInfo->isStopUpMoniData = 0x01;

                    // ホスト報知監視状態初期化(0x00：監視していない/0x01：監視中)
                    packetInfo->isWatch = 0x00;
                }

                // ログ記録
                sprintf(
                        clog
                    , "%s検出,装置:%s%s"
                    , cDialText
                    , cDeviceType
                    , cDeviceNo
                );
                outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, packetInfo );
                printf( "%s\n", clog );
/*
                // FN通信電文ファイルを作成する
                ret = outputNTSSDataFile(
                      packetInfo
                    , NTSS_OUTPUT_FOLDER_DATA_COLLECT
                    , cCommandId
                    , NULL
                    , NULL
                    , NULL
                    , packetInfo->cMoniData
                    , packetInfo->nMoniDataSize
                );
*/
                //　治療状態を保持
                packetInfo->isDialysis[1] = packetInfo->isDialysis[0];
            }
        }
        else
        {
            // 電文なし/チェックサム異常の場合は処理中止

            ret = intres;

            break;
        }

    }    

    return ret;
}

//@}
