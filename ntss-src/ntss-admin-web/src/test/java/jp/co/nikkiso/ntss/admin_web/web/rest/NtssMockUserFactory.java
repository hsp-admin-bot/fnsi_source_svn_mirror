package jp.co.nikkiso.ntss.admin_web.web.rest;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContext;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.test.context.support.WithSecurityContextFactory;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import org.springframework.util.StringUtils;

public class NtssMockUserFactory implements WithSecurityContextFactory<NtssMockUser> {

    @Override
    public SecurityContext createSecurityContext(NtssMockUser annotation) {
      SecurityContext context = SecurityContextHolder.createEmptyContext();

        String facilityCd = annotation.facilityCd();
        Long userId = annotation.userId();
        Integer userType = annotation.userType();
        final Integer administrator = annotation.administrator();

      List<GrantedAuthority> authorities = Collections.emptyList();
        if (!StringUtils.isEmpty(annotation.authority())) {
          authorities = Arrays.asList(new SimpleGrantedAuthority(annotation.authority()));
        }

        UserDetails user = new NtssUser(
          facilityCd,
          "username",
          "password",
          userId,
          userType,
          administrator,
          0,
          authorities
        );
        Authentication authentication = new UsernamePasswordAuthenticationToken(
                                            user, user.getPassword(), user.getAuthorities());

        context.setAuthentication(authentication);

        return context;
    }

}
