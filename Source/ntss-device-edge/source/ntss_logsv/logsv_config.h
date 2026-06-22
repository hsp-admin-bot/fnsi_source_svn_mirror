#ifndef _LOGSV_CONFIG_H_
#define _LOGSV_CONFIG_H_
 
#include <stdint.h>

typedef struct {
    char logsvHost[20];
    uint32_t logsvPort;
    uint32_t logsvTimeout;
    char logsvFolder1[50];
    char logsvFolder2[50];
    char logsvFolder3[50];
    char logsvTemp[50];

    char uploadS3Path[256];
    char uploadTime[10];

    // ntss_common.conf
    char facilityCd[10];
    uint32_t deviceNo;
    char serialNo[20];

    // ntss_network.conf
    char uploadHostName[256];
    char uploadPW[256];
    uint16_t uploadLimitFileSize;
    int nUploadRetryCount;
    int nUploadRetryWaitTime;
} ConfigParameter_t;

extern uint32_t readConfigFile(const char *configFileName, ConfigParameter_t *configParam);
extern uint32_t readConfigCommonFile(const char *configFileName, ConfigParameter_t *configParam);
extern uint32_t readConfigNetworkFile(const char *configFileName, ConfigParameter_t *configParam);
extern void lntrim(char *str);
 
#endif // _LOGSV_CONFIG_H_
