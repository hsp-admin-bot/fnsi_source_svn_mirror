package jp.co.nikkiso.ntss.admin_web.service.mente;

import jp.co.nikkiso.ntss.admin_web.request.periodicInspection.UpdateMainteMainRequest;
import jp.co.nikkiso.ntss.admin_web.response.partsRunning.PartsRunningResponse;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PeriodSearchRequest;
import jp.co.nikkiso.ntss.core.entity.DevMenteMain;
import jp.co.nikkiso.ntss.core.entity.MstMachineType;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.MstRoomBedGroup;
import jp.co.nikkiso.ntss.core.entity.custom.CusMenteMainPlan;
import jp.co.nikkiso.ntss.core.entity.custom.MachineInspection;
import jp.co.nikkiso.ntss.core.entity.custom.MaintePassAllDailyParam;
import org.apache.commons.collections4.map.HashedMap;

import java.io.IOException;
import java.util.List;
import java.util.Map;

/**
 * 検査結果のServiceインタフェース.
 */
public interface DevMenteMainService {
  List<MstRoomBedGroup> selectBedList(List<String> bedGroupList);

  /**
   * ベッドグループを1件取得する
   *
   * @param roomBedGroupCd ベッドグループコード
   * @return ベッドグループ
   */
  MstRoomBedGroup getBedGroup(String roomBedGroupCd);

  /**
   * ベッドグループリストを取得する
   *
   * @param facilityCd 施設コード
   * @return ベッドグループリスト
   */
  List<MstRoomBedGroup> getBedGroupList(String facilityCd);

  List<MstRoomBedGroup> selectConditionBedList(Long bedGroupCd);

  /**
   * 日常点検画面の対象装置リストを取得する
   *
   * @param facilityCd 施設コード
   * @param machineTypeList 装置型式条件
   * @param listBedCd ベッド条件
   * @param keyword キーワード条件
   * @return 対象装置リスト
   */
  List<MachineInspection> getConditionListMachineForInspection(
      String facilityCd, List<String> machineTypeList, List<Long> listBedCd,
      String keyword);

  /**
   * 検査用のマシンリストを取得する
   *
   * @param facilityCd 施設コード
   * @return マシン情報リスト
   */
  List<MachineInspection> getListMachineForInspection(String facilityCd);

  /**
   * （日常点検用）点検結果リストに（グループ対象型式の重複による）
   * 複数グループの点検項目がある場合に一つのグループのみを残した状態にする
   * 補正処理を行う
   *
   * @param listInspection 点検結果リスト
   * @return 処理後の点検結果リスト（引数のものと同じインスタンス）
   * @throws Exception
   */
  List<DevMenteMain> modifyTypeOverlapOfDailyInspection(
      List<DevMenteMain> listInspection) throws Exception;

  /**
   * （日常点検用）点検結果レコードに（グループ対象型式の重複による）
   * 複数グループの点検項目がある場合に一つのグループのみを残した状態にする
   * 補正処理を行う
   *
   * @param devMenteMain 点検結果
   * @return 処理後の点検結果（引数のものと同じインスタンス）
   * @throws Exception
   */
  DevMenteMain modifyTypeOverlapOfDailyOneInspection(
      DevMenteMain devMenteMain) throws Exception;

  /**
   * （日常点検用）日付の検査結果リストを取得する
   *
   * @param facilityCd 施設コード
   * @param mainteDate 点検日（YYYY-MM-DD）
   * @param mainteClass 検査型式（用途）
   * @return 検査結果リスト
   * @throws Exception
   */
  List<DevMenteMain> getResultInspectionByMainteDateAndClass(
      String facilityCd, String mainteDate, String mainteClass)
      throws Exception;

  /**
   * （定期点検用）指定した日付範囲の検査結果リストを取得する
   * （処理内容自体は定期点検専用ではないが
   * 　通常日常点検用では必要となるグループ重複排除処理は入っていないため
   * 　定期点検用を想定した機能となっている）
   *
   * @param facilityCd 施設コード
   * @param mainteClass 検査型式（用途）
   * @param mainteDateStart 点検日範囲開始（下限）（YYYY-MM-DD）
   * @param mainteDateEnd 点検日範囲終了（上限）（YYYY-MM-DD）
   * @return 検査結果リスト
   * @throws Exception
   */
  List<DevMenteMain> getResultByMainteDateSpan(
      String facilityCd, String mainteClass, String mainteDateStart,
      String mainteDateEnd) throws Exception;

  /**
   * 日付のマシンのテスト結果のリストを取得します
   *
   * @param facilityCd 施設コード
   * @param mainteDate 点検日（YYYY-MM-DD）
   * @param mainteClass 検査型式（用途）
   * @param machineNo 装置番号
   * @return 検査結果リスト
   * @throws Exception
   */
  List<DevMenteMain> getResultInspectionByMachineAndMainteDateAndClass(
      String facilityCd, String mainteDate, String mainteClass, Long machineNo)
      throws Exception;

  /**
   * 検査用のマシンリストを取得する
   *
   * @param facilityCd 施設コード
   * @return マシン情報リスト
   */
  List<DevMenteMain> getPeriodicHistory(String facilityCd, Map<String, String> params) throws Exception;

  /**
   * 点検レイアウト単位で点検結果を更新
   *
   * @param params.devMenteNo 点検結果コード
   * @param params.machineNo 装置番号
   * @param params.menteDate 点検日
   * @param params.menteLayoutCd 点検レイアウトコード
   * @param params.menteAns1 結果入力パターン
   * @param facilityCd 施設コード（NTSS認証ユーザの施設コード）
   * @param checkerId 点検者の利用者ID（NTSS認証ユーザの利用者ID）
   * @return 点検結果レコードの更新結果
   */
  DevMenteMain changeResultOfDailyInspection(
      DevMenteMain params, String facilityCd, Long checkerId)
      throws Exception;

  /**
   * 日常点検の点検項目ごとの点検結果を更新
   *
   * @param params.devMenteNo 点検結果コード
   * @param params.machineNo 装置番号
   * @param params.menteDate 点検日
   * @param params.menteLayoutCd 点検レイアウトコード
   * @param params.menteAns1 結果入力パターン
   * @param params.detail 内容（JSON文字列）
   * @param params.mainteCategoryCd 点検カテゴリコード版数（JSON文字列）
   * @param facilityCd 施設コード（NTSS認証ユーザの施設コード）
   * @param checkerId 点検者の利用者ID（NTSS認証ユーザの利用者ID）
   * @return 点検結果レコードの更新結果
   */
  DevMenteMain changeResultOfDailyInspectionList(
      DevMenteMain params, String facilityCd, Long checkerId)
      throws Exception;

  /**
   * 点検日と点検レイアウトコードによる全台合格処理を行う
   *
   * @param params.params.menteDate 点検日
   * @param params.params.menteLayoutCd 点検レイアウトコード
   * @param params.machineNoList 全台合格処理の対象とする装置番号のリスト
   * @param facilityCd 施設コード（NTSS認証ユーザの施設コード）
   * @param checkerId 点検者の利用者ID（NTSS認証ユーザの利用者ID）
   * @return 更新後の点検結果レコード
   */
  List<DevMenteMain> changeStatusPassAllDaily(
      MaintePassAllDailyParam params, String facilityCd, Long checkerId)
      throws Exception;

  /**
   * 更新結果検査の詳細
   *
   * @param devMenteMain 結果検査詳細
   * @return 検査結果更新
   */
  int updateDetailWhenCellClick(List<DevMenteMain> devMenteMain) throws Exception;

  // add 11021 定期点検結果のみ削除仕様 zkm start
  /**
   * 検査結果の削除
   *
   * @param devMenteNo 結果検査詳細
   * @return 検査結果更新
   */
  // #11205 -ペンテスト2－4認可制御の不備  mod 20260416 start
  int delDetailWhenCellClick(Long devMenteNo, String facilityCd) throws Exception;
  // #11205 -ペンテスト2－4認可制御の不備  mod 20260416 end
  // add 11021 定期点検結果のみ削除仕様 zkm end

  /**
   * 定期検査の結果を取得する
   *
   * @param facilityCd 施設コード
   * @param machineNo 機械番号
   * @param devMenteNo 検査結果
   * @return 定期検査の結果
   */
  HashedMap<String, Object> getResultDetailOfPeriodic(String facilityCd,Long machineNo, Long devMenteNo, Long layoutGrroupCd) throws Exception;

  /**
   * ユーザーコードリストによるユーザー情報リストの取得
   *
   * @param userIdList ユーザーコードリスト
   * @return ユーザー情報リスト
   */
  List<MstPersonalUser> getUsersInfoByIdList(List<Long> userIdList);

  /**
   * ユーザー情報を取得する
   *
   * @param userId ユーザーコード
   * @return ユーザー情報リスト
   */
  MstPersonalUser getUsersInfo(Long userId);

  /**
   * 定期検査スケジュールの変更
   *
   * @param facilityCd 施設コード
   * @param cusMenteMainPlan リスト変更
   */
  void addAndCancelPlan(CusMenteMainPlan cusMenteMainPlan, String facilityCd) throws Exception;

  /**
   * 検査結果を削除
   *
   * @param mainCd 検査結果コード
   * @return 結果
   */
  // #11205 -ペンテスト2－4認可制御の不備  mod 20260416 start
  boolean deleleMainteMain(List<Long> mainNo, String facilityCd) throws Exception;
  // #11205 -ペンテスト2－4認可制御の不備  mod 20260416 end

  /**
   * （日常点検用）点検日範囲と装置番号を指定して点検結果リストを取得する
   *
   * @param startDate 点検日範囲上限（YYYY-MM-DD）
   * @param machineNo 装置番号
   * @param endDate 点検日範囲下限（YYYY-MM-DD）
   * @param facilityCd 施設コード
   * @return 点検結果レコードリスト
   * @throws Exception
   */
  List<DevMenteMain> getLayout(
      String startDate, Long machineNo, String endDate, String facilityCd)
      throws Exception;

  PartsRunningResponse createPartsRunningResponse(String facilityCd, String machineTypeCd, String machineSerial)
    throws IOException;

  // #11205 -ペンテスト2－4認可制御の不備  mod 20260416 start
  boolean deleleMainteMainByTemDate(UpdateMainteMainRequest updateMainteMainRequest, String facilityCd) throws Exception;
  // #11205 -ペンテスト2－4認可制御の不備  mod 20260416 end

  /**
   * 型式、ベッドグループコードに該当する装置情報のリストを取得する
   *
   * @param periodSearchRequest
   * @param ntssUser
   * @return 装置情報のリスト
   */
  List<MachineInspection> getMachineSearchResult(PeriodSearchRequest periodSearchRequest, NtssUser ntssUser);
}
