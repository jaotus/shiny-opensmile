
This is a tool to help comparing subsets of speech WAVs.
It is using [opensmile](https://github.com/audeering/opensmile-python) for feature extraction and
RStudio [Shiny](https://shiny.rstudio.com/) for presenting the statistics.

## Installation

1. Install R
2. Change to the folder of this project
3. Start R and install `renv` and dependencies
   ```R
   install.packages("renv")
   renv::restore()
   ```

## Using

1. Prepare files:
   - Pack WAVs with ZIP
   - Create CSV file with factors.
     
     It should have a line for each WAV file and 
     file name should be in the first column with name `file`.
     Ex:
     ```
     file,f1,f2
     003.wav,calm,male
     004.wav,energetic,female
     ```

2. Run the server:
   ```bash
   Rscript app.R
   ```
3. Use browser __http://localhost:8008__

