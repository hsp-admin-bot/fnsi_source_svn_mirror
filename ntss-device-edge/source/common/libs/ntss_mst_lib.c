/**
* @briefNTSSマスタ関連
*
* @details NTSSマスタ関連
*
* @description ntss program
* Copyright (C) 2018, TDC, all right reserved.
*
* @file ntss_mst_lib.c
* @author Y.Takamura
* @date 2018/04/10
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <fcntl.h>
#include <unistd.h>

#include "ntss_mst_lib.h"
#include "../nkklib/nkklib.h"


// 工程一覧
struct proc_list proc_d[PROC_LIST_MAX];
struct proc_list *proc_p = 0;
// 自己診断メッセージ一覧
struct diag_list diag_d[DIAG_LIST_MAX];
struct diag_list *diag_p = 0;
// モニタ項目一覧
struct moni_list moni_d[MONI_LIST_MAX];
struct moni_list *moni_p = 0;
// メンテナンス項目一覧
struct ment_list ment_d[MENT_LIST_MAX];
struct ment_list *ment_p = 0;
// 条件項目一覧
struct cond_list cond_d[COND_LIST_MAX];
struct cond_list *cond_p = 0;
// 装置型式一覧（100NX以降）
struct type_list type_d[TYPE_LIST_MAX];
struct type_list *type_p;


/**
* @brief 各種マスタからデータ取得して内部保持
*
* @details 各種マスタからデータ取得を行う
*
* @description
* @param[in] *path  項目データパス
* @return int 0:全マスタ取得成功
*          bit0:工程マスタ失敗
*          bit1:自己診断メッセージマスタ失敗
*          bit2:モニタ項目マスタ失敗
*          bit3:メンテナンス項目マスタ失敗
*          bit4:条件項目マスタ失敗
*          bit5:装置型式マスタ失敗
* @attention 特になし
*/
int ntss_mst_init( char *path )
{
	int ret;
	int sta = 0;

	// 工程マスタからデータ取得
	ret = ntss_mst_proc_read( path );
	if ( ret != 0 ) {
		sta += 1;
	}
	// 自己診断メッセージマスタからデータ取得
	ret = ntss_mst_diag_read( path );
	if ( ret != 0 ) {
		sta += (1 << 1);
	}
	// モニタ項目マスタからデータ取得
	ret = ntss_mst_moni_read( path );
	if ( ret != 0 ) {
		sta += (1 << 2);
	}
	// メンテナンス項目マスタからデータ取得
	ret = ntss_mst_ment_read( path );
	if ( ret != 0 ) {
		sta += (1 << 3);
	}
	// 条件項目マスタからデータ取得
	ret = ntss_mst_cond_read( path );
	if ( ret != 0 ) {
		sta += (1 << 4);
	}
	// 装置型式マスタからデータ取得
	ret = ntss_mst_type_read( path );
	if ( ret != 0 ) {
		sta += (1 << 5);
	}
	return sta;
}

/**
* @brief 工程マスタからデータ取得して内部保持
*
* @details 工程マスタからデータ取得を行う
*
* @description
* @param[in] *path  項目データパス
* @return int 0:成功 -1:失敗
* @attention 特になし
*/
int ntss_mst_proc_read( char *path )
{
	FILE *fp;
	int i;
	int ret = -1;
	char wrk[5];
	char buf[40];
	char utf8[200];
	char fname[40];

	sprintf( fname, "%s/%s", path, MST_PROC_NAME );
	fp = fopen( fname, "r" );
	if ( fp != NULL ) {
		memset( proc_d, 0, sizeof(proc_d) );
		for ( i=0; i < PROC_LIST_MAX; i++ ) {
			memset( utf8, 0, sizeof(utf8) );
			if ( fgets( utf8, sizeof(utf8), fp ) == NULL ) break;
			memset( buf, 0, sizeof(buf) );
			utf8tosjis( utf8, buf );
			// 識別
			proc_d[i].id = buf[0];
			// 装置バージョン
			memcpy( proc_d[i].ver, &buf[1], 2 );
			// 工程番号
			memset( wrk, 0, sizeof(wrk) );
			memcpy( wrk, &buf[3], 3 );
			proc_d[i].no = atoi( wrk );
			// ＤＢ番号
			memcpy( proc_d[i].dbno, &buf[6], 2 ); 
			// 工程名称
			memcpy( proc_d[i].name, &buf[8], 20 ); 
		}
		fclose(fp);
		proc_p = proc_d;
		ret = 0;
    }
	return ret;
}

/**
* @brief 工程マスタからＤＢ番号を取得
*
* @details 工程マスタからＤＢ番号の取得を行う
*
* @description
* @param[in] dev    通信フォーマット
* @param[in] *ver   装置バージョン
* @param[in] no     工程番号
* @param[out] dbcd  DB登録工程コード
* @return int -1:初期化エラー 0:対象なし else:該当あり
* @attention 特になし
*/
int ntss_mst_proc_dbno( char dev, char *ver, short no, char *dbcd )
{
	int i;
	int ret = -1;
	char sjis[30];
	
	if ( proc_p == 0 ) {
		// 初期化(READ)されていない
		return ret;
	}

	for ( i=0, ret=0; i < PROC_LIST_MAX; i++ ) {
		if ( proc_d[i].id == 0 ) break;
		if ( !memcmp( ver, "00", 2) ) {
			if ( !memcmp( proc_d[i].ver, "00", 2 ) && proc_d[i].no == no ) {
				memcpy( dbcd, proc_d[i].dbno,  sizeof(proc_d[i].dbno));
				ret = 1;
				break;
			}
			else if ( memcmp( proc_d[i].ver, "00", 2 ) ) break;
		}
		else {
			if ( proc_d[i].id != dev ) continue;
			if ( memcmp( proc_d[i].ver, ver, 2 ) ) continue;
			if ( proc_d[i].no == no ) {
				memcpy( dbcd, proc_d[i].dbno,  sizeof(proc_d[i].dbno));
				ret = 1;
				break;
			}
		}
	}
	return ret;
}

/**
* @brief 工程マスタから工程名称を取得
*
* @details 工程マスタから工程名称の取得を行う
*
* @description
* @param[in] dev    通信フォーマット
* @param[in] *ver   装置バージョン
* @param[in] no     工程番号
* @param[out] name  工程名称
* @return int -1:初期化エラー 0:対象なし 1:対象あり
* @attention 特になし
*/
int ntss_mst_proc_name( char dev, char *ver, short no, char *name )
{
	int i;
	int ret = -1;
	char sjis[30];
	
	if ( proc_p == 0 ) {
		// 初期化(READ)されていない
		return ret;
	}

	for ( i=0, ret=0; i < PROC_LIST_MAX; i++ ) {
		if ( proc_d[i].id == 0 ) break;
		if ( !memcmp( ver, "00", 2) ) {
			if ( !memcmp( proc_d[i].ver, "00", 2 ) && proc_d[i].no == no ) {
				ret = 1;
				break;
			}
			else if ( memcmp( proc_d[i].ver, "00", 2 ) ) break;
		}
		else {
			if ( proc_d[i].id != dev ) continue;
			if ( memcmp( proc_d[i].ver, ver, 2 ) ) continue;
			if ( proc_d[i].no == no ) {
				ret = 1;
				break;
			}
		}
	}
	if ( ret == 1 ) {
		memset( sjis, 0, sizeof(sjis) );
		memcpy( sjis, proc_d[i].name, sizeof(proc_d[i].name) );
		sjistoutf8( sjis, name );
	}
	return ret;
}

/**
* @brief 自己診断メッセージマスタからデータ取得して内部保持
*
* @details 自己診断メッセージマスタからデータ取得を行う
*
* @description
* @param[in] *path  項目データパス
* @return int 0:成功 -1:失敗
* @attention 特になし
*/
int ntss_mst_diag_read( char *path )
{
	FILE *fp;
	int i;
	int ret = -1;
	char buf[100];
	char utf8[600];
	char fname[40];

	sprintf( fname, "%s/%s", path, MST_DIAG_NAME );
	fp = fopen( fname, "r" );
	if ( fp != NULL ) {
		memset( diag_d, 0, sizeof(diag_d) );
		for ( i=0; i < DIAG_LIST_MAX; i++ ) {
			memset( utf8, 0, sizeof(utf8) );
			if ( fgets( utf8, sizeof(utf8), fp ) == NULL ) break;
			memset( buf, 0, sizeof(buf) );
			utf8tosjis( utf8, buf );
			// 識別
			diag_d[i].id = buf[0];
			// 装置バージョン
			memcpy( diag_d[i].ver, &buf[1], 2 ); 
			// 自己診断コード
			memcpy( diag_d[i].code, &buf[3], 4 ); 
			// 自己診断メッセージ
			memcpy( diag_d[i].name, &buf[7], 80 ); 
		}
		fclose(fp);
		diag_p = diag_d;
		ret = 0;
    }
	return ret;
}

/**
* @brief 自己診断メッセージマスタからメッセージを取得
*
* @details 自己診断メッセージ工程マスタからメッセージの取得を行う
*
* @description
* @param[in] dev    通信フォーマット
* @param[in] *ver   装置バージョン
* @param[in] *code  自己診断コード
* @param[out] name  自己診断メッセージ
* @return int -1:初期化エラー 0:対象なし 1:対象あり
* @attention 特になし
*/
int ntss_mst_diag_name( char dev, char *ver, char *code, char *name )
{
	int i;
	int ret = -1;
	char sjis[100];
	
	if ( diag_p == 0 ) {
		// 初期化(READ)されていない
		return ret;
	}

	for ( i=0, ret=0; i < DIAG_LIST_MAX; i++ ) {
		if ( diag_d[i].id == 0 ) break;
		if ( !memcmp( ver, "00", 2) ) {
			if ( !memcmp( diag_d[i].ver, "00", 2 ) && !memcmp( diag_d[i].code, code, 4 ) ) {
				ret = 1;
				break;
			}
			else if ( memcmp( diag_d[i].ver, "00", 2 ) ) break;
		}
		else {
			if ( diag_d[i].id != dev ) continue;
			if ( memcmp( diag_d[i].ver, ver, 2 ) ) continue;
			if ( !memcmp( diag_d[i].code, code, 4 ) ) { 
				ret = 1;
				break;
			}
		}
	}
	if ( ret == 1 ) {
		memset( sjis, 0, sizeof(sjis) );
		memcpy( sjis, diag_d[i].name, sizeof(diag_d[i].name) );
		sjistoutf8( sjis, name );
	}
	return ret;
}

/**
* @brief モニタ項目マスタからデータ取得して内部保持
*
* @details モニタ項目マスタからデータ取得を行う
*
* @description
* @param[in] *path  項目データパス
* @return int 0:成功 -1:失敗
* @attention 特になし
*/
int ntss_mst_moni_read( char *path )
{
	FILE *fp;
	int i;
	int ret = -1;
	char wrk[5];
	char buf[256];
	char fname[40];

	sprintf( fname, "%s/%s", path, MST_MONI_NAME );
	fp = fopen( fname, "r" );
	if ( fp != NULL ) {
		memset( moni_d, 0, sizeof(moni_d) );
		for ( i=0; i < MONI_LIST_MAX; i++ ) {
			memset( buf, 0, sizeof(buf) );
			if ( fgets( buf, sizeof(buf), fp ) == NULL ) break;
			// 識別
			moni_d[i].id = buf[0];
			// 装置バージョン
			memcpy( moni_d[i].ver, &buf[1], 2 ); 
			// アドレス番号
			memset( wrk, 0, sizeof(wrk) );
			memcpy( wrk, &buf[3], 3 );
			moni_d[i].addr = atoi( wrk );
			// データ種類
			moni_d[i].type = buf[6];
			// 小数点以下桁数
			memset( wrk, 0, sizeof(wrk) );
			memcpy( wrk, &buf[7], 2 );
			moni_d[i].dec = atoi( wrk );
			// 積算有無
			moni_d[i].add = buf[25];
		}
		fclose(fp);
		moni_p = moni_d;
		ret = 0;
    }
	return ret;
}

/**
* @brief モニタ項目一覧から対象データを取得
*
* @details 対象となるモニタ項目のデータ取得を行う
*
* @description
* @param[in] dev    通信フォーマット
* @param[in] *ver   装置バージョン
* @param[in] adde   アドレス(又はID)
* @param[out] *mon  モニタ項目データ
* @return int -1:初期化エラー 0:対象なし 1:対象あり
* @attention 特になし
*/
int ntss_mst_moni_data( char dev, char *ver, short addr, struct moni_list *mon )
{
	int i;
	int ret = -1;
	
	if ( moni_p == 0 ) {
		// 初期化(READ)されていない
		return ret;
	}

	for ( i=0, ret=0; i < MONI_LIST_MAX; i++ ) {
		if ( moni_d[i].id == 0 ) break;
		if ( !memcmp( ver, "00", 2) ) {
			if ( !memcmp( moni_d[i].ver, "00", 2 ) && moni_d[i].addr == addr ) {
				ret = 1;
				break;
			}
			else if ( memcmp( moni_d[i].ver, "00", 2 ) ) break;
		}
		else {
			if ( moni_d[i].id != dev ) continue;
			if ( memcmp( moni_d[i].ver, ver, 2 ) ) continue;
			if ( moni_d[i].addr == addr ) {
				ret = 1;
				break;
			}
		}
	}
	if ( ret == 1 ) {
		memcpy( mon, &moni_d[i], sizeof(struct moni_list) );
	}
	return ret;
}

/**
* @brief モニタデータの積算有無を取得
*
* @details 対象となるモニタデータの積算有取得を行う
*
* @description
* @param[in] dev    通信フォーマット
* @param[in] *ver   装置バージョン
* @param[in] adde   アドレス(又はID)
* @param[out] addup 積算有無(0,1) 
* @return int -1:初期化エラー 0:積算無 1:積算有
* @attention 特になし
*/
int ntss_mst_moni_addup( char dev, char *ver, short addr )
{
	int i;
	int ret;
	struct moni_list mon;

	memset( &mon, 0, sizeof(mon) );	
	ret =  ntss_mst_moni_data( dev, ver, addr, &mon );
	if ( ret == 1 ) {
		ret = mon.add - 0x30;
	}
	return ret;
}

/**
* @brief メンテナンス項目マスタからデータ取得して内部保持
*
* @details メンテナンス項目マスタからデータ取得を行う
*
* @description
* @param[in] *path  項目データパス
* @return int 0:成功 -1:失敗
* @attention 特になし
*/
int ntss_mst_ment_read( char *path )
{
	FILE *fp;
	int i;
	int ret = -1;
	char wrk[5];
	char buf[256];
	char fname[40];

	sprintf( fname, "%s/%s", path, MST_MENT_NAME );
	fp = fopen( fname, "r" );
	if ( fp != NULL ) {
		memset( ment_d, 0, sizeof(ment_d) );
		for ( i=0; i < MENT_LIST_MAX; i++ ) {
			memset( buf, 0, sizeof(buf) );
			if ( fgets( buf, sizeof(buf), fp ) == NULL ) break;
			// 識別
			ment_d[i].id = buf[0];
			// 装置バージョン
			memcpy( ment_d[i].ver, &buf[1], 2 ); 
			// アドレス番号
			memset( wrk, 0, sizeof(wrk) );
			memcpy( wrk, &buf[3], 3 );
			ment_d[i].addr = atoi( wrk );
			// データ種類
			ment_d[i].type = buf[6];
			// 小数点以下桁数
			memset( wrk, 0, sizeof(wrk) );
			memcpy( wrk, &buf[7], 2 );
			ment_d[i].dec = atoi( wrk );
		}
		fclose(fp);
		ment_p = ment_d;
		ret = 0;
    }
	return ret;
}

/**
* @brief メンテナンス項目一覧から対象データを取得
*
* @details 対象となるメンテナンス項目のデータ取得を行う
*
* @description
* @param[in] dev    通信フォーマット
* @param[in] *ver   装置バージョン
* @param[in] adde   アドレス(又はID)
* @param[out] *mnt  メンテナンス項目データ
* @return int -1:初期化エラー 0:対象なし 1:対象あり
* @attention 特になし
*/
int ntss_mst_ment_data( char dev, char *ver, short addr, struct ment_list *mnt )
{
	int i;
	int ret = -1;
	
	if ( ment_p == 0 ) {
		// 初期化(READ)されていない
		return ret;
	}

	for ( i=0, ret=0; i < MENT_LIST_MAX; i++ ) {
		if ( ment_d[i].id == 0 ) break;
		if ( !memcmp( ver, "00", 2) ) {
			if ( !memcmp( ment_d[i].ver, "00", 2 ) && ment_d[i].addr == addr ) {
				ret = 1;
				break;
			}
			else if ( memcmp( ment_d[i].ver, "00", 2 ) ) break;
		}
		else {
			if ( ment_d[i].id != dev ) continue;
			if ( memcmp( ment_d[i].ver, ver, 2 ) ) continue;
			if ( ment_d[i].addr == addr ) {
				ret = 1;
				break;
			}
		}
	}
	if ( ret == 1 ) {
		memcpy( mnt, &ment_d[i], sizeof(struct ment_list) );
	}
	return ret;
}

/**
* @brief 条件項目マスタからデータ取得して内部保持
*
* @details 条件項目マスタからデータ取得を行う
*
* @description
* @param[in] *path  項目データパス
* @return int 0:成功 -1:失敗
* @attention 特になし
*/
int ntss_mst_cond_read( char *path )
{
	FILE *fp;
	int i;
	int ret = -1;
	char wrk[5];
	char buf[256];
	char fname[40];

	sprintf( fname, "%s/%s", path, MST_COND_NAME );
	fp = fopen( fname, "r" );
	if ( fp != NULL ) {
		memset( cond_d, 0, sizeof(cond_d) );
		for ( i=0; i < COND_LIST_MAX; i++ ) {
			memset( buf, 0, sizeof(buf) );
			if ( fgets( buf, sizeof(buf), fp ) == NULL ) break;
			// 識別
			cond_d[i].id = buf[0];
			// 装置バージョン
			memcpy( cond_d[i].ver, &buf[1], 2 ); 
			// アドレス番号
			memset( wrk, 0, sizeof(wrk) );
			memcpy( wrk, &buf[3], 3 );
			cond_d[i].addr = atoi( wrk );
			// データ種類
			cond_d[i].type = buf[6];
			// 小数点以下桁数
			memset( wrk, 0, sizeof(wrk) );
			memcpy( wrk, &buf[7], 2 );
			cond_d[i].dec = atoi( wrk );
		}
		fclose(fp);
		cond_p = cond_d;
		ret = 0;
    }
	return ret;
}

/**
* @brief 条件項目一覧から対象データを取得
*
* @details 対象となる条件項目のデータ取得を行う
*
* @description
* @param[in] dev    通信フォーマット
* @param[in] *ver   装置バージョン
* @param[in] adde   アドレス(又はID)
* @param[out] *cnd  条件項目データ
* @return int -1:初期化エラー 0:対象なし 1:対象あり
* @attention 特になし
*/
int ntss_mst_cond_data( char dev, char *ver, short addr, struct cond_list *cnd )
{
	int i;
	int ret = -1;
	
	if ( cond_p == 0 ) {
		// 初期化(READ)されていない
		return ret;
	}

	for ( i=0, ret=0; i < COND_LIST_MAX; i++ ) {
		if ( cond_d[i].id == 0 ) break;
		if ( !memcmp( ver, "00", 2) ) {
			if ( !memcmp( cond_d[i].ver, "00", 2 ) && cond_d[i].addr == addr ) {
				ret = 1;
				break;
			}
			else if ( memcmp( cond_d[i].ver, "00", 2 ) ) break;
		}
		else {
			if ( cond_d[i].id != dev ) continue;
			if ( memcmp( cond_d[i].ver, ver, 2 ) ) continue;
			if ( cond_d[i].addr == addr ) {
				ret = 1;
				break;
			}
		}
	}
	if ( ret == 1 ) {
		memcpy( cnd, &cond_d[i], sizeof(struct cond_list) );
	}
	return ret;
}

/**
* @brief 装置型式マスタからデータ取得して内部保持
*
* @details 装置型式マスタからデータ取得を行う
*
* @description
* @param[in] *path  項目データパス
* @return int 0:成功 -1:失敗
* @attention 特になし
*/
int ntss_mst_type_read( char *path )
{
	FILE *fp;
	int i;
	int ret = -1;
	char buf[40];
	char utf8[200];
	char fname[40];

	sprintf( fname, "%s/%s", path, MST_TYPE_NAME );
	fp = fopen( fname, "r" );
	if ( fp != NULL ) {
		memset( type_d, 0, sizeof(type_d) );
		for ( i=0; i < TYPE_LIST_MAX; i++ ) {
			memset( utf8, 0, sizeof(utf8) );
			if ( fgets( utf8, sizeof(utf8), fp ) == NULL ) break;
			memset( buf, 0, sizeof(buf) );
			utf8tosjis( utf8, buf );
			// 型式コード
			memcpy( type_d[i].cd, buf, 3 );
			// 型式名称
			memcpy( type_d[i].name, &buf[3], 20 ); 
		}
		fclose(fp);
		type_p = type_d;
		ret = 0;
    }
	return ret;
}

/**
* @brief 装置型式マスタのチェック
*
* @details 指定コードが装置型式マスタに存在するかチェックを行う
*
* @description
* @param[in] type   型式コード
* @return int -1:初期化エラー 0:対象なし 1:対象あり
* @attention 特になし
*/
int ntss_mst_type_chack( char *type )
{
	int i;
	int ret = -1;
	
	if ( type_p == 0 ) {
		// 初期化(READ)されていない
		return ret;
	}

	for ( i=0, ret=0; i < TYPE_LIST_MAX; i++ ) {
		if ( type_d[i].cd[0] == 0 ) break;
		if ( !memcmp( type, type_d[i].cd, sizeof(type_d[i].cd)) ) {
			ret = 1;
			break;
		}
	}
	return ret;
}

/**
* @brief 緊急発報用フォルダ内の装置状態ファイルを削除
*/
int ntss_mst_delete_old_alive( char *in_path[3] )
{
	int findDir = 0;
	char command[512] = {0};
	int loopCount;
    struct stat st;
	char buf[512] = {0};
	char pathes[512] = {0};

	for(loopCount = 0; loopCount < 3; loopCount++){
		// フォルダアクセス確認
		if(existFolderFile(in_path[loopCount], &st) != 1){
			continue;
		}
		sprintf( buf, "%s %s", pathes, in_path[loopCount] );
		sprintf( pathes, "%s", buf );
		findDir = 1;
	}

	if(findDir == 0){
		// フォルダアクセスなし
		return -2;
	}

	// 緊急発報ファイル削除
	sprintf( command, "find %s -maxdepth 2 -type f -name \"M_ALIVE_*.TXT\" | xargs --no-run-if-empty rm -f", pathes );
	system( command );

	return 0;
}

/**
* @brief 緊急発報用フォルダ内の通信電文からテキストデータ作成
*
* @details 緊急発報用の通信電文からテキスト形式のデータ作成を行う
*
* @description
* @param[in] *in_path   緊急発報格納パス
* @param[in] *out_path  データ出力用パス
* @return int -1:初期化エラー 0:対象なし 1:対象あり
* @attention 特になし
*/
int ntss_mst_make_notice( char *in_path[3], char *out_path )
{
	FILE *fp1, *fp2, *fp3;
	int count = 0;
	int loopCount;
	char name[100] = {0};
	char buf[512] = {0};
	char txt[200] = {0};
	char command[512] = {0};
	char pathes[512] = {0};
	char outPath[512] = {0};
    struct stat st;
	int rc = 0;
	int findDir = 0;

	if ( proc_p == 0 ) {
		// 初期化(READ)されていない
		return -1;
	}

	for(loopCount = 0; loopCount < 3; loopCount++){
		// フォルダアクセス確認
		if(existFolderFile(in_path[loopCount], &st) != 1){
			continue;
		}
		sprintf( buf, "%s %s/M_ALIVE_*.TXT", pathes, in_path[loopCount] );
		sprintf( pathes, "%s", buf );
		findDir = 1;
	}

	if(findDir == 0){
		// フォルダアクセスなし
		return -2;
	}

	// タイムスタンプ昇順で緊急発報格納ファイル一覧作成
	sprintf( command, "ls -rt %s > %s", pathes, NOTICE_LIST );
	system( command );

	sprintf( outPath, "%s/%s", out_path, NOTICE_OUTPUT );

	// 緊急発報格納ファイル一覧オープン
	fp1 = fopen( NOTICE_LIST, "r" );
	if ( fp1 != NULL ) {
		for ( ; ; ) {
			memset( name, 0, sizeof(name) );
			if ( fgets( name, sizeof(name), fp1 ) == NULL ) break;
			name[ strlen(name) - 1] = 0;

			// 緊急発報格納ファイルオープン
			fp2 = fopen( name, "r" );
			if ( fp2 == NULL ) continue;
			
			while(true){
				memset( txt, 0, sizeof(txt) );
				rc = fread( txt, 1, sizeof(txt) - 1, fp2 );
				if( rc == 0){
					break;
				}
				outputAppendFile(outPath, txt, rc);
				count++;
			}
			fclose( fp2 );
			remove( name );
		}
		fclose( fp1 );
	}
	remove( NOTICE_LIST );
	return count;
}

// add FNSI-バグ 通信サーバ(BIT) 高 start
char *ntss_strrstr(char * s1, char * s2)
{
  size_t  s1len = strlen(s1);
  size_t  s2len = strlen(s2);
  char *s;

  if (s2len > s1len)
    return NULL;
  for (s = s1 + s1len - s2len; s >= s1; --s)
    if (strncmp(s, s2, s2len) == 0)
      return s;
  return NULL;
}
// add FNSI-バグ 通信サーバ(BIT) 高 end

// #8730 2023.05.24 mod AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 start
/**
* @brief データ収集用フォルダ内の通信電文からテキストデータ作成
*
* @details データ収集用の通信電文からテキスト形式のデータ作成を行う
*
* @description
* @param[in] *facilitycode   施設コード{TAB}
* @param[in] edgeno          デバイスエッジ番号{TAB}
* @param[in] *in_path        データ収集格納パス
* @param[in] *out_path       データ出力用パス
* @param[in] isComSV       連動アプリが通信SVかどうか
* // #8730 2023.06.01 mod 変換したデータの件数ではなく、作成したアップロードファイルの件数を返すように修正 TDC米沢 start
* //@return int -1:初期化エラー 0〜:データ作成件数
* @return int -1:初期化エラー 0〜:アップロードファイル作成件数
* // #8730 2023.06.01 mod 変換したデータの件数ではなく、作成したアップロードファイルの件数を返すように修正 TDC米沢 start
* @attention 特になし
*/
//int ntss_mst_make_collect( char *facilitycode, int edgeno, char *in_path[3], char *out_path )
int ntss_mst_make_collect( char *facilitycode, int edgeno, char *in_path[3], char *out_path, bool isComSV )
// #8730 2023.05.24 mod AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 start
{
	FILE *fp1, *fp2;
	int fh;
	int i, len;
	int offset1;
	int offset2;
	int tp, sp, ep;
	int no, mode;
	int ret, count, loopCount, fileCount;
	int nclass;
	short val, dec;
	unsigned short uval;
	long num;
	unsigned long unum;
	time_t tim;
	char name[100];
	char fname[100];
	char dev, ver[5];
	char buf[100], wrk[100];
	u_char bin[500], txt[3000];
    // mod 治療記録用データと治療状況用データの登録先を振分けにする 高 start
    // char type[13][10] = { "LOG", "MONS", "MONF", "MON", "MNT1", "MNT2",
	// 					 "MNT3", "MNT4", "MNT5", "MT0", "MT1", "OPE", "DAR"};
	char type[14][10] = { "LOG", "MONS", "MONF", "MON", "MNT1", "MNT2",
						 "MNT3", "MNT4", "MNT5", "MT0", "MT1", "OPE", 
                         "DAR",  "RMN"};
    // mod 治療記録用データと治療状況用データの登録先を振分けにする 高 start
	struct moni_list mon;
	struct ment_list mnt;
	char command[512] = {0};
	char pathes[512] = {0};
    struct stat st;
	int findDir = 0;

	char nowStr[20];
	char nowStrSplit[30];
	char uniqueFname[128];
	time_t nowTim;
    struct tm *local;
    char str1[512];
    // add FNSI-バグ 通信サーバ(BIT) 高 start
    char * p1;
    char serialno[10];
    // add FNSI-バグ 通信サーバ(BIT) 高 end

	if ( moni_p == 0 || ment_p == 0 ) {
		// 初期化(READ)されていない
		return -1;
	}

	for(loopCount = 0; loopCount < 3; loopCount++){
		// フォルダアクセス確認
		if(existFolderFile(in_path[loopCount], &st) != 1){
			continue;
		}
		// sprintf( buf, "%s %s/*.bin", pathes, in_path[loopCount] );
		sprintf( buf, "%s %s", pathes, in_path[loopCount] );
		sprintf( pathes, "%s", buf );
		findDir = 1;
	}

	if(findDir == 0){
		// フォルダアクセスなし
		return -2;
	}

    /* 現在時刻を取得 */
    nowTim = time(NULL);
    local = localtime(&nowTim); /* 地方時に変換 */
	// ユニークな結果ファイル名作成
	sprintf( nowStr, "%4d%02d%02d%02d%02d%02d",
	local->tm_year + 1900, local->tm_mon + 1, local->tm_mday,
	local->tm_hour, local->tm_min, local->tm_sec);
	sprintf(uniqueFname, COLLECT_OUTPUT, nowStr);
	fileCount = 0;

	// タイムスタンプ昇順で緊急発報格納ファイル一覧作成
	sprintf( command, "find %s -maxdepth 1 -type f -name \"*.bin\" | xargs --no-run-if-empty ls -rt1 > %s", pathes, COLLECT_LIST );
	// sprintf( command, "ls -rt %s > %s", pathes, COLLECT_LIST );
	system( command );

	// データ収集格納ファイル一覧オープン
	count = 0;
	fp1 = fopen( COLLECT_LIST, "r" );
	if ( fp1 != NULL ) {
		for ( ; ; ) {

			sprintf( buf, "%s/%s", out_path, uniqueFname );
			if( existFolderFile( buf, &st ) == 1 )
			{
				// ファイルあり
				// ファイルサイズが１MB以上ならファイルを切り替える
				if( st.st_size > 1024 * 1024) {
					fileCount++;
					sprintf(nowStrSplit, "%s_%d", nowStr, fileCount);
					sprintf(uniqueFname, COLLECT_OUTPUT, nowStrSplit);
				}
			}

			memset( name, 0, sizeof(name) );
			if ( fgets( name, sizeof(name), fp1 ) == NULL ) break;
			name[ strlen(name) - 1] = 0;

			// データ収集格納ファイルオープン
			fh = open( name, O_RDONLY );
			if ( fh == -1 ) continue;
			memset( bin, 0, sizeof(bin) );
			len = read( fh, bin, sizeof(bin) );
			close( fh );
			if ( len <= 0 ) continue;

			// バイナリからテキストデータへ変換
			memset( fname, 0, sizeof(fname) );
			//strcpy( fname, name + (strlen(in_path) + 1) );
			strcpy( fname, basename(name) );
			memset( txt, 0, sizeof(txt) );
			offset1 = offset2 = 0;
            // kind=LOG/MON/MONS/MONF/MNT1/MNT2/MNT3/MNT4/MNT5/MT0/MT1{TAB}
            // mod 治療記録用データと治療状況用データの登録先を振分けにする 高 start
			// for ( i=0, mode=0; i < 13; i++ ) {
            for ( i=0, mode=0; i < 14; i++ ) {
            // mod 治療記録用データと治療状況用データの登録先を振分けにする 高 end
				if ( str_idx( fname, type[i] ) >= 0 ) {
					sprintf( txt, "kind=%s\t", type[i] );
					mode = i;
					break;
				}
			}
            // mod 治療記録用データと治療状況用データの登録先を振分けにする 高 start
			// if ( i >= 13 ) continue;
            if ( i >= 14 ) continue;
            // mod 治療記録用データと治療状況用データの登録先を振分けにする 高 end
			if ( str_idx( fname, "_R_" ) >= 0 ) {
				// RO装置は製造番号8バイト、他は7バイト
				offset1 = 1;
			}
            // facilitycode=施設コード{TAB}
			sprintf( buf, "facilitycode=%.6s\t", facilitycode );
			strcat( txt, buf );
            // edgeno=デバイスエッジ番号{TAB}
			sprintf( buf, "edgeno=%d\t", edgeno );
			strcat( txt, buf );
            // mod FNSI-バグ 通信サーバ 高 start
            ret = str_idx( fname, "_" );
			// if ( mode == 0 ) {
            if ( mode == 0 && ret >= 20) {
            // mod FNSI-バグ 通信サーバ 高 end
				// ログファイルの場合
	            // occurdate=発生日時{TAB}
				sprintf( buf, "occurdate=%.14s\t", fname );
				strcat( txt, buf );
				offset2 = 21;
			}
			else {
				// ログファイル以外の場合
	            // occurdate=発生日時{TAB}
				sprintf( buf, "occurdate=%.14s\t", fname + strlen(fname) - 24 );
				strcat( txt, buf );
			}
            // devicetype=型式コード{TAB}
			sprintf( buf, "devicetype=%.3s\t", fname + offset2 );
			strcat( txt, buf );
			// serialno=製造番号{TAB}
            // mod FNSI-バグ 通信サーバ(BIT) 高 start
			/*if ( offset1 == 0 ) {
				sprintf( buf, "serialno=%.7s\t", fname + offset2 + 4 );
			}
			else {
				sprintf( buf, "serialno=%.8s\t", fname + offset2 + 4 );				
			}*/
            memset(serialno, '\0', sizeof(serialno));
            p1 = ntss_strrstr(fname, "_0_");
            if(p1 == NULL) {
                p1 = ntss_strrstr(fname, "_1_");
                if(p1 == NULL) {
                    p1 = ntss_strrstr(fname, "_2_");
                    if(p1 == NULL) {
                        p1 = ntss_strrstr(fname, "_3_");
                    }
                }
            }
            memcpy(serialno, fname + offset2 + 4, strlen(fname + offset2 + 4) - strlen(p1));
            sprintf( buf, "serialno=%.8s\t", serialno );
			strcat( txt, buf );		
            // commformat=通信フォーマット{TAB}
			// dev = fname[14 + offset1 + offset2];
            dev = *(p1 + 3);
			sprintf( buf, "commformat=%c\t", dev );
            // mod FNSI-バグ 通信サーバ(BIT) 高 end
			strcat( txt, buf );
            // commstatus=通信ステータス{TAB}
            // version=装置バージョン(新通信：0x00固定、NX通信：0x01～),{TAB}
            // mod FNSI-バグ 通信サーバ(BIT) 高 start
			// if ( fname[12 + offset1 + offset2] == '1' ) {
            if ( *(p1 + 1) == '1' ) {
            // mod FNSI-バグ 通信サーバ(BIT) 高 end
				// 新通信
				sprintf( buf, "commstatus=%04x\t", *(short *)(bin + 10) );
				strcat( txt, buf );
				strcpy( ver, "00" );
			}
            // mod FNSI-バグ 通信サーバ(BIT) 高 start
			// else if ( fname[12 + offset1 + offset2] == '2' ) {
            else if ( *(p1 + 1) == '2' ) {
            // mod FNSI-バグ 通信サーバ(BIT) 高 end
				// NX通信
				sprintf( buf, "commstatus=%04x\t", *(short *)(bin + 26) );
				strcat( txt, buf );
				// #11118 2024.10.07 mod バージョン番号をファイル内から取得 TDC米沢 start
				// strcpy( ver, "01" );
				sprintf( ver, "%02x\0", bin[3] );
				// #11118 2024.10.07 mod バージョン番号をファイル内から取得 TDC米沢 end
			}
            // add 治療記録用データと治療状況用データの登録先を振分けにする 高 start
            // mod FNSI-バグ 通信サーバ(BIT) 高 start
            // else if ( fname[12 + offset1 + offset2] == '3' ) {
            else if ( *(p1 + 1) == '3' ) {
            // mod FNSI-バグ 通信サーバ(BIT) 高 start
				// 通信共通
				sprintf( buf, "commstatus=%04x\t", *(short *)(bin + 10) );
				strcat( txt, buf );
				strcpy( ver, "00" );
			}
            // add 治療記録用データと治療状況用データの登録先を振分けにする 高 end
			else continue;
			sprintf( buf, "version=%s\t", ver );
			strcat( txt, buf );
			// 各種データ部
			if ( mode == 0 && strcmp( ver, "00" ) == 0 ) {
				// 新通信ログデータ
	            // code=種別＋コード{TAB}
				sprintf( buf, "code=%02X%02X\t", bin[13], bin[14] );
				strcat( txt, buf );
				// 発生時刻の差し替え
				ret = str_idx( txt, "occurdate=" );
				if ( ret > 0 ) {
					memset( wrk, 0, sizeof(wrk) );
					memcpy( wrk, bin + 15, 7 );
					tim = 0;
					bcd_time( wrk, &tim );
					if ( tim != -1 ) {
						time_str( tim, buf, buf + 20, 1 );
						buf[4] = buf[7] = buf[22] = buf[25] = 0;
						sprintf( wrk, "%s%s%s%s%s%s",
							 buf, buf + 5, buf + 8, buf + 20, buf + 23, buf + 26 );
						memcpy( txt + ret + 10, wrk, 14 );
					}
				}
				// 装置記録区分
				nclass = 4;	// その他
				if( 0x80 <= bin[13] && bin[13] <= 0xbf ) {
					// 警報
					nclass = 1;
				} else if( 0x40 <= bin[13] && bin[13] <= 0x7f ) {
					// 報知
					nclass = 2;
				} else if( bin[13] == 0xf4 || bin[13] == 0xf5 ){
					// 操作
					nclass = 3;
				}
				if ( bin[13] == 0x01 && bin[14] && bin[14] != 0x03 && bin[14] <= 0x06 ) {
					// 対象測定データはモニタデータとしても保存
					ret = str_idx( txt, "kind=" );
					memcpy( txt + ret + 5, type[3], strlen(type[3]) );	// LOG -> MONS
					// データ種別
					//  2：透析中血圧(bin[14] == 0x01)
					//  3：再循環率  (bin[14] == 0x06)※
					//  4：体温      (bin[14] == 0x02)※
					//  5：透析前血圧(bin[14] == 0x04)
					//  6：透析後血圧(bin[14] == 0x05)
					short datatype = bin[14] + 1;
					if( datatype == 3 ) datatype = 4;	// 体温
					if( datatype == 7 ) datatype = 3;	// 再循環率
					sprintf( buf, "class=%d\t", datatype );
					strcat( txt, buf );
					strcat( txt, "items={" );
					if ( bin[14] == 0x02 ) {
						// 体温測定
						val = hl_chg( *(short *)(bin + 24) );
						dsp_s_form( wrk, 6, 1, val );
						str_trim( wrk );
						sprintf( buf, "\"94\":%s", wrk );
						strcat( txt, buf );
					}
					else if ( bin[14] == 0x06 ) {
						// 再循環率測定
						val = hl_chg( *(short *)(bin + 24) );
						sprintf( buf, "\"89\":%d", val );
						strcat( txt, buf );
					}
					else {
						// 血圧測定（最高、最低、平均、脈拍）
						val = hl_chg( *(short *)(bin + 24) );
						sprintf( buf, "\"90\":%d,", val );
						strcat( txt, buf );
						val = hl_chg( *(short *)(bin + 26) );
						sprintf( buf, "\"91\":%d,", val );
						strcat( txt, buf );
						val = hl_chg( *(short *)(bin + 28) );
						sprintf( buf, "\"92\":%d,", val );
						strcat( txt, buf );
						val = hl_chg( *(short *)(bin + 30) );
						sprintf( buf, "\"93\":%d", val );
						strcat( txt, buf );
					}
					strcat( txt, "}\n" );
					// テキストデータをファイル出力
					sprintf( buf, "%s/%s", out_path, uniqueFname );
					fp2 = fopen( buf, "a" );
					if ( fp2 != NULL ) {
						// #8730 2023.06.01 mod 変換したデータの件数ではなく、作成したアップロードファイルの件数を返すように修正 TDC米沢 start
						//if ( fputs( txt, fp2 ) >= 0 ) count++;
						fputs( txt, fp2 );
						// #8730 2023.06.01 mod 変換したデータの件数ではなく、作成したアップロードファイルの件数を返すように修正 TDC米沢 end
						fclose( fp2 );
					}
					// ログデータ用に変更
					ret = str_idx( txt, "kind=" );
					memcpy( txt + ret + 5, type[0], strlen(type[0]) );	// MONS -> LOG
					ret = str_idx( txt, "class=" );
					txt[ret] = 0;
				}
				sprintf( buf, "class=%d\t", nclass);
				strcat( txt, buf );
	            // items={"1":測定データ,"2":測定データ, ...  "x":測定データ}{LF}
				for ( i=24, no=0; i<len; i+=2, no++ ) {
					val = hl_chg( *(short *)(bin + i) );
					//if ( val == (short)(0x8000) ) continue;
					sprintf( buf, "data%d=%d\t", no + 1, val );
					strcat( txt, buf );
				}
				strcat( txt, "items={}\n" );
			}
			else if ( mode == 0 ) {
				// NX通信ログデータ
	            // code=種別＋コード{TAB}
				sprintf( buf, "code=%02X%02X\t", bin[32], bin[33] );
				strcat( txt, buf );
				// 発生時刻の差し替え
				ret = str_idx( txt, "occurdate=" );
				if ( ret > 0 ) {
					memset( wrk, 0, sizeof(wrk) );
					memcpy( wrk, bin + 34, 8 );
					// BCD8バイト→7バイトに加工
					wrk[6] = wrk[7];
					tim = 0;
					bcd_time( wrk, &tim );
					time_str( tim, buf, buf + 20, 1 );
					if ( tim != -1 ) {
						buf[4] = buf[7] = buf[22] = buf[25] = 0;
						sprintf( wrk, "%s%s%s%s%s%s",
							 buf, buf + 5, buf + 8, buf + 20, buf + 23, buf + 26 );
						memcpy( txt + ret + 10, wrk, 14 );
					}
				}
				// 装置記録区分
				nclass = 4;	// その他
				if( 0x80 <= bin[32] && bin[32] <= 0xbf ) {
					// 警報
					nclass = 1;
				} else if( 0x40 <= bin[32] && bin[32] <= 0x7f ) {
					// 報知
					nclass = 2;
				} else if( bin[32] == 0xf4 || bin[32] == 0xf5 ){
					// 操作
					nclass = 3;
				}
				sprintf( buf, "class=%d\t", nclass);
				strcat( txt, buf );
				if ( dev != 'R' ) {
					// RO装置以外の場合、アドレス０、２、３、４、５、６、７
					dec = hl_chg( *(short *)(bin + 48) );
					sprintf( buf, "data0=%d\t", dec );
					strcat( txt, buf );
					dec = 0;	// 出力する値は少数を含まない
					val = hl_chg( *(short *)(bin + 44) );
					sprintf( buf, "data2=%d\t", val );
					strcat( txt, buf );
					num = int_chg( *(int *)(bin + 50) );
					dsp_l_form( wrk, 8, dec, num );
					str_trim( wrk );
					sprintf( buf, "data3=%s\t", wrk );
					strcat( txt, buf );
					num = int_chg( *(int *)(bin + 56) );
					dsp_l_form( wrk, 8, dec, num );
					str_trim( wrk );
					sprintf( buf, "data4=%s\t", wrk );
					strcat( txt, buf );
					num = int_chg( *(int *)(bin + 62) );
					dsp_l_form( wrk, 8, dec, num );
					str_trim( wrk );
					sprintf( buf, "data5=%s\t", wrk );
					strcat( txt, buf );
					num = int_chg( *(int *)(bin + 68) );
					dsp_l_form( wrk, 8, dec, num );
					str_trim( wrk );
					sprintf( buf, "data6=%s\t", wrk );
					strcat( txt, buf );
					val = hl_chg( *(short *)(bin + 74) );
					sprintf( buf, "data7=%d\t", val );
					strcat( txt, buf );
				}
				strcat( txt, "items={}\n" );
			}
            // mod 治療記録用データと治療状況用データの登録先を振分けにする 高 start
			// else if ( 1 <= mode && mode <=3 && strcmp( ver, "00" ) == 0 ) {
            else if ( ((1 <= mode && mode <= 3) || mode == 13) && strcmp( ver, "00" ) == 0 ) {
            // mod 治療記録用データと治療状況用データの登録先を振分けにする 高 end
				// 新通信モニタデータ
	            // code=種別＋コード{TAB}
				strcat( txt, "code=0000\t" );
	            // データ種別[1：モニタ]
				strcat( txt, "class=1\t" );
	            // items={"1":測定データ,"2":測定データ, ...  "x":測定データ}{LF}
				strcat( txt, "items={" );
				for ( i=12, no=0; i<len; i+=2, no++ ) {
					memset( &mon, 0, sizeof(mon) );
					ret = ntss_mst_moni_data( dev, ver, no, &mon );
					if ( ret == 1 ) {
						val = hl_chg( *(short *)(bin + i) );
						if( mon.type == '5') {
							// HEX shortを取得して4桁HEXに変換
							sprintf( wrk, "\"%04X\"", val );
						}else{
							// 数値
							if ( val == (short)(0x8000) ) {
								continue;
							}
                            // mod FNSI-バグ 通信サーバ 高 start
							// else if ( (no == 38 || no == 79 || no == 88) && val < 0 ) {
                            else if ( (no == 3 || no == 38 || no == 79 || no == 88) && val < 0 ) {
                            // mod FNSI-バグ 通信サーバ 高 end
								// 0未満の場合は無効（残り（除水）, Kt/V測定値, URR, PRR）
								continue;
							}
							dsp_s_form( wrk, 6, mon.dec, val );
						}
						str_trim( wrk );
						// mod FNSI-バグ 通信サーバ 高 start
    					// if ( no > 0 ) strcat( txt, "," );
                        if ( txt[strlen(txt)-1] != '{' ) strcat( txt, "," );
                        // mod FNSI-バグ 通信サーバ 高 end
						sprintf( buf, "\"%d\":%s", no, wrk );
						strcat( txt, buf );
					}
				}
				strcat( txt, "}\n" );
			}
            // mod 治療記録用データと治療状況用データの登録先を振分けにする 高 start
			// else if ( 1 <= mode && mode <= 3 ) {
            else if ( (1 <= mode && mode <= 3) || mode == 13 ) {
            // mod 治療記録用データと治療状況用データの登録先を振分けにする 高 end
	            // データ種別[1：モニタ]
				strcat( txt, "class=1\t" );
				// NX通信モニタデータ
				strcat( txt, "items={" );
				ep = hl_chg( *(short *)(bin + 24) );
				for ( i = 0; i < ep; i++ ) {
					memset( &mon, 0, sizeof(mon) );
					sp = (i * 4) + 28;
					if ( sp >= len ) {
						break;
					}
					no = hl_chg( *(short *)(bin + sp) );
					ret = ntss_mst_moni_data( dev, ver, no, &mon );
					if ( ret != 1 ) {
						continue;
					}
					val = hl_chg( *(short *)(bin + sp + 2) );
					if( mon.type == '5') {
						// HEX shortを取得して4桁HEXに変換
						sprintf( wrk, "\"%04X\"", val );
					}else{
						// 数値
                        // add FNSI-バグ 通信サーバ 高 start
                        if ( val == (short)(0x8000) ) {
                            continue;
                        }
                        // add FNSI-バグ 通信サーバ 高 end
						dsp_s_form( wrk, 6, mon.dec, val );
					}
					str_trim( wrk );
					// mod FNSI-バグ 通信サーバ 高 start
					// if ( i > 0 ) strcat( txt, "," );
                    if ( txt[strlen(txt)-1] != '{' ) strcat( txt, "," );
                    // mod FNSI-バグ 通信サーバ 高 end
					sprintf( buf, "\"%d\":%s", no, wrk );
					strcat( txt, buf );
				}
				strcat( txt, "}\n" );
			}
			else if ( 4 <= mode && mode <= 8 ) {
				// 新通信メンテナンスデータ
	            // items={"1":測定データ,"2":測定データ, ...  "x":測定データ}{LF}
				strcat( txt, "items={" );
				if ( mode == 4 ) {
					// ＵＦＲＣ
					tp = sp = 40; ep = 49;
				}
				else if ( mode == 5 ) {
					// 漏血テスト
					tp = sp = 50; ep = 54;
				}
				else if ( mode == 6 ) {
					// 透析液流量
					tp = sp = 55; ep = 58;
				}
				else if ( mode == 7 ) {
					// 濃度
					tp = sp = 60; ep = 65;
				}
				else if ( mode == 8 ) {
					// 動作時間
					tp = sp = 0; ep = 39;
				}
				if ( tp > 0 ) {
					// 発生時刻の差し替え
					ret = str_idx( txt, "occurdate=" );
					if ( ret > 0 ) {
						tp *= 2;
						tp += 12;
						memset( wrk, 0, sizeof(wrk) );
						memcpy( wrk, bin + tp, 6 );
						tim = 0;
						bcd_time( wrk, &tim );
						if ( tim != -1 ) {
							time_str( tim, buf, buf + 20, 0 );
							buf[4] = buf[7] = buf[22] = 0;
							sprintf( wrk, "%s%s%s%s%s00",
								buf, buf + 5, buf + 8, buf + 20, buf + 23 );
							memcpy( txt + ret + 10, wrk, 14 );
						}
					}
				}
				for ( i=12 + sp*2, no=sp; i<len && no<=ep; i+=2, no++ ) {
					memset( &mnt, 0, sizeof(mnt) );
					ret = ntss_mst_ment_data( dev, ver, no, &mnt );
					if ( ret == 1 ) {
						val = hl_chg( *(short *)(bin + i) );
						if ( mnt.type == '5') {
							// HEX shortを取得して4桁HEXに変換
							sprintf( wrk, "\"%04X\"", val );
						}
						else{
							if ( mode == 8 ) {
								// 動作時間
								uval = (unsigned short)hl_chg( *(short *)(bin + i) );
								dsp_l_form( wrk, 6, mnt.dec, (long)uval );
							}
							else {
								if ( val == (short)(0x8000) ) {
									continue;
								}
								dsp_s_form( wrk, 6, mnt.dec, val );
							}
						}
						str_trim( wrk );
						if ( txt[strlen(txt)-1] != '{' ) strcat( txt, "," );
						sprintf( buf, "\"%d\":%s", no, wrk );
						strcat( txt, buf );
					}
				}
				strcat( txt, "}\n" );
			}
			else if ( 9 <= mode && mode <= 12 ) {
				// NX通信メンテナンスデータ
	            // items={"1":測定データ,"2":測定データ, ...  "x":測定データ}{LF}
				strcat( txt, "items={" );
				tp = 28;
				if ( mode != 11 ) {
					// 発生時刻の差し替え
					ret = str_idx( txt, "occurdate=" );
					if ( ret > 0 ) {
						memset( wrk, 0, sizeof(wrk) );
						if ( mode == 9 ) {
							// 配管テスト
							wrk[0] = bin[tp+6]; wrk[1] = bin[tp+7];
							wrk[2] = bin[tp+10]; wrk[3] = bin[tp+11];
							wrk[4] = bin[tp+14]; wrk[5] = bin[tp+15];
						}
						else if ( mode == 10 ) {
							// 希釈テスト
							wrk[0] = bin[tp+2]; wrk[1] = bin[tp+3];
							wrk[2] = bin[tp+6]; wrk[3] = bin[tp+7];
							wrk[4] = bin[tp+10]; wrk[5] = bin[tp+11];
						}
						else if ( mode == 12 ) {
							// 溶解記録
							wrk[0] = bin[tp+2]; wrk[1] = bin[tp+3];
							wrk[2] = bin[tp+6]; wrk[3] = bin[tp+7];
							wrk[4] = bin[tp+14]; wrk[5] = bin[tp+15];
							// 西暦下2桁のみの対応
							if( wrk[0] == 0x00 ) wrk[0] = 0x20;
						}
						tim = 0;
						bcd_time( wrk, &tim );
						if ( tim != -1 ) {
							time_str( tim, buf, buf + 20, 0 );
							buf[4] = buf[7] = buf[22] = 0;
							sprintf( wrk, "%s%s%s%s%s00",
								buf, buf + 5, buf + 8, buf + 20, buf + 23 );
							memcpy( txt + ret + 10, wrk, 14 );
						}
					}
				}
				ep = hl_chg( *(short *)(bin + tp - 4) );
				for ( i = 0; i < ep; i++ ) {
					memset( &mnt, 0, sizeof(mnt) );
					if ( dev != 'A' && mode == 11 ) {
						sp = (i * 6) + tp;
					}
					else {
						sp = (i * 4) + tp;
					}
					if ( sp >= len ) break;
					no = offset2 = hl_chg( *(short *)(bin + sp) );
					if ( mode == 9 ) {
						// 配管テスト
						offset2 += 800;
					}
					else if ( mode == 10 ) {
						// 希釈テスト
						offset2 += 900;
					}
					else if ( mode == 12) {
						// 溶解記録
						offset2 += 700;
					}
					ret = ntss_mst_ment_data( dev, ver, offset2, &mnt );
					if ( ret != 1 ) continue;
					if( mnt.type == '5'){
						// HEX shortを取得して4桁HEXに変換
						val = hl_chg( *(short *)(bin + sp + 2) );
						sprintf( wrk, "\"%04X\"", val );
					}else{
						// 数値
						if ( mode == 11 ) {
							if ( dev == 'A' ) {
								// DAB OPE
								uval = (unsigned short)hl_chg( *(short *)(bin + sp + 2) );
								dsp_l_form( wrk, 5, mnt.dec, (long)uval );
							}
							else {
								// DAD OPE
								unum = (unsigned int)int_chg( *(int *)(bin + sp + 2) );
								dsp_ul_form( wrk, 8, mnt.dec, unum );
							}
						}
						else {
							val = hl_chg( *(short *)(bin + sp + 2) );
							if ( dev == 'D' && mode == 12 && no == 8 ) {
								// Ｂ原液濃度（1桁切り捨て、少数１桁表示）
								// 1234 -> 123 -> 12.3
								val /= 10;
							}
							dsp_s_form( wrk, 6, mnt.dec, val );
						}
					}
					str_trim( wrk );
					if ( txt[strlen(txt)-1] != '{' ) {
						strcat( txt, "," );
					}
					sprintf( buf, "\"%d\":%s", no, wrk );
					strcat( txt, buf );
				}
				strcat( txt, "}\n" );
			}

			// テキストデータをファイル出力
			sprintf( buf, "%s/%s", out_path, uniqueFname );
			fp2 = fopen( buf, "a" );
			if ( fp2 != NULL ) {
				if ( fputs( txt, fp2 ) >= 0 ) {
					count++;
					// #8730 2023.05.23 mod AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 start
					//remove( name );
					// 連動アプリ判定
					if (isComSV) {
						// 通信SVが動作している場合
						// 変換したバイナリファイル名をアップロード用テキストファイルと同名のリスト(拡張子：idx)に追記する
						strcpy(buf + strlen(buf) - 3, "idx");
						outputAppendFile(buf, name, strlen(name));
						outputAppendFile(buf, "\n", 1);
					} else {
						// 通信SV以外が動作している場合
						// (AWSとの通信不可の場合にバイナリファイルを移動する必要がないため)バイナリファイルを削除
						remove( name );
					}
					// #8730 2023.05.23 mod AWSとの通信正常時の蓄積系データのアップロード処理変更 TDC米沢 end
				}
				fclose( fp2 );
			}
		}
		fclose( fp1 );
	}

	remove( COLLECT_LIST );
	return count;
}
