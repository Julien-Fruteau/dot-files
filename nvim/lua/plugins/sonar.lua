return {
    "iamkarasik/sonarqube.nvim",
    config = function()
      -- run: SonarQubeInstallLsp (do not install via mason)
      require("sonarqube").setup({})
    end
}
