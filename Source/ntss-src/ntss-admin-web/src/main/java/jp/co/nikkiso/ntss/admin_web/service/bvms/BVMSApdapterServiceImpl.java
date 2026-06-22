package jp.co.nikkiso.ntss.admin_web.service.bvms;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSFilterDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSGraphDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSRowDTO;
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
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;

@Service
public class BVMSApdapterServiceImpl implements BVMSApdapterService {

    @Autowired
    OrdMainDao ordMainDao;

    @Override
    public BVGraphDTO adaptBVGrapDTO(BVMSGraphDTO bvmsGraphDTO, BVMSFilterDTO inputDTO) {
        BVGraphDTO bvGraphDTO = new BVGraphDTO();

        BVGraph1CoordinateDTO graph1coordinates = new BVGraph1CoordinateDTO();
        BVGraph2CoordinateDTO graph2coordinates = new BVGraph2CoordinateDTO();

        List<CoordinateDTO> dBVs = new ArrayList<>();
        List<CoordinateDTO> dBVBaseValues = new ArrayList<>();
        List<CoordinateDTO> dBVReferenceAreaUpperLimits = new ArrayList<>();
        List<CoordinateDTO> dBVReferenceAreaLowerLimits = new ArrayList<>();
        List<CoordinateDTO> dBVAVR5mins = new ArrayList<>();
        List<CoordinateDTO> sysBPs = new ArrayList<>();
        List<CoordinateDTO> diaBPs = new ArrayList<>();
        List<CoordinateDTO> pulses = new ArrayList<>();
        List<CoordinateDTO> events = new ArrayList<>();

        List<CoordinateDTO> uFPSpeeds = new ArrayList<>();
        List<CoordinateDTO> pRRs = new ArrayList<>();
        List<CoordinateDTO> totalConds = new ArrayList<>();

        BigDecimal graph1Y1From = inputDTO.getGraph1Y1From();
        BigDecimal graph1Y1to = inputDTO.getGraph1Y1To();
        BigDecimal graph1Y2From = inputDTO.getGraph1Y2From();
        BigDecimal graph1Y2To = inputDTO.getGraph1Y2To();
        BigDecimal graph2Y1From = inputDTO.getGraph2Y1From();
        BigDecimal graph2Y1To = inputDTO.getGraph2Y1To();
        BigDecimal graph2Y2From = inputDTO.getGraph2Y2From();
        BigDecimal graph2Y2To = inputDTO.getGraph2Y2To();
        List<BVMSRowDTO> rows = bvmsGraphDTO.getRows();

        for (BVMSRowDTO row : rows) {

            BigDecimal dBV = row.getDBV();
            BigDecimal dBVBaseValue = row.getDBVBaseValue();
            BigDecimal dBVReferenceAreaUpperLimi = row.getDBVReferenceAreaUpperLimit();
            BigDecimal dBVReferenceAreaLowerLimit = row.getDBVReferenceAreaLowerLimit();
            BigDecimal dBVAVR5min = row.getDBVAVR5min();

            if (isValid(graph1Y1From, graph1Y1to, dBV, row.getRow())) {
                dBVs.add(geCoordinateDTO(dBV, row));
            }
            if (isValid(graph1Y1From, graph1Y1to, dBVBaseValue, row.getRow())) {
                dBVBaseValues.add(geCoordinateDTO(dBVBaseValue, row));
            }
            if (isValid(graph1Y1From, graph1Y1to, dBVReferenceAreaUpperLimi, row.getRow())) {
                dBVReferenceAreaUpperLimits.add(geCoordinateDTO(dBVReferenceAreaUpperLimi, row));
            }
            if (isValid(graph1Y1From, graph1Y1to, dBVReferenceAreaLowerLimit, row.getRow())) {
                dBVReferenceAreaLowerLimits.add(geCoordinateDTO(dBVReferenceAreaLowerLimit, row));
            }
            if (isValid(graph1Y1From, graph1Y1to, dBVAVR5min, row.getRow())) {
                dBVAVR5mins.add(geCoordinateDTO(dBVAVR5min, row));
            }

            BigDecimal sysBP = row.getSysBP();
            BigDecimal diaBP = row.getDiaBP();
            BigDecimal pulse = row.getPulse();
            BigDecimal event = row.getEvent();
            if (isValid(graph1Y2From, graph1Y2To, sysBP, row.getRow())) {
                sysBPs.add(geCoordinateDTO(sysBP, row));
            }
            if (isValid(graph1Y2From, graph1Y2To, diaBP, row.getRow())) {
                diaBPs.add(geCoordinateDTO(diaBP, row));
            }
            if (isValid(graph1Y2From, graph1Y2To, pulse, row.getRow())) {
                pulses.add(geCoordinateDTO(pulse, row));
            }
            if (isValid(graph1Y2From, graph1Y2To, event, row.getRow())) {
                events.add(geCoordinateDTO(event, row));
            }

            BigDecimal uFPSpeed = row.getUFPSpeed();
            BigDecimal pRR = row.getPRR();
            BigDecimal totalCond = row.getTotalCond();
            if (isValid(graph2Y1From, graph2Y1To, uFPSpeed, row.getRow())) {
                uFPSpeeds.add(geCoordinateDTO(sysBP, row));
            }
            if (isValid(graph2Y1From, graph2Y1To, pRR, row.getRow())) {
                pRRs.add(geCoordinateDTO(pRR, row));
            }
            if (isValid(graph2Y2From, graph2Y2To, totalCond, row.getRow())) {
                totalConds.add(geCoordinateDTO(totalCond, row));
            }
        }

        graph1coordinates.setDBVs(dBVs);
        graph1coordinates.setDBVAVR5mins(dBVAVR5mins);
        graph1coordinates.setDBVBaseValues(dBVBaseValues);
        graph1coordinates.setDBVReferenceAreaLowerLimits(dBVReferenceAreaLowerLimits);
        graph1coordinates.setDBVReferenceAreaUpperLimits(dBVReferenceAreaUpperLimits);
        graph1coordinates.setDiaBPs(diaBPs);
        graph1coordinates.setEvents(events);
        graph1coordinates.setPulses(pulses);
        graph1coordinates.setSysBPs(sysBPs);

        bvGraphDTO.setGraph1Coordinates(graph1coordinates);

        graph2coordinates.setPRRs(pRRs);
        graph2coordinates.setTotalConds(totalConds);
        graph2coordinates.setUFPSpeeds(uFPSpeeds);
        bvGraphDTO.setGraph2Coordinates(graph2coordinates);
        return bvGraphDTO;
    }

    @Override
    public DDMGraphDTO adaptDDMGrapDTO(BVMSGraphDTO rawDataDTO, BVMSFilterDTO inputDTO) {
        DDMGraphDTO graphDTO = new DDMGraphDTO();

        DDMGraph1CoordinateDTO graph1coordinates = new DDMGraph1CoordinateDTO();
        DDMGraph2CoordinateDTO graph2coordinates = new DDMGraph2CoordinateDTO();

        List<BVMSRowDTO> rows = rawDataDTO.getRows();
        BigDecimal graph1Y1From = inputDTO.getGraph1Y1From();
        BigDecimal graph1Y1to = inputDTO.getGraph1Y1To();
        BigDecimal graph1Y2From = inputDTO.getGraph1Y2From();
        BigDecimal graph1Y2To = inputDTO.getGraph1Y2To();
        BigDecimal graph2Y1From = inputDTO.getGraph2Y1From();
        BigDecimal graph2Y1To = inputDTO.getGraph2Y1To();
        BigDecimal graph2Y2From = inputDTO.getGraph2Y2From();
        BigDecimal graph2Y2To = inputDTO.getGraph2Y2To();

        List<CoordinateDTO> ktvs = new ArrayList<>();
        List<CoordinateDTO> uRRs = new ArrayList<>();
        List<CoordinateDTO> events = new ArrayList<>();

        List<CoordinateDTO> uFPSpeeds = new ArrayList<>();
        List<CoordinateDTO> bPSpeeds = new ArrayList<>();
        List<CoordinateDTO> totalConds = new ArrayList<>();
        List<CoordinateDTO> qss = new ArrayList<>();

        for (BVMSRowDTO row : rows) {

            BigDecimal ktv = row.getKtV();
            BigDecimal uRR = row.getURR();
            BigDecimal event = row.getEvent();

            if (isValid(graph1Y1From, graph1Y1to, ktv, row.getRow())) {
                ktvs.add(geCoordinateDTO(ktv, row));
            }
            if (isValid(graph1Y2From, graph1Y2To, uRR, row.getRow())) {
                uRRs.add(geCoordinateDTO(uRR, row));
            }
            if (isValid(graph1Y2From, graph1Y2To, event, row.getRow())) {
                events.add(geCoordinateDTO(event, row));
            }

            BigDecimal uFPSpeed = row.getUFPSpeed();
            BigDecimal bPSpeed = row.getBPSpeed();
            BigDecimal totalCond = row.getTotalCond();
            BigDecimal qs = row.getQs();

            if (isValid(graph2Y1From, graph2Y1To, uFPSpeed, row.getRow())) {
                uFPSpeeds.add(geCoordinateDTO(uFPSpeed, row));
            }

            if (isValid(graph2Y2From, graph2Y2To, bPSpeed, row.getRow())) {
                bPSpeeds.add(geCoordinateDTO(bPSpeed, row));
            }

            if (isValid(graph2Y2From, graph2Y2To, totalCond, row.getRow())) {
                totalConds.add(geCoordinateDTO(totalCond, row));
            }
            if (isValid(graph2Y2From, graph2Y2To, qs, row.getRow())) {
                qss.add(geCoordinateDTO(qs, row));
            }
        }
        graph1coordinates.setEvents(events);
        graph1coordinates.setKtVs(ktvs);
        graph1coordinates.setURRs(uRRs);
        graphDTO.setGraph1Coordinates(graph1coordinates);

        graph2coordinates.setBPSpeeds(bPSpeeds);
        graph2coordinates.setQss(qss);
        graph2coordinates.setTotalConds(totalConds);
        graph2coordinates.setUFPSpeeds(uFPSpeeds);

        graphDTO.setGraph2Coordinates(graph2coordinates);
        return graphDTO;
    }

    @Override
    public HtGraphDTO adaptHtGraphDTO(BVMSGraphDTO rawDataDTO, BVMSFilterDTO inputDTO) {
        HtGraphDTO graphDTO = new HtGraphDTO();

        HtGraph1CoordinateDTO graph1coordinates = new HtGraph1CoordinateDTO();
        HtGraph2CoordinateDTO graph2coordinates = new HtGraph2CoordinateDTO();
        List<BVMSRowDTO> rows = rawDataDTO.getRows();

        BigDecimal graph1Y1From = inputDTO.getGraph1Y1From();
        BigDecimal graph1Y1to = inputDTO.getGraph1Y1To();
        BigDecimal graph1Y2From = inputDTO.getGraph1Y2From();
        BigDecimal graph1Y2To = inputDTO.getGraph1Y2To();
        BigDecimal graph2Y1From = inputDTO.getGraph2Y1From();
        BigDecimal graph2Y1To = inputDTO.getGraph2Y1To();
        BigDecimal graph2Y2From = inputDTO.getGraph2Y2From();
        BigDecimal graph2Y2To = inputDTO.getGraph2Y2To();

        List<CoordinateDTO> hts = new ArrayList<>();
        List<CoordinateDTO> sysBPs = new ArrayList<>();
        List<CoordinateDTO> diaBPs = new ArrayList<>();
        List<CoordinateDTO> pulses = new ArrayList<>();
        List<CoordinateDTO> events = new ArrayList<>();

        List<CoordinateDTO> uFPSpeeds = new ArrayList<>();
        List<CoordinateDTO> pRRs = new ArrayList<>();
        List<CoordinateDTO> totalConds = new ArrayList<>();
        for (BVMSRowDTO row : rows) {

            BigDecimal ht = row.getHt();
            BigDecimal sysBP = row.getSysBP();
            BigDecimal diaBP = row.getDiaBP();
            BigDecimal event = row.getEvent();
            BigDecimal pulse = row.getPulse();

            if (isValid(graph1Y1From, graph1Y1to, ht, row.getRow())) {
                hts.add(geCoordinateDTO(ht, row));
            }
            if (isValid(graph1Y2From, graph1Y2To, sysBP, row.getRow())) {
                sysBPs.add(geCoordinateDTO(sysBP, row));
            }
            if (isValid(graph1Y2From, graph1Y2To, diaBP, row.getRow())) {
                diaBPs.add(geCoordinateDTO(diaBP, row));
            }
            if (isValid(graph1Y2From, graph1Y2To, pulse, row.getRow())) {
                pulses.add(geCoordinateDTO(pulse, row));
            }
            if (isValid(graph1Y2From, graph1Y2To, event, row.getRow())) {
                events.add(geCoordinateDTO(event, row));
            }

            BigDecimal uFPSpeed = row.getUFPSpeed();
            BigDecimal pRR = row.getPRR();
            BigDecimal totalCond = row.getTotalCond();

            if (isValid(graph2Y1From, graph2Y1To, uFPSpeed, row.getRow())) {
                uFPSpeeds.add(geCoordinateDTO(uFPSpeed, row));
            }

            if (isValid(graph2Y2From, graph2Y2To, pRR, row.getRow())) {
                pRRs.add(geCoordinateDTO(pRR, row));
            }

            if (isValid(graph2Y2From, graph2Y2To, totalCond, row.getRow())) {
                totalConds.add(geCoordinateDTO(totalCond, row));
            }
        }

        graph1coordinates.setDiaBPs(diaBPs);
        graph1coordinates.setEvents(events);
        graph1coordinates.setHts(hts);
        graph1coordinates.setPulses(pulses);
        graph1coordinates.setSysBPs(sysBPs);

        graph2coordinates.setPRRs(pRRs);
        graph2coordinates.setTotalConds(totalConds);
        graph2coordinates.setUFPSpeeds(uFPSpeeds);
        graphDTO.setGraph1Coordinates(graph1coordinates);
        graphDTO.setGraph2Coordinates(graph2coordinates);

        return graphDTO;
    }

    @Override
    public RRGraphDTO adaptRRGraphDTO(BVMSGraphDTO rawDataDTO, RRGraphFilterDTO filter) {
        RRGraphDTO graph = new RRGraphDTO();

        RRGraphCoordinateDTO graphcoordinates = new RRGraphCoordinateDTO();
        List<BVMSRowDTO> rows = rawDataDTO.getRows();
        BigDecimal graphY1From = filter.getGraphY1From();
        BigDecimal graphY1to = filter.getGraphY1To();
        List<CoordinateDTO> recirculationRates = new ArrayList<>();
        for (BVMSRowDTO row : rows) {
            BigDecimal rr = row.getRecirculationRate();
            if (isValid(graphY1From, graphY1to, rr, row.getRow())) {
                recirculationRates.add(geCoordinateDTO(rr, row));
            }
        }
        graphcoordinates.setRecirculationRates(recirculationRates);
        graph.setGraphCoordinates(graphcoordinates);

        return graph;
    }

    private boolean isValid(BigDecimal from, BigDecimal to, BigDecimal value, Long row) {
        return row != 1 && value.compareTo(from) >= 0 && value.compareTo(to) <= 0;
    }

    private CoordinateDTO geCoordinateDTO(BigDecimal value, BVMSRowDTO row) {
        CoordinateDTO dto = new CoordinateDTO();
        dto.setYAxis(value);
        dto.setXAxis(getDate(2020, 1, 1, row.getHour(), row.getMin(), row.getSec()));
        return dto;
    }

    private long getDate(int year, int month, int day, int hour, int minute, int second) {
        Calendar cal = Calendar.getInstance();
        cal.set(Calendar.YEAR, year);
        cal.set(Calendar.MONTH, month);
        cal.set(Calendar.DAY_OF_MONTH, day);
        cal.set(Calendar.HOUR_OF_DAY, hour);
        cal.set(Calendar.MINUTE, minute);
        cal.set(Calendar.SECOND, second);
        return cal.getTime().getTime();
    }

}
