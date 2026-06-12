using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Reflection;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using FNSICloudConvertClient.Models;
using Npgsql;

namespace FNSICloudConvertClient.Logic
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// DOMA スタイルの 2-Way SQL ランナー
    ///
    /// 【SQL ファイルの書き方】
    ///   名前付きパラメーター:  /* :paramName */dummy_value
    ///     例) WHERE facility_cd = /* :facilityCd */'F001'
    ///     例) AND   delete_flag = /* :deleteFlag */0
    ///
    ///   IN 句パラメーター:     /* :paramName */(dummy)
    ///     例) AND code IN /* :codes */('A','B')
    ///
    ///   条件ブロック:          /*IF condition */ ... /*END*/
    ///     例) /*IF :onlyActive */ AND active = true /*END*/
    ///     ※ condition は "true"/"false" または null チェック ":param IS NULL" 形式
    ///
    ///   SQL ファイルはそのまま psql で実行可能な有効な SQL です（2-way）
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class SqlRunner
    {
        private readonly string      _connectionString;
        private readonly AppLogger  _log;

        // SQL ファイルの基準ディレクトリ（実行ファイルの Sql/ フォルダ）
        private static readonly string SqlBasePath = Path.Combine(
            Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location),
            "Sql");

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// コンストラクター
        /// </summary>
        /// <param name="settings">AppSettings（OnpreRdbIpAddress を接続先ホストとして使用）</param>
        //----------------------------------------------------------------------------------------------------
        public SqlRunner(AppSettings settings)
        {
            var (sqlHost, sqlPort) = AppSettings.ParseHostPort(settings.OnpreRdbIpAddress, 5432);
            _connectionString = string.Format(
                "Host={0};Port={1};Database=ntss_db5;Username=nkk5;Password=nkk5;",
                sqlHost, sqlPort);
            _log = AppLogger.GetInstance();
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// SQL ファイルを読み込み、パラメーターを適用して非同期で SELECT を実行する
        /// </summary>
        /// <param name="sqlFileName">Sql/ 以下のパス（例: "Export/get_patients.sql"）</param>
        /// <param name="parameters">パラメーター辞書（キー: パラメーター名、値: オブジェクト）</param>
        /// <param name="ct">キャンセルトークン</param>
        /// <returns>DataTable</returns>
        //----------------------------------------------------------------------------------------------------
        public async Task<DataTable> QueryAsync(
            string sqlFileName,
            Dictionary<string, object> parameters,
            CancellationToken ct = default)
        {
            string rawSql  = LoadSqlFile(sqlFileName);
            string parsedSql;
            var    localParams = new List<NpgsqlParameter>();
            ParseSql(rawSql, parameters, out parsedSql, out localParams);

            _log.AddLogInfo(DateTime.Now, "SqlRunner", AppLogger.LOGGING_CLASS.INFO,
                string.Format("SQL実行: {0}", sqlFileName));

            var table = new DataTable();
            using (var conn = new NpgsqlConnection(_connectionString))
            {
                await conn.OpenAsync(ct);
                using (var cmd = new NpgsqlCommand(parsedSql, conn))
                {
                    foreach (var p in localParams)
                        cmd.Parameters.Add(p);

                    using (var reader = await cmd.ExecuteReaderAsync(ct))
                    {
                        table.Load(reader);
                    }
                }
            }
            return table;
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// SQL ファイルを読み込み、パラメーターを適用して非同期で INSERT/UPDATE/DELETE を実行する
        /// </summary>
        /// <returns>影響を受けた行数</returns>
        //----------------------------------------------------------------------------------------------------
        public async Task<int> ExecuteAsync(
            string sqlFileName,
            Dictionary<string, object> parameters,
            CancellationToken ct = default)
        {
            string rawSql  = LoadSqlFile(sqlFileName);
            string parsedSql;
            var    localParams = new List<NpgsqlParameter>();
            ParseSql(rawSql, parameters, out parsedSql, out localParams);

            _log.AddLogInfo(DateTime.Now, "SqlRunner", AppLogger.LOGGING_CLASS.INFO,
                string.Format("SQL実行: {0}", sqlFileName));

            using (var conn = new NpgsqlConnection(_connectionString))
            {
                await conn.OpenAsync(ct);
                using (var cmd = new NpgsqlCommand(parsedSql, conn))
                {
                    foreach (var p in localParams)
                        cmd.Parameters.Add(p);

                    return await cmd.ExecuteNonQueryAsync(ct);
                }
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// トランザクション内で複数 SQL を実行する
        /// </summary>
        /// <param name="actions">Action に conn/tx を渡してSQL実行を委譲する</param>
        //----------------------------------------------------------------------------------------------------
        public async Task ExecuteInTransactionAsync(
            Func<NpgsqlConnection, NpgsqlTransaction, Task> actions,
            CancellationToken ct = default)
        {
            using (var conn = new NpgsqlConnection(_connectionString))
            {
                await conn.OpenAsync(ct);
                using (var tx = conn.BeginTransaction())
                {
                    try
                    {
                        await actions(conn, tx);
                        tx.Commit();
                    }
                    catch
                    {
                        tx.Rollback();
                        throw;
                    }
                }
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// SQL ファイルを読み込み済みの SQL テキストとパラメーターを使って SELECT を実行する
        /// （トランザクション内での使用向け）
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public async Task<DataTable> QueryWithConnectionAsync(
            NpgsqlConnection conn,
            NpgsqlTransaction tx,
            string sqlFileName,
            Dictionary<string, object> parameters,
            CancellationToken ct = default)
        {
            string rawSql  = LoadSqlFile(sqlFileName);
            string parsedSql;
            var    localParams = new List<NpgsqlParameter>();
            ParseSql(rawSql, parameters, out parsedSql, out localParams);

            var table = new DataTable();
            using (var cmd = new NpgsqlCommand(parsedSql, conn, tx))
            {
                foreach (var p in localParams)
                    cmd.Parameters.Add(p);

                using (var reader = await cmd.ExecuteReaderAsync(ct))
                {
                    table.Load(reader);
                }
            }
            return table;
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続テスト（設定確認用）
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public async Task<bool> TestConnectionAsync(CancellationToken ct = default)
        {
            try
            {
                using (var conn = new NpgsqlConnection(_connectionString))
                {
                    await conn.OpenAsync(ct);
                    return true;
                }
            }
            catch (Exception ex)
            {
                _log.AddLogInfo(DateTime.Now, "SqlRunner", AppLogger.LOGGING_CLASS.ERROR,
                    string.Format("接続テスト失敗: {0}", ex.Message));
                return false;
            }
        }

        // --------------------------------------------------
        // 内部: SQL ファイル読み込み
        // --------------------------------------------------
        private string LoadSqlFile(string relativePath)
        {
            string fullPath = Path.Combine(SqlBasePath, relativePath);
            if (!File.Exists(fullPath))
                throw new FileNotFoundException(
                    string.Format("SQLファイルが見つかりません: {0}", fullPath));
            return File.ReadAllText(fullPath, Encoding.UTF8);
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 2-Way SQL パーサー
        ///
        /// 処理順:
        ///   1. /*IF :param */ ... /*END*/  ブロックを評価・展開
        ///   2. /* :paramName */literal      を @paramName に置換
        ///   3. IN /* :paramName */(dummy)   を (@p0,@p1,...) に展開
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void ParseSql(
            string rawSql,
            Dictionary<string, object> parameters,
            out string parsedSql,
            out List<NpgsqlParameter> npgsqlParams)
        {
            // out パラメーターをラムダ内で直接使えないためローカル変数を使用
            var localParams = new List<NpgsqlParameter>();
            string sql = rawSql;

            // --- 1. IF/END ブロック処理 ---
            // /*IF :paramName */ ... /*END*/
            sql = Regex.Replace(sql,
                @"/\*IF\s+:(\w+)\s*\*/(.+?)/\*END\*/",
                m =>
                {
                    string key   = m.Groups[1].Value;
                    string inner = m.Groups[2].Value;
                    object val;
                    if (parameters != null && parameters.TryGetValue(key, out val))
                    {
                        bool cond = val is bool ? (bool)val
                                  : val != null && !string.IsNullOrEmpty(val.ToString());
                        return cond ? inner : string.Empty;
                    }
                    return string.Empty;
                },
                RegexOptions.Singleline | RegexOptions.IgnoreCase);

            // --- 2. IN句 展開: IN /* :paramName */(dummy) ---
            // パラメーターが IEnumerable の場合に (@p0,@p1,...) へ展開
            sql = Regex.Replace(sql,
                @"\bIN\s+/\*\s*:(\w+)\s*\*/\([^)]*\)",
                m =>
                {
                    string key = m.Groups[1].Value;
                    object val;
                    if (parameters != null && parameters.TryGetValue(key, out val))
                    {
                        var enumerable = val as System.Collections.IEnumerable;
                        if (enumerable != null && !(val is string))
                        {
                            var holders = new List<string>();
                            int idx     = 0;
                            foreach (var item in enumerable)
                            {
                                string pname = string.Format("@{0}_{1}", key, idx++);
                                holders.Add(pname);
                                localParams.Add(new NpgsqlParameter(pname, item ?? DBNull.Value));
                            }
                            if (holders.Count == 0)
                                return "IN (NULL)"; // 空リストのフォールバック
                            return string.Format("IN ({0})", string.Join(",", holders));
                        }
                    }
                    return m.Value; // マッチしない場合はそのまま
                },
                RegexOptions.IgnoreCase);

            // --- 3. スカラーパラメーター置換: /* :paramName */literal ---
            sql = Regex.Replace(sql,
                @"/\*\s*:(\w+)\s*\*/\S+",
                m =>
                {
                    string key   = m.Groups[1].Value;
                    object val;
                    if (parameters != null && parameters.TryGetValue(key, out val))
                    {
                        string pname = "@" + key;
                        // 同名パラメーターの重複登録を防ぐ
                        if (!localParams.Exists(p => p.ParameterName == pname))
                            localParams.Add(new NpgsqlParameter(pname, val ?? DBNull.Value));
                        return pname;
                    }
                    return m.Value;
                });

            parsedSql    = sql;
            npgsqlParams = localParams; // out パラメーターへ代入
        }
    }
}
