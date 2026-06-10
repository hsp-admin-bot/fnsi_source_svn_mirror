/**
* @file comsv_lcd_input.c
* @brief ＬＣＤデータ入力処理(装置新機種)
* @author Y.Takamura
* @date 2018/09/14
* @details 新通信装置から受信したＬＣＤデータ入力処理
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <pthread.h>
#include "ntss_comsv.h"

/**
* @fn void comsv_lcd_input(struct scn_data_fm *sp)
* @brief ＬＣＤデータ入力処理
* @param[in,out] sp 装置制御データ
* @details 新通信装置から入力されたＬＣＤデータ入力処理
*/
void comsv_lcd_input(struct scn_data_fm *sp)
{
	short req = sp->lcd_request;
	short inp, pos;
	short cd, count;
	int ret;
	int i, j, k;
	int no[REQ41_MAX];
	int cno[REQ50_MAX];
	int tno[REQ50_MAX];
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
	//long id, ldate;
	long id;
	time_t ldate;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
	char buf[30];
	char wrk[30];
	char fpath[64];
	char jdata[3200];
	unsigned char ord_str[10];

	memset(buf, 0, sizeof(buf));
	sprintf(ord_str, "%ld", sp->ord_no);

	switch ( req ) {

		case 1:		// 愁訴／処置
			if ( sp->cond_send_flg == 0 ) {
				// 条件未送信
				break;
			}
			j = k = 0;
			memset(cno, 0, sizeof(cno));
			memset(tno, 0, sizeof(tno));
			pos = 14;
		    count = *(short*)(sp->rcvbuf + pos);
			count = hl_chg(count);	// 愁訴実施数
			pos += 2;
			if ( count > 0 && count <= REQ50_MAX ) {
				for ( i = 1; i <= count; i++, pos += 2 ) {
					inp = *(short*)(sp->rcvbuf + pos);
					inp = hl_chg(inp);	// 選択番号
					if ( inp <= 0 || inp > REQ50_MAX ) continue;
					inp--;
					cno[j] = _comsvCache._lcdReq50.c_code[inp];
					j++;
				}
			}
		    count = *(short*)(sp->rcvbuf + pos);
			count = hl_chg(count);	// 愁訴実施数
			pos += 2;
			if ( count > 0 && count <= REQ50_MAX ) {
				for ( i = 1; i <= count; i++, pos += 2 ) {
					inp = *(short*)(sp->rcvbuf + pos);
					inp = hl_chg(inp);	// 選択番号
					if ( inp <= 0 || inp > REQ50_MAX ) continue;
					inp--;
					tno[k] = _comsvCache._lcdReq50.t_code[inp];
					k++;
				}
			}
			if ( j || k ) {
				sp->comptreat_date = get_time();
				ret = comsv_json_ord_make_comptreat(jdata, cno, j, tno, k);
				printf("comsv_json_ord_make_comptreat = [%d]\n", ret);
				// 治療情報の実績愁訴・愁訴処置情報を更新する
				ret = comsv_rest_post_ord_comptreat(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, sp->comptreat_date, jdata);
				printf("comsv_rest_post_ord_comptreat = [%d]\n", ret);
			}
			break;

		case 2:		// 処置者
		case 10:	// 投与者
		case 13:	// 酸素吸入処置者
			if ( sp->cond_send_flg == 0 ) {
				// 条件未送信
				break;
			}
			memcpy(buf, sp->rcvbuf + 14, 20);
			// 処置者名称から処置者ID取得
			id = comsv_lcd_search(buf);
			if ( id == 0 ) {
				// 対象なし
				break;
			}
			if ( req == 2 ) {
				// 治療情報の実績愁訴処置者情報を更新する
				ret =  comsv_rest_put_ord_comptreat_staff(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, sp->comptreat_date, id);
				printf("comsv_rest_put_ord_comptreat_staff = [%d]\n", ret);
			}
			else if ( req == 10 ) {
				// 治療情報の実績投与薬剤情報を更新する
				ret = comsv_rest_put_ord_medi_user(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, id, sp->medi_effect_date);
				printf("comsv_rest_put_ord_medi = [%d]\n", ret);
			}
			else if ( req == 13 ) {
				// 治療情報の酸素吸入処置者情報を更新する
				ret =  comsv_rest_put_ord_oxygen_staff(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, sp->oxygen_date, id);
				printf("comsv_rest_put_ord_oxygen_staff = [%d]\n", ret);
			}
			break;

		case 3:		// 穿刺者１
		case 4:		// 穿刺者２
		case 5:		// 回収者１
		case 6:		// 回収者２
		case 7:		// 担当者１
		case 8:		// 担当者２
			if ( sp->cond_send_flg == 0 ) {
				// 条件未送信
				break;
			}
			memcpy(buf, sp->rcvbuf + 17, 20);
			// 処置者名称から処置者ID取得
			id = comsv_lcd_search(buf);
			if ( id == 0 ) {
				// 対象なし
				break;
			}
			if ( req == 3 || req == 4 ) {		// 穿刺者１、２
				inp = 0;
				pos = req - 2;
			}
			else if ( req == 5 || req == 6 ) {	// 回収者１、２
				inp = 1;
				pos = req - 4;
			}
			else if ( req == 7 || req == 8 ) {	// 担当者１、２
				inp = 2;
				pos = req - 6;
			}
			// 治療情報の穿刺者／返血者／担当者情報を更新する
			ret = comsv_rest_put_ord_user(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, inp, pos, id, get_time());
			printf("comsv_rest_put_ord_user = [%d]\n", ret);
			break;

		case 9:		// 投与薬剤
			if ( sp->cond_send_flg == 0 ) {
				// 条件未送信
				break;
			}
			// 仮想端末（投与薬剤）読み込み
			LcddataReq41_t req41;
            comsv_work_fpath(sp->dev_no, WORK_LCD_REQ41, fpath);
			ret = comsv_json_lcd_req41(fpath, &req41);
			printf("comsv_json_lcd_req41 = [%d]\n", ret);
			memset(no, 0, sizeof(no));
		    count = *(short*)(sp->rcvbuf + 14);
			count = hl_chg(count);	// 実施数
			if ( count <= 0 ) {
				break;
			}
			if ( count > 100 ) {
				count = 100;
			}
			pos = 16;
			for ( i = 1, j = 0; i <= count; i++, pos+=2 ) {
				inp = *(short*)(sp->rcvbuf+pos);
				inp = hl_chg(inp);	// 選択番号
				if ( inp <= 0 || inp > REQ41_MAX ) continue;
				inp--;
				no[j] = req41.no[inp];
				j++;
			}
			if ( j ) {
				sp->medi_effect_date = get_time();
				ret = comsv_json_ord_make_medi(jdata, no, j);
				printf("comsv_json_ord_make_medi = [%d]\n", ret);
				// 治療情報の実績投与薬剤情報を更新する
                // #11367 2025.01.10 mod 仮想端末用REST処理の見直し TDC高村 start
				//ret = comsv_rest_post_ord_medi(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, sp->medi_effect_date, jdata);
				ret = comsv_rest_post_ord_medi_ex(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, sp->medi_effect_date, jdata);
                // #11367 2025.01.10 mod 仮想端末用REST処理の見直し TDC高村 end
				printf("comsv_rest_put_ord_medi = [%d]\n", ret);
                
                // add FNSI-バグ 通信サーバ 高 start
                // 仮想端末（投与薬剤）読み込み
                unsigned char ord_str[64];
                
                if(sp->ord_no != 0) {
                    sprintf(ord_str, "%ld", sp->ord_no);
                    comsv_work_fpath(sp->dev_no, WORK_LCD_REQ41, fpath);
                    i = comsv_rest_get_lcd(sp->dev_no, sp->deviceType, sp->devid, 41, ord_str, fpath);
                    printf("comsv_rest_get_lcd 41 = [%d]\n", i);
                    i = comsv_json_lcd_req41(fpath, &req41);
                    printf("comsv_json_lcd_req41 = [%d]\n", i);
                    comsv_effectFlg_check(sp, &req41);
                }
                // add FNSI-バグ 通信サーバ 高 end
			}
			break;

		case 11:	// 酸素吸入開始
		case 12:	// 酸素吸入終了
			inp = *(short*)(sp->rcvbuf + 14);
			sp->oxygen_sta = hl_chg(inp);	// 状況
			if ( req==11 ) {
				// 治療情報の酸素吸入情報を更新する
				sp->oxygen_date = get_time();
				sp->oxygen_amount = 0;
				ret = comsv_rest_put_ord_oxygen(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, sp->oxygen_date, sp->oxygen_date, 0);
			}
			else {
				// 治療情報の酸素吸入情報を更新する
				inp = *(short*)(sp->rcvbuf + 19);
				inp = hl_chg(inp);	// 吸入量
				sp->oxygen_date = get_time();
				sp->oxygen_amount = inp;
				ret = comsv_rest_put_ord_oxygen(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, sp->oxygen_date, 0, inp);
			}
			printf("comsv_rest_put_ord_oxygen = [%d]\n", ret);
			break;

		case 14:	// チェックリスト
			cd = *(short*)(sp->rcvbuf + 14);
			cd = hl_chg(cd);	//	画面Ｎｏ
			if ( cd < 1 || cd > REQ54_NO_MAX ) {
				break;
			}
			pos = _comsvCache._checkMst.list_time[cd - 1];
	    	if ( pos == 0 && (sp->mon_sta & 1) ) {
				// 入力タイミングが透析前で装置が運転中の場合
                break;
			}
	    	else if ( pos == 0 && sp->dial_end_date ) {
				// 入力タイミングが透析前で透析終了時刻が既にある場合
                break;
			}
            // mod FNSI-バグ 通信サーバ #10310 高 start
	    	// else if ( pos && (sp->cond_send_flg == 0 || sp->pat_id == 0) ) {
            else if ( pos && (sp->cond_send_flg == 0) ) {
            // mod FNSI-バグ 通信サーバ #10310 高 end
				// 入力タイミングが透析前以外で条件未送信又は患者未登録の場合
                break;
			}
	    	else if ( pos && !(sp->mon_sta & 1) && sp->dial_end_date == 0 ) {
				// 入力タイミングが透析前以外で運転中以外かつ透析終了時刻なしの場合
                break;
			}
			//add redmine bug# 7172 劉 start
			cd = _comsvCache._checkMst.list_cd[cd - 1];
			//add redmine bug# 7172 劉 end
			count = *(short*)(sp->rcvbuf + 16);
			count = hl_chg(count);	//	チェックリスト選択数
			pos = 18;
			memset(no, 0, sizeof(no));
			memset(buf, 0, sizeof(buf));
			memcpy(buf, sp->rcvbuf + pos + (count*2), 20);
			id = 0;
			ldate = get_time();
			if ( memcmp(buf, "                    ", 20) ) {
				id = comsv_lcd_search(buf);
			}
			// #12271 2025.10.08 mod 処置項目選択時に実施時刻を記録し、処置者入力のときには記録しない TDC片口 start
			// if ( id == 0 ) {
			// 	// 対象なし
			// 	ldate = 0;
			// }
			if ( id != 0 ) {
				// 処置者が入力された場合は送信する実施時刻をリセット
				ldate = 0;
			}
			// #12271 2025.10.08 mod 処置項目選択時に実施時刻を記録し、処置者入力のときには記録しない TDC片口 end
			for ( i = 1, j = 0; i <= count; i++, pos+=2 ) {
				inp = *(short*)(sp->rcvbuf+pos);
				inp = hl_chg(inp);	// 選択番号
				if ( inp <= 0 || inp > REQ54_MAX ) continue;
				no[j] = inp;
				j++;
			}
			if ( j ) {
			    sprintf(wrk, "%s", WORK_LCD_REQ54);
				sprintf(buf, wrk, cd);
	            comsv_work_fpath(sp->dev_no, buf, fpath);
				ret = comsv_json_ord_make_check(jdata, fpath, no, j, id, ldate);
				printf("comsv_json_ord_make_check = [%d]\n", ret);
				// チェックリスト実績情報を更新する
				id = sp->ord_no;
				if ( sp->cond_send_flg == 0 ) {
					id = sp->next_ord_no;
				}
				ret = comsv_rest_post_ord_check(sp->dev_no, sp->deviceType, sp->devid, id, 0 + sp->cond_send_flg, cd, jdata);
				printf("comsv_rest_post_ord_check = [%d]\n", ret);
			}
			break;

	}
}

/**
* @fn void comsv_lcd_input_cash(struct scn_data_fm *sp)
* @brief ＬＣＤデータ入力キャッシュ処理
* @param[in,out] sp 装置制御データ
* @details 新通信装置から入力されたＬＣＤデータ入力キャッシュ処理
*/
void comsv_lcd_input_cash(struct scn_data_fm *sp)
{
	short req = sp->lcd_request;
	short inp, pos;
	short cd, count;
	int i, j, ret;
	int chk[20];
	long id;
	char buf[30];
	char fpath[64];

	memset(buf, 0, sizeof(buf));

	switch ( req ) {

		case 3:		// 穿刺者１
		case 4:		// 穿刺者２
		case 5:		// 回収者１
		case 6:		// 回収者２
		case 7:		// 担当者１
		case 8:		// 担当者２
			if ( sp->cond_send_flg == 0 ) {
				// 条件未送信
				break;
			}
			memcpy(buf, sp->rcvbuf + 17, 20);
			// 処置者名称から処置者ID取得
			id = comsv_lcd_search(buf);
			if ( id == 0 ) {
				// 対象なし
				break;
			}
			if ( req==3 || req==4 ) {		// 穿刺者１、２
				inp = 0;
				pos = req - 2;
			}
			else if ( req==5 || req==6 ) {	// 回収者１、２
				inp = 1;
				pos = req - 4;
			}
			else if ( req==7 || req==8 ) {	// 担当者１、２
				inp = 2;
				pos = req - 6;
			}
			// 仮想端末（穿刺／回収／担当）JSONファイルを更新する
			ret = comsv_json_lcd_cash_upd51(sp->dev_no, inp, pos, get_time(), id, buf);
			printf("comsv_json_lcd_cash_upd51 = [%d]\n", ret);
			break;

		case 9:		// 投与薬剤
			if ( sp->cond_send_flg == 0 ) {
				// 条件未送信
				break;
			}
		    count = *(short*)(sp->rcvbuf + 14);
			count = hl_chg(count);	// 実施数
			if ( count <= 0 ) {
				break;
			}
			if ( count > 100 ) {
				count = 100;
			}
			// 仮想端末（投与薬剤）読み込み
			LcddataReq41_t req41;
            comsv_work_fpath(sp->dev_no, WORK_LCD_REQ41, fpath);
			ret = comsv_json_lcd_req41(fpath, &req41);
			printf("comsv_json_lcd_req41 = [%d]\n", ret);
			pos = 16;
			memset(chk, 0, sizeof(chk));
			for ( i = 1, j = 0; i <= count; i++, pos+=2 ) {
				inp = *(short*)(sp->rcvbuf + pos);
				inp = hl_chg(inp);	// 選択番号
				if ( inp <= 0 || inp > REQ41_MAX ) continue;
				inp--;
				chk[inp] = 1;
				j++;
			}
			if ( j ) {
				// 仮想端末（投与薬剤）JSONファイルを更新する
				ret = comsv_json_lcd_cash_upd41(sp->dev_no, chk, get_time());
				printf("comsv_json_lcd_cash_upd41 = [%d]\n", ret);
			}
			break;

		case 11:	// 酸素吸入開始
		case 12:	// 酸素吸入終了
			inp = *(short*)(sp->rcvbuf + 14);
			sp->oxygen_sta = hl_chg(inp);	// 状況
			if ( req==11 ) {
				// 治療情報の酸素吸入情報を更新する
				sp->oxygen_date = get_time();
				sp->oxygen_amount = 0;
				// 仮想端末（酸素吸入）JSONファイルを更新する
				ret = comsv_json_lcd_cash_upd32(sp->dev_no, 0, get_time(), sp->oxygen_date, 0, 0, "");
			}
			else {
				// 治療情報の酸素吸入情報を更新する
				inp = *(short*)(sp->rcvbuf + 19);
				inp = hl_chg(inp);	// 吸入量
				sp->oxygen_date = get_time();
				sp->oxygen_amount = inp;
				// 仮想端末（酸素吸入）JSONファイルを更新する
				ret = comsv_json_lcd_cash_upd32(sp->dev_no, 1, get_time(), sp->oxygen_date, sp->oxygen_amount, 0, "");
			}
			printf("comsv_json_lcd_cash_upd32 = [%d]\n", ret);
			break;

		case 13:	// 酸素吸入処置者
			if ( sp->cond_send_flg == 0 ) {
				// 条件未送信
				break;
			}
			memcpy(buf, sp->rcvbuf + 14, 20);
			// 処置者名称から処置者ID取得
			id = comsv_lcd_search(buf);
			if ( id == 0 ) {
				// 対象なし
				break;
			}
			// 仮想端末（酸素吸入）JSONファイルの処置者を更新する
			ret = comsv_json_lcd_cash_upd32(sp->dev_no, sp->oxygen_sta ^ 1, get_time(), sp->oxygen_date, sp->oxygen_amount, id, buf);
			printf("comsv_json_lcd_cash_upd32 = [%d]\n", ret);
			break;

		case 14:	// チェックリスト
			cd = *(short*)(sp->rcvbuf + 14);
			cd = hl_chg(cd);	//	画面Ｎｏ
			if ( cd < 1 || cd > REQ54_NO_MAX ) {
				break;
			}
			pos = _comsvCache._checkMst.list_time[cd - 1];
	    	if ( pos == 0 && (sp->mon_sta & 1) ) {
				// 入力タイミングが透析前で装置が運転中の場合
                break;
			}
	    	else if ( pos == 0 && sp->dial_end_date ) {
				// 入力タイミングが透析前で透析終了時刻が既にある場合
                break;
			}
	    	else if ( pos && (sp->cond_send_flg == 0 || sp->pat_id == 0) ) {
				// 入力タイミングが透析前以外で条件未送信又は患者未登録の場合
                break;
			}
	    	else if ( pos && !(sp->mon_sta & 1) && sp->dial_end_date == 0 ) {
				// 入力タイミングが透析前以外で運転中以外かつ透析終了時刻なしの場合
                break;
			}
			//add redmine bug# 7172 劉 start
			cd = _comsvCache._checkMst.list_cd[cd - 1];
			//add redmine bug# 7172 劉 end
			count = *(short*)(sp->rcvbuf+16);
			count = hl_chg(count);	//	チェックリスト選択数
			pos = 18;
			memset(chk, 0, sizeof(chk));
			for ( i = 1, j = 0; i <= count; i++, pos+=2 ) {
				inp = *(short*)(sp->rcvbuf + pos);
				inp = hl_chg(inp);	// 選択番号
				if ( inp <= 0 || inp > REQ54_MAX ) continue;
				inp--;
				chk[inp] = 1;
				j++;
			}
			if ( j ) {
				// 仮想端末（チェックリスト）JSONファイルを更新する
				ret = comsv_json_lcd_cash_upd54(sp->dev_no, cd, chk, get_time());
				printf("comsv_json_lcd_cash_upd54 = [%d]\n", ret);
			}
			break;

	}
}

/**
* @fn long comsv_lcd_search(char *user_name)
* @brief 処置者名称から処置者ID取得
* @param[in] user_name 検索対象となる処置者名称
* @return long 処置者ID（一致なしは0）
* @details 指定した処置者名称から処置者IDを取得
*/
long comsv_lcd_search(char *user_name)
{
	int i;
	long id = 0;
	char buf[21];

	for ( i = 0; i < REQ29_MAX; i++ ) {
		memset(buf, ' ', sizeof(buf));
		comsv_lcd_memcpy(buf, _comsvCache._lcdReq29.name[i], 12);
		if ( memcmp(user_name, buf, 20) == 0 ) {
			id = _comsvCache._lcdReq29.id[i];
			break;
		}
	}

	return id;
}
