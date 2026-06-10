package jp.co.nikkiso.ntss.admin_web.web.rest.util;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import org.springframework.beans.factory.annotation.Autowired;

import com.fasterxml.jackson.annotation.JsonAnyGetter;
import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * Json形式データ管理クラス
 */
public class JsonDataManager {
  /**
   * ロギングのServiceインタフェース.
   */
  @Autowired
  private LogService logService;
  /**
   * 内部処理用Json形式データ(Hashデータ)
   */
  private Map<String, Object> extensions = new HashMap<>();
  private Map<String, Object> jsonData = new HashMap<>();
  private Map<String, String> jsonStringData = new HashMap<>();

  /**
   * 内部処理用Json形式データ一括取得(WebAPIの戻り値(ResponseEntity)で使用)
   */
  @JsonAnyGetter
  public Map<String, Object> getExtensions() {
      return extensions;
  }

  /**
   * 内部処理用Json形式データ個別設定(WebAPIの戻り値(ResponseEntity)で使用)
   */
  @JsonAnySetter
  public void setExtensions(String key, Object value) {
      this.extensions.put(key, value);
  }

  /**
   * 内部処理用Json形式データ個別取得(内部処理(データ加工処理)で使用)
   */
  public Object getJsonData(String key) {
    Object ret = null;
    if ((null != this.jsonData) && (this.jsonData.containsKey(key))) {
      ret = this.jsonData.get(key);
      // ★バックスラッシュのエスケープをどうするか？
//      if (-1 != ret.toString().indexOf("\\\\")) {
//        String aaa = ret.toString();
//        ret = aaa.replaceAll("\\\\\\\\", "\\\\");
//      }
    }
    return ret;
  }

  /**
   * 内部処理用Json形式データ取得
   */
  public String getJsonData() {
    String ret = new String();
    ret = this.jsonData.toString();
    return ret;
  }

  public String getJsonDataDoubleQuotes() {
    String ret = "{";
    for (Map.Entry<String, Object> mapData : this.jsonData.entrySet()) {
      ret = ret + " \"" + mapData.getKey() + "\":" + mapData.getValue() + ",";
    }
    if(ret.length()>1) {
      ret = ret.substring(0, ret.length()-1);
    }
    ret = ret + "}";

    return ret;
  }

  /**
   * 内部処理用Json形式データ一括設定(内部処理(データ加工処理)で使用)
   */
  public void setJsonData(String script) {
    ScriptEngineManager manager = new ScriptEngineManager();
    ScriptEngine engine = manager.getEngineByName("nashorn");
    try {
        // JavaScriptの実行
        Object obj = engine.eval(String.format("(%s)", script));
        // リフレクションでキーセットを取得
        Object[] keys = ((java.util.Set)obj.getClass().getMethod("keySet").invoke(obj)).toArray();
        // リフレクションでgetメソッドを取得
        Method method_get = obj.getClass().getMethod("get", Class.forName("java.lang.Object"));
        Map<String, Object> map = new HashMap<>();
        for(int i = 0; i < keys.length; i++) {
            Object val = method_get.invoke(obj, keys[i]);
            map.put(keys[i].toString(), val);
        }
        this.jsonData = map;
    } catch(Exception e) {
//        this.jsonData = null;
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
  }
  /**
   * 内部処理用Json形式データ一括設定
   */
  public void setJsonDataDoubleQuotes(String script, boolean overwriteFlg) {
    ScriptEngineManager manager = new ScriptEngineManager();
    ScriptEngine engine = manager.getEngineByName("nashorn");
    try {
        // JavaScriptの実行
        Object obj = engine.eval(String.format("(%s)", script));
        // リフレクションでキーセットを取得
        Object[] keys = ((java.util.Set)obj.getClass().getMethod("keySet").invoke(obj)).toArray();
        // リフレクションでgetメソッドを取得
        Method method_get = obj.getClass().getMethod("get", Class.forName("java.lang.Object"));
        Map<String, Object> map = new HashMap<>();
        if(overwriteFlg) {
          map = this.jsonData;
        }
        for(int i = 0; i < keys.length; i++) {
          String val = method_get.invoke(obj, keys[i]).toString().replace("\\", "\\\\");
          val = "\"" + val.replace("\"", "\\\"") + "\"";
          map.put(keys[i].toString(), val);
        }
        this.jsonData = map;
    } catch(Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }
  }
  /**
  * DTOクラスのインスタンスをJSON文字列に変換する
  * @param dto
  * @return String
  * @throws JsonProcessingException
  */
  public String convert(Object dto){
       ObjectMapper mapper = new ObjectMapper();
       try{
//         String json = mapper.writerWithDefaultPrettyPrinter().writeValueAsString(dto);
         String json = mapper.writeValueAsString(dto);
         return json;
       }catch(JsonProcessingException e){
            return null;
       }
  }

  /**
   * 内部処理用Json形式(String)データ個別取得(内部処理(データ加工処理)で使用)
   */
  public String getJsonStringData(String key) {
    String ret = null;
    if ((null != this.jsonStringData) && (this.jsonStringData.containsKey(key))) {
      if (null != this.jsonStringData.get(key)) ret = this.jsonStringData.get(key).toString();
//      if (null != this.jsonStringData.get(key)) ret = this.convert(this.jsonStringData.get(key));
      // ★バックスラッシュのエスケープをどうするか？
    }
    return ret;
  }

  /**
   * 内部処理用Json形式(String)データ一括設定(内部処理(データ加工処理)で使用)
   */
  public void setJsonStringData(String script) {
    ScriptEngineManager manager = new ScriptEngineManager();
    ScriptEngine engine = manager.getEngineByName("nashorn");
    try {
      // JavaScriptの実行
      Object obj = engine.eval(String.format("(%s)", script));
      // リフレクションでキーセットを取得
      Object[] keys = ((java.util.Set)obj.getClass().getMethod("keySet").invoke(obj)).toArray();
      // リフレクションでgetメソッドを取得
      Method method_get = obj.getClass().getMethod("get", Class.forName("java.lang.Object"));
      Map<String, String> map = new HashMap<>();
      for(int i = 0; i < keys.length; i++) {
//　★Json形式のネストデータの取得に失敗する（Stringデータで取得できない）
//        String val = method_get.invoke(obj, keys[i]).toString();
        String val = this.convert(method_get.invoke(obj, keys[i]));
        String strRet = null;
        if (null != val) strRet = val;
        map.put(keys[i].toString(), strRet);
      }
      this.jsonStringData = map;
    } catch(Exception e) {
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage("JsonData:" + script);
        logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
    }
  }
}
