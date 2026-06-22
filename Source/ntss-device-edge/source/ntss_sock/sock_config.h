/**
* @file sock_config.h
* @brief コンフィグ関連ヘッダー
* @author Y.Takamura
* @date 2019/01/07
*/

#ifndef _SOCK_CONFIG_H_
#define _SOCK_CONFIG_H_
 
#include <stdint.h>

/**
 * @brief コンフィグパラメータ
 */
typedef struct {
    uint32_t receivePort;               ///< 新通信用接続待受ポート
    uint32_t receivePort_NX;            ///< NX通信用接続待受ポート
    uint32_t requestTime_CP;            ///< 共通プロトコル通信用リクエスト間隔（秒）
    uint32_t deviceTimeout;             ///< 装置生存監視時間
    u_char timesetTime[6];
    u_char timesetTime_NX[6];
    u_char mstDir[50];                  ///< マスタ格納先フォルダ
    u_char receiveDataDirectory[50];    ///< データ収集用ファイル格納先フォルダ１
    u_char receiveDataDirectory2[50];   ///< データ収集用ファイル格納先フォルダ２
    u_char receiveDataDirectory3[50];   ///< データ収集用ファイル格納先フォルダ３
    u_char collectDataDirectory[50];    ///< データ収集用一時ファイル格納先フォルダ１
    u_char collectDataDirectory2[50];   ///< データ収集用一時ファイル格納先フォルダ２
    u_char collectDataDirectory3[50];   ///< データ収集用一時ファイル格納先フォルダ３
} ConfigParameter_t;

/**
 * @brief 設定ファイルの内容を取得
 * @param[in] configFileName 
 * @param[out] configParam 
 * @return 0:成功, -1:エラー
 */
extern uint32_t readConfigFile(const char *configFileName, ConfigParameter_t *configParam);

/**
 * @brief 共通設定ファイルの内容を取得
 * @param[in] configFileName 
 * @param[out] configParam 
 * @return 0:成功, -1:エラー
 */
extern uint32_t readConfigCommonFile(const char *configFileName, ConfigParameter_t *configParam);

/**
 * @brief 最期に入る改行(\r\n)を取り除く
 * @param[in,out] str 
 */
extern void lntrim(char *str);
 
#endif // _SOCK_CONFIG_H_
