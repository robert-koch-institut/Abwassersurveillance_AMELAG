## Kontextmaterialien

[**--- see English version below ---**](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/tree/main/Kontextmaterialien#context-materials)

Diese Dokumentation gibt einen Überblick über die R-Skripte, die erforderlich sind, um die im [Abwasser-Wochenbericht des Robert-Koch-Instituts](https://edoc.rki.de/handle/176904/11665) dargestellten Ergebnisse zu replizieren, mit Ausnahme des Teils über die Virusvarianten. Die dortigen Ergebnisse wurden unter Verwendung von R 4.4.1 (64 bit, Windows) generiert. Sie können die Projektumgebung mithilfe des `renv`-Pakets (https://rstudio.github.io/renv/articles/renv) neu erstellen.

Beachten Sie, dass die Ergebnisse in Unterordnern mit den Namen `Results/'Pathogen'` gespeichert werden. Die Daten werden aus dem Hauptverzeichnis bezogen. Die Ergebnisordner werden automatisch erstellt, wenn Sie `main.R` ausführen.
Wenn Sie RStudio verwenden, starten Sie RStudio durch Ausführen des R-Projekts `amelag_open_code.Rproj` und führen Sie die Skripte dort aus, andernfalls müssen Sie die Pfade am Anfang des Skripts `main.R` anpassen. Wenn Sie die anderen Skripte öffnen, stellen Sie sicher, dass die deutschen Umlaute korrekt angezeigt werden, dies kann in RStudio sichergestellt werden, indem Sie Ihr Skript im richtigen Format neu laden ("File -> Reopen with Encoding -> UTF-8"). 

Im Folgenden werden alle zur Verfügung gestellten R-Skripte und Datensätze sowie der Ordner, der die erzeugten Ergebnisse enthält, beschrieben

### R-Skripte 

Das R-Skript [`main.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/main.R) erzeugt alle Grafiken, die im Wochenbericht angezeigt werden. Setzen Sie `show_log_data = FALSE` am Anfang von `main.R`, um Plots auf der Originalskala (statt auf der Logskala) zu erzeugen. Weitere Parameter und Variablen können am Anfang des Skripts geändert werden, dies wird momentan jedoch nicht empfohlen. Die Datei `main.R` ruft alle R-Skripte auf, die im Unteordner `Scripts` gespeichert sind und speichert alle Ergebnisse im Ordner `Results` und seinen Unterordnern. Die folgenden R-Skripte sind im Ordner [`Scripts`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/tree/main/Kontextmaterialien/Scripts) verfügbar: 


* [`functions_packages.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/functions_packages.R): Installiert (falls erforderlich) und lädt notwendige Pakete und enthält selbst geschriebene Funktionen. 

* [`loess_calculation.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/loess_calculation.R): Löscht LOESS-Berechnungen, entsprechende Konfidenzintervalle und berechnete Trends aus [`amelag_einzelstandorte.tsv`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/amelag_einzelstandorte.tsv) und zeigt, wie man diese Größen berechnet. Bereitet außerdem den Datensatz so vor, dass `plot_single_places.R` ordnungsgemäß ausgeführt werden kann.

* [`aggregation_calculation.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/aggregation_calculation.R): Ausgehend von den Daten `amelag_einzelstandorte.tsv` zeigt dieses Skript, wie man für jedes Pathogen die Daten aggregiert und die LOESS-Kurve und ihre jeweiligen Konfidenzintervalle für die aggregierten Daten berechnet. Im Wesentlichen zeigt dieses Skript, wie man aus `amelag_einzelstandorte.tsv` den Datensatz [`amelag_aggregierte_kurve.tsv`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/amelag_aggregierte_kurve.tsv) erhält.

* [`plot_single_places.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/plot_single_places.R): Erzeugt für jedes Pathogen eine Zeitreihengrafik mit einer LOESS-Kurve für jeden Standort, der genügend Daten geliefert hat. Speichert auch beobachtete und mittels LOESS geschätzte Abwasserdaten für jeden Standort, der genügend Daten geliefert hat. Für Standorte ohne ausreichende Daten werden keine LOESS-Schätzungen berechnet und gespeichert, jedoch die Daten und eine Zeitreihengraphik nur mit den beobachteten Datenpunkten gespeichert. Muss nach dem Skript `loess_calculation.R` ausgeführt werden.

* [`plot_aggregated_curve.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/plot_aggregated_curve.R): Erzeugt für jedes Pathogen eine Zeitreihendarstellung mit einer LOESS-Kurve für die über alle Standorte aggregierten Daten.  

* [`plot_heatmap.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/plot_heatmap.R): Erzeugt eine Heatmap, die Trends für alle Standorte zeigt, die genügend Daten geliefert haben. Bisher wird dies für SARS-CoV-2 für alle Bundesländer einzeln und einmal zusammen getan, dies kann aber am Ende des Skripts angepasst werden.

* [`plot_loq_plot.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/plot_loq_plot.R): Erzeugt für jedes Pathogen ein gestapeltes Balkendiagramm, das für jede Woche die Anteil an Messwerten oberhalb und unterhalb der Bestimmungsgrenze anzeigt.  


### Ergebnisse 

Nach dem Ausführen von `main.R` enthalten die Unterordner des Ordners `Results'` die Heatmap(s), die aggregierte Kurve sowie das gestapelte Balkendiagramm im Hauptverzeichnis, die Kurven und Daten für die einzelnen Standorte sind in dem jeweiligen Unterordner `Single_Sites` zu finden.


## Context materials  

This documentation provides an overview of the R scripts necessary to replicate the results shown in the [Robert-Koch Institute weekly report on wastewater surveillance](https://edoc.rki.de/handle/176904/11665) excluding the part on the virus variants. The results there were obtained by using R 4.4.1 (64 bit, Windows). You can recreate the project environment by using the `renv` package (https://rstudio.github.io/renv/articles/renv).

Note that the results are stored subfolder named `Results/'pathogen'`. The folders should already exist or be created automatically when running [`main.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/main.R). If you use RStudio, start RStudio by running the R project `amelag_open_code.Rproj` and run the scripts there, otherwise you have to adjust the paths at the beginning of the script `main.R`. If you open the other scripts, make sure that German umlauts are displayed correctly, this can be guaranteed in RStudio by reloading your script in proper format ("File -> Reopen with Encoding -> UTF-8"). 

In the following, all R scripts and datasets provided as well as the folder containing the produced results are described.

### R scripts
The R script [`main.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/main.R) generates all graphics displayed in the weekly report. Set `show_log_data = FALSE` to generate plots on the original scale (instead of the log scale) at the beginning of `main.R`. Additional parameters and variables can be changed at the top of the script, but this is not recommended at this time. The file `main.R` calls all R scripts stored in the `Scripts` subfolder and stores all results in the `Results` folder and its subfolders. The following R scripts are available in the [`Scripts`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/tree/main/Kontextmaterialien/Scripts) folder: 


* [`functions_packages.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/functions_packages.R): Installs (if required) and loads necessary packages, defines self-written functions and sets parameters and variables used in other scripts.

* [`loess_calculation.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/loess_calculation.R): Drops loess calculations, respective confidence intervals and calculated trends from [`amelag_einzelstandorte.tsv`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/amelag_einzelstandorte.tsv) and shows how to calculate these quantities. Prepares the dataset such that `plot_single_places.R` can be run properly.

* [`aggregation_calculation.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/aggregation_calculation.R): Beginning with the data  `amelag_einzelstandorte.tsv`, this script shows how to aggregate the data for each pathogen and calculates the loess curve and its respective confidence interval for the aggregated data. Basically this script shows how to obtain the data set [`amelag_aggregierte_kurve.tsv`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/amelag_aggregierte_kurve.tsv) from `amelag_einzelstandorte.tsv`.

* [`plot_single_places.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/plot_single_places.R): Generates for each pathogen a time series plot containing a loess curve for each site that provided sufficient data. Also stores observed and (LOESS-)fitted wastewater data for each place that provided sufficient data. For sites with insufficient data, no LOESS estimates are computed and stored, but the data and a time series graph with only the observed data points are stored. This script to be executed after running `loess_calculation.R`.

* [`plot_aggregated_curve.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/plot_aggregated_curve.R): Generates for each pathogen a time series plot containing a loess curve for data aggregated over all sites.  

* [`plot_heatmap.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/plot_heatmap.R): Generates a heatmap which shows trends for all places that provided sufficient data. So far, this is done for SARS-CoV-2 for all federal states individually and once together, but this can be customized at the end of the script.  

* [`plot_loq_plot.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/plot_loq_plot.R): Generates for each pathogen a stacked barplot showing the share of sampled values below and above the limit of quantification.  

### Results
After running `main.R`, the subfolders of the folder `Results` contain the heatmap(s), the aggregated curve and the stacked barplot in the main directory, the curves and data for the single sites are stored in the subfolder `Single_Sites`.
