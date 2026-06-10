package batch.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Data;

@Data
@Component
@ConfigurationProperties(prefix="completed-file-config")
public class CompletedFileConfig{
    private String path;

    // add 2020-11-20 getPath機能を追加する  う start
    public String getPath() {
        return this.path;
    }
    // add 2020-11-20 getPath機能を追加する  う end
}