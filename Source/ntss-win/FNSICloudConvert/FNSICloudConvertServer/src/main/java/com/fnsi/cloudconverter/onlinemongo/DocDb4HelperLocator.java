package com.fnsi.cloudconverter.onlinemongo;

import org.springframework.stereotype.Component;

import java.io.IOException;
import java.io.InputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.StandardCopyOption;

@Component
public class DocDb4HelperLocator {

    private static final String RESOURCE_PATH = "helper/fnsi-cloud-convert-docdb4-helper.jar";
    private final Object lock = new Object();
    private volatile Path extractedJar;

    public Path helperJar() {
        Path current = extractedJar;
        if (current != null && Files.exists(current)) {
            return current;
        }

        synchronized (lock) {
            current = extractedJar;
            if (current != null && Files.exists(current)) {
                return current;
            }

            try (InputStream in = Thread.currentThread()
                    .getContextClassLoader()
                    .getResourceAsStream(RESOURCE_PATH)) {
                if (in == null) {
                    throw new IllegalStateException("DocDB4 helper resource not found: " + RESOURCE_PATH);
                }

                Path dir = Path.of(System.getProperty("java.io.tmpdir"), "fnsi-cloud-convert-helper");
                Files.createDirectories(dir);
                Path target = dir.resolve("fnsi-cloud-convert-docdb4-helper.jar");
                Files.copy(in, target, StandardCopyOption.REPLACE_EXISTING);
                extractedJar = target;
                return target;
            } catch (IOException ex) {
                throw new IllegalStateException("Failed to extract DocDB4 helper jar", ex);
            }
        }
    }
}
