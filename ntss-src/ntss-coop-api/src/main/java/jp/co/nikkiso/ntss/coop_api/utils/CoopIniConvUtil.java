package jp.co.nikkiso.ntss.coop_api.utils;


import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.core.entity.MstCoopIni;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import org.apache.commons.lang3.StringUtils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 通連携設定マスタで、外部連携のコードと本システムコードを変換します
 *
 */
public class CoopIniConvUtil {
  /**
   * 区切記号.
   */
  public static final String MARK = "\r\n";

  /* del by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し  --start */
  // /**
  //  * 区分変換データ.
  //  */
  // private static Map<String, MstCoopIni> ConvertCodeData = new HashMap<>();

  // /**
  //  * 施設コードで、区分変換データを作成する。
  //  *
  //  * @param facilityCd 施設コード
  //  */
  // public static void SetData(String facilityCd, List<MstCoopIni> coopIniList) {
  //   if (StringUtils.isEmpty(facilityCd)) {
  //     return;
  //   }
  //
  //   if (coopIniList == null || coopIniList.size() == 0) {
  //     return;
  //   }
  //
  //   if (ConvertCodeData.containsKey(facilityCd)) {
  //     // 古い連携設定情報とKEYマッピングを取得する
  //     MstCoopIni oldInfo = ConvertCodeData.get(facilityCd);
  //     String coopIniInfoOld = oldInfo.getCoopIniInfo();
  //     String keyMappingOld = oldInfo.getKeyMapping();
  //     coopIniInfoOld = StringUtils.isEmpty(coopIniInfoOld)? "" : coopIniInfoOld;
  //     keyMappingOld = StringUtils.isEmpty(keyMappingOld)? "" : keyMappingOld;
  //     // 新しい連携設定情報とKEYマッピングを取得する
  //     MstCoopIni newInfo = coopIniList.get(0);
  //     String coopIniInfoNew = newInfo.getCoopIniInfo();
  //     String keyMappingNew = newInfo.getKeyMapping();
  //     coopIniInfoNew = StringUtils.isEmpty(coopIniInfoNew)? "" : coopIniInfoNew;
  //     keyMappingNew = StringUtils.isEmpty(keyMappingNew)? "" : keyMappingNew;
  //
  //     // 連携設定情報とKEYマッピングを更新すするか
  //     if (coopIniInfoOld.equals(coopIniInfoNew) && keyMappingOld.equals(keyMappingNew)) {
  //       return;
  //     }
  //   }
  //
  //   ConvertCodeData.put(facilityCd, coopIniList.get(0));
  // }
  /* del by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し  --end */

  /* upd by chamaojia 2026-04-24 [10959] param facilityCd -> iniInfo --start */
  /**
   * 施設コードで、KEYマッピングを取得する。
   *
   * @param iniInfo 連携設定情報
   * @param key0 電子カルテ種別
   * @param direction 向き（送受信）(S:送信、R:受信)
   * @return KEYマッピング
   */
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  public static Map<String, String> GetKeyMapping(String facilityCd, String direction) {
  public static Map<String, String> GetKeyMapping(MstCoopIni iniInfo, String key0, String direction) {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    if (iniInfo == null) {
      return null;
    }

    // KEYマッピングを取得する
    String keyMappingJson = iniInfo.getKeyMapping();
    if (StringUtils.isEmpty(keyMappingJson)) {
      return null;
    }

// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    Map<String, Map<String, String>> keyMapping = null;
    Map<String, Map<String, Map<String, String>>> keyMapping = null;
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    try {
      keyMapping = ObjectMapperUtil.read(keyMappingJson, Map.class);
    } catch (Exception ex) {
      String message = String.format("通連携設定マスタのKEYマッピングはjson形式のデータではありません。施設コード:[%s] 連携設定コード:[%d] 内容:[%s]",
        iniInfo.getFacilityCd(), iniInfo.getCoopIniCd(), ex.getMessage());
      throw new NtssException(message);
    }
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    // S:送信場合
//    if ("S".equals(direction) && keyMapping.containsKey("S")) {
//      return keyMapping.get("S");
//    } else if ("R".equals(direction) && keyMapping.containsKey("R")) {
//      return keyMapping.get("R");
//    } else {
//      return null;
//    }
    // key0のマッチング
    String key0New = key0;
    if (StringUtils.isEmpty(key0)) {
      // key0未設定の場合、1つの半角スペースを設定してください。
      key0New = " ";
    }
    if (keyMapping.containsKey(key0New)) {
      Map<String, Map<String, String>> keyMappingKey = keyMapping.get(key0New);
      // S:送信場合
      if ("S".equals(direction) && keyMappingKey.containsKey("S")) {
        return keyMappingKey.get("S");
      } else if ("R".equals(direction) && keyMappingKey.containsKey("R")) {
        return keyMappingKey.get("R");
      } else {
        return null;
      }
    } else {
      return null;
    }
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
   }

  /**
   * 連携設定情報を取得する。
   *
   * @param iniInfo 連携設定情報
   * @return 連携設定情報
   */
  public static Map<String, String>  GetCoopIniInfo(MstCoopIni iniInfo) {
    if (iniInfo == null) {
      return null;
    }

    // 連携設定情報を取得する
    String coopIniInfoJson = iniInfo.getCoopIniInfo();
    if (StringUtils.isEmpty(coopIniInfoJson)) {
      return null;
    }

    Map<String, String> coopIniInfoMap = new HashMap<>();
    try {
      List<Map<String, Object>> coopIniInfoList = ObjectMapperUtil.readListOfMap(coopIniInfoJson);

      for (Map<String, Object> info : coopIniInfoList) {
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        String key0 = "";
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        String key1 = "";
        String key2 = "";
        String value = "";
        String default_v = "";
        String is_effect = "";
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        if (info.containsKey("key0") && info.get("key0") != null) {
          key0 = info.get("key0").toString().trim();
        }
// add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        if (info.containsKey("key1") && info.get("key1") != null) {
          key1 = info.get("key1").toString().trim();
        }
        if (info.containsKey("key2") && info.get("key2") != null) {
          key2 = info.get("key2").toString();
        }
        if (info.containsKey("value") && info.get("value") != null) {
          value = info.get("value").toString();
        }
        if (info.containsKey("default_v") && info.get("default_v") != null) {
            default_v = info.get("default_v").toString();
        }
        if (info.containsKey("is_effect") && info.get("is_effect") != null) {
          is_effect = info.get("is_effect").toString();
        }

        if (!StringUtils.isEmpty(key1) && !StringUtils.isEmpty(key2)) {
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//          String keyMain = key1 + MARK + key2;
          String keyMain = key0 + MARK + key1 + MARK + key2;
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          coopIniInfoMap.put(keyMain, (StringUtils.isEmpty(value)?default_v:value));
        }
      }
    } catch (Exception ex) {
      String message = String.format("通連携設定マスタの連携設定情報はjson形式のデータではありません。施設コード:[%s] 連携設定コード:[%d] 内容:[%s]",
        iniInfo.getFacilityCd(), iniInfo.getCoopIniCd(), ex.getMessage());
      throw new NtssException(message);
    }

    return coopIniInfoMap;
  }
  /* upd by chamaojia 2026-04-24 [10959] param facilityCd -> iniInfo --end */
}
