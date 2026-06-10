package web.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import web.authentication.SignRequest;
import web.authentication.SignResponse;
import web.exception.AccountNotFoundException;
import web.exception.WrongCredentialsException;
import web.service.UserService;

@RestController
public class LoginController {

    @Autowired
    private UserService userService;

    /**
     * ログインインタフェース
     *
     * @param requestBody
     * @return
     * @throws WrongCredentialsException
     */
    @PostMapping("/login")
    public SignResponse handleLogin(@RequestBody SignRequest requestBody) throws WrongCredentialsException, AccountNotFoundException {
        return userService.userLogin(requestBody);
    }

}
