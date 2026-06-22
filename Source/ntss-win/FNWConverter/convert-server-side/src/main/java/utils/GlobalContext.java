package utils;

import batch.entity.MstMachine;
import batch.entity.OrdDevice;


import java.util.*;


public class GlobalContext {

    public String fileName;

    public String facilityCd;
    /**
     * 削除対象の pat_treatment_pattern に対応する fn_pat_id リスト（DelPatientTreatmentPattern.txt から取得、カンマ区切り）。
     * <p>
     * 設定：JobStartEndLIstener.beforeJob → processDelPatientTreatmentPattern 内でのみ、
     * inputFilePath 下の DelPatientTreatmentPattern.txt を見つけた後、行ごとに読み込み split(",") で設定（ループで上書き、実際に有効なのは最後の行）。
     * <p>
     * 使用：同メソッド内 getPatIdsByFnPatIds(patIds, facilityCd) で fn_pat_id を pat_id に変換し、
     * deletePatTreatmentPatternByPatIds で Convert DB と生産 DB(NKK5) の pat_treatment_pattern を削除。
     * <p>
     * 設定値例：ファイルの最後の行が "P001,P002,P003" の場合、patIds = ["P001","P002","P003"]。
     * ファイルが見つからない場合は未設定（null）。afterJob では未クリア。
     */
    public List<String> patIds;

    /**
     * 現在処理中の「本番キー」リスト（カンマ区切り文字列）。後続の Step での COPY 条件・削除条件等に使用。
     * <p>
     * 一言で言うと：SQL ファイルを読んで Convert DB に書き込む際に「このバッチで対象となった生産側主キー」を文字列に連結して
     * sqlKeys に格納し、後続の「Convert→生産」「切り捨て」「生産→Convert」「派生データ処理」等のステップが
     * この文字列を（キーリストに解析して）条件として使用する。
     * <p>
     * フォーマット例：{@code " '100','101','102' "} または {@code " 100, 101, 102 "}
     * （テーブル・分岐によって異なり、使用時はカンマで split して引用符・スペースを除去する必要がある）。
     * <p>
     * 設定タイミング：ReadSqlFileWriteDbStep 内で JdbcBatchSqlItemWriter または BatchCsvWriterDb が
     * 各テーブル・各チャンク処理時に書き込む
     * （例：プランA では sqlKeys=values、プランB では setPlanB や mni_monitor/ord_checklist の values、
     * pat_event 等は deletePatEventInConvertDB 内で連結した updateKeys）。
     * <p>
     * 使用箇所：ConvertDbToProductionDbStep（COPY 条件・Convert 側削除）、TruncateTableStep（キーで削除）、
     * ProductionDbToConvertDbStep（生産→Convert 条件）、OrderMainDerivedDataProcessingStep（派生データキーリスト）等。
     * <p>
     * 注意：「現在処理中のファイル/テーブル」ごとに上書きされ、afterJob でクリアされない。
     * 次のファイルまたは次のチャンク書き込み時に新しい値で上書きされる。
     * 差分時「更新」：更新データ：in (sqlKeys) を使用：まず生産を削除し、次に Convert→生産へ pKey in (sqlKeys) で COPY
     * 差分時「新規」：実際の COPY 条件：key in (sqlNewKeys) または key in (sqlDisNoKeys)（key は insFnKey または pKey で、テーブルにより異なる）。
     * つまり：新規は差分時「このバッチで解析された新規キーリスト」→ sqlNewKeys（または sqlDisNoKeys）に格納し、
     * Convert から生産へ key in (sqlNewKeys) で COPY する。
     */
    public String sqlKeys;
    // 差分パターン追加レコードキー
    public String sqlNewKeys = "";
    // add zl start ord_main差分
    public String sqlDisNoKeys = "";
    public String insFnDisKey = "";
    // add zl end ord_main差分
    /**
     * {@link #insFnValue} と対で使用：本フィールドは「新規」レコードのキー列/式。
     * insFnValue はそのキーの値リスト（カンマ区切り）。条件形式は key in (sqlNewKeys) または
     * trim(insFnKey)=trim(ids)（ids は insFnValue を regexp_split_to_table したもの）。
     * <p>
     * insFnKey の設定：MakeSqlStep.setUtilSqlKeys（COALESCE/concat_ws 等）；
     * JdbcBatchSqlItemWriter 内の ord_main/pat_coop_detail/mst_comsv_setting 等テーブルの差分では
     * テーブル固有の式または列名を設定；プランA/B では processFnsiDiff が realData を設定。
     * <p>
     * insFnValue の設定：MakeSqlStep.setUtilSqlKeys でのみ、シーケンスなしテーブルの場合に
     * fn キーの値リストをクエリで取得し String.join で設定；差分パスでは sqlNewKeys を使用し、insFnValue には書き込まない。
     * <p>
     * 使用箇所：MakeSqlStep は2変数で Convert↔生産 COPY の WHERE を組み立てる；
     * ConvertDbToProductionDbStep/TruncateTableStep/ProductionDbToConvertDbStep はプランB以外の場合に
     * insFnKey をキーとして使用；ProductionDbToConvertDbStep は insFnValue.isEmpty() で COPY 実行の可否を判断。
     * <p>
     * クリア：JobStartEndLIstener.afterJob；各差分メソッドで特定テーブル処理開始前。
     * <p>
     * 設定値例：insFnKey — ord_main 差分 {@code "concat_ws('',fn_plural,fn_pat_id,treat_date)"}、
     * pat_coop_detail {@code "coop_save_no"}、単一列主キー {@code " COALESCE(trim(cast(主キー as char(20)),''))"}；
     * insFnValue — シーケンスなしテーブルの場合は例えば {@code "1,2,3"}、{@code "A001,B002,C003"}。
     * <p>
     * 2変数を使用する tableName は tableSetting.yml の convert-key.config/configb/noseq に基づき、
     * 完全な一覧は ai_output/015-cursor-insFnKey与insFnValue分析.md 第7節を参照。
     */
    public String insFnKey = "";
    /**
     * insFnKey と対で使用。{@link #insFnKey} を参照。
     */
    public String insFnValue = "";

    public String keepTableName;
    // add #10859 houyulong start
    public String materialStatus = "初回";
    // add #10859 houyulong end
    public List<String> keepKeys = new ArrayList<>();

    public List<String> keepOldKeys;

    public String plan;

    /**
     * {@link #seqRegist}・{@link #seqKey} と一組：現在処理中テーブルの「シーケンスあり」主キーに対して、
     * seqKey は主キーの列名（または式）、seq は Convert DB のその列で今バッチ書き込み前の max 値、
     * seqRegist は生産 DB のその列で今バッチ書き込み前の max 値。-1 はシーケンスなし／未使用を示す。
     * <p>
     * seqKey の設定：JdbcBatchSqlItemWriter.setCondKey（主キー列または col::int）；
     * BatchCsvWriterDb は CSV タイプ（motion_record_no / master_cd / bio_moni_ctl_no 等）に応じて設定。
     * <p>
     * seq の設定：setCondKey 内で max(seqKey) from Convert DB（noseq の場合は -1）；
     * BatchCsvWriterDb の getTableMaxSeq または直接 0；Truncate 実行後に -1 を設定。
     * <p>
     * seqRegist の設定：MakeSqlStep.setUtilSqlKeys 内で生産 DB の max(seqKey) から設定；シーケンスなしの場合は -1。
     * <p>
     * 使用箇所：MakeSqlStep は seqKey is null / seqKey > seqRegist で COPY/切り捨て条件を組み立てる；
     * OrderMainDerivedDataProcessingStep は seq で ord_no > seq 等を使用；
     * ProductionDbToConvertDbStep は seqRegist == -1 で COPY 実行の可否を判断。
     * <p>
     * クリア：JobStartEndLIstener.afterJob（seq=0, seqRegist=0, seqKey="0"）。
     * <p>
     * 設定値例：seqKey {@code "ord_no"}・{@code "motion_record_no"}；
     * seq/seqRegist は 0・100・301 等、シーケンスなしの場合は -1。
     */
    public long seq = 0;
    /**
     * 生産 DB 側の現在テーブル主キーで今バッチ書き込み前の max 値。seq/seqKey と一組。{@link #seq} を参照。
     */
    public long seqRegist = 0;
    /**
     * 現在テーブルの主キー列名または式。seq/seqRegist と一組。{@link #seq} を参照。
     */
    public String seqKey = "";


    // 該当テーブルの施設存在フラグ
    public boolean hasFacilityCd = false;
    /**
     * 一、定義と意味
     * 型：String、デフォルト ""。
     * シーケンスなし（noseq）テーブルを対象に、「今バッチで Convert DB に書き込む前」の Convert DB 内
     * そのテーブルに既に存在する主キー値リスト。
     * ',' で連結した文字列で SQL の not in ('...') に使用。
     * フォーマットは key1','key2','key3（前後に引用符は付けない）。
     * <p>
     * 二、設定
     * JdbcBatchSqlItemWriter.setCondKey：テーブルが noseq の場合、Convert DB で
     * SELECT 主キー列 FROM テーブル WHERE facility_cd = ?（facility がない場合は全テーブル）を実行し、
     * 重複排除後 String.join("','", befValueList) で本フィールドに設定；setCondKey 入時にまず空にする。
     * BatchCsvWriterDb.write：CSV 書き込み前にクリア。
     * JobStartEndLIstener.afterJob：ジョブ終了時にクリア。
     * noseq テーブルのみ非空の値が設定される；シーケンスありテーブルは befKeyList に書き込まず "" を維持。
     * <p>
     * 三、使用
     * MakeSqlStep.setUtilSqlKeys：テーブルがシーケンスなし（seq が -1 以下）の場合、
     * Convert DB.テーブル で 主キー not in ('befKeyList') を条件に realData を select し、
     * 今バッチで新規書き込まれた行の fn キー値を取得し、結果を insFnValue に設定する。
     * <p>
     * 四、設定値例
     * データあり：{@code "101','102','103"}、SQL に展開すると not in ('101','102','103')。
     * データなし または noseq でない：{@code ""}。
     */
    public String befKeyList = "";

    /**
     * 一、定義と意味
     * 型：String、デフォルト ""。
     * 患者イベント（pat_event）に関連する S3 アップロード用のローカル追加ファイルが格納される
     * ディレクトリパス（ベースパス）。
     * BbsInfoService が患者イベント追加ファイルを S3 にアップロードする際に設定され、
     * ジョブ正常終了後に JobStartEndLIstener がこのパスを使ってディレクトリをクリアしてから空にする。
     * <p>
     * 二、設定
     * BbsInfoService.UploadEventAddedFiles：患者イベントの S3 アップロードファイルリストが取得でき、
     * かつ size が 0 より大きい場合、
     * addedFileBasePath = getSpecifiedPath(facilityCd, basePath, subPathKey) で本フィールドに設定。
     * JobStartEndLIstener.afterJob：ジョブ終了時に他のグローバル変数とともに "" に設定。
     * <p>
     * 三、使用
     * JobStartEndLIstener.afterJob：ジョブが正常終了した場合、本フィールドが空でなければ new File(picPath) を生成し、
     * ディレクトリが存在すれば FileUtils.cleanDirectory を実行して S3 ファイル移動後のローカルディレクトリをクリアする。
     * <p>
     * 四、設定値例
     * 設定済み：例 {@code "D:\\ExportData_xxx\\AddedFiles"}（getSpecifiedPath と subPathKey に依存）；
     * 未設定またはクリア済み：{@code ""}。
     */
    public String picPath = "";

    public Integer ErrorOrdNo;

    public boolean isThread = false;

    public Map<Long, List<OrdDevice>> ordDeviceMap = null;

    // add #10859-6 djy start
    /**
     * 現在の facility が Convert DB の batch_convert_table_status に「インポート済み」レコードを持つ
     * テーブル名のセット（table_name、かつ type_name is not null）。
     * 進捗表示時に現在のテーブルが「初回」か「追加」かを区別するために使用：
     * テーブル名が本セットに含まれれば「追加」、そうでなければ「初回」として記録；差分テーブルは固定で「差分」とする。
     * 関連ステップ：
     * - 設定：JobStartEndLIstener.beforeJob()（本フィールドが null または empty の場合、
     *   Convert DB から SELECT distinct table_name FROM batch_convert_table_status
     *   WHERE facility_cd = ? AND type_name is not null を実行し、結果を本フィールドに設定）；
     * - 使用：ProgressManagement.createConvertTableStatus(StepExecution, content) 内で
     *   tableName が本セットに含まれるかどうかに基づき typeName（初回/追加/差分）を設定。
     *   このオーバーロードは RestartStep・ProductionDbToConvertDbStep・DeleteTableInConvertDbStep・
     *   StepStartEndListener・ChunkCountListener・OrderMainDerivedDataProcessingStep 等から
     *   createConvertTableStatus(se/chunkContext, content) を通じて呼び出される；
     * - クリア：JobStartEndLIstener.afterJob()（ジョブ COMPLETED 時に null に設定）。
     * 処理フロー概要：
     * 1) ジョブ開始前の beforeJob で Convert DB から当該 facility の type_name が存在するテーブル名セットをロード；
     * 2) 各ステップまたはリスナーが progressManagement.createConvertTableStatus を呼び出す際、
     *    現在処理中のテーブルが本セットに含まれるかどうかに基づき進捗レコードの type_name を「初回」または「追加」に決定；
     * 3) ジョブ正常終了時に afterJob が本フィールドを null に設定。
     */
    public Set<String> AlreadyImportedTableSet = null;

    /**
     * pat_event テーブルの差分変換（プランB以外）において、チャンクごとに累積された
     * 「本番キー（更新レコード）」リスト。チャンク間の重複排除に使用。
     * 関連ステップ：
     * - 読み/書き：ReadSqlFileWriteDbStep（その内の JdbcBatchSqlItemWriter.deletePatEventInConvertDB：
     *   先頭で pkeyList から重複を排除し、末尾で addAll(pkeyList) を実行）；
     * - クリア：JobStartEndLIstener（init() でジョブ開始時に new ArrayList<>() に設定；
     *   afterJob() でジョブ COMPLETED 時に再度 new ArrayList<>() に設定）。
     * 処理フロー概要：
     * 1) クリア/初期化：JobStartEndLIstener.init() でジョブ開始時に new ArrayList<>() に設定；
     *    afterJob() でジョブ COMPLETED 時に再度 new ArrayList<>() に設定；
     * 2) 読み：ReadSqlFileWriteDbStep 内の JdbcBatchSqlItemWriter.deletePatEventInConvertDB の先頭で、
     *    pkeyList から本リストに既に存在するキーを除去し、同一更新キーに対する Convert DB 削除と
     *    deleteFiles の重複実行を防ぐ；
     * 3) 書き：deletePatEventInConvertDB の末尾で globalContext.updateKeyList.addAll(pkeyList) を実行し、
     *    現在チャンクの更新キーをリストに追加；
     * 4) 呼び出しタイミング：realTableName が "pat_event" かつ差分の else 分岐（プランB以外）を通る場合のみ
     *    deletePatEventInConvertDB(rs5, keyInsList) を呼び出す。rs5 は本番のキー（更新レコード）。
     */
    public List<String> updateKeyList = new ArrayList<>();

    /**
     * 現在の facility における Convert DB の mst_machine テーブルデータのキャッシュ（メモリリスト）。
     * CSV インポート（mnt_motion_record 等）の際に fn_device_no + fn_class_cd で機器を検索し、
     * machine_type_cd・machine_serial・com_format_cd 等を取得して CSV 列から DB へのマッピングを行うために使用。
     * 毎回クエリを実行する必要がなくなる。
     * 関連ステップ：
     * - 設定/使用：ReadSqlFileWriteDbStep（その内の BatchCsvWriterDb.write()：.csv 処理時にリストが空の場合は
     *   Convert DB から mst_machine をロードして本フィールドに設定；processMntMotionRecord 内で
     *   getMachineTypeCdTrastMap・getMachineSerialTrastMap・getComFormatCdTrastMap を通じて本リストを読み込み
     *   mnt_motion_record を書き込む）；
     * - クリア：JobStartEndLIstener（init() でジョブ開始時に new ArrayList<>() に設定；
     *   afterJob() でジョブ終了時に clear()）。
     * 処理フロー概要：
     * 1) クリア/初期化：JobStartEndLIstener.init() でジョブ開始時に new ArrayList<>() に設定；
     *    afterJob() でジョブ終了時に clear()；
     * 2) 設定：ReadSqlFileWriteDbStep 内の BatchCsvWriterDb が任意の .csv ファイルを処理する際、
     *    本リストが null または empty であれば Convert DB から mst_machine をクエリ（WHERE facility_cd = ?）して
     *    本フィールドに設定し、同ジョブ内の後続 CSV 処理で再利用できるようにする；
     * 3) 使用：BatchCsvWriterDb.processMntMotionRecord 内で getMachineTypeCdTrastMap・
     *    getMachineSerialTrastMap・getComFormatCdTrastMap を通じて本リストを読み込み、
     *    fn_device_no と fn_class_cd でフィルタリングして唯一の機器を特定し、
     *    マッピングを生成後 mnt_motion_record データを書き込む。
     */
    public List<MstMachine> MstMachineList = new ArrayList<>();;

    /**
     * 生産 DB（NKK5）において「今バッチの Convert→生産」実行前の時点で、
     * 現在処理中テーブルのこの facility における最大主キー（または関連シーケンス）値。
     * 差分時の「生産→Convert」ステップで allDeleteAllInsertList テーブルに対し、
     * 今バッチで生産側に新たに生成されたレコード（主キー > この値）のみを拷い戻すために使用。
     * 関連ステップ：
     * - 設定：ConvertDbToProductionDbStep（Convert→生産 COPY を実行する前に getSeqOfEachTable(tableName) を呼び出し、
     *   pat_event / pat_ind_approve_history / pat_treatment_pattern に対して生産 DB から
     *   max(主キー) またはシーケンスの last_value を取得して本フィールドに設定）；
     * - 使用：ProductionDbToConvertDbStep（差分時の生産→Convert で、pat_event・pat_ind_approve_history に対し
     *   主キー > 本フィールド の条件で拷い戻す）；
     * - クリア：JobStartEndLIstener（afterJob かつジョブ COMPLETED 時に 0 に設定）。
     * 処理フロー概要：
     * 1) 設定：ConvertDbToProductionDbStep が pat_event / pat_ind_approve_history / pat_treatment_pattern を
     *    処理する際、Convert→生産 COPY を実行する前に getSeqOfEachTable(tableName) を呼び出し、生産 DB から
     *    現在の max(主キー) またはシーケンスの last_value を取得して本フィールドに設定
     *    （pat_treatment_pattern では ntss.ord_main_ord_no_seq の last_value を取得するが、
     *    本フィールドはその後そのテーブルの生産→Convert には使用されない）；
     * 2) その後 ConvertDbToProductionDbStep が Convert→生産 COPY を実行し、
     *    今バッチのデータが生産 DB に書き込まれる；
     * 3) 使用：ProductionDbToConvertDbStep（差分）の生産→Convert 時、pat_event と pat_ind_approve_history に対してのみ
     *    本フィールドを使用し、条件をそれぞれ pat_event_cd > 本フィールド・ind_approve_history_no > 本フィールドとして
     *    生産側で主キーが最大値より大きい行のみを拷い戻す。
     * 注：本フィールドは ConvertDbToProductionDbStep 内で「現在処理中のテーブル」ごとに上書きされる。
     * そのため「各ファイル/各テーブルが完全なパイプラインを実行する」ジョブ順序に依存する。
     * ProductionDbToConvertDbStep で使用される際の本値は、そのテーブルの Convert→生産前の生産側の最大主キーとなる。
     */
    public Integer maxPrimaryForDB5;

    /**
     * Convert DB における allDeleteAllInsertList テーブル（pat_event・pat_ind_approve_history）での
     * 今回書き込み前の、この facility における最大主キー値。
     * 差分変換時に「今バッチで書き込まれたばかりのレコード群」を特定するために使用。
     * 関連ステップ：
     * - 設定：ReadSqlFileWriteDbStep（その内の JdbcBatchSqlItemWriter が pat_event / pat_ind_approve_history の
     *   書き込み前に getMaxPrimaryOfAllDeleteAllInsertTables を通じて Convert DB から max(主キー) を取得して
     *   本フィールドに設定）；BatchCsvWriterDb.processPatExamMain も本フィールドを設定する（exam_main_cd）、
     *   pat_exam_main に使用；
     * - 使用：ConvertDbToProductionDbStep（差分時の Convert→生産で 主キー > 本フィールド を条件に拷う；
     *   その内の PatEventService.UploadEventAddedFiles は pat_event_cd > 本フィールド で pat_event をクエリする）、
     *   TruncateTableStep（差分時に Convert DB の 主キー > 本フィールド のレコードを削除する）；
     * - クリア：JobStartEndLIstener（afterJob かつジョブ COMPLETED 時に 0 に設定）。
     * 処理フロー概要：
     * 1) ReadSqlFileWriteDbStep 内の JdbcBatchSqlItemWriter が pat_event または pat_ind_approve_history を
     *    処理する際、書き込み前に Convert DB から max(pat_event_cd) または max(ind_approve_history_no) を
     *    取得して本フィールドに設定；
     * 2) その後今バッチのデータを Convert DB に書き込む；
     * 3) ConvertDbToProductionDbStep（差分）：Convert DB から生産へ拷う際の条件は
     *    pat_event_cd > 本フィールド（または ind_approve_history_no > 本フィールド）とし、
     *    今バッチで新規書き込まれたレコードのみを拷う；
     *    その内の PatEventService は pat_event_cd > 本フィールド で pat_event をクエリする；
     * 4) TruncateTableStep：Convert DB の 主キー > 本フィールド のレコードを削除して、
     *    今バッチですでに拷い終えたレコードを削除する。
     * 注：BatchCsvWriterDb.processPatExamMain も本フィールドを設定する（exam_main_cd）、
     * pat_exam_main 関連ロジックに使用。
     */
    public Integer maxPrimaryForConvert;

    /**
     * Convert DB における ord_prescription テーブルの現在（今回拷い込む前）の、
     * この facility における最大 ord_prescription_no（処方番号）。
     * 主に ord_prescription テーブルのデータ変換時の派生データ生成（ord_material_save 等）に使用。
     * 関連ステップ：
     * - 設定：ProductionDbToConvertDbStep（ord_prescription 処理時に「生産→Convert」COPY を実行する前に
     *   Convert DB から max(ord_prescription_no) を取得して本フィールドに設定）；
     * - 使用：OrderMainDerivedDataProcessingStep（ord_prescription_no > 本フィールド かつ is_del='0' で
     *   「今バッチで新規拷い込まれた ord_prescription」を絞り込み、これらのレコードに対してのみ
     *   sendOrdRPMaterialSaveProcess を呼び出して ord_material_save 派生処理を実行）。
     * 処理フロー概要：
     * 1) ProductionDbToConvertDbStep が ord_prescription を処理する際、「生産→変換」COPY を実行する前に
     *    Convert DB から max(ord_prescription_no) を取得して本フィールドに設定；
     * 2) その後 COPY を実行し、今バッチの ord_prescription が Convert DB に書き込まれる；
     * 3) OrderMainDerivedDataProcessingStep が ord_prescription_no > 本フィールド（かつ is_del='0'）で
     *    「今バッチで新規拷い込まれた ord_prescription」を絞り込み、これらのレコードに対してのみ
     *    sendOrdRPMaterialSaveProcess を呼び出して ord_material_save 派生処理を実行する。
     */
    public Integer convertOpSeq;

    // add #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe start
    /**
     * Convert DB における mst_comsv_setting の device_edge_no と fn_comsv_no のマッピングリスト。
     * 各エントリのフォーマットは "device_edge_no,fn_comsv_no"。
     * 関連ステップ：
     * - 設定：ReadSqlFileWriteDbStep（その内の JdbcBatchSqlItemWriter が mst_comsv_setting を処理する際に
     *   processMstComsvSettingDiff または updateMstComsvSettingDeviceEdgeNo が Convert DB から
     *   device_edge_no・fn_comsv_no をクエリして本リストを構築）；
     * - 使用：ProductionDbToConvertDbStep（生産→Convert COPY 完了後、本リストが空でない場合は
     *   device_edge_no でマッチングして fn_comsv_no を Convert DB の mst_comsv_setting に書き戻す）；
     *   ReadSqlFileWriteDbStep（その内の JdbcBatchSqlItemWriter.updateMstComsvSettingDeviceEdgeNo が
     *   device_edge_no を割り当てる際に usedNos から本リスト内の device_edge_no を除外する）；
     * - クリア：JobStartEndLIstener（init() で new ArrayList<>() に設定）。
     * 処理フロー概要：
     * 1) ReadSqlFileWriteDbStep 内の JdbcBatchSqlItemWriter が mst_comsv_setting を処理する際
     *    （processMstComsvSettingDiff または updateMstComsvSettingDeviceEdgeNo）、
     *    Convert DB から device_edge_no・fn_comsv_no をクエリして本リストを構築；
     * 2) その後 ConvertDbToProductionDbStep（変換→生産 COPY）・TruncateTableStep・
     *    ProductionDbToConvertDbStep（生産→変換 COPY）を実行；
     * 3) ProductionDbToConvertDbStep が生産→変換 COPY 完了後、本リストが空でない場合は
     *    device_edge_no でマッチングして fn_comsv_no を Convert DB の mst_comsv_setting に書き戻し、
     *    COPY によって上書きされた fn_comsv_no を復元する（#12230）；
     * 4) JdbcBatchSqlItemWriter.updateMstComsvSettingDeviceEdgeNo が device_edge_no を割り当てる際に
     *    usedNos から本リスト内の device_edge_no を除外して Convert DB で既に使用済みのものとの競合を防ぐ。
     */
    public List<String> convertComsvList = new ArrayList<>();
    // add #12230 差分コンバートにより元に戻ってしまう項目がある limingzhe end

    public String facilityName;

    public String tmpCopyCsvDir;

    public Integer deviceEdgeNo;

    /**
     * add #12229 ord_weight_scale start
     */
    public boolean loaded = false;
    public Map<String, Integer> patIdMap = new HashMap<>();
    public Map<String, Integer> bedCdMap = new HashMap<>();
    public Map<String, Integer> weightCdMap =new HashMap<>();
    public Map<String, Integer> kurCdMap =new HashMap<>();
    public Map<String, Integer> machineNoMap= new HashMap<>();
    public Map<String, Integer> treatmentCdMap= new HashMap<>();
    public Map<String, Integer> ordNoMap= new HashMap<>();
    public Map<String, Integer> wheelChairCdMap= new HashMap<>();;
    public Map<String, Integer> userIdMap= new HashMap<>();
    // add #12229 ord_weight_scale end

    //add #12229->12380 start
    public Set<Integer> mstTreatmentSet = new HashSet<>();
    //add #12229->12380 end
}
