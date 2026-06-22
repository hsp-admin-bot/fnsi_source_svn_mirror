/**
* @file comsv_json_lcd.c
* @brief JSON文字列変換処理（仮想端末関連）
* @author Y.Takamura
* @date 2018/10/26
* @details JSON文字列から構造体に格納する
*/

#include <stdio.h>
#include <string.h>
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
//#include "ntss_file.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
#include "ntss_comsv.h"
#include "comsv_json_num.h"

/**
 * @fn int comsv_json_lcd_req29(char *jfile, LcddataReq29_t *req29)
 * @brief JSON文字列から仮想端末（処置者）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req29 仮想端末（処置者）構造体
 * @return 0:成功, -1:エラー
 */
int comsv_json_lcd_req29(char *jfile, LcddataReq29_t *req29) {
    int i, no;
    int count;
    long id;
    char *bp;
    char name[64];
    char buf[255], sjis[255];
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;

    memset(req29, ' ', sizeof(LcddataReq29_t));
    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // 処理者
    array = json_object_get_array(root, "ListData");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        for ( i = 0; i < count; i++ ) {
            obj = json_array_get_object (array, i);
            if ( obj == NULL ) continue;
            no = comsv_json_dotget_int(obj, "dispOrder");
            if ( no <= 0 || no > REQ29_MAX ) continue;
            no--;
            id = comsv_json_dotget_long(obj, "userId");
            if ( id <= 0 ) continue;
            req29->id[no] = id;
            memset(name, 0, sizeof(name));
            bp = (char*)json_object_dotget_string(obj, "userName");
            if ( bp != NULL && bp[0] != 0 ) {
                memset(buf, 0, sizeof(buf));
                strcpy(buf, bp);
                memset(sjis, 0, sizeof(sjis));
                utf8tosjis(buf, sjis);
                memcpy(req29->name[no], sjis, sizeof(req29->name[no]));
            }
        }
    }
    json_value_free(root_value);

    return 0;
}

// mod FNSI-バグ 通信サーバ #10270 高 start
/**
 * @fn int comsv_json_lcd_req32(char *jfile, struct scn_data_fm *sp, LcddataReq32_t *req32)
 * @brief JSON文字列から仮想端末（酸素吸入）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[in,out] sp 装置制御データ
 * @param[out] req32 仮想端末（酸素吸入）構造体
 * @return 0:成功, -1:エラー
 */
 // int comsv_json_lcd_req32(char *jfile, LcddataReq32_t *req32) {
int comsv_json_lcd_req32(char *jfile, struct scn_data_fm *sp, LcddataReq32_t *req32) {
// mod FNSI-バグ 通信サーバ #10270 高 end
    int i, count;
    int s_flg, e_flg;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //long l_tim;
    time_t l_tim;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    char *bp;
    char dt[20], tm[20];
    char buf[255], sjis[255];
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;
	// add 障碍票-1仮想端末（酸素吸入）処置者異常 --趙-- start
	int s_flg_enter, e_flg_enter;
    char *ox_start;
    
    // add FNSI-バグ 通信サーバ #10270 高 start
    sp->oxygen_sta = 0;
    // add FNSI-バグ 通信サーバ #10270 高 end
	
    s_flg_enter = e_flg_enter = 0;
	// add 障碍票-1仮想端末（酸素吸入）処置者異常 --趙-- end
    s_flg = e_flg = 0;
    memset(req32, 0, sizeof(LcddataReq32_t));
    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // 酸素吸入
    array = json_object_get_array(root, "ListData");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        for ( i = 0; i < count; i++ ) {
            if ( i >= REQ50_MAX ) break;    // 愁訴処置の項目最大数まで
            obj = json_array_get_object (array, i);
            if ( obj == NULL ) continue;
			// add 障碍票-1仮想端末（酸素吸入）処置者異常 --趙-- start
			//bp = (char*)json_object_dotget_string(obj, "oxygen_start");
            ox_start = (char*)json_object_dotget_string(obj, "oxygen_start");
            if(ox_start && ox_start[0] != 0 ){
             s_flg = 0;
             e_flg = 1;
            }else{
             s_flg = 1;
             e_flg = 0;
            }
			// add 障碍票-1仮想端末（酸素吸入）処置者異常 --趙-- end
            bp = (char*)json_object_dotget_string(obj, "occur_date");
            if ( s_flg == 0 && bp != NULL && bp[0] != 0 ) {
                memset(buf, 0, sizeof(buf));
                strcpy(buf, bp);
                sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
                sprintf(tm, "%.8s", buf + 11);
                if ( str_time(dt, tm, &l_tim, 1) == 0 ) {
                    req32->s_time = l_tim;
					// mod 障碍票-1仮想端末（酸素吸入）処置者異常 --趙-- start
					//s_flg = 1;
                    s_flg_enter = 1;
					// mod 障碍票-1仮想端末（酸素吸入）処置者異常 --趙-- end
                }
                bp = (char*)json_object_dotget_string(obj, "treat_staff_name");
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    memset(sjis, 0, sizeof(sjis));
                    utf8tosjis(buf, sjis);
                    memcpy(req32->s_staff, sjis, sizeof(req32->s_staff));
                }
                // add FNSI-バグ 通信サーバ #10270 高 start
                if(i == 0) {
                    sp->oxygen_sta = 1;
                }
                // add FNSI-バグ 通信サーバ #10270 高 end
            }
            else if ( e_flg == 0 ) {
                req32->amount = comsv_json_dotget_short(obj, "oxygen_amount");
				// mod 障碍票-1仮想端末（酸素吸入）処置者異常 --趙-- start
				//e_flg = 1;
                e_flg_enter = 1;
				// mod 障碍票-1仮想端末（酸素吸入）処置者異常 --趙-- end
                bp = (char*)json_object_dotget_string(obj, "treat_staff_name");
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    memset(sjis, 0, sizeof(sjis));
                    utf8tosjis(buf, sjis);
                    memcpy(req32->e_staff, sjis, sizeof(req32->e_staff));
                }
            }
			// mod 障碍票-1仮想端末（酸素吸入）処置者異常 --趙-- start
			//if ( s_flg && e_flg ) break;
            if ( s_flg_enter && e_flg_enter ) break;
			// mod 障碍票-1仮想端末（酸素吸入）処置者異常 --趙-- end
        }
    }
    json_value_free(root_value);

    return 0;
}

/**
 * @fn int comsv_json_lcd_req33(char *jfile, short pos, LcddataReq33_t *req33)
 * @brief JSON文字列から仮想端末（検査結果）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[in] pos 表示位置（検査日）
 * @param[out] req33 仮想端末（検査結果）構造体
 * @return 検査日件数, -1:エラー
 */
int comsv_json_lcd_req33(char *jfile, short pos, LcddataReq33_t *req33) {
    int i, j, k;
    int count;
    int count_info;
    long cd;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //long e_tim;
    time_t e_tim;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    char *bp;
    char buf[1000];
    char dt[20], tm[10];
    JSON_Value *root_value;
    JSON_Object *root;
    JSON_Object *obj, *obj_info;
    JSON_Array *array, *array_info;
    // add FNSI-バグ 通信サーバ 高 start
    int idx;
    // add FNSI-バグ 通信サーバ 高 end

    memset(req33, 0, sizeof(LcddataReq33_t));
    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // 検査結果（FNW準拠）
    array = json_object_get_array( root, "ListData" );
    count = (int)json_array_get_count(array);
    if ( count < 0 ) count = 0;
    else if ( count > REQ33_DATE_MAX ) count = REQ33_DATE_MAX;
    for ( i = 0; i < count; i++ ) {
        if ( pos != i ) continue;
        obj = json_array_get_object (array, i);
        bp = (char*)json_object_dotget_string(obj, "resultExamDate");
        if ( bp != NULL && bp[0] != 0 ) {
            memset(buf, 0, sizeof(buf));
            strcpy(buf, bp);
            sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
            sprintf(tm, "%.8s", buf + 11);
            if ( str_time(dt, tm, &e_tim, 1) == 0 ) {
                req33->date = e_tim;
            }
        }
        req33->class = comsv_json_dotget_short(obj, "regOrderClass");
        array_info = json_object_get_array( obj, "examResultInfo" );
        count_info = (int)json_array_get_count(array_info);
        //mod FNSI-バグ 通信サーバ 高 start
        for ( j = 0, idx = 0; j < REQ33_MAX; j++ ) {
            req33->item_data[j] = (long)(0x80000000);   // 初期化
            if ( _comsvCache._examMst.item_cd[j] == 0 ) continue;
            if ( _comsvCache._examMst.console_class[j] == '0') continue;
            req33->item_cd[idx] = _comsvCache._examMst.item_cd[j];
            memcpy(req33->item_name[idx], _comsvCache._examMst.item_name[j], sizeof(req33->item_name[idx]));
            memcpy(req33->item_unit[idx], _comsvCache._examMst.unit[j], sizeof(req33->item_unit[idx]));
            req33->item_dec[idx] = _comsvCache._examMst.decimal[j];
            for ( k = 0; k < count_info; k++ ) {
                obj_info = json_array_get_object (array_info, k);
                cd = comsv_json_dotget_long(obj_info, "itemCd");
                if ( cd != req33->item_cd[idx] ) continue;
                bp = (char*)json_object_dotget_string(obj_info, "result");
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    req33->item_data[idx] = comsv_lcd_strlong(buf, req33->item_dec[idx]);
                    break;
                }
            }
            idx++;
            //mod FNSI-バグ 通信サーバ 高 劉 end
        }
    }
    json_value_free(root_value);

    return count;
}

/**
 * @fn int comsv_json_lcd_req36(char *jfile, LcddataReq36_t *req36)
 * @brief JSON文字列から仮想端末（ログ）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req36 仮想端末（ログ）構造体
 * @return 0:成功, -1:エラー
 */
int comsv_json_lcd_req36(char *jfile, LcddataReq36_t *req36) {
    int i, j;
    int staff;
    int count;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //long l_tim;
    time_t l_tim;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    char *bp;
    char dt[20], tm[10];
    char buf[1000], sjis[500];
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;

    memset(req36, 0, sizeof(LcddataReq36_t));
    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // ログ
    array = json_object_get_array(root, "ListData");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        for ( i = 0; i < count; i++ ) {
            if ( i >= REQ36_MAX ) break;
            obj = json_array_get_object (array, i);
            if ( obj == NULL ) continue;
            if ( i == 0 ) {
                req36->all_count = comsv_json_dotget_int(obj, "count");
            }
            bp = (char*)json_object_dotget_string(obj, "machineRecordMessage");
            if ( bp != NULL && bp[0] != 0 ) {
                memset(buf, 0, sizeof(buf));
                strcpy(buf, bp);
                memset(sjis, 0, sizeof(sjis));
                utf8tosjis(buf, sjis);
                memcpy(req36->message[req36->count], sjis, sizeof(req36->message[req36->count]));
            }
            bp = (char*)json_object_dotget_string(obj, "eventRegDate");
            if ( bp != NULL && bp[0] != 0 ) {
                memset(buf, 0, sizeof(buf));
                strcpy(buf, bp);
                sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
                sprintf(tm, "%.8s", buf + 11);
                if ( str_time(dt, tm, &l_tim, 1) == 0 ) {
                    req36->date[req36->count] = l_tim;
                    req36->count++;
                }
            }
        }
    }
    json_value_free(root_value);

    return 0;
}

/**
 * @fn int comsv_json_lcd_req38(char *jfile, LcddataReq38_t *req38)
 * @brief JSON文字列から仮想端末（体重トレンド）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req38 仮想端末（体重トレンド）構造体
 * @return 0:成功, -1:エラー
 */
int comsv_json_lcd_req38(char *jfile, LcddataReq38_t *req38) {
    int i;
    int count;
    char *bp;
    char buf[255];
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;

    memset(req38, 0, sizeof(LcddataReq38_t));
    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // 体重トレンド
    array = json_object_get_array(root, "ListData");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        for ( i = 0; i < count; i++ ) {
            if ( i >= REQ38_MAX ) break;
            obj = json_array_get_object (array, i);
            if ( obj == NULL ) continue;
            bp = (char*)json_object_dotget_string(obj, "treatDate");
            if ( bp != NULL && bp[0] != 0 ) {
                memset(buf, 0, sizeof(buf));
                sprintf(buf, "%.4s/%.2s/%.2s", bp, bp + 4, bp + 6);
                memcpy(req38->date[i], buf, sizeof(req38->date[i]));
                bp = (char*)json_object_dotget_string(obj, "weightBefore");
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    req38->bef_weight[i] = comsv_lcd_strshort(buf, 2);
                }
                bp = (char*)json_object_dotget_string(obj, "weightAfter");
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    req38->aft_weight[i] = comsv_lcd_strshort(buf, 2);
                }
                bp = (char*)json_object_dotget_string(obj, "weightDecreased");
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    req38->loss[i] = comsv_lcd_strshort(buf, 2);
                }
                bp = (char*)json_object_dotget_string(obj, "dw");
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    req38->dw[i] = comsv_lcd_strshort(buf, 2);
                }
            }
        }
        req38->count = i;
        if ( req38->count >= REQ38_MAX ) {
            // 前回後体重を取得する為、データは最大で15件取得
            // 仮想端末の表示最大件数は14件まで
            req38->count = REQ38_MAX - 1;
        }
        for ( i = 0; i < req38->count; i++ ) {
            if ( req38->date[i][0] == 0 ) break;
            // 前回後体重
            req38->pre_weight[i] = req38->aft_weight[i + 1];
            // 増加量
            req38->gain[i] = req38->bef_weight[i] - req38->pre_weight[i];
        }
    }
    json_value_free(root_value);

    return 0;
}

/**
 * @fn int comsv_json_lcd_req40(char *jfile, int thread_no, struct scn_data_fm *sp, LcddataReq40_t *req40)
 * @brief JSON文字列から仮想端末（透析日報）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[in] thread_no スレッド番号
 * @param[in,out] sp 装置制御データ
 * @param[out] req40 仮想端末（透析日報）構造体
 * @return 0:成功, -1:エラー
 */
int comsv_json_lcd_req40(char *jfile, int thread_no, struct scn_data_fm *sp, LcddataReq40_t *req40) {
    int i, no, cd;
    short num;
    short s_val[3];
    char *bp;
    char buf[200];
    char wrk[100];
    char sjis[100];
    char name[200];
    char value[200];
    char unit[200];
	char fpath[64];
    unsigned char *data;
    static char *blood_abo[5] = { "不明", "A型", "B型", "AB型", "O型" };
    static char *blood_rh[3] = { "不明", "Rh+", "Rh-" };
    JSON_Value *root_value;
    JSON_Object *root;

    memset(req40, 0, sizeof(LcddataReq40_t));
    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // モニタデータ現在値
    data = packetInfoList[thread_no].cMoniData+12;
    // JSON文字列から透析日報用条件データを格納する
    comsv_work_fpath(sp->dev_no, WORK_DEV_COND, fpath);
    i = comsv_json_dev_cond_daily(fpath, s_val);
	printf("comsv_json_dev_cond_daily = [%d]\n", i);

    // 透析日報
    for ( no = 1, i = 0; no <= REQ40_MAX; no++, i++ ) {
        memset(sjis, 0, sizeof(sjis));
        sprintf(wrk, "report%d.cd", no);
        cd = comsv_json_dotget_int(root, wrk);
        if ( cd <= 0  ) continue;
        if ( no > req40->count ) req40->count = no;
        memset(name, 0, sizeof(name));
        sprintf(wrk, "report%d.name", no);
        bp = (char*)json_object_dotget_string(root, wrk);
        if ( bp != NULL && bp[0] != 0 ) {
            strcpy(name, bp);
        }
        memset(value, 0, sizeof(value));
        sprintf(wrk, "report%d.value", no);
        bp = (char*)json_object_dotget_string(root, wrk);
        if ( bp != NULL && bp[0] != 0 ) {
            strcpy(value, bp);
        }
        memset(unit, 0, sizeof(unit));
        sprintf(wrk, "report%d.unit", no);
        bp = (char*)json_object_dotget_string(root, wrk);
        if ( bp != NULL && bp[0] != 0 ) {
            strcpy(unit, bp);
        }
        memcpy(req40->name[i], _comsvCache._comsvSet.lcd_report[i].name, sizeof(req40->name[i]));
        //mod FNSI-バグ 通信サーバ 高 start
        // if ( cd == 23 || (cd >= 28 && cd <=31) || cd == 43 || (cd >= 51 && cd <=55) ) {
        if ( cd == 23 || (cd >= 28 && cd <= 31) || cd == 43 || (cd >= 51 && cd <= 55) || (cd >= 87 && cd <= 89) ) {
        //mod FNSI-バグ 通信サーバ 高 end
            // name
            memset(buf, 0, sizeof(buf));
            sprintf(buf, "%s", name);
            //mod FNSI-バグ 通信サーバ 高 start
            // if ( cd == 28 && buf[0] == 0 ) {
            if ( (cd == 28 || (cd >= 87 && cd <= 89)) && buf[0] == 0 ) {
            //mod FNSI-バグ 通信サーバ 高 end
                strcpy(buf, "未登録");
            }
            utf8tosjis(buf, sjis);
            memcpy(req40->data[i], sjis, sizeof(req40->data[i]));
        }
        else if ( cd >= 32 && cd <=35 ) {
            // value + ' ' + unit
            if ( cd == 35 ) {
                // 合計は小数点を表示しない
                num = comsv_lcd_strshort(value, 0);
                dsp_s_form(value, 1, 0, num);
            }
            memset(buf, 0, sizeof(buf));
            sprintf(buf, "%s %s", value, unit);
            utf8tosjis(buf, sjis);
            memcpy(req40->data[i], sjis, sizeof(req40->data[i]));
        }
        else if ( cd >= 57 ) {
            // name + ' ' + value
            memset(buf, 0, sizeof(buf));
            sprintf(buf, "%s %s", name, value);
            utf8tosjis(buf, sjis);
            memcpy(req40->data[i], sjis, sizeof(req40->data[i]));
        }
        else if ( cd == 3 || cd == 4 || cd == 9 || cd == 15 || cd == 17 || cd == 24 ||
                  cd == 25 || (cd >= 36 && cd <=38) || (cd >= 44 && cd <=48) ) {
            memset(buf, 0, sizeof(buf));
            if ( cd == 37 && sp->dial_start_date ) {
                // 除水速度（運転開始以降）
                num = hl_chg( *(short*)(data + (6 * 2)) );
                if ( num != (short)(0x8000) ) {
                    dsp_s_form(buf, 1, 2, num);
                }
            }
            else if ( value[0] != 0 ) {
                num = comsv_lcd_strshort(value, 2);
                dsp_s_form(buf, 1, 2, num);
            }
            memcpy(req40->data[i], buf, sizeof(req40->data[i]));
        }
        else if ( cd == 21 ) {
            memset(buf, 0, sizeof(buf));
            // 実績除水量
            if ( (sp->mon_sta & 1) ) {
                // 運転中
                num = hl_chg( *(short*)(data + (5 * 2)) );
                if ( num != (short)(0x8000) ) {
                    dsp_s_form(buf, 1, 2, num);
                }
            }
            else if ( sp->dial_end_date && value[0] != 0 ) {
                // 運転終了以降
                num = comsv_lcd_strshort(value, 2);
                dsp_s_form(buf, 1, 2, num);
            }
            memcpy(req40->data[i], buf, sizeof(req40->data[i]));
        }
        else if ( cd == 22 ) {
            memset(buf, 0, sizeof(buf));
            // 実績血液循環量（FNW仕様で運転中の血流量積算値を使う）
            if ( (sp->mon_sta & 1) ) {
                // 運転中
                num = hl_chg( *(short*)(data + (69 * 2)) );
                if ( num != (short)(0x8000) ) {
                    dsp_s_form(buf, 1, 1, num);
                }
            }
            else if ( sp->dial_end_date && value[0] != 0 ) {
                // 運転終了以降
                num = comsv_lcd_strshort(value, 1);
                dsp_s_form(buf, 1, 1, num);
            }
            memcpy(req40->data[i], buf, sizeof(req40->data[i]));
        }
        else if ( cd == 14 || cd == 41 || cd == 42 ) {
            memset(buf, 0, sizeof(buf));
            if ( cd == 14 ) num = s_val[0];
            else num = s_val[cd - 41 + 1];
            if ( num != (short)(0x8000) ) {
                dsp_s_form(buf, 1, 2, num);
            }
            memcpy(req40->data[i], buf, sizeof(req40->data[i]));
        }
        else if ( cd == 19 || cd == 39 || cd == 40 ) {
            memset(buf, 0, sizeof(buf));
            if ( value[0] != 0 ) {
                num = comsv_lcd_strshort(value, 1);
                dsp_s_form(buf, 1, 1, num);
            }
            memcpy(req40->data[i], buf, sizeof(req40->data[i]));
        }
        else if ( cd == 26 ) {
            // 血液型
            num = (short)atoi(value);
            sprintf(buf, "%s", blood_abo[num % 5]);
            utf8tosjis(buf, sjis);
            memcpy(req40->data[i], sjis, sizeof(req40->data[i]));
        }
        else if ( cd == 27 ) {
            // ＲＨ
            num = (short)atoi(value);
            sprintf(buf, "%s", blood_rh[num % 3]);
            utf8tosjis(buf, sjis);
            memcpy(req40->data[i], sjis, sizeof(req40->data[i]));
        }
        else {
            // value
            memset(buf, 0, sizeof(buf));
            if ( cd == 1 || cd == 2 ) {
                memcpy(buf, value + 5, 11);
                buf[2] = '/';
            }
            else if ( cd == 16 ) {
                if ( sp->dial_end_date == 0 ) {
                    // 透析時間（運転終了前）
                    sprintf(buf, "%02d:%02d", sp->dial_time / 60, sp->dial_time % 60);
                }
                else {
                    // 透析時間（運転終了後）
                    num = atoi(value);
                    sprintf(buf, "%02d:%02d", num / 60, num % 60);
                }
            }
            else if ( cd == 18 ) {
                // 血流量
                sprintf(buf, "%5s mL/min", value);
            }
            else {
                sprintf(buf, "%s", value);
            }
            memcpy(req40->data[i], buf, sizeof(req40->data[i]));
        }
    }

    json_value_free(root_value);

    return 0;
}

/**
 * @fn int comsv_json_lcd_req41(char *jfile, LcddataReq41_t *req41)
 * @brief JSON文字列から仮想端末（投与薬剤）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req41 仮想端末（投与薬剤）構造体
 * @return 0:成功, -1:エラー
 */
int comsv_json_lcd_req41(char *jfile, LcddataReq41_t *req41) {
    int i, no;
    int count;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //long l_tim;
    time_t l_tim;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    char *bp;
    char dt[20], tm[10];
    char buf[1000], sjis[500];
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;

    memset(req41, 0, sizeof(LcddataReq41_t));
    for ( i = 0; i < ALERT_NUM; i++ ) req41->alert_time[i] = -1;
    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // 投与薬剤
    array = json_object_get_array(root, "ListData");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        for ( i = 0; i < count; i++ ) {
            if ( i >= REQ41_MAX ) break;
            obj = json_array_get_object (array, i);
            if ( obj == NULL ) continue;
            no = comsv_json_dotget_int(obj, "sno");
            bp = (char*)json_object_dotget_string(obj, "name");
            if ( bp != NULL && bp[0] != 0 ) {
                req41->no[req41->count] = no;
                memset(buf, 0, sizeof(buf));
                strcpy(buf, bp);
                memset(sjis, 0, sizeof(sjis));
                utf8tosjis(buf, sjis);
                memcpy(req41->name[req41->count], sjis, sizeof(req41->name[req41->count]));
                bp = (char*)json_object_dotget_string(obj, "amount");
                if ( bp != NULL && bp[0] != 0 ) {
                    // mod お知らせで装置に送信するデータが一定でない。高 start
                    // sprintf(buf, "%8s", bp);
                    sprintf(buf, "%-8s", bp);
                    // mod お知らせで装置に送信するデータが一定でない。高 end
                    memcpy(req41->amount[req41->count], buf, sizeof(req41->amount[req41->count]));
                }
                bp = (char*)json_object_dotget_string(obj, "unit");
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    memset(sjis, 0, sizeof(sjis));
                    utf8tosjis(buf, sjis);
                    memcpy(req41->unit[req41->count], sjis, sizeof(req41->unit[req41->count]));
                }
                bp = (char*)json_object_dotget_string(obj, "progressCd");
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    memcpy(req41->progress[req41->count], buf, sizeof(req41->progress[req41->count]));
                }
                bp = (char*)json_object_dotget_string(obj, "isMedicated");
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    if ( buf[0] == '1' ) req41->medicated[req41->count] = buf[0];
                }
                // mod FNSI-バグ 通信サーバ 高 start
                // bp = (char*)json_object_dotget_string(obj, "effectFlg");
                req41->effectFlg[req41->count] = comsv_json_dotget_int(obj, "effectFlg") + '0';
                //if ( bp != NULL && bp[0] != 0 ) {
                //    memset(buf, 0, sizeof(buf));
                //    strcpy(buf, bp);
                // add FNSI-バグ 通信サーバ 高 start
                //    req41->effectFlg[req41->count] = buf[0];
                // add FNSI-バグ 通信サーバ 高 end
                // if ( buf[0] == '1' ) {
                if ( req41->effectFlg[req41->count]  == '1' ) {
                    bp = (char*)json_object_dotget_string(obj, "effectDate");
                    if ( bp != NULL && bp[0] != 0 ) {
                        memset(buf, 0, sizeof(buf));
                        strcpy(buf, bp);
                        sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
                        sprintf(tm, "%.8s", buf + 11);
                        if ( str_time(dt, tm, &l_tim, 1) == 0 ) {
                            req41->time[req41->count] = l_tim;
                        }
                    }
                }
                //}
                // mod FNSI-バグ 通信サーバ 高 end
                if ( memcmp(req41->progress[req41->count], "002", 3) == 0 ) {
                    req41->alert_time[req41->count] = comsv_json_dotget_int(obj, "alertTime");
                }
                else {
                    req41->alert_time[req41->count] = -1;
                }
                // add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 start
                bp = (char*)json_object_dotget_string(obj, "isAlert");
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    req41->alert[req41->count] = buf[0];
                }
                // add 投与タイミングお知らせで透析後のお知らせが発火しない。治療終了にて透析後のお知らせを発火させる。 高 end
                req41->count++;
            }
        }
    }
    json_value_free(root_value);

    return 0;
}

/**
 * @fn comsv_json_lcd_req41_getname(char *jfile, int no, char *name)
 * @brief JSON文字列から仮想端末（投与薬剤）の薬剤名称を取得する
 * @param[in] jfile JSONファイル名
 * @param[in] no 薬剤No
 * @param[out] name 薬剤名称（加工無し）
 * @return 0:成功, -1:エラー
 */
int comsv_json_lcd_req41_getname(char *jfile, int no, char *name) {
    int i, count;
    int ret, sno;
    char *bp;
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;

    ret = -1;
    name[0] = 0;
    if ( jfile == "" ) return ret;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return ret;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return ret;
    }

    // 投与薬剤
    array = json_object_get_array(root, "ListData");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        for ( i = 0; i < count; i++ ) {
            if ( i >= REQ41_MAX ) break;
            obj = json_array_get_object (array, i);
            if ( obj == NULL ) continue;
            sno = comsv_json_dotget_int(obj, "sno");
            if ( no == sno ) {
                bp = (char*)json_object_dotget_string(obj, "name");
                if ( bp != NULL && bp[0] != 0 ) {
                    strcpy(name, bp);
                    ret = 0;
                }
                break;
            }
        }
    }
    json_value_free(root_value);

    return ret;
}

// add FNSI-バグ 通信サーバ 高 start
/**
* @fn void comsv_effectFlg_check(struct scn_data_fm *sp, LcddataReq41_t * req41)
* @brief 投薬実施済情報チェック
* @param[in,out] sp 装置制御データ
* @param[in] req41 LcddataReq41_tデータ
* @return ：無
*/
void comsv_effectFlg_check(struct scn_data_fm *sp, LcddataReq41_t * req41)
{
    int i;
    
    for ( i = 0; i <= req41->count; i++ ) {
        if ( req41->effectFlg[i] == '1' ) {
            // ディレイなしで投与タイミング通知
            sp->alert_time[i] = -1;
        }
    }
}
// add FNSI-バグ 通信サーバ 高 end

/**
 * @fn int comsv_json_lcd_req42(char *jfile, LcddataReq42_t *req42)
 * @brief JSON文字列から仮想端末（抗凝固剤）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req42 仮想端末（抗凝固剤）構造体
 * @return 0:成功, -1:エラー
 */
int comsv_json_lcd_req42(char *jfile, LcddataReq42_t *req42) {
    char *bp;
    char buf[200], sjis[100];
    JSON_Value *root_value;
    JSON_Object *root;

    memset(req42, 0, sizeof(LcddataReq42_t));
    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // 抗凝固剤
    bp = (char*)json_object_dotget_string(root, "name");
    if ( bp != NULL && bp[0] != 0 ) {
        memset(buf, 0, sizeof(buf));
        strcpy(buf, bp);
        memset(sjis, 0, sizeof(sjis));
        utf8tosjis(buf, sjis);
        memcpy(req42->name, sjis, sizeof(req42->name));
        bp = (char*)json_object_dotget_string(root, "unit");
        if ( bp != NULL && bp[0] != 0 ) {
            memset(buf, 0, sizeof(buf));
            strcpy(buf, bp);
            memset(sjis, 0, sizeof(sjis));
            utf8tosjis(buf, sjis);
            memcpy(req42->unit, sjis, sizeof(req42->unit));
        }
        bp = (char*)json_object_dotget_string(root, "value1");
        if ( bp != NULL && bp[0] != 0 ) {
            memset(buf, 0, sizeof(buf));
            strcpy(buf, bp);
            req42->value1 = atof(buf);
        }
        bp = (char*)json_object_dotget_string(root, "value2");
        if ( bp != NULL && bp[0] != 0 ) {
            memset(buf, 0, sizeof(buf));
            strcpy(buf, bp);
            req42->value2 = atof(buf);
        }
        bp = (char*)json_object_dotget_string(root, "value3");
        if ( bp != NULL && bp[0] != 0 ) {
            memset(buf, 0, sizeof(buf));
            strcpy(buf, bp);
            req42->value3 = atof(buf);
        }
    }
    json_value_free(root_value);

    return 0;
}

/**
 * @fn int comsv_json_lcd_req44(char *jfile, LcddataReq45_t *req44)
 * @brief JSON文字列から仮想端末（禁忌）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req44 仮想端末（禁忌）構造体
 * @return 0:成功, -1:エラー
 */
int comsv_json_lcd_req44(char *jfile, LcddataReq44_t *req44) {
    int i;
    int count;
    int dsp_no;
    char *bp;
    char buf[1000], sjis[500];
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;

    memset(req44, 0, sizeof(LcddataReq44_t));
    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // 患者禁忌情報
    array = json_object_get_array(root, "ListData");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        for ( i = 0; i < count; i++ ) {
            obj = json_array_get_object (array, i);
            // mod FNSI-バグ 通信サーバ 高 start
            // bp = (char*)json_object_dotget_string(obj, "dispOrder");
            dsp_no = comsv_json_dotget_int(obj, "dispOrder");
            // if ( bp != NULL && bp != "" ) {
            //    memset(buf, 0, sizeof(buf));
            //    strcpy(buf, bp);
            //    dsp_no = atoi(buf);
            if ( dsp_no <= 0 || dsp_no > REQ44_MAX ) continue;
            bp = (char*)json_object_dotget_string(obj, "content");
            if ( bp != NULL && bp != "" ) {
                memset(buf, 0, sizeof(buf));
                strcpy(buf, bp);
                memset(sjis, 0, sizeof(sjis));
                utf8tosjis(buf, sjis);
                memcpy(req44->name[dsp_no - 1], sjis, sizeof(req44->name[dsp_no - 1]));
            }
            req44->count++;
            if ( req44->count >= REQ44_MAX ) break;
            //}
            // mod FNSI-バグ 通信サーバ 高 end
        }
    }
    json_value_free(root_value);

    return 0;
}

/**
 * @fn int comsv_json_lcd_req45(char *jfile, LcddataReq45_t *req45)
 * @brief JSON文字列から仮想端末（メモ）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req45 仮想端末（メモ）構造体
 * @return 0:成功, -1:エラー
 */
int comsv_json_lcd_req45(char *jfile, LcddataReq45_t *req45) {
    int i;
    int count;
    char *bp;
    char buf[1000], sjis[500];
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;

    memset(req45, ' ', sizeof(LcddataReq45_t));
    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // 患者メモ情報
    memset(buf, 0, sizeof(buf));
    array = json_object_get_array(root, "ListData");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        /* 全件、結合する場合
        for ( i = 0; i < count; i++ ) {
            obj = json_array_get_object (array, i);
            bp = (char*)json_object_dotget_string(obj, "content");
            if ( bp != NULL && bp != "" ) {
                strcat(buf, bp);
                strcat(buf, "\r\n");
            }
        }
        */
        /* 最初の1件を患者メモとして扱う */
        if ( count > 0 ) {
            obj = json_array_get_object (array, 0);
            bp = (char*)json_object_dotget_string(obj, "content");
            if ( bp != NULL && bp != "" ) {
                if ( strlen(bp) < sizeof(buf) ) {
                    strcpy(buf, bp);
                }
            }
        }
    }
    memset(sjis, 0, sizeof(sjis));
    utf8tosjis(buf, sjis);
    memcpy(req45->memo, sjis, sizeof(req45->memo));
    json_value_free(root_value);

    return 0;
}

/**
 * @fn int comsv_json_lcd_req46(char *jfile, short type, short gno, LcddataReq46_t *req46)
 * @brief JSON文字列から仮想端末（検査グラフ）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[in] type グラフ種類（0:通常,1:複合）
 * @param[in] gno グラフ番号（1〜5）
 * @param[out] req46 仮想端末（検査グラフ）構造体
 * @return 検査日件数, -1:エラー
 */
int comsv_json_lcd_req46(char *jfile, short type, short gno, LcddataReq46_t *req46) {
    int i, j, k;
    int idx;
    int count;
    int count_info;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //long e_tim;
    time_t e_tim;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    long cd;
    char *bp;
    char buf[1000];
    char dt[20], tm[10];
    JSON_Value *root_value;
    JSON_Object *root;
    JSON_Object *obj, *obj_info;
    JSON_Array *array, *array_info;

    memset(req46, 0, sizeof(LcddataReq46_t));
    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // 検査グラフ
    gno--;
    if ( gno < 0 || gno >= 5 ) gno = 0;
    array = json_object_get_array( root, "ListData" );
    count = (int)json_array_get_count(array);
    if ( count < 0 ) count = 0;
    else if ( count > REQ46_DATE_MAX ) count = REQ46_DATE_MAX;
    for ( i = 0; i < count; i++ ) {
        obj = json_array_get_object (array, i);
        if ( i == 0 ) {
            bp = (char*)json_object_dotget_string(obj, "resultExamDate");
            if ( bp != NULL && bp[0] != 0 ) {
                memset(buf, 0, sizeof(buf));
                strcpy(buf, bp);
                sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
                sprintf(tm, "%.8s", buf + 11);
                if ( str_time(dt, tm, &e_tim, 1) == 0 ) {
                    req46->date = e_tim;
                }
            }
            req46->class = comsv_json_dotget_short(obj, "regOrderClass");
            if ( req46->class < 0 || req46->class > 1) req46->class = 0;
            if ( type == 0 ) {
                // 通常
                for ( j = 0, idx = 0; j < 3; j++ ) {
                    cd = _comsvCache._comsvSet.lcd_graph1[gno].code[j];
                    if ( cd <= 0 ) continue;    // 検査グラフ１設定なし
                    for ( k = 0; k < REQ33_MAX; k++ ) {
                        if ( cd == _comsvCache._examMst.item_cd[k] ) break;
                    }
                    if ( k >= REQ33_MAX ) continue; // 検査項目マスタに対象なし
                    req46->item_cd[idx] = cd;
                    memcpy(req46->item_name[idx], _comsvCache._examMst.item_name[k], sizeof(req46->item_name[idx]));
                    memcpy(req46->item_unit[idx], _comsvCache._examMst.unit[k], sizeof(req46->item_unit[idx]));
                    req46->item_dec[idx] = _comsvCache._examMst.decimal[k];
                    req46->item_upper[idx] = _comsvCache._examMst.graph_upper[k];
                    req46->item_lower[idx] = _comsvCache._examMst.graph_lower[k];
                    idx++;
                }
            }
            else {
                // 複合
                for ( j = 0, idx = 0; j < 4; j++ ) {
                    if ( j < 2 ) {
                        // 折れ線グラフ
                        if ( j == 0 ) {
                            cd = _comsvCache._comsvSet.lcd_graph2[gno].code1[req46->class];
                        }
                        else {
                            cd = _comsvCache._comsvSet.lcd_graph2[gno].code2[req46->class];
                        }
                    }
                    else {
                        // 棒グラフ
                        if ( j == 2 ) {
                            cd = _comsvCache._comsvSet.lcd_graph2[gno].code1[2];
                        }
                        else {
                            cd = _comsvCache._comsvSet.lcd_graph2[gno].code2[2];
                        }
                    }
                    if ( cd <= 0 ) continue;    // 検査グラフ２設定なし
                    for ( k = 0; k < REQ33_MAX; k++ ) {
                        if ( cd == _comsvCache._examMst.item_cd[k] ) break;
                    }
                    if ( k >= REQ33_MAX ) continue; // 検査項目マスタに対象なし
                    req46->item_cd[idx] = cd;
                    // add FNSI-バグ 通信サーバ 高 start
                    if ( j < 2 ) {
                    // add FNSI-バグ 通信サーバ 高 end
                        if ( (j % 2) == 0 ) {
                            memcpy(req46->item_name[idx], _comsvCache._comsvSet.lcd_graph2[gno].graph1_name, sizeof(req46->item_name[idx]));
                        }
                        else {
                            memcpy(req46->item_name[idx], _comsvCache._comsvSet.lcd_graph2[gno].graph2_name, sizeof(req46->item_name[idx]));
                        }
                    }
                    // add FNSI-バグ 通信サーバ 高 start
                    else {
                        // 棒グラフ
                        memcpy(req46->item_name[idx], _comsvCache._examMst.item_name[k], sizeof(req46->item_name[idx]));
                    }
                    // add FNSI-バグ 通信サーバ 高 end
                    memcpy(req46->item_unit[idx], _comsvCache._examMst.unit[k], sizeof(req46->item_unit[idx]));
                    req46->item_dec[idx] = _comsvCache._examMst.decimal[k];
                    req46->item_upper[idx] = _comsvCache._examMst.graph_upper[k];
                    req46->item_lower[idx] = _comsvCache._examMst.graph_lower[k];
                    // add FNSI-バグ 通信サーバ 高 start
                    if ( j < 2 ) {
                        // 折れ線グラフ
                        req46->graph_type[idx] = 1;
                    }
                    else {
                        // 棒グラフ
                        req46->graph_type[idx] = 2;
                    }
                    // add FNSI-バグ 通信サーバ 高 end
                    idx++;
                }
            }
            req46->count = idx;
        }
        array_info = json_object_get_array( obj, "examResultInfo" );
        count_info = (int)json_array_get_count(array_info);
        for ( j = 0; j < req46->count; j++ ) {
            // mod FNSI-バグ 通信サーバ 高 start
            if( req46->graph_type[j] == 2 ) {
                req46->item_data[j][i] = (long)(0x0);   // 初期化
            }
            else {
                req46->item_data[j][i] = (long)(0x7fffffff);   // 初期化
            }
            // mod FNSI-バグ 通信サーバ 高 end
            for ( k = 0; k < count_info; k++ ) {
                obj_info = json_array_get_object (array_info, k);
                cd = comsv_json_dotget_long(obj_info, "itemCd");
                if ( cd != req46->item_cd[j] ) continue;
                bp = (char*)json_object_dotget_string(obj_info, "result");
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    req46->item_data[j][i] = comsv_lcd_strlong(buf, req46->item_dec[j]);
                }
                break;
            }
        }
    }
    json_value_free(root_value);

    return count;
}

/**
 * @fn int comsv_json_lcd_req47(char *jfile, short pos, LcddataReq47_t *req47)
 * @brief JSON文字列から仮想端末（レーダーチャート）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[in] pos 表示位置（検査日）
 * @param[out] req47 仮想端末（レーダーチャート）構造体
 * @return 検査日件数, -1:エラー
 */
int comsv_json_lcd_req47(char *jfile, short pos, LcddataReq47_t *req47) {
    int i, j, k;
    int idx;
    int count;
    int count_info;
    long cd;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //long e_tim;
    time_t e_tim;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    char *bp;
    char buf[1000];
    char dt[20], tm[10];
    JSON_Value *root_value;
    JSON_Object *root;
    JSON_Object *obj, *obj_info;
    JSON_Array *array, *array_info;

    memset(req47, 0, sizeof(LcddataReq47_t));
    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // レーダーチャート
    array = json_object_get_array( root, "ListData" );
    count = (int)json_array_get_count(array);
    if ( count < 0 ) count = 0;
    else if ( count > REQ47_DATE_MAX ) count = REQ47_DATE_MAX;
    for ( i = 0; i < count; i++ ) {
        if ( pos != i ) continue;
        obj = json_array_get_object (array, i);
        bp = (char*)json_object_dotget_string(obj, "resultExamDate");
        if ( bp != NULL && bp[0] != 0 ) {
            memset(buf, 0, sizeof(buf));
            strcpy(buf, bp);
            sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
            sprintf(tm, "%.8s", buf + 11);
            if ( str_time(dt, tm, &e_tim, 1) == 0 ) {
                req47->date = e_tim;
            }
        }
        req47->class = comsv_json_dotget_short(obj, "regOrderClass");
        array_info = json_object_get_array( obj, "examResultInfo" );
        count_info = (int)json_array_get_count(array_info);
        for ( j = 0, idx = 0; j < REQ47_MAX; j++ ) {
            cd = _comsvCache._comsvSet.lcd_radar[j].code;
			if ( cd <= 0 ) continue;    // レーダーチャート設定なし
            for ( k = 0; k < REQ33_MAX; k++ ) {
                if ( cd == _comsvCache._examMst.item_cd[k] ) break;
            }
            if ( k >= REQ33_MAX ) continue; // 検査項目マスタに対象なし
            req47->item_cd[idx] = cd;
            memcpy(req47->item_name[idx], _comsvCache._examMst.item_name[k], sizeof(req47->item_name[idx]));
            memcpy(req47->item_unit[idx], _comsvCache._examMst.unit[k], sizeof(req47->item_unit[idx]));
            req47->item_dec[idx] = _comsvCache._examMst.decimal[k];
            req47->item_upper[idx] = _comsvCache._examMst.graph_upper[k];
            req47->item_lower[idx] = _comsvCache._examMst.graph_lower[k];
			req47->item_data[idx] = (long)(0x7fffffff);   // 初期化
            for ( k = 0; k < count_info; k++ ) {
                obj_info = json_array_get_object (array_info, k);
                cd = comsv_json_dotget_long(obj_info, "itemCd");
    			if ( cd != req47->item_cd[idx] ) continue;
                bp = (char*)json_object_dotget_string(obj_info, "result");
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    req47->item_data[idx] = comsv_lcd_strlong(buf, req47->item_dec[idx]);
                }
                break;
            }
            idx++;
        }
        req47->count = idx;
    }
    json_value_free(root_value);

    return count;
}

/**
 * @fn int comsv_json_lcd_req50(char *jfile, LcddataReq50_t *req50)
 * @brief JSON文字列から仮想端末（愁訴処置）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req50 仮想端末（愁訴処置）構造体
 * @return 0:成功, -1:エラー
 */
int comsv_json_lcd_req50(char *jfile, LcddataReq50_t *req50) {
    int i, count;
    char *bp;
    char buf[255], sjis[255];
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;

    memset(req50, 0, sizeof(LcddataReq50_t));
    memset(req50->c_name, ' ', sizeof(req50->c_name));
    memset(req50->t_name, ' ', sizeof(req50->t_name));

    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // 愁訴
    obj = json_object_get_object (root, "compOrderSettings");
    if ( obj != NULL ) {
        array = json_object_get_array(obj, "items");
        if ( array != NULL ) {
            count = (int)json_array_get_count(array);
            for ( i = 0; i < count; i++ ) {
                if ( i >= REQ50_MAX ) break;
                obj = json_array_get_object (array, i);
                if ( obj == NULL ) continue;
                req50->c_code[i] = comsv_json_dotget_int(obj, "code");
                bp = (char*)json_object_dotget_string(obj, "name");
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    memset(sjis, 0, sizeof(sjis));
                    utf8tosjis(buf, sjis);
                    memcpy(req50->c_name[i], sjis, sizeof(req50->c_name[i]));
                }
            }
        }
    }
    // 処置
    obj = json_object_get_object (root, "treatOrderSettings");
    if ( obj != NULL ) {
        array = json_object_get_array(obj, "items");
        if ( array != NULL ) {
            count = (int)json_array_get_count(array);
            for ( i = 0; i < count; i++ ) {
                if ( i >= REQ50_MAX ) break;
                obj = json_array_get_object (array, i);
                if ( obj == NULL ) continue;
                req50->t_code[i] = comsv_json_dotget_int(obj, "code");
                bp = (char*)json_object_dotget_string(obj, "name");
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    memset(sjis, 0, sizeof(sjis));
                    utf8tosjis(buf, sjis);
                    memcpy(req50->t_name[i], sjis, sizeof(req50->t_name[i]));
                }
            }
        }
    }
    json_value_free(root_value);

    return 0;
}

/**
 * @fn int comsv_json_lcd_req51(char *jfile, LcddataReq51_t *req51)
 * @brief JSON文字列から仮想端末（穿刺／回収／担当）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req51 仮想端末（穿刺／回収／担当）構造体
 * @return 0:成功, -1:エラー
 */
int comsv_json_lcd_req51(char *jfile, LcddataReq51_t *req51) {
    int i;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //long l_tim;
    time_t l_tim;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    char *bp;
    char buf[200], sjis[100];
    char dt[20], tm[10];
    JSON_Value *root_value;
    JSON_Object *root;

    memset(req51, 0, sizeof(LcddataReq51_t));
    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    for ( i = 0; i < 2; i++ ) {
        // 穿刺者情報
        sprintf(buf, "puserDate%d", i+1);
        bp = (char*)json_object_dotget_string(root, buf);
        if ( bp != NULL && bp[0] != 0 ) {
            memset(buf, 0, sizeof(buf));
            strcpy(buf, bp);
            sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
            sprintf(tm, "%.8s", buf + 11);
            if ( str_time(dt, tm, &l_tim, 1) == 0 ) {
                req51->p_time[i] = l_tim;
                sprintf(buf, "puserName%d", i + 1);
                bp = (char*)json_object_dotget_string(root, buf);
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    memset(sjis, 0, sizeof(sjis));
                    utf8tosjis(buf, sjis);
                    memcpy(req51->p_name[i], sjis, sizeof(req51->p_name[i]));
                }
            }
        }
        // 回収（返血）者情報
        sprintf(buf, "ruserDate%d", i+1);
        bp = (char*)json_object_dotget_string(root, buf);
        if ( bp != NULL && bp[0] != 0 ) {
            memset(buf, 0, sizeof(buf));
            strcpy(buf, bp);
            sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
            sprintf(tm, "%.8s", buf + 11);
            if ( str_time(dt, tm, &l_tim, 1) == 0 ) {
                req51->r_time[i] = l_tim;
                sprintf(buf, "ruserName%d", i + 1);
                bp = (char*)json_object_dotget_string(root, buf);
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    memset(sjis, 0, sizeof(sjis));
                    utf8tosjis(buf, sjis);
                    memcpy(req51->r_name[i], sjis, sizeof(req51->r_name[i]));
                }
            }
        }
        // 担当者情報
        sprintf(buf, "cuserDate%d", i+1);
        bp = (char*)json_object_dotget_string(root, buf);
        if ( bp != NULL && bp[0] != 0 ) {
            memset(buf, 0, sizeof(buf));
            strcpy(buf, bp);
            sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
            sprintf(tm, "%.8s", buf + 11);
            if ( str_time(dt, tm, &l_tim, 1) == 0 ) {
                req51->c_time[i] = l_tim;
                sprintf(buf, "cuserName%d", i + 1);
                bp = (char*)json_object_dotget_string(root, buf);
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    memset(sjis, 0, sizeof(sjis));
                    utf8tosjis(buf, sjis);
                    memcpy(req51->c_name[i], sjis, sizeof(req51->c_name[i]));
                }
            }
        }
    }

    json_value_free(root_value);

    return 0;
}

/**
 * @fn int comsv_json_lcd_req52(char *jfile, LcddataReq52_t *req52, short page)
 * @brief JSON文字列から仮想端末（指示／特記）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req52 仮想端末（指示／特記）構造体
 * @param[in] page ページ番号
 * @return 0:成功, -1:エラー
 */
int comsv_json_lcd_req52(char *jfile, LcddataReq52_t *req52, short page) {
    int i, j, k;
    int no, po;
    int count;
    long len;
    char *bp;
    char buf[100];
    char sfile[50];
    char work[400];
    char sjis[400];
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;

    memset(req52, 0, sizeof(LcddataReq52_t));
    if ( page <= 0 || page > 100 ) return -1;
    if ( jfile == "" ) return -1;

    memset(sfile, 0, sizeof(sfile));
    strcpy(sfile, jfile);
    strcpy(sfile + (strlen(jfile) - 5), "_sjis.json");
    //sprintf(buf, "iconv -f utf-8 -t sjis %s -o %s", jfile, sfile);
    sprintf(buf, "iconv -f UTF-8 -t SJIS-WIN %s -o %s", jfile, sfile);
    i = system(buf);
    if ( i != 0 ) {
        return -1;
    }

    root_value = json_parse_file(sfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // 指示／特記情報
    memset(work, ' ', sizeof(work));
    array = json_object_get_array(root, "ListData");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        for ( no=0; no < count; no++ ) {
            obj = json_array_get_object (array, no);
            bp = (char*)json_object_dotget_string(obj, "content");
            if ( bp != NULL && bp[0] != 0 ) {
                len = strlen(bp);
                req52->count++;
                memset(sjis, ' ', sizeof(sjis));
                for ( i = 0, j = 0, po = 0; i < len; i++ ) {
                    if ( bp[i] == '\n' || (i + 1 < len && bp[i] == '\r' && bp[i + 1] == '\n') ) {
                        // 改行コードの場合、その行の残り全てを空白で埋める
                        // 1行は40バイト
                        for ( k = po; k < 40; k++ ) {
                            sjis[j] = 0x20;
                            j++;
                            if ( j >= sizeof(sjis) ) {
                                break;
                            }
                        }
                        if ( j >= sizeof(sjis) ) {
                            // 400バイトを超えた場合、以降は次ページとして扱う
                            if ( page == req52->count ) {
                                // 指定ページのデータをコピーする
                                memcpy(req52->comment, sjis, sizeof(req52->comment));
                            }
                            req52->count++;
                            j = 0;
                            po = 0;
                            memset(sjis, ' ', sizeof(sjis));
                            continue;
                        }
                        po = 0;
                        if ( bp[i] != '\n' ) {
                            i++;
                        }
                        continue;
                    }
                    else if ( bp[i] == 0 || bp[i] == '\r' ) {
                        // 空白で埋める
                        sjis[j] = 0x20;
                    }
                    else {
                        sjis[j] = bp[i];
                        if ( ((j+1) % 40) == 0 ) {
                            if ( comsv_lcd_knjichk((unsigned char *)sjis, j) == 1 ) {
                                // １行の最後の文字が漢字１バイト目なら空白、次業に持ち越し
                                sjis[j] = 0x20;
                                i--;
                            }
                        }
                    }
                    j++;
                    po++;
                    if ( j >= sizeof(sjis) ) {
                        // 400バイトを超えた場合、以降は次ページとして扱う
                        if ( page == req52->count ) {
                            // 指定ページのデータをコピーする
                            memcpy(req52->comment, sjis, sizeof(req52->comment));
                        }
                        req52->count++;
                        j = 0;
                        po = 0;
                        memset(sjis, ' ', sizeof(sjis));
                        continue;
                    }
                    if ( po>=40 ) po = 0;
                }
                if ( memcmp(sjis, work, sizeof(sjis)) == 0 ) {
                    // データが全て空白の場合、ページカウントを戻す（-1）
                    req52->count--;
                    continue;
                }
                if ( page == req52->count ) {
                    // 指定ページのデータをコピーする
                    memcpy(req52->comment, sjis, sizeof(req52->comment));
                }
            }
            if ( req52->count >= REQ52_MAX ) {
                // 最大100まで
                req52->count = REQ52_MAX;
                break;
            }
        }
    }
    json_value_free(root_value);

    return 0;
}

/**
 * @fn int comsv_json_lcd_req52_ex(char *jfile, LcddataReq52_t *req52, short page)
 * @brief JSON文字列から仮想端末（指示／特記）構造体に禁忌も含めて格納する
 * @param[in] jfile 指示／特記JSONファイル名
 * @param[in] jfile_ex 禁忌JSONファイル名
 * @param[out] req52 仮想端末（指示／特記）構造体
 * @param[in] page ページ番号
 * @return 0:成功, -1:エラー
 */
int comsv_json_lcd_req52_ex(char *jfile, char *jfile_ex, LcddataReq52_t *req52, short page) {
    int i, j, k;
    int no, po;
    int count;
    long len;
    char *bp;
    char buf[100];
    char sfile[50];
    char sfile_ex[50];
    char work[400];
    char sjis[400];
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;

    memset(req52, 0, sizeof(LcddataReq52_t));
    if ( page <= 0 || page > 100 ) return -1;
    if ( jfile == "" ) return -1;

    memset(sfile, 0, sizeof(sfile));
    strcpy(sfile, jfile);
    strcpy(sfile + (strlen(jfile) - 5), "_sjis.json");
    //sprintf(buf, "iconv -f utf-8 -t sjis %s -o %s", jfile, sfile);
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
    //sprintf(buf, "iconv -f UTF-8 -t SJIS-WIN %s -o %s", jfile, sfile);
    snprintf(buf, sizeof(buf), "iconv -f UTF-8 -t SJIS-WIN %s -o %s", jfile, sfile);
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
    i = system(buf);
    if ( i != 0 ) {
        return -1;
    }

    root_value = json_parse_file(sfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // 指示／特記情報
    memset(work, ' ', sizeof(work));
    array = json_object_get_array(root, "ListData");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        for ( no=0; no < count; no++ ) {
            obj = json_array_get_object (array, no);
            bp = (char*)json_object_dotget_string(obj, "content");
            if ( bp != NULL && bp[0] != 0 ) {
                len = strlen(bp);
                req52->count++;
                memset(sjis, ' ', sizeof(sjis));
                for ( i = 0, j = 0, po = 0; i < len; i++ ) {
                    if ( bp[i] == '\n' || (i + 1 < len && bp[i] == '\r' && bp[i + 1] == '\n') ) {
                        // 改行コードの場合、その行の残り全てを空白で埋める
                        // 1行は40バイト
                        for ( k = po; k < 40; k++ ) {
                            sjis[j] = 0x20;
                            j++;
                            if ( j >= sizeof(sjis) ) {
                                break;
                            }
                        }
                        if ( j >= sizeof(sjis) ) {
                            // 400バイトを超えた場合、以降は次ページとして扱う
                            if ( page == req52->count ) {
                                // 指定ページのデータをコピーする
                                memcpy(req52->comment, sjis, sizeof(req52->comment));
                            }
                            req52->count++;
                            j = 0;
                            po = 0;
                            memset(sjis, ' ', sizeof(sjis));
                            continue;
                        }
                        po = 0;
                        if ( bp[i] != '\n' ) {
                            i++;
                        }
                        continue;
                    }
                    else if ( bp[i] == 0 || bp[i] == '\r' ) {
                        // 空白で埋める
                        sjis[j] = 0x20;
                    }
                    else {
                        sjis[j] = bp[i];
                        if ( ((j+1) % 40) == 0 ) {
                            if ( comsv_lcd_knjichk((unsigned char *)sjis, j) == 1 ) {
                                // １行の最後の文字が漢字１バイト目なら空白、次業に持ち越し
                                sjis[j] = 0x20;
                                i--;
                            }
                        }
                    }
                    j++;
                    po++;
                    if ( j >= sizeof(sjis) ) {
                        // 400バイトを超えた場合、以降は次ページとして扱う
                        if ( page == req52->count ) {
                            // 指定ページのデータをコピーする
                            memcpy(req52->comment, sjis, sizeof(req52->comment));
                        }
                        req52->count++;
                        j = 0;
                        po = 0;
                        memset(sjis, ' ', sizeof(sjis));
                        continue;
                    }
                    if ( po>=40 ) po = 0;
                }
                if ( memcmp(sjis, work, sizeof(sjis)) == 0 ) {
                    // データが全て空白の場合、ページカウントを戻す（-1）
                    req52->count--;
                    continue;
                }
                if ( page == req52->count ) {
                    // 指定ページのデータをコピーする
                    memcpy(req52->comment, sjis, sizeof(req52->comment));
                }
            }
            if ( req52->count >= REQ52_MAX ) {
                // 最大100まで
                req52->count = REQ52_MAX;
                break;
            }
        }
    }
    json_value_free(root_value);

    if ( req52->count >= REQ52_MAX ) {
        // 最大100まで
        req52->count = REQ52_MAX;
        return 0;
    }

    memset(sfile_ex, 0, sizeof(sfile_ex));
    strcpy(sfile_ex, jfile_ex);
    strcpy(sfile_ex + (strlen(jfile_ex) - 5), "_sjis.json");
    //sprintf(buf, "iconv -f utf-8 -t sjis %s -o %s", jfile_ex, sfile_ex);
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 start
    //sprintf(buf, "iconv -f UTF-8 -t SJIS-WIN %s -o %s", jfile_ex, sfile_ex);
    snprintf(buf, sizeof(buf), "iconv -f UTF-8 -t SJIS-WIN %s -o %s", jfile_ex, sfile_ex);
    // #12507 2026.03.01 mod FW7に伴うバッファーオーバーフロー対応 TDC高村 end
    i = system(buf);
    if ( i != 0 ) {
        return -1;
    }

    if ( sfile_ex == "" ) return -1;
    root_value = json_parse_file(sfile_ex);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // 患者禁忌情報
    array = json_object_get_array(root, "ListData");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        for ( no = 0; no < count; no++ ) {
            obj = json_array_get_object (array, no);
            bp = (char*)json_object_dotget_string(obj, "content");
            if ( bp != NULL && bp[0] != 0 ) {
                len = strlen(bp);
                req52->count++;
                memset(sjis, ' ', sizeof(sjis));
                for ( i = 0, j = 0, po = 0; i < len; i++ ) {
                    if ( bp[i] == '\n' || (i + 1 < len && bp[i] == '\r' && bp[i + 1] == '\n') ) {
                        // 改行コードの場合、その行の残り全てを空白で埋める
                        // 1行は40バイト
                        for ( k = po; k < 40; k++ ) {
                            sjis[j] = 0x20;
                            j++;
                            if ( j >= sizeof(sjis) ) {
                                break;
                            }
                        }
                        if ( j >= sizeof(sjis) ) {
                            // 400バイトを超えた場合、以降は次ページとして扱う
                            if ( page == req52->count ) {
                                // 指定ページのデータをコピーする
                                memcpy(req52->comment, sjis, sizeof(req52->comment));
                            }
                            req52->count++;
                            j = 0;
                            po = 0;
                            memset(sjis, ' ', sizeof(sjis));
                            continue;
                        }
                        po = 0;
                        if ( bp[i] != '\n' ) {
                            i++;
                        }
                        continue;
                    }
                    else if ( bp[i] == 0 || bp[i] == '\r' ) {
                        // 空白で埋める
                        sjis[j] = 0x20;
                    }
                    else {
                        sjis[j] = bp[i];
                        if ( ((j+1) % 40) == 0 ) {
                            if ( comsv_lcd_knjichk((unsigned char *)sjis, j) == 1 ) {
                                // １行の最後の文字が漢字１バイト目なら空白、次業に持ち越し
                                sjis[j] = 0x20;
                                i--;
                            }
                        }
                    }
                    j++;
                    po++;
                    if ( j >= sizeof(sjis) ) {
                        // 400バイトを超えた場合、以降は次ページとして扱う
                        if ( page == req52->count ) {
                            // 指定ページのデータをコピーする
                            memcpy(req52->comment, sjis, sizeof(req52->comment));
                        }
                        req52->count++;
                        j = 0;
                        po = 0;
                        memset(sjis, ' ', sizeof(sjis));
                        continue;
                    }
                    if ( po>=40 ) po = 0;
                }
                if ( memcmp(sjis, work, sizeof(sjis)) == 0 ) {
                    // データが全て空白の場合、ページカウントを戻す（-1）
                    req52->count--;
                    continue;
                }
                if ( page == req52->count ) {
                    // 指定ページのデータをコピーする
                    memcpy(req52->comment, sjis, sizeof(req52->comment));
                }
            }
            if ( req52->count > REQ52_MAX ) {
                // 最大100まで
                req52->count = REQ52_MAX;
                break;
            }
        }
    }
    json_value_free(root_value);

    return 0;
}

/**
 * @fn int comsv_json_lcd_req53(char *jfile, LcddataReq53_t *req53)
 * @brief JSON文字列から仮想端末（ＣＴＲトレンド）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req53 仮想端末（ＣＴＲトレンド）構造体
 * @return 0:成功, -1:エラー
 */
int comsv_json_lcd_req53(char *jfile, LcddataReq53_t *req53) {
    int i;
    int count;
    char *bp;
    char buf[255];
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;

    memset(req53, 0, sizeof(LcddataReq53_t));
    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // ＣＴＲトレンド
    array = json_object_get_array(root, "ListData");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        for ( i = 0; i < count; i++ ) {
            if ( i >= REQ53_MAX ) break;
            obj = json_array_get_object (array, i);
            if ( obj == NULL ) continue;
            bp = (char*)json_object_dotget_string(obj, "treatDate");
            if ( bp != NULL && bp[0] != 0 ) {
                memset(buf, 0, sizeof(buf));
                sprintf(buf, "%.4s/%.2s/%.2s", bp, bp + 4, bp + 6);
                memcpy(req53->date[i], buf, sizeof(req53->date[i]));
                bp = (char*)json_object_dotget_string(obj, "ctr");
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    req53->ctr[i] = comsv_lcd_strshort(buf, 2);
                }
                bp = (char*)json_object_dotget_string(obj, "ctrWeight");
                if ( bp != NULL && bp[0] != 0 ) {
                    memset(buf, 0, sizeof(buf));
                    strcpy(buf, bp);
                    req53->ctr_weight[i] = comsv_lcd_strshort(buf, 2);
                }
            }
        }
        req53->count = i;
    }
    json_value_free(root_value);

    return 0;
}

/**
 * @fn int comsv_json_lcd_req54(char *jfile, LcddataReq54_t *req54)
 * @brief JSON文字列から仮想端末（チェックリスト）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req54 仮想端末（禁忌）構造体
 * @return 項目件数, -1:エラー
 */
int comsv_json_lcd_req54(char *jfile, LcddataReq54_t *req54) {
    int i, ret;
    int count;
    int disp_no;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
    //long l_tim;
    time_t l_tim;
    // #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    char *bp;
    char dt[20], tm[10];
    char buf[1000], sjis[500];
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;

    memset(req54, 0, sizeof(LcddataReq54_t));
    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // チェックリスト情報
    array = json_object_get_array(root, "ListData");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        for ( i = 0, ret = 0; i < count; i++ ) {
            obj = json_array_get_object (array, i);
            disp_no = comsv_json_dotget_int(obj, "dispNo");
            if ( disp_no < 1 || disp_no > REQ54_MAX ) continue;
            if ( disp_no > req54->count ) req54->count = disp_no;
            disp_no--;
            bp = (char*)json_object_dotget_string(obj, "name");
            if ( bp != NULL && bp != "" ) {
                memset(buf, 0, sizeof(buf));
                strcpy(buf, bp);
                memset(sjis, 0, sizeof(sjis));
                utf8tosjis(buf, sjis);
                memcpy(req54->chk_name[disp_no], sjis, sizeof(req54->chk_name[disp_no]));
                ret++;
            }
            bp = (char*)json_object_dotget_string(obj, "isCheck");
            if ( bp != NULL && bp != "" ) {
                memset(buf, 0, sizeof(buf));
                strcpy(buf, bp);
                if ( buf[0] != '0' ) {
                    // 実施済
                    bp = (char*)json_object_dotget_string(obj, "occurDate");
                    if ( bp != NULL && bp[0] != 0 ) {
                        memset(buf, 0, sizeof(buf));
                        strcpy(buf, bp);
                        sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
                        sprintf(tm, "%.8s", buf + 11);
                        if ( str_time(dt, tm, &l_tim, 1) == 0 ) {
                            req54->chk_time[disp_no] = l_tim;
                        }
                    }
                    if ( req54->chk_time[disp_no] == 0 ) {
                        // 実施者更新日時が未登録の場合、更新日時を使用
                        bp = (char*)json_object_dotget_string(obj, "upDate");
                        if ( bp != NULL && bp[0] != 0 ) {
                            memset(buf, 0, sizeof(buf));
                            strcpy(buf, bp);
                            sprintf(dt, "%.4s/%.2s/%.2s", buf, buf + 5, buf + 8);
                            sprintf(tm, "%.8s", buf + 11);
                            if ( str_time(dt, tm, &l_tim, 1) == 0 ) {
                                req54->chk_time[disp_no] = l_tim;
                            }
                        }
                    }
                }
            }
        }
        if ( req54->count ) {
            if ( req54->count <= 10 ) {
                req54->count = 10;
            }
            else if ( req54->count <= 13 ) {
                req54->count = 13;
            }
            else {
                req54->count = 20;
            }
        }
    }
    json_value_free(root_value);

    return ret;
}

/**
 * @fn int comsv_json_lcd_req56(char *jfile, LcddataReq56_t *req56)
 * @brief JSON文字列からレポート画像転送（過去レポート）構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] req56 レポート画像転送（過去レポート）構造体
 * @return 0:成功, -1:エラー
 */
int comsv_json_lcd_req56(char *jfile, LcddataReq56_t *req56) {
    int i, count;
    char *bp;
    char buf[255];
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;

    memset(req56, 0, sizeof(LcddataReq56_t));

    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // 直近
    array = json_object_get_array( root, "latestOrdList" );
    count = (int)json_array_get_count(array);
    for ( i =0 ; i< count; i++ ) {
        obj = json_array_get_object (array, i);
        req56->last_no[i] = comsv_json_dotget_long(obj, "ordNo");
        bp = (char*)json_object_dotget_string(obj, "rstStartDate");
        if ( bp != NULL && bp[0] != 0 ) {
            memset(buf, 0, sizeof(buf));
            strcpy(buf, bp);
            buf[4] = buf[7] = buf[10] = buf[13] = buf[16] = buf[19] = 0;
            sprintf(req56->last_name[i], "report_%s%s%s_%s%s%s_01.bmp", &buf[2], &buf[5], &buf[8], &buf[11], &buf[14], &buf[17]);
        }
    }
    // 同一曜日
    array = json_object_get_array( root, "sameDayOfTheWeekOrdList" );
    count = (int)json_array_get_count(array);
    for ( i =0 ; i< count; i++ ) {
        obj = json_array_get_object (array, i);
        req56->week_no[i] = comsv_json_dotget_long(obj, "ordNo");
        bp = (char*)json_object_dotget_string(obj, "rstStartDate");
        if ( bp != NULL && bp[0] != 0 ) {
            memset(buf, 0, sizeof(buf));
            strcpy(buf, bp);
            buf[4] = buf[7] = buf[10] = buf[13] = buf[16] = buf[19] = 0;
            sprintf(req56->week_name[i], "report_%s%s%s_%s%s%s_01.bmp", &buf[2], &buf[5], &buf[8], &buf[11], &buf[14], &buf[17]);
        }
    }
    json_value_free(root_value);

    return 0;
}
