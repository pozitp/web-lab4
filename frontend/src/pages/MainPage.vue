<template>
  <main class="screen">
    <pre class="banner">
+-----------------------------------------------+
| WEB LAB 4                       | VARIANT 641 |
| MUKHAMEDIAROV ARTUR ALBERTOVICH | P3209       |
+-----------------------------------------------+</pre
    >

    <div class="user-bar">logged in as: {{ username }} <a class="link-back" @click="logout">[LOGOUT]</a></div>

    <div class="box">
      <div class="box-title">input</div>
      <div class="grid">
        <div class="grid-item">
          <div v-if="errorMessage" class="alert">{{ errorMessage }}</div>

          <fieldset>
            <legend>X</legend>
            <div class="choices">
              <span
                v-for="xVal in xValues"
                :key="xVal"
                class="choice"
                :class="{ active: x === xVal }"
                @click="setX(xVal)"
                >{{ xVal }}</span
              >
            </div>
          </fieldset>

          <fieldset>
            <legend><label for="y-input">Y (-5..3)</label></legend>
            <input
              id="y-input"
              type="text"
              v-model="yInput"
              @input="filterYInput"
              @keypress="onlyNumbers"
              class="field-input"
              :class="{ error: yError }"
              inputmode="decimal"
            />
            <div v-if="yError" class="error-text">{{ yError }}</div>
          </fieldset>

          <fieldset>
            <legend>R</legend>
            <div class="choices">
              <span
                v-for="rVal in rValues"
                :key="rVal"
                class="choice"
                :class="{ active: r === rVal }"
                @click="setR(rVal)"
                >{{ rVal }}</span
              >
            </div>
          </fieldset>

          <div class="submit-row">
            <button class="button" @click="submitPoint">[CHECK]</button>
            <span class="selection">{{ selectionText }}</span>
          </div>
        </div>

        <div class="grid-item">
          <fieldset>
            <legend>area</legend>
            <div class="plot">
              <svg
                ref="plotSvg"
                viewBox="-180 -180 360 360"
                @click="handlePlotClick"
              >
                <defs>
                  <marker
                    id="arrow"
                    markerWidth="10"
                    markerHeight="10"
                    refX="9"
                    refY="3"
                    orient="auto"
                  >
                    <path d="M0,0 L0,6 L9,3 z" fill="#00ffff" />
                  </marker>
                </defs>
                <g class="area" :transform="areaTransform">
                  <path :d="rectPath" class="area-shape"></path>
                  <path :d="trianglePath" class="area-shape"></path>
                  <path :d="circlePath" class="area-shape"></path>
                </g>
                <g class="axis">
                  <line
                    x1="-160"
                    y1="0"
                    x2="155"
                    y2="0"
                    marker-end="url(#arrow)"
                  ></line>
                  <line
                    x1="0"
                    y1="160"
                    x2="0"
                    y2="-155"
                    marker-end="url(#arrow)"
                  ></line>
                  <text class="axis-label" x="145" y="15">X</text>
                  <text class="axis-label" x="10" y="-145">Y</text>
                </g>
                <g>
                  <circle
                    v-for="point in allPoints"
                    :key="point.id"
                    :cx="scaledX(point)"
                    :cy="scaledY(point)"
                    r="4"
                    :class="
                      point.hit ? 'history-point--hit' : 'history-point--miss'
                    "
                  />
                </g>
                <circle
                  v-if="canShowPoint"
                  :cx="r === 0 ? 0 : toSvg(Number(x))"
                  :cy="r === 0 ? 0 : -toSvg(Number(yInput.replace(',', '.')) )"
                  r="5"
                  id="selected-point"
                />
              </svg>
            </div>
          </fieldset>
        </div>
      </div>
    </div>

    <div class="box">
      <div class="box-title">history ({{ totalElements }} total)</div>
      <table>
        <thead>
          <tr>
            <th>X</th>
            <th>Y</th>
            <th>R</th>
            <th>Hit</th>
            <th>Time</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="item in history" :key="item.id">
            <td>{{ item.x }}</td>
            <td>{{ item.y }}</td>
            <td>{{ item.r }}</td>
            <td>{{ item.hit ? "Y" : "N" }}</td>
            <td>{{ formatDate(item.processedAt) }}</td>
          </tr>
        </tbody>
      </table>
      <div class="pagination">
        <button class="button" @click="prevPage" :disabled="currentPage === 0">[PREV]</button>
        <span class="page-info">{{ currentPage + 1 }} / {{ totalPages || 1 }}</span>
        <button class="button" @click="nextPage" :disabled="currentPage >= totalPages - 1">[NEXT]</button>
        <button class="button" @click="clearHistory">[CLEAR]</button>
      </div>
    </div>
  </main>
</template>

<script>
import { api } from '../api.js';

const STORAGE_KEY = "lab4-selection";
const CHANNEL_NAME = "lab4-sync";

export default {
  name: "MainPage",
  data() {
    return {
      xValues: [-5, -4, -3, -2, -1, 0, 1, 2, 3],
      rValues: [-5, -4, -3, -2, -1, 0, 1, 2, 3],
      x: 0,
      yInput: "0",
      r: null,
      yError: "",
      errorMessage: "",
      history: [],
      allPoints: [],
      username: "",
      currentPage: 0,
      totalPages: 0,
      totalElements: 0,
      pageSize: 10,
      UNIT: 30,
      channel: null,
      sessionCheck: null,
      variant: "default",
      featureFlagLoaded: false,
    };
  },
  computed: {
    selectionText() {
      if (this.x === null || !this.yInput || this.r === null) return "none";
      return `X=${this.x} Y=${this.yInput} R=${this.r}`;
    },
    canShowPoint() {
      if (this.x === null || this.r === null) return false;
      const y = this.yInput.replace(",", ".");
      if (!/^-?\d+(\.\d+)?$/.test(y)) return false;
      const yNum = Number(y);
      return yNum >= -5 && yNum <= 3;
    },
    absR() {
      return Math.abs(this.r || 0);
    },
    areaTransform() {
      if (this.r && this.r < 0) return "scale(-1, -1)";
      return "";
    },
    rectPath() {
      if (!this.r || this.r === 0) return "";
      const R = this.absR;
      return `M 0 0 L ${R * this.UNIT} 0 L ${R * this.UNIT} ${
        (-R / 2) * this.UNIT
      } L 0 ${(-R / 2) * this.UNIT} Z`;
    },
    trianglePath() {
      if (!this.r || this.r === 0) return "";
      const R = this.absR;
      return `M 0 0 L ${(-R / 2) * this.UNIT} 0 L 0 ${
        -R * this.UNIT
      } Z`;
    },
    circlePath() {
      if (!this.r || this.r === 0) return "";
      const R = this.absR;
      const rad = (R / 2) * this.UNIT;
      return `M 0 0 L ${rad} 0 A ${rad} ${rad} 0 0 1 0 ${rad} Z`;
    },
  },
  mounted() {
    this.loadState();
    this.loadFeatureFlag();
    this.loadHistory();
    this.loadUsername();
    this.setupSync();
    this.sessionCheck = setInterval(() => {
      api("/api/auth/check").catch(() => {});
    }, 5000);
  },
  beforeUnmount() {
    if (this.channel) this.channel.close();
    if (this.sessionCheck) clearInterval(this.sessionCheck);
  },
  methods: {
    onlyNumbers(event) {
      const char = String.fromCodePoint(event.which || event.keyCode);
      if (!/[\d.\-,]/.test(char)) {
        event.preventDefault();
      }
    },
    filterYInput() {
      let val = this.yInput;
      val = val.replaceAll(/[^\d.\-,]/g, "");
      const parts = val.split(/[.,]/);
      if (parts.length > 2) {
        val = parts[0] + "." + parts.slice(1).join("");
      }
      const minusCount = (val.match(/-/g) || []).length;
      if (minusCount > 1 || (minusCount === 1 && val.indexOf("-") !== 0)) {
        val = val.replaceAll('-', "");
        if (this.yInput.startsWith("-")) val = "-" + val;
      }
      this.yInput = val;
      this.saveState();
    },
    setupSync() {
      if (typeof BroadcastChannel !== "undefined") {
        this.channel = new BroadcastChannel(CHANNEL_NAME);
        this.channel.onmessage = (e) => {
          if (e.data.type === "history-update") {
            this.loadHistory();
            this.loadAllPoints();
          }
        };
      }
    },
    broadcastUpdate() {
      if (this.channel) {
        this.channel.postMessage({ type: "history-update" });
      }
    },
    toSvg(v) {
      return Number(v) * this.UNIT;
    },
    scaledX(point) {
      if (!this.r || this.r === 0 || !point.r || point.r === 0) return 0;
      const sign = this.r < 0 ? -1 : 1;
      return sign * (Number(point.x) / Number(point.r)) * this.absR * this.UNIT;
    },
    scaledY(point) {
      if (!this.r || this.r === 0 || !point.r || point.r === 0) return 0;
      const sign = this.r < 0 ? -1 : 1;
      return -sign * (Number(point.y) / Number(point.r)) * this.absR * this.UNIT;
    },
    setX(val) {
      this.x = val;
      this.saveState();
    },
    setR(val) {
      this.r = val;
      this.saveState();
    },
    saveState() {
      sessionStorage.setItem(
        STORAGE_KEY,
        JSON.stringify({ x: this.x, y: this.yInput, r: this.r })
      );
    },
    loadState() {
      try {
        const saved = sessionStorage.getItem(STORAGE_KEY);
        if (saved) {
          const d = JSON.parse(saved);
          if (d.x !== undefined) this.x = d.x;
          if (d.y !== undefined) this.yInput = d.y;
          if (d.r !== undefined) this.r = d.r;
        }
      } catch (err) {
        console.debug("Load state failed", err);
      }
    },
    async loadUsername() {
      try {
        const res = await api("/api/auth/check");
        const data = await res.json();
        this.username = data.username || "";
      } catch (err) {
        console.debug("Load username failed", err);
      }
    },
    async loadFeatureFlag() {
      try {
        const res = await api("/api/feature-flags/ui-variant");
        const data = await res.json();
        this.variant = data.variant || "default";
        this.featureFlagLoaded = true;
        document.documentElement.setAttribute("data-variant", this.variant);
      } catch (err) {
        console.debug("Load feature flag failed", err);
        this.variant = "default";
        this.featureFlagLoaded = true;
      }
    },
    validateY() {
      this.yError = "";
      const y = this.yInput.replace(",", ".");
      if (!/^-?\d+(\.\d+)?$/.test(y)) {
        this.yError = "NaN";
        return false;
      }
      const yNum = Number(y);
      if (yNum < -5 || yNum > 3) {
        this.yError = "-5..3";
        return false;
      }
      return true;
    },
    async loadHistory() {
      try {
        const res = await api(`/api/points?page=${this.currentPage}&size=${this.pageSize}`);
        const data = await res.json();
        this.history = data.content;
        this.currentPage = Number(data.page);
        this.totalPages = Number(data.totalPages);
        this.totalElements = Number(data.totalElements);
        this.loadAllPoints();
      } catch (err) {
        if (err.message !== "Unauthorized") this.errorMessage = "Load err";
        console.debug("Load history failed", err);
      }
    },
    async loadAllPoints() {
      try {
        const res = await api(`/api/points?page=0&size=1000`);
        const data = await res.json();
        this.allPoints = data.content;
      } catch (err) {
        console.debug("Load all points failed", err);
      }
    },
    async submitPointDirect(x, y, r) {
      this.errorMessage = "";
      try {
        const headers = { "Content-Type": "application/json" };
        if (this.variant) {
          headers["x-feature-flag"] = this.variant;
        }
        await api("/api/points", {
          method: "POST",
          headers: headers,
          body: JSON.stringify({
            x: String(x),
            y: String(y),
            r: String(r),
          }),
        });
        this.currentPage = 0;
        await this.loadHistory();
        this.broadcastUpdate();
      } catch (err) {
        if (err.message !== "Unauthorized") this.errorMessage = "Net err";
        console.debug("Submit failed", err);
      }
    },
    async submitPoint() {
      this.errorMessage = "";
      if (this.x === null) {
        this.errorMessage = "Set X";
        return;
      }
      if (!this.validateY()) return;
      if (this.r === null) {
        this.errorMessage = "Set R";
        return;
      }
      try {
        const headers = { "Content-Type": "application/json" };
        if (this.variant) {
          headers["x-feature-flag"] = this.variant;
        }
        await api("/api/points", {
          method: "POST",
          headers: headers,
          body: JSON.stringify({
            x: String(this.x),
            y: String(this.yInput),
            r: String(this.r),
          }),
        });
        this.currentPage = 0;
        await this.loadHistory();
        this.broadcastUpdate();
      } catch (err) {
        if (err.message !== "Unauthorized") this.errorMessage = "Net err";
        console.debug("Submit failed", err);
      }
    },
    async clearHistory() {
      try {
        await api("/api/points", { method: "DELETE" });
        this.history = [];
        this.allPoints = [];
        this.currentPage = 0;
        this.totalPages = 0;
        this.totalElements = 0;
        this.broadcastUpdate();
      } catch (err) {
        if (err.message !== "Unauthorized") this.errorMessage = "Err";
        console.debug("Clear failed", err);
      }
    },
    prevPage() {
      if (this.currentPage > 0) {
        this.currentPage--;
        this.loadHistory();
      }
    },
    nextPage() {
      if (this.currentPage < this.totalPages - 1) {
        this.currentPage++;
        this.loadHistory();
      }
    },
    async logout() {
      sessionStorage.removeItem(STORAGE_KEY);
      try {
        await api("/api/auth/logout", { method: "POST" });
      } catch (err) {
        console.debug("Logout failed", err);
      }
      this.$router.push("/");
    },
    handlePlotClick(event) {
      const svg = this.$refs.plotSvg;
      const pt = svg.createSVGPoint();
      pt.x = event.clientX;
      pt.y = event.clientY;
      const ctm = svg.getScreenCTM();
      if (!ctm) return;
      const p = pt.matrixTransform(ctm.inverse());
      if (this.r === 0) {
        this.submitPointDirect(0, 0, 0);
        return;
      }
      this.x = this.xValues.reduce((a, b) =>
        Math.abs(b - p.x / this.UNIT) < Math.abs(a - p.x / this.UNIT) ? b : a
      );
      this.yInput = Math.max(-5, Math.min(3, -p.y / this.UNIT)).toFixed(2);
      this.saveState();
      if (this.r !== null) {
        this.submitPoint();
      }
    },
    formatDate(d) {
      return d ? new Date(d).toLocaleString() : "";
    },
  },
};
</script>
