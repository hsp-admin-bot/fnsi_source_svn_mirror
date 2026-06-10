package jp.co.nikkiso.ntss.core.logger;

import java.io.BufferedReader;
import java.io.File;
import java.io.FileInputStream;
import java.io.FilenameFilter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;

public class ReadLogAPI {

	/**
	 * 読み取りログAPI
	 *
	 * @param folderName
	 * @param fileName
	 * @return
	 * @throws ParseException
	 */
	public List<EventLogAPI> ReadLog(String folderName, String fileName) throws ParseException {
		List<EventLogAPI> eventLogAPIs = new ArrayList<>();
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy/MM/dd hh:mm:ss");
		BufferedReader in = null;
		try {
			File fileDir = new File(folderName + "/" + fileName);
			in = new BufferedReader(new InputStreamReader(new FileInputStream(fileDir), "UTF-8"));
			String str;
			while ((str = in.readLine()) != null) {
				try {
					if (str.trim().length() > 0) {
						List<Integer> positions = new ArrayList<>();
						for (int i = 0; i < str.length(); i++) {
							if (str.charAt(i) == '"') {
								positions.add(i);
							}
						}
						List<String> arr = new ArrayList<String>();
						for (int i = 0; i < positions.size(); i += 2) {
							arr.add(str.substring(positions.get(i) + 1, positions.get(i + 1)));
						}
						EventLogAPI eventApi = new EventLogAPI(sdf.parse(arr.get(0)), arr.get(1), arr.get(2), arr.get(3), arr.get(4),
							arr.get(5), arr.get(6), arr.get(7), arr.get(8), arr.get(9), arr.get(10), arr.get(11), arr.get(12),
							arr.get(13), arr.get(14), arr.get(15), arr.get(16));
						eventLogAPIs.add(eventApi);
					}
				} catch (Exception e) {}
			}

		} catch (Exception e) {
			return eventLogAPIs;
		} finally {
		  if (in != null) {
            try {
              in.close();
            } catch (IOException e) {
            }
		  }
		}
		return eventLogAPIs;
	}

	/**
	 *
	 * @param folderName
	 * @return
	 */
	public List<String> ReadPathFile(String folderName) {
		try {
			File directoryPath = new File(folderName);
			List<String> fileNameLst = new ArrayList<>();
			File[] files = directoryPath.listFiles(new FilenameFilter() {
				@Override
				public boolean accept(File dir, String name) {
					return name.endsWith(".log");
				}
			});

			for (File file : files) {
				String fileNames = file.getName().toString();
				fileNameLst.add(fileNames);
			}
			return fileNameLst;
		} catch (Exception e) {
			return null;
		}
	}

}
