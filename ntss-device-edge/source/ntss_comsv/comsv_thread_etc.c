/**
* @file comsv_thread_etc.c
* @brief スレッドコール用各種関数
* @author Y.Takamura
* @date 2019/12/17
* @details スレッドコール用の各種関数
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include "ntss_comsv.h"

/**
* @fn void comsv_thread_lcd_input(void *ptr)
* @brief ＬＣＤデータ入力スレッド処理
* @param[in,out] ptr 装置制御データ
* @details 新通信装置から入力されたＬＣＤデータ入力スレッド処理
*/
void *comsv_thread_lcd_input(void *ptr)
{
	struct scn_data_fm *scn = (struct scn_data_fm *) ptr;

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

	// ＬＣＤデータ入力処理
	comsv_lcd_input(scn);

	// スレッド終了
	pthread_exit((void *)0);
}

/**
* @fn void comsv_thread_rest_npat()
* @brief 一斉次患者更新処理
* @details 一斉次患者更新スレッド処理
*/
void *comsv_thread_rest_npat()
{
	int ret;
	extern void comsv_all_nextpat();

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

	// 一斉次患者更新を要求
	ret = comsv_rest_post_reload_npat("{}");
	printf("comsv_rest_post_reload_npat = [%d]\n", ret);

	// 一斉次患者情報転送
	comsv_all_nextpat();

	// スレッド終了
	pthread_exit((void *)0);
}

/**
* @fn void comsv_thread_rest_cond(void *ptr)
* @brief 条件送信完了時の一連処理
* @param[in,out] ptr 装置制御データ
* @details 条件送信完了時の一連スレッド処理
*/
void *comsv_thread_rest_cond(void *ptr)
{
	int ret;
	int i;
    char fpath[64];
	struct scn_data_fm *scn = (struct scn_data_fm *) ptr;
	extern void comsv_report_create(struct scn_data_fm *scn);
	extern void comsv_va_create(struct scn_data_fm *scn);

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

    // add ？？？？患者発生時の次患者情報送信#1437 高 start
    if( scn->unregistered_flg == 0 ) {
    // add ？？？？患者発生時の次患者情報送信#1437 高 end
    	for ( i = 0; i < 3; i++ ) {
    		// 条件送信完了時の一連処理を要求
            ret = comsv_rest_post_send_cond(scn);
    		printf("comsv_rest_post_send_cond = [%d]\n", ret);
    		if ( ret != -1 ) break;
    	}
    }

	if ( scn->commType == NTSS_COMM_TYPE_NEW ) {
		// 新通信
		// mod ？？？？患者発生時の次患者情報送信#1437 高 start
		// if ( ret == 0 ) {
        if ( ret == 0 && scn->unregistered_flg == 0 ) {
        // mod ？？？？患者発生時の次患者情報送信#1437 高 start
			// 条件送信処理完了
			scn->cond_send_complete = 1;
		}
        // #10542 2025.12.22 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start
        /*
		// #12071 2025.11.25 mod 画像処理を行う条件に患者IDが有効な場合を追加 TDC米沢 start
		// if ( scn->devsw != 'I' && scn->devsw != 'J' ) {
		if( scn->pat_id <= 0) {
			// 処理スキップ
			LogOutputs(NTSS_LOG_INFO, "未登録患者のため画像取得処理をスキップ", 0, scn->deviceType, scn->devid);
		}
		if ( 0 < scn->pat_id && scn->devsw != 'I' && scn->devsw != 'J' ) {
		// #12071 2025.11.25 mod 画像処理を行う条件に患者IDが有効な場合を追加 TDC米沢 end
			// 100NX以前の装置は処理しない
			ret = ntss_mst_type_chack(scn->deviceType);
            // #9110 2023.08.09 mod VA・レポート画像の要求削減(送付不要な装置は処理しない) TDC高村 start
			//if ( ret > 0 ) {
			if ( ret > 0 && getMachineIsVa(scn->dev_idx) ) {
            // #9110 2023.08.09 mod VA・レポート画像の要求削減(送付不要な装置は処理しない) TDC高村 end
				// 画像転送ファイル削除
				// #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 start
				//comsv_bmp_remove(scn->dev_no);
				comsv_bmp_remove(scn->dev_no, scn->deviceType, scn->devid);
				// #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 end
				// ＶＡ画像取得処理
				comsv_va_create(scn);
				// レポート画像取得処理
				comsv_report_create(scn);
			}
		}
        */
		if( scn->pat_id <= 0) {
			// 処理スキップ
			LogOutputs(NTSS_LOG_INFO, "未登録患者のため画像取得処理をスキップ", 0, scn->deviceType, scn->devid);
		}
        else if ( checkMachineIsVa(scn) > 0 ) {
            // 画像転送可能な装置の場合
            // 画像転送ファイル削除
            comsv_bmp_remove(scn->dev_no, scn->deviceType, scn->devid);
            // ＶＡ画像取得処理
            comsv_va_create(scn);
            // レポート画像取得処理
            comsv_report_create(scn);
        }
        // #10542 2025.12.22 mod 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
	}

	// スレッド終了
	pthread_exit((void *)0);
}

/**
* @fn void comsv_thread_medicated(void *ptr)
* @brief 運転開始時の投薬処理
* @param[in,out] ptr 装置制御データ
* @details 運転開始時の投薬実施、投与タイミング通知スレッド処理
*/
void *comsv_thread_medicated(void *ptr)
{
	int ret;
	int i, j;
	int no[REQ41_MAX];
	int chk[REQ41_MAX];
    char fpath[64];
	char jdata[3200];
	struct scn_data_fm *scn = (struct scn_data_fm *) ptr;

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

	// 仮想端末（投与薬剤）読み込み
	LcddataReq41_t req41;
    comsv_work_fpath(scn->dev_no, WORK_LCD_REQ41, fpath);
	ret = comsv_json_lcd_req41(fpath, &req41);
	printf("comsv_json_lcd_req41 = [%d]\n", ret);

	memset(no, 0, sizeof(no));
	memset(chk, 0, sizeof(chk));
	for ( i = 0, j = 0; i <= req41.count; i++ ) {
		if ( req41.time[i] == 0 ) {
			// 投薬未実施
			if ( req41.medicated[i] == '1' ) {
				// 投薬実施フラグあり
				// 投薬未実施を実施済にする
                no[j] = req41.no[i];
				chk[i] = 1;
				j++;
			}
            // mod FNSI-バグ 通信サーバ 高 start
            // else if ( memcmp(req41.progress[i], "001", 3) == 0 ) {
            else if ( memcmp(req41.progress[i], "001", 3) == 0 && req41.alert[i] == '1' ) {
            // mod FNSI-バグ 通信サーバ 高 end
				// 投与タイミングが透析前＆お知らせ機能あり
				// ディレイなしで投与タイミング通知
				scn->alert_time[i] = -99;
			}
		}
	}
	if ( j ) {
		if ( configParam.lcdDataCash != 0 ) {
			// 仮想端末キャッシュを使用する
			// 仮想端末（投与薬剤）JSONファイルを更新する
			ret = comsv_json_lcd_cash_upd41(scn->dev_no, chk, get_time());
			printf("comsv_json_lcd_cash_upd41 = [%d]\n", ret);
		}
		scn->medi_effect_date = get_time();
		ret = comsv_json_ord_make_medi(jdata, no, j);
		printf("comsv_json_ord_make_medi = [%d]\n", ret);
		// 治療情報の実績投与薬剤情報を更新する
		ret = comsv_rest_post_ord_medi(scn->dev_no, scn->deviceType, scn->devid, scn->ord_no, scn->medi_effect_date, jdata);
		printf("comsv_rest_put_ord_medi = [%d]\n", ret);
        // add FNSI-バグ 通信サーバ 高 start
        // 仮想端末（投与薬剤）読み込み
        LcddataReq41_t req41;
        unsigned char ord_str[64];

        if(scn->ord_no != 0) {
            sprintf(ord_str, "%ld", scn->ord_no);
            comsv_work_fpath(scn->dev_no, WORK_LCD_REQ41, fpath);
            i = comsv_rest_get_lcd(scn->dev_no, scn->deviceType, scn->devid, 41, ord_str, fpath);
            printf("comsv_rest_get_lcd 41 = [%d]\n", i);
            i = comsv_json_lcd_req41(fpath, &req41);
            printf("comsv_json_lcd_req41 = [%d]\n", i);
            comsv_effectFlg_check(scn, &req41);
        }
        // add FNSI-バグ 通信サーバ 高 end
	}

	// スレッド終了
	pthread_exit((void *)0);
}

/**
* @fn void comsv_thread_rest_report(void *ptr)
* @brief レポート画像更新処理
* @param[in,out] ptr 装置制御データ
* @details レポート画像更新のスレッド処理
*/
void *comsv_thread_rest_report(void *ptr)
{
	struct scn_data_fm *scn = (struct scn_data_fm *) ptr;
	extern void comsv_report_create(struct scn_data_fm *scn);
    // #10518 2024.05.28 add 画面側操作→DE連動処理不正 TDC高村 start
	extern void comsv_report_event(long ord_no, struct scn_data_fm *scn);
    // #10518 2024.05.28 add 画面側操作→DE連動処理不正 TDC高村 end

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

	// レポート画像取得処理
	comsv_report_create(scn);

    // #10518 2024.05.28 add 画面側操作→DE連動処理不正 TDC高村 start
    // イベント（実績確定・削除時）装置レポート画像FTP処理
    comsv_report_event(0, scn);
    // #10518 2024.05.28 add 画面側操作→DE連動処理不正 TDC高村 end

	// スレッド終了
	pthread_exit((void *)0);
}

// add 透析患者さんのレポート画面を差入れする 高 start
/**
* @fn void comsv_thread_rest_one_report(void *ptr)
* @brief レポート差入れ指示処理
* @param[in,out] ptr 装置制御データ
* @details レポート差入れ指示のスレッド処理
*/
void *comsv_thread_rest_one_report(void *ptr)
{
	struct scn_data_fm *scn = (struct scn_data_fm *) ptr;
	extern void comsv_one_report_create(struct scn_data_fm *scn);
    // #10518 2024.05.28 add 画面側操作→DE連動処理不正 TDC高村 start
	extern void comsv_report_event(long ord_no, struct scn_data_fm *scn);
    // #10518 2024.05.28 add 画面側操作→DE連動処理不正 TDC高村 end

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

	// レポート差入れ指示処理
	comsv_one_report_create(scn);

    // #10518 2024.05.28 add 画面側操作→DE連動処理不正 TDC高村 start
    // イベント（実績版確定時）装置レポート画像FTP処理
    comsv_report_event(scn->ord_no_bmp, scn);
    // #10518 2024.05.28 add 画面側操作→DE連動処理不正 TDC高村 end

	// スレッド終了
	pthread_exit((void *)0);
}
// add 透析患者さんのレポート画面を差入れする 高 end

/**
* @fn void comsv_thread_report_today(void *ptr)
* @brief 当日レポート画像転送処理
* @param[in,out] ptr 装置制御データ
* @details 当日レポート画像転送のスレッド処理
*/
void *comsv_thread_report_today(void *ptr)
{
	struct scn_data_fm *scn = (struct scn_data_fm *) ptr;
	extern void comsv_report_today(struct scn_data_fm *scn);

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

	// 当日レポート画像取得・FTP処理
	comsv_report_today(scn);

	// スレッド終了
	pthread_exit((void *)0);
}

// #11478 2026.05.15 add 当日レポートのFTP転送処理 TDC米沢 start
/**
* @fn void comsv_thread_report_today(void *ptr)
* @brief 当日レポート画像再転送処理
* @param[in,out] ptr 装置制御データ
* @details 当日レポート画像再転送のスレッド処理
*/
void *comsv_thread_report_today_ftp(void *ptr)
{
	struct scn_data_fm *scn = (struct scn_data_fm *) ptr;
	extern void comsv_report_today_ftp(struct scn_data_fm *scn);

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

	// 当日レポート画像FTP処理
	comsv_report_today_ftp(scn);

	// スレッド終了
	pthread_exit((void *)0);
}
// #11478 2026.05.15 add 当日レポートのFTP転送処理 TDC米沢 end

/**
* @fn void comsv_thread_report_latest(void *ptr)
* @brief 直近レポート画像転送処理
* @param[in,out] ptr 装置制御データ
* @details 直近レポート画像転送のスレッド処理
*/
void *comsv_thread_report_latest(void *ptr)
{
	struct scn_data_fm *scn = (struct scn_data_fm *) ptr;
	extern void comsv_report_latest(struct scn_data_fm *scn);

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

    // #10518 2024.05.28 mod 画面側操作→DE連動処理不正 TDC高村 start
	// // 当日レポート画像取得・FTP処理
	// 直近レポート画像FTP処理
    // #10518 2024.05.28 mod 画面側操作→DE連動処理不正 TDC高村 end
	comsv_report_latest(scn);

	// スレッド終了
	pthread_exit((void *)0);
}

/**
* @fn void comsv_thread_report_sameday(void *ptr)
* @brief 同一曜日レポート画像転送処理
* @param[in,out] ptr 装置制御データ
* @details 同一曜日レポート画像転送のスレッド処理
*/
void *comsv_thread_report_sameday(void *ptr)
{
	struct scn_data_fm *scn = (struct scn_data_fm *) ptr;
	extern void comsv_report_sameday(struct scn_data_fm *scn);

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

	// 同一曜日レポート画像FTP処理
	comsv_report_sameday(scn);

	// スレッド終了
	pthread_exit((void *)0);
}

/**
 * @fn void comsv_all_nextpat()
 * @brief 一斉次患者情報転送
 */
void comsv_all_nextpat() {
	int no;

	for ( no = 0; no < DEV_MAX; no++ ) {
		if ( con_sock[no].using == true && con_sock[no].running == true ) {
			// メモリ使用中 ＆ スレッド実行中
			if ( con_sock[no].scn.commType == NTSS_COMM_TYPE_NON ) {
				// オフライン
				continue;
			}
			else if ( con_sock[no].scn.commType == NTSS_COMM_TYPE_NX ) {
				// NX通信
				continue;
			}
			else if ( con_sock[no].scn.commType == NTSS_COMM_TYPE_COMMON && con_sock[no].scn.devsw == 'W' ) {
				// 共通プロトコル通信（V3）
				continue;
			}
			else if ( con_sock[no].scn.conflg != 2  ) {
				// 通信OK以外
				continue;
			}
			// 次患者情報を要求
			con_sock[no].scn.reqflg[C_NEXTPAT] = 1;
			con_sock[no].scn.next_pat_send = 0;	// 次患者送信（0:タイミング,1:イベント）
		}
	}
}

/**
* @fn void comsv_report_create(struct scn_data_fm *sp)
* @brief レポート画像取得処理
* @param[in,out] scn 装置制御データ
* @details レボート画像情報の取得処理
*/
void comsv_report_create(struct scn_data_fm *scn) {
	int ret;
	int i;
	// #12302 2025.10.10 mod 変数初期化、バッファ拡大 TDC米沢 start
	// // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 start
    // // char fpath[64];
    // char fpath[128];
	// char fpath2[128];
	// char pdir[128];
	// // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 end
    char fpath[256];
	char fpath2[256];
	char pdir[256];
	// #12302 2025.10.10 mod 変数初期化、バッファ拡大 TDC米沢 end
    unsigned char logMessage[512] = {0};
	// #12302 2025.10.23 add 処理用バッファ追加 TDC米沢 start
	char fpath3[256];
	// #12302 2025.10.23 add 処理用バッファ追加 TDC米沢 end

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "レポート画像取得処理");
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);

	// 指定オーダ番号から直近・同一曜日で過去３回分のオーダ情報を取得
	LcddataReq56_t req56;
	comsv_work_fpath(scn->dev_no, WORK_LCD_REQ56, fpath);
	ret = comsv_rest_get_past(scn->dev_no, scn->deviceType, scn->devid, scn->ord_no, fpath);
	printf("comsv_rest_get_past = [%d]\n", ret);
	ret = comsv_json_lcd_req56(fpath, &req56);
	printf("comsv_json_lcd_req56 = [%d]\n", ret);
	// レポート画像（直近）を取得する
	for ( i = 0; i < REQ56_MAX; i++ ) {
        // mod FNSI-バグ 通信サーバ 高 start
		// if ( req56.last_no[i] == 0 || req56.last_name[0] == 0 ) continue;
        if ( req56.last_no[i] == 0 || req56.last_name[i] == 0 ) continue;
        // mod FNSI-バグ 通信サーバ 高 end
		// #12302 2025.10.23 mod 圧縮ファイルで取得 TDC米沢 start
		// ret = comsv_bmp_post(scn->dev_no, scn->deviceType, scn->devid, req56.last_no[i], 1);
		// printf("comsv_bmp_post = [%d]\n", ret);
		ret = comsv_zip_post(scn->dev_no, scn->deviceType, scn->devid, req56.last_no[i], 1);
		printf("comsv_zip_post = [%d]\n", ret);
		// #12302 2025.10.23 mod 圧縮ファイルで取得 TDC米沢 end
	}
	// レポート画像（同一曜日）を取得する
	for ( i = 0; i < REQ56_MAX; i++ ) {
        // mod FNSI-バグ 通信サーバ 高 start
		// if ( req56.week_no[i] == 0 || req56.week_name[0] == 0 ) continue;
        if ( req56.week_no[i] == 0 || req56.week_name[i] == 0 ) continue;
        // mod FNSI-バグ 通信サーバ 高 end
		// #12302 2025.10.23 mod 圧縮ファイルで取得 TDC米沢 start
		// ret = comsv_bmp_post(scn->dev_no, scn->deviceType, scn->devid, req56.week_no[i], 1);
		// printf("comsv_bmp_post = [%d]\n", ret);
		ret = comsv_zip_post(scn->dev_no, scn->deviceType, scn->devid, req56.week_no[i], 1);
		printf("comsv_zip_post = [%d]\n", ret);
		// #12302 2025.10.23 mod 圧縮ファイルで取得 TDC米沢 end
	}

	// #11629 2025.05.07 add 治療済透析レポート情報を「/tmp」を含めて複数ヶ所で管理する TDC米沢 start
	//「lcdreq56.json」→「{治療中の透析番号}_lcdreq56.json」として名称変更
	makeTreatedDialysisLcdReq56FileName(scn->ord_no, pdir);
	comsv_work_fpath(scn->dev_no, pdir, fpath2);
    // #12071 2025.11.25 mod 過去透析番号情報ファイルがない場合は名称変更しない TDC米沢 start
	// ret = moveFile(fpath, fpath2, NTSS_MOVEFILE_MODE_OVERWRITE);
	// snprintf(logMessage, sizeof(logMessage), "レポート画像取得処理, 過去透析番号情報ファイル名称変更%s, %s -> %s", (ret == 1 ? "成功" : "失敗"), fpath, fpath2);
	// 過去透析番号情報ファイルの存在判定
    if( existFolderFile( fpath, NULL) == 1 )
    {
		// 存在する

		ret = moveFile(fpath, fpath2, NTSS_MOVEFILE_MODE_OVERWRITE);
		snprintf(logMessage, sizeof(logMessage), "レポート画像取得処理, 過去透析番号情報ファイル名称変更%s, %s -> %s", (ret == 1 ? "成功" : "失敗"), fpath, fpath2);
    }
	else
	{
		// 存在しない

		ret = 0;
		snprintf(logMessage, sizeof(logMessage), "レポート画像取得処理, 過去透析番号情報ファイルが存在していないので名称変更しない, %s", fpath);
	}
    // #12071 2025.11.25 mod 過去透析番号情報ファイルがない場合は名称変更しない TDC米沢 end
	LogOutputs((ret == 1 ? NTSS_LOG_INFO : NTSS_LOG_ERROR), logMessage, 0, scn->deviceType, scn->devid);
	// #11629 2025.05.07 add治療済透析レポート情報を「/tmp」を含めて複数ヶ所で管理する TDC米沢 end

	// #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 start
	// 移動先作成
	makeTreatedDialysisReportFolder(
		scn->dev_no,
		configParam.TreatedDialysisReportDataDirectory,
		configParam.TreatedDialysisReportDataDirectory2,
		pdir
	);
	// 移動先判定
	if (pdir[0] != NULL) {
		// 移動先が取得できた場合

	    // #12071 2025.11.25 mod 過去透析番号情報ファイルがない場合はバックアップしない TDC米沢 start
		// // #11629 2025.05.07 mode 治療済透析レポート情報を「/tmp」を含めて複数ヶ所で管理する TDC米沢 start
		// // //「lcdreq56.json」→「{治療中の透析番号}_lcdreq56.json」として移動
		// // sprintf(fpath, "%s/%d_%s", pdir, scn->ord_no, WORK_LCD_REQ56);
		// // ret = moveFile(fpath, fpath2, NTSS_MOVEFILE_MODE_OVERWRITE);
		// // snprintf(logMessage, sizeof(logMessage), "レポート関連ファイル移動%s, %s -> %s", (ret == 1 ? "成功" : "失敗"), fpath, fpath2);
		// // ファイルコピー
		// sprintf(fpath, "%s/%d_%s", pdir, scn->ord_no, WORK_LCD_REQ56);
		// ret = copyFile(fpath2, fpath, NTSS_MOVEFILE_MODE_OVERWRITE);
		// snprintf(logMessage, sizeof(logMessage), "レポート画像取得処理, 過去透析番号情報ファイルコピー%s, %s -> %s", (ret == 1 ? "成功" : "失敗"), fpath2, fpath);
		// 過去透析番号情報ファイルの存在判定
		if( existFolderFile( fpath2, NULL) == 1 )
		{
			// 存在している

			// ファイルコピー
			sprintf(fpath, "%s/%d_%s", pdir, scn->ord_no, WORK_LCD_REQ56);
			ret = copyFile(fpath2, fpath, NTSS_MOVEFILE_MODE_OVERWRITE);
			snprintf(logMessage, sizeof(logMessage), "レポート画像取得処理, 過去透析番号情報ファイルコピー%s, %s -> %s", (ret == 1 ? "成功" : "失敗"), fpath2, fpath);
		}
		else
		{
			// 存在しない
			
			ret = 0;
			snprintf(logMessage, sizeof(logMessage), "レポート画像取得処理, 過去透析番号情報ファイルが存在していないのでコピーしない, %s", fpath2);
		}
		// // #11629 2025.05.07 mode 治療済透析レポート情報を「/tmp」を含めて複数ヶ所で管理する TDC米沢 end
	    // #12071 2025.11.25 mod 過去透析番号情報ファイルがない場合はバックアップしない TDC米沢 start
		LogOutputs((ret == 1 ? NTSS_LOG_INFO : NTSS_LOG_ERROR), logMessage, 0, scn->deviceType, scn->devid);

		// 今回取得した透析レポートをすべてコピー
		// 直近
		for ( i = 0; i < REQ56_MAX; i++ ) {
			if ( req56.last_no[i] == 0 || req56.last_name[i] == 0 ) continue;
			// #12302 2025.10.23 mod 圧縮ファイルをコピー TDC米沢 start
			// comsv_work_fpath(scn->dev_no, req56.last_name[i], fpath);
			sprintf(fpath3, "%ld.zip", req56.last_no[i]);
			comsv_work_fpath(scn->dev_no, fpath3, fpath);
			// #12302 2025.10.23 mod 圧縮ファイルをコピー TDC米沢 end
			// 移動元ファイル確認
			if(existFolderFile(fpath, NULL) == 1) {
				// 移動元ファイルがある場合

				// #11629 2025.05.07 mode 治療済透析レポート情報を「/tmp」を含めて複数ヶ所で管理する TDC米沢 start
				// // ファイル移動
				// sprintf(fpath2, "%s/%s", pdir, req56.last_name[i]);
				// ret = moveFile(fpath, fpath2, NTSS_MOVEFILE_MODE_OVERWRITE);
				// snprintf(logMessage, sizeof(logMessage), "直近レポートファイル移動%s, %s -> %s", (ret == 1 ? "成功" : "失敗"), fpath, fpath2);
				// ファイルコピー
				// #12302 2025.10.23 mod 圧縮ファイルをコピー TDC米沢 start
				// sprintf(fpath2, "%s/%s", pdir, req56.last_name[i]);
				sprintf(fpath2, "%s/%s", pdir, fpath3);
				// #12302 2025.10.23 mod 圧縮ファイルをコピー TDC米沢 end
				ret = copyFile(fpath, fpath2, NTSS_MOVEFILE_MODE_OVERWRITE);
				snprintf(logMessage, sizeof(logMessage), "レポート画像取得処理, 直近レポートファイルコピー%s, %s -> %s", (ret == 1 ? "成功" : "失敗"), fpath, fpath2);
				// #11629 2025.05.07 mode 治療済透析レポート情報を「/tmp」を含めて複数ヶ所で管理する TDC米沢 end
				LogOutputs((ret == 1 ? NTSS_LOG_INFO : NTSS_LOG_ERROR), logMessage, 0, scn->deviceType, scn->devid);
			} else {
				// 移動元ファイルがない場合

				snprintf(logMessage, sizeof(logMessage), "レポート画像取得処理, 直近レポートファイルなし, %s (ord_no: %d)", fpath, req56.last_no[i]);
				LogOutputs(NTSS_LOG_ERROR, logMessage, 0, scn->deviceType, scn->devid);
			}
		}
		// 同一曜日
		for ( i = 0; i < REQ56_MAX; i++ ) {
			if ( req56.week_no[i] == 0 || req56.week_name[i] == 0 ) continue;
			// #12302 2025.10.23 mod 圧縮ファイルをコピー TDC米沢 start
			// comsv_work_fpath(scn->dev_no, req56.week_name[i], fpath);
			sprintf(fpath3, "%ld.zip", req56.week_no[i]);
			comsv_work_fpath(scn->dev_no, fpath3, fpath);
			// #12302 2025.10.23 mod 圧縮ファイルをコピー TDC米沢 end
			// 移動元ファイル確認
			if(existFolderFile(fpath, NULL) == 1) {
				// 移動元ファイルがある場合

				// #11629 2025.05.07 mode 治療済透析レポート情報を「/tmp」を含めて複数ヶ所で管理する TDC米沢 start
				// // ファイル移動
				// sprintf(fpath2, "%s/%s", pdir, req56.week_name[i]);
				// ret = moveFile(fpath, fpath2, NTSS_MOVEFILE_MODE_OVERWRITE);
				// snprintf(logMessage, sizeof(logMessage), "同一曜日レポートファイル移動%s, %s -> %s", (ret == 1 ? "成功" : "失敗"), fpath, fpath2);
				// ファイルコピー
				// #12302 2025.10.23 mod 圧縮ファイルをコピー TDC米沢 start
				// sprintf(fpath2, "%s/%s", pdir, req56.week_name[i]);
				sprintf(fpath2, "%s/%s", pdir, fpath3);
				// #12302 2025.10.23 mod 圧縮ファイルをコピー TDC米沢 end
				ret = copyFile(fpath, fpath2, NTSS_MOVEFILE_MODE_OVERWRITE);
				snprintf(logMessage, sizeof(logMessage), "レポート画像取得処理, 同一曜日レポートファイルコピー%s, %s -> %s", (ret == 1 ? "成功" : "失敗"), fpath, fpath2);
				// #11629 2025.05.07 mode 治療済透析レポート情報を「/tmp」を含めて複数ヶ所で管理する TDC米沢 end
				LogOutputs((ret == 1 ? NTSS_LOG_INFO : NTSS_LOG_ERROR), logMessage, 0, scn->deviceType, scn->devid);
			} else {
				// 移動元ファイルがない場合

				snprintf(logMessage, sizeof(logMessage), "レポート画像取得処理, 同一曜日レポートファイルなし, %s (ord_no: %d)", fpath, req56.week_no[i]);
				LogOutputs(NTSS_LOG_ERROR, logMessage, 0, scn->deviceType, scn->devid);
			}
		}
	// #11629 2025.05.07 del 治療済透析レポート情報を「/tmp」を含めて複数ヶ所で管理する TDC米沢 start
	// } else {
	// 	// 移動先が取得できなかった場合

	// 	//「lcdreq56.json」→「{治療中の透析番号}_lcdreq56.json」として名称変更
	// 	sprintf(pdir, "%d_%s", scn->ord_no, WORK_LCD_REQ56);
	// 	comsv_work_fpath(scn->dev_no, pdir, fpath2);
	// 	ret = moveFile(fpath, fpath2, NTSS_MOVEFILE_MODE_OVERWRITE);
	// 	snprintf(logMessage, sizeof(logMessage), "レポート関連ファイル名称変更%s, %s -> %s", (ret == 1 ? "成功" : "失敗"), fpath, fpath2);
	// 	LogOutputs((ret == 1 ? NTSS_LOG_INFO : NTSS_LOG_ERROR), logMessage, 0, scn->deviceType, scn->devid);
	// #11629 2025.05.07 del 治療済透析レポート情報を「/tmp」を含めて複数ヶ所で管理する TDC米沢 end
	}

	// 処理終了ログを記録
    snprintf(logMessage, sizeof(logMessage), "レポート画像取得処理完了");
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);
	// #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 end
}

// add 透析患者さんのレポート画面を差入れする 高 start
/**
* @fn void comsv_one_report_create(struct scn_data_fm *sp)
* @brief レポート差入れ指示処理
* @param[in,out] scn 装置制御データ
* @details レポート差入れ指示画像情報の取得処理
*/
void comsv_one_report_create(struct scn_data_fm *scn) {
	int ret;
    unsigned char logMessage[512] = {0};
	// #12302 2025.10.10 mod 変数初期化、バッファ拡大 TDC米沢 start
	// // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 start
	// LcddataReq56_t req56;
	// int i;
	// char fpath[128] = {0};
	// char fpath2[128] = {0};
	// // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 end
	LcddataReq56_t req56;
	int i;
	char fpath[256] = {0};
	char fpath2[256] = {0};
	memset(&req56, 0, sizeof(req56));
	// #12302 2025.10.10 mod 変数初期化、バッファ拡大 TDC米沢 end
	// #12302 2025.10.23 add 処理用バッファ追加 TDC米沢 start
	char fpath3[256];
	// #12302 2025.10.23 add 処理用バッファ追加 TDC米沢 end

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "レポート差入れ指示処理");
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);

	// レポート差入れ指示画像を取得する
	// #12302 2025.10.23 mod 圧縮ファイルを取得 TDC米沢 start
	// ret = comsv_bmp_post(scn->dev_no, scn->deviceType, scn->devid, scn->ord_no_bmp, 1);
	// printf("comsv_bmp_post = [%d]\n", ret);
	ret = comsv_zip_post(scn->dev_no, scn->deviceType, scn->devid, scn->ord_no_bmp, 1);
	printf("comsv_zip_post = [%d]\n", ret);
	// #12302 2025.10.23 mod 圧縮ファイルを取得 TDC米沢 end

	// #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 start
	if(ret == 0) {
		// レポートが取得できた場合

		// 治療外透析番号情報ファイルを検索
		makeTreatedDialysisLcdReq56FileName(scn->ord_no, fpath2);
		ret = -1;
		searchTreatedDialysisFile(
			// #12302 2025.10.10 add ログ出力追加 TDC米沢 start
			scn->deviceType,
			scn->devid,
			// #12302 2025.10.10 add ログ出力追加 TDC米沢 end
			scn->dev_no,
			configParam.TreatedDialysisReportDataDirectory,
			configParam.TreatedDialysisReportDataDirectory2,
			fpath2,
			fpath
		);
		if (fpath[0] != NULL) {
			// 治療外の治療番号と治療開始日時(透析レポートファイル名)を取得
			ret = comsv_json_lcd_req56(fpath, &req56);
		}
		snprintf(logMessage, sizeof(logMessage), "レポート差入れ指示処理, 過去透析番号情報ファイル取得%s, %s (%s)", (ret == 0 ? "成功": "失敗"), fpath2, fpath);
		LogOutputs((ret == 0 ? NTSS_LOG_INFO : NTSS_LOG_ERROR), logMessage, 0, scn->deviceType, scn->devid);

		// 移動先作成
		// #12302 2025.10.10 mod バッファ拡大 TDC米沢 start
		//char pdir[128];
		char pdir[256];
		// #12302 2025.10.10 mod バッファ拡大 TDC米沢 end
		makeTreatedDialysisReportFolder(
			scn->dev_no,
			configParam.TreatedDialysisReportDataDirectory,
			configParam.TreatedDialysisReportDataDirectory2,
			pdir
		);
		// 移動先判定
		if (pdir[0] != NULL) {
			// 移動先が取得できた場合

			// 指定された透析番号から透析レポートファイル名を取得して透析レポートファイルを移動
			fpath[0] = NULL;
			long bmp_ord_no;
			for ( i = 0; i < REQ56_MAX; i++ ) {
				// #12302 2025.10.23 mod 指定された圧縮ファイル名をコピー TDC米沢 start
				bmp_ord_no = 0;
				// #12302 2025.10.23 mod 指定された圧縮ファイル名をコピー TDC米沢 end
				if(req56.last_no[i] == scn->ord_no_bmp) {
					// 直近
					// #12302 2025.10.23 mod 指定された圧縮ファイル名をコピー TDC米沢 start
					// comsv_work_fpath(scn->dev_no, req56.last_name[i], fpath);
					// sprintf(fpath2, "%s/%s", pdir, req56.last_name[i]);
					bmp_ord_no = req56.last_no[i];
					// #12302 2025.10.23 mod 指定された圧縮ファイル名をコピー TDC米沢 end
				} else if (req56.week_no[i] == scn->ord_no_bmp) {
					// 同一曜日
					// #12302 2025.10.23 mod 指定された圧縮ファイル名をコピー TDC米沢 start
					// comsv_work_fpath(scn->dev_no, req56.week_name[i], fpath);
					// sprintf(fpath2, "%s/%s", pdir, req56.week_name[i]);
					bmp_ord_no = req56.week_no[i];
					// #12302 2025.10.23 mod 指定された圧縮ファイル名をコピー TDC米沢 end
				}
				// #12302 2025.10.23 mod 指定された圧縮ファイル名をコピー TDC米沢 start
				// if(fpath[0] != NULL) {
				if(bmp_ord_no != 0) {
					sprintf(fpath3, "%ld.zip", bmp_ord_no);
					comsv_work_fpath(scn->dev_no, fpath3, fpath);
					sprintf(fpath2, "%s/%s", pdir, fpath3);
					// #12302 2025.10.23 mod 指定された圧縮ファイル名をコピー TDC米沢 end
					// 移動元ファイル確認
					if(existFolderFile(fpath, NULL) == 1) {
						// 移動元ファイルがある場合

						// #11629 2025.05.07 mod 治療済透析レポート情報を「/tmp」を含めて複数ヶ所で管理する TDC米沢 start
						// // ファイル移動
						// ret = moveFile(fpath, fpath2, NTSS_MOVEFILE_MODE_OVERWRITE);
						// snprintf(logMessage, sizeof(logMessage), "差し替えレポートファイル移動%s, %s -> %s", (ret == 1 ? "成功" : "失敗"), fpath, fpath2);
						// ファイルコピー
						ret = copyFile(fpath, fpath2, NTSS_MOVEFILE_MODE_OVERWRITE);
						snprintf(logMessage, sizeof(logMessage), "レポート差入れ指示処理, 差し替えレポートファイルコピー%s, %s -> %s", (ret == 1 ? "成功" : "失敗"), fpath, fpath2);
						// #11629 2025.05.07 mod 治療済透析レポート情報を「/tmp」を含めて複数ヶ所で管理する TDC米沢 end
						LogOutputs((ret == 1 ? NTSS_LOG_INFO : NTSS_LOG_ERROR), logMessage, 0, scn->deviceType, scn->devid);
					} else {
						// 移動元ファイルがない場合

						snprintf(logMessage, sizeof(logMessage), "レポート差入れ指示処理, 差し替えレポートファイルなし, %s (ord_no: %d)", fpath, scn->ord_no_bmp);
						LogOutputs(NTSS_LOG_ERROR, logMessage, 0, scn->deviceType, scn->devid);
					}
					break;
				}
			}
		}

		// 処理終了ログを記録
		snprintf(logMessage, sizeof(logMessage), "レポート差入れ指示処理完了");
		LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);
	}
	// #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 end
}
// add 透析患者さんのレポート画面を差入れする 高 end


// #11478 2026.05.15 add 当日レポートのFTP転送処理 TDC米沢 start
/**
* @fn void comsv_report_today_ftp(struct scn_data_fm *sp)
* @brief 当日レポート画像FTP処理
* @param[in,out] scn 装置制御データ
* @details 当日レポート画像のFTP処理
*/
void comsv_report_today_ftp(struct scn_data_fm *scn) {
	FILE *fp;
	int ret;
	char wrk[64];
    char fpath[64];
    char dt[20], tm[20];
    unsigned char logMessage[512] = {0};

    // 処理内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "当日レポート画像FTP処理");
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);

	// 現在日付から当日レポートファイル名を作成
	time_str(get_time(), dt, tm, 1);
	dt[4] = dt[7] = 0;
	sprintf(wrk, "report_%s%s%s_999999_01.bmp", dt + 2, dt + 5, dt + 8);
	comsv_work_fpath(scn->dev_no, wrk, fpath);

	// 当日レポートが存在するか確認
	if ((fp = fopen(fpath, "r")) != NULL) {
		// ファイルが存在する
		fclose(fp);
		// レポート画像をFTPでアップロードする
		ret = comsv_ftp_put(scn->dev_no, scn->deviceType, scn->devid, scn->ip_addr, 1, fpath);
		printf("comsv_ftp_put = [%d]\n", ret);
	} else {
		// ファイルが存在しない
		snprintf(logMessage, sizeof(logMessage), "当日レポート画像(%s) is not exist", fpath);
		LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);
	}
}
// #11478 2026.05.15 add 当日レポートのFTP転送処理 TDC米沢 end

/**
* @fn void comsv_report_today(struct scn_data_fm *sp)
* @brief 当日レポート画像取得・FTP処理
* @param[in,out] scn 装置制御データ
* @details 当日レポート画像の取得・FTP処理
*/
void comsv_report_today(struct scn_data_fm *scn) {
	// #11478 2026.05.15 del 不要な変数を削除 TDC米沢 start
	// FILE *fp;
	// #11478 2026.05.15 del 不要な変数を削除 TDC米沢 end
	int ret;
	// #11478 2026.05.15 del 不要な変数を削除 TDC米沢 start
	// char wrk[64];
    // char fpath[64];
    // char dt[20], tm[20];
	// #11478 2026.05.15 del 不要な変数を削除 TDC米沢 end
    unsigned char logMessage[512] = {0};

	// #11478 2026.05.15 mod ログ内容変更 TDC米沢 start
    // // ペイロードの内容をログ出力
    // snprintf(logMessage, sizeof(logMessage), "当日レポート画像取得・FTP処理");
    // 処理内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "当日レポート画像取得処理");
	// #11478 2026.05.15 mod ログ内容変更 TDC米沢 end
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);

	// 当日レポート
	// レポート画像を取得する
    // mod FNSI-バグ 通信サーバ 高 start
//	ret = comsv_bmp_post(scn->dev_no, scn->deviceType, scn->devid, scn->next_ord_no, 1);
    ret = comsv_bmp_post(scn->dev_no, scn->deviceType, scn->devid, scn->ord_no, 1);
    // mod FNSI-バグ 通信サーバ 高 end
	printf("comsv_bmp_post = [%d]\n", ret);
	if ( ret == 0 ) {
		// #11478 2026.05.15 mod 当日レポートのFTP転送処理を別関数にて実施 TDC米沢 start
		// // 当日レポートが存在するか確認
		// // 現在日付から対象ファイル名に変換
		// time_str(get_time(), dt, tm, 1);
		// dt[4] = dt[7] = 0;
		// sprintf(wrk, "report_%s%s%s_999999_01.bmp", dt + 2, dt + 5, dt + 8);
		// comsv_work_fpath(scn->dev_no, wrk, fpath);
		// if ( (fp = fopen(fpath, "r")) != NULL ) {
		// 	// ファイルが存在する
		// 	fclose(fp);
		// 	// レポート画像をFTPでアップロードする
		// 	ret = comsv_ftp_put(scn->dev_no, scn->deviceType, scn->devid, scn->ip_addr, 1, fpath);
		// 	printf("comsv_ftp_put = [%d]\n", ret);
		// 	// #12302 2025.10.23 add 転送したファイルを削除する TDC米沢 start
		// 	// 転送したファイルを削除する
		// 	removeFileFullPath(fpath);
		// 	// #12302 2025.10.23 add 転送したファイルを削除する TDC米沢 end
		// }
        // else {
        //     snprintf(logMessage, sizeof(logMessage), "当日レポート画像(%s) is not exist", fpath);
        //     LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);
        // }
		// 当日レポートのFTP転送処理
		comsv_report_today_ftp(scn);	
		// #11478 2026.05.15 mod 当日レポートのFTP転送処理を別関数にて実施 TDC米沢 end
	}
}

/**
* @fn void comsv_report_latest(struct scn_data_fm *sp)
* @brief 直近レポート画像FTP処理
* @param[in,out] scn 装置制御データ
* @details 直近レポート画像のFTP処理
*/
void comsv_report_latest(struct scn_data_fm *scn) {
	FILE *fp;
	int ret;
	int i;
	// #12302 2025.10.10 mod 変数初期化、バッファ拡大 TDC米沢 start
	// // #11629 2025.05.07 mod 治療済透析レポート情報の保存箇所変更 TDC米沢 start
    // // char fpath[64];
    // char fpath[128];
	// // #11629 2025.05.07 mod 治療済透析レポート情報の保存箇所変更 TDC米沢 end
	// LcddataReq56_t req56;
    char fpath[256];
	LcddataReq56_t req56;
	memset(&req56, 0, sizeof(req56));
	// #12302 2025.10.10 mod 変数初期化、バッファ拡大 TDC米沢 end
    unsigned char logMessage[512] = {0};
	// #12302 2025.10.23 add 処理用バッファ追加 TDC米沢 start
	char fpath2[256];
	// #12302 2025.10.23 add 処理用バッファ追加 TDC米沢 end

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "直近レポート画像FTP処理");
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);

	// 過去直近３回レポート
	// #11629 2025.05.07 mod 治療済透析レポート情報の保存箇所変更 TDC米沢 start
    // comsv_work_fpath(scn->dev_no, WORK_LCD_REQ56, fpath);
	// ret = comsv_json_lcd_req56(fpath, &req56);
	// printf("comsv_json_lcd_req56 = [%d]\n", ret);
	// 治療外透析番号情報ファイルを検索
	// #12302 2025.10.10 mod バッファ拡大 TDC米沢 start
	//char json[128];
	char json[256];
	// #12302 2025.10.10 mod バッファ拡大 TDC米沢 end
	makeTreatedDialysisLcdReq56FileName(scn->ord_no, json);
	ret = -1;
	searchTreatedDialysisFile(
		// #12302 2025.10.10 add ログ出力追加 TDC米沢 start
		scn->deviceType,
		scn->devid,
		// #12302 2025.10.10 add ログ出力追加 TDC米沢 end
		scn->dev_no,
		configParam.TreatedDialysisReportDataDirectory,
		configParam.TreatedDialysisReportDataDirectory2,
		json,
		fpath
	);
	if (fpath[0] != NULL) {
		// 治療外の治療番号と治療開始日時(透析レポートファイル名)を取得
		ret = comsv_json_lcd_req56(fpath, &req56);
	}
	snprintf(logMessage, sizeof(logMessage), "直近レポート画像FTP処理, 過去透析番号情報ファイル取得%s, %s (%s)", (ret == 0 ? "成功": "失敗"), json, fpath);
	LogOutputs((ret == 0 ? NTSS_LOG_INFO : NTSS_LOG_ERROR), logMessage, 0, scn->deviceType, scn->devid);
	// #11629 2025.05.07 mod 治療済透析レポート情報の保存箇所変更 TDC米沢 end
	for ( i = 0; i < REQ56_MAX; i++ ) {
        // mod FNSI-バグ 通信サーバ 高 start
		// if ( req56.last_no[i] == 0 || req56.last_name[0] == 0 ) continue;
        snprintf(logMessage, sizeof(logMessage), "直近レポート画像FTP処理, req56.last_no[%d] = %ld, eq56.last_name[%d] = %s", i, req56.last_no[i], i, req56.last_name[i]);
        LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);
        if ( req56.last_no[i] == 0 || req56.last_name[i] == 0 ) continue;

		// #11629 2025.05.07 mod 治療済透析レポート情報の保存箇所変更 TDC米沢 start
		// comsv_work_fpath(scn->dev_no, req56.last_name[i], fpath);

		// #12302 2025.10.23 mod 圧縮ファイルにて検索を行う TDC米沢 start
		// // 転送対象の透析レポートを検索
		// searchTreatedDialysisFile(
		// 	// #12302 2025.10.10 add ログ出力追加 TDC米沢 start
		// 	scn->deviceType,
		// 	scn->devid,
		// 	// #12302 2025.10.10 add ログ出力追加 TDC米沢 end
		// 	scn->dev_no,
		// 	configParam.TreatedDialysisReportDataDirectory,
		// 	configParam.TreatedDialysisReportDataDirectory2,
		// 	req56.last_name[i],
		// 	fpath
		// );
		// snprintf(logMessage, sizeof(logMessage), "直近レポート画像FTP処理, 透析レポート取得%s, %s (%s)", (fpath[0] != 0 ? "成功": "失敗"), req56.last_name[i], fpath);
		// 圧縮ファイル名作成
		sprintf(fpath2, "%ld.zip", req56.last_no[i]);
		// 転送対象の透析レポートを検索
		searchTreatedDialysisFile(
			// #12302 2025.10.10 add ログ出力追加 TDC米沢 start
			scn->deviceType,
			scn->devid,
			// #12302 2025.10.10 add ログ出力追加 TDC米沢 end
			scn->dev_no,
			configParam.TreatedDialysisReportDataDirectory,
			configParam.TreatedDialysisReportDataDirectory2,
			fpath2,
			fpath
		);
		snprintf(logMessage, sizeof(logMessage), "直近レポート画像FTP処理, 圧縮ファイル取得%s, %s (%s)", (fpath[0] != 0 ? "成功": "失敗"), fpath2, fpath);
		// #12302 2025.10.23 mod 圧縮ファイルにて検索を行う TDC米沢 end
		LogOutputs((fpath[0] != 0 ? NTSS_LOG_INFO : NTSS_LOG_ERROR), logMessage, 0, scn->deviceType, scn->devid);
		// #11629 2025.05.07 mod 治療済透析レポート情報の保存箇所変更 TDC米沢 end
        // mod FNSI-バグ 通信サーバ 高 end
		if ( (fp = fopen(fpath, "r")) != NULL ) {
			// ファイルが存在する
			fclose(fp);

            // del FNSI-バグ 通信サーバ 高 start
			// comsv_work_fpath(scn->dev_no, req56.last_name[i], fpath);
            // del FNSI-バグ 通信サーバ 高 end

			// #12302 2025.10.23 mod 圧縮ファイルを解凍 TDC米沢 start
			// ret = comsv_ftp_put(scn->dev_no, scn->deviceType, scn->devid, scn->ip_addr, 1, fpath);
			// printf("comsv_ftp_put = [%d]\n", ret);

			// 圧縮ファイルを解凍
			comsv_work_fpath(scn->dev_no, "", fpath2);
			ret = comsv_unzip(scn->deviceType, scn->devid, fpath, fpath2, "直近レポート画像FTP処理, ");
			printf("comsv_unzip = [%d]\n", ret);

			// 解凍後のファイル名作成
			comsv_work_fpath(scn->dev_no, req56.last_name[i], fpath);

			// 解凍後のファイル存在チェック
			if ( (fp = fopen(fpath, "r")) != NULL ) {
				// ファイルが存在する
				fclose(fp);

				// ログ出力
				snprintf(logMessage, sizeof(logMessage), "直近レポート画像FTP処理, 透析レポート取得成功, %s", fpath);
				LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);

				// レポート画像をFTPでアップロードする
				ret = comsv_ftp_put(scn->dev_no, scn->deviceType, scn->devid, scn->ip_addr, 1, fpath);
				printf("comsv_ftp_put = [%d]\n", ret);

				// 転送したファイルを削除する
				removeFileFullPath(fpath);
			} else {
				// ログ出力
				snprintf(logMessage, sizeof(logMessage), "直近レポート画像FTP処理, 透析レポート取得失敗, %s", fpath);
				LogOutputs(NTSS_LOG_ERROR, logMessage, 0, scn->deviceType, scn->devid);
			}
			// #12302 2025.10.23 mod 圧縮ファイルを解凍 TDC米沢 end
		}
		// #11629 2025.05.07 del 治療済透析レポート情報の保存箇所変更 TDC米沢 start
        // else {
        //     snprintf(logMessage, sizeof(logMessage), "直近レポート画像(%s) is not exist", fpath);
        //     LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);
        // }
		// #11629 2025.05.07 del 治療済透析レポート情報の保存箇所変更 TDC米沢 end
	}

	// #12353 2025.10.23 add 転送完了ファイルを転送 TDC米沢 start
	// FTP転送完了ファイルを転送
	comsv_ftp_endfile_put(scn->dev_no, scn->deviceType, scn->devid, scn->ip_addr);
	// #12353 2025.10.23 add 転送完了ファイルを転送 TDC米沢 end
}

/**
* @fn void comsv_report_sameday(struct scn_data_fm *sp)
* @brief 同一曜日レポート画像FTP処理
* @param[in,out] scn 装置制御データ
* @details 同一曜日レポート画像のFTP処理
*/
void comsv_report_sameday(struct scn_data_fm *scn) {
	FILE *fp;
	int ret;
	int i;
	// #12302 2025.10.10 mod 変数初期化、バッファ拡大 TDC米沢 start
	// // #11629 2025.05.07 mod 治療済透析レポート情報の保存箇所変更 TDC米沢 start
    // // char fpath[64];
    // char fpath[128];
	// // #11629 2025.05.07 mod 治療済透析レポート情報の保存箇所変更 TDC米沢 end
	// LcddataReq56_t req56;
    char fpath[256];
	LcddataReq56_t req56;
	memset(&req56, 0, sizeof(req56));
	// #12302 2025.10.10 mod 変数初期化、バッファ拡大 TDC米沢 end
    unsigned char logMessage[512] = {0};
	// #12302 2025.10.23 add 処理用バッファ追加 TDC米沢 start
	char fpath2[256];
	// #12302 2025.10.23 add 処理用バッファ追加 TDC米沢 end

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "同一曜日レポート画像FTP処理");
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);

	// 過去同曜日３回レポート
	// #11629 2025.05.07 mod 治療済透析レポート情報の保存箇所変更 TDC米沢 start
	// comsv_work_fpath(scn->dev_no, WORK_LCD_REQ56, fpath);
	// ret = comsv_json_lcd_req56(fpath, &req56);
	// printf("comsv_json_lcd_req56 = [%d]\n", ret);
	// #12302 2025.10.10 mod バッファ拡大 TDC米沢 start
	// char json[128];
	char json[256];
	// #12302 2025.10.10 mod バッファ拡大 TDC米沢 end
	makeTreatedDialysisLcdReq56FileName(scn->ord_no, json);
	ret = -1;
	searchTreatedDialysisFile(
		// #12302 2025.10.10 add ログ出力追加 TDC米沢 start
		scn->deviceType,
		scn->devid,
		// #12302 2025.10.10 add ログ出力追加 TDC米沢 end
		scn->dev_no,
		configParam.TreatedDialysisReportDataDirectory,
		configParam.TreatedDialysisReportDataDirectory2,
		json,
		fpath
	);
	if (fpath[0] != NULL) {
		// 治療外の治療番号と治療開始日時(透析レポートファイル名)を取得
		ret = comsv_json_lcd_req56(fpath, &req56);
	}
	snprintf(logMessage, sizeof(logMessage), "同一曜日レポート画像FTP処理, 過去透析番号情報ファイル取得%s, %s (%s)", (ret == 0 ? "成功": "失敗"), json, fpath);
	LogOutputs((ret == 0 ? NTSS_LOG_INFO : NTSS_LOG_ERROR), logMessage, 0, scn->deviceType, scn->devid);
	// #11629 2025.05.07 mod 治療済透析レポート情報の保存箇所変更 TDC米沢 end
	for ( i = 0; i < REQ56_MAX; i++ ) {
        // mod FNSI-バグ 通信サーバ 高 start
		// if ( req56.week_no[i] == 0 || req56.week_name[0] == 0 ) continue;
        snprintf(logMessage, sizeof(logMessage), "同一曜日レポート画像FTP処理, req56.week_no[%d] = %ld, eq56.week_name[%d] = %s", i, req56.week_no[i], i, req56.week_name[i]);
        LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);
        if ( req56.week_no[i] == 0 || req56.week_name[i] == 0 ) continue;
		// #11629 2025.05.07 mod 治療済透析レポート情報の保存箇所変更 TDC米沢 start
        // comsv_work_fpath(scn->dev_no, req56.week_name[i], fpath);

		// #12302 2025.10.23 mod 圧縮ファイルにて検索を行う TDC米沢 start
		// // 転送対象の透析レポートを検索
		// searchTreatedDialysisFile(
		// 	// #12302 2025.10.10 add ログ出力追加 TDC米沢 start
		// 	scn->deviceType,
		// 	scn->devid,
		// 	// #12302 2025.10.10 add ログ出力追加 TDC米沢 end
		// 	scn->dev_no,
		// 	configParam.TreatedDialysisReportDataDirectory,
		// 	configParam.TreatedDialysisReportDataDirectory2,
		// 	req56.week_name[i],
		// 	fpath
		// );
		// snprintf(logMessage, sizeof(logMessage), "同一曜日レポート画像FTP処理, 透析レポート取得%s, %s (%s)", (fpath[0] != 0 ? "成功": "失敗"), req56.week_name[i], fpath);
		// 圧縮ファイル名作成
		sprintf(fpath2, "%ld.zip", req56.week_no[i]);
		// 転送対象の透析レポートを検索
		searchTreatedDialysisFile(
			// #12302 2025.10.10 add ログ出力追加 TDC米沢 start
			scn->deviceType,
			scn->devid,
			// #12302 2025.10.10 add ログ出力追加 TDC米沢 end
			scn->dev_no,
			configParam.TreatedDialysisReportDataDirectory,
			configParam.TreatedDialysisReportDataDirectory2,
			fpath2,
			fpath
		);
		snprintf(logMessage, sizeof(logMessage), "同一曜日レポート画像FTP処理, 圧縮ファイル取得%s, %s (%s)", (fpath[0] != 0 ? "成功": "失敗"), fpath2, fpath);
		// #12302 2025.10.23 mod 圧縮ファイルにて検索を行う TDC米沢 end
		LogOutputs((fpath[0] != 0 ? NTSS_LOG_INFO : NTSS_LOG_ERROR), logMessage, 0, scn->deviceType, scn->devid);
		// #11629 2025.05.07 mod 治療済透析レポート情報の保存箇所変更 TDC米沢 end

        // mod FNSI-バグ 通信サーバ 高 end
		if ( (fp = fopen(fpath, "r")) != NULL ) {
			// ファイルが存在する
			fclose(fp);
	
			// レポート画像をFTPでアップロードする
            // del FNSI-バグ 通信サーバ 高 start
			// comsv_work_fpath(scn->dev_no, req56.week_name[i], fpath);
            // del FNSI-バグ 通信サーバ 高 end

			// #12302 2025.10.23 mod 圧縮ファイルを解凍 TDC米沢 start
			// ret = comsv_ftp_put(scn->dev_no, scn->deviceType, scn->devid, scn->ip_addr, 1, fpath);
			// printf("comsv_ftp_put = [%d]\n", ret);

			// 圧縮ファイルを解凍
			comsv_work_fpath(scn->dev_no, "", fpath2);
			ret = comsv_unzip(scn->deviceType, scn->devid, fpath, fpath2, "同一曜日レポート画像FTP処理, ");
			printf("comsv_unzip = [%d]\n", ret);

			// 解凍後のファイル名作成
			comsv_work_fpath(scn->dev_no, req56.week_name[i], fpath);

			// 解凍後のファイル存在チェック
			if ( (fp = fopen(fpath, "r")) != NULL ) {
				// ファイルが存在する
				fclose(fp);

				// ログ出力
				snprintf(logMessage, sizeof(logMessage), "同一曜日レポート画像FTP処理, 透析レポート取得成功, %s", fpath);
				LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);

				// レポート画像をFTPでアップロードする
				ret = comsv_ftp_put(scn->dev_no, scn->deviceType, scn->devid, scn->ip_addr, 1, fpath);
				printf("comsv_ftp_put = [%d]\n", ret);

				// 転送したファイルを削除する
				removeFileFullPath(fpath);
			} else {
				// ログ出力
				snprintf(logMessage, sizeof(logMessage), "同一曜日レポート画像FTP処理, 透析レポート取得失敗, %s", fpath);
				LogOutputs(NTSS_LOG_ERROR, logMessage, 0, scn->deviceType, scn->devid);
			}
			// #12302 2025.10.23 mod 圧縮ファイルを解凍 TDC米沢 end
		}
		// #11629 2025.05.07 del 治療済透析レポート情報の保存箇所変更 TDC米沢 start
        // else {
        //     snprintf(logMessage, sizeof(logMessage), "同一曜日レポート画像(%s) is not exist", fpath);
        //     LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);
        // }
		// #11629 2025.05.07 del 治療済透析レポート情報の保存箇所変更 TDC米沢 end
	}

	// #12353 2025.10.23 add 転送完了ファイルを転送 TDC米沢 start
	// FTP転送完了ファイルを転送
	comsv_ftp_endfile_put(scn->dev_no, scn->deviceType, scn->devid, scn->ip_addr);
	// #12353 2025.10.23 add 転送完了ファイルを転送 TDC米沢 end
}

// #10518 2024.05.28 add 画面側操作→DE連動処理不正 TDC高村 start
/**
* @fn void comsv_report_event(struct scn_data_fm *sp)
* @brief イベント（実績確定・削除時／実績版確定時）装置レポート画像FTP処理
* @param[in] ord_no オーダー番号（0:実績確定・削除時, その他:実績版確定時）
* @param[in,out] scn 装置制御データ
* @details イベント（実績確定・削除時／実績版確定時）装置レポート画像のFTP処理
*/
void comsv_report_event(long ord_no, struct scn_data_fm *scn) {
	FILE *fp;
	int ret;
	int i, j;
	// #12302 2025.10.10 mod 変数初期化、バッファ拡大 TDC米沢 start
	// // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 start
    // // char fpath[64];
    // char fpath[128];
	// char logTitle[50] = {0};
	// // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 end
	// LcddataReq56_t req56;
	// #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 start
    char fpath[256];
	char logTitle[50] = {0};
	// #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 end
	LcddataReq56_t req56;
	memset(&req56, 0, sizeof(req56));
	// #12302 2025.10.10 mod 変数初期化、バッファ拡大 TDC米沢 end
    unsigned char logMessage[512] = {0};
	// #12302 2025.10.23 add 処理用バッファ追加 TDC米沢 start
	char fpath2[256];
	// #12302 2025.10.23 add 処理用バッファ追加 TDC米沢 end

    // ペイロードの内容をログ出力
	// #11629 2025.05.07 del 治療済透析レポート情報の保存箇所変更 TDC米沢 start
	// if ( ord_no == 0 ) {
	//     snprintf(logMessage, sizeof(logMessage), "実績確定・削除時装置レポート画像FTP処理");
	// }
	// else {
	//     snprintf(logMessage, sizeof(logMessage), "装置レポート画像FTP処理");
	// }
    // LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);
	if ( ord_no == 0 ) {
	    snprintf(logTitle, sizeof(logTitle), "実績確定・削除時装置レポート画像FTP処理");
	}
	else {
	    snprintf(logTitle, sizeof(logTitle), "装置レポート画像FTP処理");
	}
    LogOutputs(NTSS_LOG_INFO, logTitle, 0, scn->deviceType, scn->devid);
	// #11629 2025.05.07 del 治療済透析レポート情報の保存箇所変更 TDC米沢 end

	// 過去直近３回＆過去同曜日３回レポート

	// #11629 2025.05.07 mod 治療済透析レポート情報の保存箇所変更 TDC米沢 start
	// comsv_work_fpath(scn->dev_no, WORK_LCD_REQ56, fpath);
	// ret = comsv_json_lcd_req56(fpath, &req56);
	// printf("comsv_json_lcd_req56 = [%d]\n", ret);
	// #12302 2025.10.10 mod バッファ拡大 TDC米沢 start
	// char json[128];
	char json[256];
	// #12302 2025.10.10 mod バッファ拡大 TDC米沢 end
	makeTreatedDialysisLcdReq56FileName(scn->ord_no, json);
	ret = -1;
	searchTreatedDialysisFile(
		// #12302 2025.10.10 add ログ出力追加 TDC米沢 start
		scn->deviceType,
		scn->devid,
		// #12302 2025.10.10 add ログ出力追加 TDC米沢 start
		scn->dev_no,
		configParam.TreatedDialysisReportDataDirectory,
		configParam.TreatedDialysisReportDataDirectory2,
		json,
		fpath
	);
	if (fpath[0] != NULL) {
		// 治療外の治療番号と治療開始日時(透析レポートファイル名)を取得
		ret = comsv_json_lcd_req56(fpath, &req56);
	}
	snprintf(logMessage, sizeof(logMessage), "%s, 透析番号情報ファイル取得%s, %s (%s)", logTitle, (ret == 0 ? "成功": "失敗"), json, fpath);
	LogOutputs((ret == 0 ? NTSS_LOG_INFO : NTSS_LOG_ERROR), logMessage, 0, scn->deviceType, scn->devid);
	// #11629 2025.05.07 mod 治療済透析レポート情報の保存箇所変更 TDC米沢 end

	// 過去直近３回レポート
	for ( i = 0, j = 0; i < REQ56_MAX; i++ ) {
        snprintf(logMessage, sizeof(logMessage), "%s(直近), req56.last_no[%d] = %ld, eq56.last_name[%d] = %s", logTitle, i, req56.last_no[i], i, req56.last_name[i]);
        LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);
        if ( req56.last_no[i] == 0 || req56.last_name[i] == 0 ) continue;
		if ( ord_no && req56.last_no[i] != ord_no ) continue;
		// #11629 2025.05.07 mod 治療済透析レポート情報の保存箇所変更 TDC米沢 start
		// comsv_work_fpath(scn->dev_no, req56.last_name[i], fpath);

		// #12302 2025.10.23 mod 圧縮ファイルにて検索を行う TDC米沢 start
		// // 転送対象の透析レポートを検索
		// searchTreatedDialysisFile(
		// 	// #12302 2025.10.10 add ログ出力追加 TDC米沢 start
		// 	scn->deviceType,
		// 	scn->devid,
		// 	// #12302 2025.10.10 add ログ出力追加 TDC米沢 end
		// 	scn->dev_no,
		// 	configParam.TreatedDialysisReportDataDirectory,
		// 	configParam.TreatedDialysisReportDataDirectory2,
		// 	req56.last_name[i],
		// 	fpath
		// );
		// snprintf(logMessage, sizeof(logMessage), "%s(直近), 透析レポート取得%s, %s (%s)", logTitle, (fpath[0] != 0 ? "成功": "失敗"), req56.last_name[i], fpath);
		// 圧縮ファイル名作成
		sprintf(fpath2, "%ld.zip", req56.last_no[i]);
		// 転送対象の透析レポートを検索
		searchTreatedDialysisFile(
			// #12302 2025.10.10 add ログ出力追加 TDC米沢 start
			scn->deviceType,
			scn->devid,
			// #12302 2025.10.10 add ログ出力追加 TDC米沢 end
			scn->dev_no,
			configParam.TreatedDialysisReportDataDirectory,
			configParam.TreatedDialysisReportDataDirectory2,
			fpath2,
			fpath
		);
		snprintf(logMessage, sizeof(logMessage), "%s(直近), 圧縮ファイル取得%s, %s (%s)", logTitle, (fpath[0] != 0 ? "成功": "失敗"), fpath2, fpath);
		// #12302 2025.10.23 mod 圧縮ファイルにて検索を行う TDC米沢 end
		LogOutputs((fpath[0] != 0 ? NTSS_LOG_INFO : NTSS_LOG_ERROR), logMessage, 0, scn->deviceType, scn->devid);
		// #11629 2025.05.07 mod 治療済透析レポート情報の保存箇所変更 TDC米沢 end

		if ( (fp = fopen(fpath, "r")) != NULL ) {
			// ファイルが存在する
			fclose(fp);

			// #12302 2025.10.23 mod 圧縮ファイルを解凍 TDC米沢 start
			// ret = comsv_ftp_put(scn->dev_no, scn->deviceType, scn->devid, scn->ip_addr, 1, fpath);
			// printf("comsv_ftp_put = [%d]\n", ret);

			// 圧縮ファイルを解凍
			comsv_work_fpath(scn->dev_no, "", fpath2);
			snprintf(logMessage, sizeof(logMessage), "%s(直近), ", logTitle);
			ret = comsv_unzip(scn->deviceType, scn->devid, fpath, fpath2, logMessage);
			printf("comsv_unzip = [%d]\n", ret);

			// 解凍後のファイル名作成
			comsv_work_fpath(scn->dev_no, req56.last_name[i], fpath);

			// 解凍後のファイル存在チェック
			if ( (fp = fopen(fpath, "r")) != NULL ) {
				// ファイルが存在する
				fclose(fp);

				// ログ出力
				snprintf(logMessage, sizeof(logMessage), "%s(直近), 透析レポート取得成功, %s", logTitle, fpath);
				LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);

				// レポート画像をFTPでアップロードする
				ret = comsv_ftp_put(scn->dev_no, scn->deviceType, scn->devid, scn->ip_addr, 1, fpath);
				printf("comsv_ftp_put = [%d]\n", ret);

				// 転送したファイルを削除する
				removeFileFullPath(fpath);
			} else {
				// ログ出力
				snprintf(logMessage, sizeof(logMessage), "%s(直近), 透析レポート取得失敗, %s", logTitle, fpath);
				LogOutputs(NTSS_LOG_ERROR, logMessage, 0, scn->deviceType, scn->devid);
			}
			// #12302 2025.10.23 mod 圧縮ファイルを解凍 TDC米沢 end			
		}
		// #11629 2025.05.07 del 治療済透析レポート情報の保存箇所変更 TDC米沢 start
        // else {
        //     snprintf(logMessage, sizeof(logMessage), "直近レポート画像(%s) is not exist", fpath);
        //     LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);
        // }
		// #11629 2025.05.07 del 治療済透析レポート情報の保存箇所変更 TDC米沢 end
		if ( ord_no && req56.last_no[i] == ord_no ) {	// 指定＆対象オーダー番号あり
			j = REQ56_MAX;
			break;
		}
	}
	// 過去同曜日３回レポート
	for ( i = j; i < REQ56_MAX; i++ ) {
        snprintf(logMessage, sizeof(logMessage), "%s(同一曜日), req56.week_no[%d] = %ld, eq56.week_name[%d] = %s", logTitle, i, req56.week_no[i], i, req56.week_name[i]);
        LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);
        if ( req56.week_no[i] == 0 || req56.week_name[i] == 0 ) continue;
		if ( ord_no && req56.week_no[i] != ord_no ) continue;

		// #11629 2025.05.07 mod 治療済透析レポート情報の保存箇所変更 TDC米沢 start
		// comsv_work_fpath(scn->dev_no, req56.last_name[i], fpath);

		// #12302 2025.10.23 mod 圧縮ファイルにて検索を行う TDC米沢 start
		// // 転送対象の透析レポートを検索
		// searchTreatedDialysisFile(
		// 	// #12302 2025.10.10 add ログ出力追加 TDC米沢 start
		// 	scn->deviceType,
		// 	scn->devid,
		// 	// #12302 2025.10.10 add ログ出力追加 TDC米沢 end
		// 	scn->dev_no,
		// 	configParam.TreatedDialysisReportDataDirectory,
		// 	configParam.TreatedDialysisReportDataDirectory2,
		// 	req56.week_name[i],
		// 	fpath
		// );
		// snprintf(logMessage, sizeof(logMessage), "%s(同一曜日), 透析レポート取得%s, %s (%s)", logTitle, (fpath[0] != 0 ? "成功": "失敗"), req56.week_name[i], fpath);
		// 圧縮ファイル名作成
		sprintf(fpath2, "%ld.zip", req56.week_no[i]);
		// 転送対象の透析レポートを検索
		searchTreatedDialysisFile(
			// #12302 2025.10.10 add ログ出力追加 TDC米沢 start
			scn->deviceType,
			scn->devid,
			// #12302 2025.10.10 add ログ出力追加 TDC米沢 end
			scn->dev_no,
			configParam.TreatedDialysisReportDataDirectory,
			configParam.TreatedDialysisReportDataDirectory2,
			fpath2,
			fpath
		);
		snprintf(logMessage, sizeof(logMessage), "%s(同一曜日), 圧縮ファイル取得%s, %s (%s)", logTitle, (fpath[0] != 0 ? "成功": "失敗"), fpath2, fpath);
		// #12302 2025.10.23 mod 圧縮ファイルにて検索を行う TDC米沢 end
		LogOutputs((fpath[0] != 0 ? NTSS_LOG_INFO : NTSS_LOG_ERROR), logMessage, 0, scn->deviceType, scn->devid);
		// #11629 2025.05.07 mod 治療済透析レポート情報の保存箇所変更 TDC米沢 end

		if ( (fp = fopen(fpath, "r")) != NULL ) {
			// ファイルが存在する
			fclose(fp);

			// #12302 2025.10.23 mod 圧縮ファイルを解凍 TDC米沢 start
			// ret = comsv_ftp_put(scn->dev_no, scn->deviceType, scn->devid, scn->ip_addr, 1, fpath);
			// printf("comsv_ftp_put = [%d]\n", ret);

			// 圧縮ファイルを解凍
			comsv_work_fpath(scn->dev_no, "", fpath2);
			snprintf(logMessage, sizeof(logMessage), "%s(同一曜日), ", logTitle);
			ret = comsv_unzip(scn->deviceType, scn->devid, fpath, fpath2, logMessage);
			printf("comsv_unzip = [%d]\n", ret);

			// 解凍後のファイル名作成
			comsv_work_fpath(scn->dev_no, req56.week_name[i], fpath);

			// 解凍後のファイル存在チェック
			if ( (fp = fopen(fpath, "r")) != NULL ) {
				// ファイルが存在する
				fclose(fp);

				// ログ出力
				snprintf(logMessage, sizeof(logMessage), "%s(同一曜日), 透析レポート取得成功, %s", logTitle, fpath);
				LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);

				// レポート画像をFTPでアップロードする
				ret = comsv_ftp_put(scn->dev_no, scn->deviceType, scn->devid, scn->ip_addr, 1, fpath);
				printf("comsv_ftp_put = [%d]\n", ret);

				// 転送したファイルを削除する
				removeFileFullPath(fpath);
			} else {
				// ログ出力
				snprintf(logMessage, sizeof(logMessage), "%s(同一曜日), 透析レポート取得失敗, %s", logTitle, fpath);
				LogOutputs(NTSS_LOG_ERROR, logMessage, 0, scn->deviceType, scn->devid);
			}
			// #12302 2025.10.23 mod 圧縮ファイルを解凍 TDC米沢 end			
		}
		// #11629 2025.05.07 del 治療済透析レポート情報の保存箇所変更 TDC米沢 start
        // else {
        //     snprintf(logMessage, sizeof(logMessage), "同一曜日レポート画像(%s) is not exist", fpath);
        //     LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);
        // }
		// #11629 2025.05.07 del 治療済透析レポート情報の保存箇所変更 TDC米沢 end
		if ( ord_no && req56.week_no[i] == ord_no ) {	// 指定＆対象オーダー番号あり
			break;
		}
	}
}
// #10518 2024.05.28 add 画面側操作→DE連動処理不正 TDC高村 end

/**
* @fn void comsv_va_create(struct scn_data_fm *sp)
* @brief ＶＡ画像取得処理
* @param[in,out] scn 装置制御データ
* @details ＶＡ画像の取得処理
*/
void comsv_va_create(struct scn_data_fm *scn) {
	FILE *fp;
	int ret;
    char fpath[64];
    unsigned char logMessage[512] = {0};

    // ペイロードの内容をログ出力
    snprintf(logMessage, sizeof(logMessage), "ＶＡ画像取得処理");
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);

	// ＶＡ画像を取得する
	ret = comsv_bmp_post(scn->dev_no, scn->deviceType, scn->devid, scn->next_ord_no, 0);
	printf("comsv_bmp_post = [%d]\n", ret);
	if ( ret == 0 ) {
		// ＶＡ画像が存在するか確認
		comsv_work_fpath(scn->dev_no, "va.bmp", fpath);
		if ( (fp = fopen(fpath, "r")) != NULL ) {
			// ファイルが存在する
			fclose(fp);
			// ＶＡ画像をFTPでアップロードする
			ret = comsv_ftp_put(scn->dev_no, scn->deviceType, scn->devid, scn->ip_addr, 0, fpath);
			printf("comsv_ftp_put = [%d]\n", ret);
			// #12302 2025.10.23 add 転送したファイルを削除する TDC米沢 start
			// 転送したファイルを削除する
			removeFileFullPath(fpath);
			// #12302 2025.10.23 add 転送したファイルを削除する TDC米沢 end
		}
        else {
            snprintf(logMessage, sizeof(logMessage), "ＶＡ画像(%s) is not exist", fpath);
            LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);
        }
	}
}

/**
* @fn void comsv_thread_rest_status()
* @brief 装置ステータス一括更新処理
* @details 装置ステータス一括更新スレッド処理
*/
void *comsv_thread_rest_status()
{
	int ret;
	char fpath[64];
	extern int comsv_all_status(char *jdata);

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

	// 装置ステータス（配列）のJSONファイル作成
	// #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 start
    // comsv_work_fpath(-1, WORK_COMSV_STATUS, fpath);
	sprintf(fpath, "%s/%s", WORK_TMP_DATA_PATH, WORK_COMSV_STATUS);
	// #8731 2023.05.17 mod 一時ファイルの保存先を/tmp/下にする TDC片口 end
	ret = comsv_all_status(fpath);
	if ( ret == 0 ) {
		// 装置状態管理の装置ステータス一括更新処理
 		ret = comsv_rest_post_all_status(fpath);
		printf("comsv_rest_post_all_status = [%d]\n", ret);
	}
	// #8731 2023.05.17 add 一時ファイルの保存先を/tmp/下にする TDC片口 start
	remove(fpath);
	// #8731 2023.05.17 add 一時ファイルの保存先を/tmp/下にする TDC片口 end

	// スレッド終了
	pthread_exit((void *)0);
}

/**
 * @fn int comsv_all_status(char *jdata)
 * @brief 装置ステータス（配列）のJSONデータ作成
 * @param[in] jfile 出力JSONファイル名
 * @return 0:成功, -1:エラー
 */
int comsv_all_status(char *jfile) {
    FILE *fp;
    int ret;
    int i, j;
	short mon_sta;
    char type[5];
    char serial[10];
    char buf[50];

    fp = fopen(jfile, "w");
    if ( fp==NULL ) return -1;

    fprintf(fp, "[");
    for ( i = 0, j = 0; i < DEV_MAX; i++ ) {
		if ( con_sock[i].using == false ) continue;
		if ( con_sock[i].running == false ) continue;
		if ( con_sock[i].scn.conflg != 2 ) continue;
        // #10889 2024.10.28 add 強制オフライン中またはオフライン装置は除外 TDC片口 start
		if ( con_sock[i].scn.force_flg != 0 ) continue;
        if ( con_sock[i].scn.commType == NTSS_COMM_TYPE_NON && con_sock[i].scn.devsw == 'F' )
        // #10889 2024.10.28 add 強制オフライン中またはオフライン装置は除外 TDC片口 end
        memset(type, 0, sizeof(type));
        memset(serial, 0, sizeof(serial));
        memcpy(type, con_sock[i].scn.deviceType, sizeof(con_sock[i].scn.deviceType));
        memcpy(serial, con_sock[i].scn.devid, sizeof(con_sock[i].scn.devid));
		mon_sta = con_sock[i].scn.mon_sta;
        sprintf(buf, "{\"type\":\"%s\",\"serial\":\"%s\",\"status\":%d}", type, serial, mon_sta);
        if ( j == 0 ) {
			j++;
		}
		else {
	        fprintf(fp, ",");
        }
        fprintf(fp, "%s", buf);
        ret = 0;
    }
    fprintf(fp, "]");
    fclose(fp);

    return ret;
}

// #10844 2024.07.29 add DB高負荷状態の時に????患者が複数生成される TDC高村 start
/**
* @fn void comsv_thread_unregistered(void *ptr)
* @brief 患者未登録運転スレッド処理
* @param[in,out] ptr 装置制御データ
* @details 患者未登録運転時のRESTコールスレッド処理
*/
void *comsv_thread_unregistered(void *ptr)
{
    int ret;
	char fpath[64];
	struct scn_data_fm *scn = (struct scn_data_fm *) ptr;

	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

    // 患者未登録運転スレッド処理

    // 治療情報を登録（患者未登録運転）
    ret = comsv_rest_put_unregistered(scn->dev_no, scn->deviceType, scn->devid, scn->thread_unregistered_sta, 3, scn->dial_start_date);
    printf("comsv_rest_put_unregistered = [%d]\n", ret);
    // 装置状態管理データを取得
    comsv_work_fpath(scn->dev_no, WORK_DEV_STATE, fpath);
    ret = comsv_rest_get_dev(scn->dev_no, scn->deviceType, scn->devid, fpath);
    printf("comsv_rest_get_dev = [%d]\n", ret);
    ret = comsv_json_dev_state(fpath, 1, scn);
    printf("comsv_json_dev_state = [%d]\n", ret);
    // ホスト報知監視開始待ち時間の初期化
    comsv_host_watch_init(scn->thread_unregistered_no);
    // ホスト報知定義の取得・設定
    ret = comsv_host_watch(scn->thread_unregistered_no, scn);
    printf("comsv_host_watch = [%d]\n", ret);

    // スレッド処理（1〜3:処理中）
    if ( scn->thread_unregistered == 1 ) {
        // comsv_stream 呼び出し
        scn->reqflg[C_KANSRD] = 1;  // 警報監視状態読出要求
        scn->kansrd_flg = 1;        // 警報監視除隊フラグ（0:装置側から任意,1:運転開始時）
        scn->reqflg[C_NEXTPAT] = 1; // 次患者情報を要求
        scn->next_pat_send = 0;     // 次患者送信（0:タイミング,1:イベント）
    }
    else if ( scn->thread_unregistered == 2 ) {
        // comsv_mon 呼び出し
        scn->reqflg[C_NEXTPAT] = 1; // 次患者情報を要求
        scn->next_pat_send = 0;     // 次患者送信（0:タイミング,1:イベント）
    }
    else {
        // comsv_mon_cp 呼び出し
    }
	scn->cond_send_flg = 1;

    // 使用後にクリアする
    scn->thread_unregistered = 0;
    scn->thread_unregistered_no = 0;
    scn->thread_unregistered_sta = 0;

	// スレッド終了
	pthread_exit((void *)0);
}
// #10844 2024.07.29 add DB高負荷状態の時に????患者が複数生成される TDC高村 end

// #11192 2025.04.02 add 治療終了指示に含まれたオーダー番号がDE側で治療中のものではないケースに対応 TDC片口 start
/**
* @fn void comsv_thread_other_ord_no_end_treat(void *ptr)
* @brief 同期異常オーダー番号の終了指示を受信した際の処理
* @param[in,out] ptr 装置制御データ
* @details 同期異常オーダー番号の終了RESTコールスレッド処理
*/
void *comsv_thread_other_ord_no_end_treat(void *ptr)
{
	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

	struct scn_data_fm *scn = (struct scn_data_fm *) ptr;
	int ret = 0;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long dial_end_time = get_time();
	time_t dial_end_time = get_time();
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end

	if (scn->ord_no == scn->received_end_treat_ord_no)
	{
		// 同じオーダー番号で状態が同期できていないケース
		// 装置状態管理の日付データを更新する
		ret = comsv_rest_put_dev_date(scn->dev_no, scn->deviceType, scn->devid, 3, scn->mon_sta, dial_end_time);
		printf("comsv_rest_put_dev_date = [%d]\n", ret);
	}
	// 治療情報の日付データを更新する
	ret = comsv_rest_put_ord_date(scn->dev_no, scn->deviceType, scn->devid, scn->received_end_treat_ord_no, 2, 0, 4, dial_end_time);
	printf("comsv_rest_put_ord_date = [%d]\n", ret);
	// 患者基本情報のステータスを更新する
	ret = comsv_rest_put_pat_related(scn->dev_no, scn->deviceType, scn->devid, scn->pat_id, 0, scn->received_end_treat_ord_no, 4);
	printf("comsv_rest_put_pat_related = [%d]\n", ret);

	// 処理終了後は対象オーダー番号の初期化
	scn->received_end_treat_ord_no = 0;
	// スレッド終了
	pthread_exit((void *)0);
}
// #11192 2025.04.02 add 治療終了指示に含まれたオーダー番号がDE側で治療中のものではないケースに対応 TDC片口 end

// #11629 2025.05.26 add 「/tmp」以外の治療済透析情報を「/tmp」に復元する TDC米沢 start
/**
* @fn void comsv_thread_restoration_treated_dialysis_report_files(void *ptr)
* @brief 「/tmp/comsv_data/{装置番号}」以外の治療済透析情報を「/tmp/comsv_data/{装置番号}」に復元する
* @param[in,out] ptr 装置制御データ
* @details 治療済透析情報を「/tmp/~」に復元するスレッド処理
*/
void *comsv_thread_restoration_treated_dialysis_report_files(void *ptr)
{
	// スレッドをデタッチ（終了後に使用されずメモリ解放）
	pthread_detach(pthread_self());

	// 引数から装置情報を取得
	struct scn_data_fm *scn = (struct scn_data_fm *) ptr;

	// 処理開始
	LogOutputs(NTSS_LOG_INFO, "過去レポート復元処理開始", 0, scn->deviceType, scn->devid);

	int ret = -1;
	int i;
	// #12302 2025.10.10 mod 変数初期化、バッファ拡大 TDC米沢 start
	// char json[128];
    // char fpath[128];
    // char fpath2[128];
    // unsigned char logMessage[512] = {0};
	// LcddataReq56_t req56;
	char json[256];
    char fpath[256];
    char fpath2[256];
    unsigned char logMessage[512] = {0};
	LcddataReq56_t req56;
	memset(&req56, 0, sizeof(req56));
	// #12302 2025.10.10 mod 変数初期化、バッファ拡大 TDC米沢 end
	const char *tmp = "/tmp/";
	// #12302 2025.10.23 add 処理用バッファ追加 TDC米沢 start
	char fpath3[256];
	// #12302 2025.10.23 add 処理用バッファ追加 TDC米沢 end

	// 治療外透析番号情報ファイルを検索
	makeTreatedDialysisLcdReq56FileName(scn->ord_no, json);
	searchTreatedDialysisFile(
		// #12302 2025.10.10 add ログ出力追加 TDC米沢 start
		scn->deviceType,
		scn->devid,
		// #12302 2025.10.10 add ログ出力追加 TDC米沢 end
		scn->dev_no,
		configParam.TreatedDialysisReportDataDirectory,
		configParam.TreatedDialysisReportDataDirectory2,
		json,
		fpath
	);
	if (fpath[0] != NULL) {
		// 治療外の治療番号と治療開始日時(透析レポートファイル名)を取得
		ret = comsv_json_lcd_req56(fpath, &req56);
	}
	snprintf(logMessage, sizeof(logMessage), "過去レポート復元処理, 過去透析番号情報ファイル取得%s, %s (%s)", (ret == 0 ? "成功": "失敗"), json, fpath);
	LogOutputs((ret == 0 ? NTSS_LOG_INFO : NTSS_LOG_ERROR), logMessage, 0, scn->deviceType, scn->devid);
	if(ret == 0)
	{
		// 該当ファイルあり

		// 過去透析番号情報ファイルの格納先が「/tmp/〜」かどうか
		if(strncasecmp(fpath, tmp, strlen(tmp)) != 0)
		{
			// 過去透析番号情報ファイルが「/tmp/」にない場合

			// 「/tmp/comsv_data/{装置番号}」にコピー
			comsv_work_fpath(scn->dev_no, json, fpath2);

			ret = copyFile(fpath, fpath2, NTSS_MOVEFILE_MODE_OVERWRITE);
			snprintf(logMessage, sizeof(logMessage), "過去レポート復元処理, 過去透析番号情報ファイルコピー%s, %s -> %s", (ret == 1 ? "成功" : "失敗"), fpath, fpath2);
			LogOutputs((ret == 1 ? NTSS_LOG_INFO : NTSS_LOG_ERROR), logMessage, 0, scn->deviceType, scn->devid);
		}

		// 直近
		for ( i = 0; i < REQ56_MAX; i++ ) {
			snprintf(logMessage, sizeof(logMessage), "過去レポート復元処理(直近), req56.last_no[%d] = %ld, eq56.last_name[%d] = %s", i, req56.last_no[i], i, req56.last_name[i]);
			LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);
			if ( req56.last_no[i] == 0 || req56.last_name[i] == 0 ) continue;

			// #12302 2025.10.23 mod 圧縮ファイルにて検索を行う TDC米沢 start
			// // 転送対象の透析レポートを検索
			// searchTreatedDialysisFile(
			// 	// #12302 2025.10.10 add ログ出力追加 TDC米沢 start
			// 	scn->deviceType,
			// 	scn->devid,
			// 	// #12302 2025.10.10 add ログ出力追加 TDC米沢 end
			// 	scn->dev_no,
			// 	configParam.TreatedDialysisReportDataDirectory,
			// 	configParam.TreatedDialysisReportDataDirectory2,
			// 	req56.last_name[i],
			// 	fpath
			// );
			// snprintf(logMessage, sizeof(logMessage), "過去レポート復元処理(直近), 透析レポート取得%s, %s (%s)", (fpath[0] != 0 ? "成功": "失敗"), req56.last_name[i], fpath);
			// 圧縮ファイル名作成
			sprintf(fpath3, "%ld.zip", req56.last_no[i]);
			// 転送対象の透析レポートを検索
			searchTreatedDialysisFile(
				// #12302 2025.10.10 add ログ出力追加 TDC米沢 start
				scn->deviceType,
				scn->devid,
				// #12302 2025.10.10 add ログ出力追加 TDC米沢 end
				scn->dev_no,
				configParam.TreatedDialysisReportDataDirectory,
				configParam.TreatedDialysisReportDataDirectory2,
				fpath3,
				fpath
			);
			snprintf(logMessage, sizeof(logMessage), "過去レポート復元処理(直近), 圧縮ファイル取得%s, %s (%s)", (fpath[0] != 0 ? "成功": "失敗"), fpath3, fpath);
			// #12302 2025.10.23 mod 圧縮ファイルにて検索を行う TDC米沢 end
			LogOutputs((fpath[0] != 0 ? NTSS_LOG_INFO : NTSS_LOG_ERROR), logMessage, 0, scn->deviceType, scn->devid);
			if(fpath[0] != 0)
			{
				// 直近の透析レポートの格納先が「/tmp/〜」かどうか
				if(strncasecmp(fpath, tmp, strlen(tmp)) != 0)
				{
					// 直近の透析レポートが「/tmp/」にない場合

					// 「/tmp/comsv_data/{装置番号}」にコピー

					// #12302 2025.10.23 mod 圧縮ファイルをコピー TDC米沢 start
					// comsv_work_fpath(scn->dev_no, req56.last_name[i], fpath2);
					// ret = copyFile(fpath, fpath2, NTSS_MOVEFILE_MODE_OVERWRITE);
					// snprintf(logMessage, sizeof(logMessage), "過去レポート復元処理(直近), 透析レポートコピー%s, %s -> %s", (ret == 1 ? "成功" : "失敗"), fpath, fpath2);
					comsv_work_fpath(scn->dev_no, fpath3, fpath2);
					ret = copyFile(fpath, fpath2, NTSS_MOVEFILE_MODE_OVERWRITE);
					snprintf(logMessage, sizeof(logMessage), "過去レポート復元処理(直近), 圧縮ファイルコピー%s, %s -> %s", (ret == 1 ? "成功" : "失敗"), fpath, fpath2);
					// #12302 2025.10.23 mod 圧縮ファイルをコピー TDC米沢 end
					LogOutputs((ret == 1 ? NTSS_LOG_INFO : NTSS_LOG_ERROR), logMessage, 0, scn->deviceType, scn->devid);
				}
			}
		}
		// 同一曜日
		for ( i = 0; i < REQ56_MAX; i++ ) {
			snprintf(logMessage, sizeof(logMessage), "過去レポート復元処理(同一曜日), req56.week_no[%d] = %ld, eq56.week_name[%d] = %s", i, req56.week_no[i], i, req56.week_name[i]);
			LogOutputs(NTSS_LOG_INFO, logMessage, 0, scn->deviceType, scn->devid);
			if ( req56.week_no[i] == 0 || req56.week_name[i] == 0 ) continue;

			// #12302 2025.10.23 mod 圧縮ファイルにて検索を行う TDC米沢 start
			// // 転送対象の透析レポートを検索
			// searchTreatedDialysisFile(
			// 	// #12302 2025.10.10 add ログ出力追加 TDC米沢 start
			// 	scn->deviceType,
			// 	scn->devid,
			// 	// #12302 2025.10.10 add ログ出力追加 TDC米沢 end
			// 	scn->dev_no,
			// 	configParam.TreatedDialysisReportDataDirectory,
			// 	configParam.TreatedDialysisReportDataDirectory2,
			// 	req56.week_name[i],
			// 	fpath
			// );
			// snprintf(logMessage, sizeof(logMessage), "過去レポート復元処理(同一曜日), 透析レポート取得%s, %s (%s)", (fpath[0] != 0 ? "成功": "失敗"), req56.week_name[i], fpath);
			// 圧縮ファイル名作成
			sprintf(fpath3, "%ld.zip", req56.week_no[i]);
			// 転送対象の透析レポートを検索
			searchTreatedDialysisFile(
				// #12302 2025.10.10 add ログ出力追加 TDC米沢 start
				scn->deviceType,
				scn->devid,
				// #12302 2025.10.10 add ログ出力追加 TDC米沢 end
				scn->dev_no,
				configParam.TreatedDialysisReportDataDirectory,
				configParam.TreatedDialysisReportDataDirectory2,
				fpath3,
				fpath
			);
			snprintf(logMessage, sizeof(logMessage), "過去レポート復元処理(同一曜日), 圧縮ファイル取得%s, %s (%s)", (fpath[0] != 0 ? "成功": "失敗"), fpath3, fpath);
			// #12302 2025.10.23 mod 圧縮ファイルにて検索を行う TDC米沢 end
			LogOutputs((fpath[0] != 0 ? NTSS_LOG_INFO : NTSS_LOG_ERROR), logMessage, 0, scn->deviceType, scn->devid);
			if(fpath[0] != 0)
			{
				// 同一曜日の透析レポート去透析番号情報ファイルの格納先が「/tmp/〜」かどうか
				if(strncasecmp(fpath, tmp, strlen(tmp)) != 0)
				{
					// 同一曜日のレポートが「/tmp/」にない場合

					// 「/tmp/comsv_data/{装置番号}」にコピー
					// #12302 2025.10.23 mod 圧縮ファイルをコピー TDC米沢 start
					// comsv_work_fpath(scn->dev_no, req56.week_name[i], fpath2);
					// ret = copyFile(fpath, fpath2, NTSS_MOVEFILE_MODE_OVERWRITE);
					// snprintf(logMessage, sizeof(logMessage), "過去レポート復元処理(同一曜日), 透析レポートコピー%s, %s -> %s", (ret == 1 ? "成功" : "失敗"), fpath, fpath2);
					comsv_work_fpath(scn->dev_no, fpath3, fpath2);
					ret = copyFile(fpath, fpath2, NTSS_MOVEFILE_MODE_OVERWRITE);
					snprintf(logMessage, sizeof(logMessage), "過去レポート復元処理(同一曜日), 圧縮ファイルコピー%s, %s -> %s", (ret == 1 ? "成功" : "失敗"), fpath, fpath2);
					// #12302 2025.10.23 mod 圧縮ファイルをコピー TDC米沢 end
					LogOutputs((ret == 1 ? NTSS_LOG_INFO : NTSS_LOG_ERROR), logMessage, 0, scn->deviceType, scn->devid);
				}
			}
		}
	}

	// 処理終了
	LogOutputs(NTSS_LOG_INFO, "過去レポート復元処理終了", 0, scn->deviceType, scn->devid);

	// スレッド終了
	pthread_exit((void *)0);
}
// #11629 2025.05.26 add 「/tmp」以外の治療済透析情報を「/tmp/」に復元する TDC米沢 end
