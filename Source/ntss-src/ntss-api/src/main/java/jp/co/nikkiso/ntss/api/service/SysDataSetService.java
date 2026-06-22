package jp.co.nikkiso.ntss.api.service;

import java.util.List;
import java.util.Map;
import java.util.concurrent.Future;

import jp.co.nikkiso.ntss.api.service.SysDataSetServiceImpl.UseApplication;
import jp.co.nikkiso.ntss.core.entity.SysDataSet;

/**
 * SysDataSetの定義に基づいてデータを取得するServiceインタフェース.
 */
public interface SysDataSetService {

  /**
   * データの取得.
   *
   * @param sqlCode SqlCode
   * @param dataKey データキー
   * @return 取得したデータ
   */
  List<Map<String, Object>> getDataList(Long sqlCode, Map<String, Object> dataKey);


  /**
   * sys_data_setから帳票で扱うレコードを取得する.
   *
   * @return 帳票で扱うレコード
   */
  List<SysDataSet> selectForReport();


  /**
   * 二次元帳票用データの取得
   *
   * @param reportInfo      変換元データ
   * @param rowFieldName    行配置データフィールド名リスト配列
   * @param colFieldName    列配置データフィールド名リスト配列
   * @param valFieldName    配置データフィールド名リスト配列
   * @return 変換後データ
   */
  List<Map<String, Object>> getMatrixDataList(List<Map<String, Object>> reportInfo, List<String> rowFieldName, List<String> colFieldName, List<String> valFieldName);
 /**
   * データの取得
   * ※使用用途によるチェック
   *
   * @param sqlCode SqlCode
   * @param dataKey データキー
   * @param targetApplication 呼出元の使用用途
   * @return 取得したデータ
   */
  List<Map<String, Object>> getDataList(Long sqlCode, Map<String, Object> dataKey, UseApplication targetApplication);

  // ins 2021-04-07 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 ウ start
  /**
   * データの登録
   * ※使用用途によるチェック
   *
   * @param sqlCode SqlCode
   * @param dataKey データキー
   * @param targetApplication 呼出元の使用用途
   * @return 処理件数
   */
  Integer insertData(Long sqlCode, Map<String, Object> dataKey, UseApplication targetApplication);

  /**
   * データの更新
   * ※使用用途によるチェック
   *
   * @param sqlCode SqlCode
   * @param dataKey データキー
   * @param targetApplication 呼出元の使用用途
   * @return 処理件数
   */
  Integer updateData(Long sqlCode, Map<String, Object> dataKey, UseApplication targetApplication);

  /**
   * データの削除
   * ※使用用途によるチェック
   *
   * @param sqlCode SqlCode
   * @param dataKey データキー
   * @param targetApplication 呼出元の使用用途
   * @return 処理件数
   */
  Integer deleteData(Long sqlCode, Map<String, Object> dataKey, UseApplication targetApplication);
  // ins 2021-04-07 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 ウ end

  /**
   * サーバ内でsys_data_setをコールするapi
   * ※使用用途によるチェック
   *
   * @param sqlCode SqlCode
   * @param dataKey データキー
   * @return 取得したデータ
   */
  Map<String, Object> getResultCnt(Long sqlCode, Map<String, Object> dataKey);


  /**
   * マージキーの取得
   *
   * @param sqlCode SqlCode
   * @return マージキー
   */
  String getMergeKeyForSqlCode(Long sqlCode);

  // add 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 start
  /**
   * データの取得(エラー情報を含む)
   * ※使用用途によるチェック
   *
   * @param sqlCode SqlCode
   * @param dataKey データキー
   * @param targetApplication 呼出元の使用用途
   * @return 取得したデータ
   */
  List<Map<String, Object>> getDataListContainsError(Long sqlCode, Map<String, Object> dataKey, UseApplication targetApplication);


  // add 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 start
  /**
   * データの取得(エラー情報を含む)
   * ※使用用途によるチェック
   *
   * @param sqlCode SqlCode
   * @param dataKey データキー
   * @param targetApplication 呼出元の使用用途
   * @return 取得したデータ
   */
  List<Map<String, Object>> getDataListContainsError(Long sqlCode, Map<String, Object> dataKey, UseApplication targetApplication, int noderedTimeOut);


  //#dev 6304 ローカルDBへの登録に失敗する sichengbo start
  /**
   * データの取得(エラー情報を含む)
   * ※使用用途によるチェック
   *
   * @param sqlCode SqlCode
   * @param dataKey データキー
   * @param targetApplication 呼出元の使用用途
   * @param limit 1回に何本
   * @param num 何度目
   * @return 取得したデータ
   */
  List<Map<String, Object>> getDataListSpecialTreatment(Long sqlCode, Map<String, Object> dataKey,
                                                        UseApplication targetApplication, int limit, int num);
  //#dev 6304 ローカルDBへの登録に失敗する sichengbo end

  /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
  // /**
  //  * マージキーの取得
  //  *
  //  * @return マージキー
  //  */
  // String GetMergeKey();
  /* del by chamaojia 2026-05-13 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */
  // add 2021-01-28 No.737:NEC電子カルテはWEBAPIを提供するため、対応する必要。 孫 end

  /**
   * データの取得(エラー情報を含む)
   * ※使用用途によるチェック
   * ※帳票種別：02：単患者帳票 用の処理です
   *
   * @param sqlCodes SqlCodeのリスト
   * @param dataKey データキー
   * @return 取得したデータ
   */
  Map<Long, List<Map<String, Object>>> getSqlDataForOnePatient(List<String> sqlCodes, Map<String, Object> dataKey);

  // add 10309 治療記録画面での透析レポートの表示に時間かかる場合がある 吉 start
  Future<List<Map<String, Object>>> getDataListAsync(Long sqlCode, Map<String, Object> dataKey,
                                                     UseApplication targetApplication);
  // add 10309 治療記録画面での透析レポートの表示に時間かかる場合がある 吉 end

  // add #10605 【デグレ】観察記録がテンプレート繰返しされない limingzhe start
  /**
   * サーバ内でsys_data_setをコールするapi
   * ※使用用途によるチェック
   *
   * @param sqlCode SqlCode
   * @return 取得したデータ
   */
  boolean distinParaOnlybyPatId(Long sqlCode);
  // add #10605 【デグレ】観察記録がテンプレート繰返しされない limingzhe end

  // add #10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない 杜天成 start
  /**
   * サーバ内でsys_data_setをコールするapi
   * ※使用用途によるチェック
   *
   * @param sqlCode SqlCode
   * @return 取得したデータ
   */
  boolean distinParaOnlybyOrdNos(Long sqlCode);
  // add #10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない 杜天成  end

  // add #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
  /**
   * サーバ内でsys_data_setをコールするapi
   * ※使用用途によるチェック
   *
   * @param sqlCode SqlCode
   * @param strParam Param
   * @return 取得したデータ
   */
  boolean distinParaOnlybyParam(Long sqlCode, String strParam);
  // add #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end

  // add #11172 患者情報系historyの取得条件見直し limingzhe start
  /**
   * サーバ内でsys_data_setをコールするapi
   * ※使用用途によるチェック
   *
   * @param sqlCode SqlCode
   * @return 取得したデータ
   */
  boolean isMongDBSqlSearch(Long sqlCode);
  // add #11172 患者情報系historyの取得条件見直し limingzhe end

  // add #10740 指示.修正内容の出力不正 sunsy start
  /**
   * サーバ内でsys_data_setをコールするapi
   * ※使用用途によるチェック
   *
   * @param sqlCode SqlCode
   * @return 取得したデータ
   */
  boolean isIndHistorySqlSearch(Long sqlCode);
  // add #10740 指示.修正内容の出力不正 sunsy end

  // add #11226 患者情報系historyの取得条件見直し② limingzhe start
  /**
   *
   * @param sql Sql
   * @return 取得したデータ
   */
  List<Map<String, Object>> sqlDB5Search(String sql);
  // add #11226 患者情報系historyの取得条件見直し② limingzhe end
}
