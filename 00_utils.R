# Utils: checagens e caminhos
root <- normalizePath('.', winslash = '/', mustWork = FALSE)
path_in  <- file.path(root, 'Data', 'InputData')
path_out <- file.path(root, 'Output')
path_an  <- file.path(root, 'Data', 'AnalysisData')

dir.create(path_out, showWarnings = FALSE, recursive = TRUE)
dir.create(path_an,  showWarnings = FALSE, recursive = TRUE)

stop_if_missing <- function(f){
  if(!file.exists(f)) stop(sprintf('Arquivo não encontrado: %s', f), call. = FALSE)
}
