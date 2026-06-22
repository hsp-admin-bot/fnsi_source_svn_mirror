package utils;

public class ConvertQueue {

    private String facility_cd;
    private String inputFilePath;

    public ConvertQueue(String facility_cd, String inputFilePath) {
        this.facility_cd = facility_cd;
        this.inputFilePath = inputFilePath;
    }

    public String getFacility_cd() {
        return facility_cd;
    }

    public void setFacility_cd(String facility_cd) {
        this.facility_cd = facility_cd;
    }

    public String getInputFilePath() {
        return inputFilePath;
    }

    public void setInputFilePath(String inputFilePath) {
        this.inputFilePath = inputFilePath;
    }
}
