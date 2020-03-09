#!/bin/bash

set -euo pipefail

./epidemic 22 3 10
for f in `ls out/*.dot |sort -n`; do sfdp -Goverlap=scale $f -Tpng > $f.png; echo $f; done
ffmpeg -y -framerate '1/2' -i 'out/%03d_graph.dot.png' -s 1920x1080 out/output.webm
