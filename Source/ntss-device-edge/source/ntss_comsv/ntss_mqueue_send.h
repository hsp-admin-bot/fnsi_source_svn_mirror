/**
* @file ntss_mqueue_send.h
* @brief メッセージキュー送信処理ヘッダー
* @author Y.Takamura
* @date 2019/01/07
*/

#ifndef NTSS_MQUEUE_SEND_H
#define NTSS_MQUEUE_SEND_H
 
#define QUE_NAME    "/ntss_mqueue"
#define handle_error(msg) \
    do { perror(msg); exit(EXIT_FAILURE); } while (0)

/**
* @fn int ntss_mqueue_send(char *message)
* @brief メッセージキューへメッセージ送信
* @param[in] *message メッセージ
* @return int 0:成功 -1:失敗
* @details メッセージキューへメッセージを送信する
*/ 
extern int ntss_mqueue_send(char *message);

/**
* @fn void *ntss_mqueue_sender(char *message)
* @brief メッセージキューへメッセージ送信（スレッド用）
* @param[in] *message メッセージ
* @return int 0:成功 -1:失敗
* @details メッセージキューへメッセージを送信する
*/ 
extern void *ntss_mqueue_sender(void *message);

#endif // NTSS_MQUEUE_SEND_H
