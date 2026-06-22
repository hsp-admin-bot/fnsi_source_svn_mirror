/**
* @file comsv_lcd_disp.c
* @brief ＬＣＤデータ処理(装置新機種)
* @author Y.Takamura
* @date 2018/09/14
* @details 新通信装置から受信したＬＣＤデータ処理
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <pthread.h>
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
//#include "ntss_file.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
// #11378 2024.12.24 add 仮想端末の画面表示不正 TDC高村 start
#include <sys/time.h>
// #11378 2024.12.24 add 仮想端末の画面表示不正 TDC高村 end
#include "ntss_comsv.h"

/**
* @fn int comsv_lcd_disp(int thread_no, unsigned char *dp, struct scn_data_fm *sp)
* @brief ＬＣＤデータ表示処理
* @param[in] thread_no スレッド番号
* @param[out] dp 表示データ
* @param[in,out] sp 装置制御データ
* @return int 表示データ長
* @details 新通信装置に表示するＬＣＤデータ表示処理
*/
int comsv_lcd_disp(int thread_no, unsigned char *dp, struct scn_data_fm *sp)
{
	int ret;
	int i, j, k;
	int len, po;
	long value;
	short k_time, o_time;
	short n_time1, n_time2;
	char buf[512];
	char wrk[512];
	char fpath[64];
	char fpath_ex[64];
	char dev_sno[10];
	char dt[20], tm[20];
	unsigned char mon_dat[10];
	unsigned char ord_str[10];
	unsigned char pat_str[10];
	pthread_t thr_bmp;
	pthread_attr_t thread_attr;
    char str1[512];
    
    // add FNSI-バグ 通信サーバ 高 start
    char t_uname[128];
    char sjis[128];
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //struct timeval now;
    struct timespec now;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    // add FNSI-バグ 通信サーバ 高 end
	//add redmine bug# 5919 劉 start
	int cd = 0;
	//add redmine bug# 5919 劉 end

    // #11157 2024.11.01 add DE切断時の仮想端末サポート TDC高村 start
    int alive_flg = getCommAliveState();
    // #11157 2024.11.01 add DE切断時の仮想端末サポート TDC高村 end
	len = 0;
	memset(buf, 0, sizeof(buf));
	sprintf(ord_str, "%ld", sp->ord_no);
	sprintf(pat_str, "%ld", sp->pat_id);

	// 仮想端末
	switch ( sp->lcd_request ) {

		case 29:	// 処置者
            // #11157 2024.11.01 add DE切断時の仮想端末サポート TDC高村 start
			if ( alive_flg ) {
                // 通信断
                len = sp->lcd_argument2 * 20;
				memset(buf, ' ', len);
				memcpy(dp, buf, len);
                dp += len; 
                break;
            }
            // #11157 2024.11.01 add DE切断時の仮想端末サポート TDC高村 end
			j = sp->lcd_argument1;
			j--;
			if ( j<0 ) j = 0;
			j *= sp->lcd_argument2;
			for ( i = j; i < j + sp->lcd_argument2; i++ ) {
				memset(buf, ' ', 20);
				if ( i >= (24 * 14) ) {
					break;
				}
				else if ( i < 320 ) {
					// 全角6文字まで表示
					comsv_lcd_memcpy(buf, _comsvCache._lcdReq29.name[i], 12);
				}
				memcpy(dp, buf, 20);
				dp += 20; len += 20;
			}
			break;

		case 32:	// 酸素吸入
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 start
			//if ( sp->cond_send_flg == 0 ) {
			if ( alive_flg || sp->cond_send_flg == 0 ) {
				// 通信断 or 条件未送信
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 end
				memcpy(dp, buf, 47);
				dp += 47; len += 47;
				break;
			}
			// 仮想端末（酸素吸入）読み込み
			LcddataReq32_t req32;
			comsv_work_fpath(sp->dev_no, WORK_LCD_REQ32, fpath);
			if ( configParam.lcdDataCash == 0 ) {
				// 仮想端末データキャッシュを使用しない
				ret = comsv_rest_get_lcd(sp->dev_no, sp->deviceType, sp->devid, 32, ord_str, fpath);
				printf("comsv_rest_get_lcd 32 = [%d]\n", ret);
			}
            // mod FNSI-バグ 通信サーバ #10270 高 start
			// ret = comsv_json_lcd_req32(fpath, &req32);
            ret = comsv_json_lcd_req32(fpath, sp, &req32);
            // mod FNSI-バグ 通信サーバ #10270 高 end
			printf("comsv_json_lcd_req32 = [%d]\n", ret);
			short_set(dp, sp->oxygen_sta);
			dp += 2; len += 2;
			time_bcd(req32.s_time, wrk);
			memcpy(dp, wrk+4, 3);
			dp += 3; len += 3;
			comsv_lcd_memcpy(dp, req32.s_staff, 20);
			dp += 20; len += 20;
			comsv_lcd_memcpy(dp, req32.e_staff, 20);
			dp += 20; len += 20;
			short_set(dp, req32.amount);
			dp += 2; len += 2;
			break;

		case 33:	// 検査結果
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 start
			//if ( sp->cond_send_flg == 0 ) {
			if ( alive_flg || sp->cond_send_flg == 0 ) {
				// 通信断 or 条件未送信
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 end
				short_set(dp, 0);
				dp += 2; len += 2;
				memcpy(dp, buf, 10);
				dp += 10; len += 10;
				short_set(dp, 0);
				dp += 2; len += 2;
				break;
			}
			// 仮想端末（検査結果）読み込み
			LcddataReq33_t req33;
			comsv_work_fpath(sp->dev_no, WORK_LCD_REQ33, fpath);
			if ( configParam.lcdDataCash == 0 ) {
				// 仮想端末データキャッシュを使用しない
				if ( sp->lcd_argument1 <= 1 && sp->lcd_argument3 == 1 ) {
					// 初回表示なら
					ret = comsv_rest_get_lcd(sp->dev_no, sp->deviceType, sp->devid, 33, pat_str, fpath);
					printf("comsv_rest_get_lcd 33 = [%d]\n", ret);
				}
			}
			po = sp->lcd_argument3;
			po--;
			if ( po < 0 ) po = 0;
			else if ( po >= REQ33_DATE_MAX ) po = REQ33_DATE_MAX - 1;
			ret = comsv_json_lcd_req33(fpath, po, &req33);
			printf("comsv_json_lcd_req33 = [%d]\n", ret);
			if ( ret <= 0 ) ret = 0;
			short_set(dp, ret);	// 検査件数
			dp += 2; len += 2;
			if ( ret == 0 ) {
				memcpy(dp, buf, 10);
				dp += 10; len += 10;
				short_set(dp, 0);
				dp += 2; len += 2;
				break;
			}
			time_str(req33.date, dt, tm, 1);
			memcpy(dp, dt, 10);
			dp+=10; len+=10;
			short_set(dp, req33.class);
			dp+=2; len+=2;
			po = sp->lcd_argument1;
			k = sp->lcd_argument2;
			po--;
			if ( po < 0 ) po = 0;
			else if ( po >= 10 ) po = 9;
			if ( k <= 0 || k > 10 ) k = 10;
			po *= k;
			for ( i = po; i < po + k; i++ ) {
				if ( i >= REQ33_MAX ) break;
				comsv_lcd_memcpy(dp, req33.item_name[i], 20);
				dp+=20; len+=20;
				memset(buf, ' ', sizeof(buf));
				if ( req33.item_data[i] != (long)(0x80000000) ) {
					dsp_l_form(buf, 8, req33.item_dec[i], req33.item_data[i]);
				}
				memcpy(dp, buf, 8);
				dp+=8; len+=8;
				comsv_lcd_memcpy(dp, req33.item_unit[i], 8);
				dp+=8; len+=8;
			}
			break;

		case 36:	// ログ
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 start
			//if ( sp->cond_send_flg == 0 ) {
			if ( alive_flg || sp->cond_send_flg == 0 ) {
				// 通信断 or 条件未送信
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 end
				short_set(dp, 0);
				dp += 2; len += 2;
				short_set(dp, 0);
				dp += 2; len += 2;
				*dp++ = 0x00;
				len++;
				break;
			}
			// 仮想端末（ログ）読み込み
			LcddataReq36_t req36;
			// 製造番号の空白除去
			memset(dev_sno, 0, sizeof(dev_sno));
			memcpy(dev_sno, sp->devid, 8);
			str_trim(dev_sno);
			// 日付を対象文字列に変換
			if ( time_str(sp->cond_send_date, dt, tm, 1) == 0 ) {
				dt[4] = dt[7] = tm[2] = tm[5] = 0;
				sprintf(wrk, "%s%s%s%s%s%s", dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
			}
			else if ( time_str(sp->dial_start_date, dt, tm, 1) == 0 ) {
				// 未登録運転の場合は透析開始日時を使う
				dt[4] = dt[7] = tm[2] = tm[5] = 0;
				sprintf(wrk, "%s%s%s%s%s%s", dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
			}
			else {
				strcpy(wrk, "19700101000000");
			}
			//del redmine bug#6392 劉 start
			//if ( _comsvCache._comsvSet.lcd_log_type == '0' ) {
			//	sprintf(ord_str, "%ld", 0l);
			//}
			//del redmine bug#6392 劉 end
			sprintf(buf, "%.3s\t%.8s\t%s\t%s\t%d", sp->deviceType, dev_sno, wrk, ord_str, (sp->lcd_argument1 - 1) * 10);
			comsv_work_fpath(sp->dev_no, WORK_LCD_REQ36, fpath);
			ret = comsv_rest_get_lcd(sp->dev_no, sp->deviceType, sp->devid, 36, buf, fpath);
			printf("comsv_rest_get_lcd 36 = [%d]\n", ret);
			ret = comsv_json_lcd_req36(fpath, &req36);
			printf("comsv_json_lcd_req36 = [%d]\n", ret);
			short_set(dp, req36.all_count);
			dp += 2; len += 2;
			short_set(dp, req36.count);
			dp += 2; len += 2;
			if ( _comsvCache._comsvSet.lcd_log_time == '0' ) *dp = 0x00;
			else *dp = 0x01;
			dp++; len++;
			for ( i = 0; i < req36.count; i++ ) {
				time_bcd(req36.date[i], wrk);
				memcpy(dp, wrk, 7);
				dp += 7; len += 7;
				k_time = 0;
				if ( sp->dial_start_date ) {
					// 経過時間（分）
					k_time = (req36.date[i] - sp->dial_start_date) / 60;
					if ( k_time < 0 ) k_time = 0;
				}
				short_set(dp, k_time);
				dp += 2; len += 2;
				comsv_lcd_memcpy(dp, req36.message[i], 20);
				dp += 20; len += 20;
			}
			break;

		case 37:	// 終了予定
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 start
			//if ( sp->cond_send_flg == 0 ) {
			if ( alive_flg || sp->cond_send_flg == 0 ) {
				// 通信断 or 条件未送信
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 end
				memcpy(dp, buf, 20);
				dp += 20; len += 20;
				break;
			}
			if ( sp->dial_start_date ) {
				// 透析中の場合
				// 透析開始日時
				time_bcd(sp->dial_start_date, wrk);
				memcpy(dp, wrk, 7);
				dp += 7; len += 7;
				// 透析予定時間
				short_set(dp, sp->dial_time);
				dp += 2; len += 2;
				// 遅れ時間計算
				memcpy(mon_dat, packetInfoList[thread_no].cMoniData + 14, 8);
				k_time = hl_chg( *(short*)(mon_dat) );		// 経過時間
				n_time1 = hl_chg( *(short*)(mon_dat + 4) );	// 残り時間（除水完了）
				n_time2 = hl_chg( *(short*)(mon_dat + 6) );	// 残り時間（透析完了）
				if ( n_time1 < n_time2 ) {
					n_time1 = n_time2;
				}
				o_time = 0;
				if ( n_time1 >= 0 && n_time1 < 1440 ) {
					o_time = n_time1;
				}
				if ( k_time >= 0 && k_time < 1440 ) {
					o_time += k_time;
				}
				o_time -= sp->dial_time;
				if ( o_time < 0 ) {
					o_time = 0;
				}
				// 終了予定日時（透析開始日時 + 透析予定時間 + 遅れ時間）
				time_bcd(sp->dial_start_date + (long)(sp->dial_time * 60) + (long)(o_time * 60), wrk);
				memcpy(dp, wrk, 7);
				dp += 7; len += 7;
				// 経過時間
				short_set(dp, k_time);
				dp += 2; len += 2;
				// 遅れ時間
				short_set(dp, o_time);
				dp += 2; len += 2;
			}
			else {
				// 透析前の場合
				time_bcd(sp->plan_start_date, wrk);
				memcpy(dp, wrk, 7);
				dp += 7; len += 7;
				short_set(dp, sp->dial_time);
				dp += 2; len += 2;
				time_bcd(sp->plan_end_date, wrk);
				memcpy(dp, wrk, 7);
				dp += 7; len += 7;
				short_set(dp, 0);
				dp += 2; len += 2;
				short_set(dp, 0);
				dp += 2; len += 2;
			}
			break;

		case 38:	// 体重（データ）
		case 39:	// 体重（グラフ）
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 start
			//if ( sp->cond_send_flg == 0 || sp->pat_id == 0 ) {
			if ( alive_flg || sp->cond_send_flg == 0 || sp->pat_id == 0 ) {
				// 通信断 or 条件未送信
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 end
				short_set(dp, 0);
				dp += 2; len += 2;
				break;
			}
			// 仮想端末（体重トレンド）読み込み
			LcddataReq38_t req38;
			comsv_work_fpath(sp->dev_no, WORK_LCD_REQ38, fpath);
			if ( configParam.lcdDataCash == 0 ) {
				// 仮想端末データキャッシュを使用しない
				ret = comsv_rest_get_lcd(sp->dev_no, sp->deviceType, sp->devid, 38, pat_str, fpath);
				printf("comsv_rest_get_lcd 38 = [%d]\n", ret);
			}
			ret = comsv_json_lcd_req38(fpath, &req38);
			printf("comsv_json_lcd_req38 = [%d]\n", ret);
			short_set(dp, req38.count);
			dp += 2; len += 2;
			for ( i = 0; i < req38.count; i++ ) {
				comsv_lcd_memcpy(dp, req38.date[i], 10);
				dp += 10; len += 10;
				if ( sp->lcd_request == 38 ) {
					short_set(dp, req38.pre_weight[i]);
					dp += 2; len += 2;
					short_set(dp, req38.bef_weight[i]);
					dp += 2; len += 2;
					short_set(dp, req38.gain[i]);
					dp += 2; len += 2;
					short_set(dp, req38.dw[i]);
					dp += 2; len += 2;
					short_set(dp, req38.aft_weight[i]);
					dp += 2; len += 2;
					short_set(dp, req38.loss[i]);
					dp += 2; len += 2;
				}
				else {
					short_set(dp, req38.bef_weight[i]);
					dp += 2; len += 2;
					short_set(dp, req38.aft_weight[i]);
					dp += 2; len += 2;
				}
			}
			break;

		case 40:	// 透析日報
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 start
			//if ( sp->cond_send_flg == 0 ) {
			if ( alive_flg || sp->cond_send_flg == 0 ) {
				// 通信断 or 条件未送信
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 end
				short_set(dp, 0);
				dp += 2; len += 2;
				break;
			}
			// 仮想端末（透析日報）読み込み
			LcddataReq40_t req40;
			comsv_work_fpath(sp->dev_no, WORK_LCD_REQ40, fpath);
			if ( configParam.lcdDataCash == 0 ) {
				// 仮想端末データキャッシュを使用しない
				ret = comsv_rest_get_lcd(sp->dev_no, sp->deviceType, sp->devid, 40, ord_str, fpath);
				printf("comsv_rest_get_lcd 40 = [%d]\n", ret);
			}
			ret = comsv_json_lcd_req40(fpath, thread_no, sp, &req40);
			printf("comsv_json_lcd_req40 = [%d] count = [%d]\n", ret, req40.count);
			short_set(dp, req40.count);
			dp += 2; len += 2;
			if ( req40.count <= 0 ) break;
			for ( i = 0; i < req40.count; i++ ) {
				comsv_lcd_memcpy(dp, req40.name[i], 16);
				dp += 16; len += 16;
				comsv_lcd_memcpy(dp, req40.data[i], 12);
				dp += 12; len += 12;
			}
			break;

		case 41:	// 投与薬剤
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 start
			//if ( sp->cond_send_flg == 0 ) {
			if ( alive_flg || sp->cond_send_flg == 0 ) {
				// 通信断 or 条件未送信
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 end
				short_set(dp, 0);
				dp += 2; len += 2;
				*dp++ = 0x00; len++;
				break;
			}
			// 仮想端末（投与薬剤）読み込み
			LcddataReq41_t req41;
			comsv_work_fpath(sp->dev_no, WORK_LCD_REQ41, fpath);
			if ( configParam.lcdDataCash == 0 ) {
				// 仮想端末データキャッシュを使用しない
				ret = comsv_rest_get_lcd(sp->dev_no, sp->deviceType, sp->devid, 41, ord_str, fpath);
				printf("comsv_rest_get_lcd 41 = [%d]\n", ret);
			}
			ret = comsv_json_lcd_req41(fpath, &req41);
			printf("comsv_json_lcd_req41 = [%d] count = [%d]\n", ret, req41.count);
			short_set(dp, req41.count);
			dp += 2; len += 2;
            // mod FNSI-バグ 通信サーバ 高 start
            // if ( _comsvCache._comsvSet.is_lcd_medi == '0' ) {
			if ( _comsvCache._comsvSet.lcd_medi_time == '0' ) {
				// 仮想端末投与時間（時刻）
				*dp++ = 0x00;
			}
			else {
				// 仮想端末投与時間（経過時間）
				*dp++ = 0x01;
			}
            // mod FNSI-バグ 通信サーバ 高 end
            
            sprintf(str1, "[gs debug] lcdDataCash = %d, lcd_medi_time = %c, is_lcd_medi = %c, sp->dial_start_date = %ld", 
                        configParam.lcdDataCash, _comsvCache._comsvSet.lcd_medi_time, _comsvCache._comsvSet.is_lcd_medi, sp->dial_start_date);
            LogOutputs(NTSS_LOG_INFO, str1, 0, sp->deviceType, sp->devid);
                
			len++;
			if ( req41.count <= 0 ) break;
			for ( i = 0; i < req41.count; i++ ) {
				k = 0;
				memset(wrk, 0x99, 7);
				if ( req41.time[i] ) {
					time_bcd(req41.time[i], wrk);
					if ( sp->dial_start_date ) {
						k = req41.time[i] - sp->dial_start_date;
						if ( k < 0 ) k = 0;
						else {
							k /= 60;	// 経過時間（分）
						}
					}
				}
				// mod 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 start
                // else if ( req41.alert_time[i] < 0 ) {
				else {
                    if ( req41.alert[i] != '1') {
    					// 通知フラグはしない。
    					wrk[5] = 0x89;
                    }
				}
				// add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 end
                memcpy(dp, wrk+4, 3);
				dp += 3; len += 3;
				short_set(dp, k);
				dp += 2; len += 2;
                // mod FNSI-バグ 通信サーバ 高 start
                // comsv_lcd_memcpy(dp, req41.name[i], 28);
                memset(sjis, 0, sizeof(sjis));
                memset(t_uname, '\0', sizeof(t_uname));
                if ( _comsvCache._comsvSet.is_lcd_medi == '0' ) {
                    // 仮想端末投与時間帯表示を無効
                    comsv_lcd_memcpy(dp, req41.name[i], 28);
                }
                else {
                    // 仮想端末投与時間帯表示を有効
                    if(memcmp(req41.progress[i], "001", 3) == 0) {
                        // 透析前
                        utf8tosjis("[前]", sjis);
                        strcpy(t_uname, sjis);
                        memcpy(t_uname + strlen(sjis), req41.name[i], 28);
                        comsv_lcd_memcpy(dp, t_uname, 28);
                    }
                    else if(memcmp(req41.progress[i], "002", 3) == 0) {
                        // 透析中
                        utf8tosjis("[中]", sjis);
                        strcpy(t_uname, sjis);
                        memcpy(t_uname + strlen(sjis), req41.name[i], 28);
                        comsv_lcd_memcpy(dp, t_uname, 28);
                    }
                    else if(memcmp(req41.progress[i], "003", 3) == 0) {
                        // 透析後
                        utf8tosjis("[後]", sjis);
                        strcpy(t_uname, sjis);
                        memcpy(t_uname + strlen(sjis), req41.name[i], 28);
                        comsv_lcd_memcpy(dp, t_uname, 28);
                    }
                    else {
                        // その他
                        comsv_lcd_memcpy(dp, req41.name[i], 28);
                    }
                }
                // mod FNSI-バグ 通信サーバ 高 end
				dp += 28; len += 28;
				comsv_lcd_memcpy(dp, req41.amount[i], 8);
				dp += 8; len += 8;
				comsv_lcd_memcpy(dp, req41.unit[i], 8);
				dp += 8; len += 8;
			}
			sp->medi_effect_date = 0;
			break;

		case 42:	// 抗凝固剤
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 start
			//if ( sp->cond_send_flg == 0 ) {
			if ( alive_flg || sp->cond_send_flg == 0 ) {
				// 通信断 or 条件未送信
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 end
				memcpy(dp, buf, 56);
				dp += 56; len += 56;
				break;
			}
			// 仮想端末（抗凝固剤）読み込み
			LcddataReq42_t req42;
			comsv_work_fpath(sp->dev_no, WORK_LCD_REQ42, fpath);
			if ( configParam.lcdDataCash == 0 ) {
				// 仮想端末データキャッシュを使用しない
				ret = comsv_rest_get_lcd(sp->dev_no, sp->deviceType, sp->devid, 42, ord_str, fpath);
				printf("comsv_rest_get_lcd 42 = [%d]\n", ret);
			}
			ret = comsv_json_lcd_req42(fpath, &req42);
			printf("comsv_json_lcd_req42 = [%d]\n", ret);
			comsv_lcd_memcpy(dp, req42.name, 40);
			dp += 40; len += 40;
			comsv_lcd_memcpy(dp, req42.unit, 8);
			dp += 8; len += 8;
			sprintf(buf, "%8.2f", req42.value1);
			if ( strcmp(buf + 5, ".00") == 0 ) buf[5] = 0;
			else if ( buf[7] == '0' ) buf[7] = 0;
			sprintf(dp, "%8s", buf);
			dp += 8; len += 8;
			sprintf(buf, "%8.2f", req42.value3);
			if ( strcmp(buf + 5, ".00") == 0 ) buf[5] = 0;
			else if ( buf[7] == '0' ) buf[7] = 0;
			sprintf(dp, "%8s", buf);
			dp += 8; len += 8;
			sprintf(buf, "%8.2f", req42.value1 + req42.value3);
			if ( strcmp(buf + 5, ".00") == 0 ) buf[5] = 0;
			else if ( buf[7] == '0' ) buf[7] = 0;
			sprintf(dp, "%8s", buf);
			dp += 8; len += 8;
			sprintf(buf, "%8.2f", req42.value2);
			if ( strcmp(buf + 5, ".00") == 0 ) buf[5] = 0;
			else if ( buf[7] == '0' ) buf[7] = 0;
			sprintf(dp, "%8s", buf);
			dp += 8; len += 8;
			break;

		case 44:	// 禁忌
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 start
			//if ( sp->cond_send_flg == 0 || sp->pat_id == 0 ) {
			if ( alive_flg || sp->cond_send_flg == 0 || sp->pat_id == 0 ) {
				// 通信断 or 条件未送信
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 end
				short_set(dp, 0);
				dp += 2; len += 2;
				break;
			}
			// 仮想端末（禁忌）読み込み
			LcddataReq44_t req44;
			comsv_work_fpath(sp->dev_no, WORK_LCD_REQ44, fpath);
			if ( configParam.lcdDataCash == 0 ) {
				// 仮想端末データキャッシュを使用しない
				ret = comsv_rest_get_lcd(sp->dev_no, sp->deviceType, sp->devid, 44, pat_str, fpath);
				printf("comsv_rest_get_lcd 44 = [%d]\n", ret);
			}
			ret = comsv_json_lcd_req44(fpath, &req44);
			printf("comsv_json_lcd_req44 = [%d]\n", ret);
			short_set(dp, req44.count);
			dp += 2; len += 2;
			for ( i = 0; i < req44.count; i++ ) {
				comsv_lcd_memcpy(dp, req44.name[i], 40);
				dp += 40; len += 40;
			}
			break;

		case 45:	// メモ
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 start
			//if ( sp->cond_send_flg == 0 || sp->pat_id == 0 ) {
			if ( alive_flg || sp->cond_send_flg == 0 || sp->pat_id == 0 ) {
				// 通信断 or 条件未送信
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 end
				memset(buf, 0, sizeof(buf));
				memcpy(dp, buf, 500);
				dp += 500; len += 500;
				break;
			}
			// 仮想端末（メモ）読み込み
			LcddataReq45_t req45;
			comsv_work_fpath(sp->dev_no, WORK_LCD_REQ45, fpath);
			if ( configParam.lcdDataCash == 0 ) {
				// 仮想端末データキャッシュを使用しない
				ret = comsv_rest_get_lcd(sp->dev_no, sp->deviceType, sp->devid, 45, pat_str, fpath);
				printf("comsv_rest_get_lcd 45 = [%d]\n", ret);
			}
			ret = comsv_json_lcd_req45(fpath, &req45);
			printf("comsv_json_lcd_req45 = [%d]\n", ret);
			memcpy(buf, req45.memo, sizeof(req45.memo));
			memset(wrk, ' ', sizeof(wrk));
			for ( i = 0, j = 0, po = 0; i < 500; i++ ) {
				if ( buf[i] == '\n' || (buf[i] == '\r' && buf[i+1] == '\n') ) {
					for ( k = po; k < 40; k++ ) {
						wrk[j] = 0x20;
						j++;
						if ( j > 500 ) {
							i = 500;
							break;
						}
					}
					po = 0;
					if ( buf[i] != '\n' ) {
						i++;
					}
					continue;
				}
				else if ( buf[i] == 0 || buf[i] == '\r' ) {
					wrk[j] = 0x20;
				}
				else {
					wrk[j] = buf[i];
					// 100NX装置で行の最後が全角1バイト目になると文字化けする対策
					if ( ((j+1)%40) == 0 || j == 499 ) {
						if ( comsv_lcd_knjichk((unsigned char *)wrk, j) == 1 ) {
							wrk[j] = 0x20;
							i--;
						}
					}
				}
				j++;
				po++;
				if ( j > 500 ) {
					i = 500;
					break;
				}
				if ( po >= 40 ) po = 0;
			}
			comsv_lcd_memcpy(dp, wrk, 500);
			dp += 500; len += 500;
			break;

		case 46:	// 検査グラフ　１～５
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 start
			//if ( sp->cond_send_flg == 0 ) {
			if ( alive_flg || sp->cond_send_flg == 0 ) {
				// 通信断 or 条件未送信
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 end
				short_set(dp, 0);
				dp += 2; len += 2;	
				memcpy(dp, buf, 10);
				dp += 10; len += 10;
				short_set(dp, 0);
				dp += 2; len += 2;	
				short_set(dp, 0);
				dp += 2; len += 2;
				break;
			}
			// 仮想端末（検査結果）読み込み
			LcddataReq46_t req46;
			comsv_work_fpath(sp->dev_no, WORK_LCD_REQ33, fpath);
			if ( configParam.lcdDataCash == 0 ) {
				// 仮想端末データキャッシュを使用しない
				ret = comsv_rest_get_lcd(sp->dev_no, sp->deviceType, sp->devid, 33, pat_str, fpath);
				printf("comsv_rest_get_lcd 33 = [%d]\n", ret);
			}
			ret = comsv_json_lcd_req46(fpath, sp->lcd_argument1, sp->lcd_argument2, &req46);
			printf("comsv_json_lcd_req46 = [%d]\n", ret);
			if ( ret <= 0 ) ret = 0;
			short_set(dp, ret);	// 検査件数
			dp += 2; len += 2;
			if ( ret == 0 ) {
				memcpy(dp, buf, 10);
				dp += 10; len += 10;
				short_set(dp, 0);
				dp += 2; len += 2;	
				short_set(dp, 0);
				dp += 2; len += 2;
				break;
			}
			time_str(req46.date, dt, tm, 1);
			memcpy(dp, dt, 10);
			dp+=10; len+=10;
			short_set(dp, req46.class);
			dp+=2; len+=2;
			short_set(dp, req46.count);
			dp+=2; len+=2;
			for ( i = 0; i < req46.count; i++ ) {
				comsv_lcd_memcpy(dp, req46.item_name[i], 20);
				dp+=20; len+=20;
				comsv_lcd_memcpy(dp, req46.item_unit[i], 8);
				dp+=8; len+=8;
				short_set(dp, req46.item_dec[i]);
				dp+=2; len+=2;
				value = long_chg(req46.item_upper[i]);
				memcpy(dp, &value, 4);
				dp+=4; len+=4;
				value = long_chg(req46.item_lower[i]);
				memcpy(dp, &value, 4);
				dp+=4; len+=4;
				for ( j = 0; j < ret; j++ ) {
					if ( j >= REQ46_DATE_MAX ) break;
					value = long_chg(req46.item_data[i][j]);
					memcpy(dp, &value, 4);
					dp+=4; len+=4;
				}
			}
			break;

		case 47:	// レーダーチャート
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 start
			//if ( sp->cond_send_flg == 0 ) {
			if ( alive_flg || sp->cond_send_flg == 0 ) {
				// 通信断 or 条件未送信
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 end
				short_set(dp, 0);
				dp += 2; len += 2;
				memcpy(dp, buf, 10);
				dp += 10; len += 10;
				short_set(dp, 0);
				dp += 2; len += 2;	
				short_set(dp, 0);
				dp += 2; len += 2;	
				break;
			}
			// 仮想端末（検査結果）読み込み
			LcddataReq47_t req47;
			comsv_work_fpath(sp->dev_no, WORK_LCD_REQ33, fpath);
			if ( configParam.lcdDataCash == 0 ) {
				// 仮想端末データキャッシュを使用しない
				if ( sp->lcd_argument1 <= 1 ) {
					// 初回表示なら
					ret = comsv_rest_get_lcd(sp->dev_no, sp->deviceType, sp->devid, 33, pat_str, fpath);
					printf("comsv_rest_get_lcd 33 = [%d]\n", ret);
				}
			}
			po = sp->lcd_argument1;
			po--;
			if ( po < 0 ) po = 0;
			else if ( po >= REQ47_DATE_MAX ) po = REQ47_DATE_MAX - 1;
			ret = comsv_json_lcd_req47(fpath, po, &req47);
			printf("comsv_json_lcd_req47 = [%d]\n", ret);
			if ( ret <= 0 ) ret = 0;
			short_set(dp, ret);	// 検査件数
			dp += 2; len += 2;
			if ( ret == 0 ) {
				memcpy(dp, buf, 10);
				dp += 10; len += 10;
				short_set(dp, 0);
				dp += 2; len += 2;	
				short_set(dp, 0);
				dp += 2; len += 2;	
				break;
			}
			time_str(req47.date, dt, tm, 1);
			memcpy(dp, dt, 10);
			dp+=10; len+=10;
			short_set(dp, req47.class);
			dp+=2; len+=2;
			short_set(dp, req47.count);
			dp+=2; len+=2;
			for ( i = 0; i < req47.count; i++ ) {
				if ( i >= REQ47_MAX ) break;
				comsv_lcd_memcpy(dp, req47.item_name[i], 20);
				dp+=20; len+=20;
				comsv_lcd_memcpy(dp, req47.item_unit[i], 8);
				dp+=8; len+=8;
				short_set(dp, req47.item_dec[i]);
				dp+=2; len+=2;
				value = long_chg(req47.item_upper[i]);
				memcpy(dp, &value, 4);
				dp+=4; len+=4;
				value = long_chg(req47.item_lower[i]);
				memcpy(dp, &value, 4);
				dp+=4; len+=4;
				value = long_chg(req47.item_data[i]);
				memcpy(dp, &value, 4);
				dp+=4; len+=4;
			}
			break;

		case 50:	//	愁訴／処置
            // #11157 2024.11.01 add DE切断時の仮想端末サポート TDC高村 start
			if ( alive_flg ) {
                // 通信断
                len = sp->lcd_argument2 * 20 * 2;
				memset(buf, ' ', len);
				memcpy(dp, buf, len);
                dp += len; 
                break;
            }
            // #11157 2024.11.01 add DE切断時の仮想端末サポート TDC高村 end
			j = sp->lcd_argument1;
			j--;
			if ( j < 0 ) j = 0;
			j *= sp->lcd_argument2;
			for ( i = j; i < j+sp->lcd_argument2; i++ ) {
				comsv_lcd_memcpy(dp, _comsvCache._lcdReq50.c_name[i], 20);
				dp += 20; len += 20;
			}
			for ( i = j; i < j+sp->lcd_argument2; i++ ) {
				comsv_lcd_memcpy(dp, _comsvCache._lcdReq50.t_name[i], 20);
				dp += 20; len += 20;
			}
			break;

		case 51:	// 穿刺／回収／担当
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 start
			//if ( sp->cond_send_flg == 0 ) {
			if ( alive_flg || sp->cond_send_flg == 0 ) {
				// 通信断 or 条件未送信
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 end
				memcpy(dp, buf, 138);
				dp += 138; len += 138;
				break;
			}
			// 仮想端末（穿刺／回収／担当）読み込み
			LcddataReq51_t req51;
			comsv_work_fpath(sp->dev_no, WORK_LCD_REQ51, fpath);
			if ( configParam.lcdDataCash == 0 ) {
				// 仮想端末データキャッシュを使用しない
				ret = comsv_rest_get_lcd(sp->dev_no, sp->deviceType, sp->devid, 51, ord_str, fpath);
				printf("comsv_rest_get_lcd 51 = [%d]\n", ret);
			}
			ret = comsv_json_lcd_req51(fpath, &req51);
			printf("comsv_json_lcd_req51 = [%d]\n", ret);
			time_bcd(req51.p_time[0], wrk);
			memcpy(dp, wrk+4, 3);
			dp += 3; len += 3;
			comsv_lcd_memcpy(dp, req51.p_name[0], 20);
			dp += 20; len += 20;
			time_bcd(req51.p_time[1], wrk);
			memcpy(dp, wrk+4, 3);
			dp += 3; len += 3;
			comsv_lcd_memcpy(dp, req51.p_name[1], 20);
			dp += 20; len += 20;
			time_bcd(req51.r_time[0], wrk);
			memcpy(dp, wrk+4, 3);
			dp += 3; len += 3;
			comsv_lcd_memcpy(dp, req51.r_name[0], 20);
			dp += 20; len += 20;
			time_bcd(req51.r_time[1], wrk);
			memcpy(dp, wrk+4, 3);
			dp += 3; len += 3;
			comsv_lcd_memcpy(dp, req51.r_name[1], 20);
			dp += 20; len += 20;
			time_bcd(req51.c_time[0], wrk);
			memcpy(dp, wrk+4, 3);
			dp += 3; len += 3;
			comsv_lcd_memcpy(dp, req51.c_name[0], 20);
			dp += 20; len += 20;
			time_bcd(req51.c_time[1], wrk);
			memcpy(dp, wrk+4, 3);
			dp += 3; len += 3;
			comsv_lcd_memcpy(dp, req51.c_name[1], 20);
			dp += 20; len += 20;
			break;

		case 52:	// 指示／特記
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 start
			//if ( sp->cond_send_flg == 0 || sp->pat_id == 0 ) {
			if ( alive_flg || sp->cond_send_flg == 0 || sp->pat_id == 0 ) {
				// 通信断 or 条件未送信
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 end
				short_set(dp, 0);
				dp += 2; len += 2;
				break;
			}
			// 仮想端末（指示／特記）読み込み
			LcddataReq52_t req52;
			comsv_work_fpath(sp->dev_no, WORK_LCD_REQ52, fpath);
			if ( configParam.lcdDataCash == 0 ) {
				// 仮想端末データキャッシュを使用しない
				ret = comsv_rest_get_lcd(sp->dev_no, sp->deviceType, sp->devid, 52, ord_str, fpath);
				printf("comsv_rest_get_lcd 52 = [%d]\n", ret);
				// ret = comsv_json_lcd_req52(fpath, &req52, sp->lcd_argument1);
			}
			comsv_work_fpath(sp->dev_no, WORK_LCD_REQ44, fpath_ex);
			if ( configParam.lcdDataCash == 0 ) {
				// 仮想端末データキャッシュを使用しない
				ret = comsv_rest_get_lcd(sp->dev_no, sp->deviceType, sp->devid, 44, pat_str, fpath_ex);
				printf("comsv_rest_get_lcd 44 = [%d]\n", ret);
			}
			ret = comsv_json_lcd_req52_ex(fpath, fpath_ex, &req52, sp->lcd_argument1);
			printf("req52.count = [%d]\n", req52.count);
			printf("comsv_json_lcd_req52 = [%d]\n", ret);
			short_set(dp, req52.count);
			dp += 2; len += 2;
			if ( req52.count <= 0 ) break;
			comsv_lcd_memcpy(dp, req52.comment, 400);
			dp += 400; len += 400;
			break;

		case 53:	// ＣＴＲトレンド
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 start
			//if ( sp->cond_send_flg == 0 || sp->pat_id == 0 ) {
			if ( alive_flg || sp->cond_send_flg == 0 || sp->pat_id == 0 ) {
				// 通信断 or 条件未送信
            // #11157 2024.11.01 mod DE切断時の仮想端末サポート TDC高村 end
				short_set(dp, 0);
				dp += 2; len += 2;
				break;
			}
			// 仮想端末（ＣＴＲトレンド）読み込み
			LcddataReq53_t req53;
			comsv_work_fpath(sp->dev_no, WORK_LCD_REQ53, fpath);
            // #11175 2024.10.18 mod 仮想端末のCTRトレンド画面のデータが正しく送信されない TDC高村 start
			//if ( configParam.lcdDataCash == 0 ) {
			// 	  // 仮想端末データキャッシュを使用しない
			j = sp->lcd_argument1;
			j--;
			if ( j < 0 ) j = 0;
			if ( configParam.lcdDataCash == 0 && j == 0 ) {
			    // 仮想端末データキャッシュを使用しない and １ページ目
            // #11175 2024.10.18 mod 仮想端末のCTRトレンド画面のデータが正しく送信されない TDC高村 end
				ret = comsv_rest_get_lcd(sp->dev_no, sp->deviceType, sp->devid, 53, pat_str, fpath);
				printf("comsv_rest_get_lcd 53 = [%d]\n", ret);
			}
			ret = comsv_json_lcd_req53(fpath, &req53);
			printf("comsv_json_lcd_req53 = [%d]\n", ret);
			short_set(dp, req53.count);
			dp += 2; len += 2;
            // #11175 2024.10.18 mod 仮想端末のCTRトレンド画面のデータが正しく送信されない TDC高村 start
			//for ( i=0; i<req53.count; i++ ) {
			j *= sp->lcd_argument2;
			for ( i = j; i < j+sp->lcd_argument2; i++ ) {
            // #11175 2024.10.18 mod 仮想端末のCTRトレンド画面のデータが正しく送信されない TDC高村 end
				comsv_lcd_memcpy(dp, req53.date[i], 10);
				dp += 10; len += 10;
				short_set(dp, req53.ctr[i]);
				dp += 2; len += 2;
				short_set(dp, req53.ctr_weight[i]);
				dp += 2; len += 2;
			}
			break;

		case 54:	// チェックリスト
            // #11157 2024.11.01 add DE切断時の仮想端末サポート TDC高村 start
			if ( alive_flg ) {
				// 通信断
				short_set(dp, 0);
				dp += 2; len += 2;
				short_set(dp, 0);
				dp += 2; len += 2;
				break;
			}
            // #11157 2024.11.01 add DE切断時の仮想端末サポート TDC高村 end
			if ( sp->cond_send_flg == 0 ) {
				// 条件未送信
				sprintf(ord_str, "%ld", sp->next_ord_no);
			}
			po = sp->lcd_argument1;
			if ( po < 1 || po > REQ54_NO_MAX ) po = 1;
			i = j = 0;
			k = _comsvCache._checkMst.list_time[po - 1];
			if ( k == 0 && (sp->mon_sta & 1) ) {
				// 入力タイミングが透析前で装置が運転中の場合
				j = 1;
			}
			else if ( k == 0 && sp->dial_end_date ) {
				// 入力タイミングが透析前で透析終了時刻が既にある場合
				j = 2;
			}
            // mod FNSI-バグ 通信サーバ #10310 高 start
			// else if ( k && (sp->cond_send_flg == 0 || sp->pat_id == 0) ) {
            else if ( k && sp->cond_send_flg == 0 ) {
            // mod FNSI-バグ 通信サーバ #10310 高 end
				// 入力タイミングが透析前以外で条件未送信又は患者未登録の場合
				j = 3;
			}
			else if ( k && !(sp->mon_sta & 1) && sp->dial_end_date == 0 ) {
				// 入力タイミングが透析前以外で運転中以外かつ透析終了時刻なしの場合
				j = 4;
			}
			if ( j != 0 ) {
				short_set( dp, i );
				dp += 2; len += 2;
				short_set( dp, j );
				dp += 2; len += 2;
				break;
			}
			// 仮想端末（チェックリスト）読み込み
			//add redmine bug# 5919 劉 start
			cd = _comsvCache._checkMst.list_cd[po - 1];
			//add redmine bug# 5919 劉 end
			LcddataReq54_t req54;
			sprintf(wrk, "%s", WORK_LCD_REQ54);
			//mod redmine bug# 5919 劉 start
			//sprintf(buf, wrk, po);
			sprintf(buf, wrk, cd);
			//mod redmine bug# 5919 劉 end
			comsv_work_fpath(sp->dev_no, buf, fpath);
			if ( configParam.lcdDataCash == 0 ) {
				// 仮想端末データキャッシュを使用しない
				//mod redmine bug# 5919 劉 start
				//sprintf(buf, "%d\t%s\t%d", 0 + sp->cond_send_flg, ord_str, po);
				sprintf(buf, "%d\t%s\t%d", 0 + sp->cond_send_flg, ord_str, cd);
				ret = comsv_rest_get_lcd(sp->dev_no, sp->deviceType, sp->devid, 54, buf, fpath);
				printf("comsv_rest_get_lcd 54 no%d = [%d]\n", cd, ret);
				//printf("comsv_rest_get_lcd 54 no%d = [%d]\n", po, ret);
				//mod redmine bug# 5919 劉 end
			}
			ret = comsv_json_lcd_req54(fpath, &req54);
			//mod redmine bug# 5919 劉 start
			//printf("comsv_json_lcd_req54 no%d = [%d]\n", po, ret);
			printf("comsv_json_lcd_req54 no%d = [%d]\n", cd, ret);
			//mod redmine bug# 5919 劉 end
			short_set(dp, req54.count);
			dp += 2; len += 2;
			short_set(dp, j);
			dp += 2; len += 2;
			if ( req54.count == 0 ) break; 
			for ( i=0; i<REQ54_MAX; i++ ) {
				if ( req54.chk_time[i] ) {
					time_bcd(req54.chk_time[i], wrk);
					memcpy(dp, wrk+4, 3);
				}
				else {
					memset(wrk, 0x99, 3);
					memcpy(dp, wrk, 3);
				}
				dp += 3; len += 3;
				if ( req54.chk_name[i][0] ) {
					comsv_lcd_memcpy(dp, req54.chk_name[i], 20);
				}
				else {
					memcpy(dp, req54.chk_name[i], 20);
				}
				dp += 20; len += 20;
			}
			break;

		case 49:	// メニュー
		case 55:	// レポート画像転送（当日レポート）
		case 56:	// レポート画像転送（過去レポート）
            sprintf(buf, "通信スレッドNEW[%d] : メニュー sp->lcd_request = %d, sp->lcd_argument1 = %d", thread_no, sp->lcd_request, sp->lcd_argument1);
            LogOutputs(NTSS_LOG_INFO, buf, 0, sp->deviceType, sp->devid);
            // #11157 2024.11.01 add DE切断時の仮想端末サポート TDC高村 start
			if ( alive_flg ) {
                // 通信断
    			if ( sp->lcd_request != 56 ) {
				    memset(buf, ' ', sizeof(buf));
                    for ( i=0; i<4; i++ ) {
				        memcpy(dp, buf, 6);
                        dp += 6; len += 6;
                    }
                    memset(buf, 0, sizeof(buf));
                    for ( i = 0; i < 4; i++ ) {
                        for ( j = 0; j < 8; j++ ) {
                            short_set(dp, 0);
				            dp += 2; len += 2;
    				        memcpy(dp, buf, 12);
                            dp += 12; len += 12;
                        }
                    }
                } 
                break;
            }
            // add FNSI-バグ 通信サーバ 高 start
            // 現在日時時刻取得(マイクロ秒含む)
            // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
            //gettimeofday( &now, NULL );
            clock_gettime(CLOCK_REALTIME, &now);
            // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
            
            // #11378 2024.12.24 del 仮想端末の画面表示不正 TDC高村 start
            /*
            if(sp->lcd_request == 55) {
                if((sp->last_disp_time + 3 ) >= now.tv_sec){
                    sp->last_disp_time = now.tv_sec;
                    break;
                }
                sp->last_disp_time = now.tv_sec;
            }
            */
            // #11378 2024.12.24 del 仮想端末の画面表示不正 TDC高村 end
           if(sp->lcd_request == 56) {
				// #11478 2026.05.15 del リクエストコード56が前回から3秒以下の場合でも透析レポート画像のFTP転送を行うようにする TDC米沢 start
                // if(sp->last_lcd_argument1 == sp->lcd_argument1 && (sp->last_disp_time + 3 ) >= now.tv_sec) {
                //     sp->last_disp_time = now.tv_sec;
                //     break;
                // }
				// #11478 2026.05.15 del リクエストコード56が前回から3秒以下の場合でも透析レポート画像のFTP転送を行うようにする TDC米沢 end
                sp->last_lcd_argument1 = sp->lcd_argument1;
                sp->last_disp_time = now.tv_sec;
            }
            // add FNSI-バグ 通信サーバ 高 end
			if ( sp->lcd_request != 56 ) {
                // #11157 2024.10.13 mod DE切断時の仮想端末サポート TDC高村 start
                /*
                // add AWSとDEの通信断からの復旧 高 start
                if ( getCommAliveState() != 0 && sp->lcd_request == 49) {
                }
                else {
                // add AWSとDEの通信断からの復旧 高 end
				// メニュー
				// タイトル
				for ( i=0; i<4; i++ ) {
					comsv_lcd_memcpy(dp, _comsvCache._comsvSet.lcd_menu[i].title, 6);
					dp += 6; len += 6;
				}
				// 項目
				for ( i = 0; i < 4; i++ ) {
					for ( j = 0; j < 8; j++ ) {
						memset(buf, 0, sizeof(buf));
						k = _comsvCache._comsvSet.lcd_menu[i].no[j];
						if ( k >= 14 && k <= 18 ) {
							// 検査グラフ１
							memcpy(buf, _comsvCache._comsvSet.lcd_graph1[k - 14].name, 10);
							if ( _comsvCache._comsvSet.lcd_graph1[k - 14].name[0] == 0 ) k = 0;
						}
						else if ( k >= 20 && k <= 24 ) {
							// 検査グラフ２
							memcpy(buf, _comsvCache._comsvSet.lcd_graph2[k - 20].name, 10);
							if ( _comsvCache._comsvSet.lcd_graph2[k - 20].name[0] == 0 ) k = 0;
						}
						else if ( k >= 28 && k <= 35 ) {
							// チェックリスト
							memcpy(buf, _comsvCache._checkMst.list_name[k - 28], 12);
							if ( _comsvCache._checkMst.list_name[k - 28][0] == 0 ) k = 0;
						}
						else {
							// その他
							memcpy(buf, _comsvCache._comsvSet.lcd_menu[i].name[j], 12);
							if ( _comsvCache._comsvSet.lcd_menu[i].name[j][0] == 0 ) k = 0;
						}
						short_set(dp, k);
						dp += 2; len += 2;
						comsv_lcd_memcpy(dp, buf, 12);
						dp+=12; len+=12;
    					}
					}
				}
                */
				// メニュー
				// タイトル
				for ( i=0; i<4; i++ ) {
					comsv_lcd_memcpy(dp, _comsvCache._comsvSet.lcd_menu[i].title, 6);
					dp += 6; len += 6;
				}
				// 項目
				for ( i = 0; i < 4; i++ ) {
					for ( j = 0; j < 8; j++ ) {
						memset(buf, 0, sizeof(buf));
						k = _comsvCache._comsvSet.lcd_menu[i].no[j];
						if ( k >= 14 && k <= 18 ) {
							// 検査グラフ１
							memcpy(buf, _comsvCache._comsvSet.lcd_graph1[k - 14].name, 10);
							if ( _comsvCache._comsvSet.lcd_graph1[k - 14].name[0] == 0 ) k = 0;
						}
						else if ( k >= 20 && k <= 24 ) {
							// 検査グラフ２
							memcpy(buf, _comsvCache._comsvSet.lcd_graph2[k - 20].name, 10);
							if ( _comsvCache._comsvSet.lcd_graph2[k - 20].name[0] == 0 ) k = 0;
						}
						else if ( k >= 28 && k <= 35 ) {
							// チェックリスト
							memcpy(buf, _comsvCache._checkMst.list_name[k - 28], 12);
							if ( _comsvCache._checkMst.list_name[k - 28][0] == 0 ) k = 0;
						}
						else {
							// その他
							memcpy(buf, _comsvCache._comsvSet.lcd_menu[i].name[j], 12);
							if ( _comsvCache._comsvSet.lcd_menu[i].name[j][0] == 0 ) k = 0;
						}
						short_set(dp, k);
						dp += 2; len += 2;
						comsv_lcd_memcpy(dp, buf, 12);
						dp+=12; len+=12;
					}
				}
                // #11157 2024.10.13 mod DE切断時の仮想端末サポート TDC高村 end
				if ( sp->lcd_request == 49 ) break;
				// #11478 2026.05.15 del リクエストコード55が前回から3秒以下の場合でも透析レポート画像のFTP転送を行うようにする TDC米沢 start
                // // #11378 2024.12.24 add 仮想端末の画面表示不正 TDC高村 start
                // if((sp->last_disp_time + 3 ) >= now.tv_sec){
                //     sp->last_disp_time = now.tv_sec;
                //     break;
                // }
                // sp->last_disp_time = now.tv_sec;
                // // #11378 2024.12.24 add 仮想端末の画面表示不正 TDC高村 end
				// #11478 2026.05.15 del リクエストコード55が前回から3秒以下の場合でも透析レポート画像のFTP転送を行うようにする TDC米沢 end
			}
			if ( sp->cond_send_flg ) {
				// 条件送信済
				if ( sp->lcd_request == 56 && sp->lcd_argument2 != 0 ) {
					sprintf(buf, "通信スレッドNEW[%d] : レポート画像転送（過去レポート）中断要求", thread_no);
					LogOutputs(NTSS_LOG_INFO, buf, 0, sp->deviceType, sp->devid);
					break;
				}
				// #11478 2026.05.15 mod ログ内容が間違っているので修正 TDC米沢 start
                // sprintf(buf, "通信スレッドNEW[%d] : レポート画像転送（過去レポート）sp->lcd_request = %d, sp->lcd_argument1 = %d", thread_no, sp->lcd_request, sp->lcd_argument1);
                sprintf(buf, "通信スレッドNEW[%d] : レポート画像転送 sp->lcd_request = %d, sp->lcd_argument1 = %d", thread_no, sp->lcd_request, sp->lcd_argument1);
				// #11478 2026.05.15 mod ログ内容が間違っているので修正 TDC米沢 end
                LogOutputs(NTSS_LOG_INFO, buf, 0, sp->deviceType, sp->devid);
				// スレッド属性オブジェクトの初期化
				pthread_attr_init(&thread_attr);
				// スレッド切り離し状態属性の設定
				pthread_attr_setdetachstate(&thread_attr, PTHREAD_CREATE_DETACHED);
				if ( sp->lcd_request == 55 || (sp->lcd_request == 56 && sp->lcd_argument1 == 0) ) {
					// 当日レポート
					// #11478 2026.05.15 mod リクエストコード55が前回から3秒以下の場合でも透析レポート画像のFTP転送を行うようにする TDC米沢 start
					// // 当日レポート画像転送のスレッド処理
					// pthread_create(&thr_bmp, &thread_attr, comsv_thread_report_today, sp);
					// 前回要求から3秒以内かどうか
					if((sp->last_disp_time + 3 ) >= now.tv_sec){
						// 3秒以内の場合
						// 当日レポート画像転送のスレッド処理
						pthread_create(&thr_bmp, &thread_attr, comsv_thread_report_today_ftp, sp);
					} else {
						// 3秒を超える場合
						// 当日レポート画像の取得、転送のスレッド処理
						pthread_create(&thr_bmp, &thread_attr, comsv_thread_report_today, sp);
					}
					sp->last_disp_time = now.tv_sec;
					// #11478 2026.05.15 mod リクエストコード55が前回から3秒以下の場合でも透析レポート画像のFTP転送を行うようにする TDC米沢 end
				}
				else {
                    // add FNSI-バグ 通信サーバ 高 start
                    if ( sp->pat_id == 0 ) {
                        break;
                    }
                    // add FNSI-バグ 通信サーバ 高 end
					if ( sp->lcd_argument1 == 1 ) {
						// 過去直近３回レポート
						// 直近レポート画像転送のスレッド処理
						pthread_create(&thr_bmp, &thread_attr, comsv_thread_report_latest, sp);
					}
					else {
						// 過去同曜日３回レポート
						// 同一曜日レポート画像転送のスレッド処理
						pthread_create(&thr_bmp, &thread_attr, comsv_thread_report_sameday, sp);
					}
				}
			}
			break;

	}

    // #12301 2025.10.28 del 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 start
    // if ( len && sp->ftp_clear_flg == 2 ) {
	//     // 後体重測定後、LCD初回操作時に処理
	//     // FTP画像削除フラグ
	//     sp->ftp_clear_flg = 0;
	//     // 画像データ削除
	//     sp->reqflg[C_DELETE] = 1;
	// }
    // #12301 2025.10.28 del 画像データ削除コマンド(EF)の送信タイミング見直し TDC高村 end

	return(len);
}

/**
* @fn int comsv_lcd_knjichk(unsigned char *data, int p)
* @brief 漢字チェック(シフトJIS)
* @param[in] data チェック対象文字列
* @param[in] p チェック位置
* @return int タイプ（0:ANK,1:漢字1バイト目,2:漢字2バイト目）
* @details 文字列の指定位置のコードタイプを取得
*/
int comsv_lcd_knjichk(unsigned char *data, int p)
{
	unsigned char dc;
	int i,ret;

	ret = 0;
	for ( i = 0; i <= p; ) {
		dc = data[i];
		if ( (dc >= 0x80 && dc <= 0x9f) || dc >= 0xe0 ) i += 2;
		else i++;
	}
	if ( i > p + 1 ) ret = 1;
	else if ( p > 0 ) {
		dc = data[p - 1];
		if ( (dc >= 0x80 && dc <= 0x9f) || dc >= 0xe0 ) ret = 2;
		else ret = 0;
	}
	else ret = 0;

	return(ret);
}

/**
* @fn int comsv_lcd_memcpy(char *buff, char *data, int len)
* @brief lcd表示用データ作成
* @param[out] buff 作成データ
* @param[in] data コピー元データ
* @param[in] len 長さ
* @return int タイプ（1:漢字1バイト目,0:その他）
* @details lcd表示用のデータ作成（漢字チェックあり）
*/
int comsv_lcd_memcpy(char *buff, char *data, int len)
{
	int i, n, ret;
	char wrk[512];

	ret = 0;
	memset(wrk, 0, sizeof(wrk));
	memcpy(wrk, data, len);
	n = strlen( wrk );
	if ( n > 0 ) {
		for ( i = n; i < len; i++ ) wrk[i] = ' ';
		if ( comsv_lcd_knjichk(wrk, len-1) == 1 ) {
			wrk[len-1] = 0x20;
			ret = 1;
		}
		memcpy(buff, wrk, len);
	}
	else memset(buff, ' ', len);
	
	return(ret);
}

/**
* @fn short comsv_lcd_strshort(char *buf, short dp)
* @brief 文字列から数値変換
* @param[in] buf 文字列データ
* @param[in] dp 小数点以下桁数
* @return short 変換した数値
* @details 文字列から数値に変換（'0'～'9','.'以外を除去、'-'の場合はマイナス値）
*/
short comsv_lcd_strshort(char *buf, short dp)
{
	int i, j;
	int flg, flg2;
	short value;
	double dval;
	double dnum;
	char wrk[256];

	memset(wrk, 0x00, sizeof(wrk));
	for ( i = 0, dnum = 1.0; i < dp; i++ ) {
		dnum *= 10.0;
	}

	for ( i = 0, j = 0, flg = 0, flg2 = 0; i < (int)strlen(buf); i++ ) {
		if ( i >= 256 || j >= 256 ) break;
		if ( buf[i] >= '0' && buf[i] <= '9' ) {
			wrk[j++] = buf[i];
		}
		else if ( buf[i] == '.' ) {
			if ( flg == 0 ) {
				wrk[j++] = buf[i];
			}
			flg++;
		}
		else if ( buf[i] == '-' ) {
			flg2++;
		}
	}

	if ( wrk == 0 ) {
		value = 0;
	}
	else {
		dval = atof(wrk);
		if ( dp > 0 ) {
			dval *= dnum;
		}
		sprintf(wrk,"%f",dval);
		dval = atof(wrk);
		value = (short)(ceil(dval));	//	小数点以下切り上げ
		if ( flg2 > 0 ) {
			value = (short)(0 - value);
		}
	}
	return (value);
}

/**
* @fn long comsv_lcd_strlong(char *buf, short dp)
* @brief 文字列から数値変換
* @param[in] buf 文字列データ
* @param[in] dp 小数点以下桁数
* @return long 変換した数値
* @details 文字列から数値に変換（'0'～'9','.'以外を除去、'-'の場合はマイナス値）
*/
long comsv_lcd_strlong(char *buf, short dp)
{
	int i, j;
	int flg, flg2;
	long value;
	double dval;
	double dnum;
	char wrk[256];

	memset(wrk, 0x00, sizeof(wrk));
	for ( i = 0, dnum = 1.0; i < dp; i++ ) {
		dnum *= 10.0;
	}

	for ( i = 0, j = 0, flg = 0, flg2 = 0; i < (int)strlen(buf); i++ ) {
		if ( i >= 256 || j >= 256 ) break;
		if ( buf[i] >= '0' && buf[i] <= '9' ) {
			wrk[j++] = buf[i];
		}
		else if ( buf[i] == '.' ) {
			if ( flg == 0 ) {
				wrk[j++] = buf[i];
			}
			flg++;
		}
		else if ( buf[i] == '-' ) {
			flg2++;
		}
	}

	if ( wrk == 0 ) {
		value = 0;
	}
	else {
		dval = atof(wrk);
		if ( dp > 0 ) {
			dval *= dnum;
		}
		sprintf(wrk,"%f",dval);
		dval = atof(wrk);
		value = (long)(ceil(dval));	//	小数点以下切り上げ
		if ( flg2 > 0 ) {
			value = (long)(0 - value);
		}
	}
	return (value);
}
