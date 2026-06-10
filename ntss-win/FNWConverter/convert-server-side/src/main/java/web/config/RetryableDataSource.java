package web.config;

import com.zaxxer.hikari.HikariDataSource;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.retry.annotation.Backoff;
import org.springframework.retry.annotation.Retryable;

import java.sql.Connection;
import java.sql.SQLException;

public class RetryableDataSource extends HikariDataSource {

    @Autowired
    private HikariDataSource hikariDataSource;

    public RetryableDataSource(HikariDataSource HikariDataSource) {
        this.hikariDataSource = HikariDataSource;
    }

    @Override
    @Retryable(value = {Exception.class}, maxAttempts = 10000, backoff = @Backoff(value = 4000, multiplier = 2, maxDelay = 20000))
    public Connection getConnection() throws SQLException {
        return hikariDataSource.getConnection();
    }

    @Override
    @Retryable(maxAttempts = 10000, backoff = @Backoff(value = 4000, multiplier = 2, maxDelay = 20000))
    public Connection getConnection(String username, String password) throws SQLException {
        System.out.println("getting connection by username and password ...");
        return hikariDataSource.getConnection(username, password);
    }
}
