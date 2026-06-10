package batch.config;

import batch.ApplicationConst;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.env.Environment;
import org.springframework.data.mongodb.core.MongoTemplate;

import javax.annotation.Resource;
import java.sql.Connection;
import java.sql.DriverManager;

@Configuration
public class TestDBLinkStatus {

    @Resource
    private MongoTemplate mongoTemplate;

    @Autowired
    private Environment environment;

    /**
     * リンク可能かどうかをテストするためにMongoDbに接続オブジェクトを作成しようとします
     *
     * @return
     */
    private boolean pingMongoDb() {
        try{
            mongoTemplate.getCollectionNames();
        } catch (Exception e) {
            System.err.println("MongoDB接続に失敗しました。。。！");
            return false;
        }
        return true;
    }

    /**
     * 同時にconvert，4，5，6のDb状態を判断する（すべての接続がtrueを返し、この方法はtrueを返す）
     *
     * @return
     */
    public String DBActiveStatus() {
        JSONObject jsonObject = new JSONObject();
        String[] dbNames = {"convert", "nkk4", "nkk5", "nkk6"};
        boolean status = true;
        for (String dbName : dbNames) {
            status = this.testDBLinkStatus(dbName);
        }
        if (status) {
            jsonObject.put("status", "0");
            jsonObject.put("message", "POSTGREデータベース接続に成功しました！");
        } else {
            jsonObject.put("status", "1");
            jsonObject.put("message", "POSTGREデータベースが接続できません！");
        }
        if (!this.pingMongoDb()) {
            jsonObject.put("status", "1");
            jsonObject.put("message", "MONGODBデータベースが接続できません！");
        }
        return jsonObject.toString();
    }

    /**
     * ドライバ取得リンクの再ロードを試み、DBが利用可能かどうかを判断する
     *
     * @param dataBaseName
     * @return
     */
    private boolean testDBLinkStatus(String dataBaseName) {
        String driveClass = "";
        String url = "";
        String userName = "";
        String password = "";
        switch (dataBaseName) {
            case ApplicationConst.DbType.CONVERT :
                driveClass = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".driverClassName");
                url = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".jdbc-url");
                userName = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".username");
                password = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".password");
                break;
            case ApplicationConst.DbType.NKK4 :
                driveClass = environment.getProperty("datasource." + ApplicationConst.DbType.NKK4 + ".driverClassName");
                url = environment.getProperty("datasource." + ApplicationConst.DbType.NKK4 + ".jdbc-url");
                userName = environment.getProperty("datasource." + ApplicationConst.DbType.NKK4 + ".username");
                password = environment.getProperty("datasource." + ApplicationConst.DbType.NKK4 + ".password");
                break;
            case ApplicationConst.DbType.NKK5 :
                driveClass = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".driverClassName");
                url = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".jdbc-url");
                userName = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".username");
                password = environment.getProperty("datasource." + ApplicationConst.DbType.NKK5 + ".password");
                break;
            case ApplicationConst.DbType.NKK6 :
                driveClass = environment.getProperty("datasource." + ApplicationConst.DbType.NKK6 + ".driverClassName");
                url = environment.getProperty("datasource." + ApplicationConst.DbType.NKK6 + ".jdbc-url");
                userName = environment.getProperty("datasource." + ApplicationConst.DbType.NKK6 + ".username");
                password = environment.getProperty("datasource." + ApplicationConst.DbType.NKK6 + ".password");
                break;
            default:
                return false;
        }
        try {
            //再postgreロードドライブ,
            Class.forName(driveClass);
            Connection con = DriverManager.getConnection(url, userName, password);
            if (!con.isClosed()) {
                //データベース・オブジェクトへの接続を検出したら、接続をアクティブに停止します
                con.close();
                return true;
            }
        } catch (Exception e) {
            System.err.println(userName + ":データベースが接続できません！");
            return false;
        }
        return true;
    }
}
