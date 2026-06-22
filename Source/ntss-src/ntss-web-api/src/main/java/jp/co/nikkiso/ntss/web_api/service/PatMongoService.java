package jp.co.nikkiso.ntss.web_api.service;

import jp.co.nikkiso.ntss.core.entity.PatInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatInsuInfo;

import java.util.List;

//add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 start
public interface PatMongoService {

  void setPatDataToMongoHistory(PatInfo patInfo) throws Exception;

  void updateBulkUpdatePatInsu(List<PatInsuInfo> patInsuInfos) throws Exception;

  // add #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhao start
  void setPatIsSameDataToMongoHistory(PatInfo patInfo) throws Exception;
  // add #10436 同姓同名フラグの更新時に対になる患者のpat_main_historyがinsertされていない zhao end

  //  add 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  start
  void updateUpdatePatInsu(List<PatInsuInfo> patInsuInfos) throws Exception;
  //  add 10525 保険区分が「セット」のときクラス「処方情報」が出力できない 関  end

  // add 10626 データリストのCTR・DW一括登録修正 房 start
  void updateAndInsertPatsInfoToMongo(List<PatInfo> patsInfo) throws Exception;
  // add 10626 データリストのCTR・DW一括登録修正 房 end
}
//add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 end
