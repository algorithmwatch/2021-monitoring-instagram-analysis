# Towards a Monitoring of Instagram - Analysis

## About

This repository contains the code of the analysis of the project "Towards a Monitoring of Instagram". The project was led by AlgorithmWatch and [funded by SIDN Fonds](https://www.sidnfonds.nl/algorithmwatch-maps-instagrams-political-impact).

The analysis was designed and coded by [Boris Reuderink](http://cortext.nl/).

This project is a follow-up of the [Monitoring Instagram](https://github.com/algorithmwatch/monitoringinstagram) project, which was funded by the European Data Journalism Network. 

## Data

We asked volunteers to install a browser add-on that scans their Instagram newsfeeds at regular intervals. Each data donor was told to follow three accounts of Dutch politicians or political parties.

We recorded what politicians posted on Instagram on the one hand. On the other, we recorded what volunteers saw at the top of their newsfeed. This way, we could see when a volunteer encountered a post by a politician – and when not.

The [browser plugin](https://algorithmwatch.org/en/instagram-algorithm/) was developed by [Édouard Richard](https://www.edri.fr/).

## Analysis

The preparatory steps for the analysis can be read in `doc/analysis_plan.pdf`. The code of the analysis can be consulted at `notebooks/TAMI Dutch politics.ipynb`

The graphs used in the article use the following data:

![](https://i.imgur.com/J7IGmOZ.png)

Ratio of posts seen vs not seen in cell [19] of the [analysis from Feb 22](https://github.com/algorithmwatch/monitoring-instagram-TAMI/blob/main/archive/feb22/TAMI%20Dutch%20politics.ipynb).

![](https://i.imgur.com/3B6VlD1.png)

The probability that a post be seen, taking into account the results of the model predicting visibility, is calculated using exp(x) (x being the data from cell [26] of the [analysis from Feb 22](https://github.com/algorithmwatch/monitoring-instagram-TAMI/blob/main/archive/feb22/TAMI%20Dutch%20politics.ipynb), which represents the log-odds).

## Usage

Upon reception of the database, process the data for the analysis:

    make all

Build collage of images to help the analysis:

    make images

Run the analysis:

    jupyter notebook

Save the current notebook and the collages of images:

    make archive date=current_date