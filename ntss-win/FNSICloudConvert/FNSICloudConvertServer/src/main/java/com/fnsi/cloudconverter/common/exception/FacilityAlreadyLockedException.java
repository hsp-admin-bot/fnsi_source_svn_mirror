package com.fnsi.cloudconverter.common.exception;

public class FacilityAlreadyLockedException extends RuntimeException {
    public FacilityAlreadyLockedException(String facilityCd) {
        super("施設 " + facilityCd + " は現在処理中です。しばらく後に再試行してください。");
    }
}
