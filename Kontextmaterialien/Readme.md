## Kontextmaterialien

[**--- see English version below ---**](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/tree/main/Kontextmaterialien#context-materials)

Diese Dokumentation gibt einen Überblick über die R-Skripte, die erforderlich sind, um die im [Abwasser-Wochenbericht des Robert-Koch-Instituts](https://www.rki.de/DE/Content/Institut/OrgEinheiten/Abt3/FG32/Abwassersurveillance/Bericht_Abwassersurveillance.html?__blob=publicationFile) dargestellten Ergebnisse zu replizieren, mit Ausnahme des Teils über die Virusvarianten. Die dortigen Ergebnisse wurden unter Verwendung von R 4.3.0 (64 bit, Windows) erzielt.

Beachten Sie, dass die Ergebnisse in einem Unterordner mit dem Namen `Results` gespeichert werden. Die Daten werden aus dem Hauptverzeichniss bezogen. Der Ordner `Results` wird automatisch erstellt, wenn Sie `main.R` ausführen.
Wenn Sie RStudio verwenden, starten Sie RStudio durch Ausführen des R-Projekts `amelag_open_code.Rproj` und führen Sie die Skripte dort aus, andernfalls müssen Sie die Pfade am Anfang des Skripts `main.R` anpassen. Vergewissern Sie sich, bevor Sie `main.R` oder ein anderes Skript das erste Mal ausführen, dass das R-Paket `pacman` installiert ist. Sie können dieses Paket installieren, indem Sie 
```
install.packages("pacman", repos="https://cran.rstudio.com/")
```
in Ihrer R-Konsole eingeben. Stellen Sie auch sicher, dass die deutschen Umlaute korrekt angezeigt werden, dies kann in RStudio sichergestellt werden, indem Sie Ihr Skript im richtigen Format neu laden ("File -> Reopen with Encoding -> UTF-8"). 

Im Folgenden werden alle zur Verfügung gestellten R-Skripte und Datensätze sowie der Ordner, der die erzeugten Ergebnisse enthält, beschrieben.

### R-Skripte 

Das R-Skript [`main.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/main.R) erzeugt alle Grafiken, die im Wochenbericht angezeigt werden. Setzen Sie `show_log_data = FALSE` am Anfang von `main.R`, um Plots auf der Originalskala (statt auf der Logskala) zu erzeugen. Die Datei `main.R` ruft alle R-Skripte auf, die im Unteordner `Scripts` gespeichert sind und speichert alle Ergebnisse im Ordner `Results` und seinen Unterordnern. Die folgenden R-Skripte sind im Ordner [`Scripts`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/tree/main/Kontextmaterialien/Scripts) verfügbar: 


* [`functions_packages.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/functions_packages.R): Installiert (falls erforderlich) und lädt notwendige Pakete, definiert selbst geschriebene Funktionen und setzt Parameter und Variablen, die in anderen Skripten verwendet werden.

* [`loess_calculation.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/loess_calculation.R): Löscht LOESS-Berechnungen, entsprechende Konfidenzintervalle und berechnete Trends aus [`amelag_einzelstandorte.tsv`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/amelag_einzelstandorte.tsv) im Hauptverzeichniss und zeigt, wie man diese Größen berechnet. 

* [`aggregation_calculation.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/aggregation_calculation.R): Ausgehend von den Daten `amelag_einzelstandorte.tsv` zeigt dieses Skript, wie man die Daten aggregiert und die LOESS-Kurve und ihre jeweiligen Konfidenzintervalle für die aggregierten Daten berechnet. Im Wesentlichen zeigt dieses Skript, wie man aus `amelag_einzelstandorte.tsv` den Datensatz [`amelag_aggregierte_kurve.tsv`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/amelag_aggregierte_kurve.tsv) erhält.

* [`plot_single_places.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/plot_single_places.R): Erzeugt eine Zeitreihengrafik mit einer LOESS-Kurve für jeden Standort, der genügend Daten geliefert hat. Speichert auch beobachtete und mittels LOESS geschätzte Abwasserdaten für jeden Standort, der genügend Daten geliefert hat. Für Standorte ohne ausreichende Daten werden keine LOESS-Schätzungen berechnet und gespeichert.

* [`plot_aggregated_curve.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/plot_aggregated_curve.R): Erzeugt eine Zeitreihendarstellung mit einer LOESS-Kurve für die über alle Standorte aggregierten Daten.  

* [`plot_heatmap.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/plot_heatmap.R): Erzeugt eine Heatmap, die Trends für alle Standorte zeigt, die genügend Daten geliefert haben.  

### Ergebnisse 

Nach dem Ausführen von `main.R` enthält der Ordner `Results` die Heatmap und die aggregierte Kurve in seinem Hauptverzeichnis und die Kurven und Daten für die einzelnen Standorte in seinem Unterordner `Single_Sites`.


## Context materials  

This documentation provides an overview of the R scripts necessary to replicate the results shown in the [Robert-Koch Institute weekly report on wastewater surveillance](https://www.rki.de/DE/Content/Institut/OrgEinheiten/Abt3/FG32/Abwassersurveillance/Bericht_Abwassersurveillance.html?__blob=publicationFile) excluding the part on the virus variants. The results there were obtained by using R 4.3.0 (64 bit, Windows).

Note that the results are stored in a subfolder named `Results`. The folder should already exist or be created automatically when running [`main.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/main.R). If you use RStudio, start RStudio by running the R project `amelag_open_code.Rproj` and run the scripts there, otherwise you have to adjust the paths at the beginning of the script `main.R`. Make sure before running `main.R` or any other script the first time, that the R package `pacman` is installed, you can install this package by typing in
```
install.packages("pacman", repos="https://cran.rstudio.com/")
```
in your R console. Make also sure that German umlauts are displayed correctly, this can be guaranteed in RStudio by reloading your script in proper format ("File -> Reopen with Encoding -> UTF-8"). 

In the following, all R scripts and datasets provided as well as the folder containing the produced results are described.

### R scripts
The R script [`main.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/main.R) generates all graphics displayed in the weekly report. Set `show_log_data = FALSE` to generate plots on the original scale (instead of the log scale) at the beginning of `main.R`. `main.R` calls all R scripts stored in the subfolder named `Scripts` and stores all results in the folder `Results` and its subfolders. The following R scripts are available in the folder [`Scripts`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/tree/main/Kontextmaterialien/Scripts): 

* [`functions_packages.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/functions_packages.R): Installs (if required) and loads necessary packages, defines self-written functions and sets parameters and variables used in other scripts.

* [`loess_calculation.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/loess_calculation.R): Drops loess calculations, respective confidence intervals and calculated trends from [`amelag_einzelstandorte.tsv`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/amelag_einzelstandorte.tsv) and shows how to calculate these quantities. 

* [`aggregation_calculation.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/aggregation_calculation.R): Beginning with the data  `amelag_einzelstandorte.tsv`, this script shows how to aggregate the data and calculates the loess curve and its respective confidence interval for the aggregated data. Basically this script shows how to obtain the data set [`amelag_aggregierte_kurve.tsv`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/amelag_aggregierte_kurve.tsv)from `amelag_einzelstandorte.tsv`.

* [`plot_single_places.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/plot_single_places.R): Generates a time series plot containing a loess curve for each site that provided sufficient data. Also stores observed and (LOESS-)fitted wastewater data for each place that provided sufficient data. For sites without sufficient data, loess estimates are not calculated and stored.

* [`plot_aggregated_curve.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/plot_aggregated_curve.R): Generates a time series plot containing a loess curve for data aggregated over all sites.  

* [`plot_heatmap.R`](https://github.com/robert-koch-institut/Abwassersurveillance_AMELAG/blob/main/Kontextmaterialien/Scripts/plot_heatmap.R): Generates the heatmap which shows trends for all places that provided sufficient data.  

### Results
After running `main.R`, the folder `Results` contains the heatmap and the aggregated curve in its main directory and the curves and data for the single sites in its subfolder `Single_Sites`.
