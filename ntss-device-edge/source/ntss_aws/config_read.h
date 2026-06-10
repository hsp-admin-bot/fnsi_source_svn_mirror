#ifndef _CONFIG_READ_H_
#define _CONFIG_READ_H_

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

#include "struct_data.h"
#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/config_reader.h"

extern ConfigParameter_t getConfigParameter();
extern uint32_t readConfigFile(const char *configFileName);
extern uint32_t readConfigCommonFile(const char *configFileName);
extern uint32_t readConfigNetworkFile(const char *configFileName);
// #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 start
/**
 * @brief 通信異常時設定ファイルの内容を取得
 * @param[in] configFileName 
 * @param[out] configParam 
 * @return 0:成功, -1:エラー
 */
extern uint32_t readConfigCommFailFile(const char *configFileName);
// #8731 2023.05.15 add 通信異常ファイルの格納先を設定で持つ TDC片口 end

#endif // _CONFIG_READ_H_