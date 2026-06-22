#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

#include "config_reader.h"


#define STR_MAX 200

/**
 * @brief 
 * 
 * key=value形式の文字列から、valueを取得する
 * 
 * @param str key=value形式の文字列
 * @param param value格納先
 * @return int32_t 
 */
int32_t getParam(const char *str, char *keyStr, char *val){
    int32_t cnt = 0;
    int32_t idx = 0;
    int32_t ret = 0;

    if( strchr( str, '=' ) != 0 )
    {
        ret = 1;
        while (str[cnt] != '=' && str[cnt] != '\n' && str[cnt] != '\0') {
            keyStr[idx++] = str[cnt++];
        }
        keyStr[idx] = '\0';
        cnt++;
        idx=0;

        while (str[cnt] != '\n' && str[cnt] != '\0') {
            val[idx++] = str[cnt++];
        }
        val[idx] = '\0';
    }
    return ret;
}


/**
 * @brief 
 * key=value形式の文字列で構成されたファイルから、
 * keyとvalueを分割して取得する
 * 
 * @param configFileName 読み取りファイル名
 * @param configData 取得結果を格納するconfigData構造体のポインタ
 * @return int32_t 
 */
int16_t readConfigDataFile(const char *configFileName, ConfigData_t *configData, int16_t maxSize){
    FILE *fin;
    if ((fin = fopen(configFileName, "r")) == NULL) {
        printf("fin error:[%s]", configFileName);
        return -1; /* system error */
    }
    char str[STR_MAX] = {0};
    uint16_t idx = 0;
    char keyStr[STR_MAX], val[STR_MAX];
    while(idx < maxSize) {
        if (fgets(str, STR_MAX, fin) == NULL) {
            /* EOF */
            fclose(fin);
            return idx; 
        }
        if(strncmp(str, ";", 1) == 0){
            // コメント行
            continue;
        }
        if( getParam(str, keyStr, val) == 1 )
        {
            //strncpy(configData[idx].keyStr, keyStr, STR_MAX);
            //strncpy(configData[idx].val, val, STR_MAX);
			strcpy(configData[idx].keyStr, keyStr);
			strcpy(configData[idx].val, val);
            idx++;        
        }
    }
    fclose(fin);
    return idx; 
}

/**
* @brief configDataから指定したキーの値を取得する
*
* @details configDataから指定したキーの値を取得する
*
* @description
* @param[in] *configData    格納情報
: @param[in] maxSize        格納情報最大件数
* @param[in] *pKey          検索するキー文字列
* @return NULL：取得失敗/else：キー値のポインタ
* @attention 特になし
*/
char *
getConfigDataValue( ConfigData_t *configData
                  , int16_t maxSize
                  , char *pKey
                  )
{
    char *ret = NULL;
    int nKeySize;

    // 格納情報件数分
    int intlop;
    for( intlop = 0; intlop < maxSize; intlop++ )
    {
        // キー長さ取得
        //nKeySize = strlen( configData[intlop].keyStr );
		nKeySize = strlen( pKey );

        // debug
        //printf(" No.%d [Size:%d - Data:%s Value:%s / Key:%s]\n", intlop + 1, nKeySize, configData[intlop].keyStr, configData[intlop].val, pKey );

        // キー判定
        if( 0 < nKeySize && memcmp( configData[intlop].keyStr, pKey, nKeySize) == 0 )
        {
            // 該当あり

            // 値のポインタ取得
            ret = configData[intlop].val;
            
            break;
        }
    }

    return ret;
}
