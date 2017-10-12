# Importar datos (Borrar última parte del report)
# Nombres
noms.diag <- c("fecha", "diag.name", "categoria", "n.practica", "practica",
               "meta", "cumple.diag")
noms.seg <- c("fecha", "diag.name", "categoria", "n.practica", "practica",
              "cumple.seg")
# Importar
diag <- read.csv("Registros de diagnostico MyE.csv", sep = ";",
                 encoding = "UTF-8", col.names = noms.diag)
segs <- read.csv("Registros de seguimiento MyE.csv", sep = ";", 
                 encoding = "UTF-8", col.names = noms.seg)
# Fechas como clase date
segs$fecha <- as.Date.character(segs$fecha, format = "%d/%m/%Y")
diag$fecha <- as.Date.character(diag$fecha, format = "%d/%m/%Y")

# Cread ID de práctica y PMF
# ID diagnostico
id1 <- paste(diag$diag.name, diag$n.practica, sep = ".")
diag <- data.frame(id1, diag)
# ID seguimientos
id1 <- paste(segs$diag.name, segs$n.practica, sep = ".")
segs <- data.frame(id1, segs)

# Ordenar por fecha y elminar duplicados
# Diagnósticos
diag <- diag[order(diag$fecha, decreasing = TRUE), ]
diag <- diag[!duplicated(diag$id1), ]
# Seguimientos
segs <- segs[order(segs$fecha, decreasing = TRUE), ]
segs <- segs[!duplicated(segs$id1), ]
 
# Join de las dos tablas
library(dplyr)
consolidado <- inner_join(diag, select(segs, id1, cumple.seg),
                          by = "id1")
consolidado <- select(consolidado, categoria, practica, meta, cumple.diag,
                      cumple.seg)
 
# Crear indicador de meta y cumplimientos
consolidado$meta <- ifelse(consolidado$meta == "Sí", 1, 0)
consolidado$cumple.diag <- ifelse(consolidado$cumple.diag == "Sí", 1, 0)
consolidado$cumple.seg <- ifelse(consolidado$cumple.seg == "Sí", 1, 0)
 
# Agregar meta y cumplimientos por práctica
agregado <- aggregate(select(consolidado, meta, cumple.diag, 
                            cumple.seg),
                     select(consolidado, practica),
                     FUN = mean, na.rm = TRUE)

# Exportar csv
write.csv(agregado, "agregado_practica.csv")
