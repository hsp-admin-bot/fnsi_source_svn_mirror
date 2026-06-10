package jp.co.nikkiso.ntss.admin_web.service.MstListCompose;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.dao.MasterDao;
import jp.co.nikkiso.ntss.core.dto.MstListCompose.request.*;
import jp.co.nikkiso.ntss.core.dto.MstListCompose.response.MstListComposeResponse;
import jp.co.nikkiso.ntss.core.dto.MstListCompose.response.MstListComposeWrapper;

import org.springframework.context.ApplicationContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.stream.Collectors;

@Service
public class MstListComposeServiceImpl implements MstListComposeService {

  @Autowired
  private ApplicationContext applicationContext;

  @Override
  public MstListComposeResponse selectMstListCompose(MstListComposeRequest request) {
    Map<String, MstListComposeWrapper> out = new LinkedHashMap<>();
    if (request == null || request.getLists() == null) {
      MstListComposeResponse resp = new MstListComposeResponse();
      resp.setLists(out);
      return resp;
    }

    for (MstListComposeSpec spec : request.getLists()) {
      List<Map<String, Object>> rows = fetchBySpec(spec);
      // リストレベルのキー・マッピング（各ソースごとのマッピング後に実行）
      if (spec.getKeyMapping() != null && !spec.getKeyMapping().isEmpty()) {
        applyKeyMapping(rows, spec.getKeyMapping());
      }

      MstListComposeWrapper w = new MstListComposeWrapper();
      w.setId(spec.getId());
      w.setName(spec.getName());
      w.setItems(rows);
      out.put(spec.getId(), w);
    }

    MstListComposeResponse resp = new MstListComposeResponse();
    resp.setLists(out);

    ObjectMapper mapper = new ObjectMapper();

    try {
      InvestigateLogUtils.info("12441", mapper.writerWithDefaultPrettyPrinter().writeValueAsString(out), "12441");
    } catch (JsonProcessingException e) {
      throw new RuntimeException(e);
    }

    return resp;
  }
  /**
   * ListSpec に基づいてデータ行を取得する（キー・マッピングは行わない）
   */
  private List<Map<String, Object>> fetchBySpec(
    MstListComposeSpec spec
  ) {
    if (spec == null) return Collections.emptyList();

    switch (spec.getSourceType()) {

      case FIXED:
        return fetchFixed(spec);

      case MST:
        return fetchMst(spec);

      case MST_COMBINED:
        return fetchCombined(spec);

      case MAIN_DISTINCT:
        return fetchMainDistinct(spec);

      default:
        return Collections.emptyList();
    }
  }

  // FIXED
  private List<Map<String, Object>> fetchFixed(MstListComposeSpec spec) {
    if (spec.getFixedItems() == null) return Collections.emptyList();
    return spec.getFixedItems().stream()
      .map(m -> new LinkedHashMap<>(m))
      .collect(Collectors.toList());
  }

  // MST（単一ソース）
  private List<Map<String, Object>> fetchMst(MstListComposeSpec spec) {
    MstListComposeSource src = spec.getMstSource();
    if (src == null || src.getMstCode() == null) return Collections.emptyList();
    List<Map<String, Object>> rows = safeSelect(src.getMstCode(), src.getSqlParams());
    // 後続処理で利用するため、sourceTag を注入する（存在する場合）
    if (src.getSourceTag() != null) {
      for (Map<String, Object> r : rows) r.put("_sourceTag", src.getSourceTag());
    }
    // per-source keyMapping
    if (src.getKeyMapping() != null && !src.getKeyMapping().isEmpty()) {
      applyKeyMapping(rows, src.getKeyMapping());
    }
    return rows;
  }

  // MST_COMBINED（複数ソース統合）
  private List<Map<String, Object>> fetchCombined(MstListComposeSpec spec) {
    if (spec.getMstSourceList() == null || spec.getMstSourceList().isEmpty()) return Collections.emptyList();
    List<Map<String, Object>> acc = new ArrayList<>();
    for (MstListComposeSource src : spec.getMstSourceList()) {
      if (src == null || src.getMstCode() == null) continue;
      List<Map<String, Object>> part = safeSelect(src.getMstCode(), src.getSqlParams());
      if (src.getSourceTag() != null) {
        for (Map<String, Object> r : part) r.put("_sourceTag", src.getSourceTag());
      }
      if (src.getKeyMapping() != null && !src.getKeyMapping().isEmpty()) {
        applyKeyMapping(part, src.getKeyMapping());
      }
      acc.addAll(part);
    }
    // spec に fixedItems が定義されている場合は、あわせて追加する
    if (spec.getFixedItems() != null && !spec.getFixedItems().isEmpty()) {
      for (Map<String,Object> f : spec.getFixedItems()) acc.add(new LinkedHashMap<>(f));
    }
    return acc;
  }

  /**
   * MAIN_DISTINCT：
   * ・mstSource が指定されている場合（単一ソースかつ distinctField を持つ）：
   *   当該ソースに対して重複排除を行い、結果を返却する。
   *
   * ・mstCodes が指定されている場合（複数ソース）：
   *   各ソースごとに重複排除を実施する（source.distinctField が設定されている場合）。
   *   その後、ソース識別子を付与したうえで統合し返却する
   *   （フロントエンド側で key により分割可能）。
   *
   * 推奨：
   * 複数の distinct リストを個別に取得したい場合は、
   * 各 distinct リストごとに個別の ListSpec を発行することを推奨する。
   */
  private List<Map<String,Object>> fetchMainDistinct(MstListComposeSpec spec) {
    List<Map<String,Object>> acc = new ArrayList<>();

    // 単一ソースを優先的に処理する
    if (spec.getMstSource() != null) {
      MstListComposeSource src = spec.getMstSource();
      if (src.getMstCode() == null) return Collections.emptyList();
      List<Map<String,Object>> rows = safeSelect(src.getMstCode(), src.getSqlParams());
      // sourceTag を付与する
      if (src.getSourceTag() != null) for (Map<String,Object> r : rows) r.put("_sourceTag", src.getSourceTag());
      // distinctField が存在する場合は、当該フィールドを基準に重複排除を行う
      if (src.getDistinctField() != null && !src.getDistinctField().isBlank()) {
        rows = deduplicate(rows, src.getDistinctField());
      }
      // per-source keyMapping
      if (src.getKeyMapping() != null && !src.getKeyMapping().isEmpty()) {
        return applyKeyMappingDistinct(rows, src.getKeyMapping());
      }
      return rows;
    }

    // 複数ソースの場合：各ソースごとにデータ取得および重複排除を実施し、その後統合する
    if (spec.getMstSourceList() != null && !spec.getMstSourceList().isEmpty()) {
      for (MstListComposeSource src : spec.getMstSourceList()) {
        if (src == null || src.getMstCode() == null) continue;
        List<Map<String,Object>> rows = safeSelect(src.getMstCode(), src.getSqlParams());
        if (src.getSourceTag() != null) for (Map<String,Object> r : rows) r.put("_sourceTag", src.getSourceTag());
        if (src.getDistinctField() != null && !src.getDistinctField().isBlank()) {
          rows = deduplicate(rows, src.getDistinctField());
        }
        if (src.getKeyMapping() != null && !src.getKeyMapping().isEmpty()) {
          acc.addAll(applyKeyMappingDistinct(rows, src.getKeyMapping()));
        } else {
          acc.addAll(rows);
        }
      }
      // 注意：ここでは全ソースの distinct 結果を一つに統合して返却する。フロントエンド側では key（例：sourceTag / key_xxx）により分割可能。
      return acc;
    }

    return Collections.emptyList();
  }

  private List<Map<String,Object>> safeSelect(String mstCode, Map<String,String> params) {
    try {
      Map<String,String> p = params == null ? Collections.emptyMap() : params;
      List<Map<String,Object>> rows = selectByMstCode(mstCode, p);
      List<Map<String,Object>> cp = new ArrayList<>(rows.size());
      for (Map<String,Object> r : rows) cp.add(new LinkedHashMap<>(r));
      return cp;
    } catch (Exception ex) {
      return Collections.emptyList();
    }
  }

  private List<Map<String,Object>> deduplicate(List<Map<String,Object>> rows, String field) {
    if (rows == null || rows.isEmpty() || field == null || field.isBlank()) return Collections.emptyList();
    LinkedHashMap<String, Map<String,Object>> uniq = new LinkedHashMap<>();
    for (Map<String,Object> r : rows) {
      Object v = r.get(field);
      String k = v == null ? "__NULL__" : String.valueOf(v);
      if (!uniq.containsKey(k)) uniq.put(k, new LinkedHashMap<>(r));
    }
    return new ArrayList<>(uniq.values());
  }

  private void applyKeyMapping(List<Map<String,Object>> rows, List<MstListComposeKeyMapping> mappings) {
    if (rows == null || rows.isEmpty() || mappings == null || mappings.isEmpty()) return;
    for (Map<String,Object> r : rows) {
      for (MstListComposeKeyMapping km : mappings) {
        Object val = resolveKeyValue(r, km.getValueFrom());
        r.put(km.getKeyName(), val);
      }
    }
  }

  private List<Map<String,Object>> applyKeyMappingDistinct(List<Map<String,Object>> rows, List<MstListComposeKeyMapping> mappings) {
    if (rows == null || rows.isEmpty() || mappings == null || mappings.isEmpty()) return rows;
    List<Map<String,Object>> rowsDistinct = new ArrayList<>();
    for (Map<String,Object> r : rows) {
      Map<String,Object> r_distinct = new LinkedHashMap<>();
      for (MstListComposeKeyMapping km : mappings) {
        Object val = resolveKeyValue(r, km.getValueFrom());
        r_distinct.put(km.getKeyName(), val);
      }
      rowsDistinct.add(r_distinct);
    }
    return rowsDistinct;
  }

  private Object resolveKeyValue(Map<String,Object> row, String valueFrom) {
    if (valueFrom == null) return null;
    if (valueFrom.startsWith("literal:")) return valueFrom.substring("literal:".length());
    if ("sourceTag".equals(valueFrom)) return row.get("_sourceTag");
    return row.get(valueFrom);
  }

  private List<Map<String, Object>> selectByMstCode(
    String mstCode,
    Map<String,String> sqlParams
  ) {
    MasterDao bean = applicationContext.getBean(mstCode, MasterDao.class);
    if (bean == null) return Collections.emptyList();
    return bean.selectAllStatus(sqlParams);
  }
}
