package jp.co.nikkiso.ntss.admin_web.service.indHistory;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.Date;
import java.text.SimpleDateFormat;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.StringUtils;

import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import tools.jackson.databind.PropertyNamingStrategies;

import software.amazon.awssdk.services.dynamodb.DynamoDbClient;
import software.amazon.awssdk.services.dynamodb.model.AttributeValue;
import software.amazon.awssdk.services.dynamodb.model.PutItemRequest;
import software.amazon.awssdk.services.dynamodb.model.QueryRequest;
import software.amazon.awssdk.services.dynamodb.model.QueryResponse;

@Service
public class IndHistoryServiceDynamoImpl implements IndHistoryServiceDynamo {
  private static final String TABLE_NAME = "ind_history";
  private static final Set<String> KEY_FIELDS = Set.of("pat_id", "log_date");
  private static final Set<String> NUMERIC_FIELDS = Set.of("sort_no", "created_user_id", "updated_user_id");
  private static final ObjectMapper NON_NULL_SNAKE_CASE_MAPPER = new ObjectMapper()
      .rebuild()
      .propertyNamingStrategy(PropertyNamingStrategies.SNAKE_CASE)
      .build();
  private static final ObjectMapper SNAKE_CASE_MAPPER = new ObjectMapper()
      .rebuild()
      .propertyNamingStrategy(PropertyNamingStrategies.SNAKE_CASE)
      .build();

  private final DynamoDbClient dynamoDbClient;

  public IndHistoryServiceDynamoImpl(DynamoDbClient dynamoDbClient) {
    this.dynamoDbClient = dynamoDbClient;
  }

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
    if (params == null) {
      params = new IndHistory();
    }
    if (options == null) {
      options = new IndHistoryOptions();
    }
    if (!StringUtils.hasText(params.getPatId())) {
      return new PageImpl<>(Collections.emptyList(), pageable, 0);
    }

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
    Map<String, AttributeValue> expressionAttributes = new HashMap<String, AttributeValue>();
    expressionAttributes.put(":pat_id", stringAttribute(params.getPatId()));

    /**
     * 開始日・終了日処理
     */
    if (StringUtils.hasText(options.getLogDateStart()) && StringUtils.hasText(options.getLogDateEnd())) {
      keyExpression += " and log_date between :log_date_start and :log_date_end";

      expressionAttributes.put(":log_date_start", stringAttribute(options.getLogDateStart().replaceAll("-", "") + "000000000" ));
      expressionAttributes.put(":log_date_end", stringAttribute(options.getLogDateEnd().replaceAll("-", "") + "999999999"));
    }
    else if (StringUtils.hasText(options.getLogDateStart()) && !StringUtils.hasText(options.getLogDateEnd())) {
      keyExpression += " and log_date >= :log_date_start";

      expressionAttributes.put(":log_date_start", stringAttribute(options.getLogDateStart().replaceAll("-", "") + "000000000" ));
    }
    else if (!StringUtils.hasText(options.getLogDateStart()) && StringUtils.hasText(options.getLogDateEnd())) {
      keyExpression += " and log_date <= :log_date_end";

      expressionAttributes.put(":log_date_end", stringAttribute(options.getLogDateEnd().replaceAll("-", "") + "999999999"));
    }

    /**
     * 抽出条件処理
     * 以下はEntityの非nullフィールドをクエリ条件として処理する
     */
    Iterator<Map.Entry<String, JsonNode>> iter = NON_NULL_SNAKE_CASE_MAPPER.valueToTree(params).properties().iterator();
    Map.Entry<String, JsonNode> curr = null;

    while (iter.hasNext()) {
      curr = iter.next();
      String paramName = curr.getKey();
      String paramNameSub = ":" + paramName;
      String paramValue = curr.getValue().textValue();

      if (!curr.getValue().isNull() && StringUtils.hasText(paramValue)) {
        // その他の属性の場合、「filterExpression」に追加
        if (!KEY_FIELDS.contains(paramName) && !NUMERIC_FIELDS.contains(paramName)) {
          if (filterExpression == null) {
            filterExpression = "";
          }

          if (!filterExpression.isEmpty()) {
            filterExpression += " and ";
          }

          filterExpression += paramName + " = " + paramNameSub;
          expressionAttributes.put(paramNameSub, stringAttribute(paramValue));
        }
      }
    }

    /**
     * フリーワード処理
     */
    if(StringUtils.hasText(options.getSearchString())) {
      expressionAttributes.put(":search_string", stringAttribute(options.getSearchString()));

      if (filterExpression != null && !filterExpression.isEmpty()) {
        filterExpression += " and ";
      }
      else {
        filterExpression = "";
      }

      filterExpression += "(";

      String subFilterExpression = null;

      iter = SNAKE_CASE_MAPPER.valueToTree(params).properties().iterator();
      curr = null;

      while (iter.hasNext()) {
        curr = iter.next();
        String paramName = curr.getKey();

        if (!KEY_FIELDS.contains(paramName) && !NUMERIC_FIELDS.contains(paramName)) {
          if (subFilterExpression == null) {
            subFilterExpression = "";
          }

          if (!subFilterExpression.isEmpty()) {
            subFilterExpression += " or ";
          }


          subFilterExpression += "contains(" + paramName + ", :search_string)";
        }
      }

      if (subFilterExpression != null) {
        filterExpression += subFilterExpression + ")";
      } else {
        filterExpression = null;
      }
    }

    /**
     * クエリ作成
     */
    QueryRequest.Builder queryRequestBuilder = QueryRequest.builder()
        .tableName(TABLE_NAME)
        .keyConditionExpression(keyExpression)
        .expressionAttributeValues(expressionAttributes)
        .scanIndexForward(scanIndexForward);
    if (StringUtils.hasText(filterExpression)) {
      queryRequestBuilder.filterExpression(filterExpression);
    }

    /**
     * クエリ実行
     */
    result = queryAll(queryRequestBuilder);
    resultCount = result.size();
    if (skip >= result.size()) {
      result = Collections.emptyList();
    } else {
      result = new ArrayList<>(result.subList(skip, Math.min(result.size(), skip + limit)));
    }

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
    dynamoDbClient.putItem(PutItemRequest.builder()
        .tableName(TABLE_NAME)
        .item(toItem(params))
        .build());

    return params;
  }

  private List<IndHistory> queryAll(QueryRequest.Builder queryRequestBuilder) {
    List<IndHistory> result = new ArrayList<>();
    Map<String, AttributeValue> exclusiveStartKey = null;

    do {
      QueryRequest.Builder pageRequestBuilder = queryRequestBuilder;
      if (exclusiveStartKey != null && !exclusiveStartKey.isEmpty()) {
        pageRequestBuilder = queryRequestBuilder.exclusiveStartKey(exclusiveStartKey);
      }
      QueryResponse response = dynamoDbClient.query(pageRequestBuilder.build());
      response.items().stream()
          .map(this::fromItem)
          .forEach(result::add);
      exclusiveStartKey = response.lastEvaluatedKey();
    } while (exclusiveStartKey != null && !exclusiveStartKey.isEmpty());

    return result;
  }

  private IndHistory fromItem(Map<String, AttributeValue> item) {
    Map<String, Object> values = new HashMap<>();
    item.forEach((key, value) -> {
      if (value.s() != null) {
        values.put(key, value.s());
      } else if (value.n() != null) {
        if ("sort_no".equals(key)) {
          values.put(key, Integer.valueOf(value.n()));
        } else if ("created_user_id".equals(key) || "updated_user_id".equals(key)) {
          values.put(key, Long.valueOf(value.n()));
        } else {
          values.put(key, value.n());
        }
      }
    });
    return NON_NULL_SNAKE_CASE_MAPPER.convertValue(values, IndHistory.class);
  }

  private Map<String, AttributeValue> toItem(IndHistory params) {
    Map<String, AttributeValue> item = new HashMap<>();
    Iterator<Map.Entry<String, JsonNode>> iter = NON_NULL_SNAKE_CASE_MAPPER.valueToTree(params).properties().iterator();

    while (iter.hasNext()) {
      Map.Entry<String, JsonNode> entry = iter.next();
      JsonNode value = entry.getValue();

      if (value.isNull()) {
        continue;
      } else if (value.isNumber()) {
        item.put(entry.getKey(), numberAttribute(value.asText()));
      } else if (value.isTextual() && StringUtils.hasText(value.textValue())) {
        item.put(entry.getKey(), stringAttribute(value.textValue()));
      }
    }

    return item;
  }

  private AttributeValue stringAttribute(String value) {
    return AttributeValue.builder()
        .s(value)
        .build();
  }

  private AttributeValue numberAttribute(String value) {
    return AttributeValue.builder()
        .n(value)
        .build();
  }
}
