# 開発メモ
開発中に発見したことなどを記載します。

## `npm run serve`が JavaScript heap out of memory でエラー終了する場合の対処方法
`npm run serve`で開発サーバを起動していると、以下のようなエラーを吐いて異常終了する場合があります。
```
<--- Last few GCs --->

[21224:000001D789CCD340]    86704 ms: Mark-sweep 1224.6 (1312.7) -> 1223.0 (1280.8) MB, 646.2 / 0.1 ms  (average mu = 0.715, current mu = 0.000) last resort GC in old space requested
[21224:000001D789CCD340]    87643 ms: Mark-sweep 1223.0 (1280.8) -> 1223.0 (1272.8) MB, 938.9 / 0.1 ms  (average mu = 0.480, current mu = 0.000) last resort GC in old space requested


<--- JS stacktrace --->

==== JS stack trace =========================================

    0: ExitFrame [pc: 000000E5CEBD0461]
Security context: 0x00e88d09d949 <JSObject>
    1: byteLength(aka byteLength) [000001DA67EDB041] [buffer.js:526] [bytecode=0000011FBC91A601 offset=204](this=0x01e08c6825b1 <undefined>,0x00907c554be1 <Very long string[88508600]>,0x00e88d0b90b1 <String[4]: utf8>)
    2: arguments adaptor frame: 3->2
    3: fromString(aka fromString) [000001DA67EF7EB1] [buffer.js:337] [bytecode=0000011FBC914FB1 offset=...

FATAL ERROR: CALL_AND_RETRY_LAST Allocation failed - JavaScript heap out of memory
 1: 00007FF727ADD50A v8::internal::GCIdleTimeHandler::GCIdleTimeHandler+4618
 2: 00007FF727A84F86 uv_loop_fork+79446
 3: 00007FF727A85C21 uv_loop_fork+82673
 4: 00007FF727F8CAEE v8::internal::FatalProcessOutOfMemory+798
 5: 00007FF727F8CA27 v8::internal::FatalProcessOutOfMemory+599
 6: 00007FF728265844 v8::internal::Heap::RootIsImmortalImmovable+14788
 7: 00007FF728263608 v8::internal::Heap::RootIsImmortalImmovable+6024
 8: 00007FF727E240DB v8::internal::Factory::AllocateRawWithImmortalMap+59
 9: 00007FF727E26B5D v8::internal::Factory::NewRawTwoByteString+77
10: 00007FF7282144A3 v8::internal::Smi::SmiPrint+483
11: 00007FF727E214A3 v8::internal::CompilationJob::operator=+1155
12: 00007FF727FA8C46 v8::String::Utf8Length+22
13: 00007FF727AA22FB node::Buffer::New+4859
14: 00007FF727F724FE v8::internal::ZoneVector<v8::internal::compiler::MoveOperands * __ptr64>::ZoneVector<v8::internal::compiler::MoveOperands * __ptr64>+59870
15: 00007FF727F73A60 v8::internal::ZoneVector<v8::internal::compiler::MoveOperands * __ptr64>::ZoneVector<v8::internal::compiler::MoveOperands * __ptr64>+65344
16: 00007FF727F729F9 v8::internal::ZoneVector<v8::internal::compiler::MoveOperands * __ptr64>::ZoneVector<v8::internal::compiler::MoveOperands * __ptr64>+61145
17: 00007FF727F728DB v8::internal::ZoneVector<v8::internal::compiler::MoveOperands * __ptr64>::ZoneVector<v8::internal::compiler::MoveOperands * __ptr64>+60859
18: 000000E5CEBD0461
npm ERR! code ELIFECYCLE
npm ERR! errno 134
npm ERR! ReMS@0.1.0 serve: `vue-cli-service serve`
npm ERR! Exit status 134
npm ERR!
npm ERR! Failed at the ReMS@0.1.0 serve script.
npm ERR! This is probably not a problem with npm. There is likely additional logging output above.

npm ERR! A complete log of this run can be found in:
npm ERR!     C:\Users\h.murakami.CENTER.000\AppData\Roaming\npm-cache\_logs\2019-08-28T07_01_37_585Z-debug.log
```

### 原因
これは、Node.js のヒープサイズ上限（デフォルトで1.5GB）を超えたために起きているもので、開発ボリュームが大きくなってくると出やすくなるものです。

### 対策
Node.jsのヒープサイズを拡張する必要があります。  
手段としては、環境変数`NODE_OPTIONS`に`--max_old_space_size=4096`のように指定します。（数値はMB単位、デフォルトは`1536`なのでそれより大きく）
- #### Windows コマンドプロンプトの場合
  `set NODE_OPTIONS=--max_old_space_size=4096`
- #### Windows PowerShellの場合
  `$env:NODE_OPTIONS="--max_old_space_size=4096"`
- #### Unix系（Linux,Mac等）の場合
  `export NODE_OPTIONS="--max_old_space_size=4096"`

`npm run serve`を実行する前に上記のコマンドを実行し、環境変数を設定してください。
