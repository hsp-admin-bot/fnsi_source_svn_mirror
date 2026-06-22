package jp.co.nikkiso.ntss.api.service.utils;

public class InvokeResult<T> {

    private boolean success;
    private String code;
    private String message;
    private T data;

    public InvokeResult() {}

    public InvokeResult success(T data) {
        this.success = true;
        this.code = null;
        this.message = null;
        this.data = data;
        return this;
    }

    public InvokeResult fail(String code, String message, T data) {
        this.success = false;
        this.code = code;
        this.message = message;
        this.data = data;
        return this;
    }

    public boolean isSuccess(){
        return success;
    }

    public String getCode() {
        return code;
    }

    public String getMessage() {
        return message;
    }

    public T getData() {
        return data;
    }

}
