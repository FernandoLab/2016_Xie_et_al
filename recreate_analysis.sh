#!/bin/bash

#File to recreate the analysis from Xie et al. manuscript. To run, simply call the script with the link to a usearch download as the lone argument (see below)

if [ "$1" = "" ]; then
    printf "\nProvide a link for USEARCH download (from email) as argument.\nGet a license from http://www.drive5.com/usearch/download.html\nSee the associated github README file for details.\n\n"
    exit 1
fi

wget https://3230d63b5fc54e62148e-c95ac804525aac4b6dba79b00b39d1d3.ssl.cf1.rackcdn.com/Anaconda-2.3.0-MacOSX-x86_64.sh
bash Anaconda-2.3.0-MacOSX-x86_64.sh
#wget https://3230d63b5fc54e62148e-c95ac804525aac4b6dba79b00b39d1d3.ssl.cf1.rackcdn.com/Anaconda-2.3.0-Linux-x86_64.sh
#bash Anaconda-2.3.0-Linux-x86_64.sh

anaconda/bin/conda create -n wood_lab python pip numpy matplotlib scipy pandas cython mock nose
source anaconda/bin/activate wood_lab
pip install https://github.com/biocore/qiime/archive/1.9.0.tar.gz
#conda install -c https://conda.binstar.org/jorge qiime
anaconda/bin/conda install -c https://conda.binstar.org/r rpy2

wget -O anaconda/envs/wood_lab/bin/usearch $1
chmod 775 anaconda/envs/wood_lab/bin/usearch

mkdir fastx
cd fastx
wget http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_MacOSX.10.5.8_i386.tar.bz2
bzip2 -d fastx_toolkit_0.0.13_binaries_MacOSX.10.5.8_i386.tar.bz2
tar -xvf fastx_toolkit_0.0.13_binaries_MacOSX.10.5.8_i386.tar
#wget http://hannonlab.cshl.edu/fastx_toolkit/fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2
#bzip2 -d fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar.bz2
#tar -xvf fastx_toolkit_0.0.13_binaries_Linux_2.6_amd64.tar
cd ..
mv fastx/bin/* anaconda/envs/wood_lab/bin/
rm -rf fastx

#wget https://github.com/mothur/mothur/releases/download/v1.35.1/Mothur.cen_64.zip
#unzip Mothur.cen_64.zip
#mv mothur/mothur anaconda/envs/rumenEnv/bin/
#rm Mothur.cen_64.zip
wget https://github.com/mothur/mothur/releases/download/v1.35.1/Mothur.mac_64.OSX-10.9.zip
unzip Mothur.mac_64.OSX-10.9.zip
mv mothur/mothur anaconda/envs/wood_lab/bin/
rm Mothur.mac_64.OSX-10.9.zip
rm -rf mothur
rm -rf __MACOSX


tar -zxvf wood_lab_16S_raw0.tgz
tar -zxvf wood_lab_16S_raw1.tgz
cat wood_lab_16S_raw0.fna wood_lab_16S_raw1.fna > wood_lab_16S_raw_cat.fna 

##QC
source anaconda/bin/activate wood_lab
split_libraries.py -m mapping.txt -f wood_lab_16S_raw_cat.fna -b variable_length -l 0 -L 1000 -M 1 -o wood_split
truncate_reverse_primer.py -f wood_split/seqs.fna -o wood.split.rev_primer.fna -m mapping.txt -z truncate_only -M 2
mothur "#trim.seqs(fasta=wood.split.rev_primer.fna/seqs_rev_primer_truncated.fna, minlength=130)"
fastx_trimmer -i wood.split.rev_primer.fna/seqs_rev_primer_truncated.trim.fasta -l 130 -o wood.split_rev_primer_truncated.trim.trim.fasta
mothur "#reverse.seqs(fasta=wood.split_rev_primer_truncated.trim.trim.fasta)"

##Pick OTUs
./qiime_to_usearch.pl -fasta=wood.split_rev_primer_truncated.trim.trim.rc.fasta -prefix=mouse
mv format.fasta wood.usearch_input.fasta

gzip -d gold.fasta.gz
chmod 775 gold.fasta
chmod -R 775 usearch_python_scripts/

usearch -derep_fulllength wood.usearch_input.fasta -sizeout -output wood.derep.fa
usearch -sortbysize wood.derep.fa -minsize 2 -output wood.derep.sort.fa
usearch -cluster_otus wood.derep.sort.fa -otus wood.otus1.fa
usearch -uchime_ref wood.otus1.fa -db gold.fasta -strand plus -nonchimeras wood.otus1.nonchimera.fa
usearch_python_scripts/fasta_number.py wood.otus1.nonchimera.fa > wood.otus2.fa
usearch -usearch_global wood.usearch_input.fasta -db wood.otus2.fa -strand plus -id 0.97 -uc wood.otu_map.uc
python usearch_python_scripts/uc2otutab.py wood.otu_map.uc > wood.otu_table.txt

#Assign taxonomy - initial analysis used an older version of gg database, so fetch that to recreate
wget ftp://greengenes.microbio.me/greengenes_release/gg_12_10/gg_12_10_otus.tar.gz
tar -zxvf gg_12_10_otus.tar.gz
assign_taxonomy.py -i wood.otus2.fa -t gg_12_10_otus/taxonomy/97_otu_taxonomy.txt -r gg_12_10_otus/rep_set/97_otus.fasta -o assign_gg_taxa/
awk 'NR==1; NR > 1 {print $0 | "sort"}' wood.otu_table.txt > wood.otu_table.sort.txt 
sort assign_gg_taxa/wood.otus2_tax_assignments.txt > assign_gg_taxa/wood.otus2_tax_assignments.sort.txt
{ printf '\ttaxonomy\t\t\n'; cat assign_gg_taxa/wood.otus2_tax_assignments.sort.txt ; }  > assign_gg_taxa/wood.otus2_tax_assignments.sort.label.txt
paste wood.otu_table.sort.txt <(cut -f 2 assign_gg_taxa/wood.otus2_tax_assignments.sort.label.txt) > wood.otu_table.tax.txt
rm wood.otu_table.sort.txt
biom convert --table-type "OTU table" -i wood.otu_table.tax.txt -o wood.otu_table.tax.biom --process-obs-metadata taxonomy --to-json
biom summarize-table -i wood.otu_table.tax.biom -o summarize_wood.otu_table.txt

#Algin OTUs
printf "\n\n\nUsing the RDP alignment file on github to continue analysis. To recreate this step yourself, use the wood.otus2.fa file and upload it to https://pyro.cme.msu.edu/aligner/form.spr. Resulting file is aligned_wood.otus2.fa\n\n"
sleep 15
printf "\n\n\nUsing file manually created (remove_otus.txt) to remove OTUs that did not align well\n\n"
sleep 15
filter_otus_from_otu_table.py -i wood.otu_table.tax.biom -o wood.otu_table.filter.biom -e remove_otus.txt 

#Remove samples that qpcr was not done for and remove singleton OTUs that remain
filter_otus_from_otu_table.py -i wood.otu_table.filter.biom -o wood.otu_table.no_singletons.biom -n 2
filter_samples_from_otu_table.py -i wood.otu_table.no_singletons.biom --sample_id_fp sample_ids_new.txt -o wood.otu_table.new_samples.biom
filter_otus_from_otu_table.py -i wood.otu_table.new_samples.biom -o wood.otu_table.for_maaslin.biom -n 1
sort_otu_table.py -i wood.otu_table.for_maaslin.biom -o wood.otu_table.for_maaslin.sort.biom -m mapping.txt -s SampleID

#run R script to calculate OTU relative abundances and add metadata
R CMD BATCH setup_maaslin.R

printf "\n\n\nAnalysis complete, the file wood.otu_table.upload_maaslin.txt was used to upload to MaAsLin (default parameters) to identify correlations - http://huttenhower.sph.harvard.edu/galaxy/\n\n"
printf "Output - wood_maaslin_output.txt - is available in the cloned github repository or at https://github.com/chrisLanderson/2015_PNAS_Xie_et_al\n\n"


