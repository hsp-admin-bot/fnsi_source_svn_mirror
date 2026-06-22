package utils;

import batch.ApplicationConst;
import org.postgresql.util.PGobject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import web.config.EventLoggerUtil;
import web.logger.EventLogMessage;
import web.logger.LogLevel;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;
@Component
public class MasterDataService {



    @Autowired
    @Qualifier(ApplicationConst.JdbcTempleteName.JDBC_TEMPLATE_CONVERT)
    private JdbcTemplate jdbcTemplateNkkConvert;

    @Autowired
    private EventLoggerUtil eventLoggerUtil;


    /**
     * 初始化（只调用一次）
     */
    public void loadIfNeeded(String facilityCd,GlobalContext globalContext) {
        if (globalContext.loaded) return;
        try {
            loadPatIdMap(facilityCd,globalContext);
            loadBedCdMap(facilityCd,globalContext);
            loadWeightCdMap(facilityCd,globalContext);
            loadKurCdMap(facilityCd,globalContext);
            loadMachineNoMap(facilityCd,globalContext);
            loadTreatmentCdMap(facilityCd,globalContext);
            loadOrdNoMap(facilityCd,globalContext);
            loadWheelChairCdMap(facilityCd,globalContext);
            loadUserIdMap(facilityCd,globalContext);
            globalContext.loaded = true;
        } catch (Exception e) {
            globalContext.loaded = false;
            EventLogMessage eventLogMessage10 = eventLoggerUtil.getEventLogMessage("「ord_weight_scale関連検索失败」" + e.getMessage().toString(),
                    facilityCd, "loadIfNeeded");
            eventLoggerUtil.recordLog(facilityCd, eventLogMessage10, LogLevel.ERROR);

        }

    }

    private void loadPatIdMap(String facilityCd,GlobalContext globalContext) {

        String sql = "SELECT fn_pat_id, pat_id FROM pat_personal_main WHERE facility_cd = ?";
        List<Object> params = new ArrayList<>();
        params.add(facilityCd);
        List<Map<String, Object>> resultList = jdbcTemplateNkkConvert.queryForList(sql, params.toArray());
        globalContext.patIdMap = resultList.stream()
                .collect(Collectors.toMap(
                        row -> String.valueOf(row.get("fn_pat_id")),
                        row -> ((Number) row.get("pat_id")).intValue(),
                        (existing, replacement) -> existing
                ));
    }

    private void loadBedCdMap(String facilityCd,GlobalContext globalContext)   {
        String sql = "SELECT fn_bed_no, bed_cd FROM mst_bed WHERE facility_cd = ?";
        List<Object> params = new ArrayList<>();
        params.add(facilityCd);
        List<Map<String, Object>> resultList = jdbcTemplateNkkConvert.queryForList(sql, params.toArray());
        globalContext.bedCdMap = resultList.stream()
                .collect(Collectors.toMap(
                        row -> String.valueOf(row.get("fn_bed_no")),
                        row -> ((Number) row.get("bed_cd")).intValue(),
                        (existing, replacement) -> existing
                ));
    }


    private void loadWeightCdMap(String facilityCd,GlobalContext globalContext)   {
        String sql = "SELECT weight_no, weight_cd FROM mst_weight WHERE facility_cd = ?";
        List<Object> params = new ArrayList<>();
        params.add(facilityCd);
        List<Map<String, Object>> resultList = jdbcTemplateNkkConvert.queryForList(sql, params.toArray());
        globalContext.weightCdMap = resultList.stream()
                .collect(Collectors.toMap(
                        row -> String.valueOf(row.get("weight_no")),
                        row -> ((Number) row.get("weight_cd")).intValue(),
                        (existing, replacement) -> existing
                ));
    }

    private void loadKurCdMap(String facilityCd,GlobalContext globalContext)   {
        String sql = "SELECT fn_kur_cd, kur_cd FROM mst_kur WHERE facility_cd = ?";
        List<Object> params = new ArrayList<>();
        params.add(facilityCd);
        List<Map<String, Object>> resultList = jdbcTemplateNkkConvert.queryForList(sql, params.toArray());
        globalContext.kurCdMap = resultList.stream()
                .collect(Collectors.toMap(
                        row -> String.valueOf(row.get("fn_kur_cd")),
                        row -> ((Number) row.get("kur_cd")).intValue(),
                        (existing, replacement) -> existing
                ));
    }


    private void loadMachineNoMap(String facilityCd,GlobalContext globalContext)   {
        String sql = "SELECT fn_device_no,machine_no FROM mst_machine WHERE facility_cd= ?";
        List<Object> params = new ArrayList<>();
        params.add(facilityCd);
        List<Map<String, Object>> resultList = jdbcTemplateNkkConvert.queryForList(sql, params.toArray());
        globalContext.machineNoMap = resultList.stream()
                .collect(Collectors.toMap(
                        row -> String.valueOf(row.get("fn_device_no")),
                        row -> ((Number) row.get("machine_no")).intValue(),
                        (existing, replacement) -> existing
                ));
    }

    private void loadTreatmentCdMap(String facilityCd,GlobalContext globalContext)   {
        String sql = "SELECT fn_treatment_cd,treatment_cd FROM mst_treatment WHERE facility_cd= ?";
        List<Object> params = new ArrayList<>();
        params.add(facilityCd);
        List<Map<String, Object>> resultList = jdbcTemplateNkkConvert.queryForList(sql, params.toArray());
        globalContext.treatmentCdMap = resultList.stream()
                .collect(Collectors.toMap(
                        row -> String.valueOf(row.get("fn_treatment_cd")),
                        row -> ((Number) row.get("treatment_cd")).intValue(),
                        (existing, replacement) -> existing
                ));
    }

    private void loadOrdNoMap(String facilityCd,GlobalContext globalContext)   {
        String sql = "SELECT rst_fn_dialysis_no,ord_no FROM ord_main WHERE facility_cd= ?";
        List<Object> params = new ArrayList<>();
        params.add(facilityCd);
        List<Map<String, Object>> resultList = jdbcTemplateNkkConvert.queryForList(sql, params.toArray());
        globalContext.ordNoMap = resultList.stream()
                .collect(Collectors.toMap(
                        row -> String.valueOf(row.get("rst_fn_dialysis_no")),
                        row -> ((Number) row.get("ord_no")).intValue(),
                        (existing, replacement) -> existing
                ));
    }

    private void loadWheelChairCdMap(String facilityCd,GlobalContext globalContext)   {
        String sql = "SELECT fn_wheel_chair_cd,wheel_chair_cd FROM mst_wheel_chair WHERE facility_cd= ?";
        List<Object> params = new ArrayList<>();
        params.add(facilityCd);
        List<Map<String, Object>> resultList = jdbcTemplateNkkConvert.queryForList(sql, params.toArray());
        globalContext.wheelChairCdMap  = resultList.stream()
                .collect(Collectors.toMap(
                        row -> String.valueOf(row.get("fn_wheel_chair_cd")),
                        row -> ((Number) row.get("wheel_chair_cd")).intValue(),
                        (existing, replacement) -> existing
                ));
    }

    private void loadUserIdMap(String facilityCd,GlobalContext globalContext)   {
        String sql = "SELECT fn_staff_cd,user_id FROM mst_personal_user WHERE facility_cd= ?";
        List<Object> params = new ArrayList<>();
        params.add(facilityCd);
        List<Map<String, Object>> resultList = jdbcTemplateNkkConvert.queryForList(sql, params.toArray());
        globalContext.userIdMap  = resultList.stream()
                .collect(Collectors.toMap(
                        row -> String.valueOf(row.get("fn_staff_cd")),
                        row -> ((Number) row.get("user_id")).intValue(),
                        (existing, replacement) -> existing
                ));
    }


    /**
     * 获取 pat_id
     */
    public Integer getPatId(String fnPatIdStr,Map<String, Integer> patIdMap) {
        if (fnPatIdStr == null || fnPatIdStr.isEmpty()) return null;
        return patIdMap.get(fnPatIdStr);
    }

    /**
     * 获取 bed_cd
     */
    public Integer getBedCd(String fnBedNoStr,Map<String, Integer> bedCdMap) {
        if (fnBedNoStr == null || fnBedNoStr.isEmpty()) return null;
        return bedCdMap.get(fnBedNoStr);
    }
    /**
     * 获取 weight_cd
     */
    public Integer getWeightCd(String fnWeightNoStr,Map<String, Integer> weightCdMap) {
        if (fnWeightNoStr == null || fnWeightNoStr.isEmpty()) return null;
        return weightCdMap.get(fnWeightNoStr);
    }
    /**
     * 获取 kur_cd
     */
    public Integer getKurCd(String fnKurNoStr,Map<String, Integer> kurCdMap) {
        if (fnKurNoStr == null || fnKurNoStr.isEmpty()) return null;
        return kurCdMap.get(fnKurNoStr);
    }

    /**
     * 获取 machine_no
     */
    public Integer getMachineNo(String fnDeviceNoStr,Map<String, Integer> machineNoMap) {
        if (fnDeviceNoStr == null || fnDeviceNoStr.isEmpty()) return null;
        return machineNoMap.get(fnDeviceNoStr);
    }

    /**
     * 获取 treatment_cd
     */
    public Integer getTreatmentCd(String fnTreatmentCDStr,Map<String, Integer> treatmentCdMap) {
        if (fnTreatmentCDStr == null || fnTreatmentCDStr.isEmpty()) return null;
        return treatmentCdMap.get(fnTreatmentCDStr);
    }

    /**
     * 获取 ord_no
     */
    public Integer getOrdNo(String RstFnDialysisNoStr,Map<String, Integer> ordNoMap) {
        if (RstFnDialysisNoStr == null || RstFnDialysisNoStr.isEmpty()) return null;
        return ordNoMap.get(RstFnDialysisNoStr);
    }

    /**
     * 获取 wheel_chair_cd
     */
    public Integer getWheelChairCd(String fnWheelChairCd,Map<String, Integer> wheelChairCdMap) {
        if (fnWheelChairCd == null || fnWheelChairCd.isEmpty()) return null;
        return wheelChairCdMap.get(fnWheelChairCd);
    }

    /**
     * 获取 user_id
     */
    public Integer getUserId(String fnStaffCd,Map<String, Integer> userIdMap) {
        if (fnStaffCd == null || fnStaffCd.isEmpty()) return null;
        return userIdMap.get(fnStaffCd);
    }


    public static Integer parseToInteger(String fnPatIdStr, String DeviceModeStr) {

        if (fnPatIdStr == null || fnPatIdStr.trim().isEmpty()) {
            return null;
        }

        if (DeviceModeStr == null || DeviceModeStr.trim().isEmpty()) {
            return null;
        }
        return Integer.parseInt(DeviceModeStr);
    }

    public PGobject createJsonb(String json) {
        try {
            PGobject obj = new PGobject();
            obj.setType("jsonb");
            obj.setValue(json);
            return obj;
        } catch (Exception e) {
            throw new RuntimeException("jsonb変換に失敗しました", e);
        }
    }
    public void reset(GlobalContext globalContext) {

        if (globalContext.loaded) {
            globalContext.loaded = false;
            globalContext.patIdMap.clear();
            globalContext.bedCdMap.clear();
            globalContext.weightCdMap.clear();
            globalContext.kurCdMap.clear();
            globalContext.machineNoMap.clear();
            globalContext.treatmentCdMap.clear();
            globalContext.ordNoMap.clear();
            globalContext.wheelChairCdMap.clear();
            globalContext.userIdMap.clear();
        }
    }
}
