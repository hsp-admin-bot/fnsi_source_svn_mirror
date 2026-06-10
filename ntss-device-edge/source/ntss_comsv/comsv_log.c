/**
* @file comsv_log.c
* @brief 通信データ処理（ログデータ）
* @author Y.Takamura
* @date 2018/09/24
* @details 装置から受信したログデータ処理
*/

#include <stdio.h>
#include <string.h>
#include "ntss_comsv.h"

/**
* @fn void comsv_log(unsigned char *logdata, struct scn_data_fm *sp)
* @brief 通信データ処理（ログデータ）
* @param[in] logdata 受信ログデータ
* @param[in,out] sp 装置制御データ
* @details 装置から受信したログデータ処理
*/
void comsv_log(unsigned char *logdata, struct scn_data_fm *sp)
{
	int ret;
	short type;
	char jdata[256];
	unsigned char sw, code;

    // #8266 2023.03.29 add ログシーケンシャルＮｏによる重複チェック TDC高村 start
    if ( sp->is_check_log_sno == 0 ) {
        sp->is_check_log_sno = 1;    // 以降はチェックを行う
    }
    else if ( logdata[0] == sp->log_sno ) {
        sp->rcvlen = 0;
        return;
    }
    sp->log_sno = logdata[0];
    // #8266 2023.03.29 add ログシーケンシャルＮｏによる重複チェック TDC高村 end
	sw = logdata[1];
	code = logdata[2];
    
    // add 治療完了後、I-HDFの引き残し記録を別途で登録要 高 start
    char buf[255];
    time_t tim;
    unsigned char occurDateTime[15];
    
    tim = -1;
    memset( buf, 0, sizeof(buf ));
    occurDateTime[14] = 0;
    
    // 装置からの発生日時を取得する
    memcpy( buf, logdata + 3, 7 );
    bcd_time( buf, &tim );
    
    if ( tim != -1 )
    {
        // 発生日時を置き換える
        time_str( tim, buf, buf + 20, 1 );
        buf[4] = buf[7] = buf[22] = buf[25] = 0;
        sprintf(
                occurDateTime
            , "%s%s%s%s%s%s"
            , buf
            , buf + 5
            , buf + 8
            , buf + 20
            , buf + 23
            , buf + 26
        );
    }
    else {
        // 発生日時
        memset( buf, 0, sizeof(buf ));
        time_str(get_time(), buf, buf + 20, 1 );
        buf[4] = buf[7] = buf[22] = buf[25] = 0;
        sprintf(
                occurDateTime
            , "%s%s%s%s%s%s"
            , buf
            , buf + 5
            , buf + 8
            , buf + 20
            , buf + 23
            , buf + 26
        );
    }
    // add 治療完了後、I-HDFの引き残し記録を別途で登録要 高 end

	/* 測定データ & 条件送信済 */
	if ( sw == 0x01 && sp->cond_send_flg ) {
		type = 0;
		if ( code == 0x06 ) {		/* 再循環率測定 */
			// そのままの値を利用
			type = 1;
		}
		else if ( code == 0x09 ) {	/* 補液バランス情報/FNW呼称:I-HDFの引き残し量 */
			// 100で割った値を利用
			type = 2;
		}
		else if ( code == 0x13 ) {	/* 静的静脈圧 */
			// 999と-999の場合は無視、他はそのままの値を利用
			type = 3;
		}
		else if ( code == 0x14 ) {	/* IAP ratio */
			// 999と-999の場合は無視、他は100で割った値を利用
			type = 4;
		}
		// ログデータ（測定データ）からJSONデータを作成
		ret = comsv_json_ord_make_log(jdata, type, logdata+12);
		printf("comsv_json_ord_make_log = [%d]\n", ret);
		if ( ret == 0 ) {
			// 治療情報の実績ログ（測定データ）を更新する
            // mod 治療完了後、I-HDFの引き残し記録を別途で登録要 高 start
			// ret = comsv_rest_post_ord_log(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, type, jdata);
            ret = comsv_rest_post_ord_log(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, type, jdata, occurDateTime);
            // mod 治療完了後、I-HDFの引き残し記録を別途で登録要 高 end
			printf("comsv_rest_post_ord_log = [%d]\n", ret);
		}
	}
	/* 警報、報知、ホスト報知 */
	else if ( (sw >= 0x40 && sw <= 0xbf) || sw == 0 ) {
	}
	/* 警報、報知リセット */
	else if ( sw == 0xf0 && code == 0 ) {
	}
	/* 通信データ「解除」（治療中以外の場合） */
	else if ( sw == 0xf4 && code == 0x06 && !(sp->mon_sta & 1) ) {
		sp->cond_set_date = 0;	// 条件確認日時
		// 装置状態管理の日付データを更新する
		ret = comsv_rest_put_dev_date(sp->dev_no, sp->deviceType, sp->devid, 1, sp->mon_sta, sp->cond_set_date);
		printf("comsv_rest_put_dev_date = [%d]\n", ret);

		// 治療情報の日付データを更新する
		// #12344 2025.10.21 mod ord_noがある場合のみ更新 TDC片口 start
		// ret = comsv_rest_put_ord_date(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, 0, 0, 1, sp->cond_send_date);
		// printf("comsv_rest_put_ord_date = [%d]\n", ret);
		if (sp->ord_no != 0) {
			ret = comsv_rest_put_ord_date(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, 0, 0, 1, sp->cond_send_date);
			printf("comsv_rest_put_ord_date = [%d]\n", ret);
		}
		// #12344 2025.10.21 mod ord_noがある場合のみ更新 TDC片口 end

		// 患者基本情報のステータスを更新する
		// #12344 2025.10.21 mod pat_idがある場合のみ更新 TDC片口 start
		// ret = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 0, sp->ord_no, 1);
		// printf("comsv_rest_put_pat_related = [%d]\n", ret);
		if (sp->pat_id != 0) {
			ret = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 0, sp->ord_no, 1);
			printf("comsv_rest_put_pat_related = [%d]\n", ret);
		}
		// #12344 2025.10.21 mod pat_idがある場合のみ更新 TDC片口 end

        // add AWSとDEの通信断からの復旧 高 start
        sp->current_mon_sta[1] = sp->current_mon_sta[0]; 
        sp->current_mon_sta[0] = COMM_STA1;
        // add AWSとDEの通信断からの復旧 高 end
	}
	/* 通信データ「確認」（治療中以外の場合） */
	else if ( sw == 0xf4 && code == 0x07 && !(sp->mon_sta & 1) ) {
		sp->cond_set_date = get_time();	// 条件確認日時
		// 装置状態管理の日付データを更新する
		ret = comsv_rest_put_dev_date(sp->dev_no, sp->deviceType, sp->devid, 1, sp->mon_sta, sp->cond_set_date);
		printf("comsv_rest_put_dev_date = [%d]\n", ret);

		// 治療情報の日付データを更新する
		// #12344 2025.10.21 mod ord_noがある場合のみ更新 TDC片口 start
		// ret = comsv_rest_put_ord_date(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, 0, 0, 2, sp->cond_send_date);
		// printf("comsv_rest_put_ord_date = [%d]\n", ret);
		if (sp->ord_no != 0) {
			ret = comsv_rest_put_ord_date(sp->dev_no, sp->deviceType, sp->devid, sp->ord_no, 0, 0, 2, sp->cond_send_date);
			printf("comsv_rest_put_ord_date = [%d]\n", ret);
		}
		// #12344 2025.10.21 mod ord_noがある場合のみ更新 TDC片口 end
		
		// 患者基本情報のステータスを更新する
		// #12344 2025.10.21 mod pat_idがある場合のみ更新 TDC片口 start
		// ret = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 0, sp->ord_no, 2);
		// printf("comsv_rest_put_pat_related = [%d]\n", ret);
		if (sp->pat_id != 0) {
			ret = comsv_rest_put_pat_related(sp->dev_no, sp->deviceType, sp->devid, sp->pat_id, 0, sp->ord_no, 2);
			printf("comsv_rest_put_pat_related = [%d]\n", ret);
		}
		// #12344 2025.10.21 mod pat_idがある場合のみ更新 TDC片口 end

        // add AWSとDEの通信断からの復旧 高 start
        sp->current_mon_sta[1] = sp->current_mon_sta[0]; 
        sp->current_mon_sta[0] = COMM_STA2;
        // add AWSとDEの通信断からの復旧 高 end
	}
	/* 排液 */
	else if ( sw == 0xf2 && code == 0x09 ) {
        // del FNSI-バグ 通信サーバ 高 start
        //if ( comsv_cmd_npat2_check(sp) ) {
            //sp->reqflg[C_NEXTPAT2] = 1;	// 次患者情報２送信
        //}
        // del FNSI-バグ 通信サーバ 高 end
	}
	/* 血液回収 */
	else if ( (sw == 0xf2 && code == 0x54) || (sw == 0xf2 && code == 0x55) ) {
		sp->cond_read_flg = 3;		// 設定値読出フラグ（3:排液時）
		sp->reqflg[C_JSETRD] = 1;	// 条件データ読出要求
	}
	/* 返血 */
	else if ( (sw == 0xf2 && code == 0x5d) || (sw == 0xf2 && code == 0x5e) ) {
		sp->cond_read_flg = 3;		// 設定値読出フラグ（3:排液時）
		sp->reqflg[C_JSETRD] = 1;	// 条件データ読出要求
	}
	/* D-FAS終了 */
	else if ( sw == 0xf5 && code == 0xff ) {
		if ( comsv_cmd_npat2_check(sp) ) {
			sp->reqflg[C_NEXTPAT2] = 1;	// 次患者情報２送信
		}
	}
	/* その他、ログ */
	else { 
	}

}
