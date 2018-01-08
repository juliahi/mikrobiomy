import sys

sep=','
maxlines = 20

with open(sys.argv[2], 'w+') as f:
    fin = open(sys.argv[1])
    header = fin.readline().split(sep)
    header = [header[0], header[2],header[3]] + header[5:]

    f.write('\\begin{tabular}{'+'|'.join(['r']*len(header))+'}\n')
    f.write(' & '.join(header)+'\\\\\n')
    lines = 0
    for line in fin:
        entries = line.split(sep)
        
        #######
        entries = [entries[0], entries[2], entries[3]] + map(lambda x:  "%.5f" % float(x) if len(x) > 6 else x, entries[5:])
        #######
        f.write(' & '.join(entries).replace('_', '\\_')+'\\\\\n')
        lines += 1
        if lines >= maxlines: break
    f.write('\\end{tabular}')
