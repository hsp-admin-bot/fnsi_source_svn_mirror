package jp.co.nikkiso.ntss.admin_web.service.bvms.converter;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.regex.Pattern;

import org.apache.commons.csv.CSVRecord;

import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSHeaderDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.BVMSRowDTO;
import jp.co.nikkiso.ntss.admin_web.response.bvms.dto.ErrorCellDTO;
import lombok.NonNull;

public class BVMSRowConverter implements CSVConverter<CSVRecord, BVMSRowDTO> {

    private static final int FIRST_ROW = 1;

    @Override
    @NonNull
    public BVMSRowDTO convert(CSVRecord record, List<BigDecimal> headerValue) {
        BVMSRowDTO dto = new BVMSRowDTO();
        long recordNumber = record.getRecordNumber();
        dto.setRow(recordNumber);
        List<ErrorCellDTO> errorColumns = new ArrayList<>();
        if (recordNumber == FIRST_ROW) {
            BVMSHeaderDTO headerDTO = new BVMSHeaderDTO();
            List<ErrorCellDTO> errors = getBVMSHeaderDTO(record, headerDTO);
            if (errors.isEmpty()) {
                dto.setBvmsHeaderDTO(headerDTO);
            } else {
                errorColumns.addAll(errors);
            }

        } else {
            String hour = record.get(HOUR_INDEX);
            List<ErrorCellDTO> errors = getErrors(hour, recordNumber, HOUR_INDEX, true, true, true, true, true, false,
                    true, true);
            if (errors.isEmpty()) {
                dto.setHour(Integer.parseInt(hour));
            } else {
                errorColumns.addAll(errors);
            }

            String min = record.get(MIN_INDEX);
            errors = getErrors(min, recordNumber, MIN_INDEX, true, true, true, true, true, false, true, true);
            if (errors.isEmpty()) {
                dto.setMin(Integer.parseInt(min));
            } else {
                errorColumns.addAll(errors);
            }

            String sec = record.get(SEC_INDEX);
            errors = getErrors(sec, recordNumber, SEC_INDEX, true, true, true, true, true, false, true, true);
            if (errors.isEmpty()) {
                dto.setSec(Integer.parseInt(sec));
            } else {
                errorColumns.addAll(errors);
            }

            String treatTime = record.get(TREAT_TIME_INDEX);
            errors = getErrors(treatTime, recordNumber, TREAT_TIME_INDEX, true, true, true, true, true, false, false,
                    true);
            if (errors.isEmpty()) {
                dto.setTreatTime(new BigDecimal(treatTime).divide(headerValue.get(TREAT_TIME_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String dbv = record.get(DBV_INDEX);
            errors = getErrors(dbv, recordNumber, DBV_INDEX, false, true, false, false, false, false, false, false);

            if (errors.isEmpty()) {
                dto.setDBV(new BigDecimal(dbv).divide(headerValue.get(DBV_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String dBVBaseValue = record.get(DBV_BASE_VALUE_INDEX);
            errors = getErrors(dBVBaseValue, recordNumber, DBV_BASE_VALUE_INDEX, false, true, false, false, false,
                    false, false, false);
            if (errors.isEmpty()) {
                dto.setDBVBaseValue(new BigDecimal(dBVBaseValue).divide(headerValue.get(DBV_BASE_VALUE_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String uFPSpeed = record.get(UFP_SPEED_INDEX);
            errors = getErrors(uFPSpeed, recordNumber, UFP_SPEED_INDEX, false, true, false, false, false, false, false,
                    false);
            if (errors.isEmpty()) {
                dto.setUFPSpeed(new BigDecimal(uFPSpeed).divide(headerValue.get(UFP_SPEED_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String uFVolume = record.get(UF_VOLUME_INDEX);
            errors = getErrors(uFVolume, recordNumber, UF_VOLUME_INDEX, false, true, false, false, false, false, false,
                    false);
            if (errors.isEmpty()) {
                dto.setUFVolume(new BigDecimal(uFVolume).divide(headerValue.get(UF_VOLUME_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String bPSpeed = record.get(BP_SPEED_INDEX);
            errors = getErrors(bPSpeed, recordNumber, BP_SPEED_INDEX, false, true, false, false, false, false, false,
                    false);
            if (errors.isEmpty()) {
                dto.setBPSpeed(new BigDecimal(bPSpeed).divide(headerValue.get(BP_SPEED_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String totalCond = record.get(TOTAL_COND_INDEX);
            errors = getErrors(totalCond, recordNumber, TOTAL_COND_INDEX, false, true, false, false, false, false,
                    false, false);
            if (errors.isEmpty()) {
                dto.setTotalCond(new BigDecimal(totalCond).divide(headerValue.get(TOTAL_COND_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String sysBP = record.get(SYS_BP_INDEX);
            errors = getErrors(sysBP, recordNumber, SYS_BP_INDEX, false, true, false, false, false, false, false,
                    false);
            if (errors.isEmpty()) {
                dto.setSysBP(new BigDecimal(sysBP).divide(headerValue.get(SYS_BP_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String diaBP = record.get(DIA_BP_INDEX);
            errors = getErrors(diaBP, recordNumber, DIA_BP_INDEX, false, true, false, false, false, false, false,
                    false);
            if (errors.isEmpty()) {
                dto.setDiaBP(new BigDecimal(diaBP).divide(headerValue.get(DIA_BP_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String pulse = record.get(PULSE_INDEX);
            errors = getErrors(pulse, recordNumber, PULSE_INDEX, false, true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setPulse(new BigDecimal(pulse).divide(headerValue.get(PULSE_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String event = record.get(EVENT_INDEX);
            errors = getErrors(event, recordNumber, EVENT_INDEX, false, true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setEvent(new BigDecimal(event).divide(headerValue.get(EVENT_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String bloodFlowVolume = record.get(BLOOD_FLOW_VOLUME_INDEX);
            errors = getErrors(bloodFlowVolume, recordNumber, BLOOD_FLOW_VOLUME_INDEX, false, true, false, false, false,
                    false, false, false);
            if (errors.isEmpty()) {
                dto.setBloodFlowVolume(new BigDecimal(bloodFlowVolume).divide(headerValue.get(BLOOD_FLOW_VOLUME_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String dBVReferenceAreaUpperLimit = record.get(DBV_REFERENCEAREA_UPPER_LIMIT_INDEX);
            errors = getErrors(dBVReferenceAreaUpperLimit, recordNumber, DBV_REFERENCEAREA_UPPER_LIMIT_INDEX, false,
                    true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setDBVReferenceAreaUpperLimit(new BigDecimal(dBVReferenceAreaUpperLimit).divide(headerValue.get(DBV_REFERENCEAREA_UPPER_LIMIT_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String dBVReferenceAreaLowerLimit = record.get(DBV_REFERENCEAREA_LOWER_LIMIT_INDEX);
            errors = getErrors(dBVReferenceAreaLowerLimit, recordNumber, DBV_REFERENCEAREA_LOWER_LIMIT_INDEX, false,
                    true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setDBVReferenceAreaLowerLimit(new BigDecimal(dBVReferenceAreaLowerLimit).divide(headerValue.get(DBV_REFERENCEAREA_LOWER_LIMIT_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String dBVAVR5min = record.get(DBV_AVR_5MIN_INDEX);
            errors = getErrors(dBVAVR5min, recordNumber, DBV_AVR_5MIN_INDEX, false, true, false, false, false, false,
                    false, false);
            if (errors.isEmpty()) {
                dto.setDBVAVR5min(new BigDecimal(dBVAVR5min).divide(headerValue.get(DBV_AVR_5MIN_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String recirculationRate = record.get(RECIRCULATION_RATE_INDEX);
            errors = getErrors(recirculationRate, recordNumber, RECIRCULATION_RATE_INDEX, false, true, false, false,
                    false, false, false, false);
            if (errors.isEmpty()) {
                dto.setRecirculationRate(new BigDecimal(recirculationRate).divide(headerValue.get(RECIRCULATION_RATE_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String prr = record.get(PRR_INDEX);
            errors = getErrors(prr, recordNumber, PRR_INDEX, false, true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setPRR(new BigDecimal(prr).divide(headerValue.get(PRR_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String ktv = record.get(KTV_INDEX);
            errors = getErrors(ktv, recordNumber, KTV_INDEX, false, true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setKtV(new BigDecimal(ktv).divide(headerValue.get(KTV_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String urr = record.get(URR_INDEX);
            errors = getErrors(urr, recordNumber, URR_INDEX, false, true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setURR(new BigDecimal(urr).divide(headerValue.get(URR_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String dp = record.get(DP_INDEX);
            errors = getErrors(dp, recordNumber, DP_INDEX, false, true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setDP(new BigDecimal(dp).divide(headerValue.get(DP_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String qs = record.get(QS_INDEX);
            errors = getErrors(qs, recordNumber, QS_INDEX, false, true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setQs(new BigDecimal(qs).divide(headerValue.get(QS_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String treatMode = record.get(TREAT_MODE_INDEX);
            errors = getErrors(treatMode, recordNumber, TREAT_MODE_INDEX, false, true, false, false, false, false,
                    false, false);
            if (errors.isEmpty()) {
                dto.setTreatMode(new BigDecimal(treatMode).divide(headerValue.get(TREAT_MODE_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String estimateBloodFlow = record.get(ESTIMATE_BLOOD_FLOW_INDEX);
            errors = getErrors(estimateBloodFlow, recordNumber, ESTIMATE_BLOOD_FLOW_INDEX, false, true, false, false,
                    false, false, false, false);
            if (errors.isEmpty()) {
                dto.setEstimateBloodFlow(new BigDecimal(estimateBloodFlow).divide(headerValue.get(ESTIMATE_BLOOD_FLOW_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String drainAbs = record.get(DRAIN_ABS_INDEX);
            errors = getErrors(drainAbs, recordNumber, DRAIN_ABS_INDEX, false, true, false, false, false, false, false,
                    false);
            if (errors.isEmpty()) {
                dto.setDrainAbs(new BigDecimal(drainAbs).divide(headerValue.get(DRAIN_ABS_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String bVUFCStepNo = record.get(BV_UFC_STEP_NO_INDEX);
            errors = getErrors(bVUFCStepNo, recordNumber, BV_UFC_STEP_NO_INDEX, false, true, false, false, false, false,
                    false, false);
            if (errors.isEmpty()) {
                dto.setBVUFCStepNo(new BigDecimal(bVUFCStepNo).divide(headerValue.get(BV_UFC_STEP_NO_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String lDQb = record.get(LDQB_INDEX);
            errors = getErrors(lDQb, recordNumber, LDQB_INDEX, false, true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setLDQb(new BigDecimal(lDQb).divide(headerValue.get(LDQB_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String ht = record.get(HT_INDEX);
            errors = getErrors(ht, recordNumber, HT_INDEX, false, true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setHt(new BigDecimal(ht).divide(headerValue.get(HT_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String star = record.get(STAR_INDEX);
            errors = getErrors(star, recordNumber, STAR_INDEX, false, true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setStar(new BigDecimal(star).divide(headerValue.get(STAR_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String s = record.get(S_INDEX);
            errors = getErrors(s, recordNumber, S_INDEX, false, true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setS(new BigDecimal(s).divide(headerValue.get(S_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String ia = record.get(IA_INDEX);
            errors = getErrors(ia, recordNumber, IA_INDEX, false, true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setIa(new BigDecimal(ia).divide(headerValue.get(IA_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String ra = record.get(RA_INDEX);
            errors = getErrors(ra, recordNumber, RA_INDEX, false, true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setRa(new BigDecimal(ra).divide(headerValue.get(RA_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String ga = record.get(GA_INDEX);
            errors = getErrors(ga, recordNumber, GA_INDEX, false, true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setGa(new BigDecimal(ga).divide(headerValue.get(GA_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String iv = record.get(IV_INDEX);
            errors = getErrors(iv, recordNumber, IV_INDEX, false, true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setIv(new BigDecimal(iv).divide(headerValue.get(IV_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String kc = record.get(KC_INDEX);
            errors = getErrors(kc, recordNumber, KC_INDEX, false, true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setKc(new BigDecimal(kc).divide(headerValue.get(KC_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String tis = record.get(TIS_INDEX);
            errors = getErrors(tis, recordNumber, TIS_INDEX, false, true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setTis(new BigDecimal(tis).divide(headerValue.get(TIS_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String ris = record.get(RIS_INDEX);
            errors = getErrors(ris, recordNumber, RIS_INDEX, false, true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setRis(new BigDecimal(ris).divide(headerValue.get(RIS_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String ic = record.get(IC_INDEX);
            errors = getErrors(ic, recordNumber, IC_INDEX, false, true, false, false, false, false, false, false);
            if (errors.isEmpty()) {
                dto.setIc(new BigDecimal(ic).divide(headerValue.get(IC_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }

            String apa = record.get(ART_PRESS_AVE_INDEX);
            errors = getErrors(apa, recordNumber, ART_PRESS_AVE_INDEX, false, true, false, false, false, false, false,
                    false);
            if (errors.isEmpty()) {
                dto.setArtPressAve(new BigDecimal(apa).divide(headerValue.get(ART_PRESS_AVE_INDEX)));
            } else {
                errorColumns.addAll(errors);
            }
        }

        if (!errorColumns.isEmpty()) {
            dto.setErrorColumns(errorColumns);
        }
        return dto;
    }

    private List<ErrorCellDTO> getBVMSHeaderDTO(CSVRecord record, BVMSHeaderDTO dto) {
        long recordNumber = record.getRecordNumber();
        List<ErrorCellDTO> errorColumns = new ArrayList<>();
        String value = record.get(LAST_TWO_DIGITS_INDEX);
        List<ErrorCellDTO> errorColumn = getErrors(value, recordNumber, LAST_TWO_DIGITS_INDEX, true, true, true, true,
                true, false, false, true);
        if (errorColumn.isEmpty()) {
            dto.setLastTwoDigits(Long.parseLong(value));
        } else {
            errorColumns.addAll(errorColumn);
        }

        value = record.get(MONTH_INDEX);
        errorColumn = getErrors(value, recordNumber, MONTH_INDEX, true, true, true, true, true, true, true, true);
        if (errorColumn.isEmpty()) {
            dto.setMonth(Long.parseLong(value));
        } else {
            errorColumns.addAll(errorColumn);
        }

        value = record.get(DAY_INDEX);
        errorColumn = getErrors(value, recordNumber, DAY_INDEX, true, true, true, true, true, true, true, true);
        if (errorColumn.isEmpty()) {
            dto.setDay(Long.parseLong(value));
        } else {
            errorColumns.addAll(errorColumn);
        }

        value = record.get(WEIGHT_BEFORE_DIALYSIS_INDEX);
        errorColumn = getErrors(value, recordNumber, WEIGHT_BEFORE_DIALYSIS_INDEX, false, true, false, false, false,
                false, false, false);
        if (errorColumn.isEmpty()) {
            dto.setWeightBeforeDialysis(new BigDecimal(value));
        } else {
            errorColumns.addAll(errorColumn);
        }
        dto.setEquipmentModel(record.get(EQUIPMENT_MODEL_INDEX));
        dto.setVersion(record.get(VERSION_INDEX));
        dto.setSubVersion(Long.parseLong(record.get(SUBVERSION_INDEX)));
        dto.setPatientName(record.get(PATIENT_NAME_INDEX));
        dto.setEquipmentSerialNumber(Long.parseLong(record.get(EQUIPMENT_SERIAL_NUMBER_INDEX)));

        value = record.get(TRANSMITTED_AD_VALUE_INDEX);
        errorColumn = getErrors(value, recordNumber, TRANSMITTED_AD_VALUE_INDEX, false, true, false, false, false,
                false, false, false);
        if (errorColumn.isEmpty()) {
            dto.setTransmittedADValue(Long.parseLong(value));
        } else {
            errorColumns.addAll(errorColumn);
        }

        value = record.get(REFERENCE_AD_VALUE_INDEX);
        errorColumn = getErrors(value, recordNumber, REFERENCE_AD_VALUE_INDEX, false, true, false, false, false, false,
                false, false);
        if (errorColumn.isEmpty()) {
            dto.setReferenceAdValue(Long.parseLong(value));
        } else {
            errorColumns.addAll(errorColumn);
        }

        value = record.get(DATETIME_INDEX);
        errorColumn = getErrors(value, recordNumber, DATETIME_INDEX, false, true, false, false, false, false, false,
                false);
        if (errorColumn.isEmpty()) {
            dto.setDateTime(Long.parseLong(value));
        } else {
            errorColumns.addAll(errorColumn);
        }

        value = record.get(PROCESS_INDEX);
        errorColumn = getErrors(value, recordNumber, PROCESS_INDEX, false, true, false, false, false, false, false,
                false);
        if (errorColumn.isEmpty()) {
            dto.setProcess(Long.parseLong(value));
        } else {
            errorColumns.addAll(errorColumn);
        }

        value = record.get(ABV_VALUE_INDEX);
        errorColumn = getErrors(value, recordNumber, ABV_VALUE_INDEX, false, true, false, false, false, false, false,
                false);
        if (errorColumn.isEmpty()) {
            dto.setABVValue(new BigDecimal(value));
        } else {
            errorColumns.addAll(errorColumn);
        }

        value = record.get(DEWATERING_SPEED_INDEX);
        errorColumn = getErrors(value, recordNumber, DEWATERING_SPEED_INDEX, false, true, false, false, false, false,
                false, false);
        if (errorColumn.isEmpty()) {
            dto.setDewateringSpeed(new BigDecimal(value));
        } else {
            errorColumns.addAll(errorColumn);
        }

        value = record.get(WATER_REMOVAL_INTEGRATED_VALUE_INDEX);
        errorColumn = getErrors(value, recordNumber, WATER_REMOVAL_INTEGRATED_VALUE_INDEX, false, true, false, false,
                false, false, false, false);
        if (errorColumn.isEmpty()) {
            dto.setWaterRemovalIntegratedValue(new BigDecimal(value));
        } else {
            errorColumns.addAll(errorColumn);
        }

        value = record.get(BOOLD_FLOW_INDEX);
        errorColumn = getErrors(value, recordNumber, BOOLD_FLOW_INDEX, false, true, false, false, false, false, false,
                false);
        if (errorColumn.isEmpty()) {
            dto.setBooldFlow(Long.parseLong(value));
        } else {
            errorColumns.addAll(errorColumn);
        }

        value = record.get(DIALYSATE_CONCENTRATION_INDEX);
        errorColumn = getErrors(value, recordNumber, DIALYSATE_CONCENTRATION_INDEX, false, true, false, false, false,
                false, false, false);
        if (errorColumn.isEmpty()) {
            dto.setDialysateConcentration(new BigDecimal(value));
        } else {
            errorColumns.addAll(errorColumn);
        }

        value = record.get(SYSTOLIC_BLOOD_PRESSURE_INDEX);
        errorColumn = getErrors(value, recordNumber, SYSTOLIC_BLOOD_PRESSURE_INDEX, false, true, false, false, false,
                false, false, false);
        if (errorColumn.isEmpty()) {
            dto.setSystolicBloodPressure(Long.parseLong(value));
        } else {
            errorColumns.addAll(errorColumn);
        }

        value = record.get(DIASTOLIC_BLOOD_PRESSURE);
        errorColumn = getErrors(value, recordNumber, DIASTOLIC_BLOOD_PRESSURE, false, true, false, false, false, false,
                false, false);
        if (errorColumn.isEmpty()) {
            dto.setDiastolicBloodPressure(Long.parseLong(value));
        } else {
            errorColumns.addAll(errorColumn);
        }

        value = record.get(PULSE_WITH_NO_HEADER_INDEX);
        errorColumn = getErrors(value, recordNumber, PULSE_WITH_NO_HEADER_INDEX, false, true, false, false, false,
                false, false, false);
        if (errorColumn.isEmpty()) {
            dto.setPulseWithNoHeader(Long.parseLong(value));
        } else {
            errorColumns.addAll(errorColumn);
        }
        dto.setPulseWithNoHeader(Long.parseLong(record.get(PULSE_WITH_NO_HEADER_INDEX)));
        return errorColumns;
    }

    private boolean isNumeric(final String str) {

        Pattern pattern = Pattern.compile("-?\\d+(\\.\\d+)?");
        // null or empty
        if (str == null || str.isEmpty()) {
            return false;
        }

        return pattern.matcher(str).matches();

    }

    private List<ErrorCellDTO> getErrors(String value, long row, int index, boolean checkEmpty, boolean checkNumber,
            boolean checkNull, boolean checkNegativeOne, boolean checkNegativeValue, boolean checkZero,
            boolean check999, boolean checkNeagtive9999) {
        List<ErrorCellDTO> errorColumns = new ArrayList<>();
        if (checkNull && value == null) {
            errorColumns.add(new ErrorCellDTO(row, index, "NULL", value));
            return errorColumns;
        }
        if (checkEmpty && value.isEmpty()) {
            errorColumns.add(new ErrorCellDTO(row, index, "値無し", value));
        }

        if (checkNumber && !isNumeric(value)) {
            errorColumns.add(new ErrorCellDTO(row, index, "数値以外", value));
        } else {

            BigDecimal numberic = new BigDecimal(value);
            if (checkNegativeOne && numberic.intValue() == -1) {
                errorColumns.add(new ErrorCellDTO(row, index, "-1", value));
            }

            if (checkNegativeValue && numberic.intValue() < 0
                    && (numberic.intValue() != -1 || numberic.intValue() != -9999)) {
                errorColumns.add(new ErrorCellDTO(row, index, "-1/-9999以外のマイナス値", value));
            }

            if (checkZero && numberic.intValue() == 0) {
                errorColumns.add(new ErrorCellDTO(row, index, "0", value));
            }
            if (check999 && numberic.intValue() == 999) {
                errorColumns.add(new ErrorCellDTO(row, index, "999", value));
            }
            if (checkNeagtive9999 && numberic.intValue() == -9999) {
                errorColumns.add(new ErrorCellDTO(row, index, "-9999", value));
            }
        }

        return errorColumns;
    }

    private static final Integer HOUR_INDEX = 0;
    private static final Integer MIN_INDEX = 1;
    private static final Integer SEC_INDEX = 2;
    private static final Integer TREAT_TIME_INDEX = 3;
    private static final Integer DBV_INDEX = 4;
    private static final Integer DBV_BASE_VALUE_INDEX = 5;
    private static final Integer UFP_SPEED_INDEX = 6;
    private static final Integer UF_VOLUME_INDEX = 7;
    private static final Integer BP_SPEED_INDEX = 8;
    private static final Integer TOTAL_COND_INDEX = 9;
    private static final Integer SYS_BP_INDEX = 10;
    private static final Integer DIA_BP_INDEX = 11;
    private static final Integer PULSE_INDEX = 12;
    private static final Integer BLOOD_FLOW_VOLUME_INDEX = 13;
    private static final Integer EVENT_INDEX = 14;
    private static final Integer DBV_REFERENCEAREA_UPPER_LIMIT_INDEX = 15;
    private static final Integer DBV_REFERENCEAREA_LOWER_LIMIT_INDEX = 16;
    private static final Integer DBV_AVR_5MIN_INDEX = 17;
    private static final Integer RECIRCULATION_RATE_INDEX = 18;
    private static final Integer PRR_INDEX = 19;
    private static final Integer KTV_INDEX = 20;
    private static final Integer URR_INDEX = 21;
    private static final Integer DP_INDEX = 22;
    private static final Integer QS_INDEX = 23;
    private static final Integer TREAT_MODE_INDEX = 24;
    private static final Integer ESTIMATE_BLOOD_FLOW_INDEX = 25;
    private static final Integer DRAIN_ABS_INDEX = 26;
    private static final Integer BV_UFC_STEP_NO_INDEX = 27;
    private static final Integer LDQB_INDEX = 28;
    private static final Integer HT_INDEX = 29;
    private static final Integer STAR_INDEX = 30;
    private static final Integer S_INDEX = 31;
    private static final Integer IA_INDEX = 32;
    private static final Integer RA_INDEX = 33;
    private static final Integer GA_INDEX = 34;
    private static final Integer IV_INDEX = 35;
    private static final Integer KC_INDEX = 36;
    private static final Integer TIS_INDEX = 37;
    private static final Integer RIS_INDEX = 38;
    private static final Integer IC_INDEX = 39;
    private static final Integer ART_PRESS_AVE_INDEX = 40;
    private static final Integer LAST_TWO_DIGITS_INDEX = 42;
    private static final Integer MONTH_INDEX = 43;
    private static final Integer DAY_INDEX = 44;
    private static final Integer WEIGHT_BEFORE_DIALYSIS_INDEX = 45;
    private static final Integer EQUIPMENT_MODEL_INDEX = 46;
    private static final Integer VERSION_INDEX = 47;
    private static final Integer SUBVERSION_INDEX = 48;
    private static final Integer PATIENT_NAME_INDEX = 50;
    private static final Integer EQUIPMENT_SERIAL_NUMBER_INDEX = 51;
    private static final Integer TRANSMITTED_AD_VALUE_INDEX = 52;
    private static final Integer REFERENCE_AD_VALUE_INDEX = 53;
    private static final Integer DATETIME_INDEX = 54;
    private static final Integer PROCESS_INDEX = 55;
    private static final Integer ABV_VALUE_INDEX = 55;
    private static final Integer DEWATERING_SPEED_INDEX = 57;
    private static final Integer WATER_REMOVAL_INTEGRATED_VALUE_INDEX = 58;
    private static final Integer BOOLD_FLOW_INDEX = 59;
    private static final Integer DIALYSATE_CONCENTRATION_INDEX = 60;
    private static final Integer SYSTOLIC_BLOOD_PRESSURE_INDEX = 61;
    private static final Integer DIASTOLIC_BLOOD_PRESSURE = 62;
    private static final Integer PULSE_WITH_NO_HEADER_INDEX = 63;
}
