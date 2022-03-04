wget -q -O - "https://www.peta.org/living/food/animal-ingredients-list/" > pagesource.txt
# copies the html of list to a text file
perl -nE 'say for /<b>(.*?)<\/b>/sg' pagesource.txt > nonveganlist.txt
# .*? -> match any character 0 or more times, say -> print but adds newline
# all ingredients are in bold so this takes everything between every occurence of <b> and </b>
# and puts them in a new file
sed -i '' 's|.$||' nonveganlist.txt #get rid of last character (full stop)
sed -i '' 's|\. |\n|g' nonveganlist.txt # replace full stops in line with newlines
sed -i '' 's|<sub>||g' nonveganlist.txt # for ingredients like vitamen B12 the 12 is enclosed in
sed -i '' 's|</sub>||g' nonveganlist.txt # sub tags
