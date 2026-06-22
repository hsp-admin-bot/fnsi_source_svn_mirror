/**
* @file ntss_mqueue_recv.h
* @brief メッセージキュー受信処理ヘッダー
* @author Y.Takamura
* @date 2019/01/07
*/

#ifndef NTSS_MQUEUE_RECV_H
#define NTSS_MQUEUE_RECV_H
 
#define QUE_NAME    "/ntss_mqueue"
#define FILE_MODE   0644
#define handle_error(msg) \
    do { perror(msg); exit(EXIT_FAILURE); } while (0)
// add 透析患者さんのレポート画面を差入れする 高 start
// #define REQ_NO_MAX  18      ///< 要求番号最大数
#define REQ_NO_MAX  21      ///< 要求番号最大数
// add 透析患者さんのレポート画面を差入れする 高 end
#define REQ_SCNOUT  999     ///< 装置制御データのログ出力要求

/**
* @fn int ntss_mqueue_recv(char *message)
* @brief メッセージキューからメッセージ受信
* @param[out] *message メッセージ
* @return int 0:成功 -1:失敗
* @details メッセージキューからメッセージを受信する
*/
extern int ntss_mqueue_recv(char *message);

/**
* @fn void *ntss_mqueue_receiver()
* @brief メッセージキューからメッセージ受信（スレッド用）
* @details メッセージキューからメッセージを受信する
*/
extern void *ntss_mqueue_receiver(void *ptr);

#endif // NTSS_MQUEUE_RECV_H
