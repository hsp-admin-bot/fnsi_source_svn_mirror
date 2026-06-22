package jp.co.nikkiso.ntss.admin_web.service.indHistory;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

/**
 * 
 *指示履歴サービス
 */
public interface IndHistoryService {
/**
 * すべて選択
 * @param pageable
 * @param params
 * @param options
 * @return
 */
  Page<IndHistory> findAll(Pageable pageable, IndHistory params, IndHistoryOptions options);
  /**
   * mongoDbに指示を作成
   * @param params
   * @return
   */
  IndHistory create(IndHistory params);
  /**
   * MongoDBで条件検索で指示を検索する
   * @param params
   * @return
   */
  List<IndSearchResult> searchByFilter(IndicationSearch params);
  /**
   * 指示一覧で更新する
   * @param params
   * @return
   */
  boolean updateIndHistoryInListScreen(IndListUpdateCondition params);
  /**
   * 指示詳細画面で更新する
   * @param params
   * @return
   */
  boolean updateIndHistoryInDetailScreen(List<IndDetailUpdateCondition> params);
  // #11205 -ペンテスト2－4認可制御の不備  add 20260427 start
  /**
   * 指示詳細画面で更新する
   * @param params
   * @param facilityCd ログインユーザー施設
   * @return
   */
  boolean updateIndHistoryInDetailScreen(List<IndDetailUpdateCondition> params, String facilityCd);
  // #11205 -ペンテスト2－4認可制御の不備  add 20260427 end
  /**
   * 指示を取得
   * @param params _ids
   * @return
   */
  List<IndHistory> getIndHistoryDetail(List<String> params);


  int createBatch(List<IndHistory> paramsList);
}
