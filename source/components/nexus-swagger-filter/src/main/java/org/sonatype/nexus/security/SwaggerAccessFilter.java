package org.sonatype.nexus.security;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Blocks unauthenticated access to Swagger API documentation endpoints.
 * Authenticated users (with NXSESSIONID cookie or Authorization header) can still access them.
 *
 * Build: javac --release 17 -cp javax.servlet-api-4.0.1.jar -d out SwaggerAccessFilter.java
 *        jar cf swagger-access-filter.jar -C out org
 */
public class SwaggerAccessFilter implements Filter {
  @Override
  public void init(FilterConfig filterConfig) throws ServletException {}

  @Override
  public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
      throws IOException, ServletException
  {
    HttpServletRequest httpReq = (HttpServletRequest) request;
    String path = httpReq.getRequestURI();

    if (path != null && path.matches(".*/service/rest/swagger\\.(json|yaml)")) {
      if (!isAuthenticated(httpReq)) {
        ((HttpServletResponse) response).sendError(HttpServletResponse.SC_FORBIDDEN, "Forbidden");
        return;
      }
    }
    chain.doFilter(request, response);
  }

  private boolean isAuthenticated(HttpServletRequest request) {
    if (request.getHeader("Authorization") != null) {
      return true;
    }
    Cookie[] cookies = request.getCookies();
    if (cookies != null) {
      for (Cookie cookie : cookies) {
        if ("NXSESSIONID".equals(cookie.getName())) {
          return true;
        }
      }
    }
    return false;
  }

  @Override
  public void destroy() {}
}
