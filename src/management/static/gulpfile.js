var gulp = require('gulp');
var fileinclude = require('gulp-file-include');
var srcfiles = './src/*.html'
var destdir = './html'

gulp.task('default', function() {
  gulp.src(srcfiles)
    .pipe(fileinclude({
      prefix: '@@',
      basepath: '@file'
    }))
    .pipe(gulp.dest(destdir));
});
