package jp.co.nikkiso.ntss.api.service.additionInfo;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.api.request.AdditionCalculationRequest;
import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstAdditionDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstHolidayDao;
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.entity.MstAddition;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.MstSelector.Item;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.AdditionInfo;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdAdditionInfo;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.TriggerUtil;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.annotation.Transient;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import java.io.IOException;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

/**
 * 加算情報の算定処理系Serviceの実装クラス.
 */
@Service
public class AdditionCalculationServiceImpl implements AdditionCalculationService {

  @Autowired
  private PatMainDao patMainDao;

  @Autowired
  private MstAdditionDao mstAdditionDao;

  @Autowired
  private PatUniqueDao patUniqueDao;

  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  @Autowired
  private OrdMainDao ordMainDao;

  @Autowired
  PatExamMainDao patExamMainDao;

  @Autowired
  MstHolidayDao mstHolidayDao;

  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;

  @Autowired
  private MstFacilityDao mstFacilityDao;

  @Autowired
  private MstSelectorDao mstSelectorDao;

  @Autowired
  private LogService logService;

  @Autowired
  private TriggerUtil triggerUtil;

  //加算機能
  private static final String ADDITION_INFO = "A08";

  @Override
  @Transient
  public boolean calculationAddition(AdditionCalculationRequest request) {
    // wangzuo アプリケーションログの適正化 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "calculationAddition実施開始：" + "/calculation/");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    try {
      String facilityCd = request.getFacilityCd();

      // wangzuo アプリケーションログの適正化 Add Start
      eventLogMessage.setFacilityCd(facilityCd);
      // wangzuo アプリケーションログの適正化 Add End

      Long patId = request.getPatId();
      Long ordNo = request.getOrdNo();
      // xujl ordNoをnullの場合、加算処理は実行されません Add Start
      if (ordNo == null) {
        eventLogMessage.setLogMessage(this.getClass().getName() + "calculationAddition実施終了：" + "ordNo = null");
        logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return true;
      }
      // xujl ordNoをnullの場合、加算処理は実行されません Add End
      Integer eventId = request.getEventId();

      // 加算機能が有効になっているか
      MstFacility mstFacility = mstFacilityDao.selectByAddvancedSettingCodeAndFacilityCd(ADDITION_INFO, facilityCd);
      if (mstFacility == null) {
        return true;
      }

      // 処理対象の種別区分を格納
      List<String> patMainArr = checkPatMainArr(eventId);
      List<String> ordMainArr = checkOrdMainArr(eventId);
      List<String> addtionCdArr = checkEvent(eventId);
      List<MstAddition> mstAdditionList = mstAdditionDao.getByAdditionCdList(facilityCd, addtionCdArr);

      // 古いリスト
      List<OrdAdditionInfo> ordOldList = ordMainDao.selectAdditionInfo(facilityCd, patId, ordNo);
      List<AdditionInfo> patOldList = patMainDao.selectAdditionInfo(facilityCd, patId);

      // 特殊浄化かどうか判定
      Boolean isSpecialPurification = ordMainDao.checkSpecialPurification(ordNo);
      // 加算マスタから判定対象を抽出
      List<MstAddition> calcTargets = mstAdditionList.stream().filter(mst -> additionTargetJudg(mst, patOldList)).collect(Collectors.toList());
      // 自動かつデータのない加算情報を患者情報に展開
      normalizePatAdditionInfo(calcTargets, patMainArr, patOldList);

      for (MstAddition mstAddition : calcTargets) {
        // 加算種別毎の指定条件
        Boolean addFlg = false;
        List<Map<String, String>> additionTarCd = changeListMap(mstAddition.getAdditionTarCd());
        String additionClassCheck = mstAddition.getAdditionClass();

        // 種別区分に応じて算定条件の反映を行い、合致したらaddFlgをtrueにする
        switch (additionClassCheck) {
        case "1": // 透析液水質確保加算 特殊浄化でなければ該当
          if (!isSpecialPurification) {
            addFlg = true;
          }
          break;
        case "2": // 障害者加算
          if (!additionTarCd.isEmpty()) {
            addFlg = checkApplyDiffCom(patId, mstAddition, additionTarCd);
          }
          break;
        case "3": // 指定病名連動
          if (!additionTarCd.isEmpty()) {
            addFlg = checkApplyDiseaseName(patId, additionTarCd);
          }
          break;
        case "4": // 指定治療方法加算
          addFlg = checkApplyTreatmentUsed(ordNo, mstAddition, additionTarCd);
          break;
        case "5": // 長時間加算
          addFlg = checkActualTreatTime(ordNo, mstAddition);
          break;
        case "6": // 指定薬剤実施連動
          if (!additionTarCd.isEmpty()) {
            addFlg = checkApplyMediUsed(ordNo, additionTarCd);
          }
          break;
        case "7": // 指定患者イベント連動
          if (!additionTarCd.isEmpty()) {
            addFlg = checkApplyPatEvent(patId, ordNo, additionTarCd);
          }
          break;
        case "8": // 検査依頼連動
          addFlg = checkApplyTreatmentRequest(facilityCd, patId, ordNo);
          break;
        case "9": // 導入期加算
          if (!isSpecialPurification) {
            addFlg = checkApplyPeriodTime(facilityCd, patId, ordNo, mstAddition.getAdditionCd().toString());
          }
          break;
        case "13": // 慢性維持透析患者外来医学管理料
          if (!isSpecialPurification) {
            addFlg = checkMaintDialysisOutPatientCost(facilityCd, patId, ordNo, mstAddition.getAdditionCd().toString());
          }
          break;
        case "10": // 休日加算
          if (!isSpecialPurification) {
            addFlg = checkApplyHoliday(facilityCd, ordNo);
          }
          break;
        case "11": // 時間外加算
          if (!isSpecialPurification) {
             addFlg = checkApplyOffHours(ordNo, ordOldList);
          }
          break;
        case "12": // 汎用 無条件(透析も特殊浄化も)
          addFlg = true;
          break;
        default:
          break;
        };

        // 指定条件に合致しない
        if (!addFlg) {
          // 判定しない
          continue;
        }

        // 汎用自動算定で、算定回数に「期限」が指定されていた場合の開始日を格納
        String calcStartDate = "";
        // 算定回に合致するかどうかの判定
        Boolean addTimingFlg = false;
        // 種別区分に応じて現在治療が算定回に合致するかの判定を行い、合致したらaddTimingFlgをtrueにする
        switch (additionClassCheck) {
          case "1": // 透析液水質確保加算 特殊浄化でなければ該当
          case "5": // 長時間加算
          case "9": // 導入期加算
          case "10": // 休日加算
          case "11": // 時間外加算
            // 上記6項目は実質毎回加算
            addTimingFlg = true;
            break;
          case "2": // 障害者加算
          case "3": // 指定病名連動
          case "4": // 指定治療方法加算
          case "6": // 指定薬剤実施連動
          case "7": // 指定患者イベント連動
          case "8": // 検査依頼連動
          case "12": // 汎用自動
            // 算定回数に「期限」が指定されていた場合の開始日を取得
            AdditionInfo patAdditionItem = findExistItemInPatMain(mstAddition, patOldList);
            if (null != patAdditionItem && patAdditionItem.getIs_enable().equals("1")) {
              calcStartDate = patAdditionItem.getStart_date();
            }
            // 算定回に合致するかの判定を実施
            addTimingFlg = checkAddTiming(mstAddition, patId, facilityCd, ordNo, calcStartDate);
            break;
          case "13": // 慢性維持透析患者外来医学管理料
            // 算定回に合致するかの判定を実施
            addTimingFlg = checkAddTimingOnly13(mstAddition, patId, facilityCd, ordNo);
            break;
        }

        // 算定回に合致しない
        if (!addTimingFlg) {
          // 判定しない
          continue;
        }

        // 算定回数上限未満かの判定
        Boolean underAddLimitFlg = false;
        if (mstAddition.getAdditionLimit() == null ||
          (additionClassCheck.equals("12") && mstAddition.getAdditionSpan().equals("4"))) {
          // 算定回数上限nullならば無制限
          // 汎用の自動算定、算定回数：期限の場合は既に判定が終わっている為、こちらの処理は true で抜ける
          underAddLimitFlg = true;
        } else {
          Long count = 0L;
          // 同月内の治療実績から同加算項目(コード検索)がONの件数をカウント
          count = ordMainDao.countExistAdditionBySameMonth(facilityCd, patId, ordNo, mstAddition.getAdditionCd().toString());
          // 算定回数上限未満なら算定する
          if (count < mstAddition.getAdditionLimit()) {
            underAddLimitFlg = true;
          }
        }

        // 算定回数上限を超える
        if (!underAddLimitFlg) {
          // 判定しない
          continue;
        }

        // 算定条件に合致する場合の処理
        // 全体的に、加算マスタレコードと同じ加算コードが加算情報になければpat_main側に追加。有効か無効かは見てない。追加する際に強制的に有効になる。

        // ORD_MAIN
        // ord_mainに加算するタイミングの場合
        if (ordMainArr.contains(additionClassCheck)) {
          // mstAdditionは加算マスタレコード（以下、加算マスタレコード）
          // 既存のord_main加算情報がある
          if (ordOldList.size() > 0) {
            OrdAdditionInfo ordAdditionItem = findExistItemInOrdMain(mstAddition, ordOldList);
            // 加算マスタレコードの加算コードと同じord_main加算情報がない → insertByCheckPatInfo
            // 加算マスタレコードの加算コードと同じord_main加算情報がある → なにもしない
            if (null == ordAdditionItem) {
              insertByCheckPatInfo(ordOldList, patOldList, mstAddition, calcStartDate);
            }
          } else {
            // 既存のord_main加算情報がない → insertByCheckPatInfo
            insertByCheckPatInfo(ordOldList, patOldList, mstAddition, calcStartDate);
          }
        }
      }

      ObjectMapper mapper = new ObjectMapper();
      if (patOldList != null && patOldList.size() > 0) {
        String patStr = mapper.writeValueAsString(patOldList);
        patMainDao.updateAdditionInfoById(patId, patStr);
      }
      if (ordOldList != null && ordOldList.size() > 0) {

        String ordStr = "";

        // 並び替えマスタ取得
        String masterPhysicalName = "mst_addition";
        MstSelector mstAdditionSelector = mstSelectorDao.selectByName(facilityCd, masterPhysicalName);

        if(Objects.isNull(mstAdditionSelector)) {
          // 並び替えマスタがnullの場合、無編集で実績情報をStringに展開
          ordStr = mapper.writeValueAsString(ordOldList);
        } else {
          // 並び替えマスタがある場合、ソートを実施して実績情報をStringに展開
          List<OrdAdditionInfo> ordNewList = new ArrayList<OrdAdditionInfo>();
          List<Item> orderItems = mstAdditionSelector.getOrderSettings().getItems();

          // 並び順データの先頭順に、加算情報を新しいリストに追加していく
          // mst_selectorにない加算マスタ項目は加算処理の対象外なので考慮しない
          for (Item item: orderItems) {
            List<OrdAdditionInfo> filteredOrdList = ordOldList.stream()
              .filter(ordAddInfo -> {
                return ordAddInfo.getCd().equals(item.getCode());
              })
              .collect(Collectors.toList());
            if (filteredOrdList.size() > 0) {
              ordNewList.add(filteredOrdList.get(0));
            }
          }
          // 実績情報をStringに展開
          ordStr = mapper.writeValueAsString(ordNewList);
        }

        OrdMain oldOrdMain = ordMainDao.selectByOrdNo(ordNo);
        ordMainDao.updateAdditionInfoById(ordNo, ordStr);
        OrdMain newOrdMain = ordMainDao.selectByOrdNo(ordNo);
        triggerUtil.updateTriggerOrdMain(Collections.singletonList(oldOrdMain),
          Collections.singletonList(newOrdMain));
      }

      // wangzuo アプリケーションログの適正化 Add Start
      eventLogMessage.setLogMessage(this.getClass().getName() + "calculationAddition実施終了：" + "/calculation/" + facilityCd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // wangzuo アプリケーションログの適正化 Add End

      return true;
    } catch (Exception e) {
      // ログ出力
      // wangzuo アプリケーションログの適正化 Mod
      eventLogMessage.setLogMessage(this.getClass().getName() + "calculationAddition実施異常終了：" + e.getMessage());
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      //modify by ShiHongda 2023-01-31 [Transaction] --start /

      throw new NtssException(this.getClass().getName() + "calculationAddition実施異常終了：" + e.getMessage(), e);
      //return false;

      //modify by ShiHongda 2023-01-31 [Transaction] --end /

    }
  }

  /**
   * 算定対象となった自動加算について、患者情報（pat_main）への存在保証処理
   *
   * @param calcTargets additionTargetJudg を通過した加算マスタ
   * @param patMainArr 患者情報に展開する種別区分
   * @param patOldList 患者情報の加算情報リスト
   */
  private void normalizePatAdditionInfo(List<MstAddition> calcTargets, List<String> patMainArr, List<AdditionInfo> patOldList) {
    // 既存加算コードをSetに
    Set<Long> existCdSet = patOldList.stream().map(AdditionInfo::getCd).collect(Collectors.toSet());
    for (MstAddition mstAddition : calcTargets) {
      String additionClass = mstAddition.getAdditionClass();
      // 患者情報に展開する種別のみ
      if (!patMainArr.contains(additionClass)) {
        continue;
      }

      // 存在しなければ追加
      if (!existCdSet.contains(mstAddition.getAdditionCd())) {
        addAdditionInfo(mstAddition, patOldList);
        existCdSet.add(mstAddition.getAdditionCd());
      }
    }
  }

  /**
   * 判定処理の対象になっているかを確認する
   * @param mstAddition mst_addition(加算マスタ)のエンティティクラス
   * @param patOldList 患者情報の加算情報オブジェクトのリスト
   * @return true：判定対象 / false：判定しない
   */
  private Boolean additionTargetJudg(MstAddition mstAddition, List<AdditionInfo> patOldList) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "additionTargetJudg実施開始：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    Boolean rtn = false;
    // 患者情報から、対象の加算マスタを取得 (なければnull)
    AdditionInfo patAdditionItem = findExistItemInPatMain(mstAddition, patOldList);
    // 以下、算定が自動の場合
    if (Objects.isNull(patAdditionItem)) {
      // 患者情報に登録がない場合
      rtn = true;
    } else if (null != patAdditionItem && patAdditionItem.getIs_enable().equals("1")) {
      // 患者情報が存在し、有効
      rtn = true;
    }

    // ログ出力
    eventLogMessage.setLogMessage(this.getClass().getName() + "additionTargetJudg実施終了：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    return rtn;
  }

  /**
   * @param ordOldList
   * @param patOldList
   * @param mstAddition
   * @param calcStartDate　汎用自動算定で、算定回数に「期限」が指定されていた場合の開始日
   * @throws Exception
   */
  private void insertByCheckPatInfo(List<OrdAdditionInfo> ordOldList, List<AdditionInfo> patOldList,
          MstAddition mstAddition, String calcStartDate) throws Exception {
    // wangzuo アプリケーションログの適正化 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "insertByCheckPatInfo実施開始：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    AdditionInfo patAdditionItem = findExistItemInPatMain(mstAddition, patOldList);
    if (null != patAdditionItem) {
      // 加算マスタレコードの加算コードと同じpat_main加算情報がある
      if (patAdditionItem.getIs_enable().equals("1")) {
        // pat_main加算情報の有効フラグがON
        // ord_main加算情報 算定日時の更新
        updateOrdAddition(mstAddition, ordOldList, calcStartDate);
      }
    } else {
      // 加算マスタレコードの加算コードと同じpat_main加算情報がない
      // pat_main加算情報に追加
      addAdditionInfo(mstAddition, patOldList);
      // ord_main加算情報 算定日時の更新
      updateOrdAddition(mstAddition, ordOldList, calcStartDate);
    }

    // wangzuo アプリケーションログの適正化 Add Start
    eventLogMessage.setLogMessage(this.getClass().getName() + "insertByCheckPatInfo実施終了：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End
  }

  /**
   *
   * @param item
   * @param array
   * @return
   */
  private OrdAdditionInfo findExistItemInOrdMain(MstAddition item, List<OrdAdditionInfo> array) {
    // wangzuo アプリケーションログの適正化 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "findExistItemInOrdMain実施開始：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    for (OrdAdditionInfo addition : array) {
      if (item.getAdditionCd().equals(addition.getCd())) {

        // wangzuo アプリケーションログの適正化 Add Start
        eventLogMessage.setLogMessage(this.getClass().getName() + "findExistItemInOrdMain実施終了：");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // wangzuo アプリケーションログの適正化 Add End

        return addition;
      }
    }

    // wangzuo アプリケーションログの適正化 Add Start
    eventLogMessage.setLogMessage(this.getClass().getName() + "findExistItemInOrdMain実施終了：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    return null;
  }

  /**
   *
   * @param item
   * @param array
   * @return
   */
  private AdditionInfo findExistItemInPatMain(MstAddition item, List<AdditionInfo> array) {

    // wangzuo アプリケーションログの適正化 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "findExistItemInPatMain実施開始：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    for (AdditionInfo addition : array) {
      if (item.getAdditionCd().equals(addition.getCd())) {

        // wangzuo アプリケーションログの適正化 Add Start
        eventLogMessage.setLogMessage(this.getClass().getName() + "findExistItemInPatMain実施終了：");
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // wangzuo アプリケーションログの適正化 Add End

        return addition;
      }
    }

    // wangzuo アプリケーションログの適正化 Add Start
    eventLogMessage.setLogMessage(this.getClass().getName() + "findExistItemInPatMain実施終了：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    return null;
  }

  /**
   * 算定回数の判定
   * 毎回の場合は無条件で該当判定
   * 週1回、月1回の場合は範囲内のord_mainを治療日でソートしてn番目であれば該当判定
   *
   * @param mstAddition
   * @param patId
   * @param facilityCd
   * @param ordNo
   * @param calcStartDate 汎用自動算定で、算定回数に「期限」が指定されていた場合の開始日
   * @return
   * @throws Exception
   */
  private Boolean checkAddTiming(MstAddition mstAddition, Long patId, String facilityCd, Long ordNo, String calcStartDate) throws Exception {
    Boolean rtnVal = false;

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkAddTiming実施開始：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    if (mstAddition.getAdditionSpan().equals("3")) {
      // 毎回
      rtnVal = true;
    } else if (mstAddition.getAdditionSpan().equals("4")) {
      // 期限
      if (StringUtils.isEmpty(calcStartDate)) {
        // 開始日がない場合は、無効
        rtnVal = false;
      } else if (mstAddition.getAdditionLimit() == null || mstAddition.getAdditionLimit().equals(0L)) {
        // 期限が未入力、又は0の場合は無期限とする
        rtnVal = true;
      } else {
        // 算定日が開始日～期限内に収まっているか判定
        SimpleDateFormat sdFormat = new SimpleDateFormat("yyyyMMdd");
        OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
        String treatDate = ordMain.getTreatDate();
        // 期限日を計算
        Date calcStartDateObj = sdFormat.parse(calcStartDate);
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(calcStartDateObj);
        // 開始日を含めての期限の為、 期限 -1 で加算する
        int limit = mstAddition.getAdditionLimit().intValue() - 1;
        calendar.add(Calendar.DATE, limit);
        calcStartDateObj = calendar.getTime();
        String deadlineStr = sdFormat.format(calcStartDateObj);

        if (treatDate.compareTo(calcStartDate) >= 0 && treatDate.compareTo(deadlineStr) <= 0) {
          // 期限内の場合は有効
          rtnVal = true;
        }
      }
    } else {
      // 週1回or月1回
      List<OrdMain> ordMainList = new ArrayList<OrdMain>();

      if (mstAddition.getAdditionSpan().equals("1")) {
        // 週1回

        // 週の初日～最終日を取得
        OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
        LocalDate treatDate = LocalDate.parse(ordMain.getTreatDate(), DateTimeFormatter.ofPattern("yyyyMMdd"));
        LocalDate searchStartDate = treatDate.with(DayOfWeek.MONDAY);
        LocalDate searchEndDate = treatDate.with(DayOfWeek.SUNDAY);

        // 期間内の治療をすべて取得
        ordMainList = ordMainDao.selectByPeriod(facilityCd, patId, searchStartDate.toString(), searchEndDate.toString());

      } else if (mstAddition.getAdditionSpan().equals("0")) {
        // 月1回

        // 同月の治療をすべて取得
        ordMainList = ordMainDao.selectBySameMonth(facilityCd, patId, ordNo);
      }

      // N回目を格納する変数
      Integer nthTime = 0;
      // 同月の治療内で何番目かを取得
      for (int i = 0; i < ordMainList.size(); i++) {
        if (ordMainList.get(i).getOrdNo().equals(ordNo)) {
          nthTime = i + 1;
          break;
        }
      }

      // 加算マスタの設定と比較
      if (mstAddition.getAdditionLimitType() != null) {
          if (mstAddition.getAdditionLimitType().equals("0")) {
              // 月初めの治療
              rtnVal = nthTime.equals(1);
            } else if (mstAddition.getAdditionLimitType().equals("1")) {
              // 第N回目の治療
              rtnVal = nthTime.equals(mstAddition.getAddCnt_1());
            } else if (mstAddition.getAdditionLimitType().equals("2")) {
              // 月最終の治療
              rtnVal = nthTime.equals(ordMainList.size());
            }
      	}else {
      	    eventLogMessage.setLogMessage("加算等名称:" + mstAddition.getAdditionName() + " AdditionLimitTypeがnullのため加算対象外");
      	    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      	}
    }

    // ログ出力
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkAddTiming実施終了： rtnVal=" + rtnVal);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    return rtnVal;
  }

  /**
   * 算定回数の判定
   * NOTE: 種別区分：13(慢性維持透析患者外来医学管理料)専用処理
   *       既存への影響を抑えるため、一旦専用処理で実装する方針となった(#12289 対応).
   *       @see checkAddTiming
   *
   * @param mstAddition
   * @param patId
   * @param facilityCd
   * @param ordNo
   * @return true：判定対象 / false：判定しない
   * @throws Exception
   * @see #checkAddTiming(MstAddition, Long, String, Long, String) 算定回数の判定処理を参考にしています.
   */
  private Boolean checkAddTimingOnly13(MstAddition mstAddition, Long patId, String facilityCd, Long ordNo) throws Exception {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkAddTimingOnly13実施開始：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // 期間内の治療をすべて取得
    List<OrdMain> ordMainList = ordMainDao.selectBySameMonth(facilityCd, patId, ordNo);
    // 「入外区分:外来(1)」で絞込み
    List<OrdMain> filteredList = ordMainList.stream()
      .filter(o -> o.getRstInOutClass() != null && o.getRstInOutClass() != 1)
      .collect(Collectors.toList());

    String addType = mstAddition.getAdditionLimitType();
    List<OrdMain> targetList = (addType != null && addType.equals("2")) ? ordMainList : filteredList;

    Integer nthTime = 0;
    for (int i = 0; i < targetList.size(); i++) {
      if (targetList.get(i).getOrdNo().equals(ordNo)) {
        nthTime = i + 1;
        break;
      }
    }

    Boolean checkResult = false;
    if ("0".equals(addType)) {
      checkResult = nthTime.equals(1);                         // 月初めの治療
    } else if ("1".equals(addType)) {
      checkResult = nthTime.equals(mstAddition.getAddCnt_1()); // 第N回目の治療
    } else if ("2".equals(addType)) {
      checkResult = nthTime.equals(ordMainList.size());         // 月最終の治療（filteredListではなく全体）
    } else {
      eventLogMessage.setLogMessage("加算等名称:" + mstAddition.getAdditionName() + " AdditionLimitTypeが不正値のため加算対象外");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    }

    eventLogMessage.setLogMessage(this.getClass().getName() + "checkAddTimingOnly13実施終了： checkResult=" + checkResult);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    return checkResult;
  }

  /**
   * 透析日が休日マスタ上の休日と一致した場合
   *
   * @param facilityCd
   * @param ordNo
   * @return
   * @throws Exception
   */
  private Boolean checkApplyHoliday(String facilityCd, Long ordNo) throws Exception {
    // wangzuo アプリケーションログの適正化 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyHoliday実施開始：" + facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    int count = 0;
    count = mstHolidayDao.selectHolidayByTreatdate(ordNo, facilityCd);

    // wangzuo アプリケーションログの適正化 Add Start
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyHoliday実施終了：" + facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    return count > 0;
  }

  /**
   * 導入期加算
   * 施設設定No49に依存する。
   * 導入日から施設設定の設定に応じた期間の範囲の透析(特殊浄化は除外)は該当判定する。
   * チケット#2339より
   * ・導入期加算はその期間内では14回までしか算定できない。
   * ・1日に1回の算定なので、同じ日に何回実績があっても最初の1回目に算定される。
   *
   * @param facilityCd
   * @param patId
   * @param ordNo
   * @param additionCd
   * @return
   * @throws Exception
   */
  private Boolean checkApplyPeriodTime(String facilityCd, Long patId, Long ordNo, String additionCd) throws Exception {

    // wangzuo アプリケーションログの適正化 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyPeriodTime実施開始：" + facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    Boolean addFlg = false;
    int count = 0;
    boolean isValidDate = false;
    OrdMain ordMain= ordMainDao.selectByOrdNo(ordNo);
    // 同一治療日・同一患者に対象の加算コードが入っているか
    // 入っていたらfalseを返す
    boolean isExistFlg = ordMainDao.checkExistAdditionByTreateDate(facilityCd, patId, additionCd, ordMain.getTreatDate(), null);
    if(isExistFlg == true) {

      // wangzuo アプリケーションログの適正化 Add Start
      eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyPeriodTime実施終了：" + facilityCd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // wangzuo アプリケーションログの適正化 Add End

      return false;
    }
    // 期加算算定条件
    FacilitySettingInfo additionSetting = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd,
            FacilitySettingNo.ADDITIONAL_FEE);
    if(additionSetting.getValue().equals("1")) {
      isValidDate = ordMainDao.checkDialysisStartDateByMonth(ordNo, patId);
      // 同月内
      if(!isValidDate) {
        // wangzuo アプリケーションログの適正化 Add Start
        eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyPeriodTime実施終了：" + facilityCd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // wangzuo アプリケーションログの適正化 Add End

        return false;
      }
      count = ordMainDao.countMedicalFeeByMonth(facilityCd, patId, additionCd);
    } else {
      isValidDate = ordMainDao.checkDialysisStartDateByDate(ordNo, patId);
      // 日付計算
      if(!isValidDate) {
        // wangzuo アプリケーションログの適正化 Add Start
        eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyPeriodTime実施終了：" + facilityCd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        // wangzuo アプリケーションログの適正化 Add End

        return false;
      }
      count = ordMainDao.countMedicalFeeByDate(facilityCd, patId, additionCd);
    }
    if (count < 14) {
      addFlg = true;
    }

    // wangzuo アプリケーションログの適正化 Add Start
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyPeriodTime実施終了：" + facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    return addFlg;
  }

  /**
   * 慢性維持透析患者外来医学管理料
   * ・患者情報の透析導入日から3か月以上経過していること(導入期加算の期間が終わってからの加算となる)
   * ・同月内で導入期加算と重複して加算しないこと
   * ・月1回の算定の加算となる ( その月で慢性維持透析患者外来医学管理料を既に加算していた場合、以降の治療時に重複して加算しない )
   * ・実績が「入院」以外である場合に加算する
   *
   * @param facilityCd
   * @param patId
   * @param ordNo
   * @param additionCd
   * @return
   * @throws Exception
   */
  private Boolean checkMaintDialysisOutPatientCost(String facilityCd, Long patId, Long ordNo, String additionCd) throws Exception {

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkMaintDialysisOutPatientCost実施開始：" + facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    // 実績の入外区分が「入院」以外か
    OrdMain ordMain= ordMainDao.selectByOrdNo(ordNo);
    if (ordMain.getRstInOutClass() != null && ordMain.getRstInOutClass() == 1) {
      // 「入院」の場合は算定しない
      eventLogMessage.setLogMessage(this.getClass().getName() + "checkMaintDialysisOutPatientCost実施終了_入院中：" + facilityCd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return false;
    }

    LocalDate treatDate = LocalDate.parse(ordMain.getTreatDate(), DateTimeFormatter.ofPattern("yyyyMMdd"));
    // 透析導入日から3か月以上経過しているか ( 透析導入日 + 3ヶ月 の次の月以降から加算する )
    String dialysisStartDate = patUniqueDao.selectDialysisStartDateById(patId);
    // add bug 8386 修正 chen start
    if (dialysisStartDate == null) {
      // NOTE: 透析導入日が判定できない（年月日特定不可 or 導入がない）場合、算定対象とする（#12289対応）
      // 導入日が空の場合でも、同月内に加算済みかを確認
      LocalDate mStartDate = treatDate.withDayOfMonth(1);
      boolean isExistFlg = ordMainDao.checkExistAdditionByTreateDate(facilityCd, patId, additionCd, ordMain.getTreatDate(), mStartDate.format(DateTimeFormatter.ofPattern("yyyyMMdd")));
      if (isExistFlg) {
        eventLogMessage.setLogMessage(this.getClass().getName() + "checkMaintDialysisOutPatientCost実施終了_同月内算定済み：" + facilityCd);
        logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        return false;
      }
      return true;
    }
    // add bug 8386 修正 chen end
    LocalDate over3mon = LocalDate.parse(dialysisStartDate, DateTimeFormatter.ofPattern("yyyyMMdd")).plusMonths(4).withDayOfMonth(1);
    if (!(treatDate.isEqual(over3mon) || treatDate.isAfter(over3mon))) {
      // 透析導入日から3か月以上経過していないので算定しない
      eventLogMessage.setLogMessage(this.getClass().getName() + "checkMaintDialysisOutPatientCost実施終了_3ヶ月未経過：" + facilityCd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return false;
    }

    // 同月内に、慢性維持透析患者外来医学管理料 の加算が行われていないか
    LocalDate mStartDate = treatDate.withDayOfMonth(1);
    boolean isExistFlg = ordMainDao.checkExistAdditionByTreateDate(facilityCd, patId, additionCd, ordMain.getTreatDate(), mStartDate.format(DateTimeFormatter.ofPattern("yyyyMMdd")));
    if (isExistFlg == true) {
      // 同月内に慢性維持透析患者外来医学管理料の算定があるので算定しない
      eventLogMessage.setLogMessage(this.getClass().getName() + "checkMaintDialysisOutPatientCost実施終了_同月内算定済み：" + facilityCd);
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      return false;
    }

    eventLogMessage.setLogMessage(this.getClass().getName() + "checkMaintDialysisOutPatientCost実施終了：" + facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return true;
  }

  /**
   * 検査依頼連動
   * 同日に検査依頼が1件でも存在する場合に該当。
   * ※結果のみのデータは除外が必要。
   * ※締め切りや結果ありは考慮しなくてよい。
   *
   * @param facilityCd
   * @param patId
   * @param ordNo
   * @return
   */
  private Boolean checkApplyTreatmentRequest(String facilityCd, Long patId, Long ordNo) {
    // wangzuo アプリケーションログの適正化 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyTreatmentRequest実施開始：" + facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    Boolean addFlg = false;
    Long requestCount = patExamMainDao.countTreatRequestByPatId(patId, ordNo, facilityCd);
    if (requestCount > 0) {
      addFlg = true;
    }

    // wangzuo アプリケーションログの適正化 Add Start
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyTreatmentRequest実施終了：" + facilityCd);
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    return addFlg;
  }

  /**
   * 指定患者イベント連動
   * 指定サブカテゴリイベントが治療日と同日に存在する場合に該当
   *
   * @param patId
   * @param ordNo
   * @param additionTarCd
   * @return
   */
  private Boolean checkApplyPatEvent(Long patId, Long ordNo, List<Map<String, String>> additionTarCd) {
    // wangzuo アプリケーションログの適正化 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyPatEvent実施開始：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    Boolean addFlg = false;
    Long patEventAmount = 0L;
    for (Map<String, String> addition : additionTarCd) {
      //mod #12623 指示展開処理失敗が発生 zrx start
      if (addition == null) continue;
      String cd = addition.get("cd");
      if (cd == null || !cd.matches("\\d+")) continue;
      patEventAmount = ordMainDao.selectPatEventAmount(patId, ordNo, Long.valueOf(cd));
      if (patEventAmount > 0) {
        addFlg = true;
      }
      //mod #12623 指示展開処理失敗が発生 zrx end
    }

    // wangzuo アプリケーションログの適正化 Add Start
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyPatEvent実施終了：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    return addFlg;
  }

  /**
   * 時間外加算
   * 実績の透析開始時刻が１７時以降または透析終了日時（透析開始時刻＋透析時間）が２１時以降の場合
   * または透析終了年月日年、月、日何れかが透析開始年月日より跨った場合
   * 特殊浄化は該当しない
   * 算定時に休日加算がONのデータが存在する場合は、時間外加算は無条件でOFFとする。
   *
   * @param ordNo
   * @return
   */
   private Boolean checkApplyOffHours(Long ordNo, List<OrdAdditionInfo> ordOldList) {
    // wangzuo アプリケーションログの適正化 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyOffHours実施開始：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    // 休日加算データが存在するかの確認
    Boolean isHoliday = false;
    for (OrdAdditionInfo ordAddition : ordOldList) {
      MstAddition mstAddition = mstAdditionDao.selectByAdditionCd(ordAddition.getCd());
      if (mstAddition.getAdditionClass().equals("10")) {
        isHoliday = true;
      }
    }

    if (isHoliday) {
      // ログ出力
      eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyOffHours実施終了：");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

      return false;
    }

    Boolean existFlg = false;
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    String rstCondInfo = ordMain.getRstCondInfo();
    if (ordMain != null && rstCondInfo != null) {
       // 開始時間を取得
       Timestamp startTime = ordMain.getRstStartDate();
       // 開始時間がnullなら以降の処理実行不可
       if (startTime == null) {

         // wangzuo アプリケーションログの適正化 Add Start
         eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyOffHours実施終了：");
         logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
         // wangzuo アプリケーションログの適正化 Add End

         return false;
       }

      // 開始時間をLocalDateTimeに変換
      LocalDateTime startTimeLdt = startTime.toLocalDateTime();

      // 治療条件項目のJSONから治療時間を取得
      JSONObject rstCondInfoJson = new JSONObject(rstCondInfo);
      // add #9973 Resolve null exception for key 20240117 ztc start
      if (rstCondInfoJson.has("1")) {
      // add #9973 Resolve null exception for key 20240117 ztc end
        JSONObject condTimeJson = (JSONObject) rstCondInfoJson.get("1");
        // add #9973 Resolve null exception for key 20240117 ztc start
        if (!condTimeJson.isNull("value")) {
        // add #9973 Resolve null exception for key 20240117 ztc end
          Long condTime = condTimeJson.getLong("value");

          // 終了時間 = 開始時間+治療時間
          LocalDateTime endTimeLdt = startTimeLdt.plusMinutes(condTime);


          // 透析開始時刻が１７時以降または透析終了日時が２１時以降の場合
          // mod #10132 時間外加算処理不正 dengshen start
          // if (startTimeLdt.getHour() > 16 || endTimeLdt.getHour() > 20) {
          if (startTimeLdt.getHour() > 16 || endTimeLdt.getHour() > 20
            // 透析終了年月日年、月、日何れかが透析開始年月日より跨った場合
            || !(endTimeLdt.toLocalDate().isEqual(startTimeLdt.toLocalDate()))) {
          // mod #10132 時間外加算処理不正 dengshen end
            existFlg = true;
          }
        }
      }
    }

    // wangzuo アプリケーションログの適正化 Add Start
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyOffHours実施終了：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    return existFlg;
  }

  /**
   * 指定薬剤実施連動
   * 指定薬剤が投与薬剤に存在する場合に該当
   *
   * @param ordNo
   * @param additionTarCd
   * @return
   */
  private Boolean checkApplyMediUsed(Long ordNo, List<Map<String, String>> additionTarCd) {
    // wangzuo アプリケーションログの適正化 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyMediUsed実施開始：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    Boolean existFlg = false;
    for (Map<String, String> tar : additionTarCd) {
      //mod #12623 指示展開処理失敗が発生 zrx start
      if (tar == null) continue;
      String cd = tar.get("cd");
      if (cd == null || !cd.matches("\\d+")) continue;

      List<Long> mediCdList = ordMainDao.selectMediCdList(ordNo, Integer.valueOf(cd));
      if (mediCdList != null && mediCdList.size() > 0) {
        existFlg = true;
      }
      //mod #12623 指示展開処理失敗が発生 zrx end
    }

    // wangzuo アプリケーションログの適正化 Add Start
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyMediUsed実施終了：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    return existFlg;
  }

  /**
   * 長時間加算
   * 治療実績時間が指定時間（算定治療時間）以上の場合
   *
   * @param ordNo
   * @param mstAddition
   * @return
   */
  private Boolean checkActualTreatTime(Long ordNo, MstAddition mstAddition) {
    // wangzuo アプリケーションログの適正化 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkActualTreatTime実施開始：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    if (Objects.isNull(mstAddition.getAdditionDialysisTime())) {
      // 算定治療時間がnullならチェック不能なのでfalseを返す

      // wangzuo アプリケーションログの適正化 Add Start
      eventLogMessage.setLogMessage(this.getClass().getName() + "checkActualTreatTime実施終了：false" + " additionDialysisTime = null");
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // wangzuo アプリケーションログの適正化 Add End

      return false;
    }
    // 対象のordMainを取得
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    if (ordMain != null) {
      // 治療条件項目を取得
      String rstCondInfo = ordMain.getRstCondInfo();
      if (null != rstCondInfo) {
        // 治療条件項目のJSONから治療時間を取得
        JSONObject rstCondInfoJson = new JSONObject(rstCondInfo);
        // add #9973 Resolve null exception for key 20240117 ztc start
        if (rstCondInfoJson.has("1")) {
        // add #9973 Resolve null exception for key 20240117 ztc end
          JSONObject condTimeJson = (JSONObject) rstCondInfoJson.get("1");
          // add #9973 Resolve null exception for key 20240117 ztc start
          if (!condTimeJson.isNull("value")) {
          // add #9973 Resolve null exception for key 20240117 ztc end
            Long condTime = condTimeJson.getLong("value");
            if (condTime != null) {
              // 算定治療時間を取得
              Long additionDialysisTime = mstAddition.getAdditionDialysisTime();
              if (condTime >= additionDialysisTime) {

                // wangzuo アプリケーションログの適正化 Add Start
                eventLogMessage.setLogMessage(this.getClass().getName() + "checkActualTreatTime実施終了：true");
                logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                // wangzuo アプリケーションログの適正化 Add End

                return true;
              }
            }
          }
        }
      }
    }

    // wangzuo アプリケーションログの適正化 Add Start
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkActualTreatTime実施終了：false");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    return false;
  }

  /**
   * 指定治療方法加算
   * 加算マスタに登録された治療方法のいずれかであるとき
   *
   * @param ordNo
   * @param mstAddition
   * @param additionTarCd
   * @return
   */
  private Boolean checkApplyTreatmentUsed(Long ordNo, MstAddition mstAddition,
      List<Map<String, String>> additionTarCd) {

    // ログ出力
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyTreatmentUsed実施開始：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    Boolean existFlg = false;

    // 対象のordMainから治療方法コードを取得
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    Integer treatmentCd = ordMain.getRstTreatmentCd();

    for (Map<String, String> tar : additionTarCd) {
      // 治療方法コードが加算マスタの対象治療方法と一致
      // #11192 2025.04.23 mod Null例外対応 TDC片口 start
//      if (treatmentCd.equals(Integer.valueOf(tar.get("cd")))) {
//        existFlg = true;
//      }
      //mod #12623 指示展開処理失敗が発生 zrx start
      if (tar == null) continue;
      String cd = tar.get("cd");
      if (cd == null || !cd.matches("\\d+")) continue;
      if (Objects.equals(treatmentCd, Integer.valueOf(cd))) {
        existFlg = true;
      }
      // #11192 2025.04.23 mod Null例外対応 TDC片口 end
      //mod #12623 指示展開処理失敗が発生 zrx end
    }

    // ログ出力
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyTreatmentUsed実施終了：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);

    return existFlg;
  }

  /**
   * 障害者加算
   * 透析困難コメントに登録がある場合
   *
   * @param patId
   * @param mstAddition
   * @param additionTarCd
   * @return
   */
  private Boolean checkApplyDiffCom(Long patId, MstAddition mstAddition, List<Map<String, String>> additionTarCd) {
    // wangzuo アプリケーションログの適正化 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyDiffCom実施開始：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    Boolean existFlg = false;
    PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
    if (patPersonalMain != null) {
      List<Map<String, String>> diffComList = changeListMap(patPersonalMain.getDial_diff_com_info());
      if (!diffComList.isEmpty()) {
        for (Map<String, String> diffCom : diffComList) {
          for (Map<String, String> tar : additionTarCd) {
            if (diffCom.get("dial_diff_cd").equals(tar.get("cd")) && diffCom.get("is_dial_diff").equals("1")) {
              existFlg = true;
            }
          }
        }
      }
    }

    // wangzuo アプリケーションログの適正化 Add Start
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyDiffCom実施終了：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    return existFlg;
  }

  /**
   * 指定病名連動
   * 特定の病名が登録されている場合
   *
   * @param patId
   * @param additionTarCd
   * @return
   */
  private Boolean checkApplyDiseaseName(Long patId, List<Map<String, String>> additionTarCd) {
    // wangzuo アプリケーションログの適正化 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyDiseaseName実施開始：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    Boolean existFlg = false;
    for (Map<String, String> tar : additionTarCd) {
      //mod #12623 指示展開処理失敗が発生 zrx start
      if (tar == null) continue;
      String cd = tar.get("cd");
      if (cd == null || !cd.matches("\\d+")) continue;
      Integer count = patUniqueDao.countMedicalAdditionTarget(patId, Integer.valueOf(cd));
      if (count > 0) {
        existFlg = true;
      }
      //mod #12623 指示展開処理失敗が発生 zrx end
    }

    // wangzuo アプリケーションログの適正化 Add Start
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkApplyDiseaseName実施終了：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    return existFlg;
  }

  /**
   * JSon文字列をマップ型リストに変換する処理
   *
   * @param strJson
   *            JSon文字列
   * @return 変換したマップ型リスト
   */
  public List<Map<String, String>> changeListMap(String strJson) {
    // wangzuo アプリケーションログの適正化 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "changeListMap実施開始：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    // 変換したマップ型リスト
    List<Map<String, String>> changedList = new ArrayList<>();

    //add #12623 指示展開処理失敗が発生 zrx start
    if (!StringUtils.hasText(strJson)) {
      strJson = "[]";
    }
    //add #12623 指示展開処理失敗が発生 zrx end

    // 変換処理
    ObjectMapper mapper = new ObjectMapper();
    TypeReference<List<Map<String, String>>> type = new TypeReference<List<Map<String, String>>>() {
    };
    try {
      changedList = mapper.readValue(strJson, type);
    } catch (IOException e) {
      System.err.println(e.getMessage());
    }

    // wangzuo アプリケーションログの適正化 Add Start
    eventLogMessage.setLogMessage(this.getClass().getName() + "changeListMap実施終了：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    return changedList;
  }

  /**
   *
   * @param mstAddition
   * @param ordArr
   * @param calcStartDate 汎用自動算定で、算定回数に「期限」が指定されていた場合の開始日
   */
  private void updateOrdAddition(MstAddition mstAddition, List<OrdAdditionInfo> ordArr, String calcStartDate) {
    // wangzuo アプリケーションログの適正化 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "updateOrdAddition実施開始：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    OrdAdditionInfo info = new OrdAdditionInfo();
    info.setCd(mstAddition.getAdditionCd());
    info.setName(mstAddition.getAdditionName());
    String isEnable = "1";
    if (mstAddition.getAdditionClass().equals("12") && !mstAddition.getAdditionKind().equals("1")) {
      // 加算種別：汎用(12) + 登録区分：自動(1)以外
      isEnable = "0";
    }
    info.setIs_enable(isEnable);
    // 汎用自動算定で、算定回数に「期限」が指定されていた場合場合は start_data を実績に保存する
    if (mstAddition.getAdditionClass().equals("12") && mstAddition.getAdditionSpan().equals("4")) {
      info.setStart_date(calcStartDate);
    }
    ordArr.add(info);

    // wangzuo アプリケーションログの適正化 Add Start
    eventLogMessage.setLogMessage(this.getClass().getName() + "updateOrdAddition実施終了：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End
  }

  /**
   * @param mstAddition
   * @param patList
   * @throws Exception
   */
  private void addAdditionInfo(MstAddition mstAddition, List<AdditionInfo> patList) {
    // wangzuo アプリケーションログの適正化 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "addAdditionInfo実施開始：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    // 更新時刻
    Timestamp now = new Timestamp(System.currentTimeMillis());
    SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");

    AdditionInfo info = new AdditionInfo();
    info.setCd(mstAddition.getAdditionCd());
    String isEnable = "1";
    if (mstAddition.getAdditionClass().equals("12") && !mstAddition.getAdditionKind().equals("1")) {
      // 加算種別：汎用(12) + 登録区分：自動(1)以外
      isEnable = "0";
    }
    info.setIs_enable(isEnable);
    info.setReg_date(dateFormat.format(now));
    patList.add(info);

    // wangzuo アプリケーションログの適正化 Add Start
    eventLogMessage.setLogMessage(this.getClass().getName() + "addAdditionInfo実施終了：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End
  }

  /**
   *
   * @param eventId
   * @return
   */
  private List<String> checkEvent(Integer eventId) {
    // wangzuo アプリケーションログの適正化 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkEvent実施開始：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    List<String> addtionCdArr = new ArrayList<String>();
    switch (eventId) {
    case 1:
      // NOTE : 廃番
      break;
    case 2:
      // 透析完了した時
      addtionCdArr = Arrays.asList("11");
      break;
    case 3:
      // 条件送信
      addtionCdArr = Arrays.asList("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "12", "13");
      break;
    case 5:
      // 治療開始
      addtionCdArr = Arrays.asList("11");
      break;
    default:
      break;
    }

    // wangzuo アプリケーションログの適正化 Add Start
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkEvent実施終了：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    return addtionCdArr;
  }

  /**
   *
   * @param eventId
   * @return
   */
  private List<String> checkPatMainArr(Integer eventId) {
    // wangzuo アプリケーションログの適正化 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkPatMainArr実施開始：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    List<String> patMainArr = new ArrayList<String>();
    switch (eventId) {
    case 1:
      // NOTE : 廃番
      break;
    case 2:
      // 透析完了した時
      patMainArr = Arrays.asList("11");
      break;
    case 3:
      // 条件送信
      patMainArr = Arrays.asList("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "12", "13");
      break;
    case 4:
      // 期加算
      break;
    case 5:
      // 治療開始
      patMainArr = Arrays.asList("11");
      break;
    default:
      break;
    }

    // wangzuo アプリケーションログの適正化 Add Start
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkPatMainArr実施終了：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    return patMainArr;
  }

  /**
   *
   * @param eventId
   * @return
   */
  private List<String> checkOrdMainArr(Integer eventId) {
    // wangzuo アプリケーションログの適正化 Add Start
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkOrdMainArr実施開始：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    List<String> ordMainArr = new ArrayList<String>();
    switch (eventId) {
    case 1:
      // NOTE : 廃番
      break;
    case 2:
      // 透析完了した時
      ordMainArr = Arrays.asList("11");
      break;
    case 3:
      // 条件送信
      ordMainArr = Arrays.asList("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "12", "13");
      break;
    case 5:
      // 治療開始
      ordMainArr = Arrays.asList("11");
      break;
    default:
      break;
    }

    // wangzuo アプリケーションログの適正化 Add Start
    eventLogMessage.setLogMessage(this.getClass().getName() + "checkOrdMainArr実施終了：");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    // wangzuo アプリケーションログの適正化 Add End

    return ordMainArr;
  }
}
