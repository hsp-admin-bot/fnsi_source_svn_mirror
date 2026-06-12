package com.fnsi.cloudconverter.system;

import com.fnsi.cloudconverter.system.model.SystemInfoResponse;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

@RestController
@RequestMapping("/api/v1/system")
public class SystemInfoController {

    private static final Pattern POSTGRES_JDBC_PATTERN =
            Pattern.compile("^jdbc:postgresql://(?<host>[^/:?]+)(?::(?<port>\\d+))?/.*$");

    private final String converterJdbcUrl;

    public SystemInfoController(@Value("${spring.datasource.jdbc-url}") String converterJdbcUrl) {
        this.converterJdbcUrl = converterJdbcUrl;
    }

    @GetMapping("/info")
    public ResponseEntity<SystemInfoResponse> getSystemInfo() {
        Matcher matcher = POSTGRES_JDBC_PATTERN.matcher(converterJdbcUrl);
        if (!matcher.matches()) {
            throw new IllegalStateException("convert_db JDBC URL の解析に失敗しました: " + converterJdbcUrl);
        }

        String host = matcher.group("host");
        String portValue = matcher.group("port");
        int port = portValue == null || portValue.isEmpty() ? 5432 : Integer.parseInt(portValue);

        return ResponseEntity.ok(new SystemInfoResponse(host, port));
    }
}
