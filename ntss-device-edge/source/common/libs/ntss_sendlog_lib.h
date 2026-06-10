/**
* @briefNTSSログ送信関連ヘッダーファイル
*
* @details NTSSログ送信関連
*
* @description ntss program

* Copyright (C) 2018, TDC, all right reserved.
*
* @file ntss_sendlog_lib.h
* @author Y.Takamura
* @date 2018/07/11
*/

#ifndef NTSS_SENDLOG_LIB_H
#define NTSS_SENDLOG_LIB_H

/**
* @brief ログ送信初期化処理
*
* @details ログサーバに接続を行う
*
* @description
* @return int :接続状態(0:未接続 1:接続中 2:接続完了)
* @attention 設定ファイルからアドレス・ポート番号を取得
*/
extern int ntss_sendlog_init();

/**
* @brief ログ送信初期化処理
*
* @details ログサーバに接続を行う
*
* @description
* @param[in] *addr  ログサーバーアドレス
* @param[in] *port  ログサーバーポート番号
* @return int :接続状態(0:未接続 1:接続中 2:接続完了)
* @attention 特になし
*/
extern int ntss_sendlog_init_p(char *host, int port);

/**
* @brief ログ送信終了処理
*
* @details ログ送信終了処理を行う
*
* @attention 特になし
*/
extern void ntss_sendlog_exit();

/**
* @brief ログ送信処理
*
* @details ログサーバに送信を行う
*
* @description
* @param[in] flg 出力フラフ
*            0:通常
*            1:システム情報有り
*            2:ネットワーク状態有り（アンテナレベル含む）
* @param[in] *param  パラメータ（9項目TAB区切り）
* @param[in] *logmsg  ログデータ
* @return int :送信済みデータ長
* @attention param : "1\t2\t3\t4\t"
*            param(1) :型式
*            param(2) :製造番号
*            param(3) :サービス名
*            param(4) :ログ種別
*/
extern int ntss_sendlog(int flg, char *param, char *logmsg);

#endif