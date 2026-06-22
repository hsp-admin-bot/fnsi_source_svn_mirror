#ifndef _CONFIG_READ_H_
#define _CONFIG_READ_H_

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>

#include "struct_data.h"
#include "../common/libs/ntss_log_lib.h"
#include "../common/libs/ntss_etc_lib.h"
#include "../common/libs/config_reader.h"

extern ConfigParameter_t getConfigParameter();
extern uint32_t readConfigFile(const char *configFileName);
extern uint32_t readConfigNetworkFile(const char *configFileName);

#endif // _CONFIG_READ_H_