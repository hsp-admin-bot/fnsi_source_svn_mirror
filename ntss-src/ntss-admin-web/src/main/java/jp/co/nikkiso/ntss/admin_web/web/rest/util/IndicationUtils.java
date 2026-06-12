package jp.co.nikkiso.ntss.admin_web.web.rest.util;

import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
//add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import jakarta.annotation.PostConstruct;
@Component
//add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
public class IndicationUtils {
  /**
   * 曜日パターン情報加工
   * @param weekPattern 選択曜日のJsonデータ
   * @return 選択曜日INDEXの配列
   */
  //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
  @Autowired
  private LogService logService;
  @Autowired
  private static LogService stalogService;

  @PostConstruct
  public void init () {
    stalogService = logService;
  }
  //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
  public static List<Integer> getWeekPattern(String weekPattern)
  {
    int count = 0;
    JSONArray json;
    List<Integer> weeksArry = new ArrayList<Integer>();
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
    EventLogMessage eventLogMessage;
    //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
    try {
      json = new JSONArray(weekPattern);
      // 選択された曜日を配列に格納
      JSONObject allWeek = (JSONObject)(json.get(0));
      // 曜日指定で全(1)が押されたらweeksArryに月(1),火曜(2),水(3),木(4),金(5),土(6),日(7)を格納
      if ((boolean)(allWeek.get("done")) == true) {
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
        eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("全曜日選択");
        stalogService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
        //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
        for (int i = 0; i < 7; i++) {
         weeksArry.add(i+1);
         count ++;
        }
      } else {
        // 指定された曜日をweeksArryに格納
        for (int i = 1; i < json.length(); i++) {
          JSONObject jObj = (JSONObject)(json.get(i));
          if ((boolean)(jObj.get("done")) == true) {
            weeksArry.add((int)(jObj.get("value")));
            count++;
            //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
            eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage("登録曜日："+i);
            stalogService.log(LogLevel.INFO, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
            //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
          }
        }
      }
      // 曜日選択がされていない場合SQLでweeksArryを条件から外す
      if (count <= 0) {
        weeksArry.add(0);
      }
    } catch (JSONException e) {
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 start
      eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("エラー発生："+e.getMessage());
      stalogService.log(LogLevel.ERROR, eventLogMessage,null, LoggingConstant.SERVICE_NAME.FNSI, null);
      //add FNSI-「コンソール出力のみで、ログに出力されていないメッセージがある」の改修 江 end
      return null;
    }

    return weeksArry;
  }
}
