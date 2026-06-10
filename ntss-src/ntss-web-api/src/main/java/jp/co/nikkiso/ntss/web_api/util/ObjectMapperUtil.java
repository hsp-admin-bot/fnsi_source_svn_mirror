package jp.co.nikkiso.ntss.web_api.util;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import org.springframework.util.StringUtils;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.JavaType;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.type.CollectionType;
import com.fasterxml.jackson.databind.type.MapType;

/**
 * Singleton {@link ObjectMapper} Util
 *
 */
public class ObjectMapperUtil {
  private static final ObjectMapper mapper = new ObjectMapper();

  /**
   * JSON形式文字列からオブジェクト（POJO、マップ、リスト）を作成する。
   * {@link ObjectMapper#readValue(json, Class)}
   *
   * @param json - 対象JSON
   * @param type - 指定class
   * @return Mappingされたクラス
   * @throws IOException
   */
  public static <T> T read(String json, Class<T> type) throws IOException {
    return mapper.readValue(json, type);
  }

  /**
   * JSON形式文字列からオブジェクト（POJO、マップ、リスト）を作成する。
   * {@link ObjectMapper#readValue(json, JavaType)}
   *
   * @param json JSON形式文字列
   * @param type 返値の型
   * @return オブジェクト
   * @throws IOException
   */
  public static <T> T read(String json, JavaType type) throws IOException {
    return mapper.readValue(json, type);
  }

  /**
   * {@link ObjectMapper#readValue(File, Class)}
   *
   * @param jsonFile - 対象JSONファイル
   * @param type - 指定クラス
   * @return Mappingされたクラス
   * @throws IOException
   */
  public static <T> T readFile(File jsonFile, Class<T> type) throws IOException {
    return mapper.readValue(jsonFile, type);
  }

  /**
   * JSON形式文字列からList<Map<String, Object>>型のオブジェクトを作成する。
   *
   * @param json JSON形式文字列
   * @return オブジェクト
   * @throws IOException
   */
  public static List<Map<String, Object>> readListOfMap(String json) throws IOException {
    if (StringUtils.isEmpty(json)) {
      return new ArrayList<>();
    }

    JavaType listMapType = constructListType(Map.class);
    return read(json, listMapType);
  }

  /**
   * {@link ObjectMapper#readValue(json, TypeReference)}
   *
   * @param json - 対象JSON
   * @param type - 指定class
   * @return Mappingされたクラス
   * @throws IOException
   */
  public static <T> T readTypeReference(String json, TypeReference<T> type) throws IOException {
    return mapper.readValue(json, type);
  }

  /**
   * {@link ObjectMapper#writeValueAsString(Object)
   *
   * @param target - 出力Object
   * @return JSON
   * @throws IOException
   */
  public static String write(Object target) throws IOException {
    return mapper.writeValueAsString(target);
  }

  /**
   * JSON形式文字列からマップを作成する。
   *
   * @param keyClass マップのキーのクラス
   * @param valueClass マップの値のクラス
   * @return マップオブジェクト
   */
  public static MapType constructMapType(Class<?> keyClass, Class<?> valueClass) {
    return mapper.getTypeFactory().constructMapType(Map.class, keyClass, valueClass);
  }

  /**
   * JSON形式文字列からマップを作成する。
   *
   * @param keyType マップのキーの型
   * @param valueType マップの値の型
   * @return マップオブジェクト
   */
  public static MapType constructMapType(JavaType keyType, JavaType valueType) {
    return mapper.getTypeFactory().constructMapType(Map.class, keyType, valueType);
  }

  /**
   * 指定されたクラスのオブジェクトを要素とするリスト型を作成する。
   *
   * @param elementClass 要素のクラス
   * @return リスト型
   */
  public static CollectionType constructListType(Class<?> elementClass) {
    return mapper.getTypeFactory().constructCollectionType(List.class, elementClass);
  }

  /**
   * 指定された型のオブジェクトを要素とするリスト型を作成する。
   *
   * @param elementType 要素の型
   * @return リスト型
   */
  public static CollectionType constructListType(JavaType elementType) {
    return mapper.getTypeFactory().constructCollectionType(List.class, elementType);
  }

  /**
   * オブジェクトの型をList<String>に変換する。
   *
   * @param obj オブジェクト
   * @return List<String>オブジェクト
   */
  public static List<String> castToStringList(Object obj) {
    JavaType stringListType = constructListType(String.class);
    return mapper.convertValue(obj, stringListType);
  }

  /**
   * オブジェクトの型をMap<String, Object>に変換する。
   *
   * @param obj オブジェクト
   * @return Map<String, Object>オブジェクト
   */
  public static Map<String, Object> castToStringObjectMap(Object obj) {
    JavaType stringObjectMapType = constructMapType(String.class, Object.class);
    return mapper.convertValue(obj, stringObjectMapType);
  }

  /**
   * オブジェクトの型をMap<String, String>に変換する。
   *
   * @param obj オブジェクト
   * @return Map<String, String>オブジェクト
   */
  public static Map<String, String> castToStringStringMap(Object obj) {
    JavaType stringStringMapType = constructMapType(String.class, String.class);
    return mapper.convertValue(obj, stringStringMapType);
  }

  /**
   * オブジェクトの型をList<Map<String, Object>>に変換する。
   *
   * @param obj オブジェクト
   * @return List<Map<String, Object>>オブジェクト
   */
  public static List<Map<String, Object>> castToStringObjectMapList(Object obj) {
    JavaType stringObjectMapType = constructMapType(String.class, Object.class);
    JavaType stringObjectMapListType = constructListType(stringObjectMapType);
    return mapper.convertValue(obj, stringObjectMapListType);
  }

  /**
   * オブジェクトの型をList<Map<String, String>>に変換する。
   *
   * @param obj オブジェクト
   * @return List<Map<String, String>>オブジェクト
   */
  public static List<Map<String, String>> castToStringStringMapList(Object obj) {
    JavaType stringStringMapType = constructMapType(String.class, String.class);
    JavaType stringStringMapListType = constructListType(stringStringMapType);
    return mapper.convertValue(obj, stringStringMapListType);
  }

  /**
   * オブジェクトの型をMap<String, Map<String, String>>に変換する。
   *
   * @param obj オブジェクト
   * @return Map<String, Map<String, String>>オブジェクト
   */
  public static Map<String, Map<String, String>> castToDualStringKeyMap(Object obj) {
    JavaType stringType = mapper.constructType(String.class);
    JavaType stringStringMapType = constructMapType(String.class, String.class);
    JavaType dualStringKeyMapType = constructMapType(stringType, stringStringMapType);
    return mapper.convertValue(obj, dualStringKeyMapType);
  }

  /**
   * オブジェクトの型をList<Object>に変換する。
   *
   * @param obj オブジェクト
   * @return List<Object>オブジェクト
   */
  public static List<Object> castToObjectList(Object obj) {
    JavaType objectListType = constructListType(Object.class);
    return mapper.convertValue(obj, objectListType);
  }

  public static ObjectMapper getObjectMapper() {
    return mapper;
  }
}
