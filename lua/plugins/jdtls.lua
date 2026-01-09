return {
  {
    "mfussenegger/nvim-jdtls",
    ft = { "java" },
    config = function()
      local jdtls = require("jdtls")

      local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" }
      local root_dir = require("jdtls.setup").find_root(root_markers)
      if not root_dir then return end

      local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
      local workspace_dir = vim.fn.stdpath("data") .. "/jdtls-workspace/" .. project_name

      local mason_path = vim.fn.stdpath("data") .. "/mason"
      local jdtls_path = mason_path .. "/packages/jdtls"
      local launcher_jar = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
      local config_dir = jdtls_path .. "/config_win"

      local cmd = {
        "java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xms1g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens", "java.base/java.util=ALL-UNNAMED",
        "--add-opens", "java.base/java.lang=ALL-UNNAMED",
        "-jar", launcher_jar,
        "-configuration", config_dir,
        "-data", workspace_dir,
      }

      jdtls.start_or_attach({
        cmd = cmd,
        root_dir = root_dir,
      })
    end,
  },
}

