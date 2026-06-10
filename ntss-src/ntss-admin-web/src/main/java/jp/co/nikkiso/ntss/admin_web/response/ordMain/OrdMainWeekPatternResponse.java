package jp.co.nikkiso.ntss.admin_web.response.ordMain;

import jp.co.nikkiso.ntss.admin_web.service.ordMainDelayTask.OrdMainJournalRequest;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatRadMain;
import lombok.Data;
import org.springframework.http.HttpStatus;
import org.springframework.util.MultiValueMap;

import java.util.List;
import java.util.Map;

@Data
public class OrdMainWeekPatternResponse {
  /*
   * @param body the entity body
   */
  String body;
  /*
   * @param headers the entity headers
   */
  MultiValueMap<String, String> headers;
  /*
   * @param status the status code
   */
  HttpStatus status;
  /*
   * ordMain ジャーナル Api リクエスト
   * */
  List<OrdMainJournalRequest> requestList;

  //add #10412 次患者更新関連全体見直し対応 朴 start
  /*
   * @param doCallNextPatOrdMainList
   */
  List<OrdMain> doCallNextPatOrdMainList;
  //add #10412 次患者更新関連全体見直し対応 朴 end

  // add #10553 start
  /*
   * @param 連携用、イベントログ用
   */
  List<OrdMain> resultOrdMainChangedAfterDataInfoList;

  /*
   * @param 連携用、イベントログ用
   */
  List<OrdMain> resultOrdMainChangeBeforeDataInfoList;
  // add #10553 end
  // add 10125 検査予定に関する連携イベント作成不備 関  start
  /*
   * @param 連携用、イベントログ用
   */
  List<PatExamMain> resultPatExamMainChangedAfterDataInfoList;

  /*
   * @param 連携用、イベントログ用
   */
  List<PatExamMain> resultPatExamMainChangeBeforeDataInfoList;
  /*
   * @param 連携用、イベントログ用
   */
  List<PatRadMain> resultPatRadMainChangedAfterDataInfoList;
  // add 10125 検査予定に関する連携イベント作成不備 関  end

  // add #11716 曜日パターン変更の不正 関 start
  private String PROC_RESULT;

  private Map<String, List<Object>> resultAllChangeBeforeDataInfoList;

  private Map<String, List<Object>> resultAllChangedDataInfoList;
  // add #11716 曜日パターン変更の不正 関 end
}
