package batch.config;

import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Data;

@Data
@Component
@ConfigurationProperties(prefix="zip-file-config")
public class ZipFileConfig{
    private String password;

    // add 2020-11-19 getPassword機能を追加  う start
    public String getPassword() {
        return this.password;
    }
    // add 2020-11-19 getPassword機能を追加  う end
}