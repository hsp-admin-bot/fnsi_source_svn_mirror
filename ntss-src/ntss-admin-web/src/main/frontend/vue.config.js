const path = require("path");
const webpack = require('webpack');
const TerserPlugin = require("terser-webpack-plugin");

module.exports = {
  publicPath: "/ntss-admin-web/",
  outputDir: path.resolve(__dirname, "../resources/public"),

  devServer: {
    port: 8000,
    proxy: {
      "/ntss-admin-web/api": {
        target: "http://localhost:8080"
      }
    },
    client: {
      overlay: false
    }
  },
  configureWebpack: {
    plugins:[
        new webpack.ProvidePlugin({
            Buffer: [ 'buffer', 'Buffer' ],
            process: 'process/browser',
        }),
    ],
    module: {
      // Service Workerのファイルをwebpackのloader対象から除外
      rules: [
        {
          test: /\.js$/,
          exclude: [
            path.resolve(__dirname, 'src/FabServiceWorker.js')
          ]
        }
      ]
    },
    optimization: {
      minimizer: [
        //ビルド対象ディレクトリのService Workerのファイルのみコードを難読化
        new TerserPlugin({
          include: /app-file\.js$/,
          extractComments: false,
          parallel: true,
          terserOptions: {
            compress: {
              drop_console: true,
              passes: 5,
              unsafe: true,
              unsafe_arrows: true,
              unsafe_comps: true,
              unsafe_math: true,
              unsafe_symbols: true,
              hoist_funs: true,
              hoist_vars: true,
              inline: 3,
              reduce_funcs: true,
              reduce_vars: true
            },
            mangle: {
              keep_classnames: false,
              keep_fnames: false,
              toplevel: true
            },
            format: {
              comments: false,
              beautify: false,
              ascii_only: true
            }
          }
        })
      ]
    }

    // cache: true,
    // optimization: {
    //   minimizer: [
    //     new TerserPlugin({
    //       // cache: true,
    //       extractComments: true,
    //       parallel: false,
    //       // sourceMap: false, // Must be set to true if using source-maps in production
    //       terserOptions: {
    //         // https://github.com/webpack-contrib/terser-webpack-plugin#terseroptions
    //       }
    //     })
    //   ]
    // }
  },

  lintOnSave: false,
  productionSourceMap: false,

  chainWebpack: config => {
    config.resolve.alias.set("vue$", "vue/dist/vue.esm.js");
    config.resolve.alias.set("process", "process/browser");
    // サインイン画面のprefetch定義を除外
    config.plugins.delete('prefetch');
    //Service Workerのファイルをビルド対象ディレクトリにコピー
    config.plugin('copy').tap(args => {
      args[0].patterns = [
        ...args[0].patterns,
        {
          from: path.resolve(__dirname, 'src/FabServiceWorker.js'),
          to: 'app-file.js',
          noErrorOnMissing: false
        }
      ];
      return args;
    });
  },

  pwa: {
    iconPaths: {
      // favicon
      favicon32: "img/login/NIKKISO.ico",
      // Vueのデフォルトのファイル名が使用されて404エラーになることがあるためfavicon16も指定しておく
      favicon16: "img/login/NIKKISO.ico",
      // ウェブクリップアイコン
      appleTouchIcon: "img/login/NIKKISO152_iPhone.png"
    },
    appleMobileWebAppCapable: "yes"
    // カスタムSWスクリプトを利用
    ,workboxPluginMode: 'InjectManifest'
    ,workboxOptions: {
      swSrc: './src/customServiceWorker.js'
      ,swDest: 'service-worker.js'
      /* modify by chamaojia 2023-08-30 [9599] helpフォルダとerrorフォルダの静的ファイルキャッシュの追加無視  --start */
      ,exclude: [/\.pdf$/, /\.wav$/, /\.mp4$/, /index\.html$/, /^.*help\/.*$/, /^.*error\/.*$/, /\.msi$/]
      /* modify by chamaojia 2023-08-30 [9599] helpフォルダとerrorフォルダの静的ファイルキャッシュの追加無視  --end */
    }
  },
  parallel: false
};
