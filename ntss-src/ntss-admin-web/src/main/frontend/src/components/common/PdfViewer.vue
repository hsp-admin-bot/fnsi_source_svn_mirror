<template>
  <div class="pdfViewer-page">
    <canvas ref="canvaspdf" class="pdf-canvas"></canvas>
  </div>
</template>

<script>
import * as pdfjsLib from "pdfjs-dist/webpack";

export default {
  name: "PdfViewer",
  props: {
    src: { type: String, required: true },
    page: { type: Number, required: true }
  },
  data() {
    return {
      pdf: null,
      renderTask: null
    };
  },
  mounted() {
    this.loadPdf();
  },
  watch: {
    src() {
      this.loadPdf();
    },
    page() {
      this.renderPage();
    }
  },
  methods: {
    async loadPdf() {
      if (!this.src) return;

      pdfjsLib.GlobalWorkerOptions.workerSrc =
        require("pdfjs-dist/build/pdf.worker.js");

      const loadingTask = pdfjsLib.getDocument(this.src);
      this.pdf = await loadingTask.promise;

      await this.renderPage();
    },

    async renderPage() {
      if (!this.pdf) return;
      if (this.page < 1 || this.page > this.pdf.numPages) {
        return;
      }
      const page = await this.pdf.getPage(this.page);
      const canvas = this.$refs.canvaspdf;
      const context = canvas.getContext("2d");

      const viewport = page.getViewport({ scale: 1.5 });
      canvas.width = viewport.width;
      canvas.height = viewport.height;

      const renderContext = {
        canvasContext: context,
        viewport: viewport
      };

      if (this.renderTask) {
        this.renderTask.cancel();
      }

      this.renderTask = page.render(renderContext);

      try {
        await this.renderTask.promise;
      } catch (err) {
        if (err.name !== "RenderingCancelledException") {
          console.error("PDF Exception:", err);
        }
      }

      this.renderTask = null;
    }
  }
};
</script>

<style scoped>
.pdfViewer-page {
  margin-bottom: 20px;
}
.pdf-canvas {
  width: 100%;
  display: block;
}
</style>
