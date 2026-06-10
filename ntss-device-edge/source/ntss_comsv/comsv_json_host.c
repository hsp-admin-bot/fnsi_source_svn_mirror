/**
* @file comsv_json_host.c
* @brief JSON文字列変換処理（ホスト報知関連）
* @author Y.Takamura
* @date 2020/12/27
* @details JSON文字列から構造体に格納、JSON文字列の作成を行う
*/

#include <stdio.h>
#include <string.h>
// #11965 2025.07.09 add ホスト報知の通知がされない TDC高村 start
#include <limits.h>
// #11965 2025.07.09 add ホスト報知の通知がされない TDC高村 end
#include "ntss_comsv.h"
#include "comsv_json_num.h"

/**
 * @fn int comsv_json_host_pat(char *jfile, HostWatchPat_t *watch)
 * @brief JSON文字列から患者ホスト報知定義構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] watch 患者ホスト報知定義構造体
 * @return 0:成功, -1:エラー
 */
int comsv_json_host_pat(char *jfile, HostWatchPat_t *watch) {
    int i, cnt;
    char *bp;
    char key[10], buf[50];
    double val;
    JSON_Value *root_value;
    JSON_Object *root;

    memset(watch, 0, sizeof(HostWatchPat_t) * HOST_WATCH_MAX);
    // #11965 2025.07.09 mod ホスト報知の通知がされない TDC高村 start
    // for ( i = 0; i < HOST_WATCH_MAX; i++ ) watch[i].addr = -1;
    for ( i = 0; i < HOST_WATCH_MAX; i++ ) {
        watch[i].addr = -1;
        watch[i].upper = SHRT_MIN;
        watch[i].lower = SHRT_MIN;
        watch[i].judge = 0;
    }
    // #11965 2025.07.09 mod ホスト報知の通知がされない TDC高村 end
    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // 患者ホスト報知定義
    for ( i = 0, cnt = 0; i < MON2_NUM; i++ ) {
        // #11965 2025.07.09 mod ホスト報知の通知がされない TDC高村 start
        // sprintf(key, "%d.upper", i);
        // val = json_object_dotget_number(root, key);
        // if ( val < 0 ) continue;
        // watch[cnt].upper = (short)(val);
        // sprintf(key, "%d.lower", i);
        // val = json_object_dotget_number(root, key);
        // if ( val < 0 ) continue;
        // watch[cnt].lower = (short)(val);
        // sprintf(key, "%d.judge", i);
        // val = json_object_dotget_number(root, key);
        // if ( val < 0 ) continue;
        // if ( (short)(val) != 0 ) {
        //     watch[cnt].judge = 1;
        // }
        // watch[cnt].addr = i;
        // cnt++;
        sprintf(key, "%d.judge", i);
        val = json_object_dotget_number(root, key);
        if ( val == -99999.0 ) continue;
        if ( (short)(val) != 0 ) {
            watch[cnt].judge = 1;
        }
        sprintf(key, "%d.upper", i);
        val = json_object_dotget_number(root, key);
        if ( val != -99999.0 ) {
            watch[cnt].upper = (short)(val);
        }
        sprintf(key, "%d.lower", i);
        val = json_object_dotget_number(root, key);
        if ( val != -99999.0 ) {
            watch[cnt].lower = (short)(val);
        }
        watch[cnt].addr = i;
        cnt++;        
        // #11965 2025.07.09 mod ホスト報知の通知がされない TDC高村 end
    }

    json_value_free(root_value);

    return 0;
}

/**
 * @fn int comsv_json_host_make_medi(char *jdata, int no, struct scn_data_fm *sp)
 * @brief 未投与薬剤データからJSONデータを作成する
 * @param[out] jdata 出力JSONデータ
 * @param[in] no 薬剤No
 * @param[in] sp 装置制御データ
 * @return 0:成功, -1:エラー
 */
int comsv_json_host_make_medi(char *jdata, int no, struct scn_data_fm *sp) {
    int ret, i;
    char buf[256];
    char wrk[384];
    char fpath[64];
    char dt[20], tm[10];

    // 投薬タイミング通知のJSONデータ作成
    ret = -1;
    strcpy(jdata, "{");
    if ( facility_cd[0] != 0 && device_edge_no ) {
        // 施設コード
        memset(buf, 0, sizeof(buf));
        memcpy(buf, facility_cd, sizeof(facility_cd));
        sprintf(wrk, "\\\"facilityCd\\\":\\\"%s\\\",", buf);
        strcat(jdata, wrk);
        // デバイスエッジ番号
        sprintf(wrk, "\\\"deviceEdgeNo\\\":%d,", device_edge_no);
        strcat(jdata, wrk);
        // 装置型式
        memset(buf, 0, sizeof(buf));
        memcpy(buf, sp->deviceType, sizeof(sp->deviceType));
        sprintf(wrk, "\\\"machineTypeCd\\\":\\\"%s\\\",", buf);
        strcat(jdata, wrk);
        // 通信フォーマット
        sprintf(wrk, "\\\"comFormatCd\\\":\\\"%c\\\",", sp->devsw);
        strcat(jdata, wrk);
        // 装置シリアル
        memset(buf, 0, sizeof(buf));
        memcpy(buf, sp->devid, 7);
        sprintf(wrk, "\\\"machineSerial\\\":\\\"%s\\\",", buf);
        strcat(jdata, wrk);
        // オーダー番号
        sprintf(wrk, "\\\"ordNo\\\":%ld,", sp->ord_no);
        strcat(jdata, wrk);
        // 患者ID
        sprintf(wrk, "\\\"patId\\\":%ld,", sp->pat_id);
        strcat(jdata, wrk);
        // 発生日時
        time_str(get_time(), dt, tm, 1);
        dt[4] = dt[7] = tm[2] = tm[5] = 0;
        memset(buf, 0, sizeof(buf));
        sprintf(buf, "%s%s%s%s%s%s", dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
        sprintf(wrk, "\\\"occurDate\\\":\\\"%s\\\",", buf);
        strcat(jdata, wrk);
        // 薬剤名称
        comsv_work_fpath(sp->dev_no, WORK_LCD_REQ41, fpath);
        comsv_json_lcd_req41_getname(fpath, no, buf);
        sprintf(wrk, "\\\"medicineName\\\":\\\"%s\\\"", buf);
        strcat(jdata, wrk);
        ret = 0;
    }
    strcat(jdata, "}");

    return ret;
}

