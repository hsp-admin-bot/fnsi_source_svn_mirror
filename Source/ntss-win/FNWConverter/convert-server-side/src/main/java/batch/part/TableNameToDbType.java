package batch.part;

import javax.sql.DataSource;

import org.springframework.context.ApplicationContext;
import org.springframework.jdbc.core.JdbcOperations;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;

import batch.ApplicationConst;
import lombok.Setter;

public class TableNameToDbType{
    /**
	 * アプリケーションのコンテキスト（Bean取り出し元）
	 * @param ctx アプリケーションコンテキスト
	 */
	@Setter
    private ApplicationContext ctx;

    /**
	 * コンストラクタ
	 * @param paraCtx アプリケーションコンテキスト
	 */
    public TableNameToDbType(final ApplicationContext paraCtx){
        ctx = paraCtx;
    }

    /**
     * テーブル名からDB接続設定名を取得する
     *
     * @param tableName テーブル名
     * @return DB接続設定名
     * @throws Exception
     */
    public String getDbTypeByTableName(final String tableName) throws Exception {
        // nkk4を検索
        if(isExistsTableInDb(ApplicationConst.DbType.NKK4,tableName)){
            return ApplicationConst.DbType.NKK4;
        }

        // nkk5を検索
        if(isExistsTableInDb(ApplicationConst.DbType.NKK5,tableName)){
            return ApplicationConst.DbType.NKK5;
        }

        // nkk6を検索
        if(isExistsTableInDb(ApplicationConst.DbType.NKK6,tableName)){
            return ApplicationConst.DbType.NKK6;
        }
            
        throw new Exception(tableName + "テーブルが存在しません。");
    }

    /**
     * テーブルが指定したDB接続先に存在するかチェックする
     * @param dbType DB接続先
     * @param tableName テーブル名
     * @return true:存在する false:存在しない
     */
    private boolean isExistsTableInDb(final String dbType,
                                    final String tableName){
        NamedParameterJdbcTemplate namedParameterJdbcTemplate = new NamedParameterJdbcTemplate((DataSource)ctx.getBean(dbType));
        JdbcOperations jdbc = namedParameterJdbcTemplate.getJdbcOperations();

        // SQLインジェクション対策：パラメータ化クエリを使用
        String sql = "select relname from pg_stat_user_tables where relname=lower(?)";
        if (!jdbc.queryForList(sql, tableName).isEmpty()){
            return true;
        }else{
            return false;
        }

    }
}