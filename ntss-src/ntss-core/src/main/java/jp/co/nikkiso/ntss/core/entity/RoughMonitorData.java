package jp.co.nikkiso.ntss.core.entity;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.utils.BeanBuilderUtils;
import lombok.Getter;
import lombok.Setter;
import org.apache.commons.lang3.StringUtils;
import org.springframework.util.CollectionUtils;

import java.sql.Timestamp;
import java.time.Instant;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collectors;
import java.util.stream.Stream;

public class RoughMonitorData {

  private static final ObjectMapper MAPPER = new ObjectMapper();

  private static final Short MONITOR_DT = Short.valueOf("1");
  private static final Short TREATING_DT = Short.valueOf("2");
  private static final Short RCR_DT = Short.valueOf("3");
  private static final Short TEMPERATURE_DT = Short.valueOf("4");
  private static final Short BBP_DT = Short.valueOf("5");
  private static final Short ABP_DT = Short.valueOf("6");

  /**
   * 施設コード
   */
  @Setter
  @Getter
  private String facilityCd;
  /**
   * 型式コード
   */
  @Setter
  @Getter
  private String machineTypeCd;
  /**
   * 製造番号
   */
  @Setter
  @Getter
  private String machineSerial;
  /**
   * システムで管理する一意なオーダ番号
   */
  @Setter
  @Getter
  private Long ordNo;
  /**
   * システムで管理する一意な患者ID
   */
  @Setter
  @Getter
  private Long patId;

  private List<RoughMonitorDataItem> roughMonitorDataItems;

  // #11329 【たくしん会】治療状況リストに体温が表示しない Add by Z.T Start
  // 今までのモニタデータクラクション
  @Setter
  @Getter
  private MniMonitor monitorData;

  // オーダーに紐づくモニタ情報(現在血圧)
  @Setter
  @Getter
  private MniMonitor mniMonitorNowBloodPressure;

  // オーダーに紐づくモニタ情報(前血圧)
  @Setter
  @Getter
  private MniMonitor mniMonitorBeforeBloodPressure;

  // オーダーに紐づくモニタ情報(後血圧)
  @Setter
  @Getter
  private MniMonitor mniMonitorAfterBloodPressure;

  // オーダーに紐づくモニタ情報(体温)
  @Setter
  @Getter
  private MniMonitor mniMonitorTemperaturePressure;

  // オーダーに紐づくモニタ情報(再循環率)
  @Setter
  @Getter
  private MniMonitor mniMonitorCyclePressure;
  // #11329 【たくしん会】治療状況リストに体温が表示しない Add by Z.T End

  public RoughMonitorData(MniMonitor mniMonitor) {

    if (mniMonitor != null) {
      this.facilityCd = mniMonitor.getFacilityCd();
      this.machineTypeCd = mniMonitor.getMachineTypeCd();
      this.machineSerial = mniMonitor.getMachineSerial();
      this.ordNo = mniMonitor.getOrdNo();
      this.patId = mniMonitor.getPatId();

      // There are two conversions between Map and Json, which will definitely cause performance issues.
      // We hope to optimize it in the future.
      if (StringUtils.isNotEmpty(mniMonitor.getMonitorData())) {

        try {
          this.roughMonitorDataItems =
            MAPPER.readValue(mniMonitor.getMonitorData(), new TypeReference<>() {});
        } catch (JsonProcessingException e) {
          this.roughMonitorDataItems = new ArrayList<>();
        }
      }

      // #11329 【たくしん会】治療状況リストに体温が表示しない MOD by Z.T Start
      if (!CollectionUtils.isEmpty(this.roughMonitorDataItems)) {

        Map<Short, List<RoughMonitorDataItem>> monitorDataGroupByType =
          this.roughMonitorDataItems.stream().collect(Collectors.groupingBy(RoughMonitorDataItem::getData_type));

        if (!CollectionUtils.isEmpty(monitorDataGroupByType)) {

          // sorted this monitor data list by occur date DESC
          // after data has been sorted, we just find the last un-null entity of each node, collect those value will be the result.
          // TODO 1 I suspect that parallel streams with SEQUENCE list may cause issues in the end.
          // TODO 2 I think there must be a break mechanism in this loop.

          // CASE:1
          if (monitorDataGroupByType.containsKey(MONITOR_DT)) {
            // Gol モニタデータ
            Map<String, String> monitorData = monitorDataGroupByType
              .get(MONITOR_DT)
              .stream()
              .sorted(Comparator.comparing(RoughMonitorDataItem::getOccur_date).reversed())
              .flatMap(item ->
                CollectionUtils.isEmpty(item.getMonitor_data()) ?
                  Stream.empty() : item.getMonitor_data().entrySet().stream()
              )
              .collect(
                Collectors.toMap(
                  Map.Entry::getKey, Map.Entry::getValue,
                  (existing, replacement) -> StringUtils.isEmpty(existing) ? replacement : existing
                )
              );

            // Building data
            this.setMonitorData(
              BeanBuilderUtils.of(MniMonitor::new)
                .with(MniMonitor::setFacilityCd, this.facilityCd)
                .with(MniMonitor::setMachineTypeCd, this.machineTypeCd)
                .with(MniMonitor::setMachineSerial, this.machineSerial)
                .with(MniMonitor::setOrdNo, this.ordNo)
                .with(MniMonitor::setPatId, this.patId)
                .with(MniMonitor::setDataType, MONITOR_DT)
                .with(MniMonitor::setOccurDate, this.getOccurDateFromList(monitorDataGroupByType.get(MONITOR_DT)))
                .with(MniMonitor::setMonitorData, this.getMonitorDataStrFromMap(monitorData))
                .build()
            );

          }
          // CASE:2
          if (
            monitorDataGroupByType.containsKey(TREATING_DT)
              || monitorDataGroupByType.containsKey(TEMPERATURE_DT)
              || monitorDataGroupByType.containsKey(BBP_DT)
              || monitorDataGroupByType.containsKey(ABP_DT)
          ) {

            List<RoughMonitorDataItem> concatSteamList =
              Stream.of(
                  Optional.ofNullable(monitorDataGroupByType.get(TREATING_DT)).orElse(Collections.emptyList())
                  , Optional.ofNullable(monitorDataGroupByType.get(TEMPERATURE_DT)).orElse(Collections.emptyList())
                  , Optional.ofNullable(monitorDataGroupByType.get(BBP_DT)).orElse(Collections.emptyList())
                  , Optional.ofNullable(monitorDataGroupByType.get(ABP_DT)).orElse(Collections.emptyList())
                )
                .flatMap(Collection::stream)
                .toList();

            Map<String, String> monitorData = concatSteamList
              .stream()
              .sorted(Comparator.comparing(RoughMonitorDataItem::getOccur_date).reversed())
              .flatMap(item ->
                CollectionUtils.isEmpty(item.getMonitor_data()) ?
                  Stream.empty() : item.getMonitor_data().entrySet().stream())
              .collect(
                Collectors.toMap(
                  Map.Entry::getKey, Map.Entry::getValue,
                  (existing, replacement) -> StringUtils.isEmpty(existing) ? replacement : existing
                )
              );

            this.setMniMonitorNowBloodPressure(
              BeanBuilderUtils.of(MniMonitor::new)
                .with(MniMonitor::setFacilityCd, this.facilityCd)
                .with(MniMonitor::setMachineTypeCd, this.machineTypeCd)
                .with(MniMonitor::setMachineSerial, this.machineSerial)
                .with(MniMonitor::setOrdNo, this.ordNo)
                .with(MniMonitor::setPatId, this.patId)
                .with(MniMonitor::setDataType, TREATING_DT)
                .with(MniMonitor::setOccurDate, this.getOccurDateFromList(concatSteamList))
                .with(MniMonitor::setMonitorData, this.getMonitorDataStrFromMap(monitorData))
                .build()
            );
          }
          // CASE:3
          if (monitorDataGroupByType.containsKey(RCR_DT)) {

            Map<String, String> monitorData = monitorDataGroupByType
              .get(RCR_DT)
              .stream()
              .sorted(Comparator.comparing(RoughMonitorDataItem::getOccur_date).reversed())
              .flatMap(item ->
                CollectionUtils.isEmpty(item.getMonitor_data()) ?
                  Stream.empty() : item.getMonitor_data().entrySet().stream()
              )
              .collect(
                Collectors.toMap(
                  Map.Entry::getKey, Map.Entry::getValue,
                  (existing, replacement) -> StringUtils.isEmpty(existing) ? replacement : existing
                )
              );

            this.setMniMonitorCyclePressure(
              BeanBuilderUtils.of(MniMonitor::new)
                .with(MniMonitor::setFacilityCd, this.facilityCd)
                .with(MniMonitor::setMachineTypeCd, this.machineTypeCd)
                .with(MniMonitor::setMachineSerial, this.machineSerial)
                .with(MniMonitor::setOrdNo, this.ordNo)
                .with(MniMonitor::setPatId, this.patId)
                .with(MniMonitor::setDataType, RCR_DT)
                .with(MniMonitor::setOccurDate, this.getOccurDateFromList(monitorDataGroupByType.get(RCR_DT)))
                .with(MniMonitor::setMonitorData, this.getMonitorDataStrFromMap(monitorData))
                .build()
            );
          }
          // CASE:4
          if (monitorDataGroupByType.containsKey(TEMPERATURE_DT)) {
            Map<String, String> monitorData = monitorDataGroupByType
              .get(TEMPERATURE_DT)
              .stream()
              .sorted(Comparator.comparing(RoughMonitorDataItem::getOccur_date).reversed())
              .flatMap(item ->
                CollectionUtils.isEmpty(item.getMonitor_data()) ?
                  Stream.empty() : item.getMonitor_data().entrySet().stream()
              )
              .collect(
                Collectors.toMap(
                  Map.Entry::getKey, Map.Entry::getValue,
                  (existing, replacement) -> StringUtils.isEmpty(existing) ? replacement : existing
                )
              );

            this.setMniMonitorTemperaturePressure(
              BeanBuilderUtils.of(MniMonitor::new)
                .with(MniMonitor::setFacilityCd, this.facilityCd)
                .with(MniMonitor::setMachineTypeCd, this.machineTypeCd)
                .with(MniMonitor::setMachineSerial, this.machineSerial)
                .with(MniMonitor::setOrdNo, this.ordNo)
                .with(MniMonitor::setPatId, this.patId)
                .with(MniMonitor::setDataType, TEMPERATURE_DT)
                .with(MniMonitor::setOccurDate, this.getOccurDateFromList(monitorDataGroupByType.get(TEMPERATURE_DT)))
                .with(MniMonitor::setMonitorData, this.getMonitorDataStrFromMap(monitorData))
                .build()
            );
          }
          // CASE:5
          if (monitorDataGroupByType.containsKey(BBP_DT)) {

            Map<String, String> monitorData = monitorDataGroupByType
              .get(BBP_DT)
              .stream()
              .sorted(Comparator.comparing(RoughMonitorDataItem::getOccur_date).reversed())
              .flatMap(item ->
                CollectionUtils.isEmpty(item.getMonitor_data()) ?
                  Stream.empty() : item.getMonitor_data().entrySet().stream()
              )
              .collect(
                Collectors.toMap(
                  Map.Entry::getKey, Map.Entry::getValue,
                  (existing, replacement) -> StringUtils.isEmpty(existing) ? replacement : existing
                )
              );

            this.setMniMonitorBeforeBloodPressure(
              BeanBuilderUtils.of(MniMonitor::new)
                .with(MniMonitor::setFacilityCd, this.facilityCd)
                .with(MniMonitor::setMachineTypeCd, this.machineTypeCd)
                .with(MniMonitor::setMachineSerial, this.machineSerial)
                .with(MniMonitor::setOrdNo, this.ordNo)
                .with(MniMonitor::setPatId, this.patId)
                .with(MniMonitor::setDataType, BBP_DT)
                .with(MniMonitor::setOccurDate, this.getOccurDateFromList(monitorDataGroupByType.get(BBP_DT)))
                .with(MniMonitor::setMonitorData, this.getMonitorDataStrFromMap(monitorData))
                .build()
            );
          }
          // CASE:6
          if (monitorDataGroupByType.containsKey(ABP_DT)) {

            Map<String, String> monitorData = monitorDataGroupByType
              .get(ABP_DT)
              .stream()
              .sorted(Comparator.comparing(RoughMonitorDataItem::getOccur_date).reversed())
              .flatMap(item ->
                CollectionUtils.isEmpty(item.getMonitor_data()) ?
                  Stream.empty() : item.getMonitor_data().entrySet().stream()
              )
              .collect(
                Collectors.toMap(
                  Map.Entry::getKey, Map.Entry::getValue,
                  (existing, replacement) -> StringUtils.isEmpty(existing) ? replacement : existing
                )
              );

            this.setMniMonitorAfterBloodPressure(
              BeanBuilderUtils.of(MniMonitor::new)
                .with(MniMonitor::setFacilityCd, this.facilityCd)
                .with(MniMonitor::setMachineTypeCd, this.machineTypeCd)
                .with(MniMonitor::setMachineSerial, this.machineSerial)
                .with(MniMonitor::setOrdNo, this.ordNo)
                .with(MniMonitor::setPatId, this.patId)
                .with(MniMonitor::setDataType, ABP_DT)
                .with(MniMonitor::setOccurDate, this.getOccurDateFromList(monitorDataGroupByType.get(ABP_DT)))
                .with(MniMonitor::setMonitorData, this.getMonitorDataStrFromMap(monitorData))
                .build()
            );
          }
        }
      }

      // #11329 【たくしん会】治療状況リストに体温が表示しない MOD by Z.T End
    }
  }

  private Timestamp getOccurDateFromList(List<RoughMonitorDataItem> roughMonitorDataItems) {
    if (CollectionUtils.isEmpty(roughMonitorDataItems)) {
      return Timestamp.from(Instant.now());
    }

    return roughMonitorDataItems
      .stream()
      .sorted(Comparator.comparing(RoughMonitorDataItem::getOccur_date).reversed())
      .map(RoughMonitorDataItem::getOccur_date)
      .findFirst()
      .orElse(Timestamp.from(Instant.now()));
  }

  private String getMonitorDataStrFromMap(Map<String, String> monitorData) {
    if (CollectionUtils.isEmpty(monitorData)) {
      return null;
    }
    try {
      return MAPPER.writeValueAsString(monitorData);
    } catch (JsonProcessingException e) {
      return null;
    }
  }
}
