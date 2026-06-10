# サーバサイド開発手順

サーバサイドでDBにテーブルを追加して、それに対するWeb APIを追加するまでの手順を説明します。
大まかな流れは以下の通りです。

1. DBにテーブルを追加する
2. エンティティクラスを作成する
3. DAOインタフェースを作成する
4. SQLファイルを作成する
5. サービスインタフェース・クラスを作成する
6. コントローラクラスを実装する

以降は上記のそれぞれのステップについて、`施設マスタ`を追加するという内容を例にして説明します。
特に注記がない場合はドキュメント中のファイルパスはプロジェクトのルートディレクトリからの相対パスとします。また、コマンドもプロジェクトのルートディレクトリで実行するものとします。
尚、以降のステップに進む前に[開発環境構築](../SETUP.md)にしたがって開発環境を構築してください。

## テーブル追加

データベースのスキーマは履歴の管理を行い、それに基づいてツールでDBのマイグレーションを実行します。マイグレーションには[flyway](https://flywaydb.org/)を利用します。flywayはSQLで書かれたスキーマに対する変更内容（テーブル作成、カラムの追加など）をデータベースに適用し、その履歴を管理することができるツールです。

`施設マスタ`のテーブルを追加するので、以下のようにそのSQLファイルを作成します。

施設マスタのCREATE TABLEのSQLファイル（`V20170906143300__create_facility.sql`):
```sql
CREATE TABLE facility (
  id SERIAL,
  name character varying(128) NOT NULL,
  idCode character varying(20) NOT NULL
);
COMMENT ON TABLE facility IS '施設マスタ';
COMMENT ON COLUMN facility.id IS '病医院一意コード';
COMMENT ON COLUMN facility.name IS '病医院名称';
COMMENT ON COLUMN facility.idCode IS '施設識別コード';
```

SQLファイルはデータベースに応じて、以下に配置します。
- 個人情報DB
  - `ntss-core/src/main/resources/db6/migration`
- 医療情報DB
  - `ntss-core/src/main/resources/db5/migration`
- 認証DB
  - `ntss-core/src/main/resources/db4/migration`

SQLファイル名は`V${version}__${description}.sql`のフォーマットとしてください。

- `${version}`:作成時点の年月日時分秒
- `${description}`: マイグレーションの内容を表す文（英語）

マイグレーションは`${version}`の値が小さいDBに未適応のSQLファイルが順に実行されてる仕組みになっています。

SQLファイルを作成したら以下のコマンドでマイグレーションを実行します。

```sh
./gradlew flywayMigrateAll
```


個別データベースを指定して、マイグレーションを行いたい場合(下記例は、`ntss_db5`を指定)は、以下のコマンドを実行します。
```sh
./gradlew db5FlywayMigrate
```

データベース上の全てのオブジェクトを削除したい場合は、以下のコマンドを実行します。

```sh
./gradlew flywayCleanAll
```

なお、プロファイルが`dev`(プロファイルを指定されていない際のデフォルトプロファイル)の場合、以下の配置場所にSQLを用意することでマイグレーション後にそのSQLを実行できます(`afterMigrate`)。SQLファイルのフォーマットは通常のマイグレーションファイルと同様です。

- 個人情報DB
  - `ntss-core/src/main/resources/db6/testdata`
- 医療情報DB
  - `ntss-core/src/main/resources/db5/testdata`
- 認証DB
  - `ntss-core/src/main/resources/db4/testdata`

## エンティティクラスの作成

Doma2ではDBのテーブルやクエリの結果セットに対応するエンティティというJavaクラスを作成し、そのDBの値をエンティティ経由で扱います。

施設マスタのテーブルに対応するエンティティのJavaファイルは
`ntss-core/src/main/java/jp/co/nikkiso/ntss/core/entity/MstFacilityHash.java`です。

下記は`MstFacilityHash.java`の一部抜粋です。
```java
@Entity(listener = BaseEntityListener.class, naming = NamingType.SNAKE_LOWER_CASE)
@Table(name = "mst_facility_hash")
@Getter
@Setter
public class MstFacilityHash extends BaseEntity {
  
  /**
   * 施設コード.
   */
  @Id
  private String facilityCd;
  
  /**
   * ハッシュ値.
   */
  private String hashValue;

```

エンティティクラスに対するアノテーションで結果セットとエンティティ（インスタンス）との対応などを定義します。各アノテーションの詳細は公式ドキュメント (https://doma.readthedocs.io/ja/stable/entity/) を参照して下さい。

`@Entity`アノーテーションに指定する`listener`には、特異なエンティティなど、やむを得ない場合を除き、個別の`EntityListener`を実装せず、`BaseEntityListener`を使用するようにしてください。

## Daoインタフェースの作成

DaoインタフェースでDBに対するアクセスを定義します。
Daoインタフェースの実装クラスはDoma2によりコンパイル時に自動生成されます（Pluggable Annotation Processing APIを利用して作成されます）。

施設マスタのテーブルに対応するDaoインタフェースのJavaファイルは`ntss-admin-web/src/main/java/jp/co/nikkiso/ntss/dao/FacilityDao.java`です。

下記は`FacilityDao.java`の一部抜粋です。
```java
@ConfigAutowireable
@Dao
public interface FacilityDao {
  @Select
  List<Facility> selectAll(SelectOptions options);

  @Select
  Facility selectById(Integer id);

  @Insert
  int insert(Facility facility);

  @Delete
  int delete(Facility facility);

  @Update
  int update(Facility facility);
}
```

Daoインタフェースのメソッドを実行すると対応するSQLが実行されます。
例えば、上記の`FacilityDao.selectById`メソッドを呼び出すとDoma2は`selectById.sql`を実行します。
`@Select`などの各アノテーションの詳細は公式ドキュメント (https://doma.readthedocs.io/ja/stable/dao/) を参照して下さい。

> 尚、`@ConfigAutowireable`はDaoインタフェースの実装クラスをSpringBootで管理するために付与するアノテーションです。SpringBootなどのDIコンテナを利用する場合はDaoインタフェースのインスタンスの生成をDIコンテナが行うためです。

**注意**
個人情報DBもしくは認証DBを使用するDaoの場合は、以下のアノーテーションを付与してください（上記のアノーテーションを拡張しています）。データベースを跨いだDaoインタフェースのメソッドは実装できません。
- 個人情報DB
  - `@ConfigAutowireablePersonalDb`
- 認証DB
  - `@ConfigAutowireableAuthDb`

## SQLファイルの作成

Daoインタフェースのメソッドの呼び出しに対応するSQLファイルを作成します。SQLファイルは対応するメソッド名と同じにしてください。また、SQLファイルは以下のルールにしたがって配置してください。

```
META-INF/Daoのクラスの完全修飾名をディレクトリに変換したもの/Daoのメソッド名.sql
```

例えば、`FacilityDao.selectById`メソッドに対応するSQLファイルは`ntss-admin-web/src/main/resources/META-INF/jp/co/nikkiso/ntss/dao/FacilityDao/selectById.sql`に配置します。

SQLファイルの内容は以下のようになります。

selectById.sql:
```sql
select
  *
from
  facility
where
  id = /*id*/'1'
;
```

メソッドの引数として渡された値をSQLファイル内で参照するにはSQLコメントを利用します。`FacilityDao.selectById`が呼び出されると上記の`selectById.sql`の`/*id*/`のコメント部分に、`FacilityDao.selectById`メソッドの引数`id`の値が紐づけられてSQLが実行されます。
コメント直後には`'1'`のようにテスト用（任意のSQLツールでそのままSQLを実行するための値）の値を記述できます。

Doma2ではSQLファイル内のコメントに式を記述することで値のバインディングや条件分岐を行います。
SQLコメントに記述できるフォーマットなど詳細は公式ドキュメント（https://doma.readthedocs.io/ja/stable/sql/) を参照してください。

## サービスインタフェース・クラスの作成

Daoはのメソッドは1つのメソッドが1つのSQLに対応します。また、SQLを実行することが目的です。そこで以下の役割を目的とするサービスを実装します。

- SQL実行以外のロジックの実装
- トランザクション境界

また、各クラスを疎結合にしユニットテストの容易性を確保するために、サービスはインタフェースを宣言し、それを実装するクラスを作成します。

まず、以下のようにサービスが外部に提供するメソッドを宣言したインタフェース（`FacilityService`)を作成します。
完全なソースコードは`ntss-admin-web/src/main/java/jp/co/nikkiso/ntss/service/FacilityService.java`です。

下記は`FacilityService.java`の一部抜粋です。
```java
public interface FacilityService {

  Page<Facility> findAll(Pageable pageable);

  Facility findById(Integer id);

  Facility create(Facility f);

  Facility update(Facility f);

  void delete(Integer id);
}
```

次に、以下のように`FacilityService`の実装クラスを作成します。
サービスクラスには`@Service`を付与することで`FacilityServiceImpl`のインスタンスをDIコンテナが作成できるようになります。
また、サービスクラスから`FacilityDao`インスタンスのメソッドを呼び出すために、`FacilityDao`インスタンスが必要です。`@Autowired`アノテーションを付与した`facilityDao`プロパティを宣言することで、DIコンテナが実行時に`FacilityDao`インスタンスを設定してくれます。
`FacilityServiceImpl`では`FacilityService`で宣言したメソッドを実装します。そのメソッドないでDaoのメソッドを呼び出します。
サービスのメソッドはトランザクション境界としての役割もあります。サービスクラスのメソッドに対して`@Transactional`アノテーションを付与すると、トランザクションの以下の処理が自動でおこなれます。

- メソッド呼び出しの最初にトランザクションを開始する。
- メソッド呼び出しが終わるとトランザクションがコミットする。
- もし、例外が発生した場合はトランザクションをロールバックする。

更新系メソッドや同一トランザクションで複数クエリを実行する必要がある場合は`@Transactional`を付与してください。
より詳細な情報は https://docs.spring.io/spring/docs/4.2.x/spring-framework-reference/html/transaction.html#transaction-declarative-annotations を参照してください。

下記は`FacilityServiceImpl.java`の一部抜粋です。
完全なソースコードは`ntss-admin-web/src/main/java/jp/co/nikkiso/ntss/service/FacilityServiceImpl.java`です。

```java
@Service
public class FacilityServiceImpl implements FacilityService {
  @Autowired
  private FacilityDao facilityDao;

  @Override
  public Page<Facility> findAll(Pageable pageable) {
    SelectOptions selectOptions = SelectOptionsUtils.get(pageable, true);
    List<Facility> facilities = facilityDao.selectAll(selectOptions);
    return new PageImpl<>(facilities, pageable, selectOptions.getCount());
  }

  @Override
  @Transactional
  public Facility create(Facility f) {
    facilityDao.insert(f);
    return f;
  }

  @Override
  public Facility findById(Integer id) {
    return facilityDao.selectById(id);
  }

  @Override
  @Transactional
  public void delete(Integer id) {
    Facility f = facilityDao.selectById(id);
    if (f != null) {
      facilityDao.delete(f);
    }
  }

  @Override
  @Transactional
  public Facility update(Facility f) {
    facilityDao.update(f);
    return f;
  }
}
```

## コントロールクラスの作成

Web(REST)APIを処理するクラスとしてコントローラクラスを実装します。

下記のようコントローラクラスには`@RestController`を付与します。そうするとDIコンテナによりインスタンスが管理され、HTTPリクエストに対して定義したメソッドが呼び出されるようになります。

どのようなHTTPリクエストに対してどのメソッドが呼び出されるかは`@RequestMapping`と`@GetMapping`などのアノテーションで定義します。`@RequestMapping`でHTTPのURLとクラスまたはメソッドをマッピングします。また、メソッドに`@GetMapping`を付与することでHTTPのGETメソッドのリクエストにマッピングします。

例えば、以下のようなヘッダのHTTPリクエストがあった場合、
```http
GET /api/facilities/123 HTTP/1.1
Accept: text/html,application/json
```

`FacilityResource.get()`メソッドが引数`123`で呼び出されます。

より詳細な情報は https://docs.spring.io/spring/docs/4.3.x/spring-framework-reference/htmlsingle/#mvc-ann-restcontroller を参照してください。

下記は`FacilityResource.java`の一部抜粋です。
完全なソースコードは`ntss-admin-web/src/main/java/jp/co/nikkiso/ntss/web/rest/FacilityResource.java`です。
```java
@RestController
@RequestMapping("/api/facilities")
public class FacilityResource {

  private final Logger log = LoggerFactory.getLogger(getClass());

  @Autowired
  FacilityService facilityService;

  @GetMapping("/{id}")
  public ResponseEntity<Facility> get(@PathVariable Integer id) {
    log.debug("REST request to get Facility : {}", id);
    return Optional.ofNullable(facilityService.findById(id))
        .map(facility -> new ResponseEntity<>(
            facility,
            HttpStatus.OK))
        .orElse(new ResponseEntity<>(HttpStatus.NOT_FOUND));
  }
}
```
