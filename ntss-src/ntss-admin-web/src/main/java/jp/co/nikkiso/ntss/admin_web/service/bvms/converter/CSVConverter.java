package jp.co.nikkiso.ntss.admin_web.service.bvms.converter;

import java.util.List;
import java.math.BigDecimal;

public interface CSVConverter<CSVRecord, T> {

    public T convert(CSVRecord record, List<BigDecimal> headerValue);
}
