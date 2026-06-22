package jp.co.nikkiso.ntss.coop_api.service;

import java.util.List;

import jp.co.nikkiso.ntss.api.model.JournalCreateRequestPayload;
import org.springframework.scheduling.annotation.Async;

/**
 * JSON形式データをトランザクションテーブルに反映するサービスインタフェース。
 */
import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult.ResultMap;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;

/**
 * JSON形式データ（多段マップ）登録のAPIを規定するインタフェース。
 */
public interface RegisterService {

  /**
   * JSON形式データをトランザクションテーブルに反映する。
   * @param facilityCd 施設コード
   * @param direction 向き（送受信）
   * @param jsonList JSON形式データ（複数テーブル分）
   * @param journalList
   */
  // mod #5607 連動機能の実装確認 20230103 孟堅 start
  //void register(String facilityCd, String direction, List<ResultMap> jsonList);
  void register(String facilityCd, String direction, List<ResultMap> jsonList,List<SysCoopJournal> journalList);
  // mod #5607 連動機能の実装確認 20230103 孟堅 end

  //add #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi start
  void deathRelatedBusiness(String facilityCd, List<JournalCreateRequestPayload> scForCheckList) throws Exception;
  //add #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi end
  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
  @Async
  void setDataToMongo(SysCoopJournal journal);
  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end
}
