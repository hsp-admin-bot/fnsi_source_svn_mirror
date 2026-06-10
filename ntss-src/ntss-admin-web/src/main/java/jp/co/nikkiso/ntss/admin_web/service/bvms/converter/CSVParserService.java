package jp.co.nikkiso.ntss.admin_web.service.bvms.converter;

import java.math.BigDecimal;
import java.io.Reader;
import java.util.ArrayList;
import java.util.List;

import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVParser;
import org.apache.commons.csv.CSVRecord;
import org.springframework.util.Assert;

import jp.co.nikkiso.ntss.core.exception.NtssException;
import lombok.NonNull;

public class CSVParserService<T> {

    private static final int FIRST_ROW = 1;

    private CSVConverter<CSVRecord, T> converter;

    public CSVParserService(CSVConverter<CSVRecord, T> converter) {
        this.converter = converter;
    }

    @NonNull
    public List<T> parse(Reader in) throws NtssException {
        Assert.notNull(in, "Reader can't be null");
        List<T> list = new ArrayList<>();
        List<BigDecimal> headerValue = new ArrayList<>();
        try {
            CSVParser parse = CSVFormat.newFormat(',').parse(in);
            for (CSVRecord csvRecord : parse) {
                if (csvRecord.getRecordNumber()  == FIRST_ROW) {
                    for (int i = 0; i < csvRecord.size(); i++) {
                        if (csvRecord.get(i) != null && csvRecord.get(i).contains("*")) {
                            String[] arr = csvRecord.get(i).split("\\*");
                            if (arr.length >= 2) {
                                headerValue.add(new BigDecimal(arr[arr.length - 1]));
                            } else {
                                headerValue.add(new BigDecimal(1));
                            }
                        } else {
                            headerValue.add(new BigDecimal(1));
                        }
                    }
                }
                list.add(converter.convert(csvRecord, headerValue));
            }
        } catch (Exception e) {
            throw new NtssException("I/O exception occurs during input parsing CSV file", e);
        }

        return list;
    }
}
