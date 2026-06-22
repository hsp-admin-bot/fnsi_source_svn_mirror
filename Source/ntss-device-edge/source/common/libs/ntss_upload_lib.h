/**
* @brief NTSSファイルアップロード用汎用処理ヘッダーファイル
*
* @details NTSSファイルアップロードの汎用処理
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_upload_lib.h
* @author H.Yonezawa
* @date 2018/07/18
*/

#ifndef NTSS_UPLOAD_LIB_H
#define NTSS_UPLOAD_LIB_H


/**
* @brief 指定フォルダから圧縮ファイルを作成する
*
* @details 指定フォルダから圧縮ファイルを作成する
*
* @description
* @param[in] *cDataFolder       データ格納先フォルダ
* @param[in] *ZipFileName       圧縮ファイル名
* @param[in] *cPW               パスワード
* @param[in] cWorkFolder        作業用フォルダ
* @param[in] *cMachineType      型式コード(不要な場合はから文字を指定)
* @param[in] *cMachineSerial    製造番号(不要な場合はから文字を指定)
* @return 0：作成成功/else：作成失敗
* @attention 特になし
*/
extern int
zipNTSSFiles( u_char *cDataFolder
            , u_char *cZipFileName
            , u_char *cPW
            , u_char *cWorkFolder
            , u_char *cMachineType
            , u_char *cMachineSerial
            );

/**
* @brief 指定ファイルから圧縮ファイルを作成する
*
* @details 指定ファイルから圧縮ファイルを作成する
*
* @description
* @param[in] *cFileName   　圧縮元ファイル名
* @param[in] *ZipFileName   圧縮ファイル名
* @param[in] *cPW           パスワード
* @return 0：作成成功/else：作成失敗
* @attention 特になし
*/
extern int
zipNTSSFile( u_char *cFileName
           , u_char *cZipFileName
           , u_char *cPW
           );

/**
* @brief 指定ファイルを指定URLへアップロードする
*
* @details 指定ファイルを指定URLへアップロードする
*
* @description
* @param[in]  *cUploadFileName      アップロードするファイル名(フルパス)
* @param[in]  nUploadURI            アップロードURI(ホスト名 + API)
* @param[in]  *cUploadPath          アップロード先パス名
* @param[in]  nUploadFileMaxSize    アップロードファイル最大サイズ
* @param[out] *nSeparateCount       ファイル分割数
* @param[in] *cMachineType          型式コード(不要な場合はから文字を指定)
* @param[in] *cMachineSerial        製造番号(不要な場合はから文字を指定)
* @param[in] nRetryCount            リトライ回数
* @param[in] nRetryWaitTime         リトライ待ち時間[秒]
* @return 0：転送成功/1：URL接続失敗/2：転送失敗
* @attention 特になし
*/
extern int
uploadNTSSFile( u_char *cUploadFileName
              , u_char *cUploadURI
              , u_char *cUploadPath
              , uint16_t nUploadFileMaxSize
              , int *nSeparateCount
              , u_char *cMachineType
              , u_char *cMachineSerial
              , int nRetryCount
              , int nRetryWaitTime
              );
/**
* @brief アップロードしたファイルの結合指示
*
* @details アップロードしたファイルの結合指示を行う
*
* @description
* @param[in] *nSeparateCount    ファイル分割数
* @param[in] *cUploadFileName   アップロードしたファイル名(フルパス)
* @param[in] nUploadURI         アップロードURI(ホスト名 + API)
* @param[in] *cUploadPath       アップロード先パス名
* @param[in] *cMachineType      型式コード(不要な場合はから文字を指定)
* @param[in] *cMachineSerial    製造番号(不要な場合はから文字を指定)
* @return 0：指示成功/else：指示失敗
* @attention 特になし
*/
int
uploadNTSSFileJoin( int nSeparateCount
                  , u_char *cUploadFileName
                  , u_char *cUploadURI
                  , u_char *cUploadPath
                  , u_char *cMachineType
                  , u_char *cMachineSerial
                  );
#endif