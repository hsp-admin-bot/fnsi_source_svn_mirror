/**
* @file comsv_json_num.c
* @brief JSONライブラリ（Parson）のラッパー関数
* @author Y.Takamura
* @date 2019/05/16
* @details JSON文字列から数値を取得する
*/

#include <stdio.h>
// #11367 2025.01.09 add 次患者情報のJSONデータ取得処理変更 TDC高村 start
#include <stdlib.h>
// #11367 2025.01.09 add 次患者情報のJSONデータ取得処理変更 TDC高村 end
#include <string.h>
#include "comsv_json_num.h"

/**
 * @fn long comsv_json_dotget_short(JSON_Object *obj, char *key)
 * @brief JSON文字列から数値（short型）を取得する
 * @param[in] obj JSONオブジェクト
 * @param[in] key キー名称
 * @return 取得結果（対象なしは0）
 */
short comsv_json_dotget_short(JSON_Object *obj, char *key) {
    short ret;
    double val;
    
    // keyが見つからない場合、-99999が返える
    val = json_object_dotget_number(obj, key);
    // keyが見つからない場合、値を0にする
    if ( val <= -99999 ) val = 0;
    ret = (short)(val);

    return ret;
}

/**
 * @fn long comsv_json_dotget_int(JSON_Object *obj, char *key)
 * @brief JSON文字列から数値（int型）を取得する
 * @param[in] obj JSONオブジェクト
 * @param[in] key キー名称
 * @return 取得結果（対象なしは0）
 */
int comsv_json_dotget_int(JSON_Object *obj, char *key) {
    int ret;
    double val;
    
    // keyが見つからない場合、-99999が返える
    val = json_object_dotget_number(obj, key);
    // keyが見つからない場合、値を0にする
    if ( val <= -99999 ) val = 0;
    ret = (int)(val);
    
    return ret;
}

/**
 * @fn long comsv_json_dotget_long(JSON_Object *obj, char *key)
 * @brief JSON文字列から数値（long型）を取得する
 * @param[in] obj JSONオブジェクト
 * @param[in] key キー名称
 * @return 取得結果（対象なしは0）
 */
long comsv_json_dotget_long(JSON_Object *obj, char *key) {
    long ret;
    double val;
    
    // keyが見つからない場合、-99999が返える
    val = json_object_dotget_number(obj, key);
    // keyが見つからない場合、値を0にする
    if ( val <= -99999 ) val = 0;
    ret = (long)(val);
    
    return ret;
}

/**
 * @fn long comsv_json_dotget_double(JSON_Object *obj, char *key)
 * @brief JSON文字列から数値（double型）を取得する
 * @param[in] obj JSONオブジェクト
 * @param[in] key キー名称
 * @return 取得結果（対象なしは0）
 */
double comsv_json_dotget_double(JSON_Object *obj, char *key) {
    double val;
    
    // keyが見つからない場合、-99999が返える
    val = json_object_dotget_number(obj, key);
    // keyが見つからない場合、値を0にする
    if ( val <= -99999 ) val = 0;
    
    return val;
}

// #11367 2025.01.09 add 次患者情報のJSONデータ取得処理変更 TDC高村 start
/**
 * @fn int comsv_json_strget_double(char *buffer, char *key, double *value)
 * @brief JSON文字列から数値（double型）を取得する
 * @param[in] buffer JSON文字列
 * @param[in] key キー名称
 * @param[out] value 取得値
 * @return 結果（-1:入力異常, 0:取得値なし, 1:取得値あり）
 */
int comsv_json_strget_double(char *buffer, char *key, double *value)
{
    int i, j;
    int ret = -1;
    int len_buf;
    int len_key;
    char *p;
    char str_key[24];
    char str_val[24];
    char str_buf[1024];

    // 入力チェック
    if ( key == "" || key[0] == 0 ) return ret;
    len_buf = strlen(buffer);
    if ( len_buf <= 0 ) return ret;
    memset(str_key, 0, sizeof(str_key));
    sprintf(str_key, "\"%s\":", key);
    len_key = strlen(str_key);
    if ( len_key == 0 ) return ret;

    // キーチェック
    ret = 0;
    p = strstr(buffer, str_key);
    if ( p == NULL ) return ret;
    memset(str_buf, 0, sizeof(str_buf));
    strcpy(str_buf, p + len_key);
    len_buf = strlen(str_buf);
    if ( len_buf == 0 ) return ret;

    // 値チェック
    memset(str_val, 0, sizeof(str_val));
    for ( i=0, j=0; i < len_buf; i++ ) {
        if ( str_buf[i] == ',' || str_buf[i] == '}' ) break;
        if ( str_buf[i] >= '0' && str_buf[i] <= '9' || str_buf[i] == '.' ) {
           str_val[j] = str_buf[i];
           j++;
        }
    }
    if ( j && strlen(str_val) != 0 ) {
        ret = 1;
        *value = atof(str_val);
    }

    return ret;
}
// #11367 2025.01.09 add 次患者情報のJSONデータ取得処理変更 TDC高村 end
