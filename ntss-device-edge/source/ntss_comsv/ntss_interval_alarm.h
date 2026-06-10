#ifndef _NTSS_INTERVAL_ALARM_H_
#define _NTSS_INTERVAL_ALARM_H_

#include <stdbool.h>
#include <sys/types.h>

#define API_INTERVAL_ALART_NOTICE   "notification/interval-alarm"

/**
 * @brief スレッド情報
 */
typedef struct
{
    bool        isRunning;              ///< 実行中フラグ
    u_char      restDeviceEdgeUrl[150]; ///< REST DeviceEdge URL
    u_char      facilityCd[8];          ///< 施設コード
    u_int32_t   deviceEdgeNo;           ///< デバイスエッジ番号
    struct connect_socket *con_sock;    ///< 装置制御情報
} ThreadParameter_t;


void *
intervalAlarmThread(void *ptr);

#endif // _NTSS_INTERVAL_ALARM_H_