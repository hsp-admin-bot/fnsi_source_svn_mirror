/**
* @file comsv_json_dev.c
* @brief JSON文字列変換処理（装置状態管理関連）
* @author Y.Takamura
* @date 2018/10/26
* @details JSON文字列から構造体に格納する
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ntss_comsv.h"
#include "comsv_json_num.h"

// #8266 2023.03.24 mod 前回取得データを削除しない修正に伴う対応 TDC高村 start
/**
 * @fn int comsv_json_dev_state(char *jfile, short type, struct scn_data_fm *scn)
 * @brief JSON文字列から装置状態管理を構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[in] type 取得タイプ（-1:装置ステータスのみ,0:オーダ番号&患者ID取得無し,1,2:オーダ番号&患者ID取得有り)
 *                              0,1:AWSとDEの通信断時は既存ファイルから構造体に格納しない）
 *                             -1,2:AWSとDEの通信断時も既存ファイルから構造体に格納する）
 * @param[out] scn 装置制御データ構造体
 * @return 0:成功, -1:エラー
 */
// #8266 2023.03.24 mod 前回取得データを削除しない修正に伴う対応 TDC高村 end
int comsv_json_dev_state(char *jfile, short type, struct scn_data_fm *scn) {
    int flg;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //long l_tim;
    time_t l_tim;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    double dval;
    char *bp;
    char dt[20], tm[10];
    char key[40], num[20];
    char buf[255], sjis[255];
    JSON_Value *root_value;
    JSON_Object *root;

    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // #8266 2023.03.24 add 前回取得データを削除しない修正に伴う対応 TDC高村 start
    if ( (type == 0 || type == 1) && getCommAliveState() != 0 ) {
        // #12507 2026.03.01 add FW7に伴うメモリリーク対応 TDC高村 start
        json_value_free(root_value);
        // #12507 2026.03.01 add FW7に伴うメモリリーク対応 TDC高村 end
        return -1;
    }
    // #8266 2023.03.24 add 前回取得データを削除しない修正に伴う対応 TDC高村 end

    // 装置状態管理
    // 装置ステータス
    scn->mon_sta = comsv_json_dotget_short(root, "machineStatus");
    if ( type < 0 ) {
        json_value_free(root_value);
        return 0;
    }
    // 次回オーダ番号
    scn->next_ord_no = comsv_json_dotget_long(root, "nextOrdNo");
    // 次患者ID
    scn->next_pat_id = comsv_json_dotget_long(root, "nextPatid");
    // 次患者氏名
    bp = (char*)json_object_dotget_string(root, "nextPatName");
    if ( bp != NULL && bp[0] != 0 ) {
        memset(buf, 0, sizeof(buf));
        strcpy(buf, bp);
        memset(sjis, 0, sizeof(sjis));
        utf8tosjis(buf, sjis);
        memcpy(scn->next_pat_name, sjis, sizeof(scn->next_pat_name));
    }
    // 条件送信用患者氏名
    bp = (char*)json_object_dotget_string(root, "deviceSetPatName");
    if ( bp != NULL && bp[0] != 0 ) {
        memset(buf, 0, sizeof(buf));
        strcpy(buf, bp);
        memset(sjis, 0, sizeof(sjis));
        utf8tosjis(buf, sjis);
        memcpy(scn->jset_pat_name, sjis, sizeof(scn->jset_pat_name));
    }
    // #11157 2024.11.01 add DE切断時の仮想端末サポート TDC高村 start
    // 透析開始予定日時
    bp = (char*)json_object_dotget_string(root, "startPlanDate");
    scn->plan_start_date = 0;
    if ( bp != NULL && bp[0] != 0 ) {
        strncpy(buf, bp, sizeof(buf));
        sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
        sprintf(tm, "%.8s", buf + 11);
        if ( str_time(dt, tm, &l_tim, 1) == 0 ) {
            scn->plan_start_date = l_tim;
        }
    }
    // 透析終了予定日時
    bp = (char*)json_object_dotget_string(root, "endPlanDate");
    scn->plan_end_date = 0;
    if ( bp != NULL && bp[0] != 0 ) {
        strncpy(buf, bp, sizeof(buf));
        sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
        sprintf(tm, "%.8s", buf + 11);
        if ( str_time(dt, tm, &l_tim, 1) == 0 ) {
            scn->plan_end_date = l_tim;
        }
    }
    // #11157 2024.11.01 add DE切断時の仮想端末サポート TDC高村 end
    // add 通信共通プロトコル（V3/V4）患者IDが異なる 高 start
    // 院内表示用の患者ID
    bp = (char*)json_object_dotget_string(root, "hospPatid");
    if ( bp != NULL && bp[0] != 0 ) {
        memset(buf, 0, sizeof(buf));
        strcpy(buf, bp);
        memcpy(scn->hosp_pat_id, buf, sizeof(scn->hosp_pat_id));
    }
    // add 通信共通プロトコル（V3/V4）患者IDが異なる 高 end
    // 条件送信日時
    bp = (char*)json_object_dotget_string(root, "condSendDate");
    scn->cond_send_flg = 0;
    if ( bp != NULL && bp[0] != 0 ) {
        strncpy(buf, bp, sizeof(buf));
        sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
        sprintf(tm, "%.8s", buf + 11);
        if ( str_time(dt, tm, &l_tim, 1) == 0 ) {
            scn->cond_send_date = l_tim;
            scn->cond_send_flg = 1;
        }
    }
    // 条件確認日時
    bp = (char*)json_object_dotget_string(root, "condSetDate");
    if ( bp != NULL && bp[0] != 0 ) {
        strncpy(buf, bp, sizeof(buf));
        sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
        sprintf(tm, "%.8s", buf + 11);
        if ( str_time(dt, tm, &l_tim, 1) == 0 ) {
            scn->cond_set_date = l_tim;
        }
    }
    // 患者確認フラグ
    flg = 0;
    bp = (char*)json_object_dotget_string(root, "isPatVerified");
    if ( bp != NULL && bp[0] != 0 ) {
        strncpy(buf, bp, sizeof(buf));
        flg = atoi(buf);
    }
    if ( flg == 0 && scn->cond_set_date ) {
        // 患者確認フラグがOFFの場合、条件確認日時をクリア
        scn->cond_set_date = 0;
    }
    // 透析開始日時
    // add FNSI-バグ 通信サーバ(#5618) 高 start
    scn->dial_start_date = 0;
    // add FNSI-バグ 通信サーバ(#5618) 高 end
    bp = (char*)json_object_dotget_string(root, "startDate");
    if ( bp != NULL && bp[0] != 0 ) {
        strncpy(buf, bp, sizeof(buf));
        sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
        sprintf(tm, "%.8s", buf + 11);
        if ( str_time(dt, tm, &l_tim, 1) == 0 ) {
            scn->dial_start_date = l_tim;
 	    	if ( scn->cond_send_flg == 0 ) {
                 // 仮想端末入力を可能にする為
                 scn->cond_send_flg = 1;
            }           
        }
    }
    // 透析終了日時
    // add FNSI-バグ 通信サーバ(#5618) 高 start
    scn->dial_end_date = 0;
    // add FNSI-バグ 通信サーバ(#5618) 高 end
    bp = (char*)json_object_dotget_string(root, "endDate");
    if ( bp != NULL && bp[0] != 0 ) {
        strncpy(buf, bp, sizeof(buf));
        sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
        sprintf(tm, "%.8s", buf + 11);
        if ( str_time(dt, tm, &l_tim, 1) == 0 ) {
            scn->dial_end_date = l_tim;
        }
    }
    // 透析時間
    scn->dial_time = 0;
    // add FNSI-バグ 通信サーバ 高 start
    scn->treat_time = 0;
    // add FNSI-バグ 通信サーバ 高 end
    bp = (char*)json_object_dotget_string(root, "treatTime");
    if ( bp != NULL && bp[0] != 0 ) {
        strncpy(buf, bp, sizeof(buf));
        scn->dial_time = atoi(buf);
        // add FNSI-バグ 通信サーバ 高 start
        scn->treat_time = scn->dial_time;
        // add FNSI-バグ 通信サーバ 高 end
    }
	if ( scn->dial_time <= 0 ) {
        scn->dial_time = 240;	// 4時間
        // add FNSI-バグ 通信サーバ 高 start
        scn->treat_time = scn->dial_time;
        // add FNSI-バグ 通信サーバ 高 end
    }
    // 治療時間判定時間
    scn->facility_time = 0;
    bp = (char*)json_object_dotget_string(root, "treatJudgeTime");
    if ( bp != NULL && bp[0] != 0 ) {
        strncpy(buf, bp, sizeof(buf));
        scn->facility_time = atoi(buf);
    }
    
    // add FNSI-バグ 通信サーバ 高 start
    // 治療モード
    bp = (char*)json_object_dotget_string(root, "tmpDeviceSetInfo.dev.15");
    if ( bp != NULL && bp[0] != 0 ) {
        memset(buf, 0, sizeof(buf));
        strcpy(buf, bp);
        scn->treatment = atoi(buf);
    }
    // add FNSI-バグ 通信サーバ 高 end

    if ( type ) {
        // #8266 2023.03.24 mod 前回取得データを削除しない修正に伴う対応 TDC高村 start
        /*
        // mod AWSとDEの通信断からの復旧 高 start
        if ( getCommAliveState() == 0 ) {
        // mod AWSとDEの通信断からの復旧 高 end
            // オーダ番号
            scn->ord_no = comsv_json_dotget_long(root, "ordNo");
            // 患者ID
            scn->pat_id = comsv_json_dotget_long(root, "patId");
        }
        */
        // オーダ番号
        scn->ord_no = comsv_json_dotget_long(root, "ordNo");
        // 患者ID
        scn->pat_id = comsv_json_dotget_long(root, "patId");
        // #8266 2023.03.24 mod 前回取得データを削除しない修正に伴う対応 TDC高村 end
        
/*
        // 透析時間
        if ( scn->cond_send_flg ) {
            // 設定値
            sprintf(key, "tmpDeviceSetInfo.dev.%d", 14);
            bp = (char*)json_object_dotget_string(root, key);
            if ( bp != NULL && bp[0] != 0 ) {
                memset(buf, 0, sizeof(buf));
                strcpy(buf, bp);
                dval = atof(buf);
            }
            else {
                dval = json_object_dotget_number(root, key);
            }
            if ( dval > 0 ) {
                sprintf(num, "%.2f", dval);
                scn->dial_time = comsv_lcd_strshort(num, 0);
            }
        }
*/
    }

    json_value_free(root_value);

    return 0;
}

/**
 * @fn int comsv_json_dev_cond(char *jfile, short type, struct scn_data_fm *scn, unsigned char *data, int len)
 * @brief JSON文字列から条件送信データに格納する
 * @param[in] jfile JSONファイル名
 * @param[in] type JSONタイプ（0:REST GET用,1:REST PUT用）
 * @param[out] scn 装置制御データ構造体
 * @param[out] data 条件送信データ
 * @param[in] len データ長
 * @return 0:成功, -1:エラー
 */
int comsv_json_dev_cond(char *jfile, short type, struct scn_data_fm *scn, unsigned char *data, int len) {
    int i;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //long l_tim;    
    time_t l_tim;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    long npat_id;
    short val;
    double dval;
    char *bp;
    char dt[20], tm[10];
    char key[40], num[20];
    char buf[255], sjis[255];
    struct cond_list item;
    JSON_Value *root_value;
    JSON_Object *root;

    // 条件データの初期化（患者ID,患者名部分のみ）
    memset(data, 0, (8 + 20));

    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    if ( type == 0 ) {
        // オーダ番号
        //scn->ord_no = comsv_json_dotget_long(root, "ordNo");
        // 患者ID
        //scn->pat_id = comsv_json_dotget_long(root, "patId");

        // 条件送信時に患者IDが決まっていない為、次患者IDを患者IDとする
        scn->pat_id = comsv_json_dotget_long(root, "nextPatid");
        // 透析開始予定日時
        bp = (char*)json_object_dotget_string(root, "startPlanDate");
        scn->plan_start_date = 0;
        if ( bp != NULL && bp[0] != 0 ) {
            strncpy(buf, bp, sizeof(buf));
            sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
            sprintf(tm, "%.8s", buf + 11);
            if ( str_time(dt, tm, &l_tim, 1) == 0 ) {
                scn->plan_start_date = l_tim;
            }
        }
        // 透析終了予定日時
        bp = (char*)json_object_dotget_string(root, "endPlanDate");
        scn->plan_end_date = 0;
        if ( bp != NULL && bp[0] != 0 ) {
            strncpy(buf, bp, sizeof(buf));
            sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
            sprintf(tm, "%.8s", buf + 11);
            if ( str_time(dt, tm, &l_tim, 1) == 0 ) {
                scn->plan_end_date = l_tim;
            }
        }
    }
    
    // add 通信共通プロトコル（V3/V4）患者IDが異なる 高 start
    // 院内表示用の患者ID
    bp = (char*)json_object_dotget_string(root, "hospPatid");
    if ( bp != NULL && bp[0] != 0 ) {
        memset(buf, 0, sizeof(buf));
        strcpy(buf, bp);
        memcpy(scn->hosp_pat_id, buf, sizeof(scn->hosp_pat_id));
    }
    // add 通信共通プロトコル（V3/V4）患者IDが異なる 高 end
    
    // add FNSI-バグ 通信サーバ 高 start
    // 透析時間
    scn->treat_time = 0;
    bp = (char*)json_object_dotget_string(root, "treatTime");
    if ( bp != NULL && bp[0] != 0 ) {
        strncpy(buf, bp, sizeof(buf));
        scn->treat_time = atoi(buf);
    }
    if ( scn->treat_time <= 0 ) {
        scn->treat_time = 240;  // 4時間
    }
    // add FNSI-バグ 通信サーバ 高 end

    npat_id = 0;
    for ( i = 0; i < SET3_NUM; i++ ) {
        if ( (i * 2) >= len ) break;
        if ( type == 0 ) {
            sprintf(key, "tmpDeviceSetInfo.dev.%d", i);
        }
        else {
            sprintf(key, "%d", i);
        }
        if ( i == 0 ) {
            // 患者ID
            memset(buf, 0, sizeof(buf));
            bp = (char*)json_object_dotget_string(root, key);
            if ( bp != NULL && bp[0] != 0 ) {
                memset(buf, 0, sizeof(buf));
                strcpy(buf, bp);
                npat_id = atol(buf);
                if ( type == 0 ) {
                    if ( npat_id != scn->next_pat_id ) {
                        // 次患者IDと設定値の患者IDが不一致の場合、
                        // 設定値の患者IDを正とする（患者ID,次患者ID）
                        scn->pat_id = scn->next_pat_id = npat_id;
                    }
                }
            }
            else {
                npat_id = scn->next_pat_id;
            }
            sprintf(buf, "%08ld", npat_id);
            comsv_lcd_memcpy(data, buf, 8);
            i += 3;
        }
        else if ( i == 4 ) {
            // 患者名
            // 個人情報は設定値から取得しない（登録なし）
            if ( npat_id ) {
                comsv_lcd_memcpy(data + (i * 2), scn->jset_pat_name, 20);
            }
            else {
                memset(buf, ' ', 20);
                comsv_lcd_memcpy(data + (i * 2), buf, 20);
            }
            i += 9;
        }
        else if ( i == 45 || i == 54 || i == 63 || i == 72 || i == 81 ) {
            // 除水補正項目名１〜５
            bp = (char*)json_object_dotget_string(root, key);
            if ( bp != NULL && bp[0] != 0 ) {
                memset(buf, 0, sizeof(buf));
                strcpy(buf, bp);
                memset(sjis, 0, sizeof(sjis));
                utf8tosjis(buf, sjis);
                comsv_lcd_memcpy(data + (i * 2), sjis, 16);
                i += 7;
            }    
            // add FNSI-バグ 通信サーバ 高 start
            else {
                memset(sjis, 0, sizeof(sjis));
                comsv_lcd_memcpy(data + (i * 2), sjis, 16);
            }
            // add FNSI-バグ 通信サーバ 高 end       
        }
        else {
            // その他、設定値
            bp = (char*)json_object_dotget_string(root, key);
            if ( bp != NULL && bp[0] != 0 ) {
                memset(buf, 0, sizeof(buf));
                strcpy(buf, bp);
                dval = atof(buf);
            }
            else {
                dval = json_object_dotget_number(root, key);
            }
            if ( dval <= -99999 ) continue;
            sprintf(num, "%.2f", dval);
            // 条件項目取得
            item.dec = 0;
            ntss_mst_cond_data(0, "00", i, &item);
            val = comsv_lcd_strshort(num, item.dec);
            short_set(data + (i * 2), val);
            if ( i == 14 ) {
                // 透析時間
                scn->dial_time = val;
            }
            
            // add 強制オフライン 高 start
            if ( i == 15 ) {
                scn->treatment = val;
            }
            // add 強制オフライン 高 end
        }
    }

    json_value_free(root_value);

    return 0;
}

// #11367 2025.01.09 mod 次患者情報のJSONデータ取得処理変更 TDC高村 start
/**
 * @fn int comsv_json_dev_npat1(char *jfile, short type, struct scn_data_fm *scn, unsigned char *data)
 * @brief JSON文字列から次患者情報１送信データに格納する
 * @param[in] jfile JSONファイル名
 * @param[in] type JSON取得タイプ（0:JSON Library,1:Original）
 * @param[out] scn 装置制御データ構造体
 * @param[out] data 次患者情報１送信データ
 * @return 0:成功, -1:エラー
 */
int comsv_json_dev_npat1(char *jfile, short type, struct scn_data_fm *scn, unsigned char *data) {
    int ret, i;
    short val;
    double dval;
    char *bp, buf[2048];
    char key[40], num[20];
    JSON_Value *root_value;
    JSON_Object *root, *root_tmp;

    // 次患者情報１送信データの初期化（イニシャル値）
    memset(data, 0, 20 * 2);
	short_set(data, 200);               // プライミング補助 動脈充填液量
	short_set(data + (1 * 2), 100);     // プライミング補助 動脈充填液速
	short_set(data + (2 * 2), 200);     // プライミング補助 静脈充填液量
	short_set(data + (3 * 2), 100);     // プライミング補助 静脈充填液速
	short_set(data + (4 * 2), 400);     // プライミング補助 気泡抜き液量
	short_set(data + (5 * 2), 300);     // プライミング補助 気泡抜き液速
	short_set(data + (9 * 2), 800);     // プライミング補助 液交換量
	short_set(data + (10 * 2), 20);     // プライミング補助 間欠動作動作時間
	short_set(data + (11 * 2), 10);     // プライミング補助 間欠動作停止時間
	short_set(data + (12 * 2), 700);    // 自動プライミング 開始時刻
	short_set(data + (13 * 2), 40);     // 自動プライミング 落差時間
	short_set(data + (14 * 2), 250);    // 自動プライミング 送液流量
	short_set(data + (15 * 2), 250);    // 自動プライミング 送液流速（１回目）
	short_set(data + (16 * 2), 250);    // 自動プライミング 送液流速（２回目）
	short_set(data + (17 * 2), 400);    // 自動プライミング 送液流速
	short_set(data + (18 * 2), 300);    // 自動プライミング 循環時間
	short_set(data + (19 * 2), 600);    // 自動プライミング 総量

    if ( jfile == "" || jfile[0] == 0 ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -2;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -3;
    }

    // 次回オーダ番号
    scn->next_ord_no = comsv_json_dotget_long(root, "nextOrdNo");
    // 次患者ID
    scn->next_pat_id = comsv_json_dotget_long(root, "nextPatid");

    ret = 0;
    if ( type == 0 ) {  // Library
        memset(key, 0, sizeof(key));
        strcpy(key, "tmpDeviceSetInfo.pat1");
        root_tmp = json_object_dotget_object(root, key);
        if ( root_tmp == NULL && scn->next_pat_id == 0 ) {
            ret = -4;
        }
        else if ( root_tmp == NULL ) {
            ret = -5;
        }
        else if ( scn->next_pat_id == 0 ) {
            ret = -6;
        }
        if ( ret < 0 ) {
            json_value_free(root_value);
            return ret;
        }
    }
    else {  // Originalkey
        // JSON文字列から次患者情報データ部を取得する
        memset(buf, 0, sizeof(buf));
        i = comsv_npat_getbuffer(jfile, 1, buf);
        if ( i != 0 && scn->next_pat_id == 0 ) {
            ret = -4;
        }
        else if ( i != 0 ) {
            ret = -5;
        }
        else if ( scn->next_pat_id == 0 ) {
            ret = -6;
        }
        if ( ret < 0 ) {
            return ret;
        }
    }

    for ( i = 0; i < 20; i++ ) {
        if ( type == 0 ) {  // Library
            memset(key, 0, sizeof(key));
            sprintf(key, "tmpDeviceSetInfo.pat1.%d", i + 219);
            bp = (char*)json_object_dotget_string(root, key);
            if ( bp != NULL && bp[0] != 0 ) {
                memset(buf, 0, sizeof(buf));
                strcpy(buf, bp);
                dval = atof(buf);
            }
            else {
                dval = comsv_json_dotget_double(root, key);
            }
        }
        else {  // Original
            memset(key, 0, sizeof(key));
            sprintf(key, "%d", i + 219);
            if ( comsv_json_strget_double(buf, key, &dval) <= 0 ) continue;
        }
        memset(num, 0, sizeof(num));
        sprintf(num, "%.2f\n", dval);
        if ( i==10 || i==11 ) {
            // プライミング間欠動作時間（小数点以下1桁）
            val = comsv_lcd_strshort(num, 1);
        }
        else {
            val = comsv_lcd_strshort(num, 0);
        }
        if ( i==12 ) {
	        // プライミング開始時刻
            bintobcd((long)(val/60), 2, data + (i * 2));        // 時
            bintobcd((long)(val%60), 2, data + (i * 2) + 1);    // 分
        }
        else {
        	short_set(data + (i * 2), val);
        }
    }

    json_value_free(root_value);

    return 0;
}
// #11367 2025.01.09 mod 次患者情報のJSONデータ取得処理変更 TDC高村 end

// #11367 2025.01.09 mod 次患者情報のJSONデータ取得処理変更 TDC高村 start
/**
 * @fn int comsv_json_dev_npat2(char *jfile, short type, unsigned char *data)
 * @brief JSON文字列から次患者情報２送信データに格納する
 * @param[in] jfile JSONファイル名
 * @param[in] type JSON取得タイプ（0:JSON Library,1:Original）
 * @param[out] data 次患者情報２送信データ
 * @return 0:成功, -1:エラー
 */
int comsv_json_dev_npat2(char *jfile, short type, unsigned char *data) {
    int ret, i;
    short val;
    short d_type = 0;
    short h_type = 0;
    long next_pat_id;
    double dval;
    char *bp, buf[2048];
    char key[40], num[20];
    JSON_Value *root_value;
    JSON_Object *root, *root_tmp;

    // 次患者情報２送信データの初期化（イニシャル値）
    memset(data, 0, 51 * 2);
	short_set(data + (1 * 2), 1);       // IPラインプライミング使用選択
	short_set(data + (2 * 2), 5);       // ガスパージ時間
	short_set(data + (3 * 2), 1000);    // 置換洗浄量（透析液）
	short_set(data + (5 * 2), 300);     // プライミング 血液ポンプ速度 
	short_set(data + (7 * 2), 30);      // プライミング 送液最大時間 
	short_set(data + (8 * 2), 200);     // プライミング 血液回路内洗浄 置換②使用液量 
	short_set(data + (10 * 2), 150);    // プライミング 気泡抜き動作 加圧時圧力上限
	short_set(data + (11 * 2), 20);     // プライミング 除水ポンプ速度
	short_set(data + (31 * 2), 2);      // ダイアライザー気泡抜き時間
	short_set(data + (32 * 2), 60);     // 動脈チャンバ液面作成時間
	short_set(data + (33 * 2), 3);      // 循環洗浄時間

    if ( jfile == "" || jfile[0] == 0 ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -2;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -3;
    }

    // 次患者ID
    next_pat_id = comsv_json_dotget_long(root, "nextPatid");

    ret = 0;
    if ( type == 0 ) {  // Library
        memset(key, 0, sizeof(key));
        strcpy(key, "tmpDeviceSetInfo.pat2");
        root_tmp = json_object_dotget_object(root, key);
        if ( root_tmp == NULL && next_pat_id == 0 ) {
            ret = -4;
        }
        else if ( root_tmp == NULL ) {
            ret = -5;
        }
        else if ( next_pat_id == 0 ) {
            ret = -6;
        }
        if ( ret < 0 ) {
            json_value_free(root_value);
            return ret;
        }
    }
    else {  // Original
        // JSON文字列から次患者情報データ部を取得する
        memset(buf, 0, sizeof(buf));
        i = comsv_npat_getbuffer(jfile, 2, buf);
        if ( i != 0 && next_pat_id == 0 ) {
            ret = -4;
        }
        else if ( i != 0 ) {
            ret = -5;
        }
        else if ( next_pat_id == 0 ) {
            ret = -6;
        }
        if ( ret < 0 ) {
            return ret;
        }
    }

    for ( i = 0; i <= 50; i++ ) {
        if ( type == 0 ) {  // Library
            memset(key, 0, sizeof(key));
            sprintf(key, "tmpDeviceSetInfo.pat2.%d", i);
            bp = (char*)json_object_dotget_string(root, key);
            if ( bp != NULL && bp[0] != 0 ) {
                memset(buf, 0, sizeof(buf));
                strcpy(buf, bp);
                dval = atof(buf);
            }
            else {
                dval = comsv_json_dotget_double(root, key);
            }
        }
        else {  // Original
            memset(key, 0, sizeof(key));
            sprintf(key, "%d", i);
            if ( comsv_json_strget_double(buf, key, &dval) <= 0 ) continue;
        }
        memset(num, 0, sizeof(num));
        sprintf(num, "%.2f\n", dval);
        if ( i==11 ) {
            // 除水ポンプ速度（小数点以下2桁）
            val = comsv_lcd_strshort(num, 2);
        }
        else {
            val = comsv_lcd_strshort(num, 0);
        }
        if ( i==0 ) {
            // ダイアライザ選択
            d_type = val;
        }
        else if ( i==30 ) {
            // 補液選択
            h_type = val;
        }
        // add FNSI-バグ 通信サーバ 高 start
        else if ( i == 34 ) {
            // 治療モード
            if(val == 9 || val == 6)    //"6":"AFBF",   "9":"特殊血液浄化"
                continue;
        }
        // add FNSI-バグ 通信サーバ 高 end
    	short_set(data + (i * 2), val);
    }
    if ( h_type == 0 ) {
        // 補液選択が後補液
        for (i=51; i<=53; i++) {
            if ( type == 0 ) {  // Library
                memset(key, 0, sizeof(key));
                sprintf(key, "tmpDeviceSetInfo.pat2.%d", i);
                bp = (char*)json_object_dotget_string(root, key);
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    dval = atof(buf);
                }
                else {
                    dval = comsv_json_dotget_double(root, key);
                }
            }
            else {  // Original
                memset(key, 0, sizeof(key));
                sprintf(key, "%d", i);
                if ( comsv_json_strget_double(buf, key, &dval) <= 0 ) continue;
            }
            memset(num, 0, sizeof(num));
            sprintf(num, "%.2f\n", dval);
            val = comsv_lcd_strshort(num, 0);
            short_set(data + ((i-20) * 2), val);
        }
    }
    if ( d_type == 1 ) {
        // ダイアライザ選択が積層
        for (i=54; i<=59; i++) {
            if ( type == 0 ) {  // Library
                memset(key, 0, sizeof(key));
                sprintf(key, "tmpDeviceSetInfo.pat2.%d", i);
                bp = (char*)json_object_dotget_string(root, key);
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    dval = atof(buf);
                }
                else {
                    dval = comsv_json_dotget_double(root, key);
                }
            }
            else {  // Original
                memset(key, 0, sizeof(key));
                sprintf(key, "%d", i);
                if ( comsv_json_strget_double(buf, key, &dval) <= 0 ) continue;
            }
            memset(num, 0, sizeof(num));
            sprintf(num, "%.2f\n", dval);
            if ( i==58 ) {
                // 除水ポンプ速度（小数点以下2桁）
                val = comsv_lcd_strshort(num, 2);
            }
            else {
                val = comsv_lcd_strshort(num, 0);
            }
            if ( i==59 ) {
                short_set(data + (5 * 2), val);
            }
            else {
                short_set(data + ((i-47) * 2), val);
            }
        }
    }

    json_value_free(root_value);

    return 0;
}
// #11367 2025.01.09 mod 次患者情報のJSONデータ取得処理変更 TDC高村 end

/**
 * @fn int comsv_json_dev_make_cond(char *jfile, unsigned char *data, int len)
 * @brief 条件送信データからJSONファイルを作成する
 * @param[in] jfile 出力JSONファイル名
 * @param[in] data 条件送信データ
 * @param[in] len データ長
 * @return 0:成功, -1:エラー
 */
int comsv_json_dev_make_cond(char *jfile, unsigned char *data, int len) {
    FILE *fp;
    int  i;
    short val;
    char buf[128];
    char utf[128];
    struct cond_list item;

    fp = fopen(jfile, "w");
    if ( fp==NULL ) return -1;

    // 条件データのJSONファイル出力
    fprintf(fp, "{");
    for (i=0; i<SET3_NUM; i++) {
        if ( (i * 2) >= len ) break;
        if ( i == 0 ) {
            // 患者ID
            fprintf(fp, "\"%d\":\"%.8s\"", i, data);
            i += 3;
        }
        // 個人情報は登録しない
        /*
        else if ( i == 4 ) {
            // 患者名
            memset(buf, 0, sizeof(buf));
            memcpy(buf, data + (i * 2), 20);
            memset(utf, 0, sizeof(utf));
            sjistoutf8(buf, utf);
            fprintf(fp, ",\"%d\":\"%s\"", i, utf);
            i += 9;
        }
        */
        else if ( i == 45 || i == 54 || i == 63 || i == 72 || i == 81 ) {
            // 除水補正項目名１〜５
            memset(buf, 0, sizeof(buf));
            memcpy(buf, data + (i * 2), 16);
            memset(utf, 0, sizeof(utf));
            sjistoutf8(buf, utf);
            fprintf(fp, ",\"%d\":\"%s\"", i, utf);
            i += 7;
        }
        else if ( ntss_mst_cond_data(0, "00", i, &item) > 0 ) {
            val = hl_chg( *(short*)(data + (i * 2)) );
            memset(buf, 0, sizeof(buf));
            dsp_s_form(buf, 1, item.dec, val);
            fprintf(fp, ",\"%d\":%s", i, buf);
        }
    }
    fprintf(fp, "}");
    fclose(fp);

    return 0;
}

/**
 * @fn int comsv_json_dev_hash_check(char *jfile, long ord_no, char *hash)
 * @brief JSON文字列から取得したハッシュ値をチェックする
 * @param[in] jfile JSONファイル名
 * @param[in] ord_no オーダー番号
 * @param[in] hash チェック対象のハッシュ値
 * @return 0:成功, -1:エラー
 */
int comsv_json_dev_hash_check(char *jfile, long ord_no, char *hash) {
    int ret, i;
    FILE *fp, *fpp;
    char *str;
    char code[128];
    char buf[10000];

    ret = -1;
    if ( ord_no <= 0 || jfile == "" || hash == "" ) {
        return ret;
    }

    // 装置設定一時データのハッシュ値をチェック
    // ord_no + tmpDeviceSetInfo -> SHA256
    if ( (fp = fopen(jfile, "r")) == NULL ) {
        return ret;
    }
    if ( fgets(buf, sizeof(buf), fp) != NULL ) {
        str = strstr( buf , "\"tmpDeviceSetInfo\":" );
        str += 19;
        int len = strlen(str);
        for ( i=0; i<len - 1; i++ ) {
            if ( str[i] == '}' && str[i+1] == '}' ) {
                str[i+2] = 0;
            }
        }
        sprintf(buf, "echo -n '%ld%s' | sudo sha256sum", ord_no, str);
        //sprintf(buf, "echo -n '%ld%s' | sudo shasum -a 256", ord_no, str);
        //printf("[ %s ]\n", buf);
        fclose(fp);
        
        memset(code, 0, sizeof(code));
        if ( (fpp = popen(buf,"r")) != NULL ) {
            if ( fgets(code, 100, fpp) != NULL ) {
                //printf("hash = [ %s ]\n", code);
                if ( memcmp(hash, code, 64) == 0 ) {
                    // ハッシュ値が一致
                    ret = 0;
                }
            }
    	    pclose(fpp);
        }
    }
    return ret;
}

/**
 * @fn int comsv_json_dev_running_make(char *jfile, struct connect_socket *con_sp)
 * @brief 通信中の装置からJSONファイルを作成する
 * @param[in] jfile 出力JSONファイル名
 * @param[in] con_sp 装置制御データ
 * @return 通信中の装置件数, -1:エラー
 */
int comsv_json_dev_running_make(char *jfile, struct connect_socket *con_sp) {
    FILE *fp;
    int i;
    int cnt;

    // 既にファイルがあれば削除
    remove(jfile);

    fp = fopen(jfile, "w");
    if ( fp==NULL ) return -1;

    // 通信中の装置を検索してjsonファイルを作成
    fprintf(fp, "[");
	for ( i = 0, cnt = 0; i < DEV_MAX; i++ ) {
		if ( con_sp[i].using == false ) continue;
		if ( con_sp[i].running == false ) continue;
		if ( con_sp[i].scn.commType == NTSS_COMM_TYPE_NX ) continue;
		if ( con_sp[i].scn.conflg != 2 ) continue;
        if ( cnt > 0 ) {
            fprintf(fp, ",");
        }
        fprintf(fp, "{\"machine_type_cd\":\"%.3s\",", con_sp[i].scn.deviceType);
        fprintf(fp, "\"machine_serial\":\"%.7s\"}", con_sp[i].scn.devid);
        cnt++;
	}
    fprintf(fp, "]");
    fclose(fp);
 
    return cnt;
}

/**
 * @fn int comsv_json_dev_cond_daily(char *jfile, short *sdata)
 * @brief JSON文字列から透析日報用条件データを格納する
 * @param[in] jfile JSONファイル名
 * @param[out] sdata 透析日報用条件データ（除水速度制限, 補液速度限界値, 補液設定値制限）
 * @return 0:成功, -1:エラー
 */
int comsv_json_dev_cond_daily(char *jfile, short *sdata) {
    int i;
    short val[8];
    double dval;
    char *bp;
    char key[40];
    char num[20];
    char buf[255];
    struct cond_list item;
    JSON_Value *root_value;
    JSON_Object *root;
    static short no[8] = {
	    15,     // 治療モード
	    181,    // 除水速度操作範囲上限
	    185,    // 補液速度操作範囲上限（HDF）
	    186,    // 補液速度操作範囲上限（HF）
	    383,    // 補液量設定値制限（OHDF・OHF用）
	    386,    // 補液速度操作範囲上限（AFBF）
	    396,    // 補液速度操作範囲上限（OHDF）
	    397,    // 補液速度操作範囲上限（OHF）
    };

    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // 設定値
    for ( i = 0; i < 8; i++ ) {
        val[i] = (short)(0x8000);
        sprintf(key, "%d", no[i]);
        bp = (char*)json_object_dotget_string(root, key);
        if ( bp != NULL && bp[0] != 0 ) {
            memset(buf, 0, sizeof(buf));
            strcpy(buf, bp);
            dval = atof(buf);
        }
        else {
            dval = json_object_dotget_number(root, key);
        }
        if ( dval <= -99999 ) continue;
        sprintf(num, "%.2f", dval);
        // 条件項目取得
        item.dec = 0;
        ntss_mst_cond_data(0, "00", no[i], &item);
        val[i] = comsv_lcd_strshort(num, item.dec);
    }

    // sdata[0] 除水速度制限
    sdata[0] = val[1];
    // sdata[1] 補液速度限界値
    if ( val[0] == 3 ) {
        // HFの場合
        sdata[1] = val[3];
    }
    else if ( val[0] == 4 ) {
        // HD+補液の場合
        sdata[1] = val[6];
    }
    else if ( val[0] == 6 ) {
        // AFBFの場合
        sdata[1] = val[5];
    }
    else if ( val[0] == 7 ) {
        // OHDFの場合
        sdata[1] = val[6];
    }
    else if ( val[0] == 8 ) {
        // OHFの場合
        sdata[1] = val[7];
    }
    else if ( val[0] == 10 ) {
        // I-HDFの場合
        sdata[1] = val[6];
    }
    else {
        // その他の場合
        sdata[1] = val[2];
    }
    // sdata[2] 補液設定値制限
    sdata[2] = val[4];

    json_value_free(root_value);

    return 0;
}

/**
 * @fn void comsv_json_dev_status(char *jdata, struct connect_socket *con_sp)
 * @brief 装置ステータス更新用JSONデータを作成する
 * @param[out] jdata 出力JSONデータ
 * @param[in] sp 装置制御データ
 */
void comsv_json_dev_status(char *jdata, struct scn_data_fm *sp) {
    char type[5];
    char serial[10];
    char buf[40];

    // 実施No配列のJSONデータ作成
    memset(type, 0, sizeof(type));
    memset(serial, 0, sizeof(serial));
    memcpy(type, sp->deviceType, sizeof(sp->deviceType));
    memcpy(serial, sp->devid, sizeof(sp->devid));
    // mod FNSI-バグ 通信サーバ(BIT) 高 start
    str_trim(serial);
    // sprintf(jdata, "[{\\\"type\\\":\\\"%.3s\\\",\\\"serial\\\":\\\"%.7s\\\",\\\"status\\\":%d}]", type, serial, sp->mon_sta);
    sprintf(jdata, "[{\\\"type\\\":\\\"%.3s\\\",\\\"serial\\\":\\\"%.8s\\\",\\\"status\\\":%d}]", type, serial, sp->mon_sta);
    // mod FNSI-バグ 通信サーバ(BIT) 高 end
}

// #11925 2025.06.13 add サーバ-DE間切断時に治療中だった患者が？？？？患者化することがある TDC高村 start
/**
 * @fn int comsv_json_dev_update(short type, int *chk, long tim)
 * @brief 装置状態管理JSONファイルを更新する
 * @param[in] timing タイミング（0:仮オーダー番号発番, 1:治療開始, 2:治療終了）
 * @param[in] sp 装置制御データ
 * @return 0:成功, -1:エラー
 */
int comsv_json_dev_update(short timing, struct scn_data_fm *sp)
{
    JSON_Value *root_value;
    JSON_Object *root;
    JSON_Status ret;
    char dst[20];
    char tst[20];
    char buf[40];
    char fpath[64];
    unsigned char logMessage[512] = {0};

    snprintf(logMessage, sizeof(logMessage), "装置状態管理JSONファイル更新 (timing:%d, ord_no:%ld)", timing, sp->ord_no);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, sp->deviceType, sp->devid);

    // 装置状態管理データを更新
    comsv_work_fpath(sp->dev_no, WORK_DEV_STATE, fpath);

    root_value = json_parse_file(fpath);
    if (root_value == NULL)
    {
        LogOutputs(NTSS_LOG_ERROR, "json parse 失敗", 0, sp->deviceType, sp->devid);
        return -1;
    }
    root = json_object(root_value);
    if (root == NULL)
    {
        LogOutputs(NTSS_LOG_ERROR, "json object 取得失敗", 0, sp->deviceType, sp->devid);
        json_value_free(root_value);
        return -1;
    }

    if (timing == 0) // 仮オーダー番号発番
    {
        // オーダ番号
        json_object_dotset_number(root, "ordNo", sp->ord_no);
    }
    if (timing == 1) // 治療開始
    {
        // 透析開始日時
        if (sp->dial_start_date == 0)
        {
            sp->dial_start_date = get_time();
        }
        time_str(sp->dial_start_date, dst, tst, 1);
        dst[4] = dst[7] = '-';
        sprintf(buf, "%s %s", dst, tst);
        json_object_dotset_string(root, "startDate", buf);
        // 透析終了日時
        if (sp->dial_end_date)
        {
            sp->dial_end_date = 0;
        }
        json_object_dotset_null(root, "endDate");
        // 装置ステータス
        json_object_dotset_number(root, "machineStatus", sp->mon_sta);
    }
    else
    {
        // 治療終了
        // 透析終了日時
        if (sp->dial_end_date == 0)
        {
            sp->dial_end_date = get_time();
        }
        time_str(sp->dial_end_date, dst, tst, 1);
        dst[4] = dst[7] = '-';
        sprintf(buf, "%s %s", dst, tst);
        json_object_dotset_string(root, "endDate", buf);
        // 装置ステータス
        json_object_dotset_number(root, "machineStatus", sp->mon_sta);
    }
    
    ret = json_serialize_to_file(root_value, fpath);
    json_value_free(root_value);

    snprintf(logMessage, sizeof(logMessage), "装置状態管理JSONファイル更新終了 (timing:%d, ord_no:%ld) [%d]", timing, sp->ord_no, ret);
    LogOutputs(NTSS_LOG_INFO, logMessage, 0, sp->deviceType, sp->devid);

    return ret;
}
// #11925 2025.06.13 add サーバ-DE間切断時に治療中だった患者が？？？？患者化することがある TDC高村 end
