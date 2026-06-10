package jp.co.nikkiso.ntss.admin_web.web.rest.util;

import java.net.URI;
import java.net.URISyntaxException;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpHeaders;


public class PaginationUtils {

  public static final int DEFAULT_OFFSET = 1;

  public static final int MIN_OFFSET = 1;

  public static final int DEFAULT_LIMIT = 20;

  public static final int MAX_LIMIT = 100;

  public static Pageable generatePageRequest(Integer offset, Integer limit) {
    return generatePageRequest(offset, limit, null);
  }

  private static Pageable generatePageRequest(Integer offset, Integer limit, Sort sort) {
    if (offset == null || offset < MIN_OFFSET) {
      offset = DEFAULT_OFFSET;
    }
    if (limit == null || limit > MAX_LIMIT) {
      limit = DEFAULT_LIMIT;
    }
    sort = sort == null?Sort.unsorted():sort; /* add by shiyw 2023-04-18 [#8271] jdk8->aws jdk17 --start */
    return PageRequest.of(offset - 1, limit, sort);
  }

  public static HttpHeaders generatePaginationHttpHeaders(Page<?> page, String baseUrl, Integer offset, Integer limit)
      throws URISyntaxException {

    if (offset == null || offset < MIN_OFFSET) {
      offset = DEFAULT_OFFSET;
    }
    if (limit == null || limit > MAX_LIMIT) {
      limit = DEFAULT_LIMIT;
    }
    HttpHeaders headers = new HttpHeaders();
    headers.add("X-Total-Count", "" + page.getTotalElements());
    String link = "";
    if (offset < page.getTotalPages()) {
      link = "<" + (new URI(baseUrl + "?page=" + (offset + 1) + "&per_page=" + limit)).toString() + ">; rel=\"next\",";
    }
    if (offset > 1) {
      link += "<" + (new URI(baseUrl + "?page=" + (offset - 1) + "&per_page=" + limit)).toString() + ">; rel=\"prev\",";
    }
    link += "<" + (new URI(baseUrl + "?page=" + page.getTotalPages() + "&per_page=" + limit)).toString()
        + ">; rel=\"last\"," + "<" + (new URI(baseUrl + "?page=" + 1 + "&per_page=" + limit)).toString()
        + ">; rel=\"first\"";
    headers.add(HttpHeaders.LINK, link);
    return headers;
  }
}
