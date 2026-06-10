package batch.writer;


import batch.ApplicationConst;
import batch.config.ConvertKeyConfig;
import batch.entity.IndHistoryEntity;
import batch.entity.MntMainteMain;
import batch.entity.MstMainteCategory;
import batch.entity.MstMainteDetail;
import batch.entity.OrdMain;
import batch.entity.OrdWeightScale;
import batch.entity.RstHistoryEntity;
import batch.listener.JobStartEndLIstener;
import batch.part.InfomationSchemaControl;
import batch.part.PsqlCopyUtils;
import batch.part.StreamThread;
import batch.part.TableNameToDbType;
import com.amazonaws.util.CollectionUtils;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.zaxxer.hikari.HikariDataSource;
import java.io.IOException;
import java.math.BigDecimal;
import java.math.RoundingMode;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.stream.Collectors;
import java.util.stream.Stream;
import javax.sql.DataSource;
import lombok.Getter;
import lombok.Setter;
import org.json.JSONObject;
import org.springframework.batch.item.ItemWriter;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.ApplicationContext;
import org.springframework.core.env.Environment;
import org.springframework.dao.DataAccessException;
import org.springframework.data.mongodb.core.ExecutableUpdateOperation;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.PreparedStatementCallback;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcOperations;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.jdbc.core.namedparam.SqlParameterSourceUtils;
import org.springframework.jdbc.datasource.DataSourceTransactionManager;
import org.springframework.jdbc.support.rowset.SqlRowSet;
import org.springframework.util.Assert;
import org.springframework.util.ObjectUtils;
import org.thymeleaf.util.StringUtils;
import utils.BbsInfoService;
import utils.GlobalContext;
import utils.MasterDataService;
import utils.PatEventService;
import utils.Utils;
import web.config.EventLoggerUtil;
import web.constant.TreatmentItemsDef;
import web.entity.MstTreatment;
import web.entity.PatMain;
import web.entity.PatTreatmentPatternPatMain;
import web.logger.EventLogMessage;
import web.logger.LogLevel;

/**
 * ProcessorからSQLの文字列を受け取り実行するWriter
 */
public class JdbcBatchSqlItemWriter<T> implements ItemWriter<T>, InitializingBean {

	private NamedParameterJdbcOperations namedParameterJdbcTemplate;

	@Autowired
	private ApplicationContext appContext;

	@Autowired
	private ConvertKeyConfig convertKeyConfig;

	@Autowired(required = false)
	MongoTemplate mongoTemplate;

	@Autowired
	Utils utils;

	@Autowired
	private Environment environment;

	//繰り返し挿入しない
	private final String DONOTHING = " ON CONFLICT DO NOTHING;";

	private final String hzstr = "/**/";


	@Autowired
	private PatEventService patEventService;

	@Autowired
	private BbsInfoService bbsInfoService;

    private final String facilityCd;

    private final GlobalContext globalContext;
    //add #12229 start
    private final MasterDataService masterDataService;
    //add #12229 end


    /**
     * コンストラクタでデータソースを設定
     */
    public JdbcBatchSqlItemWriter(DataSource dataSource, String fileName, String facilityCd, GlobalContext globalContext, MasterDataService masterDataService) {
        this.namedParameterJdbcTemplate = new NamedParameterJdbcTemplate(dataSource);
        this.facilityCd = facilityCd;
        this.globalContext = globalContext;
        this.masterDataService = masterDataService; //add #12229
    }

	/**
	 * 必須プロパティの確認
	 * - namedParameterJdbcTemplate -
	 */
	@Override
	public void afterPropertiesSet() {
		Assert.notNull(namedParameterJdbcTemplate, "DataSourceまたはNamedParameterJdbcTemplateが必要です。");
	}

	/**
	 * TransactionManager取り出し
	 * @return トランザクション管理インスタンス
	 */
	@Getter
	@Setter
	DataSourceTransactionManager transactionManager;

	/**
	 * ロギング ツール クラスの導入
	 */
	@Autowired
	private EventLoggerUtil eventLoggerUtil;

	@Autowired
	@Qualifier(ApplicationConst.JdbcTempleteName.JDBC_TEMPLATE_NKK5)
	private JdbcTemplate jdbcTemplateNkk5;

	@Autowired
	@Qualifier(ApplicationConst.JdbcTempleteName.JDBC_TEMPLATE_NKK6)
	private JdbcTemplate jdbcTemplateNkk6;

	@Autowired
	@Qualifier(ApplicationConst.JdbcTempleteName.JDBC_TEMPLATE_CONVERT)
	private JdbcTemplate jdbcTemplateConvert;

	@Autowired
	@Qualifier(ApplicationConst.JdbcTempleteName.NAMED_PARAMETER_JDBCTEMPLATE_NKK5)
	private NamedParameterJdbcTemplate namedParameterJdbcTemplateNkk5;

	@Autowired
	@Qualifier(ApplicationConst.JdbcTempleteName.NAMED_PARAMETER_JDBCTEMPLATE_CONVERT)
	private NamedParameterJdbcTemplate namedParameterJdbcTemplateConvert;

	/**
	 * Java呼び出しProcess実行CMDコマンド共通メソッド
	 *
	 * @param cmd
	 * @param status
	 * @return
	 * @throws RuntimeException
	 */
	private boolean processCmdSql (String[] cmd, boolean status) throws RuntimeException {
		Process process = null;
		boolean exSuccess = true;
		try {
			if (status) { //statusはtrueであるから実行される
				System.err.println("window---CMDコマンドを実行するには：" + cmd[2]);
				//数组执行
				process = Runtime.getRuntime().exec(cmd);
			} else {
				System.err.println("linux---CMDコマンドを実行するには：" + cmd[0]);
				//字符串执行
				process = Runtime.getRuntime().exec(cmd[0]);
			}
			//assert process != null;
			StreamThread it = new StreamThread(process.getInputStream());
			StreamThread et = new StreamThread(process.getErrorStream());
			it.start();
			et.start();
			// スレッドの終了を待つ
			it.join();
			et.join();
			// ストリームを一応明示的にクローズしておく
			process.getInputStream().close();
			process.getOutputStream().close();
			process.getErrorStream().close();
			process.destroy(); // 子プロセスを明示的に終了
			if (!org.springframework.util.ObjectUtils.isEmpty(et.getOutputString())) {
				exSuccess = false;
				System.err.println("出力文字：" + et.getOutputString());
				EventLogMessage elm = eventLoggerUtil.getEventLogMessage(et.getOutputString(),
						facilityCd, "processCmdSql(String[] cmd, boolean status)");
				eventLoggerUtil.recordLog(facilityCd, elm, LogLevel.ERROR);
			}
			System.out.println("psqlコマンドの実行が完了しました！");
		} catch (IOException | InterruptedException e) {
			// TODO Auto-generated catch block
			eventLoggerUtil.recordLog(
					facilityCd,
					eventLoggerUtil.getEventLogMessage(
							"processCmdSql (String[] cmd, boolean status) Java呼び出しProcess実行CMDコマンド共通メソッド："  + EventLoggerUtil.excetionStackTraceToString(e),
							facilityCd,
							e.getClass().getName() + ".processCmdSql()"),
					LogLevel.ERROR);
		}
		return exSuccess;
	}


	/**
	 * 一括実行SQLの組立て(multi-insertフォーマットを使用したsql)
	 *
	 * @param items
	 * @return
	 */
	private String makeSqlInsert(List<? extends T> items, String tableName){
		//multi-insertフォーマットを使用したsql
		StringBuffer sb = new StringBuffer();
		if (items.size() == 1) {
			return items.get(0).toString();
		}
		int objectIndex = 0;
		String oldStr = "\u001C\u001B\u001D";
		String newtStr = "\n";
		for (T item : items ) {
			String itemStr = item.toString();
			if (item.toString().contains("INSERT")) {
				//pat _mainテーブル、特殊な処理をして、改行を置換する必要があります
				if (tableName.contains("bbs_info") && itemStr.contains(oldStr)) {
					String[] sql = new String[0];
					if(itemStr.contains("ON CONFLICT ON CONSTRAINT")){
						sql = itemStr.split("ON CONFLICT ON CONSTRAINT");
						itemStr=sql[0];
					}
					StringBuilder replaceStr = new StringBuilder();
					String[] strArr = itemStr.split(oldStr);
					String beginStr = strArr[0].substring(0, strArr[0].lastIndexOf("'") + 1);
					String endStr = strArr[0].substring(strArr[0].lastIndexOf("'") + 1);
					replaceStr.append(beginStr);
					replaceStr.append("S：");
					replaceStr.append(endStr);
					replaceStr.append(newtStr);
					replaceStr.append("O：");
					replaceStr.append(strArr[1]);
					replaceStr.append(newtStr);
					replaceStr.append("A：");
					replaceStr.append(strArr[2]);
					replaceStr.append(newtStr);
					replaceStr.append("P：");
					String beginStr1 = strArr[3].substring(0, strArr[3].lastIndexOf(">") + 1);
					String endStr1 = strArr[3].substring(strArr[3].lastIndexOf(">") + 1);
					replaceStr.append(beginStr1);
					replaceStr.append("S：");
					replaceStr.append(endStr1);
					replaceStr.append(newtStr);
					replaceStr.append("O：");
					replaceStr.append(strArr[4]);
					replaceStr.append(newtStr);
					replaceStr.append("A：");
					replaceStr.append(strArr[5]);
					replaceStr.append(newtStr);
					replaceStr.append("P：");
					replaceStr.append(strArr[6]);
					if (item.toString().contains("ON CONFLICT ON CONSTRAINT")) {
						replaceStr.append("ON CONFLICT ON CONSTRAINT");
						itemStr=sql[1];
						String[] strArr1 = itemStr.split(oldStr);
						String begin = strArr1[0].substring(0, strArr1[0].lastIndexOf("'") + 1);
						String end = strArr1[0].substring(strArr1[0].lastIndexOf("'") + 1);
						replaceStr.append(begin);
						replaceStr.append("S：");
						replaceStr.append(end);
						replaceStr.append(newtStr);
						replaceStr.append("O：");
						replaceStr.append(strArr1[1]);
						replaceStr.append(newtStr);
						replaceStr.append("A：");
						replaceStr.append(strArr1[2]);
						replaceStr.append(newtStr);
						replaceStr.append("P：");
						String beginStr2 = strArr1[3].substring(0, strArr1[3].lastIndexOf(">") + 1);
						String endStr2 = strArr1[3].substring(strArr1[3].lastIndexOf(">") + 1);
						replaceStr.append(beginStr2);
						replaceStr.append("S：");
						replaceStr.append(endStr2);
						replaceStr.append(newtStr);
						replaceStr.append("O：");
						replaceStr.append(strArr1[4]);
						replaceStr.append(newtStr);
						replaceStr.append("A：");
						replaceStr.append(strArr1[5]);
						replaceStr.append(newtStr);
						replaceStr.append("P：");
						replaceStr.append(strArr1[6]);
					}
					itemStr = replaceStr.toString();
				}

				if (objectIndex == 0) {
					//最初の全保持（最後の;置換、）
					// mod #10153,#10191,#10249 djy start
					StringBuilder stringBuilder = new StringBuilder(itemStr);
					stringBuilder.replace(stringBuilder.lastIndexOf(";"),stringBuilder.lastIndexOf(";")+1,",");
					sb.append(stringBuilder.toString());
					//String firstSql = itemStr.replace(";", ",");
					objectIndex++;
					continue;
				}
				int index = itemStr.indexOf("(");
				int index2 = itemStr.indexOf("(", index + 1);
				String sql = "";
				//最後のsqlかどうかを判断する（最後のsqlは置換する必要はありません；）
				if (objectIndex == items.size()-1) {
					sql = itemStr.substring(index2);
					StringBuilder b = new StringBuilder(sql);
					b.replace(b.lastIndexOf(";"), b.lastIndexOf(";") + 1, DONOTHING);
					//sql = itemStr.substring(index2);
					sql = b.toString();
				} else {
					// mod #10153,#10191,#10249 djy start
					StringBuilder stringBuilder = new StringBuilder(itemStr.substring(index2));
					stringBuilder.replace(stringBuilder.lastIndexOf(";"),stringBuilder.lastIndexOf(";")+1,",");
					sql=stringBuilder.toString();
					//sql = itemStr.substring(index2).replace(";", ",");
				}
				sb.append(sql);
				objectIndex++;
			} else if (itemStr.contains("UPDATE")) {
				sb.append(item);
			}
		}
		String finalStr = sb.toString();
		// ファイル実行に失敗したときにファイルに書き込まれた/***/文字を分割SQL削除
		if (finalStr.indexOf(hzstr) > 0) {
			finalStr = finalStr.replace(hzstr,"");
		}
		return finalStr;
	}



	/**
	 * SQLが一括実行可能であることを確認する
	 *
	 * @param items SQL-items
	 * @return
	 */
	private boolean checkSqlIsExecute(List<? extends T> items, String tableName){
		if (items.isEmpty()) {
			return false;
		}
		//mst_selectorバッチ分割を直接スキップ
		if (tableName.equals("mst_selector")) {
			return false;
			// add 7406 ReMS利用施設をコンバートすると送信先グループマスタや警報通知マスタなどのデータが消えている 楊 start
		} else if (tableName.equals("mst_user_authentication")) {
			return false;
			// add 7406 ReMS利用施設をコンバートすると送信先グループマスタや警報通知マスタなどのデータが消えている 楊 end
		} else if (tableName.equals("pat_treatment_pattern")) {
			return false;
		} else if (tableName.equals("ord_main")) {
			return false;
		} else if (tableName.equals("pat_unique")) {
			return false;
		}else if (tableName.equals("pat_unique_history")) {
			return false;
		}else if (tableName.equals("pat_main_history")) {
			return false;
		}//add 8644 zc start
		else if (tableName.equals("mst_comsv_setting")) {
			return false;
		}//add 8644 zc end

		// add 8753
		else if ("mst_machine_record_control".equals(tableName)) {
			return false;
		}
		// add 8753
		// add 9173
		else if ("mst_personal_user".equals(tableName)) {
			return false;
		}
		// add 9173
		// add #9215 djy start
		else if ("mst_treatment_status_layout".equals(tableName)) {
			return false;
		}
		// add #9215 djy end

		String firstLine = "";
		for (T item : items ) {
			//判断--または{で始まる場合、直接デフォルトは一括実行不可
			if (item.toString().startsWith("--") || item.toString().startsWith("{")) {
				return false;
			}
			if (items.indexOf(item) == 0) {
				//最初の行のSQLで挿入する列を切り取る
				firstLine = item.toString().substring(item.toString().indexOf("(")+1, item.toString().indexOf(")"));
				continue;
			} else {
				String comStr = item.toString().substring(item.toString().indexOf("(")+1, item.toString().indexOf(")"));
				if (!firstLine.equals(comStr)) {
					return false;
				}
			}
		}
		return true;
	}

	// add 7406 ReMS利用施設をコンバートすると送信先グループマスタや警報通知マスタなどのデータが消えている 楊 start
	/**
	 * 同じユーザー存在の場合、関連テープルを更新する
	 *
	 * @param facilityCd SQL-items
	 * @param rltList SQL-items
	 * @param jdbcTemplate SQL-items
	 *
	 * @return
	 */
	private void updUserTab(String facilityCd, List<String> rltList, JdbcTemplate jdbcTemplate)throws Exception{
		// 新規の場合、処理なし
		if (Integer.parseInt(rltList.get(0)) == 0) {
			return;
		}
		// user 関連テーブル
		List<String> userTblList = Arrays.asList("mst_personal_user", "mst_user");
		// 更新の場合、mst_personal_userを更新
		// convertDBには、fwnから同じuser_idを取得
		String sql = "SELECT user_id FROM mst_personal_user WHERE facility_cd = ? AND fn_staff_cd :: CHARACTER VARYING = ?";
		String fnwUserId = jdbcTemplate.queryForObject(sql, String.class, facilityCd, rltList.get(1));
		String fnsiUserId = rltList.get(2);
		if (fnwUserId.equals(fnsiUserId))
		{
			return;
		}
		// 更新sqlを作成
		// mst_personal_userの列を取得
		InfomationSchemaControl isc = new InfomationSchemaControl(appContext);
		for(String userTbl : userTblList) {
			List<String> columnNameList = isc.getColumnNamesExclusiveSeqColumn(userTbl);
			// mst_personal_user、user_id列を削除
			if ("mst_personal_user".equals(userTbl)) {
				columnNameList.remove("fn_staff_cd");
			}
			// mst_userの場合、user_id列を削除
			if ("mst_user".equals(userTbl)) {
				columnNameList.remove("user_id");
			}
			StringBuffer str = new StringBuffer();
			str.append("update ");
			str.append(userTbl);
			str.append(" set (");
			str.append(String.join(",", columnNameList));
			str.append(")  = ( select ");
			str.append(String.join(",", columnNameList));
			str.append(" from ");
			str.append(userTbl);
			str.append(" where facility_cd = '");
			str.append(facilityCd);
			str.append("' and user_id = '");
			str.append(fnwUserId);
			str.append("' ) where facility_cd = '");
			str.append(facilityCd);
			str.append("' and user_id = '");
			str.append(fnsiUserId);
			str.append("';");
			// convertDBに更新
			jdbcTemplate.execute(str.toString());
			// 本番DBに更新
			TableNameToDbType tableNameToDbType = new TableNameToDbType(appContext);
			String associationType = tableNameToDbType.getDbTypeByTableName(userTbl);
			HikariDataSource associationds = (HikariDataSource) appContext.getBean(associationType);
			JdbcTemplate assJdbcTemplate = new JdbcTemplate(associationds);
			assJdbcTemplate.execute(str.toString());
			// fnwデータを削除
			StringBuffer strDel = new StringBuffer();
			strDel.append("delete from ");
			strDel.append(userTbl);
			strDel.append(" where facility_cd = '");
			strDel.append(facilityCd);
			strDel.append("' and user_id = '");
			strDel.append(fnwUserId);
			strDel.append("';");
			// convertDBに削除
			jdbcTemplate.execute(strDel.toString());
			// 本番DBに削除
			assJdbcTemplate.execute(strDel.toString());
			// fncode更新
			if ("mst_personal_user".equals(userTbl)) {
				StringBuffer updStr = new StringBuffer();
				updStr.append("update mst_personal_user set fn_staff_cd = '" + rltList.get(1) + "'");
				updStr.append(" where facility_cd = '");
				updStr.append(facilityCd);
				updStr.append("' and user_id = '");
				updStr.append(fnsiUserId);
				updStr.append("';");
				// convertDBに削除
				jdbcTemplate.execute(updStr.toString());
				// 本番DBに削除
				assJdbcTemplate.execute(updStr.toString());
			}
		}
	}
	// add 7406 ReMS利用施設をコンバートすると送信先グループマスタや警報通知マスタなどのデータが消えている 楊 end

	// mod 7853-差分コンバートで更新/削除ができない 楊 start
	/**
	 * 初回と追加コンバート時、対象データのキーを設定
	 * @param tableName テープル名
	 *
	 * @return
	 */
    private void setCondKey(String tableName, GlobalContext globalContext) throws Exception {

        if (!tableName.equals("pat_personal_main_history")
                && !tableName.equals("pat_group_detail_history")
                && !tableName.equals("pat_insurance_history")
                && !tableName.equals("pat_main_history")
                && !tableName.equals("pat_unique_history")
                && !tableName.equals("rst_history")
                && !tableName.equals("ind_history")) {
			// 本番Type
			String reType = "";
			// 本番prefix
			String table_prefix = "";
			String cols = convertKeyConfig.getConvertKey(tableName);
			if (cols == null || cols.trim().isEmpty()){
				cols = convertKeyConfig.getConvertbKey(tableName);
			}
			TableNameToDbType tableNameType = new TableNameToDbType(appContext);
			reType =tableNameType.getDbTypeByTableName(tableName);
			table_prefix = environment.getProperty(reType+ "_prefix");
			table_prefix = table_prefix == null ? "" : table_prefix;
			// seqなしフラグ
			boolean isNoseq = convertKeyConfig.getNoseq(tableName);
			String[] names = cols.split(",");
			InfomationSchemaControl isc = new InfomationSchemaControl(appContext);
			List<String> columnNameList = isc.getColumnNamesForCodeConversion(tableName);
			//　該当テーブルには、該当テーブルの施設存在フラグを設定
			globalContext.hasFacilityCd = columnNameList.stream().anyMatch(x -> x.equals("facility_cd"));
			// 初期化
			// mod 8309 【デグレ】FNWデモ環境からコンバートするツールがエラーで停止する 楊 start
			globalContext.seq = -1;
			// mod 8309 【デグレ】FNWデモ環境からコンバートするツールがエラーで停止する 楊 end
			globalContext.seqRegist = -1;
			globalContext.seqKey = "";
			globalContext.befKeyList = "";
			// 本番DBのDBTypeの取得（テーブルが存在するDBを検索して取得）
			// 本番DBのDBTypeに対応するデータソースの取得
			if (isNoseq) {
				String productionSql = "SELECT\n" + names[1] + " From " + table_prefix + tableName;
				// レコード更新前、存在したのキーを取得
				List<String> befValueList;
				if (globalContext.hasFacilityCd) {
					productionSql += " where facility_cd = ?";
					befValueList = jdbcTemplateConvert.queryForList(productionSql, String.class, facilityCd);
				} else {
					befValueList = jdbcTemplateConvert.queryForList(productionSql, String.class);
				}
				befValueList = befValueList.stream().distinct().collect(Collectors.toList());
				globalContext.befKeyList = String.join("','", befValueList);
			} else {
				// このテーブルのシーケンス取得
				if ("mst_machine".equals(tableName)) {
					globalContext.seqKey = columnNameList.get(4);
				} else if("mst_graph_setting".equals(tableName)){
					globalContext.seqKey = columnNameList.get(0)+"::int";
				}else {
					globalContext.seqKey = columnNameList.get(0);
				}
				//add 12229  start
				if(utils.ConvertNotData.contains(tableName)){
					globalContext.seq = 0;
				}else{
					String seqSql = "select max(" + globalContext.seqKey + ") from " + table_prefix + tableName  +" where facility_cd = ?";
					Long seqResult = jdbcTemplateConvert.queryForObject(seqSql, Long.class, facilityCd);
					long seq = seqResult == null ? 0 : seqResult.longValue();
					globalContext.seq = seq;
				}
                //add 12229  end
			}
		}
	}

	/**
	 * mnt_motion_recordとord _personal_prescriptionテーブルの特殊処理
	 */
	private List<? extends T> processMotionAndPrescriptionSpecialLogic(List<? extends T> items) {
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
		try {
			//最初の行を先に選択
			String firstItem = items.get(0).toString().trim();
			//SQL文の最後の行の取得
			String lastItem = items.get(items.size()-1).toString().trim();
			//差分処理の除外
			if (firstItem.contains("INSERT") && !globalContext.fileName.contains("diff") && !lastItem.startsWith(hzstr)) {
				int firstLeftBracket = firstItem.indexOf("(");
				String beforeSubStr = "";
				if (firstLeftBracket != -1) {
					beforeSubStr = firstItem.substring(0, firstLeftBracket);
				}
				int INTOIndex = beforeSubStr.lastIndexOf("INTO") + 4;
				String tableNameWithBlank = beforeSubStr.substring(INTOIndex, beforeSubStr.length());
				String tableName = tableNameWithBlank.trim(); //テーブル名の取得
				if ("ord_personal_prescription".equals(tableName)) {
					String jdbcUrlConvert = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".jdbc-url");
					String userNameConvert = environment.getProperty("datasource." + ApplicationConst.DbType.CONVERT + ".username");
					// 登録先DB接続情報を取得
					String toHostIp = jdbcUrlConvert.split("/")[2].split(":")[0];
					String toDbUser = userNameConvert;
					String toDbName = jdbcUrlConvert.split("/")[3];
					String[] cmdPsqlOrd = new String[3];
					boolean xt = true;
					//ord_personal_prescriptionテーブルSQLファイルを実行する方法でconvertDBを挿入する
                    String cmdPsql = "psql -h " + toHostIp + " -d " + toDbName + " -U " + toDbUser + " -f " + globalContext.fileName;
					if ("\\".equals(System.getProperty("file.separator"))) {
						cmdPsqlOrd[0] = "cmd.exe";
						cmdPsqlOrd[1] = "/c";
						cmdPsqlOrd[2] = cmdPsql;
					} else {
						cmdPsqlOrd[0] = cmdPsql;
						xt = false;
					}
					boolean r = this.processCmdSql(cmdPsqlOrd, xt);
					if (!r) {
						//実行に失敗しました。ファイルの内容を指定した場所に書き込み、sqlファイルを削除して例外書き込みログをスローします
						EventLogMessage eventLogMessagecmdPsqlOrd = eventLoggerUtil.getEventLogMessage("psqlコマンド実行" + tableName + "テーブルのSQLファイルにエラーが発生しました！",
                                facilityCd, "JdbcBatchSqlItemWriter.write(final List<? extends T> items)");
                        eventLoggerUtil.recordLog(facilityCd, eventLogMessagecmdPsqlOrd, LogLevel.ERROR);
						//例外のスロー（次のSQLファイルの実行が続行されます）
                        throw new RuntimeException("psqlコマンドファイルを実行するには：" + globalContext.fileName + "エラー発生！");
					} else {
                        Path path = Paths.get(globalContext.fileName);//ソースファイル
						//SQLファイルの削除
						Files.deleteIfExists(path);
					}
					return new ArrayList<>();
				} else {
					//非mnt _motion_レコードテーブルとord _personal_prescriptionテーブルの処理（通常の論理実行）
					return items;
				}
			} else {
				//差分または非INSERT文は次の論理を続けます。
				return items;
			}
		} catch (Exception e) {
			//異常が発生し、実行したSQLファイルを最後に/**/に書き込んだ後に異常をスローし、次回ファイルを読み込む時に最後の行が/**/であるかどうかを判断し、もしそうであれば直接スキップしてファイルに従って実行し、直接に元の論理に従って実行する
			WriteSQLAnnotation wqa = new WriteSQLAnnotation();
            wqa.fileNioWrite(globalContext.fileName, "/**/", true);
			//捕捉異常、良い処理、実行時異常の直接スロー
			System.err.println("plsql実行エラー: " + e.getMessage());
            EventLogMessage eventLogMessagecmdPsqlOrd = eventLoggerUtil.getEventLogMessage("plsql実行エラー: " + e.getMessage() + "\n fileName:" + globalContext.fileName,
                    facilityCd, "JdbcBatchSqlItemWriter.write(final List<? extends T> items)");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessagecmdPsqlOrd, LogLevel.ERROR);
			throw new RuntimeException("plsql実行エラー");
		}
	}

	private Integer getMaxPrimaryOfAllDeleteAllInsertTables(String realTableName){
		Integer maxPrimaryForConvert = null;
		if (utils.allDeleteAllInsertList.contains(realTableName)) {
			DataSource dsConvert = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
			NamedParameterJdbcTemplate convertTemplate = new NamedParameterJdbcTemplate(dsConvert);
			if (realTableName.equals("pat_event")) {
                Map<String, Object> currSeqMap = convertTemplate.getJdbcOperations().queryForMap("SELECT COALESCE(max(pat_event_cd),0) as currSeq FROM pat_event where facility_cd = ?", facilityCd);
				maxPrimaryForConvert = Integer.parseInt(String.valueOf(currSeqMap.get("currSeq")));
			}
			// add #8992-4 pat_event zs end

			// add #10739  zc start
			else if(realTableName.equals("pat_ind_approve_history")){
                Map<String, Object> currSeqMap = convertTemplate.getJdbcOperations().queryForMap("SELECT COALESCE(max(ind_approve_history_no),0) as currSeq FROM pat_ind_approve_history where facility_cd = ?", facilityCd);
				maxPrimaryForConvert = Integer.parseInt(String.valueOf(currSeqMap.get("currSeq")));
			}
			// add #10739  zc end
		}
		return maxPrimaryForConvert;
    }

	/**
	 * @param pkeyList	本番のキー (更新レコード)
	 * @param keyInsList	sqlファイルの一行目fnキーリスト(新規レコード)
	 */
	private void deletePatEventInConvertDB(List<String> pkeyList,List<String> keyInsList) {
		if (!globalContext.updateKeyList.isEmpty()) {
			for (String key : globalContext.updateKeyList) {
				if (pkeyList.contains(key)) {
					pkeyList.remove(key);
				}
			}
		}

		String updateKeys = "";
		for (String value : pkeyList) {
			updateKeys +=  " '" + value + "',";
		}
		if (!globalContext.sqlNewKeys.isEmpty()) {
			for (String value : keyInsList) {
				updateKeys +=  " '" + value + "',";
			}
		}
		updateKeys = updateKeys.replaceFirst(".$","");
		globalContext.sqlKeys = updateKeys;
		globalContext.sqlNewKeys = "";
		if (!globalContext.sqlKeys.isEmpty()) {
			Map<String, Object> params = new HashMap<>();
			// pat_event.pKey : trim('') || pat_id || fn_ctl_no
			List<String> pKeys = Arrays.stream(globalContext.sqlKeys.replace("'","").split(","))
					.filter(k -> !k.isEmpty())
					.collect(Collectors.toList());
			params.put("pKeys", pKeys);
			String selectFilePathSql = "select result_value from (" +
					" select json_array_elements(( info ->> 'result_value' ) :: json)-> 'file_path' AS result_value " +
					" from pat_event CROSS JOIN LATERAL json_array_elements ( result_params :: JSON ) info " +
					" where (info ->> 'format_class' = '7'  or info ->> 'format_class' = '2' ) " +
					" and (info ->> 'result_value' IS NOT NULL AND info ->> 'result_value' != '' AND info ->> 'result_value' != '[]' ) " +
					" and info->>'result_value' like '%old_full_file_name%' " +
					" and trim('') || pat_id || fn_ctl_no in (:pKeys)  and facility_cd = :facilityCd ";
            selectFilePathSql += " and facility_cd = :facilityCd";
            params.put("facilityCd", facilityCd);
			selectFilePathSql += " ) r where r.result_value::TEXT != '\"\"' ";
			List<String> pathList = namedParameterJdbcTemplateNkk5.queryForList(selectFilePathSql,params,String.class);
			if (pathList != null && !pathList.isEmpty()) {
				patEventService.deleteFiles(pathList, facilityCd);
			}

            String delSql = "delete from pat_event where trim('') || pat_id || fn_ctl_no in (:pKeys) and facility_cd = :facilityCd";
            params.put("facilityCd", facilityCd);
			// コンバートDBを削除
			namedParameterJdbcTemplateConvert.update(delSql,params);
		}
		globalContext.updateKeyList.addAll(pkeyList);
	}

	/**
	 * add 11667 日常点検コンバート修正  start
	 */
	private void deletePatIndApproveHistoryInConvertDB(List<String> pkeyList) {
		String updateKeys = "";
		for (String value : pkeyList) {
			updateKeys +=  " '" + value + "',";
		}
		updateKeys = updateKeys.replaceFirst(".$","");
		globalContext.sqlKeys = updateKeys;
		globalContext.sqlNewKeys = "";
		if (!globalContext.sqlKeys.isEmpty()) {
			Map<String, Object> params = new HashMap<>();
			// pKey: pat_ind_approve_history.ord_no(int8)
			List<Long> ordNos = Arrays.stream(globalContext.sqlKeys.replace("'","").replace(" ","").split(","))
					.filter(k -> !k.isEmpty())
					.map(Long::valueOf)
					.collect(Collectors.toList());
			params.put("ordNos", ordNos);
            String delSql = "delete from pat_ind_approve_history where ord_no in (:ordNos) and facility_cd = :facilityCd";
            delSql += " and facility_cd = :facilityCd";
            params.put("facilityCd", facilityCd);
			// コンバートDBを削除
			namedParameterJdbcTemplateConvert.update(delSql,params);
		}
	}

	/**
	 */
	private void deleteBbsInfoInConvertDB(String facilityCd,String bbsCtlNosStr) {
		if (bbsCtlNosStr != null && !bbsCtlNosStr.isEmpty()) {
			Map<String, Object> params = new HashMap<>();
			// pKey : bbs_info.bbs_ctl_no(int8)
			List<Long> bbsCtlNos = Arrays.stream(globalContext.sqlKeys.replace("'","").replace(" ","").split(","))
					.filter(k -> !k.isEmpty())
					.map(Long::valueOf)
					.collect(Collectors.toList());
			params.put("bbsCtlNos", bbsCtlNos);
			String selectFilePathSql = "select jsonb_array_elements(file_info)->'path' AS pathName " +
					" from bbs_info " +
					" where ( file_info[0] ->> 'path' IS NOT NULL AND file_info[0] ->> 'path' != '' AND file_info != '[]' ) " +
					" and bbs_ctl_no in (:bbsCtlNos)";
			selectFilePathSql += " and facility_cd = :facilityCd";
			params.put("facilityCd", facilityCd);
			List<String> pathList = namedParameterJdbcTemplateNkk5.queryForList(selectFilePathSql,params,String.class);
			if (pathList != null && !pathList.isEmpty()) {
				bbsInfoService.deleteFiles(pathList, facilityCd);
			}
		}
	}

	private String[] getTableConvertKey(String tableName) {
		String cols = convertKeyConfig.getConvertKey(tableName);
		globalContext.plan = "A";
		if (cols == null || cols.trim().isEmpty()){
			cols = convertKeyConfig.getConvertbKey(tableName);
			globalContext.plan = "B";
		}
		if (ObjectUtils.isEmpty(cols)) {
			//差分キーが設定されていません
			//mod  7834  鄭  start
			String errorMsg = tableName+"差分キーが設定されていません\n";
			//mod  7834  鄭  end
			//ログ
			EventLogMessage eventLogMessage1 = eventLoggerUtil.getEventLogMessage(errorMsg,
					facilityCd, "JdbcBatchSqlItemWriter.write(final List<? extends T> items)");
			eventLoggerUtil.recordLog(facilityCd, eventLogMessage1, LogLevel.INFO);
			throw new RuntimeException(errorMsg);
		}
		String[] names = cols.split(",");
		return names;
	}


	/**
	 * 差分時、その他テープルより行うのテープルキーを作成
	 * @param rs5 本番のキー (更新レコード)
	 * @param values sqlファイルの一行目fnキーリスト(新規レコード)
	 * @param realTableName テープル名
	 * @param pKey  fnsiキー(keyconvert-key[1]
	 *
	 */
	private void setPlanB (String values, String realTableName, List<String> rs5, String pKey) throws Exception{
		String planBValue = "";
		HikariDataSource dsb = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
		JdbcTemplate jdbcTemplateb = new JdbcTemplate(dsb);
		String sql = "select " + pKey + " as pkey from " + realTableName + " where facility_cd = ?" + " and " +  pKey + " in (" + values + ")";
		List<String> rlt = new ArrayList<String>();
		if (!values.isEmpty())
		{
			rlt = jdbcTemplateb.queryForList(sql, new Object[] {facilityCd}, String.class);
		}
		values = "";
		String delVal = "";
		// 該当テープルには、関連データがあるの場合、コンバートDBにレコードを削除
		if (rlt != null && !rlt.isEmpty())
		{
			for (String value:rlt) {
				values +=  " '" + value + "',";
				if (!planBValue.contains(" '" + value + "',"))
				{
					planBValue += " '" + value + "',";
					delVal += " '" + value + "',";
				}
			}
			if (!values.equals("")) values = values.replaceFirst(".$","");
			if (!delVal.isEmpty()) delVal = delVal.replaceFirst(".$","");
			globalContext.sqlKeys =  values;

			// コンバートDBにレコードを削除
			if (!delVal.isEmpty())
			{
				String delSql = "delete from " + realTableName + " where " + pKey + " in (" + delVal + ") and facility_cd = '\" + facilityCd + \"'";
                jdbcTemplateb.execute(delSql);
			}
			rs5.removeAll(rlt);
		}
		// 新規のレコードの変換されたキーを設定する
		String newValues = "";
		for (String value:rs5) {
			newValues +=  " '" + value + "',";
		}
		if (!newValues.isEmpty()) newValues = newValues.replaceFirst(".$","");
		globalContext.sqlNewKeys =  newValues;
	}
	// mod 7853-差分コンバートで更新/削除ができない 楊 end
	/**
	 * Writerによって実行される処理
	 */
	@Override
	public void write(final List<? extends T> items) throws Exception {
		if (items.isEmpty()) {
			return;
		}
		globalContext.sqlKeys =  "";
		globalContext.plan = "";
		//ログ
		EventLogMessage eventLogMessage = eventLoggerUtil.getEventLogMessage(items.size() + " 回 SQL文を実行",
				facilityCd, "JdbcBatchSqlItemWriter.write(final List<? extends T> items)");
		eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.DEBUG);

		// 8366 除外期間情報のコンバートで失敗する　楊　start
		if (globalContext.fileName.contains("ord_exception_period"))
		{
			// 除外期間の場合、本番とコンバートDBを削除
			String delStr = "delete from ntss.ord_exception_period where facility_cd = ?";
			// コンバートDBにデータを更新
			jdbcTemplateConvert.update(delStr, facilityCd);
			// db5にデータを更新
			jdbcTemplateNkk5.update(delStr, facilityCd);
		}
		// 8366 除外期間情報のコンバートで失敗する　楊　end

		// add #7638 装置設定デフォルトマスタ追加 鄭 start
		// add 2022-06-07 テーブルプレフィックス【ntss.】取得 鄭 start
		String TableName = PsqlCopyUtils.getTableName(globalContext.fileName);
		// add 2022-06-07 テーブルプレフィックス【ntss.】取得 鄭 end
		//ログ テーブ
		EventLogMessage eventLogMessageTable = eventLoggerUtil.getEventLogMessage(TableName + " テーブルが実行Start。。。。。。",
				facilityCd, "JdbcBatchSqlItemWriter.write(final List<? extends T> items)");
		eventLoggerUtil.recordLog(facilityCd, eventLogMessageTable, LogLevel.INFO);

		// mod FNSI-指示履歴の最新patIdに修正 楊 start
		//mod 6886 zc start
		setCondKey(TableName, globalContext);
		//mod 6886 zc end
		// mod 7853-差分コンバートで更新/削除ができない 楊 end
		// mod FNSI-指示履歴の最新patIdに修正 楊 end

		//一括実行と単一ピック実行の一括実行trueを区別する、シングルピック実行false
		boolean importFlg = true;


		/**
		 * 	mnt_motion_recordとord _personal_prescriptionテーブルの特殊処理
		 */
		List<? extends T> itemsNew = processMotionAndPrescriptionSpecialLogic(items);
        //add 11576 pat_coop_detailのsave_1がGX固定でコンバートされる start
        globalContext.insFnDisKey = "";
        globalContext.sqlDisNoKeys = "";
        //add 11576 pat_coop_detailのsave_1がGX固定でコンバートされる end
		if (globalContext.fileName.contains("diff")) {
			boolean isReturnCallerMethod = processDiff(itemsNew,TableName);
			if (isReturnCallerMethod) {
				return;
			}
		}

		// 実績履歴はmongodbに直接書き込む
		if(TableName.equals("rst_history")) { // cyc:1
			boolean isReturnCallerMethod = convertValueRsrHistory(items,globalContext.fileName);
			if (isReturnCallerMethod) {
				return;
			}
		}

		// 指示履歴はmongodbに直接書き込む
		if(TableName.equals("ind_history")) { // cyc:1
			convertValHistory(globalContext.fileName,items);
			return;
		}

        //add #12229  ord_weight_scale start
        if(TableName.equals("ord_weight_scale") && !globalContext.fileName.contains("diff")){
            convertValOrdWeightScale(items,globalContext);
            return;
        }
        //add #12229  ord_weight_scale end

		for (T item : itemsNew)
		{
			// Insertが空かどうかを判断する
			if (item.toString().trim().equals("")) {
				continue;
			}
			//Insertコメントと削除機能 う　2020-12-29
			//非注釈文はフラグを削除する う　2020-12-29
			//mod 鄭 7834 start
			//語句が注釈されているかどうかを判断する う　2020-12-29
			String itemBeforeStr = item.toString().length() < 2 ? item.toString() : item.toString().substring(0, 2);
			if (itemBeforeStr.equals("--")) {
				// コメントアウトされた SQL ステートメントは処理されません。
				return;
			}

			//mod 鄭 7834 end
			String firstChar = item.toString().trim().substring(0,1);
			if (firstChar.equals("{")) {
				// JSON形式が処理されません
				return;
			}

			// add FNSI-差分コンバート対応 李 start
			boolean isContinueFor = processFnsiDiff(item,items.get(0));
			if (isContinueFor) {
				continue;
			}
			// add FNSI-差分コンバート対応 李 end

			String tableName = "";
			ProcessSQLAnnotationResult processSQLAnnotationResult = processSQLAnnotation(globalContext.fileName,item);
			boolean isContinue = processSQLAnnotationResult.isContinue();
			if (isContinue) { // cyc:1
				continue;
			}
			boolean boolState = processSQLAnnotationResult.isBoolState();
			tableName = processSQLAnnotationResult.getTableName();

			if (boolState) // cyc:1
			{
				try {


					if (globalContext.fileName.contains("pat_main")) // cyc:5
					{
						//itemsの最初のオブジェクト実行かどうかを判断する
						if (items.indexOf(item) == 0) {
							if (!"--".equals(items.get(items.size()-1))) {
								if (item.toString().trim().startsWith("INSERT")) {
									if (checkSqlIsExecute(items, tableName)) {
										String sqlStr = this.makeSqlInsert(items, tableName);
                                        // eg : INSERT INTO pat_main ( ... pat_id ...) values (... (select pat_id from pat_personal_main where facility_cd='CONV50' AND fn_pat_id::character varying='000000000001') ....)
										namedParameterJdbcTemplate.getJdbcOperations().batchUpdate(sqlStr);
                                        break; // break for (T item : itemsNew)
									}
								}
							}
						}
						importFlg = false;
						// mod 7853 差分コンバートで更新/削除ができない 楊 start
						if (item.toString().contains("ON CONFLICT"))
						{
							namedParameterJdbcTemplate.getJdbcOperations().execute(item.toString());
						}
						else
						{
							String sql = item.toString();
							StringBuilder b = new StringBuilder(sql);
							b.replace(b.lastIndexOf(";"), b.lastIndexOf(";") + 1, DONOTHING);
							namedParameterJdbcTemplate.getJdbcOperations().execute(b.toString());
						}
						// mod 7853 差分コンバートで更新/削除ができない 楊 end
					}
					else // cyc:12
					{
						//itemsの最初のオブジェクト実行かどうかを判断する
						if (items.indexOf(item) == 0) {
							//sqlファイルの最後の行が--一括実行されており、エラーが発生しているファイルを示している場合は、一括実行を行っていないと判断し、次のシングルピック実行に進みます。
							if (!"--".equals(items.get(items.size()-1))) {
								if (item.toString().trim().startsWith("INSERT")) {
									if (checkSqlIsExecute(items, tableName)) {
										String sqlStr = this.makeSqlInsert(items, tableName);
										namedParameterJdbcTemplate.getJdbcOperations().execute(sqlStr);
										break;
									}
								}
							}
						}
						importFlg = false;
						if (tableName.equals("mst_selector")) {
							namedParameterJdbcTemplate.getJdbcOperations().execute(item.toString());
						}
						// add 7406 ReMS利用施設をコンバートすると送信先グループマスタや警報通知マスタなどのデータが消えている 楊 start
						else if (tableName.equals("mst_user_authentication"))
						{
							List<String> rlt = namedParameterJdbcTemplate.getJdbcOperations().execute(item.toString(), new PreparedStatementCallback<List<String>>() {
								public List<String> doInPreparedStatement(PreparedStatement ps) throws SQLException, DataAccessException {
									ResultSet rs = ps.executeQuery();
									rs.next();
									List<String> rltList = new ArrayList<String>();
									rltList.add(rs.getString("xmax"));
									rltList.add(rs.getString("disp_user_id"));
									rltList.add(rs.getString("user_id"));
									return rltList;
								}
							});
							// 関連テープルを更新する
							updUserTab(facilityCd, rlt, jdbcTemplateConvert);
							// add 7406 ReMS利用施設をコンバートすると送信先グループマスタや警報通知マスタなどのデータが消えている 楊 end
						}
						else {
							String oldStr = "\u001C\u001B\u001D";
							String newtStr = "\n";
							String itemStr = item.toString();
							if (tableName.contains("bbs_info") && itemStr.contains(oldStr))
							{
								String[] sql = new String[0];
								if(itemStr.contains("ON CONFLICT ON CONSTRAINT")){
									sql = itemStr.split("ON CONFLICT ON CONSTRAINT");
									itemStr=sql[0];
								}
								StringBuilder replaceStr = new StringBuilder();
								String[] strArr = itemStr.split(oldStr);
								String beginStr = strArr[0].substring(0, strArr[0].lastIndexOf("'") + 1);
								String endStr = strArr[0].substring(strArr[0].lastIndexOf("'") + 1);
								replaceStr.append(beginStr);
								replaceStr.append("S：");
								replaceStr.append(endStr);
								replaceStr.append(newtStr);
								replaceStr.append("O：");
								replaceStr.append(strArr[1]);
								replaceStr.append(newtStr);
								replaceStr.append("A：");
								replaceStr.append(strArr[2]);
								replaceStr.append(newtStr);
								replaceStr.append("P：");
								String beginStr1 = strArr[3].substring(0, strArr[3].lastIndexOf(">") + 1);
								String end = strArr[3].substring(strArr[3].lastIndexOf(">") + 1);
								replaceStr.append(beginStr1);
								replaceStr.append("S：");
								replaceStr.append(end);
								replaceStr.append(newtStr);
								replaceStr.append("O：");
								replaceStr.append(strArr[4]);
								replaceStr.append(newtStr);
								replaceStr.append("A：");
								replaceStr.append(strArr[5]);
								replaceStr.append(newtStr);
								replaceStr.append("P：");
								replaceStr.append(strArr[6]);
								if (item.toString().contains("ON CONFLICT ON CONSTRAINT")) {
									replaceStr.append("ON CONFLICT ON CONSTRAINT");
									itemStr=sql[1];
									String[] strArr1 = itemStr.split(oldStr);
									String begin = strArr1[0].substring(0, strArr1[0].lastIndexOf("'") + 1);
									String endStr1 = strArr1[0].substring(strArr1[0].lastIndexOf("'") + 1);
									replaceStr.append(begin);
									replaceStr.append("S：");
									replaceStr.append(endStr1);
									replaceStr.append(newtStr);
									replaceStr.append("O：");
									replaceStr.append(strArr1[1]);
									replaceStr.append(newtStr);
									replaceStr.append("A：");
									replaceStr.append(strArr1[2]);
									replaceStr.append(newtStr);
									replaceStr.append("P：");
									String beginStr2 = strArr1[3].substring(0, strArr1[3].lastIndexOf(">") + 1);
									String endStr2 = strArr1[3].substring(strArr1[3].lastIndexOf(">") + 1);
									replaceStr.append(beginStr2);
									replaceStr.append("S：");
									replaceStr.append(endStr2);
									replaceStr.append(newtStr);
									replaceStr.append("O：");
									replaceStr.append(strArr1[4]);
									replaceStr.append(newtStr);
									replaceStr.append("A：");
									replaceStr.append(strArr1[5]);
									replaceStr.append(newtStr);
									replaceStr.append("P：");
									replaceStr.append(strArr1[6]);
								}
								item = (T)replaceStr.toString();
							}
							// mod 7853 差分コンバートで更新/削除ができない 楊 start
							if (item.toString().contains("ON CONFLICT"))
							{
								namedParameterJdbcTemplate.getJdbcOperations().execute(item.toString());
							}
							else
							{
								StringBuilder b = new StringBuilder(item.toString());
								// mod #8992-13 mst_comsv_setting zs start
                                if (!globalContext.fileName.contains("mst_comsv_setting")) {
									// mod #8992-13 mst_comsv_setting zs end
									b.replace(b.lastIndexOf(";"), b.lastIndexOf(";") + 1, DONOTHING);
								}
								namedParameterJdbcTemplate.getJdbcOperations().execute(b.toString());
							}
							// mod 7853 差分コンバートで更新/削除ができない 楊 end
						}
					}
					// mod FNSI-装置記録マスタ追加 楊 end
				} catch (Exception e)  // cyc:4
				{
					if (importFlg) {  //一括実行例外
						//ログ出力
                        EventLogMessage eventLogMessageBatch = eventLoggerUtil.getEventLogMessage("一括実行SQL文にエラーが発生しました。一括実行を停止します！" + "\n 誤ったSQLファイル：" + globalContext.fileName,
								facilityCd, "JdbcBatchSqlItemWriter.write(final List<? extends T> items)");
						eventLoggerUtil.recordLog(facilityCd, eventLogMessageBatch, LogLevel.ERROR);
						System.err.println("SQLの一括実行に失敗し、単一SQL文実行に移行しました！");
						//ファイルへの最後の書き込み--"。この判断により、SQLの一括実行を直接スキップして、単一ピックで実行できます。
						WriteSQLAnnotation wqa = new WriteSQLAnnotation();
                        wqa.fileNioWrite(globalContext.fileName, "--", true);
						//実行時例外ロールバック終了取引の最後のスロー
                        throw new RuntimeException("SQL文の一括実行エラー Error:" + EventLoggerUtil.excetionStackTraceToString(e));
					} else { //単一実行例外
						//単一のエラー通知処理を実行し、ループ実行します。次のエラーにより他の未知のエラーが発生する可能性があるので、下に進む必要はありません。
						//ログ出力
						EventLogMessage eventLogMessage4 = eventLoggerUtil.getEventLogMessage("「誤ったSQL文：」" + item.toString() + "\n 位置は第" + items.indexOf(item) + "条" ,
                                facilityCd, "JdbcBatchSqlItemWriter.write(final List<? extends T> items)");
                        eventLoggerUtil.recordLog(facilityCd, eventLogMessage4, LogLevel.ERROR);
						System.err.println("誤ったSQL文：" + item.toString());
						/**
						 * 異常をスローすることはスキップしないことを意味し、次はこのsqlを実行し続けるとエラーが発生し、またここに行って異常をスローすることができます;
						 * スキップしたい場合は、このsqlの前に参加する必要があります--は、直接スキップされます;
						 * ymlにおけるconvert-priority構成の優先度値に基づいて決定し、0-7は停止し、8以上は実行を継続する
						 */
						String convert_table = environment.getProperty("convert-priority.config." + tableName);
						if (convert_table != null && !ObjectUtils.isEmpty(convert_table)) {
							if (Integer.parseInt(convert_table) < 8) { //中断が必要で、下に行かないで、打つ必要はありません--、直接異常を投げます
								throw new RuntimeException("シングルピックSQL実行エラー");
							} else {
								//ymlにはこのテーブルは構成されておらず、0-7以内ではなく、8以外の論理を実行することを意味しています
								//次の実行を続行するには、例外を捨てるには--を打つ必要があります。
								WriteSQLAnnotation wqa = new WriteSQLAnnotation();
                                wqa.UpdateWriteSQLFile(globalContext.fileName, item.toString());
								throw new RuntimeException("シングルピックSQL実行エラー");
							}
						} else {
							//ymlにはこのテーブルは構成されておらず、0-7以内ではなく、8以外の論理を実行することを意味しています
							//次のエントリに進む
							WriteSQLAnnotation wqa = new WriteSQLAnnotation();
                            wqa.UpdateWriteSQLFile(globalContext.fileName, item.toString());
							throw new RuntimeException("シングルピックSQL実行エラー");
						}
					}
				}
				//update実行 // 以下 cyc:10
				if (item.toString().startsWith("UPDATE")) {
					WriteSQLAnnotation wqa = new WriteSQLAnnotation();
                    wqa.DeleteWriteSQLFile(globalContext.fileName, item.toString());
				}
			}
		}

		// add #11399 djy start
		if(globalContext.fileName.contains("mst_comsv_setting")&& !itemsNew.isEmpty())
		{
            // mod #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe start
			updateMstComsvSettingDeviceEdgeNo(globalContext.fileName.contains("diff"));
			// mod #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe end
		}
		// add #11399 djy end

		// add #9181 zl start
        if (globalContext.fileName.contains("mst_trend_graph_monitor_set")) {
            processMstTrendGraphMonitorSet(globalContext.fileName);
		}
		// add #9181 zl end

        if (globalContext.fileName.contains("ord_main")) {
			processOrdMain();
		}
		// add 12380 コンバートされたデータで治療記録-治療条件-補液量が0で登録されることがある zkm start
        if (globalContext.fileName.contains("pat_treatment_pattern")) {
            processPatTreatmentPattern(globalContext.fileName);
		}
		// add 12380 コンバートされたデータで治療記録-治療条件-補液量が0で登録されることがある zkm end

		/**
		 * INSERT一括実行SQLの場合、一括実行終了でSQLファイルが削除されます
		 * 一括実行のSQLにエラーはありません。一括実行ができない場合は、既存の方法で1つずつ実行され、
		 * エラーのSQLが記録され、最後に一括注釈が追加されます。SQLファイルに書き込まれます。
		 */
		if (items.get(0).toString().trim().startsWith("INSERT")) {
			//エラーsqlデータはありません（ファイルへの空の書き込み）
			WriteSQLAnnotation wqa = new WriteSQLAnnotation();
            wqa.fileNioWrite(globalContext.fileName, "", false);
		}

		// add #9448 mst_mainte_category.detail再設定 zkm start
        if (globalContext.fileName.contains("mst_mainte_category")) {
			updMainteCategoryDetail();
		}
		// add #9448 mst_mainte_category.detail再設定 zkm end

		// add #10870 mnt_mainte_main.detail再設定 zkm start
        if (globalContext.fileName.contains("mnt_mainte_main")) {
			updMainteMainDetail();
		}
		// add #10870 mnt_mainte_main.detail再設定 zkm end

		// add #10969  zc start
        if (globalContext.fileName.contains("ord_personal_prescription")) {
			updateOrdPersonalPrescription();
		}
		// add #10969  zc end

		// add #11096  zc start
        if (globalContext.fileName.contains("mst_machine_record_control")) {
            updateMstMachineRecordControl(globalContext.fileName);
		}
		// add #11096  zc end
	}

	// add FNSI-差分コンバート対応 李 start
	/**
	 *
	 * @param item
	 * @param firstItem
	 * @return true: continue outter for (T item : itemsNew)
	 * 			false: not continue outter for (T item : itemsNew)
	 * @throws Exception
	 */
	private boolean processFnsiDiff(T item,T firstItem) throws Exception {
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        if (!item.toString().trim().contains("UPDATE") && !item.toString().trim().contains("INSERT"))
		{
            String realTableName = PsqlCopyUtils.getTableName(globalContext.fileName);
			String realData = "";
			String[] names = getTableConvertKey(realTableName);
			if (names.length > 2){
				for (int i = 2 ;i < names.length;i++)
				{
					realData = realData + names[i].substring(0, names[i].length() - 2) + ",";
				}
				if (!realData.isEmpty()){
					realData = realData.substring(0, realData.length() - 1);
				}
				realData = " concat_ws(''," + realData + ")";
			}
			TableNameToDbType tableNameToDbType = new TableNameToDbType(appContext);
			WriteSQLAnnotation wqa5 = new WriteSQLAnnotation();
			// db5から、pKey
			String keys = firstItem.toString();
			List<String> realKeysList =  new ArrayList<>();
			// mod 7853-差分コンバートで更新/削除ができない 楊  start
			// List<String> keyList = Arrays.asList(keys.split(","));
			List<String> keyList = new ArrayList<String>(Arrays.asList(keys.split(",")));
			// 複数レコード削除
			keyList = keyList.stream().distinct().collect(Collectors.toList());
			// mod 7853-差分コンバートで更新/削除ができない 楊  end
			for (String key:keyList)
			{
				realKeysList.add(key);
			}

			String associationTableName = names[0];
			String pKey = names[1];
			String sql = "";
			// mod 7853-差分コンバートで更新/削除ができない 楊 start
			globalContext.sqlNewKeys =  "";
			globalContext.insFnKey = "";
			globalContext.sqlKeys =  "";
			// add 12420 FNWの「転入/導入」が全て「導入」でコンバートされる hyl start
			globalContext.sqlDisNoKeys = "";
			//add 12420 FNWの「転入/導入」が全て「導入」でコンバートされる hyl end
			// 本番のキー (更新レコード)
			List<String> rs5 = new ArrayList<String>();
			// 本番のキー (更新レコード、sql検索用)
			String values = "";
			// sqlファイルの一行目fnキーリスト(新規レコード)
			List<String> keyInsList= keyList;
			// fnのキー(更新レコード、 keyconvert-key[2]から)
			List<String> keyUpdList= new ArrayList<String>();
			// 本番dbのキーを取得
			// mod #8992-4 pat_event zs start
			HikariDataSource associationds = null;
			if (Set.of(
					"pat_event",
					"mst_user",
					"mst_user_authentication",
					"pat_group_detail",
					"pat_ind_approve_history"
			).contains(realTableName)) {
				associationds = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
			} else {
				String associationType =tableNameToDbType.getDbTypeByTableName(associationTableName);
				associationds = (HikariDataSource) appContext.getBean(associationType);
			}
			// mod #8992-4 pat_event zs end
			NamedParameterJdbcTemplate associationNamedJdbcTemplate = new NamedParameterJdbcTemplate(associationds);
			// mod #11588 差分コンバートで投与薬剤の変更でサーバー処理が進まなくなる limingyang start
			List fieldsList = new ArrayList(){};
			if (("medicine_latest_no").equals(realTableName)){
				HikariDataSource associationds6 = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.NKK6);
				JdbcTemplate associationJdbcTemplate6 = new JdbcTemplate(associationds6);
				String sqlForMLN = "SELECT pat_id::text AS pkey, fn_pat_id AS realDate FROM pat_personal_main WHERE facility_cd = :facilityCd AND fn_pat_id IN (:fnPatIds)";

				List<String> fnPatIds = keyList;

				Map<String, Object> params = new HashMap<>();
				params.put("facilityCd", facilityCd);
				params.put("fnPatIds", fnPatIds);

				NamedParameterJdbcTemplate namedParameterJdbcTemplate = new NamedParameterJdbcTemplate(associationJdbcTemplate6);
				fieldsList = namedParameterJdbcTemplate.queryForList(sqlForMLN, params);
			}else{
				if (utils.byFacilityCdList.contains(realTableName)) {
					Map<String, Object> params = new HashMap<>();
					params.put("facilityCd", facilityCd);
					sql = "select " + pKey + " as pkey , " +  realData + " as realDate from " + associationTableName + " where facility_cd = :facilityCd";
					fieldsList = associationNamedJdbcTemplate.queryForList(sql, params);
				} else {
					Map<String, Object> params = new HashMap<>();
					params.put("facilityCd", facilityCd);
					sql = "select " + pKey + " as pkey , " +  realData + " as realDate from " + associationTableName + " where facility_cd = :facilityCd";
					if (!realKeysList.isEmpty()) {
						params.put("realKeys", realKeysList);
						sql += " and " +  realData + " in (:realKeys)";
					}
					fieldsList = associationNamedJdbcTemplate.queryForList(sql, params);
				}
			}
			// mod #11588 差分コンバートで投与薬剤の変更でサーバー処理が進まなくなる limingyang end
			if (!fieldsList.isEmpty()) {
				Iterator it = fieldsList.iterator();
				while (it.hasNext()) {
					Map field = (Map) it.next();
					// 本番キー(keyconvert-key[1])
					String pkey = field.get("pkey").toString();
					if (!rs5.contains(pkey))
					{
						rs5.add(pkey);
						values +=  " '" + pkey + "',";
					}
					// fnキー
					String realDate = field.get("realDate").toString();
					keyUpdList.add(realDate);
				}
			}
			if ( "A".equals(globalContext.plan) )
			{
				keyInsList.removeAll(keyUpdList);
			}
			values = values.replaceFirst(".$","");
			// mod 7853-差分コンバートで更新/削除ができない 楊 end
			if (ObjectUtils.isEmpty(globalContext.keepTableName) || globalContext.keepTableName.equals(realTableName)){
				// mod 7853-差分コンバートで更新/削除ができない 楊 start
				globalContext.keepOldKeys = globalContext.keepKeys;
				HashSet hs1 = new HashSet(rs5);
				HashSet hs2 = new HashSet(globalContext.keepOldKeys);
				hs1.removeAll(hs2);
				globalContext.keepKeys.addAll(hs1);
				// mod 7853-差分コンバートで更新/削除ができない 楊 end
			} else {
				globalContext.keepKeys = rs5;
			}
			globalContext.keepTableName = realTableName;

			// add zl start
			Integer maxPrimaryForConvert = getMaxPrimaryOfAllDeleteAllInsertTables(realTableName);
			if (maxPrimaryForConvert != null) {
				globalContext.maxPrimaryForConvert = maxPrimaryForConvert;
			}
			// add zl end

			if ( "B".equals(globalContext.plan) ) {
				// mod 7853-差分コンバートで更新/削除ができない 楊 start
				// utils.sqlKeys =  values;
				this.setPlanB(values, realTableName, rs5, pKey);
				globalContext.insFnKey = realData;
				// mod 7853-差分コンバートで更新/削除ができない 楊 end
				wqa5.DeleteWriteSQLFile(globalContext.fileName, firstItem.toString());
				// add zl start
				if (Set.of("mni_monitor","ord_checklist").contains(realTableName)) {
					globalContext.sqlNewKeys = "";
					globalContext.sqlKeys = values;
				}
				// add zl end
				return true; // continue outter for (T item : itemsNew)
			}
			else {
				globalContext.sqlKeys =  values;
				// mod 7853-差分コンバートで更新/削除ができない 楊 start
				String newValues = "";
				for (String value:keyInsList) {
					newValues +=  " '" + value + "',";
				}
				newValues = newValues.replaceFirst(".$","");
				globalContext.sqlNewKeys =  newValues;
				globalContext.insFnKey = realData;
				// mod 7853-差分コンバートで更新/削除ができない 楊 end

				// add #8992-4 pat_event zs start
				// コンバートDBを削除
				if (("pat_event").equals(realTableName)) {
					deletePatEventInConvertDB(rs5,keyInsList);
				}
				// add #8992-4 pat_event zs end

				// add 10739 pat_ind_approve_history  start
				if (("pat_ind_approve_history").equals(realTableName)) {
					deletePatIndApproveHistoryInConvertDB(rs5);
				}
				// add10739 pat_ind_approve_history  end

				// add 11667 日常点検コンバート修正  start
				if("bbs_info".equals(realTableName)){
					deleteBbsInfoInConvertDB(facilityCd,globalContext.sqlKeys);
				}
				// add #9801 zl end

				// add #8400 LL　start
				if (!(globalContext.fileName.contains("diff") && globalContext.fileName.contains("mst_selector"))) {
					wqa5.DeleteWriteSQLFile(globalContext.fileName, firstItem.toString());
				}
				// continue;
				return true; // continue outter for (T item : itemsNew)
				// add #8400 LL　end
			}
		}
		return false;
	}
	// add FNSI-差分コンバート対応 李 end

	private boolean processDiff(List<? extends T> items,String tableName) throws Exception {
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
		boolean isReturnCallerMethod =  false;
		// add zl start ord_main差分
        if (globalContext.fileName.contains("ord_main")) {
			processOrdMainDiff(items);
			isReturnCallerMethod = true;
			return isReturnCallerMethod;
		}
		// add zl end ord_main差分

		// ad zl start pat_coop_detail差分
        if (globalContext.fileName.contains("pat_coop_detail"))
		{
            globalContext.sqlKeys = "";
            globalContext.sqlNewKeys = "";
            globalContext.insFnKey = "";
			processPatCoopDetailDiff(items);
			isReturnCallerMethod = true;
			return isReturnCallerMethod;
		}
		// ad zl end pat_coop_detail差分


		// add #12401 コンバート施設で予定作成が処理中から進まなくなる gaolin start
        if (globalContext.fileName.contains("mst_kur")) { // cyc:2
			processMstKurDiff(items);
		}
		// add #12401 コンバート施設で予定作成が処理中から進まなくなる gaolin end

		// add #12339 コンバート対象とコンバータの設定値見直し start
        if (globalContext.fileName.contains("mst_user"))
		{
			processMstUserDiff(items);
		}
		// add #12339 コンバート対象とコンバータの設定値見直し end

		// add #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe start
		if (tableName.contains("mst_comsv_setting")) {
			globalContext.sqlKeys = "";
			globalContext.sqlNewKeys = "";
			globalContext.insFnKey = "";
			processMstComsvSettingDiff(globalContext.fileName,items);
			isReturnCallerMethod = true;
			return isReturnCallerMethod;
		}

		if (tableName.equals("mst_weight")) {
			List<String> columnNameList = new ArrayList<>();
			columnNameList.add("wait_auto_send_before");
			columnNameList.add("wait_auto_send_after");
			columnNameList.add("color_setting");
			columnNameList.add("audio_setting");
			columnNameList.add("telegram_format");
			String sql = " select weight_no from mst_weight where facility_cd = ? ";
            List<Integer> cdList = namedParameterJdbcTemplate.getJdbcOperations().queryForList(sql, new Object[]{facilityCd}, Integer.class);
            updateProdDefaultValueSet("mst_weight", "weight_no", StringUtils.join(cdList, ","), columnNameList);
		}
		// add #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe end
		return isReturnCallerMethod;
	}

	private void processOrdMainDiff(List<? extends T> items) {
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
		// 差分キーMap(fn_plural,fn_pat_id,treat_date)
		Map<Integer,String> normalMap = new HashMap();
		// 差分キーMap(rst_fn_dialysis_no)
		Map manualActualMap = new HashMap();
		// データベースに存在する集合
		List<String> dialysisNoList = new ArrayList<>();
		List<String> treatDateList = new ArrayList<>();
		// ファイル行数
		int row = 0;
		//List<T> itemsOrdMain = new ArrayList<>();
		String sqlNewKeys = "";
		String sqlNewKeys2 = "";
		globalContext.sqlKeys = "";
		globalContext.sqlNewKeys = "";
		globalContext.insFnKey = "";
		for (T item : items) {
			// 一行目（差分キー）
			if (row == 0) {
				String keys = item.toString();
				List<String> keyList = new ArrayList<String>(Arrays.asList(keys.split(",")));
				// キー総数
				int count = 1;
				//　キー - SQLインジェクション対策：文字列連結の代わりにListを使用
				List<String> normalKeyList = new ArrayList<>();
				List<String> manualActualKeyList = new ArrayList<>();
				for (String key : keyList) {
					//　同日複数回
					String fn_plual = key.substring(0,1);
					if ("0".equals(fn_plual)) {
						// 手動実際
						String actualKey = key.substring(1);
						manualActualMap.put(count, actualKey);
						manualActualKeyList.add(actualKey);
					} else {
						// 手動実際以外
						normalMap.put(count, key);
						normalKeyList.add(key);
					}
					count ++;
				}

				// 更新キー（存在する場合、ord_no）
				List<String> ordNoList = new ArrayList<>();

				// #9247 手動実際データがなくなるで、クエリのWHERE句に指定しているrst_fn_dialysis_noが1つもないという内容の場合のエラーが発生している Start
				// SQLインジェクション対策：パラメータ化クエリを使用
				if (!manualActualKeyList.isEmpty()) {
					// 手動実際の場合、rst_fn_dialysis_noとord_noを取得
					List<Long> manualActualKeyIntList = manualActualKeyList.stream()
							.map(k -> Long.valueOf(k.trim()))
							.toList();
					// facility_cd
					Map<String, Object> params = new HashMap<>();
					params.put("facilityCd", facilityCd);
					// rst_fn_dialysis_no (where IN)
					params.put("keyList", manualActualKeyIntList);
					String manualActualSql =
							"SELECT rst_fn_dialysis_no, ord_no " +
									"FROM ord_main " +
									"WHERE facility_cd = :facilityCd " +
									"  AND rst_fn_dialysis_no IN (:keyList)";
					List<Map<String, Object>> maMap = namedParameterJdbcTemplateConvert.queryForList(manualActualSql, params);
					if (!maMap.isEmpty()) {
						dialysisNoList = maMap.stream().map(m-> m.get("rst_fn_dialysis_no").toString()).collect(Collectors.toList());
						ordNoList = maMap.stream().map(m-> m.get("ord_no").toString()).collect(Collectors.toList());
					}
				}

				// SQLインジェクション対策：パラメータ化クエリを使用
				// 正常の場合、concat_ws('',fn_plural,fn_pat_id,treat_date) を取得
				if (!normalKeyList.isEmpty()) {
					String normalSql = """ 
										select concat_ws('',fn_plural,fn_pat_id,treat_date) as key,ord_no 
										from ord_main 
										where facility_cd = :facilityCd 
										and concat_ws('',fn_plural,fn_pat_id,treat_date) in (:normalKeyList)
										""";
					Map<String, Object> params = new HashMap<>();
					params.put("facilityCd", facilityCd);
					params.put("normalKeyList", normalKeyList);
					List<Map<String, Object>> noMap = namedParameterJdbcTemplateConvert.queryForList(normalSql, params);
					if (!noMap.isEmpty()) {
						treatDateList = noMap.stream().map(m-> m.get("key").toString()).collect(Collectors.toList());
						ordNoList.addAll(noMap.stream().map(m-> m.get("ord_no").toString()).collect(Collectors.toList()));
					}
				}
				// #9247 手動実際データがなくなるで、クエリのWHERE句に指定しているrst_fn_dialysis_noが1つもないという内容の場合のエラーが発生している End

				// 更新キー
				if (!ordNoList.isEmpty()) {
					globalContext.sqlKeys = String.join(", ", ordNoList);
				}
			} else {
				// SQL再作成
				if (item.toString().contains(" @@@@@ ")) {
					// SQL：INSERT @@@@@ UPDATE
					String[] sql = item.toString().split(" @@@@@ ");
					MapSqlParameterSource parameters = new MapSqlParameterSource().addValue("facility_cd", facilityCd);
					//　正常場合
					if (normalMap.containsKey(row)){
						if (treatDateList.contains(normalMap.get(row))){
							// 更新 - SQLインジェクション対策：名前付きパラメータを使用
							item = (T)(sql[1] + " WHERE concat_ws('',fn_plural,fn_pat_id,treat_date) = :concat_key and facility_cd = :facility_cd");
							parameters.addValue("concat_key", normalMap.get(row));
						} else {
							// 新規
							item = (T)sql[0];
							sqlNewKeys += "'" + normalMap.get(row).toString() + "',";
						}
					}
					//　手動実際場合
					if (manualActualMap.containsKey(row)){
						if (dialysisNoList.contains(manualActualMap.get(row))){
							// 更新 - SQLインジェクション対策：名前付きパラメータを使用
							item = (T)(sql[1]  + " WHERE rst_fn_dialysis_no = :dialysis_no and facility_cd = :facility_cd");
							String dialysisNoStr = (String) manualActualMap.get(row);
							Long dialysisNo = (dialysisNoStr == null || dialysisNoStr.trim().isEmpty())
									? null
									: Long.valueOf(dialysisNoStr.trim());
							parameters.addValue("dialysis_no", dialysisNo);
						} else {
							// 新規
							item = (T)sql[0];
							sqlNewKeys2 += "'" + manualActualMap.get(row).toString() + "',";
						}
					}
					namedParameterJdbcTemplate.update(item.toString(), parameters);
				}
			}
			WriteSQLAnnotation wqa5 = new WriteSQLAnnotation();
			wqa5.DeleteWriteSQLFile(globalContext.fileName, items.get(row).toString());
			row++;
		}
		// 新規キー（fn_plural,fn_pat_id,treat_date）
		if (!sqlNewKeys.isEmpty()) {
			if (StringUtils.isEmptyOrWhitespace(sqlNewKeys) == false){
				sqlNewKeys = sqlNewKeys.substring(0, sqlNewKeys.length() - 1);
			}
			globalContext.sqlNewKeys = sqlNewKeys;
			globalContext.insFnKey = "concat_ws('',fn_plural,fn_pat_id,treat_date)";
		}
		// 新規キー（rst_fn_dialysis_no）
		if (!sqlNewKeys2.isEmpty()) {
			if (StringUtils.isEmptyOrWhitespace(sqlNewKeys2) == false){
				sqlNewKeys2 = sqlNewKeys2.substring(0, sqlNewKeys2.length() - 1);
			}
			globalContext.sqlDisNoKeys = sqlNewKeys2;
			globalContext.insFnDisKey = "rst_fn_dialysis_no";
		}
		// add 12380 コンバートされたデータで治療記録-治療条件-補液量が0で登録されることがある zkm start
		String sql = "select pat_id, ord_no, rst_dialysis_state, ind_treatment_cd, ind_cond_info," +
				" rst_treatment_cd, rst_cond_info, rst_bed_cd, rst_off_water_info, rst_weight_info,convert_id " +
				"from ord_main " +
				"where rst_dialysis_state in ('0', '6') and facility_cd = :facilityCd";
		Map<String, Object> params = new HashMap<>();
		params.put("facilityCd", facilityCd);
		List<OrdMain> ordMainList = new ArrayList<>();
		if (!StringUtils.isEmptyOrWhitespace(globalContext.sqlNewKeys)) {
			// utils.insFnKey : concat_ws('',fn_plural,fn_pat_id,treat_date)
			String sqlInsert = sql + " and " + globalContext.insFnKey + "in (" + globalContext.sqlNewKeys + ")";
			ordMainList = namedParameterJdbcTemplateConvert.query(sqlInsert, params, new BeanPropertyRowMapper<>(OrdMain.class));
		}
		if (!StringUtils.isEmptyOrWhitespace(globalContext.sqlKeys)) {
			String sqlInsert = sql + " and ord_no in (" + globalContext.sqlKeys + ")";
			ordMainList.addAll(namedParameterJdbcTemplateConvert.query(sqlInsert, params, new BeanPropertyRowMapper<>(OrdMain.class)));
		}
		// ind_cond_info
		ordMainList = ordMainList.stream().filter(o -> Objects.nonNull(o.getIndTreatmentCd())).collect(Collectors.toList());

		//add #12229->12380 start
		String getPatSql = "SELECT pat_id, device_set_info FROM pat_main WHERE pat_id in(:patId)  AND facility_cd = :facilityCd";

		List<Long> patIdList = ordMainList.stream()
				.map(OrdMain::getPatId)
				.filter(Objects::nonNull)
				.distinct()
				.collect(Collectors.toList());
		Map<String, Object> params1 = Map.of(
				"patId", patIdList,
				"facilityCd", facilityCd
		);
		if(patIdList.isEmpty()){
			return;
		}
		List<PatMain> patMainList = namedParameterJdbcTemplateConvert.query(
				getPatSql,
				params1,
				new BeanPropertyRowMapper<>(PatMain.class)
		);
		Map<Long, String> patDeviceMap = patMainList.stream()
				.collect(Collectors.toMap(
						PatMain::getPat_id,
						PatMain::getDevice_set_info,
						(a, b) -> a
				));
		//add #12229->12380 end

		if (!CollectionUtils.isNullOrEmpty(ordMainList)) {
			//add #12229->12380 start
			updateOrdMainIvAmountAndIvSpeed(namedParameterJdbcTemplateConvert, ordMainList, false,patDeviceMap);
			//add #12229->12380 end
		}
		// rst_ind_info
		List<OrdMain> rstOrdMains = ordMainList.stream().filter(o -> "6".equals(o.getRstDialysisState())).toList();
		if (!CollectionUtils.isNullOrEmpty(rstOrdMains)) {
			rstOrdMains.forEach(o -> {
				o.setIndTreatmentCd(o.getRstTreatmentCd());
				o.setIndCondInfo(o.getRstCondInfo());
			});
			//add #12229->12380 start
			updateOrdMainIvAmountAndIvSpeed(namedParameterJdbcTemplateConvert, rstOrdMains, true,patDeviceMap);
			//add #12229->12380 end
		}
		// add 12380 コンバートされたデータで治療記録-治療条件-補液量が0で登録されることがある zkm end
		//add #12309  【因島】「指示変更内容」の画面が表示できない　hyl start
		updateOrdMain();
		//add #12309  【因島】「指示変更内容」の画面が表示できない　hyl start
	}

	private void processPatCoopDetailDiff(List<? extends T> items) {
		// ファイル行数
		int row = 0;
		// データベースに存在する集合
        //mod 11576 pat_coop_detailのsave_1がGX固定でコンバートされる start
        Map<String, Long> resultMap=new HashMap<>();
        //mod 11576 pat_coop_detailのsave_1がGX固定でコンバートされる end
		List<String> listKey = new ArrayList<>();
		Map map = new HashMap();
		// 登録キー
		String sqlNewKeys = "";
		String sqlM = "SELECT COALESCE(max(coop_save_no),0) as currSeq FROM pat_coop_detail where facility_cd = ?";
		String convertProcId = jdbcTemplateConvert.queryForObject(
				sqlM, new Object[] {  facilityCd }, String.class);
		for (T item : items) {
			String keys = item.toString();
			// 一行目（差分キー）
			if (row == 0) {
				List<String> keyList = new ArrayList<String>(Arrays.asList(keys.split(",")));
				int count = 1;
				for (String key : keyList) {
					map.put(count, key);
					count ++;
				}
				String sql = """
							select (save_2->> 'ord_no') as ord_no,
								coop_save_no,
								fn_pat_id 
							 from pat_coop_detail c 
								INNER JOIN pat_personal_main p ON c.pat_id=p.pat_id 
							 where c.facility_cd = :facilityCd and (save_2->> 'ord_no')||p.fn_pat_id in (:fnPatIds) 
							""";
				Map<String, Object> params = new HashMap<>();
				params.put("facilityCd", facilityCd);
                //mod 11576 pat_coop_detailのsave_1がGX固定でコンバートされる start
                List<String> fnPatIds = Arrays.stream(keys.split(","))
						.filter(k -> !k.isEmpty())
                        .map(String::valueOf)
						.collect(Collectors.toList());
                //mod 11576 pat_coop_detailのsave_1がGX固定でコンバートされる end
				params.put("fnPatIds", fnPatIds);
				List<Map<String, Object>> maMap = namedParameterJdbcTemplateConvert.queryForList(sql,params);
				if (!maMap.isEmpty()) {
                    //mod 11576 pat_coop_detailのsave_1がGX固定でコンバートされる start
					resultMap =  maMap.stream()
							.collect(Collectors.toMap(
									m -> m.get("ord_no").toString() + m.get("fn_pat_id").toString(),
                                    m -> ((Number) m.get("coop_save_no")).longValue(),
									(existing, replacement) -> existing
							));
                    //mod 11576 pat_coop_detailのsave_1がGX固定でコンバートされる end
					listKey = maMap.stream().map(m-> m.get("coop_save_no").toString()).collect(Collectors.toList());
				}
				if (!listKey.isEmpty()) {
					globalContext.sqlKeys = String.join(", ", listKey);
				}
			} else {
				if (item.toString().contains(" @@@@@ ")) {
					// SQL：INSERT @@@@@ UPDATE
					String[] sql = item.toString().split(" @@@@@ ");
					if (map.containsKey(row)){
                        if (resultMap.containsKey(map.get(row).toString())) {
							// 更新
							item = (T)(sql[1] + " WHERE facility_cd = :facility_cd and coop_save_no = :coop_save_no");
							MapSqlParameterSource parameters = new MapSqlParameterSource()
                                    .addValue("facility_cd", facilityCd)
                                    .addValue("coop_save_no", resultMap.get(map.get(row).toString()));
							namedParameterJdbcTemplate.update(item.toString(), parameters);
						} else {
							// 新規
							item = (T)sql[0];
							sqlNewKeys += map.get(row).toString() + ",";
                            MapSqlParameterSource parameters = new MapSqlParameterSource().addValue("facility_cd", facilityCd);
							namedParameterJdbcTemplate.update(item.toString(), parameters);
						}
					}
				}
			}
			WriteSQLAnnotation wqa5 = new WriteSQLAnnotation();
            wqa5.DeleteWriteSQLFile(globalContext.fileName, items.get(row).toString());
			row++;
		}
		// 新規キー
		if (!sqlNewKeys.isEmpty()) {
            globalContext.sqlNewKeys = convertProcId;
            globalContext.insFnKey = "coop_save_no";
		}
	}

	private void processMstKurDiff(List<? extends T> items) {
		// ファイル行数
		int row = 0;
		// データベースに存在する集合 - SQLインジェクション対策：パラメータ化クエリを使用
		String original = items.get(row).toString();
		List<String> itemsList = Arrays.stream(original.split(","))
				.map(String::trim)
				.filter(s -> !s.isEmpty())
				.collect(Collectors.toList());
		Map<String, Object> params = new HashMap<>();
		params.put("facilityCd", facilityCd);
		params.put("fnKurCds", itemsList);
		String defFieldSql = " select kur_cd,mst_user_authentication from mst_kur  where facility_cd = :facilityCd and fn_kur_cd  in (:fnKurCds) order by kur_cd ";
		DataSource db5Ds = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
		NamedParameterJdbcTemplate db5NamedJdbcTemplate = new NamedParameterJdbcTemplate(db5Ds);
		List<Map<String, Object>> maMap = db5NamedJdbcTemplate.queryForList(defFieldSql, params);
		for(Map<String, Object> m : maMap){
			String defUpdSql = "update mst_kur set mst_user_authentication = ? ::JSONB where kur_cd=? and facility_cd = ?";
			jdbcTemplateConvert.update(defUpdSql,
					m.get("mst_user_authentication").toString(),
					m.get("kur_cd"),
					facilityCd);
		}
	}

	private void processMstUserDiff(List<? extends T> items) {
		// ファイル行数
		int row = 0;
		// データベースに存在する集合
		String original = items.get(row).toString();
		String itemsInSql = Arrays.stream(original.split(","))
				.map(s -> "'" + s + "'")
				.collect(Collectors.joining(","));
		String sql ="select user_id " +
				"from mst_personal_user " +
				"where facility_cd = ? " +
				"and fn_staff_cd in (" + itemsInSql + ") " +
				"order by user_id";

		List<String> userIdLists =
				jdbcTemplateConvert.queryForList(sql, String.class, facilityCd);

		String userIdInSql = userIdLists.stream()
				.map(id -> "?")
				.collect(Collectors.joining(","));
		DataSource db5Ds = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
		JdbcTemplate db5Jdbc = new JdbcTemplate(db5Ds);
		String defFieldSql =
				"select user_id, user_settings " +
						"from mst_user " +
						"where facility_cd = ? " +
						"and user_id in (" + userIdInSql + ") " +
						"order by user_id";
		List<Object> defParams = new ArrayList<>();
		defParams.add(facilityCd);

		for (String id : userIdLists) {
			defParams.add(Long.valueOf(id));
		}

		List<Map<String, Object>> maMap =
				db5Jdbc.queryForList(defFieldSql, defParams.toArray());
		String defUpdSql =
				"update mst_user " +
						"set user_settings = ?::jsonb " +
						"where user_id = ? " +
						"and facility_cd = ?";

		for (Map<String, Object> m : maMap) {

			Object[] params = new Object[] {
					m.get("user_settings"),
					((Number) m.get("user_id")).longValue(),
					facilityCd
			};

			jdbcTemplateConvert.update(defUpdSql, params);
		}
	}

	/**
	 * 差分コンバートにより元に戻ってしまう項目がある
	 * @param fileName
	 * @param items
	 */
	private void processMstComsvSettingDiff(String fileName,List<? extends T> items) throws Exception {
		// 登録キー
		String sqlNewKeys = "";

		// ファイル行数
		int row = 0;
		// データベースに存在する集合
		List<String> keyList = new ArrayList<>();
		List<Integer> updList = new ArrayList<>();
		Map<Integer, List<Integer>> resultMap = new HashMap<>();
		for (T item : items) {
			String keys = item.toString();
			// 一行目（差分キー）
			if (row == 0) {
				keyList = new ArrayList<String>(Arrays.asList(keys.split(",")));
                String sql = " select convert_id, comsv_cd, device_edge_no, fn_comsv_no from mst_comsv_setting c where c.facility_cd = ? order by c.device_edge_no ";
                List<Map<String, Object>> maMap = jdbcTemplateConvert.queryForList(sql, facilityCd);
				if (!maMap.isEmpty()) {
					int count = 1;
					for (String key : keyList) {
                        List<Integer> comsvCdList = maMap.stream().filter(m -> m.get("fn_comsv_no") != null && m.get("fn_comsv_no").toString().equals(key))
								.map(m-> Integer.parseInt(m.get("comsv_cd").toString()))
								.collect(Collectors.toList());
                        resultMap.put(count, comsvCdList);
                        updList.addAll(comsvCdList);
						count++;
					}

					List<String> convertComsvList = new ArrayList<>();
					for(Map<String, Object> map : maMap){
						convertComsvList.add(String.valueOf(map.get("device_edge_no")) + "," + String.valueOf(map.get("fn_comsv_no")));
					}
                    globalContext.convertComsvList = convertComsvList;
				}
				if (!updList.isEmpty()) {
                    globalContext.sqlKeys = StringUtils.join(updList, ",");

					List<String> columnNameList = new ArrayList<>();
					columnNameList.add("treat_realtime_monito_interval");
					columnNameList.add("other_realtime_monito_interval");
                    updateProdDefaultValueSet("mst_comsv_setting", "comsv_cd", globalContext.sqlKeys, columnNameList);
				}
			} else {
				if (item.toString().contains(" @@@@@ ")) {
					// SQL：INSERT @@@@@ UPDATE
					String[] sql = item.toString().split(" @@@@@ ");
					if (resultMap.get(row) != null && !resultMap.get(row).isEmpty()){
						// SQLインジェクション対策：NamedParameterJdbcTemplateのCollectionパラメータを使用
						item = (T)(sql[1] + " WHERE facility_cd = :facility_cd and comsv_cd in (:comsv_cd_list)");
						MapSqlParameterSource parameters = new MapSqlParameterSource()
								.addValue("facility_cd", facilityCd)
								.addValue("comsv_cd_list", resultMap.get(row));
						namedParameterJdbcTemplate.update(item.toString(), parameters);
					} else {
						// 新規
						item = (T)sql[0];
						sqlNewKeys += keyList.get(row-1) + ",";
						MapSqlParameterSource parameters = new MapSqlParameterSource().addValue("facility_cd", facilityCd);
						namedParameterJdbcTemplate.update(item.toString(), parameters);
					}
				}
			}
			WriteSQLAnnotation wqa5 = new WriteSQLAnnotation();
            wqa5.DeleteWriteSQLFile(globalContext.fileName, items.get(row).toString());
			row++;
		}

		sqlNewKeys += updateMstComsvSettingDeviceEdgeNo(fileName.contains("diff"));

		// 新規キー
		if (!sqlNewKeys.isEmpty()) {
            String comsv_setting_sql = "select convert_id from mst_comsv_setting where facility_cd = ? and comsv_cd is null order by convert_id asc";
            List<Integer> setting_convert_ids = namedParameterJdbcTemplate.getJdbcOperations().queryForList(comsv_setting_sql, new Object[]{facilityCd}, Integer.class);
            if (setting_convert_ids != null && !setting_convert_ids.isEmpty()) {
                globalContext.sqlNewKeys = StringUtils.join(setting_convert_ids, ",");
            }
            globalContext.insFnKey = "comsv_cd";
		}
	}

	private void processMstTrendGraphMonitorSet(String fileName) throws Exception {
		String sql = " WITH list AS ( " +
                " SELECT convert_id,array_to_json (array_agg(json_build_object('code',d.code::INT,'name',d.name,'checked',d.check) ORDER BY sequence )) as series_info " +
                " FROM ( SELECT ROW_NUMBER() OVER (ORDER BY b.moni_data_type_new,rownum,CAST(REPLACE(b.moni_data_no, b.moni_data_type_new, '' ) AS INT)) AS sequence ," +
                " a.convert_id,b.moni_data_no as code ,b.moni_data_name as name,case when r.convert_id is not null then true else false end as check " +
                " FROM ( SELECT case moni_data_type when 'R' then '001' when 'A' then '002' when 'D' then '003' end as moni_data_type_new, moni_data_name, replace(moni_data_no,moni_data_type,'') as moni_data_no " +
                " FROM sys_monitor_item WHERE moni_data_type IN ( 'A', 'D', 'R' )) b  join mst_trend_graph_monitor_set a on b.moni_data_type_new = a.model and a.facility_cd= ? " +
                " left join ( SELECT row_number() over () as rownum, r.* FROM (SELECT convert_id, model, jsonb_array_elements_text(series_info)::jsonb->>'code' as codeList FROM mst_trend_graph_monitor_set where facility_cd = ? " +
                " )r ) r on  b.moni_data_type_new = r.model and replace(b.moni_data_no,b.moni_data_type_new,'') in (r.codeList) and a.convert_id = r.convert_id " +
                " order by b.moni_data_type_new, rownum, cast(replace(b.moni_data_no,b.moni_data_type_new,'') as INT) ) d " +
                " group by convert_id )" +
                " UPDATE mst_trend_graph_monitor_set SET series_info = list.series_info FROM list where mst_trend_graph_monitor_set.convert_id = list.convert_id ";

		// 差分
		if (fileName.contains("diff")) {
			//更新
            if (!globalContext.sqlKeys.isEmpty()) {
                String sqlUpdate = sql + "and mst_trend_graph_monitor_set.monitor_set_cd in (" + globalContext.sqlKeys + ")";
                namedParameterJdbcTemplateConvert.getJdbcOperations().update(sqlUpdate, facilityCd, facilityCd);
			}
			//新規
            if (!globalContext.sqlNewKeys.isEmpty()) {
                String sqlInsert = sql + "and " + globalContext.insFnKey + "in (" + globalContext.sqlNewKeys + ")";
                namedParameterJdbcTemplateConvert.getJdbcOperations().update(sqlInsert, facilityCd, facilityCd);
			}
		} else {
            namedParameterJdbcTemplateConvert.getJdbcOperations().update(sql, facilityCd, facilityCd);
		}
	}

	private void processOrdMain() throws Exception {
		String sql = "select \n" +
				// mod 12380 コンバートされたデータで治療記録-治療条件-補液量が0で登録されることがある zkm start
				"pat_id, ord_no, ind_treatment_cd, ind_cond_info, rst_dialysis_state, " +
				"rst_treatment_cd, rst_cond_info, rst_bed_cd, rst_off_water_info, rst_weight_info,convert_id " +
				// mod 12380 コンバートされたデータで治療記録-治療条件-補液量が0で登録されることがある zkm end
				"from \n" +
				"ord_main  " +
                "where ord_no is null \n" +
				"and facility_cd = ?";
        List<OrdMain> ordMainList = namedParameterJdbcTemplateConvert.getJdbcOperations().query(sql, new Object[]{facilityCd}, new BeanPropertyRowMapper<>(OrdMain.class));
		String upd_ord_main_sql = "update ord_main set facility_name = (select facility_name from mst_facility  where facility_cd = ?) " +
                "where facility_cd = ? and rst_dialysis_state <> '0' and ord_no is null ";
        namedParameterJdbcTemplateConvert.getJdbcOperations().update(upd_ord_main_sql, facilityCd, facilityCd);
		//dw
        this.addDwInfo(facilityCd, ordMainList);
		// add 12380 コンバートされたデータで治療記録-治療条件-補液量が0で登録されることがある zkm start

		//mod #12229->12380 start
		// pat_main情報の取得
		String getPatSql = "SELECT pat_id, device_set_info FROM pat_main WHERE pat_id = :patId AND facility_cd = :facilityCd";
		Map<String, Object> params = Map.of(
				"patId", ordMainList.get(0).getPatId(),
				"facilityCd", facilityCd
		);

		PatMain patMain = namedParameterJdbcTemplateConvert.queryForObject(getPatSql, params, new BeanPropertyRowMapper<>(PatMain.class));
		Map<Long, String> patDeviceMap = new HashMap<>();

		if (patMain != null) {
			patDeviceMap.put(
					patMain.getPat_id(),
					patMain.getDevice_set_info()
			);
		}
		//mod #12229->12380 end

		List<OrdMain> updOrdMainIvAmountAndIvSpeedList = ordMainList.stream().filter(o ->
				("0".equals(o.getRstDialysisState()) || "6".equals(o.getRstDialysisState()))
						&& Objects.nonNull(o.getIndTreatmentCd())).toList();
		if (!CollectionUtils.isNullOrEmpty(updOrdMainIvAmountAndIvSpeedList)) {
			//mod #12229->12380 start
			updateOrdMainIvAmountAndIvSpeed(namedParameterJdbcTemplateConvert, updOrdMainIvAmountAndIvSpeedList, false,patDeviceMap);
			//mod #12229->12380 end
		}

		List<OrdMain> rstIvAmountAndIvSpeedList = ordMainList.stream().filter(o -> "6".equals(o.getRstDialysisState())
				&& Objects.nonNull(o.getRstTreatmentCd())).toList();
		if (!CollectionUtils.isNullOrEmpty(rstIvAmountAndIvSpeedList)) {
			if (!CollectionUtils.isNullOrEmpty(rstIvAmountAndIvSpeedList)) {
				rstIvAmountAndIvSpeedList.forEach(o -> {
					o.setIndTreatmentCd(o.getRstTreatmentCd());
					o.setIndCondInfo(o.getRstCondInfo());
				});
				//mod #12229->12380 start
				updateOrdMainIvAmountAndIvSpeed(namedParameterJdbcTemplateConvert, rstIvAmountAndIvSpeedList, true,patDeviceMap);
				//mod #12229->12380 end
			}
		}
		// add 12380 コンバートされたデータで治療記録-治療条件-補液量が0で登録されることがある zkm end
		//add #12309  【因島】「指示変更内容」の画面が表示できない　hyl start
		updateOrdMain();
		//add #12309  【因島】「指示変更内容」の画面が表示できない　hyl end
	}

	private void processPatTreatmentPattern(String fileName) throws Exception {
		String[] parts;
		if ("\\".equals(System.getProperty("file.separator"))) {
			parts = fileName.split("\\\\");
		} else {
			parts = fileName.split("/");
		}
		String patId = parts[parts.length - 2];
		String sql = "select \n" +
				"pat_id, ctl_no, ind_treatment_cd, ind_cond_info \n" +
				"from pat_treatment_pattern  " +
				"where pat_id = (select pat_id from pat_personal_main where facility_cd = ? and fn_pat_id = ?) " +
				"and facility_cd = ?";
		List<PatTreatmentPatternPatMain> patTreatmentPatterns = namedParameterJdbcTemplateConvert.getJdbcOperations().query(sql, new Object[]{facilityCd, patId, facilityCd}, new BeanPropertyRowMapper<>(PatTreatmentPatternPatMain.class));
		if (!CollectionUtils.isNullOrEmpty(patTreatmentPatterns)) {
			updatePatTreatmentPatternIvAmountAndIvSpeed(namedParameterJdbcTemplateConvert, patTreatmentPatterns);
		}
		//add #12309  【因島】「指示変更内容」の画面が表示できない　hyl start
		updatePatTreatmentPattern();
		//add #12309  【因島】「指示変更内容」の画面が表示できない　hyl end
	}

	private ProcessSQLAnnotationResult processSQLAnnotation(String fileName,T item) throws Exception {
		ProcessSQLAnnotationResult processSQLAnnotationResult = new ProcessSQLAnnotationResult();
		processSQLAnnotationResult.setBoolState(true);
		processSQLAnnotationResult.setContinue(false);
		String tableName = "";
		int firstLeftBracket = item.toString().indexOf("("); // 最初の左括弧の位置
		// mod ies5918 limingyang start
		//if (firstLeftBracket != -1) {
		if (firstLeftBracket != -1 && !item.toString().startsWith("UPDATE"))
		{
			// mod ies5918 limingyang end
			String beforeSubStr = item.toString().substring(0, firstLeftBracket);
			if (!beforeSubStr.isEmpty()) // 左括弧の左側に内容がある場合
			{
				int INTOIndex = beforeSubStr.lastIndexOf("INTO") + 4;
				String tableNameWithBlank = beforeSubStr.substring(INTOIndex, beforeSubStr.length());
				tableName = tableNameWithBlank.trim();
				processSQLAnnotationResult.setTableName(tableName);
				String SQL = "SELECT a.attname AS name FROM pg_class AS c,pg_attribute AS a WHERE c.relname = lower(?) AND a.attrelid = c.oid AND a.attnum>0";
				//";"を含むか否かを判断する
				String lastChar = item.toString().substring(item.toString().length() - 1);
				if (!tableName.equals("mst_selector") && !lastChar.equals(";")) {
					WriteSQLAnnotation wqa = new WriteSQLAnnotation();
					wqa.UpdateWriteSQLFile(fileName, item.toString());
					processSQLAnnotationResult.setContinue(true);
					return processSQLAnnotationResult;
				}
				beforeSubStr = beforeSubStr.toUpperCase().trim();
				//insertに"INSERT"が含まれているかを判断する
				String insertStr = beforeSubStr.substring(0, 6);
				if (!tableName.equals("mst_selector") && !insertStr.equals("INSERT")) {
					WriteSQLAnnotation wqa = new WriteSQLAnnotation();
					wqa.UpdateWriteSQLFile(fileName, item.toString());
					processSQLAnnotationResult.setContinue(true);
					return processSQLAnnotationResult;
				}
				//データテーブルの列名を取得します う　2020-12-30
				SqlRowSet sqlRowSet = jdbcTemplateConvert.queryForRowSet(SQL, tableName);
				//Insert列名を取得します う　2020-12-31
				int firstRightBracket = item.toString().indexOf(")");
				String fieldWithComma = item.toString().substring(firstLeftBracket + 1, firstRightBracket);
				String[] fieldNames = fieldWithComma.split(",");
				//Insert列名とデータテーブルの列名が同じかどうかをループで判断する う　2020-1-4
				List<String> list = new ArrayList<String>();
				if (null != sqlRowSet) {
					while (sqlRowSet.next()) {
						list.add(sqlRowSet.getString("name").trim());
					}
				}
				for (String name : fieldNames) {
					int columnIncolud = 0;
					String fieldName = name.trim();
					if (list.contains(fieldName)) {
						columnIncolud++;
					}
					//データテーブルの列名がInsert列名を含んでいない場合、現在の挿入が注釈される う　2020-1-4
					if (columnIncolud == 0) {
						WriteSQLAnnotation wqa = new WriteSQLAnnotation();
						wqa.UpdateWriteSQLFile(fileName, item.toString());
						processSQLAnnotationResult.setBoolState(false);
					}
					//フィールドタイプが一致するかどうかを判断する
				}
			}
		}
		return processSQLAnnotationResult;
	}

	static class ProcessSQLAnnotationResult {
		private String tableName;
		private boolean boolState;
		private boolean isContinue;

		public String getTableName() {
			return tableName;
		}

		public void setTableName(String tableName) {
			this.tableName = tableName;
		}

		public boolean isBoolState() {
			return boolState;
		}

		public void setBoolState(boolean boolState) {
			this.boolState = boolState;
		}

		public boolean isContinue() {
			return isContinue;
		}

		public void setContinue(boolean aContinue) {
			isContinue = aContinue;
		}
	}

    //add #12229  ord_weight_scale start
    private boolean  convertValOrdWeightScale(List<? extends T> items,GlobalContext globalContext){

        boolean isReturnCallerMethod = false;
        ObjectMapper objectMapper = new ObjectMapper();
        List<OrdWeightScale> ordWeightScaleList = items.stream()
                .map(item -> {
                    try {
                        if (item instanceof String) {
                            return objectMapper.readValue((String) item, OrdWeightScale.class);
                        } else {
                            return objectMapper.convertValue(item, OrdWeightScale.class);
                        }
                    } catch (Exception e) {
                        throw new RuntimeException("JSON変換に失敗しました: " + item, e);
                    }
                })
                .collect(Collectors.toList());

        if (ordWeightScaleList.isEmpty()) {
            isReturnCallerMethod = true;
            return isReturnCallerMethod;
        }
        masterDataService.loadIfNeeded(facilityCd,globalContext);

        try {
            DateTimeFormatter formatter =
                    DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss");

            String sql = "INSERT INTO ord_weight_scale (facility_cd,weight_cd,weight_name,measure_date,pat_id,scale_class,bed_cd,bed_name,kur_cd," +
                    "kur_name,machine_no,machine_name,treatment_cd,treatment_name,device_mode,weight_scale_status,scale_mode,target_weight_value," +
                    "scale_value,weight_value,off_water_limit,wheel_chair_weight,ord_no,wheel_chair_cd,wheel_chair_name,user_id,reg_date,up_date," +
                    "rst_off_water_info,rst_tare_info) " +
                    "VALUES(?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";

            jdbcTemplateConvert.batchUpdate(sql, ordWeightScaleList, 1000, (ps, entity) -> {
                ps.setObject(1, entity.getFacilityCd());
                ps.setObject(2, masterDataService.getWeightCd(entity.getWeightCd(),globalContext.weightCdMap));
                ps.setObject(3, entity.getWeightName());
                ps.setObject(4, LocalDateTime.parse(entity.getMeasureDate(), formatter));
                ps.setObject(5, masterDataService.getPatId(entity.getPatId(),globalContext.patIdMap));
                ps.setObject(6, entity.getScaleClass());
                ps.setObject(7, masterDataService.getBedCd(entity.getBedCd(),globalContext.bedCdMap));
                ps.setObject(8, entity.getBedName());
                ps.setObject(9, masterDataService.getKurCd(entity.getKurCd(),globalContext.kurCdMap));
                ps.setObject(10, entity.getKurName());
                ps.setObject(11, masterDataService.getMachineNo(entity.getMachineNo(),globalContext.machineNoMap));
                ps.setObject(12, entity.getMachineName());
                ps.setObject(13, masterDataService.getTreatmentCd(entity.getTreatmentCd(),globalContext.treatmentCdMap));
                ps.setObject(14, entity.getTreatmentName());
                ps.setObject(15, MasterDataService.parseToInteger(entity.getPatId(), entity.getDeviceMode()));
                ps.setObject(16, entity.getWeightScaleStatus());
                ps.setObject(17, entity.getScaleMode());
                ps.setObject(18, entity.getTargetWeightValue());
                ps.setObject(19, entity.getScaleValue());
                ps.setObject(20, entity.getWeightValue());
                ps.setObject(21, entity.getOffWaterLimit());
                ps.setObject(22, entity.getWheelChairWeight());
                ps.setObject(23, masterDataService.getOrdNo(entity.getOrdNo(),globalContext.ordNoMap));
                ps.setObject(24, masterDataService.getWheelChairCd(entity.getWheelChairCd(),globalContext.wheelChairCdMap));
                ps.setObject(25, entity.getWheelChairName());
                ps.setObject(26, masterDataService.getUserId(entity.getUserId(),globalContext.userIdMap));
                ps.setObject(27, LocalDateTime.parse(entity.getRegDate(), formatter));
                ps.setObject(28, LocalDateTime.parse(entity.getUpDate(), formatter));
                ps.setObject(29, entity.getRstOffWaterInfo() == null ? null : masterDataService.createJsonb(entity.getRstOffWaterInfo().toString()));
                ps.setObject(30, entity.getRstTareInfo() == null ? null : masterDataService.createJsonb(entity.getRstTareInfo().toString()));
            });

        } catch (Exception er) {
            //ログ
            EventLogMessage eventLogMessage10 = eventLoggerUtil.getEventLogMessage("「SQL失敗」:" + er.getMessage(),
                    facilityCd, "convertValOrdWeightScale");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage10, LogLevel.ERROR);
        }
        return isReturnCallerMethod;
    }
    //add #12229  ord_weight_scale end


	/**
	 * add #12229 start
	 * 指示履歴はmongodbに直接書き込む
	 */
	private boolean convertValHistory(String fileName,List<? extends T> items){
		boolean isReturnCallerMethod =  false;
		ObjectMapper objectMapper = new ObjectMapper();
		List<IndHistoryEntity> indHistoryEntityList = items.stream()
				.map(item -> {
					try {
						if (item instanceof String) {
							return objectMapper.readValue((String) item, IndHistoryEntity.class);
						} else {
							return objectMapper.convertValue(item, IndHistoryEntity.class);
						}
					} catch (Exception e) {
						throw new RuntimeException("JSON解析失敗: " + item, e);
					}
				})
				.collect(Collectors.toList());
		if(indHistoryEntityList.isEmpty()){
			isReturnCallerMethod = true;
			return isReturnCallerMethod;
		}
		// mod #9944 FNWで指示確認の確認をチェックしても、FNSiに反映されない 肖 start
		try {
			List<String> distinctPatIds = indHistoryEntityList.stream()
					.map(IndHistoryEntity::getPatId)
					.filter(patId -> patId != null && !patId.trim().isEmpty())
					.distinct()
					.collect(Collectors.toList());


			Map<String, Object> patIdToOrdNoMap;
			if (!distinctPatIds.isEmpty()) {

				String placeholders = distinctPatIds.stream()
						.map(ordNo -> "?")
						.collect(Collectors.joining(","));
				String sql = "select fn_pat_id,pat_id from pat_personal_main where facility_cd = ?  and fn_pat_id in (" + placeholders + ")";
				List<Object> params = new ArrayList<>();
				params.add(facilityCd);
				params.addAll(distinctPatIds);
				List<Map<String, Object>> resultList = jdbcTemplateNkk6.queryForList(sql, params.toArray());
				patIdToOrdNoMap = resultList.stream()
						.collect(Collectors.toMap(
								row -> (String) row.get("fn_pat_id"),
								row -> row.get("pat_id"),
								(existing, replacement) -> existing
						));
			} else {
				patIdToOrdNoMap = new HashMap<>();
			}
			String sql = "select fn_staff_cd,user_id from mst_personal_user where facility_cd = ? ";
			List<Object> params = new ArrayList<>();
			params.add(facilityCd);
			List<Map<String, Object>> userIdresultList = jdbcTemplateNkk6.queryForList(sql, params.toArray());
			Map<String, Object> userIdToMap = userIdresultList.stream()
					.collect(Collectors.toMap(
							row -> (String) row.get("fn_staff_cd"),
							row -> row.get("user_id"),
							(existing, replacement) -> existing
					));
			for (IndHistoryEntity entity : indHistoryEntityList) {

				String patId = entity.getPatId();
				Object patIdObj = (patId != null) ? patIdToOrdNoMap.get(patId) : null;
				entity.setPatId((patIdObj != null) ? patIdObj.toString() : "");
				//log_content
				entity.setLogContent(entity.getLogContent() != null ? entity.getLogContent().replace("<br>", System.lineSeparator()) : null);
				//created_user_id
				String createdUserId = entity.getCreatedUserId();
				Object createdUserIdObj = (createdUserId != null) ? userIdToMap.get(createdUserId) : null;
				entity.setCreatedUserId((createdUserIdObj != null) ? createdUserIdObj.toString() : "");

				//updated_user_id
				String updatedUserId = entity.getUpdatedUserId();
				Object updatedUserIdObj = (updatedUserId != null) ? userIdToMap.get(updatedUserId) : null;
				entity.setUpdatedUserId((updatedUserIdObj != null) ? updatedUserIdObj.toString() : "");

				//receiver_1
				String receiverUserId = entity.getReceiver1();
				Object receiverUserIdObj = (receiverUserId != null) ? userIdToMap.get(receiverUserId) : null;
				entity.setReceiver1((receiverUserIdObj != null) ? receiverUserIdObj.toString() : "");
				entity.setFacilityCd(facilityCd);


			}


			if (fileName.contains("diff")) {
				for (IndHistoryEntity entity : indHistoryEntityList) {
					ExecutableUpdateOperation.ExecutableUpdate<IndHistoryEntity> executableUpdate = mongoTemplate.update(IndHistoryEntity.class);
					Criteria criteria = Criteria.where("fn_confirm_id").is(entity.getFnConfirmId())
							.and("fn_mng_no").is(entity.getFnMngNo())
							.and("fn_category_cd").is(entity.getFnCategoryCd())
							.and("fn_category_sub_no").is(entity.getFnCategorySubNo())
							.and("facility_cd").is(entity.getFacilityCd())
							.and("pat_id").is(entity.getPatId());
					Query query = new Query(criteria);
					Update update = new Update()
							.set("pat_id", entity.getPatId())
							.set("facility_cd", entity.getFacilityCd())
							.set("treatment_start_date", entity.getTreatmentStartDate())
							.set("treatment_end_date", entity.getTreatmentEndDate())
							.set("treatment_weekday", entity.getTreatmentWeekday())
							.set("treatment_method", entity.getTreatmentMethod())
							.set("treatment_course", entity.getTreatmentCourse())
							.set("log_class", entity.getLogClass())
							.set("sort_no", entity.getSortNo())
							.set("log_content", entity.getLogContent())
							.set("created_by", entity.getCreatedBy())
							.set("updated_by", entity.getUpdatedBy())
							.set("created_user_id", entity.getCreatedUserId())
							.set("updated_user_id", entity.getUpdatedUserId())
							.set("_class", IndHistoryEntity.class.getName())
							.set("receiver_1", entity.getReceiver1())
							.set("receiver_1_name", entity.getReceiver1Name())
							.set("fn_confirm_id", entity.getFnConfirmId())
							.set("fn_mng_no", entity.getFnMngNo())
							.set("fn_category_cd", entity.getFnCategoryCd())
							.set("fn_category_sub_no", entity.getFnCategorySubNo());
					if (mongoTemplate.exists(query, IndHistoryEntity.class)) {
						executableUpdate.matching(query).apply(update).all();
					}else{
						mongoTemplate.insert(entity);
					}
				}
			}else {
				mongoTemplate.insertAll(indHistoryEntityList);
			}
			// mod #9944 FNWで指示確認の確認をチェックしても、FNSiに反映されない 肖 end
		} catch (Exception er) {
			//ログ
			EventLogMessage eventLogMessage10 = eventLoggerUtil.getEventLogMessage("「SQL文ミス」" + indHistoryEntityList.toString(),
					facilityCd, "JdbcBatchSqlItemWriter.write(final List<? extends T> items)");
			eventLoggerUtil.recordLog(facilityCd, eventLogMessage10, LogLevel.DEBUG);
		}
		// 一括插入mongodbの実行に成功したらsqlファイルを一括クリア
		WriteSQLAnnotation wqa = new WriteSQLAnnotation();
		wqa.fileNioWrite(fileName, "", false);
		return isReturnCallerMethod;
	}

	/**
	 * 実績履歴はmongodbに直接書き込む
	 */
	private boolean convertValueRsrHistory(List<? extends T> items,String fileName ){
		boolean isReturnCallerMethod =  false;
		ObjectMapper objectMapper = new ObjectMapper();
		List<RstHistoryEntity> rstHistoryEntityList = items.stream()
				.map(item -> {
					try {
						if (item instanceof String) {
							return objectMapper.readValue((String) item, RstHistoryEntity.class);
						} else {
							return objectMapper.convertValue(item, RstHistoryEntity.class);
						}
					} catch (Exception e) {
						throw new RuntimeException("JSON解析失敗: " + item, e);
					}
				})
				.collect(Collectors.toList());
		if(rstHistoryEntityList.isEmpty()){
			isReturnCallerMethod =  true;
			return isReturnCallerMethod;
		}
		try {
			//add #12229 start
			List<Integer> distinctOrdNos = rstHistoryEntityList.stream()
					.map(RstHistoryEntity::getOrd_no)
					.filter(ordNo -> ordNo != null && !ordNo.trim().isEmpty())
					.map(Integer::parseInt)
					.distinct()
					.collect(Collectors.toList());
			Map<Object, Object> rstNoToOrdNoMap=new HashMap<>();
			if(!distinctOrdNos.isEmpty()){

				String placeholders = distinctOrdNos.stream()
						.map(ordNo -> "?")
						.collect(Collectors.joining(","));
				String sql = "select rst_fn_dialysis_no,ord_no from ord_main where facility_cd = ?  and rst_fn_dialysis_no in ("+placeholders+")";
				List<Object> params = new ArrayList<>();
				params.add(facilityCd);
				params.addAll(distinctOrdNos);
				List<Map<String, Object>> resultList = jdbcTemplateNkk5.queryForList(sql, params.toArray());
				rstNoToOrdNoMap = resultList.stream()
						.collect(Collectors.toMap(
								row -> row.get("rst_fn_dialysis_no"),
								row -> row.get("ord_no"),
								(existing, replacement) -> existing
						));
			}

			Map<String, Object> userIdToOrdNoMap=new HashMap<>();
			List<String> distinctuserIds = rstHistoryEntityList.stream()
					.map(RstHistoryEntity::getUp_user_id)
					.filter(userId -> userId != null && !userId.trim().isEmpty())
					.distinct()
					.collect(Collectors.toList());
			if(!distinctuserIds.isEmpty()){

				String placeholdersuserId = distinctuserIds.stream()
						.map(userId -> "?")
						.collect(Collectors.joining(","));
				String sqlUserid ="select fn_staff_cd,user_id from mst_personal_user where facility_cd = ? and fn_staff_cd in ("+placeholdersuserId+")";

				List<Object> paramsUserId = new ArrayList<>();
				paramsUserId.add(facilityCd);
				paramsUserId.addAll(distinctuserIds);

				List<Map<String, Object>> resultListUserId = jdbcTemplateNkk6.queryForList(sqlUserid, paramsUserId.toArray());
				userIdToOrdNoMap = resultListUserId.stream()
						.collect(Collectors.toMap(
								row -> String.valueOf(row.get("fn_staff_cd")),
								row -> row.get("user_id"),
								(existing, replacement) -> existing
						));
			}

			List<String> userNames  = rstHistoryEntityList.stream()
					.map(RstHistoryEntity::getUp_user_name)
					.filter(userName -> userName != null && !userName.trim().isEmpty())
					.distinct()
					.collect(Collectors.toList());
			Map<String, String> userNamesMap=new HashMap<>();
			if(!userNames.isEmpty()){

				userNamesMap=batchDecryptWithValues(userNames,jdbcTemplateNkk6);
			}

			for (RstHistoryEntity entity : rstHistoryEntityList) {
				//  ord_no
				String rstNo = entity.getOrd_no();
				Object ordNoObj = null;
				if (rstNo != null && !rstNo.trim().isEmpty()) {
					try {
						Long rstNoLong = Long.valueOf(rstNo.trim());
						ordNoObj = rstNoToOrdNoMap.get(rstNoLong);
					} catch (NumberFormatException ignored) {
						continue;
					}
				}
				entity.setOrd_no(ordNoObj != null ? ordNoObj.toString() : "");

				//  up_user_id
				String fnUserId = entity.getUp_user_id();
				Object userIdObj = (fnUserId != null) ? userIdToOrdNoMap.get(fnUserId) : null;
				entity.setUp_user_id((userIdObj != null) ? userIdObj.toString() : "");

				//up_user_name
				String fnUserNmae = entity.getUp_user_name();
				Object UserNmaeObj = (fnUserId != null) ? userNamesMap.get(fnUserNmae) : null;
				entity.setUp_user_name((userIdObj != null) ? UserNmaeObj.toString() : "");
				String rstEditionValue = entity.getRst_edition();
				entity.setRst_edition((rstEditionValue != null && !rstEditionValue.isEmpty()) ? rstEditionValue : "0");
				entity.setFacilityCd(facilityCd);
			}
			//add #12229 end
			mongoTemplate.insertAll(rstHistoryEntityList);
		} catch (Exception er) {
			//ログ
			EventLogMessage eventLogMessage10 = eventLoggerUtil.getEventLogMessage("「SQL文ミス」" + rstHistoryEntityList.toString()+er.getMessage(),
					facilityCd, "JdbcBatchSqlItemWriter.write(convertValueRsrHistory)");
			eventLoggerUtil.recordLog(facilityCd, eventLogMessage10, LogLevel.ERROR);
		}
		//一括挿入mongodbの実行に成功したらsqlファイルを一括クリア
		WriteSQLAnnotation wqa = new WriteSQLAnnotation();
		wqa.fileNioWrite(fileName, "", false);
		return isReturnCallerMethod;
	}

	public Map<String, String> batchDecryptWithValues(List<String> encryptedUserNames,JdbcTemplate jdbcTemplate6 ) {

		StringBuilder valuesBuilder = new StringBuilder();
		List<String> namesList = new ArrayList<>(encryptedUserNames);

		for (int i = 0; i < namesList.size(); i++) {
			if (i > 0) valuesBuilder.append(",");
			valuesBuilder.append("(?)");
		}

		String sql = "SELECT t.encrypted_name, personal_info_encrypt(t.encrypted_name) as decrypted_name " +
				"FROM (VALUES " + valuesBuilder.toString() + ") AS t(encrypted_name)";

		Map<String, String> decryptionMap = new HashMap<>();
		jdbcTemplate6.query(sql, namesList.toArray(), (rs) -> {
			String encrypted = rs.getString("encrypted_name");
			String decrypted = rs.getString("decrypted_name");
			decryptionMap.put(encrypted, decrypted);
		});

		return decryptionMap;
	}
	//add #12229 end

	// add 12380 コンバートされたデータで治療記録-治療条件-補液量が0で登録されることがある zkm start
	private void updatePatTreatmentPatternIvAmountAndIvSpeed(NamedParameterJdbcTemplate convertJdbcTemplate,
															 List<PatTreatmentPatternPatMain> patTreatmentPatterns) {

		List<Integer> indTreatmentCds = patTreatmentPatterns.stream()
				.map(PatTreatmentPatternPatMain::getIndTreatmentCd)
				.distinct().toList();
		List<Integer> treatmentCds = getOnLineMstTreatmentCds(convertJdbcTemplate, indTreatmentCds);

		if (patTreatmentPatterns.isEmpty() || treatmentCds.isEmpty()) return;

		Map<Integer, List<PatTreatmentPatternPatMain>> groupByTreatment = new HashMap<>();
		for (PatTreatmentPatternPatMain p : patTreatmentPatterns) {
			if (!treatmentCds.contains(p.getIndTreatmentCd())) continue;
			groupByTreatment.computeIfAbsent(p.getIndTreatmentCd(), k -> new ArrayList<>()).add(p);
		}
		if (groupByTreatment.isEmpty()) return;

		String getPatSql = "SELECT pat_id, device_set_info FROM pat_main WHERE pat_id = :patId AND facility_cd = :facilityCd";
		Map<String, Object> params = Map.of(
				"patId", patTreatmentPatterns.get(0).getPatId(),
				"facilityCd", facilityCd
		);
		PatMain patMain = convertJdbcTemplate.queryForObject(
				getPatSql, params, new BeanPropertyRowMapper<>(PatMain.class)
		);
		String deviceSetInfo = patMain != null ? patMain.getDevice_set_info() : null;
		if (ObjectUtils.isEmpty(deviceSetInfo)) return;

		List<PatTreatmentPatternPatMain> updPatTreatmentPatterns = new ArrayList<>();

		for (List<PatTreatmentPatternPatMain> treatmentGroup : groupByTreatment.values()) {
			Map<String, List<PatTreatmentPatternPatMain>> groupByIndCondInfo = treatmentGroup.stream()
					.collect(Collectors.groupingBy(PatTreatmentPatternPatMain::getIndCondInfo));
			groupByIndCondInfo.forEach((indCondInfo, subList2) -> {
				boolean calFlag = false;
				JSONObject condInfoJson = new JSONObject(indCondInfo);
				if (condInfoJson.has(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode())) {
					String amountStr = condInfoJson.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode()).get("value").toString();
					if ("0.0".equals(amountStr)) {
						calFlag = true;
					}
				}
				if (!calFlag && condInfoJson.has(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode())) {
					String speedStr = condInfoJson.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode()).get("value").toString();
					if ("0.00".equals(speedStr)) {
						calFlag = true;
					}
				}
				if (calFlag) {
					JSONObject patDeviceSetInfoJSON = new JSONObject(deviceSetInfo);
					Map<String, String> ivAmountAndSpeedMap = calIvAmountAndIvSpeed(condInfoJson, patDeviceSetInfoJSON);
					if (!ObjectUtils.isEmpty(ivAmountAndSpeedMap)) {
						ivAmountAndSpeedMap.forEach((key, value) -> {
							JSONObject ivAmountAndSpeedJSON = condInfoJson.getJSONObject(key);
							if (!ObjectUtils.isEmpty(ivAmountAndSpeedJSON)) {
								ivAmountAndSpeedJSON.put("value", value);
							}
						});

						List<Long> ordNoList = subList2.stream().map(PatTreatmentPatternPatMain::getCtlNo).toList();
						updPatTreatmentPatterns.addAll(ordNoList.stream().map(o -> {
							PatTreatmentPatternPatMain ptpToUpd = new PatTreatmentPatternPatMain();
							ptpToUpd.setCtlNo(o);
							ptpToUpd.setPatId(subList2.get(0).getPatId());
							ptpToUpd.setIndCondInfo(condInfoJson.toString());
							return ptpToUpd;
						}).toList());
					}
				}
			});
		}
		if (!CollectionUtils.isNullOrEmpty(updPatTreatmentPatterns)) {
			String updateOrdMainIvAmountAndIvSpeedSql =
					"update pat_treatment_pattern set ind_cond_info = CAST(:indCondInfo AS jsonb) where ctl_no = :ctlNo and pat_id = :patId";
			convertJdbcTemplate.batchUpdate(updateOrdMainIvAmountAndIvSpeedSql, SqlParameterSourceUtils.createBatch(updPatTreatmentPatterns));
		}
	}

	private List<Integer> getOnLineMstTreatmentCds(NamedParameterJdbcTemplate convertJdbcTemplate, List<Integer> indTreatmentCds) {

		//mod #12229->12380 start
		if(globalContext.mstTreatmentSet.isEmpty()){

			String getTreatmentsql = """
			SELECT treatment_cd
			FROM mst_treatment
			WHERE facility_cd = :facilityCd
			  AND device_mode IN (7, 8)
        """;
			Map<String, Object> params = new HashMap<>();
			params.put("facilityCd", facilityCd);
			List<MstTreatment> mstTreatments = convertJdbcTemplate.query(getTreatmentsql, params, new BeanPropertyRowMapper<>(MstTreatment.class));
			globalContext.mstTreatmentSet = mstTreatments.stream()
					.map(MstTreatment::getTreatmentCd)
					.collect(Collectors.toSet());
		}
		return indTreatmentCds.stream()
				.filter(globalContext.mstTreatmentSet::contains)
				.distinct()
				.toList();
		//mod #12229->12380 end
	}

	private void updateOrdMainIvAmountAndIvSpeed(NamedParameterJdbcTemplate convertJdbcTemplate, List<OrdMain> ordMains, boolean isRst,Map<Long, String> patDeviceMap) {
		List<Integer> indTreatmentCds = ordMains.stream().map(OrdMain::getIndTreatmentCd).distinct().toList();
		List<Integer> treatmentCds = getOnLineMstTreatmentCds(convertJdbcTemplate, indTreatmentCds);

		if (ordMains.isEmpty() || treatmentCds.isEmpty()) return;

		Map<Integer, List<OrdMain>> groupByTreatment = new HashMap<>();
		for (OrdMain o : ordMains) {
			if (!treatmentCds.contains(o.getIndTreatmentCd())) continue;
			groupByTreatment.computeIfAbsent(o.getIndTreatmentCd(), k -> new ArrayList<>()).add(o);
		}
		if (groupByTreatment.isEmpty()) return;


		Map<Integer, String> bedComTypeMap;
		if (isRst) {
			Map<String, Object> getMachineParams = new HashMap<>();
			getMachineParams.put("facilityCd", facilityCd);
			List<Integer> bedCds = ordMains.stream().map(OrdMain::getRstBedCd).distinct().toList();
			getMachineParams.put("bedCds", bedCds);
			String getMachineSql = "select distinct MB.bed_cd, com_type from mst_bed MB inner join mst_machine MM" +
					" ON MB.machine_no = MM.machine_no and MM.facility_cd = MB.facility_cd" +
					" where MM.is_del = '0' and MB.bed_cd in (:bedCds) and MM.facility_cd = :facilityCd";
			bedComTypeMap = convertJdbcTemplate.query(getMachineSql,getMachineParams, rs -> {
				Map<Integer, String> map = new HashMap<>();
				while (rs.next()) {
					Integer bed = Integer.valueOf(rs.getString("bed_cd"));
					String type = rs.getString("com_type");
					map.putIfAbsent(bed, type);
				}
				return map;
			});
		} else {
			bedComTypeMap = new HashMap<>();
		}
		List<OrdMain> updOrdMains = new ArrayList<>();

		//add #12229->12380 start
		for (List<OrdMain> treatmentGroup : groupByTreatment.values()) {
			Map<String, List<OrdMain>> groupByIndCondInfo = treatmentGroup.stream()
					.collect(Collectors.groupingBy(OrdMain::getIndCondInfo));
			groupByIndCondInfo.forEach((indCondInfo, subList2) -> {
				boolean calFlag = false;
				JSONObject checkJson  = new JSONObject(indCondInfo);
				if (checkJson.has(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode())) {
					String amountStr = checkJson.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode()).get("value").toString();
					if ("0.0".equals(amountStr)) {
						calFlag = true;
					}
				}
				if (!calFlag && checkJson.has(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode())) {
					String speedStr = checkJson.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode()).get("value").toString();
					if ("0.00".equals(speedStr)) {
						calFlag = true;
					}
				}


				if (calFlag) {
					subList2.forEach(o -> {

					Long patId = o.getPatId();
					String deviceSetInfo = patDeviceMap.get(patId);
					if (ObjectUtils.isEmpty(deviceSetInfo)) return;

					JSONObject condInfoJson = new JSONObject(indCondInfo);

					JSONObject patDeviceSetInfoJSON = new JSONObject(deviceSetInfo);
					Map<String, String> ivAmountAndSpeedMap = calIvAmountAndIvSpeed(condInfoJson, patDeviceSetInfoJSON);
						// 実績の場合、補液計算優先項目を「濾過率から算出」に設定した時の補液速度と補液量を算出する
						if (isRst
								&& ivAmountAndSpeedMap != null
								&& "-1".equals(ivAmountAndSpeedMap.get(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode()))
								&& "-1".equals(ivAmountAndSpeedMap.get(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode()))
						) {

							Map<String, String> rstIvAmountAndSpeedMap = calByRstIvFlowSetting(patDeviceSetInfoJSON, o,
									null == bedComTypeMap || bedComTypeMap.containsKey(o.getRstBedCd()) ? null : bedComTypeMap.get(o.getRstBedCd()));
							if (!ObjectUtils.isEmpty(rstIvAmountAndSpeedMap)) {
								rstIvAmountAndSpeedMap.forEach((key, value) -> {
									JSONObject ivAmountAndSpeedJSON = condInfoJson.getJSONObject(key);
									if (!ObjectUtils.isEmpty(ivAmountAndSpeedJSON)) {
										ivAmountAndSpeedJSON.put("value", value);
									}
								});
								OrdMain omToUpd = new OrdMain();
								omToUpd.setConvertId(o.getConvertId());
								omToUpd.setIndCondInfo(condInfoJson.toString());
								updOrdMains.add(omToUpd);
							}
						} else {
						if (!ObjectUtils.isEmpty(ivAmountAndSpeedMap)) {
							ivAmountAndSpeedMap.forEach((key, value) -> {
								JSONObject ivAmountAndSpeedJSON = condInfoJson.getJSONObject(key);
								if (!ObjectUtils.isEmpty(ivAmountAndSpeedJSON)) {
									ivAmountAndSpeedJSON.put("value", value);
								}
							});

								OrdMain omToUpd = new OrdMain();
								omToUpd.setConvertId(o.getConvertId());
								omToUpd.setIndCondInfo(condInfoJson.toString());
								updOrdMains.add(omToUpd);
							}
						}
					});
				}
			});
		}
		//add #12229->12380 end
		if (!CollectionUtils.isNullOrEmpty(updOrdMains)) {
			String updateOrdMainIvAmountAndIvSpeedSql =
                    isRst ? "update ord_main set rst_cond_info = CAST(:indCondInfo AS jsonb) where convert_id = :convertId"
                            : "update ord_main set ind_cond_info = CAST(:indCondInfo AS jsonb) where convert_id = :convertId";
			convertJdbcTemplate.batchUpdate(updateOrdMainIvAmountAndIvSpeedSql, SqlParameterSourceUtils.createBatch(updOrdMains));
		}
	}

	/**
	 * @Description
	 * @Param
	 * [indCond（治療時間、血の流れです、補液量です、補液速度です）,
	 * patDeviceSetInfo (補液速度算出、補液量算出、補液比率算出、濾過率算出を個人設定します),
	 * deviceMode (OHF/OHDF),
	 * ordDeviceSetInfo(トラフィックテーブルに保存されたデバイスデータです),
	 * bodyDataIndCond(ページ編集項目です)]
	 * @return java.util.Map<java.lang.String,java.math.BigDecimal>
	 **/
	public Map<String, String> calIvAmountAndIvSpeed(JSONObject indCond, JSONObject patDeviceSetInfoJSON) {
		String liquidCalPriority = patDeviceSetInfoJSON.getJSONObject("ope").getJSONObject("dev")
				.getJSONObject("A").get("389").toString();
		String delayTimeStr = String.valueOf(patDeviceSetInfoJSON.getJSONObject("ope").getJSONObject("dev")
				.getJSONObject("A").get("398"));
		return switch (liquidCalPriority) {
			//補液速度を算出します
			case "0" -> calByIvSpeedSetting(indCond, delayTimeStr);
			// 補液量算出します
			case "1" -> {
				Map<String, String> resultMap = new HashMap<>();
				String amountStr = indCond.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode()).get("value").toString();
				BigDecimal ivAmount = !ObjectUtils.isEmpty(amountStr) &&
						(TreatmentItemsDef.isFloat(amountStr) || TreatmentItemsDef.isInteger(amountStr))
						? new BigDecimal(amountStr) : BigDecimal.ZERO;
				if (BigDecimal.ZERO.compareTo(ivAmount) == 0) {
					resultMap = calByIVAmountSetting(indCond, delayTimeStr);
				}
				yield resultMap;
			}
			// 補液率を算出します
			case "2" -> {
				// 補液選択
				String beforeIv = indCond.getJSONObject(TreatmentItemsDef.T_I_IV_SELECTION.getItemCode()).get("value").toString();
				String rateStr;
				if (BEFORE_IV.equals(beforeIv)) {
					rateStr = patDeviceSetInfoJSON.getJSONObject("ope").getJSONObject("dev").getJSONObject("A").get("379").toString();
				} else {
					rateStr = patDeviceSetInfoJSON.getJSONObject("ope").getJSONObject("dev").getJSONObject("B").get("39").toString();
				}
				rateStr = !ObjectUtils.isEmpty(rateStr)
						&& (TreatmentItemsDef.isFloat(rateStr) || TreatmentItemsDef.isInteger(rateStr))
						? rateStr : "0";
				yield calByIvRateSetting(indCond, delayTimeStr, rateStr);
			}
			// フィルター率を算出しました
			case "3" -> calByIvFlowSetting();
			default -> null;
		};
	}

	/**
	 * @Description  補液速度を算出します
	 * @Param [indCond, delayTimeStr]
	 * @return java.util.Map<java.lang.String,java.math.BigDecimal>
	 **/
	private Map<String,String> calByIvSpeedSetting(JSONObject indCond, String delayTimeStr) {

		if (indCond.isNull(TreatmentItemsDef.T_I_START_DATE.getItemCode())
				|| JSONObject.NULL.equals(indCond.getJSONObject(TreatmentItemsDef.T_I_START_DATE.getItemCode()).get("value")))
			return null;

		String amountStr = indCond.getJSONObject(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode()).get("value").toString();

		if ("-1".equals(amountStr)) {
			return new HashMap<>() {{
				put(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode(),
						TreatmentItemsDef.T_I_IV_AMOUNT.getFormattedValue(new BigDecimal("0")));
				put(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode(),
						TreatmentItemsDef.T_I_IV_FLOW_RATE.getFormattedValue(new BigDecimal("0")));
			}};
		}

		String treatTimeStr = indCond.getJSONObject(TreatmentItemsDef.T_I_START_DATE.getItemCode()).get("value").toString();

		BigDecimal ivAmount = !ObjectUtils.isEmpty(amountStr) &&
				(TreatmentItemsDef.isFloat(amountStr) || TreatmentItemsDef.isInteger(amountStr))
				? new BigDecimal(amountStr) : BigDecimal.ZERO;

		BigDecimal treatTime = !ObjectUtils.isEmpty(treatTimeStr) &&
				(TreatmentItemsDef.isFloat(treatTimeStr) || TreatmentItemsDef.isInteger(treatTimeStr))
				? new BigDecimal(treatTimeStr) : BigDecimal.ZERO;

		BigDecimal delayTime = !ObjectUtils.isEmpty(delayTimeStr) &&
				(TreatmentItemsDef.isFloat(delayTimeStr) || TreatmentItemsDef.isInteger(delayTimeStr))
				? new BigDecimal(delayTimeStr) : BigDecimal.ZERO;
		Map<String, String> resultMap = new HashMap<>();
		resultMap.put(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode(), ivAmount.toString());
		if (treatTime.compareTo(delayTime) > 0) {
			BigDecimal speed = ivAmount.multiply(new BigDecimal("60"))
					.divide(treatTime.subtract(delayTime)
							, 2, RoundingMode.CEILING);
			resultMap.put(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode(), speed.toString());
			return resultMap;
		}
		return resultMap;
	}

	/**
	 * @Description 補液量算出します
	 * @Param [indCond, delayTimeStr]
	 * @return java.util.Map<java.lang.String,java.math.BigDecimal>
	 **/
	private Map<String,String> calByIVAmountSetting(JSONObject indCond, String delayTimeStr) {
		if (indCond.isNull(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode())
				|| JSONObject.NULL.equals(
				indCond.getJSONObject(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode()).get("value"))
				|| indCond.isNull(TreatmentItemsDef.T_I_START_DATE.getItemCode())
				|| JSONObject.NULL.equals(indCond.getJSONObject(TreatmentItemsDef.T_I_START_DATE.getItemCode()).get("value")))
			return null;

		String speedStr = indCond.getJSONObject("24").get("value").toString();
		if ("-1".equals(speedStr)) {
			return new HashMap<>() {{
				put(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode(),
						TreatmentItemsDef.T_I_IV_AMOUNT.getFormattedValue(new BigDecimal("0")));
				put(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode(),
						TreatmentItemsDef.T_I_IV_FLOW_RATE.getFormattedValue(new BigDecimal("0")));
			}};
		}

		String treatTimeStr = indCond.getJSONObject(TreatmentItemsDef.T_I_START_DATE.getItemCode()).get("value").toString();

		BigDecimal speed = !ObjectUtils.isEmpty(speedStr)
				&& (TreatmentItemsDef.isFloat(speedStr) || TreatmentItemsDef.isInteger(speedStr))
				? new BigDecimal(speedStr) : BigDecimal.ZERO;

		BigDecimal treatTime = !ObjectUtils.isEmpty(treatTimeStr)
				&& (TreatmentItemsDef.isFloat(treatTimeStr) || TreatmentItemsDef.isInteger(treatTimeStr))
				? new BigDecimal(treatTimeStr) : BigDecimal.ZERO;

		BigDecimal delayTime = !ObjectUtils.isEmpty(delayTimeStr)
				&& (TreatmentItemsDef.isFloat(delayTimeStr) || TreatmentItemsDef.isInteger(delayTimeStr))
				? new BigDecimal(delayTimeStr) : BigDecimal.ZERO;
		Map<String, String> resultMap = new HashMap<>();
		resultMap.put(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode(), speed.toString());
		if (treatTime.compareTo(delayTime) > 0) {
			BigDecimal amount = speed.multiply(
					treatTime.subtract(delayTime)).divide(new BigDecimal("60"), 1, RoundingMode.DOWN);

			resultMap.put(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode(), amount.toString());
			return resultMap;
		}
		return resultMap;
	}

	//  前補液
	public final String BEFORE_IV = "1";

	/**
	 * @Description 補液率を算出します
	 * @Param [indCond, delayTimeStr, rateStr]
	 * @return java.util.Map<java.lang.String,java.lang.String>
	 **/
	private Map<String,String> calByIvRateSetting(JSONObject indCond, String delayTimeStr, String rateStr) {


		BigDecimal rate = new BigDecimal(rateStr);
		BigDecimal bloodFlowValue =
				JSONObject.NULL.equals(indCond.getJSONObject(TreatmentItemsDef.T_I_BLOOD_FLOW.getItemCode()).get("value")) ? BigDecimal.ZERO :
						new BigDecimal(String.valueOf(indCond.getJSONObject(TreatmentItemsDef.T_I_BLOOD_FLOW.getItemCode()).get("value")));

		BigDecimal speed = bloodFlowValue.multiply(rate)
				.multiply(new BigDecimal("60")).divide(new BigDecimal("100000"), 2, RoundingMode.CEILING);

		String treatTimeStr = indCond.getJSONObject(TreatmentItemsDef.T_I_START_DATE.getItemCode()).get("value").toString();

		BigDecimal delayTime = !ObjectUtils.isEmpty(delayTimeStr)
				&& (TreatmentItemsDef.isFloat(delayTimeStr) || TreatmentItemsDef.isInteger(delayTimeStr))
				? new BigDecimal(delayTimeStr) : BigDecimal.ZERO;

		BigDecimal treatTime = !ObjectUtils.isEmpty(treatTimeStr)
				&& (TreatmentItemsDef.isFloat(treatTimeStr) || TreatmentItemsDef.isInteger(treatTimeStr))
				? new BigDecimal(treatTimeStr) : BigDecimal.ZERO;
		Map<String, String> resultMap = new HashMap<>();
		resultMap.put(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode(), speed.toString());
		if (treatTime.compareTo(delayTime) > 0) {
			BigDecimal amount = speed.multiply(treatTime.subtract(delayTime))
					.divide(new BigDecimal("60"), 1, RoundingMode.DOWN);
			resultMap.put(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode(), amount.toString());
		}
		return resultMap;
	}

	/**
	 * @Description フィルター率を算出しました
	 * @return java.util.Map<java.lang.String,java.lang.String>
	 **/
	private Map<String,String> calByIvFlowSetting() {
		return new HashMap<>() {
			{
				put(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode(), "-1");
				put(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode(), "-1");
			}
		};
	}
	private Map<String,String> calByRstIvFlowSetting(JSONObject deviceSetInfo, OrdMain ordMain, String comType) {
		String delayTimeStr = String.valueOf(deviceSetInfo.getJSONObject("ope").getJSONObject("dev")
				.getJSONObject("A").get("398"));
		JSONObject condInfo = null == ordMain.getIndCondInfo() ? new JSONObject() :
				new JSONObject(ordMain.getIndCondInfo());
		double QB = 0d;
		double FF;
		double QUF;
		double DT = Double.parseDouble(delayTimeStr);

		String beforeIv = condInfo.getJSONObject(TreatmentItemsDef.T_I_IV_SELECTION.getItemCode()).get("value").toString();
		if ("1".equals(beforeIv)) {
			// "前補液"
			FF = Double.parseDouble(deviceSetInfo.getJSONObject("ope")
					.getJSONObject("dev")
					.getJSONObject("A").get("90").toString());
		} else {
			// "後補液"
			FF = Double.parseDouble(deviceSetInfo.getJSONObject("ope")
					.getJSONObject("dev")
					.getJSONObject("B").get("40").toString());
		}
		double Ht = Double.parseDouble(deviceSetInfo.getJSONObject("ope")
				.getJSONObject("dev")
				.getJSONObject("A").get("91").toString());
		double TP = Double.parseDouble(deviceSetInfo.getJSONObject("ope")
				.getJSONObject("dev")
				.getJSONObject("A").get("92").toString());

		if (condInfo.has(TreatmentItemsDef.T_I_BLOOD_FLOW.getItemCode()) && !condInfo.isNull(TreatmentItemsDef.T_I_BLOOD_FLOW.getItemCode())) {
			JSONObject condTimeJson = (JSONObject) condInfo.get(TreatmentItemsDef.T_I_BLOOD_FLOW.getItemCode());
			QB = condTimeJson.getDouble("value");
		}

		// 前体重
		String rstWeight = ordMain.getRstWeightInfo();
		rstWeight = null == rstWeight ? "{}" : rstWeight;
		JSONObject rstWeightInfoJson = new JSONObject(rstWeight);
		double weigheBefore = rstWeightInfoJson.isNull("weight_before") ? 0d : rstWeightInfoJson.optDouble("weight_before", 0d);

		// 目標体重
		double targetWeight = 0d;
		if (condInfo.has(TreatmentItemsDef.T_I_WEIGHT.getItemCode()) && !condInfo.isNull(TreatmentItemsDef.T_I_WEIGHT.getItemCode())) {
			JSONObject condTimeJson = (JSONObject) condInfo.get(TreatmentItemsDef.T_I_WEIGHT.getItemCode());
			targetWeight = condTimeJson.getDouble("value");
		}

		// 透析時間
		double condTime = 0d;
		if (condInfo.has(TreatmentItemsDef.T_I_START_DATE.getItemCode()) && !condInfo.isNull(TreatmentItemsDef.T_I_START_DATE.getItemCode())) {
			JSONObject condTimeJson = (JSONObject) condInfo.get(TreatmentItemsDef.T_I_START_DATE.getItemCode());
			condTime = condTimeJson.getDouble("value");
		}
		double dd = 0d;
		if (condInfo.has(TreatmentItemsDef.T_I_FILTER_LIMIT.getItemCode()) && !condInfo.isNull(TreatmentItemsDef.T_I_FILTER_LIMIT.getItemCode())) {
			JSONObject condTimeJson = (JSONObject) condInfo.get(TreatmentItemsDef.T_I_FILTER_LIMIT.getItemCode());
			dd = condTimeJson.getDouble("value");
		}
		JSONObject offWaterInfo = new JSONObject(ordMain.getRstOffWaterInfo());
		Integer offWaterInfoWeight1 = toWeight(offWaterInfo.get("weight_1").toString());
		Integer offWaterInfoWeight2 = toWeight(offWaterInfo.get("weight_2").toString());
		Integer offWaterInfoWeight3 = toWeight(offWaterInfo.get("weight_3").toString());
		Integer offWaterInfoWeight4 = toWeight(offWaterInfo.get("weight_4").toString());
		Integer offWaterInfoWeight5 = toWeight(offWaterInfo.get("weight_5").toString());
		int offWaterInfoWeightAmount = offWaterInfoWeight1 + offWaterInfoWeight2 + offWaterInfoWeight3 + offWaterInfoWeight4 + offWaterInfoWeight5;

		// 除水速度
		double ddRel = weigheBefore + Double.parseDouble(Integer.toString(offWaterInfoWeightAmount)) / 1000 - targetWeight;
		if (ddRel > dd) {
			QUF = dd / (condTime / 60);
		} else {
			QUF = ddRel / (condTime / 60);
		}
		QUF = Double.parseDouble(new BigDecimal(QUF).setScale(4, BigDecimal.ROUND_UP).toString());

		double QPW = ((100 - Ht) / 100) * (1 - (0.0107 * TP)) * QB;
		QPW = Double.parseDouble(new BigDecimal(QPW).setScale(1, BigDecimal.ROUND_DOWN).toString());

		// 医器工V3、V4：補液速度、補液量ともに0を展開する。
		if ("3".equals(comType)) {
			return new HashMap<>() {
				{
					put(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode(), "0");
					put(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode(), "0");
				}
			};
		} else {
			// 新通信、オフライン
			double value;
			String valueString = "0";
			String valueSaveString = "0";
			if ("1".equals(beforeIv)) {
				// "前補液"
				value = ((QPW * 60 / 1000 * FF / 100) - QUF) / (1 - (FF / 100));
			} else {
				// "後補液"
				value = (QPW * 60 / 1000 * FF / 100) - QUF;
			}
			String replenishMeasureString = "0";
			if (condInfo.has(TreatmentItemsDef.T_I_IV.getItemCode()) && !condInfo.isNull(TreatmentItemsDef.T_I_IV.getItemCode())) {
				BigDecimal valueDec = new BigDecimal(value);
				valueString = valueDec.setScale(4, BigDecimal.ROUND_UP).toString();
				valueSaveString = valueDec.setScale(2, BigDecimal.ROUND_UP).toString();
				double replenishMeasure = Double.parseDouble(valueString) * (condTime - DT) / 60;
				BigDecimal replenishMeasureDec = new BigDecimal(replenishMeasure);
				replenishMeasureString = replenishMeasureDec.setScale(1, BigDecimal.ROUND_DOWN).toString();
			}
			if (weigheBefore == 0) {
				replenishMeasureString = "0.0";
				valueSaveString = "0.00";
			}

			String finalReplenishMeasureString = replenishMeasureString;
			String finalValueSaveString = valueSaveString;
			return new HashMap<>() {
				{
					put(TreatmentItemsDef.T_I_IV_AMOUNT.getItemCode(), finalReplenishMeasureString);
					put(TreatmentItemsDef.T_I_IV_FLOW_RATE.getItemCode(), finalValueSaveString);
				}
			};
		}
	}
	private Integer toWeight(String weigh) {
		if ("null".equals(weigh)) {
			return 0;
		} else {
			return Integer.parseInt(weigh);
		}
	}

	// add 12380 コンバートされたデータで治療記録-治療条件-補液量が0で登録されることがある zkm end
	//add #12309  【因島】「指示変更内容」の画面が表示できない　hyl start
	private void updateOrdMain() {
		DataSource convert_dataSource = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
		NamedParameterJdbcTemplate convertJdbcTemplate = new NamedParameterJdbcTemplate(convert_dataSource);
		EventLogMessage eventLogMessage = new EventLogMessage();
		MapSqlParameterSource parameters = new MapSqlParameterSource()
				.addValue("facility_cd", facilityCd);
		try {

			StringBuilder insertOrdNo = new StringBuilder();
			insertOrdNo.append("""
                       update ord_main set ind_medi_info='[]' where ind_medi_info is null and facility_cd=:facility_cd and ind_cond_info is not null;
                       update ord_main set rst_medi_info='[]' where rst_medi_info is null and facility_cd=:facility_cd and rst_dialysis_state = '6' ;
                       update ord_main set ind_equip_info='[]' where ind_equip_info is null and facility_cd=:facility_cd and ind_cond_info is not null;
                       update ord_main set rst_equip_info='[]' where rst_equip_info is null and facility_cd=:facility_cd and rst_dialysis_state = '6' ;
                       update ord_main set ind_ind_comment_info='[]' where ind_ind_comment_info is null and facility_cd=:facility_cd and ind_cond_info is not null;
                       update ord_main set rst_ind_comment_info='[]' where rst_ind_comment_info is null and facility_cd=:facility_cd and rst_dialysis_state = '6' ;
               """);
			String upsql = insertOrdNo.toString();
			convertJdbcTemplate.update(upsql, parameters);

		} catch (Exception e) {
			// 異常処理
			eventLogMessage.setLogMessage("更新操作失败: " + e.getMessage());
			// ログ記録またはその他の処理を実施する
			System.err.println("Error in updateOrdMian: " + e.getMessage());
			eventLoggerUtil.recordLog(
					facilityCd,
					eventLoggerUtil.getEventLogMessage(
							"updateOrdMain()："  + EventLoggerUtil.excetionStackTraceToString(e),
							facilityCd,
							e.getClass().getName() + ".updateOrdMain()"),
					LogLevel.ERROR);
		}
	}
	private void updatePatTreatmentPattern() {
		DataSource convert_dataSource = (DataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
		NamedParameterJdbcTemplate convertJdbcTemplate = new NamedParameterJdbcTemplate(convert_dataSource);
		EventLogMessage eventLogMessage = new EventLogMessage();
		MapSqlParameterSource parameters = new MapSqlParameterSource()
				.addValue("facility_cd", facilityCd);
		try {

			StringBuilder insertpatId = new StringBuilder();
			insertpatId.append("""
					   update pat_treatment_pattern set ind_medi_info='[]' where ind_medi_info is null and facility_cd=:facility_cd and ind_cond_info is not null;
                       update pat_treatment_pattern set ind_equip_info='[]' where ind_equip_info is null and facility_cd=:facility_cd and ind_cond_info is not null;
                       update pat_treatment_pattern set ind_ind_comment_info='[]' where ind_ind_comment_info is null and facility_cd=:facility_cd and ind_cond_info is not null;
					  """);
			String upsql = insertpatId.toString();
			convertJdbcTemplate.update(upsql, parameters);

		} catch (Exception e) {
			// 異常処理
			eventLogMessage.setLogMessage("更新操作失败: " + e.getMessage());
			// ログ記録またはその他の処理を実施する
			System.err.println("Error in updatePatTreatmentPattern: " + e.getMessage());
			eventLoggerUtil.recordLog(
					facilityCd,
					eventLoggerUtil.getEventLogMessage(
							"updatePatTreatmentPattern()："  + EventLoggerUtil.excetionStackTraceToString(e),
							facilityCd,
							e.getClass().getName() + ".updatePatTreatmentPattern()"),
					LogLevel.ERROR);
		}
	}
	//add #12309  【因島】「指示変更内容」の画面が表示できない　hyl end
	// add #11096  zc start
	private void updateMstMachineRecordControl(String fileName ){
		EventLogMessage eventLogMessage = new EventLogMessage();
		MapSqlParameterSource parameters = new MapSqlParameterSource()
				.addValue("facility_cd", facilityCd);
		String delsql=null;
		try {
			//差分
			if(fileName.contains("diff")){
				delsql="DELETE FROM mst_machine_record_control WHERE" +
						" machine_record_cd NOT IN (" +
						"SELECT" +
						"  machine_record_cd " +
						" FROM mst_machine_record  ) " +
						" AND facility_cd = :facility_cd";
			}else{
				delsql="DELETE FROM mst_machine_record_control WHERE" +
						" machine_record_cd NOT IN (" +
						"SELECT" +
						"  rc.machine_record_cd " +
						" FROM mst_machine_record_control rc " +
						" INNER JOIN mst_machine_record rd ON rc.machine_record_cd = rd.machine_record_cd " +
						" WHERE" +
						" rc.facility_cd = :facility_cd  " +
						" AND rc.disp_flg != rd.disp_flg ) " +
						" AND facility_cd = :facility_cd";
			}
			int count = namedParameterJdbcTemplateConvert.update(delsql, parameters);
			//ログ
			eventLogMessage = eventLoggerUtil.getEventLogMessage(String.format("mst_machine_record_control削除成功%d件", count),
					facilityCd, "updateMstMachineRecordControl()");
			eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
		}catch (Exception e){
			//ログ
			eventLogMessage = eventLoggerUtil.getEventLogMessage("mst_machine_record_control削除に失敗しました！ " + e.getMessage(),
					facilityCd, "updateMstMachineRecordControl()");
			eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
		}
	}
	// add #11096  zc end
	// add #9448 mst_mainte_category.detail再設定 zkm start
	private void updMainteCategoryDetail() {
		// 日常・定期点検項目グループマスタの詳細設定する必要のレコード取得する
        String sql = "select convert_id,mainte_category_cd, fn_mainte_category_cd, fn_mainte_type from mst_mainte_category where facility_cd = ? and mainte_class = '2'";
        List<MstMainteCategory> mainteCategoryList = jdbcTemplateConvert.query(sql, new BeanPropertyRowMapper<>(MstMainteCategory.class), facilityCd);
		// 重複レコードの詳細情報が同じの原因で、FNW+で管理する施設内の一意なコードの中で、一つのみ取得して結構です。
		mainteCategoryList.forEach(category -> category.setFnMainteCategoryCd(category.getFnMainteCategoryCd().split(",")[0]));

		if (!CollectionUtils.isNullOrEmpty(mainteCategoryList)) {
			// 日常・定期点検項目マスタの定期点検情報を取得する
			String detailSql = "select mainte_detail_cd, fn_mainte_detail_cd, fn_mainte_type, mainte_content_1 as mainteContent1 from mst_mainte_detail where facility_cd = ? and mainte_class = '2' order by mainte_detail_cd";
			List<MstMainteDetail> mainteDetailList = jdbcTemplateConvert.query(detailSql, new BeanPropertyRowMapper<>(MstMainteDetail.class), facilityCd);
			// 取得した情報のFNW+で管理する施設内の一意なコードをリストに格納する
			mainteDetailList.forEach(d -> {
				List<String> fnDetailCds = Arrays.stream(d.getFnMainteDetailCd().split(",")).toList();
				d.setFnMainteDetailCdList(fnDetailCds);
			});

			if (!CollectionUtils.isNullOrEmpty(mainteDetailList)) {
				List<String> sortContents = Stream.of("任意付属品", "タイプ別装備").toList();
				record DetailJson(Long code, String isDisp, Long sortKey1, Long sortKey2) {}
				mainteCategoryList.forEach(category -> {
					List<DetailJson> detailJsonList = mainteDetailList.stream()
							.map(d -> {
								// 定期点検の場合、理由欄の項目が表示フラグ：1に設定する（理由の具体的な項目がSYNC_CONV_REASONに格納、fnwを取得する時、DEVICE_TYPE_CDが9999を一時設定する）
								String disp = "0";
								long sortKey1 = 0L;
								long sortKey2 = 0L;
								if ("1".equals(category.getFnMainteType()) && d.getFnMainteDetailCdList().stream().anyMatch(cd -> cd.startsWith("9999"))) {
									disp = "1";
									sortKey1 = 2L;
									sortKey2 = Long.parseLong(d.getFnMainteDetailCdList().get(0));
								}
								if (d.getFnMainteDetailCdList().stream().anyMatch(cd -> cd.startsWith(category.getFnMainteCategoryCd()))) {
									disp = d.getFnMainteType().equals(category.getFnMainteType()) ? "1" : "0";
									if ("1".equals(category.getFnMainteType()) && sortContents.contains(d.getMainteContent1())) {
										sortKey1 = 1L;
										sortKey2 = Long.parseLong(d.getFnMainteDetailCdList().stream().filter(cd -> cd.startsWith(category.getFnMainteCategoryCd())).toList().get(0));
									} else {
										sortKey1 = Long.parseLong(d.getFnMainteDetailCdList().stream().filter(cd -> cd.startsWith(category.getFnMainteCategoryCd())).toList().get(0));
									}
								}
								return new DetailJson(d.getMainteDetailCd(), disp, sortKey1, sortKey2);
							}).toList();
					List<DetailJson> dispDetail = detailJsonList.stream().filter(d -> "1".equals(d.isDisp)).sorted(Comparator.comparing(DetailJson::sortKey1).thenComparing(DetailJson::sortKey2)).toList();
					List<DetailJson> noDispDetail = detailJsonList.stream().filter(d -> "0".equals(d.isDisp)).sorted(Comparator.comparing(DetailJson::code)).toList();
					List<DetailJson> detailJsons = new ArrayList<>();
					detailJsons.addAll(dispDetail);
					detailJsons.addAll(noDispDetail);

					String jsonObjFormat = "{\"code\": %d, \"isDisp\": \"%s\", \"mainteClass\": \"2\"}";
					String jsonObjStr = detailJsons.stream().map(d -> jsonObjFormat.formatted(d.code, d.isDisp))
							.collect(Collectors.joining(", "));
					String jsonArray = "[%s]".formatted(jsonObjStr);
					// SQL Injection protection: use parameterized query for JSON array
                    String updSql = "UPDATE mst_mainte_category a SET detail = ?::jsonb where a.facility_cd = ? AND convert_id = ?";
                    jdbcTemplateConvert.update(updSql, jsonArray, facilityCd, category.getConvertId());
				});
			}
		}
	}
	// add #9448 mst_mainte_category.detail再設定 zkm end

	// add #10870 mnt_mainte_main.detail再設定 zkm start
	private void updMainteMainDetail() {
		// 点検結果マスタの詳細設定する必要のレコード取得する
        String sql = "select convert_id, mainte_no, mainte_layout_cd, up_date from mnt_mainte_main where facility_cd = ? and mainte_class = '2' and detail = '[[],[]]'";
        List<MntMainteMain> mainteMainList = jdbcTemplateConvert.query(sql, new BeanPropertyRowMapper<>(MntMainteMain.class), facilityCd);
		List<String> sortContents = Stream.of("任意付属品", "タイプ別装備").toList();
		mainteMainList.forEach(main -> {
			// 日常・定期点検項目マスタの定期点検情報を取得する
			String detailSql = """
					SELECT
						mainte_detail_cd,
						fn_mainte_type,
						replace(ini_text, chr(10), '\\n') as ini_text,
						fn_mainte_detail_cd,
						mainte_content_1 as mainteContent1
					FROM
						mst_mainte_detail
					WHERE
						mainte_class = '2'
						AND mainte_detail_cd IN (
						SELECT
							to_number( detail_element ->> 'code', '99999999' ) AS key_value
						FROM
							mst_mainte_category,
							LATERAL jsonb_array_elements ( detail ) AS detail_element
						WHERE
							facility_cd = ?
							AND detail_element->>'isDisp' = '1'
							AND mainte_category_cd IN (
							SELECT
								to_number( jsonb_element ->> 'cd', '99999999' ) AS key_value
							FROM
								mst_mainte_layout,
								LATERAL jsonb_array_elements ( detail_info_1 || detail_info_2 ) AS jsonb_element
							WHERE
								facility_cd = ?
								AND mainte_layout_cd = ?
								AND jsonb_element->>'isDisp' = 'true'
							)
						)
					""";
            List<MstMainteDetail> details = jdbcTemplateConvert.query(detailSql, new BeanPropertyRowMapper<>(MstMainteDetail.class), facilityCd, facilityCd, main.getMainteLayoutCd());
			// 取得した情報のFNW+で管理する施設内の一意なコードをリストに格納する
			details.forEach(d -> {
				List<String> fnDetailCds = Arrays.stream(d.getFnMainteDetailCd().split(",")).toList();
				d.setFnMainteDetailCdList(fnDetailCds);
			});
			String categorySql = """
					SELECT
						fn_mainte_type,
						mainte_category_cd
					FROM
						mst_mainte_category
					WHERE
						facility_cd = ?
						AND mainte_category_cd IN (
						SELECT
							to_number( jsonb_element->>'cd', '99999999' ) AS key_value
						FROM
							mst_mainte_layout,
							LATERAL jsonb_array_elements ( detail_info_1 || detail_info_2 ) AS jsonb_element
						WHERE
							facility_cd = ?
							AND mainte_layout_cd = ?
						AND jsonb_element->>'isDisp' = 'true'
						)
					""";
			List<MstMainteCategory> categoryList = jdbcTemplateConvert.query(categorySql, new BeanPropertyRowMapper<>(MstMainteCategory.class), facilityCd, facilityCd, main.getMainteLayoutCd());
			Map<String, List<MstMainteCategory>> categoryMapByMainteTypeMap = categoryList.stream().collect(Collectors.groupingBy(MstMainteCategory::getFnMainteType));

			record DetailModel (String date, long cate_cd, String comment, long detail_cd, int tableIndex, int sortKey1, int sortKey2) {}
			AtomicInteger i = new AtomicInteger(10);
			List<DetailModel> detailModels = details.stream().map(d -> {
				int sortKey1 = 0;
				int sortKey2 = 0;
				i.addAndGet(1);
				sortKey1 = i.get();
				if ("1".equals(d.getFnMainteType())) {
					if (d.getFnMainteDetailCdList().stream().anyMatch(cd -> cd.startsWith("9999"))) {
						sortKey1 = 2;
						sortKey2 = i.get();
					}
					if (sortContents.contains(d.getMainteContent1())) {
						sortKey1 = 1;
						sortKey2 = i.get();
					}
				}
				return new DetailModel(
						new SimpleDateFormat("yyyy-MM-dd").format(main.getUpDate()),
						categoryMapByMainteTypeMap.get(d.getFnMainteType()).get(0).getMainteCategoryCd(),
						d.getIniText(),
						d.getMainteDetailCd(),
						Integer.parseInt(d.getFnMainteType()),
						sortKey1,
						sortKey2
				);
			}).toList();
			Map<Integer, List<DetailModel>> detailMap = detailModels.stream()
					.sorted(Comparator.comparing(DetailModel::tableIndex)
							.thenComparing(DetailModel::sortKey1)
							.thenComparing(DetailModel::sortKey2))
					.collect(Collectors.groupingBy(DetailModel::tableIndex));
			List<String> jsonStrList = new ArrayList<>(detailMap.values().stream().map(sublist -> {
				String jsonObjFormat = "{\"date\": \"%s\", \"judge\": \"\", \"cate_cd\": %d, \"comment\": \"%s\", \"edition\": 1, \"cate_edi\": 1, \"detail_cd\": %d, \"tableIndex\": %d}";
				String jsonObjStr = sublist.stream().map(d -> jsonObjFormat.formatted(d.date, d.cate_cd, d.comment, d.detail_cd, d.tableIndex))
						.collect(Collectors.joining(", "));
				return "[%s]".formatted(jsonObjStr);
			}).toList());
			if (!CollectionUtils.isNullOrEmpty(jsonStrList)) {
				if (jsonStrList.size() == 1) {
					if (detailMap.containsKey(1)) {
						jsonStrList.add("[]");
					} else {
						jsonStrList.add(0, "[]");
					}
				}
				String jsonArray = "[%s]".formatted(String.join(",", jsonStrList));
				// SQL Injection protection: use parameterized query for JSON array
                String updSql = "UPDATE mnt_mainte_main a SET detail = ?::jsonb where a.facility_cd = ? AND convert_id = ?";
                jdbcTemplateConvert.update(updSql, jsonArray, facilityCd, main.getConvertId());
			}
		});

	}
	// add #10870 mnt_mainte_main.detail再設定 zkm end

	// add #10969 zc start
	private void updateOrdPersonalPrescription() {
		EventLogMessage eventLogMessage = new EventLogMessage();
		MapSqlParameterSource parameters = new MapSqlParameterSource()
				.addValue("facility_cd", facilityCd);
		try {
			// SQL
			String update_ord_personal_prescription = """
                WITH A AS (
                     SELECT
                        pat_id,
                        jsonb_set (
                            jsonb_set (
                                jsonb_set ( jsonb_set ( insu_info, '{insu_class}', '"0"' :: JSONB, TRUE ), '{insu_cd}', to_jsonb ( insurance_cd :: TEXT ), TRUE ),
                                '{insu_info_name}',
                            ( CASE WHEN insu_name IS NULL THEN 'null' :: JSONB ELSE to_jsonb ( insu_name ) END ) :: JSONB,
                    TRUE
                    ),
                    '{insu_info_name_short}',
                    ( CASE WHEN insu_name_short IS NULL THEN 'null' :: JSONB ELSE to_jsonb ( insu_name_short ) END ) :: JSONB,
                TRUE
                    ) AS info
					 FROM    
						 pat_insurance
                WHERE
                    insu_class = 0
                    AND facility_cd = :facility_cd 
                    ),
                    BB AS (
                    SELECT
                        pat_id,
                        jsonb_set (
                            jsonb_set (
                                jsonb_set ( jsonb_set ( insu_pub_info, '{insu_class}', '"1"' :: JSONB, TRUE ), '{insu_pub1_cd}', to_jsonb ( insurance_cd :: TEXT ), TRUE ),
                                '{insu_pub1_info_name}',
                            ( CASE WHEN insu_name IS NULL THEN 'null' :: JSONB ELSE to_jsonb ( insu_name ) END ) :: JSONB,
                    TRUE
                    ),
                    '{insu_pub1_info_name_short}',
                    ( CASE WHEN insu_name_short IS NULL THEN 'null' :: JSONB ELSE to_jsonb ( insu_name_short ) END ) :: JSONB,
                TRUE
                    ) AS info
                FROM
                    pat_insurance
                WHERE
                    insu_class = 1
                    AND facility_cd = :facility_cd 
                    AND fn_ctl_no = '2'
                    ),
                    B AS (
                    SELECT
                        pat_id,
                        jsonb_build_object (
                            'insu_class',
                            info -> 'insu_class',
                            'insu_pub1_cd',
                            info -> 'insu_pub1_cd',
                            'insu_pub1_info_name',
                            info -> 'insu_pub1_info_name',
                            'insu_pub1_info_name_short',
                            info -> 'insu_pub1_info_name_short',
                            'insu_pub1_no',
                            info -> 'insu_pub_no',
                            'insu_pub1_passbook_no',
                            info -> 'passbook_no',
                            'insu_pub1_name',
                            info -> 'insu_pub_name',
                            'insu_pub1_pat_no',
                            info -> 'insu_pub_pat_no'
                        ) AS info
                    FROM
                        BB
                    ),
                    CC AS (
                    SELECT
                        pat_id,
                        jsonb_set (
                            jsonb_set (
                                jsonb_set ( jsonb_set ( insu_pub_info, '{insu_class}', '"1"' :: JSONB, TRUE ), '{insu_pub2_cd}', to_jsonb ( insurance_cd :: TEXT ), TRUE ),
                                '{insu_pub2_info_name}',
                            ( CASE WHEN insu_name IS NULL THEN 'null' :: JSONB ELSE to_jsonb ( insu_name ) END ) :: JSONB,
                    TRUE
                    ),
                    '{insu_pub2_info_name_short}',
                    ( CASE WHEN insu_name_short IS NULL THEN 'null' :: JSONB ELSE to_jsonb ( insu_name_short ) END ) :: JSONB,
                TRUE
                    ) AS info
                FROM
                    pat_insurance
                WHERE
                    insu_class = 1
                    AND facility_cd = :facility_cd 
                    AND fn_ctl_no = '3'
                    ),
                    C AS (
                    SELECT
                        pat_id,
                        jsonb_build_object (
                            'insu_class',
                            info -> 'insu_class',
                            'insu_pub2_cd',
                            info -> 'insu_pub2_cd',
                            'insu_pub2_info_name',
                            info -> 'insu_pub2_info_name',
                            'insu_pub2_info_name_short',
                            info -> 'insu_pub2_info_name_short',
                            'insu_pub2_no',
                            info -> 'insu_pub_no',
                            'insu_pub2_passbook_no',
                            info -> 'passbook_no',
                            'insu_pub2_name',
                            info -> 'insu_pub_name',
                            'insu_pub2_pat_no',
                            info -> 'insu_pub_pat_no'
                        ) AS info
                    FROM
                        CC
                    ),
                    D AS ( SELECT A.* FROM A UNION ALL SELECT B.* FROM B UNION ALL SELECT C.* FROM C ),
                    E AS ( SELECT pat_id, jsonb_agg ( info ) AS info_array FROM D GROUP BY pat_id) 
                    UPDATE ord_personal_prescription
                    SET insu_set_info = E.info_array
                FROM
                    E
                WHERE
                    ord_personal_prescription.pat_id = E.pat_id
                    AND  ord_personal_prescription.facility_cd = :facility_cd
                """;
			int count = namedParameterJdbcTemplateConvert.update(update_ord_personal_prescription, parameters);
			//ログ
			eventLogMessage = eventLoggerUtil.getEventLogMessage(String.format("ord_personal_prescription.insu_set_info更新成功%d件", count),
					facilityCd, "updatePatInsuranceHistory()");
			eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.INFO);
		}catch (Exception e){
			//ログ
			eventLogMessage = eventLoggerUtil.getEventLogMessage("ord_personal_prescription.insu_set_info更新に失敗しました！ " + e.getMessage(),
					facilityCd, "updatePatInsuranceHistory()");
			eventLoggerUtil.recordLog(facilityCd, eventLogMessage, LogLevel.ERROR);
		}
	}
	// add #10969 zc end

	/**
	 * ord_main add DW
	 *
	 * @param facilityCd
	 * @param ordMainList
	 * @throws Exception
	 */
	private void addDwInfo(String facilityCd, List<OrdMain> ordMainList) throws Exception {
		List<Long> patIdList = ordMainList.stream().map(OrdMain::getPatId).distinct().collect(Collectors.toList());
		if (CollectionUtils.isNullOrEmpty(patIdList)) {
			return;
		}
		HikariDataSource convert_ds = (HikariDataSource) appContext.getBean(ApplicationConst.DbType.CONVERT);
		NamedParameterJdbcTemplate jdbcTemplate_convert = new NamedParameterJdbcTemplate(convert_ds);
        String queryOMPart = "select convert_id ,ord_no, pat_id, treat_date from ord_main " +
				"where facility_cd = :facilityCd and pat_id in (:patIds) and ind_dw is null " +
				"and ind_cond_info <> '[]' and ind_cond_info is not null;";
		Map<String, Object> omPartCond = new HashMap<>();
		omPartCond.put("facilityCd", facilityCd);
		omPartCond.put("patIds", patIdList);
		List<Map<String, Object>> ordMainPartList = jdbcTemplate_convert.queryForList(queryOMPart, new MapSqlParameterSource(omPartCond));
		String updOmDw = "update ord_main" +
				" set ind_dw = :indDw" +
                " where convert_id = :convertId";
		List<OrdMain> ordMainToUpdate = new LinkedList<>();
		if (!CollectionUtils.isNullOrEmpty(ordMainPartList)) {
			String queryDw = "SELECT info->>'dw' FROM pat_unique CROSS JOIN LATERAL json_array_elements (physical_info :: json) info "
					+ "where info->>'inspect_date' <= :treatDate "
					+ "and pat_id = :patId "
					+ "and facility_cd = :facilityCd "
					+ "and info->>'dw' is not null  "
					+ "ORDER BY  info->>'inspect_date' DESC LIMIT 1";
			Map<String, Object> dwCond = new HashMap<>();
			dwCond.put("facilityCd", facilityCd);
			for (Map<String, Object> ordMainPart : ordMainPartList) {
				dwCond.put("patId", ordMainPart.get("pat_id"));
				dwCond.put("treatDate", ordMainPart.get("treat_date"));
				List<String> dwList = jdbcTemplate_convert.queryForList(queryDw, dwCond, String.class);
				if (!CollectionUtils.isNullOrEmpty(dwList)
						&& !org.springframework.util.ObjectUtils.isEmpty(dwList.get(0))) {
					OrdMain omToUpd = new OrdMain();
                    omToUpd.setConvertId(Long.getLong(String.valueOf(ordMainPart.get("convert_id"))));
					omToUpd.setIndDw(new BigDecimal(dwList.get(0)));
					ordMainToUpdate.add(omToUpd);
				}
			}
			if (!CollectionUtils.isNullOrEmpty(ordMainToUpdate)) {
				jdbcTemplate_convert.batchUpdate(updOmDw, SqlParameterSourceUtils.createBatch(ordMainToUpdate));
			}
		}
	}

	// add #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe start
	/**
	 * mst_comsv_setting update device_edge_no
	 *
	 * @param bDiff true: 差分コンバート false: コンバート
	 * @return insertKeys
	 */
	private String updateMstComsvSettingDeviceEdgeNo(boolean bDiff) throws Exception{
		String sqlNewKeys = "";
        String comsv_setting_sql = "select convert_id,fn_comsv_no,device_edge_no from mst_comsv_setting where facility_cd = ? order by " + (bDiff ? "convert_id" : "device_edge_no");
        List<Map<String, Object>> comsv_setting_info = namedParameterJdbcTemplate.getJdbcOperations().queryForList(comsv_setting_sql, new Object[]{facilityCd});
        List<Integer> setting_convert_id = comsv_setting_info.stream().filter(info -> info.get("fn_comsv_no") != null).map(info -> Integer.parseInt(info.get("convert_id").toString())).collect(Collectors.toList());
        if (setting_convert_id != null && !setting_convert_id.isEmpty()) {
			String upd_device_edge_no_sql = "select device_edge_no, is_del  from mst_device_edge where facility_cd = ? order by device_edge_no ";
            List<Map<String, Object>> maMap = namedParameterJdbcTemplate.getJdbcOperations().queryForList(upd_device_edge_no_sql, new Object[]{facilityCd});
			Integer max = maMap.stream().map(m -> Integer.parseInt(m.get("device_edge_no").toString())).max(Comparator.naturalOrder()).orElse(0) + 1;

			List<Integer> edgeNos = maMap.stream().filter(m -> m.get("is_del").equals("0")).map(m -> Integer.parseInt(m.get("device_edge_no").toString())).collect(Collectors.toList());
			TableNameToDbType tableNameToDbType = new TableNameToDbType(appContext);
			String registDbType = tableNameToDbType.getDbTypeByTableName("mst_comsv_setting");
			DataSource dbDs = (DataSource) appContext.getBean(registDbType);
			JdbcTemplate dbJdbc = new JdbcTemplate(dbDs);
			String used_device_edge_no_sql = "select device_edge_no from mst_comsv_setting where facility_cd = ? and is_del = '0'";
            List<Integer> usedNos = dbJdbc.queryForList(used_device_edge_no_sql, Integer.class, facilityCd);
            if (!globalContext.convertComsvList.isEmpty()) {
				List<Integer> convertUsedNos = new ArrayList<>();
                for (String key : globalContext.convertComsvList) {
					String[] keyArr = key.split(",");
					if(keyArr.length > 1){
						convertUsedNos.add(Integer.parseInt(keyArr[0]));
					}
				}
				usedNos.removeAll(convertUsedNos);
			}
			edgeNos.removeAll(usedNos);

            int sizeNmu = setting_convert_id.size() > edgeNos.size() ? setting_convert_id.size() : edgeNos.size();
            for (int i = 0; i < sizeNmu; i++) {
                if (i >= setting_convert_id.size()) {
                    String insertSql = "INSERT INTO mst_comsv_setting (device_edge_no, facility_cd, is_timeset, timeset_time, is_timeset_nx, timeset_nx_time, lcd_log_time, lcd_log_type, is_lcd_medi, end_wait_time, pat_timing, is_notice, notice_time, log_upload_time, lcd_menu, lcd_npat, lcd_report, lcd_graph1, lcd_graph2, lcd_radar, lcd_staff_list, is_disp, is_del, reg_date, up_date, offline_start_time, is_offline_auto_end, reload_next_pat_time, next_pat_mode, next_pat_mode_range, device_timeout, treat_moni_interval, other_moni_interval, is_notice_medi, treat_realtime_monito_interval, other_realtime_monito_interval, lcd_medi_time, fn_comsv_no ) " +
                            "(select ?, facility_cd, is_timeset, timeset_time, is_timeset_nx, timeset_nx_time, lcd_log_time, lcd_log_type, is_lcd_medi, end_wait_time, pat_timing, is_notice, notice_time, log_upload_time, lcd_menu, lcd_npat, lcd_report, lcd_graph1, lcd_graph2, lcd_radar, lcd_staff_list, is_disp, is_del, reg_date, up_date, offline_start_time, is_offline_auto_end, reload_next_pat_time, next_pat_mode, next_pat_mode_range, device_timeout, treat_moni_interval, other_moni_interval, is_notice_medi, treat_realtime_monito_interval, other_realtime_monito_interval, lcd_medi_time, fn_comsv_no  " +
                            "from mst_comsv_setting where facility_cd = ? and convert_id = ?)";
                    namedParameterJdbcTemplate.getJdbcOperations().update(insertSql, edgeNos.get(i), facilityCd, setting_convert_id.get(0));
                    sqlNewKeys += edgeNos.get(i) + ",";
                } else if (i >= edgeNos.size()) {
                    String updateSql = "update mst_comsv_setting set device_edge_no = ? where facility_cd = ? and convert_id = ?";
                    namedParameterJdbcTemplate.getJdbcOperations().update(updateSql, max, facilityCd, setting_convert_id.get(i));
                    max++;
                } else {
                    String updateSql = "update mst_comsv_setting set device_edge_no = ? where facility_cd = ? and convert_id = ?";
                    namedParameterJdbcTemplate.getJdbcOperations().update(updateSql, edgeNos.get(i), facilityCd, setting_convert_id.get(i));
                }
            }
        }
        String comsv_setting_sql_end = "select device_edge_no,fn_comsv_no from mst_comsv_setting where facility_cd= ? order by " + (bDiff ? "convert_id" : "device_edge_no");
        List<Map<String, Object>> comsv_setting_info_end = namedParameterJdbcTemplate.getJdbcOperations().queryForList(comsv_setting_sql_end, new Object[]{facilityCd});
        List<String> convertComsvList = new ArrayList<>();
        for (Map<String, Object> map : comsv_setting_info_end) {
            convertComsvList.add(String.valueOf(map.get("device_edge_no")) + "," + String.valueOf(map.get("fn_comsv_no")));
        }
        globalContext.convertComsvList = convertComsvList;
		return sqlNewKeys;
	}

	/**
	 * updateProdDefaultValueSet for mst_comsv_setting.comsv_cd(int8) and mst_weight.weight_no(int2)
	 * @param jdbcTemplate
	 * @param tableName		mst_comsv_setting、mst_weight
	 * @param UniqueName	comsv_cd、weight_no
	 * @param UniqueKey
	 * @param columnNameList
	 * @throws Exception
	 */
    private void updateProdDefaultValueSet(String tableName, String UniqueName, String UniqueKey, List<String> columnNameList) {
		StringBuilder sb = new StringBuilder();
		sb.append(" select " + UniqueName); // comsv_cd(int8) or weight_no(int2)
		for(String colName : columnNameList){
			sb.append(", ");
			sb.append(colName);
		}
        sb.append(" from " + tableName + " where facility_cd = '" + facilityCd + "' and " + UniqueName + " in (" + UniqueKey + ")");
        List<Map<String, Object>> maMap = jdbcTemplateNkk5.queryForList(sb.toString());
		for(Map<String, Object> m : maMap){
			StringBuilder defUpdStrBuil = new StringBuilder();
			defUpdStrBuil.append("update " + tableName + " set ");
			for(int i = 0; i < columnNameList.size(); i++){
				if(i != 0) defUpdStrBuil.append(", ");
				if(m.get(columnNameList.get(i)).toString().contains("{")){
					defUpdStrBuil.append(columnNameList.get(i) + " = '" + m.get(columnNameList.get(i)).toString() + "'::JSONB");
				}
				else if (m.get(columnNameList.get(i)).getClass().equals(String.class)) {
					defUpdStrBuil.append(columnNameList.get(i) + " = '" + m.get(columnNameList.get(i)).toString() + "'");
				}
				else {
					defUpdStrBuil.append(columnNameList.get(i) + " = " + m.get(columnNameList.get(i)).toString());
				}
			}
			defUpdStrBuil.append(" where facility_cd = '" + facilityCd +"' and " + UniqueName + " = " + m.get(UniqueName).toString());
			jdbcTemplateConvert.execute(defUpdStrBuil.toString());
		}
	}
	// add #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe end

}
