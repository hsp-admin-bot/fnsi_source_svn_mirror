package jp.co.nikkiso.ntss.core.logger;

import java.util.List;

import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class FileInfoModelLog {
    private String root;
    private List lstFile;
    private String currentPath;
	public FileInfoModelLog(String root, List lstFile, String currentPath) {
		super();
		this.root = root;
		this.lstFile = lstFile;
		this.currentPath = currentPath;
	}
	public FileInfoModelLog() {}
}

