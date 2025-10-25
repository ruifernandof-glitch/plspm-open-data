# 03_bootstrap_and_diagram.R — Bootstrap e diagrama
suppressPackageStartupMessages({
  library(plspm); library(dplyr); library(DiagrammeR)
})

source(file.path('Scripts','00_utils.R'))

pls_stage2 <- readRDS(file.path(path_out, 'stage2_pls.rds'))

# Bootstrap (ajuste br conforme necessidade)
pls_stage2_boot <- plspm(pls_stage2$data, pls_stage2$model$path_matrix,
                         pls_stage2$model$blocks, modes=pls_stage2$model$modes,
                         scaled=TRUE, boot.val=TRUE, br=500)

saveRDS(pls_stage2_boot, file.path(path_out, 'stage2_boot.rds'))
write.csv(pls_stage2_boot$boot$paths, file.path(path_out,'stage2_boot_paths.csv'))
write.csv(pls_stage2_boot$boot$outer, file.path(path_out,'stage2_boot_outer.csv'))

# Números para o diagrama
fo <- c('LD','AC','IA','AI','CC','OE','AE','EP')

loads <- pls_stage2$outer_model %>%
  dplyr::filter(name %in% fo) %>%
  dplyr::transmute(to = name, lab = sprintf('%.3f', loading))

B <- pls_stage2$path_coefs
labs <- c(
  pgc_ccg = sprintf('%.3f', B['CCG','PGC']),
  ccg_com = sprintf('%.3f', B['COM','CCG']),
  ccg_des = sprintf('%.3f', B['DES','CCG']),
  com_des = sprintf('%.3f', B['DES','COM'])
)

# P-values e estrelas (se bootstrap carregado)
paths_boot <- pls_stage2_boot$boot$paths
pval <- function(est,se) 2*pnorm(abs(est/se), lower.tail = FALSE)
stars <- function(p) ifelse(p<.001,'***', ifelse(p<.01,'**', ifelse(p<.05,'*','')))
pb <- paths_boot
pb$p <- pval(pb$Original, pb$Std.Error)
st <- setNames(stars(pb$p), pb$`row.names`)

labs['pgc_ccg'] <- paste0(labs['pgc_ccg'], st['PGC -> CCG'])
labs['ccg_com'] <- paste0(labs['ccg_com'], st['CCG -> COM'])
labs['ccg_des'] <- paste0(labs['ccg_des'], st['CCG -> DES'])
labs['com_des'] <- paste0(labs['com_des'], st['COM -> DES'])

load_str <- paste(
  sprintf('CCG -> %s [color="gray60", fontcolor="gray30", label="%s"];',
          loads$to, loads$lab),
  collapse = "\n  "
)

titulo <- 'H1: PGC → CCG | H2: CCG → DES | H3: CCG → COM | H4: COM → DES'

dot <- sprintf('digraph G {
  graph [rankdir=LR, splines=true, fontsize=12, label="%s", labelloc="t"];
  node  [shape=ellipse, style=filled, color="#CFE5FF", fontcolor=black];
  edge  [fontsize=11];

  PGC [label="PGC"];
  CCG [label="CCG\n(2ª ordem)"];
  COM [label="COM"];
  DES [label="DES"];

  // cargas (cinza)
  %s

  // caminhos (verde)
  PGC -> CCG [color="#2E8B57", penwidth=2, label="%s"];  // H1
  CCG -> DES [color="#2E8B57", penwidth=2, label="%s"];  // H2
  CCG -> COM [color="#2E8B57", penwidth=2, label="%s"];  // H3
  COM -> DES [color="#2E8B57", penwidth=2, label="%s"];  // H4

  {rank=same; PGC; CCG; COM; DES}
}', titulo, load_str, labs['pgc_ccg'], labs['ccg_des'], labs['ccg_com'], labs['com_des'])

# Exporta HTML do diagrama
html_file <- file.path(path_out, 'diagram_pls.html')
DiagrammeR::export_graph(grViz(dot), file_name = html_file)

cat('[OK] Bootstrap e diagrama gerados. Verifique arquivos em Output/.\n')
