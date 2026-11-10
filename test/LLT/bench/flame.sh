
perf record -e cpu-clock -g ./main 
perf script -i perf.data > perf.unfold 
stackcollapse-perf.pl perf.unfold > perf.folded 

svgname=1
flamegraph.pl perf.folded > ${svgname}.svg 
x-www-browser ${svgname}.svg