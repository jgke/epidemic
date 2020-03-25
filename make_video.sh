#!/bin/bash

set -euo pipefail

./epidemic 20 0.5 true
for f in `ls out/*.dot |sort -n`; do sfdp -Gdpi=15 -Goverlap=scale $f -Tpng > $f.png; echo $f; done
ffmpeg -y -r 2 -i 'out/%03d_graph.dot.png' -vf scale=1024:-1 -c:v libvpx-vp9 -pix_fmt yuva420p -lossless 1 -r 2 out/output.webm
