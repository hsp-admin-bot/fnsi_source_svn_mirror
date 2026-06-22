/**
* @brief NTSS通信共通プロトコル処理ファイル
*
* @details NTSSでの通信共通プロトコル処理を行う
*
* @description ntss program
* Copyright (C) 2018, TDC, all right reserved.
*
* @file ntss_common_comm.c
* @author H.Yonezawa
* @date 2018/10/15
*/

/*　必要な機能
*   ・先頭が特定文字、末尾のデータにCRLFが含まれているかどうかをチェックする
*   ・コマンドが見つかった場合、チェックサム判定を実施
*/


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <time.h>
#include <sys/time.h>
#include <limits.h>

#include <netinet/in.h>

#include "ntss_devicecap_conf.h"
#include "ntss_common_comm.h"
#include "ntss_packet_manage.h"
#include "ntss_packet_file.h"

#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/ntss_etc_lib.h"
#include "../common/libs/ntss_mst_lib.h"
#include "../common/nkklib/nkklib.h"



/// @name 通信共通プロトコルV3用モニタ定数
//@{

/// 通信共通プロトコルV3用モニタ項目設定
struct NTSS_COMMON_V3_DATA
{
    u_char  cID;        // データ識別コード
    u_char  cLength;    // データサイズ
    short   nDataNo;    // 新通信モニタ項目番号(or 警報ログコード)
} V3_MONI_DATA[] = {
    { 'M', 1, 0 },      // 治療中フラグ(工程)
    { 'K', 5, 1 },      // 治療経過時間(経過時間)[min]
    { 'B', 5, 5 },      // 現在除水量(除水積算値)[L]
    { 'C', 5, 6 },      // 除水速度[L/hr]
    { 'D', 5, 8 },      // 血液流量(血流量)[mL/min]
    { 'W', 5, 9 },      // シリンジポンプ積算値(IP総量)[ml]
    { 'E', 5, 10 },     // シリンジポンプ速度(IP速度)[mL/hr]
    { 'H', 5, 11 },     // 静脈圧[mmHg]
    { 'I', 5, 12 },     // 透析液圧[mmHg]
    { 'J', 5, 13 },     // TMP[mmHg]
    { 'G', 5, 19 },     // 透析液濃度[mS/cm]
    { 'F', 5, 21 },     // 透析液温度[℃]
    { 'L', 5, 22 },     // 透析液流量[mL/min]
    { 'N', 1, 31 },     // 治療モード(装置モード)
    { 'A', 5, 32 },     // 目標除水量[L]
    { 'O', 5, 70 },     // 目標補液量(補液設定値)[L]
    { 'Q', 5, 71 },     // 補液速度[L/hr]
    { 'P', 5, 72 },     // 現在補液量(補液経過値)[L]
    { 'R', 5, 74 },     // 補液温度[℃]
    { 'T', 5, 90 },     // 最高血圧[mmHg]
    { 'U', 5, 91 },     // 最低血圧[mmHg]
    { 'V', 5, 93 },     // 脈拍[bpm]
    { 'S', 6, 100 },    // 血圧測定時刻
    { 'a', 1, 110 },    // 液温警報発生[0x9f00]
    { 'b', 1, 111 },    // 濃度警報発生[0x9f01]
    { 'c', 1, 112 },    // 静脈圧警報発生[0x9f02]
    { 'd', 1, 113 },    // 液圧警報発生[0x9f03]
    { 'e', 1, 114 },    // TMP警報発生[0x9f04]
    { 'f', 1, 115 },    // 気泡検出警報発生[0x9f05]
    { 'g', 1, 116 },    // 漏血警報発生[0x9f06]
    { 'h', 1, 117 },    // その他警報発生[0x9f07]
    { 'i', 1, 118 }     // 血圧警報発生[0x9f08]
};
#define NTSS_V3_MONI_DATA_LEGTH 32

// @}

/// @name 通信共通プロトコルV3用モニタ定数
//@{

/// 通信共通プロトコルV4用モニタ項目設定
struct NTSS_COMMON_V4_DATA
{
    u_char  cID[3];     // データ識別コード
    u_char  cLength;    // データサイズ
    short   nDataNo;    // 新通信モニタ項目番号
} V4_MONI_DATA[] = {
    { "CM", 1, 0 },     // 治療中フラグ(工程)
    { "CK", 4, 1 },     // 治療経過時間(経過時間)[min]
    { "CB", 4, 5 },     // 現在除水量(除水積算値)[L]
    { "DD", 4, 6 },     // 除水速度[L/hr]
    { "DE", 3, 8 },     // 血液流量(血流量)[mL/min]
    { "DF", 4, 9 },     // シリンジポンプ積算値(IP総量)[ml]
    { "CH", 4, 11 },    // 静脈圧[mmHg]
    { "CI", 6, 12 },    // 透析液圧[mmHg]
    { "CJ", 4, 13 },    // TMP[mmHg]
    { "DI", 4, 14 },    // ダイアライザ血液入り口圧[mmHg]   
    { "DH", 4, 19 },    // 透析液濃度[mS/cm]
    { "DG", 4, 21 },    // 透析液温度[℃]
    { "CL", 4, 22 },    // 透析液流量[mL/min]
    { "CN", 1, 31 },    // 治療モード(装置モード)
    { "CA", 4, 32 },    // 目標除水量[L]
    { "CC", 4, 33 },    // 除水速度(設定値)
    { "CF", 4, 34 },    // 透析液温度(設定値)
    { "CD", 3, 36 },    // 血液流量(設定値)
    { "CE", 4, 37 },    // シリンジポンプ速度(設定値)
    { "CO", 4, 70 },    // 目標補液量(補液設定値)[L]
    { "CQ", 4, 71 },    // 補液速度[L/hr]
    { "CP", 4, 72 },    // 現在補液量(補液経過値)[L]
    { "DK", 4, 74 },    // 補液温度(現在値)[℃]
    { "CR", 4, 75 },    // 補液温度(設定値)[℃]
    { "CG", 4, 200 },   // 透析液濃度(設定値)[mS/cm]：小数点以下1桁？
    { "DJ", 4, 201 },   // 脱血圧(動脈圧)[mmHg]：整数？
    { "DL", 2, 202 },   // I-HDF補液回数[回]：整数？
    { "DM", 4, 203 },   // I-HDF相補液量[mL]:整数？
    { "DN", 4, 204 },   // 緊急総補液量[mL]：整数？
    { "DA", 14, 300 },  // 現在日時(yyyymmddhhnnss)
    { "DB", 14, 301 },  // 治療開始日時(yyyymmddhhnnss)
    { "DC", 14, 302 },  // 治療終了日時(yyyymmddhhnnss)
};
#define NTSS_V4_MONI_DATA_LEGTH 32

// @}


/// @name 通信共通プロトコル処理関連
//@{
/**
* @brief 対象バッファ情報から通信共通プロトコルの電文を取得する
*
* @details 対象バッファから通信共通プロトコルの電文を取得する
*
* @description
* @param[in] *packetInfo    バッファ情報
* @param[out] *cmd          取得したコマンド(チェックサム、CRLF除去済み)
* @param[out] cmdLength     取得したコマンドサイズ
* @return 1：電文取得/0：電文なし/-1：チェックサム異常
* @attention 特になし
*/
int
getNTSSCommonCommand( struct NTSS_BUFFER *bufferInfo
                    , u_char *cmd
                    , int *cmdLength
                    )
{
    int ret = 0;
    int nidx = -1;
    int intlop;
    int nsize;
    u_char csum = 0;
    u_char checksum[3];

    // バッファ内にデータがあるかどうか
    if( 3 <= bufferInfo->nBufferSize )
    {
        // バッファの先頭がSTXかどうか確認
        int intlop;
        u_char cstx = 0;
        for( intlop = 0; intlop < NTSS_COMMON_STX_COUNT; intlop++ )
        {
            if( bufferInfo->cBuffer[0] == NTSS_COMMON_STX[intlop] )
            {
                // STXあり
                cstx = 0x01;
                break;
            }

        }

        if( cstx == 0x01 )
        {
            // 先頭がSTX

            // ETX検索
            for( intlop = 1; intlop < bufferInfo->nBufferSize; intlop++ )
            {
                // LF検索
                if( bufferInfo->cBuffer[intlop] == NTSS_COMMON_LF)
                {
                    // LFあり
        
                    // CR検索
                    if( bufferInfo->cBuffer[intlop - 1] == NTSS_COMMON_CR)
                    {
                        // CRあり

                        // ETXあり
                        nidx = intlop;

                        break;
                    }
                }
            }

            // ETXが検出された場合
            if( 1 < nidx )
            {
                nidx++;

                // STX〜SUMのデータを抜き出し
                nsize = nidx - 2;
                u_char cwork[nsize];
                memmove( cwork, bufferInfo->cBuffer, nsize );

                // バッファを詰める
                memmove( bufferInfo->cBuffer, bufferInfo->cBuffer + nidx, bufferInfo->nBufferSize - nidx );
        
                // バッファサイズ更新
                bufferInfo->nBufferSize -= nidx;

                // サムチェック算出処理
                for( intlop = 0; intlop < nsize - 2; intlop++ )
                {
                    csum += cwork[intlop];
                }
                // HEX文字列化
                sprintf(
                      checksum
                    , "%02x"
                    , csum
                );
                // サムチェック判定
                if( memcmp( &cwork[nsize - 2], checksum, 2 ) == 0 )
                {
                    // OK
                    ret = 1;

                    // サムチェックを除いたコマンドサイズを算出
                    nsize -= 2;

                    // 取得したコマンドをコピー
                    memmove( cmd, cwork, nsize );
                    *cmdLength = nsize;
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
* @brief 指定したモニタデータをモニタ項目番号のデータ精度に合わせて変換する
*
* @details 指定したモニタデータをモニタ項目番号のデータ精度に合わせて変換する
*
* @description
* @param[in]    cID         // モニタ項目番号[0〜]
* @param[in]    *cData      // モニタデータ
* @return 変換後のshortデータ
* @attention 特になし
*/
short
getNTSSCommonMonitorData( short nMoniNo
                        , u_char *cData
                        )
{
    short ret = SHRT_MIN;

    // モニタ項目取得
    struct moni_list info;
    info.dec = 0;
    ntss_mst_moni_data( 0, "00", nMoniNo, &info );

// // モニタ項目一覧
// struct moni_list {
// 	char	id;			// 識別
// 	char	ver[2];		// 装置バージョン番号
// 	short	addr;		// アドレス番号
// 	char	type;		// データ種類
// 	short 	dec;		// 小数点以下桁数
// 	char 	add;		// 積算有無
// };

    // 通信共通V4、200：透析液濃度(設定値)の場合
    if( nMoniNo == 200 )
    {
        // 小数点以下桁数を1とする
        info.dec = 1;
    }

    int nValSize = 0;
    u_char cbuff[10];
    u_char cSign = 0;
    u_char cPoint = 0;
    u_char cStr;
    double dRate = 1.0;
    int intlop;

    // 掛率作成
    for( intlop = 0; intlop < info.dec; intlop++ )
    {
        dRate *= 10;
    }

    // 文字列整形
    memset( cbuff, 0, sizeof( cbuff ));
    for( intlop = 0; intlop < strlen(cData); intlop++ )
    {
        cStr = cData[intlop];
        if( cStr == '-' )
        {
            cSign = 1;
        }
        else if( '0' <= cStr && cStr <= '9' )
        {
            cbuff[nValSize] = cStr;
            nValSize++;
        }
        else if( cStr == '.' && cPoint == 0 )
        {
            cbuff[nValSize] = cStr;
            nValSize++;
            cPoint = 1;
        }
    }

    // 文字列数値化
    if( 0 < nValSize )
    {
        double dVal = atof( cbuff );
        dVal *= dRate;
        int nVal = dVal;
        if( SHRT_MAX < nVal )
        {   
            nVal = SHRT_MAX;                                    
        }
        else if( nVal < SHRT_MIN ) 
        {
            nVal = -SHRT_MIN;
        }
        ret = nVal;
        if( cSign == 1 )
        {
            ret = (short)(0 - ret);
        }
    }
    
    return ret;
}
/**
* @brief 指定した時分秒文字列が有効かどうかを判定する
*
* @details 指定した時分秒文字列が有効かどうかを判定する
*
* @description
* @param[in]    *cTime      // 時分秒文字列(HHMMSS)
* @return 0：無効/1：有効
* @attention 特になし
*/
int 
checkNTSSCommonBloodTime( u_char *cTime 
                        )
{
    int ret = 0;

    // HH(00-23)
    if(('0' <= cTime[0] && cTime[0] <= '1' && '0' <= cTime[1] && cTime[1] <= '9' )
    || ( '2' == cTime[0] && '0' <= cTime[1] && cTime[1] <= '3' ))
    {
        // MM(00-59)
        if( '0' <= cTime[2] && cTime[2] <= '5' && '0' <= cTime[3] && cTime[3] <= '9' )
        {
            // SS(00-59)
            if( '0' <= cTime[2] && cTime[2] <= '5' && '0' <= cTime[3] && cTime[3] <= '9' )
            {
                ret = 1;
            }
        }
    }

    return ret;
}
/**
* @brief 対象パケット管理情報で通信共通プロトコルのモニタデータ登録処理を行う
*
* @details 対象パケット管理情報で通信共通プロトコルのモニタデータ登録処理を行う
*
* @description
* @param[in] *cCmd          コマンド
* @param[in] *packetInfo    パケット管理情報
* @param[in] dtNow          パケット受信日時
* @param[in] nAddr          モニタ項目番号
* @param[in] nData          モニタデータ
* @return なし
* @attention 特になし
*/
void 
// mod FNSI-Redmine＃3099/＃3100:（V3/V4）仕様に無い治療モードの場合に正しく変換して送信されない。 高 start
// setNTSSCommonMonitorData( struct NTSS_PACKET_INFORMATION *packetInfo
setNTSSCommonMonitorData( u_char * cCmd
                        , struct NTSS_PACKET_INFORMATION *packetInfo 
// mod FNSI-Redmine＃3099/＃3100:（V3/V4）仕様に無い治療モードの場合に正しく変換して送信されない。 高 end
                        , struct timeval dtNow
                        , short nAddr
                        , short nData
                        )
{
    // 治療中フラグの場合
    if( nAddr == 0 )
    {
        // 治療中状態
        // add 強制オフライン 高 start
        if( packetInfo->force_flg != 1 ) {
        // add 強制オフライン 高 end
            packetInfo->isDialysis[0] = nData;
        }

        // 治療中判定
        if( nData == 1 )
        {
            // 治療中
            nData = 11;
        }
        else
        {
            // 排液（準備回収として扱う）
            nData = 7;
        }
        // add FNSI-バグ 通信サーバ #9519 高 start
        if( packetInfo->force_flg == 1 )
        {
            nData = packetInfo->nProcess[0];
        }
        // add FNSI-バグ 通信サーバ #9519 高 end

        // 現在の工程を設定
        // add 強制オフライン 高 start
        if( packetInfo->force_flg != 1 ) {
        // add 強制オフライン 高 end
            packetInfo->nProcess[0] = nData;
        }
    }

    // 治療モード
    if ( nAddr == 31 ) {
// mod FNSI-Redmine＃3099/＃3100:（V3/V4）仕様に無い治療モードの場合に正しく変換して送信されない。 高 start
        //switch( nData )
        //{
        //    case 4: // OHDF
                // 日機装装置：OHDF
        //        nData = 7;
        //        break;
        //    case 5: // I-HDF
                // 日機装装置：プログラム補液
        //        nData = 10;
        //        break;
        //    case 6: // O/I-HDF
        //    case 7: // 予備
        //        nData = 0x20;
        //       break;
        //}
        
        if( cCmd[0] == 'S')   // S4
        {
            switch( nData )
            {
                case 0: // HD
                case 1: // ECUM
                case 2: // HDF
                case 3: // HF
                    break;
                case 4: // OHDF
                    // OHDF
                    nData = 7;
                    break;
                case 5: // I-HDF
                    // 日機装装置：I-HDF
                    nData = 10;
                    break;
                default: // これ以外
                    nData = 0x20;
                    break;
            }
        }
        else
        {   // K3
            // しない
        }
// mod FNSI-Redmine＃3099/＃3100:（V3/V4）仕様に無い治療モードの場合に正しく変換して送信されない。 高 end
    }


    u_char cCopy = 1;

    // 治療中の初回モニタデータ判定
    if( packetInfo->isDialysis[0] == 0x01
        && packetInfo->isFirstMoniData == 0x00 )
    {
        // 治療中で初回ではない場合

        // 積算処理判定
        u_short cAdd =ntss_mst_moni_addup(
              packetInfo->cDeviceFormat
            , "00"
            , nAddr
        );
        if( cAdd == 1 )
        {
            // 積算処理あり

            // 最新値が0x8000、又は0x0000の場合はコピーしない
            if( nData == SHRT_MIN || nData == 0x0000 )
            {
                cCopy = 0x00;
            }
        }
    }

    // データコピー有無判定
    if( packetInfo->isStopUpMoniData == 0x01
      || ( packetInfo->isDialysis[1] == 0x01 && packetInfo->isDialysis[1] != packetInfo->isDialysis[0]))
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
        memmove( packetInfo->cMoniData + nAddr * 2, &nData, 2 );

        // ホスト通知監視中
        if( packetInfo->isWatch == 0x01 )
        {
            // ホスト通知監視実施

            // モニタ項目が最高血圧[90]、最低血圧[91]、平均血圧[92]、脈拍[93]の以外の場合
            if(! ( 90 <= nAddr && nAddr <= 93 ))
            {
                // ホスト通知監視処理実施
                checkNTSSHostWatchInfo(
                      packetInfo
                    , dtNow
                    , nAddr
                    , nData
                );
            }
        }
    }

    return;
}
/**
* @brief 対象パケット管理情報で通信共通プロトコルの血圧測定ファイル出力処理を行う
*
* @details 対象パケット管理情報で通信共通プロトコルの血圧測定ファイル出力処理を行う
*
* @description
* @param[in] *packetInfo    パケット管理情報
* @param[in] dtNow          パケット受信日時
* @param[in] cKind
* @param[in] cCode
* @param[in] nOccurDate
* @param[in] nOccurTime
* @param[in] nMax
* @param[in] nMin
* @param[in] nAve
* @param[in] nBpm
* @return 1：保存成功0：保存不要/−2：フォルダ作成失敗/-3:ファイル作成失敗
* @attention 特になし
*/
int 
outputNTSSCommonBloodLog( struct NTSS_PACKET_INFORMATION *packetInfo 
                        , struct timeval dtNow
                        , u_char cKind
                        , u_char cCode
                        , long nOccurDate
                        , long nOccurTime
                        , short nMax
                        , short nMin
                        , short nAve
                        , short nBpm
                        )
{
    int ret = 0;
    u_char clog[NTSS_STR_MAX_SIZE];
    u_char cbuff[ NTSS_STR_MAX_SIZE ];

    // ログ記録
    sprintf( 
          clog
        , "血圧測定検出, kind:%02x, code:%02x, (%d,%d,%d,%d)"
        , cKind
        , cCode
        , nMax
        , nMin
        , nAve
        , nBpm
    );
    outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, packetInfo );
    printf( "%s\n", clog );
    
    // 監視処理実施[最高血圧(90)]
    checkNTSSHostWatchInfo(
        packetInfo
        , dtNow
        , 90
        , nMax
    );
    // 監視処理実施[最低血圧(91)]
    checkNTSSHostWatchInfo(
        packetInfo
        , dtNow
        , 91
        , nMin
    );
    // 監視処理実施[平均血圧(92)]
    checkNTSSHostWatchInfo(
        packetInfo
        , dtNow
        , 92
        , nAve
    );
    // 監視処理実施[脈拍(93)]
    checkNTSSHostWatchInfo(
        packetInfo
        , dtNow
        , 93
        , nBpm
    );

    // 保存データ作成
    memset( cbuff, 0, 32 );
    //  0:通信フォーマット[1]
    cbuff[0] = packetInfo->cDeviceFormat;
    //  1:製造番号[7]
    memmove(cbuff + 1, packetInfo->cDeviceNo, 7);
    //  8:シーケンスNo[1](0x00)
    //cbuff[8] 
    //  9:コマンド[1](0x66)
    cbuff[9] = 0x66;
    //  10:装置ステータス[2]
    //cbuff[10]
    cbuff[11] |= packetInfo->isDialysis[0];
    //  12:データ[20]
    //      12:ログシーケンスNo[1](0x00)
    //cbuff[12]
    //      13:種別[1](0x01)
    cbuff[13] = cKind;
    //      14:コード[1]？
    cbuff[14] = cCode;
    //      15:発生日時[4](BCD)
    //cbuff[15]　
    bintobcd(nOccurDate, 8, cbuff + 15);
    //      19:発生時刻[3](BCD)
    //cbuff[19]
    bintobcd(nOccurTime, 6, cbuff + 19);
    //      22:発生透析時間[2]
    //cbuff[22]
    //cbuff[23]
    //      24:関連データ1[2](最高血圧)
    nMax = hl_chg( nMax );
    memmove( cbuff + 24, &nMax, 2 );
    //      26:関連データ2[2](最低血圧)
    nMin = hl_chg( nMin );
    memmove( cbuff + 26, &nMin, 2 );
    //      28:関連データ3[2](平均血圧)
    nAve = hl_chg( nAve );
    memmove( cbuff + 28, &nAve, 2 );
    //      30:関連データ4[2](脈拍)
    nBpm = hl_chg( nBpm );
    memmove( cbuff + 30, &nBpm, 2 );
 
    // FN通信電文ファイルを作成する   
    ret = outputNTSSDataFile(
          packetInfo
        , 0x01
        , "LOG"
        , NULL
        , NULL
        , &dtNow
        , cbuff
        , 32
    ); 
    
    // モニタデータ監視ファイル出力
    outputNTSSHostWatchInfo(
          packetInfo
        , dtNow
    );

    return ret;
}

/**
* @brief 対象パケット管理情報で通信共通プロトコルの通信処理を行う
*
* @details 対象パケット管理情報で通信共通プロトコルの通信処理を行う
*
* @description
* @param[in] *packetInfo    パケット管理情報
* @return 1：対象電文あり/0：対象電文なし/-1：チェックサム異常/−2：フォルダ作成失敗/-3:ファイル作成失敗
* @attention 特になし
*/
int
checkNTSSCommonCommand( struct NTSS_PACKET_INFORMATION *packetInfo )
{
    int ret = 0;

    u_char cCmd[2048];
    u_char clog[ NTSS_STR_MAX_SIZE ];
    u_char cbuff[ NTSS_STR_MAX_SIZE ];
    int cmdLength;
    int intres;
    int intlop;
    // #8468 del 2023.03.16 通信共通V4での警報/報知状態を通知しないため削除 TDC米沢 start
    // // add 装置のSTATUS状態更新方法の変更 高 start
    // bool machineStatusFlag = false;
    // bool machineNotifyStatusFlag = false;
    // // add 装置のSTATUS状態更新方法の変更 高 end
    bool machineStatusFlag = false;
    // #8468 del 2023.03.16 通信共通V4での警報/報知状態を通知しないため削除 TDC米沢 end
    
    // バッファ内の電文分繰り返す
    while( true )
    {
        // バッファの先頭がSTXになるまでバッファ内の情報を前に詰める
        UpdateNTSSPacketInfoBuffer( &packetInfo->buffer, NTSS_COMMON_STX, NTSS_COMMON_STX_COUNT );
    
        //  STX〜ETX検出
        //  チェックサム判定
        intres = getNTSSCommonCommand( &packetInfo->buffer, cCmd, &cmdLength);
        printf( " getNTSSCommonCommand:%d\n", ret );
        if( intres == 1 )
        {
            cCmd[cmdLength] = 0;

            u_char cDeviceType[4];
            u_char cDeviceNo[10];
            u_char cDataLength[4];
            int nHeaderSize = 5;
            int nDataLength;

            // 型式コード
            memmove( cDeviceType, packetInfo->cDeviceType, 3 );
            cDeviceType[3] = 0;

            // 通信フォーマット+製造番号
            memmove( cDeviceNo, &packetInfo->cDeviceFormat, sizeof( packetInfo->cDeviceFormat ) + sizeof( packetInfo->cDeviceNo ));
            cDeviceNo[9] = 0;
            // 末尾の空白を除去
            trimEnd( cDeviceNo, ' ' );

            // データ長
            cDataLength[0] = cCmd[2];
            cDataLength[1] = cCmd[3];
            cDataLength[2] = cCmd[4];
            cDataLength[3] = 0;
            nDataLength = atoi( cDataLength );


            // ファイル名作成
            char cfile[NTSS_STR_MAX_SIZE];
            // ※collect_[作成年月日時分秒マイクロ秒]_comm.TXT
            sprintf( cfile, "collect" );
            


            // debug
            printf(" command model:%s / deviceNo:%s / cmd:%s / size:%d / datasize:%d\n", cDeviceType, cDeviceNo, cCmd, cmdLength, nDataLength);

            // パケット受信日時時刻取得(マイクロ秒含む)
            struct timeval now;
            struct tm tmnow;
            memmove( &now, &(packetInfo->buffer.lastReceiveTime), sizeof( now ));
            // 発生日時作成
            localtime_r( &now.tv_sec,  &tmnow );
            u_char cNow[20];
            sprintf( 
                  cNow
                , "%04d%02d%02d%02d%02d%02d"
                , tmnow.tm_year + 1900
                , tmnow.tm_mon + 1
                , tmnow.tm_mday
                , tmnow.tm_hour
                , tmnow.tm_min
                , tmnow.tm_sec
            );

            printf("** 装置コマンド[%c%c]受信!! **\n", cCmd[0], cCmd[1]);

            // 通信共通V3
            //  S3：条件送信[装置から送られてこないため未実装]
            //  K3：モニタ読み出し
            //  R3：正常応答
            //  E3：異常応答

            // 通信共通V4
            //  S4：装置からの送信コマンド
            //  R4：正常応答
            //  E4：異常応答

            // モニタデータ判定
            if( memcmp( cCmd, "K3", 2 ) == 0 
             || ( memcmp( cCmd, "S4", 2 ) == 0 && memcmp( cCmd + 17, "MS", 2 ) == 0 ))
            {
                // モニタデータ受信

                // モニタ受信日時を保持
                memmove( &(packetInfo->dtMoni), &now , sizeof( now ));
                // モニタ出力フラグを初期化
                packetInfo->isMoniOutput = 0x00;

                // 監視待ち時間チェック
                if( 0 <= packetInfo->watchWaitTime )
                {
                    // 監視待ち時間が有効な場合

                    // 透析中のモニタデータ監視が行われていない場合
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

            u_char cDialStartDate[11];
            u_char cDialStartTime[10];
            u_char cDialFinishDate[11];
            u_char cDialFinishTime[10];
            cDialStartDate[0]  = cDialStartTime[0]  = 0;
            cDialFinishDate[0] = cDialFinishTime[0] = 0;

            // 電文種類の判定
            if( cCmd[1] == '3' )
            {
                // 血圧測定、警報発生検出を初期化[0〜8：警報発生/9：血圧測定]
                u_char cAlarm[10];
                memset( cAlarm, 0, sizeof( cAlarm ));

                int nidx = 0;
                int intlop = 0;
                int intlop2 = 0;

                // 通信共通V3
                switch( cCmd[0] )
                {
                    case 'S':   // S3
                    case 'R':   // R3
                    case 'E':   // E3
                        ret = 1;
                        break;

                    case 'K':   // K3
                        // モニタデータ
                        for( intlop = nHeaderSize; intlop < cmdLength; intlop++ )
                        {
                            // モニタ項目判定
                            for( intlop2 = 0; intlop2 < NTSS_V3_MONI_DATA_LEGTH; intlop2++ )
                            {
                                // データ識別コード判定
                                if( cCmd[intlop] == V3_MONI_DATA[intlop2].cID )
                                {
                                    // 一致

                                    intlop++;
                                    short nAddr = V3_MONI_DATA[intlop2].nDataNo;

                                    // データ取得
                                    memmove( cbuff, cCmd + intlop, V3_MONI_DATA[intlop2].cLength );
                                    cbuff[ V3_MONI_DATA[intlop2].cLength ] = 0;
                                    intlop += V3_MONI_DATA[intlop2].cLength;

                                    // debug
                                    sprintf(
                                          clog    
                                        , "ID:%c(%03d) - %s"
                                        , V3_MONI_DATA[intlop2].cID
                                        , V3_MONI_DATA[intlop2].nDataNo
                                        , cbuff
                                    );

                                    // 項目判定
                                    if( nAddr == 100 )
                                    {
                                        // 血圧測定の場合

                                        // 血圧測定時刻の有効、及び変化判定
                                        if( checkNTSSCommonBloodTime( cbuff ) == 1 
                                          && memcmp( packetInfo->cMoniData + 490 , cbuff, 6) != 0 )
                                        {
                                            // 血圧測定時刻を保持
                                            memmove( packetInfo->cMoniData + 490, cbuff, 6 + 1 );

                                            // 血圧測定を記録
                                            cAlarm[9] = 1;
                                        }
                                    }
                                    else if( 110 <= nAddr && nAddr <= 118 )
                                    {
                                        // 警報発生の場合

                                        // 警報発生判定
                                        if( cbuff[0] == '1' )
                                        {
                                            // add 装置のSTATUS状態更新方法の変更 高 start
                                            packetInfo->machineState |= 0x08;
                                            machineStatusFlag = true;
                                            // add 装置のSTATUS状態更新方法の変更 高 end
                                            // 警報発生中

                                            // 変化判定
                                            if( packetInfo->cMoniData[ 500 - nAddr - 110] != cbuff[0] )
                                            {
                                                // 警報発生を記録
                                                cAlarm[ nAddr - 110 ] = 1;
                                            }
                                        }

                                        // 今回の発生状態を保持
                                        packetInfo->cMoniData[ 500 - nAddr - 110 ] = cbuff[0];
                                    }
                                    else
                                    {
                                        // モニタの場合

                                        // テキスト→数字化
                                        short sdata = getNTSSCommonMonitorData( nAddr, cbuff );

                                        // debug
                                        sprintf(
                                              clog + strlen( clog )
                                            , " -> %d"
                                            , sdata
                                        );

                                        // モニタデータ登録処理
                                        // mod FNSI-Redmine＃3099/＃3100:（V3/V4）仕様に無い治療モードの場合に正しく変換して送信されない。 高 start
                                        // setNTSSCommonMonitorData( packetInfo, now, nAddr, sdata );
                                        setNTSSCommonMonitorData( cCmd, packetInfo, now, nAddr, sdata );
                                        // mod FNSI-Redmine＃3099/＃3100:（V3/V4）仕様に無い治療モードの場合に正しく変換して送信されない。 高 end
                                    }

                                    // debug
                                    printf( "%s\n", clog );

                                    intlop--;
                                    break;
                                }
                            }
                        }
                        
                        // モニタデータサイズを更新
                        packetInfo->nMoniDataSize = 1;

                        // 初回モニタデータ指示を解除
                        packetInfo->isFirstMoniData = 0x00;

                        // 工程変化を判定
                        if( packetInfo->nProcess[0] != packetInfo->nProcess[1] )
                        {
                            // 工程通知を依頼
                            packetInfo->isNeedSendProcess = 0x01;
                        }

                        u_char cKind = 0;
                        u_char cCode = 0;
                        u_char cStatus[5];
                        memmove( cStatus, "0008\0", 5 );
                        cStatus[3] += packetInfo->isDialysis[0];
                        
                        // add 装置のSTATUS状態更新方法の変更 高 start
                        if( packetInfo->isDialysis[0] == 0x01)
                            packetInfo->machineState |= 0x01;
                        else
                            packetInfo->machineState &= 0xFE;
                        // add 装置のSTATUS状態更新方法の変更 高 end

                        // 警報発生、血圧測定
                        for( intlop = 0; intlop < 10; intlop++ )
                        {
                            // 発生/測定判定
                            if( cAlarm[ intlop ] == 1 )
                            {
                                // 種別判定
                                if(intlop < 9 )
                                {
                                    // 警報

                                    cKind = 0x9f;
                                    cCode = intlop;

                                    // ログ記録
                                    sprintf( 
                                          clog
                                        , "警報発生検出, kind:%02X, code:%02X"
                                        , cKind
                                        , cCode
                                    );
                                    outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, packetInfo );
                                    printf( "%s\n", clog );

                                    // 保存データ作成
                                    sprintf( 
                                          cbuff
                                        // mod FNSI-バグ 通信サーバ 高 start
                                        //, "kind=%s\tfacilitycode=%s\tedgeno=%d\toccurdate=%s\tdevicetype=%s\tserialno=%s\tcomformat=%c\tcomstatus=%s\tclass=%d\tcode=%02X%02X\n"
                                        , "kind=%s\tfacilitycode=%s\tedgeno=%d\toccurdate=%s\tdevicetype=%s\tserialno=%s\tcommformat=%c\tcomstatus=%s\tclass=%d\tcode=%02X%02X\n"
                                        // mod FNSI-バグ 通信サーバ 高 end
                                        , "C-LOG"
                                        , devicecapConf.cFacilityCode
                                        , devicecapConf.nDeviceEdgeNo
                                        , cNow
                                        , cDeviceType
                                        , cDeviceNo + 1
                                        , *cDeviceNo
                                        , cStatus
                                        , 1
                                        , cKind
                                        , cCode
                                    );

                                    // 警報ファイル作成
                                    outputAppendNTSSDataFile(
                                          packetInfo    // パケット管理情報
                                        , 0x01          // データ収集格納先
                                        , cfile         // 先頭ファイル名(collect)
                                        , "_comm.txt"   // 拡張子
                                        , &now          // 日付時刻
                                        , cbuff         // 書き込みデータ
                                        , strlen(cbuff) // 書き込みデータ長
                                    );
                                }
                                else
                                {
                                    // 血圧測定

                                    cKind = 0x01;
                                    cCode = 0x01;

                                    struct tm tmnow;
                                    localtime_r( &now.tv_sec, &tmnow );
                                    sprintf( 
                                         cbuff
                                        , "%04d%02d%02d"
                                        , tmnow.tm_year + 1900
                                        , tmnow.tm_mon + 1
                                        , tmnow.tm_mday
                                    );
                                    long nOccurDate = atol( cbuff );
                                    // mod FNSI-バグ 通信サーバ 高 start
                                    // long nOccurTime = atol( packetInfo->cMoniData + 490 ); 
                                    sprintf( 
                                         cbuff
                                        , "%d%02d%02d"
                                        , tmnow.tm_hour
                                        , tmnow.tm_min
                                        , tmnow.tm_sec
                                    );
                                    long nOccurTime = atol( cbuff );
                                    // mod FNSI-バグ 通信サーバ 高 end

                                    // 最高血圧、最低血圧、脈拍を取得
                                    short nMax = *(short*)(packetInfo->cMoniData + 90 * 2);
                                    short nMin = *(short*)(packetInfo->cMoniData + 91 * 2);
                                    short nBpm = *(short*)(packetInfo->cMoniData + 93 * 2);
                                    
                                    // add FNSI-バグ 通信サーバ 高 start
                                    if(!(nMax == 0 && nMin == 0 && nBpm == 0))
                                    {
                                    // add FNSI-バグ 通信サーバ 高 end

                                        // 平均血圧を算出
                                        short nAve = (nMax + nMin * 2 ) / 3;

                                        // 血圧測定処理
                                        outputNTSSCommonBloodLog( 
                                              packetInfo
                                            , now
                                            , cKind
                                            , cCode
                                            , nOccurDate
                                            , nOccurTime
                                            , nMax
                                            , nMin
                                            , nAve
                                            , nBpm
                                        );
                                    }
                                }
                            }
                        }
                        
                        // add 装置のSTATUS状態更新方法の変更 高 start
                        if( machineStatusFlag == false )    // ステータス（警報OFF）
                            packetInfo->machineState &= ~0x08;
                        // add 装置のSTATUS状態更新方法の変更 高 end

                        ret = 1;

                        break;
                }
            }

            if( cCmd[1] == '4' )
            {
                int nidx = 0;
                int intlop = 0;
                int intlop2 = 0;
                u_char cKind = 0;
                u_char cCode = 0;
                u_char cFreeMsg[NTSS_STR_MAX_SIZE];

                nHeaderSize += 12;

                // 通信共通V4
                switch( cCmd[0] )
                {
                    case 'R':   // R4
                    case 'E':   // E4
                        ret = 1;
                        break;

                    case 'S':   // S4
                        // TC：治療条件         [装置から送られてこないため未実装]
                        // CM：コメントデータ   [装置から送られてこないため未実装]
                        // DT：日時設定         [装置から送られてこないため未実装]

                        // MS：装置状態データ
                        if( memcmp( cCmd + nHeaderSize, "MS", 2 ) == 0 )
                        {
                            nHeaderSize += 2;

                            // #9441 2023.09.15 add ＜[DM:I-HDF 総補液量]が0以外&&有効値、かつ、[CP:現在補液量]が0||無効値＞で「72:補液量現在値」を上書き TDC山崎 start
                            int v4MonDataCount = 0; // v4モニタデータのメモ配列の格納数
                            struct v4_mon_data {
                                short nkkAddr; // v4モニタデータと対応する新通信装置モニタデータアドレス
                                short digitConvertedValue; // v4モニタデータを桁上げ整数化した値
                            } v4MonData[NTSS_V4_MONI_DATA_LEGTH] = {0}; // v4モニタデータのメモ配列
                            int cpPos = -1; // v4モニタデータのメモ配列における[CP:現在補液量]の格納位置
                            short cpValue = (short)0x8000; // [CP:現在補液量]を桁上げ整数化した値
                            short dmValue = (short)0x8000; // [DM:I-HDF 総補液量]を桁上げ整数化した値
                            // #9441 2023.09.15 add ＜[DM:I-HDF 総補液量]が0以外&&有効値、かつ、[CP:現在補液量]が0||無効値＞で「72:補液量現在値」を上書き TDC山崎 end

                            // モニタデータ
                            for( intlop = nHeaderSize; intlop < cmdLength; intlop++ )
                            {
                                // モニタ項目判定
                                for( intlop2 = 0; intlop2 < NTSS_V4_MONI_DATA_LEGTH; intlop2++ )
                                {
                                    // データ識別コード判定
                                    if( memcmp( cCmd + intlop, V4_MONI_DATA[intlop2].cID, 2 ) == 0 )
                                    {
                                        // 一致

                                        intlop += 2;
                                        short nAddr = V4_MONI_DATA[intlop2].nDataNo;

                                        // データ取得
                                        memmove( cbuff, cCmd +intlop, V4_MONI_DATA[intlop2].cLength );
                                        cbuff[ V4_MONI_DATA[intlop2].cLength ] = 0;
                                        intlop += V4_MONI_DATA[intlop2].cLength;

                                        if( nAddr < 300 )
                                        {
                                            // モニタ項目

                                            // テキスト→数字化
                                            short sdata = getNTSSCommonMonitorData( nAddr, cbuff );

                                            // debug
                                            printf(
                                                "ID:%s(%03d) - %s -> %d\n"
                                                , V4_MONI_DATA[intlop2].cID
                                                , V4_MONI_DATA[intlop2].nDataNo
                                                , cbuff
                                                , sdata
                                            );

                                            // #9441 2023.09.15 chg ＜[DM:I-HDF 総補液量]が0以外&&有効値、かつ、[CP:現在補液量]が0||無効値＞で「72:補液量現在値」を上書き TDC山崎 start
                                            //// モニタデータ登録処理
                                            //// mod FNSI-Redmine＃3099/＃3100:（V3/V4）仕様に無い治療モードの場合に正しく変換して送信されない。 高 start
                                            //// setNTSSCommonMonitorData( packetInfo, now, nAddr, sdata );
                                            //setNTSSCommonMonitorData( cCmd, packetInfo, now, nAddr, sdata );
                                            //// mod FNSI-Redmine＃3099/＃3100:（V3/V4）仕様に無い治療モードの場合に正しく変換して送信されない。 高 start

                                            if (nAddr == 203)
                                            {
                                                // [DM:I-HDF 総補液量]の桁上げ整数化した値をメモ
                                                dmValue = sdata;
                                            }
                                            else if (nAddr == 72)
                                            {
                                                // [CP:現在補液量]の桁上げ整数化した値 と 格納位置 をメモ
                                                cpValue = sdata;
                                                cpPos = v4MonDataCount;
                                            }

                                            // v4モニタデータと対応する新通信装置モニタデータアドレス と v4モニタデータを桁上げ整数化した値 をメモ配列に格納
                                            v4MonData[v4MonDataCount].nkkAddr = nAddr;
                                            v4MonData[v4MonDataCount].digitConvertedValue = sdata;
                                            v4MonDataCount++;
                                            // #9441 2023.09.15 chg ＜[DM:I-HDF 総補液量]が0以外&&有効値、かつ、[CP:現在補液量]が0||無効値＞で「72:補液量現在値」を上書き TDC山崎 end

                                        }
                                        else if( nAddr == 301 )
                                        {
                                            // 透析開始日時

                                            // 日付
                                            memcpy( cDialStartDate, cbuff, 4 );
                                            cDialStartDate[4] = '/';
                                            memcpy( cDialStartDate + 5, cbuff + 4, 2 );
                                            cDialStartDate[7] = '/';
                                            memcpy( cDialStartDate + 8, cbuff + 6, 2 );

                                            // 時刻
                                            memcpy( cDialStartTime, cbuff + 8, 2 );
                                            cDialStartTime[2] = ':';
                                            memcpy( cDialStartTime + 3, cbuff + 10, 2 );
                                            cDialStartTime[5] = ':';
                                            memcpy( cDialStartTime + 6, cbuff + 12, 2 );

                                            // debug
                                            printf(
                                                 "ID:%s - %s\n"
                                                , V4_MONI_DATA[intlop2].cID
                                                , cbuff
                                            );
                                        }
                                        else if( nAddr == 302 )
                                        {
                                            // 透析終了日時

                                            // 日付
                                            memcpy( cDialFinishDate, cbuff, 4 );
                                            cDialFinishDate[4] = '/';
                                            memcpy( cDialFinishDate + 5, cbuff + 4, 2 );
                                            cDialFinishDate[7] = '/';
                                            memcpy( cDialFinishDate + 8, cbuff + 6, 2 );

                                            // 時刻
                                            memcpy( cDialFinishTime, cbuff + 8, 2 );
                                            cDialFinishTime[2] = ':';
                                            memcpy( cDialFinishTime + 3, cbuff + 10, 2 );
                                            cDialFinishTime[5] = ':';
                                            memcpy( cDialFinishTime + 6, cbuff + 12, 2 );

                                            // debug
                                            printf(
                                                 "ID:%s - %s\n"
                                                , V4_MONI_DATA[intlop2].cID
                                                , cbuff
                                            );
                                        }

                                        intlop--;
                                        break;
                                    }
                                }
                            }
                            
                            // #9441 2023.09.15 add ＜[DM:I-HDF 総補液量]が0以外&&有効値、かつ、[CP:現在補液量]が0||無効値＞で「72:補液量現在値」を上書き TDC山崎 start
                            // [DM:I-HDF 総補液量] が 0以外&&有効値
                            if (dmValue != 0 && dmValue != (short)0x8000)
                            {
                                // メモ配列に[CP:現在補液量]が存在しない場合(仕様上はCPは推奨となっており存在しない可能性もゼロではない)には
                                // 新規に[CP:現在補液量]の格納領域を準備
                                if (cpPos == -1)
                                {
                                    v4MonData[v4MonDataCount].nkkAddr = 72;
                                    v4MonData[v4MonDataCount].digitConvertedValue = (short)0x8000;
                                    cpPos = v4MonDataCount;
                                    v4MonDataCount++;
                                }

                                // [CP:現在補液量] が 0||無効値
                                if (cpValue == 0 || cpValue == (short)0x8000)
                                {
                                    // [DM:I-HDF 総補液量] 整数のmL(最大で9999) → [72:補液量現在値] 小数点桁数2を桁上げ整数化のL の変換を実施。
                                    // 1234 mL → 1.23 L → 123 とするには整数のmLの[1の桁]をカットした文字列を数値化すればよい。
                                    char tmpStr[5] = {0};
                                    snprintf(tmpStr, sizeof(tmpStr), "%-d", dmValue);
                                
                                    int tmpLen = strlen(tmpStr);
                                    tmpStr[tmpLen - 1] = '\0'; // 末尾の桁＝1の桁をカット
                                    v4MonData[cpPos].digitConvertedValue = atoi(tmpStr);
                                }
                            }

                            // モニタデータ群の登録処理(積算系データ保持の処理も含む)
                            for (int vmdLoopIdx = 0; vmdLoopIdx < v4MonDataCount - 1; vmdLoopIdx++)
                            {
                                setNTSSCommonMonitorData(cCmd, packetInfo, now, v4MonData[vmdLoopIdx].nkkAddr, v4MonData[vmdLoopIdx].digitConvertedValue);
                            }
                            // #9441 2023.09.15 add ＜[DM:I-HDF 総補液量]が0以外&&有効値、かつ、[CP:現在補液量]が0||無効値＞で「72:補液量現在値」を上書き TDC山崎 end

                            // add 装置のSTATUS状態更新方法の変更 高 start
                            if( packetInfo->isDialysis[0] == 0x01)
                                packetInfo->machineState |= 0x01;
                            else
                                packetInfo->machineState &= 0xFE;
                            // add 装置のSTATUS状態更新方法の変更 高 end
                            
                            // モニタデータサイズを更新
                            packetInfo->nMoniDataSize = 1;

                            // 初回モニタデータ指示を解除
                            packetInfo->isFirstMoniData = 0x00;

                            // 工程変化を判定
                            if( packetInfo->nProcess[0] != packetInfo->nProcess[1] )
                            {
                                // 工程通知を依頼
                                packetInfo->isNeedSendProcess = 0x01;
                            }
                        }
                        // BP：血圧データ
                        else if( memcmp( cCmd + nHeaderSize, "BP", 2 ) == 0 )
                        {
                            nHeaderSize += 2;

                            // 血圧データ[0：最高血圧/1：最低血圧/2：脈拍/3：平均血圧]
                            short nBlood[4];
                            long nOccurDate = 0;
                            long nOccurTime = 0;
                          
                            for( intlop = nHeaderSize; intlop < cmdLength; intlop++ )
                            {
                                // 項目判定
                                for( intlop2 = 0; intlop2 < 4; intlop2++ )
                                {
                                    // データ識別コード判定
                                    if( cCmd[intlop] == 'D' && cCmd[intlop + 1] == 'A' + intlop2 )
                                    {
                                        // 一致

                                        intlop += 2;

                                        // debug
                                        sprintf(
                                              clog
                                            , "ID:D%c - "
                                            , 'A' + intlop2
                                        );

                                        // データ識別コード判定
                                        if( intlop2 == 0 )
                                        {
                                            // 血圧測定日時

                                            // データ取得

                                            // 日付
                                            memmove( cbuff, cCmd +intlop, 8 );
                                            cbuff[ 8 ] = 0;
                                            intlop += 8;

                                            nOccurDate = atol( cbuff );

                                            // 時刻
                                            memmove( cbuff + 9, cCmd +intlop, 6 );
                                            cbuff[ 15 ] = 0;
                                            intlop += 6;
                                            nOccurTime = atol( cbuff + 9 ); 

                                            // debug
                                            sprintf(
                                                clog + strlen( clog )
                                                , "%s%s"
                                                , cbuff
                                                , cbuff + 9
                                            );
                                        }
                                        else
                                        {
                                            // 血圧データ

                                            // データ取得
                                            memmove( cbuff, cCmd +intlop, 3 );
                                            cbuff[ 3 ] = 0;
                                            intlop += 3;

                                            // テキスト→数字化
                                            short sdata = atoi( cbuff );

                                            nBlood[ intlop2 - 1 ] = sdata;

                                            // debug
                                            sprintf(
                                                clog + strlen( clog )
                                                , "%s -> %d"
                                                , cbuff
                                                , sdata
                                            );
                                        }

                                        // debug
                                        printf( "%s\n", clog );

                                        intlop--;
                                        break;
                                    }
                                }
                            }

                            cKind = 0x01;
                            cCode = 0x01;

                            // 平均血圧を算出
                            nBlood[3] = ( nBlood[0] + nBlood[1] * 2 ) / 3;

                            // 血圧測定処理
                            outputNTSSCommonBloodLog( 
                                  packetInfo
                                , now
                                , cKind
                                , cCode
                                , nOccurDate
                                , nOccurTime
                                , nBlood[0]
                                , nBlood[1]
                                , nBlood[3]
                                , nBlood[2]
                            );
                        }
                        // AL：警報報知
                        else if( memcmp( cCmd + nHeaderSize, "AL", 2 ) == 0 )
                        {
                            nHeaderSize += 2;

                            struct V4_AL_INFO {
                                u_char cID;     // 識別コード
                                u_char cKind;   // 種別
                                u_char cCode;   // コード
                                u_char cClass;  // 発生区分(1：警報/2：報知)
                                u_char cFlag;   // 発生中
                            } al_info[] ={
                                { 'A', 0x00, 0x00, 0, 0x00 },
                                { 'B', 0x9f, 0x01, 1, 0x00 },
                                { 'C', 0x9f, 0x02, 1, 0x00 },
                                { 'D', 0x9f, 0x03, 1, 0x00 },
                                { 'E', 0x9f, 0x04, 1, 0x00 },
                                { 'F', 0x00, 0x00, 1, 0x00 },
                                { 'G', 0x00, 0x00, 1, 0x00 },
                                { 'H', 0x9f, 0x05, 1, 0x00 },
                                { 'I', 0x9f, 0x06, 1, 0x00 },
                                { 'J', 0x9f, 0x00, 1, 0x00 },
                                { 'K', 0x9f, 0x08, 1, 0x00 },
                                { 'M', 0x00, 0x00, 1, 0x00 },
                                { 'O', 0x40, 0x00, 2, 0x00 },
                                { 'P', 0x40, 0x10, 2, 0x00 },
                                { 'Q', 0x41, 0x00, 2, 0x00 },
                                { 'R', 0x00, 0x00, 2, 0x00 }
                            };
                            int nALCount = sizeof( al_info ) / sizeof( struct V4_AL_INFO );

                            for( intlop = nHeaderSize; intlop < cmdLength; intlop++ )
                            {
                                // 項目判定
                                for( intlop2 = 0; intlop2 < nALCount; intlop2++ )
                                {
                                    // データ識別コード判定
                                    if( cCmd[intlop] == 'D' && cCmd[intlop + 1] == al_info[intlop2].cID )
                                    {
                                        // 一致

                                        intlop += 2;

                                        // debug
                                        sprintf(
                                              clog
                                            , "ID:D%c - "
                                            , al_info[intlop2].cID
                                        );

                                        // データ識別コード判定
                                        if( intlop2 == 0 )
                                        {
                                            // 警報発生日時

                                            // データ取得
                                            memcpy( cNow, cCmd + intlop, 14 );
                                            intlop += 14;

                                            // debug
                                            sprintf(
                                                clog + strlen( clog )
                                                , "%s ->%s"
                                                , cbuff
                                                , cNow
                                            );
                                        }
                                        else
                                        {
                                            // 警報/報知

                                            // 発生状態
                                            al_info[intlop2].cFlag = cCmd[intlop];
                                            intlop++;

                                            // debug
                                            sprintf(
                                                clog + strlen( clog )
                                                , "%c"
                                                , al_info[intlop2].cFlag
                                            );
                                        }
                                        // debug
                                        printf( "%s\n", clog );

                                        break;
                                    }
                                    // フリー警報内容
                                    else if( memcmp( cCmd + intlop, "02", 2 ) == 0 )
                                    {
                                        intlop += 2;

                                        memset( cFreeMsg, 0, sizeof(cFreeMsg));
                                        memcpy( cFreeMsg, cCmd + intlop, 50 );
                                        intlop += 50;

                                        // シフトJIS→UTF8変換
                                        sjistoutf8( cFreeMsg, cFreeMsg );

                                        // debug
                                        printf(
                                              "ID:02 - %s\n"
                                            , cFreeMsg
                                        );
                                        
                                        break;
                                    }
                                }
                                intlop--;
                            }

                            // 項目判定
                            for( intlop = 0; intlop < nALCount; intlop++ )
                            {
                                // 発生状態判定
                                if( al_info[intlop].cFlag == '1' )
                                {
                                    // 発生中
                                    cKind = al_info[intlop].cKind;
                                    cCode = al_info[intlop].cCode;
                                    u_char cClass = al_info[intlop].cClass;
                                    u_char *cMsg = "";
                                    u_char cParam[ NTSS_STR_MAX_SIZE];
                                    
                                    // #8468 del 2023.03.16 通信共通V4での警報/報知状態を通知しないため削除 TDC米沢 start
                                    // // add 装置のSTATUS状態更新方法の変更 高 start
                                    // if( cClass == 1) {
                                    //     packetInfo->machineState |= 0x08;
                                    //     machineStatusFlag = true;
                                    // }
                                    // else if( cClass == 2) {
                                    //     packetInfo->machineState |= 0x20;
                                    //     machineNotifyStatusFlag = true;
                                    // }
                                    // // 変化判定
                                    // if( cClass == 2) {
                                    //     if( packetInfo->comm_alarm[intlop - 1] == al_info[intlop].cFlag )
                                    //     {
                                    //         continue;
                                    //     }
                                    // }
                                    // // add 装置のSTATUS状態更新方法の変更 高 end
                                    // #8468 del 2023.03.16 通信共通V4での警報/報知状態を通知しないため削除 TDC米沢 end

                                    // 識別コード判定
                                    switch( al_info[intlop].cID )
                                    {
                                        case 'F':   // ダイアライザ血液入口圧警報
                                            cMsg = "ダイアライザ血圧入口圧警報発生";
                                            sprintf(
                                                  cParam
                                                , "msg=%s"
                                                , cMsg
                                            );
                                            break;

                                        case 'G':   // 脱血圧(動脈圧)警報
                                            cMsg = "脱血圧(動脈圧)警報発生";
                                            sprintf(
                                                  cParam
                                                , "msg=%s"
                                                , cMsg
                                            );
                                            break;

                                        case 'M':   // その他警報
                                            cMsg = cFreeMsg;
                                            sprintf(
                                                  cParam
                                                , "msg=%s"
                                                , cMsg
                                            );
                                            break;

                                        case 'R':   // その他報知
                                            cMsg = "その他報知発生";
                                            sprintf(
                                                  cParam
                                                , "msg=%s"
                                                , cMsg
                                            );
                                            break;

                                        default:
                                            sprintf(
                                                  cParam
                                                , "code=%02X%02X"
                                                , cKind
                                                , cCode
                                            );
                                            break;

                                    }

                                    // ログ記録
                                    sprintf( 
                                          clog
                                        , "警報/報知発生検出, kind:%02X, code:%02X, msg:%s"
                                        , cKind
                                        , cCode
                                        , cMsg
                                    );
                                    outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, packetInfo );
                                    printf( "%s\n", clog );

                                    // 保存データ作成
                                    sprintf( 
                                          cbuff
                                        // mod FNSI-バグ 通信サーバ 高 start
                                        //, "kind=%s\tfacilitycode=%s\tedgeno=%d\toccurdate=%s\tdevicetype=%s\tserialno=%s\tcomformat=%c\tclass=%d\t%s\n"
                                        , "kind=%s\tfacilitycode=%s\tedgeno=%d\toccurdate=%s\tdevicetype=%s\tserialno=%s\tcommformat=%c\tclass=%d\t%s\n"
                                        // mod FNSI-バグ 通信サーバ 高 end
                                        , "C-LOG"
                                        , devicecapConf.cFacilityCode
                                        , devicecapConf.nDeviceEdgeNo
                                        , cNow
                                        , cDeviceType
                                        , cDeviceNo + 1
                                        , *cDeviceNo
                                        , cClass
                                        , cParam
                                    );

                                    // 警報報知ファイル作成
                                    outputAppendNTSSDataFile(
                                          packetInfo    // パケット管理情報
                                        , 0x01          // データ収集格納先
                                        , cfile         // 先頭ファイル名(collect)
                                        , "_comm.txt"   // 拡張子
                                        , &now          // 日付時刻
                                        , cbuff         // 書き込みデータ
                                        , strlen(cbuff) // 書き込みデータ長
                                    );

                                    // 警報フラグ初期化
                                    // del FNSI-バグ 通信サーバ 高 start
                                    // al_info[intlop].cFlag = 0;
                                    // del FNSI-バグ 通信サーバ 高 end
                                }
                                // #8468 del 2023.03.16 通信共通V4での警報/報知状態を通知しないため削除 TDC米沢 start
                                // // add FNSI-バグ 通信サーバ 高 start
                                // // 今回の発生状態を保持
                                // if(intlop != 0) {
                                //     packetInfo->comm_alarm[intlop - 1] = al_info[intlop].cFlag;
                                // }
                                // // add FNSI-バグ 通信サーバ 高 end
                                // #8468 del 2023.03.16 通信共通V4での警報/報知状態を通知しないため削除 TDC米沢 end
                            }
                            // #8468 del 2023.03.16 通信共通V4での警報/報知状態を通知しないため削除 TDC米沢 start
                            // // add 装置のSTATUS状態更新方法の変更 高 start
                            // if( machineStatusFlag == false )    // ステータス（警報OFF）
                            //     packetInfo->machineState &= ~0x08;
                                
                            // if( machineNotifyStatusFlag == false )  // ステータス（報知OFF）
                            //     packetInfo->machineState &= ~0x20;
                            // // add 装置のSTATUS状態更新方法の変更 高 end
                            // #8468 del 2023.03.16 通信共通V4での警報/報知状態を通知しないため削除 TDC米沢 end
                        }
                        // OL：操作履歴
                        else if( memcmp( cCmd + nHeaderSize, "OL", 2 ) == 0 )
                        {
                            nHeaderSize += 2;

                            u_char *cMsg[] = {
                                "操作：不明",
                                "操作：血液流量",
                                "操作：目標除水量",
                                "操作：除水速度操作",
                                "操作：透析時間",
                                "操作：除水時間",
                                "操作：治療モード"
                            };

                            for( intlop = nHeaderSize; intlop < cmdLength; intlop++ )
                            {
                                clog[0] = 0;

                                // データ識別コード判定
                                if( memcmp( cCmd + intlop, "DA", 2 ) == 0 )
                                {
                                    // 操作日時

                                    intlop += 2;

                                    // データ取得
                                    memcpy( cNow, cCmd + intlop, 14 );
                                    intlop += 14;

                                    // debug
                                    sprintf(
                                          clog
                                        , "ID:DA - %s -> %s"
                                        , cbuff
                                        , cNow
                                    );
                                }
                                else if( memcmp( cCmd + intlop, "DB", 2 ) == 0 )
                                {
                                    // データ区分

                                    intlop += 2;

                                    // データ取得
                                    cKind = cCmd[intlop] - '0';
                                    if( ! ( 0 <= cKind && cKind <= 6 ))
                                    {
                                        cKind = 0;
                                    }

                                    // debug
                                    sprintf(
                                        clog
                                        , "ID:DB - %c"
                                        , cCmd[intlop]
                                    );
                                    intlop++;
                                }
                                else if( memcmp( cCmd + intlop, "DC", 2 ) == 0 )
                                {
                                    // 操作内容

                                    intlop += 2;

                                    memset( cFreeMsg, 0, sizeof(cFreeMsg));
                                    memcpy( cFreeMsg, cCmd + intlop, 50 );
                                    intlop += 50;

                                    // シフトJIS→UTF8変換
                                    sjistoutf8( cFreeMsg, cFreeMsg );

                                    // debug
                                    sprintf(
                                        clog
                                        , "ID:DC - %s"
                                        , cFreeMsg
                                    );
                                }

                                if( clog[0] != 0 )
                                {
                                    // debug
                                    printf( "%s\n", clog );
                                    intlop--;
                                }
                            }

                            // ログ記録
                            sprintf( 
                                    clog
                                , "操作履歴受信, msg:%s, ope:%s"
                                , cMsg[cKind]
                                , cFreeMsg
                            );
                            outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, packetInfo );
                            printf( "%s\n", clog );

                            // 保存データ作成
                            sprintf( 
                                    cbuff
                                // mod FNSI-バグ 通信サーバ 高 start
                                //, "kind=%s\tfacilitycode=%s\tedgeno=%d\toccurdate=%s\tdevicetype=%s\tserialno=%s\tcomformat=%c\tclass=%d\tmsg=%s\tmsg2=%s\n"
                                , "kind=%s\tfacilitycode=%s\tedgeno=%d\toccurdate=%s\tdevicetype=%s\tserialno=%s\tcommformat=%c\tclass=%d\tmsg=%s\tmsg2=%s\n"
                                // mod FNSI-バグ 通信サーバ 高 end
                                , "C-LOG"
                                , devicecapConf.cFacilityCode
                                , devicecapConf.nDeviceEdgeNo
                                , cNow
                                , cDeviceType
                                , cDeviceNo + 1
                                , *cDeviceNo
                                , 3
                                , cMsg[cKind]
                                , cFreeMsg
                            );

                            // 操作履歴ファイル作成
                            outputAppendNTSSDataFile(
                                  packetInfo    // パケット管理情報
                                , 0x01          // データ収集格納先
                                , cfile         // 先頭ファイル名(collect)
                                , "_comm.txt"   // 拡張子
                                , &now          // 日付時刻
                                , cbuff         // 書き込みデータ
                                , strlen(cbuff) // 書き込みデータ長
                            );
                        }
                        // EL：ETRF稼働時間
                        else if( memcmp( cCmd + nHeaderSize, "EL", 2 ) == 0 )
                        {
                            nHeaderSize += 2;
                            // add FNSI-Redmine＃3107:（V4）消耗品の動作時間（ETRF1/ETRF2）が表示されない 高 start
                            memset( cFreeMsg, 0, sizeof(cFreeMsg));
                            // add FNSI-Redmine＃3107:（V4）消耗品の動作時間（ETRF1/ETRF2）が表示されない 高 end

                            for( intlop = nHeaderSize; intlop < cmdLength; intlop++ )
                            {
                                for( intlop2 = 0; intlop2 < 2; intlop2++ )
                                {
                                    // データ識別コード判定
                                    if( cCmd[intlop] == 'D' && cCmd[intlop + 1] == ('A' + intlop2 ))
                                    {
                                        // 一致

                                        // ETRF1時間/ETRF2時間

                                        intlop += 2;

                                        // データ取得
                                        memcpy( cbuff, cCmd + intlop, 5 );
                                        cbuff[5] = 0;
                                        intlop += 5;

                                        //
                                        if( cFreeMsg[0] != 0 ) 
                                        {
                                            strcat( cFreeMsg, ", " );
                                        }
                                        sprintf( 
                                              cFreeMsg + strlen( cFreeMsg )
                                            , "\"%d\":%ld"
                                            , 16 + ( intlop2 * 15 )
                                            , atol( cbuff )
                                        );

                                        // debug
                                        sprintf(
                                            clog
                                            , "ID:D%c - %s"
                                            , 'A' + intlop2
                                            , cbuff
                                        );

                                        intlop--;
                                        break;
                                    }
                                }

                                // debug
                                printf( "%s\n", clog );
                            }

                            // ログ記録
                            sprintf( 
                                    clog
                                , "ETRF稼働時間受信, %s"
                                , cFreeMsg
                            );
                            outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, packetInfo );
                            printf( "%s\n", clog );

                            // 保存データ作成
                            sprintf( 
                                    cbuff
                                // mod FNSI-バグ 通信サーバ 高 start
                                //, "kind=%s\tfacilitycode=%s\tedgeno=%d\toccurdate=%s\tdevicetype=%s\tserialno=%s\tcomformat=%c\titems={%s}\n"
                                , "kind=%s\tfacilitycode=%s\tedgeno=%d\toccurdate=%s\tdevicetype=%s\tserialno=%s\tcommformat=%c\titems={%s}\n"
                                // mod FNSI-バグ 通信サーバ 高 end
                                , "C-OPE"
                                , devicecapConf.cFacilityCode
                                , devicecapConf.nDeviceEdgeNo
                                , cNow
                                , cDeviceType
                                , cDeviceNo + 1
                                , *cDeviceNo
                                , cFreeMsg
                            );

                            // ETRF稼働時間ファイル作成
                            outputAppendNTSSDataFile(
                                    packetInfo    // パケット管理情報
                                , 0x01          // データ収集格納先
                                , cfile         // 先頭ファイル名(collect)
                                , "_comm.txt"   // 拡張子
                                , &now          // 日付時刻
                                , cbuff         // 書き込みデータ
                                , strlen(cbuff) // 書き込みデータ長
                            );
                        }
                        // SC：自己診断結果判定
                        else if( memcmp( cCmd + nHeaderSize, "SC", 2 ) == 0 )
                        {
                            nHeaderSize += 2;

                            for( intlop = nHeaderSize; intlop < cmdLength; intlop++ )
                            {
                                clog[0] = 0;

                                // データ識別コード判定
                                if( memcmp( cCmd + intlop, "DA", 2 ) == 0 )
                                {
                                    // 自己診断判定結果

                                    intlop += 2;

                                    // データ取得
                                    memcpy( cbuff, cCmd + intlop, 2 );
                                    cbuff[2] = 0;
                                    intlop += 2;

                                    // 
                                    sprintf( 
                                          cFreeMsg
                                        , "自己診断結果：%s"
                                        , cbuff
                                    );

                                    // debug
                                    sprintf(
                                          clog
                                        , "ID:DA - %s -> %s"
                                        , cbuff
                                        , cFreeMsg
                                    );
                                }
                                else if( memcmp( cCmd + intlop, "DB", 2 ) == 0 )
                                {
                                    // 自己診断実施日時

                                    intlop += 2;

                                    // データ取得
                                    memcpy( cNow, cCmd + intlop, 14 );
                                    intlop += 14;

                                    // debug
                                    sprintf(
                                        clog
                                        , "ID:DB - %s -> %s"
                                        , cbuff
                                        , cNow
                                    );                                   
                                }

                                if( clog[0] != 0 )
                                {
                                    // debug
                                    printf( "%s\n", clog );
                                    intlop--;
                                }
                            }

                            // ログ記録
                            sprintf( 
                                    clog
                                , "自己診断結果判定受信, date:%s, msg:%s"
                                , cNow
                                , cFreeMsg
                            );
                            outputNTSSPacketInfoLog( NTSS_LOG_INFO, clog, 0, packetInfo );
                            printf( "%s\n", clog );

                            // 保存データ作成
                            sprintf( 
                                    cbuff
                                // mod FNSI-バグ 通信サーバ 高 start
                                //, "kind=%s\tfacilitycode=%s\tedgeno=%d\toccurdate=%s\tdevicetype=%s\tserialno=%s\tcomformat=%c\tclass=%d\t\tmsg=%s\n"
                                , "kind=%s\tfacilitycode=%s\tedgeno=%d\toccurdate=%s\tdevicetype=%s\tserialno=%s\tcommformat=%c\tclass=%d\t\tmsg=%s\n"
                                // mod FNSI-バグ 通信サーバ 高 end
                                , "C-MNT"
                                , devicecapConf.cFacilityCode
                                , devicecapConf.nDeviceEdgeNo
                                , cNow
                                , cDeviceType
                                , cDeviceNo + 1
                                , *cDeviceNo
                                , 4
                                , cFreeMsg
                            );

                            // 自己診断結果判定ファイル作成
                            outputAppendNTSSDataFile(
                                  packetInfo    // パケット管理情報
                                , 0x01          // データ収集格納先
                                , cfile         // 先頭ファイル名(collect)
                                , "_comm.txt"   // 拡張子
                                , &now          // 日付時刻
                                , cbuff         // 書き込みデータ
                                , strlen(cbuff) // 書き込みデータ長
                            );
                        }

                        break;
                }
            }

            // 治療中判定
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

                    // 次回受信するモニタデータを初回とする(積算処理をしない)
                    packetInfo->isFirstMoniData = 0x01;

                    // 透析開始日時を設定
                    memmove(&packetInfo->dialysisStartTime, &(packetInfo->dtMoni.tv_sec), sizeof( time_t ));

                    // モニタ出力日時を初期化
                    packetInfo->moniOutputTime = 0;
                    // add 治療記録用データと治療状況用データの登録先を振分けにする 高 start
                    packetInfo->realMoniOutputTime = 0;
                    // add 治療記録用データと治療状況用データの登録先を振分けにする 高 start

                    // 治療開始日時判定
                    time_t dtwork;
                    if( str_time( cDialStartDate, cDialStartTime, &dtwork, 1 ) == 0 )
                    {
                        // 治療開始日時が有効な場合
                        memmove( &packetInfo->dialysisStartTime, &dtwork, sizeof( dtwork ));
                    }
                }
                else
                {
                    // 透析終了時
                    cCommandId = "MONF";
                    cDialText = "透析終了";

                    // ホスト報知監視状態初期化(0x00：監視してない/0x01：監視中)
                    packetInfo->isWatch = 0x00;

                    // 透析終了日時を設定
                    memmove(&packetInfo->dialysisFinishTime, &(packetInfo->dtMoni.tv_sec), sizeof( time_t ));

                    // モニタ出力日時を初期化
                    packetInfo->moniOutputTime = 0;
                    // add 治療記録用データと治療状況用データの登録先を振分けにする 高 start
                    packetInfo->realMoniOutputTime = 0;
                    // add 治療記録用データと治療状況用データの登録先を振分けにする 高 start

                    // モニタ更新禁止
                    packetInfo->isStopUpMoniData = 0x01;

                    // 治療終了日時判定
                    time_t dtwork;
                    if( str_time( cDialFinishDate, cDialFinishTime, &dtwork, 1 ) == 0 )
                    {
                        // 治療終了日時が有効な場合
                        memmove( &packetInfo->dialysisFinishTime, &dtwork, sizeof( dtwork ));
                    }
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

                //　治療状態を保持
                packetInfo->isDialysis[1] = packetInfo->isDialysis[0];
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

/**
* @brief 対象パケット管理情報からJSON形式のモニタデータを取得する
*
* @details 対象パケット管理情報からJSON形式のモニタデータを取得する
*
* @description
* @param[in] *packetInfo    パケット管理情報
* @param[in] nAddr          モニタ項目番号
* @param[in] *cJSONText     JSON形式の出力モニタデータ
* @return 1：取得成功/0：取得失敗
* @attention 特になし
*/
int 
getNTSSCommonMonitorDataJsonItem( struct NTSS_PACKET_INFORMATION *packetInfo
                                , short nAddr
                                , u_char *cJSONText
                                )
{
    int ret = 0;

    // データ取得
    short sdata;
    u_char cData[10];
    memmove( &sdata, packetInfo->cMoniData + nAddr * 2, 2 );

    // データ判定(0x8000は出力しない)
    if( SHRT_MIN < sdata )
    {
        // 0x8000より大きい場合

        // モニタ項目取得
        struct moni_list info;
        info.dec = 0;
        ntss_mst_moni_data( 0, "00", nAddr, &info );

        // モニタ項目が200：透析液濃度(設定値)の場合
        if( nAddr == 200 )
        {
            // 小数点以下桁数を1とする
            info.dec = 1;
        }

        // 小数点以下判定
        if( info.dec == 0 )
        {
            // 整数

            // 文字列化
            sprintf(
                    cData
                , "%d"
                , sdata
            );
        }
        else
        {
            // 少数

            int intlop2;
            int nRate = 1;
            for( intlop2 = 0; intlop2 < info.dec; intlop2++ )
            {
                nRate *= 10;
            }

            // 文字列化
            u_char cFmt[10];
            sprintf(
                    cFmt
                , "%%d.%%0%dd"
                , info.dec
            );
            sprintf(
                cData
                , cFmt
                , sdata / nRate
                , sdata % nRate
            );
        }

        // 
        sprintf( 
              cJSONText
            , "\"%d\":%s"
            , nAddr
            , cData
        );    

        ret = 1;
    }

    return ret;   
}
/**
* @brief 対象パケット管理情報で通信共通プロトコル用のモニタデータファイル名、及びモニタデータを取得する
* ※collect_[作成年月日時分秒マイクロ秒]_comm.txt
*
* @details 対象パケット管理情報で通信共通プロトコル用のモニタデータファイル名、及びモニタデータを取得する
*
* @description
* @param[in] *packetInfo    パケット管理情報
* @param[in] *cFileName     出力ファイル名
* @param[in] *cMonitorData  出力モニタデータ
* @param[in] *cKindName     Kind名
* @return 1：取得成功/0：取得失敗
* @attention 特になし
*/
int
// mod 治療記録用データと治療状況用データの登録先を振分けにする 高 start
// getNTSSCommonMonitorDataFile( struct NTSS_PACKET_INFORMATION *packetInfo
//                             , u_char *cFileName
//                             , u_char *cMonitorData
//                             )
getNTSSCommonMonitorDataFile( struct NTSS_PACKET_INFORMATION *packetInfo
                            , u_char *cFileName
                            , u_char *cMonitorData
                            , u_char *cKindName
                            )
// mod 治療記録用データと治療状況用データの登録先を振分けにする 高 end
{
    int ret = 1;

    u_char cDeviceType[4];
    u_char cDeviceNo[9];
    u_char cbuff[ NTSS_STR_MAX_SIZE ];

    // 型式コード
    memmove( cDeviceType, packetInfo->cDeviceType, 3 );
    cDeviceType[3] = 0;

    // 製造番号
    memmove( cDeviceNo, &packetInfo->cDeviceNo, sizeof( packetInfo->cDeviceNo ));
    cDeviceNo[8] = 0;
    // 末尾の空白を除去
    trimEnd( cDeviceNo, ' ' );

    // モニタ最終受信日時作成
    u_char cNow[20];
    struct tm tmnow;
    localtime_r( &packetInfo->dtMoni.tv_sec, &tmnow );
    sprintf( 
            cNow
        , "%04d%02d%02d%02d%02d%02d"
        , tmnow.tm_year + 1900
        , tmnow.tm_mon + 1
        , tmnow.tm_mday
        , tmnow.tm_hour
        , tmnow.tm_min
        , tmnow.tm_sec
    );

    // 通信ステータス作成
    u_char cStatus[5];
    memmove( cStatus, "0000\0", 5 );
    cStatus[3] += packetInfo->isDialysis[0];

    // ファイル名作成
    // ※collect_[作成年月日時分秒マイクロ秒]_comm.txt
    sprintf( cFileName, "collect" );

    // モニタデータ作成
    char cMoniData[ 1024 ];
    cMoniData[0] = 0;
    int intlop;
    if( packetInfo->cDeviceFormat == 'W' )
    {
        // 通信共通V3

        for( intlop = 0; intlop < NTSS_V3_MONI_DATA_LEGTH; intlop++ )
        {
            // モニタ項目判定[最高血圧より前のものが対象]
            short nAddr = V3_MONI_DATA[intlop].nDataNo;
            if( nAddr < 90 )
            {
                // モニタデータ取得
                if( getNTSSCommonMonitorDataJsonItem(
                      packetInfo
                    , nAddr
                    , cbuff
                ) == 1 )
                {
                    if( cMoniData[0] != 0 )
                    {
                        strcat( cMoniData, ", " );
                    }
                    strcat( cMoniData, cbuff );
                }
            }
        }

        // 警報発生状態
        for( intlop = 0; intlop < 9; intlop++ )        
        {
            // 警報発生判定
            if( packetInfo->cMoniData[ 500 + intlop ] == '1' )
            {
                // 警報発生中
                cStatus[3] |= 0x08;
                break;
            }
        }
    }
    else if( packetInfo->cDeviceFormat == 'V' )
    {
        // 通信共通V4

        for( intlop = 0; intlop < NTSS_V4_MONI_DATA_LEGTH; intlop++ )
        {
            // モニタ項目判定[300より前のものが対象]
            short nAddr = V4_MONI_DATA[intlop].nDataNo;
            if( nAddr < 300 )
            {
                // モニタデータ取得
                if( getNTSSCommonMonitorDataJsonItem(
                      packetInfo
                    , nAddr
                    , cbuff
                ) == 1 )
                {
                    if( cMoniData[0] != 0 )
                    {
                        strcat( cMoniData, ", " );
                    }
                    strcat( cMoniData, cbuff );
                }
            }
        }
    }

    // 保存データ作成
    sprintf( 
          cMonitorData
        // mod FNSI-バグ 通信サーバ 高 start
        //, "kind=%s\tfacilitycode=%s\tedgeno=%d\toccurdate=%s\tdevicetype=%s\tserialno=%s\tcomformat=%c\tcommstatus=%s\tclass=%d\titems={%s}\n"
        , "kind=%s\tfacilitycode=%s\tedgeno=%d\toccurdate=%s\tdevicetype=%s\tserialno=%s\tcommformat=%c\tcommstatus=%s\tclass=%d\titems={%s}\n"
        // mod FNSI-バグ 通信サーバ 高 end
        , cKindName
        , devicecapConf.cFacilityCode
        , devicecapConf.nDeviceEdgeNo
        , cNow
        , cDeviceType
        , cDeviceNo
        , packetInfo->cDeviceFormat
        , cStatus
        , 1        
        , cMoniData
    );

    return ret;
}
//@}
