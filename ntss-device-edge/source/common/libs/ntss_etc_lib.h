/**
* @briefNTSS汎用関数ヘッダーファイル
*
* @details NTSS汎用関数
*
* @description ntss program

* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_etc_lib.h
* @author H.Yonezawa
* @date 2017/11/06
*/

#ifndef NTSS_ETC_LIB_H
#define NTSS_ETC_LIB_H

// #8729 2023.05.29 add RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
#include <dirent.h>
#include <stdbool.h>
#include <stdint.h>
#include <err.h>
#include <errno.h>
// #8729 2023.05.29 add RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/statvfs.h>

/// 文字列情報最大長
#define NTSS_STR_MAX_SIZE 256


/// ファイル一覧処理モード
typedef enum NTSS_GETFOLDERLIST_MODE
{
    /// フォルダのみ
    NTSS_GETFOLDERLIST_MODE_FOLDER_ONLY,
    /// ファイルのみ
    NTSS_GETFOLDERLIST_MODE_FILE_ONLY
} NtssGetFolderListMode;

/// ファイルコピー処理モード
typedef enum NTSS_COPYFILE_MODE
{
    ///　上書き禁止
    NTSS_COPYFILE_MODE_NO_OVERWRITE,
    /// 上書き許可
    NTSS_COPYFILE_MODE_OVERWRITE
} NtssCopyFileMode;

/// ファイル移動処理モード
typedef enum NTSS_MOVEFILE_MODE
{
    ///　上書き禁止
    NTSS_MOVEFILE_MODE_NO_OVERWRITE,
    /// 上書き許可
    NTSS_MOVEFILE_MODE_OVERWRITE
} NtssMoveFileMode;


/// @name ファイル関連
//@{

/**
* @brief 指定フォルダ文字列の末尾にセパレータ文字列をがない場合に付加する
*
* @details　指定フォルダ文字列の末尾にセパレータ文字列をがない場合に付加する
* ただし指定フォルダ文字列がからの場合は付加しない
*
* @description
* @param[in] *folder    フォルダ文字列
* @return なし
* @attention 特になし
*/
extern void
addFolderSeparator( u_char *folder );

/**
* @brief ファイル/フォルダの存在確認
*
* @details ファイル/フォルダの存在を確認する
*
* @description
* @param[in] *item  存在確認を行うファイル名/フォルダ名(フルパス含む)
* @param[out] *pst  stat構造体格納用(不要な場合はNULLを指定)
* @return 1：存在する/else：確認失敗(存在しない場合含む)
* @attention 特になし
*/
extern int
existFolderFile( const u_char *item
               , struct stat *pst
               );

/**
* @brief フォルダ作成
*
* @details 指定フォルダを作成する
*
* @description
* @param[in] *folder    作成するフォルダ名(フルパス含む)
* @return 1：作成成功/else：作成失敗
* @attention 特になし
*/
extern int
createFolder( const u_char *folder );

/**
* @brief ファイルを作成
*
* @details ファイルを作成する
*
* @description
* @param[in] *fileName  保存ファイル名(フルパス含む)
* @param[in] *data      保存データ
* @param[in] dataLength 保存データ長さ
* @return 1：作成成功/else：作成失敗
* @attention 特になし
*/
extern int
outputFile( u_char *fileName
          , u_char *data
          , int dataLength
          );

/**
* @brief ファイルを追記
*
* @details ファイルを追記する
*
* @description
* @param[in] *fileName  保存ファイル名(フルパス含む)
* @param[in] *data      保存データ
* @param[in] dataLength 保存データ長さ
* @return 1：作成成功/else：作成失敗
* @attention 特になし
*/
extern int
outputAppendFile( u_char *fileName
                , u_char *data
                , int dataLength
                );

/**
* @brief 検索対象フォルダ内の一覧を指定ファイルに出力する
*
* @details 検索対象フォルダ内の一覧を指定ファイルに出力する
*
* @description
* @param[in] *cFolder       検索対象フォルダ
* @param[in] *listFileName  出力ファイル名(フルパス含む)
* @param[in] mode           取得方法[NTSS_GETFOLDERLIST_FOLDER_ONLY：フォルダのみ/NTSS_GETFOLDERLIST_FILE_ONLY：ファイルのみ]
* @return 1：出力成功/else：出力失敗
* @attention 特になし
*/
extern int
getFolderList( u_char *cFolder
             , u_char *cListFileName
             , NtssGetFolderListMode mode
             );

/**
* @brief ファイルをコピー
*
* @details ファイルをコピーする
*
* @description
* @param[in] *sourceFileName    コピー元ファイル名(フルパス含む)
* @param[in] *destFileName      コピー先ファイル名(フルパス含む)
* @param[in] mode               移動先ファイルが存在する場合の処理方法[NTSS_MOVEFILE_MODE_NO_OVERWRITE：上書きしない/NTSS_MOVEFILE_MODE_OVERWRITE：上書きする]
* @return 1：コピー成功/else：コピー失敗
* @attention 特になし
*/
extern int 
copyFile( u_char *sourceFileName
        , u_char *destFileName
        , NtssCopyFileMode mode
        );

/**
* @brief ファイルを移動
*
* @details ファイルを移動する
*
* @description
* @param[in] *sourceFileName    移動元ファイル名(フルパス含む)
* @param[in] *destFileName      移動先ファイル名(フルパス含む)
* @param[in] mode               移動先ファイルが存在する場合の処理方法[NTSS_MOVEFILE_MODE_NO_OVERWRITE：上書きしない/NTSS_MOVEFILE_MODE_OVERWRITE：上書きする]
* @return 1：作成成功/else：作成失敗
* @attention 特になし
*/
extern int 
moveFile( u_char *sourceFileName
        , u_char *destFileName
        , NtssMoveFileMode mode
        );
            
/**
* @brief 指定フォルダ内にファイルがあるかどうかを調べる
*
* @details 指定フォルダ内にファイルがあるかどうかを調べる
*
* @description
* @param[in] *cFolder   検索対象フォルダ
* @return -1：取得失敗/0：ファイルなし/１：ファイルあり
* @attention 特になし
*/
extern int
existFolderInFiles( u_char *cFolder
                  );

/**
* @brief 指定フォルダ内の全ファイルを削除する
*
* @details 指定フォルダ内の全ファイルを削除する
*
* @description
* @param[in] *cFolder   格納全ファイルを削除するフォルダ
* @return 0：削除成功/else：削除失敗
* @attention 特になし
*/
extern int
deleteFolderInFiles( u_char *cFolder
                   );

/**
 * @brief Get the Free Size 
 * 
 * @param path フォルダパス
 * @return unsigned long long 指定フォルダの空き容量　エラー時は(0)
 */
unsigned long long
getFreeSize(u_char *path);
//@}

/**
* @brief 末尾の指定文字を削除する
*
* @details 末尾の指定文字削除
*　末尾の指定文字をNULLに変換する
*
* @description
* @param[in] *cText             削除対象文字列
* @param[in] cTrimeCharactor    削除文字
* @return なし
* @attention 特になし
*/
extern void
trimEnd( u_char *cText
       , u_char cTrimCharactor
       );


/**
* @brief 自プロセス名を取得する
*
* @details 次プロセス名を取得する
*
* @description
* @param[in] *cName         取得名称
* @param[in] nBufferSize    取得可能領域サイズ
* @param[in] cFullPath      フルパス付加フラグ[0:含めない/1:含める]
* @return なし
* @attention 特になし
*/
extern void
getProcessName( u_char *cName
              , int nBufferSize
              , u_char cFullPath
              );


/**
* @brief 10進表記のIPアドレスを取得する
*
* @details 10進表記のIPアドレスを取得する
* 数値の前が0で産められている場合は8進数となる場合があるため
* 0埋めを除去する
*
* @description
* @param[in]    *cBaseIPAddr 変換前IPアドレス
* `param[out]   *cCnvIPAddr  返還後IPアドレス
* @return なし
* @attention 特になし
*/
extern void 
getDecimalIPAddr( u_char *cBaseIPAddr
                , u_char *cConvIPAddr
                );


/**
* @brief 2桁の16進文字列をバイナリ変換する
*
* @details 2桁の16進文字列をバイナリ変換する
*
* @description
* @param[in]    cHexStr 2桁のHEX文字列
* @return u_charデータ
* @attention 特になし
*/
extern u_char
getBinFromHexStr( u_char *cHexStr
               );

/**
* @brief Unicode文字列を指定文字数(複数コードポイント文字は非対応)で切り出す
*
* @details Unicode文字列を指定文字数までで切り出す
*
* @description
* @param[in|out] cStr Unicode文字文字列(返り値も兼ねる)
* @param[in] maxLength 最大文字数
* @return 文字数
* @attention 特になし
*/
extern int
subStr(char *cStr, int maxLength);

/**
* @brief Unicode文字の先頭バイトから1文字のバイト数を取得する
*
* @details Unicode文字は1文字あたりのバイト数が不定、先頭バイトから1文字のバイト数を取得する
*
* @description
* @param[in] cChar Unicode文字先頭バイト
* @return バイト数
* @attention 特になし
*/
extern int countByteUChar(u_char cChar);

/**
* @brief フォルダ内のファイル数を取得
*
* @details フォルダ内のファイル数を取得する（フォルダは対象外）
*
* @description
* @param[in] *cFolder 検索対象フォルダ
* @return ファイル件数
* @attention 特になし
*/
extern int
getFileCount(char *cFolder
               );


/**
* @brief LTE/3Gモジュールのアンテナレベル取得
*
* @details LTE/3Gモジュールのアンテナレベルを取得
*
* @description
* @return 出力情報（改行無し）
* @attention 特になし
*/
extern char
*getAntenna();


/**
* @brief ネットワーク状態取得
*
* @details 指定したネットワークデバイスの状態を取得
*
* @description
* @param[in] *cDev 対象デバイス（eth0,ppp0など）
* @return 出力情報（改行有り）
* @attention 特になし
*/
extern char
*getNetworkStat(char *cDev);

// #11965 2025.07.11 mod 戻り値をなしにして引数に変更 TDC米沢 start
// /**
// * @brief 指定パスがマウントメディアかどうか判定する
// *
// * @details 指定パスがマウント対象となるメディアかどうか確認し、マウントパスを返す
// *
// * @description
// * @param[in] *cMedia 対象デバイス（/mnt/usb、/mnt/sd等）
// * @return NULL：対象外デバイス/else：対象デバイス（/mnt/usb、/mnt/sd等）
// * @attention 特になし
// */
// extern char *
// checkMountMedia( const char *path);
/**
* @brief 指定パスがマウントメディアかどうか判定する
*
* @details 指定パスがマウント対象となるメディアかどうか確認し、マウントパスを返す
*
* @description
* @param[in] *path 指定パス
* @param[out] *cMedia 対象デバイス文字列[最低10文字確保](/mnt/usb、/mnt/sd等）、対象外の場合は空
* @return 0：対象外デバイス/1：対象デバイス（/mnt/usb、/mnt/sd等）
* @attention 特になし
*/
extern int
checkMountMedia( const char *path, char *cMedia);
// #11965 2025.07.11 mod 戻り値をなしにして引数に変更 TDC米沢 end

/**
* @brief 指定メディアがマウントされているかどうか
*
* @details 指定したメディアのマウント確認を行う
*
* @description
* @param[in] *cMedia 対象デバイス（/mnt/usb、/mnt/sd等）
* @return mountの戻り値(0：未マウント/1：マウント済)
* @attention 特になし
*/
extern int
isMounted(char * dev_path);

/**
* @brief 指定メディアがReadOnlyかどうかチェックする
*
* @details 指定したメディアがReadOnlyかどうかチェックする
*
* @description
* @param[in] *cMedia 対象デバイス（/mnt/usb、/mnt/sd等）
* @return 1：ReaOnly/else：ReadOnly以外
* @attention 特になし
*/
int
checkReadOnlyMedia(char * cMedia);

/**
 * @brief 指定メディアの再マウント処理
*
* @details 指定したメディアの再マウントを行う
*
* @description
* @param[in] *cMedia 対象デバイス（/mnt/usb、/mnt/sd等）
* @return mountの戻り値(0：成功/else：失敗)
* @attention 特になし
*/
int
Remount(char *cMedia);

/**
* @brief 指定フォルダがマウント対象かどうか判定し、ReadOnlyの場合は再マウント処理を行う
*
* @details 指定フォルダがマウント対象（/mnt/usb、/mnt/sd等）かどうか判定し、ReadOnlyの場合は再マウント処理を行う
*
* @description
* @param[in] *path  フォルダ/ファイル
* @return 1：成功/else：失敗
* @attention 特になし
*/
int
checkReadOnlyFolder( char *path );


/**
* @brief 文字列置き換え
*
* @details 文字列の置き換え処理を行う
*
* @description
* @param[in/out]    *cBuffer    置き換え対象文字列
* @param[in]        *cBeforeStr 置き換え元文字列
* @param[in]        *cAfterStr  置き換え先文字列
* @return 1：成功/else：失敗
* @attention 特になし
*/
extern int
strReplace( u_char *cBuffer
          , int nBufferSize
          , const u_char *cBeforeStr
          , const u_char *cAfterStr
          );

// 

/**
* @brief フォルダ/ファイルの作成結果による処理
*
* @details フォルダ/ファイルの作成結果によりエラーファイルの作成/削除を行う
*
* @description
* @param[in]        nResult 処理結果
* @param[in]        *cName  フォルダ/ファイル名
* @return なし
* @attention 特になし
*/
extern void
checkCreateFolderFileResult( int nResult
                           , const u_char *cName );

// #8081 add 2023.05.09 通信不可状態をファイルの有無により決定 TDC米沢 start
#include <stdbool.h>
/// 通信許可ファイル
#define NTSS_COMM_ENABLED_FILE  "/tmp/ntss_comm_enabled.dat"

/**
* @brief 通信許可状態変更
*
* @details 通信許可状態切り替えを行う
*
* @description
* @param[in]        bEnabled 通信許可状態[true：許可/false：不可]
* @return なし
* @attention 特になし
*/
extern void
changeCommEnabledState( bool bEnabled );

/**
* @brief 通信許可状態取得
*
* @details 通信許可状態の取得を行う
*
* @description
* @return なし
* @attention 特になし
*/
extern bool
isCommEnableState();
// #8081 add 2023.05.09 通信不可状態をファイルの有無により決定 TDC米沢 end

// #8729 2023.05.29 add RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
/**
 * @brief ファイル情報構造体
 */
typedef struct
{
    int64_t lastTime;     // 最終アクセス時間
    int16_t type;         // 0:なし, 1:日機装（新）通信 , 2:NX通信, 3:通信共通プロトコル
    u_char fileDir[255];  // ディレクトリパス
    u_char fileName[255]; // ファイル名
} FileData_t;

extern uint16_t
readFileOneLine(u_char *buff, uint16_t max_size, const u_char *filePath);

extern int16_t
renameFile(const u_char *oldFile, const u_char *newFile);

/**
 * @brief 指定サイズをオーバーするファイルを日付付与でリネームする
 * @details 指定サイズをオーバーするファイルを末尾に日付情報を付与してリネームする
 * 
 * @param oldFile 対象ファイル
 * @param hasDate 付与文字列設定 Trueの場合は yyyyMMddHHmmss Falseの場合は _HHmmss
 * @param maxSize しきい値となるファイル
 * @return 成功・失敗
 */
extern bool
backupRenameFile(u_char *oldFile, bool hasDate, uint64_t maxSize);

/**
 * @brief 指定したファイル名のbackupRenameFile()で作成されたバックアップファイルを名前順にソートして指定件数を残して削除する
 * 
 * @param baseFileName ベースになるファイル名
 * @param keepCount キープ件数
 * @return true 成功
 * @return false 失敗
 */
extern bool
removeBackupFileByNameSort(u_char *baseFileName, uint16_t keepCount);

extern bool
stat_mkdir(const u_char *filepath);

extern bool
removeFile(const u_char *dirPath, const u_char *fileName);
extern bool
removeFileFullPath(const u_char *filePath);
// #8729 2023.05.29 add RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end

// #11567 2025.04.07 add 指定された外部メディアが未マウントの場合にマウントを行う TDC米沢 start
/**
* @brief 指定メディアのマウント状態をチェックして未マウントの場合はマウントを行う
*
* @details 指定メディアのマウント状態をチェックして未マウントの場合はマウントを行う
*
* @description
* @param[in] *cMedia 対象デバイス（/mnt/usb、/mnt/sd等）
* @attention 特になし
*/
void
checkUnmountToMount( char *cMedia );
// #11567 2025.04.07 add 指定された外部メディアが未マウントの場合にマウントを行う TDC米沢 end
// #11567 2025.04.08 add マウント/再マウント実施成功した場合に書き込み可能かテストする TDC米沢 start
/**
* @brief 指定メディアが書き込み可能かどうかテストする
*
* @details 指定メディアが書き込み可能かどうかテストする
*
* @description
* @param[in] *cMedia 対象デバイス（/mnt/usb、/mnt/sd等）
* @return 1：書き込み可能/0：書き込み不可
* @attention 特になし
*/
int
checkWriteMountMedia(char *cMedia);
// #11567 2025.04.08 add マウント/再マウント実施成功した場合に書き込み可能かテストする TDC米沢 end

#endif
