/**
* @file comsv_json_mst.c
* @brief JSON文字列変換処理（マスタ関連）
* @author Y.Takamura
* @date 2018/10/26
* @details JSON文字列から構造体に格納する
*/

#include <stdio.h>
#include <string.h>
#include "ntss_comsv.h"
#include "comsv_json_num.h"

/**
 * @fn int comsv_json_mst_comset(char *jfile, ComsvSetting_t *comset)
 * @brief JSON文字列から通信サーバ設定構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] comset 通信サーバ構造体
 * @return 0:成功, -1:エラー
 */
int comsv_json_mst_comset(char *jfile, ComsvSetting_t *comset) {
    int i, j;
    int count;
    short num;
    double val;
    char *bp;
    char buf[255], sjis[255];
    char title[20], item[20];
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;

    memset(comset, 0, sizeof(ComsvSetting_t));
    comset->device_timeout = 60;    // 初期値（60秒）
    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // 新通信一斉時刻合わせ
    bp = (char*)json_object_dotget_string(root, "isTimeset");
    if ( bp != NULL && bp[0] != 0 ) {
        comset->is_timeset = bp[0];
    }
    if ( comset->is_timeset == '1' ) {
        // 新通信一斉時刻合わせ時刻
        bp = (char*)json_object_dotget_string(root, "timesetTime");
        if ( bp != NULL && bp[0] != 0 ) {
            strcpy(buf, bp);
            if ( strlen(buf) == 4 ) {
                sprintf(item, "%.2s:%.2s", buf, buf + 2);
                memcpy(comset->timeset_time, item, sizeof(comset->timeset_time));
            }
        }
    }
    // NX通信一斉時刻合わせ
    bp = (char*)json_object_dotget_string(root, "isTimesetNx");
    if ( bp != NULL && bp[0] != 0 ) {
        comset->is_timeset_nx = bp[0];
    }
    if ( comset->is_timeset_nx == '1' ) {
        // NX通信一斉時刻合わせ時刻
        bp = (char*)json_object_dotget_string(root, "timesetNxTime");
        if ( bp != NULL && bp[0] != 0 ) {
            strcpy(buf, bp);
            if ( strlen(buf) == 4 ) {
                sprintf(item, "%.2s:%.2s", buf, buf + 2);
                memcpy(comset->timeset_nx_time, item, sizeof(comset->timeset_nx_time));
            }
        }
    }
    // 仮想端末ログ時間
    bp = (char*)json_object_dotget_string(root, "lcdLogTime");
    if ( bp != NULL && bp[0] != 0 ) {
        comset->lcd_log_time = bp[0];
    }
    // 仮想端末ログ内容
    bp = (char*)json_object_dotget_string(root, "lcdLogType");
    if ( bp != NULL && bp[0] != 0 ) {
        comset->lcd_log_type = bp[0];
    }
    // 仮想端末投与時間帯表示
    bp = (char*)json_object_dotget_string(root, "isLcdMedi");
    if ( bp != NULL && bp[0] != 0 ) {
        comset->is_lcd_medi = bp[0];
    }
    // 排液判定待機時間
    comset->end_wait_time = comsv_json_dotget_short(root, "endWaitTime");
    if ( comset->end_wait_time < 0 ) comset->end_wait_time = 0;
    // 患者切り替えタイミング
    bp = (char*)json_object_dotget_string(root, "patTiming");
    if ( bp != NULL && bp[0] != 0 ) {
        comset->pat_timing = bp[0];
    }
    // お知らせ機能
    bp = (char*)json_object_dotget_string(root, "isNotice");
    if ( bp != NULL && bp[0] != 0 ) {
        comset->is_notice = bp[0];
    }
    if ( comset->is_notice == '1' ) {
        // お知らせ機能補正時間
        // お知らせ機能がOFFの場合、お知らせ機能補正時間は0
        comset->notice_time = comsv_json_dotget_short(root, "noticeTime");
        if ( comset->notice_time < 0 ) comset->notice_time = 0;
    }
    // ログのアップロード実施時刻
    bp = (char*)json_object_dotget_string(root, "logUploadTime");
    if ( bp != NULL && bp[0] != 0 ) {
        strcpy(buf, bp);
        if ( strlen(buf) == 4 ) {
            sprintf(item, "%.2s:%.2s", buf, buf + 2);
            memcpy(comset->log_upload_time, item, sizeof(comset->log_upload_time));
        }
    }
    // オフライン運転自動開始時間
    val = json_object_dotget_number(root, "offlineStartTime");
    if ( val <= -99999 ) comset->offline_start_time = -1;
    else comset->offline_start_time = (short)(val);
    // オフライン運転自動終了
    bp = (char*)json_object_dotget_string(root, "isOfflineAutoEnd");
    if ( bp != NULL && bp[0] != 0 ) {
        comset->is_offline_auto_end = bp[0];
    }
    // 日付変更時次患者更新時刻
    bp = (char*)json_object_dotget_string(root, "reloadNextPatTime");
    if ( bp != NULL && bp[0] != 0 ) {
        strcpy(buf, bp);
        if ( strlen(buf) == 4 ) {
            sprintf(item, "%.2s:%.2s", buf, buf + 2);
            memcpy(comset->reload_next_pat_time, item, sizeof(comset->reload_next_pat_time));
        }
    }
    // 装置生存監視時間
    comset->device_timeout = comsv_json_dotget_short(root, "deviceTimeout");
    if ( comset->device_timeout <= 0 ) comset->device_timeout = 60;
    // 治療中モニタ通知間隔
    comset->treat_moni_interval = comsv_json_dotget_short(root, "treatMoniInterval");
    //if ( comset->treat_moni_interval <= 0 ) comset->treat_moni_interval = 900;
    // 治療外モニタ通知間隔
    comset->other_moni_interval = comsv_json_dotget_short(root, "otherMoniInterval");
    //if ( comset->other_moni_interval <= 0 ) comset->other_moni_interval = 3600;
    // add 治療記録用データと治療状況用データの登録先を振分けにする 高 start
    // 治療中リアルタイムモニタ通知間隔
    comset->treat_realtime_monito_interval = comsv_json_dotget_short(root, "treatRealtimeMonitoInterval");
    // 治療外リアルタイムモニタ通知間隔
    comset->other_realtime_monito_interval = comsv_json_dotget_short(root, "otherRealtimeMonitoInterval");
    // add 治療記録用データと治療状況用データの登録先を振分けにする 高 end
    // 仮想端末メニュー表示設定
    for ( i = 0; i < 4; i++ ) {
        sprintf(title, "lcdMenu.menu%d_title", i + 1);
        bp = (char*)json_object_dotget_string(root, title);
        if ( bp != NULL && bp[0] != 0 ) {
            strcpy(buf, bp);
            memset(sjis, 0, sizeof(sjis));
            utf8tosjis(buf, sjis);
            memcpy(comset->lcd_menu[i].title, sjis, sizeof(comset->lcd_menu[i].title));
        }
        sprintf(item, "lcdMenu.menu%d_item", i + 1);
        array = json_object_dotget_array(root, item);
        if ( array == NULL ) continue;
        count = (int)json_array_get_count(array);
        for ( j = 0; j < count; j++ ) {
            if ( j >= 8 ) break;
            obj = json_array_get_object (array, j);
            if ( obj == NULL ) continue;
            comset->lcd_menu[i].no[j] = comsv_json_dotget_short(obj, "code");
            bp = (char*)json_object_dotget_string(obj, "name");
            if ( bp != NULL && bp[0] != 0 ) {
                strcpy(buf, bp);
                memset(sjis, 0, sizeof(sjis));
                utf8tosjis(buf, sjis);
                memcpy(comset->lcd_menu[i].name[j], sjis, sizeof(comset->lcd_menu[i].name[j]));
            }
        }
    }
    // 透析日報表示設定
    array = json_object_dotget_array(root, "lcdReport.report_item");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        for ( i = 0; i < count; i++ ) {
            obj = json_array_get_object (array, i);
            if ( obj == NULL ) continue;
            j = comsv_json_dotget_short(obj, "no");
            if ( j <= 0 || j > 8 ) continue;
            bp = (char*)json_object_dotget_string(obj, "name");
            if ( bp != NULL && bp[0] != 0 ) {
                strcpy(buf, bp);
                memset(sjis, 0, sizeof(sjis));
                utf8tosjis(buf, sjis);
                memcpy(comset->lcd_report[j-1].name, sjis, sizeof(comset->lcd_report[j-1].name));
            }
        }
    }
    // 検査１グラフ表示設定
    array = json_object_dotget_array(root, "lcdGraph1.graph1_item");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        for ( i = 0; i < count; i++ ) {
            if ( i >= 5 ) break;
            obj = json_array_get_object (array, i);
            if ( obj == NULL ) continue;
            bp = (char*)json_object_dotget_string(obj, "name");
            if ( bp != NULL && bp[0] != 0 ) {
                strcpy(buf, bp);
                memset(sjis, 0, sizeof(sjis));
                utf8tosjis(buf, sjis);
                memcpy(comset->lcd_graph1[i].name, sjis, sizeof(comset->lcd_graph1[i].name));
            }
            bp = (char*)json_object_dotget_string(obj, "code1");
            if ( bp != NULL && bp[0] != 0 ) {
                strcpy(buf, bp);
                comset->lcd_graph1[i].code[0] = atol(buf);
            }
            bp = (char*)json_object_dotget_string(obj, "code2");
            if ( bp != NULL && bp[0] != 0 ) {
                strcpy(buf, bp);
                comset->lcd_graph1[i].code[1] = atol(buf);
            }
            bp = (char*)json_object_dotget_string(obj, "code3");
            if ( bp != NULL && bp[0] != 0 ) {
                strcpy(buf, bp);
                comset->lcd_graph1[i].code[2] = atol(buf);
            }
        }
    }
    // 検査２グラフ表示設定
    array = json_object_dotget_array(root, "lcdGraph2.graph2_item");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        for ( i = 0; i < count; i++ ) {
            if ( i >= 5 ) break;
            obj = json_array_get_object (array, i);
            if ( obj == NULL ) continue;
            bp = (char*)json_object_dotget_string(obj, "name");
            if ( bp != NULL && bp[0] != 0 ) {
                strcpy(buf, bp);
                memset(sjis, 0, sizeof(sjis));
                utf8tosjis(buf, sjis);
                memcpy(comset->lcd_graph2[i].name, sjis, sizeof(comset->lcd_graph2[i].name));
            }
            bp = (char*)json_object_dotget_string(obj, "graph1_name");
            if ( bp != NULL && bp[0] != 0 ) {
                strcpy(buf, bp);
                memset(sjis, 0, sizeof(sjis));
                utf8tosjis(buf, sjis);
                memcpy(comset->lcd_graph2[i].graph1_name, sjis, sizeof(comset->lcd_graph2[i].graph1_name));
            }
            bp = (char*)json_object_dotget_string(obj, "code_bfr1");
            if ( bp != NULL && bp[0] != 0 ) {
                strcpy(buf, bp);
                comset->lcd_graph2[i].code1[0] = atol(buf);
            }
            bp = (char*)json_object_dotget_string(obj, "code_afr1");
            if ( bp != NULL && bp[0] != 0 ) {
                strcpy(buf, bp);
                comset->lcd_graph2[i].code1[1] = atol(buf);
            }
            bp = (char*)json_object_dotget_string(obj, "code_bar1");
            if ( bp != NULL && bp[0] != 0 ) {
                strcpy(buf, bp);
                comset->lcd_graph2[i].code1[2] = atol(buf);
            }
            bp = (char*)json_object_dotget_string(obj, "graph2_name");
            if ( bp != NULL && bp[0] != 0 ) {
                strcpy(buf, bp);
                memset(sjis, 0, sizeof(sjis));
                utf8tosjis(buf, sjis);
                memcpy(comset->lcd_graph2[i].graph2_name, sjis, sizeof(comset->lcd_graph2[i].graph2_name));
            }
            bp = (char*)json_object_dotget_string(obj, "code_bfr2");
            if ( bp != NULL && bp[0] != 0 ) {
                strcpy(buf, bp);
                comset->lcd_graph2[i].code2[0] = atol(buf);
            }
            bp = (char*)json_object_dotget_string(obj, "code_afr2");
            if ( bp != NULL && bp[0] != 0 ) {
                strcpy(buf, bp);
                comset->lcd_graph2[i].code2[1] = atol(buf);
            }
            bp = (char*)json_object_dotget_string(obj, "code_bar2");
            if ( bp != NULL && bp[0] != 0 ) {
                strcpy(buf, bp);
                comset->lcd_graph2[i].code2[2] = atol(buf);
            }
        }
    }
    // 検査レーダーチャート表示設定
    array = json_object_dotget_array(root, "lcdRadar.radar_item");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        for ( i = 0; i < count; i++ ) {
            if ( i >= 6 ) break;
            obj = json_array_get_object (array, i);
            if ( obj == NULL ) continue;
            bp = (char*)json_object_dotget_string(obj, "code");
            if ( bp != NULL && bp[0] != 0 ) {
                strcpy(buf, bp);
                comset->lcd_radar[i].code = atol(buf);
            }
        }
    }
    
    // add FNSI-バグ 通信サーバ 高 start
    // 治療時間
    comset->treatment_judge_time = 0;
    bp = (char*)json_object_dotget_string(root, "treatmentJudgeTime");
    if ( bp != NULL && bp[0] != 0 ) {
        strncpy(buf, bp, sizeof(buf));
        comset->treatment_judge_time = atoi(buf);
    }
    
    // 仮想端末投与時間
    bp = (char*)json_object_dotget_string(root, "lcdMediTime");
    if ( bp != NULL && bp[0] != 0 ) {
        comset->lcd_medi_time = bp[0];
    }
    // add FNSI-バグ 通信サーバ 高 end
    
    json_value_free(root_value);

    return 0;
}

/**
 * @fn int comsv_json_mst_checklist(char *jfile, CheckListMst_t *checklist)
 * @brief JSON文字列からチェックリストマスタ構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] checklist チェックリストマスタ構造体
 * @return 0:成功, -1:エラー
 */
int comsv_json_mst_checklist(char *jfile, CheckListMst_t *checklist) {
    int i, cd;
    int count;
    char *bp;
    char buf[1000], sjis[500];
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;

    memset(checklist, 0, sizeof(CheckListMst_t));
    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // チェックリストマスタ
    array = json_object_get_array(root, "ListData");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        for ( i = 0; i < count; i++ ) {
            if ( i >= CHECK_LIST_MAX ) break;
            obj = json_array_get_object (array, i);
            if ( obj == NULL ) continue;
            cd = (int)comsv_json_dotget_int(obj, "listCd");
            if ( cd < 1 || cd > CHECK_LIST_MAX ) continue;
            //mod redmine bug# 5919 劉 start
            //cd--;
            //checklist->list_cd[cd] = cd + 1;
            checklist->list_cd[i] = cd;
            //mod redmine bug# 5919 劉 end
            bp = (char*)json_object_dotget_string(obj, "listName");
            if ( bp != NULL && bp[0] != 0 ) {
                memset(buf, 0, sizeof(buf));
                strcpy(buf, bp);
                memset(sjis, 0, sizeof(sjis));
                utf8tosjis(buf, sjis);
                //mod redmine bug# 5919 劉 start
                //memcpy(checklist->list_name[cd], sjis, sizeof(checklist->list_name[cd]));
                memcpy(checklist->list_name[i], sjis, sizeof(checklist->list_name[i]));
                //mod redmine bug# 5919 劉 end
            }
            //mod redmine bug# 5919 劉 start
            //checklist->list_time[cd] = comsv_json_dotget_int(obj, "listProg");
            checklist->list_time[i] = comsv_json_dotget_int(obj, "listProg");
            //mod redmine bug# 5919 劉 end
        }
    }
    json_value_free(root_value);

    return 0;
}

/**
 * @fn int comsv_json_mst_examitem(char *jfile, ExamItemMst_t *examitem)
 * @brief JSON文字列から検査項目マスタ構造体に格納する
 * @param[in] jfile JSONファイル名
 * @param[out] examitem 検査項目マスタ構造体
 * @return 0:成功, -1:エラー
 */
int comsv_json_mst_examitem(char *jfile, ExamItemMst_t *examitem) {
    int i;
    int count;
    long cd;
    char *bp;
    char buf[1000], sjis[500];
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;

    memset(examitem, 0, sizeof(ExamItemMst_t));
    if ( jfile == "" ) return -1;
    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // 検査項目マスタ
    array = json_object_get_array(root, "ListData");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
        for ( i = 0; i < count; i++ ) {
            if ( i >= EXAM_ITEM_MAX ) break;
            obj = json_array_get_object (array, i);
            if ( obj == NULL ) continue;
            cd = (long)comsv_json_dotget_long(obj, "examItemCd");
            if ( cd <= 0 ) continue;
            examitem->item_cd[i] = cd;
            bp = (char*)json_object_dotget_string(obj, "examItemName");
            if ( bp != NULL && bp[0] != 0 ) {
                memset(buf, 0, sizeof(buf));
                strcpy(buf, bp);
                memset(sjis, 0, sizeof(sjis));
                utf8tosjis(buf, sjis);
                memcpy(examitem->item_name[i], sjis, sizeof(examitem->item_name[i]));
            }
            bp = (char*)json_object_dotget_string(obj, "unit");
            if ( bp != NULL && bp[0] != 0 ) {
                memset(buf, 0, sizeof(buf));
                strcpy(buf, bp);
                // mod FNSI-バグ 通信サーバ 高 start
                memset(sjis, 0, sizeof(sjis));
                utf8tosjis(buf, sjis);
                //memcpy(examitem->unit[i], buf, sizeof(examitem->unit[i]));
                memcpy(examitem->unit[i], sjis, sizeof(examitem->unit[i]));
                // mod FNSI-バグ 通信サーバ 高 end
            }
            examitem->decimal[i] = comsv_json_dotget_short(obj, "inputDecimalFigure");
            bp = (char*)json_object_dotget_string(obj, "graphUpper");
            if ( bp != NULL && bp[0] != 0 ) {
                memset(buf, 0, sizeof(buf));
                strcpy(buf, bp);
                examitem->graph_upper[i] = comsv_lcd_strlong(buf, examitem->decimal[i]);
            }
            bp = (char*)json_object_dotget_string(obj, "graphLower");
            if ( bp != NULL && bp[0] != 0 ) {
                memset(buf, 0, sizeof(buf));
                strcpy(buf, bp);
                examitem->graph_lower[i] = comsv_lcd_strlong(buf, examitem->decimal[i]);
            }
            //add redmine bug#6766,6767 劉 start
            bp = (char*)json_object_dotget_string(obj, "consoleClass");
            if ( bp != NULL && bp[0] != 0 ) {
                examitem->console_class[i] = bp[0];
            }
            //add redmine bug#6766,6767 劉 end
        }
    }
    json_value_free(root_value);

    return 0;
}
