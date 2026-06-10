/**
* @file loglib.c
* @brief ログメッセージ出力関数
* @author Y.Takamura
* @date 2017/09/18
* @details ログメッセージファイル出力(追記)用の関数ライブラリ
*/

#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <libgen.h>
#include <time.h>
#include "nkklib.h"

/**
* @def DEF_LOG_FILE
* @brief ログファイル名
* @details デフォルトのログファイル名
*/
#define DEF_LOG_FILE "Execution.log"

/**
* @fn void log_output(char *msg)
* @brief ログメッセージ出力
* @param[in] *msg メッセージ文字列
* @details ログメッセージを追記形式でファイルに出力(実行ファイル名.log)
*/
void log_output(char *msg)
{
    FILE *fp;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //long tim;
    time_t tim;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    char prg_name[64];
    char buf[20],wrk[20];

	memset(prg_name, 0, sizeof(prg_name));

    //! 実行ファイル名取得
    get_prg_name(prg_name);
    if ( prg_name[0]==0 ) {
        //! 取得できなければデフォルトを使用
        strcpy(prg_name, DEF_LOG_FILE);
    }
	else {
        strcat(prg_name, ".log");
    }

    fp = fopen(prg_name, "a");
    if ( fp!=NULL ) {
        time(&tim);
        time_str(tim, buf, wrk, 1);
        fprintf(fp, "[%s %s] %s\n", buf, wrk, msg);
        fclose(fp);
    }
}

/**
* @fn void get_prg_name(char *prg_name)
* @brief 実行ファイル名取得
* @param[out] *prg_name 実行ファイル名
* @details 実行ファイル名をパス無しで取得する
*/
void get_prg_name(char *prg_name)
{
    char prg_path[256];

	memset(prg_path, 0, sizeof(prg_path));
    readlink("/proc/self/exe", prg_path, sizeof(prg_path));
    sprintf(prg_name, "%s", basename(prg_path));
}

