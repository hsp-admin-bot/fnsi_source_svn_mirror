package jp.co.nikkiso.ntss.admin_web.service.exam;

import java.io.UnsupportedEncodingException;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Comparator;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.DeviceSetInfoService;
import jp.co.nikkiso.ntss.admin_web.service.PatInfoService;
import jp.co.nikkiso.ntss.admin_web.service.rad.RadRequestService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
// add FNSI-終了およびその結果を通知機能で教える 江 start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
// add FNSI-終了およびその結果を通知機能で教える 江 end
import jp.co.nikkiso.ntss.core.entity.MstExamItem;
import jp.co.nikkiso.ntss.core.entity.MstExamRecordItem;
import jp.co.nikkiso.ntss.core.entity.MstExamSet;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.OrdMainForExamRecord;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainData;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainExamResultInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainForDetails;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainForOneOrder;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainForPatIdLastDate;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainForRecord;
import jp.co.nikkiso.ntss.core.entity.custom.PatExamMainInfo;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.dao.MstExamSetDao;
import jp.co.nikkiso.ntss.core.dao.MstExamItemDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;

import jp.co.nikkiso.ntss.admin_web.request.exam.examResultFileCaptureRequest;
import jp.co.nikkiso.ntss.admin_web.response.exam.ExamResultFileCaptureResponse;

import jp.co.nikkiso.ntss.admin_web.service.FacilitySettingService;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.FlagType;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.TransactionManagerName;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;


@Service
public class ExamRecordServiceImpl implements ExamRecordService {

  /**
   * 検査セットマスタのDaoインタフェース.
   */
  @Autowired
  private MstExamSetDao mstExamSetDao;

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
   * 透析履歴のDaoインタフェース.
   */
  @Autowired
  private OrdMainDao OrdMainDao;

  /**
   * 患者基本情報のDaoインタフェース.
   */
  @Autowired
  private PatPersonalMainDao patPersonalMainDao;

  @Autowired
  FacilitySettingService facilitySettingService;

  // add FNSI-終了およびその結果を通知機能で教える 江 start
  /**
   * 施設設定マスタのDaoインタフェース.
   */
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;
  // add FNSI-終了およびその結果を通知機能で教える 江 end

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;
  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  @Autowired
  private RadRequestService radRequestService;

  // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc start
  @Autowired
  DeviceSetInfoService deviceSetInfoService;
  // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc end

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstExamSet> selectExamRecordSetList(String facilityCd) {
    List<MstExamSet> mstExamSetList = mstExamSetDao.selectExamSetList(facilityCd,false,true);
    return mstExamSetList;
  }


  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstExamItem> selectExamItemList(String facilityCd) {
    List<MstExamItem> mstExamItemList = mstExamItemDao.selectSharingByFacilityCd(facilityCd);
    return mstExamItemList;
  }

  // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add start
  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstExamItem> selectExamItemListForRecalc(String facilityCd) {
    List<MstExamItem> mstExamItemList = mstExamItemDao.selectExamItemForRecalcByFacilityCd(facilityCd);
    return mstExamItemList;
  }
  // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add end

  /**
   * {@inheritDoc}
   */
  @Override
  public List<OrdMainForExamRecord> selectRstStartDateList(Long patId,String facilityCd){
    List<OrdMainForExamRecord> rstDataList = OrdMainDao.selectRstStartDateByPatId(patId,facilityCd);
    return rstDataList;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstExamRecordItem> selectExamItemListForItemCd(String facilityCd, List<Long> examItemCd, List<String> examClass, String dispFlg) {
    List<MstExamRecordItem> mstExamItemList = mstExamItemDao.selectExamItemListForItemCd(facilityCd,examItemCd,examClass,dispFlg);
    return mstExamItemList;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstExamRecordItem> selectExamItemListForExamClass(String facilityCd, List<String> examClass, String dispFlg) {
    List<MstExamRecordItem> mstExamItemList = mstExamItemDao.selectExamItemListForExamClass(facilityCd,examClass,dispFlg);
    return mstExamItemList;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<PatExamMainForRecord> selectExamMainToRecord(String facilityCd, List<Long> patIdList, String resultFrom, String resultTo) {
    List<PatExamMainForRecord> patExamMainRecordList = patExamMainDao.selectPatExamMainRecordList(facilityCd, patIdList, resultFrom, resultTo);
    return patExamMainRecordList;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<PatExamMainForPatIdLastDate> selectExamMainToPatIdLastDate(String facilityCd, List<Long> patIdList) {
    List<PatExamMainForPatIdLastDate> patExamMainLastDate = patExamMainDao.selectPatExamMainPatIdLastDate(facilityCd, patIdList);
    return patExamMainLastDate;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<PatExamMainInfo> selectExamMainToPatId(String facilityCd, String patId, String resultFrom, String resultTo, String examDateOrder) {
    List<PatExamMainForDetails> patExamMainDetailList = patExamMainDao.selectPatExamMainDetailList(facilityCd, patId, resultFrom, resultTo, examDateOrder);
    List<PatExamMainInfo> patExamMainList = new ArrayList<>();
    SimpleDateFormat examDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    for (PatExamMainForDetails patExamMain : patExamMainDetailList) {
      PatExamMainInfo resultInfo = new PatExamMainInfo();
      resultInfo.setExamMainCd(patExamMain.getExamMainCd());
      resultInfo.setPatId(patExamMain.getPatId());
      resultInfo.setFacilityCd(patExamMain.getFacilityCd());
      resultInfo.setRegOrderClass(patExamMain.getRegOrderClass());
      resultInfo.setExamResultInfo(patExamMain.getExamResultInfo());
      resultInfo.setDataGenClass(patExamMain.getDataGenClass());
      resultInfo.setExamStatus(patExamMain.getExamStatus());
      resultInfo.setRegOrderClassName(patExamMain.getRegOrderClassName());
      resultInfo.setResultComment(patExamMain.getResultComment());
      resultInfo.setResultExamDateName(patExamMain.getResultExamDateName());
      resultInfo.setResultExamDate(examDateFormat.format(patExamMain.getResultExamDate()));
      patExamMainList.add(resultInfo);
    }
    return patExamMainList;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<PatExamMainForOneOrder> selectExamMainForOneOrder(String examMainCd){
    List<PatExamMainForOneOrder> patExamMainOneOrder = patExamMainDao.selectPatExamMainOneOrder(examMainCd);
    return patExamMainOneOrder;
  }


  /**
   *
   */
  @Override
  @Transactional(rollbackFor=Exception.class)
  public Long insertExamMainForOneOrder(PatExamMain insertData)  throws Exception {
    try {
      patExamMainDao.insertOrderExamSetInfo(insertData);
      return insertData.getExamMainCd();
    } catch (Exception e) {
      throw new Exception(e);
    }
  }

  /**
   *
   */
  @Override
  @Transactional(rollbackFor=Exception.class)
  public void updateExamMainForOneOrder(Long examMainCd, String examResultInfo, Long upStaff, String examDate, String regOrderClass)  throws Exception {
    try {

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "pat_exam_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" exam_main_cd = " + examMainCd + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(patExamMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End
      List<PatExamMainExamResultInfo> examResulList = null == examResultInfo ? new ArrayList<>()
        : new ObjectMapper().readValue(examResultInfo, new TypeReference<List<PatExamMainExamResultInfo>>() {});

      // 更新前の検査結果を取得
      List<PatExamMainForOneOrder> patExamMainOneOrder = patExamMainDao.selectPatExamMainOneOrder(String.valueOf(examMainCd));

      // 削除済の検査項目を取得
      List<PatExamMainForOneOrder> delExamMainOneOrder = patExamMainOneOrder.stream()
          .filter(item -> "0".equals(item.getIsDisp()))
          .collect(Collectors.toList());

      // 削除した検査項目についての更新は行わないようにする
      // 検査項目が削除済の場合は更新後の検査結果にマージして更新処理を行う
      for (PatExamMainForOneOrder delItem : delExamMainOneOrder) {

        boolean haveDelItem = false;

        for (PatExamMainExamResultInfo examResult : examResulList) {
          // 検査項目が削除済の場合は更新用のデータを削除済データで上書き
          if (examResult.getItem_cd().equals(delItem.getItemCd())) {
            setDeletedExamResult(delItem, examResult);
            haveDelItem = true;
            break;
          }
        }

        // 更新用のデータに削除済データが含まれていない場合は削除済データをマージ
        if (!haveDelItem) {
          PatExamMainExamResultInfo mergeExamResult = new PatExamMainExamResultInfo();
          setDeletedExamResult(delItem, mergeExamResult);
          examResulList.add(mergeExamResult);
        }
      }

      // mod #7035-検査結果の値がない項目も画面に表示される（exam_rst連携で受信した検査結果（空値）の項目） 徐博 start
      // List<PatExamMainExamResultInfo> filterExamResulList = examResulList.stream().filter(item -> {
      //   return !"NaN".equals(item.getResult());
      // }).collect(Collectors.toList());
      String valueToString = JSONObject.valueToString(examResulList);
      // String valueToString = JSONObject.valueToString(filterExamResulList);
      // mod #7035-検査結果の値がない項目も画面に表示される（exam_rst連携で受信した検査結果（空値）の項目） 徐博 end
      int updateCount = patExamMainDao.updatePatExamMainOneOrder(examMainCd, valueToString, upStaff, examDate, regOrderClass);

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      if(updateCount == 0){
        //update対象が0件だった場合はエラー処理
        throw new Exception();
      }
    } catch (Exception e) {
      throw new Exception(e);
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<OrdMainForExamRecord> selectOrdMainStartDatesList(Long patId,String facilityCd){
    List<OrdMainForExamRecord> ordMainForExamRecord = OrdMainDao.selectRstStartDateByPatId(patId,facilityCd);
    return ordMainForExamRecord;
  }


  /**
   * {@inheritDoc}
   */
  @Override
  @Transactional(TransactionManagerName.ALL)
  public ExamResultFileCaptureResponse examResultFileCapture(Long userId, String facilityCd, List<examResultFileCaptureRequest> request) {

    // mod 9361 検査結果で一括取込を行うと取込失敗となる 関 start
    //add 検査結果：検査結果一括登録、結果不正 修正 20230704 ztc start
    // Timestamp currentTime = new Timestamp(System.currentTimeMillis());
    //add 検査結果：検査結果一括登録、結果不正 修正 20230704 ztc end
    // mod 9361 検査結果で一括取込を行うと取込失敗となる 関 end
    int cntSuccess = 0;
    List<Integer> lstSkipRecNo = new ArrayList<Integer>();
    List<Long> examMainCdList = new ArrayList<Long>();
    // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc start
    Map<Long,Long> examMainCdPatIdMap = new HashMap<>();
    // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc end

    // 施設設定マスタから 検査結果取込 項目コード出力先設定機能 の設定値を取得
    String resSelectInHospCd = facilitySettingService.getFacilitySettingValue(
      facilityCd,
      FacilitySettingNo.SELECT_INHOSPITAL_CD
    );

    // 施設設定マスタから 検査結果取込 項目コード出力先設定機能 の設定値を取得
    String patSexNon = facilitySettingService.getFacilitySettingValue(
      facilityCd,
      FacilitySettingNo.PAT_SEX_NON
    );

    // 検査項目一覧をDBから取得
    List<MstExamItem> lstExamItem = mstExamItemDao.selectByFacilityCd(facilityCd);
    // 連携コードの一覧リストを作成する(1～3は施設設定マスタで設定する)
    List<String> lstExamItemInHospCd = lstExamItem.stream()
        .map(e -> getAnyInHospitalCd(e, resSelectInHospCd))
        .collect(Collectors.toList());

    // ファイルから取り込みしたデータを検査日時の昇順ソートする
    Comparator<examResultFileCaptureRequest> comparator =  Comparator.comparing(examResultFileCaptureRequest::getExamDate).thenComparing(examResultFileCaptureRequest::getExamTime);
    List<examResultFileCaptureRequest> requestSorted = request.stream().sorted(comparator).collect(Collectors.toList());

    for(int idx = 0; idx < request.size(); idx++)
    {
      examResultFileCaptureRequest rec = requestSorted.get(idx);
      if (validateExamResult(facilityCd, rec, lstExamItemInHospCd)) {
        // バリデーションチェックOK→登録処理へ
        // 既存の検査結果データが存在するかチェック
        // mod 9361 検査結果で一括取込を行うと取込失敗となる 関 start
        //upd 検査結果：検査結果一括登録、結果不正 修正 20230704 ztc start
//        List<PatExamMain> lstPatExamResult = patExamMainDao.selectPatExamMainByPatIdExamdateOrderclass(rec.getPatId(), rec.getExamDateTime(), new Timestamp(rec.getExamDateTime().getTime() + 60000), rec.getOrderClass());
        // List<PatExamMain> lstPatExamResult = patExamMainDao.selectPatExamMainByPatIdExamdateOrderclass(rec.getPatId(), rec.getExamDateTime(), currentTime, rec.getOrderClass());
        //upd 検査結果：検査結果一括登録、結果不正 修正 20230704 ztc end
        List<PatExamMain> lstPatExamResult = patExamMainDao.selectPatExamMainByPatIdExamdateOrderclass(rec.getPatId(), rec.getExamDateTime(), new Timestamp(rec.getExamDateTime().getTime() + 60000), rec.getOrderClass());
        // mod 9361 検査結果で一括取込を行うと取込失敗となる 関 end

        // 更新時刻
        Timestamp upDt = new Timestamp(System.currentTimeMillis());
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");
        SimpleDateFormat sdf2 = new SimpleDateFormat("yyyy/MM/dd HH:mm");
        SimpleDateFormat sdfDay = new SimpleDateFormat("yyyyMMdd");

        // 検査結果日時(JSON等の更新用)
        String resultExamDate = sdf2.format(rec.getExamDateTime()) + ":00";

        Date dtRegExamDate = null;
        // 登録日時
        try {
          dtRegExamDate = sdfDay.parse(rec.getExamDate());
          sdfDay.applyPattern("yyyy/MM/dd");
        } catch (ParseException e1) {
        }
        String regExamDate = sdfDay.format(dtRegExamDate);

        // フラグ
        Boolean isExistOrder = false;


        PatExamMain existOrderData = selectExistOrder(rec.getPatId(), rec.getOrderClass(), regExamDate, null);

        if (existOrderData != null) {
          // 検査依頼との紐づけ登録
          isExistOrder = true;
        }

        if ((lstPatExamResult != null && lstPatExamResult.size() > 0) || isExistOrder == true) {
          // 検査結果ありor紐付け登録あり→更新

          // 更新対象のレコード情報
          // マージか紐付け登録かで異なる
          PatExamMain targetRec = isExistOrder == true ? existOrderData : lstPatExamResult.get(0);

          // 検査結果情報の取得・更新
          try {
            List<PatExamMainExamResultInfo> examResultInfo = targetRec.getExamResultInfo() == null || targetRec.getExamResultInfo().isEmpty() ? new ArrayList<>()
                : new ObjectMapper().readValue(targetRec.getExamResultInfo(), new TypeReference<List<PatExamMainExamResultInfo>>() {});

            // ファイル行内の検査結果を処理していく
            for (int index = 1; index <= 5; index++) {
              // 検査結果有無を判定する関数
              Method isExistExamMethod = rec.getClass().getMethod("isExistExam" + index);
              boolean isExistExam = (boolean) isExistExamMethod.invoke(rec);
              if (isExistExam) {
                // 検査結果ありの場合は取り込み処理実施

                // 検査項目IDを取得する関数
                Method getExamItemCdMethod = rec.getClass().getMethod("getExamItemCd" + index);
                String examItemCd = (String) getExamItemCdMethod.invoke(rec);
                // 検査結果を取得する関数
                Method getExamResultMethod = rec.getClass().getMethod("getExamResult" + index);
                String examResult = (String) getExamResultMethod.invoke(rec);
                // 検査値形態を取得する関数
                Method getExamCheckMethod = rec.getClass().getMethod("getExamCheck" + index);
                String examCheck = (String) getExamCheckMethod.invoke(rec);
                // 検査コメントを取得する関数
                Method getExamComment1Method = rec.getClass().getMethod("getExamComment1_" + index);
                String examComment1 = (String) getExamComment1Method.invoke(rec);
                Method getExamComment2Method = rec.getClass().getMethod("getExamComment2_" + index);
                String examComment2 = (String) getExamComment2Method.invoke(rec);

                Optional<MstExamItem> examItem = lstExamItem.stream().filter(e->examItemCd.trim().equals(getAnyInHospitalCd(e, resSelectInHospCd))).findFirst();

                if (examResultInfo.stream().anyMatch(e->e.getItem_cd().equals(examItem.get().getExamItemCd().toString())))
                {
                  // 同一のexam_item_cdが設定された検査結果あり → 検査結果を上書き
                  for (int idx2 = 0; idx2 < examResultInfo.size(); idx2++) {
                    if ( examResultInfo.get(idx2).getItem_cd().equals(examItem.get().getExamItemCd().toString())) {
                      PatExamMainExamResultInfo upTarget = examResultInfo.get(idx2);
                      // 取り込みファイルの内容で書き換え
                      upTarget.setResult(binaryToAscii(examResult));
                      upTarget.setHl(chgResultCheck(examCheck.trim()));
                      upTarget.setCom_cd(binaryToAscii(examComment1) + binaryToAscii(examComment2));
                      // フリーコメント
                      upTarget.setFreememo(examResultInfo.get(idx2).getFreememo());
                      // 更新日時
                      upTarget.setResult_date(resultExamDate);

                      examResultInfo.set(idx2, upTarget);
                    }
                  }
                } else {
                  // 同一のexam_item_cdが設定された検査結果なし → 検査結果を追加する
                  PatExamMainExamResultInfo exam = new PatExamMainExamResultInfo() {
                    {
                      setItem_cd(examItem.get().getExamItemCd().toString());
                      setItem_name(examItem.get().getExamItemName());
                      setResult(binaryToAscii(examResult));
                      setHl(chgResultCheck(examCheck.trim()));
                      setCom_cd(binaryToAscii(examComment1) + binaryToAscii(examComment2));
                      setFreememo("");
                      setResult_date(sdf.format(rec.getExamDateTime()));
                      setUnit(examItem.get().getUnit());
                      // mod FNSI-NO504-冗長なjsonデータを削除する 関 start
                      // setType(examItem.get().getDataType());
                      setExam_class(examItem.get().getExamClass());
                      // setUpper(getNormalValue(examItem.get(), rec.getPatSex(), patSexNon, true));
                      // setLower(getNormalValue(examItem.get(), rec.getPatSex(), patSexNon, false));
                      // mod FNSI-NO504-冗長なjsonデータを削除する 関 end
//                      setJlac10_cd(examItem.get().getJlac10Cd());
                    }
                  };
                  examResultInfo.add(exam);
                }
              }
            }

            // DB更新用の文字列に変換
            StringBuilder sbExamResultInfo = new StringBuilder();
            examResultInfo.stream()
              .forEach(e-> sbExamResultInfo.append("," + e.getValue()));
            // 文字列の前後に"["と"]"を付け加える
            sbExamResultInfo.delete(0, 1);
            sbExamResultInfo.insert(0, "[");
            sbExamResultInfo.append("]");

            targetRec.setExamResultInfo(sbExamResultInfo.toString());
          } catch (Exception e) {
            // DBから直接取得するため特に何もしない
          }
          // その他情報の更新
          targetRec.setExamStatus("1");
          targetRec.setDataGenClass("1");
          targetRec.setUpDate(upDt);
          targetRec.setUpStaff(userId);
          if (isExistOrder == true) {
            try {
              targetRec.setResultExamDate(new Timestamp(sdf.parse(resultExamDate).getTime()));
            } catch (ParseException e1) {
            }
            // mod 9361 検査結果で一括取込を行うと取込失敗となる 関 start
            //add 検査結果：検査結果一括登録、結果不正 修正 20230704 ztc start
          // }else {
           // targetRec.setResultExamDate(targetRec.getRegExamDate());
            //add 検査結果：検査結果一括登録、結果不正 修正 20230704 ztc end
            // mod 9361 検査結果で一括取込を行うと取込失敗となる 関 end
          }

          // DB更新
          patExamMainDao.updateResultExamSetInfo(targetRec);
          examMainCdList.add(targetRec.getExamMainCd());
          // mod 9361 検査結果で一括取込を行うと取込失敗となる 関 start
          //upd 検査結果：検査結果一括登録、結果不正 修正 20230704 ztc start
          // cntSuccess += 1;
         } else {
          // stSkipRecNo.add(idx+1);
          //upd 検査結果：検査結果一括登録、結果不正 修正 20230704 ztc end
          // mod 9361 検査結果で一括取込を行うと取込失敗となる 関 end
        // }
        // mod 9361 検査結果で一括取込を行うと取込失敗となる 関 start
        //del 検査結果：検査結果一括登録、結果不正 修正 20230704 ztc start
        // else {
          // 検査結果なし→新規登録

          // 検査結果情報文字列
          StringBuilder sbExamResult = new StringBuilder();

          // ファイル行内の検査結果を処理していく
          for (int index = 1; index <= 5; index++) {
            try {
              // 検査結果情報の１データ分のクラスを順次作成→文字列に変換する
              // 検査結果有無を判定する関数
              Method isExistExamMethod = rec.getClass().getMethod("isExistExam" + index);
              boolean isExistExam = (boolean) isExistExamMethod.invoke(rec);
              if (isExistExam) {
                // 検査結果ありの場合は取り込み処理実施

                // 検査項目IDを取得する関数
                Method getExamItemCdMethod = rec.getClass().getMethod("getExamItemCd" + index);
                String examItemCd = (String) getExamItemCdMethod.invoke(rec);
                // 検査結果を取得する関数
                Method getExamResultMethod = rec.getClass().getMethod("getExamResult" + index);
                String examResult = (String) getExamResultMethod.invoke(rec);
                // 検査値形態を取得する関数
                Method getExamCheckMethod = rec.getClass().getMethod("getExamCheck" + index);
                String examCheck = (String) getExamCheckMethod.invoke(rec);
                // 検査コメントを取得する関数
                Method getExamComment1Method = rec.getClass().getMethod("getExamComment1_" + index);
                String examComment1 = (String) getExamComment1Method.invoke(rec);
                Method getExamComment2Method = rec.getClass().getMethod("getExamComment2_" + index);
                String examComment2 = (String) getExamComment2Method.invoke(rec);

                Optional<MstExamItem> examItem = lstExamItem.stream().filter(e->examItemCd.trim().equals(getAnyInHospitalCd(e, resSelectInHospCd))).findFirst();

                PatExamMainExamResultInfo exam = new PatExamMainExamResultInfo() {
                  {
                    setItem_cd(examItem.get().getExamItemCd().toString());
                    setItem_name(examItem.get().getExamItemName());
                    setResult(binaryToAscii(examResult));
                    setHl(chgResultCheck(examCheck.trim()));
                    setCom_cd(binaryToAscii(examComment1) + binaryToAscii(examComment2));
                    setFreememo("");
                    setResult_date(sdf.format(rec.getExamDateTime()));
                    setUnit(examItem.get().getUnit());
                    // mod FNSI-NO504-冗長なjsonデータを削除する 関 start
                    // setType(examItem.get().getDataType());
                    setExam_class(examItem.get().getExamClass());
                    // setUpper(getNormalValue(examItem.get(), rec.getPatSex(), patSexNon, true));
                    // setLower(getNormalValue(examItem.get(), rec.getPatSex(), patSexNon, false));
                    // mod FNSI-NO504-冗長なjsonデータを削除する 関 end
//                    setJlac10_cd(examItem.get().getJlac10Cd());
                  }
                };
                if (sbExamResult.length() != 0) {
                  sbExamResult.append(", ");
                }
                sbExamResult.append(exam.getValue());
              }
            } catch (Exception e) {
              // 例外発生時は次の処理結果取得へ
            }
          }

          // 文字列の前後に"["と"]"を付け加える
          sbExamResult.insert(0, "[");
          sbExamResult.append("]");

          PatExamMain patExamMain = new PatExamMain()
          {
            {
              setPatId(rec.getPatId());
              setFacilityCd(facilityCd);
              setRegExamDate(rec.getExamDateTime());
              setRegOrderClass(rec.getOrderClass());
              setExamStatus("1");
              setOrderExamSetInfo("[]");
              setExamOrderInfo("[]");
              setOrderLabelInfo("[]");
              setDataGenClass("1");
              setResultExamDate(rec.getExamDateTime());
              setExamResultInfo(sbExamResult.toString());
              setRegDate(upDt);
              setRegStaff(userId);
              setUpDate(upDt);
              setUpStaff(userId);
              setIsDel("0");
              setIsOrder("0");
            }
          };
          // DB追加
          patExamMainDao.insertOrderExamSetInfo(patExamMain);
          examMainCdList.add(patExamMain.getExamMainCd());
          // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc start
          examMainCdPatIdMap.put(patExamMain.getExamMainCd(),rec.getPatId());
          // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc end
        }

        cntSuccess += 1;
        //del 検査結果：検査結果一括登録、結果不正 修正 20230704 ztc end
        // mod 9361 検査結果で一括取込を行うと取込失敗となる 関 end
      } else {
        // バリデーションチェックNG→スキップ
        lstSkipRecNo.add(idx+1);
      }
    }
    // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc start
    return new ExamResultFileCaptureResponse(lstSkipRecNo, cntSuccess, examMainCdList, examMainCdPatIdMap);
    // add #9811 装置設定>操作範囲>ヘマトクリットと総タンパクの検査値が不正 修正 20231113 ztc end
  }

  /**
   * 取り込んだ検査結果ファイルのデータチェック処理
   * @param 検査結果ファイルの1レコード
   * @return true(チェックOK)、false(チェックNG)
   */
  private boolean validateExamResult(String facilityCd, examResultFileCaptureRequest rec, List<String> listExamItemInHospCd) {
    boolean ret = true;
    //　レコード区分("A1"固定)
    if (! rec.getRecordKbn().equals("A1")) {
      return false;
    }

    //　採取日 + 採取時刻(日付の形式チェック)
    try {
      DateFormat formatDate = new SimpleDateFormat("yyyyMMddHHmm");

      formatDate.setLenient(false);
      formatDate.parse(rec.getExamDate() + rec.getExamTime());
      rec.setExamDateTime(new Timestamp(new SimpleDateFormat("yyyyMMdd HHmm").parse(rec.getExamDate() + " " + rec.getExamTime()).getTime()));
    }catch(ParseException e){
      return false;
    }

    // 透析前後("0","1","2"以外はエラー)
    switch (rec.getOrderClass()) {
    case "0":
    case "1":
    case "2":
      break;
    default:
      return false;
    }
    // 患者ID(存在チェック)
    // add FNSI-終了およびその結果を通知機能で教える 江 start
    String hospPatId =rec.getHospPatId();
    // 施設コードを元に施設設定データ(Mst/Sys)を取得:全項目ケースのためfacilitySettingNoは3003セット
    List<FacilitySettingInfo> settingInfoList = mstFacilitySettingDao.selectFacilitySetting(facilityCd,FacilitySettingNo.CHECK_RESULT_FOR_FACILITY);
    for(FacilitySettingInfo settingInfo : settingInfoList){
      if (settingInfo.getValue().equals("1")) {
        hospPatId = String.valueOf(Long.parseLong(rec.getHospPatId().replaceAll("^[  ]+", "")));
      }
      if (settingInfo.getValue().equals("2")) {
        hospPatId = rec.getHospPatId().replaceAll("^[  ]+", "");
      }
    }
    // add FNSI-終了およびその結果を通知機能で教える 江 end
    // mod FNSI-終了およびその結果を通知機能で教える 江 start
    //PatPersonalMain patInfo = patPersonalMainDao.selectPatInfoByHospPatId(facilityCd, rec.getHospPatId().trim());
    PatPersonalMain patInfo = patPersonalMainDao.selectPatInfoByHospPatId(facilityCd, hospPatId);
    // mod FNSI-終了およびその結果を通知機能で教える 江 end
    if ( patInfo == null || patInfo.getPat_id() == null) {
      // 患者が存在しない or 削除済み
      return false;
    } else {
      if(patInfo.getDie_date() == null || rec.getExamDateTime().compareTo(patInfo.getDie_date()) < 0) {
        // patIdが取得できた場合はここでセットする
        rec.setPatId(patInfo.getPat_id());
        rec.setPatSex(patInfo.getPat_sex());
      } else {
        // 検査日以前に患者が死亡している場合
        return false;
      }
    }

    // 検査結果有無フラグ
    boolean isExistExamResult = false;

    // 検査結果情報１～５
    if (rec.getExamItemCd1() != null && ! rec.getExamItemCd1().replace(" ", "").isEmpty()) {
      if (listExamItemInHospCd.contains(rec.getExamItemCd1().trim())) {
        rec.setExistExam1(true);
        isExistExamResult = true;
      }
    }
    if (rec.getExamItemCd2() != null && ! rec.getExamItemCd2().replace(" ", "").isEmpty()) {
      if (listExamItemInHospCd.contains(rec.getExamItemCd2().trim())) {
        rec.setExistExam2(true);
        isExistExamResult = true;
      }
    }
    if (rec.getExamItemCd3() != null && ! rec.getExamItemCd3().replace(" ", "").isEmpty()) {
      if (listExamItemInHospCd.contains(rec.getExamItemCd3().trim())) {
        rec.setExistExam3(true);
        isExistExamResult = true;
      }
    }
    if (rec.getExamItemCd4() != null && ! rec.getExamItemCd4().replace(" ", "").isEmpty()) {
      if (listExamItemInHospCd.contains(rec.getExamItemCd4().trim())) {
        rec.setExistExam4(true);
        isExistExamResult = true;
      }
    }
    if (rec.getExamItemCd5() != null && ! rec.getExamItemCd5().replace(" ", "").isEmpty()) {
      if (listExamItemInHospCd.contains(rec.getExamItemCd5().trim())) {
        rec.setExistExam5(true);
        isExistExamResult = true;
      }
    }

    // 検査結果有無確認(検査結果が1行もないレコード(スペース埋めだったとき)はスキップ対象)
    if (! isExistExamResult){
      return false;
    }

    return ret;
  }

  /**
   * 検査値形態の変換用メソッド
   * @param strResChk 変換前（ファイル記載内容)文字列
   * @return 変換後文字列
   */
  private String chgResultCheck(String strResChk) {
    String ret = "";

    switch (strResChk){
      case "L":
        ret = "未満";
        break;
      case "E":
        ret = "以下";
        break;
      case "U":
        ret = "以上";
        break;
      case "O":
        ret = "超過";
        break;
      case "B":
        ret = "結果なし";
        break;
      default:
        break;
    }

    return ret;
  }

  /**
   * 正常値の値を取得する
   */
  private String getNormalValue(MstExamItem examItem, Integer patSex, String patSexNon, boolean isUpper) {
    if (examItem.getNormalValueClass().equals("0")) {
      // 共通設定を使用
      if (isUpper) {
        return chgNormalValueStr(examItem.getNormalValueUpper());
      } else {
        return chgNormalValueStr(examItem.getNormalValueLower());
      }
    } else {
      // 男女別設定を使用
      if (patSex.equals(1)) {
        // 性別：男性
        if (isUpper) {
          return chgNormalValueStr(examItem.getNormalValueUpperM());
        } else {
          return chgNormalValueStr(examItem.getNormalValueLowerM());
        }
      } else if (patSex.equals(2)) {
        // 性別：女性
        if (isUpper) {
          return chgNormalValueStr(examItem.getNormalValueUpperW());
        } else {
          return chgNormalValueStr(examItem.getNormalValueLowerW());
        }
      } else {
        // 性別：不明
        if (patSexNon.equals("1")) {
          // 男性数値使用
          if (isUpper) {
            return chgNormalValueStr(examItem.getNormalValueUpperM());
          } else {
            return chgNormalValueStr(examItem.getNormalValueLowerM());
          }
        } else {
          // 女性数値使用
          if (isUpper) {
            return chgNormalValueStr(examItem.getNormalValueUpperW());
          } else {
            return chgNormalValueStr(examItem.getNormalValueLowerW());
          }
        }
      }
    }
  }

  /**
   * 正常値の値(BigDecimal)をString型に変換
   */
  private String chgNormalValueStr(BigDecimal input) {
    if (input == null) {
      return "";
    } else {
      return input.stripTrailingZeros().toPlainString();
    }
  }

  /**
   * 連携コード1,2,3のいずれかを取得する。
   *
   * @param mstExamItem 検査項目データ
   * @param selectInHospCd 取得対象の連携コード(1,2,3)
   * @return 検査項目データから取得した連携コード
   */
  private String getAnyInHospitalCd(MstExamItem mstExamItem, String selectInHospCd) {
    String rtn = "";
    switch (selectInHospCd) {
      case "1":
        rtn = mstExamItem.getInHospitalCd1();
        break;
      case "2":
        rtn = mstExamItem.getInHospitalCd2();
        break;
      case "3":
        rtn = mstExamItem.getInHospitalCd3();
        break;
      default:
        rtn = mstExamItem.getInHospitalCd1();
        break;
    }
    return rtn;
  }

  /**
   * 引数の文字列(Base64)を、Shift_JISにエンコードする。
   *
   * @param value 変換対象の文字列
   * @return エンコードされた文字列
   */
  public static String binaryToAscii(String value) {
    byte[] bytes = Base64.getDecoder().decode(value.getBytes());
    try {
      String result = new String(bytes, "SJIS");
      return result.trim();
    } catch (UnsupportedEncodingException e) {
      return value;
    }
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstExamSet> selectExamSetList(String facilityCd) {
    List<MstExamSet> mstFacilityList = mstExamSetDao.selectExamSetList(facilityCd, false, true);
    return mstFacilityList;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public PatExamMain selectExistResult(Long patId, String regOrderClass, String resultExamDate, Long exclExamMainCd) {
    return patExamMainDao.selectExistResult(patId, regOrderClass, resultExamDate, exclExamMainCd);
  }

  // add #9273 施設設定マスタのNo105の設定どおり動かない。 start
  /**
   * {@inheritDoc}
   */
  @Override
  public List<PatExamMain> selectExistResultByPatId(Long patId, String startDate) {
    return patExamMainDao.selectExistResultByPatId(patId, startDate);
  }
  // add #9273 施設設定マスタのNo105の設定どおり動かない。 end

  /**
   * {@inheritDoc}
   */
  @Override
  public PatExamMain selectExistOrder(Long patId, String regOrderClass, String regExamDate, Long exclExamMainCd) {
    return patExamMainDao.selectExistOrder(patId, regOrderClass, regExamDate, exclExamMainCd);
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public PatExamMain selectPatExamMainByExamMainCd(Long examMainCd) {
    return patExamMainDao.selectPatExamMainByExamMainCd(examMainCd);
  }

  /**
   * {@inheritDoc}
   * @throws Exception
   */
  @Override
  public void clearExamResultInfo(Long examMainCd) throws Exception {
    try {

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "pat_exam_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" exam_main_cd = " + examMainCd + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(patExamMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      int updateCount = patExamMainDao.updateForClearExamResultInfo(examMainCd);

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      if(updateCount == 0){
        //update対象が0件だった場合はエラー処理
        throw new Exception();
      }
    } catch (Exception e) {
      throw new Exception(e);
    }
  }

  /**
   * {@inheritDoc}
   * @throws Exception
   */
  @Override
  public void deletePatExamMain(Long examMainCd) throws Exception {
    try {
      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "pat_exam_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" exam_main_cd = " + examMainCd + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(patExamMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      int updateCount = patExamMainDao.updateIsDelOneOrder(examMainCd);

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updateCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      if(updateCount == 0){
        //update対象が0件だった場合はエラー処理
        throw new Exception();
      }
    } catch (Exception e) {
      throw new Exception(e);
    }
  }


  /**
   * {@inheritDoc}
   * @throws Exception
   */
  @Override
  @Transactional(rollbackFor=Exception.class)
  public void deleteExamMainForOneOrder(Long examMainCd, Long upStaff, String checkDate) throws Exception{
    String isOrder = null;
    //1.現時点の最新テーブル情報を取得
    //1.1.:エラー時：NoResultException→EmptyResultDataAccessExceptionがthrowされる
    //mod FNSI-検査結果を削除する場合は、一般撮影監査依頼の状態を変更する 劉全航 start
    //isOrder = patExamMainDao.selectIsOrderByExamMainCd(examMainCd, checkDate);
    PatExamMain patExamMain = patExamMainDao.selectIsOrderByExamMainCd(examMainCd, checkDate);
    isOrder = patExamMain.getIsOrder();
    //mod FNSI-検査結果を削除する場合は、一般撮影監査依頼の状態を変更する 劉全航 end
    //2.論理削除実行
    if(FlagType.FLAG_ON.equals(isOrder)){
      //2-1.[is_order]が1:の場合
      //2-1-1.現データをコピーした履歴データをINSERT(削除フラグ立て済) :結果0件でエラー
      int insCount = patExamMainDao.insertIsDelResult(examMainCd, upStaff);
      if(insCount == 0){
        throw new Exception("deleteExamMainForOneOrder:insertDelResultError 0");
      }

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "pat_exam_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" exam_main_cd = " + examMainCd + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(patExamMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      // 予定＋結果、同日同検査区分結果のみが存在時に予定＋結果の結果削除時に予定と同日同検査区分結果のみを結合する。
      int updCount = 0;
      // 同日同検査区分結果のみを取得
      PatExamMain mergeTarget = patExamMainDao.selectOneExistResult(
          patExamMain.getPatId(), patExamMain.getFacilityCd(), patExamMain.getRegExamDate(), patExamMain.getRegOrderClass());
      if (mergeTarget != null) {
        // 同日同検査区分結果が存在する場合は予定にマージする
        SimpleDateFormat examDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        updCount = patExamMainDao.updatePatExamMainOneOrder(
            examMainCd,
            mergeTarget.getExamResultInfo(),
            upStaff,
            examDateFormat.format(mergeTarget.getResultExamDate()),
            patExamMain.getRegOrderClass());


        // DB論理削除ログ出力
        StringBuffer wheresDel = new StringBuffer("");
        wheresDel.append(" WHERE\n");
        wheresDel.append(" exam_main_cd = " + mergeTarget.getExamMainCd() + "\n");
        DataUpdateLogCommonNew logCommonDel = getLogCommon(patExamMainDao, tableName, wheres, getEventLogMessage());
        boolean setResultDel = logCommonDel.setInfo();
        // マージ元のレコードは論理削除
        int delCount = patExamMainDao.updateIsDelByExamMainCd(mergeTarget.getExamMainCd(), upStaff);
        if (setResultDel && delCount > 0) {
          logCommonDel.updateLog();
        }

        if(delCount == 0){
          throw new Exception("deleteExamMainForOneOrder:updateIsDelByExamMainCd(isOrder=1) 0");
        }

      } else {
        // 同日同検査区分結果が存在しない場合は結果部分を消す
        updCount = patExamMainDao.updateResultDel(examMainCd, upStaff);
      }

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && updCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      if(updCount == 0){
        throw new Exception("deleteExamMainForOneOrder:updateResultDel 0");
      }
    }else if(FlagType.FLAG_OFF.equals(isOrder)){

      // DB更新ログ出力ロジック wangzuo Start
      String tableName = "pat_exam_main";
      // SQL検索条件
      StringBuffer wheres = new StringBuffer("");
      wheres.append(" WHERE\n");
      wheres.append(" exam_main_cd = " + examMainCd + "\n");
      // logCommon設定
      DataUpdateLogCommonNew logCommon = getLogCommon(patExamMainDao, tableName, wheres, getEventLogMessage());
      // ログ出力カラム情報及び更新前データ情報取得
      boolean setResult = logCommon.setInfo();
      // DB更新ログ出力ロジック wangzuo End

      //2-2.[is_order]が0:の場合
      //2-2-1.現データの削除フラグを立てる:結果0件でエラー
      int delCount = patExamMainDao.updateIsDelByExamMainCd(examMainCd, upStaff);

      // DB更新ログ出力ロジック wangzuo Start
      // 更新後データ取得、差分あれば、log出力
      if (setResult && delCount > 0) {
        logCommon.updateLog();
      }
      // DB更新ログ出力ロジック wangzuo End

      if(delCount == 0){
        throw new Exception("deleteExamMainForOneOrder:updateIsDelByExamMainCd 0");
      }

    }else{
      //テーブル情報[is_order]が1-検査依頼あり/0-検査依頼無し以外の値を持っている場合
      //→データ想定外エラー返却でロールバック
      throw new Exception("deleteExamMainForOneOrder:isOrder is Unexpected value");
    }
  }
  @Autowired
  PatInfoService patInfoService;
  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;
  @Override
  public void registerNotification(Long patId, String facilityCd) throws Exception {
    Map<String, String> patInfo = patInfoService.selectById(patId , facilityCd);
    ObjectMapper mapper = new ObjectMapper();
    PatPersonalMain patPersonalMain = mapper.readValue(patInfo.get("pat_personal_main"), PatPersonalMain.class);
    JSONObject replaceData = new JSONObject();
    replaceData.put("PATID", String.valueOf(patId));
    replaceData.put("LASTNAME", patPersonalMain.getPat_last_name());
    replaceData.put("FIRSTNAME", patPersonalMain.getPat_first_name());
    webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.EXAM_RECORD, facilityCd, replaceData);
  }

  // add FNSI-終了およびその結果を通知機能で教える 江 start
  @Override
  public void registerNotificationForReadFiles(String facilityCd,String successfulCount,String failedCount) throws Exception {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    JSONObject replaceData = new JSONObject();
    replaceData.put("FACILITYCD", facilityCd);
    replaceData.put("SUCCESSFULCOUNT", successfulCount);
    replaceData.put("FAILEDCOUNT", failedCount);
    replaceData.put("UP_DATE", sdf.format(new Date()));
    webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.EXAM_RECORD_ReadFile, facilityCd, replaceData);
  }
  // add FNSI-終了およびその結果を通知機能で教える 江 end

  // DB更新ログ出力ロジック wangzuo Start
  /**
   * ログ情報設定
   *
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    if (user != null) {
      // 利用者ID
      eventLogMessage.setUserId(user.getUserId().toString());
      // 施設コード
      eventLogMessage.setFacilityCd(user.getFacilityCd());
      // 接続先IPアドレス
      eventLogMessage.setClientIp(user.getClientIpAddress());
      // セッションID
      eventLogMessage.setSessionId(user.getSessionId());
    }
    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
    return eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(Object dao, String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(Config.get(dao));
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }
  // DB更新ログ出力ロジック wangzuo End

  //  add マスタ削除対応 張 start
  @Override
  public List<Long> selectExamItemListForFacilityCd(String facilityCd) {
    return mstExamItemDao.selectExamItemListForFacilityCd(facilityCd);
  }
  //  add マスタ削除対応 張 end

  //mod FNSI-6842 劉全航 start
  @Override
  public List<PatExamMainData> selectPatExamRequestByRegExamDateAndRegOrderClass(String facilityCd, Long patId, String startDate, String endDate, List<String> regOrderClass, List<Integer> weeksArry) {
    return patExamMainDao.selectPatExamRequestByRegExamDateAndRegOrderClass(facilityCd, patId, startDate, endDate, regOrderClass, weeksArry);
  }
  //mod FNSI-6842 劉全航 end

  /**
   * 更新用の検査結果に削除済の検査項目の検査結果を設定する
   *
   * @param delItem 検査結果※検査項目マスタ削除済
   * @param examResult 更新用の検査結果
   */
  private void setDeletedExamResult(PatExamMainForOneOrder delItem, PatExamMainExamResultInfo examResult) {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd HH:mm:ss");

    examResult.setItem_cd(delItem.getItemCd());
    examResult.setDisp_order(delItem.getDispOrder());
    examResult.setResult(delItem.getResult());
    examResult.setHl(delItem.getHl());
    examResult.setCom_cd(delItem.getComCd());
    examResult.setFreememo(delItem.getFreememo());
    examResult.setResult_date(sdf.format(delItem.getResultExamDate()));
    examResult.setItem_name(delItem.getItemName());
    examResult.setType(delItem.getType());
    examResult.setUnit(delItem.getUnit());
    examResult.setUpper(delItem.getUpper());
    examResult.setLower(delItem.getLower());
    examResult.setExam_class(delItem.getExamClass());
    examResult.setJlac10_cd(delItem.getJlac10Cd());
  }
}
