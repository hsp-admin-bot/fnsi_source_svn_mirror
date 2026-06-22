package jp.co.nikkiso.ntss.admin_web.service.reportDesigner;

import java.util.List;
import java.util.Map;

import jp.co.nikkiso.ntss.admin_web.service.reportDesigner.dto.MedicineDto;
import jp.co.nikkiso.ntss.admin_web.service.reportDesigner.dto.PatEventCategoryDto;
import jp.co.nikkiso.ntss.admin_web.service.reportDesigner.dto.ReceiptDto;
import jp.co.nikkiso.ntss.core.entity.MstMachineType;
import jp.co.nikkiso.ntss.core.entity.MstMainteCategoryAndDetail;
import jp.co.nikkiso.ntss.core.entity.MstMenteDetail;
import jp.co.nikkiso.ntss.core.entity.MstSelector;

/**
 * 帳票レイアウトデザイナのServiceインタフェース.
 */
public interface ReportDesignerService {

  /**
   * MstSelectorからマスタ
   * @param facilityCd
   * @param tableName
   * @return
   */
  List<MstSelector.Item> getMaster(String facilityCd, String tableName);

  /**
   * 患者イベントカテゴリ＋サブカテゴリのマスタ情報を返す
   * @param facilityCd
   * @return
   */
  List<PatEventCategoryDto> getPatEventCategory(String facilityCd);

  /**
   * 薬剤マスタ情報を返す
   * @param facilityCd
   * @param medflag 0:all 1:通常薬剤 2:調製薬剤
   * @return
   */
  // mod #11832 準備リスト.物品情報(薬剤)の調製薬剤フィルタは不要 limingzhe start
  //List<MedicineDto> getMedicine(String facilityCd);
  List<MedicineDto> getMedicine(String facilityCd, Integer medflag);
  // mod #11832 準備リスト.物品情報(薬剤)の調製薬剤フィルタは不要 limingzhe end

  // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe start
  /**
   * レセプト情報を返す
   * @param facilityCd
   * @return
   */
  List<ReceiptDto> getReceipt(String facilityCd);
  // add #11494 データセットにカテゴリ「レセプト」を追加 limingzhe end

  // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
  /**
   * 点検項目詳細を装置番号に対応する型式で絞り込んで取得
   *
   * @param facilityCd 施設コード
   * @param layoutClass 用途 1:日常点検用 2:定期点検用
   * @return リストの詳細
   * @throws Exception
   */
  // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
  //List<MstMenteDetail> getInspection(String facilityCd, Long mainteLayoutCd, Long mainteRecordType)
  List<MstMainteCategoryAndDetail> getInspection(String facilityCd, String layoutClass)
  // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
    throws Exception;
  // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end

  // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
  /**
   * 型式マスタの情報を返す
   *
   * @param facilityCd 施設コード
   * @param layoutClass 用途 1:日常点検用 2:定期点検用
   * @return リストの詳細
   * @throws Exception
   */
  List<MstMachineType> getMachineType(String facilityCd, String layoutClass)
    throws Exception;
  // add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

  // add #12585 水質管理.水質検査のフィルタ処理仕様修正　高　start
  List<Map<String, Object>> getWaterSurveyPoint(String facilityCd, String machineTypeCd) throws Exception;
  // add #12585 水質管理.水質検査のフィルタ処理仕様修正　高　end

  /* add by yuqinlong  2023-01-31 [CodeOptimization]  start */
  List<Map<String, Object>> getMatrixTest(Long sqlCode, Map<String, Object> dataKey);
  /* add by yuqinlong  2023-01-31 [CodeOptimization]  end */

  /**
   * 帳票ファイルを取得する
   * @param reportCd
   * @return
   */
  public byte[] getReportFile(long reportCd);

}
