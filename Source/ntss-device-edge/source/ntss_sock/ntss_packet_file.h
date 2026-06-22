/**
* @brief NTSSデータ出力処理
*
* @details NTSSデータをファイルに出力
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_packet_file.h
* @author H.Yonezawa
* @date 2017/10/26
*/

#ifndef NTSS_PACKET_FILE_H
#define NTSS_PACKET_FILE_H

#include "ntss_packet_manage.h"

/// @name ファイル出力関連
//@{
/**
* @brief NTSS汎用ファイル名取得
*
* @details NTSS汎用ファイル名を取得する
*
* @description
* @param[in] cFirstFileName 先頭ファイル名
* @param[in] cFileExtName   ファイル拡張子
* @param[in] makeTime       作成日時
* @param[in] *folder        格納先フォルダ名
* @param[out] *fileName     保存ファイル名
* @return 1：作成成功/else：作成失敗
* @attention 特になし
*/
int
getNTSSFileName( u_char *cFileNameBase
               , u_char *cFileExtName
               , struct timeval receiveTime
               , u_char *folder
               , u_char *fileName
               );

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
* @param[in] *cFileExtName      ファイル拡張子(packetInfo=NULLの場合に使用)
* @param[in] *makeTime          ファイル作成日時(packetInfo=NULLの場合に使用)
* @param[in] *cData             データ格納先バッファ
* @param[in] dataLength         データ長
* @return 1：保存成功0：保存不要/−2：フォルダ作成失敗/-3:ファイル作成失敗
* @attention 特になし
*/
extern int
outputNTSSDataFile( struct NTSS_PACKET_INFORMATION *packetInfo 
                  , u_char cOutputType
                  , u_char *cCommandId
                  , u_char *cFirstFileName
                  , u_char *cFileExtName
                  , struct timeval *makeTime
                  , u_char *cData
                  , int dataLength
                  );
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
extern int
outputAppendNTSSDataFile( struct NTSS_PACKET_INFORMATION *packetInfo 
                        , u_char cOutputType
                        , u_char *cFirstFileName
                        , u_char *cFileExtName
                        , struct timeval *makeTime
                        , u_char *cData
                        , int dataLength
                        );
//@}
#endif
