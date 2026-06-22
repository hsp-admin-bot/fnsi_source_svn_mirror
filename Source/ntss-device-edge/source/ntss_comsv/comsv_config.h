/**
* @file comsv_config.h
* @brief コンフィグ関連ヘッダー
* @author Y.Takamura
* @date 2019/01/07
*/

#ifndef _CONFIG_READ_H_
#define _CONFIG_READ_H_
 
#include <stdint.h>

/**
 * @brief コンフィグパラメータ
 */
typedef struct {
    uint32_t receivePort;               ///< 新通信用接続待受ポート
    uint32_t receivePort_NX;            ///< NX通信用接続待受ポート
    uint32_t requestTime_CP;            ///< 共通プロトコル通信用リクエスト間隔（秒）
    // #10031 2023.12.01 add 医器工V4タイムアウト設定による受信待ち対応 TDC高村 start
    uint32_t responseTimeout_CP;        ///< 共通プロトコル通信V4用応答タイムアウト（秒）
    // #10031 2023.12.01 add 医器工V4タイムアウト設定による受信待ち対応 TDC高村 end
    uint32_t lcdDataCash;               ///< 仮想端末データキャッシュ（0:使用しない,1:使用する）
    u_char mstDir[50];                  ///< マスタ格納先フォルダ
    u_char facilityCd[8];               ///< 施設コード
    uint32_t deviceEdgeNo;              ///< デバイスエッジ番号
    u_char receiveDataDirectory[50];    ///< データ収集用ファイル格納先フォルダ１
    u_char receiveDataDirectory2[50];   ///< データ収集用ファイル格納先フォルダ２
    u_char receiveDataDirectory3[50];   ///< データ収集用ファイル格納先フォルダ３
    u_char collectDataDirectory[50];    ///< データ収集用一時ファイル格納先フォルダ１
    u_char collectDataDirectory2[50];   ///< データ収集用一時ファイル格納先フォルダ２
    u_char collectDataDirectory3[50];   ///< データ収集用一時ファイル格納先フォルダ３
    // #8731 2023.05.08 add 通信異常ファイルの格納先を設定で持つ TDC片口 start
    u_char commFailDirectory[50];       ///< 通信異常時ファイル格納先フォルダ
    // #8731 2023.05.08 add 通信異常ファイルの格納先を設定で持つ TDC片口 end
    u_char restDeviceEdgeUrl[150];      ///< REST DeviceEdge URL
    u_char restWebApiUrl[150];          ///< REST Web Api URL
    // add AWSとDEの通信断からの復旧 高 start
    u_char aliveMoniUrl[150];           ///< REST Web Api URL
    // add AWSとDEの通信断からの復旧 高 end
    // #11520 2025.02.26 add 起動時の一時停止処理（待ち時間）見直し TDC高村 start
    uint32_t commPermissonWait;         ///< 通信不可フラグの解除待ち時間(秒)
    // #11520 2025.02.26 add 起動時の一時停止処理（待ち時間）見直し TDC高村 end
    // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 start
    u_char TreatedDialysisReportDataDirectory[50];   /// 治療済透析レポート情報格納先フォルダ１
    u_char TreatedDialysisReportDataDirectory2[50];  /// 治療済透析レポート情報格納先フォルダ２
    // #11629 2025.05.07 add 治療済透析レポート情報の保存箇所変更 TDC米沢 end
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

// #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 start
/**
 * @brief 通信異常時設定ファイルの内容を取得
 * @param[in] configFileName 
 * @param[out] configParam 
 * @return 0:成功, -1:エラー
 */
extern uint32_t readConfigCommFailFile(const char *configFileName, ConfigParameter_t *configParam);
// #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 end

/**
 * @brief ネットワーク設定ファイルの内容を取得
 * @param configFileName 
 * @param configParam 
 * @return int32_t 
 */
extern uint32_t readConfigNetworkFile(const char *configFileName, ConfigParameter_t *configParam);

/**
 * @brief 最期に入る改行(\r\n)を取り除く
 * @param[in,out] str 
 */
extern void lntrim(char *str);
 
#endif // _CONFIG_READ_H_
