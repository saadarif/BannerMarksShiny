FROM rocker/shiny:4.2.1
RUN install2.r rsconnect:1.2.0 shinyFeedback readxl openxlsx
WORKDIR /home/BannerMarksShiny
COPY app.R app.R 
COPY deploy.R deploy.R
CMD Rscript deploy.R
