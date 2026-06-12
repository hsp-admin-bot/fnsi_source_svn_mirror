# 06 既存業務サービス参照文書（ntss-admin-web）

> **参照元**: `ntss-admin-web`（Spring Boot 2 / 在線業務認証サービス）
> **目的**: FNSi Cloud Converter 実装時の参照情報として既存サービスの認証・セキュリティ・ログ設計を記録する
> **作成日**: 2026-03-12

---

## 1. プロジェクト基本情報

| 項目 | ntss-admin-web（既存） | FNSi Cloud Converter（新規） |
|------|----------------------|---------------------------|
| Spring Boot | 2.x | 4.0.6 |
| Java | 未明示（JVM デフォルト） | Amazon Corretto 25.0.3 |
| ビルドツール | Gradle 7.2 | Gradle 9.5.0 |
| パッケージルート | `jp.co.nikkiso.ntss.admin_web` | `com.fnsi.cloudconverter` |
| サーバーポート | 8080 | 8080 |
| コンテキストパス | `/ntss-admin-web` | `/api/v1`（ベースパス） |
| 起動形式 | WAR（Tomcat 組込み / 外部両対応） | JAR（組込みサーバー） |

---

## 2. 依存ライブラリ（参照用）

### 2.1 既存サービス主要依存

```groovy
// Spring Boot Starters
spring-boot-starter-web
spring-boot-starter-security
spring-boot-starter-jdbc
spring-boot-starter-actuator
spring-boot-starter-validation
spring-boot-starter-aop
spring-boot-starter-data-mongodb

// ORM
doma-spring-boot-starter  // Doma2（SQL ベース ORM）
postgresql                 // PostgreSQL ドライバ

// セキュリティ
bcprov-jdk15on:1.64        // BouncyCastle（暗号化）

// ユーティリティ
lombok:1.18.28
gson:2.8.6
commons-lang3:3.9
zxing:3.2.1               // QR コード生成（OTP 用）
```

### 2.2 FNSi Cloud Converter 向け対応選定（参考）

| 機能 | 既存 | 新規採用候補 |
|------|------|------------|
| ORM | Doma2 | Spring Data JPA（Hibernate 7） |
| JWT | 未使用（セッション認証） | JJWT 0.12.x |
| JSON | Gson / Jackson | Jackson（Spring Boot 標準） |
| パスワード暗号化 | BCryptPasswordEncoder | BCryptPasswordEncoder（踏襲） |
| DB マイグレーション | Flyway 6.0.4 | Flyway 11.x |

---

## 3. 認証実装（参照）

### 3.1 既存の認証フロー

```
クライアント
  │
  │ POST /ntss-admin-web/login
  │   userId, password, facilityCd(ハッシュ), funcCd, cardCd
  │
  ▼
NtssAuthenticationFilter（UsernamePasswordAuthenticationFilter 拡張）
  │
  ├── facilityCd ハッシュ → 実施設コード 解決
  ├── クライアント証明書検証（設定による）
  ├── VPN アクセス確認（ホスト名パターン）
  │
  ▼ NtssAuthenticationToken 生成
NtssAuthenticationProvider（AbstractUserDetailsAuthenticationProvider 拡張）
  │
  ├── NtssUserDetailsService → MstUserAuthenticationDao でユーザー取得
  ├── BCryptPasswordEncoder でパスワード検証
  ├── アカウントロック確認（失敗回数）
  ├── ユーザータイプ整合性確認（auth DB / personal DB）
  │
  ▼ 認証成功
NtssAuthenticationSuccessHandler
  │
  ├── OTP 検証・リダイレクト（2段階認証）
  ├── セッションタイムアウト設定（施設設定値）
  ├── SessionRegistry に登録
  ├── MongoDB へ認証ログ記録
  │
  ▼ JSON レスポンス返却
  { facilityCd, userId, userType }
```

### 3.2 カスタムトークンクラス構成

```java
// 既存: NtssAuthenticationToken
class NtssAuthenticationToken extends UsernamePasswordAuthenticationToken {
    String facilityCd;   // 施設コード
    String funcCd;       // 機能コード
    String cardCd;       // カードコード
    boolean userIdOnly;  // 自動ログインフラグ
    String mode;         // 操作モード
}

// 既存: NtssUser（UserDetails 実装）
class NtssUser extends User {
    String facilityCd;
    String userId;         // 内部ユーザーID
    String userType;
    boolean administrator;
    int failureCnt;        // ログイン失敗回数
    String sessionId;      // セッションID（認証後にセット）
    String clientIpAddress;
}
```

### 3.3 FNSi Cloud Converter への適用方針

既存はセッション認証。新規は **JWT Bearer Token 認証**。以下の対応関係で実装する:

| 既存（セッション） | 新規（JWT） |
|-----------------|-----------|
| `NtssAuthenticationFilter` | `JwtAuthenticationFilter`（OncePerRequestFilter） |
| `NtssAuthenticationProvider` | `AuthService.login()` |
| `NtssUser`（セッション保持） | JWT ペイロード（userId, roles） |
| `NtssAuthenticationSuccessHandler` | `LoginResponse`（accessToken, refreshToken） |
| `NtssAuthenticationEntryPoint` | 401 JSON レスポンス（共通エラーハンドラー） |
| `SessionRegistry` | 不要（JWT はステートレス） |
| セッションタイムアウト | JWT `expiresIn`（1時間）+ リフレッシュトークン（24時間） |

---

## 4. Spring Security 設定（参照）

### 4.1 既存の SecurityConfig 構成

```java
// 既存の主要設定内容（Spring Boot 2 / WebSecurityConfigurerAdapter）

// セキュリティ除外パス（静的リソース等）
web.ignoring().antMatchers("/css/**", "/fonts/**", "/img/**", "/js/**", ...)

// 認可ルール
.authorizeRequests()
    .antMatchers(HttpMethod.OPTIONS).denyAll()
    .antMatchers("/", "/login", "/logout", ...).permitAll()
    .anyRequest().authenticated()

// CSRF
.csrf().csrfTokenRepository(CookieCsrfTokenRepository.withHttpOnlyFalse())
    .ignoringAntMatchers("/login")

// セッション管理
.sessionManagement()
    .maximumSessions(-1)                          // 無制限
    .sessionRegistry(sessionRegistry)
    .expiredUrl(...)

// カスタムフィルター順序
addFilterBefore(sessionTimeoutManageFilter, ...)
addFilterAt(ntssAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
addFilterAfter(concurrentSessionFilter, ...)
addFilterAfter(ntssSessionFilter, ...)

// ログアウト
.logout()
    .logoutUrl(Uri.LOGOUT)
    .invalidateHttpSession(true)
    .clearAuthentication(true)
    .deleteCookies("JSESSIONID")
    .logoutSuccessHandler(customLogoutSuccessHandler)

// パスワードエンコーダー
@Bean BCryptPasswordEncoder passwordEncoder()
```

### 4.2 FNSi Cloud Converter への適用方針

Spring Boot 4.0 では `WebSecurityConfigurerAdapter` が削除済み。`SecurityFilterChain` Bean 方式で実装する。

```java
// 新規: Spring Boot 4.0 スタイル（参考テンプレート）
@Bean
SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
    return http
        // JWT 使用のためセッション無効化
        .sessionManagement(s -> s.sessionCreationPolicy(STATELESS))
        // CSRF 無効化（REST API + JWT のため不要）
        .csrf(AbstractHttpConfigurer::disable)
        // 認可ルール
        .authorizeHttpRequests(auth -> auth
            .requestMatchers("/auth/login", "/auth/refresh").permitAll()
            .anyRequest().authenticated()
        )
        // JWT フィルター追加
        .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class)
        // 認証エントリーポイント（401 JSON 返却）
        .exceptionHandling(e -> e.authenticationEntryPoint(jwtAuthEntryPoint))
        .build();
}

// パスワードエンコーダー（既存と同一）
@Bean
PasswordEncoder passwordEncoder() {
    return new BCryptPasswordEncoder();
}
```

### 4.3 既存のフィルター構成（参照）

| フィルター | 役割 | 新規適用 |
|-----------|------|---------|
| `SessionTimeoutManageFilter` | バックグラウンドリクエストをセッションタイムアウト対象外にする | 不要（JWT はステートレス） |
| `NtssAuthenticationFilter` | 認証フィルター本体 | `JwtAuthenticationFilter` に置換 |
| `ConcurrentSessionFilter` | セッション重複制御 | 不要 |
| `NtssSessionFilter` | セッション有効性確認 | 不要 |

---

## 5. ロギング実装（参照）

### 5.1 既存のログ構成

**フレームワーク**: Logback（SLF4J）
**設定ファイル**: `logback-spring.xml`

```xml
<!-- 既存の主要設定 -->
<logger name="jp.co.nikkiso.ntss" level="${logback.loglevel}" />
<logger name="org.springframework" level="WARN" />
<logger name="org.springframework.security" level="WARN" />
<logger name="org.mongodb.driver" level="ERROR" />

<!-- ファイルアペンダー -->
<!-- 開発: /tmp/ntss-admin-web/log/app/{0}/{0}.log -->
<!-- 本番: /opt/ntss-admin-web/log/{0}/{0}.log     -->
<!-- ローリング: 日次、14日保持                      -->
```

**ログレベル設定（application.yml）**:
```yaml
logging:
  level:
    org.springframework.transaction.interceptor: TRACE
    org.mongodb.driver: ERROR
```

### 5.2 アプリケーションログの種類（既存）

| ログ種別 | 実装 | 内容 |
|---------|------|------|
| アプリケーションログ | Logback ファイル | 処理ログ・デバッグ |
| 認証イベントログ | `EventLoggerFactory` | ログイン成功・失敗 |
| 監査ログ | MongoDB `LogService` | ユーザー操作履歴 |

### 5.3 FNSi Cloud Converter への適用方針

```java
// 新規: logback-spring.xml（参考テンプレート）
// パッケージルートが異なるため調整

<logger name="com.fnsi.cloudconverter" level="${LOG_LEVEL:-INFO}" />
<logger name="org.springframework" level="WARN" />
<logger name="org.springframework.security" level="WARN" />
<logger name="org.mongodb.driver" level="ERROR" />
<logger name="org.postgresql" level="WARN" />
```

アプリケーションログは `migration_task_log` テーブルへの DB ログ（Module 14）を使用。
Logback ファイルログはサーバー運用ログ（起動・エラー等）に使用する。

---

## 6. 例外ハンドリング（参照）

### 6.1 既存の例外ハンドラー構成

```java
// 既存: NtssExceptionHandler（@RestControllerAdvice）
@RestControllerAdvice
class NtssExceptionHandler {
    // データ不整合 → 401
    @ExceptionHandler(DataSourceInconsistencyException.class)
    ResponseEntity<ErrorResponse> handle(...) { return 401; }

    // バリデーション失敗
    @ExceptionHandler(RequiredException.class) ...

    // 楽観ロック競合
    @ExceptionHandler(OptimisticLockException.class) ...

    // キャッチオール
    @ExceptionHandler(Exception.class)
    ResponseEntity<ErrorResponse> handleAll(...) { return 500; }
}

// 既存エラーレスポンス形式
class ErrorResponse {
    String message;       // エラーメッセージ
    String exMessage;     // 例外メッセージ
    String stackTrace;    // スタックトレース（デバッグ用）
}
```

### 6.2 FNSi Cloud Converter への適用方針

既存の設計を参考に、API ドキュメント（02_api.md）で定義した共通エラー形式で実装する。

```java
// 新規: 共通エラーレスポンス（02_api.md 定義）
class ErrorResponse {
    String timestamp;  // "2026-02-25T10:00:00Z"
    int status;        // HTTP ステータスコード
    String error;      // "Bad Request" など
    String message;    // エラー詳細
    String path;       // "/api/v1/jobs"
}

// 新規: GlobalExceptionHandler（@RestControllerAdvice）
@RestControllerAdvice
class GlobalExceptionHandler {
    @ExceptionHandler(FacilityAlreadyLockedException.class)  → 409
    @ExceptionHandler(JobNotFoundException.class)             → 404
    @ExceptionHandler(MigrationBusinessException.class)      → 422
    @ExceptionHandler(AuthenticationException.class)         → 401
    @ExceptionHandler(Exception.class)                       → 500
}
```

---

## 7. マルチデータソース構成（参照）

### 7.1 既存のデータソース構成

```yaml
# 既存: application.yml（3 DB 構成）
datasource:
  default:   # ntss_db5 (nkk5) - メイン業務 DB
  personal:  # ntss_db6 (nkk6) - 個人情報 DB
  auth:      # ntss_db4 (nkk4) - 認証 DB
```

**接続先**: 同一 PostgreSQL インスタンス / 異なるDB名とスキーマ

### 7.2 FNSi Cloud Converter のデータソース構成（04_database.md より）

```yaml
# 新規: application.yml（7 DB 構成）
datasource:
  converter:    # convert_db - 管理テーブル（job, task, pk_mapping 等）
  transit-db1:  # transit_db_1 - 中転 DB（ntss_db4 相当）
  transit-db2:  # transit_db_2 - 中転 DB（ntss_db5 相当）
  transit-db3:  # transit_db_3 - 中転 DB（ntss_db6 相当）
  online-prod:  # 在線生産 RDS（SEQ 取得・CLEAR 処理用）
mongodb:
  transit:      # transit_mongo - 中転 Mongo
  online:       # 在線生産 DocumentDB
```

---

## 8. OTP（二段階認証）実装（参照）

### 8.1 既存の OTP フロー

```
1. ログイン成功後 → OTP 設定状態を確認
2. OTP 未設定     → QR コード生成画面へリダイレクト
3. OTP 設定済み   → OTP 入力画面へリダイレクト
4. OTP 検証成功   → 認証完了、メイン画面へ
5. OTP 検証失敗   → 失敗カウント増加、ロック機能あり

実装クラス:
- TwoFactAuth ユーティリティ（TOTP 検証）
- ZXing でQRコード生成
- OTP シークレットはユーザーマスタに保存
```

### 8.2 FNSi Cloud Converter への適用方針

DbMigrationTool クライアントは OTP 対応済み（user2/pass2 でテスト済み）。
サーバー側は `/auth/login` のレスポンスで OTP 要否を返す設計:

```json
// OTP 不要
{ "accessToken": "...", "refreshToken": "...", "expiresIn": 3600, "tokenType": "Bearer" }

// OTP 必要（拡張検討）
{ "otpRequired": true, "otpSessionToken": "..." }
```

---

## 9. ユーザー管理テーブル構成（参照）

### 9.1 既存の認証関連 DAO

| DAO | テーブル | 役割 |
|-----|---------|------|
| `MstUserAuthenticationDao` | 認証 DB（ntss_db4） | ユーザー認証情報 |
| `MstPersonalUserDao` | 個人 DB（ntss_db6） | 個人情報 |
| `MstFacilityHashDao` | 認証 DB | 施設コード↔ハッシュ対応 |
| `MstFacilitySettingDao` | メイン DB | 施設設定（タイムアウト等）|
| `MstUserDao` | メイン DB | ユーザーマスタ |

### 9.2 FNSi Cloud Converter のユーザー管理

Converter 専用ユーザーテーブルは**作成しない**。
認証は在線生産 DB（`ntss_db4`）の既存テーブル `mst_user_authentication` を直接参照する。

**認証テーブル（参照先）**:
```
DB:    ntss_db4（在線生産 PostgreSQL: localhost:5432）
TABLE: mst_user_authentication
```

| カラム | 型 | 説明 |
|--------|-----|------|
| `facility_cd` | TEXT | 施設コード |
| `disp_user_id` | TEXT | 表示用ユーザー ID |
| `user_password` | TEXT | BCrypt ハッシュパスワード |

**認証フロー（Spring Security UserDetailsService）**:
```java
// ConverterUserDetailsService
// username 形式: "{facilityCd}:{dispUserId}"（複合ユーザー名）

String sql = "SELECT user_password FROM mst_user_authentication " +
             "WHERE facility_cd = ? AND disp_user_id = ?";
```

**ログインリクエスト（クライアント → Converter サーバー）**:
```json
POST /auth/login
{
  "facilityCd":  "11166",
  "dispUserId":  "user01",
  "password":    "plain_password"
}
```

`AuthServiceImpl` が `{facilityCd}:{dispUserId}` の複合ユーザー名で `DaoAuthenticationProvider` に渡す。
BCryptPasswordEncoder が `user_password`（BCrypt ハッシュ）と照合する。

---

## 10. アプリケーション起動構成（参照）

### 10.1 既存のメインクラス

```java
// 既存: NtssAdminWebApplication.java
@SpringBootApplication(scanBasePackages = {
    "jp.co.nikkiso.ntss.admin_web",
    "jp.co.nikkiso.ntss.core",
    "jp.co.nikkiso.ntss.api"
})
@EnableScheduling
public class NtssAdminWebApplication extends SpringBootServletInitializer {
    public static void main(String[] args) {
        SpringApplication.run(NtssAdminWebApplication.class, args);
    }
}
```

### 10.2 FNSi Cloud Converter のメインクラス（参考テンプレート）

```java
// 新規: CloudConverterApplication.java
@SpringBootApplication
@EnableAsync        // Task 非同期実行用
@EnableScheduling   // 定期クリーンアップ用（将来）
public class CloudConverterApplication {
    public static void main(String[] args) {
        SpringApplication.run(CloudConverterApplication.class, args);
    }
}
```

---

## 11. パッケージ・ファイル構成比較

### 11.1 既存パッケージ構成（抜粋）

```
jp.co.nikkiso.ntss.admin_web/
├── security/          # SecurityConfig, Filter 群, Provider, Handler 群
├── handler/           # NtssExceptionHandler（@RestControllerAdvice）
├── web/
│   ├── rest/          # *Resource.java（150+ REST コントローラー）
│   └── filter/        # SessionTimeoutManageFilter
├── service/           # ビジネスロジック
├── request/           # リクエスト DTO
├── response/          # レスポンス DTO
├── config/            # 各種 Configuration クラス
└── aspect/            # AOP
```

### 11.2 FNSi Cloud Converter パッケージ構成（03_module.md より）

```
com.fnsi.cloudconverter/
├── auth/              # 認証（本文書を参照して実装）
├── job/               # JOB 制御
├── task/              # Task 制御
├── migration/
│   ├── pg/            # PG ダンプ/リストア
│   └── mongo/         # Mongo エクスポート/インポート
├── mapping/
│   ├── pk/            # PK マッピング
│   ├── fk/            # FK 設定（PG）
│   └── fkmongo/       # FK 設定（Mongo）
├── refresh/
│   ├── pg/            # PG FK 刷新
│   ├── mongo/         # Mongo FK 刷新
│   └── file/          # ファイル名 PK 置換
├── clear/             # データクリア（online/transit × pg/mongo/file）
├── facility/          # 施設一覧・件数
├── transfer/          # アップロード/ダウンロード
├── log/               # ログ出力
├── config/            # DataSource, Security 等の設定
└── util/
    └── archive/       # ZIP 圧縮/解凍
```

---

## 12. 実装優先順位（本文書に基づく推奨順）

既存サービスの参照から、以下の順序で実装を進めることを推奨する:

1. **プロジェクト雛形** — `build.gradle`（Spring Boot 4.0.x）+ メインクラス + `application.yml`
2. **DB 設定** — マルチデータソース Bean 定義 + Flyway マイグレーション（V1〜V6 DDL）
3. **認証モジュール** — `JwtTokenProvider` + `JwtAuthenticationFilter` + `AuthController`
4. **セキュリティ設定** — `SecurityFilterChain`（既存の `SecurityConfig` を参考に JWT 向けに変換）
5. **ログ設定** — `logback-spring.xml` + `MigrationLogService`
6. **例外ハンドラー** — `GlobalExceptionHandler`（既存 `NtssExceptionHandler` を参考に）
7. **施設・JOB API** — Controller → Service → Repository の順
8. **Task Engine** — `TaskExecutorService` + 各 Task 実装
