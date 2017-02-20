gulp = require 'gulp'

mainBowerFiles = require 'main-bower-files'

# path = require 'path'
connect = require 'gulp-connect'
coffee = require 'gulp-coffee'
concat = require 'gulp-concat'
uglify = require 'gulp-uglify'
sass = require 'gulp-sass'

gulp.task 'connect', ->
	connect.server
		port: 3000,
		root: './',
		# root: path.resolve('.'),
		livereload: true

# gulp.task 'bower', ->
# 	gulp.src(mainBowerFiles
# 			paths: {
# 				bowerrc: './.bowerrc',
# 				bowerJson: './bower.json'
# 			}
# 		, { base: 'assets/vendor' })
# 		.pipe(concat 'plugins.js')
# 		.pipe(uglify())
# 		.pipe(gulp.dest 'assets/scripts/js')
# 		.pipe(connect.reload())

gulp.task 'app', ->
	gulp.src(['app/app.coffee', 'app/**/*.coffee'])
		.pipe(coffee())
		# .pipe(uglify())
		.pipe(gulp.dest 'assets/scripts/js')
		.pipe(connect.reload())

gulp.task 'scripts', ->
	gulp.src('assets/scripts/coffee/**/*.coffee')
		.pipe(concat 'scripts.coffee')
		.pipe(coffee())
		# .pipe(uglify())
		.pipe(gulp.dest 'assets/scripts/js')
		.pipe(connect.reload())

gulp.task 'styles', ->
    gulp.src('assets/styles/scss/main.scss')
        .pipe(sass includePaths: ['assets/styles/scss/imports'])
        .pipe(concat 'main.css')
        .pipe(gulp.dest 'assets/styles/css')
        .pipe(connect.reload())

gulp.task 'html', ->
	gulp.src('**/*.html')
		.pipe(connect.reload())

gulp.task 'default', ->
	gulp.run 'connect', 'app', 'scripts', 'styles'

	gulp.watch 'app/**/*.coffee', ->
		gulp.run 'app'

	gulp.watch 'assets/scripts/coffee/**/*', ->
		gulp.run 'scripts'

	gulp.watch 'assets/styles/scss/**/*', ->
		gulp.run 'styles'

	gulp.watch '*.html', ->
		gulp.run 'html'
