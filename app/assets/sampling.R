
# set working directory
wd = getwd()

# set data directory
raw_data_dir <- "./data_raw/final/en_US/"

samplingFile <- function(filename, prob) {
    # create a sample file for a given probability
    
    # read raw files
    incon <- file(paste(raw_data_dir, "en_US.", filename, ".txt",sep=""),"rb")
    file <- readLines(incon)
    
    # sampling by rbinom()
    set.seed(123)
    sample_file <- file[rbinom(n = length(file), size = 1, prob = prob) == 1]
    close(incon)
    
    # Write out the sample file to the local file to save it
    outCon <- file(paste(raw_data_dir, "sample_", filename, ".txt",sep=""), "w")
    writeLines(sample_file, con = outCon)
    close(outCon)
}

samplingFile("blogs", .1)
samplingFile("news", .1) # to skip incomplete final line found open in binary mode (rb)
samplingFile("twitter", .1)