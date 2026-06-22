package com.fnsi.cloudconverter.auth;

import com.fnsi.cloudconverter.auth.model.LoginRequest;
import com.fnsi.cloudconverter.auth.model.LoginResponse;
import com.fnsi.cloudconverter.auth.model.RefreshRequest;
import com.fnsi.cloudconverter.auth.model.RefreshResponse;

public interface AuthService {
    LoginResponse login(LoginRequest request);
    RefreshResponse refresh(RefreshRequest request);
}
