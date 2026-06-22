package web.config;

import java.util.Timer;
import java.util.TimerTask;
import ch.qos.logback.classic.LoggerContext;
import ch.qos.logback.classic.spi.ILoggingEvent;
import ch.qos.logback.core.Appender;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.stereotype.Component;

import java.util.Iterator;

@Component
public class StartupCompleteListener implements ApplicationRunner {

    @Override
    public void run(ApplicationArguments args) throws Exception {
        Timer timer = new Timer();
        timer.schedule(new TimerTask() {
            @Override
            public void run() {
                LoggerContext context = (LoggerContext) LoggerFactory.getILoggerFactory();
                Logger rootLogger = context.getLogger(org.slf4j.Logger.ROOT_LOGGER_NAME);
                Appender<ILoggingEvent> toFileAppender = null;
                for (Iterator<Appender<ILoggingEvent>> iterator = ((ch.qos.logback.classic.Logger) rootLogger).iteratorForAppenders(); iterator.hasNext();) {
                    Appender<ILoggingEvent> appender = iterator.next();
                    if ("TO_FILE".equals(appender.getName())) {
                        toFileAppender = appender;
                        break;
                    }
                }
                if (toFileAppender != null) {
                    ((ch.qos.logback.classic.Logger) rootLogger).detachAppender(toFileAppender);
                }
            }
        }, 1000);
    }
}
