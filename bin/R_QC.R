#!/usr/bin/env Rscript

args = commandArgs(trailingOnly=TRUE)

cat(args, sep = "\n")

imiss <- read.table(args[1], header=TRUE, sep = "") #Did not include shoot3.sh
het <- read.table(args[2], header=TRUE, sep = "")

#CALCULATE LOG10(F_FMISS) and mean heterozygosity
imiss$logF_MISS = log10(imiss[,6])
het$meanHet = (het$N.NM. - het$O.HOM.)/het$N.NM.
het$meanHet <- ifelse(het$meanHet=="NaN", c(0),c(het$meanHet))
imiss.het <- merge(het,imiss,by=c("FID","IID"))

#GENERATE CALL RATE BY HETEROZYGOSITY PLOT
colors  <- densCols(imiss$logF_MISS,het$meanHet)
pdf("pairs.imiss-vs-het.pdf")
plot(imiss$logF_MISS,het$meanHet, col=colors, xlim=c(-3,0),ylim=c(0.15,0.75),pch=20, xlab="Proportion of missing genotypes", ylab="Heterozygosity rate",axes=F)
axis(2,at=c(0.15,0.2,0.25,0.3,0.35,0.4,0.45,0.5,0.55,0.60,0.65,0.70,0.75),tick=T)
axis(1,at=c(-3,-2,-1,0),labels=c(0.001,0.01,0.1,1))

#Heterozygosity thresholds (Horizontal Line)
abline(h=mean(het$meanHet)-(3*sd(het$meanHet)),col="RED",lty=2)
abline(h=mean(het$meanHet)+(3*sd(het$meanHet)),col="RED",lty=2)

#Missing Data Thresholds (Vertical Line)
abline(v=-1.3, col="BLUE", lty=2) #THRESHOLD=0.05

#Listing the extreme heterozygosity
low_lim <- mean(het$meanHet)-(3*sd(het$meanHet))
high_lim <- mean(het$meanHet)+(3*sd(het$meanHet))
low_lim
high_lim
#write.table(het[which(het$meanHet < low_lim), c(1-8)], file="lower.txt")
#write(het[which(het$meanHet > high_lim), c(1-8)], file="higher")
#&& het$meanHet > high_lim
#het[which(het$meanHet > high_lim), c(1-8)]
