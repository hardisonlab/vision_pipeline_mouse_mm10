echo V_F_S

echo level uniq
echo V uniq
bedtools window -a atac_20cell.fun.no0.bed.txt -b FLD_PEAKS_merged_mm10.txt -w 150 -v > V_X_0_X.bed
bedtools window -a V_X_0_X.bed -b SCREEN_FetLiv14_5_mm10_bed_2017.txt -w 150 -v > V_X_0_0.bed
echo F uniq
bedtools window -a FLD_PEAKS_merged_mm10.txt -b atac_20cell.fun.no0.bed.txt -w 150 -v > 0_X_F_X.bed
bedtools window -a 0_X_F_X.bed -b SCREEN_FetLiv14_5_mm10_bed_2017.txt -w 150 -v > 0_X_F_0.bed
echo S uniq
bedtools window -a SCREEN_FetLiv14_5_mm10_bed_2017.txt -b atac_20cell.fun.no0.bed.txt -w 150 -v > 0_X_X_S.bed
bedtools window -a 0_X_X_S.bed -b FLD_PEAKS_merged_mm10.txt -w 150 -v > 0_X_0_S.bed


echo level 2 uniq
echo V_X_F_0 
bedtools window -a atac_20cell.fun.no0.bed.txt -b FLD_PEAKS_merged_mm10.txt -w 150 -u > V_X_F_X.bed
bedtools window -a V_X_F_X.bed -b SCREEN_FetLiv14_5_mm10_bed_2017.txt -w 150 -v > V_X_F_0.bed
echo V_X_0_S 
bedtools window -a V_X_0_X.bed -b SCREEN_FetLiv14_5_mm10_bed_2017.txt -w 150 -u > V_X_0_S.bed
echo 0_X_F_S
bedtools window -a FLD_PEAKS_merged_mm10.txt -b SCREEN_FetLiv14_5_mm10_bed_2017.txt -w 150 -u > X_X_F_S.bed
bedtools window -a X_X_F_S.bed -b atac_20cell.fun.no0.bed.txt -w 150 -v > 0_X_F_S.bed

echo level 3 uniq
echo V_X_F_X
bedtools window -a V_X_F_X.bed -b SCREEN_FetLiv14_5_mm10_bed_2017.txt -w 150 -u > V_X_F_S.bed



cut -f1,2,3 V_X_0_0.bed > V_X_0_0.01.bed
cut -f1,2,3 0_X_F_0.bed > 0_X_F_0.01.bed
cut -f1,2,3 0_X_0_S.bed > 0_X_0_S.01.bed
cut -f1,2,3 V_X_F_0.bed > V_X_F_0.01.bed
cut -f1,2,3 V_X_0_S.bed > V_X_0_S.01.bed
cut -f1,2,3 0_X_F_S.bed > 0_X_F_S.01.bed
cut -f1,2,3 V_X_F_S.bed > V_X_F_S.01.bed

echo get intersect with known ccREs
#bedtools window -a Known_erythroid_REs_2017_mm10.txt -b V_X_0_0.01.bed -w 150 -u > V_X_0_0.01.K.bed
#bedtools window -a Known_erythroid_REs_2017_mm10.txt -b 0_X_F_0.01.bed -w 150 -u > 0_X_F_0.01.K.bed
#bedtools window -a Known_erythroid_REs_2017_mm10.txt -b 0_X_0_S.01.bed -w 150 -u > 0_X_0_S.01.K.bed
#bedtools window -a Known_erythroid_REs_2017_mm10.txt -b V_X_F_0.01.bed -w 150 -u > V_X_F_0.01.K.bed
#bedtools window -a Known_erythroid_REs_2017_mm10.txt -b V_X_0_S.01.bed -w 150 -u > V_X_0_S.01.K.bed
#bedtools window -a Known_erythroid_REs_2017_mm10.txt -b 0_X_F_S.01.bed -w 150 -u > 0_X_F_S.01.K.bed
#bedtools window -a Known_erythroid_REs_2017_mm10.txt -b V_X_F_S.01.bed -w 150 -u > V_X_F_S.01.K.bed

wc -l *_X_*_*.01.K.bed

#ls *_X_*_*.01.bed > VFS_list.txt
#ls *_X_*_*.01.K.bed | awk -F '.' '{print $1}' | awk -F '_' -v OFS='_' '{print $1,$3,$4, "K"}' >> VFS_list.txt

echo get ven diagram
#python plot_ven.py -l VFS_list.txt

for file in $(cat VFS_list.txt)
do
	echo file
	pattern=$(echo "$file" | awk -F '.' '{print $1}')
	bedtools window -a Known_erythroid_REs_2017_mm10.txt -b $pattern'.01.bed' -w 150 -u > $pattern'.01.K.bed'
done


echo intersect with EP300
echo Download bed narrow peaks (conservative idr thresholded peaks) from ENCODE
echo unzip *.gz files
gunzip -k *.gz
ls ENC*.bed > EP300_list.txt
for ep300_t in $(cat EP300_list.txt)
do
	ct=$(echo "$ep300_t" | awk -F '.' '{print $2}')
	echo $ct
	bedtools window -a $ep300_t -b V_X_0_0.01.bed -w 150 -u > 'V_X_0_0.'$ct'.bed'
	Rscript expect_vs_obs.R 'V_X_0_0.'$ct'.bed' V_X_0_0.01.bed $ep300_t 2725521370 'V_X_0_0.'$ct'.VFS'
	bedtools window -a $ep300_t -b 0_X_F_0.01.bed -w 150 -u > '0_X_F_0.'$ct'.bed'
	Rscript expect_vs_obs.R '0_X_F_0.'$ct'.bed' 0_X_F_0.01.bed $ep300_t 2725521370 '0_X_F_0.'$ct'.VFS'
	bedtools window -a $ep300_t -b 0_X_0_S.01.bed -w 150 -u > '0_X_0_S.'$ct'.bed'
	Rscript expect_vs_obs.R '0_X_0_S.'$ct'.bed' 0_X_0_S.01.bed $ep300_t 2725521370 '0_X_0_S.'$ct'.VFS'
	bedtools window -a $ep300_t -b V_X_F_0.01.bed -w 150 -u > 'V_X_F_0.'$ct'.bed'
	Rscript expect_vs_obs.R 'V_X_F_0.'$ct'.bed' V_X_F_0.01.bed $ep300_t 2725521370 'V_X_F_0.'$ct'.VFS'
	bedtools window -a $ep300_t -b V_X_0_S.01.bed -w 150 -u > 'V_X_0_S.'$ct'.bed'
	Rscript expect_vs_obs.R 'V_X_0_S.'$ct'.bed' V_X_0_S.01.bed $ep300_t 2725521370 'V_X_0_S.'$ct'.VFS'
	bedtools window -a $ep300_t -b 0_X_F_S.01.bed -w 150 -u > '0_X_F_S.'$ct'.bed'
	Rscript expect_vs_obs.R '0_X_F_S.'$ct'.bed' 0_X_F_S.01.bed $ep300_t 2725521370 '0_X_F_S.'$ct'.VFS'
	bedtools window -a $ep300_t -b V_X_F_S.01.bed -w 150 -u > 'V_X_F_S.'$ct'.bed'
	Rscript expect_vs_obs.R 'V_X_F_S.'$ct'.bed' V_X_F_S.01.bed $ep300_t 2725521370 'V_X_F_S.'$ct'.VFS'
	mkdir 'EP300_VFS_'$ct
	mv *'_'*'_'*'_'*'.'$ct'.bed' 'EP300_VFS_'$ct
done

mkdir VFS_enrich
mv *.VFS.enrichment.txt VFS_enrich

echo get heatmap
cd VFS_enrich
ls *VFS.enrichment.txt | awk -F '.' '{print $1}' | sort -u > intersect_pattern.txt
for pattern in $(cat intersect_pattern.txt)
do
	echo $pattern
	tail -n+2 $pattern'.CH12.VFS.enrichment.txt' >> CH12.enrichment.txt
	tail -n+2 $pattern'.Fetal_Liver.VFS.enrichment.txt' >> Fetal_Liver.enrichment.txt
	tail -n+2 $pattern'.MEL.VFS.enrichment.txt' >> MEL.enrichment.txt
done
paste intersect_pattern.txt CH12.enrichment.txt Fetal_Liver.enrichment.txt MEL.enrichment.txt > VFS.enrich.matrix.txt
rm CH12.enrichment.txt Fetal_Liver.enrichment.txt MEL.enrichment.txt

echo plot heatmap
Rscript /Users/universe/Documents/2018_BG/great_analysis_vision_vs_others/windows/get_enrichment_heatmap.R VFS.enrich.matrix.txt VFS.enrich.matrix.png

echo all 4 sets
mkdir all_4
cp *.01.bed all_4/
cd all_4
rm *X*.01.bed
ls *.01.bed > all_4_list.txt

for ep300_t in $(cat /Users/universe/Documents/2018_BG/great_analysis_vision_vs_others/windows/EP300_list.txt)
do
	ct=$(echo "$ep300_t" | awk -F '.' '{print $2}')
	echo $ct
	for pattern in $(cat all_4_list.txt)
	do
		pattern_4=$(echo "$pattern" | awk -F '.' '{print $1}')
		bedtools window -a '/Users/universe/Documents/2018_BG/great_analysis_vision_vs_others/windows/'$ep300_t -b $pattern_4'.01.bed' -w 150 -u > $pattern_4'.'$ct'.bed'
		Rscript /Users/universe/Documents/2018_BG/great_analysis_vision_vs_others/windows/expect_vs_obs.R $pattern_4'.'$ct'.bed' $pattern_4'.01.bed' '/Users/universe/Documents/2018_BG/great_analysis_vision_vs_others/windows/'$ep300_t 2725521370 $pattern_4'.'$ct'.all4'
	done
	mkdir 'EP300_all4_'$ct
	mv *'_'*'_'*'_'*'.'$ct'.bed' 'EP300_all4_'$ct
done

mkdir all4_enrich
mv *.all4.enrichment.txt all4_enrich

echo get heatmap
cd all4_enrich
ls *all4.enrichment.txt | awk -F '.' '{print $1}' | sort -u > intersect_pattern.txt
for pattern in $(cat intersect_pattern.txt)
do
	echo $pattern
	tail -n+2 $pattern'.CH12.all4.enrichment.txt' >> CH12.enrichment.txt
	tail -n+2 $pattern'.Fetal_Liver.all4.enrichment.txt' >> Fetal_Liver.enrichment.txt
	tail -n+2 $pattern'.MEL.all4.enrichment.txt' >> MEL.enrichment.txt
done
paste intersect_pattern.txt CH12.enrichment.txt Fetal_Liver.enrichment.txt MEL.enrichment.txt > all4.enrich.matrix.txt
rm CH12.enrichment.txt Fetal_Liver.enrichment.txt MEL.enrichment.txt

echo plot heatmap
Rscript /Users/universe/Documents/2018_BG/great_analysis_vision_vs_others/windows/get_enrichment_heatmap.R all4.enrich.matrix.txt all4.enrich.matrix.png



