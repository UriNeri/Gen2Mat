#!/bin/bash
#hostname

if [[ $# -eq 0 ]] ; then
  echo '   
   Arguments:
   #  Desc (suggestion) 
   1  Threads
   2  Memory in Mb
   3  output directory
   4  Input directory  (one file *.faa file per genome)
   5  Water mark passed to .env (some text, deafult is date).
   6  Minimal id for preclustering sequence collapsing (0.9) 
   7  Minimal coverage for preclustering (0.75) (-aS in cd-hit, aligment coverage of the smaller seq)
   8  Output similarity ("Sym") or dissimilarity (not "Sym").
'
exit
fi
##################################################################################################
THREADS=$1
Memory=$2
output_dir=$3
input_dir=$4
watermark=$5 #(0.0000000001 70 0.5 300) # [<E-value,score1/score/bits,min_alignment_coverage,qlen>]
min_prec_id=$6 #0.90 
min_prec_cov=$7 #0.75

script_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
clstr2txt="$script_DIR"/clstr2txt.pl

Genome_list=$(ls $input_dir | sed 's|.faa||g')
Ngenomes=$(wc -w <<< "$Genome_list")
mkdir $output_dir
cd $output_dir
cp $input_dir/* $output_dir
grep ">" -F ./*.faa | sed 's|./|:>|g' | sed 's|.faa||g'|nl |sed 's| ||g' | awk -F":>"   '{print $3"\t"$2"."$1}'   > Gene_Lookup.tsv
cat ./*.faa > cated_proteins.faa
awk 'FNR==NR { a[">"$1]=$2; next } $1 in a { sub(/>/,">"a[$1]" |",$1)}1' Gene_Lookup.tsv cated_proteins.faa > nmnorm.faa
input_fasta="$output_dir"/nmnorm.faa
mkdir fastaFiles Clusteringfiles 
cd-hit -n 3 -M $Memory -T $THREADS  -i $input_fasta -o Clusteringfiles/Cls_c"$min_prec_id"_aS"$min_prec_cov" -aS $min_prec_cov -c $min_prec_id  
perl $clstr2txt ./Clusteringfiles/Cls_c"$min_prec_id"_aS"$min_prec_cov".clstr > formated.clstr 
Nclstrs=$(awk '{print $2}' formated.clstr |sort -u |wc -l)
for genome in ${Genome_list[*]} 
do
  echo "Looking clusters with $genome members"
  grep $genome -F ./formated.clstr  | awk '{print $2}' |sort -u > "$genome"_clstrs.txt
done
mkdir GenomeXGenome 
cd GenomeXGenome
i=1
for genome_1 in ${Genome_list[*]} 
do
  j=1
for genome_2 in ${Genome_list[*]} 
do
echo "Looking clusters shared between $genome_1 AND $genome_2"
comm  ../"$genome_1"_clstrs.txt ../"$genome_2"_clstrs.txt > tmp 
header=$(echo $genome_1'\t'$genome_2'\t'$genome_1"_AND_"$genome_2)
sed "1 i$header" tmp > ./"$genome_1"_vs_"$genome_2".tsv 
if [ "$8" == "Sym" ]; 
then
  Nshared=$(awk -F'\t' '{print $3}' ./"$genome_1"_vs_"$genome_2".tsv  |sort -u |echo "$(($(wc -l)-1))")
fi
if [ "$8" != "Sym" ]; 
then
  Nshared=$(awk -F'\t' '{print $1}' ./"$genome_1"_vs_"$genome_2".tsv  |sort -u |echo "$(($(wc -l)-2))")
fi
echo $Nshared > "$i"_"$j".Nshared
j=$((j+1))
done
i=$((i+1))
done
rm tmp
declare -A matrix
num_rows=$Ngenomes
num_columns=$Ngenomes

for ((i=1;i<=num_rows;i++)) do
    for ((j=1;j<=num_columns;j++)) do
        matrix[$i,$j]=$(cat "$i"_"$j".Nshared)
    done
done

f1="%$((${#num_rows}+1))s"
f2=" %9s"

printf "$f1" ''
for ((i=1;i<=num_rows;i++)) do
    printf "$f2" $i
done
echo

for ((j=1;j<=num_columns;j++)) do
    printf "$f1" $j
    for ((i=1;i<=num_rows;i++)) do
        printf "$f2" ${matrix[$i,$j]}
    done
    echo
done > tmp
awk '{for (i=2; i<NF; i++) printf $i " "; print $NF}' tmp > tmp_matrix.tsv
headers=$(echo " "$Genome_list)
ls $input_dir -l | awk '{print $9}' |sed 's|.faa||g' > rowids.txt
sed  "1 i$headers" tmp_matrix.tsv >tmp
paste -d' ' rowids.txt tmp > tmp_matrix.tsv
sed 's| |\t|g' tmp_matrix.tsv > ../Genome_Matrix.tsv
rm *.Nshared
rm tmp tmp_matrix.tsv rowids.txt
cd ..
mv *clstr* ./Clusteringfiles/
mv *.faa ./fastaFiles/
echo "Enviroment_parameters: 
Total number of clusters prefix = $Nclstrs 
Clustering id >= $min_prec_id 
Clustering coverage >= $min_prec_cov 
Watermark $(echo ${watermark[*]})
Call command $0
$(date)
" > "$(date | awk '{print $4}' | sed 's|:|_|g')"_Gen2MatRun.env

echo "Done."