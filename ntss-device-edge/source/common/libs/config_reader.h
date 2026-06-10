#ifndef _CONFIG_READER_H_
#define _CONFIG_READER_H_
 
#include <stdint.h>
#include <string.h>

typedef struct {
    char keyStr[250];
    char val[250];
} ConfigData_t;

/**
 * @brief 
 * key=value形式の文字列で構成されたファイルから、
 * keyとvalueを分割して取得する
 * 
 * @param configFileName 読み取りファイル名
 * @param configData 取得結果を格納するconfigData構造体のポインタ
 * @return int32_t 
 */
int16_t readConfigDataFile(const char *configFileName, ConfigData_t *configData, int16_t maxSize);
 

/**
* @brief configDataから指定したキーの値を取得する
*
* @details configDataから指定したキーの値を取得する
*
* @description
* @param[in] *configData    格納情報
: @param[in] maxSize        格納情報最大件数
* @param[in] *pKey          検索するキー文字列
* @param[out] **ppVal       タを格納するポインタ
* @return NULL：取得失敗/else：キー値のポインタ
* @attention 特になし
*/
extern char *
getConfigDataValue( ConfigData_t *configData
                  , int16_t maxSize
                  , char *pKey
                  );

#endif // _CONFIG_READER_H_