package com.fnsi.cloudconverter.mapping.pk;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.PreparedStatementCreator;
import org.springframework.jdbc.core.RowCallbackHandler;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;

/**
 * PK マッピングサービス実装 — convert_db の pk_mapping 分区テーブルを操作
 * 参照: 03_module.md § Module 5 / 04_database.md § 2.4
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class PkMappingServiceImpl implements PkMappingService {

    private static final int PK_MAPPING_BATCH_SIZE = 5_000;

    @Qualifier("converterJdbc")
    private final JdbcTemplate converterJdbc;

    @Override
    @Transactional
    public void insertBatch(String tableName, List<Long> oldIds, List<Long> newIds, long jobId) {
        if (oldIds.size() != newIds.size()) {
            throw new IllegalArgumentException("oldIds と newIds のサイズが一致しません");
        }
        // ON CONFLICT で旧ジョブの残留データを上書き（pk_mapping_pkey は (table_name, old_id)）
        String sql = "INSERT INTO pk_mapping (table_name, old_id, new_id, job_id) VALUES (?,?,?,?)"
                   + " ON CONFLICT (table_name, old_id) DO UPDATE SET new_id = EXCLUDED.new_id, job_id = EXCLUDED.job_id";
        for (int start = 0; start < oldIds.size(); start += PK_MAPPING_BATCH_SIZE) {
            int end = Math.min(start + PK_MAPPING_BATCH_SIZE, oldIds.size());
            List<Object[]> batchArgs = new ArrayList<>(end - start);
            for (int i = start; i < end; i++) {
                batchArgs.add(new Object[]{tableName, oldIds.get(i), newIds.get(i), jobId});
            }
            converterJdbc.batchUpdate(sql, batchArgs);
        }
        log.debug("[PK_MAP] INSERT 完了: table={}, count={}", tableName, oldIds.size());
    }

    @Override
    public Optional<Long> findNewId(String tableName, long oldId) {
        List<Long> result = converterJdbc.queryForList(
                "SELECT new_id FROM pk_mapping WHERE table_name = ? AND old_id = ?",
                Long.class, tableName, oldId);
        return result.isEmpty() ? Optional.empty() : Optional.of(result.getFirst());
    }

    @Override
    public Map<Long, Long> findAllMappings(String tableName) {
        Map<Long, Long> map = new LinkedHashMap<>();
        converterJdbc.query(
                "SELECT old_id, new_id FROM pk_mapping WHERE table_name = ?",
                rs -> {
                    map.put(rs.getLong("old_id"), rs.getLong("new_id"));
                },
                tableName);
        return map;
    }

    @Override
    public Map<Long, Long> findMappings(String tableName, List<Long> oldIds) {
        Map<Long, Long> map = new LinkedHashMap<>();
        if (oldIds == null || oldIds.isEmpty()) {
            return map;
        }
        for (int start = 0; start < oldIds.size(); start += PK_MAPPING_BATCH_SIZE) {
            int end = Math.min(start + PK_MAPPING_BATCH_SIZE, oldIds.size());
            List<Long> oldIdBatch = oldIds.subList(start, end);
            converterJdbc.query((PreparedStatementCreator) con -> {
                var ps = con.prepareStatement(
                        "SELECT old_id, new_id FROM pk_mapping WHERE table_name = ? AND old_id = ANY(?::bigint[])");
                ps.setString(1, tableName);
                ps.setArray(2, con.createArrayOf("bigint", oldIdBatch.toArray(new Long[0])));
                return ps;
            }, (RowCallbackHandler) rs -> map.put(rs.getLong("old_id"), rs.getLong("new_id")));
        }
        return map;
    }

    @Override
    @Transactional
    public void generateFromStartSeq(String tableName, List<Long> oldIds, long startSeq, long jobId) {
        for (int start = 0; start < oldIds.size(); start += PK_MAPPING_BATCH_SIZE) {
            int end = Math.min(start + PK_MAPPING_BATCH_SIZE, oldIds.size());
            List<Long> oldIdBatch = oldIds.subList(start, end);
            List<Long> newIdBatch = new ArrayList<>(end - start);
            for (int i = start; i < end; i++) {
                newIdBatch.add(startSeq + i);
            }
            insertBatch(tableName, oldIdBatch, newIdBatch, jobId);
        }
    }

    @Override
    @Transactional
    public void deleteByJobId(long jobId) {
        int deleted = converterJdbc.update(
                "DELETE FROM pk_mapping WHERE job_id = ?", jobId);
        log.debug("[PK_MAP] クリーンアップ: jobId={}, deleted={}", jobId, deleted);
    }
}
