/**
* @brief NTSS暗号/復号関数ファイル
*
* @details NTSS暗号/復号関数
*
* @description ntss program

* Copyright (C) 2017, TDC, all right reserved.
*
* @file ntss_enc_dec.c
* @author H.Yonezawa
* @date 2017/12/21
*/


#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <string.h>
#include <sys/stat.h>

#include "ntss_enc_dec.h"
#include "ntss_etc_lib.h"


/// 暗号/復号化パスワード
#define NTSS_AES256_PASSWORD "Ntss2017_Nkk_Tdc"


/**
* @brief 指定文字列を暗号/復号化する
*
* @details 指定文字列を暗号/複合化する
*
* @description
* `param[in]    Mode        処理方法
* @param[in]    *cText      暗号/復号化する文字列
* @param[in]    nBufferSize バッファーサイズ
* @param[out]   *cBuffer    暗号/復号化文字列格納先バッファ
* @return １：復号成功/else：復号失敗
* @attention 特になし
*/
int
encdecNTSSText( NtssEncDecNtssTextMode Mode
              , u_char *cText
              , int nBufferSize
              , u_char *cBuffer
              )
{
    int ret = 0;
    u_char cfile[NTSS_STR_MAX_SIZE];
    u_char cbuff[NTSS_STR_MAX_SIZE];
    u_char *cmd = "";
    FILE *fp;

    // 作業用ファイル名作成
    strcpy(
          cfile
        , "/tmp/tmp.XXXXXX"
    );

    // ファイル出力(ファイル名作成)
    int fd = mkstemp( cfile );
    if( fd != 0 )
    {
        //
        close(fd);

        // コマンド作成
        switch( Mode )
        {
            case NTSS_ENCDECNTSSTEXT_MODE_ENC:  // 暗号化
                cmd = "echo \"%s\" | openssl aes-256-cbc -e -base64 -A -k \"%s\" > %s";
                break;

            case NTSS_ENCDECNTSSTEXT_MODE_DEC:  // 復号化
                cmd = "echo \"%s\" | openssl aes-256-cbc -d -base64 -A -k \"%s\" > %s";
                break;
        }
        sprintf(
              cbuff
            , cmd
            , cText
            , NTSS_AES256_PASSWORD
            , cfile
        );

        // コマンド実行(終了ステータス：コマンドの終了ステータス値 & 0377)
        int res = system( cbuff );
        if( WIFEXITED( res ) )
        {
            // 子プロセスが正常に終了した場合

            // 子プロセスの終了ステータスを取得
            res = WEXITSTATUS( res );
        }
        //// debug
        //printf( "EncDec : %s\n %d\n", cbuff, res );
        if( res == 0 )
        {
            // 暗号/復号化した文字列を取得

            // ファイルの存在確認
            if( existFolderFile( cfile, NULL ) == 1 )
            {
                // 対象ファイルあり

                // ファイルを開く
                if (( fp = fopen( cfile, "r" )) != NULL )
                {
                    // 情報読み込み
                    if( 0 < fread( cBuffer, 1, nBufferSize, fp ))
                    {
                        ret = 1;
                    }
                    // 末尾のLFを除去
                    trimEnd( cBuffer, '\n' );

                    fclose(fp);
                }
            }
        }

        // ファイル削除
        remove( cfile );
    }

    return ret;
}