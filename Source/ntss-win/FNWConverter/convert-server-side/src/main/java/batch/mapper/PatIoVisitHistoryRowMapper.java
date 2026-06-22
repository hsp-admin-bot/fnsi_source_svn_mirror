package batch.mapper;

import batch.entity.InOutVisitHistoryInfoEntity;
import tools.jackson.databind.ObjectMapper;
import org.springframework.jdbc.core.RowMapper;

import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;
import java.util.stream.Collectors;

public class PatIoVisitHistoryRowMapper implements RowMapper<Map.Entry<String, List<InOutVisitHistoryInfoEntity>>> {

    private static final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public Map.Entry<String, List<InOutVisitHistoryInfoEntity>> mapRow(ResultSet rs, int rowNum) throws SQLException {
        String patId = rs.getString("pat_id");
        String historyJson = rs.getString("in_out_visit_history_info");

        List<InOutVisitHistoryInfoEntity> historyList = new ArrayList<>();
        if (historyJson != null && !historyJson.trim().isEmpty()) {
            try {

                historyList = Arrays.asList(objectMapper.readValue(historyJson, InOutVisitHistoryInfoEntity[].class));

                boolean shouldClearList = historyList.stream()
                        .anyMatch(entity -> "11".equals(entity.getMove_in_out()) || entity.getIn_out() == 2);

                if (shouldClearList) {
                    historyList = List.of();
                } else {
                    historyList = historyList.stream()
                            .filter(entity -> Objects.nonNull(entity.getPeriod_start_date()))
                            .collect(Collectors.toList());
                    historyList.sort(null);
                }

            } catch (Exception e) {
                throw new RuntimeException("Failed to parse JSON", e);
            }
        }

        return new AbstractMap.SimpleEntry<>(patId, historyList);
    }
}
