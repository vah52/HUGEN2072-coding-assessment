#!/bin/bash
#SBATCH -M teach
#SBATCH -A hugen2072-2026s

module load bcftools
module load vcftools
module load plink 

echo "script.sh starting:"


# 2) Copies data.vcf to your working directory 
cp /ix1/hugen2072-2026s/ca/data.vcf /ihome/hugen2071-2025f/vah52/HUGEN-2072/coding-assessment/data.vcf

# 3) Then uses bcftools to create a data4.bcf.gz file that is sorted and indexed
bcftools view data.vcf -Oz -o data2.bcf.gz
bcftools sort data2.bcf.gz -Ob -o data3.bcf.gz 
bcftools index data3.bcf.gz

# 4) Is filtered to include only positions on chromosome 4
bcftools view -r 4 data3.bcf.gz -Ob -o data4.bcf.gz
### check with: 
bcftools view data4.bcf.gz -G | grep -v "##" | head

# 5) Then uses PLINK to create a PLINK binary file set version of data4.bcf.gz called data4.{fam,bim,bed};
plink --bcf data4.bcf.gz --make-bed --out data4

# 6) Then uses PLINK to update sex variable in the data4.fam file using the sex variable in sex.txt (without copying sex.txt to your own directory),
plink --bfile data4 --update-sex /ix1/hugen2072-2026s/ca/sex.txt --make-bed --out data4

# 7) Then uses PLINK, coupled with the phenotypes in phenotype.txt (without copying phenotype.txt to your own directory—and you should use phenotype.txt as an auxiliary file for the next few tasks without altering data4.fam to include phenotype data), to:
head -n 5 /ix1/hugen2072-2026s/ca/phenotype.txt 
tail -n 5 /ix1/hugen2072-2026s/ca/phenotype.txt

### 1 - unaffected (controls), 2 - affected (cases)
### add phenotypes to data4 <-- nevermind!
### plink --bfile data4 --pheno /ix1/hugen2072-2026s/ca/phenotype.txt --make-bed --out data4

# 8) Calculate the allele frequencies of the markers in data4.{fam,bim,bed} in the cases only 
grep -w 2 /ix1/hugen2072-2026s/ca/phenotype.txt > phe-cases.txt | plink --bfile data4 --keep phe-cases.txt --freq --make-bed --out data4-cases

# 9)  Calculate the allele frequencies of the markers in data4.{fam,bim,bed} in the controls only
grep -w 1 /ix1/hugen2072-2026s/ca/phenotype.txt > phe-ctrls.txt | plink --bfile data4 --keep phe-ctrls.txt --freq --make-bed --out data4-controls

# 10) Performs a GWAS of the phenotype using logistic regression with no covariates.
plink --bfile data4 --pheno /ix1/hugen2072-2026s/ca/phenotype.txt --logistic --out gwas

echo "script.sh finished running."
