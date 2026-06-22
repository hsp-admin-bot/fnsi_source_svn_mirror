package batch.part;

import batch.ApplicationConst;
import batch.config.ConvertKeyConfig;
import lombok.Setter;
import org.springframework.context.ApplicationContext;
import org.springframework.jdbc.core.JdbcOperations;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;

import java.util.List;
import java.util.Map;

public class InfomationSchemaControl{
    /**
	 * アプリケーションのコンテキスト（Bean取り出し元）
	 * @param ctx アプリケーションコンテキスト
	 */
	@Setter
    private ApplicationContext ctx;

    private ConvertKeyConfig convertKeyConfig;

    /**
	 * Beans用デフォルトコンストラクタ
	 */
	public InfomationSchemaControl() {
	}

    /**
	 * コンストラクタ
	 * @param paraCtx アプリケーションコンテキスト
	 */
    public InfomationSchemaControl(final ApplicationContext paraCtx){
        ctx = paraCtx;
        convertKeyConfig = paraCtx.getBean(ConvertKeyConfig.class);
    }

    /**
     * テーブル名から列名をリストで取得する。
     * その際、シーケンス対象のカラムは除外する。
     * @param tableName
     * @return
     * @throws Exception
     */
    public List<String> getColumnNamesExclusiveSeqColumn(final String tableName) throws Exception {
        NamedParameterJdbcTemplate namedParameterJdbcTemplate = (NamedParameterJdbcTemplate) ctx.getBean(ApplicationConst.JdbcTempleteName.NAMED_PARAMETER_JDBCTEMPLATE_CONVERT);
        JdbcOperations jdbc = namedParameterJdbcTemplate.getJdbcOperations();
        String tableKey = convertKeyConfig.getTableKey(tableName);
        // SQLインジェクション対策：パラメータ化クエリを使用
        String sql = "SELECT column_name FROM information_schema.columns"
                + " WHERE table_name = lower(?) AND column_name!=? and column_name!='convert_id'"
                + " ORDER BY ordinal_position";
        return jdbc.queryForList(sql, String.class, tableName,tableKey);
    }

    /**
     * テーブル名から列名をリストで取得する。
     * その際、コード変換に必要な列名のみとする
     * （シーケンス対象の列名とfnから始まる列名
     * とfacility_cdが存在する場合はその列名を取得する。）
     * @param tableName
     * @return
     * @throws Exception
     */
    public List<String> getColumnNamesForCodeConversion(final String tableName) throws Exception {
        NamedParameterJdbcTemplate namedParameterJdbcTemplate = (NamedParameterJdbcTemplate) ctx.getBean(ApplicationConst.JdbcTempleteName.NAMED_PARAMETER_JDBCTEMPLATE_CONVERT);
        JdbcOperations jdbc = namedParameterJdbcTemplate.getJdbcOperations();

        // TODO 暫定的にすべての列を取得する
        // SQLインジェクション対策：パラメータ化クエリを使用
        String  sql = "SELECT column_name FROM information_schema.columns"
                    + " WHERE table_name = lower(?) "
                    + " AND column_name <> 'convert_id' "
                    + " ORDER BY ordinal_position";
        if(tableName.equals(("mnt_motion_record"))){
            // SQLインジェクション対策：パラメータ化クエリを使用
            sql = "SELECT column_name FROM information_schema.columns"
                    + " WHERE table_name = lower(?) AND column_name!='motion_record_no' and column_name!='convert_id' "
                    + " ORDER BY ordinal_position";
        }
        return jdbc.queryForList(sql, String.class, tableName);
    }

    /**
     * 対象テーブルに施設コードの列が存在するか確認する
     */
    public boolean hasFacilityCd(final String tableName) throws Exception {
        NamedParameterJdbcTemplate namedParameterJdbcTemplate = (NamedParameterJdbcTemplate) ctx.getBean(ApplicationConst.JdbcTempleteName.NAMED_PARAMETER_JDBCTEMPLATE_CONVERT);
        JdbcOperations jdbc = namedParameterJdbcTemplate.getJdbcOperations();

        // SQLインジェクション対策：パラメータ化クエリを使用
        String sql = "SELECT column_name FROM information_schema.columns"
                    + " WHERE table_name = lower(?)"
                    + " AND (column_name='facility_cd')";
        boolean ret = !jdbc.queryForList(sql, String.class, tableName).isEmpty();

        return ret;
    }

    public boolean tableHasConvertId(String tableName){
        NamedParameterJdbcTemplate namedParameterJdbcTemplate = (NamedParameterJdbcTemplate) ctx.getBean(ApplicationConst.JdbcTempleteName.NAMED_PARAMETER_JDBCTEMPLATE_CONVERT);
        JdbcOperations jdbc = namedParameterJdbcTemplate.getJdbcOperations();

        // SQLインジェクション対策：パラメータ化クエリを使用
        String sql = "SELECT count(*) as count FROM information_schema.columns WHERE table_name = lower(?) AND column_name = 'convert_id'";
        Map<String, Object> map = jdbc.queryForMap(sql, tableName);
        return (Long) map.get("count") > 0;
    }
}