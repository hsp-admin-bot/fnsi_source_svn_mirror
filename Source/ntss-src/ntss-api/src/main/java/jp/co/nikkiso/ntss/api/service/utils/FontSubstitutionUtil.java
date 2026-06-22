// add #10633 【たくしん会】帳票のフォント問題 吉 start
package jp.co.nikkiso.ntss.api.service.utils;

import com.aspose.cells.Font;
import com.aspose.cells.Workbook;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.core.dao.SysSystemDefineDao;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Component;

import java.awt.GraphicsEnvironment;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

@Component
public class FontSubstitutionUtil implements ApplicationContextAware {

  private static ApplicationContext applicationContext;

  @Override
  public void setApplicationContext(ApplicationContext context) {
    applicationContext = context;
  }

  // add #10633 【たくしん会】帳票のフォント問題 高 start
  public static Map<String,String> checkAndReplaceFontsSvg(Workbook workbook) throws Exception {
    Map<String,String> fontMap = new HashMap<>();
    SysSystemDefineDao dao = applicationContext.getBean(SysSystemDefineDao.class);
    // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　start
//    Map<String, List<String>> fontRules = loadFontRulesFromDB(dao);
    Map<String, String> fontRules = loadFontRulesFromDB(dao);
    String defaultFont = loadDefaultFontRulesFromDB(dao);
    // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　end
    Set<String> systemFonts = getSystemFonts();
    Set<String> lowerCaseSystemFonts = new HashSet<>();
    for (String font : systemFonts) {
      lowerCaseSystemFonts.add(font.toLowerCase());
    }
    Font[] fonts = workbook.getFonts();
    // add #10633 【たくしん会】【因島】帳票のフォント問題 高　start
    List<String> fontNameList = new ArrayList<>();
    // add #10633 【たくしん会】【因島】帳票のフォント問題 高　end
    for (Font font : fonts) {
      // add #10633 【たくしん会】【因島】帳票のフォント問題 高　start
      boolean fontReplaceFlag = false;
      // add #10633 【たくしん会】【因島】帳票のフォント問題 高　end
      String fontName = font.getName();
      if (!lowerCaseSystemFonts.contains(fontName.toLowerCase())) {
        // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　start
//        List<String> substitutes = fontRules.get(fontName);
        String substitutes = fontRules.get(fontName);
        // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　end
        // add #10633 【たくしん会】【因島】帳票のフォント問題 高　start
        // add #10633 【たくしん会】【因島】帳票のフォント問題 高　end
        if (substitutes != null) {
          // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　start
//          for (String sub : substitutes) {
//            if (lowerCaseSystemFonts.contains(sub.toLowerCase())) {
//              if (Arrays.stream(fonts).filter(p->p.getName().toLowerCase().equals(sub.toLowerCase())).collect(Collectors.toList()).size() > 0
//                || fontNameList.contains(sub)) {
//                continue;
//              }
//              fontNameList.add(sub);
//              fontMap.put(fontName,sub);
//              // add #10633 【たくしん会】【因島】帳票のフォント問題 高　start
//              fontReplaceFlag = true;
//              // add #10633 【たくしん会】【因島】帳票のフォント問題 高　end
//              break;
//            }
//          }
//          // add #10633 【たくしん会】【因島】帳票のフォント問題 高　start
//          if (!fontReplaceFlag) {
//            for (Map.Entry<String, Boolean> entry : filteredMap.entrySet()) {
//              String mapGetFontKey = entry.getKey();
//              Boolean mapGetFontValue = entry.getValue();
//              if (mapGetFontValue) {
//                // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　start
////                fontMap.put(fontName,mapGetFontKey);
////                lowerCaseSystemFontsFilter.put(entry.getKey(),false);
////                entry.setValue(false);
////                break;
//                if (!moreNameList.contains(fontName)) {
//                  moreNameList.add(fontName);
//                  fontMap.put(fontName,mapGetFontKey);
//                  lowerCaseSystemFontsFilter.put(entry.getKey(),false);
//                  entry.setValue(false);
//                  break;
//                }
//                // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　end
//              }
//            }
//          }
//          // add #10633 【たくしん会】【因島】帳票のフォント問題 高　end
//        } else {
//          fontMap.put(fontName,"sans-serif");
//        }
          if (lowerCaseSystemFonts.contains(substitutes.toLowerCase())) {
            fontMap.put(fontName,substitutes);
          }
          else {
            fontMap.put(fontName,defaultFont);
          }
        } else {
          fontMap.put(fontName,defaultFont);
        }
        // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　end
      }
    }
    return fontMap;
  }
  // add #10633 【たくしん会】帳票のフォント問題 高 end

  public static Map<String,String> checkAndReplaceFonts(Workbook workbook) throws Exception {
    Map<String,String> fontMap = new HashMap<>();
    SysSystemDefineDao dao = applicationContext.getBean(SysSystemDefineDao.class);
    // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　start
//    Map<String, List<String>> fontRules = loadFontRulesFromDB(dao);
    Map<String, String> fontRules = loadFontRulesFromDB(dao);
    String defaultFont = loadDefaultFontRulesFromDB(dao);
    // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　end
    Set<String> systemFonts = getSystemFonts();
    Set<String> lowerCaseSystemFonts = new HashSet<>();
    for (String font : systemFonts) {
      lowerCaseSystemFonts.add(font.toLowerCase());
    }
    Font[] fonts = workbook.getFonts();

    for (Font font : fonts) {
      String fontName = font.getName();
      if (!lowerCaseSystemFonts.contains(fontName.toLowerCase())) {
        // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　start
//        List<String> substitutes = fontRules.get(fontName);
//        if (substitutes != null) {
//          for (String sub : substitutes) {
//            if (lowerCaseSystemFonts.contains(sub.toLowerCase())) {
//              fontMap.put(fontName,sub);
//              break;
//            }
//          }
        String substitutes = fontRules.get(fontName);
        if (substitutes != null) {
          if (lowerCaseSystemFonts.contains(substitutes.toLowerCase())) {
            fontMap.put(fontName,substitutes);
          } else {
            fontMap.put(fontName,defaultFont);
          }
          // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　end
        } else {
          // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　start
//          fontMap.put(fontName,"sans-serif");
          fontMap.put(fontName,defaultFont);
          // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　end
        }
      }
    }
    return fontMap;
  }

  // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　start
//  private static Map<String, List<String>> loadFontRulesFromDB(SysSystemDefineDao dao) throws Exception {
  // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　start
//  public static Map<String, List<String>> loadFontRulesFromDB(SysSystemDefineDao dao) throws Exception {
  public static Map<String, String> loadFontRulesFromDB(SysSystemDefineDao dao) throws Exception {
    // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　end
    // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　end
    SysSystemDefine sysSystemDefine = dao.selectOnPremise(1013);
    // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　start
//    Map<String, List<String>> result = new LinkedHashMap<>();
    Map<String, String> result = new LinkedHashMap<>();
    // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　end
    String json = sysSystemDefine.getValue();
    ObjectMapper mapper = new ObjectMapper();
    JsonNode root = mapper.readTree(json);
    JsonNode fontconfig = root.get("fontconfig");
    for (JsonNode aliasWrapper : fontconfig) {
      JsonNode alias = aliasWrapper.get("alias");
      String mainFont = alias.get("family").asText();
      List<String> prefers = new ArrayList<>();

      // mod #10633 【たくしん会】【因島】帳票のフォント問題 高　start
//      JsonNode preferArray = alias.get("prefer");
      JsonNode preferArray = alias.get("from");
      // mod #10633 【たくしん会】【因島】帳票のフォント問題 高 end
      if (preferArray != null && preferArray.isArray()) {
        for (JsonNode p : preferArray) {
          prefers.add(p.get("family").asText());
          // add #10633 【たくしん会】【因島】帳票のフォント問題 高　start
          result.put(p.get("family").asText(), mainFont);
          // add #10633 【たくしん会】【因島】帳票のフォント問題 高　end
        }
      }
      // del #10633 【たくしん会】【因島】帳票のフォント問題 高　start
//      result.put(mainFont, prefers);
      // del #10633 【たくしん会】【因島】帳票のフォント問題 高　end
    }
    return result;
  }

  // add #10633 【たくしん会】【因島】帳票のフォント問題 高　start
  public static String loadDefaultFontRulesFromDB(SysSystemDefineDao dao) throws Exception {
    SysSystemDefine sysSystemDefine = dao.selectOnPremise(1013);
    String json = sysSystemDefine.getValue();
    ObjectMapper mapper = new ObjectMapper();
    JsonNode root = mapper.readTree(json);
    String fontconfig = root.get("default").asText();
    return fontconfig;
  }
  // add #10633 【たくしん会】【因島】帳票のフォント問題 高　end

  // add #10633 【たくしん会】【因島】帳票のフォント問題 高　start
  /**
   *
   * すべてのシステムフォントを取得する方法
   *
   * */
  public static Set<String> getSystemFonts() {
    GraphicsEnvironment ge = GraphicsEnvironment.getLocalGraphicsEnvironment();
    return new HashSet<>(Arrays.asList(ge.getAvailableFontFamilyNames()));
  }
  // add #10633 【たくしん会】【因島】帳票のフォント問題 高　end
  // del #10633 【たくしん会】【因島】帳票のフォント問題 高　start
//  private static Set<String> getSystemFonts() {
//    Set<String> fontNames = new HashSet<>();
//    List<String> fontDirs = new ArrayList<>();
//
//    String os = System.getProperty("os.name").toLowerCase();
//    if (os.contains("win")) {
//      fontDirs.add(System.getenv("WINDIR") + "\\Fonts");
//    } else {
//      fontDirs.add("/usr/share/fonts");
//      fontDirs.add("/usr/local/share/fonts");
//      fontDirs.add(System.getProperty("user.home") + "/.fonts");
//    }
//
//    for (String dir : fontDirs) {
//      try {
//        Files.walk(Paths.get(dir))
//          .filter(Files::isRegularFile)
//          .filter(path -> path.toString().toLowerCase().matches(".*\\.(ttf|otf|ttc)$"))
//          .forEach(path -> {
//            String name = path.getFileName().toString().toLowerCase();
//            if (name.endsWith(".ttf")) name = name.replace(".ttf", "");
//            if (name.endsWith(".otf")) name = name.replace(".otf", "");
//            if (name.endsWith(".ttc")) name = name.replace(".ttc", "");
//            fontNames.add(name);
//          });
//      } catch (Exception ignored) {}
//    }
//    return fontNames;
//  }
  // add #10633 【たくしん会】【因島】帳票のフォント問題 高　end
}
// add #10633 【たくしん会】帳票のフォント問題 吉 end
