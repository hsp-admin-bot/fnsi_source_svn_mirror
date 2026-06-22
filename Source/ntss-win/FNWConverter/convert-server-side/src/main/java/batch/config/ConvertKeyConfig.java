package batch.config;

import batch.part.InfomationSchemaControl;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.ApplicationContext;
import org.springframework.stereotype.Component;

import java.util.Map;

@Data
@Component
@ConfigurationProperties(prefix="convert-key")
public class ConvertKeyConfig {

    @Autowired
    ApplicationContext appContext;

    private Map<String,String[]> config;

    private Map<String,String[]> configb;

    // add 7853-差分コンバートで更新/削除ができない 楊 start
    private Map<String,String> noseq;
    //add 11546 差分コンバートで医材マスタの表示順の変更が反映されない hyl start
    private Map<String,String> orderby;
    //add 11546 差分コンバートで医材マスタの表示順の変更が反映されない hyl end
    private Map<String,String> prodDbTableKey;
    public boolean getNoseq(String tableName){
        // リレーションが存在しない場合は空を設定
        if(noseq.containsKey(tableName)){
            return true;
        }else{
            return false;
        }
    }
    // add 7853-差分コンバートで更新/削除ができない 楊 end
    //add 11546 差分コンバートで医材マスタの表示順の変更が反映されない hyl start
    public String getOrderby(String tableName){
        if(orderby.containsKey(tableName)){
            return  " order by " + orderby.get(tableName);
        }else{
            return "";
        }
    }

    public String getOrderByForConvert(String tableName){
        InfomationSchemaControl isc = new InfomationSchemaControl(appContext);
        boolean has = isc.tableHasConvertId(tableName);
        if(has){
            return  " order by convert_id ";
        }
        if(orderby.containsKey(tableName)){
            return  " order by " + orderby.get(tableName);
        }else{
            return "";
        }
    }

    //add 11546 差分コンバートで医材マスタの表示順の変更が反映されない hyl end
    public String getTableKey(String tableName){
        if(prodDbTableKey.containsKey(tableName)){
            return prodDbTableKey.get(tableName);
        }else{
            return "";
        }
    }
    public String getConvertKey(String tableName){
        // リレーションが存在しない場合は空を設定
        if(!config.containsKey(tableName)){
            return "";
        }else{
            String cols = "";
            for (String col:config.get(tableName)
                 ) {
                cols += col + ", ";
            }
            return cols.substring(0, cols.length() - 2);
        }
    }

    public String getConvertbKey(String tableName){
        // リレーションが存在しない場合は空を設定
        if(!configb.containsKey(tableName)){
            return "";
        }else{
            String cols = "";
            for (String col:configb.get(tableName)
            ) {
                cols += col + ", ";
            }
            return cols.substring(0, cols.length() - 2);
        }
    }

    public Map<String,String[]> getConfig() {
        return this.config;
    }
    public Map<String,String[]> getConfigb() {
        return this.configb;
    }
}
