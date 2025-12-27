<template>
  <main class="screen">
    <pre class="banner">
+-----------------------------------------------+
| WEB LAB 4                       | VARIANT 641 |
| MUKHAMEDIAROV ARTUR ALBERTOVICH | P3209       |
+-----------------------------------------------+</pre
    >

    <div class="box">
      <div class="box-title">welcome</div>
      <p>{{ currentTime }}</p>
    </div>

    <div class="box">
      <div class="box-title">login</div>
      <div
        v-if="message"
        :class="messageType === 'error' ? 'alert' : 'success'"
      >
        {{ message }}
      </div>

      <form @submit.prevent="login">
        <div class="form-group">
          <label for="username-input">Username</label>
          <input
            id="username-input"
            type="text"
            v-model="username"
            class="field-input"
            :class="{ error: usernameError }"
          />
          <div v-if="usernameError" class="error-text">{{ usernameError }}</div>
        </div>

        <div class="form-group">
          <label for="password-input">Password</label>
          <input
            id="password-input"
            type="password"
            v-model="password"
            class="field-input"
            :class="{ error: passwordError }"
          />
          <div v-if="passwordError" class="error-text">{{ passwordError }}</div>
        </div>

        <div class="submit-row">
          <button type="submit" class="button">[LOGIN]</button>
          <button type="button" class="button" @click="register">
            [REGISTER]
          </button>
        </div>
      </form>
    </div>
  </main>
</template>

<script>
export default {
  name: "StartPage",
  data() {
    return {
      username: "",
      password: "",
      usernameError: "",
      passwordError: "",
      message: "",
      messageType: "",
      currentTime: "",
    };
  },
  mounted() {
    this.updateClock();
    setInterval(this.updateClock, 5000);
    this.checkAuth();
  },
  methods: {
    updateClock() {
      this.currentTime = new Date().toLocaleString();
    },
    async checkAuth() {
      try {
        const res = await fetch("/api/auth/check", {
          credentials: 'include'
        });
        if (res.ok) this.$router.push("/app");
      } catch (err) {
        console.debug("Auth check failed", err);
      }
    },
    validate() {
      this.usernameError = "";
      this.passwordError = "";
      let ok = true;
      if (!this.username || this.username.length < 3) {
        this.usernameError = "Min 3 chars";
        ok = false;
      }
      if (!this.password || this.password.length < 3) {
        this.passwordError = "Min 3 chars";
        ok = false;
      }
      return ok;
    },
    async login() {
      if (!this.validate()) return;
      try {
        const res = await fetch("/api/auth/login", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          credentials: "include",
          body: JSON.stringify({
            username: this.username,
            password: this.password,
          }),
        });
        if (res.ok) {
          this.$router.push("/app");
        } else {
          this.message = "Invalid credentials";
          this.messageType = "error";
        }
      } catch (err) {
        this.message = "Connection error";
        this.messageType = "error";
        console.debug("Login failed", err);
      }
    },
    async register() {
      if (!this.validate()) return;
      try {
        const res = await fetch("/api/auth/register", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          credentials: "include",
          body: JSON.stringify({
            username: this.username,
            password: this.password,
          }),
        });
        if (res.ok) {
          await this.login();
        } else {
          const data = await res.json().catch(() => ({}));
          this.message = data.message || "Failed";
          this.messageType = "error";
        }
      } catch (err) {
        this.message = "Connection error";
        this.messageType = "error";
        console.debug("Register failed", err);
      }
    },
  },
};
</script>
