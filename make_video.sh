#!/bin/sh

./epidemic 500 5 15
for f in $(ls *.dot |sort -n); do sfdp -Goverlap=scale $f -Tpng > $f.png; echo $f; done
ffmpeg -framerate '1/2' -i 'out/%03d_graph.dot.png' -s 1920x1080 out/output.webm
