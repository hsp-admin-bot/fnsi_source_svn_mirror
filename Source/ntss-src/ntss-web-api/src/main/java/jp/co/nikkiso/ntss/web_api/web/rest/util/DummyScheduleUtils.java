package jp.co.nikkiso.ntss.web_api.web.rest.util;

import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map.Entry;
import java.util.stream.Collectors;

import org.json.JSONObject;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.web_api.service.LogService;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdScheduleDao;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdSchedule;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import lombok.Getter;
import lombok.Setter;
import org.springframework.util.StringUtils;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
@Component
/** ダミースケジュール操作ユーティリティクラス */
public class DummyScheduleUtils
{
    @Autowired
    private MstKurDao mstKurDao;
    @Autowired
    private OrdMainDao ordMainDao;
    @Autowired
    private OrdScheduleDao ordScheduleDao;
    @Autowired
    private LogService logService;
    /** ダミースケジュール情報を格納するクラス */
    @Getter
    @Setter
    private class DummyScheduleInfo
    {
      /**
       * 施設コード
       */
      private String facilityCd;

      /**
       * 治療日
       */
      private String treatDate;

      /**
       * 治療曜日
       */
      private Short treatWeek;

      /**
       * クールコード
       */
      private Long kurCd;

      /**
       * 治療日時(治療日+クール内標準治療開始時刻)
       */
      private String treatDatetime;

      /**
       * 患者ID
       */
      private Long patId;

      /**
       * ベッドコード
       */
      private Long bedCd;

      /**
       * ダミーフラグ(true:ダミースケジュール、false:メインスケジュール)
       */
      private Boolean isDummy;
    }

    /** クールマスタの拡張情報を格納するクラス */
    @Getter
    @Setter
    private static class MstKurEx extends MstKur {
      /**
       * 最初のクールフラグ(true:最初のクール、false:最後のクール以外)
       */
      private Boolean isFirstKur;

      private static MstKurEx parse(MstKur base) {
        MstKurEx ret = new MstKurEx();
        ret.setKurCd(base.getKurCd());
        ret.setKurStandardStartTime(base.getKurStandardStartTime());
        ret.setKurStartTime(base.getKurStartTime());
        ret.setKurEndTime(base.getKurEndTime());
        ret.setIsFirstKur(false);
        return ret;
      }
    }

    /** 処理モード */
    public enum PROC_MODE
    {
        /** 処理モード(登録) */
        CREATE("1"),
        /** 処理モード(削除) */
        DELETE("2"),
        /** 処理モード(削除+作成) */
        DELETE_AND_CREATE("3");

        /** コンストラクタ */
        private PROC_MODE(final String procModeVal) {
          this.procModeVal = procModeVal;
        }

        /** 処理モード値 */
        private final String procModeVal;
        private String getProcModeVal() {
          return this.procModeVal;
        }

        /** 処理モード(処理モード値)含有チェック */
        public static boolean isHas(String procModeVal) {
          for (PROC_MODE mode : PROC_MODE.values()) {
            if (true == mode.getProcModeVal().equals(procModeVal)) {
              return true;
            }
          }
          return false;
        }

        /** 処理モードオブジェクト取得(引数の処理モード値がenum内に存在しない場合はnullを返す) */
        public static PROC_MODE getProcMode(String procModeVal) {
          for (PROC_MODE mode : PROC_MODE.values()) {
            if (true == mode.getProcModeVal().equals(procModeVal)) {
              return mode;
            }
          }
          return null;
        }
    }

    /** 戻り値 */
    public enum PROC_RESULT
    {
        /** 正常終了 */
        SUCCESS,
        /** パラメータ異常 */
        PARAM_ERR,
        /** 異常終了 */
        ERROR,
    }

    /**
     * ベッド空き状況確認
     * @param facilityCd 検索施設コード
     * @param ordNoList 検索対象外治療予定リスト(ベッド割り当て予定(処理対象のクール、曜日、期間(開始日、終了日)を加味した)オーダ番号リスト)
     * @param patId 検索対象外患者ID(ベッド割り当て予定の患者ID)
     * @param bedCd 検索ベッドコード
     * @param searchStartDate 検索開始日(形式:yyyyMMdd)
     * @param searchStartKurCd 検索開始クール
     * @param isMoveTreatDate 治療日移動フラグ(true:移動あり、false:移動なし)
     * @return 正常終了:検索にヒットしたスケジュールのリスト、異常終了:null
     */
    public List<OrdSchedule> selectForSearchReservedBed(String facilityCd, List<Long> ordNoList, Long patId, Long bedCd, String searchStartDate, Long searchStartKurCd, Boolean isMoveTreatDate)
    {
        List<OrdSchedule> retInfo = new ArrayList<OrdSchedule>();

        // 検索開始日時設定
        List<MstKur> mstKur = mstKurDao.selectByFacilityCd(SelectOptions.get(), facilityCd, "0");
        if (0 == mstKur.size()) {
            String strMsg = "クールマスタの取得に失敗しました(取得件数:" + mstKur.size() + ")";
            throw new RuntimeException(strMsg);
        }
        List<MstKur> currentKur = mstKur.stream().filter(info -> Long.parseLong(info.getKurCd().toString()) == searchStartKurCd).collect(Collectors.toList());
        if (0 == currentKur.size()) {
            String strMsg = "クールマスタから対象クールの情報の取得に失敗しました(クールコード:" + searchStartKurCd + ")";
            throw new RuntimeException(strMsg);
        }
        String searchStartDatetime = searchStartDate + currentKur.get(0).getKurStandardStartTime();

        // 検索終了日時設定
        String searchEndDatetime = searchStartDatetime;
        // ダミースケジュール登録情報リストが取得できた場合は最後のダミースケジュールの日時を設定
        try
        {
            // 処理対象のクール、曜日、期間(開始日、終了日)を加味したordNoListを元に、メインスケジュールごとのメインスケジュールを含むダミースケジュール登録情報リストを取得
            if ((null == ordNoList) || ((null != ordNoList) && (0 == ordNoList.size()))) {
                String tmp = "null";
                if (null != ordNoList) tmp = "未指定";
                String strMsg = "ベッド空き状況確認条件(ord_no=" + tmp + ")が異常なためベッド空き状況確認処理を中断しました";
                throw new RuntimeException(strMsg);
            }
            // 治療日移動がある場合は移動後の治療日を検索開始日に設定
            String moveStartDate = null;
            if (true == isMoveTreatDate) moveStartDate = searchStartDate;
            LinkedHashMap<Long, List<DummyScheduleInfo>> scheduleInfoList = this.createDummyScheduleInfoList(ordNoList, moveStartDate, bedCd, searchStartKurCd, mstKur, true);
            if (null == scheduleInfoList) {
                return null;
            }

            // 指定期間の予約済みスケジュール情報リストを取得
            List<DummyScheduleInfo> lastscheduleInfo = null;
            for (Iterator<Entry<Long, List<DummyScheduleInfo>>> entry = scheduleInfoList.entrySet().iterator(); entry.hasNext();) {
              lastscheduleInfo = entry.next().getValue();
            }
            if ((null != lastscheduleInfo) && (0 != lastscheduleInfo.size())) searchEndDatetime = lastscheduleInfo.get(lastscheduleInfo.size() - 1).getTreatDatetime();
            List<OrdSchedule> reservedBeds = this.selectForSearchReservedBed(facilityCd, ordNoList, patId, bedCd, searchStartDatetime, searchEndDatetime);

            // ベッド空き状況確認(メインスケジュールを含むダミースケジュール登録情報リストと指定期間の予約済みスケジュール情報リストを比較して一致する情報があれば対象ベッドの空きなしとして扱う) ※既に作成されているスケジュールを取得したスケジュール情報から作成予定スケジュール枠が埋まっているかチェック
            for (Iterator<Entry<Long, List<DummyScheduleInfo>>> entry = scheduleInfoList.entrySet().iterator(); entry.hasNext();) {
                Entry<Long, List<DummyScheduleInfo>> entryInfo = entry.next();
                Long ordNo = entryInfo.getKey();
                List<DummyScheduleInfo> dummyInfo = entryInfo.getValue();
                if (null == dummyInfo) {
                    EventLogMessage eventLogMessage = new EventLogMessage();
                	eventLogMessage.setLogMessage("対象治療予定(ord_no=" + ordNo + ")に対するダミースケジュール(dummyInfo=null)が異常なためベッド空き状況確認処理を中断しました");
                	logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                    return null;
                }

                // 作成予定スケジュールと既に作成されているスケジュールを比較し、スケジュールがかぶった場合は予約済みスケジュールとしてリストへ追加する
                for (int i = 0; i < dummyInfo.size(); i++) {
                    final DummyScheduleInfo tmp = dummyInfo.get(i);
                    List<OrdSchedule> addScheduleList = reservedBeds.stream().filter(info ->
                        (info.getFacilityCd().equals(tmp.getFacilityCd()) &&
                         info.getTreatDate().equals(tmp.getTreatDate()) &&
                         info.getKurCd().equals(tmp.getKurCd()) &&
                         info.getBedCd().equals(tmp.getBedCd()))).collect(Collectors.toList());
                    // 予約済みスケジュールが存在した場合はリストに追加
                    for (int j = 0; j < addScheduleList.size(); j++) {
                        retInfo.add(addScheduleList.get(j));

                        //add #10784 空きベッドが候補に表示しない  start
                        //他の予定と重複のベッド対してord_noを返す（他の予定のord_noを含む）
                        OrdSchedule ordSchedule = new OrdSchedule();
                        ordSchedule.setOrdNo(ordNo);
                        retInfo.add(ordSchedule);
                        //add #10784 空きベッドが候補に表示しない  end
                    }
                }
            }
        }
        catch (Exception ex)
        {
            // ロールバック実行
            throw new RuntimeException(ex.getMessage());
        }

        return retInfo;
    }

    /**
     * ベッド空き状況確認
     * @param facilityCd 検索施設コード
     * @param ordNoList 検索対象外治療予定リスト(ベッド割り当て予定(処理対象のクール、曜日、期間(開始日、終了日)を加味した)オーダ番号リスト)
     * @param patId 検索対象外患者ID(ベッド割り当て予定の患者ID)
     * @param bedCd 検索ベッドコード
     * @param searchStartDatetime 検索開始日時(形式:yyyyMMddHH24MISS) ※メインスケジュールの治療日+クール内標準治療開始時刻
     * @param searchEndDatetime 検索終了日時(形式:yyyyMMddHH24MISS) ※メインスケジュール(ダミースケジュール)の治療日+クール内標準治療開始時刻 ※オプション
     * @return 正常終了:検索にヒットしたスケジュールのリスト、異常終了:null
     */
    private List<OrdSchedule> selectForSearchReservedBed(String facilityCd, List<Long> ordNoList, Long patId, Long bedCd, String searchStartDatetime, String searchEndDatetime)
    {
        // パラメータチェック
        if (null == facilityCd) {
            EventLogMessage eventLogMessage = new EventLogMessage();
        	eventLogMessage.setLogMessage("ベッド空き状況確認条件(facility_cd=null)が異常なためベッド空き状況確認処理を中断しました");
        	logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            return null;
        }
        if (null == ordNoList) {
            EventLogMessage eventLogMessage = new EventLogMessage();
        	eventLogMessage.setLogMessage("ベッド空き状況確認条件(ord_no=null)が異常なためベッド空き状況確認処理を中断しました");
        	logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            return null;
        }
        if (null == patId) {
            EventLogMessage eventLogMessage = new EventLogMessage();
      	    eventLogMessage.setLogMessage("ベッド空き状況確認条件(pat_id=null)が異常なためベッド空き状況確認処理を中断しました");
      	    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          return null;
        }
        if (null == bedCd) {
            EventLogMessage eventLogMessage = new EventLogMessage();
      	    eventLogMessage.setLogMessage("ベッド空き状況確認条件(bed_cd=null)が異常なためベッド空き状況確認処理を中断しました");
      	    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            return null;
        }
        if ((null == searchStartDatetime) || ((null != searchStartDatetime) && (null == this.parseDateFormat(searchStartDatetime)))) {
            EventLogMessage eventLogMessage = new EventLogMessage();
      	    eventLogMessage.setLogMessage("ベッド空き状況確認条件(検索開始日時=" + searchStartDatetime + ")が異常なためベッド空き状況確認処理を中断しました");
      	    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            return null;
        }
        if ((null != searchEndDatetime) && (null == this.parseDateFormat(searchEndDatetime))) {
            EventLogMessage eventLogMessage = new EventLogMessage();
      	    eventLogMessage.setLogMessage("ベッド空き状況確認条件(検索終了日時=" + searchEndDatetime + ")が異常なためベッド空き状況確認処理を中断しました");
      	    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            return null;
        }

        return ordScheduleDao.selectForSearchReservedBed(facilityCd, ordNoList, patId, bedCd, searchStartDatetime, searchEndDatetime);
    }

    /**
     * ダミースケジュール削除+作成API
     * @param ordNoList メインスケジュールのオーダ番号リスト
     * @param searchBedCd 検索ベッドコード ※nullの場合はメインスケジュールのベッドコードを使用
     * @param searchStartKurCd 検索開始クールコード ※nullの場合はメインスケジュールのクールコードを使用
     * @param upDate 処理更新日時
     * @return PROC_RESULT 処理結果(SUCCESS:正常終了、ERROR:異常終了(Exceptionエラー含む)、PARAM_ERR:パラメータ異常)
     */
    @Transactional
    public PROC_RESULT deleteAndCreateDummySchedule(List<Long> ordNoList, Long searchBedCd, Long searchStartKurCd, Timestamp upDate)
    {
      PROC_RESULT ret = PROC_RESULT.SUCCESS;
      try
      {
          // ダミースケジュール削除
          ret = this.deleteDummySchedule(ordNoList);
          // 異常があった場合は処理を中断する
          if (PROC_RESULT.SUCCESS != ret) {
              return ret;
          }
          // ダミースケジュール作成
          ret = this.createDummySchedule(ordNoList, searchBedCd, searchStartKurCd, upDate);
      }
      catch (Exception ex)
      {
        // ロールバック実行
        throw new RuntimeException(ex.getMessage());
      }

      return ret;
    }

    /**
     * ダミースケジュール削除API
     * @param ordNoList メインスケジュールのオーダ番号リスト
     * @return PROC_RESULT 処理結果(SUCCESS:正常終了、ERROR:異常終了(Exceptionエラー含む)、PARAM_ERR:パラメータ異常)
     */
    @Transactional
    public PROC_RESULT deleteDummySchedule(List<Long> ordNoList)
    {
        // パラメータチェック
        if (null == ordNoList) {
            EventLogMessage eventLogMessage = new EventLogMessage();
      	    eventLogMessage.setLogMessage("対象治療予定(メインスケジュールのオーダ番号リスト=" + ordNoList + ")が異常なためダミースケジュール登録処理を中断しました");
      	    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            return PROC_RESULT.PARAM_ERR;
        }
        try
        {
            // ダミースケジュール削除処理実施(ダミースケジュールが作成されない場合もあるため処理結果件数はチェックしない)
            ordScheduleDao.deleteDummySchedule(ordNoList);
        }
        catch (Exception ex)
        {
          // ロールバック実行
          throw new RuntimeException(ex.getMessage());
        }

        return PROC_RESULT.SUCCESS;
    }

	/**
     * ダミースケジュール登録API
     * @param ordNoList メインスケジュールのオーダ番号リスト
     * @param searchBedCd 検索ベッドコード ※nullの場合はメインスケジュールのベッドコードを使用
     * @param searchStartKurCd 検索開始クールコード ※nullの場合はメインスケジュールのクールコードを使用
	 * @param upDate 処理更新日時
	 * @return PROC_RESULT 処理結果(SUCCESS:正常終了、ERROR:異常終了(Exceptionエラー含む)、PARAM_ERR:パラメータ異常)
	 */
    @Transactional
    public PROC_RESULT createDummySchedule(List<Long> ordNoList, Long searchBedCd, Long searchStartKurCd, Timestamp upDate)
	{
        // パラメータチェック
        if (null == ordNoList) {
            EventLogMessage eventLogMessage = new EventLogMessage();
      	    eventLogMessage.setLogMessage("対象治療予定(メインスケジュールのオーダ番号リスト=" + ordNoList + ")が異常なためダミースケジュール登録処理を中断しました");
      	    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            return PROC_RESULT.PARAM_ERR;
        }
  		try
  		{
            // メインスケジュールごとのダミースケジュール登録情報リストを取得
  		    LinkedHashMap<Long, List<DummyScheduleInfo>> dummyInfoList = this.createDummyScheduleInfoList(ordNoList, null, searchBedCd, searchStartKurCd, null, false);
            if (null == dummyInfoList) {
                return PROC_RESULT.ERROR;
            }

            // ベッド空き状況確認(バックグラウンドで治療予定が作成されていた場合のチェック)
            // TODO-YSK:本APIを呼び出す直前にベッド空き状況確認APIを呼び出しているのでここでは対応不要か?
//          if (0 != dummyInfo.size()) {
//            String facilityCd = dummyInfo.get(0).getFacilityCd();
//            Long patId = dummyInfo.get(0).getPatId();
//            Long bedCd = dummyInfo.get(0).getBedCd();
//            String searchStartDatetime = dummyInfo.get(0).getTreatDatetime();
//            String searchEndDatetime = dummyInfo.get(dummyInfo.size() - 1).getTreatDatetime();
//            List<OrdSchedule> fullBeds = this.selectSearchForFreeBeds(facilityCd, ordNo, patId, bedCd, null, null, searchStartDatetime, searchEndDatetime);
//            if (0 != fullBeds.size()) {
//                String strMsg = "対象治療予定(" +
//                "ord_no=" + ordNo +
//                ")に対して空きベッドがなかったため処理を中断しました(ベッド空き状況確認条件(施設コード=" + facilityCd + "、ベッドコード=" + bedCd + "、検索開始日時=" + searchStartDatetime + "、検索終了日時=" + searchEndDatetime + ")、ベッド登録済み件数:" + fullBeds.size() +")";
//                throw new RuntimeException(strMsg);
//            }
//          }

            // ダミースケジュール登録情報リスト分処理実施
            for (Iterator<Entry<Long, List<DummyScheduleInfo>>> entry = dummyInfoList.entrySet().iterator(); entry.hasNext();) {
                Entry<Long, List<DummyScheduleInfo>> entryInfo = entry.next();
                Long ordNo = entryInfo.getKey();
                List<DummyScheduleInfo> dummyInfo = entryInfo.getValue();
      	        if (null == dummyInfo) {
      	            EventLogMessage eventLogMessage = new EventLogMessage();
            	    eventLogMessage.setLogMessage("対象治療予定(ord_no=" + ordNo + ")に対するダミースケジュール(dummyInfo=null)が異常なためダミースケジュール登録処理を中断しました");
            	    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      	            return PROC_RESULT.ERROR;
      	        }
                // ダミースケジュール作成
                for (int i = 0; i < dummyInfo.size(); i++) {
                    // ダミースケジュール登録処理実施
                    int retCnt = ordScheduleDao.insertDummySchedule(ordNo, dummyInfo.get(i).getTreatDate(), dummyInfo.get(i).getKurCd(), dummyInfo.get(i).getBedCd(), upDate);
                    // 処理件数が1件でない場合は異常終了
                    if (1 != retCnt) {
                        String strMsg = "対象治療予定(" +
                        "ord_no=" + ordNo +
                        ")に対してダミースケジュール登録処理に失敗しました(処理件数:" + retCnt +")";
                        throw new RuntimeException(strMsg);
                    }
                }
            }
  		}
  		catch (Exception ex)
  		{
          // ロールバック実行
          throw new RuntimeException(ex.getMessage());
  		}

		return PROC_RESULT.SUCCESS;
	}

    /**
     * ダミースケジュール登録情報リスト作成
     * @param ordNoList メインスケジュールのオーダ番号リスト
     * @param searchStartDate 検索開始日(形式:yyyyMMdd) ※nullの場合はメインスケジュールの治療日を使用
     * @param searchBedCd 検索ベッドコード ※nullの場合はメインスケジュールのベッドコードを使用
     * @param searchStartKurCd 検索開始クールコード ※nullの場合はメインスケジュールのクールコードを使用
     * @param cacheMstKur クールマスタ情報 ※nullの場合は内部で取得
     * @param isIncludeMain メインスケジュール含有フラグ(true:メインスケジュールを含む、false:メインスケジュールを含めない)
     * @return 正常終了:メインスケジュールごとのダミースケジュール登録情報リスト、異常終了:null
     */
    private LinkedHashMap<Long, List<DummyScheduleInfo>> createDummyScheduleInfoList(List<Long> ordNoList, String searchStartDate, Long searchBedCd, Long searchStartKurCd, List<MstKur> cacheMstKur, Boolean isIncludeMain) {
        // メインスケジュールの治療予定リスト取得
        List<OrdMain> retInfoList = ordMainDao.selectByOrdNoList(ordNoList);
        if (null == retInfoList) {
            String strMsg = "治療予定の取得に失敗しました(ord_no=" + ordNoList + ")";
            throw new RuntimeException(strMsg);
        }
        LinkedHashMap<Long, List<DummyScheduleInfo>> dummyInfoList = new LinkedHashMap<Long, List<DummyScheduleInfo>>();
        List<MstKur> mstKur = cacheMstKur;
        for (int i = 0; i < retInfoList.size(); i++) {
            // メインスケジュールの治療予定情報取得
            OrdMain retInfo = retInfoList.get(i);
            Long ordNo = retInfo.getOrdNo();
            String facilityCd = retInfo.getFacilityCd();
            String treatDate = retInfo.getTreatDate();
            if (null != searchStartDate) {
              treatDate = searchStartDate;
            }
           /*mod #8494 by zhangruixue 2023-03-27  GC overhead limit exceeded start*/
            Integer indKurCdTemp = retInfo.getIndKurCd();
            if(indKurCdTemp == null){
              indKurCdTemp = 0;
            }
            Long tmpKurCd = indKurCdTemp.longValue();

            Integer indBedCdTemp = retInfo.getIndBedCd();
            if(indBedCdTemp == null){
              indBedCdTemp = 0;
            }
          /*mod #8494 by zhangruixue 2023-03-27  GC overhead limit exceeded end*/
            if (null != searchStartKurCd) {
                tmpKurCd = searchStartKurCd;
            }
            Long indKurCd = tmpKurCd;
            Long patId = retInfo.getPatId();
            Long indBedCd = indBedCdTemp.longValue();
            if (null != searchBedCd) {
                indBedCd = searchBedCd;
            }

            // ベッドとクールが未登録でなければダミースケジュール登録情報リスト作成処理実施
            if ((0 != indKurCd) && (0 != indBedCd)) {
                Long treatTime = null;
                // 治療時間(指示:治療条件情報)設定
                String indCondInfoTmp = retInfo.getIndCondInfo();
                if (indCondInfoTmp == null) {
                  treatTime = 0L;
                } else {
                  JSONObject indCondInfo= new JSONObject(indCondInfoTmp);
                  try {
                    //FNSI-修正 5902 xiebzh del start
                    //treatTime = new Long((new JSONObject(indCondInfo.get("1").toString()).get("value").toString()));
                    //FNSI-修正 5902 xiebzh del end
                    //FNSI-修正 5902 xiebzh add start
                    if (indCondInfo.has("1")) {
                      String treatTimeStr = new JSONObject(indCondInfo.get("1").toString()).get("value").toString();
                      if (StringUtils.isEmpty(treatTimeStr) || "null".equals(treatTimeStr.toLowerCase())) {
                        treatTime = 0L;
                      } else {
                        treatTime = Long.parseLong((new JSONObject(indCondInfo.get("1").toString()).get("value").toString()));
                      }
                    } else {
                      treatTime = 0L;
                    }
                    //FNSI-修正 5902 xiebzh add end
                  }
                  catch(Exception e)
                  {
                    EventLogMessage eventLogMessage = new EventLogMessage();
                    // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
                    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
                    String strMsg = "対象治療予定(" +
                      "ord_no=" + ordNo +
                      ")の治療時間(指示:治療条件情報)の取得に失敗しました";
                    throw new RuntimeException(strMsg);
                  }
                }

                // メインスケジュールの治療日、クール(クール内標準治療開始時刻)、治療時間から治療終了予定日時の日時を算出
                if (null == mstKur) {
                    mstKur = mstKurDao.selectByFacilityCd(SelectOptions.get(), facilityCd, "0");
                }
                if (0 == mstKur.size()) {
                    String strMsg = "クールマスタの取得に失敗しました(取得件数:" + mstKur.size() + ")";
                    throw new RuntimeException(strMsg);
                }
                List<MstKur> currentKur = mstKur.stream().filter(info -> Long.parseLong(info.getKurCd().toString()) == indKurCd).collect(Collectors.toList());
                if (0 == currentKur.size()) {
                    String strMsg = "クールマスタから対象治療予定(" +
                    "ord_no=" + ordNo +
                    ")のクール情報の取得に失敗しました(対象治療予定のクール(クールコード):" + indKurCd + ")";
                    throw new RuntimeException(strMsg);
                }
                DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
                DateTimeFormatter dayFormat = DateTimeFormatter.ofPattern("yyyyMMdd");
                LocalDateTime treatStartDay = LocalDateTime.parse(treatDate + "000000", dateFormat);
                //mod FNSI redmine 6575 劉祥霖　start
                String startTime=currentKur.get(0).getKurStandardStartTime();
                //ダミースケジュール移動の場合、開始時間不正による判定を追加する
                // mod #7118 2022/11/07 【デグレ】ダミースケジュール作成ロジック不正 dou start
                // if(currentKur.get(0).getKurCd()==retInfo.getIndKurCd()){
                //   if(retInfo.getIndTreatStartTime()!=null&&!retInfo.getIndTreatStartTime().equals("")){
                //     startTime=retInfo.getIndTreatStartTime()+"00";
                //   }
                // }
                if (currentKur.get(0).getKurCd().equals(retInfo.getIndKurCd())) {
                  if (!StringUtils.isEmpty(retInfo.getIndTreatStartTime())) {
                    startTime = retInfo.getIndTreatStartTime() + "00";
                  }
                }
                // mod #7118 2022/11/07 【デグレ】ダミースケジュール作成ロジック不正 dou end
                LocalDateTime treatEndDate = LocalDateTime.parse(treatDate + startTime, dateFormat).plusMinutes(treatTime);
                //mod FNSI redmine 6575 劉祥霖　end

                // ダミースケジュール登録情報リスト作成
                List<DummyScheduleInfo> dummyInfo = new ArrayList<DummyScheduleInfo>();
                // メインスケジュール含有フラグがtrueの場合、メインスケジュールをリストに含める
                if (true == isIncludeMain) {
                    DummyScheduleInfo main = new DummyScheduleInfo();
                    main.setFacilityCd(facilityCd);
                    main.setTreatDate(treatDate);
                    main.setKurCd(indKurCd);
                    //  mod #10784 空きベッドが候補に表示しない  start
                    //  main.setTreatDatetime(treatDate + currentKur.get(0).getKurStandardStartTime());
                    LocalDateTime treatEndDateTemp = LocalDateTime.parse(treatDate + currentKur.get(0).getKurStandardStartTime(), dateFormat).plusMinutes(treatTime);
                    String formattedDateTime = treatEndDateTemp.format(dateFormat);
                    main.setTreatDatetime(formattedDateTime);
                    //  mod #10784 空きベッドが候補に表示しない  end
                    main.setPatId(patId);
                    main.setBedCd(indBedCd);
                    main.setIsDummy(false);
                    dummyInfo.add(main);
                }
                LocalDateTime dummyDate = treatStartDay;
                Long dummyKur = indKurCd;
                // ダミースケジュールが治療終了予定日時を超えていなければ、ダミースケジュール登録情報リストに追加
                while (true == dummyDate.isBefore(treatEndDate)) {
                    // 次クール情報取得
                    MstKurEx nextKurInfo = this.calcNextKurInfo(mstKur, dummyKur);
                    if (null == nextKurInfo) {
                        String strMsg = "対象治療予定(" +
                        "ord_no=" + ordNo +
                        ")のダミースケジュール作成時にダミースケジュールのクールの取得に失敗しました(ダミースケジュールのクール(クールコード):" + dummyKur + ")";
                        throw new RuntimeException(strMsg);
                    } else {
                        DummyScheduleInfo tmp = new DummyScheduleInfo();
                        // 次クールの最初のクールフラグがtrueの場合は日付を翌日に更新
                        if (true == nextKurInfo.getIsFirstKur()) {
                            dummyDate = dummyDate.plusDays(1);
                        }
                        // ダミースケジュール更新(クールの期間すべてを含んでいるかをチェックするため、ダミースケジュールの時刻はクール終了時刻を設定)
                        String dummyTreatDate = dummyDate.format(dayFormat);
                        dummyDate = LocalDateTime.parse(dummyTreatDate + nextKurInfo.getKurEndTime(), dateFormat);
                        dummyKur = nextKurInfo.getKurCd().longValue();
                        // ダミースケジュールが治療終了予定日時を超えていなければ、ダミースケジュール登録情報リストに追加
                        if (false == dummyDate.isBefore(treatEndDate)) break;
                        tmp.setFacilityCd(facilityCd);
                        tmp.setTreatDate(dummyTreatDate);
                        tmp.setTreatWeek((short)(dummyDate.getDayOfWeek().getValue()));
                        tmp.setKurCd(dummyKur);

                        //mod #10784 空きベッドが候補に表示しない  start
//                        tmp.setTreatDatetime(dummyTreatDate + nextKurInfo.getKurStandardStartTime());
                        LocalDateTime treatEndDateTemp = LocalDateTime.parse(dummyTreatDate + nextKurInfo.getKurStandardStartTime(), dateFormat).plusMinutes(treatTime);
                        String formattedDateTime = treatEndDateTemp.format(dateFormat);
                        tmp.setTreatDatetime(formattedDateTime);
                        //mod #10784 空きベッドが候補に表示しない  end

                        tmp.setPatId(patId);
                        tmp.setBedCd(indBedCd);
                        tmp.setIsDummy(true);
                        dummyInfo.add(tmp);
                    }
                }
                // ダミースケジュールがあれば追加
                if (0 != dummyInfo.size()) dummyInfoList.put(ordNo, dummyInfo);
            } else {
                EventLogMessage eventLogMessage = new EventLogMessage();
        	    eventLogMessage.setLogMessage("メインスケジュールが未確定(ベッド未登録またはクール未登録)のためダミースケジュール作成処理をスキップしました(ord_no=" + ordNo + "、pat_id=" + patId + "、treat_date=" + treatDate + "、ind_bed_cd=" + indBedCd + "、ind_kur_cd=" + indKurCd + ")");
        	    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
            }
        }

        return dummyInfoList;
    }

    /**
     * 次クール情報取得
     * @param mstKur クールマスタ情報
     * @param currentKurCd 現在クール
     * @return 正常終了:次クール情報、異常終了:null
     */
    private MstKurEx calcNextKurInfo(List<MstKur>mstKur, long currentKurCd) {
      MstKurEx targetKur = null;
      Boolean isCurrentKur = false;
      if (0 < mstKur.size()) {
        for (int i = 0; i < mstKur.size(); i++) {
          // 次クール判定
          if (true == isCurrentKur) {
            // 次クールを返す
            targetKur = MstKurEx.parse(mstKur.get(i));
            break;
          }
          // 現在クール判定(最後のクールは除外)
          if ((i != mstKur.size()-1) && (currentKurCd == mstKur.get(i).getKurCd().longValue())) {
            isCurrentKur = true;
          }
        }
        // 次クールが見つからなかった場合は最初のクールを返す
        if (false == isCurrentKur) {
          targetKur = MstKurEx.parse(mstKur.get(0));
          targetKur.setIsFirstKur(true);
        }
      }

      return targetKur;
    }

    /**
     * 日時フォーマット変換(String→LocalDateTime)
     * @param checkStr 変換文字列
     * @return 正常終了:日時フォーマット後データ、異常終了:null
     */
    private LocalDateTime parseDateFormat(String checkStr) {
        LocalDateTime ret = null;
        try {
            // LocalDateTimeのparseは時刻:HHmmssまで指定しないとExceptionエラーとなる
            DateTimeFormatter dateFormat = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
            ret = LocalDateTime.parse(checkStr, dateFormat);
        } catch (Exception e) {
            EventLogMessage eventLogMessage = new EventLogMessage();
    	    eventLogMessage.setLogMessage("日時フォーマット変換に失敗しました(checkStr=" + checkStr + ")");
    	    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
        }

        return ret;
    }
}
