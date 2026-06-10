package jp.co.nikkiso.ntss.admin_web.service.sysDataListDetail;

import jp.co.nikkiso.ntss.admin_web.response.sysDataListDetail.SysDataListDetailResponse;
import jp.co.nikkiso.ntss.core.entity.MstExamItem;
import jp.co.nikkiso.ntss.core.entity.MstWaterSurveyPointType;
import jp.co.nikkiso.ntss.core.entity.SysDataListCategory;

import java.util.List;
import java.util.Map;

/**
 * データリストカテゴリ詳細Serviceインタフェース.
 */
public interface SysDataListDetailService {

 /**
   * マスタに表示用のデータリストカテゴリ詳細項目を取得
   * @throws Exception
   */
 List<SysDataListDetailResponse> getDataListItemDisplayMaster(Integer templateCd, String facilityCd) throws Exception;

 /**
  * 該当機能に表示用のデータリストカテゴリ詳細項目を取得
  * @throws Exception
  */
 List<SysDataListDetailResponse> getDataListItemDisplayFuntion(Long patListLayoutCd, String facilityCd) throws Exception;

 /**
  * 各セルに表示するデータを取得
  * @throws Exception
  */
 Object getCellData(Long dataListDetailCd, Map<String, Object> dataKey) throws Exception;

  /* add by zhaohan 2022-11-16 [6543] 集計のテンプレートを表示すると、DBへの負荷がかかる。 --start */
  /**
   * 各行ルに表示するデータを取得
   * @throws Exception
   */
  Object getRowData(Long dataListDetailCd, Map<String, Object> dataKey) throws Exception;
  /* add by zhaohan 2022-11-16 [6543] 集計のテンプレートを表示すると、DBへの負荷がかかる。 --end */

// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou start
 /**
  * 該当機能に表示用のデータリストカテゴリ詳細項目を取得
  * @throws Exception
  */
 Map<String, Object> getTemplateValue(List<Long> patIdList, String facilityCd, String startDate, String endDate, Integer templateCd) throws Exception;

  //No.7167 upd Paging Optimization runtime by ztc start
 /**
   * 該当機能に表示用のデータリストカテゴリ詳細項目を取得
   * @throws Exception
   */
  Map<String, Object> getTemplateValue(List<Long> patIdList, String facilityCd, String startDate, String endDate,
                                       Integer templateCd, Integer offset, Boolean isOnlyRst) throws Exception;
//No.7167 upd Paging Optimization runtime by ztc end
 /**
  * 該当機能に表示用のデータリストカテゴリ詳細項目を取得
  * @throws Exception
  */
 List<SysDataListCategory> getTitleName(Integer templateCd);

 Map<String, Object> getInitData(Integer templateCd, String facilityCd);

 Map<String, Object> getListData(Integer templateCd, String facilityCd, String startDate, String endDate) throws Exception;
// add FNSI-No.223 テンプレートおよび項目の不足、特定データの編集保存に対応。身体情報は新規追加に対応 dou end
/*add FNSI-改修内容5237 任 start*/
  List<MstExamItem> getFigureValue(String facilityCd);
  List<MstWaterSurveyPointType> getDecimalValue(String facilityCd);
  /*add FNSI-改修内容5237 任 end*/
}
