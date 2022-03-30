FROM rocker/shiny:4.0.5

RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev \
    unixodbc-dev \
    odbc-postgresql
    
# Install Doppler CLI
RUN apt-get update && apt-get install -y apt-transport-https ca-certificates curl gnupg && \
    curl -sLf --retry 3 --tlsv1.2 --proto "=https" 'https://packages.doppler.com/public/cli/gpg.DE2A7741A397C129.key' | apt-key add - && \
    echo "deb https://packages.doppler.com/public/cli/deb/debian any-version main" | tee /etc/apt/sources.list.d/doppler-cli.list && \
    apt-get update && \
    apt-get -y install doppler

RUN R -e 'install.packages(c("shiny", "tidyverse", "stringi", "odbc", "DBI", "pool"), \
            repos = "https://packagemanager.rstudio.com/cran/__linux__/focal/2021-04-23")'
          
WORKDIR /home/app
COPY app .
EXPOSE 3838
ADD ./odbcinst_app.ini /etc/odbcinst.ini

CMD ["doppler", "run", "--", "R", "-e", "shiny::runApp('/home/app', host = '0.0.0.0', port = 3838)"]
