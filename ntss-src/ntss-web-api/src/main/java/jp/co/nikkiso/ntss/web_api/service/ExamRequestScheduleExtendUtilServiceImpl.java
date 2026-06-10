package jp.co.nikkiso.ntss.web_api.service;

import com.amazonaws.util.StringUtils;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstExamSetDao;
import jp.co.nikkiso.ntss.core.dao.MstRadSetDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatExamPatternDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadPatternDao;
import jp.co.nikkiso.ntss.core.entity.MstExamSet;
import jp.co.nikkiso.ntss.core.entity.MstRadSet;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatExamPattern;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatRadMain;
import jp.co.nikkiso.ntss.core.entity.PatRadPattern;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainExamOrderInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainOrderExamSetInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainOrderLabelInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamPatternExamOrderInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamPatternOrderLabelInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatRadMainOrderRadSetInfo;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.web_api.request.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.web_api.web.rest.util.ScheduleExtendUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.BatchPreparedStatementSetter;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import javax.annotation.Nonnull;
import javax.sql.DataSource;
import java.io.IOException;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.sql.Types;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Objects;
import java.util.function.Function;
import java.util.function.Predicate;
import java.util.function.ToIntFunction;
import java.util.stream.Collectors;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 検査依頼スケジュール更新処理のService実装クラス.
 */
@Service
public class ExamRequestScheduleExtendUtilServiceImpl implements ExamRequestScheduleExtendUtilService {

  /**
   * 検査結果Daoインタフェース.
   */
  @Autowired
  private PatExamMainDao patExamMainDao;

  // add 10553 連携イベント発生部分不正 関 start
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;
  // add 10553 連携イベント発生部分不正 関 end

  /**
   * 検査セットパターンDaoインタフェース.
   */
  @Autowired
  private PatExamPatternDao patExamPatternDao;

  /**
   * 検査セットマスタのDaoインタフェース.
   */
  @Autowired
  private MstExamSetDao mstExamSetDao;

  /**
   * 放射線検査結果Daoインタフェース.
   */
  @Autowired
  private PatRadMainDao patRadMainDao;

  /**
   * 放射線検査セットパターンDaoインタフェース.
   */
  @Autowired
  private PatRadPatternDao patRadPatternDao;

  /**
   * 放射線検査セットマスタのDaoインタフェース.
   */
  @Autowired
  private MstRadSetDao mstRadSetDao;

  @Autowired
  private LogService logService;

  @Autowired
  private ScheduleExtendUtil scheduleExtendUtil;

  @Autowired
  @Qualifier(value = CoreConstant.DataSourceName.DEFAULT)
  private DataSource dataSource;

  @Override
  public void createPatExamMain(Long patId, String facilityCd, String fromDt, String toDt, String defaultDoctor, List<JournalCreateRequestPayload> payloads) throws Exception {
    JdbcTemplate template = new JdbcTemplate(dataSource);

    try {
      // 期間内に当てはまるパターンを取得
      List<PatExamPattern> patExamPatternList = patExamPatternDao.selectPatExamPattern(patId, fromDt, toDt);

      Date fromDate = Date.valueOf(fromDt);
      Date toDate = Date.valueOf(toDt);

      // DBから検査セット情報をとってくる
      List<MstExamSet> lstMstExamSet = mstExamSetDao.selectValidExamSetList(facilityCd);

      // mod FNSI-改修内容#6013 周 start
      //if (lstMstExamSet.isEmpty()) {
      if (null == lstMstExamSet || lstMstExamSet.isEmpty()) {
      // mod FNSI-改修内容#6013 周 end
        // 検査セットマスタに登録がない(全件削除済みなど)の場合はここで処理を抜ける
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("検査セットマスタ未登録(全件削除済み)のため、検査予定の延長をスキップします。 patId = " + patId.toString());
        logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
        return;
      }

      List<PatExamMain> patAllExamMains = patExamMainDao.selectPatExamMainByPatId(patId);

      // add 10553 連携イベント発生部分不正 関 start
      PatPersonalMain patSrc = patPersonalMainDao.selectById(patId);
      // add 10553 連携イベント発生部分不正 関 end

      List<PatExamMain> toInsertPatExamMains = new ArrayList<>();
      List<PatExamMain> toUpdatePatExamMains = new ArrayList<>();

      // 取得したレコード分ループ処理
      patExamPatternList.forEach(patExamPattern -> {

        // 検査パターンをもとに登録する日付一覧を取得
        List<Date> dateList = getCreateDate(patExamPattern.getExamFrom(), patExamPattern.getExamTo(),
            fromDate, toDate, patExamPattern.getExamPattern(), patExamPattern.getExamWeek());

        MstExamSet mstExamSet = lstMstExamSet.stream()
            .filter(d -> d.getExamSetCd().equals(patExamPattern.getOrderExamSetCd()))
            .findFirst().orElse(null);

        if (mstExamSet == null) {
          // 対象の検査セットが存在しない(削除済み)の場合、次のセット処理に移行する
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("検査依頼コードが存在しない(削除済み)のため、該当検査パターンの延長処理をスキップします。 patId = " + patId.toString() + " orderExamSetCd = " + patExamPattern.getOrderExamSetCd().toString());
          logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
          return;
        }

        // 生理検査用検査セットの判定
        Boolean isPhysiologicalTest = "3".equals(mstExamSet.getExamSetClass());
        // 1セット1レコードとする条件（生理検査用検査セット、もしくは検査区分が「その他」）の判定
        Boolean isEachOrder = isPhysiologicalTest || ("0".equals(patExamPattern.getRegOrderClass()));

        // 取得した日付分ループ処理
        dateList.forEach(dt -> {

          Timestamp regExamDate = new Timestamp(dt.getTime());

          // 追加対象の検査セットがあるか検索する関数
          ToIntFunction<PatExamMain> findOrderExamSetIndex = patExamMain -> {
            int result = -1;
            String orderExamSetInfoJson = patExamMain.getOrderExamSetInfo();
            try {
              List<PatExamMainOrderExamSetInfo> orderExamSetInfo =
                StringUtils.isNullOrEmpty(orderExamSetInfoJson)
                  ? new ArrayList<>()
                  : new ObjectMapper().readValue(
                    orderExamSetInfoJson,
                    new TypeReference<List<PatExamMainOrderExamSetInfo>>() {}
                  );
              for (int i = 0; i < orderExamSetInfo.size(); i++) {
                if (patExamPattern.getOrderExamSetCd().equals(orderExamSetInfo.get(i).getSet_cd())) {
                  // 追加対象の検査セットがあった場合
                  result = i;
                  break;
                }
              }
            } catch (IOException e) {
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
              if (facilityCd != null) {
                eventLogMessage.setFacilityCd(facilityCd);
              }
              logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
            }
            return result;
          };
          // 更新対象レコードデータを絞り込む関数
          Predicate<PatExamMain> patExamMainFilter = patExamMain ->
            regExamDate.equals(patExamMain.getRegExamDate())
            && Objects.equals(patExamMain.getRegOrderClass(), patExamPattern.getRegOrderClass())
            && (isPhysiologicalTest == "1".equals(patExamMain.getPhyOrdClass()));
          // 更新対象レコードデータを検索する関数
          Function<List<PatExamMain>, PatExamMain> findTargetExamMain = list -> {
            PatExamMain result = null;
            List<PatExamMain> targetList = list.stream()
                .filter(patExamMainFilter)
                .collect(Collectors.toList());
            if (targetList.size() > 0) {
              if (!isEachOrder) {
                // 1セット1レコードとしない場合
                // 1件目を更新対象にする（通常1件しか存在しない）
                result = targetList.get(0);
              } else {
                // 1セット1レコードとする場合
                // 追加対象の検査セットがすでに入っている場合のみ更新対象にする
                // （自動延長処理では通常存在しない）
                for (int i = 0; i < targetList.size(); i++) {
                  if (findOrderExamSetIndex.applyAsInt(targetList.get(i)) != -1) {
                    // 追加対象の検査セットがあった場合
                    result = targetList.get(i);
                    break;
                  }
                }
              }
            }
            return result;
          };

          // 更新対象レコードデータを検索する
          PatExamMain targetExamMain = null;
          Boolean isDirtyRecord = false;
          // 新規追加レコードデータから検索
          targetExamMain = findTargetExamMain.apply(toInsertPatExamMains);
          if (targetExamMain == null) {
            // 更新レコードデータから検索
            targetExamMain = findTargetExamMain.apply(toUpdatePatExamMains);
          } else {
            // 新規追加レコードデータを更新対象とする場合
            isDirtyRecord = true;
          }
          if (targetExamMain == null) {
            // 既存レコードから検索
            targetExamMain = findTargetExamMain.apply(patAllExamMains);
          } else {
            // 更新レコードデータを更新対象とする場合
            isDirtyRecord = true;
          }

          // 検査予定の取得結果に応じてUpdate/Insertを変える
          if (targetExamMain != null) {
            // 更新対象レコードデータが存在する場合
            // JSONの更新
            // OrderExamSetInfo更新
            StringBuilder sbExamSetInfo = new StringBuilder();
            Integer intNo = 0;  // 通し番号
            try {
              List<PatExamMainOrderExamSetInfo> orderExamSetInfo =
                StringUtils.isNullOrEmpty(targetExamMain.getOrderExamSetInfo())
                  ? new ArrayList<>()
                  : new ObjectMapper().readValue(
                    targetExamMain.getOrderExamSetInfo(),
                    new TypeReference<List<PatExamMainOrderExamSetInfo>>() {}
                  );

              // 同じ検査セットがあるか最後まで検索
              boolean existExamItemSetCd = false;
              for (int idx = 0; idx < orderExamSetInfo.size(); idx++) {
                if (patExamPattern.getOrderExamSetCd().equals(orderExamSetInfo.get(idx).getSet_cd())) {
                  // 同じ exam_item_set_cd があればセット名を更新
                  intNo = orderExamSetInfo.get(idx).getNo();
                  PatExamMainOrderExamSetInfo updateOrderExamSetInfo = orderExamSetInfo.get(idx);
                  updateOrderExamSetInfo.setSet_name(mstExamSet.getExamSetName());
                  orderExamSetInfo.set(idx, updateOrderExamSetInfo);
                  existExamItemSetCd = true;
                }
              }
              // 同じ exam_item_set_cd がなければ1件レコード追加
              if (!existExamItemSetCd) {
                int intNoForSet = orderExamSetInfo.size() + 1; // no は最大件数+1
                intNo = intNoForSet;
                PatExamMainOrderExamSetInfo addOrderExamSetInfo = new PatExamMainOrderExamSetInfo()
                {
                  {
                    setNo(intNoForSet);
                    setSet_cd(patExamPattern.getOrderExamSetCd());
                    setSet_name(mstExamSet.getExamSetName());
                  }
                };
                orderExamSetInfo.add(addOrderExamSetInfo);
              }

              // StringBuilderに変換
              orderExamSetInfo.stream().forEach(exam-> sbExamSetInfo.append("," + exam.getValue()));

              // 文字列の前後に"["と"]"を付け加える
              sbExamSetInfo.delete(0, 1);
              sbExamSetInfo.insert(0, "[");
              sbExamSetInfo.append("]");

            } catch (IOException e) {
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
              if (facilityCd != null) {
                eventLogMessage.setFacilityCd(facilityCd);
              }
              logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
            }

            // ExamOrderInfo更新
            StringBuilder sbExamOrderInfo = new StringBuilder();
            try {
              // 既存レコードのデータを取得する
              List<PatExamMainExamOrderInfo> examOrderInfo =
                StringUtils.isNullOrEmpty(targetExamMain.getExamOrderInfo())
                  ? new ArrayList<>()
                  : new ObjectMapper().readValue(
                    targetExamMain.getExamOrderInfo(),
                    new TypeReference<List<PatExamMainExamOrderInfo>>() {}
                  );

              // 通し番号と同じのがあれば削除
              int delIdx = 0;
              while (delIdx < examOrderInfo.size()) {
                if (intNo.equals(examOrderInfo.get(delIdx).getNo())) {
                  examOrderInfo.remove(delIdx);
                } else {
                  delIdx++;
                }
              }

              // パターンの元データを取得する
              List<PatExamPatternExamOrderInfo> patternExamOrderInfo =
                StringUtils.isNullOrEmpty(patExamPattern.getExamOrderInfo())
                  ? new ArrayList<>()
                  : new ObjectMapper().readValue(patExamPattern.getExamOrderInfo(), new TypeReference<List<PatExamPatternExamOrderInfo>>() {});

              // パターンの検査項目データをすべて追加登録
              for (int idx = 0; idx < patternExamOrderInfo.size(); idx++) {
                Long examItemCd = patternExamOrderInfo.get(idx).getExam_item_cd();
                String examItemName = patternExamOrderInfo.get(idx).getExam_item_name();
                Integer examNo = intNo;

                PatExamMainExamOrderInfo addExamOrderInfo = new PatExamMainExamOrderInfo ()
                {
                  {
                    setNo(examNo);
                    setItem_cd(examItemCd);
                    setItem_name(examItemName);
                  }
                };
                examOrderInfo.add(addExamOrderInfo);
              }

              // 通し番号順にソート
              Collections.sort(examOrderInfo, new Comparator<PatExamMainExamOrderInfo>() {
                public int compare(PatExamMainExamOrderInfo info1, PatExamMainExamOrderInfo info2) {
                  if (info1.getNo().compareTo(info2.getNo()) < 0) {
                    return -1;
                  } else {
                    return 1;
                  }
                }
              });

              // StringBuilderに変換
              examOrderInfo.stream().forEach(exam-> sbExamOrderInfo.append("," + exam.getValue()));

              // 文字列の前後に"["と"]"を付け加える
              sbExamOrderInfo.delete(0, 1);
              sbExamOrderInfo.insert(0, "[");
              sbExamOrderInfo.append("]");

            } catch (IOException e) {
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
              if (facilityCd != null) {
                eventLogMessage.setFacilityCd(facilityCd);
              }
              logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
            }

            // OrderLabelInfo更新
            StringBuilder sbOrderLabelInfo  = new StringBuilder();

            try {
              // 既存レコードのデータを取得する
              List<PatExamMainOrderLabelInfo> orderLabelInfo =
                StringUtils.isNullOrEmpty(targetExamMain.getOrderLabelInfo())
                  ? new ArrayList<>()
                  : new ObjectMapper().readValue(
                    targetExamMain.getOrderLabelInfo(),
                    new TypeReference<List<PatExamMainOrderLabelInfo>>() {}
                  );

              // パターンの元データを取得する
              List<PatExamPatternOrderLabelInfo> patternOrderLabelInfo =
                StringUtils.isNullOrEmpty(patExamPattern.getOrderLabelInfo())
                  ? new ArrayList<>()
                  : new ObjectMapper().readValue(patExamPattern.getOrderLabelInfo(), new TypeReference<List<PatExamPatternOrderLabelInfo>>() {});

              // パターンの元データを確認する
              for (int ptnIdx = 0; ptnIdx < patternOrderLabelInfo.size(); ptnIdx++) {
                // 既存レコードのデータを確認する
                List<PatExamMainOrderLabelInfo> updateOrderLabelInfoList = new ArrayList<>();
                int updateIdx = 99999;
                for (int idx = 0; idx < orderLabelInfo.size(); idx++) {
                  // 同じexam_spitz_cdのデータがあるか確認
                  if (orderLabelInfo.get(idx).getSpitz_cd().equals(patternOrderLabelInfo.get(ptnIdx).getSpitz_cd())) {
                    // 同じ採血管コードがあるため更新対象データを抽出
                    updateOrderLabelInfoList.add(orderLabelInfo.get(idx));
                    updateIdx = idx;
                  }
                }

                if (updateOrderLabelInfoList.size() == 0) {
                  // 新規
                  Long orderSpitzNo = patternOrderLabelInfo.get(ptnIdx).getSpitz_cd();

                  PatExamMainOrderLabelInfo addOrderLabelInfo = new PatExamMainOrderLabelInfo()
                  {
                    {
                      setSpitz_cd(orderSpitzNo);
                    }
                  };
                  orderLabelInfo.add(addOrderLabelInfo);
                }
              }
              // StringBuilderに変換
              orderLabelInfo.stream().forEach(exam-> sbOrderLabelInfo.append("," + exam.getValue()));

              // 文字列の前後に"["と"]"を付け加える
              sbOrderLabelInfo.delete(0, 1);
              sbOrderLabelInfo.insert(0, "[");
              sbOrderLabelInfo.append("]");

            } catch (IOException e) {
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
              if (facilityCd != null) {
                eventLogMessage.setFacilityCd(facilityCd);
              }
              logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
            }

            if (isDirtyRecord) {
              // 登録情報は作成済の場合
              // 検査セット追加によって変わる項目のみ設定しなおす
              targetExamMain.setOrderExamSetInfo(sbExamSetInfo.toString());
              targetExamMain.setExamOrderInfo(sbExamOrderInfo.toString());
              // mod 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm start
//              targetExamMain.setOrderLabelInfo(sbOrderLabelInfo.toString());
              targetExamMain.setOrderLabelInfo("[]");
              // mod 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm end
            } else {
              // 登録情報の作成
              final PatExamMain targetExamMainCapture = targetExamMain;
              PatExamMain updatePatExamMain = new PatExamMain()
              {
                {
                  setExamMainCd(targetExamMainCapture.getExamMainCd());
                  setRegExamDate(targetExamMainCapture.getRegExamDate());
                  setRegOrderClass(targetExamMainCapture.getRegOrderClass());
                  setOrderExamSetInfo(sbExamSetInfo.toString());
                  setExamOrderInfo(sbExamOrderInfo.toString());
                  // mod 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm start
//                  setOrderLabelInfo(sbOrderLabelInfo.toString());
                  setOrderLabelInfo("[]");
                  // mod 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm end
                  setIsLock(targetExamMainCapture.getIsLock());
                  setIndUserId(targetExamMainCapture.getIndUserId());
                  setIsDel("0");
                  setUpDate(getCurrentDate());
                  setUpStaff(targetExamMainCapture.getUpStaff());
                  setIsOrder("1");
                  setPhyOrdClass(targetExamMainCapture.getPhyOrdClass());
                }
              };

              // update対象に追加
              toUpdatePatExamMains.add(updatePatExamMain);

              // 連携用のAPIをコール
              try {
                JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
                payload.setFacilityCd(targetExamMain.getFacilityCd());
                // mod 10553 生理検査送信連携不正 関  start
                // payload.setCoopCd("exam_ord");
                if (targetExamMain.getPhyOrdClass() != null && "1".equals(targetExamMain.getPhyOrdClass() )) {
                  payload.setCoopCd("phy_ord");
                  payload.setOpeCd("900012");
                } else {
                  payload.setCoopCd("exam_ord");
                  payload.setOpeCd("900002");
                }
                payload.setCoopCdIndex("");
                payload.setCrud("C");
                payload.setDirection("S");
                payload.setAnaResult("0");
                payload.setCoopResult("0");
                payload.setPatId(targetExamMain.getPatId());
                payload.setOrdNo(updatePatExamMain.getExamMainCd());
                payload.setBaseDate(new SimpleDateFormat("yyyyMMdd").format(updatePatExamMain.getRegExamDate()));
                payload.setUserId(patExamPattern.getIndUserId());
                payload.setRegOrderClass(patExamPattern.getRegOrderClass());
                if (patSrc != null) {
                  payload.setHospPatId(patSrc.getHosp_pat_id());
                }
                // mod 10553 生理検査送信連携不正 関  end
                payloads.add(payload);
              } catch (Exception e) {
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
                EventLogMessage eventLogMessage = new EventLogMessage();
                eventLogMessage.setLogMessage("連携イベント作成処理で例外発生： " + ExcetionStackTraceToString(e));
                if (facilityCd != null) {
                  eventLogMessage.setFacilityCd(facilityCd);
                }
                logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
              }
            }
          } else {
            // OrderExamSetInfo新規追加
            StringBuilder sbExamSetInfo = new StringBuilder();
            PatExamMainOrderExamSetInfo orderExamSetInfo = new PatExamMainOrderExamSetInfo()
            {
              {
                setNo(1);
                setSet_cd(patExamPattern.getOrderExamSetCd());
                setSet_name(mstExamSet.getExamSetName());
              }
            };
            sbExamSetInfo.append(orderExamSetInfo.getValue());

            sbExamSetInfo.insert(0, "[");
            sbExamSetInfo.append("]");

            // ExamOrderInfo新規追加
            StringBuilder sbExamOrderInfo = new StringBuilder();
            List<PatExamMainExamOrderInfo> examOrderInfo = new ArrayList<>();
            try {
              // 元データを取得する
              List<PatExamPatternExamOrderInfo> patternExamOrderInfo =
                StringUtils.isNullOrEmpty(patExamPattern.getExamOrderInfo())
                  ? new ArrayList<>()
                  : new ObjectMapper().readValue(patExamPattern.getExamOrderInfo(), new TypeReference<List<PatExamPatternExamOrderInfo>>() {});

              // パターンの検査項目データをすべて登録
              for (int idx = 0; idx < patternExamOrderInfo.size(); idx++) {
                Long examItemCd = patternExamOrderInfo.get(idx).getExam_item_cd();
                String examItemName = patternExamOrderInfo.get(idx).getExam_item_name();

                PatExamMainExamOrderInfo addExamOrderInfo = new PatExamMainExamOrderInfo ()
                {
                  {
                    setNo(1);
                    setItem_cd(examItemCd);
                    setItem_name(examItemName);
                  }
                };
                examOrderInfo.add(addExamOrderInfo);
              }

              // StringBuilderに変換
              examOrderInfo.stream().forEach(exam-> sbExamOrderInfo.append("," + exam.getValue()));

              // 文字列の前後に"["と"]"を付け加える
              sbExamOrderInfo.delete(0, 1);
              sbExamOrderInfo.insert(0, "[");
              sbExamOrderInfo.append("]");

            } catch (IOException e) {
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
              if (facilityCd != null) {
                eventLogMessage.setFacilityCd(facilityCd);
              }
              logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
            }

            // OrderLabelInfo新規作成はpat_exam_patternの内容をそのまま持ってくるため何もしない

            // 登録情報の作成
            PatExamMain insertPatExamMain = new PatExamMain()
            {
              {
                setPatId((long)patExamPattern.getPatId());
                setFacilityCd(patExamPattern.getFacilityCd());
                setFnPatId(patExamPattern.getFnPatId());
                setRegExamDate(regExamDate);
                setRegOrderClass(patExamPattern.getRegOrderClass());
                setExamStatus("0");
                setOrderExamSetInfo(sbExamSetInfo.toString());
                setExamOrderInfo(sbExamOrderInfo.toString());
                // mod 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm start
//                setOrderLabelInfo(patExamPattern.getOrderLabelInfo());
                setOrderLabelInfo("[]");
                // mod 11602 検査の「院内／院外」を検査項目マスタに持たせる zkm end
                setDataGenClass("0");
                // パフォーマンスなどを考慮してとりあえず依頼変更可否フラグは固定値"0"で入力する
                setIsLock("0");
                setIndUserId(StringUtils.isNullOrEmpty(defaultDoctor) ? null : Long.parseLong(defaultDoctor));
                setIsDel("0");
                setUpDate(getCurrentDate());
                setRegDate(getCurrentDate());
                setIsOrder("1");
                setRegStaff(patExamPattern.getRegStaff());
                setUpStaff(patExamPattern.getUpStaff());
              }
            };
            if (isPhysiologicalTest) {
              // 生理検査用検査セットの場合
              insertPatExamMain.setPhyOrdClass("1");
            }

            // insert対象に追加
            toInsertPatExamMains.add(insertPatExamMain);

            // 連携用のAPIをコール
            try {
              JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
              payload.setFacilityCd(insertPatExamMain.getFacilityCd());
              // mod 10553 生理検査送信連携不正 関  start
              // payload.setCoopCd("exam_ord");
              if (insertPatExamMain.getPhyOrdClass() != null && "1".equals(insertPatExamMain.getPhyOrdClass() )) {
                payload.setCoopCd("phy_ord");
                payload.setOpeCd("900012");
              } else {
                payload.setCoopCd("exam_ord");
                payload.setOpeCd("900002");
              }
              payload.setCoopCdIndex("");
              payload.setCrud("C");
              payload.setDirection("S");
              payload.setAnaResult("0");
              payload.setCoopResult("0");
              payload.setPatId(insertPatExamMain.getPatId());
              payload.setOrdNo(insertPatExamMain.getExamMainCd());
              payload.setBaseDate(new SimpleDateFormat("yyyyMMdd").format(insertPatExamMain.getRegExamDate()));
              payload.setUserId(patExamPattern.getIndUserId());
              payload.setRegOrderClass(patExamPattern.getRegOrderClass());
              if (patSrc != null) {
                payload.setHospPatId(patSrc.getHosp_pat_id());
              }
              // mod 10553 生理検査送信連携不正 関  end
              payloads.add(payload);
            } catch (Exception e) {
              EventLogMessage eventLogMessage = new EventLogMessage();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
              eventLogMessage.setLogMessage("連携イベント作成処理で例外発生： " + ExcetionStackTraceToString(e));
              if (facilityCd != null) {
                eventLogMessage.setFacilityCd(facilityCd);
              }
              eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
              logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
            }
          }
        });
      });

      template.batchUpdate("insert into pat_exam_main (" +
        "                           pat_id, facility_cd, ord_no, fn_pat_id, reg_exam_date, reg_order_class, " +
        "                           exam_status, order_comment, order_exam_set_info, exam_order_info, order_label_info,   " +
        "                           data_gen_class, result_exam_date, result_comment, exam_result_info, cop_order_no1,    " +
        "                           cop_order_no2, is_lock, ind_user_id, is_del, reg_date, reg_staff, up_date, up_staff,  " +
        "                           is_order, phy_ord_class)" +
        "values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", new BatchPreparedStatementSetter() {
        @Override
        public void setValues(@Nonnull PreparedStatement ps, int i) throws SQLException {
          PatExamMain patExamMain = toInsertPatExamMains.get(i);
          set(ps, 1, patExamMain.getPatId());
          set(ps, 2, patExamMain.getFacilityCd());
          set(ps, 3, patExamMain.getOrdNo());
          set(ps, 4, patExamMain.getFnPatId());
          set(ps, 5, patExamMain.getRegExamDate());
          set(ps, 6, patExamMain.getRegOrderClass());
          set(ps, 7, patExamMain.getExamStatus());
          set(ps, 8, patExamMain.getOrderComment());
          set(ps, 9, patExamMain.getOrderExamSetInfo());
          set(ps, 10, patExamMain.getExamOrderInfo());
          set(ps, 11, patExamMain.getOrderLabelInfo());
          set(ps, 12, patExamMain.getDataGenClass());
          set(ps, 13, patExamMain.getResultExamDate());
          set(ps, 14, patExamMain.getResultComment());
          set(ps, 15, patExamMain.getExamResultInfo());
          set(ps, 16, patExamMain.getCopOrderNo1());
          set(ps, 17, patExamMain.getCopOrderNo2());
          set(ps, 18, patExamMain.getIsLock());
          set(ps, 19, patExamMain.getIndUserId());
          set(ps, 20, patExamMain.getIsDel());
          set(ps, 21, patExamMain.getRegDate());
          set(ps, 22, patExamMain.getRegStaff());
          set(ps, 23, patExamMain.getUpDate());
          set(ps, 24, patExamMain.getUpStaff());
          set(ps, 25, patExamMain.getIsOrder());
          set(ps, 26, patExamMain.getPhyOrdClass());
        }

        @Override
        public int getBatchSize() {
          return toInsertPatExamMains.size();
        }
      });

      template.batchUpdate("update pat_exam_main set order_exam_set_info = ?, exam_order_info = ?, order_label_info = ?, " +
        " is_lock = ?, ind_user_id = ?, is_del = ?, up_date = ?, up_staff = ? " +
        " where exam_main_cd = ?", new BatchPreparedStatementSetter() {
        @Override
        public void setValues(@Nonnull PreparedStatement ps, int i) throws SQLException {
          PatExamMain patExamMain = toUpdatePatExamMains.get(i);
          set(ps, 1, patExamMain.getOrderExamSetInfo());
          set(ps, 2, patExamMain.getExamOrderInfo());
          set(ps, 3, patExamMain.getOrderLabelInfo());
          set(ps, 4, patExamMain.getIsLock());
          set(ps, 5, patExamMain.getIndUserId());
          set(ps, 6, patExamMain.getIsDel());
          set(ps, 7, patExamMain.getUpDate());
          set(ps, 8, patExamMain.getUpStaff());
          set(ps, 9, patExamMain.getExamMainCd());
        }

        @Override
        public int getBatchSize() {
          return toUpdatePatExamMains.size();
        }
      });

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者スケジュール自動延長 検査予定の延長準備ができました。 patId = " + patId.toString() + " insert件数 = " + toInsertPatExamMains.size() + " update件数 = " + toUpdatePatExamMains.size());
      logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);

    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "patExamMainDao/insertOrderExamSetInfo");
      throw new Exception();
    }
  }

  @Override
  public void createPatRadMain(Long patId, String facilityCd, String fromDt, String toDt, String defaultDoctor, List<JournalCreateRequestPayload> payloads) throws Exception {
    JdbcTemplate template = new JdbcTemplate(dataSource);
    try {
      // 期間内に当てはまるパターンを取得
      List<PatRadPattern> patRadPatternList = patRadPatternDao.selectPatRadPattern(patId, fromDt, toDt);

      Date fromDate = Date.valueOf(fromDt);
      Date toDate = Date.valueOf(toDt);

      List<MstRadSet> lstMstRadSet = mstRadSetDao.selectRadSetList(facilityCd);

      if (lstMstRadSet.isEmpty()) {
        // 放射線検査マスタに登録がない(全件削除済みなど)の場合はここで処理を抜ける
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("放射線検査マスタ未登録(全件削除済み)のため、放射線検査予定の延長をスキップします。 patId = " + patId.toString());
        logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
        return;
      }

      List<PatRadMain> patAllRadMains = patRadMainDao.selectPatRadMainByPatId(patId);
      // add 10553 連携イベント発生部分不正 関 start
      PatPersonalMain patSrc = patPersonalMainDao.selectById(patId);
      // add 10553 連携イベント発生部分不正 関 end

      List<PatRadMain> toInsertPatRadMains = new ArrayList<>();
      List<PatRadMain> toUpdatePatRadMains = new ArrayList<>();

      // 取得したレコード分ループ処理
      patRadPatternList.forEach(patRadPattern -> {
        // 検査パターンをもとに登録する日付一覧を取得
        List<Date> dateList = getCreateDate(new Date(patRadPattern.getRadFrom().getTime()), new Date(patRadPattern.getRadTo().getTime()),
            fromDate, toDate, patRadPattern.getRadPattern(), patRadPattern.getRadWeek());

        // DBから検査セット情報をとってくる
        MstRadSet mstRadSet = lstMstRadSet.stream()
            .filter(d -> d.getRadSetCd().equals(patRadPattern.getOrderRadSetCd()))
            .findFirst().orElse(null);

        if (mstRadSet == null) {
          // 対象放射線検査が存在しない場合(削除済みなど)は、次の処理に進む
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage("放射線検査依頼コードが存在しない(削除済み)のため、該当検査パターンの延長処理をスキップします。 patId = " + patId.toString() + " orderRadSetCd = " + patRadPattern.getOrderRadSetCd().toString());
          logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
          return;
        }

        // 取得した日付分ループ処理
        dateList.forEach(dt -> {
          Timestamp regRadDate = new Timestamp(dt.getTime());

          // 登録時刻の設定
          SimpleDateFormat sdfymd = new SimpleDateFormat("yyyy-MM-dd");
          SimpleDateFormat sdfhms = new SimpleDateFormat("HH:mm:ss");
          String strhms = StringUtils.isNullOrEmpty(sdfhms.format(patRadPattern.getRegRadDate())) ? "00:00:00" : sdfhms.format(patRadPattern.getRegRadDate());
          Timestamp regRadDateFormat = Timestamp.valueOf(sdfymd.format(regRadDate) + " " + strhms);

          // 追加対象の検査セットがあるか検索する関数
          ToIntFunction<PatRadMain> findOrderRadSetIndex = patRadMain -> {
            int result = -1;
            String orderRadSetInfoJson = patRadMain.getOrderRadSetInfo();
            try {
              List<PatRadMainOrderRadSetInfo> orderRadSetInfo =
                StringUtils.isNullOrEmpty(orderRadSetInfoJson)
                  ? new ArrayList<>()
                  : new ObjectMapper().readValue(
                    orderRadSetInfoJson,
                    new TypeReference<List<PatRadMainOrderRadSetInfo>>() {}
                  );
              for (int i = 0; i < orderRadSetInfo.size(); i++) {
                if (patRadPattern.getOrderRadSetCd().equals(orderRadSetInfo.get(i).getRad_set_cd())) {
                  // 追加対象の検査セットがあった場合
                  result = i;
                  break;
                }
              }
            } catch (IOException e) {
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
              if (facilityCd != null) {
                eventLogMessage.setFacilityCd(facilityCd);
              }
              logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
            }
            return result;
          };
          // 更新対象レコードデータを絞り込む関数
          Predicate<PatRadMain> patRadMainFilter = patRadMain ->
            regRadDateFormat.equals(patRadMain.getRegRadDate())
            && Objects.equals(patRadMain.getRegOrderClass(), patRadPattern.getRegOrderClass());
          // 更新対象レコードデータを検索する関数
          Function<List<PatRadMain>, PatRadMain> findTargetRadMain = list -> {
            PatRadMain result = null;
            List<PatRadMain> targetList = list.stream()
                .filter(patRadMainFilter)
                .collect(Collectors.toList());
            if (targetList.size() > 0) {
              // 常に1セット1レコードとするので
              // 追加対象の検査セットがすでに入っている場合のみ更新対象にする
              // （自動延長処理では通常存在しない）
              for (int i = 0; i < targetList.size(); i++) {
                if (findOrderRadSetIndex.applyAsInt(targetList.get(i)) != -1) {
                  // 追加対象の検査セットがあった場合
                  result = targetList.get(i);
                  break;
                }
              }
            }
            return result;
          };

          // 更新対象レコードデータを検索する
          PatRadMain targetRadMain = null;
          Boolean isDirtyRecord = false;
          // 新規追加レコードデータから検索
          targetRadMain = findTargetRadMain.apply(toInsertPatRadMains);
          if (targetRadMain == null) {
            // 更新レコードデータから検索
            targetRadMain = findTargetRadMain.apply(toUpdatePatRadMains);
          } else {
            // 新規追加レコードデータを更新対象とする場合
            isDirtyRecord = true;
          }
          if (targetRadMain == null) {
            // 既存レコードから検索
            targetRadMain = findTargetRadMain.apply(patAllRadMains);
          } else {
            // 更新レコードデータを更新対象とする場合
            isDirtyRecord = true;
          }

          // 検査予定の取得結果に応じてUpdate/Insertを変える
          if (targetRadMain != null) {
            // JSONの更新
            // OrderRadSetInfo更新
            StringBuilder sbRadSetInfo = new StringBuilder();
            try {
              List<PatRadMainOrderRadSetInfo> orderRadSetInfo =
                StringUtils.isNullOrEmpty(targetRadMain.getOrderRadSetInfo())
                  ? new ArrayList<>()
                  : new ObjectMapper().readValue(
                    targetRadMain.getOrderRadSetInfo(),
                    new TypeReference<List<PatRadMainOrderRadSetInfo>>() {}
                  );

              // 同じ検査セットがあるか最後まで検索
              boolean existRadItemSetCd = false;
              for (int idx = 0; idx < orderRadSetInfo.size(); idx++) {
                if (patRadPattern.getOrderRadSetCd().equals(orderRadSetInfo.get(idx).getRad_set_cd())) {
                  // 同じ Rad_item_set_cd があればセット名を更新
                  PatRadMainOrderRadSetInfo updateOrderRadSetInfo = orderRadSetInfo.get(idx);
                  updateOrderRadSetInfo.setRad_set_name(mstRadSet.getRadSetName());
                  orderRadSetInfo.set(idx, updateOrderRadSetInfo);
                  existRadItemSetCd = true;
                  break;
                }
              }
              // 同じ Rad_item_set_cd がなければ1件レコード追加
              if (!existRadItemSetCd) {
                int intNoForSet = orderRadSetInfo.size() + 1; // no は最大件数+1
                PatRadMainOrderRadSetInfo addOrderRadSetInfo = new PatRadMainOrderRadSetInfo()
                {
                  {
                    setNo(intNoForSet);
                    setRad_set_cd(patRadPattern.getOrderRadSetCd());
                    setRad_set_name(mstRadSet.getRadSetName());
                  }
                };
                orderRadSetInfo.add(addOrderRadSetInfo);
              }

              // StringBuilderに変換
              orderRadSetInfo.stream().forEach(Rad-> sbRadSetInfo.append("," + Rad.getValue()));

              // 文字列の前後に"["と"]"を付け加える
              sbRadSetInfo.delete(0, 1);
              sbRadSetInfo.insert(0, "[");
              sbRadSetInfo.append("]");

            } catch (IOException e) {
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
              EventLogMessage eventLogMessage = new EventLogMessage();
              eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
              if (facilityCd != null) {
                eventLogMessage.setFacilityCd(facilityCd);
              }
              logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
            }

            if (isDirtyRecord) {
              // 登録情報は作成済の場合
              // 検査セット追加によって変わる項目のみ設定しなおす
              targetRadMain.setOrderRadSetInfo(sbRadSetInfo.toString());
            } else {
              // 登録情報の作成
              final PatRadMain targetRadMainCapture = targetRadMain;
              PatRadMain updatePatRadMain = new PatRadMain()
              {
                {
                  setRadResultCd(targetRadMainCapture.getRadResultCd());
                  setRegRadDate(targetRadMainCapture.getRegRadDate());
                  setRegOrderClass(targetRadMainCapture.getRegOrderClass());
                  setOrderRadSetInfo(sbRadSetInfo.toString());
                  setIsLock(targetRadMainCapture.getIsLock());
                  setIsDel("0");
                  setUpDate(getCurrentDate());
                }
              };

              // update対象に追加
              toUpdatePatRadMains.add(updatePatRadMain);

              // 連携用のAPIをコール
              try {
                JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
                payload.setFacilityCd(targetRadMain.getFacilityCd());
                payload.setCoopCd("rad_ord");
                payload.setCoopCdIndex("");
                payload.setCrud("C");
                payload.setDirection("S");
                payload.setAnaResult("0");
                payload.setCoopResult("0");
                payload.setPatId(targetRadMain.getPatId());
                payload.setOrdNo(updatePatRadMain.getRadResultCd());
                payload.setBaseDate(new SimpleDateFormat("yyyyMMdd").format(updatePatRadMain.getRegRadDate()));
                payload.setOpeCd("900003");
                payload.setUserId(patRadPattern.getIndUserId());
                payload.setRegOrderClass(patRadPattern.getRegOrderClass());
                // add 10553 連携イベント発生部分不正 関 start
                if (patSrc != null) {
                  payload.setHospPatId(patSrc.getHosp_pat_id());
                }
                // add 10553 連携イベント発生部分不正 関 end
                payloads.add(payload);
              } catch (Exception e) {
                EventLogMessage eventLogMessage = new EventLogMessage();
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
                eventLogMessage.setLogMessage("連携イベント作成処理で例外発生： " + ExcetionStackTraceToString(e));
                if (facilityCd != null) {
                  eventLogMessage.setFacilityCd(facilityCd);
                }
                eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
                logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
                // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
              }
            }
          } else {
            // OrderRadSetInfo新規追加
            StringBuilder sbRadSetInfo = new StringBuilder();
            PatRadMainOrderRadSetInfo orderRadSetInfo = new PatRadMainOrderRadSetInfo()
            {
              {
                setNo(1);
                setRad_set_cd(patRadPattern.getOrderRadSetCd());
                setRad_set_name(mstRadSet.getRadSetName());
              }
            };
            sbRadSetInfo.append(orderRadSetInfo.getValue());

            sbRadSetInfo.insert(0, "[");
            sbRadSetInfo.append("]");

            // 登録情報の作成
            PatRadMain insertPatRadMain = new PatRadMain()
            {
              {
                setPatId(patRadPattern.getPatId());
                setFacilityCd(patRadPattern.getFacilityCd());
                setFnPatId(patRadPattern.getFnPatId());
                setRegRadDate(regRadDateFormat);
                setRegOrderClass(patRadPattern.getRegOrderClass());
                setRadStatus("0");
                setOrderRadSetInfo(sbRadSetInfo.toString());
                // パフォーマンスなどを考慮してとりあえず依頼変更可否フラグは固定値"0"で入力する
                setIsLock("0");
                setIndUserId(StringUtils.isNullOrEmpty(defaultDoctor) ? null : Long.parseLong(defaultDoctor));
                setIsDel("0");
                setUpDate(getCurrentDate());
                setRegDate(getCurrentDate());
                setRegStaff(patRadPattern.getRegStaff());
                setUpStaff(patRadPattern.getUpStaff());
              }
            };

            // insert対象に追加
            toInsertPatRadMains.add(insertPatRadMain);

            // 連携用のAPIをコール
            try {
              JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
              payload.setFacilityCd(insertPatRadMain.getFacilityCd());
              payload.setCoopCd("rad_ord");
              payload.setCoopCdIndex("");
              payload.setCrud("C");
              payload.setDirection("S");
              payload.setAnaResult("0");
              payload.setCoopResult("0");
              payload.setPatId(insertPatRadMain.getPatId());
              payload.setOrdNo(insertPatRadMain.getRadResultCd());
              payload.setBaseDate(new SimpleDateFormat("yyyyMMdd").format(insertPatRadMain.getRegRadDate()));
              payload.setOpeCd("900003");
              payload.setUserId(patRadPattern.getIndUserId());
              payload.setRegOrderClass(patRadPattern.getRegOrderClass());
              // add 10553 連携イベント発生部分不正 関 start
              if (patSrc != null) {
                payload.setHospPatId(patSrc.getHosp_pat_id());
              }
              // add 10553 連携イベント発生部分不正 関 end
              payloads.add(payload);
            } catch (Exception e) {
              EventLogMessage eventLogMessage = new EventLogMessage();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang start
              eventLogMessage.setLogMessage("連携イベント作成処理で例外発生： " + ExcetionStackTraceToString(e));
              if (facilityCd != null) {
                eventLogMessage.setFacilityCd(facilityCd);
              }
              eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 mod yangxuewang end
              logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
              // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
            }
          }
        });
      });

      template.batchUpdate("insert into pat_rad_main (pat_id, facility_cd, fn_pat_id, reg_rad_date, reg_order_class, rad_status, " +
        "                          order_rad_set_info, cop_order_no1, cop_order_no2, is_lock, ind_user_id, is_del, reg_date, " +
        "                          reg_staff, up_date, up_staff) " +
        "values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", new BatchPreparedStatementSetter() {

        @Override
        public void setValues(@Nonnull PreparedStatement ps, int i) throws SQLException {
          PatRadMain patRadMain = toInsertPatRadMains.get(i);
          set(ps, 1, patRadMain.getPatId());
          set(ps, 2, patRadMain.getFacilityCd());
          set(ps, 3, patRadMain.getFnPatId());
          set(ps, 4, patRadMain.getRegRadDate());
          set(ps, 5, patRadMain.getRegOrderClass());
          set(ps, 6, patRadMain.getRadStatus());
          set(ps, 7, patRadMain.getOrderRadSetInfo());
          set(ps, 8, patRadMain.getCopOrderNo1());
          set(ps, 9, patRadMain.getCopOrderNo2());
          set(ps, 10, patRadMain.getIsLock());
          set(ps, 11, patRadMain.getIndUserId());
          set(ps, 12, patRadMain.getIsDel());
          set(ps, 13, patRadMain.getRegDate());
          set(ps, 14, patRadMain.getRegStaff());
          set(ps, 15, patRadMain.getUpDate());
          set(ps, 16, patRadMain.getUpStaff());
        }

        @Override
        public int getBatchSize() {
          return toInsertPatRadMains.size();
        }
      });
      template.batchUpdate("update pat_rad_main set reg_rad_date = ?, order_rad_set_info = ?, is_lock = ?, " +
        " is_del = ?, up_date = ? where rad_result_cd = ? ", new BatchPreparedStatementSetter() {

        @Override
        public void setValues(@Nonnull PreparedStatement ps, int i) throws SQLException {
          PatRadMain patRadMain = toUpdatePatRadMains.get(i);
          set(ps, 1, patRadMain.getRegRadDate());
          set(ps, 2, patRadMain.getOrderRadSetInfo());
          set(ps, 3, patRadMain.getIsLock());
          set(ps, 4, patRadMain.getIsDel());
          set(ps, 5, patRadMain.getUpDate());
          set(ps, 6, patRadMain.getRadResultCd());
        }

        @Override
        public int getBatchSize() {
          return toUpdatePatRadMains.size();
        }
      });

      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("患者スケジュール自動延長 放射線検査予定の延長準備ができました。 patId = " + patId.toString() + " insert件数 = " + toInsertPatRadMains.size() + " update件数 = " + toUpdatePatRadMains.size());
      logService.log(LogLevel.INFO, eventLogMessage,"",SERVICE_NAME.FNSI, null);
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("例外発生：" + e.getMessage());
      eventLogMessage.setFacilityCd(facilityCd);
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, "patExamMainDao/insertOrderRadSetInfo");
      throw new Exception();
    }
  }

  /**
   * 期間内にマッチする検査パターンの日付一覧を取得
   * @param patternFromDt 患者検査パターン：期間開始日
   * @param patternToDt 患者検査パターン：期間終了日
   * @param paramFromDt 期間開始日
   * @param paramToDt 期間終了日
   * @param pattern 検査パターン
   * @param dayOfWeek 曜日
   * @return 検査候補日一覧
   */
  private List<Date> getCreateDate(Date patternFromDt, Date patternToDt,
      Date paramFromDt, Date paramToDt, int pattern, int dayOfWeek ){
    List<Date> dateList = new ArrayList<>();
    List<Integer> weekList = new ArrayList<>();

    // パターンにより、登録する週を取得
    switch (pattern){
    case 1: // 指定日1回分(パターンには入らない)
      weekList.add(0);
      break;
    case 2: // 月１：第1週
      weekList.add(1);
      break;
    case 3: // 月１：第2週
      weekList.add(2);
      break;
    case 4: // 月１：第3週
      weekList.add(3);
      break;
    case 5: // 月１：第4週
      weekList.add(4);
      break;
    case 6: // 月２：第1週、第3週
      weekList.add(1);
      weekList.add(3);
      break;
    case 7: // 月２：第2週、第4週
      weekList.add(2);
      weekList.add(4);
      break;
    case 8: // 年間複数日指定(パターンには入らない)
      weekList.add(0);
      break;
    case 9: // 隔週
      dateList = getCreateBiWeeklyDate(patternFromDt, patternToDt, paramFromDt, paramToDt, dayOfWeek);
      return dateList;
    }

    // カレンダーの開始・終了日設定
    //ベースとなる期間開始日と期間終了日を取得
    Date baseFromDt = patternFromDt.after(paramFromDt) ? patternFromDt : paramFromDt;
    Date baseToDt = patternToDt.after(paramToDt) ? paramToDt : patternToDt;
    Calendar calBaseFrom = Calendar.getInstance();
    Calendar calBaseTo = Calendar.getInstance();
    calBaseFrom.setTime(baseFromDt);
    calBaseTo.setTime(baseToDt);

    //期間開始から終了までをループ処理
    while (calBaseFrom.before(calBaseTo) || calBaseFrom.equals(calBaseTo)) {

      //週がマッチした場合、曜日判定
      if (weekList.contains(calBaseFrom.get(Calendar.DAY_OF_WEEK_IN_MONTH))){

        Date dt = new Date(calBaseFrom.getTime().getTime());

        //曜日がマッチした場合、Listに追加
        switch (dayOfWeek){
        case 1:
          if(calBaseFrom.get(Calendar.DAY_OF_WEEK)==2) dateList.add(dt);
          break;
        case 2:
          if(calBaseFrom.get(Calendar.DAY_OF_WEEK)==3) dateList.add(dt);
          break;
        case 3:
          if(calBaseFrom.get(Calendar.DAY_OF_WEEK)==4) dateList.add(dt);
          break;
        case 4:
          if(calBaseFrom.get(Calendar.DAY_OF_WEEK)==5) dateList.add(dt);
          break;
        case 5:
          if(calBaseFrom.get(Calendar.DAY_OF_WEEK)==6) dateList.add(dt);
          break;
        case 6:
          if(calBaseFrom.get(Calendar.DAY_OF_WEEK)==7) dateList.add(dt);
          break;
        case 7:
          if(calBaseFrom.get(Calendar.DAY_OF_WEEK)==1) dateList.add(dt);
          break;
        }
      }else if(weekList.contains(0)) {
        // 指定日１回分または複数日指定の場合は上記処理を行わない
        return dateList;
      };

      // 対象日時を進める
      calBaseFrom.add(Calendar.DATE,1);
    }

    return dateList;
  }

  /**
   * 期間内にマッチする検査パターンの日付一覧を取得(隔週)
   * @param patternFromDt 患者検査パターン：期間開始日
   * @param patternToDt 患者検査パターン：期間終了日
   * @param paramFromDt 期間開始日
   * @param paramToDt 期間終了日
   * @param dayOfWeek 曜日
   */
  private List<Date> getCreateBiWeeklyDate(Date patternFromDt, Date patternToDt,
      Date paramFromDt, Date paramToDt, int dayOfWeek ) {
    List<Date> dateList = new ArrayList<>();

    // 検査パターンの開始日付を取得
    Date biweeklyPtnFromDt = patternFromDt;
    Calendar calBiweeklyPtnFrom = Calendar.getInstance();
    calBiweeklyPtnFrom.setTime(biweeklyPtnFromDt);

    // 指定期間の開始日付を取得
    Date biweeklyPrmFromDt = paramFromDt;
    Calendar calBiweeklyPrmFrom = Calendar.getInstance();
    calBiweeklyPrmFrom.setTime(biweeklyPrmFromDt);

    // 終了日付を取得
    Date biweeklyToDt = patternToDt.after(paramToDt) ? paramToDt : patternToDt;
    Calendar calBiweeklyTo = Calendar.getInstance();
    calBiweeklyTo.setTime(biweeklyToDt);

    // 曜日値の調整
    // dayOfWeek: 1：月曜日 ～ 7：日曜日
    // Calendar.DAY_OF_WEEK: 1：日曜日 ～ 7：土曜日
    int ptnFromDayOfWeek = 0;
    if (calBiweeklyPtnFrom.get(Calendar.DAY_OF_WEEK) == 1) {
      ptnFromDayOfWeek = calBiweeklyPtnFrom.get(Calendar.DAY_OF_WEEK) + 6;  // 日曜日
    } else if (calBiweeklyPtnFrom.get(Calendar.DAY_OF_WEEK) >= 2) {
      ptnFromDayOfWeek = calBiweeklyPtnFrom.get(Calendar.DAY_OF_WEEK) - 1;  // 月～土曜日
    }

    // 基準日を取得(パターンの開始日付から一番近い指定曜日)
    int addDays = 0;
    if (ptnFromDayOfWeek <= dayOfWeek) {
      addDays = dayOfWeek - ptnFromDayOfWeek;
      calBiweeklyPtnFrom.add(Calendar.DATE,addDays);
    } else {
      addDays = 7 - (ptnFromDayOfWeek - dayOfWeek);
      calBiweeklyPtnFrom.add(Calendar.DATE,addDays);
    }

    // 隔週(14日毎)の日付を取得
    while (calBiweeklyPtnFrom.before(calBiweeklyTo) || calBiweeklyPtnFrom.equals(calBiweeklyTo)) {
      if (calBiweeklyPtnFrom.after(calBiweeklyPrmFrom)) {
        // 検査パターンの日付が指定期間後の場合、14日ごとの日付を登録する
        Date dt = new Date(calBiweeklyPtnFrom.getTime().getTime());
        dateList.add(dt);
      }
      // 対象日時を進める
      calBiweeklyPtnFrom.add(Calendar.DATE,14);
    }

    return dateList;
  }

  /**
   * システム日時を取得します
   * @return システム日時
   */
  private java.sql.Timestamp getCurrentDate() {
    return new java.sql.Timestamp(System.currentTimeMillis());
  }

  private void set(PreparedStatement ps, int index, Long value) throws SQLException {
    if (value == null) {
      ps.setNull(index, Types.BIGINT);
    } else {
      ps.setLong(index, value);
    }
  }

  private void set(PreparedStatement ps, int index, String value) throws SQLException {
    if (value == null) {
      ps.setNull(index, Types.VARCHAR);
    } else {
      ps.setString(index, value);
    }
  }

  private void set(PreparedStatement ps, int index, Integer value) throws SQLException {
    if (value == null) {
      ps.setNull(index, Types.INTEGER);
    } else {
      ps.setInt(index, value);
    }
  }

  private void set(PreparedStatement ps, int index, Timestamp value) throws SQLException {
    if (value == null) {
      ps.setNull(index, Types.TIMESTAMP);
    } else {
      ps.setTimestamp(index, value);
    }
  }

  private void set(PreparedStatement ps, int index, java.util.Date value) throws SQLException {
    if (value == null) {
      ps.setNull(index, Types.DATE);
    } else {
      ps.setDate(index, new Date(value.getTime()));
    }
  }

}
