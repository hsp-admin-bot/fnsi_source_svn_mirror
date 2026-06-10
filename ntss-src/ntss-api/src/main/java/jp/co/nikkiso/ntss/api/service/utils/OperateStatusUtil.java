package jp.co.nikkiso.ntss.api.service.utils;

import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.api.service.PatMainAcceptanceStatusInfo.PatMainAcceptanceStatusInfoService;
import jp.co.nikkiso.ntss.api.service.conditionSend.OperateStatusUtilService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RestController;

import java.util.Date;

/*
 * 治療ステータスクラス
        @param  status
            0：条件送信前                                    ※0は、pat_mainの区分と値をクリア(null)ord_main:条件送信日時クリア。その他：指示->実績にコピーする部分はすべてクリア
            1：条件送信済                                    ※実績：条件送信日時も設定
            2：条件送信確認済み
            3：治療中
            4：排液済                    →終了
            5：後体重測定済み(実績未確定)
            6：後体重確認済み(過去実績)     ※6は、pat_mainの区分と値をクリア(null)
        @return
            true:成功
            false:失敗
 */
@RestController
public class OperateStatusUtil {


  //DB access
  @Autowired
  private OperateStatusUtilService operateStatusUtilService ;

  @Autowired
  private LogService logService;

  @Autowired
  PatMainAcceptanceStatusInfoService patMainAcceptanceStatusInfoService;


  //ステータス定義
  //ord_main 実績：治療状況rst_dialysis_stateの定義
  public enum STATUS {
    BEFORE_SENDCOND("0"),            //0:条件送信前
    DONE_SENDCOND("1"),              //1：条件送信済
    ENSURE_SENDCOND("2"),            //2：条件送信確認済み
    UNDER_TREATMENT("3"),            //3：治療中
    DONE_DRAINAGE("4"),              //4：排液済
    DONE_MEASURE_AFTER_WEIGHT("5"),  //5：後体重測定済み(実績未確定)
    ENSURE_AFTER_WEIGHT("6")         //6：後体重確認済み(過去実績)
    ;
    //値格納用

    public String strKey = null ;

    //String型のコンストラクタ
    private STATUS(String strKey) {
      this.strKey = strKey ;
    }

    //String型のGetter
    public String get() {
      return this.strKey ;
    }
  }

  /**
   * 実績治療状況ステータス変更処理
   * @param patId
   * @param ordNo オーダー番号
   * @param status ステータス
   *                ステータス                             ord_mainのステータス変更以外の処理
   *                0：条件送信前、                 ※0は、pat_mainの区分と値をクリア(null)
   *                1：条件送信済、                ※実績：条件送信日時も設定。pat_mainは区分のみ設定(値は何もしない)
   *                2：条件送信確認済み
   *                3：治療中、                        ※pat_mainの区分と値を設定する
   *                4：排液済、                         ※pat_mainの区分のみ設定する(値は何もしない)
   *                5：後体重測定済み(実績未確定)
   *                6：後体重確認済み(過去実績)  ※6は、pat_mainの区分と値をクリア(null)
   * @param startDateTime 治療開始日時
   * @param treatmentTime 治療時間[分]
   * @return true:成功 false:失敗
   */
  public boolean changeTreatStatusOrdAndPat(
        Long patId,
        Long ordNo,
        String status,
        Date startDateTime,
        String treatmentTime
      )
  {
    boolean ret = true ;

    //クラス名の取得(ログ用)
    final String className = new Object(){}.getClass().getEnclosingClass().getName();
    //メソッド名の取得(ログ用)
    final String methodName = new Object(){}.getClass().getEnclosingMethod().getName();

    //開始ログ
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setLogMessage(className + "." + methodName + "の処理を開始しました(pat_id:" + patId + " ord_no:" + ordNo + " status:" + status +")");
    logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    //statusのenum化(switchで使用するため)
    STATUS enumStatus = getEnumByOrdinal(STATUS.class, Integer.parseInt(status));

    //ord_mainの条件送信日時更新フラグ(true:更新)
    boolean updateOrdMainSendDateFlag = false ;

    //pat_mainのステータスクリアフラグ(true:クリア)
    boolean clearPatMainStatusFlag = false ;
    //pat_mainのステータス(区分)更新フラグ(true:更新)
    boolean changePatMainClassFlag = false ;
    //pat_mainのステータス(値)更新フラグ(true:更新)
    boolean changePatMainValueFlag = false ;

    switch(enumStatus)
    {
      case BEFORE_SENDCOND:     //0:条件送信前
        //pat_mainクリア
        clearPatMainStatusFlag = true ;
        break;
      case DONE_SENDCOND:       //1：条件送信済
      case ENSURE_SENDCOND:     //2：条件送信確認済み
        //条件送信日時の更新(mnt_machine_stateの条件送信日時cond_send_dateで更新)
        updateOrdMainSendDateFlag = true ;
        //pat_mainのステータスの区分を変更
        changePatMainClassFlag = true ;
        break;
      case UNDER_TREATMENT:     //3：治療中
        //pat_mainのステータスの区分を変更
        changePatMainClassFlag = true ;
        //pat_mainのステータスの値を変更
        changePatMainValueFlag = true ;
        break;
      case DONE_DRAINAGE:       //4：排液済
        //pat_mainのステータスの区分を変更
        changePatMainClassFlag = true ;
        break;
      case DONE_MEASURE_AFTER_WEIGHT://5：後体重測定済み(実績未確定)
        //ord_mainのみ変更
        break;
      case ENSURE_AFTER_WEIGHT: //6：後体重確認済み(過去実績)
        //pat_mainクリア
        clearPatMainStatusFlag = true ;
        break;
      default:
        //想定外の状態指定
        ret = false ;
    }

    if(ret)
    {
      //ord_mainの状態書き換え
      //DB(ord_main)の更新

      int retOrdMain = operateStatusUtilService.updateOrdMainStatus(
                          ordNo,
                          status,
                          updateOrdMainSendDateFlag
                    );

      if(retOrdMain != 1)
          ret = false ;

      //TODO:実績のクリア
      //ステータスが0の場合、その他：指示->実績にコピーする部分はすべてクリア

      if(ret && (clearPatMainStatusFlag || changePatMainClassFlag))
      {
        //DB(pat_main)の更新
        try
        {
          int retPatMain = patMainAcceptanceStatusInfoService.update(patId, ordNo, status, startDateTime, treatmentTime);
          if(retPatMain != 1)
            ret = false;
        }
        catch(Exception e)
        {
      	  eventLogMessage.setLogMessage(className + "." + methodName + "の処理が失敗しました:"+ e.getMessage());
      	  logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
          ret = false;
        }
      }
    }
    //終了ログ
    eventLogMessage.setLogMessage(className + "." + methodName + "の処理を終了しました(pat_id:" + patId + " ord_no:" + ordNo + " status:" + status +")");
    logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    return ret ;
  }

  /**
   * Ordinal番号を元に対応するEnumを取得する
   * @param enumClass   enum定義クラス
   * @param ordinal     ordinal番号
   * @return Enum
   */
  public static <E extends Enum<E>> E getEnumByOrdinal(Class<E> enumClass, int ordinal) {
    E[] enumArray = enumClass.getEnumConstants();
    return enumArray[ordinal];
}

}
