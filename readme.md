# Towards a Monitoring of Instagram - Analysis

## About

This repository contains the code of the analysis of the project "Towards a Monitoring of Instagram". The project was led by AlgorithmWatch and [funded by SIDN Fonds](https://www.sidnfonds.nl/algorithmwatch-maps-instagrams-political-impact).

The analysis was designed and coded by [Boris Reuderink](http://cortext.nl/).

## Data

The data comes from a [browser plugin](https://algorithmwatch.org/en/instagram-algorithm/) developed by [Édouard Richard](https://www.edri.fr/).

## Usage

Upon reception of the database:

- Process the data for the analysis:

    make all

- Build collage of images to help the analysis:

    make images

- Run the analysis:

    jupyter notebook

- Save the current notebook and the collages of images:

    make archive date=current_date