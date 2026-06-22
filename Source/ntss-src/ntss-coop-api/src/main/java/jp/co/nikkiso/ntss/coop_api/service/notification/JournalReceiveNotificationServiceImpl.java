package jp.co.nikkiso.ntss.coop_api.service.notification;

import java.net.URISyntaxException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;

import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.api.service.PatMainDeviceSetInfo.PatMainDeviceSetInfoService;
import jp.co.nikkiso.ntss.coop_api.response.JournalConvertResult;
import jp.co.nikkiso.ntss.coop_api.response.JournalNotificationResult;
import jp.co.nikkiso.ntss.coop_api.service.ConvertCommonService;
import jp.co.nikkiso.ntss.coop_api.service.CoopJournalErrorComponent;
import jp.co.nikkiso.ntss.coop_api.service.LogService;
import jp.co.nikkiso.ntss.coop_api.utils.CoopCdConstant;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.coop_api.utils.JournalParametersUtil;
import jp.co.nikkiso.ntss.coop_api.utils.Key0Constant;
import jp.co.nikkiso.ntss.coop_api.utils.NotificationApiCallUtil;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatUniqueDao;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;
import jp.co.nikkiso.ntss.core.entity.MstPersonalUser;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatUnique;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.entity.custom.Notification;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;

import static jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants.AUX_CODE_ALL;

@Service
public class JournalReceiveNotificationServiceImpl implements JournalReceiveNotificationService {
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  @Autowired
  private NotificationApiCallUtil notificationApiCallUtil;
  @Autowired
  private PatMainDao patMainDao;
  @Autowired
  private PatUniqueDao patUniqueDao;
  @Autowired
  private LogService logService;
  @Autowired
  private MstCoopLayoutDao mstCoopLayoutDao;
  @Autowired
  private ConvertCommonService convertCommonService;
  //add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 20231027  孟堅 start
  @Autowired
  private PatMainDeviceSetInfoService patMainDeviceSetInfoServiceImpl;
  //add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 20231027  孟堅 end

  //add 9583 by kangjie 20240410 start 通知一覧の連携エラー通知の遷移不正
  @Autowired
  private CoopJournalErrorComponent coopJournalErrorComponent;
  //add 9583 by kangjie 20240410 end 通知一覧の連携エラー通知の遷移不正
  private static final String JSONARRAY_EMPTY = "[]";
  // 正規表現文字列
  /**
   * レイアウト中のmulti指定の引数を分割する正規表現
   */
  private static final String LAYOUT_MULTI_DELIM = "[:/]";
  /**
   * 特殊値: CR
   */
  private static final String TELEGRAM_DELIM_CR = "CR";

  /**
   * CR指定に対応する区切り文字
   */
  private static final String TELEGRAM_DELIM_CR_VALUE = "\r";

  /**
   * 特殊値: LF
   */
  private static final String TELEGRAM_DELIM_LF = "LF";

  /**
   * LF指定に対応する区切り文字
   */
  private static final String TELEGRAM_DELIM_LF_VALUE = "\n";

  // #7631-profile連携で患者登録した通知が行われない zhoubin add start
  /**
   * (受信)患者名未定
   */
  private static final String PATNAME_UNKOWN = "患者名不明";
  // #7631-profile連携で患者登録した通知が行われない zhoubin add end

  // 説明
  public enum DESCRIPTION {
    NKK_PROFILE_XML("患者情報（XML)"),
    NKK_PROFILE_TEXTSPECIAL("患者情報（特殊）"),
    NKK_PROFILE_TEXTSTANDARDS("患者情報（標準）"),
    NKK_PROFILE_TEXTEXPANSION("患者情報（拡張）");
    private String result;

    public boolean isSameResult(String target) {
      return this.result.equals(target);
    }

    DESCRIPTION(String result) {
      this.result = result;
    }
  }

  /**
   * 通知
   *
   * @param resultList            journal 結果集合
   * @param journalList           　journal　集合
   * @param orgPatMainMap         　　旧患者基本情報
   * @param orgPatPersonalMainMap 　旧患者個人情報
   * @param orgPatUniqueMap       　旧患者固有情報
   * @return
   * @throws URISyntaxException
   * @throws RuntimeException
   */
  @Override
  public JournalNotificationResult notification(List<JournalConvertResult.ResultMap> resultList, List<SysCoopJournal> journalList, Map<Long, PatMain> orgPatMainMap, Map<Long, PatPersonalMain> orgPatPersonalMainMap, Map<Long, PatUnique> orgPatUniqueMap) throws URISyntaxException, RuntimeException {
    for (JournalConvertResult.ResultMap result : resultList) {
      for (SysCoopJournal journal : journalList) {
        String facilityCd = journal.getFacilityCd();
        try {
          // 変換対象ジャーナルから、データを取得する
          if (journal.getCtlNo() == result.get(JournalParametersUtil.JOURNAL_CTL_NO) || journal.getCtlNo() == result.get(JournalConvertResult.ResultKey.CTL_NO.getKey())) {
            // 成功の場合
            if (NtssCoopApiConstants.AnaResult.DONE.getResult().equals(result.get(JournalConvertResult.ResultKey.ANA_RESULT.getKey()))) {
              // パラメーター　準備
              Object hospPatId = result.get(JournalParametersUtil.HOSP_PAT_ID);
              Long patId = patPersonalMainDao.selectPatIdByHospPatId(facilityCd, (String) hospPatId);
              PatPersonalMain oldPatPersonalMain = orgPatPersonalMainMap.get(patId);
              PatMain oldPatMain = orgPatMainMap.get(patId);
              PatUnique oldPatUnique = orgPatUniqueMap.get(patId);
              PatPersonalMain newPatPersonalMain = patPersonalMainDao.selectById(patId);
              PatMain newPatMain = patMainDao.selectById(patId);
              // #7631-profile連携で患者登録した通知が行われない zhoubin mod start
              //String lastName = Objects.isNull(newPatPersonalMain.getPat_last_name()) ? "" : newPatPersonalMain.getPat_last_name();
              //String firstName = Objects.isNull(newPatPersonalMain.getPat_first_name()) ? "" : newPatPersonalMain.getPat_first_name();
              String lastName = StringUtils.hasLength(newPatPersonalMain.getPat_last_name())
                ? newPatPersonalMain.getPat_last_name() : "";
              String firstName = StringUtils.hasLength(newPatPersonalMain.getPat_first_name())
                ? newPatPersonalMain.getPat_first_name() : "";
              if("".equals(lastName) && "".equals(firstName)) {
                lastName = PATNAME_UNKOWN;
              }
              // #7631-profile連携で患者登録した通知が行われない zhoubin mod end
              JSONObject baseReplaceData = new JSONObject();
              baseReplaceData.put("LASTNAME", lastName);
              baseReplaceData.put("FIRSTNAME", firstName);
              //　通知処理
              if (Key0Constant.GX.equals(journal.getKey0())) {
                notificationGxProcess(journal, oldPatMain, oldPatPersonalMain, oldPatUnique, newPatMain, baseReplaceData, newPatPersonalMain, String.valueOf(hospPatId));
              } else if (Key0Constant.NKK.equals(journal.getKey0())) {
                notificationNkkProcess(journal, oldPatMain, oldPatPersonalMain, oldPatUnique, newPatMain, baseReplaceData, newPatPersonalMain, String.valueOf(hospPatId));
              } else {
                notificationProcess(journal, oldPatMain, oldPatPersonalMain, oldPatUnique, newPatMain, baseReplaceData, newPatPersonalMain, String.valueOf(hospPatId));
              }
              if (CoopCdConstant.PROFILE.equals(journal.getCoopCd())) {
                // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 start
//                if (convertResultMap.containsKey(journal.getPatId())){
//                  if ("C".equals(convertResultMap.get(journal.getPatId()))){
//                    continue;
//                  }
//                }
                if ("C".equals(new String(journal.getDump(), 2, 1))) {
                  continue;
                }
                // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 end
                // 自動計算処理API
                ResponseEntity<String> calcRet = notificationApiCallUtil.updateExamResultCalc(journal.getPatId());
                // 失敗時
                if (calcRet.getStatusCode() != HttpStatus.OK) {
                  JournalNotificationResult notificationResult = new JournalNotificationResult();
                  notificationResult.setMessage("自動計算処理API実行失敗");
                  notificationResult.setBeBad(true);
                  return notificationResult;
                }

              } else if (CoopCdConstant.EXAM_RST.equals(journal.getCoopCd())) {
                // 自動計算処理API
                ResponseEntity<String> calcRet = notificationApiCallUtil.updateExamResultCalc(journal.getPatId());
                // 失敗時
                if (calcRet.getStatusCode() != HttpStatus.OK) {
                  JournalNotificationResult notificationResult = new JournalNotificationResult();
                  notificationResult.setMessage("自動計算処理API実行失敗");
                  notificationResult.setBeBad(true);
                  return notificationResult;
                }
                // add 2021-07-28 #5607：連動機能の実装確認  wangchen end
                // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 20231027  孟堅 start
                if (result.get(JournalParametersUtil.EXAMMAINCD) != null) {
                  int isTpHTDataAvailableFlag = patMainDeviceSetInfoServiceImpl.isTpHTDataAvailable(journal.getFacilityCd(), Long.valueOf(result.get(JournalParametersUtil.EXAMMAINCD).toString()));
//                  patMainDeviceSetInfoServiceImpl.updDeviceSetInfo(journal.getFacilityCd(), journal.getPatId(), Long.valueOf(result.get(JournalParametersUtil.EXAMMAINCD).toString()), null);
                  if(isTpHTDataAvailableFlag > 0){
                    patMainDeviceSetInfoServiceImpl.updDeviceSetInfo(journal.getFacilityCd(), journal.getPatId(), null, isTpHTDataAvailableFlag);
                  }
                }
                // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 20231027  孟堅 end
              }

            } else {
            	//スキップの場合はエラー通知を行わない #12217 NKK連携 exam_rst FNSiに存在しない患者のデータがスキップ処理されるがエラーとして通知される
            	if (!NtssCoopApiConstants.AnaResult.SKIP.getResult().equals(result.get(JournalConvertResult.ResultKey.ANA_RESULT.getKey()))) {
            		coopJournalErrorComponent.sendCoopJournalError(journal);
            	}
            	loserLogEx(journal);
            }
            break;
          }
        }catch (Exception ex){
          ex.getStackTrace();
          LogEx(journal,ex.getStackTrace().toString());
        }
      }
    }
    // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
    JournalNotificationResult notificationResult = new JournalNotificationResult();
    notificationResult.setResultList(resultList);
    notificationResult.setBeBad(false);
    return notificationResult;
  }

  /**
   * default通知処理
   *
   * @param journal
   * @param oldpatMain
   * @param oldPatPersonalMain
   * @param oldPatUnique
   */
  private void notificationProcess(SysCoopJournal journal, PatMain oldpatMain, PatPersonalMain oldPatPersonalMain, PatUnique oldPatUnique, PatMain newPatMain, JSONObject baseReplaceData, PatPersonalMain newPatPersonalMain, String hospPatId) {
    List<Notification> notificationList = new LinkedList<>();
    // 新患通知
    Notification notificationNewProfile = notificationNewProfile(newPatPersonalMain, oldPatPersonalMain,hospPatId, journal, baseReplaceData);
    if (notificationNewProfile != null) {
      notificationList.add(notificationNewProfile);
    }
    // 感染症(＋)に変更通知
    Notification notificationInfectInfo = notificationInfectInfo(oldpatMain, newPatMain, journal, baseReplaceData);
    if (notificationInfectInfo != null) {
      notificationList.add(notificationInfectInfo);
    }
    // 禁忌・ｱﾚﾙｷﾞｰ追加・更新・削除通知
    Notification notificationTabooallergy = notificationTabooallergy(oldpatMain, newPatMain, journal, baseReplaceData);
    if (notificationTabooallergy != null) {
      notificationList.add(notificationTabooallergy);
    }
    // 死亡通知
    Notification notificationDie = notificationDie(newPatPersonalMain, journal, baseReplaceData);
    if (notificationDie != null) {
      notificationList.add(notificationDie);
    }
    // 患者情報連携通知
    Notification notificationProfile = notificationProfile(newPatPersonalMain, oldpatMain, oldPatUnique, oldPatPersonalMain, journal, baseReplaceData);
    if (notificationProfile != null) {
      notificationList.add(notificationProfile);
    }
    // オーダ受け連携通知
    Notification notificationOrdDial = notificationOrdDial(journal);
    if (notificationOrdDial != null) {
      notificationList.add(notificationOrdDial);
    }
    // 担当設定通知
    // 担当者の変更箇所のみのデータ（変更がない箇所は空データ、initValue/editValueを含む）
    JSONArray changedStaffInfoArray = getChangedRecordChargeStaffInfo(oldpatMain,newPatMain);
    JSONArray patMainStaffInfoArray = new JSONArray(newPatMain.getCharge_staff_info());
    for (int idx = 0; idx < changedStaffInfoArray.length(); idx++) {
      JSONObject changedStaffInfo = changedStaffInfoArray.getJSONObject(idx);
      Notification notificationChargeStaff = notificationChargeStaff(changedStaffInfo,journal);
      if (notificationChargeStaff != null) {
        notificationList.add(notificationChargeStaff);
      }
    }
    sendNotification(notificationList);
  }

  /**
   * gx通知処理
   *
   * @param journal
   * @param oldpatMain
   * @param oldPatPersonalMain
   * @param oldPatUnique
   */
  private void notificationGxProcess(SysCoopJournal journal, PatMain oldpatMain, PatPersonalMain oldPatPersonalMain, PatUnique oldPatUnique, PatMain newPatMain, JSONObject baseReplaceData, PatPersonalMain newPatPersonalMain, String hospPatId) {
    List<Notification> notificationList = new LinkedList<>();
    if (CoopCdConstant.PROFILE.equals(journal.getCoopCd())) {
      // 新患通知
      Notification notificationNewProfile = notificationNewProfile(newPatPersonalMain,oldPatPersonalMain,hospPatId, journal, baseReplaceData);
      if (notificationNewProfile != null) {
        notificationList.add(notificationNewProfile);
      }
      // 感染症(＋)に変更通知
      Notification notificationInfectInfo = notificationInfectInfo(oldpatMain, newPatMain, journal, baseReplaceData);
      if (notificationInfectInfo != null) {
        notificationList.add(notificationInfectInfo);
      }
      // 禁忌・ｱﾚﾙｷﾞｰ追加・更新・削除通知
      Notification notificationTabooallergy = notificationTabooallergy(oldpatMain, newPatMain, journal, baseReplaceData);
      if (notificationTabooallergy != null) {
        notificationList.add(notificationTabooallergy);
      }
      // 死亡通知
      Notification notificationDie = notificationDie(newPatPersonalMain, journal, baseReplaceData);
      if (notificationDie != null) {
        notificationList.add(notificationDie);
      }
      // 患者情報連携通知
      Notification notificationProfile = notificationProfile(newPatPersonalMain, oldpatMain, oldPatUnique, oldPatPersonalMain, journal, baseReplaceData);
      if (notificationProfile != null) {
        notificationList.add(notificationProfile);
      }
    } else if (CoopCdConstant.EXAM_RST.equals(journal.getCoopCd())) {
      // 感染症(＋)に変更通知
      Notification notificationInfectInfo = notificationInfectInfo(oldpatMain, newPatMain, journal, baseReplaceData);
      if (notificationInfectInfo != null) {
        notificationList.add(notificationInfectInfo);
      }
    } else if (CoopCdConstant.INI_DIAL.equals(journal.getCoopCd())) {
      // 新患通知
      Notification notificationNewProfile = notificationNewProfile(newPatPersonalMain,oldPatPersonalMain, hospPatId, journal, baseReplaceData);
      if (notificationNewProfile != null) {
        notificationList.add(notificationNewProfile);
      }
      // オーダ受け連携通知
      Notification notificationNoini_Dial = new Notification();
      notificationNoini_Dial.notificationNo = CoreConstant.NotificationDefinition.COOP_JOURNAL_INI_DIAL;
      // modify 9583 by kangjie 20240404 start 通知一覧の連携エラー通知の遷移不正
      JSONObject replaceData = new JSONObject();
      replaceData.put("PATID",journal.getPatId()==null?null:String.valueOf(journal.getPatId()));
      replaceData.put("FACILITYCD",journal.getFacilityCd());
//      notificationNoini_Dial.replaceData = new JSONObject();
      notificationNoini_Dial.replaceData = replaceData;
      // modify 9583 by kangjie 20240404 end 通知一覧の連携エラー通知の遷移不正
      notificationNoini_Dial.facilityCd = journal.getFacilityCd();
      notificationList.add(notificationNoini_Dial);

    }
    // 通知発送
    sendNotification(notificationList);
  }

  /**
   * nkk通知処理
   *
   * @param journal
   * @param oldpatMain
   * @param oldPatPersonalMain
   * @param oldPatUnique
   */
  private void notificationNkkProcess(SysCoopJournal journal, PatMain oldpatMain, PatPersonalMain oldPatPersonalMain, PatUnique oldPatUnique, PatMain newPatMain, JSONObject baseReplaceData, PatPersonalMain newPatPersonalMain, String hospPatId) {
    List<Notification> notificationList = new LinkedList<>();
    MstCoopLayout mcl = getMstCoopLayout(journal.getFacilityCd(), journal.getDirection(), journal.getCoopCd(), journal.getCoopCdIndex(), journal.getCoopVersion(), JournalConvertConstants.AUX_CODE_PRELOGIC);
    if (CoopCdConstant.PROFILE.equals(journal.getCoopCd())) {
      if (mcl != null) {
        if (JournalConvertConstants.FORMAT_XML.equals(mcl.getCoopFormat()) && DESCRIPTION.NKK_PROFILE_XML.result.equals(mcl.getDescription())) {
          // 新患通知
          Notification notificationNewProfile = notificationNewProfile(newPatPersonalMain,oldPatPersonalMain, hospPatId, journal, baseReplaceData);
          if (notificationNewProfile != null) {
            notificationList.add(notificationNewProfile);
          }
          // 感染症(＋)に変更通知
          Notification notificationInfectInfo = notificationInfectInfo(oldpatMain, newPatMain, journal, baseReplaceData);
          if (notificationInfectInfo != null) {
            notificationList.add(notificationInfectInfo);
          }
          // 禁忌・ｱﾚﾙｷﾞｰ追加・更新・削除通知
          Notification notificationTabooallergy = notificationTabooallergy(oldpatMain, newPatMain, journal, baseReplaceData);
          if (notificationTabooallergy != null) {
            notificationList.add(notificationTabooallergy);
          }
          // 死亡通知
          Notification notificationDie = notificationDie(newPatPersonalMain, journal, baseReplaceData);
          if (notificationDie != null) {
            notificationList.add(notificationDie);
          }
          // 患者情報連携通知
          Notification notificationProfile = notificationProfile(newPatPersonalMain, oldpatMain, oldPatUnique, oldPatPersonalMain, journal, baseReplaceData);
          if (notificationProfile != null) {
            notificationList.add(notificationProfile);
          }
        } else if (JournalConvertConstants.FORMAT_TEXT.equals(mcl.getCoopFormat()) && DESCRIPTION.NKK_PROFILE_TEXTSPECIAL.result.equals(mcl.getDescription())) {
          // 新患通知
          Notification notificationNewProfile = notificationNewProfile(newPatPersonalMain,oldPatPersonalMain,  hospPatId, journal, baseReplaceData);
          if (notificationNewProfile != null) {
            notificationList.add(notificationNewProfile);
          }
          // 患者情報連携通知
          Notification notificationProfile = notificationProfile(newPatPersonalMain, oldpatMain, oldPatUnique, oldPatPersonalMain, journal, baseReplaceData);
          if (notificationProfile != null) {
            notificationList.add(notificationProfile);
          }
        } else if (JournalConvertConstants.FORMAT_TEXT.equals(mcl.getCoopFormat()) && DESCRIPTION.NKK_PROFILE_TEXTSTANDARDS.result.equals(mcl.getDescription())) {
          // 新患通知
          Notification notificationNewProfile = notificationNewProfile(newPatPersonalMain,oldPatPersonalMain, hospPatId, journal, baseReplaceData);
          if (notificationNewProfile != null) {
            notificationList.add(notificationNewProfile);
          }
          // 患者情報連携通知
          Notification notificationProfile = notificationProfile(newPatPersonalMain, oldpatMain, oldPatUnique, oldPatPersonalMain, journal, baseReplaceData);
          if (notificationProfile != null) {
            notificationList.add(notificationProfile);
          }
        } else if (JournalConvertConstants.FORMAT_TEXT.equals(mcl.getCoopFormat()) && DESCRIPTION.NKK_PROFILE_TEXTEXPANSION.result.equals(mcl.getDescription())) {
          // 新患通知
          Notification notificationNewProfile = notificationNewProfile(newPatPersonalMain,oldPatPersonalMain, hospPatId, journal, baseReplaceData);
          if (notificationNewProfile != null) {
            notificationList.add(notificationNewProfile);
          }

          // 患者情報連携通知
          Notification notificationProfile = notificationProfile(newPatPersonalMain, oldpatMain, oldPatUnique, oldPatPersonalMain, journal, baseReplaceData);
          if (notificationProfile != null) {
            notificationList.add(notificationProfile);
          }
        }
      }
    } else if (CoopCdConstant.EXAM_RST.equals(journal.getCoopCd())) {
      // 感染症(＋)に変更通知
      Notification notificationInfectInfo = notificationInfectInfo(oldpatMain, newPatMain, journal, baseReplaceData);
      if (notificationInfectInfo != null) {
        notificationList.add(notificationInfectInfo);
      }
    }
    // 通知発送
    sendNotification(notificationList);
  }

  /**
   * No.1 新規患者登録通知
   *
   * @param patPersonalMain
   * @param hospPatId
   * @param journal
   * @param baseReplaceData
   * @return
   */
  private Notification notificationNewProfile(PatPersonalMain patPersonalMain,PatPersonalMain oldPatPersonalMain, Object hospPatId, SysCoopJournal journal, JSONObject baseReplaceData) {
    if (oldPatPersonalMain==null) {
      // mod 2022-06-14 5607連動機能の実装確認 修正 李 end
      // 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
      Notification notification = new Notification();
      notification.notificationNo = CoreConstant.NotificationDefinition.CREATE_PAT;
      JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
      replaceData.put("PATID", patPersonalMain.getPat_id().toString());
      replaceData.put("HOSPPATID", hospPatId);
      replaceData.put("FACILITYCD", journal.getFacilityCd());
      notification.replaceData = replaceData;
      notification.facilityCd = journal.getFacilityCd();
      return notification;
    }
    return null;
  }
  /**
   * No.3 感染症(＋)に変更通知
   *
   * @param oldPatMain
   * @param newPatMain
   * @param journal
   * @param baseReplaceData
   * @return
   */
  private Notification notificationInfectInfo(PatMain oldPatMain, PatMain newPatMain, SysCoopJournal journal, JSONObject baseReplaceData) {
    List<String> newinfectionCdList = this.getinfectInfo(newPatMain);
    List<String> oldinfectionCdList = this.getinfectInfo(oldPatMain);
    Boolean infectInfoFlag = false;
    if (oldPatMain != null && newPatMain != null) {
        for (int i = 0; i < newinfectionCdList.size(); i++) {
          if (!oldinfectionCdList.contains(newinfectionCdList.get(i))) {
            infectInfoFlag = true;
            break;
          }
        }
    } else {
      if (newinfectionCdList.size() > 0) {
        infectInfoFlag = true;
      }
    }
    if (infectInfoFlag) {
      Notification notification = new Notification();
      notification.notificationNo = CoreConstant.NotificationDefinition.CHANGE_INFECT_POSITIVE;
      JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
      replaceData.put("PATID", newPatMain.getPat_id().toString());
      replaceData.put("FACILITYCD", journal.getFacilityCd());
      notification.replaceData = replaceData;
      notification.facilityCd = journal.getFacilityCd();
      return notification;
    }
    return null;
  }


  /**
   * No.4 禁忌・ｱﾚﾙｷﾞｰ追加・更新・削除通知
   *
   * @param oldPatMain
   * @param newPatMain
   * @param journal
   * @param baseReplaceData
   * @return
   */
  private Notification notificationTabooallergy(PatMain oldPatMain, PatMain newPatMain, SysCoopJournal journal, JSONObject baseReplaceData) {
    List<JSONObject> oldTabooAllergyInfoList = new ArrayList<>();
    if (oldPatMain != null) {
      String taboo_allergy_info = oldPatMain.getTaboo_allergy_info();
      if (!"[]".equals(taboo_allergy_info)) {
        JSONArray taboo_allergy_infoJsonList = new JSONArray(taboo_allergy_info);
        for (int i = 0; i < taboo_allergy_infoJsonList.length(); i++) {
          oldTabooAllergyInfoList.add(taboo_allergy_infoJsonList.getJSONObject(i));
        }
      }
    }
    List<JSONObject> newTabooAllergyInfoList = new ArrayList<>();
    if (newPatMain != null) {
      String taboo_allergy_info = newPatMain.getTaboo_allergy_info();
      if (!"[]".equals(taboo_allergy_info)) {
        JSONArray taboo_allergy_infoJsonList = new JSONArray(taboo_allergy_info);
        for (int i = 0; i < taboo_allergy_infoJsonList.length(); i++) {
          newTabooAllergyInfoList.add(taboo_allergy_infoJsonList.getJSONObject(i));
        }
      }
    }
    boolean tabooAllergyTag = false;
    if (oldPatMain != null && newPatMain != null) {
      if (oldTabooAllergyInfoList.size() != newTabooAllergyInfoList.size()) {
        tabooAllergyTag = true;

      } else {
        for (int i = 0; i < oldTabooAllergyInfoList.size(); i++) {

          if (!(newTabooAllergyInfoList.get(i).get("disp_order").toString().equals(oldTabooAllergyInfoList.get(i).get("disp_order").toString()) &&
            newTabooAllergyInfoList.get(i).get("category_class").toString().equals(oldTabooAllergyInfoList.get(i).get("category_class").toString()) &&
            newTabooAllergyInfoList.get(i).get("taboo_allergy_cd").toString().equals(oldTabooAllergyInfoList.get(i).get("taboo_allergy_cd").toString()) &&
            newTabooAllergyInfoList.get(i).get("taboo_allergy_class").toString().equals(oldTabooAllergyInfoList.get(i).get("taboo_allergy_class").toString()) &&
            newTabooAllergyInfoList.get(i).get("content").toString().equals(oldTabooAllergyInfoList.get(i).get("content").toString()) &&
            newTabooAllergyInfoList.get(i).get("memo").toString().equals(oldTabooAllergyInfoList.get(i).get("memo").toString()))) {
            tabooAllergyTag = true;
            break;
          }
        }

      }
    } else {
      if(newTabooAllergyInfoList.size()>0){
        tabooAllergyTag = true;
      }
    }
    if (tabooAllergyTag) {
      Notification notification = new Notification();
      notification.notificationNo = CoreConstant.NotificationDefinition.UPDATE_TABOO_ALLERGY;
      JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
      replaceData.put("PATID", newPatMain.getPat_id().toString());
      replaceData.put("FACILITYCD", journal.getFacilityCd());
      notification.replaceData = replaceData;
      notification.facilityCd = journal.getFacilityCd();
      return notification;
    }
    return null;
  }
  /**
   *　No.5～10 入外・転入出
   * TODO 未実装
   */
  /**
   *　No.13 患者グループ通知
   * TODO 未実装
   */
  /**
   *　No.15 担当者に設定通知
   * @param patMainStaffInfoArray
   * @param changedStaffInfo
   * @param journal
   * @return
   */
  private Notification notificationChargeStaff(JSONObject changedStaffInfo,SysCoopJournal journal) {
	  if (!CoopCdConstant.PROFILE.equals(journal.getCoopCd())) {
		  return null;
	  }
	  Notification notificationNoini_Dial = new Notification();
	  notificationNoini_Dial.notificationNo = CoreConstant.NotificationDefinition.SET_CHARGE_STAFF;
	  JSONObject replaceData = new JSONObject();
    Long userId = changedStaffInfo.getLong("staff_cd");
    // 利用者名の取得
    MstPersonalUser staffUser = mstPersonalUserDao.selectById(userId);
    String staffLastName = staffUser.getUserLastName();
    String staffFirstName = staffUser.getUserFirstName();
    // 担当者種別の取得
    String mainStaff = changedStaffInfo.has("is_main") && changedStaffInfo.get("is_main").equals("1")
        ? "主治医"
        : "";
    String chargeStaff = changedStaffInfo.has("is_charge") && changedStaffInfo.get("is_charge").equals("1")
        ? "担当者"
        : "";
    String punctureStaff = changedStaffInfo.has("is_puncture") && changedStaffInfo.get("is_puncture").equals("1")
        ? "穿刺者"
        : "";
    String comma1 = !mainStaff.equals("") && !chargeStaff.equals("") ? "、" : "";
    String comma2 = !chargeStaff.equals("") && !punctureStaff.equals("") ? "、" : "";
    String StaffType = mainStaff + comma1 + chargeStaff + comma2 + punctureStaff;
    replaceData.put("STAFFLASTNAME", staffLastName);
    replaceData.put("STAFFFIRSTNAME", staffFirstName);
    replaceData.put("STAFFTYPE", StaffType);
	  replaceData.put("PATID", journal.getPatId() == null ? null : String.valueOf(journal.getPatId()));
	  replaceData.put("FACILITYCD", journal.getFacilityCd());
    replaceData.put("USERID", userId.toString());
	  notificationNoini_Dial.replaceData = replaceData;
	  notificationNoini_Dial.facilityCd = journal.getFacilityCd();
	  return notificationNoini_Dial;
	}
  /**
   *　変更した担当者を取得
   * @param oldPatMain
   * @param newPatMain
   * @return
   */
  private JSONArray getChangedRecordChargeStaffInfo(PatMain oldPatMain, PatMain newPatMain) {
    JSONArray oldPatMainStaffInfoArray = new JSONArray();
    if (oldPatMain != null) {
      oldPatMainStaffInfoArray = new JSONArray(oldPatMain.getCharge_staff_info());
    }
    JSONArray newPatMainStaffInfoArray = new JSONArray();
    if (newPatMain != null) {
      newPatMainStaffInfoArray = new JSONArray(newPatMain.getCharge_staff_info());
    }
    JSONArray changedRecordChargeStaffInfoArray = new JSONArray();
    if (newPatMain != null) {
      for (int idx1 = 0; idx1 < newPatMainStaffInfoArray.length(); idx1++) {
          JSONObject newChangedStaffInfo = newPatMainStaffInfoArray.getJSONObject(idx1);
          boolean isNew = true;
          if (oldPatMain != null) {
              for (int idx2 = 0; idx2 < oldPatMainStaffInfoArray.length(); idx2++) {
                  JSONObject oldChangedStaffInfo = oldPatMainStaffInfoArray.getJSONObject(idx2);
                  if (newChangedStaffInfo.toString().equals(oldChangedStaffInfo.toString())){
                    isNew = false;
                  }
              }
          }
          if(isNew){
            changedRecordChargeStaffInfoArray.put(newChangedStaffInfo);
          }
      }
    }
    return changedRecordChargeStaffInfoArray;
  }
  /**
   * No.10 死亡通知
   *
   * @param newPatPersonalMain
   * @param journal
   * @param baseReplaceData
   * @return
   */
  private Notification notificationDie(PatPersonalMain newPatPersonalMain, SysCoopJournal journal, JSONObject baseReplaceData) {
    boolean dieTag = false;
    if (newPatPersonalMain!=null&&"1".equals(newPatPersonalMain.getIs_die())) {
        dieTag = true;
    }
    if (dieTag) {
      Notification notification = new Notification();
      notification.notificationNo = CoreConstant.NotificationDefinition.DEATH;
      JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
      String DIEDATE="";
      if (newPatPersonalMain.getDie_date()!=null){
        Calendar cal = Calendar.getInstance();
        cal.setTime((newPatPersonalMain.getDie_date()));
        DIEDATE = cal.get(Calendar.YEAR)+"年"+(cal.get(Calendar.MONTH) + 1)+"月"+cal.get(Calendar.DAY_OF_MONTH)+"日";
      }else{
        DIEDATE="死亡日不明";
      }
      replaceData.put("DIEDATE", DIEDATE );
      replaceData.put("PATID", newPatPersonalMain.getPat_id().toString());
      replaceData.put("FACILITYCD", journal.getFacilityCd());
      notification.replaceData = replaceData;
      notification.facilityCd = journal.getFacilityCd();
      return notification;
    }
    return null;
  }

  /**
   * 患者情報連携通知
   *
   * @param patPersonalMain
   * @param oldPatMain
   * @param oldPatUnique
   * @param oldPatPersonalMain
   * @param journal
   * @param baseReplaceData
   * @return
   */
  private Notification notificationProfile(PatPersonalMain patPersonalMain, PatMain oldPatMain, PatUnique oldPatUnique, PatPersonalMain oldPatPersonalMain, SysCoopJournal journal, JSONObject baseReplaceData) {
		// 「profile:患者プロファイル」処理 成功時
		// 通知メッセージ及び付加情報の変換用JSONデータを作成 値は文字列型にすること
		long patId = patPersonalMain.getPat_id();
		PatMain newPatMain = patMainDao.selectById(patId);
		PatUnique newPatUnique = patUniqueDao.selectByPatId(patId);
		PatPersonalMain newPatpersonMain = patPersonalMainDao.selectById(patId);
		// mod #8181 【デグレ】profile連携の電文解析処理で失敗しする 20221214 zhaoqi start
		if (oldPatPersonalMain == null ||
				(oldPatMain != null && oldPatUnique != null && oldPatPersonalMain != null
		// #8086-電文作成処理タイムアウトの変換ステータスがエラーではなくスキップになっている 周 20221220 add start
				&& newPatMain != null && newPatUnique != null && newPatpersonMain != null
				// #8086-電文作成処理タイムアウトの変換ステータスがエラーではなくスキップになっている 周 20221220 add end
				&& isPatUpdated(oldPatMain, oldPatUnique, oldPatPersonalMain, newPatMain, newPatUnique,
						newPatpersonMain))) {
			JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
			replaceData.put("PATID", String.valueOf(patId));
			replaceData.put("FACILITYCD", journal.getFacilityCd());
			Long notificationNo = CoreConstant.NotificationDefinition.COOP_JOURNAL_PROFILE;
			Notification notification = new Notification();
			notification.notificationNo = notificationNo;
			notification.replaceData = replaceData;
			notification.facilityCd = journal.getFacilityCd();
			return notification;
			// mod #8181 【デグレ】profile連携の電文解析処理で失敗しする 20221214 zhaoqi end
			// #7631-profile連携で患者登録した通知が行われない(項目更新あり場合のみ通知) 周 mod end
			// mod #7631 【デグレ】profile連携で患者登録した通知が行われない 20221124 孟堅 end
		}
		return null;
  }

  /**
   * オーダ受け連携通知
   * @param journal
   * @return
   */
  private Notification notificationOrdDial(SysCoopJournal journal) {
	  if (!CoopCdConstant.ORD_DIAL.equals(journal.getCoopCd())) {
		  return null;
	  }
	  Notification notificationNoini_Dial = new Notification();
	  notificationNoini_Dial.notificationNo = CoreConstant.NotificationDefinition.COOP_JOURNAL_INI_DIAL;
	  JSONObject replaceData = new JSONObject();
	  replaceData.put("PATID", journal.getPatId() == null ? null : String.valueOf(journal.getPatId()));
	  replaceData.put("FACILITYCD", journal.getFacilityCd());
	  notificationNoini_Dial.replaceData = replaceData;
	  notificationNoini_Dial.facilityCd = journal.getFacilityCd();
	  return notificationNoini_Dial;
	}

  /**
   * 連携が成功したらお知らせします
   *
   * @param notificationList
   */
  private void sendNotification(List<Notification> notificationList) {
    for (Notification notification : notificationList) {
      try {
        notificationApiCallUtil.registerNotification(notification.notificationNo, notification.facilityCd, notification.replaceData);
      } catch (Exception e) {
        StackTraceElement[] list = null;
        String errAdd = "";
        if (e.getCause() != null && e.getCause().getStackTrace() != null
          && e.getCause().getStackTrace().length > 0) {
          list = e.getCause().getStackTrace();
          for (StackTraceElement err : list) {
            if (err != null && err.toString().startsWith("jp.co.")) {
              errAdd = errAdd + "\r\n" + err.toString();
            }
          }
        }
        if (StringUtils.isEmpty(errAdd)) {
          list = e.getStackTrace();
          for (StackTraceElement err : list) {
            if (err != null && err.toString().startsWith("jp.co.")) {
              errAdd = errAdd + "\r\n" + err.toString();
            }
          }
        }
        String error = String.format("[連携が成功したらお知らせします]処理で予期せぬエラーが発生しました。[%s][%s]", e, errAdd);
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(error);
        eventLogMessage.setFacilityCd(notification.facilityCd);
        eventLogMessage.setInvokeClass(this.getClass().getName());
        logService.log(LogLevel.DEBUG, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      }
    }
// add 2021-11-11 #5896:SSI連携ができない(患者プロファイル) 孫 end
  }

  // #7631-profile連携で患者登録した通知が行われない(項目更新あり場合のみ通知) 周 add start

  /**
   * 患者情報連携通知
   *
   * @param oldPatMain
   * @param oldPatUnique
   * @param oldPatPersonalMain
   * @param newPatMain
   * @param newPatUnique
   * @param newPatPersonalMain
   * @return
   */
  private boolean isPatUpdated(PatMain oldPatMain, PatUnique oldPatUnique, PatPersonalMain oldPatPersonalMain,
                               PatMain newPatMain, PatUnique newPatUnique, PatPersonalMain newPatPersonalMain) {
    return isPatMainUpdated(oldPatMain, newPatMain)
      || isPatUniqueUpdated(oldPatUnique, newPatUnique)
      || isPatPersonalMainUpdated(oldPatPersonalMain, newPatPersonalMain);
  }
  /**
   * 患者固有情報チェック
   *
   * @param oldPatMain
   * @param newPatMain
   * @return
   */
  private boolean isPatMainUpdated(PatMain oldPatMain, PatMain newPatMain) {
    //インプラント
    if (null != newPatMain.getImplant_info() && 0 != JSONARRAY_EMPTY.compareTo(newPatMain.getImplant_info())) {
      if (null == oldPatMain.getImplant_info()
        || 0 == JSONARRAY_EMPTY.compareTo(oldPatMain.getImplant_info())) {
        return true;
      }

      List<Object> oldImplantList = (new JSONArray(oldPatMain.getImplant_info())).toList();
      List<Object> newImplantList = (new JSONArray(newPatMain.getImplant_info())).toList();
      if (oldImplantList.size() != newImplantList.size()) {
        return true;
      }

      int implantCount = 0;
      for (Object o1 : newImplantList) {
        boolean isMatch = false;
        for (Object o2 : oldImplantList) {
          if (0 == ((HashMap) o1).get("implant_cd").toString().compareTo(((HashMap) o2).get("implant_cd").toString())) {
            implantCount++;
            isMatch = true;
            break;
          }
        }
        if (!isMatch) {
          return true;
        }
      }
      if (implantCount != newImplantList.size()) {
        return true;
      }
    }

    //感染症有無
    if (null != newPatMain.getInfect_info() && 0 != JSONARRAY_EMPTY.compareTo(newPatMain.getInfect_info())) {
      if (null == oldPatMain.getInfect_info()
        || 0 == JSONARRAY_EMPTY.compareTo(oldPatMain.getInfect_info())) {
        return true;
      }

      List<Object> oldInfectList = (new JSONArray(oldPatMain.getInfect_info())).toList();
      List<Object> newInfectList = (new JSONArray(newPatMain.getInfect_info())).toList();
      if (oldInfectList.size() != newInfectList.size()) {
        return true;
      }

      int infectCount = 0;
      for (Object o1 : newInfectList) {
        boolean isMatch = false;
        for (Object o2 : oldInfectList) {
          if (0 == ((HashMap) o1).get("infection_cd").toString().compareTo(((HashMap) o2).get("infection_cd").toString())
            && 0 == ((HashMap) o1).get("infect").toString().compareTo(((HashMap) o2).get("infect").toString())) {
            infectCount++;
            isMatch = true;
            break;
          }
        }
        if (!isMatch) {
          return true;
        }
      }
      if (infectCount != newInfectList.size()) {
        return true;
      }
    }

    //糖尿病患者扱いなし？
    //血糖検査有無なし？
    //確定転入出状態なし？
    //予定転入出状態なし？
    //予定転入出日時なし？
    //患者メモ情報
    if (null != newPatMain.getPat_memo_info() && 0 != JSONARRAY_EMPTY.compareTo(newPatMain.getPat_memo_info())) {
      if (null == oldPatMain.getPat_memo_info()
        || 0 == JSONARRAY_EMPTY.compareTo(oldPatMain.getPat_memo_info())) {
        return true;
      }

      List<Object> oldMemoList = (new JSONArray(oldPatMain.getPat_memo_info())).toList();
      List<Object> newMemoList = (new JSONArray(newPatMain.getPat_memo_info())).toList();
      if (oldMemoList.size() != newMemoList.size()) {
        return true;
      }

      int memoCount = 0;
      for (Object o1 : newMemoList) {
        boolean isMatch = false;
        for (Object o2 : oldMemoList) {
          if (((null == ((HashMap) o1).get("title") && null == ((HashMap) o2).get("title"))
            || (null != ((HashMap) o1).get("title") && null != ((HashMap) o2).get("title")
            && 0 == ((HashMap) o1).get("title").toString().compareTo(((HashMap) o2).get("title").toString())))
            && ((null == ((HashMap) o1).get("content") && null == ((HashMap) o2).get("content"))
            || (null != ((HashMap) o1).get("content") && null != ((HashMap) o2).get("content")
            && 0 == ((HashMap) o1).get("content").toString().compareTo(((HashMap) o2).get("content").toString())))) {
            memoCount++;
            isMatch = true;
            break;
          }
        }
        if (!isMatch) {
          return true;
        }
      }
      if (memoCount != newMemoList.size()) {
        return true;
      }
    }

    //加算情報なし？
    //担当スタッフ情報
    if (null != newPatMain.getCharge_staff_info() && 0 != JSONARRAY_EMPTY.compareTo(newPatMain.getCharge_staff_info())) {
      if (null == oldPatMain.getCharge_staff_info()
        || 0 == JSONARRAY_EMPTY.compareTo(oldPatMain.getCharge_staff_info())) {
        return true;
      }

      List<Object> oldStaffList = (new JSONArray(oldPatMain.getCharge_staff_info())).toList();
      List<Object> newStaffList = (new JSONArray(newPatMain.getCharge_staff_info())).toList();
      if (oldStaffList.size() != newStaffList.size()) {
        return true;
      }

      int staffCount = 0;
      for (Object o1 : newStaffList) {
        boolean isMatch = false;
        for (Object o2 : oldStaffList) {
          if (((null == ((HashMap) o1).get("staff_cd") && null == ((HashMap) o2).get("staff_cd"))
            || (null != ((HashMap) o1).get("staff_cd") && null != ((HashMap) o2).get("staff_cd")
            && 0 == ((HashMap) o1).get("staff_cd").toString().compareTo(((HashMap) o2).get("staff_cd").toString())))
            && ((null == ((HashMap) o1).get("is_charge") && null == ((HashMap) o2).get("is_charge"))
            || (null != ((HashMap) o1).get("is_charge") && null != ((HashMap) o2).get("is_charge")
            && 0 == ((HashMap) o1).get("is_charge").toString().compareTo(((HashMap) o2).get("is_charge").toString())))
            && ((null == ((HashMap) o1).get("is_puncture") && null == ((HashMap) o2).get("is_puncture"))
            || (null != ((HashMap) o1).get("is_puncture") && null != ((HashMap) o2).get("is_puncture")
            && 0 == ((HashMap) o1).get("is_puncture").toString().compareTo(((HashMap) o2).get("is_puncture").toString())))
            && ((null == ((HashMap) o1).get("is_main") && null == ((HashMap) o2).get("is_main"))
            || (null != ((HashMap) o1).get("is_main") && null != ((HashMap) o2).get("is_main")
            && 0 == ((HashMap) o1).get("is_main").toString().compareTo(((HashMap) o2).get("is_main").toString())))
            && ((null == ((HashMap) o1).get("flg") && null == ((HashMap) o2).get("flg"))
            || (null != ((HashMap) o1).get("flg") && null != ((HashMap) o2).get("flg")
            && 0 == ((HashMap) o1).get("flg").toString().compareTo(((HashMap) o2).get("flg").toString())))) {
            staffCount++;
            isMatch = true;
            break;
          }
        }
        if (!isMatch) {
          return true;
        }
      }
      if (staffCount != newStaffList.size()) {
        return true;
      }
    }
    //患者グループ情報なし？
    //禁忌・アレルギー情報
    if (null != newPatMain.getTaboo_allergy_info() && 0 != JSONARRAY_EMPTY.compareTo(newPatMain.getTaboo_allergy_info())) {
      if (null == oldPatMain.getTaboo_allergy_info()
        || 0 == JSONARRAY_EMPTY.compareTo(oldPatMain.getTaboo_allergy_info())) {
        return true;
      }

      List<Object> oldAllergyList = (new JSONArray(oldPatMain.getTaboo_allergy_info())).toList();
      List<Object> newAllergyList = (new JSONArray(newPatMain.getTaboo_allergy_info())).toList();
      if (oldAllergyList.size() != newAllergyList.size()) {
        return true;
      }

      int tabooAllergyCount = 0;
      for (Object o1 : newAllergyList) {
        boolean isMatch = false;
        for (Object o2 : oldAllergyList) {
          // #8102-GX連携で実装されていない機能（処方情報連携） 周 mod start
//          if ((!StringUtils.isEmpty(((HashMap)o1).get("taboo_allergy_cd").toString())
          if (null == ((HashMap) o1).get("taboo_allergy_cd") && null == ((HashMap) o1).get("taboo_allergy_cd")
            || null != ((HashMap) o1).get("taboo_allergy_cd") && null != ((HashMap) o2).get("taboo_allergy_cd")
            && !StringUtils.isEmpty(((HashMap) o1).get("taboo_allergy_cd").toString())
            // #8102-GX連携で実装されていない機能（処方情報連携） 周 mod end
            && 0 == ((HashMap) o1).get("taboo_allergy_cd").toString().compareTo(
            ((HashMap) o2).get("taboo_allergy_cd").toString())
            || (StringUtils.isEmpty(((HashMap) o1).get("taboo_allergy_cd").toString())
            && 0 == ((HashMap) o1).get("content").toString().compareTo(((HashMap) o2).get("content").toString())
            && 0 == ((HashMap) o1).get("memo").toString().compareTo(((HashMap) o2).get("memo").toString())
          )) {
            tabooAllergyCount++;
            isMatch = true;
            break;
          }
        }
        if (!isMatch) {
          return true;
        }
      }
      if (tabooAllergyCount != newAllergyList.size()) {
        return true;
      }
    }

    //風袋補正情報なし？
    //除水補正情報なし？
    //装置設定情報なし？
    //治療進捗状態なし？
    //車いす有無なし？
    //共通診療情報
    if (null != newPatMain.getMedical_care_info() && 0 != JSONARRAY_EMPTY.compareTo(newPatMain.getMedical_care_info())) {
      if (null == oldPatMain.getMedical_care_info()
        || 0 == JSONARRAY_EMPTY.compareTo(oldPatMain.getMedical_care_info())) {
        return true;
      }

      JSONObject oldMedicalCare = new JSONObject(oldPatMain.getMedical_care_info());
      JSONObject newMedicalCare = new JSONObject(newPatMain.getMedical_care_info());

      if (null != newMedicalCare.get("ward_cd")
        && !StringUtils.isEmpty(newMedicalCare.get("ward_cd").toString())
        && (null == oldMedicalCare.get("ward_cd")
        || StringUtils.isEmpty(oldMedicalCare.get("ward_cd").toString()))) {
        return true;
      }
      if (null != newMedicalCare.get("ward_cd")
        && !StringUtils.isEmpty(newMedicalCare.get("ward_cd").toString())
        && null != oldMedicalCare.get("ward_cd")
        && !StringUtils.isEmpty(oldMedicalCare.get("ward_cd").toString())
        && 0 != newMedicalCare.get("ward_cd").toString().compareTo(oldMedicalCare.get("ward_cd").toString())) {
        return true;
      }
      //透析導入日
      if ((null == newMedicalCare.get("dialysis_start_date") && null != oldMedicalCare.get("dialysis_start_date"))
        || (null != newMedicalCare.get("dialysis_start_date") && null == oldMedicalCare.get("dialysis_start_date"))
        || (null != newMedicalCare.get("dialysis_start_date") && null != oldMedicalCare.get("dialysis_start_date")
        && 0 != newMedicalCare.get("dialysis_start_date").toString().compareTo(oldMedicalCare.get("dialysis_start_date").toString()))) {
        return true;
      }
      if ((null == newMedicalCare.get("main_course_cd") && null != oldMedicalCare.get("main_course_cd"))
        || (null != newMedicalCare.get("main_course_cd") && null == oldMedicalCare.get("main_course_cd"))
        || (null != newMedicalCare.get("main_course_cd") && null != oldMedicalCare.get("main_course_cd")
        && 0 != newMedicalCare.get("main_course_cd").toString().compareTo(oldMedicalCare.get("main_course_cd").toString()))) {
        return true;
      }
    }

    return false;
  }

  /**
   * 患者固有情報チェック
   *
   * @param oldPatUnique
   * @param newPatUnique
   * @return
   */
  private boolean isPatUniqueUpdated(PatUnique oldPatUnique, PatUnique newPatUnique) {
    //既往歴情報なし？
    //入外・転入出情報なし？
    //身体情報
    if (null != newPatUnique.getPhysical_info() && 0 != JSONARRAY_EMPTY.compareTo(newPatUnique.getPhysical_info())) {
      String strOldPhysicalinfo = oldPatUnique.getPhysical_info();
      if (StringUtils.isEmpty(strOldPhysicalinfo) || 0 == JSONARRAY_EMPTY.compareTo(strOldPhysicalinfo)) {
        return true;
      } else {
        String strNewPhysicalinfo = newPatUnique.getPhysical_info();
        List<Object> newPhysicalinfoList = (new JSONArray(strNewPhysicalinfo)).toList();

        List<Object> orgPhysicalinfoList = (new JSONArray(strOldPhysicalinfo)).toList();
        if (newPhysicalinfoList.size() != orgPhysicalinfoList.size()) {
          return true;
        }
        int physicalInfoCount = 0;
        for (Object o1 : newPhysicalinfoList) {
          boolean isMatch = false;
          for (Object o2 : orgPhysicalinfoList) {
            if (((null == ((HashMap) o1).get("ctr") && null == ((HashMap) o2).get("ctr"))
              || (null != ((HashMap) o1).get("ctr") && null != ((HashMap) o2).get("ctr")
              && 0 == ((HashMap) o1).get("ctr").toString().compareTo(((HashMap) o2).get("ctr").toString())))
              && ((null == ((HashMap) o1).get("height") && null == ((HashMap) o2).get("height"))
              || (null != ((HashMap) o1).get("height") && null != ((HashMap) o2).get("height")
              && 0 == ((HashMap) o1).get("height").toString().compareTo(((HashMap) o2).get("height").toString())))
              && ((null == ((HashMap) o1).get("exam_date") && null == ((HashMap) o2).get("exam_date"))
              || (null != ((HashMap) o1).get("exam_date") && null != ((HashMap) o2).get("exam_date")
              && 0 == ((HashMap) o1).get("exam_date").toString().compareTo(((HashMap) o2).get("exam_date").toString())))
              && ((null == ((HashMap) o1).get("chest_dia") && null == ((HashMap) o2).get("chest_dia"))
              || (null != ((HashMap) o1).get("chest_dia") && null != ((HashMap) o2).get("chest_dia")
              && 0 == ((HashMap) o1).get("chest_dia").toString().compareTo(((HashMap) o2).get("chest_dia").toString())))
              && ((null == ((HashMap) o1).get("breast_dia") && null == ((HashMap) o2).get("breast_dia"))
              || (null != ((HashMap) o1).get("breast_dia") && null != ((HashMap) o2).get("breast_dia")
              && 0 == ((HashMap) o1).get("breast_dia").toString().compareTo(((HashMap) o2).get("breast_dia").toString())))) {
              physicalInfoCount++;
              isMatch = true;
              break;
            }
          }
          if (!isMatch) {
            return true;
          }
        }
        if (physicalInfoCount != newPhysicalinfoList.size()) {
          return true;
        }
      }
    }

    //原疾患コード
    if (null != newPatUnique.getMedical_hst_info() && 0 != JSONARRAY_EMPTY.compareTo(newPatUnique.getMedical_hst_info())) {
      if (null == oldPatUnique.getMedical_hst_info()
        || 0 == JSONARRAY_EMPTY.compareTo(oldPatUnique.getMedical_hst_info())) {
        return true;
      }

      List<Object> oldMedicalHstInfoList = (new JSONArray(oldPatUnique.getMedical_hst_info())).toList();
      List<Object> newMedicalHstInfoList = (new JSONArray(newPatUnique.getMedical_hst_info())).toList();
      if (oldMedicalHstInfoList.size() != newMedicalHstInfoList.size()) {
        return true;
      }

      int medicalHstInfoCount = 0;
      for (Object o1 : newMedicalHstInfoList) {
        boolean isMatch = false;
        for (Object o2 : oldMedicalHstInfoList) {
          if ((null == ((HashMap) o1).get("disease_cd") && null == ((HashMap) o2).get("disease_cd"))
            || (null != ((HashMap) o1).get("disease_cd") && null != ((HashMap) o2).get("disease_cd")
            && 0 == ((HashMap) o1).get("disease_cd").toString().compareTo(((HashMap) o2).get("disease_cd").toString()))) {
            medicalHstInfoCount++;
            isMatch = true;
            break;
          }
        }
        if (!isMatch) {
          return true;
        }
      }
      if (medicalHstInfoCount != newMedicalHstInfoList.size()) {
        return true;
      }
    }

    return false;
  }

  /**
   * 患者個人情報チェック
   *
   * @param oldPatPersonalMain
   * @param newPatPersonalMain
   * @return
   */
  private boolean isPatPersonalMainUpdated(PatPersonalMain oldPatPersonalMain, PatPersonalMain newPatPersonalMain) {
    //患者氏名(漢字姓)
    // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod start
    //if (0 != newPatPersonalMain.getPat_last_name().compareTo(oldPatPersonalMain.getPat_last_name())) {
    if (null == newPatPersonalMain.getPat_last_name() && null != oldPatPersonalMain.getPat_last_name()
      || null != newPatPersonalMain.getPat_last_name() && null == oldPatPersonalMain.getPat_last_name()
      || null != newPatPersonalMain.getPat_last_name() && null != oldPatPersonalMain.getPat_last_name()
      && 0 != newPatPersonalMain.getPat_last_name().compareTo(oldPatPersonalMain.getPat_last_name())) {
      // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod end
      return true;
    }
    //患者氏名(漢字名)
    // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod start
    //if (0 != newPatPersonalMain.getPat_first_name().compareTo(oldPatPersonalMain.getPat_first_name())) {
    if (null == newPatPersonalMain.getPat_first_name() && null != oldPatPersonalMain.getPat_first_name()
      || null != newPatPersonalMain.getPat_first_name() && null == oldPatPersonalMain.getPat_first_name()
      || null != newPatPersonalMain.getPat_first_name() && null != oldPatPersonalMain.getPat_first_name()
      && 0 != newPatPersonalMain.getPat_first_name().compareTo(oldPatPersonalMain.getPat_first_name())) {
      // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod end
      return true;
    }
    //患者氏名(カタカナ姓)
    // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod start
    //if (0 != newPatPersonalMain.getPat_last_name_kana().compareTo(oldPatPersonalMain.getPat_last_name_kana())) {
    if (null == newPatPersonalMain.getPat_last_name_kana() && null != oldPatPersonalMain.getPat_last_name_kana()
      || null != newPatPersonalMain.getPat_last_name_kana() && null == oldPatPersonalMain.getPat_last_name_kana()
      || null != newPatPersonalMain.getPat_last_name_kana() && null != oldPatPersonalMain.getPat_last_name_kana()
      && 0 != newPatPersonalMain.getPat_last_name_kana().compareTo(oldPatPersonalMain.getPat_last_name_kana())) {
      // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod end
      return true;
    }
    //患者氏名(カタカナ名)
    // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod start
    //if (0 != newPatPersonalMain.getPat_first_name_kana().compareTo(oldPatPersonalMain.getPat_first_name_kana())) {
    if (null == newPatPersonalMain.getPat_first_name_kana() && null != oldPatPersonalMain.getPat_first_name_kana()
      || null != newPatPersonalMain.getPat_first_name_kana() && null == oldPatPersonalMain.getPat_first_name_kana()
      || null != newPatPersonalMain.getPat_first_name_kana() && null != oldPatPersonalMain.getPat_first_name_kana()
      && 0 != newPatPersonalMain.getPat_first_name_kana().compareTo(oldPatPersonalMain.getPat_first_name_kana())) {
      // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod end
      return true;
    }

    //患者氏名(英字姓)なし
    //患者氏名(英字名)なし
    //患者誕生時氏名(旧姓)(漢字)なし
    //患者誕生時氏名(旧姓)(カタカナ)なし
    //患者誕生時氏名(旧姓)(英字)なし
    //生年月日(YYYYMMDD)
    // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod start
    //if (0 != newPatPersonalMain.getPat_birthday().compareTo(oldPatPersonalMain.getPat_birthday())) {
    if (null == newPatPersonalMain.getPat_birthday() && null != oldPatPersonalMain.getPat_birthday()
      || null != newPatPersonalMain.getPat_birthday() && null == oldPatPersonalMain.getPat_birthday()
      || null != newPatPersonalMain.getPat_birthday() && null != oldPatPersonalMain.getPat_birthday()
      && 0 != newPatPersonalMain.getPat_birthday().compareTo(oldPatPersonalMain.getPat_birthday())) {
      // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod end
      return true;
    }
    //性別
    if (!newPatPersonalMain.getPat_sex().equals(oldPatPersonalMain.getPat_sex())) {
      return true;
    }
    //国籍なし
    //血液型ABO
    if (!newPatPersonalMain.getPat_blood_type_abo().equals(oldPatPersonalMain.getPat_blood_type_abo())) {
      return true;
    }
    //血液型RH
    if (!newPatPersonalMain.getPat_blood_type_rh().equals(oldPatPersonalMain.getPat_blood_type_rh())) {
      return true;
    }
    //血液型亜型なし
    //入外区分
    if (!newPatPersonalMain.getIn_out_class().equals(oldPatPersonalMain.getIn_out_class())) {
      return true;
    }
    //死亡患者
    // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod start
    //if ((StringUtils.isEmpty(newPatPersonalMain.getIs_die()) && !StringUtils.isEmpty(oldPatPersonalMain.getIs_die()))
    //  || (!StringUtils.isEmpty(newPatPersonalMain.getIs_die()) && StringUtils.isEmpty(oldPatPersonalMain.getIs_die()))
    //  || (!StringUtils.isEmpty(newPatPersonalMain.getIs_die()) && !StringUtils.isEmpty(oldPatPersonalMain.getIs_die())
    //  && 0 != newPatPersonalMain.getIs_die().compareTo(oldPatPersonalMain.getIs_die()))) {
    if (null == newPatPersonalMain.getIs_die() && null != oldPatPersonalMain.getIs_die()
      || null != newPatPersonalMain.getIs_die() && null == oldPatPersonalMain.getIs_die()
      || null != newPatPersonalMain.getIs_die() && null != oldPatPersonalMain.getIs_die()
      && 0 != newPatPersonalMain.getIs_die().compareTo(oldPatPersonalMain.getIs_die())) {
      // #8289-連携で受信するファイルが検知後すぐに移動されない 周 mod end
      return true;
    }
    //死因コードなし
    //死亡日
    if ((null == newPatPersonalMain.getDie_date() && null != oldPatPersonalMain.getDie_date())
      || (null != newPatPersonalMain.getDie_date() && null == oldPatPersonalMain.getDie_date())
      || (null != newPatPersonalMain.getDie_date() && null != oldPatPersonalMain.getDie_date()
      && !newPatPersonalMain.getDie_date().equals(oldPatPersonalMain.getDie_date()))) {
      return true;
    }

    //透析困難情報なし
    //重症度コード
    if ((null == newPatPersonalMain.getSeverity_cd() && null != oldPatPersonalMain.getSeverity_cd())
      || (null != newPatPersonalMain.getSeverity_cd() && null == oldPatPersonalMain.getSeverity_cd())
      || (null != newPatPersonalMain.getSeverity_cd() && null != oldPatPersonalMain.getSeverity_cd()
      && !newPatPersonalMain.getSeverity_cd().equals(oldPatPersonalMain.getSeverity_cd()))) {
      return true;
    }

    //搬送区分コード
    if ((null == newPatPersonalMain.getTransport_cd() && null != oldPatPersonalMain.getTransport_cd())
      || (null != newPatPersonalMain.getTransport_cd() && null == oldPatPersonalMain.getTransport_cd())
      || (null != newPatPersonalMain.getTransport_cd() && null != oldPatPersonalMain.getTransport_cd()
      && !newPatPersonalMain.getTransport_cd().equals(oldPatPersonalMain.getTransport_cd()))) {
      return true;
    }

    //本人連絡先情報
    if ((null == newPatPersonalMain.getPat_contact_info() && null != oldPatPersonalMain.getPat_contact_info())
      || (null != newPatPersonalMain.getPat_contact_info() && null == oldPatPersonalMain.getPat_contact_info())
      || (null != newPatPersonalMain.getPat_contact_info() && null != oldPatPersonalMain.getPat_contact_info()
      && !newPatPersonalMain.getPat_contact_info().equals(oldPatPersonalMain.getPat_contact_info()))) {
      return true;
    }

    //連絡先情報
    if ((null == newPatPersonalMain.getOther_contact_info() && null != oldPatPersonalMain.getOther_contact_info())
      || (null != newPatPersonalMain.getOther_contact_info() && null == oldPatPersonalMain.getOther_contact_info())
      || (null != newPatPersonalMain.getOther_contact_info() && null != oldPatPersonalMain.getOther_contact_info()
      && !newPatPersonalMain.getOther_contact_info().equals(oldPatPersonalMain.getOther_contact_info()))) {
      return true;
    }

    //障害者加算
    if ((null == newPatPersonalMain.getDial_diff_com_info() && null != oldPatPersonalMain.getDial_diff_com_info())
      || (null != newPatPersonalMain.getDial_diff_com_info() && null == oldPatPersonalMain.getDial_diff_com_info())
      || (null != newPatPersonalMain.getDial_diff_com_info() && null != oldPatPersonalMain.getDial_diff_com_info()
      && !newPatPersonalMain.getDial_diff_com_info().equals(oldPatPersonalMain.getDial_diff_com_info()))) {
      return true;
    }

    //業者連絡先情報なし
    //保険情報なし?
    //原疾患コード(patUnique)
    //遠隔モニタリングサービス業者なし
    //遠隔モニタリングサービス利用者IDなし
    //遠隔モニタリングサービス利用者パスワードなし

    return false;
  }
  // #7631-profile連携で患者登録した通知が行われない(項目更新あり場合のみ通知) 周 add end

  /**
   * layout　取得
   *
   * @param facilityCd
   * @param direction
   * @param coopCd
   * @param coopCdIndex
   * @param coopVersion
   * @param coopCdSub
   * @return
   */
  private MstCoopLayout getMstCoopLayout(String facilityCd, String direction, String coopCd, String coopCdIndex,
                                         String coopVersion, String coopCdSub) {
    List<MstCoopLayout> mclList = mstCoopLayoutDao.selectWithAll(facilityCd, coopCd, coopCdIndex, coopVersion,
      direction, coopCdSub, AUX_CODE_ALL);
    if (mclList == null || mclList.size() == 0) {
      return null;
    } else {
      MstCoopLayout mcl = mclList.get(0);
      return mcl;
    }
  }

  /**
   * ジャーナルの複数チェック
   *
   * @param journal ジャーナル
   */
  private boolean splitMultJournalCheck(SysCoopJournal journal) {
    if (journal != null) {
      // 連携版番号
      String coopVersion = StringUtils.isEmpty(journal.getCoopVersion()) ? "" : journal.getCoopVersion();
      try {
        // 1電文に複数の患者が含まれる場合
        // 区切り文字で分割した電文を処理対象とする。
        String[] multiSetting = getMultiSetting(journal.getFacilityCd(), journal.getDirection(), journal.getCoopCd(),
          journal.getCoopCdIndex(), coopVersion);
        if (Boolean.valueOf(multiSetting[0])) {
          return true;
        }

      } catch (Exception ex) {
        return false;
      }
    }
    return false;
  }

  /**
   * 複数患者指定を取得する。
   *
   * @param facilityCd  施設コード
   * @param direction   向き（送受信）
   * @param coopCd      電文種別
   * @param coopCdIndex 付帯情報（電文）
   * @param coopVersion 連携版番号
   * @return 先頭が複数患者対応可否文字列（"true"/"false"）、残りが区切り文字を表す文字列配列
   */
  private String[] getMultiSetting(String facilityCd, String direction, String coopCd, String coopCdIndex,
                                   String coopVersion) {
    MstCoopLayout mcl = convertCommonService.getMstCoopLayout(facilityCd, direction, coopCd, coopCdIndex, coopVersion,
      JournalConvertConstants.AUX_CODE_PRELOGIC);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    String multi = mcl.getCoopSettingRoot().getMulti();
    EventLogMessage eventLogMessage = new EventLogMessage();

    if (StringUtils.isEmpty(multi)) {
      return new String[]{Boolean.FALSE.toString(), null};
    }

    String[] sp = multi.split(LAYOUT_MULTI_DELIM);
    if (sp.length == 1) {

      String errMsg = String.format("1電文複数患者指定で、区切り文字が指定されていません。 施設コード=[%s], 電文種別=[%s], 連携版番号=[%s]",
        facilityCd, coopCd, coopVersion);
      eventLogMessage.setInvokeClass(this.getClass().getName());
      eventLogMessage.setLogMessage(errMsg);
      logService.log(LogLevel.DEBUG, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      throw new NtssException(errMsg);
    }

    return Arrays.asList(sp).stream().map(e -> e.replaceAll(TELEGRAM_DELIM_CR, TELEGRAM_DELIM_CR_VALUE)
      .replaceAll(TELEGRAM_DELIM_LF, TELEGRAM_DELIM_LF_VALUE)).toArray(String[]::new);
  }
  /**
   * 感染症取得
   * @param patMain 患者固有情報
   * @return
   */
  private List<String> getinfectInfo(PatMain patMain) {
    List<String> infectionCdList = new ArrayList<>();
    if (patMain != null) {
      String infectInfo = patMain.getInfect_info();
      if (!"[]".equals(infectInfo)) {
        JSONArray newInfectInfoJsonList = new JSONArray(infectInfo);
        for (int i = 0; i < newInfectInfoJsonList.length(); i++) {
          JSONObject jsonObj = newInfectInfoJsonList.getJSONObject(i);
          if ("2".equals(jsonObj.get("infect").toString())) {
            String code = jsonObj.get("infection_cd").toString();
            infectionCdList.add(code);
          }
        }
      }
    }
    return infectionCdList;
  }
  /**
   * 失敗の場合LOG
   *
   * @param journal
   */
  private void loserLogEx(SysCoopJournal journal) {
    // add FNSI-7860 テスト用 劉全航 start
    EventLogMessage eventLogMessage1 = new EventLogMessage();
    eventLogMessage1.setFacilityCd(journal.getFacilityCd());
    eventLogMessage1.setInvokeClass(this.getClass().getName());
    eventLogMessage1.setLogMessage(
      "bug #7860 不要なデスクトップ通知が発生する," +
        "facility_cd:[" + journal.getFacilityCd() + "], " +
        "ctl_no:[" + journal.getCtlNo() + "]," +
        "message:[" + journal.getMessage() + "]," +
        "direction:[" + journal.getDirection() + "]," +
        "coop_cd:[" + journal.getCoopCd() + "]," +
// add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        "coop_version:[" + journal.getCoopVersion() + "]," +
// add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        "crud:[" + journal.getCrud() + "]," +
        "coopResult:[" + journal.getCoopResult() + "]" +
        "anaResult:[" + journal.getAnaResult() + "]");
    logService.log(LogLevel.ERROR, eventLogMessage1, null, LoggingConstant.SERVICE_NAME.FNSI, null);
    // add FNSI-7860 テスト用 劉全航 end
  }
  /**
   * 異常の場合LOG
   *
   * @param journal
   */
  private void LogEx(SysCoopJournal journal,String exInfo) {
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(journal.getFacilityCd());
    eventLogMessage.setInvokeClass(this.getClass().getName());
    eventLogMessage.setLogMessage(
      "facility_cd:[" + journal.getFacilityCd() + "], " +
        "ctl_no:[" + journal.getCtlNo() + "]," +
        "message:[" + journal.getMessage() + "]," +
        "direction:[" + journal.getDirection() + "]," +
        "coop_cd:[" + journal.getCoopCd() + "]," +
        "coop_version:[" + journal.getCoopVersion() + "]," +
        "crud:[" + journal.getCrud() + "]," +
        "coopResult:[" + journal.getCoopResult() + "]" +
        "anaResult:[" + journal.getAnaResult() + "]"+
        "exInfo:"+exInfo);
    logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
  }

}
