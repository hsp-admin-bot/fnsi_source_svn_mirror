package batch.part;

import batch.ApplicationConst;
import batch.config.ConvertKeyConfig;
import batch.listener.JobStartEndLIstener;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;
import utils.GlobalContext;
import web.config.EventLoggerUtil;
import web.logger.LogLevel;

import java.io.File;
import java.util.List;

@Component
public class PsqlCopyUtils {

    @Autowired
    private Environment environment;
    @Autowired
    private ConvertKeyConfig convertKeyConfig;

    /**
     * ロギング ツール クラスの導入
     */
    @Autowired
    private EventLoggerUtil eventLoggerUtil;

    /**
     * ファイルパスから拡張子なしのファイル名を取得する
     * @param filePath
     * @return 拡張子なしのファイル名
     */
    public static String getTableName(String filePath){
        String fileNameWithoutExtension = "";
        if(filePath!=null){
            File f = new File(filePath);
            String basename = f.getName();
            fileNameWithoutExtension = basename.substring(0, basename.lastIndexOf('_'));
        }
        return fileNameWithoutExtension;
    }

    // add #10859-6 djy start
    public static boolean isDiffTable(String filePath) {
        boolean isDiff = false;
        if (filePath != null) {
            isDiff = filePath.contains("[diff]");
        }
        return isDiff;
    }
    // add #10859-6 djy end

    @SuppressWarnings("unchecked")
    public static <T> T cast(Object o) {
        return (T)o;
    }

    /**
     * 内部クラス: データベース接続情報を維持する
     */
    private static class DbConnectionInfo {
        String hostIp;
        String dbUser;
        String dbName;
        String tablePrefix;

        DbConnectionInfo(String hostIp, String dbUser, String dbName, String tablePrefix) {
            this.hostIp = hostIp;
            this.dbUser = dbUser;
            this.dbName = dbName;
            this.tablePrefix = tablePrefix != null ? tablePrefix : "";
        }
    }

    /**
     * dbTypeパラメータに基づいてDB接続情報を取得
     */
    private DbConnectionInfo extractDbConnectionInfoByDbType(String dbType) {
        String jdbcUrl = environment.getProperty("datasource." + dbType + ".jdbc-url");
        String userName = environment.getProperty("datasource." + dbType + ".username");
        return parseDbConnectionInfo(jdbcUrl, userName);
    }

    /**
     * JDBC URLとユーザー名から接続情報をパース
     */
    private DbConnectionInfo parseDbConnectionInfo(String jdbcUrl, String userName) {
        String hostIp = jdbcUrl.split("/")[2].split(":")[0];
        String dbName = jdbcUrl.split("/")[3];
        String tablePrefix = environment.getProperty(userName + "_prefix");
        return new DbConnectionInfo(hostIp, userName, dbName, tablePrefix);
    }

    /**
     * 引数の情報からCOPYコマンド実行のためのOSシステムコールコマンドを生成して返す
     * @param tableName 登録対象テーブル名
     * @param registColumnNameList 登録列名のリスト
     * @param facilityCd 処理対象施設コード
     * @param registDbType
     * @param status
     * @return 生成されたCOPYコマンドを含むOSシステムコールコマンドの配列
     */
    public String[] createCopyCommand(
            String inputFilePath,
            String tableName,
            List<String> registColumnNameList,
            String facilityCd, String registDbType, int status
    ) {
        DbConnectionInfo productionDB = extractDbConnectionInfoByDbType(registDbType);
        DbConnectionInfo convertDB = extractDbConnectionInfoByDbType(ApplicationConst.DbType.CONVERT);
        String[] fromDbParams = resolveFromDbConnectionForCreateCopyCommand(status, productionDB, convertDB);
        String[] toDbParams = resolveToDbConnectionForCreateCopyCommand(status, productionDB, convertDB);
        String registColumnNames = String.join(",", registColumnNameList);
        String sql = buildSelectSqlForCreateCopyCommand(tableName, registColumnNameList, facilityCd, fromDbParams[3]);
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        String tmpCopyCsvFile = inputFilePath + globalContext.tmpCopyCsvDir + tableName + ".csv";
        eventLoggerUtil.recordLog(facilityCd,
                eventLoggerUtil.getEventLogMessage("[CommonFunction.createCopyCommand] "
                        + ",tmpCopyCsvFile=" + tmpCopyCsvFile, null, null), LogLevel.INFO);
        String copyCommand = buildPsqlCopyCommandStringForCreateCopyCommand(
                fromDbParams, toDbParams, sql, tmpCopyCsvFile, tableName, registColumnNames);
        return buildOsShellCommandForCreateCopyCommand(copyCommand);
    }

    /**
     * createCopyCommand用の登録元DB接続パラメータを解決する
     */
    private String[] resolveFromDbConnectionForCreateCopyCommand(
            int status, DbConnectionInfo productionDB, DbConnectionInfo convertDB) {
        String fromHostIp = "";
        String fromDbUser = "";
        String fromDbName = "";
        String fromDb_table_prefix = "";
        // 登録元DB接続情報を取得
        if (status == 0) { //convertDataSourceパラメータを最初に
            fromHostIp = convertDB.hostIp;
            fromDbUser = convertDB.dbUser;
            fromDbName = convertDB.dbName;
            fromDb_table_prefix = convertDB.tablePrefix;
        } else { //convertDataSource後のパラメータ
            fromHostIp = productionDB.hostIp;
            fromDbUser = productionDB.dbUser;
            fromDbName = productionDB.dbName;
            fromDb_table_prefix = productionDB.tablePrefix;
        }
        fromDb_table_prefix = fromDb_table_prefix == null ? "" : fromDb_table_prefix;
        return new String[]{fromHostIp, fromDbUser, fromDbName, fromDb_table_prefix};
    }

    /**
     * createCopyCommand用の登録先DB接続パラメータを解決する
     */
    private String[] resolveToDbConnectionForCreateCopyCommand(
            int status, DbConnectionInfo productionDB, DbConnectionInfo convertDB) {
        String toHostIp = "";
        String toDbUser = "";
        String toDbName = "";
        String toDb_table_prefix = "";
        if (status == 1) { //convertDataSource後のパラメータ
            toHostIp = convertDB.hostIp;
            toDbUser = convertDB.dbUser;
            toDbName = convertDB.dbName;
            toDb_table_prefix = convertDB.tablePrefix;
        } else { //パラメータを最初に
            toHostIp = productionDB.hostIp;
            toDbUser = productionDB.dbUser;
            toDbName = productionDB.dbName;
            toDb_table_prefix = productionDB.tablePrefix;
        }
        toDb_table_prefix = toDb_table_prefix == null ? "" : toDb_table_prefix;
        return new String[]{toHostIp, toDbUser, toDbName, toDb_table_prefix};
    }

    /**
     * createCopyCommand用のデータ取得SELECT文を組み立てる
     */
    private String buildSelectSqlForCreateCopyCommand(
            String tableName, List<String> registColumnNameList, String facilityCd, String fromDb_table_prefix) {
        boolean hasFacilityCd = registColumnNameList.stream().anyMatch(x -> x.equals("facility_cd"));
        // 登録列名リストをカンマ区切りに変換
        String registColumnNames = String.join(",", registColumnNameList);
        // データ取得SQL生成
        String sql = "select " + registColumnNames + " from " + fromDb_table_prefix + tableName;
        if(hasFacilityCd){
            // facility_cdが存在する場合、条件に追加
            sql += " where facility_cd='" + facilityCd + "'";
        }
        String orderSql = convertKeyConfig.getOrderby(tableName);
        sql += orderSql;
        return sql;
    }

    /**
     * createCopyCommand用のpsql COPYコマンド文字列を組み立てる
     */
    private String buildPsqlCopyCommandStringForCreateCopyCommand(
            String[] fromDbParams,
            String[] toDbParams,
            String sql,
            String tmpCopyCsvFile,
            String tableName,
            String registColumnNames) {
        return "psql"
                + " -h "
                + fromDbParams[0]
                + " -U "
                + fromDbParams[1]
                + " -d "
                + fromDbParams[2]
                + " -c \"\\copy "
                + "("
                + sql
                + ") TO " + tmpCopyCsvFile + " WITH CSV HEADER\""
                + " && "
                + "psql"
                + " -h "
                + toDbParams[0]
                + " -U "
                + toDbParams[1]
                + " -d "
                + toDbParams[2]
                + " -c \"\\copy " + toDbParams[3]
                + tableName
                + "("
                + registColumnNames
                + ") FROM " + tmpCopyCsvFile + " WITH CSV HEADER\"";
    }

    /**
     * createCopyCommand用のOSシェルコマンド配列を組み立てる
     */
    private String[] buildOsShellCommandForCreateCopyCommand(String copyCommand) {
        String[] command = new String[3];
        if ( "\\".equals(System.getProperty("file.separator")) ) {
            // mod 2020-11-24 cmdをcmd.exeに変更  う start
            command[0] = "cmd.exe";
            // mod 2020-11-24 cmdをcmd.exeに変更  う end
            command[1] = "/c";
        } else {
            command[0] = "sh";
            command[1] = "-c";
        }
        command[2] = copyCommand;
        return command;
    }

    /**
     * 引数の情報からCOPYコマンド実行のためのOSシステムコールコマンドを生成して返す
     * @param tableName 登録対象テーブル名
     * @param registColumnNameList 登録列名のリスト
     * @param facilityCd 処理対象施設コード
     * @return 生成されたCOPYコマンドを含むOSシステムコールコマンドの配列
     */
    public String[] createCopyCommandUpd(
            String inputFilePath,
            String tableName,
            List<String> registColumnNameList,
            String facilityCd,
            String sqlCnd, String registDbType, int status, boolean hasConvertId) {
        DbConnectionInfo productionDB = extractDbConnectionInfoByDbType(registDbType);
        DbConnectionInfo convertDB = extractDbConnectionInfoByDbType(ApplicationConst.DbType.CONVERT);
        String[] fromDbParams = resolveFromDbConnectionForCreateCopyCommandUpd(status, productionDB, convertDB);
        String[] toDbParams = resolveToDbConnectionForCreateCopyCommandUpd(status, productionDB, convertDB);
        adjustRegistColumnsForCreateCopyCommandUpd(tableName, registColumnNameList);
        String registColumnNames = String.join(",", registColumnNameList);
        String sql = buildSelectSqlForCreateCopyCommandUpd(
                tableName, registColumnNameList, facilityCd, sqlCnd, fromDbParams[3], hasConvertId);
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        String tmpCopyCsvFile = inputFilePath + globalContext.tmpCopyCsvDir + tableName + ".csv";
        String copyCommand = buildPsqlCopyCommandStringForCreateCopyCommandUpd(
                fromDbParams, toDbParams, sql, tmpCopyCsvFile, tableName, registColumnNames);
        return buildOsShellCommandForCreateCopyCommandUpd(copyCommand);
    }

    /**
     * createCopyCommandUpd用の登録元DB接続パラメータを解決する
     */
    private String[] resolveFromDbConnectionForCreateCopyCommandUpd(
            int status, DbConnectionInfo productionDB, DbConnectionInfo convertDB) {
        String fromHostIp = "";
        String fromDbUser = "";
        String fromDbName = "";
        String fromDb_table_prefix = "";
        if (status == 0) { //convertDataSourceパラメータを最初に
            fromHostIp = convertDB.hostIp;
            fromDbUser = convertDB.dbUser;
            fromDbName = convertDB.dbName;
            fromDb_table_prefix = convertDB.tablePrefix;
        } else { //convertDataSource在后
            fromHostIp = productionDB.hostIp;
            fromDbUser = productionDB.dbUser;
            fromDbName = productionDB.dbName;
            fromDb_table_prefix = productionDB.tablePrefix;
        }
        fromDb_table_prefix = fromDb_table_prefix == null ? "" : fromDb_table_prefix;
        return new String[]{fromHostIp, fromDbUser, fromDbName, fromDb_table_prefix};
    }

    /**
     * createCopyCommandUpd用の登録先DB接続パラメータを解決する
     */
    private String[] resolveToDbConnectionForCreateCopyCommandUpd(
            int status, DbConnectionInfo productionDB, DbConnectionInfo convertDB) {
        String toHostIp = "";
        String toDbUser = "";
        String toDbName = "";
        String toDb_table_prefix = "";
        if (status == 1) { //convertDataSource在后
            toHostIp = convertDB.hostIp;
            toDbUser = convertDB.dbUser;
            toDbName = convertDB.dbName;
            toDb_table_prefix = convertDB.tablePrefix;
        } else { //convertDataSource在前
            toHostIp = productionDB.hostIp;
            toDbUser = productionDB.dbUser;
            toDbName = productionDB.dbName;
            toDb_table_prefix = productionDB.tablePrefix;
        }
        toDb_table_prefix = toDb_table_prefix == null ? "" : toDb_table_prefix;
        return new String[]{toHostIp, toDbUser, toDbName, toDb_table_prefix};
    }

    /**
     * createCopyCommandUpd用の登録列リストをテーブル別に調整する
     */
    private void adjustRegistColumnsForCreateCopyCommandUpd(String tableName, List<String> registColumnNameList) {
        if(tableName.equals("mst_comsv_setting")){
            registColumnNameList.remove("fn_comsv_no");
        }
    }

    /**
     * createCopyCommandUpd用のデータ取得SELECT文を組み立てる
     */
    private String buildSelectSqlForCreateCopyCommandUpd(
            String tableName,
            List<String> registColumnNameList,
            String facilityCd,
            String sqlCnd,
            String fromDb_table_prefix,
            boolean hasConvertId) {
        boolean hasFacilityCd = registColumnNameList.stream().anyMatch(x -> x.equals("facility_cd"));
        String registColumnNames = String.join(",", registColumnNameList);
        // データ取得SQL生成
        // mod 2020-11-20 データテーブル名追加ntss. う start
        String sql = "select " + registColumnNames + " from " + fromDb_table_prefix + tableName;
        // mod 2020-11-20 データテーブル名追加ntss. う end
        if (hasFacilityCd) {
            // facility_cdが存在する場合、条件に追加
            sql += " where facility_cd='" + facilityCd + "'";
            sql += sqlCnd;
        }

        String orderSql = hasConvertId ? convertKeyConfig.getOrderByForConvert(tableName) : convertKeyConfig.getOrderby(tableName);
        sql += orderSql;

        return sql;
    }
    /**
     * createCopyCommandUpd用のpsql COPYコマンド文字列を組み立てる
     */
    private String buildPsqlCopyCommandStringForCreateCopyCommandUpd(
            String[] fromDbParams,
            String[] toDbParams,
            String sql,
            String tmpCopyCsvFile,
            String tableName,
            String registColumnNames) {
        return "psql"
                + " -h "
                + fromDbParams[0]
                + " -U "
                + fromDbParams[1]
                + " -d "
                + fromDbParams[2]
                + " -c \"\\copy "
                + "("
                + sql
                + ") TO " + tmpCopyCsvFile + " WITH CSV HEADER\""
                + " && "
                + "psql"
                + " -h "
                + toDbParams[0]
                + " -U "
                + toDbParams[1]
                + " -d "
                + toDbParams[2]
                + " -c \"\\copy " + toDbParams[3]
                + tableName
                + "("
                + registColumnNames
                + ") FROM " + tmpCopyCsvFile + " WITH CSV HEADER\"";
    }

    /**
     * createCopyCommandUpd用のOSシェルコマンド配列を組み立てる
     */
    private String[] buildOsShellCommandForCreateCopyCommandUpd(String copyCommand) {
        String[] command = new String[3];
        if( "\\".equals(System.getProperty("file.separator")) ) {
            command[0] = "cmd.exe";
            command[1] = "/c";
        }else{
            command[0] = "sh";
            command[1] = "-c";
        }
        command[2] = copyCommand;
        return command;
    }


    // add 7853-差分コンバートで更新/削除ができない 楊 start
    /**
     * 差分更新データ用、引数の情報からCOPYコマンド実行のためのOSシステムコールコマンドを生成して返す
     *
     * @param tableName            登録対象テーブル名
     * @param fromDbType           登録元データタイプ
     * @param toDbType             登録先データタイプ
     * @param registColumnNameList 登録列名のリスト
     * @param facilityCd           処理対象施設コード
     * @param sqlDel               本番削除sql
     * @param hasConvertId
     * @return 生成されたCOPYコマンドを含むOSシステムコールコマンドの配列
     */
    public String[] createCopyCommandUpdDiff(
            String inputFilePath,
            String tableName,
            String fromDbType,
            String toDbType,
            List<String> registColumnNameList,
            String facilityCd,
            String sqlCnd,
            String sqlDel,
            boolean hasConvertId) {
        // 登録元DB接続情報を取得
        DbConnectionInfo fromDB = extractDbConnectionInfoByDbType(fromDbType);
        String fromHostIp = fromDB.hostIp;
        String fromDbUser = fromDB.dbUser;
        String fromDbName = fromDB.dbName;
        // 登録元DBスキーマを取得
        String fromDb_table_prefix = fromDB.tablePrefix;
        fromDb_table_prefix = fromDb_table_prefix == null ? "" : fromDb_table_prefix;

        // 登録先DB接続情報を取得
        DbConnectionInfo toDB = extractDbConnectionInfoByDbType(toDbType);
        String toHostIp = toDB.hostIp;
        String toDbUser = toDB.dbUser;
        String toDbName = toDB.dbName;
        // 登録先DBスキーマを取得
        String toDb_table_prefix = toDB.tablePrefix;
        toDb_table_prefix = toDb_table_prefix == null ? "" : toDb_table_prefix;

        removeRegistColumnsForCreateCopyCommandUpdDiff(tableName, registColumnNameList);
        String registColumnNames = String.join(",", registColumnNameList);
        String sql = buildSelectSqlForCreateCopyCommandUpdDiff(
                tableName, registColumnNameList, facilityCd, sqlCnd, fromDb_table_prefix, hasConvertId);
        String sqlDelete = buildSqlDeleteOptionForCreateCopyCommandUpdDiff(sqlDel);
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        String tmpCopyCsvFile = inputFilePath + globalContext.tmpCopyCsvDir + tableName + ".csv";
        String copyCommand = buildPsqlCopyCommandStringForCreateCopyCommandUpdDiff(
                fromHostIp, fromDbUser, fromDbName, toHostIp, toDbUser, toDbName,
                toDb_table_prefix, sql, sqlDelete, tmpCopyCsvFile, tableName, registColumnNames);
        return buildOsShellCommandForCreateCopyCommandUpdDiff(copyCommand);
    }

    /**
     * createCopyCommandUpdDiff用の登録列リストをテーブル別に除外する
     */
    private void removeRegistColumnsForCreateCopyCommandUpdDiff(String tableName, List<String> registColumnNameList) {
        if (registColumnNameList.size() > 0){
            if (tableName.equals("pat_event")) {
                registColumnNameList.remove("pat_event_cd");
            } else if(tableName.equals("ord_checklist")){
                registColumnNameList.remove("checklist_ctl_no");
            } else if(tableName.equals("mni_monitor")){
                registColumnNameList.remove("bio_moni_ctl_no");
            }else if (tableName.equals("ord_weight_scale")) {
                registColumnNameList.remove("weight_scale_no");
            }else if(tableName.equals("mst_favorite_facility")){
                registColumnNameList.remove("master_cd");
            }else if(tableName.equals("ord_coop_no")){
                registColumnNameList.remove("ctl_no");
            }else if(tableName.equals("ord_treat_condition")){
                registColumnNameList.remove("condition_cd");
            } else if (tableName.equals("mst_comsv_setting")) {
                registColumnNameList.remove("fn_comsv_no");
                registColumnNameList.remove("comsv_cd");
            }
        }
    }

    /**
     * createCopyCommandUpdDiff用のデータ取得SELECT文を組み立てる
     */
    private String buildSelectSqlForCreateCopyCommandUpdDiff(
            String tableName,
            List<String> registColumnNameList,
            String facilityCd,
            String sqlCnd,
            String fromDb_table_prefix,
            boolean hasConvertId) {
        boolean hasFacilityCd = registColumnNameList.stream().anyMatch(x -> x.equals("facility_cd"));
        String registColumnNames = String.join(",", registColumnNameList);
        // データ取得SQL生成
        String sql = "select " + registColumnNames + " from " + fromDb_table_prefix + tableName;
        if (hasFacilityCd) {
            // facility_cdが存在する場合、条件に追加
            sql += " where facility_cd='" + facilityCd + "'";
            if(!tableName.equals("pat_group_detail")){
                sql += sqlCnd;
            }
        }
        String orderSql = hasConvertId ? convertKeyConfig.getOrderByForConvert(tableName) : convertKeyConfig.getOrderby(tableName);
        sql += orderSql;
        return sql;
    }

    /**
     * createCopyCommandUpdDiff用の本番削除SQLオプション文字列を組み立てる
     */
    private String buildSqlDeleteOptionForCreateCopyCommandUpdDiff(String sqlDel) {
        String sqlDelete = "";
        if(!sqlDel.isEmpty()){
            sqlDelete = " -c \"" + sqlDel + "\"";
        }
        return sqlDelete;
    }

    /**
     * createCopyCommandUpdDiff用のpsql COPYコマンド文字列を組み立てる
     */
    private String buildPsqlCopyCommandStringForCreateCopyCommandUpdDiff(
            String fromHostIp,
            String fromDbUser,
            String fromDbName,
            String toHostIp,
            String toDbUser,
            String toDbName,
            String toDb_table_prefix,
            String sql,
            String sqlDelete,
            String tmpCopyCsvFile,
            String tableName,
            String registColumnNames) {
        return "psql"
                + " -h "
                + fromHostIp
                + " -U "
                + fromDbUser
                + " -d "
                + fromDbName
                + " -c \"\\copy "
                + "("
                + sql
                + ") TO " + tmpCopyCsvFile + " WITH CSV HEADER\""
                + " && "
                + "psql"
                + " -h "
                + toHostIp // 登録先DBホストIPアドレス
                + " -U "
                + toDbUser // 登録先DBユーザー名
                + " -d "
                + toDbName // 登録先DB名
                + " -1 "
                + sqlDelete
                + " -c \"\\copy " + toDb_table_prefix
                + tableName //テーブル名
                + "("
                + registColumnNames //カラム名（カンマ区きり）
                + ") FROM " + tmpCopyCsvFile + " WITH CSV HEADER;\" ";
    }

    /**
     * createCopyCommandUpdDiff用のOSシェルコマンド配列を組み立てる
     */
    private String[] buildOsShellCommandForCreateCopyCommandUpdDiff(String copyCommand) {
        String[] command = new String[3];
        if( "\\".equals(System.getProperty("file.separator")) ) {
            command[0] = "cmd.exe";
            command[1] = "/c";
        }else{
            command[0] = "sh";
            command[1] = "-c";
        }
        command[2] = copyCommand;
        return command;
    }


    /**
     * 引数の情報からCOPYコマンド実行のためのOSシステムコールコマンドを生成して返す
     *
     * @param tableName            登録対象テーブル名
     * @param fromDbType           登録元データソース
     * @param registColumnNameList 登録列名のリスト
     * @param facilityCd           処理対象施設コード
     * @param sqlCnd               登録元データ検索条件
     * @param sqlDel               本番データ削除sql
     * @param hasConvertId         hasConvertId
     * @return 生成されたCOPYコマンドを含むOSシステムコールコマンドの配列
     */
    public String[] createCopyCommandByCond(
            String inputFilePath,
            String tableName,
            String fromDbType,
            String toDbType,
            List<String> registColumnNameList,
            String facilityCd,
            String sqlCnd,
            String sqlDel,
            boolean hasConvertId) {
        // 登録元DB接続情報を取得
        DbConnectionInfo productionDB = extractDbConnectionInfoByDbType(fromDbType);
        String fromHostIp = productionDB.hostIp;
        String fromDbUser = productionDB.dbUser;
        String fromDbName = productionDB.dbName;
        // 登録元DBスキーマを取得
        String fromDb_table_prefix = productionDB.tablePrefix;
        fromDb_table_prefix = fromDb_table_prefix == null ? "" : fromDb_table_prefix;

        // 登録先DB接続情報を取得
        DbConnectionInfo convertDB = extractDbConnectionInfoByDbType(toDbType);
        String toHostIp = convertDB.hostIp;
        String toDbUser = convertDB.dbUser;
        String toDbName = convertDB.dbName;
        // 登録先DBスキーマを取得
        String toDb_table_prefix = convertDB.tablePrefix;
        toDb_table_prefix = toDb_table_prefix == null ? "" : toDb_table_prefix;

        adjustRegistColumnsForCreateCopyCommandByCond(tableName, registColumnNameList);
        String registColumnNames = String.join(",", registColumnNameList);
        String sql = buildBaseSelectSqlForCreateCopyCommandByCond(
                tableName, registColumnNames, fromDb_table_prefix, sqlCnd, facilityCd, registColumnNameList);
        sql = appendOrderClauseForCreateCopyCommandByCond(tableName, sql, fromDbType, hasConvertId);
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        String tmpCopyCsvFile = inputFilePath + globalContext.tmpCopyCsvDir + tableName + ".csv";
        String copyCommand = buildPsqlCopyCommandStringForCreateCopyCommandByCond(
                fromHostIp, fromDbUser, fromDbName, toHostIp, toDbUser, toDbName,
                toDb_table_prefix, sql, sqlDel, tmpCopyCsvFile, tableName, registColumnNames);
        return buildOsShellCommandForCreateCopyCommandByCond(copyCommand);
    }

    /**
     * createCopyCommandByCond用の登録列リストをテーブル別に調整する
     */
    private void adjustRegistColumnsForCreateCopyCommandByCond(String tableName, List<String> registColumnNameList) {
        if(tableName.equals("mst_mainte_detail_hst")){
            registColumnNameList.remove("fn_mainte_detail_cd");
            // add #9448 mst_mainte_category.detail再設定 zkm start
            registColumnNameList.remove("fn_mainte_type");
            // add #9448 mst_mainte_category.detail再設定 zkm end
        }
        // add #9448 mst_mainte_category.detail再設定 zkm start
        if(tableName.equals("mst_mainte_category_hst")){
            registColumnNameList.remove("fn_mainte_category_cd");
            registColumnNameList.remove("fn_mainte_type");
        }
        // add #9448 mst_mainte_category.detail再設定 zkm end
        // add #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe start
        if(tableName.equals("mst_comsv_setting")){
            registColumnNameList.remove("fn_comsv_no");
        }
    }

    /**
     * createCopyCommandByCond用のデータ取得SELECT文本体を組み立てる
     */
    private String buildBaseSelectSqlForCreateCopyCommandByCond(
            String tableName,
            String registColumnNames,
            String fromDb_table_prefix,
            String sqlCnd,
            String facilityCd,
            List<String> registColumnNameList) {
        boolean hasFacilityCd = registColumnNameList.stream().anyMatch(x -> x.equals("facility_cd"));
        String sql = "select " + registColumnNames + " from " + fromDb_table_prefix + tableName;
        //mst_mainte_layout copy mst_mainte_layout_hst
        if(tableName.equals("mst_mainte_layout_hst")){
            sql = "select " + registColumnNames + " from " + fromDb_table_prefix + "mst_mainte_layout";
        }else if(tableName.equals("mst_mainte_detail_hst")){
            sql = "select " + registColumnNames + " from " + fromDb_table_prefix + "mst_mainte_detail";
            // add #9448 mst_mainte_category.detail再設定 zkm start
        }else if(tableName.equals("mst_mainte_category_hst")){
            sql = "select " + registColumnNames + " from " + fromDb_table_prefix + "mst_mainte_category";
        }else if(tableName.equals("mst_mainte_layout_group_hst")){
            sql = "select " + registColumnNames + " from " + fromDb_table_prefix + "mst_mainte_layout_group";
        }
        // add #9448 mst_mainte_category.detail再設定 zkm end
        sql += !sqlCnd.isEmpty() ? sqlCnd.contains("JOIN") ? sqlCnd + " where 1 = 1 ":" where " + sqlCnd : " where 1 = 1 ";
        if(hasFacilityCd){
            // facility_cdが存在する場合、条件に追加
            sql += " and facility_cd='" + facilityCd + "'";
        }
        return sql;
    }

    /**
     * createCopyCommandByCond用のORDER BY句をSELECT文に付与する
     */
    private String appendOrderClauseForCreateCopyCommandByCond(
            String tableName, String sql, String fromDbType, boolean hasConvertId) {
        String orderSql = hasConvertId ? convertKeyConfig.getOrderByForConvert(tableName) : convertKeyConfig.getOrderby(tableName);
        // add #11998  start
        if (tableName.equals("mst_facility")) {
            sql += " order by facility_cd";
        } else if (tableName.equals("mst_graph_setting")) {
            sql += " order by graph_setting_no";
        } else if (tableName.equals("mst_mainte_category_hst") || tableName.equals("mst_mainte_layout_hst")) {
            sql += orderSql;
        } else if (ApplicationConst.DbType.CONVERT.equals(fromDbType) && !convertKeyConfig.getNoseq(tableName)) {
            sql += " order by convert_id";
        } else {
            sql += orderSql;
        }
        return sql;
    }

    /**
     * createCopyCommandByCond用のpsql COPYコマンド文字列を組み立てる
     */
    private String buildPsqlCopyCommandStringForCreateCopyCommandByCond(
            String fromHostIp,
            String fromDbUser,
            String fromDbName,
            String toHostIp,
            String toDbUser,
            String toDbName,
            String toDb_table_prefix,
            String sql,
            String sqlDel,
            String tmpCopyCsvFile,
            String tableName,
            String registColumnNames) {
        String copyCommand = "psql"
                + " -h "
                + fromHostIp
                + " -U "
                + fromDbUser
                + " -d "
                + fromDbName
                + " -c \"\\copy "
                + "("
                + sql
                + ") TO " + tmpCopyCsvFile + " WITH CSV HEADER\""
                + " && "
                + "psql"
                + " -h "
                + toHostIp // 登録先DBホストIPアドレス
                + " -U "
                + toDbUser // 登録先DBユーザー名
                + " -d "
                + toDbName; // 登録先DB名

        if (!sqlDel.isEmpty()) {
            copyCommand += " -1 -c \" " + sqlDel + "\" -c \"\\copy " + toDb_table_prefix;
        } else {
            copyCommand += " -c \"\\copy " + toDb_table_prefix;
        }
        copyCommand += tableName //テーブル名
                + "("
                + registColumnNames //カラム名（カンマ区きり）
                + ") FROM " + tmpCopyCsvFile + " WITH CSV HEADER\"";
        return copyCommand;
    }


    /**
     * createCopyCommandByCond用のOSシェルコマンド配列を組み立てる
     */
    private String[] buildOsShellCommandForCreateCopyCommandByCond(String copyCommand) {
        String[] command = new String[3];
        if ( "\\".equals(System.getProperty("file.separator")) ) {
            command[0] = "cmd.exe";
            command[1] = "/c";
        } else {
            command[0] = "sh";
            command[1] = "-c";
        }
        command[2] = copyCommand;
        return command;
    }
    // add 7853-差分コンバートで更新/削除ができない 楊 end

    // add #11399 djy start
    public String[] createDelCopyCommandByCond(
            String inputFilePath,
            String tableName,
            String fromDbType,
            String toDbType,
            List<String> registColumnNameList,
            String facilityCd,
            String sqlCnd,
            String sqlDel) {
        // 登録元DB接続情報を取得
        DbConnectionInfo productionDB = extractDbConnectionInfoByDbType(fromDbType);
        String fromHostIp = productionDB.hostIp;
        String fromDbUser = productionDB.dbUser;
        String fromDbName = productionDB.dbName;
        // 登録元DBスキーマを取得
        String fromDb_table_prefix = productionDB.tablePrefix;
        fromDb_table_prefix = fromDb_table_prefix == null ? "" : fromDb_table_prefix;

        // 登録先DB接続情報を取得
        DbConnectionInfo convertDB = extractDbConnectionInfoByDbType(toDbType);
        String toHostIp = convertDB.hostIp;

        String toDbUser = convertDB.dbUser;
        String toDbName = convertDB.dbName;
        // 登録先DBスキーマを取得
        String toDb_table_prefix = convertDB.tablePrefix;
        toDb_table_prefix = toDb_table_prefix == null ? "" : toDb_table_prefix;

        String registColumnNames = String.join(",", registColumnNameList);
        String sql = buildSelectSqlForCreateDelCopyCommandByCond(
                registColumnNames, fromDb_table_prefix, tableName, sqlCnd, facilityCd, registColumnNameList);
        String copyCommand = buildInitialDelCopyCommandForCreateDelCopyCommandByCond(sqlDel, toHostIp, toDbUser, toDbName);
        GlobalContext globalContext = JobStartEndLIstener.getGlobalContext();
        String tmpCopyCsvFile = inputFilePath + globalContext.tmpCopyCsvDir + tableName + ".csv";
        copyCommand += buildExportImportDelCopyCommandForCreateDelCopyCommandByCond(
                fromHostIp, fromDbUser, fromDbName, toHostIp, toDbUser, toDbName,
                toDb_table_prefix, sql, tmpCopyCsvFile, tableName, registColumnNames);
        return buildOsShellCommandForCreateDelCopyCommandByCond(copyCommand);
    }

    /**
     * createDelCopyCommandByCond用のデータ取得SELECT文を組み立てる
     */
    private String buildSelectSqlForCreateDelCopyCommandByCond(
            String registColumnNames,
            String fromDb_table_prefix,
            String tableName,
            String sqlCnd,
            String facilityCd,
            List<String> registColumnNameList) {
        boolean hasFacilityCd = registColumnNameList.stream().anyMatch(x -> x.equals("facility_cd"));
        String sql = "select " + registColumnNames + " from " + fromDb_table_prefix + tableName;
        sql += !sqlCnd.isEmpty() ? sqlCnd.contains("JOIN") ? sqlCnd + " where 1 = 1 ":" where " + sqlCnd : " where 1 = 1 ";
        if(hasFacilityCd){
            sql += " and facility_cd='" + facilityCd + "'";
        }
        return sql;
    }

    /**
     * createDelCopyCommandByCond用の本番削除psqlコマンド前置部を組み立てる
     */
    private String buildInitialDelCopyCommandForCreateDelCopyCommandByCond(
            String sqlDel, String toHostIp, String toDbUser, String toDbName) {
        String copyCommand = "";
        if (!sqlDel.isEmpty()) {
            copyCommand += "psql"
                    + " -h "
                    + toHostIp
                    + " -U "
                    + toDbUser
                    + " -d "
                    + toDbName
                    + " -c \" " + sqlDel + "\" && ";
        }
        return copyCommand;
    }

    /**
     * createDelCopyCommandByCond用のエクスポート・インポートpsqlコマンド部を組み立てる
     */
    private String buildExportImportDelCopyCommandForCreateDelCopyCommandByCond(
            String fromHostIp,
            String fromDbUser,
            String fromDbName,
            String toHostIp,
            String toDbUser,
            String toDbName,
            String toDb_table_prefix,
            String sql,
            String tmpCopyCsvFile,
            String tableName,
            String registColumnNames) {
        return "psql"
                + " -h "
                + fromHostIp
                + " -U "
                + fromDbUser
                + " -d "
                + fromDbName
                + " -c \"\\copy "
                + "("
                + sql
                + ") TO " + tmpCopyCsvFile + " WITH CSV HEADER\""
                + " && "
                + "psql"
                + " -h "
                + toHostIp // 登録先DBホストIPアドレス
                + " -U "
                + toDbUser // 登録先DBユーザー名
                + " -d "
                + toDbName // 登録先DB名
                +" -c \"\\copy "
                + toDb_table_prefix
                + tableName //テーブル名
                + "("
                + registColumnNames //カラム名（カンマ区きり）
                + ") FROM " + tmpCopyCsvFile + " WITH CSV HEADER\"";
    }

    /**
     * createDelCopyCommandByCond用のOSシェルコマンド配列を組み立てる
     */
    private String[] buildOsShellCommandForCreateDelCopyCommandByCond(String copyCommand) {
        String[] command = new String[3];
        if ( "\\".equals(System.getProperty("file.separator")) ) {
            command[0] = "cmd.exe";
            command[1] = "/c";
        } else {
            command[0] = "sh";
            command[1] = "-c";
        }
        command[2] = copyCommand;
        return command;
    }
    // add #11399 djy end
}
