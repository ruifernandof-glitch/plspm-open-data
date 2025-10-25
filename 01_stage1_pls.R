# 01_stage1_pls.R — Estágio 1 (1ª ordem + saídas)
suppressPackageStartupMessages({
  library(plspm); library(readxl)
})

source(file.path('Scripts','00_utils.R'))

# 0) Ler dados
data_path <- file.path(path_in, 'data.xlsx')
stop_if_missing(data_path)
data <- readxl::read_excel(data_path)

# 1) Blocos externos (1ª ordem + outputs)
blocks <- list(
  c('PGC1','PGC2','PGC3','PGC4','PGC5'),   # PGC
  c('COM1','COM2','COM3'),                 # COM
  c('DES1','DES2','DES3','DES4'),          # DES
  c('LD1','LD2','LD3','LD4'),              # LD
  c('AC1','AC2','AC3','AC4'),              # AC
  c('IA1','IA2','IA3','IA4'),              # IA
  c('AI1','AI2','AI3','AI4'),              # AI
  c('CC1','CC2','CC3','CC4'),              # CC
  c('OE1','OE2','OE3','OE4'),              # OE
  c('AE1','AE2','AE3','AE4'),              # AE
  c('EP1','EP2','EP3','EP4')               # EP
)
modes <- rep('A', length(blocks))  # todos reflexivos
names(blocks) <- names(modes) <- c('PGC','COM','DES','LD','AC','IA','AI','CC','OE','AE','EP')

# 2) Modelo interno
LV <- names(blocks)
inner <- matrix(0, nrow=length(LV), ncol=length(LV), dimnames=list(LV, LV))
drivers <- c('LD','AC','IA','AI','CC','OE','AE','EP')
targets <- c('PGC','COM','DES')
inner[drivers, targets] <- 1

# 3) Rodar PLS-PM Estágio 1
pls_stage1 <- plspm(data, inner, blocks, modes = modes, scaled = TRUE)

# 4) Exportar resultados principais
saveRDS(pls_stage1, file.path(path_out, 'stage1_pls.rds'))
write.csv(pls_stage1$outer_model, file.path(path_out,'stage1_outer_model.csv'), row.names = FALSE)
write.csv(pls_stage1$inner_model, file.path(path_out,'stage1_inner_model.csv'), row.names = FALSE)
write.csv(pls_stage1$scores,      file.path(path_an, 'stage1_scores.csv'),      row.names = FALSE)

cat('[OK] Estágio 1 concluído. Arquivos gravados em Output/ e Data/AnalysisData/.\n')
