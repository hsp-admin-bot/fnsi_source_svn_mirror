package batch.part;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;

/**
 * 入力ストリームを監視して読み込み、文字列にして返すスレッド
 */
public class StreamThread extends Thread {
    private String outputString;
    private BufferedReader br;

    /** コンストラクタ */
    public StreamThread(InputStream is) {
        br = new BufferedReader(new InputStreamReader(is));
    }

    /** コンストラクタ */
    public StreamThread(InputStream is, String charset) {
        try {
            br = new BufferedReader(new InputStreamReader(is, charset));
        } catch (UnsupportedEncodingException e) {
            // ここでのRuntimeExceptionが発生する場合は
            // charsetの指定ミスのため、例外をスローする
            throw new RuntimeException(e);
        }
    }

    @Override
    public void run(){
        try {
            outputString = "";
            for (;;) {
                String line = br.readLine();
                if (line == null) 	break;
                outputString += line;
            }
        } catch (IOException e) {
            throw new RuntimeException(e);
        } finally {
            try {
                br.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * 出力文字列取得
     */
    public String getOutputString(){
        return this.outputString;
    }
}