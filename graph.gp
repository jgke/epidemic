set datafile separator ","
set terminal png size 480,400 enhanced truecolor font 'Verdana,9'
set output "output.png"
set ylabel "Persons"
set xlabel "Tick"
set yrange [0:10<*]
set pointsize 0.8
set border 11
set xtics out
set tics front
set key below
plot \
  "out.csv" using 1:3 title 'Dead' with filledcurves x1 lc "black", \
  "out.csv" using 1:4 title 'Infected' with filledcurves x1 lc "red", \
  "out.csv" using 1:5 title 'Immune' with filledcurves x1 lc "gray"
