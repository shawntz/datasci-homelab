options(repos = c(CRAN = "https://cloud.r-project.org"))

# Detect if running under QEMU emulation (cross-compilation)
# Use single-threaded compilation for reliability under emulation
is_emulated <- file.exists("/dev/.buildkit_qemu_emulator") ||
               Sys.getenv("QEMU_CPU") != "" ||
               grepl("qemu", Sys.getenv("_"), ignore.case = TRUE)

ncpus <- if (is_emulated) 1L else parallel::detectCores()
cat(sprintf("Using %d CPU(s) for package compilation\n", ncpus))

# Core tidyverse and data packages (some pre-installed in rocker/verse)
core_pkgs <- c(
  "tidyverse",
  "data.table",
  "duckdb"
)

# Visualization packages
viz_pkgs <- c(
  "ggthemes",
  "wesanderson",
  "formattable",
  "showtext",
  "sysfonts",
  "showtextdb",
  "patchwork",
  "scales"
)

# Statistics and modeling packages
stats_pkgs <- c(
  "lme4",
  "lmerTest",
  "emmeans",
  "performance",
  "rstatix",
  "broom",
  "broom.mixed"
)

# Utility packages
util_pkgs <- c(
  "pacman",
  "glue",
  "here",
  "eyeris",
  "janitor",
  "skimr"
)

# Database packages
db_pkgs <- c(
  "DBI",
  "RPostgres",
  "RMySQL",
  "odbc",
  "dbplyr"
)

# Development and publishing packages
dev_pkgs <- c(
  "devtools",
  "usethis",
  "gitcreds",
  "renv",
  "quarto",
  "tinytex",
  "rticles",
  "conflicted",
  "styler",
  "lintr"
)

# Machine learning packages
ml_pkgs <- c(
  "tidymodels",
  "dtplyr",
  "plotly"
)

# R-Jupyter integration
jupyter_pkgs <- c(
  "IRkernel"
)

# Combine all packages
all_pkgs <- c(core_pkgs, viz_pkgs, stats_pkgs, util_pkgs, db_pkgs, dev_pkgs, ml_pkgs, jupyter_pkgs)

# Install packages that aren't already installed
to_install <- setdiff(all_pkgs, rownames(installed.packages()))

if (length(to_install)) {
  cat("Installing packages:", paste(to_install, collapse = ", "), "\n")
  install.packages(to_install, Ncpus = ncpus)
} else {
  cat("All packages already installed!\n")
}

# Verify installations
cat("\nInstalled package versions:\n")
for (pkg in all_pkgs) {
  if (pkg %in% rownames(installed.packages())) {
    cat(sprintf("  ✓ %s: %s\n", pkg, packageVersion(pkg)))
  } else {
    cat(sprintf("  ✗ %s: FAILED TO INSTALL\n", pkg))
  }
}
