const path = require("path");

module.exports = {
  publicPath: "/ntss-certificate-management/",
  outputDir: path.resolve(__dirname, "../resources/public"),

  devServer: {
    port: 8000,
    proxy: {
      "/ntss-certificate-management/api": {
        target: "http://localhost:8080"
      }
    }
  },
  //add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 start 修正５
  pwa: {
    iconPaths: {
      // favicon
      favicon32: "img/favicon.ico"
    }
  },
  //add FNSI-【1006】最新の改修対象一覧.NO43を追加 周安寧 end 修正５
  chainWebpack: config => {
    config.resolve.alias.set("vue$", "vue/dist/vue.esm.js");
  }
};
