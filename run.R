#Script para cuantificar las importaciones en Colombia
#Cargar funciones y dependencias
source("readData.R")
source("processData.R")
source("plots.R")
source("D:/BigData//lib/DownloadFile.R")
#Funci�n que corre el an�lisis
# - filename: nombre del archivo csv que contiene la base de datos
# - directorio: directorio donde ser�n guardados los gr�ficos
run <- function(filename = "500_PERIODO_01_2016.csv", directorio = "Importaciones", download = FALSE){
  #Cargar librarias
  loadLibs()
  if(!dir.exists(directorio)){
    dir.create(directorio)
  }
  
  #Descargar archivos
  if(!file.exists("Declaraciones/importaciones_ultrafiltracion.csv")){
    
    meses <- sprintf("500_PERIODO_%02d_", 1:12)
    if(download == TRUE){
      for(j in 2016:2017)
        for(i in 1:12){
          url <- paste0("http://www.dian.gov.co/descargas/cifrasyg/declaraciones/importacion/",j,"/",meses[i],j,".zip")
          name <- paste0(meses[i],j,".zip")
          if(i <= 5 || j <= 2016) 
            MyDownloadFile(fileUrl = url,folder = "Declaraciones",name = name,dataset = FALSE)
        }
    }
    #Leer base de datos
    if(download == FALSE){
      importaciones <- NULL
      for(j in 2009:2017)
        for(i in 1:12){
          filename <- paste0("Declaraciones","/",meses[i],j,".csv")
          if(i <= 5 || j <= 2016){
            if(file.exists(filename))
            importaciones <- rbind(importaciones,readData(filename))
            else
              message(paste0("File: ",filename," not found!"))
          }
        }
      write.csv(x=importaciones,file = "Declaraciones/importaciones_ultrafiltracion.csv")
    }
    else{
      importaciones <- read.csv("Declaraciones/importaciones_ultrafiltracion.csv")
    }
    #Procesar importaciones
    importaciones <- processData(importaciones)
    #generar graficas
    #Mes
    main(importaciones,"Total")
    main(importaciones[grepl("^2204",as.character(importaciones$subpartida)),],"Vino")
    main(importaciones[grepl("2204100000",as.character(importaciones$subpartida)),],"VinoEspumoso")
    #a�o
    importacionesA�o <- importaciones %>% mutate(tiempo = a�o) %>% filter(tiempo < 2017)
    main(importacionesA�o,"TotalA�o")
    main(importacionesA�o[grepl("^2204",as.character(importacionesA�o$subpartida)),],"VinoA�o")
    main(importacionesA�o[grepl("2204100000",as.character(importacionesA�o$subpartida)),],"VinoEspumosoA�o")
    #Guardar archivos en Carpeta correspondiente
    files <- list.files(pattern = "\\.png$")
    file.rename(files,paste0(directorio,"/",files))
    
    print("Analisis finalizado ...")
    
    importaciones
  }
}

#Cargar librerias
loadLibs = function() {
  
  #Check si los paquetes est�n instalados
  if(!require(lubridate)){
    install.packages("lubridate")
  }
  if(!require(dplyr)){
    install.packages("dplyr")
  }
  if(!require(RColorBrewer)){
    install.packages("RColorBrewer")
  }
  if(!require(zoo)){
    install.packages("ggplot2")
  }
  #Check lista de librer�as
  packages <- search()
  
  #Cargar librer�as necesarias en caso que no esten cargadas
  if(sum(grepl("package::lubridate", packages)) == 0) library(lubridate)
  if(sum(grepl("package::dplyr", packages)) == 0) library(dplyr)
  if(sum(grepl("package::ggplot2", packages)) == 0) library(ggplot2)
  if(sum(grepl("package::RColorBrewer", packages)) == 0) library(RColorBrewer)
  
}