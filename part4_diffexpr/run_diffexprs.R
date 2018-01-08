#!/usr/bin/Rscript
#####################################################

library("optparse")

option_list = list(
  make_option(c("-c", "--countsfile"), type="character", default=NULL, 
              help="count dataset file name", metavar="character"),
  make_option(c("-o", "--out"), type="character", default=".", 
              help="output directory", metavar="character"),
  make_option(c("-w", "--wilcoxon"), action="store_true", default=FALSE, 
              help="compute Mann-Whitney-Wilcoxon test", metavar="character"),
  make_option(c("-d", "--deseqpar"),action="store_true",default=FALSE, 
              help="Run DESeq with parametric ", metavar="character"),
  make_option(c("-l", "--deseqloc"),action="store_true",default=FALSE, 
              help="Run DESeq with local", metavar="character"),
  make_option(c("-m", "--metagenomeseq"), action="store_true",default=FALSE, 
              help="run metagenomeSeq", metavar="character"),
  make_option(c("-e", "--edgeR"), action="store_true",default=FALSE, 
              help="run edgeR ", metavar="character")
  #make_option(c("-t", "--conditions"), type="character",
  #            help="0 or 1 for each sample, coma separated", metavar="character")
); 

opt_parser = OptionParser(option_list=option_list);
opt = parse_args(opt_parser, positional_arguments=TRUE);


datafile <- opt$options$countsfile

print(paste("DE on file:", datafile))
dir.create(opt$options$out, showWarnings = FALSE)

args <- opt$args
countTable = read.table( datafile, sep="\t", header=TRUE, row.names=1 )

if ((length(args) != length(colnames(countTable))) || (sum(args == "0") + sum(args == "1") + sum(args == '-') != length(args))) {
    cat(" You need to specify if sample is treated (1) or untreated(0) for every sample\n")
    cat(args)
    q(save="no", status=1)
}

############################### Prepare data ##############################################


countTable[,] <- round(countTable[,])
countTable[, args == '-'] <- NULL
print(colnames(countTable))

f <- function(x) {
    f <- ifelse(x=="0", "untreated", "treated")
}
condition <- sapply(args[args != '-'], f)
n <- length(condition)


n1<- sum(condition == 'untreated')
n2<-sum(condition == 'treated')
#### Remove samples that are clearly differential
sums1 <- rowSums(countTable[, condition == "untreated" ])
sums2 <- rowSums(countTable[, condition == "treated" ])

data <- countTable
data$name <- rownames(data)
data$mean <- (sums1+sums2)/n
data$mean1 <- sums1/n1
data$mean2 <- sums2/n2
data$fold <- data$mean1/data$mean2
data$log2fold <- sapply(data$fold, log2)


MINREADSCOND <- 5
MINREADSSUMS <- 10
MINREADS <- 1
NMINREADS <- n-1


########### remove some reads with not enough reads in condition ####################
interesting <- (sums2/n2<=MINREADSCOND) | (sums1/n1<=MINREADSCOND) 
int <- data[interesting,]

write.table(int[order(abs(int$log2fold)),(n+1):dim(int)[2]], paste(opt$options$out, '/interesting.txt', sep=''), quote=FALSE, sep='\t',
            col.names = FALSE)
rm(int)
###interesting <- interesting | (apply(countTable, 1, function(x) sum(x>5)) < n)
countTable <- countTable[!interesting,] 
data <- data[!interesting,]


########## run simpler test first - Mann-Whitney-Wilcoxon, H0: equal means, no assumption on distr

if (opt$options$wilcoxon) {
  pv = rep(0,dim(countTable)[1]) 
  normfac <- colSums(countTable)
  s <- scale(countTable, center=FALSE, scale=normfac/1000000)

  for (i in 1:dim(countTable)[1]) { pv[i]=wilcox.test(as.numeric(s[i,condition=="untreated"]), 
                                                    as.numeric(s[i,condition=="treated"]), 
                                                    alternative = "two.sided")$p.value } 
  data$MWpval <- pv
  ## multiple hypothesis correction
  #data$padj <- min(1, pv*dim(data)[1])

  write.table(data[order(abs(data$MWpval)),(n+1):dim(data)[2]], paste(opt$options$out, '/wilcoxon.tsv', sep=''), quote=FALSE, sep='\t',
            col.names = FALSE)
  rm(s)
}

####################### edgeR #############################
if (opt$options$edgeR) {
  suppressWarnings(suppressMessages(library(edgeR)))
  group <- sapply(condition, function(x) ifelse(x=="treated", 1,2))
  y <- DGEList(counts=countTable,group=group)
  y <- calcNormFactors(y)
  keep <- rowSums(cpm(y)>=MINREADS) >= NMINREADS #filter
  y <- y[keep, , keep.lib.sizes=FALSE]
  y <- calcNormFactors(y)
  
  design <- model.matrix(~group)
  y <- estimateDisp(y,design)
  
  ##### exact Fisher-like test - for one-factor data (?)
  #et <- exactTest(y)
  #et<-et[order(et$table$PValue),]
  #et[et$table$PValue < 0.05,]
  
  #To perform quasi-likelihood F-tests:   for small number of replicates
  fit <- glmQLFit(y,design)
  qlf <- glmQLFTest(fit,coef=2)
  topTags(qlf)
  
  #print(sapply(rownames(data)[1:10], function(x) qlf$table[x,"PValue"]))
  data$edgeRpv <- sapply(rownames(data), function(x) qlf$table[x,"PValue"])
  
  #To perform likelihood ratio tests:
  #fit <- glmFit(y,design)
  #lrt <- glmLRT(fit,coef=2)
  #topTags(lrt)
  
  rm(y, fit, qlf)
}

########################### DESeq #####################

rundeseq <- function(cds, outdir, fitType, title) {
  suppressWarnings(suppressMessages(library(gplots)))
  
  pdf(paste(outdir, '/', fitType, '.pdf', sep=''), paper='a4', title=title)
  ### write basic info 
  par(mar=c(0,0,0,0))
  
  y <- strsplit(colnames(countTable),".",fixed=TRUE)
  tab <- data.frame(names=colnames(countTable))
  tab$names <- lapply(y, function(x) {paste(x[6],x[10],sep=".")})
  tab$condition <- condition
  tab$sizeFactors <-  lapply(sizeFactors(cds), function(x) { formatC(x, digits=4, format="g", flag="-") })
  tab$nReads <- colSums(countTable)
  colnames(tab) <- c("sample", "condition", "size factors", "no. reads")
  textplot(tab, show.rownames=F)
  
  ########## estimate dispersion and run DE analysis
  if ( fitType == "parametric" ) {
    cds = estimateDispersions( cds, fitType="parametric" )
  } else {
    cds = estimateDispersions( cds, method="blind", sharingMode="fit-only", fitType="local" )
  }
  
  #print( fitInfo( cds ) )
  par(oma=c(0,0,3,0), mar=c(5,5,3,5))
    
  plotDispEsts( cds, main="Empirical (black dots) and fitted (red lines) dispersion values \nplotted against the mean of the normalised counts. " )

  mtext(title, outer=TRUE, cex=1.5, line=1) 
  res = nbinomTest( cds, "untreated", "treated" )
  plotMA(res, main="Plot of normalised mean versus log2 fold change \nfor the contrast untreated versus treated")
  hist(res$pval, breaks=100, col="skyblue", border="slateblue", main="Histogram of p-values")
  par(xaxs='i', yaxs='i' )
  
  res <- res[ order(res$pval), ] 
  write.table(res, paste(outdir, '/', fitType, '.csv', sep=''), append=FALSE, quote=FALSE, row.names = FALSE, sep="\t")
  return(res)
}

#######  DESeq cd ###########

if (opt$options$deseqpar | opt$options$deseqloc) {
  suppressWarnings(suppressMessages(library( "DESeq" )))
  title=paste("DESeq on ", sum(condition=="untreated"), " untreated and ", sum(condition=="treated"), " treated samples, on ", nrow(countTable) , "genes."  ) 

  cds = newCountDataSet( countTable, condition )
  cds = estimateSizeFactors( cds )
  
  if ( length(condition) > 3 & opt$options$deseqpar ) {
    cds1 = tryCatch({
      res <- rundeseq(cds, opt$options$out, "parametric", title )
      data$DESeqparpv <- sapply(rownames(data), function(x) res[res$id==x,]$pval)
    }, error = function(e) {
      warning(e)
      opt$options$deseqloc <- TRUE
      FALSE
    }    )
  } 
  
  if ( opt$options$deseqloc ) {
    res <- rundeseq(cds, opt$options$out, "local", title )
    data$DESeqlocpv <- sapply(rownames(data), function(x) res[res$id==x,]$pval)
  }
}

################## metagenomeSeq #######################
if ( opt$options$metagenomeseq ) {
  suppressWarnings(suppressMessages(library(metagenomeSeq)))
  metaData <- loadMeta(datafile,sep = '\t' )
  #metaData <- load_meta(datafile,sep = '\t' )
  mrexpr <- newMRexperiment(metaData$counts)
  samplesToKeep = which(args != '-')
  mrexpr = mrexpr[, samplesToKeep]
  #filtrowanie
  print(paste("MetagenomeSeq before filtering", dim(MRcounts(mrexpr))[1]))
  
  p = cumNormStatFast(mrexpr)
  mrexpr = cumNorm(mrexpr, p = p)
  mrexpr = filterData(mrexpr, present = NMINREADS, depth = MINREADS)
  print(paste("MetagenomeSeq after filtering", dim(MRcounts(mrexpr))[1]))
  
  
  #### another filtering?
  #rareFeatures = which(rowSums(MRcounts(mrexpr, norm=T) < 1) > 1)
  #mrexpr = mrexpr[-rareFeatures, ]
  #print(paste("MetagenomeSeq filtered out", length(rareFeatures), "reads leaving", dim(MRcounts(mrexpr))[1]))

  
  ###export counts
  #mat = MRcounts(mrexpr, norm = TRUE, log = TRUE)
  #exportMat(mat, file = outputfile6)
  #exportStats(mrexpr, file= outputfile6)
  
  ## log-normal model
  pd <- pData(mrexpr)
  mod <- model.matrix(~condition, data = pd)
  fitModel = fitFeatureModel(mrexpr, mod)
  #fitModel = fitLogNormal(mrexpr, mod)
  head(MRcoefs(fitModel)$pvalues)
  
  data$metagenomeSeq.pvLogNorm <- sapply(rownames(data), function(x) fitModel$pvalues[x])
  
  ##ZIG model 
  normFactor = normFactors(mrexpr)
  normFactor = log2(normFactor/median(normFactor) + 1)
  mod2 = model.matrix(~condition + normFactor)
  settings = zigControl(maxit = 10, verbose = TRUE)
  fitZigModel = fitZig(obj = mrexpr, mod = mod2, useCSSoffset = FALSE,
               control = settings)
  
  data$metagenomeSeq.pvZIG <- sapply(rownames(data), function(x) fitZigModel$eb$p.value[,2][x])
}

#print(warnings())
################# WRITE SUMMARY


data <- data[, (n+1):dim(data)[2]]
data$toCheck <- apply(data, 1, function(x) sum(x[6:length(x)]  < 0.05, na.rm = T))

mins <- apply(data, 1, function(x) min(x[6:(dim(data)[2]-1)]))
data<-data[order(mins,  decreasing = F),]

print(paste("Number of contigs to check by at least 2 methods:", sum(data$toCheck >= 2, na.rm = TRUE)))
write.table(data[order(data$toCheck,  decreasing = T),], paste(opt$options$out, '/pvals.csv', sep=''), quote=FALSE, sep=',', row.names = F,
            col.names = TRUE, )

q(save="no", status=0)
