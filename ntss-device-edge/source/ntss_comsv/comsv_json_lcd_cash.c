/**
* @file comsv_json_lcd_cash.c
* @brief 仮想端末キャッシュ用JSONファイル処理
* @author Y.Takamura
* @date 2019/10/04
* @details 仮想端末キャッシュ用JSONファイルを処理する
*/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 start
//#include "ntss_file.h"
// #8729 2023.05.29 del RESTリトライ処理実装に伴うライブラリ変更 TDC高村 end
#include "ntss_comsv.h"
#include "comsv_json_num.h"

/**
 * @fn int comsv_json_lcd_cash(char *jfile, long dev_no)
 * @brief キャッシュJSONファイルから仮想端末JSONファイルを作成
 * @param[in] jfile キャッシュJSONファイル名
 * @param[in] dev_no 装置Ｎｏ
 * @return 0:成功, -1:エラー
 */
int comsv_json_lcd_cash(char *jfile, long dev_no) {
    FILE *fp, *fwp;
    int ret = -1;
    int no;
    long num;
	char buf[64];
	char wrk[64];
	char fpath[64];
    char *jbuf;
    char *sp, *ep;
    char *n1, *n2;

    // 仮想端末（キャッシュ）
    fp = fopen(jfile, "r");
    if ( fp == NULL ) return ret;
    num = getFileSize(fp);

    if ( num > 0 ) {
        jbuf = (char *)malloc(num + 2);
        memset(jbuf, 0, num + 2);
        fgets(jbuf, num + 1, fp);
        // 仮想端末（酸素吸入）
        sp = strstr(jbuf, "lcdCashReq32");
        n1 = strstr(jbuf, "lcdCashReq32\":null,");
        n2 = strstr(jbuf, "lcdCashReq32\":\"[]\",");
        if ( NULL != sp && (n1 == NULL && n2 == NULL) ) {
            ep = strstr(sp, "}],");
            if ( NULL != ep ) {
                comsv_work_fpath(dev_no, WORK_LCD_REQ32, fpath);
                fwp = fopen(fpath, "w");
                fputs("{\"ListData\":\n", fwp);
                sp[(int)(ep - sp + 2)] = 0;
                fputs(sp+14, fwp);
                sp[(int)(ep - sp + 2)] = ',';
                fputs("\n}\n", fwp);
                fclose(fwp);
                ret = 0;
            }
        }
        // 仮想端末（体重トレンド）
        sp = strstr(jbuf, "lcdCashReq38");
        n1 = strstr(jbuf, "lcdCashReq38\":null,");
        n2 = strstr(jbuf, "lcdCashReq38\":\"[]\",");
        if ( NULL != sp && (n1 == NULL && n2 == NULL) ) {
            ep = strstr(sp, "}],");
            if ( NULL != ep ) {
                comsv_work_fpath(dev_no, WORK_LCD_REQ38, fpath);
                fwp = fopen(fpath, "w");
                fputs("{\"ListData\":\n", fwp);
                sp[(int)(ep - sp + 2)] = 0;
                fputs(sp+14, fwp);
                sp[(int)(ep - sp + 2)] = ',';
                fputs("\n}\n", fwp);
                fclose(fwp);
                ret = 0;
            }
        }
        // 仮想端末（透析日報）
        sp = strstr(jbuf, "lcdCashReq40");
        n1 = strstr(jbuf, "lcdCashReq40\":null,");
        n2 = strstr(jbuf, "lcdCashReq40\":\"[]\",");
        if ( NULL != sp && (n1 == NULL && n2 == NULL) ) {
            ep = strstr(sp, "}},");
            if ( NULL != ep ) {
                comsv_work_fpath(dev_no, WORK_LCD_REQ40, fpath);
                fwp = fopen(fpath, "w");
                sp[(int)(ep - sp + 2)] = 0;
                fputs(sp+14, fwp);
                sp[(int)(ep - sp + 2)] = ',';
                fclose(fwp);
                ret = 0;
            }
        }
        // 仮想端末（投与薬剤）
        sp = strstr(jbuf, "lcdCashReq41");
        n1 = strstr(jbuf, "lcdCashReq41\":null,");
        n2 = strstr(jbuf, "lcdCashReq41\":\"[]\",");
        if ( NULL != sp && (n1 == NULL && n2 == NULL) ) {
            ep = strstr(sp, "}],");
            if ( NULL != ep ) {
                comsv_work_fpath(dev_no, WORK_LCD_REQ41, fpath);
                fwp = fopen(fpath, "w");
                fputs("{\"ListData\":\n", fwp);
                sp[(int)(ep - sp + 2)] = 0;
                fputs(sp+14, fwp);
                sp[(int)(ep - sp + 2)] = ',';
                fputs("\n}\n", fwp);
                fclose(fwp);
                ret = 0;
            }
        }
        // 仮想端末（抗凝固剤）
        sp = strstr(jbuf, "lcdCashReq42");
        n1 = strstr(jbuf, "lcdCashReq42\":null,");
        n2 = strstr(jbuf, "lcdCashReq42\":\"[]\",");
        if ( NULL != sp && (n1 == NULL && n2 == NULL) ) {
            ep = strstr(sp, "},");
            if ( NULL != ep ) {
                comsv_work_fpath(dev_no, WORK_LCD_REQ42, fpath);
                fwp = fopen(fpath, "w");
                sp[(int)(ep - sp + 1)] = 0;
                fputs(sp+14, fwp);
                sp[(int)(ep - sp + 1)] = ',';
                fclose(fwp);
                ret = 0;
            }
        }
        // 仮想端末（禁忌）
        sp = strstr(jbuf, "lcdCashReq44");
        n1 = strstr(jbuf, "lcdCashReq44\":null,");
        n2 = strstr(jbuf, "lcdCashReq44\":\"[]\",");
        if ( NULL != sp && (n1 == NULL && n2 == NULL) ) {
            ep = strstr(sp, "}],");
            if ( NULL != ep ) {
                comsv_work_fpath(dev_no, WORK_LCD_REQ44, fpath);
                fwp = fopen(fpath, "w");
                fputs("{\"ListData\":\n", fwp);
                sp[(int)(ep - sp + 2)] = 0;
                fputs(sp+14, fwp);
                sp[(int)(ep - sp + 2)] = ',';
                fputs("\n}\n", fwp);
                fclose(fwp);
                ret = 0;
            }
        }
        // 仮想端末（メモ）
        sp = strstr(jbuf, "lcdCashReq45");
        n1 = strstr(jbuf, "lcdCashReq45\":null,");
        n2 = strstr(jbuf, "lcdCashReq45\":\"[]\",");
        if ( NULL != sp && (n1 == NULL && n2 == NULL) ) {
            ep = strstr(sp, "}],");
            if ( NULL != ep ) {
                comsv_work_fpath(dev_no, WORK_LCD_REQ45, fpath);
                fwp = fopen(fpath, "w");
                fputs("{\"ListData\":\n", fwp);
                sp[(int)(ep - sp + 2)] = 0;
                fputs(sp+14, fwp);
                sp[(int)(ep - sp + 2)] = ',';
                fputs("\n}\n", fwp);
                fclose(fwp);
                ret = 0;
            }
        }
        // 仮想端末（検査グラフ）
        sp = strstr(jbuf, "lcdCashReq46");
        n1 = strstr(jbuf, "lcdCashReq46\":null,");
        n2 = strstr(jbuf, "lcdCashReq46\":\"[]\",");
        if ( NULL != sp && (n1 == NULL && n2 == NULL) ) {
            ep = strstr(sp, "}],");
            if ( NULL != ep ) {
                comsv_work_fpath(dev_no, WORK_LCD_REQ33, fpath);
                fwp = fopen(fpath, "w");
                fputs("{\"ListData\":\n", fwp);
                sp[(int)(ep - sp + 2)] = 0;
                fputs(sp+14, fwp);
                sp[(int)(ep - sp + 2)] = ',';
                fputs("\n}\n", fwp);
                fclose(fwp);
                ret = 0;
            }
        }
        // 仮想端末（穿刺／回収／担当）
        sp = strstr(jbuf, "lcdCashReq51");
        n1 = strstr(jbuf, "lcdCashReq51\":null,");
        n2 = strstr(jbuf, "lcdCashReq51\":\"[]\",");
        if ( NULL != sp && (n1 == NULL && n2 == NULL) ) {
            ep = strstr(sp, "},");
            if ( NULL != ep ) {
                comsv_work_fpath(dev_no, WORK_LCD_REQ51, fpath);
                fwp = fopen(fpath, "w");
                sp[(int)(ep - sp + 1)] = 0;
                fputs(sp+14, fwp);
                sp[(int)(ep - sp + 1)] = ',';
                fclose(fwp);
                ret = 0;
            }
        }
        // 仮想端末（指示／特記）
        sp = strstr(jbuf, "lcdCashReq52");
        n1 = strstr(jbuf, "lcdCashReq52\":null,");
        n2 = strstr(jbuf, "lcdCashReq52\":\"[]\",");
        if ( NULL != sp && (n1 == NULL && n2 == NULL) ) {
            ep = strstr(sp, "}],");
            if ( NULL != ep ) {
                comsv_work_fpath(dev_no, WORK_LCD_REQ52, fpath);
                fwp = fopen(fpath, "w");
                fputs("{\"ListData\":\n", fwp);
                sp[(int)(ep - sp + 2)] = 0;
                fputs(sp+14, fwp);
                sp[(int)(ep - sp + 2)] = ',';
                fputs("\n}\n", fwp);
                fclose(fwp);
                ret = 0;
            }
        }
        // 仮想端末（ＣＴＲトレンド）
        sp = strstr(jbuf, "lcdCashReq53");
        n1 = strstr(jbuf, "lcdCashReq53\":null,");
        n2 = strstr(jbuf, "lcdCashReq53\":\"[]\",");
        if ( NULL != sp && (n1 == NULL && n2 == NULL) ) {
            ep = strstr(sp, "}],");
            if ( NULL != ep ) {
                comsv_work_fpath(dev_no, WORK_LCD_REQ53, fpath);
                fwp = fopen(fpath, "w");
                fputs("{\"ListData\":\n", fwp);
                sp[(int)(ep - sp + 2)] = 0;
                fputs(sp+14, fwp);
                sp[(int)(ep - sp + 2)] = ',';
                fputs("\n}\n", fwp);
                fclose(fwp);
                ret = 0;
            }
        }
        // 仮想端末（チェックリスト）
        for ( no = 1; no <= REQ54_NO_MAX; no++ ) {
            sprintf(wrk, "lcdCashReq54No%d", no);
            sp = strstr(jbuf, wrk);
            sprintf(wrk, "lcdCashReq54No%d\":null", no);
            n1 = strstr(jbuf, wrk);
            sprintf(wrk, "lcdCashReq54No%d\":\"[]\",", no);
            n2 = strstr(jbuf, wrk);
            if ( NULL != sp && (n1 == NULL && n2 == NULL) ) {
                ep = strstr(sp, "}],");
                if ( NULL != ep ) {
					sprintf(wrk, "%s", WORK_LCD_REQ54);
					sprintf(buf, wrk, no);
                    comsv_work_fpath(dev_no, buf, fpath);
                    fwp = fopen(fpath, "w");
                    fputs("{\"ListData\":\n", fwp);
                    sp[(int)(ep - sp + 2)] = 0;
                    fputs(sp+17, fwp);
                    sp[(int)(ep - sp + 2)] = ',';
                    fputs("\n}\n", fwp);
                    fclose(fwp);
                    ret = 0;
                }
            }
        }
        free(jbuf);
    }
    fclose(fp);

    return ret;
}

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_json_lcd_cash_upd32(long dev_no, short inp, long tim, long start, short amount, long cd, char *name)
// * @brief 仮想端末（酸素吸入）JSONファイルを更新する
// * @param[in] dev_no 装置Ｎｏ
// * @param[in] inp 入力区分（0:開始,1:終了）
// * @param[in] tim 現在時刻
// * @param[in] start 開始時刻
// * @param[in] amount 吸入量
// * @param[in] cd スタッフコード
// * @param[in] name スタッフ名
// * @return 0:成功, -1:エラー
// */
//int comsv_json_lcd_cash_upd32(long dev_no, short inp, long tim, long start, short amount, long cd, char *name) {
/**
 * @fn int comsv_json_lcd_cash_upd32(long dev_no, short inp, time_t tim, time_t start, short amount, long cd, char *name)
 * @brief 仮想端末（酸素吸入）JSONファイルを更新する
 * @param[in] dev_no 装置Ｎｏ
 * @param[in] inp 入力区分（0:開始,1:終了）
 * @param[in] tim 現在時刻
 * @param[in] start 開始時刻
 * @param[in] amount 吸入量
 * @param[in] cd スタッフコード
 * @param[in] name スタッフ名
 * @return 0:成功, -1:エラー
 */
int comsv_json_lcd_cash_upd32(long dev_no, short inp, time_t tim, time_t start, short amount, long cd, char *name) {
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;
    JSON_Status sta = -1;
    FILE *fpr, *fpw;
    int count;
    int len;
    char dst[20], tst[20];
    char odate[20], sdate[20];
    char num[20], code[20];
    char fpath[64];
    char ftemp[64];
    char dat[256];
    char buf[256];

    comsv_work_fpath(dev_no, WORK_LCD_REQ32, fpath);
    root_value = json_parse_file(fpath);
    if ( root_value != NULL ) {
        root = json_object(root_value);
        if ( root != NULL ) {
            sta = 0;
        }
        else {
            json_value_free(root_value);
        }
    }

    time_str(tim, dst, tst, 1);
    dst[4] = dst[7] = '-';
    sprintf(odate, "\"%s %s\"", dst, tst);
    sprintf(num, "%d", amount);
    if ( inp == 0 ) {
        // 酸素吸入開始
        time_str(start, dst, tst, 1);
        dst[4] = dst[7] = '-';
        sprintf(sdate, "\"%s %s\"", dst, tst);
    }
    else {
        // 酸素吸入終了
        strcpy(sdate, "null");
    }
    if ( cd ) {
        sprintf(code, "%ld", cd);
        sjistoutf8(name, dat);
        sprintf(buf, "\"%s\"", dat);
    }
    else {
        strcpy(code, "null");
        strcpy(buf, "null");
    }

    sprintf(dat, "[{\"occur_date\":%s,\"oxygen_start\":%s,\"oxygen_amount\":%s,\"treat_staff_cd\":%s,\"treat_staff_name\":%s}",
            odate, sdate, num, code, buf);

    if ( sta != 0 ) {
        // 新規
        fpw = fopen(fpath, "w");
        if ( fpw != NULL ) {
            fputs("{\"ListData\":\n", fpw);
            strcat(dat, "]\n}\n");
            fputs(dat, fpw);
        }
        fclose(fpw);
        sta = 0;
    }
    else {
        count = 0;
        array = json_object_get_array(root, "ListData");
        if ( array != NULL ) {
            count = (int)json_array_get_count(array);
        }
        json_value_free(root_value);
        fpr = fopen(fpath, "r");
        sprintf(ftemp, "%s.temp", fpath);
        fpw = fopen(ftemp, "w");
        if ( fpr != NULL && fpw != NULL ) {
            while ( fgets(buf, 256, fpr) != NULL ) {
                len = strlen(buf);
                if ( buf[0] == '[' ) {
                    if ( count <= 0 ) {
                        // データ無し（追加）
                        strcat(dat, "]\n");
                        fputs(dat, fpw);
                        continue;
                    }
                    else {
                        // データ有り（追加）
                        strcat(dat, ",\n");
                        fputs(dat, fpw);
                        memmove(buf, buf + 1, len - 1);
                        buf[len - 1] = 0;
                    }
                }
                fputs(buf, fpw);
            }
            fclose(fpr);
            fclose(fpw);
        }
        // ファイル名をリネーム
        renameFile(ftemp, fpath);
    }
    return sta;    
}

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_json_lcd_cash_upd41(long dev_no, int chk, long tim)
// * @brief 仮想端末（投与薬剤）JSONファイルを更新する
// * @param[in] dev_no 装置Ｎｏ
// * @param[in] chk 入力状態（0:入力無し,1:入力有り）
// * @param[in] tim 現在時刻
// * @return 0:成功, -1:エラー
// */
//int comsv_json_lcd_cash_upd41(long dev_no, int *chk, long tim) {
/**
 * @fn int comsv_json_lcd_cash_upd41(long dev_no, int chk, time_t tim)
 * @brief 仮想端末（投与薬剤）JSONファイルを更新する
 * @param[in] dev_no 装置Ｎｏ
 * @param[in] chk 入力状態（0:入力無し,1:入力有り）
 * @param[in] tim 現在時刻
 * @return 0:成功, -1:エラー
 */
int comsv_json_lcd_cash_upd41(long dev_no, int *chk, time_t tim) {
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;
    JSON_Status sta;
    int i, count;
    char dst[20];
    char tst[20];
    char dat[40];
    char fpath[64];

    comsv_work_fpath(dev_no, WORK_LCD_REQ41, fpath);
    root_value = json_parse_file(fpath);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    time_str(tim, dst, tst, 1);
    dst[4] = dst[7] = '-';
    sprintf(dat, "%s %s", dst, tst);

    // 投与薬剤
    array = json_object_get_array(root, "ListData");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        for ( i = 0; i < count; i++ ) {
            if ( i >= REQ41_MAX ) break;
            if ( chk[i] == 0 ) continue;
            obj = json_array_get_object (array, i);
            json_object_dotset_number(obj, "effectFlg", 1);
            json_object_dotset_string(obj, "effectDate", dat);
        }
        sta = json_serialize_to_file(root_value, fpath);
    }

    json_value_free(root_value);
    return sta;
}

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_json_lcd_cash_upd51(long dev_no, short inp, short no, long tim, long id, char *name)
// * @brief 仮想端末（穿刺／回収／担当）JSONファイルを更新する
// * @param[in] dev_no 装置Ｎｏ
// * @param[in] inp 入力区分（0:穿刺,1:回収,2:担当）
// * @param[in] no Ｎｏ（1,2）
// * @param[in] tim 現在時刻
// * @param[in] id スタッフID
// * @param[in] name スタッフ名
// * @return 0:成功, -1:エラー
// */
//int comsv_json_lcd_cash_upd51(long dev_no, short inp, short no, long tim, long id, char *name) {
/**
 * @fn int comsv_json_lcd_cash_upd51(long dev_no, short inp, short no, time_t tim, long id, char *name)
 * @brief 仮想端末（穿刺／回収／担当）JSONファイルを更新する
 * @param[in] dev_no 装置Ｎｏ
 * @param[in] inp 入力区分（0:穿刺,1:回収,2:担当）
 * @param[in] no Ｎｏ（1,2）
 * @param[in] tim 現在時刻
 * @param[in] id スタッフID
 * @param[in] name スタッフ名
 * @return 0:成功, -1:エラー
 */
int comsv_json_lcd_cash_upd51(long dev_no, short inp, short no, time_t tim, long id, char *name) {
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    JSON_Value *root_value;
    JSON_Object *root;
    JSON_Status sta;
    char dst[20];
    char tst[20];
    char dat[40];
    char tag[40];
    char utf[200];
    char fpath[64];

    if ( inp < 0 || inp > 2 ) return -1;
    if ( no < 1 || no > 2 ) return -1;

    comsv_work_fpath(dev_no, WORK_LCD_REQ51, fpath);
    root_value = json_parse_file(fpath);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    time_str(tim, dst, tst, 1);
    dst[4] = dst[7] = '-';
    sprintf(dat, "%s %s", dst, tst);
    sjistoutf8(name, utf);

    if ( inp == 0 ) {
        // 穿刺者情報
        sprintf(tag, "puserDate%d", no);
        json_object_dotset_string(root, tag, dat);
        sprintf(tag, "puserId%d", no);
        json_object_dotset_number(root, tag, id);
        sprintf(tag, "puserName%d", no);
        json_object_dotset_string(root, tag, utf);
    }
    else if ( inp == 1 ) {
        // 回収（返血）者情報
        sprintf(tag, "ruserDate%d", no);
        json_object_dotset_string(root, tag, dat);
        sprintf(tag, "ruserId%d", no);
        json_object_dotset_number(root, tag, id);
        sprintf(tag, "ruserName%d", no);
        json_object_dotset_string(root, tag, utf);
    }
    else {
        // 担当者情報
        sprintf(tag, "cuserDate%d", no);
        json_object_dotset_string(root, tag, dat);
        sprintf(tag, "cuserId%d", no);
        json_object_dotset_number(root, tag, id);
        sprintf(tag, "cuserName%d", no);
        json_object_dotset_string(root, tag, utf);
    }

    sta = json_serialize_to_file(root_value, fpath);
    json_value_free(root_value);
    return sta;
}

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_json_lcd_cash_upd54(long dev_no, short gno, int *chk, long tim)
// * @brief 仮想端末（チェックリスト）JSONファイルを更新する
// * @param[in] dev_no 装置Ｎｏ
// * @param[in] gno 画面Ｎｏ（1〜8）
// * @param[in] chk 入力状態（0:入力無し,1:入力有り）
// * @param[in] tim 現在時刻
// * @return 0:成功, -1:エラー
// */
//int comsv_json_lcd_cash_upd54(long dev_no, short gno, int *chk, long tim) {
/**
 * @fn int comsv_json_lcd_cash_upd54(long dev_no, short gno, int *chk, time_t tim)
 * @brief 仮想端末（チェックリスト）JSONファイルを更新する
 * @param[in] dev_no 装置Ｎｏ
 * @param[in] gno 画面Ｎｏ（1〜8）
 * @param[in] chk 入力状態（0:入力無し,1:入力有り）
 * @param[in] tim 現在時刻
 * @return 0:成功, -1:エラー
 */
int comsv_json_lcd_cash_upd54(long dev_no, short gno, int *chk, time_t tim) {
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;
    JSON_Status sta;
    int i, count;
    int disp_no;
    char dst[20];
    char tst[20];
    char dat[40];
	char buf[40];
	char wrk[40];
	char fpath[64];

    sprintf(wrk, "%s", WORK_LCD_REQ54);
    sprintf(buf, wrk, gno);
    comsv_work_fpath(dev_no, buf, fpath);
    root_value = json_parse_file(fpath);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    time_str(tim, dst, tst, 1);
    dst[4] = dst[7] = '-';
    sprintf(dat, "%s %s", dst, tst);

    // チェックリスト
    array = json_object_get_array(root, "ListData");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        for ( i = 0; i < count; i++ ) {
            if ( i >= REQ54_MAX ) break;
            obj = json_array_get_object (array, i);
            disp_no = comsv_json_dotget_int(obj, "dispNo");
            if ( disp_no < 1 || disp_no > REQ54_MAX ) continue;
            if ( chk[disp_no - 1] == 0) continue;
            sta = json_object_dotset_string(obj, "isCheck", "1");
            sta = json_object_dotset_string(obj, "occurDate", dat);
        }
        sta = json_serialize_to_file(root_value, fpath);
    }

    json_value_free(root_value);
    return sta;
}
