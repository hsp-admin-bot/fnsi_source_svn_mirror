/**
* @file comsv_rcv.c
* @brief 新通信受信データ処理
* @author Y.Takamura
* @date 2018/09/15
* @details 新通信装置から受信したデータ処理
*/

#include <stdio.h>
#include <string.h>
#include <pthread.h>
#include "ntss_comsv.h"
#include "ntss_devicecap_conf.h"

/**
* @fn void comsv_rcv(int thread_no, struct scn_data_fm *sp)
* @brief 新通信受信データ処理
* @param[in] thread_no スレッド番号
* @param[in,out] sp 装置制御データ
* @details 新通信装置から受信したデータ処理
*/
void comsv_rcv(int thread_no, struct scn_data_fm *sp) {
	int i, no;
	int len, max;
	short *sip;
	char fpath[64];
	unsigned char *cp;
	u_char logMsg[256];
	pthread_t thr_lcd;
	pthread_t thr_cond;
	pthread_attr_t thread_attr;
	struct NTSS_PACKET_INFORMATION *pInfo;
    // add FNSI-バグ 通信サーバ 高 start
    u_char sDev_pat_id[20];
    long lDev_pat_id;
    int ret;
    u_char *folder;
    char s_dir[128];
    char d_dir[256];
    // add FNSI-バグ 通信サーバ 高 end

	len = sp->rcvlen - 12;
	sp->sno = sp->rcvbuf[8];	// 受信したsno

	switch ( sp->rcvbuf[9] & 0xff ) {

	//////////////////////////////////////////
	// 透析装置からのコマンド（送信データ） //
	//////////////////////////////////////////

	case 0x61:	// ステータス転送
		comsv_mon(0, thread_no, sp);
		break;

	case 0x62:	// モニタデータ転送
		comsv_mon(1, thread_no, sp);
		break;

	case 0x63:	// 警報監視状態転送
		no = MON1_NUM;
		if ( sp->devsw == 'P' || sp->devsw == 'Q' ) {
			no = MON2_NUM;
		}
		if ( no < len ) break;
		// 装置監視状態設定
		pInfo = &packetInfoList[thread_no];
		for ( i = 0; i < no; i++ ) {
			setNTSSHostWatchMachineState( pInfo, i, sp->rcvbuf[i + 12]);
		}
		if ( sp->kansrd_flg == 1 ) {	// 警報監視除隊フラグ（0:装置側から任意,1:運転開始時）
			sp->kansrd_flg = 0;
			pInfo->watchWaitTime = 0;
		}
		break;

	case 0x65:	// 装置オプション転送
		sip = (short*)(sp->rcvbuf + 12);
		if ( len == 10 || len == 14 ) {
			// 戻り値に結果をセット
			sprintf(logMsg, "通信スレッドNEW[%d] : 装置オプション転送 [%ld]", thread_no, sp->dev_no);
		    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
			sp->option[0] = hl_chg(sip[0]);		// オプション１
			sp->option[1] = hl_chg(sip[1]);		// オプション２
			sp->option[2] = hl_chg(sip[2]);		// オプション３
			if ( len == 14 ) {	// 'P','Q'
				sp->option[3] = hl_chg(sip[5]);	// オプション４
				sp->option[4] = hl_chg(sip[6]);	// オプション５
			}
			// 装置マスタのオプションデータを更新する
			i = comsv_rest_put_option(sp->dev_no, sp->deviceType, sp->devid, sp->option);
			printf("comsv_rest_put_option = [%d]\n", i);
			// 装置マスタのオプションを更新する
			comsv_rcv_option_write(sp);
		}
		else if ( len != 0 ) {
			sp->staflg = E_LENCHK;
		}
		break;

	case 0x66:	// ログデータ転送
		comsv_mon(2, thread_no, sp);
		break;

	case 0x67:	// ＬＣＤデータ転送
		sip = (short*)(sp->rcvbuf + 12);
		sp->lcd_request = hl_chg(sip[0]);	// リクエストコード
		sp->lcd_argument1 = hl_chg(sip[1]);	// 引数１
		sp->lcd_argument2 = hl_chg(sip[2]);	// 引数２
		sp->lcd_argument3 = hl_chg(sip[3]);	// 引数３
		break;

	case 0x68:	// ＬＣＤデータ送信
		sip = (short*)(sp->rcvbuf + 12);
		sp->lcd_request = hl_chg(sip[0]);	// リクエストコード
        // #12257 2025.10.01 add DEのログに装置から受信したLCDデータのリクエストコードを出力する TDC高村 start
        sprintf(logMsg, "通信スレッドNEW[%d] : 透析装置からのLCDデータ送信（リクエストコード：%d）", thread_no, sp->lcd_request);
        LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
        // #12257 2025.10.01 add DEのログに装置から受信したLCDデータのリクエストコードを出力する TDC高村 end
		if ( configParam.lcdDataCash == 0 ) {
			// 仮想端末キャッシュを使用しない
			// ＬＣＤデータ入力処理
			comsv_lcd_input(sp);
		}
		else {
			// 仮想端末キャッシュを使用する
			// ＬＣＤデータ入力キャッシュ処理
			comsv_lcd_input_cash(sp);
			// スレッド属性オブジェクトの初期化
			pthread_attr_init(&thread_attr);
			// スレッド切り離し状態属性の設定
			pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
			// ＬＣＤデータ入力スレッド処理
			pthread_create(&thr_lcd, &thread_attr, comsv_thread_lcd_input, sp);
		}
		break;

	////////////////////////////////////////////
	// 送信コマンドに対してのレスポンスデータ //
	////////////////////////////////////////////

	case 0xe3:	// 警報監視状態読出
		no = MON1_NUM;
		if ( sp->devsw == 'P' || sp->devsw == 'Q' ) {
			no = MON2_NUM;
		}
		if ( no < len ) break;
		// 装置監視状態設定
		pInfo = &packetInfoList[thread_no];
		for ( i = 0; i < no; i++ ) {
			setNTSSHostWatchMachineState( pInfo, i, sp->rcvbuf[i + 12]);
		}
		if ( sp->kansrd_flg == 1 ) {	// 警報監視除隊フラグ（0:装置側から任意,1:運転開始時）
			sp->kansrd_flg = 0;
			pInfo->watchWaitTime = 0;
		}
		break;

	case 0xe5:	// 装置オプション読出
		sip = (short*)(sp->rcvbuf + 12);
		if ( len == 10 || len == 14 ) {
			sprintf(logMsg, "通信スレッドNEW[%d] : 装置オプション読出完了 [%ld]", thread_no, sp->dev_no);
		    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
			sp->option[0] = hl_chg(sip[0]);			// オプション１
			sp->option[1] = hl_chg(sip[1]);			// オプション２
			sp->option[2] = hl_chg(sip[2]);			// オプション３
			if ( len == 14 ) {	// 'P','Q'
				sp->option[3] = hl_chg(sip[5]);		// オプション４
				sp->option[4] = hl_chg(sip[6]);		// オプション５
			}
			// 装置マスタのオプションデータを更新する
			i = comsv_rest_put_option(sp->dev_no, sp->deviceType, sp->devid, sp->option);
			printf("comsv_rest_put_option = [%d]\n", i);
			// 装置マスタのオプションを更新する
			comsv_rcv_option_write(sp);
		}
		else if ( len != 0 ) {
			sp->staflg = E_LENCHK;
		}
		sp->comflg = C_OPTRD;
		break;

	case 0xe6:	// 装置時計設定
		sprintf(logMsg, "通信スレッドNEW[%d] : 装置時計設定完了 [%ld]", thread_no, sp->dev_no);
	    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
		sp->comflg = C_CLOCK;
		break;

	case 0xe9:	// 設定値読出
		if ( sp->devsw == 'I' || sp->devsw == 'J' ) {
			max = SET1_NUM;
		}
		else if ( sp->devsw == 'M' || sp->devsw == 'N' ) {
			max = SET2_NUM;
		}
		else {
			max = SET3_NUM;
		}
		if ( (len/2) < max ) break;
		sprintf(logMsg, "通信スレッドNEW[%d] : 設定値読出完了 [%ld][%ld][%ld]", thread_no, sp->dev_no, sp->ord_no, sp->pat_id);
	    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
		// 条件送信データからJSONファイルを作成する
		comsv_work_fpath(sp->dev_no, WORK_DEV_COND, fpath);
		i = comsv_json_dev_make_cond(fpath, sp->rcvbuf+12, len);
		printf("comsv_json_dev_make_cond = [%d]\n", i);
		// 設定値読み込み履歴を更新する
		no = sp->cond_read_flg;
		if ( no == 0 ) {
			no = 4;
		}
		else if ( no == 1 ) {
			no = 0;
		}
        sprintf(logMsg, "[gs debug] : sp->cond_read_flg = %d, no = %d, sp->cond_send_cancel = %d, sp->ord_no = %ld, sp->pat_id = %ld, sp->cond_set_date = %ld, sp->cond_send_flg = %d, sp->dial_start_date = %ld, sp->dial_end_date = %ld",  
                            sp->cond_read_flg, no, sp->cond_send_cancel, sp->ord_no, sp->pat_id, sp->cond_set_date, sp->cond_send_flg, sp->dial_start_date, sp->dial_end_date);
        LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
        
		// mod 内結障害#17 劉 start
		//if ( (no == 0 && !sp->cond_send_cancel) || (no && sp->ord_no && sp->pat_id && sp->cond_send_flg && sp->cond_set_date) ) {
		if ((no == 0 && !sp->cond_send_cancel) ||
			(no && sp->ord_no && sp->pat_id && sp->cond_send_flg && sp->cond_set_date) ||
			(no == 3 && sp->ord_no && sp->pat_id && sp->cond_send_flg) ||
            (sp->ord_no && sp->pat_id == 0 && sp->dial_start_date && sp->dial_end_date == 0)) {
		// mod 内結障害#17 劉 end
			// 条件キャンセル及び未登録運転以外の場合は設定値を保存
			i = comsv_rest_post_ord_cond(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, get_time(), no, fpath);
			printf("comsv_rest_post_ord_cond = [%d]\n", i);
		}
		sp->comflg = C_JSETRD;
		if ( sp->cond_read_flg == 1 ) {
            // del FNSI-バグ 通信サーバ 高 start
            //if ( comsv_cmd_npat2_check(sp) ) {
                // 次患者情報２送信
                //sp->reqflg[C_NEXTPAT2] = 1;
            //}
            // del FNSI-バグ 通信サーバ 高 end
			// 条件送信要求（1:有）
			sp->cond_read_flg = 0;
			sp->reqflg[C_JSET] = 1;
		}
		break;

	case 0xea:	// 設定値書込
		sprintf(logMsg, "通信スレッドNEW[%d] : 設定値書込完了 [%ld][%ld][%ld]", thread_no, sp->dev_no, sp->ord_no, sp->pat_id);
	    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
		sp->comflg = C_JSET;
		sp->cond_send_flg = 0;				// 条件送信フラグ（0:未送信,1:送信済）
		sp->cond_send_time = 0;				// 条件送信時刻（コマンド送信時刻）
		sp->cond_send_date = 0;				// 条件送信日時
		if ( sp->pat_id == 0 ) {
			// 条件送信キャンセルの場合
			// 状況に応じた装置制御データのクリア
			comsv_clear(3, sp);
		}
		else {
			sp->cond_send_flg = 1;
			sp->cond_send_date = get_time();
			// 設定値読み込み履歴を更新する
			comsv_work_fpath(sp->dev_no, WORK_DEV_COND, fpath);
			i = comsv_rest_post_ord_cond(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, sp->cond_send_date, 1, fpath);
			printf("comsv_rest_post_ord_cond = [%d]\n", i);
			// ホスト報知定義の取得・設定
			i = comsv_host_watch(thread_no, sp);
			printf("comsv_host_watch = [%d]\n", i);
			// スレッド属性オブジェクトの初期化
			pthread_attr_init(&thread_attr);
			// スレッド切り離し状態属性の設定
			pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
            // add ？？？？患者発生時の次患者情報送信#1437 高 start
            sp->unregistered_flg = 0;
            // add ？？？？患者発生時の次患者情報送信#1437 高 end
			// 条件送信完了時の一連スレッド処理
			pthread_create(&thr_cond, &thread_attr, comsv_thread_rest_cond, sp);
			// 時計設定を要求
			sp->reqflg[C_CLOCK] = 1;
            // add AWSとDEの通信断からの復旧 高 start
            sp->current_mon_sta[1] = sp->current_mon_sta[0]; 
            sp->current_mon_sta[0] = COMM_STA1;
            // add AWSとDEの通信断からの復旧 高 end
		}
		break;

	case 0xeb:	// 次回透析患者情報転送
		sprintf(logMsg, "通信スレッドNEW[%d] : 次回透析患者情報転送完了 [%ld][%ld][%ld]", thread_no, sp->dev_no, sp->next_ord_no, sp->next_pat_id);
	    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
		sp->comflg = C_NEXTPAT;
        // mod FNSI-バグ 通信サーバ 高 start
        //if ( sp->cond_read_flg == 0 ) {
        // 設定値読出がない場合（ある場合は設定読出完了タイミングで要求）
        if ( comsv_cmd_npat2_check(sp) ) {
            sp->reqflg[C_NEXTPAT2] = 1;
        }
        //}
        // #12301 2025.10.28 del 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start
        // if ( sp->ftp_clear_flg == 1 ) {
        //     // FTP画像削除フラグ
        //     sp->ftp_clear_flg = 0;
        //     // 画像データ削除
        //     sp->reqflg[C_DELETE] = 1;
        // }
        // #12301 2025.10.28 del 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
        // mod FNSI-バグ 通信サーバ 高 end
        // add 強制オフライン 高 start
        // 強制オフライン
        if( sp->force_flg == 1 && sp->force_cond_flg == 1) {
            sp->force_cond_flg = 0;
            sp->cond_send_flg = 1;
            
            // スレッド属性オブジェクトの初期化
            pthread_attr_init(&thread_attr);
            // スレッド切り離し状態属性の設定
            pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
            sp->unregistered_flg = 0;
            // 条件送信完了時の一連スレッド処理
            pthread_create(&thr_cond, &thread_attr, comsv_thread_rest_cond, sp);
        }
        // add 強制オフライン 高 end
		break;

	case 0xed:	// 次回透析患者情報２転送
		sprintf(logMsg, "通信スレッドNEW[%d] : 次回透析患者情報２転送完了 [%ld][%ld][%ld]", thread_no, sp->dev_no, sp->next_ord_no, sp->next_pat_id);
	    LogOutputs(NTSS_LOG_INFO, logMsg, 0, sp->deviceType, sp->devid);
		sp->comflg = C_NEXTPAT2;
        // #12301 2025.10.28 del 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start
		// if ( sp->ftp_clear_flg == 1 ) {
		//     // FTP画像削除フラグ
		//     sp->ftp_clear_flg = 0;
		//     // 画像データ削除
		//     sp->reqflg[C_DELETE] = 1;
		// }
        // #12301 2025.10.28 del 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end
		break;

	case 0xef:	// 画像データ削除
		sp->comflg = C_DELETE;
		break;

	case 0xf1:	// お知らせ情報転送
		sp->comflg = C_NOTICE;
		break;

	}
}

/**
* @fn void	comsv_rcv_reset( struct scn_data_fm *sp )
* @brief 受信コマンドによる要求リセット
* @param[in,out] sp 装置制御データ
* @details 受信コマンドによる要求リセット処理
*/
void comsv_rcv_reset(struct scn_data_fm *sp)
{
	switch ( sp->rcvbuf[9] & 0xff ) {

		//////////////////////////////////////////////
		//	送信コマンドに対してのレスポンスデータ	//
		//////////////////////////////////////////////

		case 0xe5:	//	装置オプション読出
			sp->reqflg[C_OPTRD] = 0;
			break;

		case 0xe6:	//	装置時計設定
			sp->reqflg[C_CLOCK] = 0;
			break;

		case 0xe9:	//	設定値読出
			sp->reqflg[C_JSETRD] = 0;
			break;

		case 0xea:	//	設定値書込
			sp->reqflg[C_JSET] = 0;
			sp->cond_send_time = 0;	// 条件送信時刻（コマンド送信時刻）
			break;

		case 0xeb:	//	次回透析患者情報転送
			sp->reqflg[C_NEXTPAT] = 0;
			break;

		case 0xed:	//	次回透析患者情報２転送
			sp->reqflg[C_NEXTPAT2] = 0;
			break;

	}
}

/**
* @fn void	comsv_reqflg_reset( struct scn_data_fm *sp )
* @brief 要求フラフ全リセット
* @param[in,out] sp 装置制御データ
* @details 要求フラフ全リセット処理
*/
void comsv_reqflg_reset(struct scn_data_fm *sp)
{
	//	装置オプション読出
	sp->reqflg[C_OPTRD] = 0;
	//	装置時計設定
	sp->reqflg[C_CLOCK] = 0;
	//	設定値読出
	sp->reqflg[C_JSETRD] = 0;
	//	設定値書込
	if ( sp->reqflg[C_JSET] ) {
		// 体重計測定実績のステータス・メッセージデータを更新する
		comsv_rest_put_scale_state(sp->dev_no, sp->deviceType, sp->devid, sp->cond_send_ctrl, 4);
	}
	sp->reqflg[C_JSET] = 0;
	sp->cond_send_time = 0;	// 条件送信時刻（コマンド送信時刻）
	//	次回透析患者情報転送
	sp->reqflg[C_NEXTPAT] = 0;
	//	次回透析患者情報２転送
	sp->reqflg[C_NEXTPAT2] = 0;
}

/**
 * @fn int comsv_rcv_option_write(struct scn_data_fm *scn)
 * @brief 装置マスタのオプション更新（新通信用）
 * @param[in] scn 装置制御データ
 * @return 0 成功
 * @return -1 失敗
 */
int comsv_rcv_option_write(struct scn_data_fm *scn) {
	int Ret = -1;
	u_char opt[25];
	u_char filePath[256];

    // バイナリモードで書込ファイルオープン
	sprintf(filePath, "%s/%s", configParam.mstDir, MST_INFO);
    FILE *fpr = fopen(filePath, "r+");
    if ( fpr != NULL ) {
		if ( !fseek(fpr, (long)((sizeof(MachineInfo2_t) * scn->dev_idx) - 20), SEEK_SET) ) {
			// オプションデータを書込
			sprintf(opt, "%04X%04X%04X%04X%04X",
				scn->option[0], scn->option[1], scn->option[2], scn->option[3], scn->option[4]);
			fwrite(opt, 1, 20, fpr);
			Ret = 0;
		}
		fclose(fpr);
    }
	return Ret;
}
