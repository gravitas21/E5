#!/bin/bash
m=0
# standard C-C bond length in Graphite  a = 1.421 A or 2.685 Bohr ,c by a ratio is 2.4 to 2.7
mmax=12
while [ "$m" -le "$mmax" ]
do
alen=`echo "2.1+0.05*$m" | bc -l`

n=0
nmax=12
while [ "$n" -le "$nmax" ]
do
cbya=`echo "2.2+0.05*$n" | bc -l`
clen=`echo "$alen*$cbya" | bc -l`

cat >scf.in<<EOF
&CONTROL
  calculation  = 'scf'
  prefix       = 'Graphite'
  disk_io      = 'none'
  pseudo_dir   = '/home/qe2020n_099/scr0/Rough'
  outdir       = './'
/
&SYSTEM
  ibrav     = 4 ! standard C-C bond length = 1.421 A or 2.685 Bohr
  a=$alen,b=$alen,c= $clen
  nat       = 4
  ntyp      = 1
  ecutwfc   = 24.d0
  ecutrho   = 144.d0
/
&ELECTRONS
  conv_thr    = 1.0d-07
  mixing_beta = 0.70d0
/
&IONS
  ion_dynamics      = 'bfgs'
  pot_extrapolation = 'atomic'
  wfc_extrapolation = 'none'
/
ATOMIC_SPECIES
  C  12.0107  C.pz-vbc.UPF
ATOMIC_POSITIONS {crystal}
  C  0.00000  0.00000  0.25000  
  C  0.00000  0.00000  0.75000
  C  0.33333  0.66667  0.25000
  C  0.66667  0.33333  0.75000  
K_POINTS automatic
 8 8 8 1 1 1
EOF
prun pw.x -nk 1 -npw 4 -inp scf.in > scf.out
te=`grep ! scf.out | tail -1 | awk '{print $5}'`
echo "$cbya $alen  $te" >> etot.dat
mv scf.in scf$m.$n.in
mv scf.out scf$m.$n.out

let n=$n+1
done

let m=$m+1
done

