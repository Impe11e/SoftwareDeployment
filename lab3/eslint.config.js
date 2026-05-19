import pluginJs from "@eslint/js";

export default [
  pluginJs.configs.recommended,
  {
    ignores: ["node_modules/", "coverage/", "tests/"],
    languageOptions: {
      globals: {
        process: "readonly",
        console: "readonly",
        module: "readonly",
        require: "readonly",
        __dirname: "readonly"
      }
    }
  }
];