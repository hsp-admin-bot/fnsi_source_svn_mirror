package batch.writer;

import java.io.*;
import java.nio.ByteBuffer;
import java.nio.channels.FileChannel;
import java.nio.charset.StandardCharsets;
import java.util.Objects;

public class WriteSQLAnnotation {

    public boolean UpdateWriteSQLFile(String filePath, String sql) {
        String newSQLStr = "--" + sql;
        String newFileContent = readFileContent(filePath, sql , newSQLStr, "Update");
        Boolean isWriterSucceed = fileNioWrite(filePath, newFileContent, false);
        return isWriterSucceed;
    }

    public boolean DeleteWriteSQLFile(String filePath, String sql) {
        String newSQLStr = "";
        String newFileContent = readFileContent(filePath, sql , newSQLStr, "Del");
        Boolean isWriterSucceed = fileNioWrite(filePath, newFileContent, false);
        return isWriterSucceed;
    }
    // ファイルを読み込む
    public String readFileContent(String filePath, String oldString, String newString, String UpdatOrDelState) {
        //mod #9862 close stream 2023-10-27 liushengnan start
        String line = null;
        StringBuffer bufAll = new StringBuffer();// 修正したものはすべて保存します
        try (BufferedReader br = new BufferedReader(new InputStreamReader(new FileInputStream(filePath), StandardCharsets.UTF_8))){
            while ((line = br.readLine()) != null) {
                StringBuffer buf = new StringBuffer();
                // 内容コアコードを修正します
                if (oldString.equals(line)) {//判断条件は自分の要求に合わせて修正する
                    if(UpdatOrDelState.equals("Update"))
                    {
                        buf.append(line);
                        buf.replace(0, oldString.length(), newString);// 内容を修正する
                        buf.append(System.getProperty("line.separator"));// 改行を入れる
                        bufAll.append(buf);
                    }
                } else {
                    buf.append(line);
                    buf.append(System.getProperty("line.separator"));
                    bufAll.append(buf);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return bufAll.toString();
        //mod #9862 close stream 2023-10-27 liushengnan end
    }


    /**
     *  NIO write file
     *
     * @param path ファイルアドレス
     * @param content 書き込み内容
     * @param writeType 書き込みタイプfalse上書き、true追加
     */
    public boolean fileNioWrite(String path, String content, boolean writeType) {
        FileChannel channel = null;
        FileOutputStream outputStream = null;
        try {
            outputStream = new FileOutputStream(path, writeType);
            channel = outputStream.getChannel();
            byte[] bytes = content.getBytes();
            ByteBuffer buffer = ByteBuffer.allocateDirect(bytes.length);
            buffer.put(bytes);
            buffer.flip();
            channel.write(buffer);
            buffer.clear();
        } catch (Exception e) {
            e.printStackTrace();
            return false;
        } finally {
            close(channel, outputStream);
        }
        return true;
    }


    /**
     * 可変パラメータオフcloseable実装
     *
     * @param readers ファイル読み込みオブジェクト
     */
    private void close(Closeable... readers) {
        try {
            for (Closeable reader : readers) {
                if (Objects.nonNull(reader)) {
                    reader.close();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            System.err.println("CLOSE FAIL !");
        }
    }


}
