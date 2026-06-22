/**
* @file comsv_json_num.h
* @brief JSONライブラリ（Parson）のラッパー関数ヘッダー
* @author Y.Takamura
* @date 2019/05/16
*/

#include "../common/libs/parson.h"

/**
 * @fn long comsv_json_dotget_short(JSON_Object *obj, char *key)
 * @brief JSON文字列から数値（short型）を取得する
 * @param[in] obj JSONオブジェクト
 * @param[in] key キー名称
 * @return 取得結果（対象なしは0）
 */
extern short comsv_json_dotget_short(JSON_Object *obj, char *key);

/**
 * @fn long comsv_json_dotget_int(JSON_Object *obj, char *key)
 * @brief JSON文字列から数値（int型）を取得する
 * @param[in] obj JSONオブジェクト
 * @param[in] key キー名称
 * @return 取得結果（対象なしは0）
 */
extern int comsv_json_dotget_int(JSON_Object *obj, char *key);

/**
 * @fn long comsv_json_dotget_long(JSON_Object *obj, char *key)
 * @brief JSON文字列から数値（long型）を取得する
 * @param[in] obj JSONオブジェクト
 * @param[in] key キー名称
 * @return 取得結果（対象なしは0）
 */
extern long comsv_json_dotget_long(JSON_Object *obj, char *key);

/**
 * @fn long comsv_json_dotget_double(JSON_Object *obj, char *key)
 * @brief JSON文字列から数値（double型）を取得する
 * @param[in] obj JSONオブジェクト
 * @param[in] key キー名称
 * @return 取得結果（対象なしは0）
 */
// #11367 2025.01.09 mod 次患者情報のJSONデータ取得処理変更 TDC高村 start
//double comsv_json_dotget_double(JSON_Object *obj, char *key);
extern double comsv_json_dotget_double(JSON_Object *obj, char *key);
// #11367 2025.01.09 mod 次患者情報のJSONデータ取得処理変更 TDC高村 end

// #11367 2025.01.09 add 次患者情報のJSONデータ取得処理変更 TDC高村 start
/**
 * @fn int comsv_json_strget_double(char *buffer, char *key, double *value)
 * @brief JSON文字列から数値（double型）を取得する
 * @param[in] buffer JSON文字列
 * @param[in] key キー名称
 * @param[out] value 取得値
 * @return 結果（-1:入力異常, 0:取得値なし, 1:取得値あり）
 */
extern int comsv_json_strget_double(char *buffer, char *key, double *value);
// #11367 2025.01.09 add 次患者情報のJSONデータ取得処理変更 TDC高村 end
