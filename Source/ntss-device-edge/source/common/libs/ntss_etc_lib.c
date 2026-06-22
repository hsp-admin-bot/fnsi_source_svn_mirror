/**
* @briefNTSS汎用関数
*
* @details NTSS汎用関数
*
* @description ntss program
* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_etc_lib.c
* @author H.Yonezawa
* @date 2017/11/06
*/

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <sys/time.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/file.h>
#include <fcntl.h>
#include <libgen.h>
#include <dirent.h>
#include <mntent.h>

#include "../libs/ntss_etc_lib.h"
#include "../libs/ntss_log_lib.h"
#include "../nkklib/nkklib.h"

// #11567 2025.04.07 add 外部メディアマウントパラメータ TDC米沢 start
// USBマウントコマンド
#define USB_MOUNT_CMD   "sudo mount -w -t vfat /dev/disk/by-path/platform-musb-hdrc.0-usb-0:1:1.0-scsi-0:0:0:0-part1 /mnt/usb"
// SDマウントコマンド
#define SD_MOUNT_CMD    "sudo mount -w -t vfat /dev/mmcblk0p1 /mnt/sd"
// #11567 2025.04.07 add 外部メディアマウントパラメータ TDC米沢 end

// #11965 2025.07.11 add 外部メディア定義 TDC米沢 start
// mntメデイア定義
static char *mnt_usb = "/mnt/usb";
static char *mnt_sd = "/mnt/sd";
// #11965 2025.07.11 add 外部メディア定義 TDC米沢 end

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
void
addFolderSeparator( u_char *folder )
{
    const u_char cSeparator[] = {'/', '\0'};
    int nsize;
    
    if(0 < ( nsize = strlen( folder )))
    {
        if( folder[nsize - 1] != cSeparator[0] )
        {
            // 末尾に'/'追加
            strcat( folder, cSeparator );
        }
    }
}

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
int
existFolderFile( const u_char *item
               , struct stat *pst
               )
{
    int ret = 0;

    struct stat st;
    if( stat( item, &st ) == 0)
    {
        // 情報あり

        ret = 1;

        int isMount = 1;

        // マウントメディア判定
        // #11965 2025.07.11 mod 関数修正対応 TDC米沢 start
        // char *dev = checkMountMedia( item );
        // if( dev != NULL )
        char dev[10] = {0};
        if( checkMountMedia( item,  dev) == 1 )
        // #11965 2025.07.11 mod 関数修正対応 TDC米沢 end
        {
            // マウントチェック
            if( isMounted( dev ) == 0 )
            {
                // マウントされていない場合
                ret = 0;
            }
        }

        // stat構造体が指定されているかどうか
        if( ret == 1 && pst != NULL )
        {
            memmove( pst, &st, sizeof(st));
        }
    }

    return ret;
}

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
int
createFolder( const u_char *folder )
{
    int ret = 0;

    // マウントメディア判定
    // #11965 2025.07.11 mod 関数修正対応 TDC米沢 start
    // char *dev = checkMountMedia( folder );
    // if( dev != NULL )
    char dev[10] = {0};
    if( checkMountMedia( folder,  dev) == 1 )
    // #11965 2025.07.11 mod 関数修正対応 TDC米沢 end
    {
        // マウントチェック
        if( isMounted( dev ) == 0 )
        {
            // マウントされていない場合

            // フォルダ/ファイルの作成結果による処理
            checkCreateFolderFileResult( 0, folder );

            return -3;
        }
    }

    // マスク値変更
    mode_t old_mask = umask(0000);

    // // フォルダ作成
    // ret = mkdir(
    //       folder
    //     , S_IRWXU | S_IRWXG | S_IRWXO
    //     ); 
    
    char *tok, *work, *path, *ptr;
    int len;
    struct stat sb;

    len = strlen(folder) + 1;
    work = malloc(len);
    path = malloc(len);
    strcpy(work, folder);
    path[0] = 0;
    if( work[0] == '/' )
    {
        strncat(path, "/\0", len);
    }
//printf( "folder:%s\r\n", work );

    // 先頭フォルダ切り出し
    tok = strtok_r( work, "/", &ptr );
    if(tok)
    {
        strncat(path, tok, len);
    }
    //snprintf(path, len, "%s", tok );
    while(1)
    {
//printf( "path:%s\r\n", path );
        // フォルダチェック
        if(stat(path, &sb) < 0) 
        {
            // フォルダがない場合
            
            // /mnt or /mnt/usb or /mnt/sd は作成失敗とする
            if( strcasecmp( path, "/mnt" ) == 0
		    // #11965 2025.07.11 mod 関数修正対応 TDC米沢 start
            // || strcasecmp( path, "/mnt/usb" ) == 0
            // || strcasecmp( path, "/mnt/sd" ) == 0
             || strcasecmp( path, mnt_usb ) == 0
             || strcasecmp( path, mnt_sd ) == 0
		    // #11965 2025.07.11 mod 関数修正対応 TDC米沢 end
            )
            {
                ret = -2;
            }
            else
            {
                // フォルダ作成
                ret = mkdir(path
                            , S_IRWXU | S_IRWXG | S_IRWXO
                            ); 
            }
        }

        // フォルダチェック
        if(!S_ISDIR(sb.st_mode) || ret != 0) {
            break;
        }

        // 次フォルダ切り出し
        tok = strtok_r( NULL, "/", &ptr );
        if(!tok)
        {
            // 最終フォルダ
            break;
        }

        // 対象フォルダ名作成
        strncat(path, "/", len);
        strncat(path, tok, len);
    }
    free(path);
    free(work);
    
    // 変更したマスク値を元に戻す
    umask(old_mask);
    
    //
    if(ret == 0 )
    {
        ret = 1;
    }

    // 未マウント、マウント先なし以外の場合
    if( -1 <= ret ) {
        // フォルダ/ファイルの作成結果による処理
        checkCreateFolderFileResult( ret, folder );
    }

    return ret;
}


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
int
outputFile( u_char *fileName
          , u_char *data
          , int dataLength
          )
{
    int ret = 0;
    int fd;

    // マスク値変更
    mode_t old_mask = umask(0000);
                                            
    // ファイル出力
    fd = open( fileName
        , O_CREAT | O_WRONLY | O_TRUNC
        , S_IRWXU | S_IRWXG | S_IRWXO
        );
        
    // 変更したマスク値を元に戻す
    umask(old_mask);

    // 
    if ( 0 <= fd )
    {
        // データ書き込み
        // #8081 mod 2023.05.09 通信不可状態をファイルの有無により決定 TDC米沢 start
        //if (write( fd, data, dataLength ) == dataLength){
        if (dataLength == 0 || (0 < dataLength && write( fd, data, dataLength ) == dataLength)){
        // #8081 mod 2023.05.09 通信不可状態をファイルの有無により決定 TDC米沢 start
            ret = 1;
        }
        close( fd );
    }

    // フォルダ/ファイルの作成結果による処理
    checkCreateFolderFileResult( ret, fileName );

    return ret;    
}

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
int
outputAppendFile( u_char *fileName
                , u_char *data
                , int dataLength
                )
{
    int ret = 0;
    int fd;

    // マスク値変更
    mode_t old_mask = umask(0000);
                                            
    // ファイル出力
    fd = open( fileName
        , O_CREAT | O_WRONLY | O_APPEND
        , S_IRWXU | S_IRWXG | S_IRWXO
        );
        
    // 変更したマスク値を元に戻す
    umask(old_mask);

    // 
    if ( 0 <= fd )
    {
        // 排他ロックを適用
        if (flock(fd, LOCK_EX) == 0) {
            // データ書き込み
            if (write( fd, data, dataLength ) == dataLength){
                ret = 1;
            }
            // ロックを解除
            flock(fd, LOCK_UN);
        }
        close( fd );
    }

    // フォルダ/ファイルの作成結果による処理
    checkCreateFolderFileResult( ret, fileName );

    return ret;    
}

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
int
getFolderList( u_char *cFolder
             , u_char *cListFileName
             , NtssGetFolderListMode mode
             )
{
    int ret = 0;
    DIR *dir;
    struct dirent *dp;
    u_char cbuf[ NTSS_STR_MAX_SIZE + 1 ];

    // 出力ファイル削除
    remove( cListFileName );

    // 指定ディレクトリを開く
    if(( dir = opendir( cFolder )) != NULL )
    {
        //　ディレクトリ内の情報を取得する
        for( dp = readdir( dir ); dp != NULL; dp = readdir( dir ))
        {
            //// debug
            //printf( "getFolderList %s->%s\n", cFolder, dp->d_name );

            // 指定された種類の情報かどうか判定
            if(( mode == NTSS_GETFOLDERLIST_MODE_FOLDER_ONLY && dp->d_type == DT_DIR )
              || ( mode == NTSS_GETFOLDERLIST_MODE_FILE_ONLY && dp->d_type == DT_REG ))
            {
                // 一致した場合

                // リストファイルに追記
                sprintf(
                      cbuf
                    , "%s\n"
                    ,dp->d_name
                );
                outputAppendFile(
                      cListFileName
                    , cbuf
                    , strlen( cbuf )
                );
            }
        }
        closedir(dir);

        ret = 1;
    }

    return ret;
}

/**
* @brief ファイルをコピーする
*
* @details ファイルをコピーする
*
* @description
* @param[in] *sourceFileName    コピー元ファイル名(フルパス含む)
* @param[in] *destFileName      コピー先ファイル名(フルパス含む)
* @param[in] mode               コピー先ファイルが存在する場合の処理方法[NTSS_MOVEFILE_MODE_NO_OVERWRITE：上書きしない/NTSS_MOVEFILE_MODE_OVERWRITE：上書きする]
* @return 1：コピー成功/else：コピー失敗
* @attention 特になし
*/
int 
copyFile( u_char *sourceFileName
        , u_char *destFileName
        , NtssCopyFileMode mode
        )
{
    int ret = 0;
    u_char cbuff[ NTSS_STR_MAX_SIZE ];

    // #12071 2025.11.25 add コピー元ファイルがない場合は処理中止 TDC米沢 start
    if( existFolderFile( sourceFileName, NULL) != 1 )
    {
        return ret;
    }
    // #12071 2025.11.25 add コピー元ファイルがない場合は処理中止 TDC米沢 end

    // コピー先ファイル存在判定
    if( existFolderFile( destFileName, NULL ) == 1 )
    {
        // コピー先ファイルあり

        // 上書き判定
        if( mode == NTSS_COPYFILE_MODE_OVERWRITE )
        {
            // 上書き実施

            // コピー先ファイルを削除
            remove( destFileName );
        }
        else
        {
            // 上書き禁止

            // 処理中止
            return ret;
        }
    }
        
    // ファイルコピー
    sprintf(
          cbuff
        , "cp \"%s\" \"%s\""
        , sourceFileName
        , destFileName
    );

    // ファイルコピー実行
    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    ret = system( cbuff );
    if( WIFEXITED( ret ))
    {
        // 子プロセスが正常に終了した場合

        // 子プロセスの終了ステータスを取得
        ret = WEXITSTATUS( ret );
        if( ret == 0 )
        {
            ret = 1;
        }
        // #12071 2025.11.25 add コピー失敗時の処理が実装されていないので追加 TDC米沢 start
        else
        {
            ret = 0;
        }
        // #12071 2025.11.25 add コピー失敗時の処理が実装されていないので追加 TDC米沢 end
    }

    return ret;
}

/**
* @brief ファイルを移動
*
* @details ファイルを移動する
*
* @description
* @param[in] *sourceFileName    移動元ファイル名(フルパス含む)
* @param[in] *destFileName      移動先ファイル名(フルパス含む)
* @param[in] mode               移動先ファイルが存在する場合の処理方法[NTSS_MOVEFILE_MODE_NO_OVERWRITE：上書きしない/NTSS_MOVEFILE_MODE_OVERWRITE：上書きする]
* @return 1：移動成功/else：移動失敗
* @attention 特になし
*/
int 
moveFile( u_char *sourceFileName
        , u_char *destFileName
        , NtssMoveFileMode mode
        )
{
    int ret = 0;

    // #12071 2025.11.25 add 移動元ファイルがない場合は処理中止 TDC米沢 start
    if( existFolderFile( sourceFileName, NULL) != 1 )
    {
        return ret;
    }
    // #12071 2025.11.25 add 移動元ファイルがない場合は処理中止 TDC米沢 end

    // 移動先ファイル存在判定
    if( existFolderFile( destFileName, NULL ) == 1 )
    {
        // 移動先ファイルあり

        // 上書き判定
        if( mode == NTSS_MOVEFILE_MODE_OVERWRITE )
        {
            // 上書き実施

            // 移動先ファイルを削除
            remove( destFileName );
        }
        else
        {
            // 上書き禁止

            // 処理中止
            return ret;
        }
    }
/*        
    // ファイル移動
    if( rename( sourceFileName, destFileName ) == 0 )
    {
        ret = 1;
    }
*/
    // ファイルコピー
    ret = copyFile( sourceFileName, destFileName, NTSS_COPYFILE_MODE_OVERWRITE );
    if( ret == 1 )
     {
        // 移動元ファイルを削除
        remove( sourceFileName );
     }

    return ret;
}

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
int
existFolderInFiles( u_char *cFolder
                  )
{
    int ret = -1;
    DIR *dir;
    struct dirent *dp;

    // 指定ディレクトリを開く
    if(( dir = opendir( cFolder )) != NULL )
    {
        ret = 0;

        //　ディレクトリ内の情報を取得する
        for( dp = readdir( dir ); dp != NULL; dp = readdir( dir ))
        {
            //// debug
            //printf( "getFolderList %s->%s\n", cFolder, dp->d_name );

            // ファイルが見つかっったかどうか判定
            if( dp->d_type == DT_REG )
            {
                // ファイルあり

                ret = 1;

                break;
            }
        }
        closedir(dir);
    }

    return ret;
}

/**
* @brief 指定フォルダ内の全ファイルを削除する
*
* @details 指定フォルダ内の全ファイルを削除する
*
* @description
* @param[in] *cFolder   格納全ファイルを削除するフォルダ
* @return 1：削除成功/else：削除失敗
* @attention 特になし
*/
int
deleteFolderInFiles( u_char *cFolder
                   )
{
    int ret = 0;
    u_char cbuff[ NTSS_STR_MAX_SIZE ];

    // 指定フォルダ存在確認
    if( existFolderFile( cFolder, NULL ) == 1 )
    {
        //
        sprintf( 
              cbuff
            , "find \"%s\" -maxdepth 1 -type f -print0 |xargs -0 rm -f"
            , cFolder
        );
        // コマンド実行((終了ステータス：子プロセスの終了ステータス値 & 0377)
        int res = system( cbuff );
        if( WIFEXITED( res ) )
        {
            // 子プロセスが正常に終了した場合

            // 子プロセスの終了ステータスを取得
            res = WEXITSTATUS( res );
        }
        if( res == 0 )
        {
            ret  = 1;
        }
    }

    return ret;
}

/**
 * @brief Get the Free Size 
 * 
 * @param path フォルダパス
 * @return unsigned long long 指定フォルダの空き容量　エラー時は(0)
 */
unsigned long long
getFreeSize(u_char *path){
    struct statvfs buff = {0};
    if(statvfs(path, &buff) != 0){
        return 0;
    }
    unsigned long long freesize = (long long)buff.f_bfree * (long long)buff.f_bsize / (1000 * 1000);

    // マウントメディア判定
    // #11965 2025.07.11 mod 関数修正対応 TDC米沢 start
    // char *dev = checkMountMedia( path );
    // if( dev != NULL )
    char dev[10] = {0};
    if( checkMountMedia( path,  dev) == 1 )
    // #11965 2025.07.11 mod 関数修正対応 TDC米沢 end
    {
        // マウントチェック
        if( isMounted( dev ) == 0 )
        {
            // マウントされていない場合

            // 空き容量を0とする
            freesize = 0;
        }
        else
        {
            // マウント済み

            // メディアのReadOnlyチェック
            if( checkReadOnlyFolder( path ) != 1 )
            {
                // 再マウント失敗

                // 空き容量を0とする
                freesize = 0;
            }
        }
    }

    return freesize;
}

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
void
trimEnd( u_char *cText
       , u_char cTrimCharactor
       )
{
    // NULL判定
    if( cText != NULL )
    {
        // 文字列長取得
        int intsize = strlen( cText ) - 1;
        
        // 末尾からチェック
        for( ; 0<= intsize ; intsize-- )
        {
            // 指定文字判定
            if( cText[ intsize ] == cTrimCharactor )
            {
                // 指定文字の場合

                // NULL文字に変更
                cText[ intsize ] = 0;
            }
            else
            {
                // 指定文字以外の場合

                // 処理中止
                break;
            }
        }
    }
}


/**
* @brief 自プロセス名を取得する
*
* @details 次プロセス名を取得する
*
* @description
* @param[in] *cName         取得名称
* @param[in] nBufferSize    取得可能領域サイズ
* @param[in] cFullPath      フルパス付加フラグ[0x00:含めない/0x01:含める]
* @return なし
* @attention 特になし
*/
void
getProcessName( u_char *cName
              , int nBufferSize
              , u_char cFullPath
              )
{
    // 自プロセス名を取得
    readlink( "/proc/self/exe", cName, nBufferSize );

    //
    if( cFullPath == 0x00 )
    {
        sprintf( cName, "%s", basename( cName ));
    }    
}


/**
* @brief 10進表記のIPアドレスを取得する
*
* @details 10進表記のIPアドレスを取得する
* 数値の前が0で産められている場合は8進数となる場合があるため
* 0埋めを除去する
*
* @description
* @param[in]    *cBaseIPAddr 変換前IPアドレス
* `param[out]   *cCnvIPAddr  変換後IPアドレス
* @return なし
* @attention 特になし
*/
void 
getDecimalIPAddr( u_char *cBaseIPAddr
                , u_char *cConvIPAddr
                )
{
    u_char cbuf[16];
    u_char *p[] = { cbuf, NULL, NULL, NULL };
    int intlop;
    int idx = 1;

    // 指定値の10進化[前方0埋め値は8進として処理されてしまうため]
    memmove( cbuf, cBaseIPAddr, sizeof( cbuf ));
    for( intlop = 1; intlop < strlen( cBaseIPAddr ); intlop++ )
    {
        if( cbuf[ intlop ] == '.' )
        {
            //
            cbuf[ intlop ] = 0;
            p[idx++] = &cbuf[ intlop + 1];
        }    
    }  

    // mod FNSI-バグ 通信サーバ 高 start
    // sprintf( cConvIPAddr, "%d.%d.%d.%d", atoi( p[0] ), atoi( p[1] ), atoi( p[2] ), atoi( p[3] ));
    switch(idx) {
        case 1:
            sprintf( cConvIPAddr, "%d", atoi( p[0] ));
            break;
        case 2:
            sprintf( cConvIPAddr, "%d.%d", atoi( p[0] ), atoi( p[1] ));
            break;
        case 3:
            sprintf( cConvIPAddr, "%d.%d.%d", atoi( p[0] ), atoi( p[1] ), atoi( p[2] ));
            break;
        case 4:
            sprintf( cConvIPAddr, "%d.%d.%d.%d", atoi( p[0] ), atoi( p[1] ), atoi( p[2] ), atoi( p[3] ));
            break;
        default:
            sprintf( cConvIPAddr, "%d", atoi( p[0] ));
            break;
            
    }
    // mod FNSI-バグ 通信サーバ 高 end

    //// debug
    //printf( "%s -> %s\n", cBaseIPAddr, cConvIPAddr );    
}

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
               )
{
    u_char  ret = 0;
    int     cwork;
    int     intlop;

    for( intlop = 0; intlop < 2; intlop++ )
    {
        cwork = cHexStr[ intlop ];
        if( '0' <= cwork && cwork <= '9' )
        {
            ret |= ( cwork - '0' );
        }
        else if( 'a' <= cwork && cwork <= 'f')
        {
            ret |= ( 10 + cwork - 'a' );
        }
        else if( 'A' <= cwork && cwork <= 'F')
        {
            ret |= ( 10 + cwork - 'A' );
        }

        // 上位桁
        if( intlop == 0 ) 
        {
            ret <<= 4;
        }

        //// debug
        //printf( "%c %.02X\n", cwork, ret );
    }

    return ret;
}

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
subStr(char *cStr, int maxLength)
{
    int i = 0, iCnt = 0;

    while (cStr[i] != '\0') {
        if (iCnt >= maxLength) {
            cStr[i] = '\0';
            break;
        }

        iCnt++;
        i += countByteUChar(cStr[i]);
    }

    return iCnt;
}

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
int countByteUChar(u_char cChar)
{
    int iByte;

    if ((cChar >= 0x00) && (cChar <= 0x7f)) {
        iByte = 1;
    } else if ((cChar >= 0xc2) && (cChar <= 0xdf)) {
        iByte = 2;
    } else if ((cChar >= 0xe0) && (cChar <= 0xef)) {
        iByte = 3;
    } else if ((cChar >= 0xf0) && (cChar <= 0xf7)) {
        iByte = 4;
    } else if ((cChar >= 0xf8) && (cChar <= 0xfb)) {
        iByte = 5;
    } else if ((cChar >= 0xfc) && (cChar <= 0xfd)) {
        iByte = 6;
    } else {
        iByte = 0;
    }

    return iByte;
}

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
int getFileCount(char *cFolder)
{
    int count; 
    FILE *fp;
    char buf[NTSS_STR_MAX_SIZE];
    char cmdline[NTSS_STR_MAX_SIZE];
    //char *cmd = "ls -FU1 \%s 2>/dev/null | grep -v / | wc -l";
    char *cmd = "find \%s -type f 2>/dev/null | wc -l";

    count = 0;
    sprintf(cmdline, cmd, cFolder);
    if ( (fp=popen(cmdline,"r")) != NULL) {
        // while(fgets(buf, BUF, fp) != NULL) {
        //     ret = atoi(buf);
        // }
        if (fgets(buf, NTSS_STR_MAX_SIZE, fp) != NULL) {
            count = atoi(buf);
        }
    }
    pclose(fp);

    return count;
}

/**
* @brief LTE/3Gモジュールのアンテナレベル取得
*
* @details LTE/3Gモジュールのアンテナレベルを取得
*
* @description
* @return 出力情報（改行無し）
* @attention 特になし
*/
char *getAntenna()
{
    FILE *fp;
    char buf[NTSS_STR_MAX_SIZE];
    char *cmdline = "curl http://localhost:4112/antenna 2>/dev/null";
    static char list[NTSS_STR_MAX_SIZE];

    memset(list, 0, sizeof(list));
    if ( (fp=popen(cmdline,"r")) != NULL) {
        if (fgets(buf, NTSS_STR_MAX_SIZE, fp) != NULL) {
            strcat(list, buf);
        }
    }
    pclose(fp);

    return list;
}

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
char *getNetworkStat(char *cDev)
{
    FILE *fp;
    char buf[NTSS_STR_MAX_SIZE];
    char cmdline[NTSS_STR_MAX_SIZE];
    char *cmd = "ip -s link show dev \%s 2>/dev/null";
    static char list[NTSS_STR_MAX_SIZE * 6];

    memset(list, 0, sizeof(list));
    sprintf(cmdline, cmd, cDev);
    if ( (fp=popen(cmdline,"r")) != NULL) {
        while(fgets(buf, NTSS_STR_MAX_SIZE, fp) != NULL) {
            strcat(list, buf);
        }
    }
    pclose(fp);

    return list;
}

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
// char *
// checkMountMedia(const char *path)
// {
//     char *ret = NULL;
//     char *dev = NULL;

//     // /mnt/usbマウント判定
//     //dev = "/mnt/usb";
//     if( strncasecmp( path, dev, strlen( dev )) == 0 )
//     {
//         // マウント対象
//         ret = dev;
//     }
//     else
//     {
//         // /mnt/sdマウント判定
//         //dev = "/mnt/sd";
//         if( strncasecmp( path, dev, strlen( dev )) == 0 )
//         {
//             // マウント対象
//             ret = dev;
//         }
//     }

//     return ret;
// }
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
int
checkMountMedia(const char *path, char *cMedia)
{
    int ret = 0;
    cMedia[0] = NULL;

    // /mnt/usbマウント判定
    if( strncasecmp( path, mnt_usb, strlen( mnt_usb )) == 0 )
    {
        // マウント対象
        ret = 1;
        strcpy(cMedia, mnt_usb);
    }
    else
    {
        // /mnt/sdマウント判定
        if( strncasecmp( path, mnt_sd, strlen( mnt_sd )) == 0 )
        {
            // マウント対象
            ret = 1;
            strcpy(cMedia, mnt_sd);
        }
    }

    return ret;
}
// #11965 2025.07.11 mod 戻り値をなしにして引数に変更 TDC米沢 

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
int
isMounted(char * dev_path)
{
    FILE * mtab = NULL;
    
    struct mntent * part = NULL;
    
    int is_mounted = 0;

    if (( mtab = setmntent("/etc/mtab", "r")) != NULL )
    {
        while(( part = getmntent( mtab )) != NULL && is_mounted == 0 )
        {
            if(( part->mnt_fsname != NULL ) 
            && ( strcmp( part->mnt_dir, dev_path )) == 0 )
            {
                is_mounted = 1;
            }
        }
        
        endmntent( mtab );
    }
    return is_mounted;
}

/**
* @brief 指定メディアがReadOnlyかどうかチェックする
*
* @details 指定したメディアがReadOnlyかどうかチェックする
*
* @description
* @param[in] *cMedia 対象デバイス（/mnt/usb、/mnt/sd等）
* @return 1：Reaonly/else：ReadOnly以外
* @attention 特になし
*/
int
checkReadOnlyMedia(char * cMedia)
{
    int ret = 0;
    unsigned char cbuff[NTSS_STR_MAX_SIZE];
    // #11567 2025.04.04 add ReadOnly判定根拠をログに記録する TDC米沢 start
    unsigned char log[NTSS_STR_MAX_SIZE];
    // #11567 2025.04.04 add ReadOnly判定根拠をログに記録する TDC米沢 end
    FILE *fp;

    // 処理定義
    sprintf(
          cbuff, 
        "mount -l | grep \"%s\" | grep \"(ro\""
        , cMedia);
    if ((fp = popen(cbuff, "r")) != NULL)
    {
        while (ret == 0 && fgets(cbuff, NTSS_STR_MAX_SIZE, fp) != NULL)
        {
            ret = 1;

            // #11567 2025.04.04 add ReadOnly判定根拠をログに記録する TDC米沢 start
            // ログ記録
            snprintf(log, NTSS_STR_MAX_SIZE, "mountにてReadOnlyを検出, (%s)", cMedia);
            LogOutput(NTSS_LOG_INFO, log);
            // #11567 2025.04.04 add ReadOnly判定根拠をログに記録する TDC米沢 end
        }
    }
    pclose(fp);

    // #11567 2025.04.04 add ReadOnly判定にSD/USB書き込み失敗ファイルを使用する TDC米沢 start
    // ReadOnly以外の場合
    if(ret == 0)
    {
        // 未通知
        snprintf(cbuff, NTSS_STR_MAX_SIZE, "/tmp/writeError_%s.txt", cMedia + 5 );
        if(existFolderFile(cbuff, NULL) == 1)
        {
            // ReadOnly検出
            ret = 1;

            // ログ記録
            snprintf(log, NTSS_STR_MAX_SIZE, "書き込み失敗ファイルにてReadOnlyを検出, (%s)", cbuff);
            LogOutput(NTSS_LOG_INFO, log);
        }
    }
    // #11567 2025.04.04 add ReadOnly判定にSD/USB書き込み失敗ファイルを使用する TDC米沢 end

    return ret;
}

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
Remount(char *cMedia)
{
    int ret = 0;
    unsigned char cbuff[NTSS_STR_MAX_SIZE];
    unsigned char log[NTSS_STR_MAX_SIZE];

    // 処理定義
    sprintf(
        cbuff, 
        "sudo mount -o remount,rw %s"
        , cMedia);

    // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
    ret = system(cbuff);
    if (WIFEXITED(ret))
    {
        // 子プロセスが正常に終了した場合

        // 子プロセスの終了ステータスを取得
        ret = WEXITSTATUS(ret);

        // #11567 2025.04.07 add ここで処理結果をログに記録する TDC米沢 start
        unsigned char res[30] = "成功";
        NtssLogType logtype = NTSS_LOG_INFO;
        if( ret != 0 )
        {
            // 失敗
            logtype = NTSS_LOG_ERROR;
            sprintf(res, "エラー(%d)", ret);
        }
        sprintf(log, "%s に対して再マウント実施,処理結果:%s", cMedia, res);
        LogOutput(logtype, log);

        // 再マウントに成功した場合
        if(ret == 0 )
        {
            // 書き込みチェック
            if( checkWriteMountMedia(cMedia) == 0)
            {
                // 再マウント失敗
                ret = 1;
            }
        }

        // 再マウントに失敗、または再マウント成功後の書き込みチェックに失敗している場合
        if(ret != 0)
        {
            // 「mount -l」の結果を取得
            FILE *fp;

            // 処理定義
            sprintf(
                  cbuff, 
                "mount -l | grep \"%s\""
                , cMedia);
            if ((fp = popen(cbuff, "r")) != NULL)
            {
                while (fgets(cbuff, NTSS_STR_MAX_SIZE, fp) != NULL)
                {
                    // ログ記録
                    snprintf(log, NTSS_STR_MAX_SIZE, "再マウント後の「mount -l」結果, (%s)", cbuff);
                    LogOutput(NTSS_LOG_ERROR, log);

                    break;
                }
            }
            pclose(fp);            

            // #11567 2025.04.17 add ここでアンマウント処理を行い、結果をログに記録する TDC米沢 start
            sprintf(
                cbuff, 
                "sudo umount -l %s"
                , cMedia);
        
            // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
            ret = system(cbuff);
            if (WIFEXITED(ret))
            {
                // 子プロセスが正常に終了した場合
        
                // 子プロセスの終了ステータスを取得
                ret = WEXITSTATUS(ret);
        
                strcpy(res, "成功");
                NtssLogType logtype = NTSS_LOG_INFO;
                if( ret != 0 )
                {
                    // 失敗
                    logtype = NTSS_LOG_ERROR;
                    sprintf(res, "エラー(%d)", ret);
                }
                sprintf(log, "%s に対しアンマウント実施,処理結果:%s", cMedia, res);
                LogOutput(logtype, log);

                // 「mount -l」の結果を取得

                // 処理定義
                sprintf(
                    cbuff, 
                    "mount -l | grep \"%s\""
                    , cMedia);
                if ((fp = popen(cbuff, "r")) != NULL)
                {
                    cbuff[0] = 0;
                    logtype = NTSS_LOG_INFO;
                    while (fgets(cbuff, NTSS_STR_MAX_SIZE, fp) != NULL)
                    {
                        // 情報あり

                        logtype = NTSS_LOG_ERROR;
                        break;
                    }

                    // ログ記録
                    snprintf(log, NTSS_STR_MAX_SIZE, "アンマウント後の「mount -l」結果, (%s)", cbuff);
                    LogOutput(logtype, log);
                }
                pclose(fp);            
            }            
            else
            {
                // 子プロセスが正常に終了しなかった場合
                sprintf(cbuff, "%s に対してアンマウントを実行できませんでした,処理結果:%d", cMedia, ret);
                LogOutput(NTSS_LOG_ERROR, cbuff);
            }
            // #11567 2025.04.17 add ここでアンマウント処理を行い、結果をログに記録する TDC米沢 end
        }
        // #11567 2025.04.07 add ここで処理結果をログに記録する TDC米沢 end
    }
    // #11567 2025.04.07 add 子プロセスの実行失敗をログに記録する TDC米沢 start
    else
    {
        // 子プロセスが正常に終了しなかった場合
        sprintf(cbuff, "%s に対して再マウントを実行できませんでした,処理結果:%d", cMedia, ret);
        LogOutput(NTSS_LOG_ERROR, cbuff);
    }
    // #11567 2025.04.07 add 子プロセスの実行失敗をログに記録する TDC米沢 start

    return ret;
}

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
checkReadOnlyFolder( char *path )
{
    // #11567 2025.04.07 mod マウント対象外の場合は0を返す TDC米沢 start
    //int ret = 1;
    int ret = 0;
    // #11567 2025.04.07 mod マウント対象外の場合は0を返す TDC米沢 end

    // マウントメディア判定
    // #11965 2025.07.11 mod 関数修正対応 TDC米沢 start
    // char *dev = checkMountMedia( path );
    // if( dev != NULL )
    char dev[10] = {0};
    if( checkMountMedia( path,  dev) == 1 )
    // #11965 2025.07.11 mod 関数修正対応 TDC米沢 end
    {
        // マウントチェック
        if( isMounted( dev ) == 1 )
        {
            // マウントされている場合

            // #11567 2025.04.07 mod マウント対象の場合の初期値は1を返す TDC米沢 start
            ret = 1;
            // #11567 2025.04.07 mod マウント対象の場合の初期値は1を返す TDC米沢 end

            // ReadOnlyチェック
            if( checkReadOnlyMedia( dev ) == 1 )
            {
                // ReadOnly状態

                // 再マウント実施
                if( Remount( dev ) != 0 )
                {
                    // 再マウント失敗
                    ret = 0;
                }
            }
        }
    }

    return ret;
}


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
int
strReplace( u_char *cBuffer
          , int nBufferSize
          , const u_char *cBeforeStr
          , const u_char *cAfterStr
          )
{  
    int     ret = 1;
    char    *tmp, *p;
    long    tmplen;

    // 置き換え元文字列検索
    while(ret == 1 && ( p = strstr( cBuffer, cBeforeStr )) != NULL )
    {
        // 見つかった置き換え元文字列の先頭をNULLにする
        *p = '\0';

        // 見つかった置き換え元文字列以降の文字列を保持
        p += strlen(cBeforeStr);
        tmplen = strlen(p) + 1;
        tmp = (char*)malloc(tmplen);
        strcpy(tmp, p);

        // バッファチェック
        if((strlen( cBuffer ) + strlen( cBeforeStr )) < nBufferSize )
        {
            // 置き換え先文字列に置き換え
            strcat( cBuffer, cAfterStr );

            // バッファチェック
            if((strlen( cBuffer ) + strlen( tmp )) < nBufferSize )
            {
                // 保持した文字列を置き換えた文字列の後ろに結合
                strcat( cBuffer, tmp );
            }
            else
            {
                ret = 0;
            }
        }
        else
        {
            ret = 0;
        }
        free(tmp);
   }

   return ret;
}

/**
* @brief フォルダ/ファイルの作成結果による処理
*
* @details フォルダ/ファイルの作成結果によりエラーファイルの作成/削除を行う
*
* @description
* @param[in]        nResult 処理結果[1：作成成功/else：作成失敗]
* @param[in]        *cName  フォルダ/ファイル名
* @return なし
* @attention 特になし
*/
void
checkCreateFolderFileResult( int nResult
                           , const u_char *cName )
{
    char logMessage[NTSS_STR_MAX_SIZE];
    char unsentFileName[NTSS_STR_MAX_SIZE];
    char sentFileName[NTSS_STR_MAX_SIZE];
    char writeErrorFileName[NTSS_STR_MAX_SIZE];

    // マウントメディア判定
    // #11965 2025.07.11 mod 関数修正対応 TDC米沢 start
    // char *dev = checkMountMedia( cName );
    // if( dev != NULL )
    char dev[10] = {0};
    if( checkMountMedia( cName,  dev) == 1 )
    // #11965 2025.07.11 mod 関数修正対応 TDC米沢 end
    {
        // SD or USB

        // 未通知/通知済み書き込み失敗ファイル名を作成
        // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
        // snprintf(unsentFileName, NTSS_STR_MAX_SIZE, "./unsentWriteError_%s.txt", dev + 5 );
        // snprintf(sentFileName, NTSS_STR_MAX_SIZE,   "./sentWriteError_%s.txt", dev + 5 );
        snprintf(unsentFileName, NTSS_STR_MAX_SIZE, "/tmp/unsentWriteError_%s.txt", dev + 5 );
        snprintf(sentFileName, NTSS_STR_MAX_SIZE,   "/tmp/sentWriteError_%s.txt", dev + 5 );
        // #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end

        // ＃11567 2025.04.08 add 外部メディアの読み書き失敗時はReadOnly検出用ファイルを生成/削除する TDC米沢 start
        snprintf(writeErrorFileName, NTSS_STR_MAX_SIZE,   "/tmp/writeError_%s.txt", dev + 5 );
        // ＃11567 2025.04.08 add 外部メディアの読み書き失敗時はReadOnly検出用ファイルを生成/削除する TDC米沢 end

        // 処理結果判定
        if ( nResult == 1 ) {
            // 作成成功時の処理

            time_t tim_now;
            struct tm tmc;
            struct tm tmc_now;
            struct stat st;

            // 現在日時取得
            time( &tim_now );
            localtime_r( &tim_now, &tmc_now );
            
            // 未通知書き込み失敗ファイルの存在を確認
            if( existFolderFile( unsentFileName, &st ) == 1) {
                // 対象ファイルが存在する場合

                // ファイル作成日時を変換
                localtime_r( &st.st_mtime, &tmc );

                // 対象ファイルの作成日付が現在日付より古い場合
                if( tmc.tm_year < tmc_now.tm_year
                 || tmc.tm_mon < tmc_now.tm_mon
                 || tmc.tm_mday < tmc_now.tm_mday
                 ) {
                    // 対象ファイルを削除
                    remove( unsentFileName );

                    // ログ記録
                    snprintf(logMessage, NTSS_STR_MAX_SIZE, "書き込み失敗通知ファイルを削除, (%s)", unsentFileName);
                    LogOutput(NTSS_LOG_INFO, logMessage);
                }
            }
            // 通知済書き込み失敗ファイルの存在を確認
            if( existFolderFile( sentFileName, &st ) == 1) {
                // 対象ファイルが存在する場合
                // ファイル作成日時を変換
                localtime_r( &st.st_mtime, &tmc );
                
                // 対象ファイルの作成日付が現在日付より古い場合
                if( tmc.tm_year < tmc_now.tm_year
                 || tmc.tm_mon < tmc_now.tm_mon
                 || tmc.tm_mday < tmc_now.tm_mday
                 ) {
                    // 対象ファイルを削除
                    remove( sentFileName );

                    // ログ記録
                    snprintf(logMessage, NTSS_STR_MAX_SIZE, "通知済の書き込み失敗通知ファイルを削除, (%s)", sentFileName);
                    LogOutput(NTSS_LOG_INFO, logMessage);
                }
            }

            // ＃11567 2025.04.08 add 外部メディアの読み書き失敗時はReadOnly検出用ファイルを生成/削除する TDC米沢 start
            // 書き込み失敗ファイルの存在を確認
            if( existFolderFile( writeErrorFileName, NULL ) == 1)
            {
                // 対象ファイルを削除
                remove( writeErrorFileName );

                // ログ記録
                snprintf(logMessage, NTSS_STR_MAX_SIZE, "書き込み失敗ファイルを削除, (%s)", writeErrorFileName);
                LogOutput(NTSS_LOG_INFO, logMessage);
            }
            // ＃11567 2025.04.08 add 外部メディアの読み書き失敗時はReadOnly検出用ファイルを生成/削除する TDC米沢 end
        } else {
            // 作成失敗時の処理

            // 未通知書き込み失敗ファイルの存在確認
            // 通知済書き込み失敗ファイルの存在確認
            if( existFolderFile( unsentFileName, NULL ) == 0
             && existFolderFile( sentFileName, NULL ) == 0 ) {
                // どちらのファイルも存在しない場合

                // 未通知書き込み失敗ファイルを作成
                outputFile(
                      unsentFileName
                    , NULL
                    , 0
                );

                // ログ記録
                snprintf(logMessage, NTSS_STR_MAX_SIZE, "書き込み失敗通知ファイルを作成, (%s)", unsentFileName);
                LogOutput(NTSS_LOG_INFO, logMessage);
            }

            // ＃11567 2025.04.08 add 外部メディアの読み書き失敗時はReadOnly検出用ファイルを生成/削除する TDC米沢 start
            // 書き込み失敗ファイルの存在を確認
            if( existFolderFile( writeErrorFileName, NULL ) == 0)
            {
                //書き込み失敗ファイルを作成
                outputFile(
                    writeErrorFileName
                  , NULL
                  , 0
              );

              // ログ記録
              snprintf(logMessage, NTSS_STR_MAX_SIZE, "書き込み失敗ファイルを作成, (%s)", writeErrorFileName);
              LogOutput(NTSS_LOG_INFO, logMessage);
            }
            // ＃11567 2025.04.08 add 外部メディアの読み書き失敗時はReadOnly検出用ファイルを生成/削除する TDC米沢 end
        }
    }
}

// #8081 add 2023.05.09 通信不可状態をファイルの有無により決定 TDC米沢 start

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
void
changeCommEnabledState( bool bEnabled ) {
    // 通信状態判定
    if (bEnabled) {
        //　通信許可
        outputFile(
            NTSS_COMM_ENABLED_FILE,
            NULL,
            0
        );
    } else {
        //　通信不可
        remove(NTSS_COMM_ENABLED_FILE);
    }
}

/**
* @brief 通信許可状態取得
*
* @details 通信許可状態の取得を行う
*
* @description
* @return なし
* @attention 特になし
*/
bool
isCommEnableState() {
    // 通信許可ファイル有無判定
    return (existFolderFile(NTSS_COMM_ENABLED_FILE, NULL) == 1);
}
// #8081 add 2023.05.09 通信不可状態をファイルの有無により決定 TDC米沢 end

// #8729 2023.05.29 add RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
/**
 * @brief ファイルの１行目だけを取得する
 * 
 * @param buff 格納バッファ
 * @param max_size 最大サイズ
 * @param filePath ファイルパス
 * @return uint16_t 0:取得成功, -1:ファイルオープン失敗, -2:ファイル内容なし
 */
uint16_t
readFileOneLine(u_char *buff, uint16_t max_size, const u_char *filePath)
{
    FILE *fin;
    u_char msg[512] = {0};

    if ((fin = fopen(filePath, "r")) == NULL)
    {
        sprintf(msg, "ファイルを開けません:[%s]", filePath);
        LogResourceOutput(NTSS_LOG_ERROR, msg);
        return -1;
    }

    if (fgets(buff, max_size - 1, fin) == NULL)
    {
        /* EOF */
        fclose(fin);
        return -2;
    }
    // close
    fclose(fin);

    // 余計な改行コード削除
    if (buff[strlen(buff) - 1] == '\n')
    {
        buff[strlen(buff) - 1] = '\0';
    }

    return 0;
}

/**
 * @brief ファイルをリネームする
 * @details ファイルを移動またはリネームする。その際に全操作権限を付与する。
 * 
 * @param oldFile 元ファイルのパス
 * @param newFile 先ファイルのパス
 */
int16_t
renameFile(const u_char *oldFile, const u_char *newFile)
{

    // マスク値変更
    mode_t old_mask = umask(0000);

    uint16_t r = rename(oldFile, newFile);
    // 変更したマスク値を元に戻す
    umask(old_mask);

    return r;
}

/**
 * @brief ファイルサイズを取得する
 * 
 * @param file 
 * @return int64_t 
 */
int64_t
getFileSize(u_char *file)
{
    struct stat statBuf;

    if (stat(file, &statBuf) == 0)
        return statBuf.st_size;

    return -1;
}

/**
 * @brief 指定サイズをオーバーするファイルを日付付与でリネームする
 * @details 指定サイズをオーバーするファイルを末尾に日付情報を付与してリネームする
 * 
 * @param oldFile 対象ファイル
 * @param hasDate 付与文字列設定 Trueの場合は yyyyMMddHHmmss Falseの場合は _HHmmss
 * @param maxSize しきい値となるファイル
 * @return 成功・失敗
 */
bool backupRenameFile(u_char *oldFile, bool hasDate, uint64_t maxSize)
{

    int64_t fSize = getFileSize(oldFile);
    if (fSize != -1 && fSize > maxSize)
    {
        // 拡張子取得
        u_char ext[20] = {0};
        u_char nonExtOldFile[strlen(oldFile)];
        strncpy(nonExtOldFile, oldFile, strlen(oldFile));

        uint16_t i;
        for (i = strlen(oldFile); i > 0; i--)
        {
            if (oldFile[i] == '.')
            {
                nonExtOldFile[i] = 0x00;
                break;
            }
        }
        if (i > 0)
        {
            // 拡張子取得
            strncpy(ext, oldFile + i, strlen(oldFile) - i);
        }

        // 新しいファイル名をつくる
        u_char newname[100] = {0};
        struct tm tm;
        time_t t = time(NULL);
        localtime_r(&t, &tm);
        if (hasDate)
        {
            sprintf(newname, "%s_%04d%02d%02d%02d%02d%02d%s", nonExtOldFile, 1900 + tm.tm_year, tm.tm_mon + 1, tm.tm_mday, tm.tm_hour, tm.tm_min, tm.tm_sec, ext);
        }
        else
        {
            sprintf(newname, "%s_%02d%02d%02d%s", nonExtOldFile, tm.tm_hour, tm.tm_min, tm.tm_sec, ext);
        }

        renameFile(oldFile, newname);
    }

    return true;
}

/**
 * @brief 指定したファイル名のbackupRenameFile()で作成されたバックアップファイルを名前順にソートして指定件数を残して削除する
 * 
 * @param baseFileName ベースになるファイル名
 * @param keepCount キープ件数
 * @return true 成功
 * @return false 失敗
 */
bool
removeBackupFileByNameSort(u_char *baseFileName, uint16_t keepCount)
{
    u_char nonExtOldFile[strlen(baseFileName)];
    u_char command[NTSS_STR_MAX_SIZE] = {0}, buf[NTSS_STR_MAX_SIZE] = {0};
    FILE *fp;
    uint16_t i = 0, keepNo = 0;

    strncpy(nonExtOldFile, baseFileName, strlen(baseFileName));

    for (i = strlen(baseFileName); i > 0; i--)
    {
        if (baseFileName[i] == '.')
        {
            nonExtOldFile[i] = 0x00;
            break;
        }
    }
    snprintf(command, NTSS_STR_MAX_SIZE, "ls -r1 %s_*", nonExtOldFile);
    if ((fp = popen(command, "r")) != NULL)
    {
        while (fgets(buf, NTSS_STR_MAX_SIZE, fp) != NULL)
        {
            // 末尾の改行コード削除
            buf[strlen(buf) - 1] = 0;
            keepNo++;
            if (keepNo > keepCount)
            {
                // 維持数を超えたファイルは削除
                if(existFolderFile(buf, NULL ) == 1)
                {
                    // buf = ファイルパス
                    removeFileFullPath(buf);
                }
            }
        }
        pclose(fp);
    }
    return true;
}

/**
 * @brief 指定パスのディレクトリがなければ作成
 * 
 * @param filepath 
 * @return true 
 * @return false 
 */
bool stat_mkdir(const u_char *filepath)
{
    struct stat sb = {0};
    int rc = 0;
    u_char msg[256] = {0};

    rc = stat(filepath, &sb);
    if (rc == 0)
    {
        if (!S_ISDIR(sb.st_mode))
        {
            snprintf(msg, 256, "Not a directory: %s", filepath);
            LogResourceOutput(NTSS_LOG_ERROR, msg);
            return (false);
        }
        return (true);
    }

    rc = createFolder(filepath);
    if (rc != 1)
    {
        snprintf(msg, 256, "mkdir(%d) %s: %s", errno, strerror(errno), filepath);
        LogResourceOutput(NTSS_LOG_ERROR, msg);
        return (false);
    }

    return (true);
}

/**
 * @brief ファイル削除
 * @details ディレクトリとファイル名を指定して削除
 * 
 * @param dirPath ディレクトリ
 * @param fileName ファイル名
 * 
 * @return 成功／失敗
 */
bool removeFile(const u_char *dirPath, const u_char *fileName)
{
    u_char filePath[512] = {0};
    sprintf(filePath, "%s/%s", dirPath, fileName);
    return removeFileFullPath(filePath);
}

/**
 * @brief ファイル削除
 * @details ファイルのフルパスを指定して削除
 * 
 * @param filePath ファイルのフルパス
 * @return 成功／失敗
 */
bool removeFileFullPath(const u_char *filePath)
{
    u_char msg[256] = {0};

    // #11567 2025.04.04 add ファイルがない場合は処理を抜ける TDC米沢 start
    // ファイルの存在チェック
    if(existFolderFile(filePath, NULL) != 1)
    {
        // ファイルがない場合は処理失敗
        return false;
    }
    // #11567 2025.04.04 add ファイルがない場合は処理を抜ける TDC米沢 end

    if (remove(filePath) == 0)
    {
        snprintf(msg, 256, "%sの削除が完了しました．", filePath);
        LogOutput(NTSS_LOG_INFO, msg);
        return true;
    }
    else
    {
        snprintf(msg, 256, "%sの削除に失敗しました．", filePath);
        LogResourceOutput(NTSS_LOG_ERROR, msg);

        // メディアのチェック
        if( checkReadOnlyFolder( (u_char *)filePath ) == 1 )
        {
            // 再マウント成功

            // 再度削除を実施
            if (remove(filePath) == 0)
            {
                snprintf(msg, 256, "%sの削除が完了しました．(再マウント後)", filePath);
                LogOutput(NTSS_LOG_INFO, msg);
                return true;
            }
            else
            {
                snprintf(msg, 256, "%sの削除に失敗しました．(再マウント後)", filePath);
                LogResourceOutput(NTSS_LOG_ERROR, msg);
            }
        }

        // 
        return false;
    }
}
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
checkUnmountToMount( char *cMedia )
{
    int ret = 0;
    u_char msg[NTSS_STR_MAX_SIZE] = {0};
    u_char cbuff[NTSS_STR_MAX_SIZE * 2] = {0};

    // マウントメディア判定
    // #11965 2025.07.11 mod 関数修正対応 TDC米沢 start
    // char *dev = checkMountMedia( cMedia );
    // if( dev != NULL )
    char dev[10] = {0};
    if( checkMountMedia( cMedia,  dev) == 1 )
    // #11965 2025.07.11 mod 関数修正対応 TDC米沢 end
    {
        // 外部メディア(/mnt/sd、/mnt/usb)

        // マウントチェック
        if( isMounted( dev ) == 0 )
        {
            // 未マウント

            // ログ記録
            snprintf(msg, NTSS_STR_MAX_SIZE, "未マウントを検出, (%s)", dev);
            LogOutput(NTSS_LOG_ERROR, msg);

            // マウントを行うパラメータ作成

            // /mnt/usbマウント判定
    		// #11965 2025.07.11 mod 共通パラメータ対応 TDC米沢 start
            //char *chk = "/mnt/usb";
            char *chk = mnt_usb;
    		// #11965 2025.07.11 mod 共通パラメータ対応 TDC米沢 end
            if( strncasecmp( dev, chk, strlen( chk )) == 0 )
            {
                // usbマウントコマンド
                strcpy(cbuff, USB_MOUNT_CMD);
            }

            // /mnt/sdマウント判定
    		// #11965 2025.07.11 mod 共通パラメータ対応 TDC米沢 start
            //chk = "/mnt/sd";
            chk = mnt_sd;
    		// #11965 2025.07.11 mod 共通パラメータ対応 TDC米沢 end
            if( strncasecmp( dev, chk, strlen( chk )) == 0 )
            {
                // sd

                // SDマウントコマンド
                strcpy(cbuff, SD_MOUNT_CMD);
            }

            // コマンド実行(終了ステータス：子プロセスの終了ステータス値 & 0377)
            ret = system(cbuff);
            if (WIFEXITED(ret))
            {
                // 子プロセスが正常に終了した場合
        
                // 子プロセスの終了ステータスを取得
                ret = WEXITSTATUS(ret);
        
                unsigned char res[30] = "成功";
                NtssLogType logtype = NTSS_LOG_INFO;
                if( ret != 0 )
                {
                    // 失敗
                    logtype = NTSS_LOG_ERROR;
                    sprintf(res, "エラー(%d)", ret);
                }
                snprintf(msg, NTSS_STR_MAX_SIZE, "%s に対してマウント実施,処理結果:%s", dev, res);
                LogOutput(logtype, msg);

                // マウントに成功した場合
                if(ret == 0)
                {
                    // 書き込みチェック
                    checkWriteMountMedia(cMedia);
                }
            }
            else
            {
                // 子プロセスが正常に終了しなかった場合
                snprintf(msg, NTSS_STR_MAX_SIZE, "%s に対してマウントを実行できませんでした,処理結果:%d", dev, ret);
                LogOutput(NTSS_LOG_ERROR, msg);
            }
        }
    }
}
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
checkWriteMountMedia(char *cMedia)
{
    int ret = 0;
    u_char log[NTSS_STR_MAX_SIZE] = {0};
    u_char cbuff[NTSS_STR_MAX_SIZE] = {0};

    // チェック用ォルダ名作成
    sprintf( cbuff, "%s/checkReadOnly", cMedia);
    
    // チェック用フォルダの有無確認
    if( existFolderFile( cbuff, NULL ) != 1 )
    {
        // チェック用フォルダがない場合

        // チェック用フォルダを作成
        createFolder( cbuff );
    }

    // チェック用フォルダの有無確認
    if( existFolderFile( cbuff, NULL ) == 1 )
    {
        // チェック用フォルダがある場合
        
        // ダミーファイル名作成
        strcat(cbuff, "/dummy.XXXXXX");
        // ダミーファイル作成
        int fp = mkstemp(cbuff);
        if(fp != -1)
        {
            // ダミーファイルの作成成功

            // ダミーファイルをクローズ
            close(fp);

            // ダミーファイル削除
            if(remove(cbuff) == 0)
            {
                // ダミーファイル削除成功

                ret = 1;

                sprintf(log, "ReadOnlyチェック用ファイルの作成→削除に成功, %s", cbuff);
                LogOutput(NTSS_LOG_INFO, log);

                // ファイルの作成成功による書き込み失敗通知ファイルの削除
                checkCreateFolderFileResult( 1, cbuff );
            }
            else
            {
                //ダミーファイル削除失敗

                sprintf(log, "ReadOnlyチェック用ファイルの削除に失敗, %s", cbuff);
                LogOutput(NTSS_LOG_ERROR, log);
            }
        }
        else
        {
            // ダミーファイル作成失敗

            sprintf(log, "ReadOnlyチェック用ファイルの作成に失敗, %s", cbuff);
            LogOutput(NTSS_LOG_ERROR, log);
        }
    }
    else
    {
        // チェック用フォルダなし

        sprintf(log, "ReadOnlyチェック用フォルダの作成に失敗, %s", cbuff);
        LogOutput(NTSS_LOG_ERROR, log);
    }

    return ret;
}
// #11567 2025.04.08 add マウント/再マウント実施成功した場合に書き込み可能かテストする TDC米沢 end
