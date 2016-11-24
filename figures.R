data <- read.table("time.txt", sep="\n")[,1]

data <- data[data < 1024]

ts.plot(data/1024, xlab="Time", ylab="Jitter")
hist(data+0.5,freq = FALSE, breaks=-1:(max(data)+1)+0.5, xlab="Time passed expected (ms)")
lines(density(data, bw=0.5))


table(data)
max(data)+1
