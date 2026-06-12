package batch.validator;

import org.springframework.batch.core.job.parameters.JobParameters;
import org.springframework.batch.core.job.parameters.InvalidJobParametersException;
import org.springframework.batch.core.job.parameters.JobParametersValidator;

import batch.ApplicationConst;

import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.Set;
import java.io.File;

/**
 * ジョブ起動時のジョブパラメータチェック
 */
public class ConvertJobValidator implements JobParametersValidator {

    private Collection<String> requiredKeys;

    public ConvertJobValidator() {
        super();
        this.requiredKeys = new HashSet<String>(Arrays.asList(
            ApplicationConst.JobParameterKeys.INPUT_FILE_PATH,
            ApplicationConst.JobParameterKeys.JOB,
            ApplicationConst.JobParameterKeys.FACILITY_CD
        ));
	}
    @Override
    public void validate(JobParameters params) throws InvalidJobParametersException {
        Collection<String> missingKeys = new HashSet<String>();

        // 必須チェック
		for (String key : requiredKeys) {
			if (params.getParameter(key) == null) {
				missingKeys.add(key);
			}
		}
		if (!missingKeys.isEmpty()) {
			throw new InvalidJobParametersException("JobParametersに必要なキーが含まれていません: " + missingKeys);
        }
        
        // 入力ファイル存在チェック
        String filePath = params.getString(ApplicationConst.JobParameterKeys.INPUT_FILE_PATH);
        File file = new File(filePath);

        // ファイルの存在を確認する
        if (!file.exists()) {
            throw new InvalidJobParametersException("ファイルが存在しません: " + filePath);
        }
    }

    
    
 }