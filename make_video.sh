#!/bin/bash

set -euo pipefail

./epidemic 10 3 30
for f in `ls out/*.dot |sort -n`; do sfdp -Goverlap=scale $f -Tpng > $f.png; echo $f; done
ffmpeg -y -framerate '1' -i 'out/%03d_graph.dot.png' -vf scale=1920:-1 out/output.webm
