package batch.part;

import java.io.IOException;

import org.junit.jupiter.api.Test;

public class SqlFileVisitorTest {
    @Test
    public void getSqlFileListTest() {
        try {
            FileVisitor.getSqlFileList("./").forEach(System.out::println);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}