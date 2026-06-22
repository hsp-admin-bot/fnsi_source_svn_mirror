package jp.co.nikkiso.ntss.admin_web.service.bvms;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import jp.co.nikkiso.ntss.api.model.HighchartGenerateModel;
import jp.co.nikkiso.ntss.api.service.LogService;
import jp.co.nikkiso.ntss.api.service.RenderPoolService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSFilterDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.CoordinateDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.bv.BVGraph1CoordinateDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.bv.BVGraph2CoordinateDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.bv.BVGraphDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ddm.DDMGraph1CoordinateDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ddm.DDMGraph2CoordinateDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ddm.DDMGraphDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ht.HtGraph1CoordinateDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ht.HtGraph2CoordinateDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ht.HtGraphDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.rr.RRGraphCoordinateDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.rr.RRGraphDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.rr.RRGraphFilterDTO;
import jp.co.nikkiso.ntss.api.service.report.ReportChartService.ChartImageType;
import jp.co.nikkiso.ntss.api.service.utils.TmpFileService;
import jp.co.nikkiso.ntss.core.dao.TreatmentRecordDao;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

@Service
public class BVMSReportChartServiceImpl implements BVMSReportChartService {

    @Autowired
    TreatmentRecordDao treatmentRecordDao;

    @Autowired
    ResourceLoader resourceLoader;

    @Autowired
    LogService logService;

    @Autowired
    TmpFileService tmpFileService;

    private final RenderPoolService pool;

    public BVMSReportChartServiceImpl(RenderPoolService pool) {
    this.pool = pool;
  }

    @Value("${ntss.report.createTmpDir}")
    private String createTmpDir;

    private static final int EVENT_1 = 1;
    private static final int EVENT_2 = 2;
    private static final int EVENT_3 = 3;
    private static final int EVENT_4 = 4;
    private static final int EVENT_5 = 5;
    private static final int EVENT_99 = 99;
    private static final int EVENT_100 = 100;

    private static Map<Integer, String> initEventMap() {
        Map<Integer, String> map = new HashMap<>();
        map.put(EVENT_1, "ΔBV初期化");
        map.put(EVENT_2, "除水停止");
        map.put(EVENT_3, "除水開始");
        map.put(EVENT_4, "再循環率測定開始");
        map.put(EVENT_5, "再循環率測定終了");
        map.put(EVENT_99, "その他");
        map.put(EVENT_100, "複数イベント");
        return Collections.unmodifiableMap(map);
    }

    /**
     * グラフ時間軸のデフォルト値.
     */

    @Override
    public List<byte[]> getBVChart(Long ordNo, ChartImageType type, BVGraphDTO dto, BVMSFilterDTO filter) {
        List<byte[]> chartData = new ArrayList<>();
        String json1 = createJsonForBVChart1(dto.getGraph1Coordinates(), filter);
        String json2 = createJsonForBVChart2(dto.getGraph2Coordinates(), filter);
        chartData.addAll(buildChartData(type, json1));
        chartData.addAll(buildChartData(type, json2));
        return chartData;
    }

    @Override
    public List<byte[]> getDDMChart(Long ordNo, ChartImageType type, DDMGraphDTO dto, BVMSFilterDTO filter) {
        List<byte[]> chartData = new ArrayList<>();
        String json1 = createJsonForDDMChart1(dto.getGraph1Coordinates(), filter);
        String json2 = createJsonForDDMChart2(dto.getGraph2Coordinates(), filter);
        chartData.addAll(buildChartData(type, json1));
        chartData.addAll(buildChartData(type, json2));
        return chartData;
    }

    @Override
    public List<byte[]> getHtChart(Long ordNo, ChartImageType type, HtGraphDTO dto, BVMSFilterDTO filter) {
        List<byte[]> chartData = new ArrayList<>();
        String json1 = createJsonForHtChart1(dto.getGraph1Coordinates(), filter);
        String json2 = createJsonForHtChart2(dto.getGraph2Coordinates(), filter);
        chartData.addAll(buildChartData(type, json1));
        chartData.addAll(buildChartData(type, json2));
        return chartData;
    }

    @Override
    public List<byte[]> getRRChart(Long ordNo, ChartImageType type, RRGraphDTO dto, RRGraphFilterDTO filter) {
        String json = createJsonForRRChart(dto.getGraphCoordinates(), filter);
        return buildChartData(type, json);
    }

    private String createJsonForBVChart1(BVGraph1CoordinateDTO dto, BVMSFilterDTO filter) {

        long startTime = getStartTime(dto.getDBVs());
        // プロットデータ作成
        List<String> tickPositions = new ArrayList<>();
        List<String> dBV = dto.getDBVs().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        List<String> dBVBaseValue = dto.getDBVBaseValues().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        List<String> dBVReferenceAreaUpperLimit = dto.getDBVReferenceAreaUpperLimits().stream()
                .filter(e -> e.getYAxis() != null).map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis()))
                .collect(Collectors.toList());

        List<String> dBVReferenceAreaLowerLimit = dto.getDBVReferenceAreaLowerLimits().stream()
                .filter(e -> e.getYAxis() != null).map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis()))
                .collect(Collectors.toList());
        List<String> dBVAVR5min = dto.getDBVAVR5mins().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        List<String> sysBP = dto.getSysBPs().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        List<String> diaBP = dto.getDiaBPs().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        List<String> pulse = dto.getPulses().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        List<String> event1 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_1))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());

        List<String> event2 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_2))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());

        List<String> event3 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_3))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());

        List<String> event4 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_4))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());

        List<String> event5 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_5))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());

        List<String> event99 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_99))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());

        List<String> event100 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_100))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());
        // グラフの左端を調整するためにダミーデータを追加
        if (startTime != 0) {
            dBV.add(0, String.format("[%d, null]", startTime));
        }

        // JSONテンプレートを取得
        String template;
        try {
            URL url = resourceLoader.getResource("classpath:report/bv1.chart-template.json").getURL();
            try (InputStream is = url.openStream(); ByteArrayOutputStream os = new ByteArrayOutputStream();) {

                byte[] buffer = new byte[1024];
                int len = is.read(buffer);
                while (len >= 0) {
                    os.write(buffer, 0, len);
                    len = is.read(buffer);
                }
                template = new String(os.toByteArray(), StandardCharsets.UTF_8);
            }
        } catch (IOException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
            // テンプレートが取得できなかった場合は空文字列を返す
            return "";
        }

        // テンプレートにプロットデータを埋め込んで返す
        return template.replace("#tickPositions#", String.join(",", tickPositions))
                .replace("#dBV#", String.join(",", dBV)).replace("#dBVBaseValue#", String.join(",", dBVBaseValue))
                .replace("#dBVReferenceAreaUpperLimit#", String.join(",", dBVReferenceAreaUpperLimit))
                .replace("#dBVReferenceAreaLowerLimit#", String.join(",", dBVReferenceAreaLowerLimit))
                .replace("#dBVAVR5min#", String.join(",", dBVAVR5min)).replace("#sysBP#", String.join(",", sysBP))
                .replace("#diaBP#", String.join(",", diaBP)).replace("#pulse#", String.join(",", pulse))
                .replace("#event1#", String.join(",", event1)).replace("#event2#", String.join(",", event2))
                .replace("#event3#", String.join(",", event3)).replace("#event4#", String.join(",", event4))
                .replace("#event5#", String.join(",", event5)).replace("#event99#", String.join(",", event99))
                .replace("#event100#", String.join(",", event100))
                .replace("#Y1From#", filter.getGraph1Y1From().toString())
                .replace("#Y1To#", filter.getGraph1Y1To().toString())
                .replace("#Y2From#", filter.getGraph1Y2From().toString())
                .replace("#Y2To#", filter.getGraph1Y2To().toString());
    }

    private String createJsonForBVChart2(BVGraph2CoordinateDTO dto, BVMSFilterDTO filter) {
        long startTime = getStartTime(dto.getUFPSpeeds());
        // プロットデータ作成
        List<String> tickPositions = new ArrayList<>();
        List<String> uFPSpeed = dto.getUFPSpeeds().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        List<String> pRR = dto.getPRRs().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        List<String> totalCond = dto.getTotalConds().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        // グラフの左端を調整するためにダミーデータを追加
        if (startTime != 0) {
            uFPSpeed.add(0, String.format("[%d, null]", startTime));
        }

        // JSONテンプレートを取得
        String template;
        try {
            URL url = resourceLoader.getResource("classpath:report/bv2.chart-template.json").getURL();
            try (InputStream is = url.openStream(); ByteArrayOutputStream os = new ByteArrayOutputStream();) {

                byte[] buffer = new byte[1024];
                int len = is.read(buffer);
                while (len >= 0) {
                    os.write(buffer, 0, len);
                    len = is.read(buffer);
                }
                template = new String(os.toByteArray(), StandardCharsets.UTF_8);
            }
        } catch (IOException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
            // テンプレートが取得できなかった場合は空文字列を返す
            return "";
        }

        // テンプレートにプロットデータを埋め込んで返す
        return template.replace("#tickPositions#", String.join(",", tickPositions))
                .replace("#uFPSpeed#", String.join(",", uFPSpeed)).replace("#pRR#", String.join(",", pRR))
                .replace("#totalCond#", String.join(",", totalCond))
                .replace("#Y1From#", filter.getGraph2Y1From().toString())
                .replace("#Y1To#", filter.getGraph2Y1To().toString())
                .replace("#Y2From#", filter.getGraph2Y2From().toString())
                .replace("#Y2To#", filter.getGraph2Y2To().toString());
    }

    private String createJsonForDDMChart1(DDMGraph1CoordinateDTO dto, BVMSFilterDTO filter) {
        long startTime = getStartTime(dto.getKtVs());
        // プロットデータ作成
        List<String> tickPositions = new ArrayList<>();
        List<String> ktV = dto.getKtVs().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        List<String> uRR = dto.getURRs().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        List<String> event1 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_1))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());

        List<String> event2 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_2))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());

        List<String> event3 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_3))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());

        List<String> event4 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_4))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());

        List<String> event5 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_5))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());

        List<String> event99 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_99))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());

        List<String> event100 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_100))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());
        // グラフの左端を調整するためにダミーデータを追加
        if (startTime != 0) {
            ktV.add(0, String.format("[%d, null]", startTime));
        }

        // JSONテンプレートを取得
        String template;
        try {
            URL url = resourceLoader.getResource("classpath:report/ddm1.chart-template.json").getURL();
            try (InputStream is = url.openStream(); ByteArrayOutputStream os = new ByteArrayOutputStream();) {

                byte[] buffer = new byte[1024];
                int len = is.read(buffer);
                while (len >= 0) {
                    os.write(buffer, 0, len);
                    len = is.read(buffer);
                }
                template = new String(os.toByteArray(), StandardCharsets.UTF_8);
            }
        } catch (IOException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
            // テンプレートが取得できなかった場合は空文字列を返す
            return "";
        }

        // テンプレートにプロットデータを埋め込んで返す
        return template.replace("#tickPositions#", String.join(",", tickPositions))
                .replace("#ktV#", String.join(",", ktV)).replace("#uRR#", String.join(",", uRR))
                .replace("#event1#", String.join(",", event1)).replace("#event2#", String.join(",", event2))
                .replace("#event3#", String.join(",", event3)).replace("#event4#", String.join(",", event4))
                .replace("#event5#", String.join(",", event5)).replace("#event99#", String.join(",", event99))
                .replace("#event100#", String.join(",", event100))
                .replace("#Y1From#", filter.getGraph1Y1From().toString())
                .replace("#Y1To#", filter.getGraph1Y1To().toString())
                .replace("#Y2From#", filter.getGraph1Y2From().toString())
                .replace("#Y2To#", filter.getGraph1Y2To().toString());
    }

    private String createJsonForDDMChart2(DDMGraph2CoordinateDTO dto, BVMSFilterDTO filter) {
        long startTime = getStartTime(dto.getUFPSpeeds());
        // プロットデータ作成
        List<String> tickPositions = new ArrayList<>();
        List<String> uFPSpeed = dto.getUFPSpeeds().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        List<String> bPSpeed = dto.getBPSpeeds().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        List<String> totalCond = dto.getTotalConds().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        List<String> qs = dto.getQss().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        // グラフの左端を調整するためにダミーデータを追加
        if (startTime != 0) {
            uFPSpeed.add(0, String.format("[%d, null]", startTime));
        }

        // JSONテンプレートを取得
        String template;
        try {
            URL url = resourceLoader.getResource("classpath:report/ddm2.chart-template.json").getURL();
            try (InputStream is = url.openStream(); ByteArrayOutputStream os = new ByteArrayOutputStream();) {

                byte[] buffer = new byte[1024];
                int len = is.read(buffer);
                while (len >= 0) {
                    os.write(buffer, 0, len);
                    len = is.read(buffer);
                }
                template = new String(os.toByteArray(), StandardCharsets.UTF_8);
            }
        } catch (IOException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
            // テンプレートが取得できなかった場合は空文字列を返す
            return "";
        }

        // テンプレートにプロットデータを埋め込んで返す
        return template.replace("#tickPositions#", String.join(",", tickPositions))
                .replace("#uFPSpeed#", String.join(",", uFPSpeed)).replace("#bPSpeed#", String.join(",", bPSpeed))
                .replace("#qs#", String.join(",", qs)).replace("#totalCond#", String.join(",", totalCond))
                .replace("#Y1From#", filter.getGraph2Y1From().toString())
                .replace("#Y1To#", filter.getGraph2Y1To().toString())
                .replace("#Y2From#", filter.getGraph2Y2From().toString())
                .replace("#Y2To#", filter.getGraph2Y2To().toString());
    }

    private String createJsonForHtChart1(HtGraph1CoordinateDTO dto, BVMSFilterDTO filter) {
        long startTime = getStartTime(dto.getHts());
        // プロットデータ作成
        List<String> tickPositions = new ArrayList<>();
        List<String> ht = dto.getHts().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        List<String> sysBP = dto.getSysBPs().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        List<String> diaBP = dto.getDiaBPs().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        List<String> event1 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_1))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());
        List<String> event2 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_2))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());

        List<String> event3 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_3))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());

        List<String> event4 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_4))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());

        List<String> event5 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_5))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());

        List<String> event99 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_99))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());

        List<String> event100 = dto.getEvents().stream()
                .filter(e -> (e.getYAxis() != null && e.getYAxis().intValue() == EVENT_100))
                .map(e -> String.format("{\"x\": %d, \"y\": %f}", e.getXAxis(), filter.getGraph1Y2To()))
                .collect(Collectors.toList());

        List<String> pulse = dto.getPulses().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());
        // グラフの左端を調整するためにダミーデータを追加
        if (startTime != 0) {
            ht.add(0, String.format("[%d, null]", startTime));
        }

        // JSONテンプレートを取得
        String template;
        try {
            URL url = resourceLoader.getResource("classpath:report/ht1.chart-template.json").getURL();
            try (InputStream is = url.openStream(); ByteArrayOutputStream os = new ByteArrayOutputStream();) {

                byte[] buffer = new byte[1024];
                int len = is.read(buffer);
                while (len >= 0) {
                    os.write(buffer, 0, len);
                    len = is.read(buffer);
                }
                template = new String(os.toByteArray(), StandardCharsets.UTF_8);
            }
        } catch (IOException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
            // テンプレートが取得できなかった場合は空文字列を返す
            return "";
        }

        // テンプレートにプロットデータを埋め込んで返す
        return template.replace("#tickPositions#", String.join(",", tickPositions))
                .replace("#ht#", String.join(",", ht)).replace("#sysBP#", String.join(",", sysBP))
                .replace("#diaBP#", String.join(",", diaBP)).replace("#pulse#", String.join(",", pulse))
                .replace("#event1#", String.join(",", event1)).replace("#event2#", String.join(",", event2))
                .replace("#event3#", String.join(",", event3)).replace("#event4#", String.join(",", event4))
                .replace("#event5#", String.join(",", event5)).replace("#event99#", String.join(",", event99))
                .replace("#event100#", String.join(",", event100))
                .replace("#Y1From#", filter.getGraph1Y1From().toString())
                .replace("#Y1To#", filter.getGraph1Y1To().toString())
                .replace("#Y2From#", filter.getGraph1Y2From().toString())
                .replace("#Y2To#", filter.getGraph1Y2To().toString());
    }

    private String createJsonForHtChart2(HtGraph2CoordinateDTO dto, BVMSFilterDTO filter) {
        long startTime = getStartTime(dto.getUFPSpeeds());
        // プロットデータ作成
        List<String> tickPositions = new ArrayList<>();
        List<String> uFPSpeed = dto.getUFPSpeeds().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        List<String> pRR = dto.getPRRs().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        List<String> totalCond = dto.getTotalConds().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        // グラフの左端を調整するためにダミーデータを追加
        if (startTime != 0) {
            uFPSpeed.add(0, String.format("[%d, null]", startTime));
        }

        // JSONテンプレートを取得
        String template;
        try {
            URL url = resourceLoader.getResource("classpath:report/ht2.chart-template.json").getURL();
            try (InputStream is = url.openStream(); ByteArrayOutputStream os = new ByteArrayOutputStream();) {

                byte[] buffer = new byte[1024];
                int len = is.read(buffer);
                while (len >= 0) {
                    os.write(buffer, 0, len);
                    len = is.read(buffer);
                }
                template = new String(os.toByteArray(), StandardCharsets.UTF_8);
            }
        } catch (IOException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
            // テンプレートが取得できなかった場合は空文字列を返す
            return "";
        }

        // テンプレートにプロットデータを埋め込んで返す
        return template.replace("#tickPositions#", String.join(",", tickPositions))
                .replace("#uFPSpeed#", String.join(",", uFPSpeed)).replace("#pRR#", String.join(",", pRR))
                .replace("#totalCond#", String.join(",", totalCond))
                .replace("#Y1From#", filter.getGraph2Y1From().toString())
                .replace("#Y1To#", filter.getGraph2Y1To().toString())
                .replace("#Y2From#", filter.getGraph2Y2From().toString())
                .replace("#Y2To#", filter.getGraph2Y2To().toString());
    }

    private String createJsonForRRChart(RRGraphCoordinateDTO dto, RRGraphFilterDTO filter) {
        long startTime = getStartTime(dto.getRecirculationRates());
        // プロットデータ作成
        List<String> tickPositions = new ArrayList<>();
        List<String> recirculationRate = dto.getRecirculationRates().stream().filter(e -> e.getYAxis() != null)
                .map(e -> String.format("[%d, %f]", e.getXAxis(), e.getYAxis())).collect(Collectors.toList());

        // グラフの左端を調整するためにダミーデータを追加
        if (startTime != 0) {
            recirculationRate.add(0, String.format("[%d, null]", startTime));
        }

        // JSONテンプレートを取得
        String template;
        try {
            URL url = resourceLoader.getResource("classpath:report/rr.chart-template.json").getURL();
            try (InputStream is = url.openStream(); ByteArrayOutputStream os = new ByteArrayOutputStream();) {

                byte[] buffer = new byte[1024];
                int len = is.read(buffer);
                while (len >= 0) {
                    os.write(buffer, 0, len);
                    len = is.read(buffer);
                }
                template = new String(os.toByteArray(), StandardCharsets.UTF_8);
            }
        } catch (IOException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
            // テンプレートが取得できなかった場合は空文字列を返す
            return "";
        }

        // テンプレートにプロットデータを埋め込んで返す
        return template.replace("#tickPositions#", String.join(",", tickPositions))
                .replace("#recirculationRate#", String.join(",", recirculationRate))
                .replace("#YFrom#", filter.getGraphY1From().toString())
                .replace("#YTo#", filter.getGraphY1To().toString());
    }

    private List<byte[]> buildChartData(ChartImageType type, String json) {
        List<byte[]> chartDatas = new ArrayList<>();
        String ext = type.toString().toLowerCase();
        EventLogMessage eventLogMessage = new EventLogMessage();
        // highcharts用JSONデータを作成
        List<File> tmpFiles = new ArrayList<>();
        try {
          Path jsonPath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, "nkk-report", ".json");
          Files.write(jsonPath, json.getBytes(StandardCharsets.UTF_8), StandardOpenOption.WRITE);
          tmpFiles.add(jsonPath.toFile());

          Path tmpPath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, "nkk-report", "." + ext);
          tmpFiles.add(tmpPath.toFile());

          List<HighchartGenerateModel> highchartGenerateModels = new ArrayList();
          HighchartGenerateModel highchartGenerateModel = new HighchartGenerateModel();

          highchartGenerateModel.setInJsonFilePath(json);
          tmpFiles.add(jsonPath.toFile());
          String imgFilePath  = jsonPath.toString().replace(".json","." + ext);
          tmpFiles.add(new File(imgFilePath));
          highchartGenerateModel.setOutImagefilePath(imgFilePath);
          highchartGenerateModels.add(highchartGenerateModel);


          List<String> tableList = new ArrayList<>();
          Map<String, Object> dataKey = new HashMap<>();
          dataKey.put("countWidth",800);
          dataKey.put("countHeight",500);
          dataKey.put("charHeight",500);
          dataKey.put("tableHeight",0);

          List<String> files = pool.renderCharts(highchartGenerateModels,tableList,dataKey,getHighchartJS());
          if (null != files && files.size() > 0) {
            // 生成された画像ファイルを読み込む
            chartDatas.add(Files.readAllBytes(Path.of(highchartGenerateModel.getOutImagefilePath())));
          }else{
            // レンダリング失敗
            eventLogMessage.setLogMessage("playwright Error:");
            logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU, LoggingConstant.SERVICE_NAME.FNSI, null);
          }
        } catch (IOException | InterruptedException e) {
            // 例外が発生した場合はなにもせず空のデータを返す
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessageNew = new EventLogMessage();
          eventLogMessageNew.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessageNew, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        } catch (Exception e) {
            // 例外が発生した場合はなにもせず空のデータを返す
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessageNewTwo = new EventLogMessage();
          eventLogMessageNewTwo.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessageNewTwo, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        } finally {
            // 一時ファイルを削除
            tmpFiles.forEach(f -> f.delete());
        }

        return chartDatas;
    }

    private long getStartTime(List<CoordinateDTO> dtos) {
        return !dtos.isEmpty() ? dtos.get(0).getXAxis() : 0;
    }

    private long getEndTime(List<CoordinateDTO> dtos) {
        return !dtos.isEmpty() ? dtos.get(dtos.size() - 1).getXAxis() : 0;
    }

    private String getHighchartJS() {
    String template;
    try {
      URL url = resourceLoader.getResource(ReportConstant.ReportGraph.TEMPLATE_HIGHCHART_JS).getURL();
      try (
        InputStream is = url.openStream();
        ByteArrayOutputStream os = new ByteArrayOutputStream();) {

        byte[] buffer = new byte[1024];
        int len = is.read(buffer);
        while (len >= 0) {
          os.write(buffer, 0, len);
          len = is.read(buffer);
        }
        template = new String(os.toByteArray(), StandardCharsets.UTF_8);
      }
    } catch (IOException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      return "";
    }
    return template.replaceAll("\\r\\n", "\n").replaceAll("\\r", "\n");
  }
}
