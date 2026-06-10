package jp.co.nikkiso.ntss.admin_web.service.mente;

import java.util.List;
import java.util.Map;

import org.apache.commons.collections4.map.HashedMap;

import jp.co.nikkiso.ntss.core.entity.DevMenteMain;
import jp.co.nikkiso.ntss.core.entity.MstMachineType;
import jp.co.nikkiso.ntss.core.entity.MstMenteDetail;
import jp.co.nikkiso.ntss.core.entity.MstMenteLayout;

/**
 * 検査レイアウトのServiceインタフェース.
 */
public interface MstMenteLayoutService {

  /**
   * クラスごとにレイアウトリストを取得
   *
   * @param facilityCd  施設コード
   * @param layoutClass レイアウトのタイプ
   * @return レイアウトリスト
   */
  List<MstMenteLayout> getLayoutsListByClass(String facilityCd, String layoutClass);

  /**
   * 日常点検画面で表示するレイアウトリストを取得
   *
   * @param facilityCd 施設コード
   * @param mainteDate 点検日（YYYY-MM-DD）
   * @return レイアウトリスト
   */
  List<MstMenteLayout> getDailyLayoutListWithDate(
      String facilityCd, String mainteDate)
      throws Exception;

  /**
   * 指定のグループを持つ日常点検用レイアウトリストを取得
   *
   * @param facilityCd 施設コード
   * @param mainteCategoryCd 点検グループコード
   * @return レイアウトリスト
   */
  List<MstMenteLayout> getDailyLayoutListWithCategoryCd(
      String facilityCd, Long mainteCategoryCd)
      throws Exception;

  /**
   * （日常点検用）レイアウトポップアップで表示する情報を取得
   *
   * @param facilityCd 施設コード（NTSS認証ユーザの施設コード）
   * @param mainteLayoutCd 点検レイアウトコード
   * @return 点検レイアウトが持つ点検グループ、点検項目の情報
   * @throws Exception
   */
  HashedMap<String, Object> getLayoutDetailForDaily(
      String facilityCd, Long mainteLayoutCd)
      throws Exception;

  /**
   * 日常点検のレイアウトの点検項目リストを取得
   *
   * @param facilityCd 施設コード
   * @param mainteLayoutCd 検査レイアウトコード
   * @return 点検項目リスト
   * @throws Exception
   */
  List<MstMenteDetail> getListDetailInLayoutForDailyInspection(
      String facilityCd, Long mainteLayoutCd)
      throws Exception;
  /**
   * 日常点検のレイアウトの点検項目リストを装置番号に対応する型式で絞り込んで取得
   *
   * @param facilityCd 施設コード
   * @param mainteLayoutCd 検査レイアウトコード
   * @param machineNo 装置番号
   * @return 点検項目リスト
   * @throws Exception
   */
  List<MstMenteDetail> getListDetailInLayoutForDailyInspection(
      String facilityCd, Long mainteLayoutCd, Long machineNo)
      throws Exception;

  /**
   * （日常点検用）グルーㇷ゚の対象型式重複排除処理を行った
   * レイアウトマスタリストを取得する
   *
   * @param layoutList 型式重複排除前のレイアウトマスタリスト
   * @return 型式重複排除後のレイアウトマスタリスト
   * @throws Exception
   */
  List<MstMenteLayout> modifyLayoutListTypeOverlap(
      List<MstMenteLayout> layoutList) throws Exception;

  /**
   * （日常点検用）グルーㇷ゚の対象型式重複排除処理を行った
   * レイアウトマスタを取得する
   *
   * @param layout 型式重複排除前のレイアウトマスタ
   * @return 型式重複排除後のレイアウトマスタ
   * @throws Exception
   */
  MstMenteLayout modifyLayoutTypeOverlap(
      MstMenteLayout layout) throws Exception;

  /**
   * （日常点検用）点検項目入力画面用の点検項目マスタ情報を取得する
   *
   * @param machineNo 装置番号
   * @param mainteDate 点検日
   * @param facilityCd 施設コード
   * @return 点検項目マスタ情報
   * @throws Exception
   */
  List<HashedMap<String, Object>> getListDetailForDailyShowDetail(
      Long machineNo, String mainteDate, String facilityCd)
      throws Exception;

  /**
   * （日常点検用）点検履歴画面用の点検項目マスタ情報を取得する
   *
   * @param machineNo 装置番号
   * @param mainteDate 点検日
   * @param facilityCd 施設コード
   * @param numOfMonth 過去月数
   * @return 点検項目マスタ情報
   * @throws Exception
   */
  List<HashedMap<String, Object>> getListDetailForDailyShowDetailHistory(
      Long machineNo, String mainteDate, String facilityCd, Integer numOfMonth)
      throws Exception;

  /**
   * 装置マスタで設定されているもののみに絞った
   * 型式マスタリストの取得
   *
   * @param facilityCd 施設コード
   * @return 型式マスタリスト
   */
  List<MstMachineType> getListMachineTypes(String facilityCd);

  /**
   * 定期ショー詳細のリスト詳細を取得
   *
   * @param facilityCd         施設コード
   * @param menteLayoutCd      検査レイアウトコード
   * @param menteLayoutGroupCd 検査レイアウトグループコード
   * @param machineTypeCd      マシンタイプ
   * @return 定期ショー詳細のリスト詳細
   * @throws Exception
   */
  HashedMap<String, Object> getListDetailForPeriShowDetail(String facilityCd, Long mainteMainNo,
      Long menteLayoutGroupCd, String machineTypeCd) throws Exception;

  /**
   * 定期的な計画リスト詳細を取得
   *
   * @param facilityCd   施設コード
   * @param mainteMainNo 検査結果コード
   * @return 定期的な計画リスト詳細
   * @throws Exception
   */
  // mod FNSI-改修内容 点検項目入力の表示順を修正する 趙慧敏 start
  // HashedMap<String, Object> getListDetailForPeriodicPlaned(Long mainteMainNo) throws Exception;
  HashedMap<String, Object> getListDetailForPeriodicPlaned(Long mainteMainNo,String facilityCd) throws Exception;
  // mod FNSI-改修内容 点検項目入力の表示順を修正する 趙慧敏 end

  /**
   * 定期点検の点検結果レコードを作成する
   *
   * @param facilityCd 施設コード
   * @param machineInfoAndDateList マシン情報と日付リスト
   * @param menteLayoutGroupCd 検査レイアウトグループコード
   * @return 点検日＋装置番号＋レイアウトグループコードが既存のレコードと重複するものがあった場合はその点検結果レコードのリスト
   * @throws Exception
   */
  List<DevMenteMain> createListMenteMainTemporaryForPeriodic(
      String facilityCd, Map<String, Object> machineInfoAndDateList,
      Long menteLayoutGroupCd) throws Exception;

  /**
   * カテゴリコードリストと装置番号に対応する点検項目リストを取得
   *
   * @param strCategoryIdList
   * @param facilityCd 施設コード
   * @param machineNo 装置番号
   * @return 点検項目リスト
   * @throws Exception
   */
  List<MstMenteDetail> getListDetailByCategoryIdList(String strCategoryIdList, String facilityCd, Long machineNo)
      throws Exception;

  /**
   * レイアウトグループ内のマシンのマッピングとレイアウトコードの取得
   *
   * @param listLayouts
   *          レイアウトグループのリストレイアウト
   * @param machineTypeCd
   *          マシンタイプコード
   * @return レイアウトコード
   * @throws Exception
   */
  Long getLayoutIdOfMachineInLayoutGroup(List<MstMenteLayout> listLayouts, String machineTypeCd)
      throws Exception;
}
