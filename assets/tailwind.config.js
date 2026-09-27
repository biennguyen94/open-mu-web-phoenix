// Tailwind CSS v3 (decision D4: UI parity with the Next.js app).
// Theme values are copied from tailwind.config.ts of the Next.js app (https://github.com/biennguyen94/open-mu-web).
module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/open_mu_web_web.ex",
    "../lib/open_mu_web_web/**/*.*ex"
  ],
  theme: {
    extend: {
      colors: {
        primary: "#105D71",
        secondary: "#A5F1F1",
        tertiary: "#A5EFFA",
        oceanic: "#EAEFF3"
      },
      fontFamily: {
        lora: ["Lora", "serif"]
      }
    }
  },
  plugins: [
    // Makes "hero-#{ICON}" classes available (used by <.icon> in core_components).
    require("./vendor/heroicons")
  ]
}
