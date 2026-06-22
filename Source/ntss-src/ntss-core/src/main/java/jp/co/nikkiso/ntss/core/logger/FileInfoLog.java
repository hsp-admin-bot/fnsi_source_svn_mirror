package jp.co.nikkiso.ntss.core.logger;

import lombok.Getter;
import lombok.Setter;

import java.util.Date;

@Getter
@Setter
public class FileInfoLog {
	private boolean isFolder;
	private boolean isHidden;
    private String name;
    private long size;
    private Date createDate;
	public FileInfoLog() {}
	public FileInfoLog(
        boolean isFolder,
        boolean isHidden,
        String name,
        long size,
        Date createDate
    ) {
		super();
		this.isFolder = isFolder;
		this.isHidden = isHidden;
        this.name = name;
        this.size = size;
        this.createDate = createDate;
	};
}