package jp.co.nikkiso.ntss.admin_web.service.indHistory;

import java.util.Iterator;
import java.util.Map;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.List;
import java.util.Date;
import java.text.SimpleDateFormat;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBMapper;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBMapperConfig;
import com.amazonaws.services.dynamodbv2.datamodeling.DynamoDBQueryExpression;
import com.amazonaws.services.dynamodbv2.model.AttributeValue;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.PropertyNamingStrategy;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.annotation.JsonInclude.Include;

// import jp.co.nikkiso.ntss.core.entity.custom.IndHistory;
// import jp.co.nikkiso.ntss.core.entity.custom.IndHistoryOptions;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndHistory;
import jp.co.nikkiso.ntss.admin_web.service.indHistory.IndHistoryOptions;

@Service
public class IndHistoryServiceDynamoImpl implements IndHistoryServiceDynamo {
  @Autowired
  DynamoDBMapper dynamoDBMapper;

  @Autowired
  DynamoDBMapperConfig dynamoDBMapperConfig;

  /**
   * DynamoDBを使用GET API
   *
   * @param pageable  ページネーション設定
   * @param params    抽出条件
   * @param options   任意検索パラメータ
   * @param pageLastEval   任意検索パラメータ
   * @return
   */
  @Override
  public Page<IndHistory> findAll(Pageable pageable, IndHistory params, IndHistoryOptions options) {
    // 取得データ
    List<IndHistory> result = new ArrayList<IndHistory>();
    // 取得データ総数
    long resultCount = 0;
    // ページネーション
    int skip = (int) pageable.getOffset();
    // 件数
    int limit = pageable.getPageSize();
    // 昇順かどうか (ソート)
    Boolean scanIndexForward = pageable.getSort().getOrderFor("logDate") != null ? pageable.getSort().getOrderFor("logDate").isAscending() : false;
    // パーティションキーとソートキーの抽出条件
    String keyExpression = "pat_id = :pat_id";
    // 属性(パーティションキーとソートキー以外)の抽出条件
    String filterExpression = null;
    // 「keyExpression」と「filterExpression」の値代入
    Map<String, AttributeValue> expressionAttributes = null;
    // (ページネーション用)最後のリクエストからの「lastEvaluatedKey」
    Map<String, AttributeValue> exclusiveStartKey = null;

    /**
     * ページネーション設定
     */
    // try {
    //   JSONObject pageLastEvalJson = new JSONObject(pageLastEval);

    //   if (pageLastEval != null && pageLastEvalJson.length() > 0) {
    //     exclusiveStartKey = new HashMap<String, AttributeValue>();
    //     exclusiveStartKey.put("pat_id", new AttributeValue(pageLastEvalJson.getString("patId")));
    //     exclusiveStartKey.put("log_date", new AttributeValue(pageLastEvalJson.getString("logDate")));
    //   }
    // } catch (Exception e) {
    //   e.printStackTrace();
    // }

    /**
     * 開始日・終了日処理
     */
    if (!StringUtils.isEmpty(options.getLogDateStart()) && !StringUtils.isEmpty(options.getLogDateEnd())) {
      keyExpression += " and log_date between :log_date_start and :log_date_end";

      if (expressionAttributes == null) {
        expressionAttributes = new HashMap<String, AttributeValue>();
      }

      expressionAttributes.put(":log_date_start", new AttributeValue(options.getLogDateStart().replaceAll("-", "") + "000000000" ));
      expressionAttributes.put(":log_date_end", new AttributeValue(options.getLogDateEnd().replaceAll("-", "") + "999999999"));
    }
    else if (!StringUtils.isEmpty(options.getLogDateStart()) && StringUtils.isEmpty(options.getLogDateEnd())) {
      keyExpression += " and log_date >= :log_date_start";

      if (expressionAttributes == null) {
        expressionAttributes = new HashMap<String, AttributeValue>();
      }

      expressionAttributes.put(":log_date_start", new AttributeValue(options.getLogDateStart().replaceAll("-", "") + "000000000" ));
    }
    else if (StringUtils.isEmpty(options.getLogDateStart()) && !StringUtils.isEmpty(options.getLogDateEnd())) {
      keyExpression += " and log_date <= :log_date_end";

      if (expressionAttributes == null) {
        expressionAttributes = new HashMap<String, AttributeValue>();
      }

      expressionAttributes.put(":log_date_end", new AttributeValue(options.getLogDateEnd().replaceAll("-", "") + "999999999"));
    }

    /**
     * 抽出条件処理
     * 以下はEntityの非nullフィールドをクエリ条件として処理する
     */
    Iterator<Map.Entry<String, JsonNode>> iter = new ObjectMapper()
        .setSerializationInclusion(Include.NON_NULL)
        .setPropertyNamingStrategy(PropertyNamingStrategy.SNAKE_CASE)
        .valueToTree(params)
        .fields();
    Map.Entry<String, JsonNode> curr = null;

    while (iter.hasNext()) {
      curr = iter.next();
      String paramName = curr.getKey();
      String paramNameSub = ":" + paramName;
      String paramValue = curr.getValue().textValue();

      if (!StringUtils.isEmpty(paramValue)) {
      // if (paramValue != "null" && paramValue != null && !paramValue.isEmpty()) {
        if (expressionAttributes == null) {
          expressionAttributes = new HashMap<String, AttributeValue>();
        }

        // その他の属性の場合、「filterExpression」に追加
        if (paramName.compareTo("pat_id") != 0 &&
            paramName.compareTo("log_date") != 0) {
          if (filterExpression == null) {
            filterExpression = "";
          }

          if (!filterExpression.isEmpty()) {
            filterExpression += " and ";
          }

          filterExpression += paramName + " = " + paramNameSub;
        }

        expressionAttributes.put(paramNameSub, new AttributeValue(paramValue));
      }
    }

    /**
     * フリーワード処理
     */
    if(!StringUtils.isEmpty(options.getSearchString())) {
      expressionAttributes.put(":search_string", new AttributeValue(options.getSearchString()));

      if (filterExpression != null && !filterExpression.isEmpty()) {
        filterExpression += " and ";
      }
      else {
        filterExpression = "";
      }

      filterExpression += "(";

      String subFilterExpression = null;

      iter = new ObjectMapper()
        .setPropertyNamingStrategy(PropertyNamingStrategy.SNAKE_CASE)
        .valueToTree(params)
        .fields();
      curr = null;

      while (iter.hasNext()) {
        curr = iter.next();
        String paramName = curr.getKey();
        String paramNameSub = ":" + paramName;
        String paramValue = curr.getValue().textValue();

        if (paramName.compareTo("pat_id") != 0 &&
            paramName.compareTo("log_date") != 0) {
          if (subFilterExpression == null) {
            subFilterExpression = "";
          }

          if (!subFilterExpression.isEmpty()) {
            subFilterExpression += " or ";
          }


          subFilterExpression += "contains(" + paramName + ", :search_string)";
        }
      }

      filterExpression += subFilterExpression + ")";
    }

    /**
     * クエリ作成
     */
    DynamoDBQueryExpression<IndHistory> queryExpression = new DynamoDBQueryExpression<IndHistory>()
        .withKeyConditionExpression(keyExpression)
        .withFilterExpression(filterExpression)
        .withExpressionAttributeValues(expressionAttributes)
        .withScanIndexForward(scanIndexForward)
        .withExclusiveStartKey(exclusiveStartKey);

    /**
     * クエリ実行
     */
    result = dynamoDBMapper.query(IndHistory.class, queryExpression, dynamoDBMapperConfig);
    result = result.subList(skip, Math.min(result.size(), skip + limit));
    resultCount = dynamoDBMapper.count(IndHistory.class, queryExpression, dynamoDBMapperConfig);

    return new PageImpl<>(result, pageable, resultCount);
  }

  /**
   * DynamoDBを使用POST(CREATE) API
   *
   * @param params
   * @return
   */
  @Transactional
  public IndHistory create(IndHistory params) {
    params.setLogDate(new SimpleDateFormat("yyyyMMddHHmmssSSS").format(new Date()));
    dynamoDBMapper.save(params);

    return params;
  }
}
