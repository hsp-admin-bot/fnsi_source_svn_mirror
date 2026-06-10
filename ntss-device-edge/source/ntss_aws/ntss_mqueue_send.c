#include <pthread.h>
#include <mqueue.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "ntss_mqueue_send.h"

/**
* @fn int ntss_mqueue_send(char *message)
* @brief メッセージキューへメッセージ送信
* @param[in] *message メッセージ
* @return int 0:成功 -1:失敗
* @details メッセージキューへメッセージを送信する
*/ 
int ntss_mqueue_send(char *message)
{
    int ret = -1;
    mqd_t send_que;
 
    send_que = mq_open(QUE_NAME, O_WRONLY);
 
    if ( send_que == -1 ) {
        perror("mq_open error");
    }
    else {
        if ( mq_send(send_que, message, strlen(message), 0) == -1 ) {
            perror("error");
        }
        else {
            ret = 0;
        }
    }

    mq_close(send_que);
    return ret;
}

/**
* @fn void *ntss_mqueue_sender(char *message)
* @brief メッセージキューへメッセージ送信（スレッド用）
* @param[in] *message メッセージ
* @return int 0:成功 -1:失敗
* @details メッセージキューへメッセージを送信する
*/ 
void *ntss_mqueue_sender(void *message)
{
    char *buff = (char *) message;
    mqd_t send_que;
 
    send_que = mq_open(QUE_NAME, O_WRONLY);
 
    if ( send_que == -1 ) {
        perror("mq_open error");
    }
    else {
        if ( mq_send(send_que, buff, strlen(buff), 0) == -1 ) {
            perror("error");
        }
    }

	pthread_exit((void *)0); // スレッド終了
    mq_close(send_que);
}
