/**
* @file comsv_json_ord.c
* @brief JSON文字列変換処理（治療情報関連）
* @author Y.Takamura
* @date 2018/10/26
* @details JSON文字列から構造体に格納する
*/

#include <stdio.h>
#include <string.h>
#include "ntss_comsv.h"
#include "comsv_json_num.h"

/**
 * @fn int comsv_json_dev_npat1(char *jfile, unsigned char *data)
 * @brief JSON文字列から次患者情報１送信データに格納する
 * @param[in] jfile JSONファイル名
 * @param[out] data 次患者情報１送信データ
 * @return 0:次患者情報送信（無）, 1:次患者情報送信（有）, -1:エラー
 */
int comsv_json_ord_npat(char *jfile, unsigned char *data) {
    int ret;
    int i, cd;
    short val;
    char *bp;
    char buf[200];
    char wrk[100];
    char sjis[100];
    char name[200];
    char value[200];
    char unit[200];
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

    // 次患者情報送信有無
    ret = comsv_json_dotget_int(root, "needToSend");
    if ( ret < 0 || ret > 1 ) ret = 0;

    // 患者名
    memset(buf, 0, sizeof(buf));
    memset(wrk, 0, sizeof(wrk));
    bp = (char*)json_object_dotget_string(root, "patLastName");
    if ( bp != NULL && bp[0] != 0 ) {
        strcpy(buf, bp);
        memset(sjis, 0, sizeof(sjis));
        utf8tosjis(buf, sjis);
        strcpy(wrk, sjis);
    }
    memset(buf, 0, sizeof(buf));
    bp = (char*)json_object_dotget_string(root, "patFirstName");
    if ( bp != NULL && bp[0] != 0 ) {
        strcpy(buf, bp);
        memset(sjis, 0, sizeof(sjis));
        utf8tosjis(buf, sjis);
        strcat(wrk, sjis);
    }
    comsv_lcd_memcpy(data, wrk, 20);
    data += 20;
    // 日付
    bp = (char*)json_object_dotget_string(root, "dialysisDate");
    if ( bp != NULL && bp[0] != 0 ) {
        memset(buf, 0, sizeof(buf));
        strcpy(buf, bp);
        sprintf(wrk, "%.4s/%.2s/%.2s", buf, buf + 4, buf + 6);
    }
    else {
        strcpy(wrk, "    /  /  ");
    }
    comsv_lcd_memcpy(data, wrk, 10);
    data += 10;
    // クール
    memset(buf, 0, sizeof(buf));
    memset(sjis, 0, sizeof(sjis));
    bp = (char*)json_object_dotget_string(root, "kur");
    if ( bp != NULL && bp[0] != 0 ) {
        strcpy(buf, bp);
        utf8tosjis(buf, sjis);
    }
    comsv_lcd_memcpy(data, sjis, 4);
    data += 4;
    // メモ
    // #9147 2023.12.22 add メモリストを20件にし、次患者情報2段組表示ON/OFFで[20件有効/10件有効で後半10件null]を切り替え TDC山崎 start
    // 10件の場合は「"memo11":null」、20件の場合は未設定(code=0)でも「"memo11":{"cd":0,"name":null,"value":null,"unit":null}」
    bool isNextPatSplitareaFuncEnabled = json_object_dothas_value(root, "memo11.cd");
    bool isHeadOfRow = true;
    int memoCharsCount = 0;
    // #9147 2023.12.22 add メモリストを20件にし、次患者情報2段組表示ON/OFFで[20件有効/10件有効で後半10件null]を切り替え TDC山崎 end
    
    // #9147 2023.12.22 chg メモリストを20件にし、次患者情報2段組表示ON/OFFで[20件有効/10件有効で後半10件null]を切り替え TDC山崎 start
    //for ( i = 1; i <= 10; i++ ) {
    for ( i = 1; i <= 20; i++ ) {
        bool isNextPatSplitareaEffectiveItem = false;
        // #9147 2023.12.22 chg メモリストを20件にし、次患者情報2段組表示ON/OFFで[20件有効/10件有効で後半10件null]を切り替え TDC山崎 end
        memset(sjis, 0, sizeof(sjis));
        sprintf(wrk, "memo%d.cd", i);
        cd = comsv_json_dotget_int(root, wrk);
        memset(name, 0, sizeof(name));
        sprintf(wrk, "memo%d.name", i);
        bp = (char*)json_object_dotget_string(root, wrk);
        if ( bp != NULL && bp[0] != 0 ) {
            strcpy(name, bp);
        }
        memset(value, 0, sizeof(value));
        sprintf(wrk, "memo%d.value", i);
        bp = (char*)json_object_dotget_string(root, wrk);
        if ( bp != NULL && bp[0] != 0 ) {
            strcpy(value, bp);
        }
        memset(unit, 0, sizeof(unit));
        sprintf(wrk, "memo%d.unit", i);
        bp = (char*)json_object_dotget_string(root, wrk);
        if ( bp != NULL && bp[0] != 0 ) {
            strcpy(unit, bp);
        }
        if ( cd == 1 ) {    // 患者ID
            sprintf(sjis, "ID:%.12s", value);
        }
        else if ( cd == 3 ) {   // 性別・年齢
            isNextPatSplitareaEffectiveItem = true; // #9147 2023.12.25 add TDC山崎

            // #9147 2024.06.26 chg 次患者整形 2段組専用の整形 TDC山崎 start
            // sprintf(buf, "性別(年齢):%s", value);
            // utf8tosjis(buf, sjis);

            if (isNextPatSplitareaFuncEnabled) { // 2段組
                // valueには "男性 (100)" 等といった形式で値が入っているので "男性" と "(100)" にバラす
                char pattern[] = " (";
                char *find;
                long pos;

                find = strstr(value, pattern);
                if (find != NULL) {
                    pos = find - value;
                    char valueSex[20] = {'\0'};
                    char valueAge[20] = {'\0'};

                    strncpy(valueSex, value, pos); // "男性 (100)" の " (" の前までコピー → "男性"
                    strcpy(valueAge, find + 1); // "男性 (100)" の " (" で見つけた "("以降 をコピー → "(100)"
                    sprintf(buf, "性別(年齢):%s%s", valueSex, valueAge);
                    utf8tosjis(buf, sjis);
                } else {
                    sprintf(buf, "性別(年齢):%s", value); // 1段組と同じ内容
                    utf8tosjis(buf, sjis);
                }
            } else { // 1段組
                sprintf(buf, "性別(年齢):%s", value);
                utf8tosjis(buf, sjis);
            }
            // #9147 2024.06.26 chg 次患者整形 2段組専用の整形 TDC山崎 end
        }
        else if ( cd == 4 ) {   // 状態(入外)
            isNextPatSplitareaEffectiveItem = true; // #9147 2023.12.25 add TDC山崎
            sprintf(buf, "%s", name);
            utf8tosjis(buf, sjis);
        }
        else if ( cd == 5 ) {   // 病棟
            sprintf(buf, "%s", name);
            utf8tosjis(buf, sjis);
        }
        else if ( cd == 6 ) {   // 診療科
            sprintf(buf, "%s", name);
            utf8tosjis(buf, sjis);
        }
        else if ( cd == 7 ) {   // 主治医
            sprintf(buf, "主治医:%s", name);
            utf8tosjis(buf, sjis);
        }
        else if ( cd == 8 ) {   // DW
            isNextPatSplitareaEffectiveItem = true; // #9147 2023.12.25 add TDC山崎
            // #9147 2024.02.15 chg 次患者整形 指示DW→無ければpat_uniqueの最新DW TDC山崎 end
            // // #9147 2024.01.10 chg 次患者整形 データラベル調整 TDC山崎 start
            // //sprintf(sjis, "DW:%s kg", value);
            // sprintf(buf, "ＤＷ　　:%s kg", value);            
            // utf8tosjis(buf, sjis);
            // // #9147 2024.01.10 chg 次患者整形 データラベル調整 TDC山崎 end

            if (value[0] != '\0') {
                // #12297 2026.02.02 mod 次患者情報に表示される英数字が全角半角不統一 TDC高村 start
                //sprintf(buf, "ＤＷ　　:%s kg", value);
                sprintf(buf, "DW      :%s kg", value);
                // #12297 2026.02.02 mod 次患者情報に表示される英数字が全角半角不統一 TDC高村 end
            } else {
                // #12297 2026.02.02 mod 次患者情報に表示される英数字が全角半角不統一 TDC高村 start
                //sprintf(buf, "ＤＷ　　:");
                sprintf(buf, "DW      :");
                // #12297 2026.02.02 mod 次患者情報に表示される英数字が全角半角不統一 TDC高村 end
            }
            utf8tosjis(buf, sjis);
            // #9147 2024.02.15 chg 次患者整形 指示DW→無ければpat_uniqueの最新DW TDC山崎 end
        }
        else if ( cd == 9 ) {   // VA
            // #9147 2024.01.10 chg 次患者整形 データラベル調整 TDC山崎 start
            //sprintf(buf, "VA:%s", name);
            // #12297 2026.02.02 mod 次患者情報に表示される英数字が全角半角不統一 TDC高村 start
            //sprintf(buf, "∨Ａ　　:%s", name);
            sprintf(buf, "VA      :%s", name);
            // #12297 2026.02.02 mod 次患者情報に表示される英数字が全角半角不統一 TDC高村 end
            // #9147 2024.01.10 chg 次患者整形 データラベル調整 TDC山崎 end
            utf8tosjis(buf, sjis);
        }
        else if ( cd == 10 ) {   // 治療方法
            sprintf(buf, "治療方法:%s", name);
            utf8tosjis(buf, sjis);
        }
        else if ( cd == 11 ) {   // 治療開始予定時刻
            isNextPatSplitareaEffectiveItem = true; // #9147 2023.12.25 add TDC山崎
            if ( value[0] == 0 ) strcpy(value, "00:00");
            sprintf(buf, "治療開始予定:%.2s:%.2s", value, value + 2);     
            utf8tosjis(buf, sjis);
        }
        else if ( cd == 12 ) {   // 治療時間
            isNextPatSplitareaEffectiveItem = true; // #9147 2023.12.25 add TDC山崎
            if ( value[0] == 0 ) strcpy(value, "00:00");
            sprintf(buf, "治療時間:%s", value);
            utf8tosjis(buf, sjis);
        }
        else if ( cd == 13 ) {   // 治療モード
            isNextPatSplitareaEffectiveItem = true; // #9147 2023.12.25 add TDC山崎
            sprintf(buf, "%s", name);
            utf8tosjis(buf, sjis);
        }
        else if ( cd == 14 ) {   // ダイアライザ名
            sprintf(buf, "%s", name);
            utf8tosjis(buf, sjis);
        }
        else if ( cd == 15 ) {   // A針名
            // #9147 2024.01.10 chg 次患者整形 データラベル調整 TDC山崎 start
            //sprintf(buf, "A針:%s %d %s", name, 1, unit);
            if (name[0] == '\0') {
                // #12297 2026.02.02 mod 次患者情報に表示される英数字が全角半角不統一 TDC高村 start
                //sprintf(buf, "Ａ針　　:");
                sprintf(buf, "A針     :");
                // #12297 2026.02.02 mod 次患者情報に表示される英数字が全角半角不統一 TDC高村 end
            } else {
                // #12297 2026.02.02 mod 次患者情報に表示される英数字が全角半角不統一 TDC高村 start
                //sprintf(buf, "Ａ針　　:%s %d %s", name, 1, unit);
                sprintf(buf, "A針     :%s %d %s", name, 1, unit);
                // #12297 2026.02.02 mod 次患者情報に表示される英数字が全角半角不統一 TDC高村 end
            }
            // #9147 2024.01.10 chg 次患者整形 データラベル調整 TDC山崎 end
            utf8tosjis(buf, sjis);
        }
        else if ( cd == 16 ) {   // V針名
            // #9147 2024.01.10 chg 次患者整形 データラベル調整 TDC山崎 start
            //sprintf(buf, "V針:%s %d %s", name, 1, unit);
            if (name[0] == '\0') {
                // #12297 2026.02.02 mod 次患者情報に表示される英数字が全角半角不統一 TDC高村 start
                //sprintf(buf, "∨針　　:");
                sprintf(buf, "V針     :");
                // #12297 2026.02.02 mod 次患者情報に表示される英数字が全角半角不統一 TDC高村 end
            } else {
                // #12297 2026.02.02 mod 次患者情報に表示される英数字が全角半角不統一 TDC高村 start
                //sprintf(buf, "∨針　　:%s %d %s", name, 1, unit);
                sprintf(buf, "V針     :%s %d %s", name, 1, unit);
                // #12297 2026.02.02 mod 次患者情報に表示される英数字が全角半角不統一 TDC高村 end
            }
            // #9147 2024.01.10 chg 次患者整形 データラベル調整 TDC山崎 end
            utf8tosjis(buf, sjis);
        }
        else if ( cd == 17 ) {   // 抗凝固剤名
            sprintf(buf, "%s", name);
            utf8tosjis(buf, sjis);
        }
        else if ( cd == 18 ) {   // 抗凝固剤ワンショット量
            isNextPatSplitareaEffectiveItem = true; // #9147 2023.12.25 add TDC山崎

            // #9147 2024.06.27 chg 次患者整形 2段組専用の整形 TDC山崎 start
            // sprintf(buf, " 抗 ﾜﾝｼｮｯﾄ量:%s %s", value, unit);
            // utf8tosjis(buf, sjis);

            if (isNextPatSplitareaFuncEnabled) { // 2段組
                sprintf(buf, "ﾜﾝｼｮｯﾄ量:%s %s", value, unit);
                utf8tosjis(buf, sjis);
            } else { // 1段組
                sprintf(buf, " 抗 ﾜﾝｼｮｯﾄ量:%s %s", value, unit);
                utf8tosjis(buf, sjis);
            }
            // #9147 2024.06.27 chg 次患者整形 2段組専用の整形 TDC山崎 end
        }
        else if ( cd == 19 ) {   // 抗凝固剤持続注入量
            isNextPatSplitareaEffectiveItem = true; // #9147 2023.12.25 add TDC山崎

            // #9147 2024.06.27 chg 次患者整形 2段組専用の整形 TDC山崎 start
            // sprintf(buf, " 抗 持続速度:%s %s", value, unit);
            // utf8tosjis(buf, sjis);

            if (isNextPatSplitareaFuncEnabled) { // 2段組
                sprintf(buf, "持続速度:%s %s", value, unit);
                utf8tosjis(buf, sjis);
            } else { // 1段組
                sprintf(buf, " 抗 持続速度:%s %s", value, unit);
                utf8tosjis(buf, sjis);
            }
            // #9147 2024.06.27 chg 次患者整形 2段組専用の整形 TDC山崎 end
        }
        else if ( cd == 20 ) {   // 抗凝固剤持続総量
            isNextPatSplitareaEffectiveItem = true; // #9147 2023.12.25 add TDC山崎

            // #9147 2024.06.27 chg 次患者整形 2段組専用の整形 TDC山崎 start
            // sprintf(buf, " 抗 持続総量:%s %s", value, unit);
            // utf8tosjis(buf, sjis);

            if (isNextPatSplitareaFuncEnabled) { // 2段組
                sprintf(buf, "持続総量:%s %s", value, unit);
                utf8tosjis(buf, sjis);
            } else { // 1段組
                sprintf(buf, " 抗 持続総量:%s %s", value, unit);
                utf8tosjis(buf, sjis);
            }
            // #9147 2024.06.27 chg 次患者整形 2段組専用の整形 TDC山崎 end
        }
        else if ( cd == 21 ) {   // 抗凝固剤総量
            isNextPatSplitareaEffectiveItem = true; // #9147 2023.12.25 add TDC山崎

            // #9147 2024.06.27 chg 次患者整形 2段組専用の整形 TDC山崎 start
            // sprintf(buf, " 抗 総量　　:%s %s", value, unit);
            // utf8tosjis(buf, sjis);

            if (isNextPatSplitareaFuncEnabled) { // 2段組
                sprintf(buf, "総量　　:%s %s", value, unit);
                utf8tosjis(buf, sjis);
            } else { // 1段組
                sprintf(buf, " 抗 総量　　:%s %s", value, unit);
                utf8tosjis(buf, sjis);
            }
            // #9147 2024.06.27 chg 次患者整形 2段組専用の整形 TDC山崎 end
        }
        else if ( cd >= 25 && cd <= 34 ) {   // 医療材料
            // #11339 2025.01.07 mod 医療材料がない場合に":"と表示される問題の対応 TDC片口 start
            // // #9147 2024.01.10 chg 次患者整形 データラベル調整 TDC山崎 start
            // //sprintf(buf, "%s %s %s", name, value, unit);
            // sprintf(buf, "%s:%s %s", name, value, unit);
            // // #9147 2024.01.10 chg 次患者整形 データラベル調整 TDC山崎 end
            if (name[0] == 0)
            {
                sprintf(buf, "");
            }
            else
            {
                sprintf(buf, "%s:%s %s", name, value, unit);
            }
            // #11339 2025.01.07 mod 医療材料がない場合に":"と表示される問題の対応 TDC片口 end
            utf8tosjis(buf, sjis);
        }
        else if ( cd == 35 ) {   // 透析液
            sprintf(buf, "%s", name);
            utf8tosjis(buf, sjis);
        }
        else if ( cd >= 36 && cd <= 55 ) {   // 投与薬剤
            // #11339 2025.01.07 mod 投与薬剤がない場合に":"と表示される問題の対応 TDC片口 start
            // // #9147 2024.01.10 chg 次患者整形 データラベル調整 TDC山崎 start
            // //sprintf(buf, "%s %s %s", name, value, unit);
            // sprintf(buf, "%s:%s %s", name, value, unit);
            // // #9147 2024.01.10 chg 次患者整形 データラベル調整 TDC山崎 end
            if (name[0] == 0)
            {
                sprintf(buf, "");
            }
            else
            {
                sprintf(buf, "%s:%s %s", name, value, unit);
            }
            // #11339 2025.01.07 mod 投与薬剤がない場合に":"と表示される問題の対応 TDC片口 end
            utf8tosjis(buf, sjis);
        }
        // add FNSI-バグ 通信サーバ 高 start
        // #9147 2024.01.10 chg 次患者整形 データラベル調整 TDC山崎 start
        // else if ( cd >= 56 && cd <= 60 ) {
        //     isNextPatSplitareaEffectiveItem = true; // #9147 2023.12.25 add TDC山崎
        //     // 目標体重(＊) 血流量(＊) IP速度(＊) IPワンショット量(＊) IP自動切時間(＊)
        //     sprintf(buf, "%s %s %s", name, value, unit);
        //     utf8tosjis(buf, sjis);
        // }
        else if (cd == 56) { // 目標体重
            isNextPatSplitareaEffectiveItem = true;
            // #9147 2024.03.07 chg 次患者整形 指示DW→無ければpat_uniqueの最新DW TDC山崎 start
            // sprintf(buf, "目標体重:%s kg", value);
            // utf8tosjis(buf, sjis);
            if (value[0] != '\0') {
                sprintf(buf, "目標体重:%s kg", value);
            } else {
                sprintf(buf, "目標体重:");
            }
            utf8tosjis(buf, sjis);
            // #9147 2024.03.07 chg 次患者整形 指示DW→無ければpat_uniqueの最新DW TDC山崎 end
        }
        else if (cd == 57) { // 血流量
            isNextPatSplitareaEffectiveItem = true;        
            sprintf(buf, "血流量　:%s %s", value, unit);
            utf8tosjis(buf, sjis);
        }
        else if (cd == 58) { // IP速度
            isNextPatSplitareaEffectiveItem = true;

            // #9147 2024.06.27 chg 次患者整形 2段組専用の整形 TDC山崎 start
            // sprintf(buf, "IP速度　　　:%s %s", value, unit);
            // utf8tosjis(buf, sjis);

            if (isNextPatSplitareaFuncEnabled) { // 2段組
                sprintf(buf, "IP速度　:%s %s", value, unit);
                utf8tosjis(buf, sjis);
            } else { // 1段組
                sprintf(buf, "IP速度　　　:%s %s", value, unit);
                utf8tosjis(buf, sjis);
            }
            // #9147 2024.06.27 chg 次患者整形 2段組専用の整形 TDC山崎 end
        }
        else if (cd == 59) { // IPワンショット量
            isNextPatSplitareaEffectiveItem = true;

            // #9147 2024.06.27 chg 次患者整形 2段組専用の整形 TDC山崎 start
            // sprintf(buf, "IPﾜﾝｼｮｯﾄ量　:%s %s", value, unit);
            // utf8tosjis(buf, sjis);

            if (isNextPatSplitareaFuncEnabled) { // 2段組
                sprintf(buf, "IPﾜﾝｼｮｯﾄ:%s %s", value, unit);
                utf8tosjis(buf, sjis);
            } else { // 1段組
                sprintf(buf, "IPﾜﾝｼｮｯﾄ量　:%s %s", value, unit);
                utf8tosjis(buf, sjis);
            }
            // #9147 2024.06.27 chg 次患者整形 2段組専用の整形 TDC山崎 end
        }
        else if (cd == 60) { // IP自動切時間
            // #9147 2024.01.17 chg 次患者整形 IP自動切時間データ内にIP電源自動切りのON/OFFデータを含ませる TDC山崎 start
            // isNextPatSplitareaEffectiveItem = true;        
            // sprintf(buf, "IP電源自動切:%s %s", value, unit);
            // utf8tosjis(buf, sjis);

            isNextPatSplitareaEffectiveItem = true;

            // #9147 2024.06.27 chg 次患者整形 2段組専用の整形 TDC山崎 start
            // if ('0' == name[0]) {
            //     sprintf(buf, "IP電源自動切:[切]%s%s", value, unit);
            // } else {
            //     sprintf(buf, "IP電源自動切:[入]%s%s", value, unit);
            // }
            // utf8tosjis(buf, sjis);

            if (isNextPatSplitareaFuncEnabled) { // 2段組
                if ('0' == name[0]) {
                    sprintf(buf, "IP自動切:[切]%s%s", value, unit);
                } else {
                    sprintf(buf, "IP自動切:[入]%s%s", value, unit);
                }
                utf8tosjis(buf, sjis);
            } else { // 1段組
                if ('0' == name[0]) {
                    sprintf(buf, "IP電源自動切:[切]%s%s", value, unit);
                } else {
                    sprintf(buf, "IP電源自動切:[入]%s%s", value, unit);
                }
                utf8tosjis(buf, sjis);
            }
            // #9147 2024.06.27 chg 次患者整形 2段組専用の整形 TDC山崎 end
            // #9147 2024.01.17 chg 次患者整形 IP自動切時間データ内にIP電源自動切りのON/OFFデータを含ませる TDC山崎 end
        }
        // #9147 2024.01.10 chg 次患者整形 データラベル調整 TDC山崎 end
        else if ( cd == 61 ) {   // 補液選択(＊)
            isNextPatSplitareaEffectiveItem = true; // #9147 2023.12.25 add TDC山崎
            // #9147 2024.01.10 chg 次患者整形 データラベル調整 TDC山崎 start
            // if ( value[0] == '0' ) {
            //     sprintf(buf, "%s%s", name, "後補液");
            //     utf8tosjis(buf, sjis);
            // }
            // else if ( value[0] == '1' ) {
            //     sprintf(buf, "%s %s", name, "前補液");
            //     utf8tosjis(buf, sjis);
            // }
            // else {
            //     sprintf(buf, "%s", name);
            //     utf8tosjis(buf, sjis);
            // }
            char maeato[7] = {0};
            if (value[0] == '0') {
                sprintf(maeato, "%s", "後補液");
            } else if (value[0] == '1') {
                sprintf(maeato, "%s", "前補液");
            }
            
            sprintf(buf, "補液選択:%s", maeato);
            utf8tosjis(buf, sjis);
            // #9147 2024.01.10 chg 次患者整形 データラベル調整 TDC山崎 end
        }
        // #9147 2024.01.10 chg 次患者整形 データラベル調整 TDC山崎 start
        // else if ( cd >= 62 && cd <= 63 ) {
        //     isNextPatSplitareaEffectiveItem = true; // #9147 2023.12.25 add TDC山崎
        //     // 補液量(＊) 補液速度(＊)
        //     sprintf(buf, "%s %s %s", name, value, unit);
        //     utf8tosjis(buf, sjis);
        // }
        else if ( cd == 62 ) { // 補液量
            isNextPatSplitareaEffectiveItem = true;

            // #9147 2024.02.09 chg 次患者整形 データラベル調整 TDC山崎 start
            //sprintf(buf, "補液量　:%s %s", value, unit);
            if (strncmp(value, "-1", 2) == 0) {
                sprintf(buf, "補液量　:濾過率から算出");
            } else {
                sprintf(buf, "補液量　:%s %s", value, unit);
            }
            // #9147 2024.02.09 chg 次患者整形 データラベル調整 TDC山崎 end

            utf8tosjis(buf, sjis);
        }
        else if ( cd == 63 ) { // 補液速度
            isNextPatSplitareaEffectiveItem = true;
            
            // #9147 2024.02.09 chg 次患者整形 データラベル調整 TDC山崎 start
            //sprintf(buf, "補液速度:%s %s", value, unit);
            if (strncmp(value, "-1", 2) == 0) {
                sprintf(buf, "補液速度:濾過率から算出");
            } else {
                sprintf(buf, "補液速度:%s %s", value, unit);
            }
            // #9147 2024.02.09 chg 次患者整形 データラベル調整 TDC山崎 end

            utf8tosjis(buf, sjis);
        }
        // #9147 2024.01.10 chg 次患者整形 データラベル調整 TDC山崎 end
        else if ( cd == 64 ) {   // 一次膜
            // #9147 2024.01.10 chg 次患者整形 データラベル調整 TDC山崎 start
            //sprintf(buf, "一次膜 %s", name);
            sprintf(buf, "一次膜　:%s", name);
            // #9147 2024.01.10 chg 次患者整形 データラベル調整 TDC山崎 end
            utf8tosjis(buf, sjis);
        }
        // add FNSI-バグ 通信サーバ 高 end
        else if ( cd > 64 ) {   // 空白
            memset(sjis, ' ', 40);
        }
        else {  // その他
            memset(buf, 0, sizeof(buf));
            sprintf(buf, "%s%s", name, value);
            utf8tosjis(buf, sjis);
        }
        // #9147 2023.12.22 chg メモリストを20件にし、次患者情報2段組表示ON/OFFで[20件有効/10件有効で後半10件null]を切り替え TDC山崎 start
        //comsv_lcd_memcpy(data, sjis, 40);
        //data += 40;

        // メモのSJIS半角換算文字数が400文字を超えていない時だけメモ追加処理を実施
        if ( !(memoCharsCount >= 400) ) {
            if (isNextPatSplitareaFuncEnabled) { // 設定で2段組表示機能が有効
                if (isNextPatSplitareaEffectiveItem) { // (設定で2段組表示機能が有効な時の)2段組対応項目の場合
                    if (isHeadOfRow) {
                        // 現在行の先頭なので データ半角19文字+半角SP1文字をセット
                        comsv_lcd_memcpy(data, sjis, 19);
                        data += 19;
                        memset(data, ' ', sizeof(unsigned char) * 1);
                        data += 1;
                        memoCharsCount += 20;
                        isHeadOfRow = false; // メモ書き込み開始位置が (現在行の)真ん中 となっていることをメモ
                    } else {
                        // 現在行の真ん中なので データ半角19文字+半角SP1文字をセット
                        comsv_lcd_memcpy(data, sjis, 19);
                        data += 19;
                        memset(data, ' ', sizeof(unsigned char) * 1);
                        data += 1;
                        memoCharsCount += 20;
                        isHeadOfRow = true; // メモ書き込み開始位置が (次の行の)先頭 となっていることをメモ
                    }
                } else { // (設定で2段組表示機能が有効な時の)1段組専用項目
                    if (isHeadOfRow) {
                        // 現在行の先頭なので データ半角40文字をセット
                        comsv_lcd_memcpy(data, sjis, 40);
                        data += 40;
                        memoCharsCount += 40;
                        isHeadOfRow = true; // メモ書き込み開始位置が (次の行の)先頭 となっていることをメモ
                    } else {
                        // 現在行の真ん中なので 半角SP20文字をセットすることで、メモ書き込み開始位置を 次の行の先頭 へ
                        memset(data, ' ', sizeof(unsigned char) * 20);
                        data += 20;
                        memoCharsCount += 20;

                        // 上記処理で メモ書き込み開始位置 が 次の行の先頭 へ進んだ時点で
                        // メモのSJIS半角換算文字数が400文字を超える可能性があるのでチェックして超えていなければメモ追加処理を続行
                        if ( !(memoCharsCount >= 400) ) {
                            // 次の行の先頭 から データ半角40文字をセット
                            comsv_lcd_memcpy(data, sjis, 40);
                            data += 40;
                            memoCharsCount += 40;
                            isHeadOfRow = true; // メモ書き込み開始位置が (次の行の)先頭 となっていることをメモ
                        }
                    }
                }
            } else { // 設定で2段組表示機能が無効
                comsv_lcd_memcpy(data, sjis, 40);
                data += 40;
                memoCharsCount += 40;
            }
        }
        // #9147 2023.12.22 chg メモリストを20件にし、次患者情報2段組表示ON/OFFで[20件有効/10件有効で後半10件null]を切り替え TDC山崎 end
    }
    // 感染症
    val = comsv_json_dotget_short(root, "isInfect");
	short_set(data, val);
    data += 2;
    // 治療モード
    val = comsv_json_dotget_short(root, "mode");
	short_set(data, val);
    data += 2;

    json_value_free(root_value);

    return ret;
}

/**
 * @fn int comsv_json_ord_make_moni(char *jfile, unsigned char *data, u_char commType)
 * @brief 排液時更新用モニタデータからJSONデータを作成する
 * @param[in] jfile 出力JSONファイル名
 * @param[in] data モニタデータ
 * @return 0:成功, -1:エラー
 */
int comsv_json_ord_make_moni(char *jfile, unsigned char *data, u_char commType) {
    FILE *fp;
    int ret;
    int i, j;
    short idx;
    short val;
    char buf[20];
    struct moni_list item;
    static short no[7] = {
	    5,      // 除水積算値
	    69,     // 血液循環量（FNW仕様で運転中の血流量積算値を使う）
	    30,     // 透析運転時間
	    38,     // Kt/V（測定値）
	    68,     // Kt/V
	    72,     // 補液量現在値
	    79,     // ＵＲＲ
    };

    fp = fopen(jfile, "w");
    if ( fp==NULL ) return -1;

    // モニタデータのJSONファイル出力
    ret = -1;
    fprintf(fp, "{");
    for ( i = 0, j = 0; i < 7; i++ ) {
        idx = no[i];
        if ( ntss_mst_moni_data(0, "00", idx, &item) > 0 ) {
            // add FNSI-バグ 通信サーバ 高 start
            if(commType == NTSS_COMM_TYPE_COMMON) {
                val = *(short*)(data + (idx * 2));
            }
            else {
            // add FNSI-バグ 通信サーバ 高 end
                val = hl_chg( *(short*)(data + (idx * 2)) );
            }
            if ( val == (short)(0x8000) ) {
                continue;
            }
            // mod FNSI-バグ 通信サーバ 高 start
			// else if ( (j == 38 || j == 79 || j == 88) && val < 0 ) {
            else if ( (idx == 38 || idx == 79 || idx == 88) && val < 0 ) {
            // mod FNSI-バグ 通信サーバ 高 end
				// 0未満の場合は無効（Kt/V測定値, URR, PRR）
                continue;
            }
            memset(buf, 0, sizeof(buf));
            dsp_s_form(buf, 1, item.dec, val);
            if ( j == 0 ) {
                fprintf(fp, "\"mon%d\":\"%s\"", i + 1, buf);
                j++;
            }
            else {
                fprintf(fp, ",\"mon%d\":\"%s\"", i + 1, buf);
            }
            ret = 0;
        }
    }
    fprintf(fp, "}");
    fclose(fp);
 
    return ret;
}

/**
 * @fn int comsv_json_ord_make_log(char *jdata, short type, unsigned char *data)
 * @brief ログデータ（測定データ）からJSONデータを作成する
 * @param[out] jdata 出力JSONデータ
 * @param[in] type ログタイプ（0:その他,1:再循環率測定,2:I-HDF引き残し量,3:静的静脈圧,4:IAP retio）
 * @param[in] data ログデータ
 * @return 0:成功, -1:エラー
 */
int comsv_json_ord_make_log(char *jdata, short type, unsigned char *data) {
    int ret, i;
    short val, dec;
    char buf[128];
    char wrk[128];

    // ログデータのJSONデータ作成
    ret = -1;
    strcpy(jdata, "{");
    for ( i = 0; i < 4; i++ ) {
        val = 0;
        dec = 0;
        if ( type && i == 0) {
            val = hl_chg( *(short*)(data + (i * 2)) );
            if ( type == 3 && (val == 999 || val == -999) ) break;
            if ( type == 4 && (val == 999 || val == -999) ) break;
            if ( type == 2 || type == 4 ) dec = 2;
        }
        memset(buf, 0, sizeof(buf));
        dsp_s_form(buf, 1, dec, val);
        if ( i == 0 ) {
            sprintf(wrk, "\\\"log%d\\\":\\\"%s\\\"", i + 1, buf);
        }
        else {
            sprintf(wrk, ",\\\"log%d\\\":\\\"%s\\\"", i + 1, buf);
        }
        strcat(jdata, wrk);
        ret = 0;
    }
    strcat(jdata, "}");
 
    return ret;
}

/**
 * @fn int comsv_json_ord_make_comptreat(char *jdata, int *c_cd, int c_max, int *t_cd, int t_max)
 * @brief 愁訴処置（実施No配列）からJSONデータを作成する
 * @param[out] jdata 出力JSONデータ
 * @param[in] c_cd 愁訴実施No配列
 * @param[in] c_max 愁訴配列最大数
 * @param[in] t_cd 処置実施No配列
 * @param[in] c_max 処置配列最大数
 * @return 0:成功, -1:エラー
 */
int comsv_json_ord_make_comptreat(char *jdata, int *c_cd, int c_max, int *t_cd, int t_max) {
    int  i, j;
    int  ret;
    char buf[128];

    // 実施No配列のJSONデータ作成
    ret = -1;
    strcpy(jdata, "[");
    for ( i = 0, j = 0; i < c_max; i++ ) {
        if ( j == 0 ) {
            sprintf(buf, "{\\\"comp_cd\\\":%d}", c_cd[i]);
            j++;
        }
        else {
            sprintf(buf, ",{\\\"comp_cd\\\":%d}", c_cd[i]);
        }
        strcat(jdata, buf);
        ret = 0;
    }
    for ( i = 0; i < t_max; i++ ) {
        if ( j == 0 ) {
            sprintf(buf, "{\\\"treat_cd\\\":%d}", t_cd[i]);
            j++;
        }
        else {
            sprintf(buf, ",{\\\"treat_cd\\\":%d}", t_cd[i]);
        }
        strcat(jdata, buf);
        ret = 0;
    }
    strcat(jdata, "]");
 
    return ret;
}

/**
 * @fn int comsv_json_ord_make_medi(char *jdata, int *no, int max)
 * @brief 投与薬剤（実施No配列）からJSONデータを作成する
 * @param[out] jdata 出力JSONデータ
 * @param[in] no 実施No配列
 * @param[in] max 配列最大数
 * @return 0:成功, -1:エラー
 */
int comsv_json_ord_make_medi(char *jdata, int *no, int max) {
    int  i;
    int  ret;
    char buf[128];

    // 実施No配列のJSONデータ作成
    ret = -1;
    strcpy(jdata, "[");
    for ( i = 0; i < max; i++ ) {
        if ( i == 0 ) {
            sprintf(buf, "{\\\"no\\\":%d}", no[i]);
        }
        else {
            sprintf(buf, ",{\\\"no\\\":%d}", no[i]);
        }
        strcat(jdata, buf);
        ret = 0;
    }
    strcat(jdata, "]");
 
    return ret;
}

// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 start
///**
// * @fn int comsv_json_ord_make_check(char *jdata, char *jfile, int *no, int max, long cd, long date)
// * @brief チェックリスト（実施No配列）からJSONデータを作成する
// * @param[out] jdata 出力JSONデータ
// * @param[in] jfile JSONファイル名
// * @param[in] no 実施No配列
// * @param[in] max 配列最大数
// * @param[in] cd 実施者コード（拡張）
// * @param[in] date 実施日時（拡張）
// * @return 0:成功, -1:エラー
// */
//int comsv_json_ord_make_check(char *jdata, char *jfile, int *no, int max, long cd, long date) {
/**
 * @fn int comsv_json_ord_make_check(char *jdata, char *jfile, int *no, int max, long cd, time_t date)
 * @brief チェックリスト（実施No配列）からJSONデータを作成する
 * @param[out] jdata 出力JSONデータ
 * @param[in] jfile JSONファイル名
 * @param[in] no 実施No配列
 * @param[in] max 配列最大数
 * @param[in] cd 実施者コード（拡張）
 * @param[in] date 実施日時（拡張）
 * @return 0:成功, -1:エラー
 */
int comsv_json_ord_make_check(char *jdata, char *jfile, int *no, int max, long cd, time_t date) {
// #12553 2026.03.01 mod FW7に伴う2038年問題対応 TDC高村 end
    int i, j;
    int ret, num;
    int ino, count;
    char *bp;
    char dt[20], tm[10];
    char cdate[20];
    char buf[128];
    char class[20];
    char code[20];
    double val;
    JSON_Value *root_value;
    JSON_Object *root, *obj;
    JSON_Array *array;

    // 実施No配列のJSONデータ作成
    ret = -1;
    if ( max <= 0 ) return ret;
    if ( time_str(date, dt, tm, 1) == 0 ) {
        dt[4] = dt[7] = tm[2] = tm[5] = 0;
        sprintf(cdate, "%s%s%s%s%s%s", dt, dt + 5, dt + 8, tm, tm + 3, tm + 6);
    }
    else {
        strcpy(cdate, "null");
    }

    root_value = json_parse_file(jfile);
    if ( root_value == NULL ) return -1;
    root = json_object(root_value);
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }
    array = json_object_get_array(root, "ListData");
    if ( root == NULL ) {
        json_value_free(root_value);
        return -1;
    }

    // チェックリスト
    count = 0;
    array = json_object_get_array(root, "ListData");
    if ( array != NULL ) {
        count = (int)json_array_get_count(array);
    }
    if ( count > 0 ) {
        strcpy(jdata, "[");
        for ( i = 0, j = 0, num = 0; i < max; i++ ) {
            for ( ; j < count; j++ ) {
                if ( j >= REQ54_MAX ) break;
                obj = json_array_get_object (array, j);
                ino = comsv_json_dotget_int(obj, "dispNo");
                if ( no[i] == ino ) {
                    strcpy(class, "null");
                    strcpy(code, "null");
                    // #9539 チェックリストマスタの設定を変更して保存しても保存できない 高 start
                    /*val = json_object_dotget_number(obj, "classCd");
                    if ( val > 0 ) {
                        sprintf(class, "%d", (int)(val));
                    }*/
                    bp = (char*)json_object_dotget_string(obj, "classCd");
                    if ( bp != NULL && bp[0] != 0 ) {
                        memset(buf, 0, sizeof(buf));
                        strncpy(buf, bp, sizeof(buf));
                        if(strcmp(buf, "null") == 0 || strcmp(buf, "NULL") == 0) {
                        }
                        else {
                            sprintf(class, "%d", atoi(buf));
                        }
                    }
                    // #9539 チェックリストマスタの設定を変更して保存しても保存できない 高 end
                    val = json_object_dotget_number(obj, "code");
                    if ( val > 0 ) {
                        sprintf(code, "%d", (int)(val));
                    }
                    ino = comsv_json_dotget_int(obj, "itemNumber");
                    if ( num ) {
                        strcat(jdata, ",");
                    }
                    sprintf(buf, "{\\\"classCd\\\":%s,\\\"code\\\":%s,\\\"itemNumber\\\":%d,\\\"cd\\\":%ld,\\\"date\\\":\\\"%s\\\"}",
                        class, code, ino, cd, cdate);
                    strcat(jdata, buf);
                    ret = 0;
                    num++;
                    break;
                }
            }
        }
        strcat(jdata, "]");
    } 

    json_value_free(root_value);
    return ret;
}

// add FNSI-バグ 通信サーバ 高 start
/**
 * @fn int comsv_json_ordno_state(char *jfile, int *data)
 * @brief JSON文字列から患者情報送信データに格納する
 * @param[in] jfile JSONファイル名
 * @param[out] data 患者情報送信データ
 * @return 0:患者情報送信, -1:エラー
 */
int comsv_json_ordno_state(char *jfile, int *data) {
    int ret = 0;
    char *bp;
    char buf[200];
    char wrk[100];
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

    // 患者情報
    *data = 0;
    memset(buf, 0, sizeof(buf));
    memset(wrk, 0, sizeof(wrk));
    bp = (char*)json_object_dotget_string(root, "rstDialysisState");
    if ( bp != NULL && bp[0] != 0 ) {
        strcpy(buf, bp);
        *data = atoi(buf);
    }
    
    json_value_free(root_value);

    return ret;
}
// add FNSI-バグ 通信サーバ 高 end
