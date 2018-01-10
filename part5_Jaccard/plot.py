import matplotlib
matplotlib.use('Agg')
import seaborn
import pandas
import matplotlib.pyplot as plt 
import sys


indir=sys.argv[1]


data = pandas.read_csv(indir+"/index.csv", sep='\t')
data["test"] = data.apply(lambda x: x.name1 + '_' + x.name2, axis=1)



fig = seaborn.boxplot(x="Jaccardindex", y="test", data=data)
seaborn.swarmplot(x="Jaccardindex", y="test", data=data, color=".3", linewidth=0)

fig.xaxis.grid(True)
fig.set(ylabel="", xlim=(0,1))
seaborn.despine(trim=True, left=True)

plt.tight_layout()

plt.savefig(indir+"/Jaccard.png")
plt.clf()




data2 = data.copy()
data2["tmp"] = data2["name1"] 
data2["name1"] = data2["name2"]
data2["name2"] = data2["tmp"]
data2["tmp"] = data2["%common1"] 
data2["%common1"] = data2["%common2"]
data2["%common2"] = data2["tmp"]
data2 = data2.drop("tmp", 1)

data = pandas.concat([data, data2])


fig = seaborn.boxplot(data=data, x="name1", y="%common1", hue="name2", palette=seaborn.color_palette('muted'))
plt.xticks(rotation=10)
fig.set(ylabel='% of probe1 uniquely mapped reads common with probe2')
plt.savefig(indir+"/mapped.png")
plt.clf()



fig = seaborn.lmplot(data=data, x="%common1", y="Jaccardindex", hue='name2', col='name1', fit_reg=False, palette=seaborn.color_palette('muted'))
fig.set(ylabel='% of probe1 uniquely mapped reads common with probe2')
plt.savefig(indir+"/lmplot.png")
plt.clf()



#fig = seaborn.lmplot(data=data, x="%common1", y="%common1", hue='name1', fit_reg=False, palette=seaborn.color_palette('muted'))
#fig.set(ylabel='% of probe1 uniquely mapped reads common with probe2')
#plt.savefig(indir+"/common_mapped.png")
#plt.clf()




