package batch.config;

import java.util.Map;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import lombok.Data;

/**
 * ymlファイルからdb-relationの情報を取得し保存するクラス
 */
@Data
@Component
@ConfigurationProperties(prefix="db-relation")
public class DbRelationConfig{
    private Map<String,String[]> config;

    public int getCountRelationTable(String tableName){
        // リレーションが存在しない場合は0
        if(!config.containsKey(tableName)){
            return 0;
        }else{
            return config.get(tableName).length;
        }
    }

    // add 2020-11-20 getConfig機能を追加する  う start
    public Map<String,String[]> getConfig() {
        return this.config;
    }
    // add 2020-11-20 getConfig機能を追加する  う end
}