-------------------
prepare:
install nodejs and gulp(global):
1.yum install -y nodejs
2.npm install -g gulp  #instal global gulp
3.npm install gulp  #install local gulp
4.npm install gulp-file-include

-------------------
run:
1.gulp install    #install local gulp (dependency in "./package.json")
2.gulp fileinclude   #run gulp task "fileinclude" (config in "./gulpfile.js") 
