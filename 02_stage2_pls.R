# 02_stage2_pls.R — Estágio 2 (CCG 2ª ordem → PGC/COM/DES)
suppressPackageStartupMessages({
  library(plspm); library(dplyr)
})
source(file.path('Scripts','00_utils.R'))

# 0) Ler escores do estágio 1
scores1_path <- file.path(path_an, 'stage1_scores.csv')
stop_if_missing(scores1_path)
scores1 <- read.csv(scores1_path, check.names = FALSE)

# 1) Montar dataset do estágio 2
data2 <- cbind(
  scores1[, c('LD','AC','IA','AI','CC','OE','AE','EP')],
  scores1[, c('PGC','COM','DES')]
)

# 2) Ordem das LVs e blocos
LV2 <- c('PGC','CCG','COM','DES')
blocks2 <- list(
  c('PGC'),
  c('LD','AC','IA','AI','CC','OE','AE','EP'),
  c('COM'),
  c('DES')
)
names(blocks2) <- LV2
modes2 <- setNames(rep('A', length(blocks2)), LV2)

# 3) Matriz de caminhos (triangular inferior)
inner2 <- matrix(0, nrow=4, ncol=4, dimnames=list(LV2, LV2))
inner2['CCG','PGC'] <- 1   # H1: PGC → CCG (atenção: matriz usa colunas como antecedentes)
inner2['COM','CCG'] <- 1   # H3: CCG → COM
inner2['DES','CCG'] <- 1   # H2: CCG → DES
inner2['DES','COM'] <- 1   # H4: COM → DES

# 4) Rodar PLS-PM Estágio 2
pls_stage2 <- plspm(data2, inner2, blocks2, modes = modes2, scaled = TRUE)

# 5) Exportar resultados
saveRDS(pls_stage2, file.path(path_out, 'stage2_pls.rds'))
write.csv(pls_stage2$path_coefs,  file.path(path_out,'stage2_path_coefs.csv'))
write.csv(pls_stage2$inner_model, file.path(path_out,'stage2_inner_model.csv'))
write.csv(pls_stage2$outer_model, file.path(path_out,'stage2_outer_model.csv'))

cat('[OK] Estágio 2 concluído. Resultados em Output/.\n')
