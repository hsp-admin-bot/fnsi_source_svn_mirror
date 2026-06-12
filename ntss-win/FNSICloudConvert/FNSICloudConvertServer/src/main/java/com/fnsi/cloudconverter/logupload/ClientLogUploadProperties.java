package com.fnsi.cloudconverter.logupload;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

/**
 * クライアントログアップロード設定。
 *
 * path には sys_system_define と同じ考え方でプレースホルダを使う:
 * - {1}: today または yyyyMMdd
 */
@Data
@Component
@ConfigurationProperties(prefix = "client-log.upload")
public class ClientLogUploadProperties {

    private Storage storage = new Storage();

    @Data
    public static class Storage {
        private String path = "/tmp/migration-client-logs/{1}/";
    }
}
