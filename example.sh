Gen2Mat_script="/home/uri/Documents/GitHub/Gen2Mat/Gen2Mat.sh"
THREADS=11
Memory=4800
output_dir="/media/uri/6a9dcae2-3419-40f7-9bb2-41b679f9909e/uri/projects/Gen2Mat/output"
input_dir="/media/uri/6a9dcae2-3419-40f7-9bb2-41b679f9909e/uri/projects/Gen2Mat/Genoems/"
watermark="28.06.2020" #Irelevant 
min_prec_id=0.75
min_prec_cov=0.75
 
bash $Gen2Mat_script $THREADS $Memory $output_dir $input_dir $watermark $min_prec_id $min_prec_cov
