package com.fnsi.cloudconverter.clear.transit.file;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;

import java.io.IOException;
import java.nio.file.*;
import java.nio.file.attribute.BasicFileAttributes;
import java.util.List;

@Slf4j
@Service
public class TransitFileClearServiceImpl implements TransitFileClearService {

    @Override
    public void clearFacilityFiles(List<String> facilityCodes, Path transitFilePath) {
        for (String code : facilityCodes) {
            Path facilityDir = transitFilePath.resolve(code);
            if (Files.exists(facilityDir)) {
                try {
                    Files.walkFileTree(facilityDir, new SimpleFileVisitor<>() {
                        @Override
                        public FileVisitResult visitFile(Path f, BasicFileAttributes a) throws IOException {
                            Files.delete(f); return FileVisitResult.CONTINUE;
                        }
                        @Override
                        public FileVisitResult postVisitDirectory(Path d, IOException e) throws IOException {
                            Files.delete(d); return FileVisitResult.CONTINUE;
                        }
                    });
                    log.info("[CLEAR_TRANSIT_FILE] 削除: {}", facilityDir);
                } catch (IOException e) {
                    log.warn("[CLEAR_TRANSIT_FILE] 削除失敗: {}", facilityDir, e);
                }
            }
        }
    }
}
