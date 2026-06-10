package jp.co.nikkiso.ntss.admin_web.service.utils;

import java.util.Arrays;
import java.util.List;

import org.bson.Document;
import org.springframework.data.domain.Sort;
import org.springframework.data.mongodb.core.aggregation.Aggregation;
import org.springframework.data.mongodb.core.aggregation.AggregationOperation;
import org.springframework.data.mongodb.core.aggregation.AggregationOperationContext;

import com.mongodb.DBObject;

/**
 * MongoDBのAggregationパイプライン構築を支援するユーティリティクラス
 */
public class AggregationUtils {

  private AggregationUtils() {
    throw new UnsupportedOperationException("Utility class");
  }
  
  /** DBObject をそのまま $match するための AggregationOperation */
  public static class DbObjectMatchOperation implements AggregationOperation {
    private final DBObject query;
    public DbObjectMatchOperation(DBObject query) { this.query = query; }
    @Override
    public Document toDocument(AggregationOperationContext context) {
      return new Document("$match", query);
    }
  }
  
  /**
   * 患者ID、数値項目を共通システム仕様でソートするためのAggregationパイプラインを構築します。
   *  
   * <ul>
   *   <li>空文字は昇順時は最後に、降順時は最初に配置されます。</li>
   *   <li>数値として解釈可能な文字列は数値順にソートされます。</li>
   *   <li>非数値文字列は小文字化した辞書順でソートされます。</li>
   * </ul>
   *
   * @param field     対象となるフィールド名
   * @param alias     ソート用一時フィールドの接頭辞
   * @param direction ソート方向（ASC または DESC）
   * @return AggregationOperation のリスト
   */
  public static List<AggregationOperation> buildNumericSortOps(String field, String alias, Sort.Direction direction) {
    final String p = "$" + field;
    
    // ソートに利用する補助フィールド名を定義
    final String emptyField = alias + "_empty"; // 空文字判定用
    final String isNumField = alias + "_isNum"; // 数値判定用
    final String numField   = alias + "_num";   // 数値変換結果
    final String lenField   = alias + "_len";   // 数値の桁数
    final String lexField   = alias + "_lex";   // 非数値用の辞書順キー
    
    // --- ステージ1: 空文字・数値の基本情報を付与 ---
    // このステージでは、元のフィールドに対して以下の補助フィールドを追加する：
    //   - emptyField: 空文字かどうか (true/false)
    //   - isNumField: 数値文字列かどうか（$convertでlongへの変換が成功したらtrue、失敗したらfalse）
    //   - numField  : 数値文字列なら long に変換した値（失敗したら null）
    AggregationOperation add1 = ctx -> new Document("$addFields", new Document()
        .append(emptyField, new Document("$eq", Arrays.asList(p, "")))  // 空文字判定
        .append(isNumField, new Document("$ne", Arrays.asList(          // 数値判定（$convert成功判定）
            new Document("$convert", new Document("input", p).append("to", "long").append("onError", null).append("onNull", null)),
            null)))
        .append(numField, new Document("$convert",                       // 数値変換
            new Document("input", p)
                .append("to", "long")
                .append("onError", null)
                .append("onNull", null)))
    );

    // --- ステージ2: 数値/非数値に応じてソート用キーを付与 ---
    // ステージ1で判定した isNumField を使い、
    //   - lenField : 数値なら桁数（文字列長）をセット、非数値なら null
    //   - lexField : 非数値なら小文字化した文字列をセット、数値なら null
    // とすることで、後続のソート処理で「数値→非数値」の順序付けを可能にする。
    AggregationOperation add2 = ctx -> new Document("$addFields", new Document()
        .append(lenField, new Document("$cond", Arrays.asList(
            "$" + isNumField, new Document("$strLenCP", p), null))) // 数値→桁数
        .append(lexField, new Document("$cond", Arrays.asList(
            "$" + isNumField, null, new Document("$toLower", p))))  // 非数値→小文字化
    );

    // --- ステージ3: フィールドを指定した方向でソート ---
    // 空文字の位置づけ（ASC: 最後 / DESC: 最初）
    Sort.Direction emptyDir = (direction == Sort.Direction.ASC) ? Sort.Direction.ASC : Sort.Direction.DESC;
    // 数値 or 非数値の位置づけ
    Sort.Direction isNumDir = (direction == Sort.Direction.ASC)
        ? Sort.Direction.DESC  // 昇順時は数値を先に
        : Sort.Direction.ASC;  // 降順時は非数値を先に
    
    List<Sort.Order> orders = Arrays.asList(
        new Sort.Order(emptyDir, emptyField), // 空文字の前後
        new Sort.Order(isNumDir, isNumField), // 数値 or 非数値の並び
        new Sort.Order(direction, numField),  // 数値の大小
        new Sort.Order(direction, lenField),  // 数値同値は桁数
        new Sort.Order(direction, lexField)   // 非数値は辞書順
    );

    return Arrays.asList(
        add1,
        add2,
        Aggregation.sort(Sort.by(orders))
    );
  }
}
