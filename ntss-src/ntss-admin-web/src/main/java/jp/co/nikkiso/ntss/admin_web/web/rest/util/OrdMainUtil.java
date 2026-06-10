package jp.co.nikkiso.ntss.admin_web.web.rest.util;

import org.apache.commons.lang3.StringUtils;
import org.json.JSONArray;
import org.json.JSONObject;
import org.json.JSONTokener;

import java.util.Map;

public class OrdMainUtil {
  /**
   * JSONObjcetを対象データで更新
   *
   * @param jObj 元データ
   * @param map  追加する情報のmap
   * @return jobj 対象データ追加後のデータ
   */
  public static JSONObject updateJSONObject(JSONObject jObj, Map<String, ?> map) {
    for (Map.Entry<String, ?> entry : map.entrySet()) {
      jObj.put(entry.getKey(), entry.getValue() == null ? JSONObject.NULL : entry.getValue());
    }
    return jObj;
  }
  /**
   * 指定した階層に対象データを追加する
   *
   * @param base           元データ
   * @param map            変更する情報のmap
   * @param RecursionCount 再帰回数
   * @return responseData 対象データ追加後のデータ
   */
  public static String updateRecursionJSONObject(String base, Map<String, ?> map, int RecursionCount) {
    /* modify by shiyw 2023-02-24 [IES check] Avoid java.lang.NullPointerException at base.isEmpty() --start */
    //if (base.isEmpty()) {
    if (StringUtils.isEmpty(base)) {
      /* modify by shiyw 2023-02-24 [IES check] Avoid java.lang.NullPointerException at base.isEmpty() --end */
      return null;
    }
    // 対象データ追加後のデータ格納用
    String responseData = base;
    // データがJSONObjectかJSONArrayかをチェック  どちらにも該当しない場合は、処理を何も行わない
    Object json = new JSONTokener(base).nextValue();
    if (json instanceof JSONObject) {
      // データがJSONObjectの場合以下の処理を実行
      JSONObject obj = new JSONObject(base);
      // 戻り値用データ
      JSONObject responseJobj = new JSONObject();
      // 再帰回数が1より小さい場合、そのまま更新する
      if (1 > RecursionCount) {
        responseJobj = OrdMainUtil.updateJSONObject(obj, map);
      } else {
        // jsonキーリスト
        JSONArray objKey = obj.names();
        for (int i = 0; i < objKey.length(); i++) {
          String key = objKey.get(i).toString();
          // 再帰回数を1つ減らし、再帰呼び出しをする
          JSONObject o = new JSONObject(updateRecursionJSONObject(obj.getJSONObject(key).toString(), map, RecursionCount - 1));
          // 対象データを格納したObjectを連想配列として格納
          responseJobj.put(key, OrdMainUtil.updateJSONObject(o, map));
        }
      }
      responseData = responseJobj.toString();
    } else if (json instanceof JSONArray) {
      // データがJSONArrayの場合以下の処理を実行
      JSONArray jArr = new JSONArray(base);
      // 戻り値用データ
      JSONArray responseArr = new JSONArray();
      for (int i = 0; i < jArr.length(); i++) {
        // JSONArrayの要素内の指定の階層にデータを追加する
        JSONObject obj = new JSONObject(updateRecursionJSONObject(jArr.get(i).toString(), map, RecursionCount));
        // 対象データを格納したObjectを配列として格納
        responseArr.put(obj);
      }
      responseData = responseArr.toString();
    }
    return responseData;
  }
}
