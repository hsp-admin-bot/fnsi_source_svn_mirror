package jp.co.nikkiso.ntss.web_api.service;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.web_api.exception.NtssException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo;
import jp.co.nikkiso.ntss.core.dao.MstExamItemDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.entity.MstExamItem;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainExamResultInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatMainInfectInfo;
import org.springframework.transaction.annotation.Transactional;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class ExamRecordInfectInfoUtilServiceImpl implements ExamRecordInfectInfoUtilService {

  /**
   * 検査項目マスタのDaoインタフェース.
   */
  @Autowired
  private MstExamItemDao mstExamItemDao;

  /**
   * 患者検査結果のDaoインタフェース.
   */
  @Autowired
  private PatExamMainDao patExamMainDao;

  /**
   * 患者基本情報のDaoインタフェース.
   */
  @Autowired
  private PatMainDao patMainDao;

  /**
   * 施設設定マスタのDaoインタフェース.
   */
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;


  // add by guanyings 2023-01-30 アプリケーションログの適正化 --start
  @Autowired
  private LogService logService;
  // add by guanyings 2023-01-30 アプリケーションログの適正化 -- end


  private String convertInfectCode(String examResult, String strPositive, String strNegative) {
    // 陽性(+)と判定する文字列
    String[] strPositiveList = strPositive.split(",", 0);

    // 陰性(-)と判定する文字列
    String[] strNegativeList = strNegative.split(",", 0);


    if (Arrays.asList(strNegativeList).contains(examResult)) {
      return "1";
    } else if (Arrays.asList(strPositiveList).contains(examResult)) {
      return "2";
    } else {
      return "0";
    }
  }

  /**
   * 検査結果から感染症の検査結果を登録
   * @param examMainCd 検査結果コードのリスト
   * @param patId 患者ID
   */
  @Transactional(rollbackFor = Exception.class)
  public void updateInfectinfo(List<Long> examMainCd) {
    // JSONに入れる日付のフォーマット(例 20190926)
    SimpleDateFormat mainDateFormat = new SimpleDateFormat("yyyyMMdd");

    // 検査結果コードすべてに対して実施
    examMainCd.forEach(exam ->{

      // 感染症情報のJSON変換用
      StringBuilder sbInfectInfo = new StringBuilder();

      // 追加数
      int addCount = 0;

      try {
        // 対象検査結果の取得
        PatExamMain patExamMain = patExamMainDao.selectPatExamMainByExamMainCd(exam);
        if (patExamMain == null) {
          // 対象検査結果の取得に失敗した場合、処理を行わない
          return;
        }

        // 患者IDの取得
        Long patId = patExamMain.getPatId();

        // DBから対象患者の情報を取得
        PatMain patMain = patMainDao.selectById(patId);

        // patExamMainの検査結果JSON取得
        List<PatExamMainExamResultInfo> examResultInfo =
            patExamMain.getExamResultInfo() == null || patExamMain.getExamResultInfo().isEmpty()
            ? new ArrayList<>()
            : new ObjectMapper().readValue(patExamMain.getExamResultInfo(), new TypeReference<List<PatExamMainExamResultInfo>>() {});

        // PatMainの感染症情報JSON取得
        List<PatMainInfectInfo> infectInfo =
            patMain.getInfect_info() == null || patMain.getInfect_info().isEmpty()
            ? new ArrayList<>()
            : new ObjectMapper().readValue(patMain.getInfect_info(), new TypeReference<List<PatMainInfectInfo>>() {});

        // 検査結果の最後まで検索
        for (int ExamIdx = 0; ExamIdx < examResultInfo.size(); ExamIdx++) {

          // 検査項目コードの取得
          Long examItemCd = Long.parseLong(examResultInfo.get(ExamIdx).getItem_cd());

          // DBから対象検査項目を取得
          MstExamItem mstExamItem = mstExamItemDao.selectByExamItemCd(examItemCd);

          // 感染症コードはあるか？
          if (mstExamItem.getInfectionCd() == null || mstExamItem.getInfectionCd().isEmpty()) {
            // 感染症コードはなし
          } else {
            // 更新日
            Timestamp nowDate = new java.sql.Timestamp(System.currentTimeMillis());
            String strDate = mainDateFormat.format(nowDate);

            // 検査日
            Timestamp patExamMainExamDate = patExamMain.getResultExamDate();
            String strExamDate =  mainDateFormat.format(patExamMainExamDate);

            // 施設コード
            String facilityCd = mstExamItem.getFacilityCd();

            // 陽性結果値群(カンマ区切り)
            FacilitySettingInfo infoPositive = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, FacilitySettingNo.INFECT_POSITIVE_RESULT_VALUE_GROUP);
            String strPositive = infoPositive.getValue();

            // 陰性結果値群(カンマ区切り)
            FacilitySettingInfo infoNegative = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, FacilitySettingNo.INFECT_NEGATIVE_RESULT_VALUE_GROUP);
            String strNegative = infoNegative.getValue();

            // 結果
            String infectCode = convertInfectCode(examResultInfo.get(ExamIdx).getResult(),strPositive,strNegative);

            // 同じ感染症コードがあるか最後まで検索
            boolean existInfectionCd = false;
            // del 9538 患者情報の感染症の感染症患者として扱うの保存を行っても感染症結果に(+)がないとONの表示がされない zhou start
            // add 患者情報：検査結果一括登録感染症後、ページ上部患者名横の感染症アイコンに色がない 関　start
            //boolean positiveInfectionFlg = false;
            // add 患者情報：検査結果一括登録感染症後、ページ上部患者名横の感染症アイコンに色がない 関  end
            // del 9538 患者情報の感染症の感染症患者として扱うの保存を行っても感染症結果に(+)がないとONの表示がされない zhou end
            for (int infectIdx = 0; infectIdx < infectInfo.size(); infectIdx++) {
              if (infectInfo.get(infectIdx).getInfection_cd().equals(Integer.parseInt(mstExamItem.getInfectionCd()))) {
                // 同じ感染症コードがあれば結果を更新
                PatMainInfectInfo updateInfectInfo = infectInfo.get(infectIdx);

                if (infectInfo.get(infectIdx).getCtl_no() == null || infectInfo.get(infectIdx).getCtl_no().isEmpty()) {
                  updateInfectInfo.setCtl_no(Integer.toString(infectIdx + 1)); // 管理番号が存在しなければ追加する
                }

                // pat_mainの感染症の検査日(JSONから取得,yyyyMMdd)
                String strInfectInfoExamDate = infectInfo.get(infectIdx).getExam_date();
                // pat_mainの感染症の検査日のTimestampクラス
                Timestamp infectInfoExamDate;

                try {
                  // JSONから取得した検査日をTimestampクラスに変換
                  infectInfoExamDate = new Timestamp(new SimpleDateFormat("yyyyMMdd").parse(strInfectInfoExamDate).getTime());
                } catch (Exception e) {
                  // Timestampクラスに変換でエラーした場合(nullなど)
                  // 1970/01/01にする
                  infectInfoExamDate = new Timestamp(0);
                }

                if (patExamMainExamDate.after(infectInfoExamDate)) {
                  updateInfectInfo.setInfect(infectCode); // 結果コード,　※0：不明、1：(-)、2：(+)
                  updateInfectInfo.setExam_date(strExamDate); // 検査日
                  updateInfectInfo.setUp_date(strDate); // 更新日

                  infectInfo.set(infectIdx, updateInfectInfo);
                }

                existInfectionCd = true;
              } else if (infectInfo.get(infectIdx).getCtl_no() == null || infectInfo.get(infectIdx).getCtl_no().isEmpty()) {
                // 同じ感染症コードがなくても管理番号が存在しなければ追加する
                PatMainInfectInfo updateInfectInfo = infectInfo.get(infectIdx);
                updateInfectInfo.setCtl_no(Integer.toString(infectIdx + 1));
                infectInfo.set(infectIdx, updateInfectInfo);
              }
              // del 9538 患者情報の感染症の感染症患者として扱うの保存を行っても感染症結果に(+)がないとONの表示がされない zhou start
              // add 患者情報：検査結果一括登録感染症後、ページ上部患者名横の感染症アイコンに色がない 関　start
//              if (infectInfo.get(infectIdx).getInfect().equals("2")) {
//                patMain.setIs_infect("1");
//                positiveInfectionFlg = true;
//              }
              // add 患者情報：検査結果一括登録感染症後、ページ上部患者名横の感染症アイコンに色がない 関  end
              // del 9538 患者情報の感染症の感染症患者として扱うの保存を行っても感染症結果に(+)がないとONの表示がされない zhou end
            }
            // del 9538 患者情報の感染症の感染症患者として扱うの保存を行っても感染症結果に(+)がないとONの表示がされない zhou start
            // add 患者情報：検査結果一括登録感染症後、ページ上部患者名横の感染症アイコンに色がない 関　start
//            if (!positiveInfectionFlg) {
//              patMain.setIs_infect("0");
//            }
            // add 患者情報：検査結果一括登録感染症後、ページ上部患者名横の感染症アイコンに色がない 関  end
            // del 9538 患者情報の感染症の感染症患者として扱うの保存を行っても感染症結果に(+)がないとONの表示がされない zhou end
            // 同じ感染症コードがなければ１件追加
            if (!existInfectionCd) {
              int intNo = infectInfo.size() + addCount + 1; // no は最大件数+追加数+1

              PatMainInfectInfo addInfectInfo = new PatMainInfectInfo();
              addInfectInfo.setCtl_no(Integer.toString(intNo));
              addInfectInfo.setInfection_cd(Integer.parseInt(mstExamItem.getInfectionCd()));
              addInfectInfo.setInfect(infectCode);
              addInfectInfo.setExam_date(strExamDate);
              addInfectInfo.setUp_date(strDate);

              infectInfo.add(addInfectInfo);
              // del 9538 患者情報の感染症の感染症患者として扱うの保存を行っても感染症結果に(+)がないとONの表示がされない zhou start
              // add 患者情報：検査結果一括登録感染症後、ページ上部患者名横の感染症アイコンに色がない 関　start
//              if (infectInfo.get(0).getInfect().equals("2")) {
//                patMain.setIs_infect("1");
//              }
              // add 患者情報：検査結果一括登録感染症後、ページ上部患者名横の感染症アイコンに色がない 関  end
              // del 9538 患者情報の感染症の感染症患者として扱うの保存を行っても感染症結果に(+)がないとONの表示がされない zhou end
            }
          }
        }

        // 感染症情報のJSONをまとめてupdate
        // 感染症情報に対してレコードを追加・更新する

        // StringBuilderに変換
        infectInfo.stream().forEach(infect-> sbInfectInfo.append("," + infect.getValue()));

        // 文字列の前後に"["と"]"を付け加える
        sbInfectInfo.delete(0, 1);
        sbInfectInfo.insert(0, "[");
        sbInfectInfo.append("]");

        // update処理
        patMain.setInfect_info(sbInfectInfo.toString());
        patMainDao.update(patMain);

      } catch (Exception e) {
        // add by guanyings 2023-01-30 アプリケーションログの適正化 --start
        EventLogMessage eventLogMessage = new EventLogMessage();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI,null);
        throw  new NtssException("更新に失敗しました");
        // add by guanyings 2023-01-30 アプリケーションログの適正化 -- end
      }
    });

  }

}
