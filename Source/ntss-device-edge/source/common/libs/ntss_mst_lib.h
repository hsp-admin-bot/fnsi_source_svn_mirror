/**
* @briefNTSSマスタ関連ヘッダーファイル
*
* @details NTSS項目関連
*
* @description ntss program

* Copyright (C) 2018, TDC, all right reserved.
*
* @file ntss_mst_lib.h
* @author Y.Takamura
* @date 2018/04/10
*/

#ifndef NTSS_MST_LIB_H
#define NTSS_MST_LIB_H

#include <stdbool.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <libgen.h>
#include <time.h>
#include "ntss_etc_lib.h"

#define PROC_LIST_MAX	100		// 工程一覧最大数
#define DIAG_LIST_MAX	200		// 自己診断メッセージ一覧最大数
#define MONI_LIST_MAX	300		// モニタ項目一覧最大数
#define MENT_LIST_MAX	200		// メンテナンス項目一覧最大数
#define COND_LIST_MAX	600		// 条件項目一覧最大数
#define TYPE_LIST_MAX	50		// 装置型式一覧最大数

#define MST_PROC_NAME	"mstProcess.dat"			// 工程マスタファイル名
#define MST_DIAG_NAME	"mstDiagMessage.dat"		// 自己診断メッセージマスタファイル名
#define MST_MONI_NAME	"mstMonitorItem.dat"		// モニタ項目マスタファイル名
#define MST_MENT_NAME	"mstMaintenanceItem.dat"	// メンテナンス項目マスタファイル名
#define MST_COND_NAME	"mstConditionItem.dat"		// 条件項目マスタファイル名
#define MST_TYPE_NAME	"mstMachineType.dat"		// 装置型式マスタファイル名

// #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
// #define NOTICE_LIST		"notice.list"		// 緊急発報格納ファイル一覧
// #define COLLECT_LIST	"collect.list"		// データ収集格納ファイル一覧
#define NOTICE_LIST		"/tmp/notice.list"		// 緊急発報格納ファイル一覧
#define COLLECT_LIST	"/tmp/collect.list"		// データ収集格納ファイル一覧
// #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start

#define NOTICE_OUTPUT	"notice.txt"		// 緊急発報テキスト出力ファイル
#define COLLECT_OUTPUT	"collect_%s.txt"	// データ収集テキスト出力ファイル


// 工程一覧
struct proc_list {
	char	id;			// 識別
	char	ver[2];		// 装置バージョン番号
	short	no;			// 工程番号
	char	dbno[2];	// ＤＢ番号
	char	name[20];	// 工程名称
};

// 自己診断メッセージ一覧
struct diag_list {
	char	id;			// 識別
	char	ver[2];		// 装置バージョン番号
	char	code[4];	// 自己診断コード
	char	name[80];	// 自己診断メッセージ
};

// モニタ項目一覧
struct moni_list {
	char	id;			// 識別
	char	ver[2];		// 装置バージョン番号
	short	addr;		// アドレス番号
	char	type;		// データ種類
	short 	dec;		// 小数点以下桁数
	char 	add;		// 積算有無
};

// メンテナンス項目一覧
struct ment_list {
	char	id;			// 識別
	char	ver[2];		// 装置バージョン番号
	short	addr;		// アドレス番号
	char	type;		// データ種類
	short 	dec;		// 小数点以下桁数
};

// 条件項目一覧
struct cond_list {
	char	id;			// 識別
	char	ver[2];		// 装置バージョン番号
	short	addr;		// アドレス番号
	char	type;		// データ種類
	short 	dec;		// 小数点以下桁数
};

// 装置型式一覧（100NX以降）
struct type_list {
	char	cd[3];		// 型式コード
	char	name[20];	// 型式名称
};

// 工程一覧
extern struct proc_list proc_d[PROC_LIST_MAX];
extern struct proc_list *proc_p;
// 自己診断メッセージ一覧
extern struct diag_list diag_d[DIAG_LIST_MAX];
extern struct diag_list *diag_p;
// モニタ項目一覧
extern struct moni_list moni_d[MONI_LIST_MAX];
extern struct moni_list *moni_p;
// メンテナンス項目一覧
extern struct ment_list ment_d[MENT_LIST_MAX];
extern struct ment_list *ment_p;
// 条件項目一覧
extern struct cond_list cond_d[COND_LIST_MAX];
extern struct cond_list *cond_p;
// 装置型式一覧（100NX以降）
extern struct type_list type_d[TYPE_LIST_MAX];
extern struct type_list *type_p;

/**
* @brief 各種マスタからデータ取得して内部保持
*/
extern int ntss_mst_init( char *path );

/**
* @brief 工程マスタからデータ取得して内部保持
*/
extern int ntss_mst_proc_read( char *path );

/**
* @brief 工程マスタからＤＢ番号を取得
*/
extern int ntss_mst_proc_dbno( char dev, char *ver, short no, char *dbcd );

/**
* @brief 工程マスタから工程名称を取得
*/
extern int ntss_mst_proc_name( char dev, char *ver, short no, char *name );

/**
* @brief 自己診断メッセージマスタからデータ取得して内部保持
*/
extern int ntss_mst_diag_read( char *path );

/**
* @brief 自己診断メッセージマスタからメッセージを取得
*/
extern int ntss_mst_diag_name( char dev, char *ver, char *code, char *name );

/**
* @brief モニタ項目マスタからデータ取得して内部保持
*/
extern int ntss_mst_moni_read( char *path );

/**
* @brief モニタ項目一覧から対象データを取得
*/
extern int ntss_mst_moni_data( char dev, char *ver, short addr, struct moni_list *mon );

/**
* @brief モニタデータの積算有無を取得
*/
extern int ntss_mst_moni_addup( char dev, char *ver, short addr );

/**
* @brief メンテナンス項目マスタからデータ取得して内部保持
*/
extern int ntss_mst_ment_read( char *path );

/**
* @brief メンテナンス項目一覧から対象データを取得
*/
extern int ntss_mst_ment_data( char dev, char *ver, short addr, struct ment_list *mnt );

/**
* @brief 条件項目マスタからデータ取得して内部保持
*/
extern int ntss_mst_cond_read( char *path );

/**
* @brief 条件項目一覧から対象データを取得
*/
extern int ntss_mst_cond_data( char dev, char *ver, short addr, struct cond_list *cnd );

/**
* @brief 装置型式マスタからデータ取得して内部保持
*/
extern int ntss_mst_type_read( char *path );

/**
* @brief 装置型式マスタのチェック
*/
extern int ntss_mst_type_chack( char *type );

/**
* @brief 緊急発報用フォルダ内の装置状態ファイルを削除
*/
extern int ntss_mst_delete_old_alive( char *in_path[3] );

/**
* @brief 緊急発報用フォルダ内の通信電文からテキストデータ作成
*/
extern int ntss_mst_make_notice( char *in_path[3], char *out_path );

/**
* @brief データ収集用フォルダ内の通信電文からテキストデータ作成
*/
// #8730 2023.05.24 mod AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 start
//extern int ntss_mst_make_collect( char *facilitycode, int edgeno, char *in_path[3], char *out_path);
extern int ntss_mst_make_collect( char *facilitycode, int edgeno, char *in_path[3], char *out_path, bool isComSV );
// #8730 2023.05.24 mod AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 end

// add FNSI-バグ 通信サーバ(BIT) 高 start
extern char *ntss_strrstr(char * s1, char * s2);
// add FNSI-バグ 通信サーバ(BIT) 高 end

#endif
